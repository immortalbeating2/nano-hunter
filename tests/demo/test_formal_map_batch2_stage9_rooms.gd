extends GutTest

# 正式地图 Batch 2：Stage9 五房必须形成一个有层级差异的连续区域，
# 不能继续共用旧 15x6 单层横排模板。

const ENTRY := "res://scenes/rooms/stage9_zone_entry_room.tscn"
const COMBAT := "res://scenes/rooms/stage9_zone_combat_room.tscn"
const CHARGER := "res://scenes/rooms/stage9_zone_charger_room.tscn"
const SWITCH := "res://scenes/rooms/stage9_zone_switch_room.tscn"
const FINAL := "res://scenes/rooms/stage9_zone_final_room.tscn"
const TERRAIN_TILESET := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_TILESET := "res://assets/art/tilesets/editor_tilesets/tutorial_jump_platform_visual_ai02.tileset.tres"


func test_stage9_entry_is_calm_18x6_region_reveal() -> void:
	var room := _room(ENTRY)
	_assert_layout(room, Rect2i(-384, -192, 1152, 384), Vector2i(-6, 2), 18, [{"start": Vector2i(3, 1), "length": 3}])
	_assert_link(room, "res://scenes/rooms/goal_trial_room.tscn", &"goal_return", Vector2(-352, 96))
	assert_eq(room.call("get_spawn_position", &"zone_entry_start"), Vector2(-256, 140))
	assert_eq(room.call("get_spawn_position", &"zone_entry_return"), Vector2(640, 140))
	assert_eq(room.get_node("ExitZone").position, Vector2(720, 96))
	assert_true(room.get_node("RegionCheckpoint/CheckpointArt").visible)


