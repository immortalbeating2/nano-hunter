extends GutTest

# Stage31 回归保护单档白名单、备份恢复、Continue 与两处驿站传送门控。

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const TUTORIAL_ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const STAGE11_ROOM_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const STAGE25_ENTRY_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_entry_room.tscn"

var _save_path := ""
var _backup_path := ""


func before_each() -> void:
	var suffix := "%d_%d" % [Time.get_ticks_usec(), randi()]
	_save_path = "user://stage31_test_%s.json" % suffix
	_backup_path = "user://stage31_test_%s.backup.json" % suffix
	_cleanup_files()


func after_each() -> void:
	get_tree().paused = false
	_cleanup_files()
	for action_name: StringName in [&"ui_accept", &"ui_cancel", &"pause"]:
		if InputMap.has_action(action_name):
			Input.action_release(action_name)


func test_save_validation_is_whitelisted_and_atomic() -> void:
	var main := await _spawn_main()
	assert_true(bool(main.call("set_save_paths_for_testing", _save_path, _backup_path)))
	main.call("start_new_game")
	main.call("unlock_air_dash")
	main.call("collect_exploration_reward", &"marsh_relic")
	main.call("toggle_build_equipped", &"marsh_relic")

	var candidate := (main.call("build_save_snapshot") as Dictionary).duplicate(true)
	(candidate.get("progress") as Dictionary).get("exploration_reward_ids").append("unknown_reward")
	(candidate.get("progress") as Dictionary).get("equipped_build_ids").append("unknown_build")
	(candidate.get("travel_point_ids") as Array).append("unknown_station")
	candidate["future_field"] = "ignored"
	var applied := main.call("apply_save_snapshot", candidate) as Dictionary
	assert_true(bool(applied.get("ok", false)))
	var normalized := applied.get("snapshot") as Dictionary
	assert_false(normalized.has("future_field"))
	assert_false("unknown_reward" in ((normalized.get("progress") as Dictionary).get("exploration_reward_ids") as Array))
	assert_false("unknown_build" in ((normalized.get("progress") as Dictionary).get("equipped_build_ids") as Array))
	assert_false("unknown_station" in (normalized.get("travel_point_ids") as Array))

	var stable := (main.call("build_save_snapshot") as Dictionary).duplicate(true)
	var wrong_type := stable.duplicate(true)
	(wrong_type.get("progress") as Dictionary)["air_dash_unlocked"] = "true"
	assert_false(bool((main.call("apply_save_snapshot", wrong_type) as Dictionary).get("ok", true)))
	var unsupported := stable.duplicate(true)
	unsupported["version"] = 2
	assert_eq((main.call("apply_save_snapshot", unsupported) as Dictionary).get("code"), &"unsupported_version")
	var unsafe := stable.duplicate(true)
	(unsafe.get("checkpoint") as Dictionary)["room_path"] = "res://../outside.tscn"
	assert_eq((main.call("apply_save_snapshot", unsafe) as Dictionary).get("code"), &"unsafe_checkpoint")
	assert_eq(main.call("build_save_snapshot"), stable, "无效档不得应用半份状态。")
	assert_false(bool(main.call("set_save_paths_for_testing", "user://../unsafe.json", _backup_path)))


