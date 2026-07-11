extends GutTest

# Stage14 Air Dash gate 正式样板契约。
# 房间必须形成下层失败回落、两段起跳、Air Dash 缺口和右侧能力门，不再按旧 shape 随机塞 tile。

const ROOM_PATH := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const PLAYER_PATH := "res://scenes/player/player_placeholder.tscn"
const TERRAIN_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"
const CLIFF_MASS_TEXTURE_PATH := "res://assets/art/textures/dac_continuous_stone_underlay.png"

const TERRAIN_LAYER_NAME := "TerrainCollisionVisual"
const PLATFORM_LAYER_NAME := "PlatformCollisionVisual"
const SURFACE_LAYER_NAME := "GroundSurfaceVisual"
const THIN_SURFACE_LAYER_NAME := "ThinPlatformSurfaceVisual"
const CLIFF_ROOT_NAME := "CliffMassVisual"
const VISUAL_ONLY_TILE_LAYERS := ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]
const OLD_LAYER_NAMES := [
	"MiasmaTilesetPreview",
	"ShrineTrialTilesetPreview",
	"FormalTerrainTilemapDecor",
	"FormalForegroundEdgeDecor",
	"FormalTerrainKitSemanticTrial",
]
const LEGACY_TERRAIN_BODY_NAMES := ["LeftWall", "Floor"]
const LOGIC_COLLISION_NODE_NAMES := [
	"GateBarrier/CollisionShape2D",
	"ExitZone/CollisionShape2D",
	"LeftExitZone/CollisionShape2D",
]

const CAMERA_LIMITS := Rect2i(-512, -288, 1536, 576)
const TERRAIN_SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)
const PLATFORM_OFFSET := Vector2(0.0, -16.0)
const SURFACE_OFFSET := Vector2(0.0, -7.0)
const LOWER_FLOOR_START := Vector2i(-8, 3)
const LOWER_FLOOR_LENGTH := 14
const RIGHT_CLIFF_START := Vector2i(6, 1)
const RIGHT_CLIFF_WIDTH := 10
const RIGHT_CLIFF_HEIGHT := 4
const STEP_PLATFORM_START := Vector2i(-6, 2)
const STEP_PLATFORM_LENGTH := 3
const LAUNCH_PLATFORM_START := Vector2i(-1, 1)
const LAUNCH_PLATFORM_LENGTH := 4
const RIGHT_LEDGE_START := Vector2i(6, 1)
const RIGHT_LEDGE_LENGTH := 10


# 运行态移动验收依赖干净输入，避免其它 GUT 用例残留按键状态。
func before_each() -> void:
	_release_movement_inputs()


func after_each() -> void:
	_release_movement_inputs()


# 地形、平台与可见表面各自只承担一个职责，旧随机装饰层保持为空。
func test_stage14_gate_layers_match_formal_room_contract() -> void:
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
	assert_almost_eq(terrain.modulate.a, 0.08, 0.001)

	assert_true(bool(platform.get("collision_enabled")))
	assert_eq(platform.tile_set.resource_path, TERRAIN_TILESET_PATH)
	assert_eq(platform.position, PLATFORM_OFFSET)
	assert_eq(platform.scale, TERRAIN_SCALE)
	assert_almost_eq(platform.modulate.a, 0.08, 0.001)

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
			assert_eq(layer.get_used_cells().size(), 0, "正式样板不再随机铺视觉 tile：%s" % layer_name)


# 旧 authoring shape 保留追溯，能力门和左右出口仍由独立逻辑碰撞负责。
func test_stage14_gate_preserves_logic_nodes_and_disables_legacy_terrain() -> void:
	var room := _instantiate_room()
	assert_eq(room.get("next_room_path"), "res://scenes/rooms/stage14_backtrack_hub_room.tscn")
	assert_eq(room.get("next_spawn_id"), &"stage14_backtrack_hub_start")
	assert_eq(room.get("previous_room_path"), "res://scenes/rooms/stage14_air_dash_shrine_room.tscn")
	assert_eq(room.get("previous_spawn_id"), &"stage14_shrine_return")
	assert_eq(room.get("checkpoint_spawn_id"), &"stage14_air_dash_gate_start")
	assert_eq(room.get("default_step_id"), &"stage14_air_dash_gate")
	assert_true(bool(room.get("air_dash_gate_room")))
	for body_name: String in LEGACY_TERRAIN_BODY_NAMES:
		var body := room.get_node_or_null(NodePath(body_name)) as StaticBody2D
		var shape := body.get_node_or_null("CollisionShape2D") as CollisionShape2D if body != null else null
		assert_not_null(body)
		assert_not_null(shape)
		if body != null:
			assert_eq(body.collision_layer, 0)
			assert_eq(body.collision_mask, 0)
		if shape != null:
			assert_true(shape.disabled)

	for path: String in LOGIC_COLLISION_NODE_NAMES:
		var shape := room.get_node_or_null(NodePath(path)) as CollisionShape2D
		assert_not_null(shape)
		if shape != null:
			assert_false(shape.disabled)

	assert_not_null(room.get_node_or_null("AirDashGateSensor"))
	_assert_old_layers_hidden(room)


