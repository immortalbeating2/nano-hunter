extends GutTest

# 正式地图 Batch 4：Stage11 终点与 Stage13 入口链前三房。

const END := "res://scenes/rooms/stage11_demo_end_room.tscn"
const ENTRY := "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"
const CASTER := "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"
const MIASMA := "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"


func test_stage11_end_is_18x8_safe_three_choice_hall() -> void:
	var room := _room(END)
	_assert_phase2_layout(room, Rect2i(-384, -256, 1152, 480), 3, &"multi_entry_waystation_hub")
	assert_eq(room.call("get_spawn_position", &"stage11_demo_end_start"), Vector2(-128, 172))
	assert_eq(room.call("get_spawn_position", &"stage11_demo_end_return"), Vector2(560, 172))
	assert_eq(room.get_node("ReplayZone").position, Vector2(-256, 128))
	assert_eq(room.get_node("GoalZone").position, Vector2(480, 128))
	assert_eq(room.get_node("ContinueZone").position, Vector2(672, 128))


func test_stage13_entry_is_three_segment_checkpoint_reveal() -> void:
	var room := _room(ENTRY)
	_assert_phase2_layout(room, Rect2i(-320, -240, 1920, 480), 3, &"region_reveal")
	_assert_previous(room, END, &"stage11_demo_end_return", -304.0)
	assert_eq(room.call("get_spawn_position", &"stage13_entry_start"), Vector2(-256, 108))
	assert_eq(room.call("get_spawn_position", &"stage13_entry_return"), Vector2(1500, 188))
	assert_eq(room.get_node("ExitZone").position, Vector2(1552, 188))
	assert_true(room.get_node("RegionCheckpoint/CheckpointArt").visible)


func test_stage13_caster_is_three_segment_wind_seal_tutorial() -> void:
	var room := _room(CASTER)
	_assert_phase2_layout(room, Rect2i(-320, -240, 1920, 480), 3, &"wind_seal_tutorial")
	_assert_previous(room, ENTRY, &"stage13_entry_return", -304.0)
	assert_eq(room.call("get_spawn_position", &"stage13_miasma_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_caster_return"), Vector2(1500, 204))
	assert_eq(room.get_node("MiasmaCasterEnemy").position, Vector2(320, 172))
	assert_eq(room.get_node("GateBarrier").position, Vector2(1480, 168))
	assert_false(bool(room.call("is_gate_unlocked")))


func test_stage13_miasma_is_three_segment_upper_lower_hazard_room() -> void:
	var room := _room(MIASMA)
	_assert_phase2_layout(room, Rect2i(-320, -240, 1920, 600), 3, &"upper_lower_hazard")
	_assert_previous(room, CASTER, &"stage13_caster_return", -304.0)
	assert_eq(room.call("get_spawn_position", &"stage13_miasma_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_miasma_return"), Vector2(1500, 204))
	assert_eq(room.get_node("MiasmaHazard").position, Vector2(672, 256))
	assert_eq(room.get_node("AirDashRevisitReward").position, Vector2(608, 216))
	assert_eq(room.get_node("ExitZone").position, Vector2(1552, 204))


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


func _assert_phase2_layout(room: Node2D, limits: Rect2i, segments: int, profile: StringName) -> void:
	assert_eq(room.call("get_camera_limits"), limits)
	var layout := room.get_node_or_null("Phase2GrayboxLayout")
	assert_not_null(layout)
	if layout == null:
		return
	assert_eq(int(layout.call("get_segment_count")), segments)
	assert_eq(layout.call("get_layout_profile"), profile)
	assert_gte(int(layout.call("get_runtime_platform_count")), segments)
	assert_false(bool((room.get_node("TerrainCollisionVisual") as TileMapLayer).collision_enabled))
	assert_false(bool((room.get_node("PlatformCollisionVisual") as TileMapLayer).collision_enabled))


func _assert_previous(room: Node2D, path: String, spawn: StringName, left_exit_x := -352.0) -> void:
	assert_eq(str(room.get("previous_room_path")), path)
	assert_eq(room.get("previous_spawn_id"), spawn)
	assert_eq(room.get_node("LeftExitZone").position.x, left_exit_x)


func _room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed)
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room
