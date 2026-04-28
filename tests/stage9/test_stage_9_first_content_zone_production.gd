extends GutTest

# 阶段 9 回归测试保护首个小区域内容生产。
# 它覆盖五房间主线链路、第二类敌人、开关门门控与 checkpoint 恢复。


const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const ZONE_ENTRY_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_entry_room.tscn"
const ZONE_COMBAT_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_combat_room.tscn"
const ZONE_CHARGER_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_charger_room.tscn"
const ZONE_SWITCH_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_switch_room.tscn"
const ZONE_FINAL_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_final_room.tscn"
const CHARGER_ENEMY_SCENE_PATH := "res://scenes/combat/ground_charger_enemy.tscn"
const CHARGER_ENEMY_CONFIG_SCRIPT_PATH := "res://scripts/configs/ground_charger_enemy_config.gd"


# 输入环境清理：保证区域推进和 checkpoint 测试不受前一条输入影响。
func before_each() -> void:
	_reset_input_actions()


# 每条 Stage9 测试结束释放输入，避免区域推进和失败重试被残留动作影响。
func after_each() -> void:
	_reset_input_actions()


# 保护 Stage9 区域骨架：五个主线房间场景必须都能加载。
func test_stage9_zone_forms_a_five_room_linear_chain() -> void:
	var room_paths := [
		ZONE_ENTRY_ROOM_SCENE_PATH,
		ZONE_COMBAT_ROOM_SCENE_PATH,
		ZONE_CHARGER_ROOM_SCENE_PATH,
		ZONE_SWITCH_ROOM_SCENE_PATH,
		ZONE_FINAL_ROOM_SCENE_PATH,
	]

	for room_path in room_paths:
		var packed_scene: PackedScene = load(room_path) as PackedScene
		assert_not_null(packed_scene, "缺少房间场景: %s" % room_path)


# 保护第二类敌人契约：冲锋敌必须使用配置资源，并在玩家进入触发距离后进入冲锋状态。
func test_ground_charger_enemy_uses_config_resource_and_exposes_charge_state() -> void:
	var packed_scene: PackedScene = load(CHARGER_ENEMY_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var enemy: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(enemy)
	await get_tree().process_frame

	var player: CharacterBody2D = await _spawn_player(enemy.get_parent(), enemy.global_position + Vector2(-32.0, 0.0))

	assert_true(enemy.has_method("bind_player"))
	enemy.call("bind_player", player)
	await _advance_physics_frames(10)

	var config: Resource = enemy.get("config") as Resource

	assert_not_null(config)
	assert_eq(config.get_script().resource_path, CHARGER_ENEMY_CONFIG_SCRIPT_PATH)
	assert_true(enemy.call("is_charge_active"))


# 保护开关门门控：激活开关后房间 gate 状态和碰撞形状必须同步解锁。
func test_switch_room_unlocks_gate_after_switch_activation() -> void:
	var room := await _spawn_room(ZONE_SWITCH_ROOM_SCENE_PATH)
	var gate_shape: CollisionShape2D = room.get_node_or_null("GateBarrier/CollisionShape2D") as CollisionShape2D

	assert_not_null(gate_shape)
	assert_false(room.call("is_gate_unlocked"))
	assert_false(gate_shape.disabled)

	room.call("activate_gate_switch")
	await _advance_process_frames(2)

	assert_true(room.call("is_gate_unlocked"))
	assert_true(gate_shape.disabled)


# 保护 Stage9 checkpoint：进入后续房间死亡时应回到最近的 charger checkpoint 房。
func test_main_resets_stage9_progress_to_last_checkpoint_room() -> void:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame

	main_scene.call("transition_to_room", ZONE_ENTRY_ROOM_SCENE_PATH, &"zone_entry_start")
	await _advance_process_frames(2)

	var entry_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(entry_room)
	entry_room.emit_signal("room_transition_requested", ZONE_COMBAT_ROOM_SCENE_PATH, &"zone_combat_start")
	await _advance_process_frames(2)

	var combat_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(combat_room)
	combat_room.emit_signal("room_transition_requested", ZONE_CHARGER_ROOM_SCENE_PATH, &"zone_charger_start")
	await _advance_process_frames(2)

	var charger_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	var player: CharacterBody2D = main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D

	assert_not_null(charger_room)
	assert_not_null(player)
	assert_eq(charger_room.scene_file_path, ZONE_CHARGER_ROOM_SCENE_PATH)

	charger_room.call("activate_checkpoint")
	charger_room.emit_signal("room_transition_requested", ZONE_FINAL_ROOM_SCENE_PATH, &"zone_final_start")
	await _advance_process_frames(2)

	var final_room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	var final_player: CharacterBody2D = main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D

	assert_not_null(final_room)
	assert_not_null(final_player)

	await _defeat_player(final_player)
	await _advance_process_frames(4)
	await _advance_physics_frames(8)

	var reset_room: Node2D = main_scene.get_node_or_null("Room") as Node2D

	assert_not_null(reset_room)
	assert_eq(reset_room.scene_file_path, ZONE_CHARGER_ROOM_SCENE_PATH)


# 测试辅助：统一生成房间、玩家和失败流程，减少区域测试里的重复样板。
# 独立加载指定房间，供开关、敌人和房间链路测试复用。
func _spawn_room(scene_path: String) -> Node2D:
	var packed_scene: PackedScene = load(scene_path) as PackedScene

	assert_not_null(packed_scene)

	var room: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


# 在指定父节点下生成玩家，用于给敌人或房间触发逻辑提供目标。
func _spawn_player(parent: Node, spawn_position: Vector2) -> CharacterBody2D:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene

	assert_not_null(player_scene)

	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	autofree(player)
	parent.add_child(player)
	player.global_position = spawn_position
	await _advance_process_frames(1)
	return player


# 主动击败玩家，验证 Main 在 Stage9 checkpoint 下的恢复路径。
func _defeat_player(player: CharacterBody2D) -> void:
	for _i in range(3):
		await _advance_physics_frames(24)
		player.call("receive_damage", 1, Vector2.RIGHT)
		await _advance_physics_frames(2)


# 物理帧推进 helper 用于冲锋敌触发、玩家受击和死亡流程。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# process 帧推进 helper 用于等待 Main 切房、房间 ready 和 checkpoint 绑定。
func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


# 输入清理覆盖当前已定义动作，保证 Stage9 区域测试之间互不串扰。
func _reset_input_actions() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")
	if InputMap.has_action("dash"):
		Input.action_release("dash")
