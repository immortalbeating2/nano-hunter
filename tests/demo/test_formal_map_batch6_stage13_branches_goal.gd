extends GutTest

# 正式地图 Batch 6：Stage13 支路 hub、两条支路、回环和区域终点。

const CHECKPOINT := "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"
const HUB := "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"
const RESOURCE := "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"
const CHALLENGE := "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn"
const RETURN := "res://scenes/rooms/stage13_miasma_marsh_return_room.tscn"
const GOAL := "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"


func test_hub_is_three_segment_three_height_landmark_room() -> void:
	var room := _room(HUB)
	_assert_phase2_layout(room, Rect2i(-320, -240, 1920, 540), 3, &"three_route_hub")
	_assert_previous(room, CHECKPOINT, &"stage13_checkpoint_return", -304.0)
	assert_eq(room.call("get_spawn_position", &"stage13_branch_hub_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_resource_branch_return"), Vector2(1088, 264))
	assert_eq(room.call("get_spawn_position", &"stage13_challenge_branch_return"), Vector2(1200, 44))
	var goal_return_spawn: Vector2 = room.call("get_spawn_position", &"stage13_branch_hub_return")
	assert_eq(goal_return_spawn, Vector2(1456, 172))
	assert_eq(room.get_node("ResourceBranchZone").position, Vector2(1088, 264))
	assert_eq(room.get_node("ChallengeBranchZone").position, Vector2(1200, 44))
	assert_eq(room.get_node("ExitZone").position, Vector2(1552, 172))
	assert_lt(goal_return_spawn.x, (room.get_node("ExitZone") as Node2D).position.x - 36.0)
	assert_true(bool(room.get_node("Phase2GrayboxLayout").call("has_support_below", goal_return_spawn, 72.0)))
	assert_eq(room.get_node("AirDashFastRouteZone").position, Vector2(1088, 44))
	assert_eq(room.get_node("AirDashFastRouteExitMarker").position, Vector2(1552, 44))


func test_resource_branch_is_18x8_low_risk_ascent() -> void:
	var room := _room(RESOURCE)
	_assert_phase2_layout(room, Rect2i(-384, -256, 1152, 512), 2, &"breakable_relic_one_way_return")
	_assert_previous(room, HUB, &"stage13_resource_branch_return")
	assert_eq(room.call("get_spawn_position", &"stage13_resource_branch_start"), Vector2(-256, 204))
	assert_eq(room.get_node("Stage13Reward").position, Vector2(544, 108))
	assert_eq(room.get_node("ExitZone").position, Vector2(736, 160))


func test_challenge_branch_is_24x9_enemy_gate_reward_room() -> void:
	var room := _room(CHALLENGE)
	_assert_phase2_layout(room, Rect2i(-384, -320, 1536, 640), 3, &"layered_encounter_clear_route")
	_assert_previous(room, HUB, &"stage13_challenge_branch_return")
	assert_eq(room.call("get_spawn_position", &"stage13_challenge_branch_start"), Vector2(-256, 204))
	assert_eq(room.get_node("MiasmaCasterEnemy").position, Vector2(384, 92))
	assert_eq(room.get_node("GateBarrier").position, Vector2(960, 168))
	assert_eq(room.get_node("Stage13Reward").position, Vector2(1040, 172))
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
	_assert_phase2_layout(room, Rect2i(-384, -256, 1280, 512), 2, &"dual_entry_goal_convergence")
	_assert_previous(room, HUB, &"stage13_branch_hub_return")
	assert_eq(room.call("get_spawn_position", &"stage13_goal_start"), Vector2(-256, 204))
	assert_eq(room.get_node("GoalDevice").position, Vector2(640, 88))
	assert_eq(room.get_node("GoalZone").position, Vector2(704, 108))
	var right_boundary := room.get_node_or_null("RightBoundary") as StaticBody2D
	assert_not_null(right_boundary)
	if right_boundary != null:
		assert_gt(right_boundary.position.x - (room.get_node("GoalZone") as Node2D).position.x, 64.0)
		var boundary_shape := right_boundary.get_node("CollisionShape2D") as CollisionShape2D
		assert_false(boundary_shape.disabled)
		assert_eq((boundary_shape.shape as RectangleShape2D).size, Vector2(32, 256))
		assert_false((right_boundary.get_node("RightCliffVisual") as Polygon2D).visible)


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
