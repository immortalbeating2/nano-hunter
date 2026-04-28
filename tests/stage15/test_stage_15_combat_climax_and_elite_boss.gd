extends GutTest

# Stage15 专项测试保护第一场战斗高潮的稳定契约：
# 一个精英 Boss 原型、一条恢复充能容错资源，以及失败重试 / 击败完成路径。
# 这些测试覆盖运行时公开接口和灰盒主链路，避免后续调整 Boss 房或 HUD 时只保留场景存在性。
const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const SEAL_GUARDIAN_SCENE_PATH := "res://scenes/enemies/seal_guardian_boss.tscn"
const STAGE14_LOOP_RETURN_ROOM_PATH := "res://scenes/rooms/stage14_loop_return_room.tscn"
const STAGE15_ANTE_ROOM_PATH := "res://scenes/rooms/stage15_seal_pressure_room.tscn"
const STAGE15_MIXED_GAUNTLET_ROOM_PATH := "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"
const STAGE15_BOSS_ROOM_PATH := "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn"
const STAGE15_CHALLENGE_ROOM_PATH := "res://scenes/rooms/stage15_challenge_branch_room.tscn"
const STAGE15_COMPLETE_ROOM_PATH := "res://scenes/rooms/stage15_completion_room.tscn"
const ASSET_MANIFEST_PATH := "res://docs/assets/asset-manifest.md"

# defeated 信号单独计数，确保 Boss 归零后只发出一次完成事件。
var _stage15_boss_defeated_signal_count := 0


# 输入初始化：兜底创建 recover，并释放 Stage15 涉及的全部动作。
func before_each() -> void:
	_stage15_boss_defeated_signal_count = 0
	if not InputMap.has_action("recover"):
		InputMap.add_action("recover")
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("attack")
	Input.action_release("dash")
	Input.action_release("recover")


# 每条 Stage15 测试结束释放输入，避免攻击 / 恢复等持续按下状态污染下一条。
func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("attack")
	Input.action_release("dash")
	Input.action_release("recover")


# 保护恢复充能 public contract：满充能、满血不消费、受伤后恢复且清空资源。
func test_recovery_charge_public_contract_and_spend_rules() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)

	assert_true(player.has_method("add_recovery_charge"))
	assert_true(player.has_method("can_spend_recovery_charge"))
	assert_true(player.has_method("spend_recovery_charge"))
	assert_true(player.has_method("get_recovery_charge_ratio"))
	assert_eq(player.call("get_recovery_charge_ratio"), 0.0)
	assert_false(player.call("can_spend_recovery_charge"))

	player.call("add_recovery_charge", 1.0)
	assert_eq(player.call("get_recovery_charge_ratio"), 1.0)
	assert_true(player.call("can_spend_recovery_charge"))
	assert_false(player.call("spend_recovery_charge"), "满血时不应消耗恢复充能。")
	assert_eq(player.call("get_current_health"), player.call("get_max_health"))
	assert_eq(player.call("get_recovery_charge_ratio"), 1.0)

	player.call("receive_damage", 1, Vector2.LEFT)
	assert_eq(player.call("get_current_health"), player.call("get_max_health") - 1)
	assert_true(player.call("spend_recovery_charge"))
	assert_eq(player.call("get_current_health"), player.call("get_max_health"))
	assert_eq(player.call("get_recovery_charge_ratio"), 0.0)

	var snapshot: Dictionary = player.call("get_hud_status_snapshot")
	assert_true(snapshot.has("recovery_charge_ratio"))
	assert_true(snapshot.has("recovery_charge_ready"))


# 保护真实命中充能：玩家攻击命中敌人时必须增长恢复充能并伤害 Boss。
func test_player_successful_hits_build_recovery_charge() -> void:
	var world := Node2D.new()
	add_child_autofree(world)

	var player := await _spawn_player_with_floor(Vector2.ZERO, world)
	var boss := await _spawn_seal_guardian(world, Vector2(38, 160))

	assert_eq(player.call("get_recovery_charge_ratio"), 0.0)
	await _perform_player_attack(player)

	assert_gt(player.call("get_recovery_charge_ratio"), 0.0)
	assert_lt(boss.call("get_current_health"), boss.call("get_max_health"))


