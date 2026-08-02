extends GutTest

# Stage26 候选回归保护非冲突手柄映射、调试入口、跨阶段生产循环、失败 / 重开边界和交付文档。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const STAGE10_PULSE_ROOM := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const STAGE11_ROOM := "res://scenes/rooms/stage11_demo_end_room.tscn"
const STAGE13_CASTER_ROOM := "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"
const STAGE13_RESOURCE_ROOM := "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"
const STAGE13_CHALLENGE_ROOM := "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn"
const STAGE25_ENTRY_ROOM := "res://scenes/rooms/stage25_thunder_waste_entry_room.tscn"
const STAGE26_QA_PATH := "res://docs/deliverables/stage26-north-star-alpha-candidate/qa-checklist.md"
const STAGE26_RELEASE_PATH := "res://docs/deliverables/stage26-north-star-alpha-candidate/release-notes.md"
const STAGE26_AUDIT_PATH := "res://docs/deliverables/stage26-north-star-alpha-candidate/north-star-completion-audit.md"
const BOUNTY_IDS: Array[StringName] = [
	&"caster_hunt",
	&"demon_bone_evidence",
	&"seal_pulse_cleanup",
]


func after_each() -> void:
	get_tree().paused = false
	for action_name: String in [
		"move_left",
		"move_right",
		"jump",
		"attack",
		"dash",
		"recover",
		"element_switch",
		"stance_switch",
		"pause",
		"ui_accept",
		"ui_cancel",
	]:
		if InputMap.has_action(action_name):
			Input.action_release(action_name)


func test_candidate_controller_map_has_non_conflicting_core_actions() -> void:
	await _spawn_main()

	assert_true(_action_has_joy_button(&"jump", JOY_BUTTON_A))
	assert_true(_action_has_joy_button(&"dash", JOY_BUTTON_B))
	assert_true(_action_has_joy_button(&"attack", JOY_BUTTON_X))
	assert_true(_action_has_joy_button(&"recover", JOY_BUTTON_Y))
	assert_true(_action_has_joy_button(&"element_switch", JOY_BUTTON_LEFT_SHOULDER))
	assert_true(_action_has_joy_button(&"stance_switch", JOY_BUTTON_RIGHT_SHOULDER))
	assert_true(_action_has_joy_button(&"pause", JOY_BUTTON_START))
	assert_false(
		_action_has_joy_button(&"dash", JOY_BUTTON_RIGHT_SHOULDER),
		"RB 只能切换姿态，不能同时触发 Dash。"
	)


func test_controller_can_operate_main_and_pause_menus() -> void:
	var main := await _spawn_main()
	var shell := main.get_node("HUD/DemoShell") as Control
	var viewport := shell.get_viewport()
	var start_button := shell.get_node(
		"MainMenu/MarginContainer/VBoxContainer/StartButton"
	) as Button
	var continue_button := shell.get_node(
		"MainMenu/MarginContainer/VBoxContainer/ContinueButton"
	) as Button
	var level_select_button := shell.get_node(
		"MainMenu/MarginContainer/VBoxContainer/LevelSelectButton"
	) as Button
	var resume_button := shell.get_node(
		"PauseMenu/MarginContainer/VBoxContainer/ResumeButton"
	) as Button
	var map_button := shell.get_node(
		"PauseMenu/MarginContainer/VBoxContainer/MapButton"
	) as Button

	assert_true(_action_has_joy_button(&"ui_accept", JOY_BUTTON_A))
	assert_true(_action_has_joy_button(&"ui_cancel", JOY_BUTTON_B))
	assert_same(viewport.gui_get_focus_owner(), start_button)
	assert_true(continue_button.disabled)

	await _send_joy_button(JOY_BUTTON_DPAD_DOWN)
	assert_same(viewport.gui_get_focus_owner(), level_select_button)
	await _send_joy_button(JOY_BUTTON_A)
	assert_true((shell.get_node("DetailPanel") as Control).visible)
	await _send_joy_button(JOY_BUTTON_B)
	assert_true((shell.get_node("MainMenu") as Control).visible)
	assert_same(viewport.gui_get_focus_owner(), start_button)

	await _send_joy_button(JOY_BUTTON_A)
	assert_false((shell.get_node("MainMenu") as Control).visible)
	await _send_joy_button(JOY_BUTTON_B)
	assert_false(
		(shell.get_node("PauseMenu") as Control).visible,
		"B 在游戏中只负责冲刺，不能同时触发 UI 返回并打开暂停菜单。",
	)
	await _send_joy_button(JOY_BUTTON_START)
	assert_true((shell.get_node("PauseMenu") as Control).visible)
	assert_same(viewport.gui_get_focus_owner(), resume_button)

	await _send_joy_button(JOY_BUTTON_DPAD_DOWN)
	assert_same(viewport.gui_get_focus_owner(), map_button)
	await _send_joy_button(JOY_BUTTON_A)
	assert_true((shell.get_node("WorldMapPanel") as Control).visible)
	await _send_joy_button(JOY_BUTTON_B)
	assert_true((shell.get_node("PauseMenu") as Control).visible)
	assert_same(viewport.gui_get_focus_owner(), map_button)


