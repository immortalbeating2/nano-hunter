extends GutTest

# 方案 B 瘴泽区域回归：F04–F12 必须形成不经过 reserve 房的主线与两条支路，
# F05 在清场后通过明确神龛授予风印，F08 保持安全恢复与回环落点。


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const F04 := "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"
const F05 := "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"
const F06 := "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"
const F07 := "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"
const F08 := "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"
const F09 := "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"
const F10 := "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"
const F11 := "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn"
const F12 := "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"


class MainStub extends Node:
	var wind_seal_unlocked := false

	func unlock_wind_seal() -> void:
		wind_seal_unlocked = true

	func is_wind_seal_unlocked() -> bool:
		return wind_seal_unlocked

	func has_exploration_reward(reward_id: StringName) -> bool:
		return reward_id == &"wind_seal" and wind_seal_unlocked

	func is_room_forward_route_completed(_room_path: String) -> bool:
		return false


# 正式主线和两支路只能落在 F04–F12 集合内，不能再把玩家送进已合并的旧链。
func test_marsh_region_uses_formal_direct_links_and_branch_loops() -> void:
	var f04 := await _spawn_room(F04)
	var f05 := await _spawn_room(F05)
	var f06 := await _spawn_room(F06)
	var f07 := await _spawn_room(F07)
	var f08 := await _spawn_room(F08)
	var f09 := await _spawn_room(F09)
	var f10 := await _spawn_room(F10)
	var f11 := await _spawn_room(F11)

	assert_eq(f04.get("next_room_path"), F05)
	assert_eq(f04.get("shortcut_room_path"), "", "F04 不得再把正式路线引回旧 Stage10")
	assert_eq(f05.get("previous_room_path"), F04)
	assert_eq(f05.get("next_room_path"), F06)
	assert_eq(f06.get("previous_room_path"), F05)
	assert_eq(f06.get("next_room_path"), F07)
	assert_eq(f07.get("previous_room_path"), F06)
	assert_eq(f07.get("next_room_path"), F08)
	assert_eq(f08.get("previous_room_path"), F07)
	assert_eq(f08.get("next_room_path"), F09)
	assert_eq(f09.get("previous_room_path"), F08)
	assert_eq(f09.get("next_room_path"), F12)
	assert_eq(f09.call("get_resource_branch_room_path"), F10)
	assert_eq(f09.call("get_challenge_branch_room_path"), F11)
	assert_eq(f10.get("previous_room_path"), F09)
	assert_eq(f10.get("next_room_path"), F08)
	assert_eq(f11.get("previous_room_path"), F09)
	assert_eq(f11.get("next_room_path"), F12)


# 风印是 F05 的清场后明确收益，靠近神龛前或门仍锁住时都不能提前授予。
func test_f05_grants_wind_seal_only_after_clear_and_shrine_touch() -> void:
	var room := await _spawn_room(F05)
	var player := await _spawn_player()
	var main := MainStub.new()
	add_child_autofree(main)
	room.call("bind_main", main)
	room.call("bind_player", player)

	var shrine := room.get_node_or_null("WindSealShrine") as Node2D
	assert_not_null(shrine)
	assert_false(bool(room.call("is_wind_seal_granted")))
	if shrine == null:
		return

	player.global_position = shrine.global_position
	await _advance_process_frames(2)
	assert_false(main.wind_seal_unlocked, "清场前触达神龛不得提前获得风印")

	room.call("unlock_gate", &"stage13_caster_cleared")
	await _advance_process_frames(2)
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_true(main.wind_seal_unlocked)
	assert_true(bool(player.call("is_wind_seal_unlocked")))
	assert_true(bool(room.call("is_wind_seal_granted")))


# 九个瘴泽正式房都声明安全地板、正式编号和出口语义，F08 必须是无敌 checkpoint。
func test_marsh_rooms_publish_formal_roles_and_safe_checkpoint() -> void:
	var paths: Array[String] = [F04, F05, F06, F07, F08, F09, F10, F11, F12]
	for index in range(paths.size()):
		var room := await _spawn_room(paths[index])
		assert_eq(str(room.get_meta("formal_room_id", "")), "F%02d" % (index + 4))
		assert_eq(float(room.get_meta("safe_floor_y", -999.0)), 160.0)
		assert_false(bool(room.get_meta("normal_exit_uses_generic_door", true)))

	var checkpoint := await _spawn_room(F08)
	assert_false(bool(checkpoint.get("checkpoint_on_ready")))
	assert_true(bool(checkpoint.get("checkpoint_requires_down_input")))
	assert_eq(checkpoint.get("checkpoint_spawn_id"), &"stage13_checkpoint_start")
	assert_eq(int(checkpoint.call("get_remaining_required_enemy_count")), 0)


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
