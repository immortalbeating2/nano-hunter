import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { execFileSync } from "node:child_process";
import { z } from "zod";
import { GodotConnection } from "../godot-connection.js";

/**
 * 诊断工具用于回答“Codex 已经加载 MCP 工具入口，但 bridge 是否真的在监听”。
 * 它不依赖 Godot editor 已连接，因此可以在断连时返回端口、workspace 和 lock 信息。
 */
export function registerDiagnosticTools(server: McpServer, godot: GodotConnection): void {
  server.tool(
    "get_bridge_status",
    "Diagnose the local Godot MCP bridge listener, workspace identity, and Godot editor connection state. For reconnect, stale bridge, or first Godot MCP call in a session, call get_bridge_status with repair=true before calling scene/runtime tools.",
    {
      repair: z.boolean().optional().describe("Recommended for reconnect/startup troubleshooting. Start this session's bridge if it is not listening, then wait briefly for Godot to connect before other Godot tools."),
    },
    async (params) => {
      if (params.repair && !godot.isListening()) {
        await godot.ensureListening();
        await godot.waitForGodotConnection();
      }

      const rendezvous = godot.getRendezvousStatus();
      const result = {
        port: godot.getPort(),
        candidatePorts: godot.getCandidatePorts(),
        legacyStdioPorts: godot.getLegacyStdioPorts(),
        reservedCliPorts: godot.getReservedCliPorts(),
        isListening: godot.isListening(),
        isGodotConnected: godot.isConnected(),
        workspace: godot.getWorkspace(),
        sessionId: godot.getSessionId(),
        lockPath: godot.getLockPath(),
        rendezvous,
        bridgeNotStarted: !godot.isListening(),
        hint: getBridgeHint(godot, rendezvous),
        dynamicTcpRange: getWindowsDynamicTcpRange(),
        portInDynamicTcpRange: isPortInDynamicTcpRange(godot.getPort()),
        pendingRequestCount: godot.getPendingRequestCount(),
        lastError: godot.getLastError(),
      };

      return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
    }
  );
}

function getBridgeHint(godot: GodotConnection, rendezvous: Record<string, unknown>): string | null {
  if (!godot.isListening()) {
    return "Bridge is not listening. For reconnect or first use, call get_bridge_status with repair=true before scene/runtime tools.";
  }
  if (rendezvous.exists && rendezvous.stale) {
    return "Project rendezvous is stale and will be overwritten by the active bridge.";
  }
  if (!godot.isConnected()) {
    return "Bridge is listening, but no matching Godot editor has completed workspace/session handshake yet.";
  }
  return null;
}

/**
 * Windows 上 netsh 是判断当前机器动态 TCP 端口池的可靠来源。
 * 该诊断只在 get_bridge_status 被调用时执行；失败返回 null，避免影响 MCP 工具入口。
 */
function getWindowsDynamicTcpRange(): { start: number; end: number; count: number } | null {
  if (process.platform !== "win32") return null;
  try {
    const output = execFileSync("netsh", ["int", "ipv4", "show", "dynamicport", "tcp"], {
      encoding: "utf8",
      timeout: 2000,
    });
    const start = Number(output.match(/Start Port\s*:\s*(\d+)/)?.[1]);
    const count = Number(output.match(/Number of Ports\s*:\s*(\d+)/)?.[1]);
    if (!Number.isFinite(start) || !Number.isFinite(count)) return null;
    return { start, count, end: start + count - 1 };
  } catch {
    return null;
  }
}

function isPortInDynamicTcpRange(port: number): boolean | null {
  const range = getWindowsDynamicTcpRange();
  if (!range) return null;
  return port >= range.start && port <= range.end;
}
