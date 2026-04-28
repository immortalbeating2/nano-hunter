extends GutTest

# 阶段 7 回归测试保护 Tutorial -> Combat -> Goal 的短链路主流程。
# 它验证三段房间串联、目标房完成态和战斗房失败只做局部重置。


const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const COMBAT_ROOM_SCENE_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const GOAL_ROOM_SCENE_PATH := "res://scenes/rooms/goal_trial_room.tscn"

# goal_completed 计数用于确认目标房完成信号只发一次。
var _goal_completed_count := 0


# 输入环境清理：保持短链路测试在同一套初始输入条件下运行。
func before_each() -> void:
	_reset_input_actions()
	_goal_completed_count = 0


# 每条短链路测试结束释放输入，避免失败重试和房间推进被残留动作污染。
func after_each() -> void:
	_reset_input_actions()


# 保护短主线串联：教程房能进入战斗房，清敌出门后能进入目标房，并同步 HUD。
func test_main_advances_from_tutorial_to_combat_to_goal_and_updates_hud() -> void:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame

	var tutorial_room: Node2D = main_scene.get_node_or_null("Room") as Node2D

	assert_not_null(tutorial_room)
	assert_true(tutorial_room.has_signal("room_transition_requested"))
	tutorial_room.emit_signal("room_transition_requested", COMBAT_ROOM_SCENE_PATH, &"combat_entry")
	await _advance_process_frames(2)

	var combat_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	var step_label: Label = main_scene.get_node_or_null("HUD/TutorialHUD/PromptPanel/StepLabel") as Label
	var prompt_label: Label = main_scene.get_node_or_null("HUD/TutorialHUD/PromptPanel/PromptLabel") as Label
	var player: CharacterBody2D = main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var combat_enemy: Node2D = combat_room.get_node_or_null("BasicMeleeEnemy") as Node2D
	var combat_exit_zone: Area2D = combat_room.get_node_or_null("ExitZone") as Area2D

	assert_not_null(combat_room)
	assert_not_null(step_label)
	assert_not_null(prompt_label)
	assert_not_null(player)
	assert_not_null(combat_enemy)
	assert_not_null(combat_exit_zone)
	assert_eq(combat_room.scene_file_path, COMBAT_ROOM_SCENE_PATH)
	assert_string_contains(step_label.text, "实战")

	combat_enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(2)
	player.global_position = combat_exit_zone.global_position
	await _advance_process_frames(2)

	var goal_room: Node2D = main_scene.get_node_or_null("Room") as Node2D

	assert_not_null(goal_room)
	assert_eq(goal_room.scene_file_path, GOAL_ROOM_SCENE_PATH)
	assert_string_contains(step_label.text, "目标")
	assert_string_contains(prompt_label.text, "目标")


# 保护目标房契约：击败敌人解锁目标门，进入目标区后发出完成信号。
func test_goal_trial_room_exposes_contract_unlocks_gate_and_completes_goal() -> void:
	var room: Node2D = await _spawn_goal_room()
	var player: CharacterBody2D = await _spawn_player_into_room(room, room.call("get_spawn_position", &"goal_entry"))
	var enemy: Node2D = room.get_node_or_null("BasicMeleeEnemy") as Node2D
	var barrier_shape: CollisionShape2D = room.get_node_or_null("GoalBarrier/CollisionShape2D") as CollisionShape2D
	var goal_zone: Area2D = room.get_node_or_null("GoalZone") as Area2D

	assert_not_null(player)
	assert_not_null(enemy)
	assert_not_null(barrier_shape)
	assert_not_null(goal_zone)
	assert_eq(room.call("get_current_step_id"), &"goal_gate")
	assert_false(room.call("is_goal_unlocked"))
	assert_false(room.call("should_reset_on_player_defeat"))

	if room.has_signal("goal_completed"):
		room.connect("goal_completed", Callable(self, "_on_goal_completed"))

	enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(2)

	assert_true(room.call("is_goal_unlocked"))
	assert_true(barrier_shape.disabled)
	assert_string_contains(str(room.call("get_current_prompt_text")), "目标")

	player.global_position = goal_zone.global_position
	await _advance_process_frames(2)

	assert_eq(room.call("get_current_step_id"), &"complete")
	assert_eq(_goal_completed_count, 1)


# 保护失败范围：短链路中战斗房死亡只重置当前战斗房，不退回教程房。
func test_main_keeps_combat_retry_local_in_short_chain() -> void:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame

	var tutorial_room: Node2D = main_scene.get_node_or_null("Room") as Node2D

	assert_not_null(tutorial_room)
	tutorial_room.emit_signal("room_transition_requested", COMBAT_ROOM_SCENE_PATH, &"combat_entry")
	await _advance_process_frames(2)

	var player: CharacterBody2D = main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var combat_room: Node2D = main_scene.get_node_or_null("Room") as Node2D

	assert_not_null(player)
	assert_not_null(combat_room)
	assert_eq(combat_room.scene_file_path, COMBAT_ROOM_SCENE_PATH)

	await _defeat_player(player)
	await _advance_process_frames(4)
	await _advance_physics_frames(8)

	var reset_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	var reset_player: CharacterBody2D = main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D

	assert_not_null(reset_room)
	assert_not_null(reset_player)
	assert_eq(reset_room.scene_file_path, COMBAT_ROOM_SCENE_PATH)
	assert_eq(reset_player.get("current_health"), 3)


# 测试辅助：统一生成目标房、玩家和失败流程，避免链路测试写重复铺场。
# 独立实例化目标房，用于验证目标门控和完成信号，不经过完整主线。
func _spawn_goal_room() -> Node2D:
	var packed_scene: PackedScene = load(GOAL_ROOM_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var room: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


# 在目标房内生成玩家并绑定房间，让目标区位置检测能读到玩家。
func _spawn_player_into_room(room: Node2D, spawn_position: Vector2) -> CharacterBody2D:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	room.add_child(player)
	if room.has_method("bind_player"):
		room.call("bind_player", player)
	await _wait_until_player_is_settled(player, 64)
	return player


# 主动打空玩家生命，用于验证 Main 对 defeated 信号的局部重置处理。
func _defeat_player(player: CharacterBody2D) -> void:
	for _i in range(3):
		await _advance_physics_frames(24)
		player.call("receive_damage", 1, Vector2.RIGHT)
		await _advance_physics_frames(2)


# 物理帧推进 helper 用于玩家受击、落地和死亡流程。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# process 帧推进 helper 用于等待 Main 切房和 HUD 刷新。
func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


# 等待玩家稳定落地，避免出生下落干扰目标区触发和受击流程。
func _wait_until_player_is_settled(player: CharacterBody2D, max_frames: int) -> void:
	for _i in range(max_frames):
		if (
			player.is_on_floor()
			and absf(player.velocity.x) <= 0.1
			and absf(player.velocity.y) <= 0.1
			and player.get("current_state") == &"idle"
		):
			await _advance_physics_frames(2)
			return

		await _advance_physics_frames(1)

	fail_test("玩家在预期帧数内没有稳定落地")


# 输入清理覆盖移动、跳跃、攻击和 dash，保证短链路测试相互隔离。
func _reset_input_actions() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")
	if InputMap.has_action("dash"):
		Input.action_release("dash")


# 目标完成信号回调只计数，用来保护 completion 不重复触发。
func _on_goal_completed() -> void:
	_goal_completed_count += 1
