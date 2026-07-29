extends GutTest

# Stage19 房间蓝图与探索地图回归：保护 44 房布局、发现状态、远端连接和 Stage11 驿厅语义。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const WORLD_MAP_VIEW_SCRIPT_PATH := "res://scripts/ui/world_map_view.gd"
const WORLD_MAP_LAYOUT_PATH := "res://assets/configs/world_map/alpha_demo_world_map.json"
const WORLD_MAP_BASE_PATH := "res://assets/art/ui/stage19_discovery_map_base_ai01.png"
const TUTORIAL_ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const COMBAT_TRIAL_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const STAGE10_CHALLENGE_ROOM_PATH := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const STAGE11_ROOM_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const STAGE13_ENTRY_ROOM_PATH := "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"


func after_each() -> void:
	get_tree().paused = false


func test_world_map_layout_covers_44_formal_rooms_and_eight_remote_connections() -> void:
	var view := _spawn_world_map_view()
	assert_not_null(view)
	if view == null:
		return

	assert_eq(int(view.call("get_room_count")), 44)
	var room_paths: Array = view.call("get_room_paths")
	assert_true(TUTORIAL_ROOM_PATH in room_paths)
	assert_false("res://scenes/rooms/test_room.tscn" in room_paths)
	for room_path: Variant in room_paths:
		assert_true(ResourceLoader.exists(str(room_path)), "地图房间场景存在：%s" % str(room_path))

	var connection_ids: Array = view.call("get_remote_connection_ids")
	for connection_id: String in ["SC-01", "SC-02", "SC-03", "SC-04", "SC-05", "SC-06", "SC-07", "SC-08"]:
		assert_true(connection_id in connection_ids, "地图缺少远端连接：%s" % connection_id)


func test_world_map_art_and_topology_remain_separate_and_editable() -> void:
	var view := _spawn_world_map_view()
	assert_not_null(view)
	if view == null:
		return

	assert_eq(str(view.call("get_layout_source_path")), WORLD_MAP_LAYOUT_PATH)
	assert_eq(str(view.call("get_visual_style_id")), "ink_shrine_v1")
	assert_true(ResourceLoader.exists(WORLD_MAP_BASE_PATH))

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WORLD_MAP_LAYOUT_PATH))
	assert_true(parsed is Dictionary)
	if not parsed is Dictionary:
		return
	var rooms: Array = parsed.get("rooms", [])
	assert_eq(rooms.size(), 44)
	var unique_vertical_positions: Dictionary = {}
	for room: Dictionary in rooms:
		var position: Array = room.get("position", [])
		assert_eq(position.size(), 2, "房间坐标使用归一化二维数组：%s" % str(room.get("id", "?")))
		if position.size() < 2:
			continue
		assert_between(float(position[0]), 0.0, 1.0)
		assert_between(float(position[1]), 0.0, 1.0)
		unique_vertical_positions[str(position[1])] = true
	assert_gt(unique_vertical_positions.size(), 10, "布局不应退回五行蛇形调试图")

	var shell_scene_text := FileAccess.get_file_as_string("res://scenes/ui/demo_shell.tscn")
	assert_true(WORLD_MAP_BASE_PATH in shell_scene_text)
	assert_false("discovery-map-visual-reference" in shell_scene_text, "视觉母版不能成为运行时拓扑")


func test_main_discovers_rooms_during_transitions_and_resets_on_restart() -> void:
	var main := await _spawn_main()
	var initial: Dictionary = main.call("get_world_map_snapshot")
	assert_eq(str(initial.get("current_room_path", "")), TUTORIAL_ROOM_PATH)
	assert_eq(Array(initial.get("visited_room_paths", [])).size(), 1)
	assert_true(TUTORIAL_ROOM_PATH in Array(initial.get("visited_room_paths", [])))

	main.call("transition_to_room", COMBAT_TRIAL_ROOM_PATH, &"combat_entry")
	await get_tree().process_frame
	var progressed: Dictionary = main.call("get_world_map_snapshot")
	assert_eq(str(progressed.get("current_room_path", "")), COMBAT_TRIAL_ROOM_PATH)
	assert_eq(Array(progressed.get("visited_room_paths", [])).size(), 2)

	main.call("restart_demo")
	await get_tree().process_frame
	var restarted: Dictionary = main.call("get_world_map_snapshot")
	assert_eq(str(restarted.get("current_room_path", "")), TUTORIAL_ROOM_PATH)
	assert_eq(Array(restarted.get("visited_room_paths", [])).size(), 1)


