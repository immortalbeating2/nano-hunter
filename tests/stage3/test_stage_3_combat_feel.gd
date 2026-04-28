extends GutTest

# 阶段 3 回归测试保护最小攻击循环。
# 它验证攻击输入、攻击状态、命中朝向和训练木桩的基础受击契约。


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const TEST_ROOM_SCENE_PATH := "res://scenes/rooms/test_room.tscn"


class DummyTarget:
	extends StaticBody2D

	# 测试替身只记录 receive_attack 的输入，不引入 BaseEnemy，避免阶段 3 过早依赖后续敌人基类。
	var hit_count: int = 0
	var last_hit_direction := Vector2.ZERO
	var last_knockback_force := 0.0

	# 测试替身实现玩家攻击契约，只记录调用参数而不参与生命或击败流程。
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


# 每条测试结束释放攻击和移动输入，防止攻击状态跨测试残留。
func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")


# 保护攻击输入契约：attack action 必须存在且带默认事件。
func test_project_stage_3_adds_attack_action_with_default_events() -> void:
	assert_true(InputMap.has_action("attack"))
	assert_true(_project_action_has_default_events("attack"))


# 保护攻击状态机：玩家按攻击后进入 attack，并能在恢复期结束后回到 idle。
func test_player_enters_attack_state_and_recovers_to_idle() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))

	assert_eq(player.get("current_state"), &"idle")

	Input.action_press("attack")
	await _advance_physics_frames(2)
	Input.action_release("attack")

	assert_eq(player.get("current_state"), &"attack")

	await _wait_for_state(player, &"idle", 40)
	assert_eq(player.get("current_state"), &"idle")


# 保护攻击判定朝向：攻击中心应跟随玩家最近水平朝向左右切换。
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


# 保护单次命中契约：一次攻击 active 窗口只能命中同一目标一次，并传递正确方向和击退力。
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


# 保护测试房训练木桩契约：场景中的 TrainingDummy 必须保留 receive_attack 入口。
func test_test_room_contains_training_dummy_with_receive_attack_contract() -> void:
	var packed_scene: PackedScene = load(TEST_ROOM_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var room: Node = packed_scene.instantiate()
	add_child_autofree(room)

	var training_dummy: Node = room.get_node_or_null("TrainingDummy")

	assert_not_null(training_dummy)
	assert_true(training_dummy.has_method("receive_attack"))


# 测试辅助：统一生成玩家、世界和木桩目标，保持各条攻击测试的铺场一致。
# 创建带地板的独立玩家实例，避免攻击测试依赖 Main 房间流程。
func _spawn_player_with_floor(spawn_position: Vector2) -> CharacterBody2D:
	var world := Node2D.new()
	add_child_autofree(world)
	return await _spawn_player_into_world(world, spawn_position)


# 将玩家放入指定测试世界，让攻击测试能同时摆放自定义目标。
func _spawn_player_into_world(world: Node2D, spawn_position: Vector2) -> CharacterBody2D:
	# 这里临时搭一个地板，是为了把攻击测试固定在稳定地面状态下。
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


# 构造只记录攻击参数的静态目标，用于验证攻击命中契约。
func _create_dummy_target(target_position: Vector2) -> DummyTarget:
	# 目标碰撞盒尺寸贴近早期训练木桩，保证攻击判定中心和朝向测试有实际碰撞对象。
	var target := DummyTarget.new()
	target.position = target_position

	var collision_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(24, 48)
	collision_shape.shape = rectangle
	target.add_child(collision_shape)

	return target


# 物理帧推进 helper 用于攻击状态、碰撞检测和命中窗口推进。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# 等待攻击或移动状态切换到目标状态，超时则输出当前状态帮助定位。
func _wait_for_state(player: CharacterBody2D, expected_state: StringName, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.get("current_state") == expected_state:
			return
		await _advance_physics_frames(1)

	fail_test("等待状态 %s 超时，当前为 %s" % [expected_state, player.get("current_state")])


# 等待玩家稳定落地后再测攻击，避免起始重力状态影响攻击恢复断言。
func _wait_until_player_is_settled(player: CharacterBody2D, max_frames: int) -> void:
	# 等玩家稳定落地后再测攻击，否则跳跃 / 重力状态会干扰攻击恢复断言。
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


# 读取输入 action 默认事件，确认 project.godot 中的 attack 配置不是空 action。
func _project_action_has_default_events(action_name: String) -> bool:
	var action_config: Dictionary = ProjectSettings.get_setting("input/%s" % action_name, {})
	var action_events: Array = action_config.get("events", [])
	return not action_events.is_empty()