# 保护 Boss 公开契约：生命、状态、击败信号和 receive_attack 必须稳定可读。
func test_seal_guardian_boss_contract_health_states_and_defeat() -> void:
	var boss := await _spawn_seal_guardian()
	boss.connect("defeated", Callable(self, "_on_stage15_boss_defeated"))

	assert_true(boss.has_method("receive_attack"))
	assert_true(boss.has_method("is_defeated"))
	assert_true(boss.has_method("get_current_health"))
	assert_true(boss.has_method("get_max_health"))
	assert_true(boss.has_method("get_boss_state"))
	assert_eq(boss.call("get_boss_state"), &"idle")

	var max_health := int(boss.call("get_max_health"))
	for _i in range(max_health):
		boss.call("receive_attack", Vector2.RIGHT, 120.0)

	assert_true(boss.call("is_defeated"))
	assert_eq(boss.call("get_current_health"), 0)
	assert_eq(boss.call("get_boss_state"), &"defeated")
	assert_eq(_stage15_boss_defeated_signal_count, 1)


# 保护 Stage15 场景集合和 Stage14 入口：回环房必须切到 Stage15 前置段。
func test_stage15_rooms_exist_and_stage14_loop_links_to_ante_room() -> void:
	assert_not_null(load(STAGE15_ANTE_ROOM_PATH))
	assert_not_null(load(STAGE15_MIXED_GAUNTLET_ROOM_PATH))
	assert_not_null(load(STAGE15_BOSS_ROOM_PATH))
	assert_not_null(load(STAGE15_CHALLENGE_ROOM_PATH))
	assert_not_null(load(STAGE15_COMPLETE_ROOM_PATH))

	var room := await _spawn_room(STAGE14_LOOP_RETURN_ROOM_PATH)
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var transitions: Array = []

	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target_room_path: String, spawn_id: StringName) -> void:
		transitions.append({"target": target_room_path, "spawn": spawn_id})
	)

	player.global_position = room.get_node("GoalZone").global_position
	await _advance_process_frames(4)

	assert_eq(transitions.size(), 1)
	assert_eq(transitions[0].get("target"), STAGE15_ANTE_ROOM_PATH)
	assert_eq(transitions[0].get("spawn"), &"stage15_seal_pressure_start")


# 保护战斗高潮节奏：混合遭遇必须三类敌人全清后才允许进入 Boss 房。
func test_stage15_mixed_gauntlet_requires_all_enemies_before_boss_gate() -> void:
	var room := await _spawn_room(STAGE15_MIXED_GAUNTLET_ROOM_PATH)
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	room.call("bind_player", player)

	assert_false(room.call("is_gate_unlocked"))
	assert_eq(room.call("get_remaining_required_enemy_count"), 3)

	_defeat_named_enemy(room, "BasicMeleeEnemy")
	assert_false(room.call("is_gate_unlocked"))
	assert_eq(room.call("get_remaining_required_enemy_count"), 2)

	_defeat_named_enemy(room, "GroundChargerEnemy")
	assert_false(room.call("is_gate_unlocked"))
	assert_eq(room.call("get_remaining_required_enemy_count"), 1)

	_defeat_named_enemy(room, "AerialSentinelEnemy")
	assert_true(room.call("is_gate_unlocked"))
	assert_eq(room.call("get_remaining_required_enemy_count"), 0)


# 保护挑战支线价值：支线房不能绕过敌人直接拿奖励返回主线。
func test_stage15_challenge_branch_requires_clear_before_return_gate() -> void:
	var room := await _spawn_room(STAGE15_CHALLENGE_ROOM_PATH)
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	room.call("bind_player", player)

	assert_false(room.call("is_gate_unlocked"))
	assert_eq(room.call("get_remaining_required_enemy_count"), 2)

	_defeat_named_enemy(room, "SporeShooterEnemy")
	assert_false(room.call("is_gate_unlocked"))
	assert_eq(room.call("get_remaining_required_enemy_count"), 1)

	_defeat_named_enemy(room, "AerialSentinelEnemy")
	assert_true(room.call("is_gate_unlocked"))
	assert_eq(room.call("get_remaining_required_enemy_count"), 0)


# 保护 Boss 房闭环：失败重试、Boss 重新生成、击败跳转和 Main 快照都要成立。
func test_stage15_boss_room_retry_victory_and_main_snapshot() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE15_BOSS_ROOM_PATH, &"stage15_boss_start")
	await _advance_process_frames(4)

	var room := _get_room(main_scene)
	var player := _get_player(main_scene)
	assert_not_null(room)
	assert_not_null(player)
	assert_true(room.has_method("get_hud_context"))

	var boss := room.get_node_or_null("SealGuardianBoss")
	assert_not_null(boss)
	assert_false(main_scene.call("get_demo_progress_snapshot").get("stage15_boss_defeated", true))

	player.call("receive_damage", player.call("get_max_health"), Vector2.LEFT)
	await _advance_process_frames(6)
	assert_eq(_get_room_path(main_scene), STAGE15_BOSS_ROOM_PATH)
	assert_not_null(_get_player(main_scene))

	room = _get_room(main_scene)
	boss = room.get_node_or_null("SealGuardianBoss")
	for _i in range(int(boss.call("get_max_health"))):
		boss.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(8)

	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")
	assert_true(snapshot.get("stage15_boss_defeated", false))
	assert_eq(_get_room_path(main_scene), STAGE15_COMPLETE_ROOM_PATH)


