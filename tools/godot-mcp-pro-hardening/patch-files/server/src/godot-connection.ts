import { WebSocketServer, WebSocket } from "ws";
import { randomUUID } from "crypto";
import { createServer } from "net";
import {
  JsonRpcRequest,
  JsonRpcResponse,
  PendingRequest,
} from "./utils/types.js";
import {
  GodotConnectionError,
  GodotCommandError,
  TimeoutError,
} from "./utils/errors.js";
import { BridgeLockHeartbeat, getDefaultBridgeLockRoot } from "./utils/bridge-lock.js";

const BASE_PORT = 6505;
const MAX_PORT = 6534;
const COMMAND_TIMEOUT_MS = 30000;
const HEARTBEAT_INTERVAL_MS = 10000;
export const DEFAULT_RESERVED_CLI_PORTS = [6510, 6511, 6512, 6513, 6514];

export function parsePortList(value: string | undefined): number[] {
  if (!value) return [];
  const ports = new Set<number>();
  for (const rawPart of value.split(",")) {
    const part = rawPart.trim();
    if (!part) continue;
    const rangeMatch = part.match(/^(\d+)\s*-\s*(\d+)$/);
    if (rangeMatch) {
      const start = parseInt(rangeMatch[1], 10);
      const end = parseInt(rangeMatch[2], 10);
      for (let p = Math.min(start, end); p <= Math.max(start, end); p++) ports.add(p);
      continue;
    }
    const port = parseInt(part, 10);
    if (!Number.isNaN(port)) ports.add(port);
  }
  return [...ports].sort((a, b) => a - b);
}

export function buildCandidatePorts(
  basePort: number = parseInt(process.env.GODOT_MCP_BASE_PORT || `${BASE_PORT}`, 10),
  maxPort: number = parseInt(process.env.GODOT_MCP_MAX_PORT || `${MAX_PORT}`, 10),
  reservedPorts: number[] = parsePortList(process.env.GODOT_MCP_RESERVED_PORTS).length > 0
    ? parsePortList(process.env.GODOT_MCP_RESERVED_PORTS)
    : DEFAULT_RESERVED_CLI_PORTS
): number[] {
  const reserved = new Set(reservedPorts);
  const ports: number[] = [];
  for (let p = basePort; p <= maxPort; p++) {
    if (!reserved.has(p)) ports.push(p);
  }
  return ports;
}

export function normalizeWorkspacePath(path: string): string {
  return path.replace(/\\/g, "/").replace(/\/+$/g, "").toLowerCase();
}

/** Check if a port is available */
function isPortFree(port: number): Promise<boolean> {
  return new Promise((resolve) => {
    const server = createServer();
    server.once("error", () => resolve(false));
    server.once("listening", () => {
      server.close(() => resolve(true));
    });
    server.listen(port, "127.0.0.1");
  });
}

export class GodotConnection {
  private wss: WebSocketServer | null = null;
  private client: WebSocket | null = null;
  private port: number;
  private strictPort: boolean;
  private pendingRequests: Map<string, PendingRequest> = new Map();
  private heartbeatTimer: ReturnType<typeof setInterval> | null = null;
  private candidatePorts: number[];
  private reservedCliPorts: number[];
  private lastError: string | null = null;
  private bridgeLock: BridgeLockHeartbeat;

  constructor(
    port: number = BASE_PORT,
    strictPort: boolean = false,
    private readonly workspace: string = process.cwd(),
    private readonly sessionId: string = randomUUID(),
    private readonly version: string = "unknown"
  ) {
    this.port = port;
    this.strictPort = strictPort;
    this.reservedCliPorts = parsePortList(process.env.GODOT_MCP_RESERVED_PORTS);
    if (this.reservedCliPorts.length === 0) this.reservedCliPorts = DEFAULT_RESERVED_CLI_PORTS;
    this.candidatePorts = buildCandidatePorts(undefined, undefined, this.reservedCliPorts);
    this.bridgeLock = new BridgeLockHeartbeat(
      getDefaultBridgeLockRoot(),
      this.workspace,
      this.sessionId,
      this.version
    );
  }

  /** Start WebSocket server on first available port in range */
  async connect(): Promise<void> {
    if (this.wss) return;

    const chosenPort = await this.choosePort();
    this.port = chosenPort;

    return new Promise<void>((resolve, reject) => {
      let settled = false;
      this.wss = new WebSocketServer({ port: this.port, host: "127.0.0.1" });

      this.wss.on("listening", () => {
        this.lastError = null;
        this.bridgeLock.start(this.port);
        console.error(
          `[MCP] WebSocket server listening on ws://127.0.0.1:${this.port}`
        );
        settled = true;
        resolve();
      });

      this.wss.on("error", (err: Error) => {
        this.lastError = err.message;
        console.error("[MCP] WebSocket server error:", err.message);
        this.cleanupFailedServer();
        if (!settled) {
          settled = true;
          reject(err);
        }
      });

      this.wss.on("connection", (ws: WebSocket) => {
        console.error("[MCP] Godot editor connected; waiting for workspace handshake");

        ws.on("message", (data: Buffer) => {
          this.handleMessage(data.toString(), ws);
        });

        ws.on("close", () => {
          console.error("[MCP] Godot editor disconnected");
          if (this.client === ws) {
            this.client = null;
            this.stopHeartbeat();
            this.rejectAllPending(
              new GodotConnectionError("Godot disconnected")
            );
          }
        });

        ws.on("error", (err: Error) => {
          console.error("[MCP] WebSocket error:", err.message);
        });
      });
    });
  }

