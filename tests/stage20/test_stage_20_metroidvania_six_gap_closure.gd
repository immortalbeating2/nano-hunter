extends GutTest

# Stage20 六类银河城缺口回归：保护早期支路、时机危险、Caster 弹体、
# 风印与 Air Dash 交叉门、双圣物 Build，以及 Stage11 一次性剧情事件。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const CASTER_SCENE_PATH := "res://scenes/combat/miasma_caster_enemy.tscn"
const PROJECTILE_SCENE_PATH := "res://scenes/combat/miasma_projectile.tscn"
const HAZARD_SCRIPT_PATH := "res://scripts/rooms/seal_pulse_hazard.gd"
const STAGE9_SWITCH := "res://scenes/rooms/stage9_zone_switch_room.tscn"
const STAGE10_BRANCH := "res://scenes/rooms/stage10_zone_branch_room.tscn"
const STAGE10_CHALLENGE := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const STAGE11_END := "res://scenes/rooms/stage11_demo_end_room.tscn"
const STAGE13_GATE := "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"
const STAGE14_GATE := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"


func after_each() -> void:
	get_tree().paused = false
	Input.action_release("ui_down")


func test_early_second_route_grants_persistent_wind_seal() -> void:
	var switch_room := await _spawn_room(STAGE9_SWITCH)
	var branch_player := await _spawn_player()
	var transitions: Array[Dictionary] = []
	switch_room.call("bind_player", branch_player)
	switch_room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	assert_true(bool(switch_room.call("is_shortcut_available")))

	branch_player.global_position = (switch_room.get_node("ShortcutZone") as Node2D).global_position
	await _advance_process_frames(3)
	assert_eq(transitions.size(), 1)
	if not transitions.is_empty():
		assert_eq(transitions[0].target, STAGE10_BRANCH)
		assert_eq(transitions[0].spawn, &"stage10_branch_from_stage9_shortcut")

	var main := await _spawn_main()
	main.call("transition_to_room", STAGE10_BRANCH, &"stage10_branch_from_stage9_shortcut")
	await get_tree().process_frame
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = (room.get_node("BranchCollectible") as Node2D).global_position
	await _advance_process_frames(3)
	assert_true(bool(main.call("is_wind_seal_unlocked")))
	assert_true(bool(main.call("has_exploration_reward", &"wind_seal")))
	assert_true(bool(player.call("is_wind_seal_unlocked")))


func test_seal_pulse_hazard_warns_then_damages_once_per_active_cycle() -> void:
	for room_path: String in [STAGE10_CHALLENGE, STAGE14_GATE]:
		var room := await _spawn_room(room_path)
		var placed_hazard := room.get_node_or_null("SealPulseHazard") as Area2D
		assert_not_null(placed_hazard, "房间必须接入封印脉冲阵：%s" % room_path)
		if placed_hazard != null:
			assert_eq(str(placed_hazard.get_meta("hazard_family", "")), "timed_seal_pulse")

	var hazard_script := load(HAZARD_SCRIPT_PATH) as Script
	var hazard := hazard_script.new() as Area2D
	hazard.collision_layer = 0
	hazard.collision_mask = 1
	hazard.set("rest_duration", 0.03)
	hazard.set("warning_duration", 0.03)
	hazard.set("active_duration", 0.12)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(200.0, 200.0)
	collision.shape = shape
	hazard.add_child(collision)
	var warning_visual := Polygon2D.new()
	warning_visual.name = "WarningVisual"
	hazard.add_child(warning_visual)
	var active_visual := Polygon2D.new()
	active_visual.name = "ActiveVisual"
	hazard.add_child(active_visual)
	add_child_autofree(hazard)

	var player := await _spawn_player()
	player.global_position = hazard.global_position
	hazard.call("bind_player", player)
	assert_true(await _wait_for_phase(hazard, &"warning", 12))
	assert_true(warning_visual.visible)
	assert_true(await _wait_for_phase(hazard, &"active", 12))
	await get_tree().physics_frame
	var health_after_hit := int(player.call("get_current_health"))
	assert_eq(health_after_hit, int(player.call("get_max_health")) - 1)
	await _advance_physics_frames(3)
	assert_eq(int(player.call("get_current_health")), health_after_hit, "同一激活周期只能伤害一次")


func test_caster_fires_targeted_projectile_and_wind_seal_disperses_it() -> void:
	var encounter := Node2D.new()
	add_child_autofree(encounter)
	var caster := _instantiate(CASTER_SCENE_PATH) as StaticBody2D
	var target := _instantiate(PLAYER_SCENE_PATH) as CharacterBody2D
	encounter.add_child(caster)
	encounter.add_child(target)
	caster.global_position = Vector2.ZERO
	target.global_position = Vector2(120.0, 0.0)
	caster.call("bind_player", target)
	caster.set("_cast_interval", 0.03)
	await _advance_physics_frames(4)
	assert_gt(int(caster.call("get_projectiles_spawned_count")), 0)

	var projectile := _instantiate(PROJECTILE_SCENE_PATH) as Area2D
	encounter.add_child(projectile)
	projectile.set_physics_process(false)
	target.global_position = Vector2(320.0, 0.0)
	projectile.global_position = target.call("get_attack_hitbox_center")
	await get_tree().physics_frame

	target.call("_perform_attack_hits")
	assert_false(bool(projectile.call("is_spent")), "未取得风印时普通攻击不能查询敌方 Area2D")
	target.call("set_wind_seal_unlocked", true)
	target.call("_perform_attack_hits")
	assert_true(bool(projectile.call("is_spent")), "取得风印后普通攻击可斩散弹体")


