extends GutTest


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const SETTLED_PLAYER_Y := 123.0


func before_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")


func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")


func test_project_stage_2_uses_named_input_actions_and_disables_better_terrain() -> void:
	assert_true(InputMap.has_action("move_left"))
	assert_true(InputMap.has_action("move_right"))
	assert_true(InputMap.has_action("jump"))
	assert_true(_project_action_has_default_events("move_left"))
	assert_true(_project_action_has_default_events("move_right"))
	assert_true(_project_action_has_default_events("jump"))

	var enabled_plugins: PackedStringArray = ProjectSettings.get_setting(
		"editor_plugins/enabled",
		PackedStringArray()
	)

	assert_false(enabled_plugins.has("res://addons/better-terrain/plugin.cfg"))


func test_main_scene_spawns_one_stage_2_player_with_readable_state_and_tuning() -> void:
	var packed_scene: PackedScene = load("res://scenes/main/main.tscn") as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node = packed_scene.instantiate()
	add_child_autofree(main_scene)

	var runtime: Node2D = main_scene.get_node_or_null("Runtime") as Node2D

	assert_not_null(runtime)
	assert_eq(runtime.get_child_count(), 1)

	var player: CharacterBody2D = runtime.get_child(0) as CharacterBody2D

	assert_not_null(player)
	assert_eq(player.get("current_state"), &"idle")
	assert_true(_has_property(player, "max_run_speed"))
	assert_true(_has_property(player, "ground_acceleration"))
	assert_true(_has_property(player, "ground_deceleration"))
	assert_true(_has_property(player, "air_acceleration"))
	assert_true(_has_property(player, "jump_velocity"))
	assert_true(_has_property(player, "jump_cut_ratio"))
	assert_true(_has_property(player, "rise_gravity"))
	assert_true(_has_property(player, "fall_gravity"))
	assert_true(_has_property(player, "max_fall_speed"))
	assert_true(_has_property(player, "coyote_time_window"))
	assert_true(_has_property(player, "jump_buffer_window"))
	assert_true(_has_property(player, "landing_state_duration"))


func test_player_enters_run_and_idle_states_from_horizontal_input() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))

	assert_not_null(player)
	assert_eq(player.get("current_state"), &"idle")

	Input.action_press("move_right")
	await _advance_physics_frames(20)
	Input.action_release("move_right")

	assert_eq(player.get("current_state"), &"run")
	assert_gt(player.velocity.x, 0.0)

	await _advance_physics_frames(20)

	assert_eq(player.get("current_state"), &"idle")
	assert_almost_eq(player.velocity.x, 0.0, 0.5)


func test_player_jumps_then_transitions_to_fall() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))

	assert_not_null(player)

	Input.action_press("jump")
	await _advance_physics_frames(2)
	Input.action_release("jump")

	assert_eq(player.get("current_state"), &"jump_rise")
	assert_lt(player.velocity.y, 0.0)

	await _wait_for_state(player, &"jump_fall", 40)

	assert_eq(player.get("current_state"), &"jump_fall")
	assert_gt(player.velocity.y, 0.0)


func test_early_jump_release_reduces_jump_height() -> void:
	var full_jump_apex: float = await _measure_jump_apex(-1)
	var short_jump_apex: float = await _measure_jump_apex(2)

	assert_lt(full_jump_apex, short_jump_apex)


func test_player_can_jump_within_coyote_time_window() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(
		Vector2(56, 96),
		Vector2(160, 32)
	)

	assert_not_null(player)

	Input.action_press("move_right")
	await _wait_until_not_on_floor(player, 25)
	Input.action_press("jump")
	await _advance_physics_frames(2)
	Input.action_release("move_right")
	Input.action_release("jump")

	assert_eq(player.get("current_state"), &"jump_rise")
	assert_lt(player.velocity.y, 0.0)


func test_player_uses_jump_buffer_when_landing() -> void:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 88))

	assert_not_null(player)

	player.velocity = Vector2(0, 260)
	Input.action_press("jump")
	await _advance_physics_frames(8)
	Input.action_release("jump")

	assert_eq(player.get("current_state"), &"jump_rise")
	assert_lt(player.velocity.y, 0.0)


func _spawn_player_with_floor(
	spawn_position: Vector2,
	floor_size: Vector2 = Vector2(1024, 32)
) -> CharacterBody2D:
	var world := Node2D.new()
	add_child_autofree(world)

	var floor := StaticBody2D.new()
	floor.position = Vector2(0, 160)
	world.add_child(floor)

	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = floor_size
	floor_shape.shape = rectangle
	floor.add_child(floor_shape)

	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	world.add_child(player)
	await _wait_until_player_is_settled(player, 64)
	return player


func _measure_jump_apex(release_after_frames: int) -> float:
	var player: CharacterBody2D = await _spawn_player_with_floor(Vector2(0, 96))
	var world: Node = player.get_parent()
	var apex := player.global_position.y

	Input.action_press("jump")
	for frame in range(45):
		await _advance_physics_frames(1)
		apex = minf(apex, player.global_position.y)

		if release_after_frames >= 0 and frame == release_after_frames:
			Input.action_release("jump")

		if frame > 3 and player.is_on_floor():
			break

	Input.action_release("jump")
	world.queue_free()
	await get_tree().process_frame
	return apex


func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


func _wait_for_state(player: CharacterBody2D, expected_state: StringName, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.get("current_state") == expected_state:
			return
		await _advance_physics_frames(1)

	fail_test("等待状态 %s 超时，当前为 %s" % [expected_state, player.get("current_state")])


func _wait_until_not_on_floor(player: CharacterBody2D, max_frames: int) -> void:
	for _i in range(max_frames):
		if not player.is_on_floor():
			return
		await _advance_physics_frames(1)

	fail_test("玩家在预期帧数内没有离开地面")


func _wait_until_player_is_settled(player: CharacterBody2D, max_frames: int) -> void:
	for _i in range(max_frames):
		if (
			player.is_on_floor()
			and absf(player.velocity.y) <= 0.1
			and player.global_position.y >= SETTLED_PLAYER_Y
		):
			await _advance_physics_frames(6)
			return

		await _advance_physics_frames(1)

	fail_test("玩家在预期帧数内没有稳定落地")


func _has_property(target: Object, property_name: String) -> bool:
	for property_info in target.get_property_list():
		if property_info.name == property_name:
			return true
	return false


func _project_action_has_default_events(action_name: String) -> bool:
	var action_config: Dictionary = ProjectSettings.get_setting("input/%s" % action_name, {})
	var action_events: Array = action_config.get("events", [])
	return not action_events.is_empty()
