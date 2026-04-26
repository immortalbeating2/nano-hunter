extends GutTest

# Stage 13 收口复核用例把人工清单固化为可重复的运行时驱动。
# 它不替代最终真人手感判断，但用于证明入口、主路、支路、危险、checkpoint 与门控都能在 Main.tscn 下串起来。
const Stage11GrayboxMainlineDriver := preload("res://tests/stage11/support/stage11_graybox_mainline_driver.gd")

const STAGE11_DEMO_END_ROOM_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const STAGE13_ENTRY_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_entry_room.tscn"
const STAGE13_ACID_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_acid_room.tscn"
const STAGE13_GATE_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_gate_room.tscn"
const STAGE13_CHECKPOINT_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_checkpoint_room.tscn"
const STAGE13_PRESSURE_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_pressure_room.tscn"
const STAGE13_BRANCH_HUB_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_branch_hub_room.tscn"
const STAGE13_RESOURCE_BRANCH_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_resource_branch_room.tscn"
const STAGE13_CHALLENGE_BRANCH_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_challenge_branch_room.tscn"
const STAGE13_RETURN_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_return_room.tscn"
const STAGE13_GOAL_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_goal_room.tscn"


func test_stage13_manual_review_checklist_runtime_closure() -> void:
	var stage11_result := await Stage11GrayboxMainlineDriver.drive_mainline(self)
	var main_scene: Node2D = _find_main_scene()

	assert_not_null(main_scene)
	assert_true(stage11_result.get("success"), stage11_result.get("failure_reason", "Stage 11 mainline failed"))
	assert_eq(_get_room_path(main_scene), STAGE11_DEMO_END_ROOM_PATH)
	assert_true(main_scene.call("get_demo_progress_snapshot").get("demo_completed", false))

	_continue_from_demo_end_to_stage13(main_scene)
	await _advance_process_frames(4)
	assert_eq(_get_room_path(main_scene), STAGE13_ENTRY_ROOM_PATH)

	var review := {
		"entered_stage13": true,
		"reached_goal": false,
		"resource_branch_completed": false,
		"challenge_branch_completed": false,
		"acid_feedback_triggered": false,
		"checkpoint_recovery_triggered": false,
		"purification_gate_verified": false,
	}

	var safety := 0
	while _get_room_path(main_scene) != STAGE13_GOAL_ROOM_PATH and safety < 30:
		safety += 1
		var current_path := _get_room_path(main_scene)

		match current_path:
			STAGE13_ACID_ROOM_PATH:
				review.acid_feedback_triggered = await _trigger_acid_feedback(main_scene)
				await _clear_current_room_to_next(main_scene)
			STAGE13_GATE_ROOM_PATH:
				review.purification_gate_verified = await _verify_purification_gate(main_scene)
				await _clear_current_room_to_next(main_scene)
			STAGE13_PRESSURE_ROOM_PATH:
				review.checkpoint_recovery_triggered = await _verify_checkpoint_recovery(main_scene)
				await _clear_current_room_to_next(main_scene)
			STAGE13_BRANCH_HUB_ROOM_PATH:
				review.resource_branch_completed = await _complete_resource_branch(main_scene)
				main_scene.call("transition_to_room", STAGE13_BRANCH_HUB_ROOM_PATH, &"stage13_branch_hub_start")
				await _advance_process_frames(4)
				review.challenge_branch_completed = await _complete_challenge_branch(main_scene)
			_:
				await _clear_current_room_to_next(main_scene)

		assert_ne(_get_room_path(main_scene), current_path, "Stage 13 room did not advance from %s" % current_path)

	review.reached_goal = true

	assert_lt(safety, 30, "Stage 13 manual closure driver exceeded safety limit at %s" % _get_room_path(main_scene))
	assert_true(review.entered_stage13)
	assert_true(review.reached_goal)
	assert_true(review.resource_branch_completed)
	assert_true(review.challenge_branch_completed)
	assert_true(review.acid_feedback_triggered)
	assert_true(review.checkpoint_recovery_triggered)
	assert_true(review.purification_gate_verified)


func _find_main_scene() -> Node2D:
	for child in get_children():
		if child.name == "Main":
			return child as Node2D

	return null


