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


func test_hud_exposes_seal_resonance_snapshot_reaction_glyphs_and_window_shader() -> void:
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
	assert_true(element_panel.visible)
	assert_true(element_panel.has_method("get_visual_snapshot"), "ElementPanel 必须由 SealResonanceHud 输出视觉快照。")
	if not element_panel.has_method("get_visual_snapshot"):
		return
	var visual: Dictionary = element_panel.call("get_visual_snapshot")
	assert_eq(visual.get("state"), &"resolved")
	assert_eq(visual.get("reaction_id"), &"wind_thunder_pierce")
	var pierce_glyph_path := str(visual.get("reaction_glyph_path", ""))
	assert_string_contains(pierce_glyph_path, "seal_resonance_symbols_warden_ai02")

	var sequence_link := element_panel.get_node_or_null("ContentRoot/SequenceRoot/SequenceLink") as Control
	assert_not_null(sequence_link, "展开态必须有独立灵力链节点。")
	if sequence_link == null:
		return
	var link_material := sequence_link.material as ShaderMaterial
	assert_not_null(link_material, "灵力链必须由专用 Shader 读取窗口比例。")
	if link_material != null:
		var window_ratio := float(link_material.get_shader_parameter("window_ratio"))
		assert_gte(window_ratio, 0.0)
		assert_lte(window_ratio, 1.0)

	player.call("clear_element_sequence")
	_perform_element_step(player, &"thunder", true)
	player.call("set_current_element_id", &"wind")
	player.call("_start_attack")
	hud.call("_process", 0.0)
	visual = element_panel.call("get_visual_snapshot")
	assert_eq(visual.get("reaction_id"), &"thunder_wind_scatter")
	var scatter_glyph_path := str(visual.get("reaction_glyph_path", ""))
	assert_string_contains(scatter_glyph_path, "seal_resonance_symbols_warden_ai02")
	assert_ne(scatter_glyph_path, pierce_glyph_path, "贯穿与散射必须绑定不同 glyph 资源。")


# 这条回归捕获正式换房把 HUD 级激活提示误当成 Player 实例状态清空的断裂。
func test_wind_unlock_prompt_survives_production_room_transition_until_new_player_switches_element() -> void:
	var main := await _spawn_main()
	var shell := main.get_node("HUD/DemoShell") as Control
	shell.call("start_demo")
	var hud := main.get_node("HUD/TutorialHUD") as Control
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	hud.call("_process", 0.0)
	assert_true(hud.has_method("get_contextual_tutorial_snapshot"), "HUD 必须公开实际 PromptPanel / attention 快照。")
	if not hud.has_method("get_contextual_tutorial_snapshot"):
		return

	var contextual: Dictionary = hud.call("get_contextual_tutorial_snapshot")
	assert_false(bool(contextual.get("active", true)), "风印未解锁时不得提前显示元素切换教学。")
	var resonance_text := ""
	for label_node: Node in (hud.get_node("ElementPanel") as Panel).find_children("*", "Label", true, false):
		resonance_text += (label_node as Label).text
	assert_eq(resonance_text.find("Q"), -1, "常驻符印共鸣盘不得重新塞入固定按键。")

	main.call("unlock_wind_seal")
	hud.call("_process", 0.0)
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_true(bool(contextual.get("active", false)))
	assert_eq(contextual.get("step_id"), &"wind_switch")
	assert_eq(contextual.get("title"), "F01 · 风印已解 · 元素切换")
	assert_string_contains(str(contextual.get("body", "")), "Q")
	assert_true(bool(contextual.get("attention_visible", false)), "风印提示必须复用当前唯一 TutorialAttention。")
	var joy_event := InputEventJoypadButton.new()
	joy_event.button_index = JOY_BUTTON_LEFT_SHOULDER
	joy_event.pressed = true
	hud.call("_input", joy_event)
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_eq(contextual.get("step_id"), &"wind_switch", "设备变化只能重算同一条提示。")
	assert_string_contains(str(contextual.get("body", "")), "LB / L1")

	var room := main.get_node("Room") as Node
	room.emit_signal("hud_context_changed", "房间缓存标题", "房间缓存正文")
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_eq(contextual.get("title"), "F01 · 风印已解 · 元素切换", "提示期间房间 signal 只能更新缓存。")

	main.call("transition_to_room", COMBAT_ROOM, &"combat_entry")
	await get_tree().process_frame
	hud.call("_process", 0.0)
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_true(bool(contextual.get("active", false)), "换房生成新 Player 不得撤销未完成的风印提示。")
	assert_eq(contextual.get("step_id"), &"wind_switch")
	assert_eq(contextual.get("title"), "F02 · 风印已解 · 元素切换")

	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.call("cycle_current_element")
	hud.call("_process", 0.0)
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_false(bool(contextual.get("active", true)))
	assert_eq(contextual.get("title"), "F02 · 实战 1/1 · 击败敌人")
	assert_eq(contextual.get("body"), "前方出现了第一只近战敌人。观察接敌压力，利用冲刺与攻击击败它。")

	main.call("transition_to_room", STAGE10_CHALLENGE, &"stage10_challenge_start")
	await get_tree().process_frame
	hud.call("_process", 0.0)
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_false(bool(contextual.get("active", true)), "完成后已解锁玩家再次换房不得补弹提示。")


# 临时解绑不代表新游戏；相同已解锁实例重绑后仍需由真实元素变化完成提示。
func test_active_wind_prompt_survives_null_then_same_player_rebind() -> void:
	var main := await _spawn_main()
	var shell := main.get_node("HUD/DemoShell") as Control
	shell.call("start_demo")
	var hud := main.get_node("HUD/TutorialHUD") as Control
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	hud.call("_process", 0.0)
	main.call("unlock_wind_seal")
	hud.call("_process", 0.0)
	var contextual: Dictionary = hud.call("get_contextual_tutorial_snapshot")
	assert_true(bool(contextual.get("active", false)))

	hud.call("bind_player", null)
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_true(bool(contextual.get("active", false)), "bind_player(null) 只能断开来源，不能完成 HUD 教学。")
	assert_eq(contextual.get("step_id"), &"wind_switch")
	hud.call("bind_player", player)
	hud.call("_process", 0.0)
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_true(bool(contextual.get("active", false)), "同一已解锁实例重绑后提示必须继续。")
	assert_eq(contextual.get("step_id"), &"wind_switch")

	player.call("cycle_current_element")
	hud.call("_process", 0.0)
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_false(bool(contextual.get("active", true)))
	assert_eq(contextual.get("title"), "F01 · 教程 1/5 · 移动与跳跃")


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