func test_controls_and_level_select_expose_stage21_and_stage25_candidate_entries() -> void:
	var main := await _spawn_main()
	var shell := main.get_node("HUD/DemoShell") as Control
	shell.call("_on_controls_pressed")
	var detail_body := shell.get_node(
		"DetailPanel/MarginContainer/VBoxContainer/DetailBodyLabel"
	) as Label
	for term: String in ["Q", "E", "LB", "RB", "Menu"]:
		assert_string_contains(detail_body.text, term)

	shell.call("_close_detail_panel")
	shell.call("_open_level_select_panel")
	var level_list := shell.get_node(
		"DetailPanel/MarginContainer/VBoxContainer/LevelSelectScroll/LevelSelectList"
	) as VBoxContainer
	var stage25_labels: Array[String] = []
	for child: Node in level_list.get_children():
		var button := child as Button
		if button != null and button.text.contains("Stage25"):
			stage25_labels.append(button.text)
	assert_eq(stage25_labels.size(), 6)


func test_stage21_to_stage25_loop_reaches_candidate_state_and_survives_checkpoint_failure() -> void:
	var main := await _spawn_started_main()
	main.call("unlock_wind_seal")
	main.call("unlock_air_dash")
	for reward_index: int in range(3):
		main.call("collect_stage14_backtrack_reward", StringName("stage26_reward_%d" % reward_index))

	main.call("transition_to_room", STAGE11_ROOM, &"stage11_demo_end_start")
	await _advance_frames(2)
	for bounty_id: StringName in BOUNTY_IDS:
		main.call("advance_bounty", bounty_id)

	main.call("transition_to_room", STAGE13_CASTER_ROOM, &"stage13_caster_start")
	await _advance_frames(2)
	main.get_node("Room/MiasmaCasterEnemy").call("receive_attack", Vector2.RIGHT, 120.0)

	main.call("transition_to_room", STAGE13_RESOURCE_ROOM, &"stage13_resource_branch_start")
	await _advance_frames(2)
	main.get_node("Room").call("collect_stage13_reward", &"stage26_resource_reward")

	main.call("transition_to_room", STAGE10_PULSE_ROOM, &"stage10_challenge_start")
	await _advance_frames(2)
	main.get_node("Room/SealPulseHazard").call(
		"receive_elemental_attack",
		Vector2.RIGHT,
		210.0,
		{"reaction_id": &"thunder_wind_scatter"}
	)

	main.call("transition_to_room", STAGE13_CHALLENGE_ROOM, &"stage13_challenge_branch_start")
	await _advance_frames(2)
	main.get_node("Room").call("collect_stage13_reward", &"stage26_challenge_reward")

	main.call("transition_to_room", STAGE11_ROOM, &"stage11_demo_end_return")
	await _advance_frames(2)
	for bounty_id: StringName in BOUNTY_IDS:
		main.call("advance_bounty", bounty_id)
	var bounty_snapshot: Dictionary = main.call("get_bounty_board_snapshot")
	assert_eq(int(bounty_snapshot.get("turned_in_count", 0)), 3)
	assert_true(bool(bounty_snapshot.get("waystation_intel_unlocked", false)))
	await _advance_frames(1)
	_close_detail_panel(main)

	main.call("mark_stage15_boss_defeated")
	main.call("toggle_build_equipped", &"marsh_relic")
	main.call("toggle_build_equipped", &"warden_sigil")
	main.call("toggle_build_equipped", &"caster_core")
	main.call("toggle_build_equipped", &"guardian_core")
	assert_eq(main.call("get_equipped_build_ids"), [&"caster_core", &"guardian_core"])

	var waystation := main.get_node("Room") as Node2D
	waystation.call("_complete_demo")
	_close_detail_panel(main)
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = (waystation.get_node("ThunderRouteZone") as Node2D).global_position
	await _advance_frames(3)
	assert_eq((main.get_node("Room") as Node2D).scene_file_path, STAGE25_ENTRY_ROOM)
	assert_eq(
		(main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D).call("get_equipped_build_ids"),
		[&"caster_core", &"guardian_core"]
	)

	var shell := main.get_node("HUD/DemoShell") as Control
	main.call("pause_demo")
	shell.call("_on_map_pressed")
	assert_true((shell.get_node("WorldMapPanel") as Control).visible)
	assert_string_contains(
		(shell.get_node("WorldMapPanel/CurrentRoomLabel") as Label).text,
		"/ 44",
		"候选地图计数必须来自当前 44 房布局，不能保留旧阶段硬编码。",
	)
	shell.call("_on_map_back_pressed")
	shell.call("_on_build_pressed")
	assert_true((shell.get_node("DetailPanel") as Control).visible)
	shell.call("_close_detail_panel")
	shell.call("_on_resume_pressed")

	var failure_player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	failure_player.call("receive_damage", 99, Vector2.UP)
	await _advance_frames(3)
	assert_eq((main.get_node("Room") as Node2D).scene_file_path, STAGE25_ENTRY_ROOM)
	assert_eq(int(main.call("get_bounty_board_snapshot").get("turned_in_count", 0)), 3)
	assert_eq(main.call("get_equipped_build_ids"), [&"caster_core", &"guardian_core"])
	assert_true((shell.get_node("FailurePanel") as Control).visible)
	shell.call("_on_failure_continue_pressed")

	main.call("mark_stage16_alpha_demo_completed")
	var candidate_snapshot: Dictionary = main.call("get_demo_progress_snapshot")
	assert_true(bool(candidate_snapshot.get("stage16_alpha_demo_completed", false)))
	assert_true(bool(candidate_snapshot.get("stage16_release_notes_ready", false)))
	assert_true(bool(candidate_snapshot.get("stage16_qa_checklist_ready", false)))


