extends GutTest


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const STAGE9_FINAL_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_final_room.tscn"
const HUD_SCENE_PATH := "res://scenes/ui/tutorial_hud.tscn"
const AERIAL_SENTINEL_SCENE_PATH := "res://scenes/combat/aerial_sentinel_enemy.tscn"
const AERIAL_SENTINEL_CONFIG_SCRIPT_PATH := "res://scripts/configs/aerial_sentinel_enemy_config.gd"
const STAGE10_MAIN_ROOM_SCENE_PATH := "res://scenes/rooms/stage10_zone_aerial_room.tscn"
const STAGE10_BRANCH_ROOM_SCENE_PATH := "res://scenes/rooms/stage10_zone_branch_room.tscn"
const STAGE10_CHALLENGE_ROOM_SCENE_PATH := "res://scenes/rooms/stage10_zone_challenge_room.tscn"


func before_each() -> void:
	_reset_input_actions()


func after_each() -> void:
	_reset_input_actions()


func test_player_can_start_air_attack_while_airborne_and_return_to_fall() -> void:
	var player := await _spawn_player(Vector2.ZERO)

	player.velocity = Vector2(0.0, -90.0)
	Input.action_press("attack")
	await _advance_physics_frames(2)
	Input.action_release("attack")

	assert_eq(player.call("get_current_state_id"), &"air_attack")
	assert_true(player.call("is_air_attack_active_or_recovering"))

	await _advance_physics_frames(24)

	assert_ne(player.call("get_current_state_id"), &"air_attack")
	assert_false(player.call("is_air_attack_active_or_recovering"))


func test_aerial_sentinel_uses_config_and_requires_air_attack_lane() -> void:
	var packed_scene: PackedScene = load(AERIAL_SENTINEL_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var enemy: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(enemy)
	await get_tree().process_frame

	var config: Resource = enemy.get("config") as Resource

	assert_not_null(config)
	assert_eq(config.get_script().resource_path, AERIAL_SENTINEL_CONFIG_SCRIPT_PATH)
	assert_true(enemy.has_method("get_air_attack_lane_height"))
	assert_gt(enemy.call("get_air_attack_lane_height"), 48.0)
	assert_gt(enemy.call("get_hover_amplitude"), 0.0)
	assert_eq(enemy.call("get_touch_damage"), config.get("touch_damage"))


func test_stage10_zone_adds_main_branch_and_challenge_rooms() -> void:
	for room_path in [STAGE10_MAIN_ROOM_SCENE_PATH, STAGE10_BRANCH_ROOM_SCENE_PATH, STAGE10_CHALLENGE_ROOM_SCENE_PATH]:
		var packed_scene: PackedScene = load(room_path) as PackedScene
		assert_not_null(packed_scene, "缺少 Stage10 房间场景: %s" % room_path)

	var main_room := await _spawn_room(STAGE10_MAIN_ROOM_SCENE_PATH)
	var branch_room := await _spawn_room(STAGE10_BRANCH_ROOM_SCENE_PATH)
	var challenge_room := await _spawn_room(STAGE10_CHALLENGE_ROOM_SCENE_PATH)

	assert_eq(main_room.call("get_optional_branch_room_path"), STAGE10_BRANCH_ROOM_SCENE_PATH)
	assert_eq(main_room.call("get_challenge_room_path"), STAGE10_CHALLENGE_ROOM_SCENE_PATH)
	assert_true(main_room.call("has_air_attack_value_marker"))
	assert_true(branch_room.call("is_optional_reward_room"))
	assert_true(challenge_room.call("is_challenge_reward_room"))


func test_recovery_point_and_collectibles_feed_hud_snapshot() -> void:
	var room := await _spawn_room(STAGE10_BRANCH_ROOM_SCENE_PATH)
	var player := await _spawn_player(Vector2.ZERO)

	room.call("bind_player", player)
	player.call("receive_damage", 1, Vector2.LEFT)
	room.call("collect_stage10_pickup", &"branch_reward")
	room.call("activate_recovery_point")

	var snapshot: Dictionary = room.call("get_stage10_progress_snapshot")
	var hud_context: Dictionary = room.call("get_hud_context")

	assert_eq(player.call("get_current_health"), player.call("get_max_health"))
	assert_eq(snapshot.get("collectible_count"), 1)
	assert_true(snapshot.get("recovery_point_activated"))
	assert_eq(hud_context.get("collectible_count"), 1)
	assert_true(hud_context.get("recovery_point_activated"))


func test_stage9_final_room_links_into_stage10_main_room() -> void:
	var room := await _spawn_room(STAGE9_FINAL_ROOM_SCENE_PATH)

	assert_eq(room.get("next_room_path"), STAGE10_MAIN_ROOM_SCENE_PATH)
	assert_eq(room.get("next_spawn_id"), &"stage10_aerial_start")


func test_stage10_spawn_points_land_on_room_floor() -> void:
	var spawn_cases := {
		STAGE10_MAIN_ROOM_SCENE_PATH: &"stage10_aerial_start",
		STAGE10_BRANCH_ROOM_SCENE_PATH: &"stage10_branch_start",
		STAGE10_CHALLENGE_ROOM_SCENE_PATH: &"stage10_challenge_start",
	}

	for room_path in spawn_cases.keys():
		var room := await _spawn_room(room_path)
		var spawn_position: Vector2 = room.call("get_spawn_position", spawn_cases[room_path])

		assert_gt(spawn_position.x, -160.0)
		assert_lt(spawn_position.x, 352.0)
		assert_lt(spawn_position.y, 160.0)


func test_stage10_main_room_branch_zone_requests_optional_branch() -> void:
	var room := await _spawn_room(STAGE10_MAIN_ROOM_SCENE_PATH)
	var player := await _spawn_player(Vector2(-224.0, 96.0))
	var transitions: Array = []

	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target_room_path: String, spawn_id: StringName) -> void:
		transitions.append({"target": target_room_path, "spawn": spawn_id})
	)

	player.global_position = room.get_node("BranchZone").global_position
	await _advance_process_frames(2)

	assert_eq(transitions.size(), 1)
	assert_eq(transitions[0].get("target"), STAGE10_BRANCH_ROOM_SCENE_PATH)
	assert_eq(transitions[0].get("spawn"), &"stage10_branch_start")


