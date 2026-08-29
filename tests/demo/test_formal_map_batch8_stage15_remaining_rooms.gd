extends GutTest

# 正式地图 Batch 8：Stage15 Pressure、Challenge、Boss、Completion 四房。

const LOOP := "res://scenes/rooms/stage14_loop_return_room.tscn"
const PRESSURE := "res://scenes/rooms/stage15_seal_pressure_room.tscn"
const GAUNTLET := "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"
const CHALLENGE := "res://scenes/rooms/stage15_challenge_branch_room.tscn"
const BOSS := "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn"
const COMPLETION := "res://scenes/rooms/stage15_completion_room.tscn"


func test_pressure_is_24x9_two_enemy_clear_room() -> void:
	var room := _room(PRESSURE)
	_assert_layout(room, Rect2i(-384, -320, 1536, 576), Vector2i(-6, 3), 24, 12)
	_assert_previous(room, LOOP, &"stage14_loop_return_return", 160.0)
	assert_eq(room.call("get_spawn_position", &"stage15_seal_pressure_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage15_pressure_return"), Vector2(960, 204))
	assert_eq(room.get_node("PressureFocusArt").position, Vector2(128, 120))
	assert_eq(room.get_node("GroundChargerEnemy").position, Vector2(448, 200))
	assert_eq(room.get_node("MiasmaCasterEnemy").position, Vector2(832, 56))
	assert_eq(room.get_node("GateBarrier").position, Vector2(1024, 168))
	assert_true(bool(room.get("require_all_enemies_defeated")))


func test_challenge_is_26x10_hazard_two_enemy_reward_room() -> void:
	var room := _room(CHALLENGE)
	_assert_layout(room, Rect2i(-384, -320, 1664, 640), Vector2i(-6, 4), 26, 12)
	_assert_previous(room, "res://scenes/rooms/stage14_backtrack_hub_room.tscn", &"stage14_hub_from_stage15_shortcut", 224.0)
	assert_eq(room.call("get_spawn_position", &"stage15_challenge_start"), Vector2(-256, 268))
	assert_eq(room.get_node("MiasmaHazard").position, Vector2(448, 276))
	assert_eq(room.get_node("MiasmaCasterEnemy").position, Vector2(128, 184))
	assert_eq(room.get_node("AerialSentinelEnemy").position, Vector2(768, 120))
	assert_eq(room.get_node("Stage13Reward").position, Vector2(1088, 256))
	assert_eq(room.get_node("GateBarrier").position, Vector2(1152, 232))
	assert_eq(room.get_node("ExitZone").position, Vector2(1248, 224))


func test_boss_is_28x10_wide_arena() -> void:
	var room := _room(BOSS)
	_assert_phase2_layout(room, Rect2i(-384, -320, 1792, 640), 2, &"boss_foyer_and_locked_arena")
	_assert_previous(room, GAUNTLET, &"stage15_boss_return", 224.0)
	assert_eq(room.call("get_spawn_position", &"stage15_boss_start"), Vector2(-256, 268))
	assert_eq(room.call("get_spawn_position", &"stage15_boss_return"), Vector2(1216, 268))
	assert_eq(room.get_node("SealGuardianBoss").position, Vector2(512, 248))
	assert_eq(room.get_node("GateBarrier").position, Vector2(1280, 232))
	assert_eq(room.get_node("ExitZone").position, Vector2(1376, 224))
	assert_null(room.get_node_or_null("SealGuardianRoomArt"))
	assert_null(room.get_node_or_null("BossWarningRoomArt"))
	assert_null(room.get_node_or_null("SealGuardianRoomAnimationPreview"))


func test_completion_is_two_segment_ceremonial_hall() -> void:
	var room := _room(COMPLETION)
	_assert_phase2_layout(room, Rect2i(-384, -256, 1408, 512), 2, &"post_boss_waystation_return")
	_assert_previous(room, BOSS, &"stage15_boss_return", 160.0)
	assert_eq(room.call("get_spawn_position", &"stage15_completion_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage15_completion_return"), Vector2(576, 204))
	assert_eq(room.get_node("CompletionSeal").position, Vector2(320, 112))
	assert_eq(room.get_node("ExitZone").position, Vector2(736, 160))
	assert_null(room.get_node_or_null("CompletionSeal/ReusableSealPropsPreviewArt"))


func test_gauntlet_exposes_boss_return_spawn() -> void:
	var room := _room(GAUNTLET)
	assert_eq(room.call("get_spawn_position", &"stage15_boss_return"), Vector2(960, 204))


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
