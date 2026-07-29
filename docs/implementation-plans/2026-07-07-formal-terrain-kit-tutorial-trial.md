# Formal Terrain Kit Tutorial Trial

## 目标

把 Stage14 门房试铺使用的 `formal_terrain_kit_ai01` 规则单独应用到真正第一关 `tutorial_room.tscn`，验证新手房的平地、薄平台、门口和新手可读性。

## 复核结论

第一版硬编码格位已废弃；2026-07-08 已改为从真实 `StaticBody2D/CollisionShape2D` bounds 反推视觉瓦片。主地面 / dash 门使用 `FormalTerrainKitTutorialTrial`，跳跃教学薄平台使用独立 `FormalTerrainKitTutorialThinTrial` 对齐非 64px 倍数的碰撞 top。旧 `FormalTerrainTilemapDecor` / `FormalForegroundEdgeDecor` 隐藏保留。

## 范围

- 仅修改 `scenes/rooms/tutorial_room.tscn`。
- 新增一个 tutorial 专用 dev 脚本和一条 GUT 回归。
- 不迁移碰撞，不重刷全部房间，不改教程流程和敌人逻辑。

## 语义表

| 语义 | Tutorial 用途 | 碰撞来源 |
| --- | --- | --- |
| `flat_ground_center` | 起点、战斗区、出口区的主路平地 | 现有 `StaticBody2D` |
| `left_cap` / `right_cap` | 每段地面边界 | 现有 `StaticBody2D` |
| `one_way_platform` | 跳跃教学薄平台视觉读值 | 现有 `JumpGuidePlatform` |
| `door_frame` | 出口门 / 房间连接读值 | visual-only |
| `door_threshold` | 出口安全落点 | visual-only |
| `support` / `crack` / `decor` | 地面下方低密度装饰 | visual-only |
| `stair_ramp` / `cliff_side` / `cliff_top` | 本房不验证 | 不铺 |

## 验收

- 旧 `FormalTerrainTilemapDecor` / `FormalForegroundEdgeDecor` 在 tutorial 房隐藏保留，不与新层叠加。
- `FormalTerrainKitTutorialTrial` 和 `FormalTerrainKitTutorialThinTrial` 必须可见，且 `collision_enabled=false`。
- 旧 `FormalTerrainTilemapDecor` / `FormalForegroundEdgeDecor` 必须隐藏保留，不与新层叠加。
- 视觉格必须从 `FloorStart`、`JumpGuidePlatform`、`DashGateLeft`、`DashGateRight`、`DashGateCeiling`、`CombatFloor`、`ExitFloor` 的碰撞 bounds 推导。
- 运行态截图复核必须证明起点落地、跳台落地、dash 门无冲刺时阻挡。
- Tutorial GUT、Stage5 GUT、Godot import 和 diff check 通过。

## 验证命令

```powershell
godot --headless --path . -s res://scripts/dev/apply_formal_terrain_kit_tutorial_trial.gd
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_formal_terrain_kit_tutorial_trial.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit
godot --path . --display-driver windows --rendering-driver opengl3 -s res://scripts/dev/capture_tutorial_collision_driven_terrain_review.gd
godot --headless --path . --import
git diff --check -- scripts/dev/apply_formal_terrain_kit_tutorial_trial.gd tests/demo/test_formal_terrain_kit_tutorial_trial.gd scenes/rooms/tutorial_room.tscn docs/implementation-plans/2026-07-07-formal-terrain-kit-tutorial-trial.md docs/progress/logs/2026-07-07.md
```

## 风险

- 这是 tutorial 单房间碰撞驱动试铺，不是全房间推广器。
- 当前只处理 RectangleShape2D；后续若遇到 PolygonShape2D 或斜坡，需要另做语义规则。
