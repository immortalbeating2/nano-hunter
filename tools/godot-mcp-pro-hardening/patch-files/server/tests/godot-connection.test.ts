import { mkdtempSync, rmSync } from "node:fs";
import { createServer } from "node:net";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { WebSocket } from "ws";
import {
  DEFAULT_LEGACY_RESERVED_CLI_PORTS,
  DEFAULT_LEGACY_STDIO_PORTS,
  DEFAULT_RESERVED_CLI_PORTS,
  DEFAULT_STDIO_PORTS,
  GodotConnection,
  buildCandidatePorts,
  normalizeWorkspacePath,
  parsePortList,
} from "../src/godot-connection.js";
import { writeProjectRendezvous } from "../src/utils/bridge-lock.js";

describe("Godot MCP stdio port plan", () => {
  it("uses 17605-17619 for stdio and keeps CLI ranges reserved", () => {
    const ports = buildCandidatePorts();

    expect(DEFAULT_STDIO_PORTS).toEqual([
      17605, 17606, 17607, 17608, 17609,
      17610, 17611, 17612, 17613, 17614,
      17615, 17616, 17617, 17618, 17619,
    ]);
    expect(DEFAULT_RESERVED_CLI_PORTS).toEqual([17620, 17621, 17622, 17623, 17624]);
    expect(DEFAULT_LEGACY_STDIO_PORTS).toEqual([6505, 6506, 6507, 6508, 6509]);
    expect(DEFAULT_LEGACY_RESERVED_CLI_PORTS).toEqual([6510, 6511, 6512, 6513, 6514]);
    expect(ports.slice(0, 5)).toEqual([17605, 17606, 17607, 17608, 17609]);
    expect(ports.slice(-5)).toEqual([6505, 6506, 6507, 6508, 6509]);
    expect(ports).not.toContain(17620);
    expect(ports).not.toContain(17624);
    expect(ports).not.toContain(6510);
    expect(ports).not.toContain(6514);
  });

  it("parses reserved port ranges and individual ports", () => {
    expect(parsePortList("17620-17622,6505")).toEqual([6505, 17620, 17621, 17622]);
  });

  it("normalizes workspace paths for Godot and Node comparisons", () => {
    expect(normalizeWorkspacePath("C:\\Users\\peng8\\Project\\nano-hunter\\")).toBe(
      "c:/users/peng8/project/nano-hunter"
    );
  });

  it("rejects same-workspace handshakes without the rendezvous session", async () => {
    const port = await new Promise<number>((resolve, reject) => {
      const server = createServer();
      server.once("error", reject);
      server.listen(0, "127.0.0.1", () => {
        const address = server.address();
        server.close(() => resolve(typeof address === "object" && address ? address.port : 0));
      });
    });
    const godot = new GodotConnection(port, true, "C:/workspace/nano-hunter", "session-a", "test");
    await godot.connect();

    try {
      const ack = await new Promise<Record<string, unknown>>((resolve, reject) => {
        const ws = new WebSocket(`ws://127.0.0.1:${port}`);
        const timer = setTimeout(() => reject(new Error("handshake timed out")), 3000);

        ws.on("open", () => {
          ws.send(JSON.stringify({
            jsonrpc: "2.0",
            method: "godot_hello",
            params: { workspace: "C:/workspace/nano-hunter", sessionId: "" },
          }));
        });

        ws.on("message", (data) => {
          clearTimeout(timer);
          ws.close();
          resolve(JSON.parse(data.toString()) as Record<string, unknown>);
        });

        ws.on("error", (err) => {
          clearTimeout(timer);
          reject(err);
        });
      });

      expect(ack).toMatchObject({
        method: "godot_hello_ack",
        params: { accepted: false, reason: "Session mismatch" },
      });
    } finally {
      godot.disconnect();
    }
  });

  it("marks old project rendezvous files as stale in diagnostics", () => {
    const workspace = mkdtempSync(join(tmpdir(), "godot-mcp-status-test-"));
    try {
      writeProjectRendezvous(workspace, {
        pid: 1234,
        port: 17605,
        workspace,
        sessionId: "old-session",
        startedAt: "2026-05-01T00:00:00.000Z",
        lastHeartbeat: "2026-05-01T00:00:05.000Z",
        version: "1.15.0-nh.1",
        kind: "stdio",
        portPlanVersion: "17605-primary",
      });

      const godot = new GodotConnection(17605, false, workspace, "new-session", "test");
      expect(godot.getRendezvousStatus()).toMatchObject({
        exists: true,
        stale: true,
        sessionId: "old-session",
      });
    } finally {
      rmSync(workspace, { recursive: true, force: true });
    }
  });
});
