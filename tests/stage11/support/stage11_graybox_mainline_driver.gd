extends RefCounted

# Stage11GrayboxMainlineDriver 负责在测试侧承载“灰盒主线自动化通关”的最小驾驶入口。
# 它复用真实房间推进与主流程切房，只通过现有生产主线来推进到 demo 终点，
# 并在失败时回收足够的运行态上下文帮助定位卡点。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const TUTORIAL_ROOM_SCENE_PATH := "res://scenes/rooms/tutorial_room.tscn"
const COMBAT_TRIAL_ROOM_SCENE_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const GOAL_TRIAL_ROOM_SCENE_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const STAGE9_ENTRY_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_entry_room.tscn"
const STAGE9_COMBAT_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_combat_room.tscn"
const STAGE9_CHARGER_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_charger_room.tscn"
const STAGE9_SWITCH_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_switch_room.tscn"
const STAGE9_FINAL_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_final_room.tscn"
const STAGE10_MAIN_ROOM_SCENE_PATH := "res://scenes/rooms/stage10_zone_aerial_room.tscn"
const STAGE10_CHALLENGE_ROOM_SCENE_PATH := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const STAGE11_DEMO_END_ROOM_SCENE_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"

const STAGE9_ENTRY_SPAWN_ID: StringName = &"zone_entry_start"


# 公开 driver 入口：加载真实 Main 场景并依次驾驶教程、战斗、Stage9/10 和 Demo 终点。
static func drive_mainline(test: GutTest) -> Dictionary:
	# 驱动入口只加载生产 Main.tscn，不拼装测试专用主流程，确保覆盖真实房间切换契约。
	var result := _make_result()
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	if packed_scene == null:
		result.failure_reason = "无法加载 Main.tscn"
		return result

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	test.add_child_autofree(main_scene)
	await test.get_tree().process_frame
	await _advance_process_frames(test, 2)

	if not await _drive_from_tutorial_to_goal_trial(test, main_scene, result):
		return _finalize_result(main_scene, result)

	if not await _drive_stage9_to_stage11_demo_end(test, main_scene, result):
		return _finalize_result(main_scene, result)

	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")
	if not snapshot.get("demo_completed", false):
		result.failure_reason = "已到达 stage11 终点房，但 demo_completed 未置为 true"
		return _finalize_result(main_scene, result)

	result.success = true
	result.failure_reason = ""
	return _finalize_result(main_scene, result)


# 驾驶早期三房间链路，保留为独立函数方便失败时判断卡在 Stage5-7 哪一段。
static func _drive_from_tutorial_to_goal_trial(test: GutTest, main_scene: Node2D, result: Dictionary) -> bool:
	if not await _drive_tutorial_room(test, main_scene, result):
		return false
	if not await _drive_combat_trial_room(test, main_scene, result):
		return false
	if not await _drive_goal_trial_room(test, main_scene, result):
		return false
	return true


# 驾驶 Stage9 到 Stage11 的内容链路，通过房间路径选择最小清房策略。
static func _drive_stage9_to_stage11_demo_end(test: GutTest, main_scene: Node2D, result: Dictionary) -> bool:
	# Stage9 之后房间数量变多，因此使用 scene_file_path 分派每个房间的最小通关策略。
	# 这里不是模拟真实手操，而是证明灰盒主链路可自动到达终点。
	while true:
		var room: Node2D = _get_room(main_scene)
		if room == null:
			result.failure_reason = "主场景缺少 Room 节点"
			return false

		match room.scene_file_path:
			STAGE9_ENTRY_ROOM_SCENE_PATH:
				if not await _clear_linear_exit_room(test, main_scene, result, "stage9_entry"):
					return false
			STAGE9_COMBAT_ROOM_SCENE_PATH:
				if not await _clear_enemy_gate_room(test, main_scene, result, "stage9_combat"):
					return false
			STAGE9_CHARGER_ROOM_SCENE_PATH:
				if not await _clear_enemy_gate_room(test, main_scene, result, "stage9_charger"):
					return false
			STAGE9_SWITCH_ROOM_SCENE_PATH:
				if not await _clear_switch_gate_room(test, main_scene, result):
					return false
			STAGE9_FINAL_ROOM_SCENE_PATH:
				if not await _clear_enemy_gate_room(test, main_scene, result, "stage9_final"):
					return false
			STAGE10_MAIN_ROOM_SCENE_PATH:
				if not await _clear_enemy_gate_room(test, main_scene, result, "stage10_main"):
					return false
			STAGE10_CHALLENGE_ROOM_SCENE_PATH:
				if not await _clear_enemy_gate_room(test, main_scene, result, "stage10_challenge"):
					return false
			STAGE11_DEMO_END_ROOM_SCENE_PATH:
				return await _finish_demo_end_room(test, main_scene, result)
			_:
				result.failure_reason = "遇到未覆盖的房间: %s" % room.scene_file_path
				return false

	return false


