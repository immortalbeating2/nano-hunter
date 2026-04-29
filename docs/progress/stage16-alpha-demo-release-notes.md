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
- Godot MCP 运行态人工复核：未完成。当前 Codex 会话可见 `mcp__godot_mcp_pro__` 工具，`enter-worktree-godot-mcp.ps1` 可运行并报告 6505 有监听与连接，但 `get_scene_exports("res://scenes/main/main.tscn")` 返回 `Godot editor is not connected`，因此本轮只记录为 MCP 连接阻塞，不视为运行态复核通过。

## 已知问题

- Stage16 视觉和音频仍为灰盒 / 占位状态。
- `stage16_demo_sfx_pack` 与 `stage16_minimal_bgm` 只记录需求，尚未接入正式音频。
- Stage13 旧命名仍存在 `bio_waste` 路径，Stage16 文案和资产备注已开始向妖瘴、封印渗漏、符印机关方向回收。
- Demo shell 是最小 Alpha Demo 外壳，不包含正式设置页、存档槽、成就或完整键位配置。

## 下一步

- 修复或重连 Godot MCP 编辑器会话后，执行主菜单、暂停 / 重开、Stage15 completion 到 Stage16 入口、Stage16 五房链路和 Alpha Demo 完成反馈的运行态人工复核。
- 若 MCP 复核发现问题，修复后补回归测试，并再次更新本 release notes 的已知问题分级。
