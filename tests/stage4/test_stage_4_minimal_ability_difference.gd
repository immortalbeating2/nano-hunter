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


func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")
	if InputMap.has_action("dash"):
		Input.action_release("dash")


func test_project_stage_4_adds_dash_action_with_default_events() -> void:
	assert_true(InputMap.has_action("dash"))
	assert_true(_project_action_has_default_events("dash"))


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


func test_test_room_contains_stage_4_exploration_and_combat_gate_nodes() -> void:
	var packed_scene: PackedScene = load(TEST_ROOM_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var room: Node = packed_scene.instantiate()
	add_child_autofree(room)

	assert_not_null(room.get_node_or_null("DashGapLeft"))
	assert_not_null(room.get_node_or_null("DashGapRight"))
	assert_not_null(room.get_node_or_null("DashCombatDummy"))
	assert_not_null(room.get_node_or_null("DashGateCeiling"))


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


func _spawn_test_room_world() -> Node2D:
	var world := Node2D.new()
	add_child_autofree(world)

	var room_scene: PackedScene = load(TEST_ROOM_SCENE_PATH) as PackedScene
	var room := room_scene.instantiate() as Node2D
	world.add_child(room)
	await get_tree().physics_frame
	return world


func _spawn_player_into_room(world: Node2D, spawn_position: Vector2) -> CharacterBody2D:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	world.add_child(player)
	await _wait_until_player_is_settled(player, 64)
	return player


func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


func _wait_for_state(player: CharacterBody2D, expected_state: StringName, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.get("current_state") == expected_state:
			return
		await _advance_physics_frames(1)

	fail_test("绛夊緟鐘舵€?%s 瓒呮椂锛屽綋鍓嶄负 %s" % [expected_state, player.get("current_state")])


func _wait_until_not_state(player: CharacterBody2D, blocked_state: StringName, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.get("current_state") != blocked_state:
			return
		await _advance_physics_frames(1)

	fail_test("鐜╁鍦ㄩ鏈熷抚鏁板唴娌℃湁绂诲紑鐘舵€?%s" % [blocked_state])


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

	fail_test("鐜╁鍦ㄩ鏈熷抚鏁板唴娌℃湁绋冲畾钀藉湴")


func _project_action_has_default_events(action_name: String) -> bool:
	var action_config: Dictionary = ProjectSettings.get_setting("input/%s" % action_name, {})
	var action_events: Array = action_config.get("events", [])
	return not action_events.is_empty()
