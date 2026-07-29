extends GutTest

# Stage24 回归保护四件 Build 的生产来源、两槽选择、组合效果和会话生命周期。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const STAGE11_ROOM := "res://scenes/rooms/stage11_demo_end_room.tscn"
const CASTER_ROOM := "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"
const STAGE10_CHALLENGE := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const BUILD_IDS: Array[StringName] = [
	&"marsh_relic",
	&"warden_sigil",
	&"caster_core",
	&"guardian_core",
]


func after_each() -> void:
	get_tree().paused = false
	if InputMap.has_action("pause"):
		Input.action_release("pause")


func test_four_builds_unlock_from_existing_routes_caster_bounty_and_boss() -> void:
	var main := await _spawn_started_main()
	main.call("collect_exploration_reward", &"marsh_relic")
	main.call("collect_exploration_reward", &"warden_sigil")
	await _turn_in_caster_bounty(main)
	main.call("mark_stage15_boss_defeated")

	if not main.has_method("get_build_loadout_snapshot"):
		assert_true(false, "Main 需要两槽 Build 快照")
		return
	var snapshot: Dictionary = main.call("get_build_loadout_snapshot")
	assert_eq(int(snapshot.get("available_count", 0)), 4)
	assert_eq(int(snapshot.get("equipped_count", 0)), 2)
	assert_eq(int(snapshot.get("slot_limit", 0)), 2)
	for build_id: StringName in BUILD_IDS:
		assert_true(_entry_ids(snapshot).has(build_id))
	assert_true(main.call("has_exploration_reward", &"caster_core"))
	assert_true(main.call("has_exploration_reward", &"guardian_core"))


func test_pause_detail_panel_can_equip_any_two_owned_builds() -> void:
	var main := await _spawn_started_main()
	_unlock_all_builds(main)
	var shell := main.get_node("HUD/DemoShell") as Control
	shell.call("pause_demo")
	var build_button := shell.get_node(
		"PauseMenu/MarginContainer/VBoxContainer/BuildButton"
	) as Button
	build_button.pressed.emit()

	var detail_panel := shell.get_node("DetailPanel") as Control
	var title := shell.get_node(
		"DetailPanel/MarginContainer/VBoxContainer/DetailTitleLabel"
	) as Label
	var build_list := shell.get_node(
		"DetailPanel/MarginContainer/VBoxContainer/BountyScroll/BountyList"
	) as VBoxContainer
	assert_true(detail_panel.visible)
	assert_true(get_tree().paused)
	assert_true(title.text.contains("圣物调谐"))
	assert_eq(build_list.get_child_count(), 4)

	_press_build_button(build_list, &"marsh_relic")
	_press_build_button(build_list, &"caster_core")
	var equipped: Array = main.call("get_equipped_build_ids")
	assert_eq(equipped.size(), 2)
	assert_true(equipped.has(&"warden_sigil"))
	assert_true(equipped.has(&"caster_core"))
	assert_false(equipped.has(&"marsh_relic"))
	shell.call("_close_detail_panel")


func test_slot_limit_requires_unequip_before_third_build() -> void:
	var main := await _spawn_started_main()
	_unlock_all_builds(main)
	if not main.has_method("toggle_build_equipped"):
		assert_true(false, "Main 需要 Build 装备切换入口")
		return

	var full_snapshot: Dictionary = main.call("toggle_build_equipped", &"caster_core")
	assert_eq(int(full_snapshot.get("equipped_count", 0)), 2)
	assert_true(str(full_snapshot.get("status_message", "")).contains("槽位已满"))
	assert_false((full_snapshot.get("equipped_ids", []) as Array).has(&"caster_core"))

	main.call("toggle_build_equipped", &"marsh_relic")
	var replaced: Dictionary = main.call("toggle_build_equipped", &"caster_core")
	assert_eq(int(replaced.get("equipped_count", 0)), 2)
	assert_true((replaced.get("equipped_ids", []) as Array).has(&"caster_core"))


func test_two_equipped_effects_stack_through_existing_player_calculations() -> void:
	var packed := load(PLAYER_SCENE_PATH) as PackedScene
	var player := packed.instantiate() as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	if not player.has_method("set_equipped_build_ids"):
		assert_true(false, "Player 需要两槽 Build 注入入口")
		return

	var base_reach: float = player.attack_hitbox_size.x
	player.call("set_equipped_build_ids", [&"marsh_relic", &"warden_sigil"])
	assert_eq(float(player.call("get_recovery_charge_gain_multiplier")), 1.5)
	assert_eq((player.call("get_effective_attack_hitbox_size") as Vector2).x, base_reach + 16.0)

	player.call("set_equipped_build_ids", [&"caster_core", &"guardian_core"])
	assert_almost_eq(float(player.call("get_element_sequence_window_duration")), 2.75, 0.001)
	assert_almost_eq(float(player.call("get_stance_switch_cooldown_duration")), 0.2, 0.001)
	player.call("_start_attack")
	var sequence: Dictionary = player.call("get_element_sequence_snapshot")
	assert_almost_eq(float(sequence.get("window_duration", 0.0)), 2.75, 0.001)


func test_two_slot_loadout_survives_room_change_and_restart_clears_session() -> void:
	var main := await _spawn_started_main()
	_unlock_all_builds(main)
	main.call("toggle_build_equipped", &"marsh_relic")
	main.call("toggle_build_equipped", &"caster_core")
	main.call("toggle_build_equipped", &"warden_sigil")
	main.call("toggle_build_equipped", &"guardian_core")
	assert_eq(main.call("get_equipped_build_ids"), [&"caster_core", &"guardian_core"])

	main.call("transition_to_room", STAGE10_CHALLENGE, &"stage10_challenge_start")
	await get_tree().process_frame
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_eq(player.call("get_equipped_build_ids"), [&"caster_core", &"guardian_core"])

	main.call("restart_demo")
	var reset: Dictionary = main.call("get_build_loadout_snapshot")
	assert_eq(int(reset.get("available_count", -1)), 0)
	assert_eq(int(reset.get("equipped_count", -1)), 0)
	assert_eq(main.call("get_active_build_id"), StringName())


func _turn_in_caster_bounty(main: Node2D) -> void:
	main.call("transition_to_room", STAGE11_ROOM, &"stage11_demo_end_start")
	await get_tree().process_frame
	main.call("advance_bounty", &"caster_hunt")
	main.call("transition_to_room", CASTER_ROOM, &"stage13_caster_start")
	await get_tree().process_frame
	main.get_node("Room/MiasmaCasterEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	main.call("transition_to_room", STAGE11_ROOM, &"stage11_demo_end_return")
	await get_tree().process_frame
	main.call("advance_bounty", &"caster_hunt")


func _unlock_all_builds(main: Node2D) -> void:
	for build_id: StringName in BUILD_IDS:
		main.call("collect_exploration_reward", build_id)


func _entry_ids(snapshot: Dictionary) -> Array:
	var ids: Array = []
	for entry: Dictionary in snapshot.get("entries", []):
		ids.append(entry.get("id", StringName()))
	return ids


func _press_build_button(build_list: VBoxContainer, build_id: StringName) -> void:
	for child: Node in build_list.get_children():
		if child.get_meta("build_id", StringName()) == build_id:
			(child as Button).pressed.emit()
			return
	assert_true(false, "缺少 Build 按钮：%s" % build_id)


func _spawn_started_main() -> Node2D:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	(main.get_node("HUD/DemoShell") as Control).call("start_demo")
	return main
