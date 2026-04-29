# Nano Hunter Status

Last Updated: 2026-04-29

## Current Phase

`Vertical Slice / 原型期`

## Current Stable Baseline

- `main` 当前稳定基线：Stage15 已收口并合并，包含 `Seal Guardian / 封印守卫`、`Recovery Charge / 恢复充能`、Stage15 战斗高潮链路、挑战支线全清门控、失败重试和完成房反馈。
- 当前可试玩方向：从早期教程、战斗原型、回溯门控推进到首个精英 Boss 原型，下一步进入 Stage16 Alpha Demo 打包候选。
- 当前设计约束：后续阶段必须继续向南北朝东方奇幻、封妖禁地、瘴泽、妖域、符印机关等语境回收灰盒命名，不继续扩大现代实验室表达。

## Current Development Site

- 当前主工作区：`C:\Users\peng8\Desktop\Project\Game\nano-hunter`，分支 `main`，已合并 Stage15。
- 固定永久工作树：`C:\Users\peng8\.codex\worktrees\ffc3\nano-hunter`，当前用于 Stage16 阶段文档与后续实现，分支 `codex/stage-16-alpha-demo-candidate`。
- 当前阶段：Stage16 Alpha Demo 打包候选已启动阶段文档设计，默认采用固定永久工作树 + 阶段分支 + subagent / multiagent 分工。

## Latest Implemented Scope

- Stage16 已在阶段分支中实现 Alpha Demo 候选主体：最小 Demo 壳、Stage16 五房终局封印链、Stage15 completion 到 Stage16 入口、Stage16 Main 快照、HUD 完成态、Stage16 专项 GUT、Alpha Demo 灰盒 driver、QA checklist、release notes 和资产 / 音频 manifest 条目。
- 新增 `SealGuardianBoss / 封印守卫` 精英 Boss 原型。
- 新增 `Recovery Charge / 恢复充能`，玩家可通过战斗积累并消费为 1 点生命恢复。
- Stage14 回环房已接入 Stage15 前置段、混合遭遇房、Boss 房、挑战支线和完成房。
- Stage15 混合遭遇房与挑战支线已启用全清门控，避免玩家绕过战斗高潮直接进入 Boss 或返回主线。
- HUD 已同时显示 Stage14 Air Dash、Stage15 恢复充能、Boss 生命 / 状态和完成房反馈。
- Godot MCP 复核发现的 Stage15 completion room HUD 遗留目标与旧收集行已修复，并补入 Stage15 回归测试。
- 全仓自有 GDScript 函数入口注释审计已清零，关键变量组、状态机、房间链路、测试 helper 与 MCP 工具脚本已补中文说明。

## Latest Verification

- Stage16 分支上 `godot --headless --path . --import`：通过。
- Stage16 专项 GUT：`8/8 passed`，`66` 个断言。
- Stage15 专项 GUT：`11/11 passed`，`102` 个断言。
- 全量 GUT：`115/115 passed`，`843` 个断言。
- `git diff --check`：通过。
- 合并后 `main` 上 `godot --headless --path . --import`：通过。
- 合并后 `main` 上 Stage15 专项 GUT：`11/11 passed`，`102` 个断言。
- 合并后 `main` 上全量 GUT：`107/107 passed`，`777` 个断言。
- `scripts/**/*.gd` 与 `tests/**/*.gd` 函数入口前置注释扫描：`0` 缺口。
- 自有脚本、测试和进度文档常见中文乱码扫描：无命中。
- 合并后 `main` 上 `git diff --check HEAD`：通过。
- `project.godot`：Godot MCP 临时 autoload 已清理，无 MCP autoload 残留 diff。

## Current Risks

- Stage16 Godot MCP 运行态人工复核尚未完成；当前工具入口可见，轻量入口脚本可运行，但 MCP 只读调用仍返回 `Godot editor is not connected`，自动化通过不等于运行态复核完成。
- Stage16 视觉和音频仍以灰盒 / manifest 需求为主，`stage16_demo_sfx_pack` 与 `stage16_minimal_bgm` 尚未接入正式音频。
- `scripts/dev/enter-worktree-godot-mcp.ps1` 已临时收束为轻量 preflight，只记录 6505-6509 bridge 监听与连接状态，不再自动清理 bridge 或启动编辑器；更完整的 MCP 脚本链仍需后续修复。
- MCP 运行态截图现已改为本地证据产物，默认保留在 `tests/artifacts/local/`，不进入提交。
- Godot MCP 端口 `6505` 在收口检查时仍有本机监听；按当前约定仅记录，不全局释放可能属于其他活跃会话的 bridge。

## Next Steps

- Stage16 自动化已通过，下一步以当前分支作为运行态复核候选。
- 执行 Stage16 Godot MCP 运行态人工复核；若发现问题，修复并补回归测试后再进入提交拆分和阶段收口。

## References

- 阶段正式计划：`plan/2026-04-27-stage-15-combat-climax-and-elite-boss.md`
- 实现清单：`docs/implementation-plans/2026-04-27-stage-15-combat-climax-and-elite-boss.md`
- Stage16 阶段正式计划：`plan/2026-04-29-stage-16-alpha-demo-candidate.md`
- Stage16 实现清单：`docs/implementation-plans/2026-04-29-stage-16-alpha-demo-candidate.md`
- Stage16 设计文档：`spec-design/2026-04-29-stage-16-alpha-demo-candidate-design.md`
- 当日日志：`docs/progress/logs/2026-04-29.md`
- 关键时间线：`docs/progress/timeline.md`
