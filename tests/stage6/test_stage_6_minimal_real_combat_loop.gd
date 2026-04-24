extends GutTest

# 阶段 6 回归测试保护最小真实战斗循环。
# 它聚焦教程后第一段实战压力、玩家生命 / 受击 / defeated，以及战斗房局部重置。


const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const TUTORIAL_ROOM_SCENE_PATH := "res://scenes/rooms/tutorial_room.tscn"
const COMBAT_ROOM_SCENE_PATH := "res://scenes/rooms/combat_trial_room.tscn"

var _health_signal_values: Array[int] = []
var _defeated_signal_count := 0


# 输入与信号缓存清理：每条测试都从空输入、空信号记录开始。
func before_each() -> void:
	_reset_input_actions()
	_health_signal_values.clear()
	_defeated_signal_count = 0


func after_each() -> void:
	_reset_input_actions()


func test_main_transitions_from_tutorial_room_to_combat_trial_room() -> void:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame

	var tutorial_room: Node2D = main_scene.get_node_or_null("Room") as Node2D

	assert_not_null(tutorial_room)
	assert_eq(tutorial_room.scene_file_path, TUTORIAL_ROOM_SCENE_PATH)
	assert_true(tutorial_room.has_signal("room_transition_requested"))

	main_scene.call("transition_to_room", COMBAT_ROOM_SCENE_PATH, &"combat_entry")
	await _advance_process_frames(2)

	var combat_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	var step_label: Label = main_scene.get_node_or_null("HUD/TutorialHUD/PromptPanel/StepLabel") as Label
	var prompt_label: Label = main_scene.get_node_or_null("HUD/TutorialHUD/PromptPanel/PromptLabel") as Label

	assert_not_null(combat_room)
	assert_not_null(step_label)
	assert_not_null(prompt_label)
	assert_eq(combat_room.scene_file_path, COMBAT_ROOM_SCENE_PATH)
	assert_string_contains(step_label.text, "实战")
	assert_string_contains(prompt_label.text, "敌人")


func test_player_health_damage_invulnerability_and_defeated_signal() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))

	assert_eq(player.get("max_health"), 3)
	assert_eq(player.get("current_health"), 3)
	assert_true(player.has_signal("health_changed"))
	assert_true(player.has_signal("defeated"))

	player.health_changed.connect(_on_player_health_changed)
	player.defeated.connect(_on_player_defeated)

	player.call("receive_damage", 1, Vector2.RIGHT)
	await _advance_physics_frames(2)
	assert_eq(player.get("current_health"), 2)
	assert_eq(_health_signal_values, [2])
	assert_eq(_defeated_signal_count, 0)

	player.call("receive_damage", 1, Vector2.RIGHT)
	await _advance_physics_frames(2)
	assert_eq(player.get("current_health"), 2)
	assert_eq(_health_signal_values, [2])

	await _advance_physics_frames(24)
	player.call("receive_damage", 1, Vector2.RIGHT)
	await _advance_physics_frames(2)
	player.call("receive_damage", 1, Vector2.RIGHT)
	await _advance_physics_frames(24)
	player.call("receive_damage", 1, Vector2.RIGHT)
	await _advance_physics_frames(2)

	assert_eq(player.get("current_health"), 0)
	assert_eq(_defeated_signal_count, 1)
	assert_eq(_health_signal_values, [2, 1, 0])


