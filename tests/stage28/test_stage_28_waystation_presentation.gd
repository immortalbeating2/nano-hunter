extends GutTest

# Stage28 回归保护正式驿站显示层、稳定图标状态、两槽视图与三段事件去重。

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const STAGE11_SCENE := preload("res://scenes/rooms/stage11_demo_end_room.tscn")
const STAGE11_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const BOUNTY_IDS: Array[StringName] = [
	&"caster_hunt",
	&"demon_bone_evidence",
	&"seal_pulse_cleanup",
]
const BUILD_IDS: Array[StringName] = [
	&"marsh_relic",
	&"warden_sigil",
	&"caster_core",
	&"guardian_core",
]


func after_each() -> void:
	get_tree().paused = false


func test_stage11_uses_formal_waystation_art_without_replacing_room_contracts() -> void:
	var room := STAGE11_SCENE.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	var background := room.get_node("DemoBackgroundArt") as Sprite2D
	var board := room.get_node("BountyBoardZone/BountyBoardMarkerArt") as Sprite2D
	var clerk := room.get_node("WaystationClerk") as AnimatedSprite2D
	var route := room.get_node("ThunderRouteZone/ThunderRouteMarkerArt") as Sprite2D

	assert_true(background.texture.resource_path.ends_with("stage28_waystation_background_runtime_ai01.png"))
	assert_true((board.texture as AtlasTexture).atlas.resource_path.ends_with("stage28_waystation_world_runtime_ai01.png"))
	assert_eq(clerk.sprite_frames.get_frame_count(&"clerk_idle"), 4)
	assert_true(clerk.is_playing())
	assert_true((route.texture as AtlasTexture).atlas.resource_path.ends_with("stage28_waystation_world_runtime_ai01.png"))
	assert_not_null(room.get_node("ReplayZone/CollisionShape2D").shape)
	assert_not_null(room.get_node("BountyBoardZone/CollisionShape2D").shape)
	assert_true(room.has_signal("room_transition_requested"))
	assert_true(room.has_signal("checkpoint_requested"))


func test_bounty_and_build_snapshots_expose_stable_icons_states_and_two_slots() -> void:
	var main := await _spawn_main()
	var bounty_snapshot: Dictionary = main.call("get_bounty_board_snapshot")
	assert_eq((bounty_snapshot.get("entries", []) as Array).size(), 3)
	for entry: Dictionary in bounty_snapshot.get("entries", []):
		assert_ne(StringName(entry.get("icon_id", &"")), StringName())
		assert_eq(entry.get("state_id"), entry.get("state"))

	for build_id: StringName in BUILD_IDS:
		main.call("collect_exploration_reward", build_id)
	var build_snapshot: Dictionary = main.call("get_build_loadout_snapshot")
	assert_eq((build_snapshot.get("entries", []) as Array).size(), 4)
	assert_eq((build_snapshot.get("slots", []) as Array).size(), 2)
	for entry: Dictionary in build_snapshot.get("entries", []):
		assert_ne(StringName(entry.get("icon_id", &"")), StringName())
		assert_true(StringName(entry.get("state_id", &"")) in [&"available", &"equipped"])
	main.call("toggle_build_equipped", &"marsh_relic")
	build_snapshot = main.call("get_build_loadout_snapshot")
	var slots := build_snapshot.get("slots", []) as Array
	assert_eq((slots[1] as Dictionary).get("state_id"), &"empty")


func test_detail_panel_reuses_one_focus_path_with_icons_and_slot_state() -> void:
	var main := await _spawn_main()
	main.call("transition_to_room", STAGE11_PATH, &"stage11_demo_end_start")
	await get_tree().process_frame
	main.call("open_bounty_board")
	var shell := main.get_node("HUD/DemoShell") as Control
	var bounty_list := shell.get_node("DetailPanel/MarginContainer/VBoxContainer/BountyScroll/BountyList") as VBoxContainer
	var context_icon := shell.get_node("DetailPanel/MarginContainer/VBoxContainer/WaystationContextIcon") as TextureRect
	assert_true(context_icon.visible)
	assert_eq(bounty_list.get_child_count(), 3)
	for node: Node in bounty_list.get_children():
		var child := node as Button
		assert_not_null(child.icon)
		assert_ne(StringName(child.get_meta("icon_id", &"")), StringName())
	var first_bounty := bounty_list.get_child(0) as Button
	var second_bounty := bounty_list.get_child(1) as Button
	assert_eq(first_bounty.focus_neighbor_bottom, first_bounty.get_path_to(second_bounty))
	(shell.get_node("DetailPanel/MarginContainer/VBoxContainer/DetailBackButton") as Button).pressed.emit()

	for build_id: StringName in BUILD_IDS:
		main.call("collect_exploration_reward", build_id)
	main.call("open_build_loadout")
	await get_tree().process_frame
	var slot_row := shell.get_node("DetailPanel/MarginContainer/VBoxContainer/BuildSlotRow") as HBoxContainer
	assert_true(slot_row.visible)
	assert_eq(slot_row.get_child_count(), 2)
	assert_eq(bounty_list.get_child_count(), 4)
	for node: Node in bounty_list.get_children():
		var child := node as Button
		assert_not_null(child.icon)
		assert_ne(StringName(child.get_meta("state_id", &"")), StringName())
	var first_build := bounty_list.get_child(0) as Button
	var second_build := bounty_list.get_child(1) as Button
	assert_eq(first_build.focus_neighbor_bottom, first_build.get_path_to(second_build))
	(shell.get_node("DetailPanel/MarginContainer/VBoxContainer/DetailBackButton") as Button).pressed.emit()
	await get_tree().process_frame


func test_all_bounties_and_thunder_return_events_are_deferred_and_deduplicated() -> void:
	var main := await _spawn_main()
	main.call("transition_to_room", STAGE11_PATH, &"stage11_demo_end_start")
	await get_tree().process_frame
	for bounty_id: StringName in BOUNTY_IDS:
		main.call("advance_bounty", bounty_id)
		main.call("_complete_bounty", bounty_id)
		main.call("advance_bounty", bounty_id)
	await get_tree().process_frame
	var snapshot: Dictionary = main.call("get_demo_progress_snapshot")
	assert_true(bool(snapshot.get("stage28_all_bounties_story_completed", false)))
	assert_eq(int(snapshot.get("story_event_count", 0)), 1)

	var back := main.get_node("HUD/DemoShell/DetailPanel/MarginContainer/VBoxContainer/DetailBackButton") as Button
	back.pressed.emit()
	main.call("transition_to_room", STAGE11_PATH, &"stage11_thunder_waste_return")
	await get_tree().process_frame
	snapshot = main.call("get_demo_progress_snapshot")
	assert_true(bool(snapshot.get("stage28_thunder_return_story_completed", false)))
	assert_eq(int(snapshot.get("story_event_count", 0)), 2)
	back.pressed.emit()
	main.call("transition_to_room", STAGE11_PATH, &"stage11_thunder_waste_return")
	await get_tree().process_frame
	assert_eq(int((main.call("get_demo_progress_snapshot") as Dictionary).get("story_event_count", 0)), 2)


func _spawn_main() -> Node2D:
	var main := MAIN_SCENE.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	return main