# 保护 Stage15 HUD：混合遭遇显示恢复充能，Boss 房显示恢复充能和 Boss 状态。
func test_stage15_hud_displays_recovery_charge_and_boss_status() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE15_MIXED_GAUNTLET_ROOM_PATH, &"stage15_mixed_gauntlet_start")
	await _advance_process_frames(4)

	var progress_label := main_scene.get_node("HUD/TutorialHUD/BattlePanel/ProgressLabel") as Label
	assert_not_null(progress_label)
	assert_string_contains(progress_label.text, "恢复充能")
	assert_eq(progress_label.text.find("收集："), -1)

	main_scene.call("transition_to_room", STAGE15_BOSS_ROOM_PATH, &"stage15_boss_start")
	await _advance_process_frames(4)

	var player := _get_player(main_scene)
	player.call("add_recovery_charge", 1.0)
	await _advance_process_frames(2)

	assert_string_contains(progress_label.text, "恢复充能")
	assert_string_contains(progress_label.text, "封印守卫")


# 保护 MCP 复核发现的问题：Boss 击败后的完成房必须显示完成反馈，而不是继续提示击败 Boss。
func test_stage15_completion_room_shows_clear_completion_feedback_after_boss_defeat() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE15_BOSS_ROOM_PATH, &"stage15_boss_start")
	await _advance_process_frames(4)

	var boss := _get_room(main_scene).get_node("SealGuardianBoss")
	for _i in range(int(boss.call("get_max_health"))):
		boss.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(4)

	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")
	var progress_label := main_scene.get_node("HUD/TutorialHUD/BattlePanel/ProgressLabel") as Label

	assert_eq(_get_room_path(main_scene), STAGE15_COMPLETE_ROOM_PATH)
	assert_true(snapshot.get("stage15_boss_defeated", false))
	assert_string_contains(str(snapshot.get("goal_text", "")), "Stage15 已完成")
	assert_string_contains(progress_label.text, "Stage15 已完成")
	assert_eq(progress_label.text.find("主目标：击败封印守卫"), -1)
	assert_eq(progress_label.text.find("恢复充能"), -1)
	assert_eq(progress_label.text.find("收集："), -1)
	assert_eq(progress_label.text.find("恢复：未激活"), -1)


# 保护 Stage15 灰盒主线：从 Stage14 回环进入 Stage15 并击败 Boss 到完成房。
func test_stage15_graybox_driver_reaches_completion_after_boss_defeat() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE14_LOOP_RETURN_ROOM_PATH, &"stage14_loop_return_start")
	await _advance_process_frames(4)

	var reached_completion := await _drive_stage15_loop(main_scene)
	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")

	assert_true(reached_completion)
	assert_true(snapshot.get("stage15_boss_defeated", false))
	assert_eq(_get_room_path(main_scene), STAGE15_COMPLETE_ROOM_PATH)


# 保护资产规划：Boss、攻击预警、HUD 和恢复充能图标必须写入 manifest。
func test_stage15_asset_manifest_contains_boss_requirements() -> void:
	var manifest := _read_text_file(ASSET_MANIFEST_PATH)
	var required_terms := [
		"stage15_seal_guardian_silhouette",
		"stage15_boss_attack_warning",
		"stage15_boss_hud_status",
		"stage15_recovery_charge_icon",
		"stage15_seal_gate_room_props",
	]

	for term in required_terms:
		assert_string_contains(manifest, term)


# 灰盒 driver 只移动到关键触发点或直接击败敌人，保护主链路，不替代 MCP 手操复核。
func _drive_stage15_loop(main_scene: Node2D) -> bool:
	var safety := 0
	while safety < 12:
		safety += 1
		var room := _get_room(main_scene)
		var player := _get_player(main_scene)
		if room == null or player == null:
			return false

		if room.scene_file_path == STAGE15_COMPLETE_ROOM_PATH:
			return true

		match room.scene_file_path:
			STAGE14_LOOP_RETURN_ROOM_PATH:
				player.global_position = room.get_node("GoalZone").global_position
			STAGE15_ANTE_ROOM_PATH:
				player.global_position = room.get_node("ExitZone").global_position
			STAGE15_MIXED_GAUNTLET_ROOM_PATH:
				_defeat_room_enemies(room)
				player.global_position = room.get_node("ExitZone").global_position
			STAGE15_BOSS_ROOM_PATH:
				var boss := room.get_node("SealGuardianBoss")
				for _i in range(int(boss.call("get_max_health"))):
					boss.call("receive_attack", Vector2.RIGHT, 120.0)
			_:
				var exit_zone := room.get_node_or_null("ExitZone") as Node2D
				if exit_zone == null:
					return false
				player.global_position = exit_zone.global_position

		await _advance_process_frames(6)

	return false


