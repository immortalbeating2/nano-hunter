# 正式 Demo 房间设计重构执行清单

## 范围与事实源

- 设计真源：`spec-design/2026-08-13-formal-demo-room-design-recovery.md`
- 正式入口：`plan/2026-08-13-formal-demo-room-design-recovery.md`
- 当前工作树存在大量既有资产、UI、场景和脚本改动；执行时只修改当前任务列出的文件，不清理、不回退、不批量暂存。
- 当前进度：RDR-01–RDR-09 已实现并通过自动技术门禁；Windows 真窗口已生成 `18×3=54` 张诊断截图。真人首次体验门禁仍待按交付清单执行，因此当前只能称为技术候选。

## 执行原则

- 先灰盒、后美术。
- 先五房微循环、后 18 房推广。
- 先补失败测试，再修改运行时。
- 每一批最多触达 `3–5` 个核心房间场景。
- 每批同时验证正向、反向、能力前、能力后和失败恢复。
- 退出正式路线的房间只改状态标记或路由，不删除文件。

## RDR-01 冻结正式切片与兼容边界

**Files:**

- Create: `assets/configs/world_map/formal_demo_room_program.json`
- Create: `tests/room_design/test_formal_demo_room_program.gd`
- Modify: `assets/configs/world_map/alpha_demo_world_map.json`
- Modify: `scripts/ui/world_map_view.gd`
- Modify: `scripts/main/main.gd`
- Test: `tests/stage19/test_stage_19_room_blueprint_and_exploration_map.gd`
- Test: `tests/stage31/test_stage_31_save_and_waystation_travel.gd`

**Steps:**

