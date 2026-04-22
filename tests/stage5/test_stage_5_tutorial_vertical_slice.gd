extends GutTest


const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const TUTORIAL_ROOM_SCENE_PATH := "res://scenes/rooms/tutorial_room.tscn"


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


func test_main_scene_defaults_to_tutorial_room_and_hud() -> void:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame

	var room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	var hud: CanvasLayer = main_scene.get_node_or_null("HUD") as CanvasLayer
	var step_label: Label = main_scene.get_node_or_null("HUD/TutorialHUD/PromptPanel/StepLabel") as Label
	var prompt_label: Label = main_scene.get_node_or_null("HUD/TutorialHUD/PromptPanel/PromptLabel") as Label

	assert_not_null(room)
	assert_not_null(hud)
	assert_not_null(step_label)
	assert_not_null(prompt_label)
	assert_eq(room.scene_file_path, TUTORIAL_ROOM_SCENE_PATH)
	assert_true(room.has_method("get_camera_limits"))
	assert_string_contains(step_label.text, "教程 1/4")
	assert_true(prompt_label.visible)
	assert_string_contains(prompt_label.text, "Space")


func test_battle_panel_labels_render_on_separate_rows() -> void:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame

	var status_label: Label = main_scene.get_node_or_null("HUD/TutorialHUD/BattlePanel/StatusLabel") as Label
	var dash_label: Label = main_scene.get_node_or_null("HUD/TutorialHUD/BattlePanel/DashLabel") as Label

	assert_not_null(status_label)
	assert_not_null(dash_label)
	assert_true(status_label.visible)
	assert_true(dash_label.visible)
	assert_ne(status_label.global_position.y, dash_label.global_position.y)
	assert_gt(dash_label.global_position.y - status_label.global_position.y, 12.0)


func test_tutorial_room_exposes_stage_5_gate_and_exit_nodes() -> void:
	var packed_scene: PackedScene = load(TUTORIAL_ROOM_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var room: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(room)

	assert_not_null(room.get_node_or_null("JumpGuidePlatform"))
	assert_not_null(room.get_node_or_null("DashGateLeft"))
	assert_not_null(room.get_node_or_null("DashGateRight"))
	assert_not_null(room.get_node_or_null("DashGateCeiling"))
	assert_not_null(room.get_node_or_null("TutorialDummy"))
	assert_not_null(room.get_node_or_null("ExitBarrier"))
	assert_not_null(room.get_node_or_null("ExitZone"))

	var jump_platform: StaticBody2D = room.get_node_or_null("JumpGuidePlatform") as StaticBody2D

	assert_not_null(jump_platform)
	assert_eq(jump_platform.position, Vector2(-144, 88))


func test_tutorial_flow_progresses_in_order_and_unlocks_exit() -> void:
	var room: Node2D = await _spawn_tutorial_room_world()
	var player: CharacterBody2D = await _spawn_player_into_room(room, Vector2(-320, 96))
	var dummy: StaticBody2D = room.get_node("TutorialDummy") as StaticBody2D

	assert_eq(room.call("get_current_step_id"), &"move_jump")
	assert_false(room.call("is_exit_unlocked"))

	player.global_position = Vector2(-48, 32)
	await _advance_process_frames(2)
	assert_eq(room.call("get_current_step_id"), &"dash")

	player.global_position = Vector2(252, 96)
	await _advance_process_frames(2)
	assert_eq(room.call("get_current_step_id"), &"attack")

	dummy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(2)
	assert_eq(room.call("get_current_step_id"), &"exit")
	assert_true(room.call("is_exit_unlocked"))

	player.global_position = Vector2(796, 96)
	await _advance_process_frames(2)
	assert_eq(room.call("get_current_step_id"), &"complete")


func test_dash_gate_requires_dash_to_cross_stably_in_tutorial_room() -> void:
	var room: Node2D = await _spawn_tutorial_room_world()
	var player: CharacterBody2D = await _spawn_player_into_room(room, Vector2(84, 96))

	Input.action_press("move_right")
	await _advance_physics_frames(24)
	Input.action_release("move_right")

	assert_lt(player.global_position.x, 212.0)

	room.queue_free()
	await get_tree().process_frame

	room = await _spawn_tutorial_room_world()
	player = await _spawn_player_into_room(room, Vector2(84, 96))

	Input.action_press("move_right")
	await _advance_physics_frames(6)
	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")
	Input.action_release("move_right")
	await _advance_physics_frames(16)

	assert_gt(player.global_position.x, 208.0)
	assert_true(player.is_on_floor())


func _spawn_tutorial_room_world() -> Node2D:
	var room_scene: PackedScene = load(TUTORIAL_ROOM_SCENE_PATH) as PackedScene
	var room: Node2D = room_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().physics_frame
	return room


func _spawn_player_into_room(room: Node2D, spawn_position: Vector2) -> CharacterBody2D:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	room.add_child(player)
	if room.has_method("bind_player"):
		room.call("bind_player", player)
	await _wait_until_player_is_settled(player, 64)
	return player


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
