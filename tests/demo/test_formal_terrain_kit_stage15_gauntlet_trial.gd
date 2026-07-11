extends GutTest

# Stage15 mixed gauntlet 正式战斗场样板契约。
# 三类敌人必须分别占据近战区、冲锋通道和空中层，支路与 Boss 门不再挤在单层短走廊。

const ROOM_PATH := "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"
const PLAYER_PATH := "res://scenes/player/player_placeholder.tscn"
const TERRAIN_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"

const CAMERA_LIMITS := Rect2i(-512, -288, 1664, 576)
const TERRAIN_SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)
const PLATFORM_OFFSET := Vector2(0.0, -16.0)
const SURFACE_OFFSET := Vector2(0.0, -7.0)
const FLOOR_START := Vector2i(-8, 3)
const FLOOR_LENGTH := 26
const BRANCH_PLATFORM_START := Vector2i(-7, 2)
const CHARGER_PLATFORM_START := Vector2i(5, 2)
const AERIAL_PLATFORM_START := Vector2i(11, 2)
const PLATFORM_LENGTH := 4
const PLAYER_HALF_HEIGHT := 20.0

const TERRAIN_LAYER_NAME := "TerrainCollisionVisual"
const PLATFORM_LAYER_NAME := "PlatformCollisionVisual"
const SURFACE_LAYER_NAME := "GroundSurfaceVisual"
const THIN_SURFACE_LAYER_NAME := "ThinPlatformSurfaceVisual"
const VISUAL_ONLY_TILE_LAYERS := ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]
const OLD_TILE_LAYERS := ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]


func before_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("dash")


# 战斗碰撞、可见表面与空层职责固定，不允许恢复随机视觉 tile。
func test_stage15_gauntlet_layers_match_formal_combat_room_contract() -> void:
	var room := _instantiate_room()
	var terrain := room.get_node_or_null(TERRAIN_LAYER_NAME) as TileMapLayer
	var platform := room.get_node_or_null(PLATFORM_LAYER_NAME) as TileMapLayer
	var surface := room.get_node_or_null(SURFACE_LAYER_NAME) as TileMapLayer
	var thin_surface := room.get_node_or_null(THIN_SURFACE_LAYER_NAME) as TileMapLayer
	assert_not_null(terrain)
	assert_not_null(platform)
	assert_not_null(surface)
	assert_not_null(thin_surface)
	if terrain == null or platform == null or surface == null or thin_surface == null:
		return

	assert_true(bool(terrain.get("collision_enabled")))
	assert_eq(terrain.tile_set.resource_path, TERRAIN_TILESET_PATH)
	assert_eq(terrain.scale, TERRAIN_SCALE)
	assert_true(bool(platform.get("collision_enabled")))
	assert_eq(platform.tile_set.resource_path, TERRAIN_TILESET_PATH)
	assert_eq(platform.position, PLATFORM_OFFSET)
	assert_eq(platform.scale, TERRAIN_SCALE)
	assert_false(bool(surface.get("collision_enabled")))
	assert_eq(surface.tile_set.resource_path, SURFACE_TILESET_PATH)
	assert_eq(surface.position, SURFACE_OFFSET)
	assert_false(bool(thin_surface.get("collision_enabled")))
	assert_eq(thin_surface.tile_set.resource_path, THIN_SURFACE_TILESET_PATH)

	for layer_name: String in VISUAL_ONLY_TILE_LAYERS:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		assert_not_null(layer)
		if layer != null:
			assert_false(bool(layer.get("collision_enabled")))
			assert_true(layer.get_used_cells().is_empty(), "%s 不得随机塞入战斗场。" % layer_name)


