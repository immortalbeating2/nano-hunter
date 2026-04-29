# Stage16 Alpha Demo Release Notes

## 试玩入口

- 入口场景：`res://scenes/main/main.tscn`
- 默认流程：主菜单开始试玩，从教程起点推进到 Stage16 Alpha Demo 终点。
- 重开入口：Demo shell 暂停菜单和完成反馈均应允许回到教程起点。

## 当前内容范围

- Alpha Demo 当前目标为 `20-28` 个可用房间范围内的原型候选。
- 已包含教程、早期战斗、Stage13 第二小区域、Stage14 Air Dash 回溯链、Stage15 Seal Guardian Boss 和 Stage16 终局封印链。
- Stage16 新增五房链路：
  - `stage16_seal_release_threshold_room`
  - `stage16_talisman_relay_room`
  - `stage16_backtrack_confirmation_room`
  - `stage16_corruption_purge_room`
  - `stage16_alpha_demo_end_room`

## 已验证内容 / 验证命令

- `godot --headless --path . --import`：通过。
- Stage16 专项 GUT：`8/8 passed`，`66` 个断言。
- Stage15 专项 GUT：`11/11 passed`，`102` 个断言。
- 全量 GUT：`115/115 passed`，`843` 个断言。
- `git diff --check`：通过。
- Godot MCP 运行态人工复核：通过。当前会话已连接固定工作树 Godot 编辑器，确认 `Main.tscn` 主菜单、暂停 / 继续 / 重开入口、Stage15 completion room、Stage16 五房链路、导出 next-room 链路和 Alpha Demo 终点节点。
- MCP 本地截图：`tests/artifacts/local/stage16-mcp/main_menu.png`、`pause_menu.png`、`stage15_completion.png`、`stage16_seal_release_threshold.png`、`stage16_alpha_demo_end.png`；按项目约定不提交。

## 已知问题

- Stage16 视觉和音频仍为灰盒 / 占位状态。
- `stage16_demo_sfx_pack` 与 `stage16_minimal_bgm` 只记录需求，尚未接入正式音频。
- Stage13 旧 `bio_waste` 路径已通过北极星回收修正迁移到 `miasma_marsh`，Stage16 文案和资产备注继续使用妖瘴、封印渗漏、符印机关方向。
- Demo shell 是最小 Alpha Demo 外壳，不包含正式设置页、存档槽、成就或完整键位配置。

## 下一步

- 合并 Stage16 到 `main` 后，在主工作区重跑 Godot import、Stage16 专项 GUT、Stage15 专项 GUT、全量 GUT 与 `git diff --check HEAD`。
- 若合并后主线验证通过，将 `main` 推送到 `origin/main`，并记录 Stage16 Alpha Demo 候选收口。
