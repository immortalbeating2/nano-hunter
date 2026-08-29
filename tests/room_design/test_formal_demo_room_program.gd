extends GutTest

# 正式 Demo 房间 program 回归：保护 18 房正式集合、44 房开发可见性，
# 以及旧存档落在合并 / reserve 房间时的安全入口迁移。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const WORLD_MAP_VIEW_SCRIPT_PATH := "res://scripts/ui/world_map_view.gd"
const TUTORIAL_ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const COMBAT_TRIAL_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const GOAL_TRIAL_ROOM_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const WAYSTATION_ROOM_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const THUNDER_ENTRY_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_entry_room.tscn"

const EXPECTED_FORMAL_IDS := [
	"F01", "F02", "F03", "F04", "F05", "F06", "F07", "F08", "F09",
	"F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18",
]


func test_program_exposes_18_formal_rooms_and_26_reserve_rooms() -> void:
	var main := await _spawn_main()
	assert_true(main.has_method("get_formal_demo_room_program_snapshot"), "Main 必须暴露只读正式房间 program。")
	if not main.has_method("get_formal_demo_room_program_snapshot"):
		return

	var snapshot: Dictionary = main.call("get_formal_demo_room_program_snapshot")
	assert_eq(snapshot.get("program_id", ""), "formal_demo_room_recovery_b")
	assert_eq(snapshot.get("formal_room_count", 0), 18)
	assert_eq(snapshot.get("reserve_room_count", 0), 26)
	assert_eq(snapshot.get("formal_room_ids", []), EXPECTED_FORMAL_IDS)

	var formal_paths: Array = snapshot.get("formal_room_paths", [])
	assert_eq(formal_paths.size(), 18)
	assert_eq(formal_paths.duplicate().reduce(func(accum: Dictionary, path: Variant) -> Dictionary:
		accum[str(path)] = true
		return accum
	, {}).size(), 18, "正式房间路径不得重复。")
	for room_path: Variant in formal_paths:
		assert_true(ResourceLoader.exists(str(room_path)), "正式房间场景必须存在：%s" % room_path)


func test_world_map_can_switch_between_formal_18_and_all_44_rooms() -> void:
	var script := load(WORLD_MAP_VIEW_SCRIPT_PATH) as Script
	assert_not_null(script)
	if script == null:
		return
	var view := script.new() as Control
	add_child_autofree(view)
	await get_tree().process_frame

	assert_true(view.has_method("set_room_scope"), "地图视图必须支持 formal / all 范围。")
	if not view.has_method("set_room_scope"):
		return
	view.call("set_room_scope", &"formal")
	assert_eq(int(view.call("get_room_count")), 18)
	view.call("set_map_snapshot", {
		"current_room_path": "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn",
		"visited_room_paths": ["res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"],
	})
	assert_eq(str(view.call("get_current_room_label")), "F04 · 瘴泽入口")
	assert_true(view.has_method("get_formal_room_definitions"), "选关与地图必须共用正式房间定义。")
	if view.has_method("get_formal_room_definitions"):
		var definitions: Array = view.call("get_formal_room_definitions")
		var visible_ids: Array = []
		for definition: Dictionary in definitions:
			visible_ids.append(str(definition.get("id", "")))
		assert_eq(visible_ids, EXPECTED_FORMAL_IDS)
	view.call("set_room_scope", &"all")
	assert_eq(int(view.call("get_room_count")), 44)


func test_merged_and_reserve_rooms_resolve_to_safe_formal_entries() -> void:
	var main := await _spawn_main()
	assert_true(main.has_method("resolve_formal_demo_room_entry"), "Main 必须统一解析旧房安全入口。")
	if not main.has_method("resolve_formal_demo_room_entry"):
		return

	var active: Dictionary = main.call("resolve_formal_demo_room_entry", TUTORIAL_ROOM_PATH, &"tutorial_start")
	assert_eq(active.get("status", &""), &"formal")
	assert_eq(active.get("room_path", ""), TUTORIAL_ROOM_PATH)
	assert_eq(active.get("spawn_id", &""), &"tutorial_start")

	var merged: Dictionary = main.call("resolve_formal_demo_room_entry", GOAL_TRIAL_ROOM_PATH, &"goal_entry")
	assert_eq(merged.get("status", &""), &"merged")
	assert_eq(merged.get("room_path", ""), COMBAT_TRIAL_ROOM_PATH)
	assert_eq(merged.get("spawn_id", &""), &"combat_entry")

	var reserve: Dictionary = main.call("resolve_formal_demo_room_entry", THUNDER_ENTRY_ROOM_PATH, &"stage25_entry_start")
	assert_eq(reserve.get("status", &""), &"reserve")
	assert_eq(reserve.get("room_path", ""), WAYSTATION_ROOM_PATH)
	assert_eq(reserve.get("spawn_id", &""), &"stage11_demo_end_start")


func test_apply_save_snapshot_migrates_merged_checkpoint_before_continue() -> void:
	var main := await _spawn_main()
	assert_true(main.has_method("resolve_formal_demo_room_entry"))
	if not main.has_method("resolve_formal_demo_room_entry"):
		return

	var snapshot: Dictionary = main.call("build_save_snapshot")
	var checkpoint: Dictionary = snapshot.get("checkpoint", {})
	checkpoint["room_path"] = GOAL_TRIAL_ROOM_PATH
	checkpoint["spawn_id"] = "goal_entry"
	var progress: Dictionary = snapshot.get("progress", {})
	progress["visited_room_paths"] = [TUTORIAL_ROOM_PATH, GOAL_TRIAL_ROOM_PATH]

	var applied: Dictionary = main.call("apply_save_snapshot", snapshot)
	assert_true(bool(applied.get("ok", false)))
	var migrated: Dictionary = main.call("build_save_snapshot")
	var migrated_checkpoint: Dictionary = migrated.get("checkpoint", {})
	assert_eq(migrated_checkpoint.get("room_path", ""), COMBAT_TRIAL_ROOM_PATH)
	assert_eq(migrated_checkpoint.get("spawn_id", ""), "combat_entry")


func _spawn_main() -> Node2D:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	return main
