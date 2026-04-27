extends GutTest

# 阶段 14 回归测试保护第一条真实回溯契约：
# 获得 1 个探索能力、回到旧空间、打开能力门，并保证能力状态能跨房间保留。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const STAGE13_GOAL_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_goal_room.tscn"
const STAGE14_SHRINE_ROOM_PATH := "res://scenes/rooms/stage14_air_dash_shrine_room.tscn"
const STAGE14_GATE_ROOM_PATH := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const STAGE14_HUB_ROOM_PATH := "res://scenes/rooms/stage14_backtrack_hub_room.tscn"
const STAGE14_LOOP_RETURN_ROOM_PATH := "res://scenes/rooms/stage14_loop_return_room.tscn"
const ASSET_MANIFEST_PATH := "res://docs/assets/asset-manifest.md"


func before_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("attack")
	Input.action_release("dash")


func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("attack")
	Input.action_release("dash")


func test_air_dash_public_contract_exists_and_defaults_locked() -> void:
	var player := await _spawn_player_with_floor(Vector2(0, 96))

	assert_true(player.has_method("set_air_dash_unlocked"))
	assert_true(player.has_method("is_air_dash_unlocked"))
	assert_true(player.has_method("is_air_dash_available"))
	assert_false(player.call("is_air_dash_unlocked"))
	assert_false(player.call("is_air_dash_available"))

	var snapshot: Dictionary = player.call("get_hud_status_snapshot")
	assert_false(snapshot.get("air_dash_unlocked", true))
	assert_false(snapshot.get("air_dash_available", true))


func test_air_dash_is_locked_before_unlock_and_available_once_after_unlock() -> void:
	var player := await _spawn_player_with_floor(Vector2(0, 96))

	await _jump_until_airborne(player)
	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")

	assert_ne(player.get("current_state"), &"dash")

	player.call("set_air_dash_unlocked", true)
	assert_true(player.call("is_air_dash_available"))

	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")

	assert_eq(player.get("current_state"), &"dash")
	assert_false(player.call("is_air_dash_available"))
	assert_lt(absf(player.velocity.y), 1.0)


func test_air_dash_recharges_after_landing() -> void:
	var player := await _spawn_player_with_floor(Vector2(0, 96))
	player.call("set_air_dash_unlocked", true)

	await _jump_until_airborne(player)
	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")
	assert_false(player.call("is_air_dash_available"))

	await _wait_until_player_is_settled(player, 90)
	assert_true(player.call("is_air_dash_available"))


func test_stage14_rooms_exist_and_gate_requires_air_dash() -> void:
	assert_not_null(load(STAGE14_SHRINE_ROOM_PATH))
	assert_not_null(load(STAGE14_GATE_ROOM_PATH))
	assert_not_null(load(STAGE14_HUB_ROOM_PATH))
	assert_not_null(load(STAGE14_LOOP_RETURN_ROOM_PATH))

	var gate_room := await _spawn_room(STAGE14_GATE_ROOM_PATH)
	var player := await _spawn_player_with_floor(Vector2.ZERO)

	gate_room.call("bind_player", player)

	assert_true(gate_room.has_method("is_air_dash_gate_unlocked"))
	assert_false(gate_room.call("is_air_dash_gate_unlocked"))

	player.call("set_air_dash_unlocked", true)
	await _advance_process_frames(3)

	assert_true(gate_room.call("is_air_dash_gate_unlocked"))


func test_stage14_shrine_unlocks_air_dash_and_hub_tracks_three_backtrack_rewards() -> void:
	var shrine := await _spawn_room(STAGE14_SHRINE_ROOM_PATH)
	var hub := await _spawn_room(STAGE14_HUB_ROOM_PATH)
	var player := await _spawn_player_with_floor(Vector2.ZERO)

	shrine.call("bind_player", player)
	player.global_position = shrine.get_node("AirDashShrine").global_position
	await _advance_process_frames(3)

	assert_true(player.call("is_air_dash_unlocked"))
	assert_true(shrine.call("has_air_dash_been_granted"))

	hub.call("bind_player", player)
	for reward_name in ["BacktrackRewardOne", "BacktrackRewardTwo", "BacktrackRewardThree"]:
		player.global_position = hub.get_node(reward_name).global_position
		await _advance_process_frames(3)

	var context: Dictionary = hub.call("get_hud_context")
	assert_eq(context.get("stage14_backtrack_reward_count"), 3)


func test_stage13_goal_links_to_stage14_air_dash_shrine() -> void:
	var room := await _spawn_room(STAGE13_GOAL_ROOM_PATH)
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var transitions: Array = []

	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target_room_path: String, spawn_id: StringName) -> void:
		transitions.append({"target": target_room_path, "spawn": spawn_id})
	)

	player.global_position = room.get_node("GoalZone").global_position
	await _advance_process_frames(4)

	assert_eq(transitions.size(), 1)
	assert_eq(transitions[0].get("target"), STAGE14_SHRINE_ROOM_PATH)
	assert_eq(transitions[0].get("spawn"), &"stage14_air_dash_shrine_start")


func test_stage14_graybox_mainline_unlocks_air_dash_collects_rewards_and_reaches_loop_return() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE13_GOAL_ROOM_PATH, &"stage13_goal_start")
	await _advance_process_frames(4)

	var reached_loop := await _drive_stage14_loop(main_scene)
	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")

	assert_true(reached_loop)
	assert_true(snapshot.get("air_dash_unlocked", false))
	assert_eq(snapshot.get("stage14_backtrack_reward_count", 0), 3)
	assert_eq(_get_room_path(main_scene), STAGE14_LOOP_RETURN_ROOM_PATH)


