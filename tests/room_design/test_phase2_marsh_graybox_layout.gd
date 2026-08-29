extends GutTest

# 方案 B 第二阶段瘴泽灰盒回归：保护 F04–F09 的真实分段碰撞、入口安全支撑、
# 三高度读路，以及 F09→F10→F08 与 F07↔F14 的生产切房信号闭环。


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const F04 := "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"
const F05 := "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"
const F06 := "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"
const F07 := "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"
const F08 := "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"
const F09 := "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"
const F10 := "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"
const F12 := "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"
const F14 := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const F15 := "res://scenes/rooms/stage14_backtrack_hub_room.tscn"


class MainStub extends Node:
	var wind_seal_unlocked := true
	var air_dash_unlocked := true
	var rewards: Dictionary = {}

	func has_exploration_reward(reward_id: StringName) -> bool:
		return reward_id == &"wind_seal" and wind_seal_unlocked

	func is_wind_seal_unlocked() -> bool:
		return wind_seal_unlocked

	func is_air_dash_unlocked() -> bool:
		return air_dash_unlocked

	func is_room_forward_route_completed(_room_path: String) -> bool:
		return false

	func collect_stage14_backtrack_reward(reward_id: StringName) -> void:
		rewards[reward_id] = true

	func has_stage14_backtrack_reward(reward_id: StringName) -> bool:
		return rewards.has(reward_id)


func before_each() -> void:
	_release_actions()


func after_each() -> void:
	_release_actions()


# 删除 Phase2GrayboxLayout、少配一个镜头段，或重新启用旧模板碰撞，都必须打红。
func test_f04_to_f09_replace_template_collision_with_blueprint_segments() -> void:
	var specs := {
		F04: {"segments": 3, "profile": &"region_reveal"},
		F05: {"segments": 3, "profile": &"wind_seal_tutorial"},
		F06: {"segments": 3, "profile": &"upper_lower_hazard"},
		F07: {"segments": 3, "profile": &"cross_ability_gate"},
		F08: {"segments": 2, "profile": &"safe_recovery"},
		F09: {"segments": 3, "profile": &"three_route_hub"},
	}
	for path: String in specs:
		var room := await _spawn_room(path)
		var layout := room.get_node_or_null("Phase2GrayboxLayout")
		assert_not_null(layout, "%s 必须落地第二阶段实体灰盒" % path)
		if layout == null:
			continue
		assert_eq(int(layout.call("get_segment_count")), int(specs[path].segments))
		assert_eq(layout.call("get_layout_profile"), specs[path].profile)
		assert_gte(int(layout.call("get_runtime_platform_count")), int(specs[path].segments))
		assert_false(bool((room.get_node("TerrainCollisionVisual") as TileMapLayer).collision_enabled))
		assert_false(bool((room.get_node("PlatformCollisionVisual") as TileMapLayer).collision_enabled))


# 入口出生点下方必须由本轮实体灰盒支撑，不能依赖旧 TileMap 或 Main 全局跌落恢复。
func test_all_six_rooms_support_every_declared_spawn_inside_the_room() -> void:
	for path: String in [F04, F05, F06, F07, F08, F09]:
		var room := await _spawn_room(path)
		var layout := room.get_node_or_null("Phase2GrayboxLayout")
		assert_not_null(layout)
		if layout == null:
			continue
		var spawn_positions: Dictionary = room.get("spawn_positions")
		for spawn_id: StringName in spawn_positions:
			var spawn_position: Vector2 = spawn_positions[spawn_id]
			assert_true(
				bool(layout.call("has_support_below", spawn_position, 72.0)),
				"%s/%s 出生点下方缺少 72u 内安全支撑" % [path, spawn_id],
			)