  disconnect(): void {
    this.stopHeartbeat();
    this.bridgeLock.stop();
    if (this.client) {
      this.client.close(1000, "Server shutting down");
      this.client = null;
    }
    if (this.wss) {
      this.wss.close();
      this.wss = null;
    }
    this.rejectAllPending(new GodotConnectionError("Server shut down"));
  }

  isConnected(): boolean {
    return this.client?.readyState === WebSocket.OPEN;
  }

  getPort(): number {
    return this.port;
  }

  getCandidatePorts(): number[] {
    return [...this.candidatePorts];
  }

  getReservedCliPorts(): number[] {
    return [...this.reservedCliPorts];
  }

  getWorkspace(): string {
    return this.workspace;
  }

  getSessionId(): string {
    return this.sessionId;
  }

  isListening(): boolean {
    return this.wss !== null;
  }

  getPendingRequestCount(): number {
    return this.pendingRequests.size;
  }

  getLastError(): string | null {
    return this.lastError;
  }

  getLockPath(): string | null {
    return this.bridgeLock.getLockPath();
  }

  async sendCommand(
    method: string,
    params: Record<string, unknown> = {}
  ): Promise<unknown> {
    await this.ensureListening();
    if (!this.isConnected()) {
      throw new GodotConnectionError(
        "Godot editor is not connected. Make sure the Godot MCP Pro plugin is enabled and the editor is running."
      );
    }

    const id = randomUUID();
    const request: JsonRpcRequest = {
      jsonrpc: "2.0",
      method,
      params,
      id,
    };

    return new Promise<unknown>((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pendingRequests.delete(id);
        reject(new TimeoutError(method, COMMAND_TIMEOUT_MS));
      }, COMMAND_TIMEOUT_MS);

      this.pendingRequests.set(id, {
        resolve: resolve as (value: JsonRpcResponse) => void,
        reject,
        timer,
      });
      this.client!.send(JSON.stringify(request));
    });
  }

  async ensureListening(): Promise<void> {
    if (this.wss) return;
    await this.connect();
  }

  private async choosePort(): Promise<number> {
    if (this.strictPort) {
      if (!(await isPortFree(this.port))) {
        throw new GodotConnectionError(`Configured strict port ${this.port} is already in use.`);
      }
      return this.port;
    }

    const preferredPorts = [this.port, ...this.candidatePorts.filter((p) => p !== this.port)];
    for (const p of preferredPorts) {
      if (this.reservedCliPorts.includes(p)) continue;
      if (await isPortFree(p)) return p;
    }

    throw new GodotConnectionError(
      `No free Godot MCP stdio bridge ports in ${this.candidatePorts.join(",")}.`
    );
  }

  private cleanupFailedServer(): void {
    this.bridgeLock.stop();
    if (this.wss) {
      try {
        this.wss.close();
      } catch {
        // Closing a failed ws server is best-effort only.
      }
    }
    this.wss = null;
  }

  private handleMessage(data: string, ws: WebSocket): void {
    let msg: JsonRpcResponse;
    try {
      msg = JSON.parse(data);
    } catch {
      console.error("[MCP] Failed to parse message from Godot:", data);
      return;
    }

    const method = (msg as unknown as { method?: string }).method;
    if (method === "godot_hello") {
      this.handleGodotHello(msg as unknown as { params?: Record<string, unknown> }, ws);
      return;
    }

    if (method === "pong") {
      return;
    }

    if (!msg.id) return;

    const pending = this.pendingRequests.get(msg.id);
    if (!pending) return;

    clearTimeout(pending.timer);
    this.pendingRequests.delete(msg.id);

    if (msg.error) {
      pending.reject(
        new GodotCommandError(
          msg.error.code,
          msg.error.message,
          msg.error.data
        )
      );
    } else {
      pending.resolve(msg.result as unknown as JsonRpcResponse);
    }
  }

  private handleGodotHello(msg: { params?: Record<string, unknown> }, ws: WebSocket): void {
    const incomingWorkspace = String(msg.params?.workspace || "");
    if (
      incomingWorkspace &&
      normalizeWorkspacePath(incomingWorkspace) !== normalizeWorkspacePath(this.workspace)
    ) {
      ws.close(1008, "Workspace mismatch");
      console.error(
        `[MCP] Rejected Godot editor for workspace '${incomingWorkspace}' while bridge expects '${this.workspace}'`
      );
      return;
    }

    if (this.client && this.client !== ws) {
      this.client.close(1000, "Replaced by new matching workspace connection");
    }
    this.client = ws;
    this.startHeartbeat();
    console.error("[MCP] Godot editor workspace handshake accepted");
  }

  private rejectAllPending(error: Error): void {
    for (const [, pending] of this.pendingRequests) {
      clearTimeout(pending.timer);
      pending.reject(error);
    }
    this.pendingRequests.clear();
  }

  private startHeartbeat(): void {
    this.stopHeartbeat();
    this.heartbeatTimer = setInterval(() => {
      if (this.isConnected()) {
        this.client!.send(
          JSON.stringify({ jsonrpc: "2.0", method: "ping", params: {} })
        );
      }
    }, HEARTBEAT_INTERVAL_MS);
  }

  private stopHeartbeat(): void {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer);
      this.heartbeatTimer = null;
    }
  }
}
