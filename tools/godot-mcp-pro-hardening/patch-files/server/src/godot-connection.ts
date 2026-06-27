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
import {
  BridgeLockHeartbeat,
  getDefaultBridgeLockRoot,
  readProjectRendezvous,
} from "./utils/bridge-lock.js";

const DEFAULT_STDIO_PORT_RANGE = "17605-17619";
const DEFAULT_LEGACY_STDIO_PORT_RANGE = "6505-6509";
const COMMAND_TIMEOUT_MS = 30000;
const HEARTBEAT_INTERVAL_MS = 10000;
const HEARTBEAT_TIMEOUT_MS = HEARTBEAT_INTERVAL_MS * 3;
const TCP_KEEPALIVE_DELAY_MS = 5000;
export const PORT_PLAN_VERSION = "17605-primary";
export const DEFAULT_STDIO_PORTS = parsePortList(DEFAULT_STDIO_PORT_RANGE);
export const DEFAULT_LEGACY_STDIO_PORTS = parsePortList(DEFAULT_LEGACY_STDIO_PORT_RANGE);
export const DEFAULT_RESERVED_CLI_PORTS = parsePortList("17620-17624");
export const DEFAULT_LEGACY_RESERVED_CLI_PORTS = parsePortList("6510-6514");

/**
 * 解析逗号分隔或短横线范围端口列表，例如 "17605-17619,6505"。
 * 该函数服务于端口环境变量，让本地环境可以覆盖 stdio/CLI 端口段；
 * 默认仍必须跳过 godot-cli 使用的 17620-17624 与 legacy 6510-6514。
 */
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

/**
 * 构造 stdio bridge 候选端口。
 * 默认优先使用 17605-17619，避开本机常见 TCP 动态端口池；6505-6509
 * 只作为 legacy fallback。stdio 自动监听永远跳过新旧 CLI reserved 端口，
 * 避免 Codex/Claude/opencode 会话启动时抢占 godot-cli 临时端口。
 */
export function buildCandidatePorts(
  stdioPorts: number[] = parsePortList(process.env.GODOT_MCP_PORT_RANGE || DEFAULT_STDIO_PORT_RANGE),
  legacyStdioPorts: number[] = process.env.GODOT_MCP_DISABLE_LEGACY_PORTS === "1"
    ? []
    : parsePortList(process.env.GODOT_MCP_LEGACY_STDIO_PORTS || DEFAULT_LEGACY_STDIO_PORT_RANGE),
  reservedPorts: number[] = [
    ...DEFAULT_RESERVED_CLI_PORTS,
    ...DEFAULT_LEGACY_RESERVED_CLI_PORTS,
    ...parsePortList(process.env.GODOT_MCP_CLI_PORT_RANGE),
    ...parsePortList(process.env.GODOT_MCP_LEGACY_CLI_PORTS),
    ...parsePortList(process.env.GODOT_MCP_RESERVED_PORTS),
  ]
): number[] {
  const reserved = new Set(reservedPorts);
  const ports = new Set<number>();
  for (const p of [...stdioPorts, ...legacyStdioPorts]) {
    if (!reserved.has(p)) ports.add(p);
  }
  return [...ports];
}

