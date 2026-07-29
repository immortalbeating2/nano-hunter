extends GutTest

# 正式地图 Batch 6：Stage13 支路 hub、两条支路、回环和区域终点。

const PRESSURE := "res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn"
const HUB := "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"
const RESOURCE := "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"
const CHALLENGE := "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn"
const RETURN := "res://scenes/rooms/stage13_miasma_marsh_return_room.tscn"
const GOAL := "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"


func test_hub_is_24x9_three_route_landmark_room() -> void:
	var room := _room(HUB)
	_assert_layout(room, Rect2i(-384, -320, 1536, 576), Vector2i(-6, 3), 24, 8)
	_assert_previous(room, PRESSURE, &"stage13_pressure_return")
	assert_eq(room.call("get_spawn_position", &"stage13_branch_hub_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_resource_branch_return"), Vector2(768, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_challenge_branch_return"), Vector2(832, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_branch_hub_return"), Vector2(896, 204))
	assert_eq(room.get_node("ResourceBranchZone").position, Vector2(128, 120))
	assert_eq(room.get_node("ChallengeBranchZone").position, Vector2(448, 56))
	assert_eq(room.get_node("ExitZone").position, Vector2(1120, 160))


func test_resource_branch_is_18x8_low_risk_ascent() -> void:
	var room := _room(RESOURCE)
	_assert_layout(room, Rect2i(-384, -256, 1152, 512), Vector2i(-6, 3), 18, 8)
	_assert_previous(room, HUB, &"stage13_resource_branch_return")
	assert_eq(room.call("get_spawn_position", &"stage13_resource_branch_start"), Vector2(-256, 204))
	assert_eq(room.get_node("Stage13Reward").position, Vector2(512, 56))
	assert_eq(room.get_node("ExitZone").position, Vector2(736, 160))


func test_challenge_branch_is_24x9_enemy_gate_reward_room() -> void:
	var room := _room(CHALLENGE)
	_assert_layout(room, Rect2i(-384, -320, 1536, 576), Vector2i(-6, 3), 24, 12)
	_assert_previous(room, HUB, &"stage13_challenge_branch_return")
	assert_eq(room.call("get_spawn_position", &"stage13_challenge_branch_start"), Vector2(-256, 204))
	assert_eq(room.get_node("MiasmaCasterEnemy").position, Vector2(512, 56))
	assert_eq(room.get_node("GateBarrier").position, Vector2(960, 168))
	assert_eq(room.get_node("Stage13Reward").position, Vector2(1040, 192))
	assert_eq(room.get_node("ExitZone").position, Vector2(1120, 160))
	assert_true(bool(room.get("require_all_enemies_defeated")))
	assert_false(bool(room.call("is_gate_unlocked")))


func test_return_is_20x8_convergence_room() -> void:
	var room := _room(RETURN)
	_assert_layout(room, Rect2i(-384, -256, 1280, 512), Vector2i(-6, 3), 20, 8)
	_assert_previous(room, HUB, &"stage13_branch_hub_return")
	assert_eq(room.call("get_spawn_position", &"stage13_return_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_return_return"), Vector2(640, 204))
	assert_eq(room.get_node("ExitZone").position, Vector2(800, 160))


func test_goal_is_20x8_upper_ritual_endpoint() -> void:
	var room := _room(GOAL)
	_assert_layout(room, Rect2i(-384, -256, 1280, 512), Vector2i(-6, 3), 20, 5)
	_assert_previous(room, RETURN, &"stage13_return_return")
	assert_eq(room.call("get_spawn_position", &"stage13_goal_start"), Vector2(-256, 204))
	assert_eq(room.get_node("GoalDevice").position, Vector2(640, 112))
	assert_eq(room.get_node("GoalZone").position, Vector2(704, 96))


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
