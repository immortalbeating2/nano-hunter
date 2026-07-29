extends GutTest

# 正式地图 Batch 5：Stage13 中段 Gate / Crossfire / Checkpoint / Pressure 四房。

const MIASMA := "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"
const GATE := "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"
const CROSSFIRE := "res://scenes/rooms/stage13_miasma_marsh_crossfire_room.tscn"
const CHECKPOINT := "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"
const PRESSURE := "res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn"


func test_gate_is_22x9_seal_then_gate_room() -> void:
	var room := _room(GATE)
	_assert_layout(room, Rect2i(-384, -320, 1408, 576), Vector2i(-6, 3), 22, 8)
	_assert_previous(room, MIASMA, &"stage13_miasma_return")
	assert_eq(room.call("get_spawn_position", &"stage13_gate_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_gate_return"), Vector2(768, 204))
	assert_eq(room.get_node("SealNode").position, Vector2(384, 56))
	assert_true(room.get_node("SealNode/SealArt").visible)
	assert_eq(room.get_node("SealNode/SealArt").get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.talisman_stake_idle")
	assert_eq(room.get_node("GateBarrier").position, Vector2(832, 168))
	assert_eq(room.get_node("ExitZone").position, Vector2(992, 160))
	assert_false(bool(room.call("is_gate_unlocked")))


func test_crossfire_is_26x10_three_layer_ranged_arena() -> void:
	var room := _room(CROSSFIRE)
	_assert_layout(room, Rect2i(-384, -320, 1664, 640), Vector2i(-6, 4), 26, 12)
	_assert_previous(room, GATE, &"stage13_gate_return")
	assert_eq(room.call("get_spawn_position", &"stage13_crossfire_start"), Vector2(-256, 268))
	assert_eq(room.call("get_spawn_position", &"stage13_crossfire_return"), Vector2(1088, 268))
	assert_eq(room.get_node("MiasmaCasterEnemyA").position, Vector2(128, 184))
	assert_eq(room.get_node("MiasmaCasterEnemyB").position, Vector2(768, 120))
	assert_eq(room.get_node("ExitZone").position, Vector2(1248, 224))


func test_checkpoint_is_18x8_quiet_recovery_hall() -> void:
	var room := _room(CHECKPOINT)
	_assert_layout(room, Rect2i(-384, -256, 1152, 512), Vector2i(-6, 3), 18, 3)
	_assert_previous(room, CROSSFIRE, &"stage13_crossfire_return")
	assert_eq(room.call("get_spawn_position", &"stage13_checkpoint_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_checkpoint_return"), Vector2(576, 204))
	assert_eq(room.get_node("RecoveryPoint").position, Vector2(128, 192))
	assert_eq(room.get_node("ExitZone").position, Vector2(736, 160))
	assert_true(room.get_node("RecoveryPoint/CheckpointArt").visible)


func test_pressure_is_24x9_hazard_bypass_and_ranged_pressure_room() -> void:
	var room := _room(PRESSURE)
	_assert_layout(room, Rect2i(-384, -320, 1536, 576), Vector2i(-6, 3), 24, 9)
	_assert_previous(room, CHECKPOINT, &"stage13_checkpoint_return")
	assert_eq(room.call("get_spawn_position", &"stage13_pressure_start"), Vector2(-256, 204))
	assert_eq(room.call("get_spawn_position", &"stage13_pressure_return"), Vector2(960, 204))
	assert_eq(room.get_node("MiasmaHazard").position, Vector2(384, 212))
	assert_eq(room.get_node("MiasmaCasterEnemy").position, Vector2(800, 56))
	assert_eq(room.get_node("ExitZone").position, Vector2(1120, 160))


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
