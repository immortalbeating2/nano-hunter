extends GutTest

# 正式地图 Batch 9：Stage16 五房终局封印链。

const COMPLETION := "res://scenes/rooms/stage15_completion_room.tscn"
const THRESHOLD := "res://scenes/rooms/stage16_seal_release_threshold_room.tscn"
const RELAY := "res://scenes/rooms/stage16_talisman_relay_room.tscn"
const BACKTRACK := "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn"
const PURGE := "res://scenes/rooms/stage16_corruption_purge_room.tscn"
const END := "res://scenes/rooms/stage16_alpha_demo_end_room.tscn"


func test_threshold_is_20x8_upper_release_room() -> void:
	var room := _room(THRESHOLD)
	_assert_layout(room, Rect2i(-384, -256, 1280, 512), Vector2i(-6, 3), 20, 5)
	_assert_previous(room, COMPLETION, &"stage15_completion_return", 160.0)
	assert_eq(room.call("get_spawn_position", &"stage16_seal_release_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage16_seal_release_return"), Vector2(640, 204))
	assert_eq(room.get_node("SealReleaseNode").position, Vector2(320, 112))
	assert_eq(room.get_node("GateBarrier").position, Vector2(704, 168))
	assert_eq(room.get_node("ExitZone").position, Vector2(800, 160))


func test_relay_is_26x10_three_level_chain() -> void:
	var room := _room(RELAY)
	_assert_layout(room, Rect2i(-384, -320, 1664, 640), Vector2i(-6, 4), 26, 12)
	_assert_previous(room, THRESHOLD, &"stage16_seal_release_return", 224.0)
	assert_eq(room.call("get_spawn_position", &"stage16_talisman_relay_start"), Vector2(-256, 268))
	assert_eq(room.call("get_spawn_position", &"stage16_relay_return"), Vector2(1088, 268))
	assert_eq(room.get_node("TalismanRelayA").position, Vector2(128, 184))
	assert_eq(room.get_node("TalismanRelayB").position, Vector2(512, 120))
	assert_eq(room.get_node("TalismanRelayC").position, Vector2(896, 56))
	assert_eq(room.get_node("GateBarrier").position, Vector2(1152, 232))


func test_backtrack_is_22x9_upper_confirmation_room() -> void:
	var room := _room(BACKTRACK)
	_assert_layout(room, Rect2i(-384, -320, 1408, 576), Vector2i(-6, 3), 22, 9)
	_assert_previous(room, RELAY, &"stage16_relay_return", 160.0)
	assert_eq(room.call("get_spawn_position", &"stage16_backtrack_confirmation_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage16_backtrack_return"), Vector2(832, 204))
	assert_eq(room.get_node("BacktrackConfirmationNode").position, Vector2(640, 56))
	assert_eq(room.get_node("GateBarrier").position, Vector2(896, 168))


func test_purge_is_24x9_hazard_and_upper_purge_room() -> void:
	var room := _room(PURGE)
	_assert_layout(room, Rect2i(-384, -320, 1536, 576), Vector2i(-6, 3), 24, 12)
	_assert_previous(room, BACKTRACK, &"stage16_backtrack_return", 160.0)
	assert_eq(room.call("get_spawn_position", &"stage16_corruption_purge_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage16_purge_return"), Vector2(960, 204))
	assert_eq(room.get_node("CorruptionMiasma").position, Vector2(448, 212))
	assert_eq(room.get_node("CorruptionPurgeNode").position, Vector2(640, 56))
	assert_eq(room.get_node("GateBarrier").position, Vector2(1024, 168))


func test_end_is_18x8_final_ceremonial_room() -> void:
	var room := _room(END)
	_assert_layout(room, Rect2i(-384, -256, 1152, 512), Vector2i(-6, 3), 18, 5)
	_assert_previous(room, PURGE, &"stage16_purge_return", 160.0)
	assert_eq(room.call("get_spawn_position", &"stage16_alpha_demo_end_start"), Vector2(-256, 204))
	assert_eq(room.get_node("AlphaDemoSeal").position, Vector2(320, 112))
	assert_eq(room.get_node("ExitZone").position, Vector2(736, 160))


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