1. RED：新增测试，要求正式 program 精确包含 F01–F18、每个 ID 对应唯一现有场景，并记录 `formal / reserve / merged` 状态。
2. RED：增加旧存档当前房属于 reserve 时回退到 F03 或最近安全入口的用例。
3. 在 JSON 中登记正式路线、支路、捷径、房间状态和旧编号映射；不让 JSON 直接驱动切房。
4. Main 继续以场景信号为切房权威，只读取兼容回退信息；地图视图默认突出正式切片，开发模式仍可查看全部 44 房。
5. 运行：

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/room_design/test_formal_demo_room_program.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage19/test_stage_19_room_blueprint_and_exploration_map.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage31/test_stage_31_save_and_waystation_travel.gd -gexit
```

**Checkpoint:** 正式 18 房集合和旧存档边界被机器保护，但尚未改变生产主路线。

## RDR-02 建立生产移动标尺

**Files:**

- Create: `scenes/dev/movement_metric_lab.tscn`
- Create: `scripts/dev/movement_metric_lab.gd`
- Create: `tests/room_design/test_room_movement_metrics.gd`
- Modify: `docs/progress/logs/2026-08-13.md` 或实际执行日期日志

**Steps:**

1. RED：测试要求从生产 Player 取得碰撞体尺寸、普通跳、Dash、Air Dash、攻击位移和击退的可重复样本。
2. 建立只供开发的移动标尺房，不添加新玩家能力。
3. 输出舒适主线、常规挑战和高难可选三档距离；禁止把单帧理论极限直接当房间尺寸。
4. 使用真实键盘和 synthetic Joypad 各跑一次；记录镜头覆盖、落点余量和两次内成功率。
5. 运行定向 GUT、Godot import，并把报告保存到 `tests/artifacts/local/room-design-recovery/movement-metrics/`。

**Checkpoint:** 后续所有平台坐标都能引用同一移动标尺。

## RDR-03 五房能力回环灰盒

**Files:**

- Modify: `scenes/rooms/stage13_miasma_marsh_gate_room.tscn`
- Modify: `scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn`
- Modify: `scenes/rooms/stage13_miasma_marsh_goal_room.tscn`
- Modify: `scenes/rooms/stage14_air_dash_shrine_room.tscn`
- Modify: `scenes/rooms/stage14_air_dash_gate_room.tscn`
- Modify: closest existing room scripts only when exported positions or current contracts cannot express the design
- Create: `tests/room_design/test_room_design_micro_loop.gd`

**Steps:**

1. RED：锁定五房的首次阻挡、Air Dash 授予、立即测试、反向返回和永久捷径状态。
2. 先移除普通出口上的通用门视觉，只保留 F07/F14 有状态理由的能力屏障。
3. 按移动标尺重做地形，确保失败落回安全区而不是触发全局跌落恢复。
4. 让 F09 首次主路与两支路权重不同；Air Dash 后出现可见的上层快速线。
5. 用 Godot MCP 依次复核：能力前正向、能力后正向、能力后反向、高速连续通过。
6. 五房人工灰盒没有通过前，不进入其余 13 房。

**Checkpoint:** 证明“预告 -> 获取 -> 测试 -> 返回 -> 捷径”在生产切房架构内成立。

## RDR-04 教程、首次实战与驿站入口

**Files:**

- Modify: `scenes/rooms/tutorial_room.tscn`
- Modify: `scenes/rooms/combat_trial_room.tscn`
- Modify: `scenes/rooms/stage11_demo_end_room.tscn`
- Modify: `scripts/rooms/tutorial_room.gd`
- Modify: `scripts/rooms/combat_trial_room.gd`
- Modify: `scripts/rooms/stage11_demo_end_room.gd`
- Modify: `scripts/main/main.gd`
- Test: `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`
- Test: `tests/stage7/test_stage_7_short_mainline_chain.gd`
- Create: `tests/room_design/test_formal_demo_opening_cluster.gd`

**Steps:**

1. RED：F02 必须在一次房间生命周期内完成观察、战斗、目标确认和离场；回访不会重复发奖或重新锁死。
2. 将 `goal_trial_room` 的目标职责并入 F02，旧场景保留兼容入口但退出正式 program。
3. F01 按四个子区重做轮廓与高度，不靠长直走廊和同一门框分段。
4. F03 作为 Hub，清楚区分教程返回、瘴泽主路、完成后回程和驿站交互。
5. 验证新游戏、Continue、F02 往返和 F03 多入口出生点。

**Checkpoint:** 前 `5–8` 分钟能形成教学、首次胜利和进入 Hub 的完整节奏。

## RDR-05 瘴泽核心路线与两条支路

**Files:**

- Modify: `scenes/rooms/stage13_miasma_marsh_entry_room.tscn`
- Modify: `scenes/rooms/stage13_miasma_marsh_caster_room.tscn`
- Modify: `scenes/rooms/stage13_miasma_marsh_miasma_room.tscn`
- Modify: `scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn`
- Modify: `scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn`
- Modify: `scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn`
- Modify: relevant thin wrapper scripts under `scripts/rooms/`
- Modify: `scripts/main/main.gd` only for moving the existing wind-seal grant
- Create: `tests/room_design/test_formal_demo_marsh_cluster.gd`
- Test: `tests/stage20/test_stage_20_metroidvania_six_gap_closure.gd`

**Steps:**

1. RED：F05 安全授予风印并依次验证“看见弹体 -> 斩散弹体 -> 在移动中应用”。
2. RED：F10 形成低风险回到 F08 的永久回环；F11 形成高风险前送到 F12 的替代路线。
3. F04 用区域大地标而不是文字提示建立方向。
4. F06 把下层瘴气与上层主路做成可读选择，并预留 Air Dash 回访奖励。
5. 保持 F08 无敌恢复；检查点前后不安排屏外弹体或出口重触发。
6. 验证支路奖励、Build、风印、失败恢复和反向进入。

**Checkpoint:** 瘴泽从重复横向房链变为包含教学、危险、恢复、分岔和回环的区域簇。

## RDR-06 Air Dash 三点回访与 Boss 前集结

**Files:**

- Modify: `scenes/rooms/stage14_backtrack_hub_room.tscn`
- Modify: `scripts/rooms/stage14_backtrack_hub_room.gd`
- Modify: F06/F07/F09 对应场景与薄包装脚本
- Modify: `scripts/main/main.gd`
- Create: `tests/room_design/test_air_dash_three_revisit_sites.gd`
- Test: `tests/stage18/test_stage_18_macro_metroidvania_world_graph.gd`

**Steps:**

1. RED：Air Dash 前 F06/F07/F09 三处不可取得新收益；解锁后分别开放奖励、高速路线或捷径。
2. 把原 F15 房内的三个 `BacktrackReward` 分散到旧地点，F15 只显示回访进度与 Boss 路线。
3. F07 的交叉能力门保持双向，并使用安全 spawn 与法坛 `↓` 主动确认；不以全局入口冷却掩盖出生点或通道重叠。
4. 至少一处回访为主线所需，另外两处可选；缺少可选奖励不能软锁。
5. 记录首次路线与捷径路线耗时，目标缩短至少 `30%`。

**Checkpoint:** Air Dash 真正改变旧地图，而不是只打开一扇新颜色门。

## RDR-07 综合战斗、Boss 与返回 Hub

**Files:**

- Modify: `scenes/rooms/stage15_mixed_gauntlet_room.tscn`
- Modify: `scenes/rooms/stage15_seal_guardian_boss_room.tscn`
- Modify: `scenes/rooms/stage15_completion_room.tscn`
- Modify: relevant scripts under `scripts/rooms/` and `scripts/combat/`
- Modify: `scripts/main/main.gd`
- Create: `tests/room_design/test_formal_demo_climax_cluster.gd`
- Test: `tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`
- Test: `tests/stage31/test_stage_31_save_and_waystation_travel.gd`

**Steps:**

1. RED：F16 的地面、冲锋和空中路线均能被 Dash/Air Dash 改变，清场门不会遮蔽普通出口语义。
2. F17 入口提供读招缓冲，失败后 `10–25` 秒回到可操作 Boss 阶段。
3. F18 提供战后降压、结果反馈和返回 F03 的明确驿路，不新增空走廊。
4. 验证 Boss 完成态、保存、Continue、返回 Hub 和重复进入不重复授奖。

**Checkpoint:** 形成“探索 -> 能力 -> 回访 -> 高潮 -> 回 Hub”的闭环。

## RDR-08 门语义与灰盒视觉清理

**Files:**

- Modify: F01–F18 对应 `.tscn`
- Modify: `assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres` only if an approved semantic tile is missing
- Modify: relevant generation scripts under `scripts/dev/` so they cannot overwrite repaired rooms with旧模板
- Create: `tests/room_design/test_transition_visual_semantics.gd`
- Modify: `docs/assets/asset-manifest.md` only when new formal assets are approved for production

**Steps:**

1. RED：普通户外出口不得包含可见通用门扇；所有可见屏障必须声明 `clear_barrier / ability_gate / boss_gate / waystation` 类别。
2. 把普通相邻连接改为山口、洞口、断桥、坡道或雾幕边界。
3. 清场门改为妖气结界；能力门改为统一符印或地形障碍；Boss 门保持唯一重型建筑。
4. 禁止旧批量脚本重新写回 F01–F18 的冻结模板；保留脚本时增加显式 reserve 范围或退役说明。
5. 灰盒验收通过后，另开资产候选与人工视觉签核，不在本任务自动生成全套背景。

**Checkpoint:** “门”只在有真实状态或建筑语义时出现。

## RDR-09 行为遥测与真人灰盒门禁

**Files:**

- Create: `scripts/dev/room_playtest_telemetry.gd`
- Create: `scripts/dev/capture_formal_demo_room_recovery.gd`
- Create: `docs/deliverables/formal-demo-room-recovery-candidate/playtest-checklist.md` only when the 18-room candidate is playable
- Create: `tests/room_design/test_room_playtest_telemetry.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md` only after a real milestone
- Modify: execution-date log under `docs/progress/logs/`

**Steps:**

1. 记录进入/离开时间、进入方向、离开方向、死亡位置、失败原因、地图打开次数、方向反转、出口误触、能力后返回路径和捷径发现时间。
2. 自动捕获每房入口、核心玩法和出口三张证据；自动截图只用于定位，不直接给出体验通过结论。
3. 运行 Godot `4.6.3` import、RDR 专项、Stage5/15/18/19/20/31 邻近回归、递归 GUT、主场景 smoke 和 `git diff --check`。
4. 使用未见过关卡的新玩家完成 `30–45` 分钟灰盒测试，逐项记录设计规格中的真人门禁。
5. 未达标时按具体房间和数据回到 RDR-03 至 RDR-08，不追加新区域掩盖问题。

**Checkpoint:** 只有自动门禁和真人灰盒门禁都满足，才能把正式切片称为 L2 类银河恶魔城 Demo 候选。

## 最终验证命令

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/room_design -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage18/test_stage_18_macro_metroidvania_world_graph.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage19/test_stage_19_room_blueprint_and_exploration_map.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage20/test_stage_20_metroidvania_six_gap_closure.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage31/test_stage_31_save_and_waystation_travel.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
git diff --check
```

## 提交边界

- 每个 RDR checkpoint 只提交本批房间、最近测试和必要文档。
- 提交信息使用“中文 + English”。
- 不批量暂存当前工作树。
- 合并、push、发布和旧房删除必须另获用户授权。
