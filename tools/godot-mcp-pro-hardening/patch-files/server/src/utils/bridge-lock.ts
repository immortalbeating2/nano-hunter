import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

/**
 * Godot MCP bridge 是 Codex 会话外部的本机 node 进程；会话异常关闭时，
 * 进程可能继续占用端口。lock/heartbeat 不是唯一真相，而是给项目脚本
 * 提供可追溯身份：脚本仍需结合 PID、TCP 连接和 Godot 编辑器归属判断 stale。
 */
export interface BridgeLock {
  pid: number;
  port: number;
  workspace: string;
  sessionId: string;
  startedAt: string;
  lastHeartbeat: string;
  version: string;
  kind: "stdio";
}

/**
 * 返回 bridge lock 默认目录。
 * Windows 优先写入 LOCALAPPDATA，缺失时退到系统 temp；这样项目脚本可以在
 * 不依赖当前仓库路径的情况下读取所有本机会话的 bridge 状态。
 */
export function getDefaultBridgeLockRoot(): string {
  const base = process.env.LOCALAPPDATA || tmpdir();
  return join(base, "godot-mcp-pro", "bridges");
}

export function getBridgeLockPath(root: string, port: number): string {
  return join(root, `${port}.json`);
}

/** 写入当前进程 lock。每次 heartbeat 都重写完整 JSON，便于脚本只读诊断。 */
export function writeBridgeLock(root: string, lock: BridgeLock): void {
  mkdirSync(root, { recursive: true });
  writeFileSync(getBridgeLockPath(root, lock.port), JSON.stringify(lock, null, 2), "utf8");
}

/** 读取指定端口 lock；损坏或半写入文件返回 null，由诊断脚本结合其它证据判断。 */
export function readBridgeLock(root: string, port: number): BridgeLock | null {
  const lockPath = getBridgeLockPath(root, port);
  if (!existsSync(lockPath)) return null;
  try {
    return JSON.parse(readFileSync(lockPath, "utf8")) as BridgeLock;
  } catch {
    return null;
  }
}

/** 退出时尽力删除本进程 lock。删除失败不应阻塞 MCP server 退出。 */
export function removeBridgeLock(root: string, port: number): void {
  rmSync(getBridgeLockPath(root, port), { force: true });
}

/** 判断 heartbeat 是否超过阈值；时间戳损坏时按 stale 处理。 */
export function isHeartbeatStale(
  lock: BridgeLock,
  staleAfterMs: number,
  now: Date = new Date()
): boolean {
  const heartbeatTime = Date.parse(lock.lastHeartbeat);
  if (Number.isNaN(heartbeatTime)) return true;
  return now.getTime() - heartbeatTime > staleAfterMs;
}

export class BridgeLockHeartbeat {
  private timer: ReturnType<typeof setInterval> | null = null;
  private lock: BridgeLock | null = null;

  constructor(
    private readonly root: string,
    private readonly workspace: string,
    private readonly sessionId: string,
    private readonly version: string,
    private readonly intervalMs: number = 5000
  ) {}

  /** 监听端口成功后启动 heartbeat；每次刷新都重写完整 lock，便于脚本只读诊断。 */
  start(port: number): void {
    this.stop();
    const now = new Date().toISOString();
    this.lock = {
      pid: process.pid,
      port,
      workspace: this.workspace,
      sessionId: this.sessionId,
      startedAt: now,
      lastHeartbeat: now,
      version: this.version,
      kind: "stdio",
    };
    writeBridgeLock(this.root, this.lock);
    this.timer = setInterval(() => {
      if (!this.lock) return;
      this.lock.lastHeartbeat = new Date().toISOString();
      writeBridgeLock(this.root, this.lock);
    }, this.intervalMs);
  }

  /** 退出或重新绑定端口时清理本进程 lock；清理失败不应阻断 MCP server 退出。 */
  stop(): void {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
    if (this.lock) {
      removeBridgeLock(this.root, this.lock.port);
      this.lock = null;
    }
  }

  getLockPath(): string | null {
    return this.lock ? getBridgeLockPath(this.root, this.lock.port) : null;
  }
}