func test_sc06_requires_wind_seal_and_air_dash_at_both_ends() -> void:
	var main := await _spawn_main()
	var player := await _spawn_player()
	var stage13 := await _spawn_room(STAGE13_GATE)
	var transitions: Array[Dictionary] = []
	stage13.call("bind_main", main)
	stage13.call("bind_player", player)
	stage13.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	player.global_position = (stage13.get_node("ShortcutZone") as Node2D).global_position

	await _advance_process_frames(2)
	assert_true(transitions.is_empty())
	main.call("unlock_wind_seal")
	await _advance_process_frames(2)
	assert_true(transitions.is_empty(), "只有风印时交叉门仍关闭")
	player.call("set_air_dash_unlocked", true)
	await _advance_process_frames(2)
	assert_true(transitions.is_empty(), "交叉法坛必须等待下方向确认。")
	player.global_position = (stage13.get_node("ShortcutZone") as Node2D).global_position
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(transitions.size(), 1)
	if not transitions.is_empty():
		assert_eq(transitions[0].target, STAGE14_GATE)
		assert_eq(transitions[0].spawn, &"stage14_gate_from_wind_cross")

	var stage14 := await _spawn_room(STAGE14_GATE)
	stage14.call("bind_main", main)
	stage14.call("bind_player", player)
	assert_true(bool(stage14.call("is_shortcut_available")))
	assert_eq(stage14.get("shortcut_room_path"), STAGE13_GATE)
	assert_eq(stage14.get("shortcut_spawn_id"), &"stage13_gate_from_wind_cross")


func test_two_rewards_form_switchable_builds_and_survive_room_change() -> void:
	var main := await _spawn_main()
	var shell := main.get_node("HUD/DemoShell") as Control
	shell.call("start_demo")
	await get_tree().process_frame
	main.call("collect_exploration_reward", &"marsh_relic")
	main.call("collect_exploration_reward", &"warden_sigil")
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	var base_reach: float = player.attack_hitbox_size.x
	assert_eq(main.call("get_active_build_id"), &"marsh_relic")
	assert_eq(float(player.call("get_recovery_charge_gain_multiplier")), 1.5)

	shell.call("pause_demo")
	var build_button := shell.get_node(
		"PauseMenu/MarginContainer/VBoxContainer/BuildButton"
	) as Button
	assert_false(build_button.disabled)
	assert_false(build_button.has_theme_stylebox_override("normal"), "暂停动作使用共享符光带，不再给单个按钮叠加变形外框。")
	assert_true(build_button.get_theme_stylebox("normal") is StyleBoxEmpty)
	build_button.pressed.emit()
	assert_eq(main.call("get_active_build_id"), &"warden_sigil")
	assert_eq((player.call("get_effective_attack_hitbox_size") as Vector2).x, base_reach + 16.0)
	shell.call("resume_demo")

	main.call("transition_to_room", STAGE10_CHALLENGE, &"stage10_challenge_start")
	await get_tree().process_frame
	var transitioned_player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_eq(transitioned_player.call("get_active_build_id"), &"warden_sigil")

	main.call("restart_demo")
	await get_tree().process_frame
	assert_eq(main.call("get_active_build_id"), StringName())
	assert_eq(int(main.call("get_available_build_count")), 0)


func test_stage11_story_event_pauses_once_and_continue_returns_to_game() -> void:
	var main := await _spawn_main()
	var shell := main.get_node("HUD/DemoShell") as Control
	shell.call("start_demo")
	main.call("transition_to_room", STAGE11_END, &"stage11_demo_end_start")
	await get_tree().process_frame
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = (room.get_node("GoalZone") as Node2D).global_position
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")

	var snapshot: Dictionary = main.call("get_demo_progress_snapshot")
	var detail_panel := shell.get_node("DetailPanel") as Control
	var detail_title := shell.get_node(
		"DetailPanel/MarginContainer/VBoxContainer/DetailTitleLabel"
	) as Label
	var detail_back := shell.get_node(
		"DetailPanel/MarginContainer/VBoxContainer/DetailBackButton"
	) as Button
	assert_true(bool(snapshot.get("stage11_story_event_completed", false)))
	assert_eq(int(snapshot.get("story_event_count", 0)), 1)
	assert_true(detail_panel.visible)
	assert_true(detail_title.text.contains("密令残页"))
	assert_true(get_tree().paused)

	detail_back.pressed.emit()
	assert_false(get_tree().paused)
	assert_false(detail_panel.visible)
	assert_false(bool(main.call(
		"trigger_story_event",
		&"stage11_hidden_dispatch",
		"重复事件",
		"不应再次显示"
	)))
	assert_eq(int((main.call("get_demo_progress_snapshot") as Dictionary).get("story_event_count", 0)), 1)


func _instantiate(path: String) -> Node:
	var packed := load(path) as PackedScene
	assert_not_null(packed, "场景存在：%s" % path)
	return packed.instantiate() if packed != null else null


func _spawn_main() -> Node2D:
	var main := _instantiate(MAIN_SCENE_PATH) as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	return main


func _spawn_room(path: String) -> Node2D:
	var room := _instantiate(path) as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


func _spawn_player() -> CharacterBody2D:
	var player := _instantiate(PLAYER_SCENE_PATH) as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	return player


func _advance_process_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame


func _advance_physics_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().physics_frame


func _wait_for_phase(hazard: Area2D, phase_id: StringName, max_frames: int) -> bool:
	for _index in range(max_frames):
		if hazard.call("get_phase_id") == phase_id:
			return true
		await get_tree().physics_frame
	return hazard.call("get_phase_id") == phase_id
