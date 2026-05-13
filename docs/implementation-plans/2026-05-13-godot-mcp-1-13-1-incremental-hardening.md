# Godot MCP Pro 1.13.1 Incremental Hardening Plan

## Goal

在不破坏现有 Godot MCP Pro hardening 主机制的前提下，吸收 `1.13.1` 中对连接存活检测、status panel 可读性和输入模拟行为有价值的增量。

## Scope

- 保留 `17605-17619` stdio 主端口、`17620-17624` CLI 主端口和 legacy fallback。
- 保留项目本地 `.godot/godot-mcp-pro/current-bridge.json` rendezvous。
- 保留 `godot_hello` / `godot_hello_ack` 与 workspace/session 握手。
- 保留 bridge lock、diagnostic tools 和 lazy reconnect。
- 吸收 1.13.1 的 ping/pong、heartbeat timeout、Godot 端 idle/stale 显示和 input `unhandled=false` 修正。

## Non-Goals

- 不直接用 `godot-mcp-pro-v1.13.1.zip` 覆盖当前全局 server 或项目插件。
- 不退回 `6505-6509` / `6510-6514` 旧主端口模型。
- 不删除当前项目的 hardening patch-files 和诊断脚本。

## Execution Checklist

- [x] 新建分支 `codex/upgrade-godot-mcp-1-13-1-increments`。
- [x] 解压并审查 `godot-mcp-pro-v1.13.1.zip`。
- [x] 确认 1.13.1 原包会删除 rendezvous / workspace handshake / diagnostic tools，因此不可直接覆盖。
- [x] 合并 Node server 心跳增强：`lastPongAt`、TCP keepalive、收到 Godot `ping` 时回 `pong`、heartbeat timeout 后 `terminate()` 死连接。
- [x] 合并 Godot 插件连接增强：主动 `ping`、idle 计时、stale 标记与静默超时重连。
- [x] 合并 status panel 增强：保留端口角色和握手日志，同时显示 idle / stale 状态。
- [x] 合并输入模拟修正：显式 `unhandled=false` 时不再被拖拽逻辑覆盖。
- [x] 同步 `tools/godot-mcp-pro-hardening/patch-files/`。
- [x] 更新补丁脚本的文件清单和已审查版本列表。
- [x] 运行 Node 测试与构建。
- [x] 运行补丁脚本 dry-run 与 Godot import 验证。

## Verification Plan

```powershell
cd C:/Users/peng8/.mcp/godot-mcp-pro/server
npm test
npm run build

cd C:/Users/peng8/Desktop/Project/Game/nano-hunter
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun
.\scripts\dev\check-godot-mcp.ps1
.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun
godot --headless --path . --import
git diff --check
```

## Exit Criteria

- `npm test` 与 `npm run build` 通过。
- `apply-godot-mcp-pro-hardening-patch.ps1 -DryRun` 列出新增输入修正文件。
- `websocket_server.gd` 仍优先使用 rendezvous，并继续发送 `godot_hello`。
- `status_panel.gd` 同时保留端口角色、握手日志和 idle/stale 显示。
- `input_commands.gd` 与 `mcp_input_service.gd` 尊重显式 `unhandled=false`。

## Verification Results

- `npm test` in `C:/Users/peng8/.mcp/godot-mcp-pro/server`: passed, 2 test files / 6 tests.
- `npm run build` in `C:/Users/peng8/.mcp/godot-mcp-pro/server`: passed.
- `.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun`: passed; includes server, plugin, and the new `input_commands.gd` / `mcp_input_service.gd` patch targets.
- `.\scripts\dev\check-godot-mcp.ps1`: passed; reports `AlreadyConnected` for the current workspace and active stdio bridge listeners on `17605-17607`.
- `.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun`: passed; recommends read-only MCP verification before runtime review.
- `godot --headless --path . --import`: passed; plugin starts with the retained `17605-17619` / `17620-17624` / legacy plan.
- `git diff --check`: passed.
