extends GutTest

# Blueprint V2 生产采纳回归：先保护高偏差房的实体段落、主动交互和路线隔离，
# 再逐批扩到 F01–F18；位置注入只用于单点交互测试，不作为自然路线证据。

const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const HIGH_GAP_ROOMS := {
	"F02": ["res://scenes/rooms/combat_trial_room.tscn", 3],
	"F09": ["res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn", 3],
	"F10": ["res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn", 2],
	"F14": ["res://scenes/rooms/stage14_air_dash_gate_room.tscn", 3],
	"F18": ["res://scenes/rooms/stage15_completion_room.tscn", 2],
}
const FORMAL_ROOMS := {
	"F01": ["res://scenes/rooms/tutorial_room.tscn", 4],
	"F02": ["res://scenes/rooms/combat_trial_room.tscn", 3],
	"F03": ["res://scenes/rooms/stage11_demo_end_room.tscn", 3],
	"F04": ["res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn", 3],
	"F05": ["res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn", 3],
	"F06": ["res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn", 3],
	"F07": ["res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn", 3],
	"F08": ["res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn", 2],
	"F09": ["res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn", 3],
	"F10": ["res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn", 2],
	"F11": ["res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn", 3],
	"F12": ["res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn", 2],
	"F13": ["res://scenes/rooms/stage14_air_dash_shrine_room.tscn", 1],
	"F14": ["res://scenes/rooms/stage14_air_dash_gate_room.tscn", 3],
	"F15": ["res://scenes/rooms/stage14_backtrack_hub_room.tscn", 2],
	"F16": ["res://scenes/rooms/stage15_mixed_gauntlet_room.tscn", 4],
	"F17": ["res://scenes/rooms/stage15_seal_guardian_boss_room.tscn", 2],
	"F18": ["res://scenes/rooms/stage15_completion_room.tscn", 2],
}


func after_each() -> void:
	Input.action_release("ui_down")
	Input.action_release("move_left")


func test_high_gap_rooms_have_runtime_layouts_with_blueprint_segment_counts() -> void:
	for room_id: String in HIGH_GAP_ROOMS:
		var contract: Array = HIGH_GAP_ROOMS[room_id]
		var room := await _spawn_room(str(contract[0]))
		var layout := room.get_node_or_null("Phase2GrayboxLayout")
		assert_not_null(layout, "%s 必须把 Blueprint V2 实体结构接入生产场景。" % room_id)
		if layout != null:
			assert_eq(int(layout.call("get_segment_count")), int(contract[1]), "%s 屏段数必须与 V2 一致。" % room_id)
			assert_gt(int(layout.call("get_runtime_platform_count")), 0, "%s 不能只写屏段元数据。" % room_id)


func test_all_formal_rooms_have_runtime_layouts_with_blueprint_segment_counts() -> void:
	for room_id: String in FORMAL_ROOMS:
		var contract: Array = FORMAL_ROOMS[room_id]
		var room := await _spawn_room(str(contract[0]))
		var layout := room.get_node_or_null("Phase2GrayboxLayout")
		assert_not_null(layout, "%s 缺少生产灰盒结构真源。" % room_id)
		if layout != null:
			assert_eq(int(layout.call("get_segment_count")), int(contract[1]), "%s 屏段数与 V2 不一致。" % room_id)
			assert_gt(int(layout.call("get_runtime_platform_count")), 0, "%s 没有实体平台。" % room_id)


func test_f02_requires_clear_then_bounty_board_confirmation() -> void:
	var room := await _spawn_room(str(HIGH_GAP_ROOMS["F02"][0]))
	var player := await _spawn_player()
	var transitions: Array[Dictionary] = []
	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	var board := room.get_node_or_null("BountyBoardZone") as Node2D
	assert_not_null(board, "F02 清场后必须有可辨认的悬令确认节点。")
	if board == null:
		return

	room.call("_on_basic_melee_enemy_defeated")
	player.global_position = board.global_position
	await _advance_process_frames(2)
	assert_true(transitions.is_empty(), "F02 清场后接近悬令台不能自动切房。")
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(transitions.size(), 1, "F02 必须在悬令台确认后只切房一次。")