func test_stage9_combat_is_20x8_two_layer_first_arena() -> void:
	var room := _room(COMBAT)
	_assert_layout(room, Rect2i(-384, -256, 1280, 512), Vector2i(-6, 3), 20, [
		{"start": Vector2i(-1, 2), "length": 4},
		{"start": Vector2i(6, 2), "length": 3},
	])
	_assert_link(room, ENTRY, &"zone_entry_return", Vector2(-352, 160))
	assert_eq(room.call("get_spawn_position", &"zone_combat_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"zone_combat_return"), Vector2(640, 204))
	assert_eq(room.get_node("BasicMeleeEnemy").position, Vector2(32, 200))
	assert_eq(room.get_node("GateBarrier").position, Vector2(704, 168))


func test_stage9_charger_is_22x8_long_charge_lane() -> void:
	var room := _room(CHARGER)
	_assert_layout(room, Rect2i(-384, -256, 1408, 512), Vector2i(-6, 3), 22, [
		{"start": Vector2i(2, 2), "length": 4},
		{"start": Vector2i(10, 2), "length": 3},
	])
	_assert_link(room, COMBAT, &"zone_combat_return", Vector2(-352, 160))
	assert_eq(room.call("get_spawn_position", &"zone_charger_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"zone_charger_return"), Vector2(768, 204))
	assert_eq(room.get_node("GroundChargerEnemy").position, Vector2(192, 200))
	assert_eq(room.get_node("GateBarrier").position, Vector2(832, 168))
	var checkpoint := room.get_node("CheckpointPoint/CheckpointArt") as Sprite2D
	assert_false(checkpoint.visible)
	room.call("_handle_enemy_defeated")
	assert_true(checkpoint.visible)
	assert_true(room.call("is_gate_unlocked"))


func test_stage9_switch_is_20x9_two_step_mechanism_route() -> void:
	var room := _room(SWITCH)
	_assert_layout(room, Rect2i(-384, -320, 1280, 576), Vector2i(-6, 3), 20, [
		{"start": Vector2i(0, 2), "length": 3},
		{"start": Vector2i(4, 1), "length": 4},
	])
	_assert_link(room, CHARGER, &"zone_charger_return", Vector2(-352, 160))
	assert_eq(room.call("get_spawn_position", &"zone_switch_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"zone_switch_return"), Vector2(640, 204))
	assert_eq(room.get_node("GateSwitch").position, Vector2(352, 56))
	assert_eq(room.get_node("GateBarrier").position, Vector2(704, 168))


func test_stage9_final_is_24x9_layered_mixed_encounter() -> void:
	var room := _room(FINAL)
	_assert_layout(room, Rect2i(-384, -320, 1536, 576), Vector2i(-6, 3), 24, [
		{"start": Vector2i(0, 2), "length": 5},
		{"start": Vector2i(8, 2), "length": 4},
	])
	_assert_link(room, SWITCH, &"zone_switch_return", Vector2(-352, 160))
	assert_eq(room.call("get_spawn_position", &"zone_final_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"zone_final_return"), Vector2(960, 204))
	assert_eq(room.get_node("BasicMeleeEnemy").position, Vector2(128, 120))
	assert_eq(room.get_node("GroundChargerEnemy").position, Vector2(512, 200))
	assert_eq(room.get_node("GateBarrier").position, Vector2(1024, 168))
	assert_eq(room.get_node("ExitZone").position, Vector2(1120, 160))


func _assert_layout(room: Node2D, limits: Rect2i, floor_start: Vector2i, floor_length: int, platforms: Array) -> void:
	assert_eq(room.call("get_camera_limits"), limits)
	var terrain := room.get_node_or_null("TerrainCollisionVisual") as TileMapLayer
	var platform := room.get_node_or_null("PlatformCollisionVisual") as TileMapLayer
	var surface := room.get_node_or_null("GroundSurfaceVisual") as TileMapLayer
	var thin := room.get_node_or_null("ThinPlatformSurfaceVisual") as TileMapLayer
	assert_not_null(terrain)
	assert_not_null(platform)
	assert_not_null(surface)
	assert_not_null(thin)
	if terrain == null or platform == null or surface == null or thin == null:
		return
	assert_true(bool(terrain.get("collision_enabled")))
	assert_true(bool(platform.get("collision_enabled")))
	assert_false(bool(surface.get("collision_enabled")))
	assert_false(bool(thin.get("collision_enabled")))
	assert_eq(terrain.tile_set.resource_path, TERRAIN_TILESET)
	assert_eq(surface.tile_set.resource_path, SURFACE_TILESET)
	assert_eq(thin.tile_set.resource_path, THIN_TILESET)
	assert_eq(terrain.get_used_cells().size(), floor_length)
	assert_eq(surface.get_used_cells().size(), floor_length)
	var platform_count := 0
	for spec: Dictionary in platforms:
		platform_count += int(spec.length)
		for offset: int in range(int(spec.length)):
			assert_eq(platform.get_cell_source_id(Vector2i(spec.start) + Vector2i(offset, 0)), 0)
	assert_eq(platform.get_used_cells().size(), platform_count)
	assert_eq(thin.get_used_cells().size(), platform_count)
	for offset: int in range(floor_length):
		assert_eq(terrain.get_cell_source_id(floor_start + Vector2i(offset, 0)), 0)
	var background := room.get_node("DemoBackgroundArt") as Sprite2D
	var half_width := background.texture.get_width() * background.scale.x * 0.5
	assert_lte(background.position.x - half_width, float(limits.position.x))
	assert_gte(background.position.x + half_width, float(limits.end.x))
	for body_name: String in ["LeftWall", "RightWall", "Floor"]:
		var body := room.get_node_or_null(body_name) as StaticBody2D
		if body == null:
			continue
		assert_eq(body.collision_layer, 0)
		assert_true((body.get_node("CollisionShape2D") as CollisionShape2D).disabled)
	for old_name: String in ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]:
		var old_layer := room.get_node(old_name) as TileMapLayer
		assert_false(old_layer.visible)
		assert_false(bool(old_layer.get("collision_enabled")))


func _assert_link(room: Node2D, previous_path: String, previous_spawn: StringName, left_exit_position: Vector2) -> void:
	assert_eq(str(room.get("previous_room_path")), previous_path)
	assert_eq(room.get("previous_spawn_id"), previous_spawn)
	assert_eq(room.get_node("LeftExitZone").position, left_exit_position)


func _room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed)
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room