# F04/F05 必须用空间顺序完成“区域揭示”和“看弹体→授印→移动应用”，而非旧连续走廊。
func test_f04_reveal_markers_and_f05_teaching_order_follow_blueprint() -> void:
	var f04 := await _spawn_room(F04)
	var vista := f04.get_node_or_null("RegionVistaMarker") as Node2D
	var descent := f04.get_node_or_null("MarshDescentMarker") as Node2D
	var cross_gate_vista := f04.get_node_or_null("CrossGateVistaMarker") as Node2D
	assert_not_null(vista)
	assert_not_null(descent)
	assert_not_null(cross_gate_vista)
	if vista != null and descent != null and cross_gate_vista != null:
		assert_lt(vista.position.x, descent.position.x)
		assert_lt(descent.position.x, cross_gate_vista.position.x)
		assert_lt(vista.position.y, descent.position.y, "F04 必须由高岸下降进入瘴泽")

	var f05 := await _spawn_room(F05)
	var caster := f05.get_node("MiasmaCasterEnemy") as Node2D
	var shrine := f05.get_node("WindSealShrine") as Node2D
	var practice := f05.get_node_or_null("ProjectilePracticeMarker") as Node2D
	var exit := f05.get_node("ExitZone") as Node2D
	assert_not_null(practice)
	if practice != null:
		assert_lt(caster.position.x, shrine.position.x)
		assert_lt(shrine.position.x, practice.position.x)
		assert_lt(practice.position.x, exit.position.x)


# F06 上下路线和 F09 三路必须产生真实高度差，并且关键入口下方可踩。
func test_f06_and_f09_publish_distinct_supported_route_heights() -> void:
	var f06 := await _spawn_room(F06)
	var f06_layout := f06.get_node_or_null("Phase2GrayboxLayout")
	assert_not_null(f06_layout)
	if f06_layout != null:
		assert_lt(float(f06_layout.call("get_route_height", &"upper_main")), float(f06_layout.call("get_route_height", &"lower_revisit")))
		var reward := f06.get_node("AirDashRevisitReward") as Node2D
		assert_true(bool(f06_layout.call("has_support_below", reward.position, 72.0)))

	var f09 := await _spawn_room(F09)
	var f09_layout := f09.get_node_or_null("Phase2GrayboxLayout")
	assert_not_null(f09_layout)
	if f09_layout == null:
		return
	var challenge := f09.get_node("ChallengeBranchZone") as Node2D
	var main_exit := f09.get_node("ExitZone") as Node2D
	var resource := f09.get_node("ResourceBranchZone") as Node2D
	assert_lt(challenge.position.y, main_exit.position.y)
	assert_lt(main_exit.position.y, resource.position.y)
	for anchor: Node2D in [challenge, main_exit, resource]:
		assert_true(bool(f09_layout.call("has_support_below", anchor.position, 72.0)))
	assert_string_contains(
		str(f09.call("get_hud_context").get("prompt_text", "")),
		"按住下方向并跳跃",
		"F09 必须说明如何进入下层资源支路。",
	)