func test_save_backup_continue_and_ui_survive_a_new_main_instance() -> void:
	var main := await _spawn_main()
	assert_true(bool(main.call("set_save_paths_for_testing", _save_path, _backup_path)))
	main.call("start_new_game")
	main.call("unlock_air_dash")
	main.call("unlock_wind_seal")
	main.call("collect_exploration_reward", &"marsh_relic")
	main.call("collect_stage14_backtrack_reward", &"stage14_reward_one")
	main.call("collect_stage14_backtrack_reward", &"stage14_reward_two")
	main.call("collect_stage14_backtrack_reward", &"stage14_reward_three")
	main.call("_on_player_stance_changed", &"ward")
	main.call("transition_to_room", STAGE11_ROOM_PATH, &"stage11_demo_end_start")
	await get_tree().process_frame
	main.call("advance_bounty", &"caster_hunt")
	main.call("_complete_bounty", &"caster_hunt")
	main.call("advance_bounty", &"caster_hunt")
	main.call("mark_stage15_boss_defeated")
	main.call("mark_stage30_boss_defeated")
	assert_true(FileAccess.file_exists(_save_path))
	assert_true(FileAccess.file_exists(_backup_path))
	main.queue_free()
	await get_tree().process_frame

	var loaded := await _spawn_main()
	assert_true(bool(loaded.call("set_save_paths_for_testing", _save_path, _backup_path)))
	var shell := loaded.get_node("HUD/DemoShell") as Control
	shell.call("refresh_save_state")
	var continue_button := shell.get_node("MainMenu/MarginContainer/VBoxContainer/ContinueButton") as Button
	assert_false(continue_button.disabled)
	assert_not_null(continue_button.icon)
	shell.call("_on_continue_pressed")
	await get_tree().process_frame
	var progress := loaded.call("get_demo_progress_snapshot") as Dictionary
	assert_true(bool(progress.get("air_dash_unlocked")))
	assert_true(bool(progress.get("wind_seal_unlocked")))
	assert_true(bool(progress.get("thunder_absorption_unlocked")))
	assert_true(bool(progress.get("stage15_boss_defeated")))
	assert_true(bool(progress.get("stage30_boss_defeated")))
	assert_true(bool(progress.get("stage30_demon_resonance_story_completed")))
	assert_eq(progress.get("current_element_id"), &"wind")
	assert_eq(progress.get("current_stance_id"), &"ward")
	assert_eq(int(progress.get("stage14_backtrack_reward_count")), 3)
	assert_eq(int(progress.get("bounty_turned_in_count")), 1)
	assert_eq(progress.get("active_build_id"), &"marsh_relic")
	var restored_save := loaded.call("build_save_snapshot") as Dictionary
	var restored_progress := restored_save.get("progress") as Dictionary
	assert_has(restored_progress.get("exploration_reward_ids") as Array, "caster_core")
	assert_has(restored_progress.get("exploration_reward_ids") as Array, "guardian_core")
	assert_has(restored_progress.get("exploration_reward_ids") as Array, "thunder_beast_core")
	assert_eq((loaded.call("get_world_map_snapshot") as Dictionary).get("current_room_path"), STAGE11_ROOM_PATH)
	assert_false((shell.get_node("MainMenu") as Control).visible)


func test_corrupt_primary_falls_back_to_backup_and_corrupt_only_can_start_new() -> void:
	var main := await _spawn_main()
	assert_true(bool(main.call("set_save_paths_for_testing", _save_path, _backup_path)))
	main.call("start_new_game")
	main.call("unlock_air_dash")
	main.queue_free()
	await get_tree().process_frame
	_write_text(_save_path, "{broken")

	var fallback := await _spawn_main()
	assert_true(bool(fallback.call("set_save_paths_for_testing", _save_path, _backup_path)))
	var status := fallback.call("get_save_status_snapshot") as Dictionary
	assert_true(bool(status.get("valid")))
	assert_true(bool(status.get("from_backup")))
	var continued := fallback.call("continue_saved_game") as Dictionary
	await get_tree().process_frame
	assert_eq(continued.get("code"), &"continued_from_backup")
	assert_false(bool((fallback.call("get_demo_progress_snapshot") as Dictionary).get("air_dash_unlocked")))
	fallback.queue_free()
	await get_tree().process_frame
	_write_text(_save_path, JSON.stringify({"version": 99}))
	_write_text(_backup_path, "not-json")

	var corrupt_only := await _spawn_main()
	assert_true(bool(corrupt_only.call("set_save_paths_for_testing", _save_path, _backup_path)))
	status = corrupt_only.call("get_save_status_snapshot") as Dictionary
	assert_false(bool(status.get("valid")))
	assert_true(bool(status.get("corrupted_primary")))
	var shell := corrupt_only.get_node("HUD/DemoShell") as Control
	shell.call("refresh_save_state")
	assert_true((shell.get_node("MainMenu/MarginContainer/VBoxContainer/ContinueButton") as Button).disabled)
	assert_string_contains((shell.get_node("MainMenu/MarginContainer/VBoxContainer/StatusLabel") as Label).text, "存档损坏")
	assert_true(bool((corrupt_only.call("start_new_game") as Dictionary).get("ok")))
	assert_true(bool((corrupt_only.call("get_save_status_snapshot") as Dictionary).get("valid")))


func test_backup_write_failure_preserves_primary_and_keeps_session_playable() -> void:
	var main := await _spawn_main()
	assert_true(bool(main.call("set_save_paths_for_testing", _save_path, _backup_path)))
	main.call("start_new_game")
	var primary_before := _read_text(_save_path)
	var missing_backup := "user://stage31_missing_%d/backup.json" % Time.get_ticks_usec()
	assert_true(bool(main.call("set_save_paths_for_testing", _save_path, missing_backup)))
	main.call("unlock_air_dash")
	var progress := main.call("get_demo_progress_snapshot") as Dictionary
	assert_true(bool(progress.get("air_dash_unlocked")), "保存失败不能中断当前会话。")
	assert_eq(progress.get("last_save_code"), &"backup_failed")
	assert_eq(_read_text(_save_path), primary_before, "backup 失败时保留上一有效主档。")