func test_restart_clears_session_progress_but_keeps_static_candidate_docs_ready() -> void:
	var main := await _spawn_started_main()
	main.call("unlock_wind_seal")
	main.call("unlock_air_dash")
	main.call("collect_exploration_reward", &"marsh_relic")
	main.call("mark_stage15_boss_defeated")
	main.call("mark_stage16_alpha_demo_completed")

	main.call("restart_demo")
	await _advance_frames(2)
	var snapshot: Dictionary = main.call("get_demo_progress_snapshot")
	assert_false(bool(snapshot.get("air_dash_unlocked", true)))
	assert_false(bool(snapshot.get("wind_seal_unlocked", true)))
	assert_eq(int(snapshot.get("bounty_accepted_count", -1)), 0)
	assert_eq(int(snapshot.get("equipped_build_count", -1)), 0)
	assert_false(bool(snapshot.get("stage16_alpha_demo_completed", true)))
	assert_true(bool(snapshot.get("stage16_release_notes_ready", false)))
	assert_true(bool(snapshot.get("stage16_qa_checklist_ready", false)))
	assert_eq((main.get_node("Room") as Node2D).scene_file_path, "res://scenes/rooms/tutorial_room.tscn")


func test_candidate_documents_cover_scope_persistence_audio_and_manual_gates() -> void:
	for path: String in [STAGE26_QA_PATH, STAGE26_RELEASE_PATH, STAGE26_AUDIT_PATH]:
		assert_true(FileAccess.file_exists(path), "缺少候选交付文档：%s" % path)

	var qa_text := _read_text(STAGE26_QA_PATH)
	for term: String in ["input-only", "synthetic Joypad", "实体手柄", "真人", "失败恢复"]:
		assert_string_contains(qa_text, term)

	var release_text := _read_text(STAGE26_RELEASE_PATH)
	for term: String in ["44", "2 元素", "2 姿态", "3 条固定悬赏", "4 件", "6 房", "不支持跨进程继续"]:
		assert_string_contains(release_text, term)

	var audit_text := _read_text(STAGE26_AUDIT_PATH)
	for term: String in ["P0", "P1", "音效", "单次会话", "商业版扩展", "待外部人工验收"]:
		assert_string_contains(audit_text, term)


func _spawn_main() -> Node2D:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	await _advance_frames(2)
	return main


func _spawn_started_main() -> Node2D:
	var main := await _spawn_main()
	(main.get_node("HUD/DemoShell") as Control).call("start_demo")
	await _advance_frames(2)
	return main


func _advance_frames(count: int) -> void:
	for _index: int in range(count):
		await get_tree().process_frame


func _action_has_joy_button(action_name: StringName, button_index: JoyButton) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		var joy_button := event as InputEventJoypadButton
		if joy_button != null and joy_button.button_index == button_index:
			return true
	return false


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


func _close_detail_panel(main: Node) -> void:
	var shell := main.get_node("HUD/DemoShell") as Control
	if (shell.get_node("DetailPanel") as Control).visible:
		shell.call("_close_detail_panel")


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	return file.get_as_text() if file != null else ""
