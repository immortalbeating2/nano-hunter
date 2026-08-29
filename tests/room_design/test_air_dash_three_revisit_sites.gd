extends GutTest

# 方案 B Air Dash 回访回归：F06、F07、F09 分别承担可选奖励、主永久捷径和高速线，
# F15 只汇总进度，并在完成 F07 主回访前保持 Boss 路线未就绪。


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const F06 := "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"
const F07 := "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"
const F09 := "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"
const F14 := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const F15 := "res://scenes/rooms/stage14_backtrack_hub_room.tscn"
const F16 := "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"


class MainStub extends Node:
	var wind_seal_unlocked := true
	var air_dash_unlocked := false
	var rewards: Dictionary = {}

	func has_exploration_reward(reward_id: StringName) -> bool:
		return reward_id == &"wind_seal" and wind_seal_unlocked

	func is_air_dash_unlocked() -> bool:
		return air_dash_unlocked

	func collect_stage14_backtrack_reward(reward_id: StringName) -> void:
		rewards[reward_id] = true

	func has_stage14_backtrack_reward(reward_id: StringName) -> bool:
		return rewards.has(reward_id)

	func get_stage14_backtrack_reward_count() -> int:
		return rewards.size()

	func is_room_forward_route_completed(_room_path: String) -> bool:
		return false


func before_each() -> void:
	get_tree().paused = false
	_release_actions()
	await get_tree().process_frame


func after_each() -> void:
	get_tree().paused = false
	_release_actions()


# F06 奖励在能力前不可取得；解锁后必须以真实空中 Dash 穿过奖励点。
func test_f06_revisit_reward_requires_air_dash_action() -> void:
	var room := await _spawn_room(F06)
	var player := await _spawn_player()
	var main := MainStub.new()
	add_child_autofree(main)
	room.call("bind_main", main)
	room.call("bind_player", player)
	var reward := room.get_node_or_null("AirDashRevisitReward") as Node2D
	assert_not_null(reward)
	if reward == null:
		return

	player.global_position = reward.global_position
	await _advance_process_frames(2)
	assert_false(main.rewards.has(&"stage14_reward_one"))

	main.air_dash_unlocked = true
	player.call("set_air_dash_unlocked", true)
	player.global_position = Vector2(reward.global_position.x, reward.global_position.y + 20.0)
	await _advance_physics_frames(1)
	Input.action_press("jump")
	await _advance_physics_frames(2)
	Input.action_release("jump")
	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")
	player.global_position = reward.global_position
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_true(main.rewards.has(&"stage14_reward_one"))


# F07 是必须回访：能力前不可用，风印与 Air Dash 同时满足后才记录主回访并返回 F14。
func test_f07_shortcut_records_required_revisit_only_when_both_abilities_exist() -> void:
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
	assert_true(transitions.is_empty())
	assert_false(main.rewards.has(&"stage14_reward_two"))

	main.air_dash_unlocked = true
	player.call("set_air_dash_unlocked", true)
	await _advance_process_frames(2)
	assert_true(transitions.is_empty(), "双能力齐全后仍需按下方向确认法坛。")
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(transitions.size(), 1)
	assert_true(main.rewards.has(&"stage14_reward_two"))
	if not transitions.is_empty():
		assert_eq(transitions[0].target, F14)


# F09 的高速线同样不能只靠持有能力误触，成功空中 Dash 后记录第三个可选回访。
func test_f09_fast_route_records_optional_revisit_reward() -> void:
	var room := await _spawn_room(F09)
	var player := await _spawn_player()
	var main := MainStub.new()
	add_child_autofree(main)
	room.call("bind_main", main)
	room.call("bind_player", player)
	var fast_zone := room.get_node("AirDashFastRouteZone") as Node2D
	player.global_position = fast_zone.global_position
	await _advance_process_frames(2)
	assert_false(main.rewards.has(&"stage14_reward_three"))

	main.air_dash_unlocked = true
	player.call("set_air_dash_unlocked", true)
	assert_true(bool(room.call("is_air_dash_fast_route_available")))
	player.global_position = fast_zone.global_position - Vector2(0.0, 32.0)
	player.velocity = Vector2.ZERO
	await _advance_physics_frames(1)
	Input.action_press("dash")
	await _advance_physics_frames(2)
	assert_false(player.is_on_floor())
	assert_eq(player.call("get_current_state_id"), &"dash")
	assert_lte(player.global_position.distance_to(fast_zone.global_position), 64.0)
	Input.action_release("dash")
	await _advance_process_frames(2)
	assert_true(main.rewards.has(&"stage14_reward_three"))


# F15 不再自己摆三份奖励；完成 F07 主回访后才开放直达 F16 的 Boss 前路线。
func test_f15_is_progress_hub_and_requires_primary_revisit_for_boss_route() -> void:
	var room := await _spawn_room(F15)
	var player := await _spawn_player()
	var main := MainStub.new()
	add_child_autofree(main)
	room.call("bind_main", main)
	room.call("bind_player", player)

	for old_reward in ["BacktrackRewardOne", "BacktrackRewardTwo", "BacktrackRewardThree"]:
		assert_null(room.get_node_or_null(old_reward))
	assert_eq(room.get("previous_room_path"), F14)
	assert_eq(room.get("next_room_path"), F16)
	assert_false(bool(room.call("is_boss_route_ready")))

	main.collect_stage14_backtrack_reward(&"stage14_reward_two")
	await _advance_process_frames(2)
	assert_true(bool(room.call("is_boss_route_ready")))
	assert_eq(int(room.call("get_stage14_backtrack_reward_count")), 1)


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