# 驾驶教程房：用位置和木桩命中触发教程步骤，验证房间流程而不重复测试输入手感。
static func _drive_tutorial_room(test: GutTest, main_scene: Node2D, result: Dictionary) -> bool:
	# 教程房直接把玩家放到关键阈值位置，用来验证房间步骤和 Main 切房，而不是验证输入手感。
	var room: Node2D = _get_room(main_scene)
	if room == null or room.scene_file_path != TUTORIAL_ROOM_SCENE_PATH:
		result.failure_reason = "教程房起点异常"
		return false

	var player := _get_player(main_scene)
	if player == null:
		result.failure_reason = "教程房缺少玩家"
		return false

	result.last_strategy_step = "tutorial_move_jump"
	player.global_position = Vector2(-48.0, 32.0)
	await _advance_process_frames(test, 2)

	result.last_strategy_step = "tutorial_dash_gate"
	player.global_position = Vector2(252.0, 96.0)
	await _advance_process_frames(test, 2)

	result.last_strategy_step = "tutorial_attack_dummy"
	var dummy: Node = room.get_node_or_null("TutorialDummy")
	if dummy == null or not dummy.has_method("receive_attack"):
		result.failure_reason = "教程房缺少可攻击训练目标"
		return false
	dummy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(test, 2)

	result.last_strategy_step = "tutorial_exit"
	player.global_position = Vector2(796.0, 96.0)
	await _advance_process_frames(test, 4)

	if _get_room(main_scene).scene_file_path != COMBAT_TRIAL_ROOM_SCENE_PATH:
		result.failure_reason = "教程房未推进到 CombatTrialRoom"
		return false

	return true


# 驾驶战斗试炼房：击败基础敌人后移动到出口，验证清敌开门和切到目标房。
static func _drive_combat_trial_room(test: GutTest, main_scene: Node2D, result: Dictionary) -> bool:
	result.last_strategy_step = "combat_trial_clear"
	if not await _defeat_enemy_node(test, main_scene, "BasicMeleeEnemy"):
		result.failure_reason = "CombatTrialRoom 清敌失败"
		return false

	result.last_strategy_step = "combat_trial_exit"
	return await _move_player_to_exit_zone(test, main_scene, GOAL_TRIAL_ROOM_SCENE_PATH, "CombatTrialRoom 未推进到 GoalTrialRoom")


# 驾驶目标房：击败敌人解锁目标区，然后进入目标区完成短链路。
static func _drive_goal_trial_room(test: GutTest, main_scene: Node2D, result: Dictionary) -> bool:
	result.last_strategy_step = "goal_trial_clear"
	if not await _defeat_enemy_node(test, main_scene, "BasicMeleeEnemy"):
		result.failure_reason = "GoalTrialRoom 清敌失败"
		return false

	result.last_strategy_step = "goal_trial_complete"
	var room: Node2D = _get_room(main_scene)
	var player := _get_player(main_scene)
	if room == null or player == null:
		result.failure_reason = "GoalTrialRoom 运行态缺失"
		return false

	var goal_zone: Area2D = room.get_node_or_null("GoalZone") as Area2D
	if goal_zone == null:
		result.failure_reason = "GoalTrialRoom 缺少 GoalZone"
		return false

	player.global_position = goal_zone.global_position
	await _advance_process_frames(test, 4)

	return true


# 清理无额外门控的线性出口房，主要用于 Stage9 入口房。
static func _clear_linear_exit_room(test: GutTest, main_scene: Node2D, result: Dictionary, strategy_name: String) -> bool:
	result.last_strategy_step = strategy_name + "_exit"
	return await _move_player_to_exit_zone(test, main_scene, "", "")


# 清理敌人门控房：统一击败可攻击子节点，再通过出口区触发下一房。
static func _clear_enemy_gate_room(test: GutTest, main_scene: Node2D, result: Dictionary, strategy_name: String) -> bool:
	# 敌人门控房统一调用 receive_attack，避免 driver 依赖具体敌人 AI 或移动时机。
	result.last_strategy_step = strategy_name + "_clear_enemies"
	var room: Node2D = _get_room(main_scene)
	if room == null:
		result.failure_reason = "缺少当前房间"
		return false

	for child in room.get_children():
		if child.has_method("receive_attack"):
			child.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(test, 3)

	result.last_strategy_step = strategy_name + "_exit"
	return await _move_player_to_exit_zone(test, main_scene, "", "")


# 清理开关门房：把玩家移动到 GateSwitch，再走出口推进。
static func _clear_switch_gate_room(test: GutTest, main_scene: Node2D, result: Dictionary) -> bool:
	result.last_strategy_step = "stage9_switch_activate"
	var room: Node2D = _get_room(main_scene)
	var player := _get_player(main_scene)
	if room == null or player == null:
		result.failure_reason = "Stage9 switch room 运行态缺失"
		return false

	var gate_switch: Area2D = room.get_node_or_null("GateSwitch") as Area2D
	if gate_switch == null:
		result.failure_reason = "Stage9 switch room 缺少 GateSwitch"
		return false

	player.global_position = gate_switch.global_position
	await _advance_process_frames(test, 3)

	result.last_strategy_step = "stage9_switch_exit"
	return await _move_player_to_exit_zone(test, main_scene, "", "")


