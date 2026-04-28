extends GutTest

# 阶段 4 回归测试保护“仅地面 dash”带来的最小能力差异。
# 它同时验证 dash 状态约束、探索门槛和接敌价值。


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const TEST_ROOM_SCENE_PATH := "res://scenes/rooms/test_room.tscn"


# 输入环境清理：确保 dash、attack 与移动状态不会跨测试串扰。
func before_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")
	if InputMap.has_action("dash"):
		Input.action_release("dash")


# 每条测试结束释放 dash / attack / movement 输入，避免能力状态被跨测试污染。
func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")
	if InputMap.has_action("dash"):
		Input.action_release("dash")


# 保护 dash 输入契约：dash action 必须存在且带默认事件。
func test_project_stage_4_adds_dash_action_with_default_events() -> void:
	assert_true(InputMap.has_action("dash"))
	assert_true(_project_action_has_default_events("dash"))


# 保护地面 dash 状态机：玩家在地面能进入 dash，并在冷却后回到 idle。
func test_player_enters_dash_state_on_ground_and_recovers() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))

	assert_eq(player.get("current_state"), &"idle")

	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")

	assert_eq(player.get("current_state"), &"dash")
	assert_gt(absf(player.velocity.x), player.get("max_run_speed"))

	await _wait_for_state(player, &"idle", 40)
	assert_eq(player.get("current_state"), &"idle")


# 保护 dash 可读性：冲刺期间 Body 颜色必须临时变化，结束后恢复。
func test_dash_temporarily_changes_body_color_for_readability() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))
	var body: Polygon2D = player.get_node("Body") as Polygon2D
	var idle_color: Color = body.color

	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")

	assert_eq(player.get("current_state"), &"dash")
	assert_ne(body.color, idle_color)

	await _wait_for_state(player, &"idle", 40)
	assert_eq(body.color, idle_color)


# 保护 Stage4 限制：本阶段 dash 只能在地面触发，不能提前变成空中 dash。
func test_player_cannot_dash_while_airborne() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))

	Input.action_press("jump")
	await _advance_physics_frames(2)
	Input.action_release("jump")
	await _wait_for_state(player, &"jump_rise", 10)

	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")

	assert_ne(player.get("current_state"), &"dash")


# 保护动作互斥：攻击恢复期间不能启动 dash，避免玩家取消攻击后摇。
func test_player_cannot_dash_during_attack() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))

	Input.action_press("attack")
	await _advance_physics_frames(2)
	Input.action_release("attack")
	assert_eq(player.get("current_state"), &"attack")

	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")

	assert_eq(player.get("current_state"), &"attack")


# 保护 dash 方向规则：有输入时按输入方向，无输入时沿当前朝向。
func test_dash_follows_input_direction_or_current_facing() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))

	Input.action_press("move_left")
	await _advance_physics_frames(8)
	Input.action_release("move_left")

	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")
	assert_eq(player.get("current_state"), &"dash")
	assert_lt(player.velocity.x, 0.0)

	await _wait_for_state(player, &"idle", 40)

	Input.action_press("move_right")
	await _advance_physics_frames(2)
	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("move_right")
	Input.action_release("dash")

	assert_eq(player.get("current_state"), &"dash")
	assert_gt(player.velocity.x, 0.0)


