extends RefCounted

# Stage16AlphaDemoGrayboxDriver 负责在测试侧承载 Alpha Demo 候选主线的最小自动化。
# 它只驱动生产 Main.tscn 和真实房间节点，不拼装测试专用主流程；失败时返回房间、HUD 和策略步骤，
# 方便阶段收口时定位卡在 Stage15 接入、Stage16 五房链路，还是终点完成反馈。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const STAGE15_COMPLETION_ROOM_PATH := "res://scenes/rooms/stage15_completion_room.tscn"
const STAGE16_SEAL_RELEASE_THRESHOLD_ROOM_PATH := "res://scenes/rooms/stage16_seal_release_threshold_room.tscn"
const STAGE16_TALISMAN_RELAY_ROOM_PATH := "res://scenes/rooms/stage16_talisman_relay_room.tscn"
const STAGE16_BACKTRACK_CONFIRMATION_ROOM_PATH := "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn"
const STAGE16_CORRUPTION_PURGE_ROOM_PATH := "res://scenes/rooms/stage16_corruption_purge_room.tscn"
const STAGE16_ALPHA_DEMO_END_ROOM_PATH := "res://scenes/rooms/stage16_alpha_demo_end_room.tscn"


# 公开 driver 入口：从 Main 加载后跳到 Stage15 完成房，验证真实接入能一路推进到 Stage16 终点。
static func drive_to_stage16_alpha_demo_end(test: GutTest) -> Dictionary:
	var result := _make_result()
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	if packed_scene == null:
		result.failure_reason = "无法加载 Main.tscn"
		return result

	var main_scene := packed_scene.instantiate() as Node2D
	test.add_child_autofree(main_scene)
	await _advance_process_frames(test, 2)

	if not main_scene.has_method("transition_to_room"):
		result.failure_reason = "Main 缺少 transition_to_room 公开入口"
		return _finalize_result(main_scene, result)

	if main_scene.has_method("start_demo"):
		main_scene.call("start_demo")
		await _advance_process_frames(test, 2)

	_prepare_stage16_preconditions(main_scene)
	main_scene.call("transition_to_room", STAGE15_COMPLETION_ROOM_PATH, &"stage15_completion_start")
	await _advance_process_frames(test, 4)

	if not await _drive_stage16_chain(test, main_scene, result):
		return _finalize_result(main_scene, result)

	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot") if main_scene.has_method("get_demo_progress_snapshot") else {}
	if not bool(snapshot.get("stage16_alpha_demo_completed", false)):
		result.failure_reason = "已到达 Stage16 终点，但 Main 快照未标记 stage16_alpha_demo_completed"
		return _finalize_result(main_scene, result)

	result.success = true
	result.failure_reason = ""
	return _finalize_result(main_scene, result)


# Stage16 五房链路只走出口、必要交互点和可攻击节点，保护灰盒主线可达性。
static func _drive_stage16_chain(test: GutTest, main_scene: Node2D, result: Dictionary) -> bool:
	var safety := 0
	while safety < 12:
		safety += 1
		var room := _get_room(main_scene)
		var player := _get_player(main_scene)
		if room == null or player == null:
			result.failure_reason = "Stage16 driver 缺少当前房间或玩家"
			return false

		if room.scene_file_path == STAGE16_ALPHA_DEMO_END_ROOM_PATH:
			result.last_strategy_step = "stage16_finish_alpha_demo"
			var goal_zone := room.get_node_or_null("ExitZone") as Node2D
			if goal_zone == null:
				result.failure_reason = "Stage16 终点房缺少 ExitZone"
				return false
			player.global_position = goal_zone.global_position
			await _advance_process_frames(test, 4)
			return true

		match room.scene_file_path:
			STAGE15_COMPLETION_ROOM_PATH:
				result.last_strategy_step = "stage15_completion_to_stage16"
				if not await _move_player_to_exit_zone(test, main_scene, result):
					return false
				if _get_room(main_scene) != null and _get_room(main_scene).scene_file_path == STAGE15_COMPLETION_ROOM_PATH:
					result.failure_reason = "Stage15 completion room 出口没有切到 Stage16 入口"
					return false
			STAGE16_SEAL_RELEASE_THRESHOLD_ROOM_PATH:
				result.last_strategy_step = "stage16_seal_release_threshold_exit"
				_activate_optional_node(room, player, "SealReleaseNode")
				await _advance_process_frames(test, 3)
				if not await _move_player_to_exit_zone(test, main_scene, result):
					return false
			STAGE16_TALISMAN_RELAY_ROOM_PATH:
				result.last_strategy_step = "stage16_talisman_relay_exit"
				for relay_name in ["TalismanRelayA", "TalismanRelayB", "TalismanRelayC"]:
					_activate_optional_node(room, player, relay_name)
					await _advance_process_frames(test, 3)
				if not await _move_player_to_exit_zone(test, main_scene, result):
					return false
			STAGE16_BACKTRACK_CONFIRMATION_ROOM_PATH:
				result.last_strategy_step = "stage16_backtrack_confirmation_exit"
				_activate_optional_node(room, player, "BacktrackConfirmationNode")
				await _advance_process_frames(test, 3)
				if not await _move_player_to_exit_zone(test, main_scene, result):
					return false
			STAGE16_CORRUPTION_PURGE_ROOM_PATH:
				result.last_strategy_step = "stage16_corruption_purge_clear"
				_activate_optional_node(room, player, "CorruptionPurgeNode")
				_defeat_room_targets(room)
				await _advance_process_frames(test, 3)
				if not await _move_player_to_exit_zone(test, main_scene, result):
					return false
			_:
				result.failure_reason = "遇到未覆盖的 Stage16 主线房间: %s" % room.scene_file_path
				return false

	return false