# 24x9 蓝图必须形成安全下层、两段起跳、192px 缺口和不可从下层绕过的右侧崖台。
func test_stage14_gate_blueprint_has_fall_retry_dash_gap_and_safe_landings() -> void:
	var room := _instantiate_room()
	var terrain := room.get_node(TERRAIN_LAYER_NAME) as TileMapLayer
	var platform := room.get_node(PLATFORM_LAYER_NAME) as TileMapLayer
	var surface := room.get_node(SURFACE_LAYER_NAME) as TileMapLayer
	var thin_surface := room.get_node(THIN_SURFACE_LAYER_NAME) as TileMapLayer

	_assert_solid_run(terrain, LOWER_FLOOR_START, LOWER_FLOOR_LENGTH)
	_assert_solid_rect(terrain, RIGHT_CLIFF_START, RIGHT_CLIFF_WIDTH, RIGHT_CLIFF_HEIGHT)
	assert_eq(terrain.get_used_cells().size(), LOWER_FLOOR_LENGTH + RIGHT_CLIFF_WIDTH * RIGHT_CLIFF_HEIGHT)

	_assert_one_way_run(platform, STEP_PLATFORM_START, STEP_PLATFORM_LENGTH)
	_assert_one_way_run(platform, LAUNCH_PLATFORM_START, LAUNCH_PLATFORM_LENGTH)
	assert_eq(platform.get_used_cells().size(), STEP_PLATFORM_LENGTH + LAUNCH_PLATFORM_LENGTH)

	_assert_surface_run(surface, LOWER_FLOOR_START, LOWER_FLOOR_LENGTH)
	_assert_surface_run(surface, RIGHT_LEDGE_START, RIGHT_LEDGE_LENGTH)
	assert_eq(surface.get_used_cells().size(), LOWER_FLOOR_LENGTH + RIGHT_LEDGE_LENGTH)
	_assert_thin_surface_run(thin_surface, STEP_PLATFORM_START, STEP_PLATFORM_LENGTH)
	_assert_thin_surface_run(thin_surface, LAUNCH_PLATFORM_START, LAUNCH_PLATFORM_LENGTH)
	assert_eq(thin_surface.get_used_cells().size(), STEP_PLATFORM_LENGTH + LAUNCH_PLATFORM_LENGTH)

	for gap_x: int in range(3, 6):
		assert_false(platform.get_used_cells().has(Vector2i(gap_x, 1)), "Air Dash 缺口必须保持三格净空。")
		assert_false(surface.get_used_cells().has(Vector2i(gap_x, 1)), "缺口不能被可见地面偷偷补上。")

	var cliff_root := room.get_node_or_null(CLIFF_ROOT_NAME) as Node2D
	var cliff_mass := room.get_node_or_null("%s/RightCliffMass" % CLIFF_ROOT_NAME) as Polygon2D
	assert_not_null(cliff_root)
	assert_not_null(cliff_mass)
	if cliff_root != null:
		assert_true(bool(cliff_root.get_meta("visual_only", false)))
	if cliff_mass != null:
		assert_eq(cliff_mass.polygon, PackedVector2Array([
			Vector2(416, 96),
			Vector2(1024, 96),
			Vector2(1024, 288),
			Vector2(416, 288),
		]))
		assert_not_null(cliff_mass.texture)
		if cliff_mass.texture != null:
			assert_eq(cliff_mass.texture.resource_path, CLIFF_MASS_TEXTURE_PATH)
		assert_eq(cliff_mass.texture_repeat, CanvasItem.TEXTURE_REPEAT_ENABLED)