# 资源回环必须用真实“下+跳”穿过 F09 中层桥，再依次发出 F09→F10、F10→F08。
func test_f09_to_f10_to_f08_resource_loop_emits_production_transitions() -> void:
	var f09 := await _spawn_room(F09)
	var player := await _spawn_player()
	var f09_transitions: Array[Dictionary] = []
	f09.call("bind_player", player)
	f09.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		f09_transitions.append({"target": target, "spawn": spawn})
	)
	player.global_position = Vector2(1088.0, 150.0)
	player.velocity = Vector2.ZERO
	await _advance_physics_frames(12)
	assert_true(player.is_on_floor(), "玩家必须先稳定站在 F09 中层单向桥上。")
	Input.action_press("ui_down")
	Input.action_press("jump")
	await _advance_physics_frames(2)
	Input.action_release("jump")
	Input.action_release("ui_down")
	await _advance_physics_frames(30)
	assert_eq(f09_transitions.size(), 1)
	if not f09_transitions.is_empty():
		assert_eq(f09_transitions[0].target, F10)
		assert_eq(f09_transitions[0].spawn, &"stage13_resource_branch_start")

	var f10 := await _spawn_room(F10)
	var f10_transitions: Array[Dictionary] = []
	f10.call("bind_player", player)
	f10.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		f10_transitions.append({"target": target, "spawn": spawn})
	)
	player.global_position = (f10.get_node("OneWayExitZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq(f10_transitions.size(), 1)
	if not f10_transitions.is_empty():
		assert_eq(f10_transitions[0].target, F08)
		assert_eq(f10_transitions[0].spawn, &"stage13_checkpoint_from_resource_branch")


# 双能力捷径必须能从 F07 到 F14，也能从 F14 的回落层反向回 F07。
func test_f07_and_f14_cross_gate_is_bidirectional_with_real_signals() -> void:
	var main := MainStub.new()
	add_child_autofree(main)
	var player := await _spawn_player()
	player.call("set_air_dash_unlocked", true)

	var f07 := await _spawn_room(F07)
	var outward: Array[Dictionary] = []
	f07.call("bind_main", main)
	f07.call("bind_player", player)
	f07.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		outward.append({"target": target, "spawn": spawn})
	)
	player.global_position = (f07.get_node("ShortcutZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_true(outward.is_empty(), "双印法坛必须等待玩家按下方向确认，不能靠近即误传送。")
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(outward.size(), 1)
	if not outward.is_empty():
		assert_eq(outward[0].target, F14)
		assert_eq(outward[0].spawn, &"stage14_gate_from_wind_cross")

	var f14 := await _spawn_room(F14)
	var inward: Array[Dictionary] = []
	f14.call("bind_main", main)
	f14.call("bind_player", player)
	f14.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		inward.append({"target": target, "spawn": spawn})
	)
	player.global_position = (f14.get_node("ShortcutZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_true(inward.is_empty(), "F14 下层法坛必须与右上 F15 主线保持独立确认。")
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(inward.size(), 1)
	if not inward.is_empty():
		assert_eq(inward[0].target, F07)
		assert_eq(inward[0].spawn, &"stage13_gate_from_wind_cross")


# 生产 Main 必须在 F14→F07 后稳定留在 F07，抵达点不能落进 F07 自己的捷径触发半径。
func test_f14_shortcut_arrival_stays_in_f07_on_the_next_frame() -> void:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	assert_true(bool(main.call("start_demo_at_room", F14, &"stage14_air_dash_gate_start", {
		"air_dash_unlocked": true,
		"wind_seal_unlocked": true,
	})))
	await _advance_process_frames(2)
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = (room.get_node("ShortcutZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq((main.get_node("Room") as Node2D).scene_file_path, F14)
	Input.action_press("ui_down")
	await get_tree().process_frame
	Input.action_release("ui_down")
	assert_eq((main.get_node("Room") as Node2D).scene_file_path, F07)
	await get_tree().process_frame
	assert_eq((main.get_node("Room") as Node2D).scene_file_path, F07, "F07 抵达点不得在下一帧反向触发回 F14。")


# F12 左返必须在 F09 的安全前庭稳定落地，不能出生在 F09 正向出口后下一帧反弹回 F12。
func test_f12_return_to_f09_stays_in_f09_on_the_next_frame() -> void:
	var main := await _spawn_main_at(F12, &"stage13_goal_start")
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = (room.get_node("LeftExitZone") as Node2D).global_position
	await get_tree().process_frame
	assert_eq((main.get_node("Room") as Node2D).scene_file_path, F09)
	await _advance_process_frames(2)
	assert_eq((main.get_node("Room") as Node2D).scene_file_path, F09, "F09 返回出生点不得压住 F09→F12 出口。")
	var return_player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_eq(return_player.global_position, Vector2(1456.0, 172.0))


# F12 下层向右应被房内实体崖壁收住；正常读路失败不能再依赖 Main 的全局跌落重生。
func test_f12_lower_route_stops_at_right_cliff_without_checkpoint_reload() -> void:
	var main := await _spawn_main_at(F12, &"stage13_goal_start")
	await _advance_physics_frames(45)
	var first_player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	var first_id := first_player.get_instance_id()
	Input.action_press("move_right")
	await _advance_physics_frames(480)
	Input.action_release("move_right")
	var current_player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_eq((main.get_node("Room") as Node2D).scene_file_path, F12)
	assert_eq(current_player.get_instance_id(), first_id, "F12 右端不得触发 checkpoint 重载。")
	assert_true(current_player.is_on_floor())
	assert_lt(current_player.global_position.x, 848.0)


# F14 右上出口仍是正常 F15 主线；双能力法坛不能截获右侧出口。
func test_f14_right_exit_enters_f15_without_triggering_f07_shortcut() -> void:
	var main := await _spawn_main_at(F14, &"stage14_air_dash_gate_start", {
		"air_dash_unlocked": true,
		"wind_seal_unlocked": true,
	})
	var room := main.get_node("Room") as Node2D
	room.call("unlock_gate")
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = (room.get_node("ExitZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq((main.get_node("Room") as Node2D).scene_file_path, F15)


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


func _spawn_main_at(room_path: String, spawn_id: StringName, progress: Dictionary = {}) -> Node2D:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	assert_true(bool(main.call("start_demo_at_room", room_path, spawn_id, progress)))
	await _advance_process_frames(3)
	return main


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
