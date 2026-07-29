# Stage14 Gate Terrain Template Copy

## 目标

把 `tutorial_room` 已验证的房间级 Terrain 模板规则复制到 `stage14_air_dash_gate_room.tscn`，验证同一套 TileSet / TileMapLayer 分层方法在 Stage14 能力门控房间中不会再产生悬空碎块、空气路或空气墙。

## 范围

- 仅处理 `stage14_air_dash_gate_room.tscn`。
- `LeftWall` / `Floor` 只作为 authoring bounds 保留，真实地形碰撞迁移到 `TerrainCollisionVisual`。
- `DoorVisual`、`BackgroundVisual`、`DecorVisual`、`ForegroundVisual` 保持 visual-only。
- `GateBarrier`、`ExitZone`、`LeftExitZone`、`AirDashGateSensor` 继续作为独立逻辑碰撞，不塞进 TileMapLayer。

## 不做项

- 不全图推广。
- 不处理 Stage14 其它房间。
- 不改变 Air Dash 解锁 / 门控 / 房间切换语义。
- 不处理房间长度、节奏层级或完整关卡重排。
- 不把背景装饰、门框装饰或前景边缘变成碰撞权威。

## 关键改动

- 新增 / 刷新 `TerrainCollisionVisual`，使用 `formal_terrain_kit_ai01` TileSet collision 承担 Stage14 gate 地形权威碰撞。
- 显式隐藏并禁用旧试铺层碰撞：`MiasmaTilesetPreview`、`ShrineTrialTilesetPreview`、`FormalTerrainTilemapDecor`、`FormalForegroundEdgeDecor`、`FormalTerrainKitSemanticTrial`。
- 禁用 `LeftWall` / `Floor` 的 `StaticBody2D` collision layer / mask 和 `CollisionShape2D.disabled`，保留节点用于追溯 bounds。
- 保留 `GateBarrier` / `ExitZone` / `LeftExitZone` 的独立碰撞，避免把能力门和出口触发误并入地形 TileMap。

## 验收标准

- Luna 出生点脚底和视觉地面吻合。
- Stage14 gate 的可踩地面 / 左墙一眼能看懂，地形不读成背景装饰。
- 背景、装饰、门框、前景边缘均不参与碰撞。
- 门口前后保留安全落点，Air Dash 解锁后能穿过右侧门。
- 断崖 / 地形边界有明确 cap，不再像悬浮碎块。
- TileMapLayer 分层语义清楚：地形碰撞权威只在 `TerrainCollisionVisual`，视觉层不改逻辑碰撞语义。

## 验证结果

- `godot --headless --path . -s res://scripts/dev/apply_formal_terrain_kit_stage14_gate_trial.gd` 通过。
- `test_formal_terrain_kit_stage14_gate_trial.gd`：`3/3` tests，`200` asserts 通过。
- `test_stage_14_backtracking_and_ability_gating.gd`：`16/16` tests，`389` asserts 通过。
- `capture_stage14_gate_terrain_template_review.gd`：`ok=true`，确认 layer authority、visual-only layers、旧碰撞禁用、逻辑碰撞保留、出生点落地和 Air Dash 过门均通过。