# 房间尺寸、出生点和能力门位置共同表达从左下回落区到右上出口的方向。
func test_stage14_gate_camera_spawns_background_and_gate_positions_match_blueprint() -> void:
	var room := _instantiate_room()
	assert_eq(room.call("get_camera_limits"), CAMERA_LIMITS)
	assert_eq(room.call("get_spawn_position", &"stage14_air_dash_gate_start"), Vector2(-384.0, 160.0))
	assert_eq(room.call("get_spawn_position", &"stage14_shrine_return"), Vector2(-384.0, 160.0))
	assert_eq(room.get_node("AirDashGateSensor").position, Vector2(160.0, 54.0))
	assert_eq(room.get_node("GateBarrier").position, Vector2(672.0, 40.0))
	assert_eq(room.get_node("ExitZone").position, Vector2(928.0, 32.0))
	assert_eq(room.get_node("LeftExitZone").position, Vector2(-480.0, 160.0))

	var background := room.get_node_or_null("ShrineGateBackgroundArt") as Sprite2D
	assert_not_null(background)
	if background != null:
		assert_true(background.visible)
		assert_eq(background.position, Vector2(256.0, 0.0))
		assert_eq(background.scale, Vector2(0.92, 0.92))
		var half_size := Vector2(background.texture.get_width(), background.texture.get_height()) * background.scale * 0.5
		assert_true(background.position.x - half_size.x <= CAMERA_LIMITS.position.x)
		assert_true(background.position.x + half_size.x >= CAMERA_LIMITS.end.x)
		assert_true(background.position.y - half_size.y <= CAMERA_LIMITS.position.y)
		assert_true(background.position.y + half_size.y >= CAMERA_LIMITS.end.y)


# 真实 Luna 必须先在无能力时跌回安全下层，再能用 Air Dash 跨越同一缺口落到右侧崖台。
func test_stage14_gate_runtime_requires_air_dash_and_keeps_failure_safe() -> void:
	var room := _instantiate_room()
	var player := await _spawn_player_in_room(room, Vector2(136.0, -32.0))
	assert_not_null(player)
	if player == null:
		return

	assert_true(player.is_on_floor())
	assert_lt(player.global_position.y, 96.0, "起跳点应落在上层薄平台，而不是下层地面。")
	var normal_jump_result := await _attempt_gap_crossing(player, false)
	assert_false(bool(normal_jump_result["crossed_upper"]), str(normal_jump_result))
	assert_true(player.is_on_floor())
	assert_lt(player.global_position.x, 416.0, str(normal_jump_result))
	assert_gt(player.global_position.y, 96.0, "失败后必须落回安全下层，而不是卡在空气墙。")

	player.global_position = Vector2(136.0, -32.0)
	player.velocity = Vector2.ZERO
	player.call("set_air_dash_unlocked", true)
	await _wait_until_settled(player, 90)
	assert_true(player.is_on_floor())
	var air_dash_result := await _attempt_gap_crossing(player, true)
	assert_true(bool(air_dash_result["dash_started"]), str(air_dash_result))
	assert_true(bool(air_dash_result["crossed_upper"]), str(air_dash_result))
	assert_true(player.is_on_floor())
	assert_gt(player.global_position.x, 428.0, str(air_dash_result))
	assert_lt(player.global_position.y, 96.0, "成功后必须落在右侧上层安全平台：%s" % air_dash_result)


func _instantiate_room() -> Node2D:
	var packed := load(ROOM_PATH) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return null
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room


# 在真实房间碰撞中生成 Luna，并等待其落到指定起跳平台。
func _spawn_player_in_room(room: Node2D, spawn_position: Vector2) -> CharacterBody2D:
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


# 同一条输入路线只在能力开启时追加一次空中冲刺，直接比较房间门槛是否成立。
func _attempt_gap_crossing(player: CharacterBody2D, use_air_dash: bool) -> Dictionary:
	var min_y := player.global_position.y
	var max_x := player.global_position.x
	var crossed_upper := false
	var dash_started := false
	Input.action_press("move_right")
	Input.action_press("jump")
	for _i: int in range(44):
		await _advance_physics_frames(1)
		min_y = minf(min_y, player.global_position.y)
		max_x = maxf(max_x, player.global_position.x)
	Input.action_release("jump")
	if use_air_dash:
		Input.action_press("dash")
		await _advance_physics_frames(2)
		dash_started = player.call("get_current_state_id") == &"dash"
		Input.action_release("dash")
	for _i: int in range(80):
		await _advance_physics_frames(1)
		min_y = minf(min_y, player.global_position.y)
		max_x = maxf(max_x, player.global_position.x)
		if player.global_position.x > 428.0 and player.global_position.y < 96.0:
			crossed_upper = true
	Input.action_release("move_right")
	await _wait_until_settled(player, 90)
	return {
		"dash_started": dash_started,
		"crossed_upper": crossed_upper,
		"min_y": min_y,
		"max_x": max_x,
		"final_position": player.global_position,
	}


