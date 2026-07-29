# Tutorial Room Terrain Template

## 目标

把 `tutorial_room.tscn` 从上一轮“碰撞驱动视觉试铺”升级为 64px 网格驱动的正式 demo 样板房：先固定移动 / 跳跃 / 出口缓冲网格蓝图，再由脚本铺设 TileMapLayer。地形与平台由 `formal_terrain_kit_ai01` 的 TileSet collision 作为权威碰撞；可见主路由 `GroundSurfaceVisual` 复用 `shrine_trial_tileset_ai01` 的 left / center / right 地面件连续覆盖，空中平台和 dash 门低顶由 `ThinPlatformSurfaceVisual` 使用裁薄后的 `tutorial_thin_platform_visual_ai01` 覆盖，门、背景、装饰和前景保持 visual-only。

## 范围

- 只处理 `tutorial_room.tscn`。
- 建立房间元素清单与 TileSet 语义清洗表。
- 重建 64px 网格蓝图驱动的分层 TileMapLayer 模板。
- 保留 `ExitBarrier`、`ExitZone`、`TutorialDummy`、能力门和房间推进逻辑的独立碰撞。

## 不做项

- 不拉长房间，不处理全局房间长度 / 纵深 / 回环。
- 不推广到 Stage14 gate 或其它主线房间。
- 不用 image gen 重生整套地形；本轮只从既有 `shrine_trial_tileset_ai01` 平台件裁出薄上沿。
- 不替换角色、敌人、HUD 或音频资产。
- 不让背景 / 装饰层参与碰撞。

## 实施清单

- 更新 `formal_terrain_kit_ai01`：把冲刺门上沿 tile 从普通装饰改为 `thin_solid` 语义。
- 更新 tutorial 模板生成脚本：生成 `TerrainCollisionVisual`、`PlatformCollisionVisual`、`DoorVisual`、`BackgroundVisual`、`DecorVisual`、`ForegroundVisual`。
- 将 tutorial 主路从“按旧碰撞块逐段填 tile”改为固定 64px 网格蓝图：主路 `x=-7..15, y=2` 连续 23 格；跳台 `x=-4..-3, y=1` 连续 2 格；dash 门低顶 `x=2..3, y=1`；出口安全落点 `x=10..14, y=2`。
- 退役带格线的 `GroundUnderlayVisual`；新增 `GroundSurfaceVisual`，复用 `shrine_trial_tileset_ai01` 的 left / center / right 地面件作为 visual-only 可见主路，避免主路读成独立碎砖。
- 新增 `tutorial_thin_platform_visual_ai01` 和 `ThinPlatformSurfaceVisual`，只覆盖跳台与 dash 门低顶；碰撞仍由 `PlatformCollisionVisual` / `TerrainCollisionVisual` 承担。
- 清空 tutorial 专用 `DoorVisual` / `BackgroundVisual` / `DecorVisual` / `ForegroundVisual` 的误读 tile，避免左墙重复件、孤立门柱、地面下碎石和漂浮小台座再次进入运行态。
- 禁用旧静态地形碰撞：旧 `StaticBody2D` 只保留 authoring bounds 和节点引用。
- 更新 tutorial GUT：检查 TileMapLayer 碰撞权威、visual-only 层、旧碰撞禁用、逻辑节点保留、主路连续 run、平台 cap、dash 门低顶、出口安全落点、GroundSurfaceVisual 和关键 cell 语义。
- 更新运行态截图复核：验证起点落地、跳台落地、无冲刺门禁阻挡、网格蓝图命中、GroundSurfaceVisual 命中，以及图层碰撞归属。
- 显式禁用 `ShrineTrialTilesetPreview` 等隐藏历史 TileMapLayer 的碰撞，避免 visible=false 但仍参与 physics 的空气墙。

## 验收标准

- Luna 脚底和视觉地面吻合。
- 所有可踩面一眼能看懂。
- 背景装饰不会被误读成路。
- 门口前后有安全落点。
- 跳台宽度不压迫下方通行，且仍能跳上落脚。
- 跳台和 dash 门低顶视觉不再使用厚石梁平台件，运行态读成薄平台 / 薄门楣。
- tutorial 专用视觉层不再出现孤立门框 / 小台座 / 重复墙件 / 地面下碎石。
- 断崖 / 平台边界有明确 cap，不再像悬浮碎块。
- TileMapLayer 承担地形 / 平台碰撞，门、背景、装饰、前景保持 visual-only。
- 运行态报告必须包含 `grid_blueprint_ok=true`、`surface_visual_ok=true`、`ground_underlay_retired=true`、`start_floor_ok=true`、`platform_floor_ok=true`。

## 验证命令

```powershell
godot --headless --path . -s res://scripts/dev/build_formal_terrain_kit_tileset_resource.gd
godot --headless --path . -s res://scripts/dev/apply_formal_terrain_kit_tutorial_trial.gd
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_formal_terrain_kit_resource.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_formal_terrain_kit_tutorial_trial.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit
godot --path . --display-driver windows --rendering-driver opengl3 -s res://scripts/dev/capture_tutorial_collision_driven_terrain_review.gd
godot --headless --path . --import
git diff --check -- scripts/dev/build_formal_terrain_kit_tileset_resource.gd scripts/dev/apply_formal_terrain_kit_tutorial_trial.gd scripts/dev/capture_tutorial_collision_driven_terrain_review.gd tests/demo/test_formal_terrain_kit_resource.gd tests/demo/test_formal_terrain_kit_tutorial_trial.gd scenes/rooms/tutorial_room.tscn docs/assets/tutorial-room-terrain-elements.md docs/implementation-plans/2026-07-09-tutorial-room-terrain-template.md
```

## 验证结果

- `test_formal_terrain_kit_resource.gd`：`3/3` tests，`183` asserts 通过。
- `test_formal_terrain_kit_tutorial_trial.gd`：`3/3` tests，`452` asserts 通过。
- `test_stage_5_tutorial_vertical_slice.gd`：`9/9` tests，`100` asserts 通过。
- `capture_tutorial_collision_driven_terrain_review.gd`：`ok=true`，报告确认 `grid_blueprint_ok=true`、`surface_visual_ok=true`、`thin_platform_surface_visible=true`、`ground_underlay_retired=true`、`start_floor_ok=true`、`platform_floor_ok=true`、`gate_blocks_without_dash=true`；起点、跳台、dash 门三张运行态截图已写入 `tests/artifacts/local/formal-terrain-kit/tutorial_room_template_review/`。
- `godot --headless --path . --import` 通过。
- `git diff --check` 通过，仅输出既有 CRLF 替换 warning。

## 下一步

本房已作为正式 demo 排版样板完成 64px 网格蓝图验收。下一步再把同一方法复制到 `combat_trial_room`、`goal_trial_room` 或 Stage14 gate；不要在本样板房继续扩全局关卡生成器。