# 混合遭遇房清场 helper：直接调用 receive_attack，专注验证房间推进契约。
func _defeat_room_enemies(room: Node) -> void:
	for child in room.get_children():
		if child.name == "SealGuardianBoss":
			continue
		if child.has_method("receive_attack"):
			child.call("receive_attack", Vector2.RIGHT, 120.0)


# 指定敌人清场 helper 让全清门控测试能逐步观察剩余计数和门状态。
func _defeat_named_enemy(room: Node, enemy_name: String) -> void:
	var enemy := room.get_node(enemy_name)
	assert_not_null(enemy)
	if enemy != null and enemy.has_method("receive_attack"):
		enemy.call("receive_attack", Vector2.RIGHT, 120.0)


# Boss defeated 信号计数器，用于发现死亡信号重复发出的回归。
func _on_stage15_boss_defeated() -> void:
	_stage15_boss_defeated_signal_count += 1


# 走真实 attack 输入，覆盖玩家攻击窗口、命中查询和敌人 receive_attack 契约。
func _perform_player_attack(player: CharacterBody2D) -> void:
	Input.action_press("attack")
	await _advance_physics_frames(2)
	Input.action_release("attack")
	await _advance_physics_frames(20)


# Main fixture 验证真实房间切换、玩家重生、HUD 绑定和进度快照。
func _spawn_main_scene() -> Node2D:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)

	var main_scene := packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await _advance_process_frames(2)
	return main_scene


# 单房间 fixture 用来测试房间信号和位置触发，不经 Main，便于观察 transition payload。
func _spawn_room(scene_path: String) -> Node2D:
	var packed_scene: PackedScene = load(scene_path) as PackedScene
	assert_not_null(packed_scene, "Missing room scene: %s" % scene_path)

	if packed_scene == null:
		return null

	var room := packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


# Boss fixture 支持挂到独立 world 或测试根节点，便于分别验证命中和 Boss 公开契约。
func _spawn_seal_guardian(parent: Node = null, spawn_position: Vector2 = Vector2.ZERO) -> Node2D:
	var packed_scene: PackedScene = load(SEAL_GUARDIAN_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)

	if packed_scene == null:
		return null

	var boss := packed_scene.instantiate() as Node2D
	boss.position = spawn_position
	if parent == null:
		add_child_autofree(boss)
	else:
		parent.add_child(boss)
	await get_tree().process_frame
	return boss


# 玩家 fixture 构造最小地面，让攻击和恢复测试从稳定地面状态开始。
func _spawn_player_with_floor(spawn_position: Vector2, parent: Node = null) -> CharacterBody2D:
	var world := parent as Node2D
	if world == null:
		world = Node2D.new()
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


# 等待玩家完全落地，避免攻击和恢复测试在跳落状态中产生偶发失败。
func _wait_until_player_is_settled(player: CharacterBody2D, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.is_on_floor() and absf(player.velocity.x) <= 0.1 and absf(player.velocity.y) <= 0.1:
			await _advance_physics_frames(2)
			return
		await _advance_physics_frames(1)

	fail_test("玩家在预期帧数内没有稳定落地")


# 物理帧推进用于玩家移动、攻击窗口和 Boss 状态机。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# process 帧推进用于 Main 切房、HUD 刷新和房间位置触发。
func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


# 读取 Main 当前房间，集中处理节点路径。
func _get_room(main_scene: Node2D) -> Node2D:
	return main_scene.get_node_or_null("Room") as Node2D


# 读取当前运行时玩家，切房 / 重试后必须重新获取。
func _get_player(main_scene: Node2D) -> CharacterBody2D:
	return main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


# 读取当前房间路径，用于判断主链路是否推进到目标场景。
func _get_room_path(main_scene: Node2D) -> String:
	var room := _get_room(main_scene)
	return room.scene_file_path if room != null else ""


# 读取 asset manifest 文本，测试只关心关键追踪 ID 是否存在。
func _read_text_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "无法读取文件：%s" % path)
	return file.get_as_text() if file != null else ""
