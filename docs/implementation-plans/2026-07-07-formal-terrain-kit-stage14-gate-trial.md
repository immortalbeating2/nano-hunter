# Formal Terrain Kit Stage14 Gate Trial

## 目标

在不扩散到全部房间的前提下，用 `stage14_air_dash_gate_room.tscn` 验证 `formal_terrain_kit_ai01` 是否能按语义铺出可读的地形主体、门口、能力门和低密度装饰。

## 范围

- 仅修改 `scenes/rooms/stage14_air_dash_gate_room.tscn`。
- 新增一个运行前可重复执行的单房间 dev 脚本。
- 新增一条 GUT 回归，保护试铺层资源、语义格子和 visual-only 边界。
- 不迁移碰撞，不重刷 39 个房间，不启用 `better-terrain`。

## 语义表

| 语义 | 用途 | 碰撞来源 | 当前试铺位置 |
| --- | --- | --- | --- |
| `flat_ground_center` | 主路平地连续主体 | 仍由 `Floor/CollisionShape2D` 提供 | Floor 主体中段 |
| `left_cap` / `right_cap` | 平地左右端读值 | 仍由灰盒碰撞提供 | Floor 左右边界 |
| `door_frame` | 房间连接的竖向门框读值 | visual-only | `LeftExitZone` 与 `ExitZone` 前后 |
| `door_threshold` | 门口安全落点读值 | visual-only | 左右出口附近地面格 |
| `support` | 平台下沿 / 结构支撑 | visual-only | 主路下方低密度点缀 |
| `crack` / `decor` | 裂缝和装饰 | visual-only | 主路下方低密度点缀 |
| `one_way_platform` / `stair_ramp` / `cliff_side` / `cliff_top` | 本房没有真实玩法语境 | 不铺 | 后续房间再验证 |

## 验收

- Luna 仍落在原有 `StaticBody2D` 地板上，不因 TileMap 改变碰撞。
- 玩家能一眼区分主路、门口、安全落点、能力门和装饰。
- 旧 `dac_formal` TileMap 在本房隐藏，不和新试铺层叠加。
- 新 TileMap 使用 `formal_terrain_kit_ai01`，`collision_enabled=false`。
- GUT、Godot import 和 `git diff --check` 通过。

## 验证命令

```powershell
godot --headless --path . -s res://scripts/dev/apply_formal_terrain_kit_stage14_gate_trial.gd
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_formal_terrain_kit_stage14_gate_trial.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
godot --headless --path . --import
git diff --check -- scripts/dev/apply_formal_terrain_kit_stage14_gate_trial.gd tests/demo/test_formal_terrain_kit_stage14_gate_trial.gd scenes/rooms/stage14_air_dash_gate_room.tscn docs/implementation-plans/2026-07-07-formal-terrain-kit-stage14-gate-trial.md docs/progress/logs/2026-07-07.md
```

## 风险

- 当前 TileSet 源格为 `384px`，试铺层用 `scale=1/6` 对齐现有 `64px` 原型网格；如果后续正式接管碰撞，应先生成 64px 运行态 TileSet 或重做 TileSet tile size。
- 本房不验证楼梯和断崖；后续推广前仍需要再选一个含高度变化的房间。