# 保护测试房 Stage4 灰盒节点：探索门、战斗目标和阻挡顶板都必须存在。
func test_test_room_contains_stage_4_exploration_and_combat_gate_nodes() -> void:
	var packed_scene: PackedScene = load(TEST_ROOM_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var room: Node = packed_scene.instantiate()
	add_child_autofree(room)

	assert_not_null(room.get_node_or_null("DashGapLeft"))
	assert_not_null(room.get_node_or_null("DashGapRight"))
	assert_not_null(room.get_node_or_null("DashCombatDummy"))
	assert_not_null(room.get_node_or_null("DashGateCeiling"))


# 保护探索价值：普通奔跑不能稳定穿过 gap，dash 可以越过并落地。
func test_dash_gate_requires_dash_to_cross_stably() -> void:
	var room_root: Node2D = await _spawn_test_room_world()
	var room: Node2D = room_root.get_node("TestRoom") as Node2D
	var player: CharacterBody2D = await _spawn_player_into_room(room_root, Vector2(-84, 96))

	Input.action_press("move_right")
	await _advance_physics_frames(26)
	Input.action_release("move_right")

	assert_lt(player.global_position.x, 20.0)

	room_root.queue_free()
	await get_tree().process_frame

	room_root = await _spawn_test_room_world()
	room = room_root.get_node("TestRoom") as Node2D
	player = await _spawn_player_into_room(room_root, Vector2(-84, 96))

	Input.action_press("move_right")
	await _advance_physics_frames(6)
	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")
	Input.action_release("move_right")
	await _advance_physics_frames(14)

	assert_gt(player.global_position.x, 28.0)
	assert_true(player.is_on_floor())


# 保护战斗价值：dash 应显著缩短接敌距离，让玩家能更早命中 dash 木桩。
func test_dash_improves_combat_entry_timing_against_dash_combat_dummy() -> void:
	var room_root: Node2D = await _spawn_test_room_world()
	var room: Node2D = room_root.get_node("TestRoom") as Node2D
	var player: CharacterBody2D = await _spawn_player_into_room(room_root, Vector2(-84, 96))
	var dummy: StaticBody2D = room.get_node("DashCombatDummy") as StaticBody2D

	Input.action_press("move_right")
	await _advance_physics_frames(18)
	Input.action_press("attack")
	await _advance_physics_frames(10)
	Input.action_release("attack")
	Input.action_release("move_right")

	assert_eq(dummy.get("hit_count"), 0)

	room_root.queue_free()
	await get_tree().process_frame

	room_root = await _spawn_test_room_world()
	room = room_root.get_node("TestRoom") as Node2D
	player = await _spawn_player_into_room(room_root, Vector2(-84, 96))
	dummy = room.get_node("DashCombatDummy") as StaticBody2D

	Input.action_press("move_right")
	await _advance_physics_frames(6)
	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")
	await _wait_until_not_state(player, &"dash", 30)

	var attack_center: Vector2 = player.call("get_attack_hitbox_center")
	assert_ne(player.get("current_state"), &"dash")
	assert_gt(attack_center.x, dummy.global_position.x - 34.0)

	Input.action_press("attack")
	await _advance_physics_frames(12)
	Input.action_release("attack")
	Input.action_release("move_right")

	assert_eq(dummy.get("hit_count"), 1)


# 测试辅助：统一生成 dash 验证需要的房间、玩家和等待逻辑。
# 构造带地板的独立玩家世界，用于只验证 dash 状态机。
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


# 构造完整测试房世界，用于验证 dash gap 和 dash combat dummy 的空间价值。
func _spawn_test_room_world() -> Node2D:
	var world := Node2D.new()
	add_child_autofree(world)

	var room_scene: PackedScene = load(TEST_ROOM_SCENE_PATH) as PackedScene
	var room := room_scene.instantiate() as Node2D
	world.add_child(room)
	await get_tree().physics_frame
	return world


# 在测试房内生成玩家并等待落地，确保 dash 门控验证从稳定地面开始。
func _spawn_player_into_room(world: Node2D, spawn_position: Vector2) -> CharacterBody2D:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	world.add_child(player)
	await _wait_until_player_is_settled(player, 64)
	return player


# 物理帧推进 helper 用于 dash 位移、攻击窗口和落地判定。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# 等待玩家进入目标状态，保护 dash / attack 等短时状态不会被漏读。
func _wait_for_state(player: CharacterBody2D, expected_state: StringName, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.get("current_state") == expected_state:
			return
		await _advance_physics_frames(1)

	fail_test("等待状态 %s 超时，当前为 %s" % [expected_state, player.get("current_state")])


# 等待玩家离开指定状态，用于确认 dash 等短时状态已经结束。
func _wait_until_not_state(player: CharacterBody2D, blocked_state: StringName, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.get("current_state") != blocked_state:
			return
		await _advance_physics_frames(1)

	fail_test("玩家在预期帧数内没有离开状态：%s" % [blocked_state])


# 等待玩家稳定落地，避免出生下落或 dash 后残余速度影响断言。
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


# 读取输入 action 默认事件，确认 dash 配置不是空 action。
func _project_action_has_default_events(action_name: String) -> bool:
	var action_config: Dictionary = ProjectSettings.get_setting("input/%s" % action_name, {})
	var action_events: Array = action_config.get("events", [])
	return not action_events.is_empty()
