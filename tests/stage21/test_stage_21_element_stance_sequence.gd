extends GutTest

# Stage21 回归保护风雷元素、疾御姿态、两步序列窗口、跨房状态与 HUD 快照。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const COMBAT_ROOM := "res://scenes/rooms/combat_trial_room.tscn"
const STAGE10_CHALLENGE := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const STAGE13_CASTER := "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"


func after_each() -> void:
	get_tree().paused = false
	for action_name: StringName in [&"element_switch", &"stance_switch", &"attack"]:
		if InputMap.has_action(action_name):
			Input.action_release(action_name)


func test_element_and_stance_inputs_respect_wind_seal_unlock() -> void:
	var main := await _spawn_main()
	assert_true(InputMap.has_action("element_switch"))
	assert_true(InputMap.has_action("stance_switch"))
	assert_false(InputMap.action_get_events("element_switch").is_empty())
	assert_false(InputMap.action_get_events("stance_switch").is_empty())

	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	var snapshot: Dictionary = main.call("get_demo_progress_snapshot")
	assert_eq(snapshot.get("current_element_id"), &"thunder")
	assert_eq(snapshot.get("current_stance_id"), &"swift")
	assert_eq(player.call("cycle_current_element"), &"thunder", "风印前不能切到风元素")

	main.call("unlock_wind_seal")
	assert_eq(player.call("get_current_element_id"), &"wind")
	assert_eq(player.call("cycle_current_element"), &"thunder")
	assert_eq(player.call("cycle_current_stance"), &"ward")
	snapshot = main.call("get_demo_progress_snapshot")
	assert_eq(snapshot.get("current_element_id"), &"thunder")
	assert_eq(snapshot.get("current_stance_id"), &"ward")


func test_two_element_orders_produce_distinct_attack_shapes_and_knockback() -> void:
	var player := await _spawn_player()
	player.call("set_wind_seal_unlocked", true)
	var base_size: Vector2 = player.attack_hitbox_size
	var base_knockback: float = player.attack_knockback_force

	_perform_element_step(player, &"wind", true)
	player.call("set_current_element_id", &"thunder")
	player.call("_start_attack")
	var chase: Dictionary = player.call("get_element_sequence_snapshot")
	assert_eq(chase.get("reaction_id"), &"wind_thunder_pierce")
	assert_eq((player.call("get_effective_attack_hitbox_size") as Vector2).x, base_size.x + 24.0)
	assert_eq(float(player.call("get_effective_attack_knockback_force")), base_knockback)
	player.call("_finish_attack")

	player.call("clear_element_sequence")
	_perform_element_step(player, &"thunder", true)
	player.call("set_current_element_id", &"wind")
	player.call("_start_attack")
	var repel: Dictionary = player.call("get_element_sequence_snapshot")
	assert_eq(repel.get("reaction_id"), &"thunder_wind_scatter")
	assert_eq((player.call("get_effective_attack_hitbox_size") as Vector2).y, base_size.y + 16.0)
	assert_almost_eq(
		float(player.call("get_effective_attack_knockback_force")),
		base_knockback * 1.75,
		0.001
	)
	player.call("_finish_attack")

	player.call("clear_element_sequence")
	player.call("set_current_stance_id", &"ward")
	assert_eq((player.call("get_effective_attack_hitbox_size") as Vector2).y, base_size.y + 8.0)
	assert_almost_eq(
		float(player.call("get_effective_attack_knockback_force")),
		base_knockback * 1.15,
		0.001
	)


func test_sequence_window_expires_and_clears_reaction() -> void:
	var player := await _spawn_player()
	player.call("set_wind_seal_unlocked", true)
	player.call("_start_attack")
	player.call("_finish_attack")
	var active: Dictionary = player.call("get_element_sequence_snapshot")
	assert_eq((active.get("element_ids", []) as Array).size(), 1)
	assert_gt(float(active.get("window_remaining", 0.0)), 0.0)

	player.call("_update_element_sequence", 2.1)
	var expired: Dictionary = player.call("get_element_sequence_snapshot")
	assert_true((expired.get("element_ids", []) as Array).is_empty())
	assert_eq(float(expired.get("window_remaining", -1.0)), 0.0)
	assert_eq(expired.get("reaction_id"), StringName())


func test_element_and_stance_persist_across_three_combat_rooms_but_sequence_resets() -> void:
	var main := await _spawn_main()
	var shell := main.get_node("HUD/DemoShell") as Control
	shell.call("start_demo")
	main.call("unlock_wind_seal")
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.call("set_current_stance_id", &"ward")

	for room_entry: Dictionary in [
		{"path": COMBAT_ROOM, "spawn": &"combat_start"},
		{"path": STAGE10_CHALLENGE, "spawn": &"stage10_challenge_start"},
		{"path": STAGE13_CASTER, "spawn": &"stage13_caster_start"},
	]:
		main.call("transition_to_room", room_entry.path, room_entry.spawn)
		await get_tree().process_frame
		player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
		assert_eq(player.call("get_current_stance_id"), &"ward")
		assert_true((player.call("get_element_sequence_snapshot") as Dictionary).get("element_ids", []).is_empty())

		player.call("set_current_element_id", &"wind")
		_perform_element_step(player, &"wind", true)
		player.call("set_current_element_id", &"thunder")
		player.call("_start_attack")
		assert_eq(
			(player.call("get_element_sequence_snapshot") as Dictionary).get("reaction_id"),
			&"wind_thunder_pierce"
		)
		player.call("_finish_attack")

	main.call("restart_demo")
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_eq(player.call("get_current_element_id"), &"thunder")
	assert_eq(player.call("get_current_stance_id"), &"swift")
	assert_true((player.call("get_element_sequence_snapshot") as Dictionary).get("element_ids", []).is_empty())


func test_hud_displays_element_stance_sequence_and_window() -> void:
	var main := await _spawn_main()
	var shell := main.get_node("HUD/DemoShell") as Control
	shell.call("start_demo")
	main.call("unlock_wind_seal")
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.call("set_current_stance_id", &"ward")
	_perform_element_step(player, &"wind", true)
	player.call("set_current_element_id", &"thunder")
	player.call("_start_attack")

	var hud := main.get_node("HUD/TutorialHUD") as Control
	hud.call("_process", 0.0)
	var element_panel := hud.get_node("ElementPanel") as Panel
	var element_label := hud.get_node("ElementPanel/ElementStatusLabel") as Label
	assert_true(element_panel.visible)
	assert_true(element_label.text.contains("御印 · 雷"))
	assert_true(element_label.text.contains("风 → 雷"))
	assert_true(element_label.text.contains("追击贯穿"))
	assert_true(element_label.text.contains("s"))


func _perform_element_step(player: CharacterBody2D, element_id: StringName, finish: bool) -> void:
	player.call("set_current_element_id", element_id)
	player.call("_start_attack")
	if finish:
		player.call("_finish_attack")


func _instantiate(path: String) -> Node:
	var packed := load(path) as PackedScene
	assert_not_null(packed, "场景存在：%s" % path)
	return packed.instantiate() if packed != null else null


func _spawn_main() -> Node2D:
	var main := _instantiate(MAIN_SCENE_PATH) as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	return main


func _spawn_player() -> CharacterBody2D:
	var player := _instantiate(PLAYER_SCENE_PATH) as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	return player