# 26x9 战斗蓝图必须有连续主地面，以及支路、冲锋规避和空中接敌三段平台。
func test_stage15_gauntlet_blueprint_separates_three_enemy_lanes() -> void:
	var room := _instantiate_room()
	var terrain := room.get_node(TERRAIN_LAYER_NAME) as TileMapLayer
	var platform := room.get_node(PLATFORM_LAYER_NAME) as TileMapLayer
	var surface := room.get_node(SURFACE_LAYER_NAME) as TileMapLayer
	var thin_surface := room.get_node(THIN_SURFACE_LAYER_NAME) as TileMapLayer

	_assert_solid_run(terrain, FLOOR_START, FLOOR_LENGTH)
	assert_eq(terrain.get_used_cells().size(), FLOOR_LENGTH)
	for start: Vector2i in [BRANCH_PLATFORM_START, CHARGER_PLATFORM_START, AERIAL_PLATFORM_START]:
		_assert_one_way_run(platform, start, PLATFORM_LENGTH)
		_assert_thin_surface_run(thin_surface, start, PLATFORM_LENGTH)
	assert_eq(platform.get_used_cells().size(), PLATFORM_LENGTH * 3)
	assert_eq(thin_surface.get_used_cells().size(), PLATFORM_LENGTH * 3)
	_assert_surface_run(surface, FLOOR_START, FLOOR_LENGTH)
	assert_eq(surface.get_used_cells().size(), FLOOR_LENGTH)

	assert_eq(room.get_node("BasicMeleeEnemy").position, Vector2(64.0, 216.0))
	assert_eq(room.get_node("GroundChargerEnemy").position, Vector2(448.0, 216.0))
	assert_eq(room.get_node("AerialSentinelEnemy").position, Vector2(832.0, 104.0))
	assert_eq(room.get_node("ChallengeBranchZone").position, Vector2(-352.0, 104.0))


# 原有全清门控、支路、checkpoint 和 Boss 连接必须完整保留。
func test_stage15_gauntlet_preserves_flow_and_logic_contracts() -> void:
	var room := _instantiate_room()
	assert_eq(room.get("challenge_branch_room_path"), "res://scenes/rooms/stage15_challenge_branch_room.tscn")
	assert_eq(room.get("next_room_path"), "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn")
	assert_eq(room.get("next_spawn_id"), &"stage15_boss_start")
	assert_eq(room.get("checkpoint_spawn_id"), &"stage15_mixed_gauntlet_return")
	assert_eq(room.get("default_step_id"), &"stage15_mixed_gauntlet")
	assert_eq(room.get("cleared_step_id"), &"stage15_mixed_gauntlet_clear")
	assert_true(bool(room.get("checkpoint_on_ready")))
	assert_true(bool(room.get("require_all_enemies_defeated")))
	assert_eq(room.call("get_remaining_required_enemy_count"), 3)
	assert_eq(room.call("get_spawn_position", &"stage15_mixed_gauntlet_start"), Vector2(-384.0, 160.0))
	assert_eq(room.call("get_spawn_position", &"stage15_mixed_gauntlet_return"), Vector2(-208.0, 160.0))

	for path: String in ["ChallengeBranchZone/CollisionShape2D", "GateBarrier/CollisionShape2D", "ExitZone/CollisionShape2D"]:
		var shape := room.get_node_or_null(path) as CollisionShape2D
		assert_not_null(shape)
		if shape != null:
			assert_false(shape.disabled)
	for body_name: String in ["LeftWall", "Floor"]:
		var body := room.get_node_or_null(body_name) as StaticBody2D
		var shape := body.get_node_or_null("CollisionShape2D") as CollisionShape2D if body != null else null
		assert_not_null(body)
		assert_not_null(shape)
		if body != null:
			assert_eq(body.collision_layer, 0)
			assert_eq(body.collision_mask, 0)
		if shape != null:
			assert_true(shape.disabled)
	for layer_name: String in OLD_TILE_LAYERS:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		assert_not_null(layer)
		if layer != null:
			assert_false(layer.visible)
			assert_false(bool(layer.get("collision_enabled")))


# 背景、门和出口位置共同覆盖完整战斗场，并保留门前后安全地面。
func test_stage15_gauntlet_camera_background_gate_and_exit_match_blueprint() -> void:
	var room := _instantiate_room()
	assert_eq(room.call("get_camera_limits"), CAMERA_LIMITS)
	assert_eq(room.get_node("GateBarrier").position, Vector2(1024.0, 168.0))
	assert_eq(room.get_node("ExitZone").position, Vector2(1104.0, 160.0))
	var background := room.get_node_or_null("GauntletBackgroundArt") as Sprite2D
	assert_not_null(background)
	if background != null:
		assert_true(background.visible)
		assert_eq(background.position, Vector2(320.0, 0.0))
		assert_eq(background.scale, Vector2(1.02, 1.02))
		var half_size := Vector2(background.texture.get_width(), background.texture.get_height()) * background.scale * 0.5
		assert_true(background.position.x - half_size.x <= CAMERA_LIMITS.position.x)
		assert_true(background.position.x + half_size.x >= CAMERA_LIMITS.end.x)


