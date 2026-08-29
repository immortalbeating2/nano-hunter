extends GutTest

# 阶段 9 回归测试保护首个小区域内容生产。
# 它覆盖五房间主线链路、第二类敌人、开关门门控与 checkpoint 恢复。


const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const GOAL_TRIAL_ROOM_SCENE_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const ZONE_ENTRY_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_entry_room.tscn"
const ZONE_COMBAT_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_combat_room.tscn"
const ZONE_CHARGER_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_charger_room.tscn"
const ZONE_SWITCH_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_switch_room.tscn"
const ZONE_FINAL_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_final_room.tscn"
const CHARGER_ENEMY_SCENE_PATH := "res://scenes/combat/ground_charger_enemy.tscn"
const CHARGER_ENEMY_CONFIG_SCRIPT_PATH := "res://scripts/configs/ground_charger_enemy_config.gd"
const SWITCH_IDLE_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/006_shrine_gate_prop_atlas_ai01_auto_007_c01.atlas_texture.tres"
const SWITCH_LIT_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/007_shrine_gate_prop_atlas_ai01_auto_008_c01.atlas_texture.tres"
const GATE_LOCKED_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres"
const GATE_OPEN_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/003_shrine_gate_prop_atlas_ai01_auto_004_c01.atlas_texture.tres"
const GATE_UNLOCK_VFX_FRAMES_PATH := "res://assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.spriteframes.tres"


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
	var switch_visual: Polygon2D = room.get_node_or_null("GateSwitch/SwitchVisual") as Polygon2D
	var gate_art: Sprite2D = room.get_node_or_null("GateBarrier/BarrierArt") as Sprite2D
	var switch_art: Sprite2D = room.get_node_or_null("GateSwitch/SwitchArt") as Sprite2D

	assert_not_null(gate_shape)
	assert_not_null(gate_art)
	if gate_art != null:
		assert_eq(gate_art.texture.resource_path, GATE_LOCKED_TEXTURE_PATH)
		assert_eq(gate_art.get_meta("asset_id", ""), "shrine_gate_prop_atlas_ai01")
		assert_eq(gate_art.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.seal_gate_locked")
	assert_not_null(switch_visual)
	assert_false(switch_visual.visible)
	assert_null(room.get_node_or_null("GateSwitch/Stage12CheckpointMarker"))
	assert_not_null(switch_art)
	assert_eq(switch_art.texture.resource_path, SWITCH_IDLE_TEXTURE_PATH)
	assert_eq(switch_art.get_meta("asset_id", ""), "shrine_gate_prop_atlas_ai01")
	assert_eq(switch_art.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.talisman_stake_idle")
	assert_false(room.call("is_gate_unlocked"))
	assert_false(gate_shape.disabled)

	room.call("activate_gate_switch")
	await _advance_process_frames(2)

	assert_true(room.call("is_gate_unlocked"))
	assert_true(gate_shape.disabled)
	if switch_art != null:
		assert_eq(switch_art.texture.resource_path, SWITCH_LIT_TEXTURE_PATH)
		assert_eq(switch_art.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.talisman_stake_lit")
	var switch_vfx := room.get_node_or_null("GateSwitch/SwitchActivateVfxArt") as AnimatedSprite2D
	assert_not_null(switch_vfx)
	if switch_vfx != null:
		assert_not_null(switch_vfx.sprite_frames)
		assert_eq(switch_vfx.sprite_frames.resource_path, GATE_UNLOCK_VFX_FRAMES_PATH)
		assert_eq(switch_vfx.animation, &"seal_magic")
		assert_eq(switch_vfx.get_meta("runtime_source", ""), "vfx_seal_magic_atlas_ai01.switch_activate_feedback")
		assert_true(switch_vfx.visible)
	if gate_art != null:
		assert_eq(gate_art.texture.resource_path, GATE_OPEN_TEXTURE_PATH)
		assert_eq(gate_art.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.seal_gate_open")
	var gate_vfx := room.get_node_or_null("GateBarrier/GateUnlockVfxArt") as AnimatedSprite2D
	assert_not_null(gate_vfx)
	if gate_vfx != null:
		assert_not_null(gate_vfx.sprite_frames)
		assert_eq(gate_vfx.sprite_frames.resource_path, GATE_UNLOCK_VFX_FRAMES_PATH)
		assert_eq(gate_vfx.get_meta("runtime_source", ""), "vfx_seal_magic_atlas_ai01.gate_unlock_feedback")
		assert_true(gate_vfx.visible)


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


# 保护 Room3 -> Room4 -> Room3 -> Room4 回访：第二次进入入口房不能把合法出生瞬间误判成跌落。
func test_goal_trial_stage9_entry_round_trip_does_not_emit_false_fall_notice() -> void:
	var packed_scene := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)
	var main_scene := packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame

	main_scene.call("transition_to_room", GOAL_TRIAL_ROOM_SCENE_PATH, &"goal_entry")
	await _advance_process_frames(2)
	await _complete_goal_room(main_scene)
	await _advance_process_frames(6)
	await _advance_physics_frames(30)

	var entry_room := main_scene.get_node_or_null("Room") as Node2D
	var player := main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var failure_panel := main_scene.get_node_or_null("HUD/DemoShell/FailurePanel") as Panel
	assert_not_null(entry_room)
	assert_not_null(player)
	assert_not_null(failure_panel)
	if entry_room == null or player == null or failure_panel == null:
		return
	assert_eq(entry_room.scene_file_path, ZONE_ENTRY_ROOM_SCENE_PATH)
	assert_false(failure_panel.visible, "第一次进入 Room4 不应显示跌落提示。")
	# 使用真实左移输入穿过 Room4 左出口，并故意让输入跨过切房帧，复现玩家正常回访手势。
	Input.action_press("move_left")
	await _advance_until_room(main_scene, GOAL_TRIAL_ROOM_SCENE_PATH, 180)
	await _advance_physics_frames(12)
	Input.action_release("move_left")

	var goal_room := main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(goal_room)
	assert_eq(goal_room.scene_file_path, GOAL_TRIAL_ROOM_SCENE_PATH)
	if goal_room == null or goal_room.scene_file_path != GOAL_TRIAL_ROOM_SCENE_PATH:
		return
	# 玩家实际回房后不会立刻传送；这里保留落地时间，才能捕获 goal_return 位于无支撑区时的真实误判。
	await _advance_physics_frames(120)
	goal_room = main_scene.get_node_or_null("Room") as Node2D
	var returned_player := main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	failure_panel = main_scene.get_node_or_null("HUD/DemoShell/FailurePanel") as Panel
	assert_not_null(goal_room)
	assert_not_null(returned_player)
	assert_not_null(failure_panel)
	if goal_room == null or returned_player == null or failure_panel == null:
		return
	assert_eq(goal_room.scene_file_path, GOAL_TRIAL_ROOM_SCENE_PATH, "从 Room4 返回后必须稳定留在 Room3，而不是跌落回 checkpoint。")
	assert_true(returned_player.is_on_floor(), "Room3 的 goal_return 必须在自然物理落地后保持接地。")
	assert_lte(returned_player.global_position.y, 256.0, "Room3 回访落点不得接近跌落阈值。")
	assert_false(failure_panel.visible, "Room3 的 goal_return 出生点必须有可站立支撑。")
	if goal_room.scene_file_path != GOAL_TRIAL_ROOM_SCENE_PATH:
		return
	# 第二次向右推进必须完全走真实路径；不能再次清敌或传送到 GoalZone，否则会掩盖回访后门控重置。
	Input.action_press("move_right")
	await _advance_until_room(main_scene, ZONE_ENTRY_ROOM_SCENE_PATH, 240)
	Input.action_release("move_right")
	await _advance_process_frames(6)
	await _advance_physics_frames(12)

	var second_entry := main_scene.get_node_or_null("Room") as Node2D
	var second_player := main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_not_null(second_entry)
	assert_not_null(second_player)
	assert_not_null(failure_panel)
	if second_entry == null or second_player == null or failure_panel == null:
		return
	assert_eq(second_entry.scene_file_path, ZONE_ENTRY_ROOM_SCENE_PATH)
	assert_lte(second_player.global_position.y, 192.0, "第二次进入 Room4 的玩家必须位于房间相机底边之上。")
	assert_false(failure_panel.visible, "合法回访不得显示“已跌落”恢复提示。")


# 换房帧可能短暂读到旧接触/越界坐标；只允许这段瞬态被忽略，缓冲结束后的真实跌落仍须恢复。
func test_room_entry_fall_guard_ignores_transition_spike_but_still_detects_real_fall() -> void:
	var packed_scene := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)
	var main_scene := packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame

	main_scene.call("transition_to_room", ZONE_ENTRY_ROOM_SCENE_PATH, &"zone_entry_start")
	var player := main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var failure_panel := main_scene.get_node_or_null("HUD/DemoShell/FailurePanel") as Panel
	assert_not_null(player)
	assert_not_null(failure_panel)
	if player == null or failure_panel == null:
		return

	player.global_position.y = 420.0
	main_scene.call("_process", 0.016)
	assert_false(failure_panel.visible, "刚换房的单帧越界读值不能直接弹出跌落失败。")
	if failure_panel.visible:
		return

	player.global_position.y = 140.0
	main_scene.call("_process", 0.5)
	player.global_position.y = 420.0
	main_scene.call("_process", 0.016)
	assert_true(failure_panel.visible, "换房保护结束后，真实跌落仍必须触发恢复。")


# 通过敌人的公开受击契约和目标区推进 GoalTrial，不调用房间私有完成函数。
func _complete_goal_room(main_scene: Node2D) -> void:
	var goal_room := main_scene.get_node_or_null("Room") as Node2D
	assert_not_null(goal_room)
	if goal_room == null:
		return
	var enemy := goal_room.get_node_or_null("BasicMeleeEnemy")
	var player := main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var goal_zone := goal_room.get_node_or_null("GoalZone") as Area2D
	assert_not_null(enemy)
	assert_not_null(player)
	assert_not_null(goal_zone)
	if enemy == null or player == null or goal_zone == null:
		return
	if enemy.has_method("receive_attack"):
		enemy.call("receive_attack", Vector2.RIGHT, 0.0)
	await _advance_process_frames(1)
	player.global_position = goal_zone.global_position
	await _advance_process_frames(2)


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
		if not is_instance_valid(player):
			return
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


# 真实输入回访测试等待指定房间出现，不改玩家坐标或直接发送房间信号。
func _advance_until_room(main_scene: Node2D, expected_room_path: String, max_physics_frames: int) -> void:
	for _i in range(max_physics_frames):
		await get_tree().physics_frame
		var current_room := main_scene.get_node_or_null("Room") as Node2D
		if current_room != null and current_room.scene_file_path == expected_room_path:
			return


# 输入清理覆盖当前已定义动作，保证 Stage9 区域测试之间互不串扰。
func _reset_input_actions() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")
	if InputMap.has_action("dash"):
		Input.action_release("dash")
