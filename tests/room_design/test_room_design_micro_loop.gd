extends GutTest

# 方案 B 五房微循环回归：F07 预告、F09 回访高速线、F12 区域目标、
# F13 授予 Air Dash、F14 立即验证，并保护能力后反向返回与永久捷径。


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const F07 := "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"
const F08 := "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"
const F09 := "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"
const F12 := "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"
const F13 := "res://scenes/rooms/stage14_air_dash_shrine_room.tscn"
const F14 := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const F15 := "res://scenes/rooms/stage14_backtrack_hub_room.tscn"


class MainStub extends Node:
	var wind_seal_unlocked := false
	var air_dash_unlocked := false
	var completed_rooms: Dictionary = {}

	func has_exploration_reward(reward_id: StringName) -> bool:
		return reward_id == &"wind_seal" and wind_seal_unlocked

	func is_air_dash_unlocked() -> bool:
		return air_dash_unlocked

	func unlock_air_dash() -> void:
		air_dash_unlocked = true

	func is_room_forward_route_completed(room_path: String) -> bool:
		return bool(completed_rooms.get(room_path, false))

	func get_stage14_backtrack_reward_count() -> int:
		return 0


func before_each() -> void:
	_release_actions()


func after_each() -> void:
	_release_actions()


# 正式主线应绕开 reserve 房，反向链也必须直接回到正式五房环。
func test_formal_micro_loop_uses_direct_forward_and_reverse_links() -> void:
	var f07 := await _spawn_room(F07)
	var f09 := await _spawn_room(F09)
	var f12 := await _spawn_room(F12)
	var f13 := await _spawn_room(F13)
	var f14 := await _spawn_room(F14)

	assert_eq(f07.get("next_room_path"), F08)
	assert_eq(f09.get("next_room_path"), F12)
	assert_eq(f12.get("previous_room_path"), F09)
	assert_eq(f12.get("next_room_path"), F13)
	assert_eq(f13.get("previous_room_path"), F12)
	assert_eq(f13.get("next_room_path"), F14)
	assert_eq(f14.get("previous_room_path"), F13)
	assert_eq(f14.get("next_room_path"), F15)


# F14 不能因“拥有能力”自动开门，必须在空中冲刺状态穿过证明传感器。
func test_f14_requires_real_air_dash_proof_before_opening_gate() -> void:
	var room := await _spawn_room(F14)
	var player := await _spawn_player()
	var main := MainStub.new()
	add_child_autofree(main)
	main.air_dash_unlocked = true
	player.call("set_air_dash_unlocked", true)
	room.call("bind_main", main)
	room.call("bind_player", player)

	await _advance_physics_frames(2)
	assert_false(bool(room.call("is_air_dash_gate_unlocked")), "仅拥有能力时 F14 仍应保持证明门关闭")

	var sensor := room.get_node("AirDashGateSensor") as Node2D
	var pulse := room.get_node("SealPulseHazard") as Node2D
	assert_gt(sensor.global_position.distance_to(pulse.global_position), 200.0, "立即能力证明落点不得与循环伤害区重叠")
	player.global_position = sensor.global_position
	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")
	await _advance_process_frames(2)

	assert_true(bool(room.call("is_air_dash_proof_complete")))
	assert_true(bool(room.call("is_air_dash_gate_unlocked")))


# F09 首次仍走底层主路；能力后在上层以 Air Dash 触发更早的高速出口。
func test_f09_air_dash_fast_route_only_works_during_air_dash() -> void:
	var room := await _spawn_room(F09)
	var player := await _spawn_player()
	var transitions: Array[Dictionary] = []
	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	var fast_zone := room.get_node_or_null("AirDashFastRouteZone") as Node2D
	assert_not_null(fast_zone)
	var layout := room.get_node_or_null("Phase2GrayboxLayout")
	assert_not_null(layout)
	assert_eq(int(layout.call("get_segment_count")), 3)
	assert_eq(layout.call("get_layout_profile"), &"three_route_hub")
	assert_lt(fast_zone.global_position.x, (room.get_node("ChallengeBranchZone") as Node2D).global_position.x)
	assert_lt((room.get_node("ChallengeBranchZone") as Node2D).global_position.x, (room.get_node("ExitZone") as Node2D).global_position.x)
	if fast_zone == null:
		return

	player.global_position = fast_zone.global_position
	await _advance_process_frames(2)
	assert_true(transitions.is_empty())

	player.call("set_air_dash_unlocked", true)
	player.global_position = Vector2(fast_zone.global_position.x, fast_zone.global_position.y + 20.0)
	player.velocity.y = 80.0
	await _advance_physics_frames(1)
	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")
	await _advance_process_frames(2)
	assert_eq(transitions.size(), 1)
	if not transitions.is_empty():
		assert_eq(transitions[0].target, F12)
		assert_eq(transitions[0].spawn, &"stage13_goal_from_fast_route")


# F07↔F14 永久捷径必须同时要求风印与 Air Dash，任一缺失都不能误触切房。
func test_f07_to_f14_shortcut_requires_both_abilities() -> void:
	var room := await _spawn_room(F07)
	var player := await _spawn_player()
	var main := MainStub.new()
	add_child_autofree(main)
	var transitions: Array[Dictionary] = []
	room.call("bind_main", main)
	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	player.global_position = (room.get_node("ShortcutZone") as Node2D).global_position

	await _advance_process_frames(2)
	main.wind_seal_unlocked = true
	await _advance_process_frames(2)
	assert_true(transitions.is_empty())

	player.call("set_air_dash_unlocked", true)
	await _advance_process_frames(2)
	assert_true(transitions.is_empty(), "双能力齐全后仍需按下方向确认法坛。")
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(transitions.size(), 1)
	if not transitions.is_empty():
		assert_eq(transitions[0].target, F14)
		assert_eq(transitions[0].spawn, &"stage14_gate_from_wind_cross")


# 五房均声明安全地板与三秒读路角色，失败应落回房内地板而不是依赖全局跌落恢复。
func test_five_rooms_publish_safe_graybox_contracts() -> void:
	for room_path: String in [F07, F09, F12, F13, F14]:
		var room := await _spawn_room(room_path)
		assert_eq(str(room.get_meta("formal_room_id", "")), _formal_id_for(room_path))
		assert_eq(float(room.get_meta("safe_floor_y", -999.0)), 160.0)
		assert_false(bool(room.get_meta("normal_exit_uses_generic_door", true)))
		assert_not_null(room.get_node_or_null("TerrainCollisionVisual"))


func _formal_id_for(room_path: String) -> String:
	return {
		F07: "F07",
		F09: "F09",
		F12: "F12",
		F13: "F13",
		F14: "F14",
	}.get(room_path, "")


func _spawn_room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed, "缺少房间：%s" % path)
	if packed == null:
		return null
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


func _spawn_player() -> CharacterBody2D:
	var packed := load(PLAYER_SCENE_PATH) as PackedScene
	var player := packed.instantiate() as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	return player


func _advance_process_frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame


func _advance_physics_frames(count: int) -> void:
	for _i in range(count):
		await get_tree().physics_frame


func _release_actions() -> void:
	for action in [&"move_left", &"move_right", &"ui_down", &"jump", &"dash"]:
		if InputMap.has_action(action):
			Input.action_release(action)
