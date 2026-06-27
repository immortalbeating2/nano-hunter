import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import {
  getBridgeLockPath,
  getProjectRendezvousPath,
  isHeartbeatStale,
  readProjectRendezvous,
  readBridgeLock,
  removeBridgeLock,
  removeProjectRendezvous,
  writeBridgeLock,
  writeProjectRendezvous,
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
      version: "1.15.0-nh.1",
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
      version: "1.15.0-nh.1",
      kind: "stdio",
    });

    const lock = readBridgeLock(root, 6515);
    expect(lock).not.toBeNull();
    expect(isHeartbeatStale(lock!, 30_000, new Date("2026-04-30T00:00:31.000Z"))).toBe(true);

    removeBridgeLock(root, 6515);
    expect(readBridgeLock(root, 6515)).toBeNull();
  });

  it("writes project rendezvous and only removes matching sessions", () => {
    const workspace = mkdtempSync(join(tmpdir(), "godot-mcp-rendezvous-test-"));
    tempRoots.push(workspace);

    writeProjectRendezvous(workspace, {
      pid: 5678,
      port: 17605,
      workspace,
      sessionId: "session-b",
      startedAt: "2026-05-01T00:00:00.000Z",
      lastHeartbeat: "2026-05-01T00:00:05.000Z",
      version: "1.15.0-nh.1",
      kind: "stdio",
      portPlanVersion: "17605-primary",
    });

    expect(getProjectRendezvousPath(workspace)).toMatch(/current-bridge\.json$/);
    expect(readProjectRendezvous(workspace)).toMatchObject({
      pid: 5678,
      port: 17605,
      sessionId: "session-b",
      portPlanVersion: "17605-primary",
      rendezvousVersion: 1,
    });

    removeProjectRendezvous(workspace, 9999, "other-session");
    expect(readProjectRendezvous(workspace)).not.toBeNull();

    removeProjectRendezvous(workspace, 5678, "session-b");
    expect(readProjectRendezvous(workspace)).toBeNull();
  });
});
