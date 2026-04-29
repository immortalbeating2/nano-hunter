# Nano Hunter Status

Last Updated: 2026-04-29

## Current Phase

`Vertical Slice / 原型期`

## Current Stable Baseline

- `main` 当前稳定基线：Stage16 Alpha Demo 打包候选已合并，包含 Stage15 `Seal Guardian / 封印守卫`、`Recovery Charge / 恢复充能`、Stage16 五房终局封印链、最小 Demo 壳、Alpha Demo 完成反馈、QA checklist、release notes 与第二轮资产 / 音频需求记录。
- 当前可试玩方向：从早期教程、战斗原型、回溯门控、首个精英 Boss 原型推进到 Alpha Demo 候选；下一步默认进入试玩反馈、稳定性修正与 Stage17 规划。
- 当前设计约束：后续阶段必须继续向南北朝东方奇幻、封妖禁地、瘴泽、妖域、符印机关等语境回收灰盒命名，不继续扩大现代实验室表达。

## Current Development Site

- 当前主工作区：`C:\Users\peng8\Desktop\Project\Game\nano-hunter`，分支 `main`，已合并 Stage16 Alpha Demo 打包候选。
- Stage12-13 修正分支：`codex/north-star-realign-stage12-13` 已合并回 `main` 并删除；Git worktree 注册已移除。
- 当前会话残留目录：`C:\Users\peng8\.codex\worktrees\efa7\nano-hunter` 已不是 Git worktree，目录内容为空，但 Windows 仍持有锁，待锁释放后再删除物理目录。
- 固定永久工作树：`C:\Users\peng8\.codex\worktrees\ffc3\nano-hunter`，Stage16 阶段分支已完成开发与人工复核，待收口后同步回最新 `main`。
- 当前阶段：Stage16 Alpha Demo 打包候选已合并到 `main`，主线验证已通过；下一步推送远端并清理阶段分支。

## Latest Implemented Scope

- 新增 `SealGuardianBoss / 封印守卫` 精英 Boss 原型。
- 新增 `Recovery Charge / 恢复充能`，玩家可通过战斗积累并消费为 1 点生命恢复。
- Stage14 回环房已接入 Stage15 前置段、混合遭遇房、Boss 房、挑战支线和完成房。
- Stage15 混合遭遇房与挑战支线已启用全清门控，避免玩家绕过战斗高潮直接进入 Boss 或返回主线。
- HUD 已同时显示 Stage14 Air Dash、Stage15 恢复充能、Boss 生命 / 状态和完成房反馈。
- Godot MCP 复核发现的 Stage15 completion room HUD 遗留目标与旧收集行已修复，并补入 Stage15 回归测试。
- 全仓自有 GDScript 函数入口注释审计已清零，关键变量组、状态机、房间链路、测试 helper 与 MCP 工具脚本已补中文说明。
- Stage12-13 北极星修正已将第二小区域语义从现代实验室 / 生物废液回收到镇妖试炼场、瘴泽妖域、瘴气危险、符印封门和瘴气妖术投射者。
- Stage16 已实现 Alpha Demo 候选主体：最小 Demo 壳、Stage16 五房终局封印链、Stage15 completion 到 Stage16 入口、Stage16 Main 快照、HUD 完成态、Stage16 专项 GUT、Alpha Demo 灰盒 driver、QA checklist、release notes 和资产 / 音频 manifest 条目。

## Latest Verification