# 支路只在上层触发；冲锋敌在上层规避台下不会启动，落回同高度通道后才冲锋。
func test_stage15_gauntlet_runtime_proves_optional_branch_and_charger_lane() -> void:
	var room := _instantiate_room()
	var player := await _spawn_player(room, Vector2(-384.0, 160.0))
	var transitions: Array[Dictionary] = []
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	await _advance_process_frames(6)
	assert_true(player.is_on_floor())
	assert_true(transitions.is_empty(), "主路出生点不能误触左上挑战支路。")

	player.global_position = Vector2(-352.0, 80.0)
	player.velocity = Vector2.ZERO
	await _wait_until_settled(player, 90)
	await _advance_process_frames(4)
	assert_eq(transitions.size(), 1)
	if transitions.size() == 1:
		assert_eq(transitions[0].get("target"), "res://scenes/rooms/stage15_challenge_branch_room.tscn")

	var charger_room := _instantiate_room()
	var charger_player := await _spawn_player(charger_room, Vector2(448.0, 80.0))
	var charger := charger_room.get_node("GroundChargerEnemy")
	await _advance_physics_frames(20)
	assert_true(charger_player.is_on_floor())
	assert_false(bool(charger.call("is_charge_active")), "上层规避台与冲锋通道必须是不同高度带。")
	charger_player.global_position = Vector2(520.0, 160.0)
	charger_player.velocity = Vector2.ZERO
	await _wait_until_settled(charger_player, 90)
	await _advance_physics_frames(6)
	assert_true(bool(charger.call("is_charge_active")), "玩家落回地面通道后冲锋敌必须形成压力。")


func _instantiate_room() -> Node2D:
	var packed := load(ROOM_PATH) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return null
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room


func _spawn_player(room: Node2D, spawn_position: Vector2) -> CharacterBody2D:
	var packed := load(PLAYER_PATH) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return null
	var player := packed.instantiate() as CharacterBody2D
	player.global_position = spawn_position
	add_child_autofree(player)
	room.call("bind_player", player)
	await _wait_until_settled(player, 90)
	return player


func _assert_solid_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var cell := Vector2i(start.x + offset, start.y)
		assert_eq(layer.get_cell_source_id(cell), 0)
		var expected := Vector2i(0, 0) if posmod(offset, 2) == 0 else Vector2i(1, 0)
		if offset == 0:
			expected = Vector2i(2, 0)
		elif offset == length - 1:
			expected = Vector2i(3, 0)
		assert_eq(layer.get_cell_atlas_coords(cell), expected)
		_assert_collision(layer, cell, false)


func _assert_one_way_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var cell := Vector2i(start.x + offset, start.y)
		assert_eq(layer.get_cell_source_id(cell), 0)
		_assert_collision(layer, cell, true)


func _assert_surface_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var expected := Vector2i(1, 0)
		if offset == 0:
			expected = Vector2i(0, 0)
		elif offset == length - 1:
			expected = Vector2i(2, 0)
		assert_eq(layer.get_cell_atlas_coords(Vector2i(start.x + offset, start.y)), expected)


func _assert_thin_surface_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	_assert_surface_run(layer, start, length)


func _assert_collision(layer: TileMapLayer, cell: Vector2i, one_way: bool) -> void:
	var source := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
	assert_not_null(source)
	if source == null:
		return
	var data := source.get_tile_data(layer.get_cell_atlas_coords(cell), 0)
	assert_not_null(data)
	if data != null:
		assert_eq(data.is_collision_polygon_one_way(0, 0), one_way)


func _wait_until_settled(player: CharacterBody2D, max_frames: int) -> void:
	await _advance_physics_frames(2)
	for _i: int in range(max_frames):
		if player.is_on_floor() and absf(player.velocity.x) <= 0.1 and absf(player.velocity.y) <= 0.1:
			await _advance_physics_frames(2)
			return
		await _advance_physics_frames(1)


func _advance_physics_frames(frame_count: int) -> void:
	for _i: int in range(frame_count):
		await get_tree().physics_frame


func _advance_process_frames(frame_count: int) -> void:
	for _i: int in range(frame_count):
		await get_tree().process_frame