func test_stage10_main_room_spawn_does_not_auto_request_optional_branch() -> void:
	var room := await _spawn_room(STAGE10_MAIN_ROOM_SCENE_PATH)
	var spawn_position: Vector2 = room.call("get_spawn_position", &"stage10_aerial_start")
	var player := await _spawn_player(spawn_position)
	var transitions: Array = []

	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target_room_path: String, spawn_id: StringName) -> void:
		transitions.append({"target": target_room_path, "spawn": spawn_id})
	)

	await _advance_process_frames(2)

	assert_eq(transitions.size(), 0)


func test_stage10_pickup_and_recovery_point_trigger_from_player_position() -> void:
	var room := await _spawn_room(STAGE10_BRANCH_ROOM_SCENE_PATH)
	var player := await _spawn_player(Vector2.ZERO)

	room.call("bind_player", player)
	player.call("receive_damage", 1, Vector2.LEFT)

	player.global_position = room.get_node("BranchCollectible").global_position
	await _advance_process_frames(2)

	player.global_position = room.get_node("RecoveryPoint").global_position
	await _advance_process_frames(2)

	var snapshot: Dictionary = room.call("get_stage10_progress_snapshot")

	assert_eq(snapshot.get("collectible_count"), 1)
	assert_true(snapshot.get("recovery_point_activated"))
	assert_eq(player.call("get_current_health"), player.call("get_max_health"))


func test_hud_displays_stage10_collectible_and_recovery_feedback() -> void:
	var room := await _spawn_room(STAGE10_BRANCH_ROOM_SCENE_PATH)
	var hud_scene: PackedScene = load(HUD_SCENE_PATH) as PackedScene

	assert_not_null(hud_scene)

	var hud: Control = hud_scene.instantiate() as Control
	add_child_autofree(hud)
	await get_tree().process_frame

	room.call("collect_stage10_pickup", &"branch_reward")
	room.call("activate_recovery_point")
	hud.call("bind_room", room)
	await _advance_process_frames(2)

	var progress_label: Label = hud.get_node_or_null("BattlePanel/ProgressLabel") as Label

	assert_not_null(progress_label)
	assert_string_contains(progress_label.text, "收集：1")
	assert_string_contains(progress_label.text, "恢复：已激活")


func _spawn_player(spawn_position: Vector2) -> CharacterBody2D:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene

	assert_not_null(player_scene)

	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	add_child_autofree(player)
	player.global_position = spawn_position
	await get_tree().process_frame
	return player


func _spawn_room(scene_path: String) -> Node2D:
	var packed_scene: PackedScene = load(scene_path) as PackedScene

	assert_not_null(packed_scene)

	var room: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


func _reset_input_actions() -> void:
	if not InputMap.has_action("attack"):
		InputMap.add_action("attack")
	Input.action_release("attack")
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("dash")
