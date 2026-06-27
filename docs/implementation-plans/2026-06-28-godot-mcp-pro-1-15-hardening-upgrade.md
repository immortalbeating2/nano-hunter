# Godot MCP Pro v1.15.0 Hardening Upgrade

## 目标

在不破坏当前稳定目录 `C:\Users\peng8\.mcp\godot-mcp-pro` 的前提下，以 `godot-mcp-pro-v1.15.0` 为基底合回本地 bridge hardening。

## 影响范围

- 外部暂存 server：`C:\Users\peng8\.mcp\godot-mcp-pro-v1.15.0\server`
- 项目 Godot 插件：`addons/godot_mcp`
- 补丁模板：`tools/godot-mcp-pro-hardening/patch-files`
- 补丁脚本、进度文档

## 回滚

- 当前稳定目录 `C:\Users\peng8\.mcp\godot-mcp-pro` 升级期间不修改。
- 若 v1.15.0 合并版验证失败，继续使用原稳定目录。
- 项目内改动通过当前分支回滚。

## 执行清单

- [x] 在 v1.15.0 server 执行 `npm install`。
- [x] 合并端口规划、rendezvous、workspace/session handshake、bridge lock、`get_bridge_status`。
- [x] 保留 v1.15.0 selection 工具、UndoRedo/dry-run 防护和 `assert_node_state` 修复。
- [x] 更新补丁模板和 verified version。
- [x] 执行 build/test/dry-run/Godot 联通验证。
- [x] 更新进度文档并提交。

## 验证命令

```powershell
cd C:\Users\peng8\.mcp\godot-mcp-pro-v1.15.0\server
npm run build
npm test

cd C:\Users\peng8\Desktop\Project\Game\nano-hunter
.\scripts\dev\apply-godot-mcp-pro-hardening-patch.ps1 -DryRun -ServerPath $env:USERPROFILE\.mcp\godot-mcp-pro-v1.15.0\server
.\scripts\dev\check-godot-mcp.ps1
git diff --check
```
