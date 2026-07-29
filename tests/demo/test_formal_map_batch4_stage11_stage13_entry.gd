extends GutTest

# 正式地图 Batch 4：Stage11 终点与 Stage13 入口链前三房。

const END := "res://scenes/rooms/stage11_demo_end_room.tscn"
const ENTRY := "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"
const CASTER := "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"
const MIASMA := "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"


func test_stage11_end_is_18x8_safe_three_choice_hall() -> void:
	var room := _room(END)
	_assert_layout(room, Rect2i(-384, -256, 1152, 512), Vector2i(-6, 3), 18, 0)
	assert_eq(room.call("get_spawn_position", &"stage11_demo_end_start"), Vector2(-128, 204))
	assert_eq(room.call("get_spawn_position", &"stage11_demo_end_return"), Vector2(560, 204))
	assert_eq(room.get_node("ReplayZone").position, Vector2(-256, 160))
	assert_eq(room.get_node("GoalZone").position, Vector2(480, 160))
	assert_eq(room.get_node("ContinueZone").position, Vector2(672, 160))


func test_stage13_entry_is_20x8_checkpoint_reveal() -> void:
	var room := _room(ENTRY)
	_assert_layout(room, Rect2i(-384, -256, 1280, 512), Vector2i(-6, 3), 20, 4)
	_assert_previous(room, END, &"stage11_demo_end_return")
	assert_eq(room.call("get_spawn_position", &"stage13_entry_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_entry_return"), Vector2(640, 204))
	assert_eq(room.get_node("ExitZone").position, Vector2(800, 160))
	assert_true(room.get_node("RegionCheckpoint/CheckpointArt").visible)


func test_stage13_caster_is_24x9_three_layer_ranged_room() -> void:
	var room := _room(CASTER)
	_assert_layout(room, Rect2i(-384, -320, 1536, 576), Vector2i(-6, 3), 24, 12)
	_assert_previous(room, ENTRY, &"stage13_entry_return")
	assert_eq(room.call("get_spawn_position", &"stage13_miasma_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_caster_return"), Vector2(960, 204))
	assert_eq(room.get_node("MiasmaCasterEnemy").position, Vector2(448, 56))
	assert_eq(room.get_node("GateBarrier").position, Vector2(1024, 168))
	assert_false(bool(room.call("is_gate_unlocked")))


func test_stage13_miasma_is_22x8_hazard_bypass_room() -> void:
	var room := _room(MIASMA)
	_assert_layout(room, Rect2i(-384, -256, 1408, 512), Vector2i(-6, 3), 22, 8)
	_assert_previous(room, CASTER, &"stage13_caster_return")
	assert_eq(room.call("get_spawn_position", &"stage13_miasma_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_miasma_return"), Vector2(768, 204))
	assert_eq(room.get_node("MiasmaHazard").position, Vector2(320, 212))
	assert_eq(room.get_node("ExitZone").position, Vector2(928, 160))


func _assert_layout(room: Node2D, limits: Rect2i, floor_start: Vector2i, floor_length: int, platform_cells: int) -> void:
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
	assert_eq(terrain.get_used_cells().size(), floor_length)
	assert_eq(surface.get_used_cells().size(), floor_length)
	assert_eq(platform.get_used_cells().size(), platform_cells)
	assert_eq(thin.get_used_cells().size(), platform_cells)
	assert_true(bool(terrain.get("collision_enabled")))
	assert_true(bool(platform.get("collision_enabled")))
	assert_false(bool(surface.get("collision_enabled")))
	assert_false(bool(thin.get("collision_enabled")))
	for offset: int in range(floor_length):
		assert_eq(terrain.get_cell_source_id(floor_start + Vector2i(offset, 0)), 0)
	for old_name: String in ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]:
		var old := room.get_node(old_name) as TileMapLayer
		assert_false(old.visible)
		assert_false(bool(old.get("collision_enabled")))


func _assert_previous(room: Node2D, path: String, spawn: StringName) -> void:
	assert_eq(str(room.get("previous_room_path")), path)
	assert_eq(room.get("previous_spawn_id"), spawn)
	assert_eq(room.get_node("LeftExitZone").position.x, -352.0)


func _room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed)
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room