- Stage12-13 修正分支 `godot --headless --path . --import`：通过。
- Stage12-13 修正分支 Stage13 / Stage14 / Stage15 专项 GUT：`29/29 passed`，`241` 个断言。
- Stage12-13 修正分支全量 GUT：`107/107 passed`，`777` 个断言。
- Stage12-13 修正分支 `git diff --check`：通过；正式 `res://` 旧路径残留扫描无命中。
- 合并后 `main` 上 `godot --headless --path . --import`：通过。
- 合并后 `main` 上 Stage15 专项 GUT：`11/11 passed`，`102` 个断言。
- 合并后 `main` 上全量 GUT：`107/107 passed`，`777` 个断言。
- `scripts/**/*.gd` 与 `tests/**/*.gd` 函数入口前置注释扫描：`0` 缺口。
- 自有脚本、测试和进度文档常见中文乱码扫描：无命中。
- 合并后 `main` 上 `git diff --check HEAD`：通过。
- `project.godot`：Godot MCP 临时 autoload 已清理，无 MCP autoload 残留 diff。
- Stage12-13 修正分支验证结果记录于 `docs/progress/logs/2026-04-29.md`。
- Stage12-13 修正已通过 Godot MCP 编辑器层与运行态人工复核，并已在 `main` 完成合并后验证和远端同步。
- Stage16 分支整合最新 `main` 前验证：`godot --headless --path . --import` 通过；Stage16 专项 GUT `8/8 passed`，`66` 个断言；Stage15 专项 GUT `11/11 passed`，`102` 个断言；全量 GUT `115/115 passed`，`843` 个断言；`git diff --check` 通过。
- Stage16 合并后 `main` 验证：`godot --headless --path . --import` 通过；Stage16 专项 GUT `8/8 passed`，`66` 个断言；Stage15 专项 GUT `11/11 passed`，`102` 个断言；全量 GUT `115/115 passed`，`843` 个断言；`git diff --check HEAD` 通过；`enter-worktree-godot-mcp.ps1 -DryRun` 可执行。

## Current Risks

- `enter-worktree-godot-mcp.ps1` 在本次复核中曾报告 `ReopenSessionThenForceKillBridge`，但 MCP 工具实测可用；后续可继续改进脚本对“当前会话可用但 bridge 状态被判 stale”的识别。
- MCP 运行态截图现已改为本地证据产物，默认保留在 `tests/artifacts/local/`，不进入提交。
- Godot MCP 端口 `6505` 在收口检查时仍有本机监听；按当前约定仅记录，不全局释放可能属于其他活跃会话的 bridge。
- `C:\Users\peng8\.codex\worktrees\efa7\nano-hunter` 为空目录但仍被 Windows 锁定；当前不影响 Git worktree、分支或主线开发，后续若锁释放可手动删除。

## Next Steps

- 推送 `origin/main`，同步固定永久工作树到最新 `main`，删除 Stage16 阶段分支；随后进入 Alpha Demo 试玩反馈、稳定性修正与 Stage17 规划。

## References

- 阶段正式计划：`plan/2026-04-27-stage-15-combat-climax-and-elite-boss.md`
- 实现清单：`docs/implementation-plans/2026-04-27-stage-15-combat-climax-and-elite-boss.md`
- 阶段修正计划：`plan/2026-04-29-stage-12-13-north-star-realignment.md`
- 修正实现清单：`docs/implementation-plans/2026-04-29-stage-12-13-north-star-realignment.md`
- Stage16 阶段正式计划：`plan/2026-04-29-stage-16-alpha-demo-candidate.md`
- Stage16 实现清单：`docs/implementation-plans/2026-04-29-stage-16-alpha-demo-candidate.md`
- Stage16 设计文档：`spec-design/2026-04-29-stage-16-alpha-demo-candidate-design.md`
- 当日日志：`docs/progress/logs/2026-04-29.md`
- 关键时间线：`docs/progress/timeline.md`
# 2026-04-30 Toolchain Note

- 当前开发现场新增工具链修复分支 `codex/fix-godot-mcp-bridge-lifecycle`，目标是根治 Godot MCP Pro bridge 残留、端口占用和多 worktree 串线问题。
- 当前稳定游戏基线仍为 Stage16 Alpha Demo 候选；本次不改玩法、场景、资产或主流程内容。
- 工具链验证以 `npm test`、`npm run build`、`godot --headless --path . --import`、`check-godot-mcp.ps1`、`enter-worktree-godot-mcp.ps1 -DryRun` 和通用补丁脚本 dry-run 为准；补丁脚本默认只覆盖全局 Node server 与目标项目 `addons/godot_mcp`。