/**
 * workspace handshake 使用规范化后的路径比较，避免 Windows 反斜杠、
 * 大小写和末尾斜杠让同一个项目被误判为不同 workspace。
 */
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
  private legacyStdioPorts: number[];
  private lastError: string | null = null;
  private bridgeLock: BridgeLockHeartbeat;
  private lastPongAt: number = 0;

  constructor(
    port: number = DEFAULT_STDIO_PORTS[0],
    strictPort: boolean = false,
    private readonly workspace: string = process.cwd(),
    private readonly sessionId: string = randomUUID(),
    private readonly version: string = "unknown"
  ) {
    this.port = port;
    this.strictPort = strictPort;
    this.reservedCliPorts = [
      ...DEFAULT_RESERVED_CLI_PORTS,
      ...DEFAULT_LEGACY_RESERVED_CLI_PORTS,
      ...parsePortList(process.env.GODOT_MCP_CLI_PORT_RANGE),
      ...parsePortList(process.env.GODOT_MCP_LEGACY_CLI_PORTS),
      ...parsePortList(process.env.GODOT_MCP_RESERVED_PORTS),
    ];
    this.legacyStdioPorts = process.env.GODOT_MCP_DISABLE_LEGACY_PORTS === "1"
      ? []
      : parsePortList(process.env.GODOT_MCP_LEGACY_STDIO_PORTS || DEFAULT_LEGACY_STDIO_PORT_RANGE);
    this.candidatePorts = buildCandidatePorts(undefined, undefined, this.reservedCliPorts);
    this.bridgeLock = new BridgeLockHeartbeat(
      getDefaultBridgeLockRoot(),
      this.workspace,
      this.sessionId,
      this.version,
      5000,
      PORT_PLAN_VERSION
    );
  }

  /**
   * 启动 WebSocket bridge。
   * 非 strict 模式下，GODOT_MCP_PORT 只是 preferred port；被占用时会 fallback
   * 到候选端口。启动失败会清空 wss，后续 sendCommand/ensureListening 可以重试。
   */
  async connect(): Promise<void> {
    if (this.wss) return;

    if (this.strictPort && this.reservedCliPorts.includes(this.port)) {
      throw new GodotConnectionError(`Configured strict port ${this.port} is reserved for godot-cli.`);
    }

    const candidates = this.strictPort
      ? [this.port]
      : [this.port, ...this.candidatePorts.filter((p) => p !== this.port)];

    let lastError: Error | null = null;
    for (const port of candidates) {
      if (this.reservedCliPorts.includes(port)) continue;
      try {
        const wss = await this.bindWebSocketServer(port);
        this.wss = wss;
        this.port = port;
        this.lastError = null;
        this.bridgeLock.start(this.port);
        this.attachConnectionHandler(wss);
        console.error(
          `[MCP] WebSocket server listening on ws://127.0.0.1:${this.port}`
        );
        return;
      } catch (err) {
        lastError = err as Error;
        this.lastError = lastError.message;
        this.cleanupFailedServer();
        if ((err as NodeJS.ErrnoException).code !== "EADDRINUSE") {
          console.error("[MCP] WebSocket server error:", lastError.message);
        }
      }
    }

    const range = this.strictPort ? String(this.port) : this.candidatePorts.join(",");
    throw new GodotConnectionError(
      `No free Godot MCP stdio bridge ports in ${range}. ` +
      `Last error: ${lastError?.message ?? "unknown"}.`
    );
  }

  /** Try to bind one WebSocketServer. A bind race rejects this candidate and lets connect try the next port. */
  private bindWebSocketServer(port: number): Promise<WebSocketServer> {
    return new Promise<WebSocketServer>((resolve, reject) => {
      const wss = new WebSocketServer({ port, host: "127.0.0.1" });

      const onError = (err: Error) => {
        wss.off("listening", onListening);
        wss.close();
        reject(err);
      };
      const onListening = () => {
        wss.off("error", onError);
        wss.on("error", (err: Error) => {
          this.lastError = err.message;
          console.error("[MCP] WebSocket server error:", err.message);
        });
        resolve(wss);
      };

      wss.once("error", onError);
      wss.once("listening", onListening);
    });
  }

  private attachConnectionHandler(wss: WebSocketServer): void {
    wss.on("connection", (ws: WebSocket) => {
      console.error("[MCP] Godot editor connected; waiting for workspace handshake");

      // OS 层 keepalive 辅助暴露半开 TCP；应用层 ping/pong 仍负责主要存活判断。
      const sock = (ws as unknown as { _socket?: { setKeepAlive?: (enable: boolean, initialDelay: number) => void } })._socket;
      sock?.setKeepAlive?.(true, TCP_KEEPALIVE_DELAY_MS);

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

  getLegacyStdioPorts(): number[] {
    return [...this.legacyStdioPorts];
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

  getRendezvousPath(): string {
    return this.bridgeLock.getRendezvousPath();
  }

  getRendezvousStatus(): Record<string, unknown> {
    const rendezvous = readProjectRendezvous(this.workspace);
    return {
      path: this.getRendezvousPath(),
      exists: rendezvous !== null,
      port: rendezvous?.port ?? null,
      pid: rendezvous?.pid ?? null,
      workspace: rendezvous?.workspace ?? null,
      sessionId: rendezvous?.sessionId ?? null,
      lastHeartbeat: rendezvous?.lastHeartbeat ?? null,
      portPlanVersion: rendezvous?.portPlanVersion ?? null,
    };
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

  /**
   * 选择监听端口。
   * strict 模式用于确实需要固定端口的调试场景；普通 stdio 会话应允许
   * fallback。新端口段优先使用 17605-17619，legacy 6505-6509 只在必要时兜底。
   */
  private async choosePort(): Promise<number> {
    if (this.strictPort) {
      if (this.reservedCliPorts.includes(this.port)) {
        throw new GodotConnectionError(`Configured strict port ${this.port} is reserved for godot-cli.`);
      }
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
      if (this.client === ws) {
        this.lastPongAt = Date.now();
      }
      return;
    }

    if (method === "ping") {
      if (this.client === ws) {
        this.lastPongAt = Date.now();
      }
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({ jsonrpc: "2.0", method: "pong", params: {} }));
      }
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
    // Godot 插件连接后必须先发 godot_hello。workspace 不匹配时关闭这个连接，
    // 且不替换当前 client，避免另一个项目的 editor 抢走本会话 bridge。
    const incomingWorkspace = String(msg.params?.workspace || "");
    if (
      incomingWorkspace &&
      normalizeWorkspacePath(incomingWorkspace) !== normalizeWorkspacePath(this.workspace)
    ) {
      this.sendHelloAck(ws, false, "Workspace mismatch");
      ws.close(1008, "Workspace mismatch");
      console.error(
        `[MCP] Rejected Godot editor for workspace '${incomingWorkspace}' while bridge expects '${this.workspace}'`
      );
      return;
    }

    const incomingSessionId = String(msg.params?.sessionId || "");
    if (incomingSessionId && incomingSessionId !== this.sessionId) {
      this.sendHelloAck(ws, false, "Session mismatch");
      ws.close(1008, "Session mismatch");
      console.error(
        `[MCP] Rejected Godot editor session '${incomingSessionId}' while bridge expects '${this.sessionId}'`
      );
      return;
    }

    if (this.client && this.client !== ws) {
      this.client.close(1000, "Replaced by new matching workspace connection");
    }
    this.client = ws;
    this.lastPongAt = Date.now();
    this.startHeartbeat();
    this.sendHelloAck(ws, true, "Accepted");
    console.error("[MCP] Godot editor workspace handshake accepted");
  }

  private sendHelloAck(ws: WebSocket, accepted: boolean, reason: string): void {
    if (ws.readyState !== WebSocket.OPEN) return;
    ws.send(JSON.stringify({
      jsonrpc: "2.0",
      method: "godot_hello_ack",
      params: {
        accepted,
        reason,
        port: this.port,
        workspace: this.workspace,
        sessionId: this.sessionId,
        portPlanVersion: PORT_PLAN_VERSION,
      },
    }));
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
      if (!this.isConnected()) return;

      if (Date.now() - this.lastPongAt > HEARTBEAT_TIMEOUT_MS) {
        console.error(
          `[MCP] Heartbeat timeout (no pong for ${HEARTBEAT_TIMEOUT_MS}ms); terminating dead connection`
        );
        const dead = this.client;
        this.client = null;
        this.stopHeartbeat();
        this.rejectAllPending(
          new GodotConnectionError("Heartbeat timeout; Godot connection lost")
        );
        dead?.terminate();
        return;
      }

      this.client!.send(
        JSON.stringify({ jsonrpc: "2.0", method: "ping", params: {} })
      );
    }, HEARTBEAT_INTERVAL_MS);
  }

  private stopHeartbeat(): void {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer);
      this.heartbeatTimer = null;
    }
  }
}