func test_stage14_runtime_spawn_lands_on_room_floor_and_hud_prioritizes_air_dash_status() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE14_SHRINE_ROOM_PATH, &"stage14_air_dash_shrine_start")
	await _advance_physics_frames(45)

	var player := _get_player(main_scene)
	var room := _get_room(main_scene)
	assert_not_null(player)
	assert_not_null(room)
	assert_true(player.is_on_floor())
	assert_lt(player.global_position.y, 180.0)

	player.global_position = room.get_node("AirDashShrine").global_position
	await _advance_process_frames(4)

	var progress_label := main_scene.get_node("HUD/TutorialHUD/BattlePanel/ProgressLabel") as Label
	assert_not_null(progress_label)
	assert_string_contains(progress_label.text, "空中冲刺")
	assert_string_contains(progress_label.text, "回溯收益")
	assert_false(progress_label.text.contains("收集：0  恢复"))


func test_stage14_asset_manifest_contains_air_dash_requirements() -> void:
	var manifest := _read_text_file(ASSET_MANIFEST_PATH)
	var required_terms := [
		"stage14_air_dash_icon",
		"stage14_air_dash_shrine",
		"stage14_air_dash_gate",
		"stage14_backtrack_reward_marker",
	]

	for term in required_terms:
		assert_string_contains(manifest, term)


func _drive_stage14_loop(main_scene: Node2D) -> bool:
	# 灰盒 driver 只通过生产 Main 和真实房间节点推进，
	# 用来证明 Stage13 终点到 Stage14 回环房的主线不是测试侧拼出来的假链路。
	var safety := 0
	while safety < 24:
		safety += 1
		var room := _get_room(main_scene)
		var player := _get_player(main_scene)
		if room == null or player == null:
			return false

		if room.scene_file_path == STAGE14_LOOP_RETURN_ROOM_PATH:
			return true

		match room.scene_file_path:
			STAGE13_GOAL_ROOM_PATH:
				player.global_position = room.get_node("GoalZone").global_position
			STAGE14_SHRINE_ROOM_PATH:
				player.global_position = room.get_node("AirDashShrine").global_position
				await _advance_process_frames(4)
				player.global_position = room.get_node("ExitZone").global_position
			STAGE14_GATE_ROOM_PATH:
				player.global_position = room.get_node("AirDashGateSensor").global_position
				await _advance_process_frames(4)
				player.global_position = room.get_node("ExitZone").global_position
			STAGE14_HUB_ROOM_PATH:
				for reward_name in ["BacktrackRewardOne", "BacktrackRewardTwo", "BacktrackRewardThree"]:
					player.global_position = room.get_node(reward_name).global_position
					await _advance_process_frames(3)
				player.global_position = room.get_node("ExitZone").global_position
			_:
				var exit_zone := room.get_node_or_null("ExitZone") as Node2D
				if exit_zone == null:
					return false
				player.global_position = exit_zone.global_position

		await _advance_process_frames(5)

	return false


func _spawn_main_scene() -> Node2D:
	# 主场景 helper 固定加载生产入口，避免绕过 Main 的房间切换、玩家注入和 HUD 绑定。
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)

	var main_scene := packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await _advance_process_frames(2)
	return main_scene


func _spawn_room(scene_path: String) -> Node2D:
	# 单房间 helper 至少等待一帧 ready，让门控、checkpoint 和节点可见性完成初始化。
	var packed_scene: PackedScene = load(scene_path) as PackedScene
	assert_not_null(packed_scene, "Missing room scene: %s" % scene_path)

	if packed_scene == null:
		return null

	var room := packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


func _spawn_player_with_floor(spawn_position: Vector2) -> CharacterBody2D:
	# 玩家 helper 使用真实 PlayerPlaceholder 和简单地板，专门保护跳跃、落地与空中冲刺状态机。
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
	assert_not_null(player_scene)

	var player := player_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	world.add_child(player)
	await _wait_until_player_is_settled(player, 64)
	return player


func _jump_until_airborne(player: CharacterBody2D) -> void:
	# 空中冲刺测试需要真实离地状态；这里用输入触发跳跃，而不是直接改 is_on_floor 相关内部值。
	Input.action_press("jump")
	await _advance_physics_frames(2)
	Input.action_release("jump")
	for _i in range(20):
		if not player.is_on_floor():
			return
		await _advance_physics_frames(1)

	fail_test("Player did not become airborne for Stage 14 air dash test.")


func _wait_until_player_is_settled(player: CharacterBody2D, max_frames: int) -> void:
	# 落地恢复测试必须等速度收束，避免刚接触地面的一帧误判空中冲刺已恢复。
	for _i in range(max_frames):
		if player.is_on_floor() and absf(player.velocity.x) <= 0.1 and absf(player.velocity.y) <= 0.1:
			await _advance_physics_frames(2)
			return
		await _advance_physics_frames(1)

	fail_test("Player did not settle on the floor.")


func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


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


func _read_text_file(path: String) -> String:
	# 资产 manifest 用文本读取即可，测试只锁定关键条目是否已被规划。
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Cannot read file: %s" % path)
	return file.get_as_text() if file != null else ""
