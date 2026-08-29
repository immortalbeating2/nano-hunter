extends GutTest

# 方案 B 门语义回归：普通相邻出口只保留路线边界，所有有状态屏障必须声明玩法类别，
# 历史批量制图脚本必须显式锁定，不能重新覆盖 F01–F18。


const PROGRAM_PATH := "res://assets/configs/world_map/formal_demo_room_program.json"
const ALLOWED_TRANSITION_TYPES := [
	"shrine_threshold",
	"waystation_passage",
	"miasma_boundary",
	"seal_threshold",
	"boss_approach",
]
const ALLOWED_GATE_SEMANTICS := ["clear_barrier", "ability_gate", "boss_gate", "waystation"]
const RETIRED_GENERATORS := [
	"res://scripts/dev/apply_formal_map_batch1_rooms.gd",
	"res://scripts/dev/apply_formal_map_batch4_stage11_stage13_entry.gd",
	"res://scripts/dev/apply_formal_map_batch5_stage13_mid_rooms.gd",
	"res://scripts/dev/apply_formal_map_batch6_stage13_branches_goal.gd",
	"res://scripts/dev/apply_formal_map_batch7_stage14_remaining_rooms.gd",
	"res://scripts/dev/apply_formal_map_batch8_stage15_remaining_rooms.gd",
	"res://scripts/dev/apply_formal_terrain_kit_tutorial_trial.gd",
	"res://scripts/dev/apply_formal_terrain_kit_stage14_gate_trial.gd",
	"res://scripts/dev/apply_formal_terrain_kit_stage15_gauntlet_trial.gd",
]


# 正式 18 房都禁止普通出口套通用门扇，并声明可读的边界表现。
func test_all_formal_rooms_publish_non_generic_transition_visuals() -> void:
	var program := _read_program()
	var rooms: Array = program.get("formal_rooms", [])
	assert_eq(rooms.size(), 18)
	for definition: Dictionary in rooms:
		var room := await _spawn_room(str(definition.get("path", "")))
		assert_false(bool(room.get_meta("normal_exit_uses_generic_door", true)), str(definition.get("id")))
		assert_true(
			str(room.get_meta("transition_visual_type", "")) in ALLOWED_TRANSITION_TYPES,
			"%s 缺少正式路线边界语义" % str(definition.get("id"))
		)
		var door_visual := room.get_node_or_null("DoorVisual") as TileMapLayer
		if door_visual != null:
			assert_true(door_visual.get_used_cells().is_empty(), "%s 的 DoorVisual 必须保持空层" % str(definition.get("id")))


# 教程门、清场结界、能力门与 Boss 门可保留，但不能再使用无含义的默认门分类。
func test_all_formal_barriers_declare_gameplay_semantics() -> void:
	var program := _read_program()
	for definition: Dictionary in program.get("formal_rooms", []):
		var room := await _spawn_room(str(definition.get("path", "")))
		for barrier_name in ["ExitBarrier", "GateBarrier", "BossRouteSeal"]:
			var barrier := room.get_node_or_null(barrier_name)
			if barrier == null:
				continue
			var semantics := str(barrier.get_meta("gate_semantics", room.get_meta("gate_semantics", "")))
			assert_true(
				semantics in ALLOWED_GATE_SEMANTICS,
				"%s/%s 屏障缺少玩法语义" % [str(definition.get("id")), barrier_name]
			)


# 旧批量模板只作历史证据；显式锁定后即使误执行也不得写回正式房。
func test_legacy_formal_generators_are_retired_from_f01_f18() -> void:
	for script_path: String in RETIRED_GENERATORS:
		var source := FileAccess.get_file_as_string(script_path)
		assert_string_contains(source, "FORMAL_DEMO_RECOVERY_LOCKED := true", script_path)
		assert_string_contains(source, "formal_demo_recovery_b", script_path)


func _read_program() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PROGRAM_PATH))
	assert_true(parsed is Dictionary)
	return parsed as Dictionary if parsed is Dictionary else {}


func _spawn_room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed, "缺少房间：%s" % path)
	if packed == null:
		return null
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room
