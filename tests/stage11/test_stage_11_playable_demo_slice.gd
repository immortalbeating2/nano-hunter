extends GutTest
const Stage11GrayboxMainlineDriver := preload("res://tests/stage11/support/stage11_graybox_mainline_driver.gd")

# 阶段 11 回归测试保护“可交付试玩 Demo 切片”的最小闭环。
# 它覆盖主线终点、支路返回主线、HUD 完成反馈，以及终点房失败后的重来落点。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const STAGE10_MAIN_ROOM_SCENE_PATH := "res://scenes/rooms/stage10_zone_aerial_room.tscn"
const STAGE10_BRANCH_ROOM_SCENE_PATH := "res://scenes/rooms/stage10_zone_branch_room.tscn"
const STAGE10_CHALLENGE_ROOM_SCENE_PATH := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const STAGE11_DEMO_END_ROOM_SCENE_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"


# 保护灰盒主线 driver：从 Main 起点自动推进必须能抵达 Demo 终点。
func test_stage11_graybox_driver_can_finish_mainline_from_main_scene() -> void:
	var result: Dictionary = await Stage11GrayboxMainlineDriver.drive_mainline(self)

	assert_true(
		result.get("success", false),
		"灰盒主线自动化未完成：failure_reason=%s last_room=%s strategy=%s position=%s velocity=%s" % [
			result.get("failure_reason", ""),
			result.get("last_room_path", ""),
			result.get("last_strategy_step", ""),
			result.get("last_player_position", Vector2.ZERO),
			result.get("last_player_velocity", Vector2.ZERO),
		]
	)


# 保护 Stage10 主线出口：挑战房完成后必须能进入 Stage11 Demo 终点房。
func test_stage11_mainline_can_progress_from_stage10_into_demo_end_room() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE10_MAIN_ROOM_SCENE_PATH, &"stage10_aerial_start")
	await _advance_process_frames(2)

	var stage10_main_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(stage10_main_room)

	stage10_main_room.emit_signal("room_transition_requested", STAGE10_CHALLENGE_ROOM_SCENE_PATH, &"stage10_challenge_start")
	await _advance_process_frames(2)

	var challenge_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(challenge_room)
	assert_eq(challenge_room.scene_file_path, STAGE10_CHALLENGE_ROOM_SCENE_PATH)

	challenge_room.emit_signal("room_transition_requested", STAGE11_DEMO_END_ROOM_SCENE_PATH, &"stage11_demo_end_start")
	await _advance_process_frames(2)

	var demo_end_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(demo_end_room)
	assert_eq(demo_end_room.scene_file_path, STAGE11_DEMO_END_ROOM_SCENE_PATH)


# 保护支路回主线：从 Stage10 支路返回主房后仍能继续到挑战房和 Demo 终点。
func test_stage11_branch_room_can_return_to_mainline_and_still_reach_demo_end() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE10_BRANCH_ROOM_SCENE_PATH, &"stage10_branch_start")
	await _advance_process_frames(2)

	var branch_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(branch_room)
	assert_eq(branch_room.get("next_room_path"), STAGE10_MAIN_ROOM_SCENE_PATH)

	branch_room.emit_signal("room_transition_requested", branch_room.get("next_room_path"), branch_room.get("next_spawn_id"))
	await _advance_process_frames(2)

	var stage10_main_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(stage10_main_room)
	assert_eq(stage10_main_room.scene_file_path, STAGE10_MAIN_ROOM_SCENE_PATH)

	stage10_main_room.emit_signal("room_transition_requested", STAGE10_CHALLENGE_ROOM_SCENE_PATH, &"stage10_challenge_start")
	await _advance_process_frames(2)

	var challenge_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(challenge_room)
	challenge_room.emit_signal("room_transition_requested", STAGE11_DEMO_END_ROOM_SCENE_PATH, &"stage11_demo_end_start")
	await _advance_process_frames(2)

	assert_eq((main_scene.get_node_or_null("Room") as Node2D).scene_file_path, STAGE11_DEMO_END_ROOM_SCENE_PATH)


# 保护 Demo 完成反馈：终点房完成后 Main 快照和 HUD 都要显示完成状态。
func test_stage11_demo_completion_updates_main_snapshot_and_hud_feedback() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE11_DEMO_END_ROOM_SCENE_PATH, &"stage11_demo_end_start")
	await _advance_process_frames(2)

	var demo_end_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(demo_end_room)

	demo_end_room.emit_signal("goal_completed")
	await _advance_process_frames(2)

	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")
	var progress_label: Label = main_scene.get_node_or_null("HUD/TutorialHUD/BattlePanel/ProgressLabel") as Label

	assert_true(snapshot.get("demo_completed", false))
	assert_not_null(progress_label)
	assert_string_contains(progress_label.text, "Demo")
	assert_string_contains(progress_label.text, "完成")


# 保护终点房 checkpoint：玩家在 Demo 终点死亡后应重生在同一终点房。
func test_stage11_player_defeat_in_demo_end_room_respawns_at_demo_end_checkpoint() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE11_DEMO_END_ROOM_SCENE_PATH, &"stage11_demo_end_start")
	await _advance_process_frames(2)

	var player: CharacterBody2D = main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_not_null(player)

	await _defeat_player(player)
	await _advance_process_frames(4)
	await _advance_physics_frames(8)

	var reset_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(reset_room)
	assert_eq(reset_room.scene_file_path, STAGE11_DEMO_END_ROOM_SCENE_PATH)


# 测试辅助：统一生成 Main、推进帧与触发失败，避免每个用例重复拼装主流程入口。
# 创建 Main 场景并等待一帧，让默认房间、HUD 和玩家完成初始化。
func _spawn_main_scene() -> Node2D:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame
	return main_scene


# 主动打空玩家生命，用于验证 Demo 终点房的 checkpoint 恢复。
func _defeat_player(player: CharacterBody2D) -> void:
	for _i in range(3):
		await _advance_physics_frames(24)
		player.call("receive_damage", 1, Vector2.RIGHT)
		await _advance_physics_frames(2)


# 物理帧推进 helper 用于玩家受击、死亡和重生后的落地等待。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# process 帧推进 helper 用于等待 Main 切房、HUD 刷新和 goal_completed 处理。
func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame
