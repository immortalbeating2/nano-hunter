extends GutTest

# 正式地图 Batch 1：测试沙盒、首战房和短链路目标房。
# 三房按职责采用不同尺寸，不把 Stage15 战斗场模板机械复制到早期房间。

const TEST_ROOM_PATH := "res://scenes/rooms/test_room.tscn"
const COMBAT_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const GOAL_ROOM_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const PLAYER_PATH := "res://scenes/player/player_placeholder.tscn"

const TERRAIN_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"
const TERRAIN_SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)
const SURFACE_OFFSET := Vector2(0.0, -7.0)


# test_room 保留精确灰盒机制，但退出随机大块 tile 和低透明素材大图。
func test_batch1_test_room_keeps_mechanics_and_uses_clean_composition() -> void:
	var room := _instantiate_room(TEST_ROOM_PATH)
	assert_eq(room.call("get_camera_limits"), Rect2i(-512, -192, 1024, 384))
	for node_name: String in ["Floor", "FloorRight", "LeftWall", "RightWall", "MidPlatform", "DashGapLeft", "DashGapRight", "DashGateCeiling", "TrainingDummy", "DashCombatDummy"]:
		assert_not_null(room.get_node_or_null(node_name))
	for layer_name: String in ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		assert_not_null(layer)
		if layer != null:
			assert_false(layer.visible)
			assert_false(bool(layer.get("collision_enabled")))
	var background := room.get_node_or_null("DemoBackgroundArt") as Sprite2D
	assert_not_null(background)
	if background != null:
		assert_eq(background.position, Vector2.ZERO)
		assert_eq(background.scale, Vector2(0.62, 0.62))
	var material_art := room.get_node_or_null("MaterialTextureArt") as Sprite2D
	assert_not_null(material_art)
	if material_art != null:
		assert_false(material_art.visible)
	var goal_visual := room.get_node_or_null("GoalVisual") as Polygon2D
	assert_not_null(goal_visual)
	if goal_visual != null:
		assert_false(goal_visual.visible)
	for path: String in ["Floor/FloorVisual", "FloorRight/FloorVisual", "MidPlatform/PlatformVisual", "DashGapLeft/PlatformVisual", "DashGapRight/PlatformVisual", "DashGateCeiling/CeilingVisual"]:
		var visual := room.get_node_or_null(path) as Polygon2D
		assert_not_null(visual)
		if visual != null:
			assert_true(visual.visible)
			assert_gte(visual.color.a, 0.24)


# 首战房保持单敌规则，但扩大反应距离、入口和出口安全区。
func test_batch1_combat_room_is_18x6_first_encounter() -> void:
	var room := _instantiate_room(COMBAT_ROOM_PATH)
	assert_eq(room.call("get_camera_limits"), Rect2i(-384, -192, 1152, 384))
	_assert_formal_layers(room, Vector2i(-6, 2), 18, [], 0)
	# TileMap 第 2 行实际可踩顶面为 y=160，出生点记录 Luna 的稳定中心 y=140。
	assert_eq(room.call("get_spawn_position", &"combat_entry"), Vector2(-256.0, 140.0))
	assert_eq(room.call("get_spawn_position", &"combat_retry"), Vector2(-256.0, 140.0))
	assert_eq(room.call("get_spawn_position", &"combat_return"), Vector2(640.0, 140.0))
	assert_eq(room.get_node("BasicMeleeEnemy").position, Vector2(-40.0, 152.0))
	assert_eq(room.get_node("ExitBarrier").position, Vector2(512.0, 104.0))
	assert_eq(room.get_node("ExitZone").position, Vector2(704.0, 96.0))
	assert_eq(room.get_node("LeftExitZone").position, Vector2(-352.0, 96.0))
	assert_lte(room.call("get_spawn_position", &"combat_entry").distance_to(room.get_node("BasicMeleeEnemy").position), 224.0)
	_assert_legacy_terrain_disabled(room, ["LeftWall", "RightWall", "Floor"])
	_assert_background(room, Vector2(192.0, 0.0), Vector2(0.7, 0.7), Rect2i(-384, -192, 1152, 384))


# 目标房必须在清敌后要求玩家真正登上右侧平台，而不是从下层跑过 x 阈值完成。
func test_batch1_goal_room_is_20x8_gate_then_elevated_goal() -> void:
	var room := _instantiate_room(GOAL_ROOM_PATH)
	assert_eq(room.call("get_camera_limits"), Rect2i(-384, -256, 1280, 512))
	_assert_formal_layers(room, Vector2i(-6, 3), 20, [Vector2i(9, 2)], 4)
	# 下层/上层可踩顶面分别为 y=224/y=144，出生中心对应 y=204/y=124。
	assert_eq(room.call("get_spawn_position", &"goal_entry"), Vector2(-256.0, 204.0))
	assert_eq(room.call("get_spawn_position", &"goal_retry"), Vector2(-256.0, 204.0))
	assert_eq(room.call("get_spawn_position", &"goal_return"), Vector2(704.0, 124.0))
	assert_eq(room.get_node("BasicMeleeEnemy").position, Vector2(-32.0, 216.0))
	assert_eq(room.get_node("GoalBarrier").position, Vector2(320.0, 168.0))
	assert_eq(room.get_node("GoalZone").position, Vector2(800.0, 104.0))
	assert_eq(room.get_node("LeftExitZone").position, Vector2(-352.0, 160.0))
	_assert_legacy_terrain_disabled(room, ["LeftWall", "RightWall", "Floor", "GoalLedge"])
	_assert_background(room, Vector2(256.0, 0.0), Vector2(0.77, 0.77), Rect2i(-384, -256, 1280, 512))


# 运行态确认目标判定同时读取水平和垂直距离。
func test_batch1_goal_room_only_completes_on_elevated_goal_platform() -> void:
	var room := _instantiate_room(GOAL_ROOM_PATH)
	var player := await _spawn_player(room, Vector2(-256.0, 160.0))
	var enemy := room.get_node("BasicMeleeEnemy")
	var completions: Array[bool] = []
	room.connect("goal_completed", func() -> void: completions.append(true))
	enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(3)
	assert_true(bool(room.call("is_goal_unlocked")))

	player.global_position = Vector2(800.0, 204.0)
	player.velocity = Vector2.ZERO
	await _advance_process_frames(4)
	assert_eq(completions.size(), 0, "下层经过目标 x 坐标不能完成上层目标。")

	player.global_position = Vector2(800.0, 124.0)
	player.velocity = Vector2.ZERO
	await _advance_process_frames(4)
	assert_eq(completions.size(), 1)


func _assert_formal_layers(room: Node2D, floor_start: Vector2i, floor_length: int, platform_starts: Array[Vector2i], platform_length: int) -> void:
	var terrain := room.get_node_or_null("TerrainCollisionVisual") as TileMapLayer
	var platform := room.get_node_or_null("PlatformCollisionVisual") as TileMapLayer
	var surface := room.get_node_or_null("GroundSurfaceVisual") as TileMapLayer
	var thin_surface := room.get_node_or_null("ThinPlatformSurfaceVisual") as TileMapLayer
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
	assert_false(bool(surface.get("collision_enabled")))
	assert_eq(surface.tile_set.resource_path, SURFACE_TILESET_PATH)
	assert_eq(surface.position, SURFACE_OFFSET)
	assert_false(bool(thin_surface.get("collision_enabled")))
	assert_eq(thin_surface.tile_set.resource_path, THIN_SURFACE_TILESET_PATH)
	assert_eq(terrain.get_used_cells().size(), floor_length)
	assert_eq(surface.get_used_cells().size(), floor_length)
	for offset: int in range(floor_length):
		assert_eq(terrain.get_cell_source_id(Vector2i(floor_start.x + offset, floor_start.y)), 0)
	assert_eq(platform.get_used_cells().size(), platform_starts.size() * platform_length)
	assert_eq(thin_surface.get_used_cells().size(), platform_starts.size() * platform_length)
	for start: Vector2i in platform_starts:
		for offset: int in range(platform_length):
			assert_eq(platform.get_cell_source_id(Vector2i(start.x + offset, start.y)), 0)
	for layer_name: String in ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		assert_not_null(layer)
		if layer != null:
			assert_false(bool(layer.get("collision_enabled")))
			assert_true(layer.get_used_cells().is_empty())


func _assert_legacy_terrain_disabled(room: Node2D, body_names: Array[String]) -> void:
	for body_name: String in body_names:
		var body := room.get_node_or_null(body_name) as StaticBody2D
		var shape := body.get_node_or_null("CollisionShape2D") as CollisionShape2D if body != null else null
		assert_not_null(body)
		assert_not_null(shape)
		if body != null:
			assert_eq(body.collision_layer, 0)
			assert_eq(body.collision_mask, 0)
		if shape != null:
			assert_true(shape.disabled)
	for layer_name: String in ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]:
		var old_layer := room.get_node_or_null(layer_name) as TileMapLayer
		assert_not_null(old_layer)
		if old_layer != null:
			assert_false(old_layer.visible)
			assert_false(bool(old_layer.get("collision_enabled")))


func _assert_background(room: Node2D, position: Vector2, scale: Vector2, limits: Rect2i) -> void:
	var background := room.get_node_or_null("DemoBackgroundArt") as Sprite2D
	assert_not_null(background)
	if background == null:
		return
	assert_eq(background.position, position)
	assert_eq(background.scale, scale)
	var half_size := Vector2(background.texture.get_width(), background.texture.get_height()) * scale * 0.5
	assert_true(position.x - half_size.x <= limits.position.x)
	assert_true(position.x + half_size.x >= limits.end.x)


func _instantiate_room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
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
	await _advance_physics_frames(50)
	return player


func _advance_process_frames(count: int) -> void:
	for _i: int in range(count):
		await get_tree().process_frame


func _advance_physics_frames(count: int) -> void:
	for _i: int in range(count):
		await get_tree().physics_frame