# 等到速度归零且接触地面，避免用碰撞发生的单帧状态做结论。
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


func _release_movement_inputs() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("dash")


# 连续实心 run 只在首尾使用 cap，中段不能出现孤立柱或随机门件。
func _assert_solid_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var cell := Vector2i(start.x + offset, start.y)
		assert_true(layer.get_used_cells().has(cell), "实心地面存在：%s" % cell)
		assert_eq(layer.get_cell_source_id(cell), 0)
		var expected := Vector2i(0, 0) if posmod(offset, 2) == 0 else Vector2i(1, 0)
		if offset == 0:
			expected = Vector2i(2, 0)
		elif offset == length - 1:
			expected = Vector2i(3, 0)
		assert_eq(layer.get_cell_atlas_coords(cell), expected)
		_assert_solid_collision(layer, cell)


# 右侧崖台是连续实体体块，玩家不能从下层步行绕过能力门。
func _assert_solid_rect(layer: TileMapLayer, start: Vector2i, width: int, height: int) -> void:
	for y_offset: int in range(height):
		for x_offset: int in range(width):
			var cell := Vector2i(start.x + x_offset, start.y + y_offset)
			assert_true(layer.get_used_cells().has(cell), "右侧崖台实体存在：%s" % cell)
			assert_eq(layer.get_cell_source_id(cell), 0)
			_assert_solid_collision(layer, cell)


# 起跳台必须是一向平台，允许失败后从下层回到左侧重试。
func _assert_one_way_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var cell := Vector2i(start.x + offset, start.y)
		assert_true(layer.get_used_cells().has(cell), "一向平台存在：%s" % cell)
		assert_eq(layer.get_cell_source_id(cell), 0)
		var tile_data := _tile_data(layer, cell)
		assert_not_null(tile_data)
		if tile_data != null:
			assert_true(tile_data.is_collision_polygon_one_way(0, 0))


# 可见实体地面只使用同源 left / center / right，形成连续轮廓。
func _assert_surface_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var cell := Vector2i(start.x + offset, start.y)
		assert_true(layer.get_used_cells().has(cell), "可见地表存在：%s" % cell)
		var expected := Vector2i(1, 0)
		if offset == 0:
			expected = Vector2i(0, 0)
		elif offset == length - 1:
			expected = Vector2i(2, 0)
		assert_eq(layer.get_cell_atlas_coords(cell), expected)


# 薄平台可见层与碰撞 run 一一对应，首尾 cap 明确。
func _assert_thin_surface_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var cell := Vector2i(start.x + offset, start.y)
		assert_true(layer.get_used_cells().has(cell), "薄平台可见面存在：%s" % cell)
		var expected := Vector2i(1, 0)
		if offset == 0:
			expected = Vector2i(0, 0)
		elif offset == length - 1:
			expected = Vector2i(2, 0)
		assert_eq(layer.get_cell_atlas_coords(cell), expected)


func _assert_solid_collision(layer: TileMapLayer, cell: Vector2i) -> void:
	var tile_data := _tile_data(layer, cell)
	assert_not_null(tile_data)
	if tile_data != null:
		assert_eq(tile_data.get_collision_polygons_count(0), 1)
		assert_false(tile_data.is_collision_polygon_one_way(0, 0))


func _tile_data(layer: TileMapLayer, cell: Vector2i) -> TileData:
	var source := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
	assert_not_null(source)
	if source == null:
		return null
	return source.get_tile_data(layer.get_cell_atlas_coords(cell), 0)


func _assert_old_layers_hidden(room: Node2D) -> void:
	for layer_name: String in OLD_LAYER_NAMES:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		assert_not_null(layer)
		if layer != null:
			assert_false(layer.visible)
			assert_false(bool(layer.get("collision_enabled")))
