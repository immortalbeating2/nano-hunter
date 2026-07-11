extends GutTest

# 正式地图 Batch 3：Stage10 主线、奖励支路和挑战房必须拥有不同垂直轮廓。

const AERIAL := "res://scenes/rooms/stage10_zone_aerial_room.tscn"
const BRANCH := "res://scenes/rooms/stage10_zone_branch_room.tscn"
const CHALLENGE := "res://scenes/rooms/stage10_zone_challenge_room.tscn"


func test_stage10_aerial_is_24x9_three_layer_main_room() -> void:
	var room := _room(AERIAL)
	_assert_cells(room, Rect2i(-384, -320, 1536, 576), Vector2i(-6, 3), 24, [4, 4, 4])
	assert_eq(room.get("previous_room_path"), "res://scenes/rooms/stage9_zone_final_room.tscn")
	assert_eq(room.get("previous_spawn_id"), &"zone_final_return")
	assert_eq(room.call("get_spawn_position", &"stage10_aerial_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage10_aerial_return"), Vector2(256, 204))
	assert_eq(room.get_node("BranchZone").position, Vector2(-96, 124))
	assert_eq(room.get_node("AerialSentinelEnemy").position, Vector2(384, 56))
	assert_eq(room.get_node("GroundChargerEnemy").position, Vector2(640, 200))
	assert_eq(room.get_node("GateBarrier").position, Vector2(1024, 168))


func test_stage10_branch_is_18x8_compact_reward_climb() -> void:
	var room := _room(BRANCH)
	_assert_cells(room, Rect2i(-384, -256, 1152, 512), Vector2i(-6, 3), 18, [4, 4])
	assert_eq(room.get("previous_room_path"), AERIAL)
	assert_eq(room.get("previous_spawn_id"), &"stage10_aerial_return")
	assert_eq(room.get("next_spawn_id"), &"stage10_aerial_return")
	assert_eq(room.call("get_spawn_position", &"stage10_branch_start"), Vector2(-256, 204))
	assert_eq(room.get_node("AerialSentinelEnemy").position, Vector2(64, 120))
	assert_eq(room.get_node("RecoveryPoint").position, Vector2(224, 112))
	assert_eq(room.get_node("BranchCollectible").position, Vector2(416, 40))
	assert_eq(room.get_node("GateBarrier").position, Vector2(640, 168))


func test_stage10_challenge_is_26x10_three_enemy_clear_arena() -> void:
	var room := _room(CHALLENGE)
	_assert_cells(room, Rect2i(-384, -384, 1664, 640), Vector2i(-6, 4), 26, [5, 5, 4])
	assert_eq(room.get("previous_room_path"), AERIAL)
	assert_eq(room.get("previous_spawn_id"), &"stage10_aerial_return")
	assert_true(bool(room.get("require_all_enemies_defeated")))
	assert_eq(room.call("get_spawn_position", &"stage10_challenge_start"), Vector2(-256, 268))
	assert_eq(room.get_node("BasicMeleeEnemy").position, Vector2(128, 184))
	assert_eq(room.get_node("GroundChargerEnemy").position, Vector2(512, 264))
	assert_eq(room.get_node("AerialSentinelEnemy").position, Vector2(832, 120))
	assert_eq(room.get_node("ChallengeCollectible").position, Vector2(896, 104))
	assert_eq(room.get_node("GateBarrier").position, Vector2(1152, 232))
	assert_false(bool(room.call("is_gate_unlocked")))
	room.get_node("BasicMeleeEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	await get_tree().process_frame
	assert_false(bool(room.call("is_gate_unlocked")))
	room.get_node("GroundChargerEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	await get_tree().process_frame
	assert_false(bool(room.call("is_gate_unlocked")))
	room.get_node("AerialSentinelEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	await get_tree().process_frame
	assert_true(bool(room.call("is_gate_unlocked")))


func _assert_cells(room: Node2D, limits: Rect2i, floor_start: Vector2i, floor_length: int, platform_lengths: Array[int]) -> void:
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
	assert_eq(terrain.get_used_cells().size(), floor_length)
	assert_eq(surface.get_used_cells().size(), floor_length)
	var expected_platform_cells := 0
	for length: int in platform_lengths:
		expected_platform_cells += length
	assert_eq(platform.get_used_cells().size(), expected_platform_cells)
	assert_eq(thin.get_used_cells().size(), expected_platform_cells)
	for offset: int in range(floor_length):
		assert_eq(terrain.get_cell_source_id(floor_start + Vector2i(offset, 0)), 0)
	assert_eq(room.get_node("LeftExitZone").position.x, -352.0)
	for old_name: String in ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]:
		var old := room.get_node(old_name) as TileMapLayer
		assert_false(old.visible)
		assert_false(bool(old.get("collision_enabled")))


func _room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed)
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room