# Stage16 driver 从 Stage15 completion 开始，因此显式补齐前置回溯和 Boss 状态。
static func _prepare_stage16_preconditions(main_scene: Node2D) -> void:
	if main_scene.has_method("unlock_air_dash"):
		main_scene.call("unlock_air_dash")
	if main_scene.has_method("collect_stage14_backtrack_reward"):
		main_scene.call("collect_stage14_backtrack_reward", &"stage14_reward_one")
		main_scene.call("collect_stage14_backtrack_reward", &"stage14_reward_two")
		main_scene.call("collect_stage14_backtrack_reward", &"stage14_reward_three")
	if main_scene.has_method("mark_stage15_boss_defeated"):
		main_scene.call("mark_stage15_boss_defeated")


# 可选交互点以节点名约定驱动；节点不存在时不直接失败，避免 driver 过度绑定房间内部细节。
static func _activate_optional_node(room: Node2D, player: CharacterBody2D, node_name: String) -> void:
	var marker := room.get_node_or_null(node_name) as Node2D
	if marker != null:
		player.global_position = marker.global_position


# 净化房允许通过 receive_attack 清理可攻击目标，专注验证门控推进而非敌人 AI。
static func _defeat_room_targets(room: Node2D) -> void:
	for child in room.get_children():
		if child.has_method("receive_attack"):
			child.call("receive_attack", Vector2.RIGHT, 120.0)


# 将玩家移动到当前房间出口；缺少出口直接写入失败原因。
static func _move_player_to_exit_zone(test: GutTest, main_scene: Node2D, result: Dictionary) -> bool:
	var room := _get_room(main_scene)
	var player := _get_player(main_scene)
	if room == null or player == null:
		result.failure_reason = "移动出口前缺少当前房间或玩家"
		return false

	var exit_zone := room.get_node_or_null("ExitZone") as Node2D
	if exit_zone == null:
		result.failure_reason = "%s 缺少 ExitZone" % room.scene_file_path
		return false

	player.global_position = exit_zone.global_position
	await _advance_process_frames(test, 4)
	return true


# process 帧推进用于等待房间触发、信号切房和 HUD 刷新。
static func _advance_process_frames(test: GutTest, frame_count: int) -> void:
	for _i in range(frame_count):
		await test.get_tree().process_frame


# 读取 Main 当前房间，集中隔离节点路径。
static func _get_room(main_scene: Node2D) -> Node2D:
	return main_scene.get_node_or_null("Room") as Node2D


# 读取当前运行时玩家；切房后每次重新读取，避免缓存旧实例。
static func _get_player(main_scene: Node2D) -> CharacterBody2D:
	return main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


# 创建 driver 统一结果，失败和成功都带上下文。
static func _make_result() -> Dictionary:
	return {
		"success": false,
		"failure_reason": "未知失败",
		"last_room_path": "",
		"last_step_label": "",
		"last_prompt_label": "",
		"last_progress_label": "",
		"last_player_position": Vector2.ZERO,
		"last_strategy_step": "bootstrap",
		"target_room_path": STAGE16_ALPHA_DEMO_END_ROOM_PATH,
	}


# 补齐最终运行态上下文，便于 GUT 断言输出定位 Stage16 回归点。
static func _finalize_result(main_scene: Node2D, result: Dictionary) -> Dictionary:
	if main_scene == null:
		return result

	var room := _get_room(main_scene)
	var player := _get_player(main_scene)
	result.last_room_path = room.scene_file_path if room != null else ""
	result.last_step_label = _get_label_text(main_scene, "HUD/TutorialHUD/PromptPanel/StepLabel")
	result.last_prompt_label = _get_label_text(main_scene, "HUD/TutorialHUD/PromptPanel/PromptLabel")
	result.last_progress_label = _get_label_text(main_scene, "HUD/TutorialHUD/BattlePanel/ProgressLabel")
	result.last_player_position = player.global_position if player != null else Vector2.ZERO
	return result


# 安全读取 HUD 文本，失败结果中保留玩家实际看到的信息。
static func _get_label_text(main_scene: Node2D, node_path: NodePath) -> String:
	var label := main_scene.get_node_or_null(node_path) as Label
	return label.text if label != null else ""
