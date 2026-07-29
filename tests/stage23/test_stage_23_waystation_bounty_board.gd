extends GutTest

# Stage23 回归保护固定悬赏榜的接取、生产事件推进、回交奖励和生命周期边界。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const STAGE11_ROOM := "res://scenes/rooms/stage11_demo_end_room.tscn"
const CASTER_ROOM := "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"
const RESOURCE_ROOM := "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"
const PULSE_ROOM := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const BOUNTY_IDS: Array[StringName] = [
	&"caster_hunt",
	&"demon_bone_evidence",
	&"seal_pulse_cleanup",
]


func after_each() -> void:
	get_tree().paused = false
	if InputMap.has_action("pause"):
		Input.action_release("pause")


func test_stage11_board_opens_three_fixed_entries_and_accepts_selected_bounty() -> void:
	var main := await _spawn_started_main()
	main.call("transition_to_room", STAGE11_ROOM, &"stage11_demo_end_start")
	await get_tree().process_frame
	var room := main.get_node("Room") as Node2D
	var board := room.get_node_or_null("BountyBoardZone") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_not_null(board)
	assert_true(room.has_signal("bounty_board_requested"))
	if board == null:
		return

	player.global_position = board.global_position
	room.call("_process", 0.0)
	var shell := main.get_node("HUD/DemoShell") as Control
	var detail_panel := shell.get_node("DetailPanel") as Control
	var bounty_list := shell.get_node_or_null(
		"DetailPanel/MarginContainer/VBoxContainer/BountyScroll/BountyList"
	) as VBoxContainer
	assert_true(detail_panel.visible)
	assert_true(get_tree().paused)
	assert_not_null(bounty_list)
	if bounty_list == null:
		return
	assert_eq(bounty_list.get_child_count(), 3)

	var first_button := bounty_list.get_child(0) as Button
	assert_true(first_button.text.contains("接取"))
	first_button.pressed.emit()
	var snapshot := _get_bounty_snapshot(main)
	assert_eq(int(snapshot.get("accepted_count", 0)), 1)
	assert_eq(_entry_state(snapshot, &"caster_hunt"), &"accepted")

	var hud := main.get_node("HUD/TutorialHUD") as Control
	hud.call("_process", 0.0)
	var progress_label := hud.get_node("BattlePanel/ProgressLabel") as Label
	assert_true(progress_label.text.contains("悬赏"))
	assert_true(progress_label.text.contains("已接 1/3"))
	_close_detail(shell)


func test_three_existing_world_events_complete_and_turn_in_all_bounties() -> void:
	var main := await _spawn_started_main()
	assert_true(await _accept_all_bounties(main))

	main.call("transition_to_room", CASTER_ROOM, &"stage13_caster_start")
	await get_tree().process_frame
	main.get_node("Room/MiasmaCasterEnemy").call("receive_attack", Vector2.RIGHT, 120.0)

	main.call("transition_to_room", RESOURCE_ROOM, &"stage13_resource_branch_start")
	await get_tree().process_frame
	main.get_node("Room").call("collect_stage13_reward", &"stage13_reward")

	main.call("transition_to_room", PULSE_ROOM, &"stage10_challenge_start")
	await get_tree().process_frame
	var hazard := main.get_node("Room/SealPulseHazard")
	hazard.call(
		"receive_elemental_attack",
		Vector2.RIGHT,
		210.0,
		{"reaction_id": &"thunder_wind_scatter"}
	)

	var completed := _get_bounty_snapshot(main)
	assert_eq(int(completed.get("completed_count", 0)), 3)
	assert_eq(int(completed.get("turned_in_count", 0)), 0)
	for bounty_id: StringName in BOUNTY_IDS:
		assert_eq(_entry_state(completed, bounty_id), &"completed")

	main.call("transition_to_room", STAGE11_ROOM, &"stage11_demo_end_return")
	await get_tree().process_frame
	for bounty_id: StringName in BOUNTY_IDS:
		main.call("advance_bounty", bounty_id)
	var turned_in := _get_bounty_snapshot(main)
	assert_eq(int(turned_in.get("turned_in_count", 0)), 3)
	assert_eq(int(turned_in.get("reward_count", 0)), 3)
	assert_true(bool(turned_in.get("waystation_intel_unlocked", false)))

	main.call("open_bounty_board")
	var detail_body := main.get_node(
		"HUD/DemoShell/DetailPanel/MarginContainer/VBoxContainer/DetailBodyLabel"
	) as Label
	assert_true(detail_body.text.contains("雷泽荒原路引"))
	_close_detail(main.get_node("HUD/DemoShell") as Control)


