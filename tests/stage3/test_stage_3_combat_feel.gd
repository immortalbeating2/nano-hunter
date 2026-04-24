extends GutTest

# 阶段 3 回归测试保护最小攻击循环。
# 它验证攻击输入、攻击状态、命中朝向和训练木桩的基础受击契约。


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const TEST_ROOM_SCENE_PATH := "res://scenes/rooms/test_room.tscn"


class DummyTarget:
	extends StaticBody2D

	var hit_count: int = 0
	var last_hit_direction := Vector2.ZERO
	var last_knockback_force := 0.0

	func receive_attack(hit_direction: Vector2, knockback_force: float) -> void:
		hit_count += 1
		last_hit_direction = hit_direction
		last_knockback_force = knockback_force


# 输入环境清理：避免上一条测试遗留的攻击或移动输入污染本条结果。
func before_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")


func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")


func test_project_stage_3_adds_attack_action_with_default_events() -> void:
	assert_true(InputMap.has_action("attack"))
	assert_true(_project_action_has_default_events("attack"))


func test_player_enters_attack_state_and_recovers_to_idle() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))

	assert_eq(player.get("current_state"), &"idle")

	Input.action_press("attack")
	await _advance_physics_frames(2)
	Input.action_release("attack")

	assert_eq(player.get("current_state"), &"attack")

	await _wait_for_state(player, &"idle", 40)
	assert_eq(player.get("current_state"), &"idle")


func test_attack_hitbox_faces_current_direction() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))

	Input.action_press("move_left")
	await _advance_physics_frames(8)
	Input.action_release("move_left")

	var left_center: Vector2 = player.call("get_attack_hitbox_center")
	assert_lt(left_center.x, player.global_position.x)

	Input.action_press("move_right")
	await _advance_physics_frames(8)
	Input.action_release("move_right")

	var right_center: Vector2 = player.call("get_attack_hitbox_center")
	assert_gt(right_center.x, player.global_position.x)


func test_single_attack_hits_target_once_with_facing_direction() -> void:
	var world := Node2D.new()
	add_child_autofree(world)

	var player: CharacterBody2D = await _spawn_player_into_world(world, Vector2(0, 96))
	var target := _create_dummy_target(Vector2(28, 104))
	world.add_child(target)
	await _advance_physics_frames(2)

	Input.action_press("attack")
	await _advance_physics_frames(20)
	Input.action_release("attack")

	assert_eq(target.hit_count, 1)
	assert_gt(target.last_hit_direction.x, 0.0)
	assert_gt(target.last_knockback_force, 0.0)


func test_test_room_contains_training_dummy_with_receive_attack_contract() -> void:
	var packed_scene: PackedScene = load(TEST_ROOM_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var room: Node = packed_scene.instantiate()
	add_child_autofree(room)

	var training_dummy: Node = room.get_node_or_null("TrainingDummy")

	assert_not_null(training_dummy)
	assert_true(training_dummy.has_method("receive_attack"))


# 测试辅助：统一生成玩家、世界和木桩目标，保持各条攻击测试的铺场一致。
func _spawn_player_with_floor(spawn_position: Vector2) -> CharacterBody2D:
	var world := Node2D.new()
	add_child_autofree(world)
	return await _spawn_player_into_world(world, spawn_position)


func _spawn_player_into_world(world: Node2D, spawn_position: Vector2) -> CharacterBody2D:
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


func _create_dummy_target(target_position: Vector2) -> DummyTarget:
	var target := DummyTarget.new()
	target.position = target_position

	var collision_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(24, 48)
	collision_shape.shape = rectangle
	target.add_child(collision_shape)

	return target


func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


func _wait_for_state(player: CharacterBody2D, expected_state: StringName, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.get("current_state") == expected_state:
			return
		await _advance_physics_frames(1)

	fail_test("等待状态 %s 超时，当前为 %s" % [expected_state, player.get("current_state")])


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


func _project_action_has_default_events(action_name: String) -> bool:
	var action_config: Dictionary = ProjectSettings.get_setting("input/%s" % action_name, {})
	var action_events: Array = action_config.get("events", [])
	return not action_events.is_empty()