func test_f09_challenge_branch_waits_for_confirmation() -> void:
	var room := await _spawn_room(str(HIGH_GAP_ROOMS["F09"][0]))
	var player := await _spawn_player()
	var transitions: Array[Dictionary] = []
	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	player.global_position = (room.get_node("ChallengeBranchZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_true(transitions.is_empty(), "F09 高风险 F11 支路必须等待明确确认。")
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(transitions.size(), 1)


func test_f10_reward_is_explicit_and_exit_is_one_way_terrain() -> void:
	var room := await _spawn_room(str(HIGH_GAP_ROOMS["F10"][0]))
	assert_true(room.get("reward_requires_down_input") == true, "F10 遗物必须明确确认，不能仅靠贴近自动领取。")
	assert_not_null(room.get_node_or_null("OneWayExitZone"), "F10 必须以可读单向滑道/落点离开，而不是普通平地出口。")


func test_f14_main_exit_and_f07_altar_are_spatially_separated() -> void:
	var room := await _spawn_room(str(HIGH_GAP_ROOMS["F14"][0]))
	var main_exit := room.get_node("ExitZone") as Node2D
	var altar := room.get_node("ShortcutZone") as Node2D
	assert_gt(absf(main_exit.global_position.y - altar.global_position.y), 96.0, "F14 上层 F15 主路与下层 F07 祭坛必须明显分层。")
	assert_true(room.get("shortcut_requires_down_input") == true, "F07 祭坛必须主动确认。")


func test_f18_waystation_waits_for_confirmation_and_has_no_auto_exit() -> void:
	var room := await _spawn_room(str(HIGH_GAP_ROOMS["F18"][0]))
	var player := await _spawn_player()
	var transitions: Array[Dictionary] = []
	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	var waystation := room.get_node_or_null("WaystationZone") as Node2D
	assert_not_null(waystation, "F18 必须有独立归驿法坛。")
	assert_true(room.get("exit_requires_down_input") == true, "F18 法坛必须主动确认。")
	if waystation == null:
		return

	player.global_position = waystation.global_position
	await _advance_process_frames(2)
	assert_true(transitions.is_empty(), "F18 不能靠接近或跑出地板自动返回 Hub。")
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(transitions.size(), 1)


func test_remaining_v2_interactions_require_explicit_confirmation() -> void:
	var requirements := {
		"F05": ["wind_seal_requires_down_input", "WindSealShrine"],
		"F06": ["air_dash_revisit_reward_requires_down_input", "AirDashRevisitReward"],
		"F07": ["seal_node_requires_down_input", "SealNode"],
		"F08": ["checkpoint_requires_down_input", "CheckpointZone"],
		"F11": ["reward_requires_down_input", "Stage13Reward"],
		"F12": ["goal_requires_down_input", "GoalZone"],
		"F13": ["air_dash_shrine_requires_down_input", "AirDashShrine"],
		"F15": ["exit_requires_down_input", "ExitZone"],
		"F17": ["boss_entry_requires_down_input", "BossEntryZone"],
	}
	for room_id: String in requirements:
		var requirement: Array = requirements[room_id]
		var room := await _spawn_room(str(FORMAL_ROOMS[room_id][0]))
		assert_true(room.get(str(requirement[0])) == true, "%s 的 %s 必须使用 ui_down 确认。" % [room_id, requirement[1]])
		assert_not_null(room.get_node_or_null(str(requirement[1])), "%s 缺少交互节点 %s。" % [room_id, requirement[1]])


func test_f03_checkpoint_and_bounty_board_do_not_auto_trigger() -> void:
	var room := await _spawn_room(str(FORMAL_ROOMS["F03"][0]))
	var player := await _spawn_player()
	var goal_events: Array[bool] = []
	var board_events: Array[bool] = []
	room.call("bind_player", player)
	room.connect("goal_completed", func() -> void: goal_events.append(true))
	room.connect("bounty_board_requested", func() -> void: board_events.append(true))

	player.global_position = (room.get_node("GoalZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq(goal_events.size(), 0, "F03 checkpoint 不能走过即激活。")
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(goal_events.size(), 1)

	player.global_position = (room.get_node("BountyBoardZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq(board_events.size(), 0, "F03 赏榜不能贴近即弹出。")
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	assert_eq(board_events.size(), 1)


func test_f12_return_spawn_can_walk_back_to_f09() -> void:
	var room := await _spawn_room(str(FORMAL_ROOMS["F12"][0]))
	var player := await _spawn_player()
	room.call("bind_player", player)
	player.global_position = room.call("get_spawn_position", &"stage13_goal_return")
	await _advance_physics_frames(3)
	var start_x := player.global_position.x
	Input.action_press("move_left")
	await _advance_physics_frames(8)
	Input.action_release("move_left")
	assert_lt(player.global_position.x, start_x - 8.0, "F12 返回出生点必须有站立净空，能自然左行回到 F09。")


func _spawn_room(path: String) -> Node2D:
	var scene := load(path) as PackedScene
	assert_not_null(scene, "生产房间场景存在：%s" % path)
	var room := scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


func _spawn_player() -> CharacterBody2D:
	var scene := load(PLAYER_SCENE_PATH) as PackedScene
	assert_not_null(scene)
	var player := scene.instantiate() as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	return player


func _advance_process_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame


func _advance_physics_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().physics_frame