func test_stage11_completes_short_chain_without_finishing_alpha_demo() -> void:
	var main := await _spawn_main()
	main.call("transition_to_room", STAGE11_ROOM_PATH, &"stage11_demo_end_start")
	await get_tree().process_frame
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_not_null(room)
	assert_not_null(player)
	if room == null or player == null:
		return

	player.global_position = (room.get_node("GoalZone") as Node2D).global_position
	await _advance_process_frames(3)
	var snapshot: Dictionary = main.call("get_demo_progress_snapshot")
	assert_true(bool(snapshot.get("short_chain_completed", false)))
	assert_false(bool(snapshot.get("demo_completed", true)))
	assert_false(bool(snapshot.get("stage16_alpha_demo_completed", true)))
	var detail_back_button := main.get_node_or_null(
		"HUD/DemoShell/DetailPanel/MarginContainer/VBoxContainer/DetailBackButton"
	) as Button
	assert_not_null(detail_back_button)
	if detail_back_button != null:
		detail_back_button.pressed.emit()
	assert_false(get_tree().paused)


func test_stage11_left_returns_stage10_and_right_continues_stage13() -> void:
	var left_room := await _spawn_room(STAGE11_ROOM_PATH)
	var left_player := await _spawn_player()
	var left_transitions: Array[Dictionary] = []
	left_room.call("bind_player", left_player)
	left_room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		left_transitions.append({"target": target, "spawn": spawn})
	)
	left_player.global_position = (left_room.get_node("GoalZone") as Node2D).global_position
	await _advance_process_frames(2)
	left_player.global_position = (left_room.get_node("ReplayZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq(left_transitions.size(), 1)
	if not left_transitions.is_empty():
		assert_eq(left_transitions[0].target, STAGE10_CHALLENGE_ROOM_PATH)
		assert_eq(left_transitions[0].spawn, &"stage10_challenge_return")

	var right_room := await _spawn_room(STAGE11_ROOM_PATH)
	var right_player := await _spawn_player()
	var right_transitions: Array[Dictionary] = []
	right_room.call("bind_player", right_player)
	right_room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		right_transitions.append({"target": target, "spawn": spawn})
	)
	right_player.global_position = (right_room.get_node("GoalZone") as Node2D).global_position
	await _advance_process_frames(2)
	right_player.global_position = (right_room.get_node("ContinueZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq(right_transitions.size(), 1)
	if not right_transitions.is_empty():
		assert_eq(right_transitions[0].target, STAGE13_ENTRY_ROOM_PATH)
		assert_eq(right_transitions[0].spawn, &"stage13_entry_start")


func test_pause_menu_opens_world_map_and_returns_without_resuming() -> void:
	var main := await _spawn_main()
	var shell := main.get_node("HUD/DemoShell") as Control
	assert_not_null(shell)
	if shell == null:
		return

	shell.call("pause_demo")
	var pause_menu := shell.get_node_or_null("PauseMenu") as Control
	var map_button := shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer/MapButton") as Button
	var map_panel := shell.get_node_or_null("WorldMapPanel") as Control
	var map_back_button := shell.get_node_or_null("WorldMapPanel/MapBackButton") as Button
	assert_not_null(map_button)
	assert_not_null(map_panel)
	assert_not_null(map_back_button)
	if map_button == null or map_panel == null or map_back_button == null:
		return

	map_button.pressed.emit()
	assert_true(map_panel.visible)
	assert_false(pause_menu.visible)
	assert_true(bool(shell.call("is_demo_paused")))

	map_back_button.pressed.emit()
	assert_false(map_panel.visible)
	assert_true(pause_menu.visible)
	assert_true(bool(shell.call("is_demo_paused")))


func _spawn_world_map_view() -> Control:
	var script := load(WORLD_MAP_VIEW_SCRIPT_PATH) as Script
	assert_not_null(script, "世界地图视图脚本存在")
	if script == null:
		return null
	var view := script.new() as Control
	add_child_autofree(view)
	return view


func _spawn_main() -> Node2D:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	return main


func _spawn_room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed)
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


func _spawn_player() -> CharacterBody2D:
	var packed := load("res://scenes/player/player_placeholder.tscn") as PackedScene
	assert_not_null(packed)
	var player := packed.instantiate() as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	return player


func _advance_process_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame
