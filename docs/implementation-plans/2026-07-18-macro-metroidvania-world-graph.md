# 宏观银河城世界图重构实施计划

## 目标

在不新增大批房间、不重写现有战斗和地形蓝图的前提下，把 34 房长主干重接为 3 个区域环路、5 条远端连接，并让 Air Dash、Stage13 两条支路和 12 个锚点房产生真实回访价值。

权威设计：`spec-design/2026-07-18-macro-metroidvania-world-graph-design.md`

## 工作树边界

- 当前工作树存在 Stage17 资产处置和正式平台校正的未提交改动。
- 本任务保留这些改动，不回滚、不覆盖生成资源，不提交用户既有文件。
- 场景修改必须基于当前文件做局部补丁；每批完成后检查 `git diff -- <本批文件>`，确认没有丢失既有节点或资源引用。
- 在当前脏树收口前不执行 merge、push、worktree 删除或分支清理。

## Phase 1：拓扑契约红灯

- [x] 新增 `tests/stage18/test_stage_18_macro_metroidvania_world_graph.gd`
- [x] 断言 3 个区域环路和 SC-01 至 SC-05 的目标 / spawn / 条件
- [x] 断言 Stage13 两条支路出口和收益 ID 不同
- [x] 断言 12 个锚点房具备对应节点或导出职责
- [x] 运行专项 GUT，记录预期红灯

## Phase 2：共享最小实现

- [x] `Stage9RoomBase` 增加 Main 绑定、通用 ShortcutZone 和 NarrativeStele 支持
- [x] `Stage14BacktrackingRoomBase` 复用父类 Main 引用，不保留重复状态
- [x] Main 增加两个持久探索收益的去重字典和公开查询
- [x] Stage13 奖励收集同步到 Main
- [x] 新增 `scripts/rooms/breakable_secret_wall.gd`
- [x] 为共享逻辑补最小 GUT 断言

## Phase 3：环路 A

- [x] Stage9 Switch 增加 SC-01 入口、独立 spawn 和上层路线地标
- [x] Stage10 Branch 左侧返回改到 Stage9 Switch，保留右侧回到 Stage10 Aerial
- [x] Stage10 Aerial 与 Stage13 Entry 增加 SC-02 双向连接
- [x] Stage10 Branch 增加秘密墙和瘴泽前兆碑
- [x] 验证 Air Dash / marsh_relic 条件与双向安全落点

## Phase 4：环路 B

- [x] Stage13 Resource Branch 出口改到 Checkpoint
- [x] Stage13 Resource Branch 增加秘密墙并授予 `marsh_relic`
- [x] Stage13 Challenge Branch 出口改到 Goal
- [x] Stage13 Challenge Branch 授予 `warden_sigil`
- [x] 保留 Hub -> Return -> Goal 普通路线
- [x] 验证资源支路低压回环与挑战支路清场前送差异

## Phase 5：环路 C

- [x] Stage14 Hub 增加 SC-05 入口，要求 `warden_sigil`
- [x] Stage15 Challenge 左侧返回改到 Stage14 Hub，右侧仍回 Gauntlet
- [x] 保留 Loop Return -> Pressure -> Gauntlet 普通路线
- [x] 验证捷径不跳过 Boss、不破坏失败恢复和 checkpoint

## Phase 6：锚点房

- [x] Tutorial：训练碑
- [x] Stage9 Entry：区域地标 / 封闭路线预示
- [x] Stage9 Switch：机关 / SC-01
- [x] Stage10 Aerial：SC-02 地标
- [x] Stage10 Branch：秘密墙 / 前兆碑
- [x] Stage13 Entry：瘴泽碑 / SC-02
- [x] Stage13 Gate：符印机关地标
- [x] Stage13 Branch Hub：三路地标
- [x] Stage13 Resource：秘密墙 / 遗物
- [x] Stage13 Challenge：危险机关 / 挑战符
- [x] Stage14 Shrine / Hub：能力碑 / SC-05
- [x] Stage15 Challenge：封妖禁地地标 / SC-05 返回

## Phase 7：验证与留痕

- [x] 专项 Stage18 GUT 通过
- [x] Stage9 / 10 / 13 / 14 / 15 / 16 邻近 GUT 通过
- [x] 全量 GUT 通过
- [x] `godot --headless --path . --import` 通过
- [x] `godot --headless --path . --quit-after 3` 通过
- [x] 输入式首次通关 replay 到 Stage16 终点
- [x] 新增可选环路运行态复核，覆盖 SC-01、SC-02、两条 Stage13 支路和 SC-05
- [x] 更新 `docs/progress/status.md`、`docs/progress/timeline.md`、`docs/progress/logs/2026-07-18.md`
- [x] `git diff --check`，并确认无无关文件混入

## 收口证据

- Stage18：`12/12` tests、`1711` asserts；其中逐房扫描正式薄平台，确认碰撞格有对应视觉格、均为 one-way，缩放后碰撞厚度不超过 `4px`。
- 全量 GUT：`34` scripts、`257/257` tests、`7919` asserts。
- 全房间 DAC：`39` 房，`P0=0 / P1=0 / P2=0`。
- input-only replay：首次通关自然经过 `34` 房，到达 `stage16_alpha_demo_end_room`，完成标记为真，`P0=0 / P1=0 / P2=0`。
- Godot `4.6.3` import 与主场景 smoke 退出码均为 `0`。

## 完成门禁

- 目标 1–5 均有场景、代码、测试和运行态证据。
- 自动报告不能替代路线是否合理的人工复核。
- 未取得当次新鲜全流程证据前，不宣称宏观银河城结构完成。