# 完成 Demo 终点房：移动到 GoalZone，让房间自己的完成逻辑发出 goal_completed。
static func _finish_demo_end_room(test: GutTest, main_scene: Node2D, result: Dictionary) -> bool:
	result.last_strategy_step = "stage11_finish_demo"
	var room: Node2D = _get_room(main_scene)
	var player := _get_player(main_scene)
	if room == null or player == null:
		result.failure_reason = "Stage11 终点房运行态缺失"
		return false

	var goal_zone: Area2D = room.get_node_or_null("GoalZone") as Area2D
	if goal_zone == null:
		result.failure_reason = "Stage11 终点房缺少 GoalZone"
		return false

	player.global_position = goal_zone.global_position
	await _advance_process_frames(test, 4)

	return true


# 击败当前房间中的指定敌人节点，保护早期固定命名敌人的清房流程。
static func _defeat_enemy_node(test: GutTest, main_scene: Node2D, node_name: String) -> bool:
	var room: Node2D = _get_room(main_scene)
	if room == null:
		return false

	var enemy: Node = room.get_node_or_null(node_name)
	if enemy == null or not enemy.has_method("receive_attack"):
		return false

	enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(test, 3)
	return true


# 将玩家移动到当前房间 ExitZone，并在需要时校验切房结果。
static func _move_player_to_exit_zone(test: GutTest, main_scene: Node2D, expected_room_path: String, fail_message: String) -> bool:
	# 出口推进仍通过房间自己的 _process 判定触发，所以这里移动玩家后等待若干帧。
	var room: Node2D = _get_room(main_scene)
	var player := _get_player(main_scene)
	if room == null or player == null:
		return false

	var exit_zone: Area2D = room.get_node_or_null("ExitZone") as Area2D
	if exit_zone == null:
		return false

	player.global_position = exit_zone.global_position
	await _advance_process_frames(test, 4)

	if expected_room_path.is_empty():
		return true

	if _get_room(main_scene).scene_file_path != expected_room_path:
		return false

	return true


# process 帧推进 helper 用于等待房间 _process、信号切房和 HUD 更新。
static func _advance_process_frames(test: GutTest, frame_count: int) -> void:
	for _i in range(frame_count):
		await test.get_tree().process_frame


# 读取当前 Main 下的 Room 节点，集中处理路径，方便以后 Main 结构调整。
static func _get_room(main_scene: Node2D) -> Node2D:
	return main_scene.get_node_or_null("Room") as Node2D


# 读取当前运行时玩家，driver 不直接持久缓存玩家引用以适配切房重生。
static func _get_player(main_scene: Node2D) -> CharacterBody2D:
	return main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


# 读取 HUD 文本，用于失败结果中保留当前玩家看到的步骤和提示。
static func _get_label_text(main_scene: Node2D, node_path: NodePath) -> String:
	var label: Label = main_scene.get_node_or_null(node_path) as Label
	return label.text if label != null else ""


# 创建统一结果字典，成功和失败都使用同一组字段，方便断言输出。
static func _make_result() -> Dictionary:
	# 失败结果保留最后房间、HUD 文案和玩家位置，便于阶段收口时快速定位卡在哪个灰盒节点。
	return {
		"success": false,
		"failure_reason": "未知失败",
		"last_room_path": "",
		"last_step_label": "",
		"last_prompt_label": "",
		"last_player_position": Vector2.ZERO,
		"last_player_velocity": Vector2.ZERO,
		"last_strategy_step": "bootstrap",
		"target_room_path": STAGE11_DEMO_END_ROOM_SCENE_PATH,
	}


# 补齐最终运行态上下文，确保失败信息包含房间、HUD 和玩家位置。
static func _finalize_result(main_scene: Node2D, result: Dictionary) -> Dictionary:
	# 无论成功失败都在结束前补齐上下文，调用方可以直接把结果写入断言信息。
	if main_scene == null:
		return result

	var room: Node2D = _get_room(main_scene)
	var player := _get_player(main_scene)
	result.last_room_path = room.scene_file_path if room != null else ""
	result.last_step_label = _get_label_text(main_scene, "HUD/TutorialHUD/PromptPanel/StepLabel")
	result.last_prompt_label = _get_label_text(main_scene, "HUD/TutorialHUD/PromptPanel/PromptLabel")
	result.last_player_position = player.global_position if player != null else Vector2.ZERO
	result.last_player_velocity = player.velocity if player != null else Vector2.ZERO
	return result
