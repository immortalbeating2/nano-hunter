extends GutTest

# 正式地图 Batch 7：Stage14 Shrine、Backtrack Hub、Loop Return 三房。

const STAGE13_GOAL := "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"
const SHRINE := "res://scenes/rooms/stage14_air_dash_shrine_room.tscn"
const GATE := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const HUB := "res://scenes/rooms/stage14_backtrack_hub_room.tscn"
const LOOP := "res://scenes/rooms/stage14_loop_return_room.tscn"


func test_shrine_is_20x8_single_focus_ability_room() -> void:
	var room := _room(SHRINE)
	_assert_layout(room, Rect2i(-384, -256, 1280, 512), Vector2i(-6, 3), 20, 4)
	_assert_previous(room, STAGE13_GOAL, &"stage13_goal_return", 160.0)
	assert_eq(room.call("get_spawn_position", &"stage14_air_dash_shrine_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage14_shrine_return"), Vector2(640, 204))
	assert_eq(room.get_node("AirDashShrine").position, Vector2(320, 120))
	assert_eq(room.get_node("ExitZone").position, Vector2(800, 160))
	for old_art: String in ["AirDashShrineRoomArt", "MiasmaHazardRoomArt", "ShrineTrialTileSheetArt"]:
		assert_false(bool(room.get_node(old_art).visible))


func test_hub_is_26x10_three_reward_ascent() -> void:
	var room := _room(HUB)
	_assert_layout(room, Rect2i(-384, -320, 1664, 640), Vector2i(-6, 4), 26, 12)
	_assert_previous(room, GATE, &"stage14_gate_return", 224.0)
	assert_eq(room.call("get_spawn_position", &"stage14_backtrack_hub_start"), Vector2(-256, 268))
	assert_eq(room.call("get_spawn_position", &"stage14_hub_return"), Vector2(1088, 268))
	assert_eq(room.get_node("BacktrackRewardOne").position, Vector2(128, 184))
	assert_eq(room.get_node("BacktrackRewardTwo").position, Vector2(512, 120))
	assert_eq(room.get_node("BacktrackRewardThree").position, Vector2(896, 56))
	assert_eq(room.get_node("ExitZone").position, Vector2(1248, 224))


func test_loop_return_is_20x8_upper_goal_room() -> void:
	var room := _room(LOOP)
	_assert_layout(room, Rect2i(-384, -256, 1280, 512), Vector2i(-6, 3), 20, 8)
	_assert_previous(room, HUB, &"stage14_hub_return", 160.0)
	assert_eq(room.call("get_spawn_position", &"stage14_loop_return_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage14_loop_return_return"), Vector2(640, 204))
	assert_eq(room.get_node("GoalZone").position, Vector2(704, 56))


func test_adjacent_rooms_expose_safe_return_spawns() -> void:
	var stage13_goal := _room(STAGE13_GOAL)
	var gate := _room(GATE)
	assert_eq(stage13_goal.call("get_spawn_position", &"stage13_goal_return"), Vector2(640, 204))
	assert_eq(gate.call("get_spawn_position", &"stage14_gate_return"), Vector2(864, 60))


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


func _assert_previous(room: Node2D, path: String, spawn: StringName, left_exit_y: float) -> void:
	assert_eq(str(room.get("previous_room_path")), path)
	assert_eq(room.get("previous_spawn_id"), spawn)
	assert_eq(room.get_node("LeftExitZone").position, Vector2(-352, left_exit_y))


func _room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed)
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room
