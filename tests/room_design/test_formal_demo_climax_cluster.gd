extends GutTest

# 方案 B 高潮簇回归：F16 综合战斗、F17 Boss、F18 战后降压必须形成直达 F03 的闭环，
# 同时保护三类移动路线、Boss 读招缓冲、快速重试与重复进入幂等。


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const F03 := "res://scenes/rooms/stage11_demo_end_room.tscn"
const F15 := "res://scenes/rooms/stage14_backtrack_hub_room.tscn"
const F16 := "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"
const F17 := "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn"
const F18 := "res://scenes/rooms/stage15_completion_room.tscn"


class MainStub extends Node:
	var boss_defeated := false
	var mark_count := 0

	func mark_stage15_boss_defeated() -> void:
		if boss_defeated:
			return
		boss_defeated = true
		mark_count += 1

	func is_stage15_boss_defeated() -> bool:
		return boss_defeated

	func is_room_forward_route_completed(_room_path: String) -> bool:
		return false


func after_each() -> void:
	Input.action_release("ui_down")


# F16 只有正式主线出口，且以三条可读路线分别服务基础移动、Dash 与 Air Dash。
func test_f16_exposes_three_mobility_routes_without_reserve_branch() -> void:
	var room := await _spawn_room(F16)
	assert_eq(room.get("previous_room_path"), F15)
	assert_eq(room.get("next_room_path"), F17)
	assert_eq(room.get("challenge_branch_room_path"), "")
	assert_eq(str(room.get_meta("formal_room_id", "")), "F16")
	assert_eq(str(room.get_meta("gate_semantics", "")), "clear_barrier")

	var profile: Dictionary = room.call("get_combat_route_profile")
	assert_eq(profile.size(), 3)
	assert_eq(profile.get("ground", {}).get("required_ability"), &"move")
	assert_eq(profile.get("charger", {}).get("required_ability"), &"dash")
	assert_eq(profile.get("aerial", {}).get("required_ability"), &"air_dash")
	for marker_name in ["GroundRouteMarker", "DashRouteMarker", "AirDashRouteMarker"]:
		assert_not_null(room.get_node_or_null(marker_name))


# F17 出生点到 Boss 保留明确读招距离，checkpoint 直接落在本房，失败无需重复跑 F16。
func test_f17_has_safe_read_buffer_and_local_retry_checkpoint() -> void:
	var room := await _spawn_room(F17)
	assert_eq(room.get("previous_room_path"), F16)
	assert_eq(room.get("next_room_path"), F18)
	assert_false(bool(room.get("checkpoint_on_ready")))
	assert_true(bool(room.get("checkpoint_requires_down_input")))
	assert_eq(room.get("checkpoint_spawn_id"), &"stage15_boss_start")
	assert_between(float(room.call("get_boss_read_buffer_distance")), 480.0, 900.0)
	assert_lte(float(room.call("get_retry_return_estimate_seconds")), 25.0)
	assert_eq(str(room.get_meta("formal_room_id", "")), "F17")
	assert_eq(str(room.get_meta("gate_semantics", "")), "boss_gate")


# Boss 完成信号与回访恢复都必须幂等；已击败后不再生成可战斗 Boss。
func test_f17_boss_completion_and_revisit_are_idempotent() -> void:
	var room := await _spawn_room(F17)
	var main := MainStub.new()
	add_child_autofree(main)
	room.call("bind_main", main)
	room.call("_on_boss_defeated")
	room.call("_on_boss_defeated")
	assert_eq(main.mark_count, 1)

	var revisited := await _spawn_room(F17)
	revisited.call("bind_main", main)
	assert_true(bool(revisited.call("is_boss_encounter_completed")))
	assert_true(bool(revisited.call("is_gate_unlocked")))
	assert_false((revisited.get_node("SealGuardianBoss") as CanvasItem).visible)


# F18 是安全降压与结果房，右侧普通驿路直接返回 F03，不再进入 Stage16 储备链。
func test_f18_returns_directly_to_waystation_hub() -> void:
	var room := await _spawn_room(F18)
	var player := await _spawn_player()
	var transitions: Array[Dictionary] = []
	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)

	assert_eq(room.get("previous_room_path"), F17)
	assert_eq(room.get("next_room_path"), F03)
	assert_eq(str(room.get_meta("formal_room_id", "")), "F18")
	assert_eq(int(room.call("get_remaining_required_enemy_count")), 0)
	player.global_position = (room.get_node("WaystationZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_true(transitions.is_empty(), "F18 归驿法坛必须等待玩家按下方向确认。")
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(transitions.size(), 1)
	if not transitions.is_empty():
		assert_eq(transitions[0].target, F03)
		assert_eq(transitions[0].spawn, &"stage11_demo_end_start")


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
