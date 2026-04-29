import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { GodotConnection } from "../godot-connection.js";

/**
 * 诊断工具用于回答“Codex 已经加载 MCP 工具入口，但 bridge 是否真的在监听”。
 * 它不依赖 Godot editor 已连接，因此可以在断连时返回端口、workspace 和 lock 信息。
 */
export function registerDiagnosticTools(server: McpServer, godot: GodotConnection): void {
  server.tool(
    "get_bridge_status",
    "Diagnose the local Godot MCP bridge listener, workspace identity, and Godot editor connection state",
    {},
    async () => {
      const result = {
        port: godot.getPort(),
        candidatePorts: godot.getCandidatePorts(),
        reservedCliPorts: godot.getReservedCliPorts(),
        isListening: godot.isListening(),
        isGodotConnected: godot.isConnected(),
        workspace: godot.getWorkspace(),
        sessionId: godot.getSessionId(),
        lockPath: godot.getLockPath(),
        pendingRequestCount: godot.getPendingRequestCount(),
        lastError: godot.getLastError(),
      };

      return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
    }
  );
}
