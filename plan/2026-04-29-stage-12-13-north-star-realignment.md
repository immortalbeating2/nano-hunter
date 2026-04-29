# Stage 12-13 北极星回收正式修正计划

## Summary

本阶段修正以当前 Stage 15 稳定基线为前提，在当前会话工作树中创建 `codex/north-star-realign-stage12-13` 分支，回收 Stage 12-13 中偏离总设计北极星的现代实验室 / 生物废液语义。

本次不是单纯文件迁移，而是对已开发内容做语义重包装：保留玩法结构、房间数量、敌人行为、门控规则和测试覆盖，将主题表达改回山门古刹、镇妖试炼场、瘴泽妖域、符印封印机关和瘴气妖术投射者。

## Stage Boundary / Preflight

- 工作模式：当前工作树 + 阶段修正分支。
- 分支：`codex/north-star-realign-stage12-13`。
- 前置确认：当前 `HEAD` 被 `main` 包含，工作区干净后开分支。
- 协作设置：`design`、`asset_direction`、`qa` 子代理只读审查，主代理串行整合和改文件。
- 不做项：不新增 Stage 16 内容，不改 Stage 14 Air Dash 玩法，不改战斗数值，不新增正式系统。

## Key Changes

- Stage 12：`biome_01_lab` 改为 `biome_01_shrine_trial`，语境回收到山门古刹 / 镇妖试炼场。
- Stage 13：`bio_waste` 改为 `miasma_marsh`，语境回收到瘴泽妖域 / 妖域腐化淤泽。
- 危险：`acid_hazard` 改为 `miasma_hazard`，表达为瘴气 / 腐瘴危险。
- 门控：`purification_gate/node` 改为 `seal_gate/seal_node`，表达为符印封门 / 镇妖印节点。
- 敌人：`spore_shooter` 改为 `miasma_caster`，表达为瘴气妖术投射者。
- 文档：新增设计修正文档与 implementation plan，并同步既有 Stage 12/13 文档、roadmap、asset manifest 和进度文档。

## Public Interfaces

- 房间公共契约不变：`room_transition_requested`、`checkpoint_requested`、`goal_completed`、`get_hud_context() -> Dictionary`。
- 敌人公共契约不变：`receive_attack(...)`、`defeated`。
- HUD 与 Main 快照语义不新增正式系统，只更新可见目标文案和提示语。
- Stage 13 专属 helper、节点名和测试名允许随语义回收重命名。

## Test Plan

- `git diff --check`
- `godot --headless --path . --import`
- Stage 13 专项 GUT：验证瘴泽区域、瘴气危险、封印门控、瘴气妖术投射者和主线灰盒 driver。
- Stage 14 专项 GUT：验证 Stage 13 终点房到 Air Dash 前置入口未断。
- Stage 15 专项 GUT：验证 Stage 15 混合遭遇和挑战支线引用新敌人名后未断。
- 全量 GUT：保持当前自动化基线不回退。
- 残留扫描：自有文件中不应残留正式语境下的旧现代实验室命名；旧名只允许出现在历史映射说明中。

## Manual Review / Runtime Review

如 Godot MCP 可用，最小运行态复核 Stage 13 入口、瘴气危险、封印门控、终点房和 Stage 14 前置入口。若 MCP 不可用，在当日日志记录 fallback 原因，并以 headless import、GUT 和残留扫描作为本次修正的最低验收证据。

## Assumptions

- 旧“实验室 / 生物废液 / 酸液 / 孢子”命名是 Stage 12-13 灰盒历史偏移。
- 本次只改变主题表达、路径身份、可见文案和资产语义，不改变玩法结构和数值行为。
- `.import` 与 Godot 自动导入缓存以 `godot --headless --path . --import` 通过为准。
