# Godot MCP Bridge Hardening Implementation Plan

## Goal

修复 Godot MCP Pro bridge 生命周期问题，并将用户目录 Node server 的本地改动固化为仓库内可重放补丁。

## Execution Checklist

- [x] 创建分支 `codex/fix-godot-mcp-bridge-lifecycle`。
- [x] 运行预检 `.\scripts\dev\check-godot-mcp.ps1`，确认旧 `6505` bridge 残留。
- [x] 先写 Node 端 Vitest 测试，覆盖 stdio/CLI 端口规划、workspace path 规范化和 bridge lock。
- [x] 修改 Node MCP Server：端口 fallback、reserved CLI skip、lazy reconnect、workspace handshake、bridge lock 和 diagnostic tool。
- [x] 修改 Godot 插件端：扫描 `6505-6534`、发送 `godot_hello`、状态面板标注端口角色。
- [x] 修改项目脚本：统一端口分组，读取 lock/heartbeat，区分 stdio bridge 与 CLI 进程。
- [x] 新增补丁脚本和 `tools/godot-mcp-pro-hardening/patch-files/`。
- [x] 验证 Node `npm test`、`npm run build`。
- [x] 验证 Godot import 与脚本 dry-run。
- [x] 更新进度文档与 timeline。
- [x] 收口前运行 `git diff --check`。

## Verification Commands

```powershell
cd C:/Users/peng8/.mcp/godot-mcp-pro/server
npm test
npm run build

cd C:/Users/peng8/.codex/worktrees/fef5/nano-hunter
godot --headless --path . --import
.\scripts\dev\check-godot-mcp.ps1
.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun
git diff --check
```

## Completion Criteria

- Node server 不自动占用 `6510-6514`。
- stale bridge 可由 lock/heartbeat/PID/connection 信息解释。
- 补丁脚本 dry-run 能列出 server path、project path、版本、端口规划、目标文件和备份路径。
- 文档记录项目外更新原因、影响范围、验证结果、风险与下一步。

## Verification Results

- `npm test` in `C:/Users/peng8/.mcp/godot-mcp-pro/server`: passed, 2 test files / 5 tests.
- `npm run build` in `C:/Users/peng8/.mcp/godot-mcp-pro/server`: passed.
- `godot --headless --path . --import`: passed; plugin logged scan range `6505-6534` and startup plan `stdio 6505-6509,6515-6534; cli 6510-6514`.
- `.\scripts\dev\check-godot-mcp.ps1`: passed; output separates stdio bridge listeners, CLI listeners, bridge locks and Godot editors.
- `.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun`: passed; recommends explicit confirmed stale cleanup before reopening when only stale listeners are found.
- `.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun`: passed; prints server/project/version, three port groups and all backup/copy targets.
- `git diff --check`: passed.