func test_unfinished_bounty_cannot_be_turned_in() -> void:
	var main := await _spawn_started_main()
	main.call("transition_to_room", STAGE11_ROOM, &"stage11_demo_end_start")
	await get_tree().process_frame
	assert_true(main.has_method("advance_bounty"))
	if not main.has_method("advance_bounty"):
		return

	main.call("advance_bounty", &"caster_hunt")
	main.call("advance_bounty", &"caster_hunt")
	var snapshot := _get_bounty_snapshot(main)
	assert_eq(_entry_state(snapshot, &"caster_hunt"), &"accepted")
	assert_eq(int(snapshot.get("reward_count", 0)), 0)


func test_pause_and_world_map_only_read_bounty_state() -> void:
	var main := await _spawn_started_main()
	main.call("transition_to_room", STAGE11_ROOM, &"stage11_demo_end_start")
	await get_tree().process_frame
	if not main.has_method("advance_bounty"):
		assert_true(false, "Main 需要悬赏推进入口")
		return
	main.call("advance_bounty", &"caster_hunt")
	main.call("advance_bounty", &"seal_pulse_cleanup")
	var before := _get_bounty_snapshot(main)

	main.call("pause_demo")
	var shell := main.get_node("HUD/DemoShell") as Control
	shell.call("_on_map_pressed")
	var world_map_panel := shell.get_node("WorldMapPanel") as Control
	assert_true(world_map_panel.visible)
	assert_true(get_tree().paused)
	var map_snapshot: Dictionary = main.call("get_world_map_snapshot")
	assert_eq(int(map_snapshot.get("bounty_accepted_count", 0)), 2)
	assert_eq(_get_bounty_snapshot(main), before)
	shell.call("_on_map_back_pressed")
	shell.call("_on_resume_pressed")
	assert_false(get_tree().paused)
	assert_eq(_get_bounty_snapshot(main), before)


func test_stage11_completion_stays_independent_and_restart_clears_bounties() -> void:
	var main := await _spawn_started_main()
	main.call("transition_to_room", STAGE11_ROOM, &"stage11_demo_end_start")
	await get_tree().process_frame
	if not main.has_method("advance_bounty"):
		assert_true(false, "Main 需要悬赏推进入口")
		return
	main.call("advance_bounty", &"caster_hunt")
	main.get_node("Room").call("_complete_demo")
	var progress: Dictionary = main.call("get_demo_progress_snapshot")
	assert_true(bool(progress.get("short_chain_completed", false)))
	assert_false(bool(progress.get("demo_completed", true)))
	assert_eq(int(_get_bounty_snapshot(main).get("accepted_count", 0)), 1)
	_close_detail(main.get_node("HUD/DemoShell") as Control)

	main.call("restart_demo")
	var reset_snapshot := _get_bounty_snapshot(main)
	assert_eq(int(reset_snapshot.get("accepted_count", -1)), 0)
	assert_eq(int(reset_snapshot.get("completed_count", -1)), 0)
	assert_eq(int(reset_snapshot.get("turned_in_count", -1)), 0)
	assert_false(bool(reset_snapshot.get("waystation_intel_unlocked", true)))


func _accept_all_bounties(main: Node2D) -> bool:
	main.call("transition_to_room", STAGE11_ROOM, &"stage11_demo_end_start")
	await get_tree().process_frame
	if not main.has_method("advance_bounty"):
		assert_true(false, "Main 需要悬赏推进入口")
		return false
	for bounty_id: StringName in BOUNTY_IDS:
		main.call("advance_bounty", bounty_id)
	return int(_get_bounty_snapshot(main).get("accepted_count", 0)) == 3


func _entry_state(snapshot: Dictionary, bounty_id: StringName) -> StringName:
	for entry: Dictionary in snapshot.get("entries", []):
		if entry.get("id") == bounty_id:
			return entry.get("state", StringName())
	return &""


func _get_bounty_snapshot(main: Node) -> Dictionary:
	if not main.has_method("get_bounty_board_snapshot"):
		return {}
	var snapshot: Variant = main.call("get_bounty_board_snapshot")
	return snapshot if snapshot is Dictionary else {}


func _close_detail(shell: Control) -> void:
	var detail_panel := shell.get_node("DetailPanel") as Control
	if not detail_panel.visible:
		return
	var back_button := shell.get_node(
		"DetailPanel/MarginContainer/VBoxContainer/DetailBackButton"
	) as Button
	back_button.pressed.emit()


func _spawn_started_main() -> Node2D:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	(main.get_node("HUD/DemoShell") as Control).call("start_demo")
	return main
