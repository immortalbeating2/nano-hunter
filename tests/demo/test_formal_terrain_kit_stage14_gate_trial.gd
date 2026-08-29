extends GutTest

# Stage14 Air Dash gate 正式样板契约。
# 房间必须形成下层失败回落、两段起跳、Air Dash 缺口和右侧能力门，不再按旧 shape 随机塞 tile。

const ROOM_PATH := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const PLAYER_PATH := "res://scenes/player/player_placeholder.tscn"
const TERRAIN_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_jump_platform_visual_ai02.tileset.tres"
const CLIFF_MASS_TEXTURE_PATH := "res://assets/art/textures/dac_continuous_stone_underlay.png"

const TERRAIN_LAYER_NAME := "TerrainCollisionVisual"
const PLATFORM_LAYER_NAME := "PlatformCollisionVisual"
const SURFACE_LAYER_NAME := "GroundSurfaceVisual"
const THIN_SURFACE_LAYER_NAME := "ThinPlatformSurfaceVisual"
const CLIFF_ROOT_NAME := "CliffMassVisual"
const VISUAL_ONLY_TILE_LAYERS := ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]
const OLD_LAYER_NAMES := [
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
# 运行态移动验收依赖干净输入，避免其它 GUT 用例残留按键状态。
func before_each() -> void:
	_release_movement_inputs()


func after_each() -> void:
	_release_movement_inputs()


# 地形、平台与可见表面各自只承担一个职责，旧随机装饰层保持为空。
func test_stage14_gate_layers_match_formal_room_contract() -> void:
	var room := _instantiate_room()
	var layout := room.get_node_or_null("Phase2GrayboxLayout")
	var terrain := room.get_node_or_null(TERRAIN_LAYER_NAME) as TileMapLayer
	var platform := room.get_node_or_null(PLATFORM_LAYER_NAME) as TileMapLayer
	var surface := room.get_node_or_null(SURFACE_LAYER_NAME) as TileMapLayer
	var thin_surface := room.get_node_or_null(THIN_SURFACE_LAYER_NAME) as TileMapLayer
	assert_not_null(layout)
	assert_not_null(terrain)
	assert_not_null(platform)
	assert_not_null(surface)
	assert_not_null(thin_surface)
	if layout == null or terrain == null or platform == null or surface == null or thin_surface == null:
		return

	assert_eq(int(layout.call("get_segment_count")), 3)
	assert_eq(layout.call("get_layout_profile"), &"air_dash_show_practice_proof")
	assert_eq(int(layout.call("get_runtime_platform_count")), 4)
	assert_false(bool(terrain.get("collision_enabled")))
	assert_false(terrain.visible)
	assert_eq(terrain.tile_set.resource_path, TERRAIN_TILESET_PATH)

	assert_false(bool(platform.get("collision_enabled")))
	assert_false(platform.visible)
	assert_eq(platform.tile_set.resource_path, TERRAIN_TILESET_PATH)

	assert_false(bool(surface.get("collision_enabled")))
	assert_eq(surface.tile_set.resource_path, SURFACE_TILESET_PATH)
	assert_false(surface.visible, "旧地表 TileMap 已由 Phase2 动态表面取代。")
	assert_false(bool(thin_surface.get("collision_enabled")))
	assert_eq(thin_surface.tile_set.resource_path, THIN_SURFACE_TILESET_PATH)
	assert_false(thin_surface.visible, "旧薄平台 TileMap 已由 Phase2 动态表面取代。")

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
	assert_null(room.get_node_or_null("MiasmaTilesetPreview"))
	assert_null(room.get_node_or_null("ShrineTrialTilesetPreview"))
	_assert_old_layers_hidden(room)


# 24x9 蓝图必须形成安全下层、两段起跳、192px 缺口和不可从下层绕过的右侧崖台。
func test_stage14_gate_blueprint_has_fall_retry_dash_gap_and_safe_landings() -> void:
	var room := _instantiate_room()
	var layout := room.get_node("Phase2GrayboxLayout")
	var solid_rects: Array[Rect2] = layout.get("solid_rects")
	var one_way_rects: Array[Rect2] = layout.get("one_way_rects")
	assert_eq(solid_rects, [
		Rect2(-512, 192, 640, 64),
		Rect2(128, 224, 496, 64),
		Rect2(624, 96, 400, 64),
	])
	assert_eq(one_way_rects, [Rect2(176, 144, 160, 16)])
	assert_eq(float(layout.call("get_route_height", &"f07_altar")), 224.0)
	assert_eq(float(layout.call("get_route_height", &"f15_main")), 96.0)
	assert_gt(624.0 - 336.0, 110.0, "Air Dash 证明段必须保留普通跳跃无法跨越的净空。")

	var cliff_root := room.get_node_or_null(CLIFF_ROOT_NAME) as Node2D
	var cliff_mass := room.get_node_or_null("%s/RightCliffMass" % CLIFF_ROOT_NAME) as Polygon2D
	assert_not_null(cliff_root)
	assert_not_null(cliff_mass)
	if cliff_root != null:
		assert_true(bool(cliff_root.get_meta("visual_only", false)))
	if cliff_mass != null:
		assert_not_null(cliff_mass.texture)
		if cliff_mass.texture != null:
			assert_eq(cliff_mass.texture.resource_path, CLIFF_MASS_TEXTURE_PATH)
		assert_eq(cliff_mass.texture_repeat, CanvasItem.TEXTURE_REPEAT_ENABLED)


# 房间尺寸、出生点和能力门位置共同表达从左下回落区到右上出口的方向。
func test_stage14_gate_camera_spawns_background_and_gate_positions_match_blueprint() -> void:
	var room := _instantiate_room()
	assert_eq(room.call("get_camera_limits"), CAMERA_LIMITS)
	assert_eq(room.call("get_spawn_position", &"stage14_air_dash_gate_start"), Vector2(-384.0, 172.0))
	assert_eq(room.call("get_spawn_position", &"stage14_shrine_return"), Vector2(-384.0, 172.0))
	assert_eq(room.call("get_spawn_position", &"stage14_gate_from_wind_cross"), Vector2(176.0, 204.0))
	assert_eq(room.get_node("AirDashGateSensor").position, Vector2(560.0, 56.0))
	assert_eq(room.get_node("GateBarrier").position, Vector2(672.0, 40.0))
	assert_eq(room.get_node("ExitZone").position, Vector2(928.0, 32.0))
	assert_eq(room.get_node("LeftExitZone").position, Vector2(-480.0, 160.0))
	assert_eq(room.get_node("ShortcutZone").position, Vector2(256.0, 204.0))
	assert_eq(room.get_node("NarrativeStele").position, Vector2(128.0, 204.0))
	assert_true(bool(room.get("shortcut_requires_down_input")))
	assert_false((room.get_node("AirDashProofTakeoff/PlatformVisual") as Polygon2D).visible)
	var shortcut_art := room.get_node("ShortcutZone/ShortcutMarkerArt") as Sprite2D
	assert_eq(str(shortcut_art.get_meta("runtime_source", "")), "shrine_gate_prop_atlas_ai01.talisman_stake_idle")

	var background := room.get_node_or_null("ShrineGateBackgroundArt") as Sprite2D
	assert_not_null(background)
	if background != null:
		assert_true(background.visible)
		assert_eq(background.position, Vector2(256.0, 0.0))
		var half_size := Vector2(background.texture.get_width(), background.texture.get_height()) * background.scale * 0.5
		assert_true(background.position.x - half_size.x <= CAMERA_LIMITS.position.x)
		assert_true(background.position.x + half_size.x >= CAMERA_LIMITS.end.x)
		assert_true(background.position.y - half_size.y <= CAMERA_LIMITS.position.y)
		assert_true(background.position.y + half_size.y >= CAMERA_LIMITS.end.y)


# 封印脉冲必须使用现有神龛资产表达预警与激活，不得再把纯色 Polygon 灰盒泄漏到游戏画面。
func test_stage14_gate_seal_pulse_uses_shrine_art_instead_of_colored_rectangles() -> void:
	var room := _instantiate_room()
	var warning := room.get_node_or_null("SealPulseHazard/WarningVisual") as Sprite2D
	var active := room.get_node_or_null("SealPulseHazard/ActiveVisual") as Sprite2D
	assert_not_null(warning)
	assert_not_null(active)
	if warning != null:
		assert_not_null(warning.texture)
		assert_eq(str(warning.get_meta("runtime_source", "")), "shrine_gate_prop_atlas_ai01.air_dash_shrine_active")
	if active != null:
		assert_not_null(active.texture)
		assert_eq(str(active.get_meta("runtime_source", "")), "shrine_gate_prop_atlas_ai01.air_dash_shrine_active")


# 真实 Luna 只有在空中 Dash 经过证明感应区时才能打开能力门。
func test_stage14_gate_runtime_requires_air_dash_and_keeps_failure_safe() -> void:
	var room := _instantiate_room()
	var player := await _spawn_player_in_room(room, Vector2(448.0, 60.0))
	assert_not_null(player)
	if player == null:
		return

	assert_true(player.is_on_floor())
	assert_false(bool(room.call("is_air_dash_gate_unlocked")))
	assert_false(await _attempt_gate_proof(player, false))
	assert_false(bool(room.call("is_air_dash_gate_unlocked")), "普通跳跃不能伪造 Air Dash 证明。")

	player.global_position = Vector2(448.0, 60.0)
	player.velocity = Vector2.ZERO
	player.call("set_air_dash_unlocked", true)
	await _wait_until_settled(player, 90)
	assert_true(player.is_on_floor())
	assert_true(await _attempt_gate_proof(player, true))
	assert_true(bool(room.call("is_air_dash_proof_complete")))
	assert_true(bool(room.call("is_air_dash_gate_unlocked")))


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


# 同一条输入路线只在能力开启时追加一次空中冲刺，直接比较证明门是否成立。
func _attempt_gate_proof(player: CharacterBody2D, use_air_dash: bool) -> bool:
	var dash_started := false
	Input.action_press("move_right")
	Input.action_press("jump")
	await _advance_physics_frames(12)
	Input.action_release("jump")
	if use_air_dash:
		Input.action_press("dash")
		await _advance_physics_frames(2)
		dash_started = player.call("get_current_state_id") == &"dash"
		Input.action_release("dash")
	await _advance_physics_frames(8)
	Input.action_release("move_right")
	return dash_started


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


func _assert_old_layers_hidden(room: Node2D) -> void:
	for layer_name: String in OLD_LAYER_NAMES:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		assert_not_null(layer)
		if layer != null:
			assert_false(layer.visible)
			assert_false(bool(layer.get("collision_enabled")))