func _continue_from_demo_end_to_stage13(main_scene: Node2D) -> void:
	var room := _get_room(main_scene)
	var player := _get_player(main_scene)
	var continue_zone := room.get_node_or_null("ContinueZone") as Node2D
	if player != null and continue_zone != null:
		player.global_position = continue_zone.global_position


func _trigger_acid_feedback(main_scene: Node2D) -> bool:
	var room := _get_room(main_scene)
	var player := _get_player(main_scene)
	var acid_hazard := room.get_node_or_null("AcidHazard") as Node2D
	if player == null or acid_hazard == null:
		return false

	var health_before: int = player.call("get_current_health")
	player.global_position = acid_hazard.global_position
	await _advance_process_frames(3)
	return player.call("get_current_health") < health_before


func _verify_purification_gate(main_scene: Node2D) -> bool:
	var room := _get_room(main_scene)
	var player := _get_player(main_scene)
	if room == null or player == null:
		return false

	var locked_before: bool = not room.call("is_gate_unlocked")
	var purification_node := room.get_node_or_null("PurificationNode") as Node2D
	if purification_node == null:
		return false

	player.global_position = purification_node.global_position
	await _advance_process_frames(4)
	return locked_before and room.call("is_gate_unlocked") and room.call("is_purification_node_activated")


func _verify_checkpoint_recovery(main_scene: Node2D) -> bool:
	main_scene.call("_on_player_defeated")
	await _advance_process_frames(4)
	if _get_room_path(main_scene) != STAGE13_CHECKPOINT_ROOM_PATH:
		return false

	await _clear_current_room_to_next(main_scene)
	return _get_room_path(main_scene) == STAGE13_PRESSURE_ROOM_PATH


func _complete_resource_branch(main_scene: Node2D) -> bool:
	var hub_room := _get_room(main_scene)
	var player := _get_player(main_scene)
	var branch_zone := hub_room.get_node_or_null("ResourceBranchZone") as Node2D
	if player == null or branch_zone == null:
		return false

	player.global_position = branch_zone.global_position
	await _advance_process_frames(4)
	if _get_room_path(main_scene) != STAGE13_RESOURCE_BRANCH_ROOM_PATH:
		return false

	await _collect_branch_reward_and_exit(main_scene)
	return _get_room_path(main_scene) == STAGE13_RETURN_ROOM_PATH


func _complete_challenge_branch(main_scene: Node2D) -> bool:
	var hub_room := _get_room(main_scene)
	var player := _get_player(main_scene)
	var branch_zone := hub_room.get_node_or_null("ChallengeBranchZone") as Node2D
	if player == null or branch_zone == null:
		return false

	player.global_position = branch_zone.global_position
	await _advance_process_frames(4)
	if _get_room_path(main_scene) != STAGE13_CHALLENGE_BRANCH_ROOM_PATH:
		return false

	await _collect_branch_reward_and_exit(main_scene)
	return _get_room_path(main_scene) == STAGE13_RETURN_ROOM_PATH


func _collect_branch_reward_and_exit(main_scene: Node2D) -> void:
	var room := _get_room(main_scene)
	var player := _get_player(main_scene)
	var reward := room.get_node_or_null("Stage13Reward") as Node2D
	if player != null and reward != null:
		player.global_position = reward.global_position
		await _advance_process_frames(3)

	await _clear_current_room_to_next(main_scene)


func _clear_current_room_to_next(main_scene: Node2D) -> void:
	var room := _get_room(main_scene)
	var player := _get_player(main_scene)
	if room == null or player == null:
		return

	for child in room.get_children():
		if child.has_method("receive_attack"):
			child.call("receive_attack", Vector2.RIGHT, 120.0)

	if room.has_method("unlock_gate") and room.scene_file_path != STAGE13_GATE_ROOM_PATH:
		room.call("unlock_gate", &"clear")

	var target_zone := room.get_node_or_null("GoalZone") as Node2D
	if target_zone == null:
		target_zone = room.get_node_or_null("ExitZone") as Node2D

	if target_zone == null:
		return

	player.global_position = target_zone.global_position
	await _advance_process_frames(4)


func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


func _get_room(main_scene: Node2D) -> Node2D:
	return main_scene.get_node_or_null("Room") as Node2D


func _get_player(main_scene: Node2D) -> CharacterBody2D:
	return main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


func _get_room_path(main_scene: Node2D) -> String:
	var room := _get_room(main_scene)
	return room.scene_file_path if room != null else ""
