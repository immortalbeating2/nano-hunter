import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import {
  getBridgeLockPath,
  isHeartbeatStale,
  readBridgeLock,
  removeBridgeLock,
  writeBridgeLock,
} from "../src/utils/bridge-lock.js";

const tempRoots: string[] = [];

afterEach(() => {
  for (const root of tempRoots.splice(0)) {
    rmSync(root, { recursive: true, force: true });
  }
});

describe("bridge lock files", () => {
  it("writes and reads a lock with workspace and heartbeat identity", () => {
    const root = mkdtempSync(join(tmpdir(), "godot-mcp-lock-test-"));
    tempRoots.push(root);

    writeBridgeLock(root, {
      pid: 1234,
      port: 6515,
      workspace: "C:/workspace/nano-hunter",
      sessionId: "session-a",
      startedAt: "2026-04-30T00:00:00.000Z",
      lastHeartbeat: "2026-04-30T00:00:05.000Z",
      version: "1.12.0",
      kind: "stdio",
    });

    expect(getBridgeLockPath(root, 6515)).toMatch(/6515\.json$/);
    expect(readBridgeLock(root, 6515)).toMatchObject({
      pid: 1234,
      port: 6515,
      workspace: "C:/workspace/nano-hunter",
      sessionId: "session-a",
      kind: "stdio",
    });
  });

  it("detects stale heartbeats and removes lock files", () => {
    const root = mkdtempSync(join(tmpdir(), "godot-mcp-lock-test-"));
    tempRoots.push(root);

    writeBridgeLock(root, {
      pid: 1234,
      port: 6515,
      workspace: "C:/workspace/nano-hunter",
      sessionId: "session-a",
      startedAt: "2026-04-30T00:00:00.000Z",
      lastHeartbeat: "2026-04-30T00:00:00.000Z",
      version: "1.12.0",
      kind: "stdio",
    });

    const lock = readBridgeLock(root, 6515);
    expect(lock).not.toBeNull();
    expect(isHeartbeatStale(lock!, 30_000, new Date("2026-04-30T00:00:31.000Z"))).toBe(true);

    removeBridgeLock(root, 6515);
    expect(readBridgeLock(root, 6515)).toBeNull();
  });
});
