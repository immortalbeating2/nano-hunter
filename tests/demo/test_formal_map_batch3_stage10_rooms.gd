extends GutTest

# 正式地图 Batch 3：Stage10 主线、奖励支路和挑战房必须拥有不同垂直轮廓。

const AERIAL := "res://scenes/rooms/stage10_zone_aerial_room.tscn"
const BRANCH := "res://scenes/rooms/stage10_zone_branch_room.tscn"
const CHALLENGE := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const PLAYER := "res://scenes/player/player_placeholder.tscn"
const THIN_PLATFORM_TILESET := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"
const PLATFORM_TOP_IN_CELL := 16.0
const PLAYER_HALF_HEIGHT := 20.0


func before_each() -> void:
	_release_movement_inputs()


func after_each() -> void:
	_release_movement_inputs()


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
	assert_eq(room.get("previous_room_path"), "res://scenes/rooms/stage9_zone_switch_room.tscn")
	assert_eq(room.get("previous_spawn_id"), &"zone_switch_from_stage10_shortcut")
	assert_eq(room.get("next_spawn_id"), &"stage10_aerial_return")
	assert_eq(room.call("get_spawn_position", &"stage10_branch_start"), Vector2(-256, 204))
	assert_eq(room.get_node("AerialSentinelEnemy").position, Vector2(64, 120))
	assert_eq(room.get_node("RecoveryPoint").position, Vector2(224, 112))
	assert_eq(room.get_node("BranchCollectible").position, Vector2(416, 40))
	assert_eq(room.get_node("GateBarrier").position, Vector2(640, 168))


# 区域 10 三房的逐级上行都必须能用当前正常跑跳完成，不能依赖尚未解锁的空中冲刺。
func test_stage10_aerial_two_step_climb_is_reachable_with_normal_jump() -> void:
	await _assert_normal_jump_reaches_step(AERIAL, Vector2(96, 96), 144.0, 80.0)


func test_stage10_branch_two_step_climb_is_reachable_with_normal_jump() -> void:
	await _assert_normal_jump_reaches_step(BRANCH, Vector2(96, 96), 144.0, 80.0, ["AerialSentinelEnemy"])


func test_stage10_challenge_two_step_climb_is_reachable_with_normal_jump() -> void:
	await _assert_normal_jump_reaches_step(CHALLENGE, Vector2(164, 160), 208.0, 144.0, ["BasicMeleeEnemy"])


# 三个正式薄平台切片共用同一顶沿偏移；修一次资源即可覆盖所有正式房间。
func test_shared_thin_platform_visual_top_matches_one_way_collision() -> void:
	var tile_set := load(THIN_PLATFORM_TILESET) as TileSet
	assert_not_null(tile_set)
	if tile_set == null:
		return
	var source := tile_set.get_source(0) as TileSetAtlasSource
	assert_not_null(source)
	if source == null:
		return
	var image := source.texture.get_image()
	assert_not_null(image)
	if image == null:
		return

	for tile_x: int in range(3):
		var tile_data := source.get_tile_data(Vector2i(tile_x, 0), 0)
		var alpha_top := _find_alpha_top(image, Rect2i(tile_x * 64, 0, 64, 64))
		assert_not_null(tile_data)
		assert_gte(alpha_top, 0)
		if tile_data != null and alpha_top >= 0:
			var visual_top := float(alpha_top + tile_data.texture_origin.y)
			assert_almost_eq(visual_top, PLATFORM_TOP_IN_CELL, 1.0, "薄平台视觉顶沿必须贴合碰撞：tile=%s" % tile_x)


func test_stage10_challenge_is_26x10_three_enemy_clear_arena() -> void:
	var room := _room(CHALLENGE)
	_assert_cells(room, Rect2i(-384, -384, 1664, 640), Vector2i(-6, 4), 26, [5, 5, 4])
	assert_eq(room.get("previous_room_path"), AERIAL)
	assert_eq(room.get("previous_spawn_id"), &"stage10_aerial_return")
	assert_true(bool(room.get("require_all_enemies_defeated")))
	assert_eq(room.call("get_spawn_position", &"stage10_challenge_start"), Vector2(-256, 268))
	assert_eq(room.get_node("BasicMeleeEnemy").position, Vector2(128, 184))
	assert_eq(room.get_node("GroundChargerEnemy").position, Vector2(512, 264))
	# 正式重排后的低台跳跃必须能进入空中攻击判定窗，避免全清门被不可达敌人永久锁住。
	assert_eq(room.get_node("AerialSentinelEnemy").position, Vector2(832, 144))
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


# 在真实房间碰撞中生成 Luna，并等待其落到指定平台。
func _spawn_player_in_room(room: Node2D, spawn_position: Vector2) -> CharacterBody2D:
	var packed := load(PLAYER) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return null
	var player := packed.instantiate() as CharacterBody2D
	player.global_position = spawn_position
	add_child_autofree(player)
	room.call("bind_player", player)
	for _frame: int in range(90):
		await get_tree().physics_frame
		if player.is_on_floor() and absf(player.velocity.y) <= 0.1:
			await get_tree().physics_frame
			return player
	return player


func _assert_normal_jump_reaches_step(
	room_path: String,
	spawn_position: Vector2,
	start_foot_y: float,
	target_foot_y: float,
	enemy_names: Array[String] = [],
) -> void:
	var room := _room(room_path)
	for enemy_name: String in enemy_names:
		room.get_node(enemy_name).call("receive_attack", Vector2.RIGHT, 120.0)
	await get_tree().process_frame
	var player := await _spawn_player_in_room(room, spawn_position)
	assert_not_null(player)
	if player == null:
		return

	assert_true(player.is_on_floor())
	assert_almost_eq(player.global_position.y + PLAYER_HALF_HEIGHT, start_foot_y, 0.6)
	player.velocity.x = float(player.get("max_run_speed"))
	Input.action_press("move_right")
	Input.action_press("jump")
	var landed_upper := false
	var max_x := player.global_position.x
	var min_y := player.global_position.y
	for frame: int in range(90):
		if frame == 32:
			Input.action_release("jump")
		await get_tree().physics_frame
		max_x = maxf(max_x, player.global_position.x)
		min_y = minf(min_y, player.global_position.y)
		if player.is_on_floor() and absf(player.global_position.y + PLAYER_HALF_HEIGHT - target_foot_y) <= 0.6:
			landed_upper = true
			break
	Input.action_release("move_right")
	Input.action_release("jump")
	assert_true(landed_upper, "%s 正常跑跳应落到二层台阶：max_x=%s min_y=%s final=%s" % [room_path, max_x, min_y, player.global_position])


func _find_alpha_top(image: Image, region: Rect2i) -> int:
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			if image.get_pixel(x, y).a > 0.05:
				return y - region.position.y
	return -1


func _release_movement_inputs() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("dash")
