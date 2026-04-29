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

## Follow-up: 通用化补丁脚本

- [x] 将补丁脚本从 nano-hunter 专用语义改为可搬移、可跨项目使用：新增 `-Scope`、`-PatchRoot`、`-BackupRoot`、`-IncludeProjectScripts`。
- [x] 默认应用范围改为 `ServerAndPlugin`：只覆盖全局 Node server 与目标项目 `addons/godot_mcp`，不默认覆盖其它项目 `scripts/dev`。
- [x] 重排补丁源目录为 `server`、`plugin`、`optional-project-scripts`，删除旧 `project` 语义。
- [x] PowerShell 脚本补充中文文件头与主要函数说明，明确是否只读、是否杀进程、是否写外部 server 和常用命令。
- [x] Node TS 与 GDScript 补丁源补充端口规划、workspace handshake、lock/heartbeat、lazy reconnect 和状态面板边界说明。
- [x] 新增 `docs/dev/godot-mcp-script-reference.md`，更新 README 与 connectivity guide 的通用使用说明。

## Follow-up Verification Matrix

- `.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun`: default `ServerAndPlugin`, includes `server, plugin`, skips `optional-project-scripts`.
- `.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun -Scope ServerOnly`: includes only `server`.
- `.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun -Scope PluginOnly`: includes only `plugin` and does not resolve Node server.
- `.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun -IncludeProjectScripts`: includes `server, plugin, optional-project-scripts`.
- `.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun -ProjectPath C:\Users\peng8\Desktop\Project\Game\angel-fallen -Scope PluginOnly`: targets `angel-fallen/addons/godot_mcp` only.
- Copied script to `tests/artifacts/local/godot-mcp-tool-standalone/` with sibling `patch-files` and verified movable auto-discovery with `-Scope PluginOnly -DryRun`.
- Copied script to `tests/artifacts/local/godot-mcp-tool-test/` and verified explicit `-PatchRoot` with `-Scope PluginOnly -DryRun`.
- `.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -Scope ServerOnly`: applied updated server patch to `C:/Users/peng8/.mcp/godot-mcp-pro/server`.
- `npm test`: passed, 2 test files / 5 tests.
- `npm run build`: passed.
- `godot --headless --path . --import`: passed and did not leave `project.godot` diff.
- `.\scripts\dev\check-godot-mcp.ps1`: passed.
- `.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun`: passed.
- Mojibake scan on changed scripts, plugin files, patch source and docs: no matches for common mojibake markers.