func test_two_point_travel_is_discovery_gated_and_controller_accessible() -> void:
	var main := await _spawn_main()
	assert_true(bool(main.call("set_save_paths_for_testing", _save_path, _backup_path)))
	var shell := main.get_node("HUD/DemoShell") as Control
	shell.call("_on_start_pressed")
	await get_tree().process_frame
	main.call("transition_to_room", STAGE11_ROOM_PATH, &"stage11_demo_end_start")
	await get_tree().process_frame
	var snapshot := main.call("get_waystation_travel_snapshot") as Dictionary
	assert_eq(snapshot.get("current_travel_point_id"), &"waystation_main")
	assert_eq(int(snapshot.get("discovered_count")), 1)
	assert_eq(_find_travel_entry(snapshot, &"thunder_outpost").get("state_id"), &"locked")
	var primary_before := _read_text(_save_path)
	var blocked := main.call("request_waystation_travel", &"thunder_outpost") as Dictionary
	assert_eq(blocked.get("code"), &"undiscovered")
	assert_eq((main.call("get_world_map_snapshot") as Dictionary).get("current_room_path"), STAGE11_ROOM_PATH)
	assert_eq(_read_text(_save_path), primary_before, "门控失败不得改档。")

	main.call("transition_to_room", STAGE25_ENTRY_ROOM_PATH, &"stage25_entry_start")
	main.call("transition_to_room", STAGE11_ROOM_PATH, &"stage11_demo_end_start")
	main.call("transition_to_room", STAGE25_ENTRY_ROOM_PATH, &"stage25_entry_start")
	await get_tree().process_frame
	assert_eq(
		((main.call("build_save_snapshot") as Dictionary).get("checkpoint") as Dictionary).get("room_path"),
		STAGE25_ENTRY_ROOM_PATH,
		"连续切房后旧房间不得延迟覆盖最新 checkpoint。",
	)
	assert_true(bool((main.call("request_waystation_travel", &"waystation_main") as Dictionary).get("ok")))
	await get_tree().process_frame
	assert_eq((main.call("get_demo_progress_snapshot") as Dictionary).get("current_travel_point_id"), &"waystation_main")

	main.call("pause_demo")
	await _advance_frames(2)
	var travel_button := shell.get_node("PauseMenu/MarginContainer/VBoxContainer/TravelButton") as Button
	assert_false(travel_button.disabled)
	assert_not_null(travel_button.icon)
	await _send_joy_button(JOY_BUTTON_DPAD_DOWN)
	await _send_joy_button(JOY_BUTTON_DPAD_DOWN)
	assert_same(shell.get_viewport().gui_get_focus_owner(), travel_button)
	await _send_joy_button(JOY_BUTTON_A)
	await _advance_frames(2)
	assert_true((shell.get_node("DetailPanel") as Control).visible)
	var travel_list := shell.get_node("DetailPanel/MarginContainer/VBoxContainer/BountyScroll/BountyList") as VBoxContainer
	assert_eq(travel_list.get_child_count(), 2)
	var travel_focus := shell.get_viewport().gui_get_focus_owner() as Button
	assert_eq(travel_focus.text, "传送 · 雷泽前哨")
	await _send_joy_button(JOY_BUTTON_B)
	assert_same(shell.get_viewport().gui_get_focus_owner(), travel_button)
	shell.call("_on_travel_entry_pressed", &"thunder_outpost")
	await get_tree().process_frame
	assert_eq((main.call("get_demo_progress_snapshot") as Dictionary).get("current_travel_point_id"), &"thunder_outpost")
	assert_eq((main.call("request_waystation_travel", &"thunder_outpost") as Dictionary).get("code"), &"invalid_target")


func _spawn_main() -> Node2D:
	var main := MAIN_SCENE.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	return main


func _find_travel_entry(snapshot: Dictionary, travel_id: StringName) -> Dictionary:
	for entry: Dictionary in snapshot.get("entries", []):
		if StringName(entry.get("id", StringName())) == travel_id:
			return entry
	return {}


func _write_text(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file)
	if file != null:
		file.store_string(content)


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file)
	return file.get_as_text() if file != null else ""


func _cleanup_files() -> void:
	for path: String in [_save_path, _backup_path, _save_path + ".tmp", _backup_path + ".tmp"]:
		if not path.is_empty() and FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _advance_frames(count: int) -> void:
	for _index: int in range(count):
		await get_tree().process_frame


func _send_joy_button(button_index: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.device = 0
	event.button_index = button_index
	event.pressed = true
	event.pressure = 1.0
	Input.parse_input_event(event)
	await _advance_frames(2)
	event.pressed = false
	event.pressure = 0.0
	Input.parse_input_event(event)
	await _advance_frames(2)