func test_combat_trial_room_unlocks_exit_after_enemy_is_defeated() -> void:
	var packed_scene: PackedScene = load(COMBAT_ROOM_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var room: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame

	var enemy: Node2D = room.get_node_or_null("BasicMeleeEnemy") as Node2D

	assert_not_null(enemy)
	assert_false(room.call("is_exit_unlocked"))
	assert_string_contains(str(room.call("get_current_prompt_text")), "击败")

	enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(2)

	assert_true(room.call("is_exit_unlocked"))
	assert_string_contains(str(room.call("get_current_prompt_text")), "出口")


func test_combat_trial_room_keeps_first_enemy_pressure_within_reaction_range() -> void:
	var room: Node2D = await _spawn_combat_room()
	var enemy: Node2D = room.get_node_or_null("BasicMeleeEnemy") as Node2D
	var spawn_position: Vector2 = room.call("get_spawn_position", &"combat_entry")

	assert_not_null(enemy)
	assert_lte(spawn_position.distance_to(enemy.global_position), 224.0)


func test_player_damage_knockback_creates_clear_short_escape_window() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))
	var start_position := player.global_position

	player.call("receive_damage", 1, Vector2.RIGHT)
	await _advance_physics_frames(8)

	assert_gt(player.global_position.x - start_position.x, 24.0)
	assert_lt(player.global_position.y, start_position.y - 6.0)
	assert_eq(player.get("current_health"), 2)


func test_main_resets_current_combat_room_after_player_is_defeated() -> void:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame

	await _complete_tutorial_and_enter_combat(main_scene)

	var player: CharacterBody2D = main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	var status_label: Label = main_scene.get_node_or_null("HUD/TutorialHUD/BattlePanel/StatusLabel") as Label

	assert_not_null(player)
	assert_not_null(room)
	assert_not_null(status_label)
	assert_eq(room.scene_file_path, COMBAT_ROOM_SCENE_PATH)
	assert_eq(player.get("current_health"), 3)
	assert_string_contains(status_label.text, "■■■")

	player.call("receive_damage", 1, Vector2.RIGHT)
	await _advance_physics_frames(2)
	assert_string_contains(status_label.text, "■■□")

	await _defeat_player(player)
	await _advance_process_frames(4)
	await _advance_physics_frames(8)

	var reset_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	var reset_player: CharacterBody2D = main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var reset_enemy: Node2D = reset_room.get_node_or_null("BasicMeleeEnemy") as Node2D

	assert_not_null(reset_room)
	assert_not_null(reset_player)
	assert_not_null(reset_enemy)
	await _wait_until_player_is_settled(reset_player, 64)
	assert_eq(reset_room.scene_file_path, COMBAT_ROOM_SCENE_PATH)
	assert_eq(reset_player.get("current_health"), 3)
	assert_false(reset_room.call("is_exit_unlocked"))
	assert_string_contains(status_label.text, "■■■")

	var spawn_position: Vector2 = reset_room.call("get_spawn_position", &"combat_entry")
	assert_lt(reset_player.global_position.distance_to(spawn_position), 8.0)


# 测试辅助：统一生成战斗房、玩家和失败流程，避免各条测试自行拼接主线推进。
func _complete_tutorial_and_enter_combat(main_scene: Node2D) -> void:
	var room: Node2D = main_scene.get_node_or_null("Room") as Node2D

	assert_not_null(room)
	assert_true(room.has_signal("room_transition_requested"))
	main_scene.call("transition_to_room", COMBAT_ROOM_SCENE_PATH, &"combat_entry")
	await _advance_process_frames(2)


func _spawn_combat_room() -> Node2D:
	var packed_scene: PackedScene = load(COMBAT_ROOM_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var room: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


func _spawn_player_with_floor(spawn_position: Vector2) -> CharacterBody2D:
	var world := Node2D.new()
	add_child_autofree(world)

	var floor := StaticBody2D.new()
	floor.position = Vector2(0, 160)
	world.add_child(floor)

	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(1024, 32)
	floor_shape.shape = rectangle
	floor.add_child(floor_shape)

	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	world.add_child(player)
	await _wait_until_player_is_settled(player, 64)
	return player


func _defeat_player(player: CharacterBody2D) -> void:
	for _i in range(2):
		await _advance_physics_frames(24)
		player.call("receive_damage", 1, Vector2.RIGHT)
		await _advance_physics_frames(2)


func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


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


func _reset_input_actions() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")
	if InputMap.has_action("dash"):
		Input.action_release("dash")


func _on_player_health_changed(current_health: int, _max_health: int) -> void:
	_health_signal_values.append(current_health)


func _on_player_defeated() -> void:
	_defeated_signal_count += 1
