# Formal Demo Map Redesign Batch 9 - Stage16

## 目标

完成 Stage16 五房终局封印链的正式房间排版，并以全量回归和 39 房运行态截图审计收口整个 Formal Demo Map Redesign。

## 房间范围

- `stage16_seal_release_threshold_room`：`20x8`，上层释放节点与下层门禁。
- `stage16_talisman_relay_room`：`26x10`，三层递进符印中继链。
- `stage16_backtrack_confirmation_room`：`22x9`，上层回溯确认节点。
- `stage16_corruption_purge_room`：`24x9`，下层腐化危险与上层净化节点。
- `stage16_alpha_demo_end_room`：`18x8`，终局封印完成大厅。

## 实施结果

- [x] 五房按职责采用不同尺寸、轮廓和高度节拍。
- [x] 保留 Stage16 release / relay / backtrack / purge / completion 公共契约。
- [x] 补齐双向连接、return spawn、门前后安全落点和相机边界。
- [x] 正式 TileMap collision 与 visual-only surface 取代旧地面视觉。
- [x] 修正 Purge 节点悬在平台间的问题，将节点落到上层可踩面。
- [x] 运行态复核通过五房门控、节点激活、净化和终点反馈。
- [x] 完成 39 房全量截图与 contact sheet 人工复核。

## 验证

- Batch9 GUT：`5/5` tests，`218` asserts。
- Stage16 GUT：`20/20` tests，`529` asserts。
- Formal remap GUT：`8/8` tests，`182` asserts。
- 全量 GUT：`31` scripts，`219/219` tests，`6105` asserts。
- Batch9 运行态报告：全部检查项 `true`。
- 39 房截图审计：`39` 张截图，`P0=0 / P1=0 / P2=0`。
- Godot import：通过。

## 边界

- 本批未新增 Image Gen 资产，复用现有背景、符印、门禁、危险 VFX 和完成反馈。
- `test_room` 继续作为精确 shape 机制沙盒，以真实 shape bounds 顶沿 / cap 通过审计，不伪装成普通整格 TileMap 房间。
- 当前结果是 `codex/demo-level-formal-remap` 分支候选，尚未代表已经合并到 `main`。
