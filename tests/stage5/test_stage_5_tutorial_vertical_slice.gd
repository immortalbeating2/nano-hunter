extends GutTest

# 阶段 5 回归测试保护教程区垂直切片。
# 它验证 Main 默认入口、TutorialRoom 教学顺序、最小 HUD 与出口解锁闭环。


const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const TUTORIAL_ROOM_SCENE_PATH := "res://scenes/rooms/tutorial_room.tscn"
const GATE_LOCKED_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres"
const GATE_OPEN_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/003_shrine_gate_prop_atlas_ai01_auto_004_c01.atlas_texture.tres"
const GATE_UNLOCK_VFX_FRAMES_PATH := "res://assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.spriteframes.tres"


# 输入环境清理：教程测试需要稳定的初始按键状态。
func before_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")
	if InputMap.has_action("dash"):
		Input.action_release("dash")


# 每条教程测试结束释放输入，避免 dash / attack 状态影响下一条教程流程。
func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	if InputMap.has_action("attack"):
		Input.action_release("attack")
	if InputMap.has_action("dash"):
		Input.action_release("dash")


# 保护默认入口：Main 必须从教程房启动，并展示第一步教程 HUD。
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


# 保护 HUD 基础排版：生命 / dash 两行不能重叠，后续 HUD 扩展要保留可读间距。
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


# 保护 HUD 文本安全区和输入设备提示：九宫格边缘不能压字，键盘 / 手柄提示要跟随最近输入切换。
func test_tutorial_hud_safe_area_and_input_device_prompt_switch() -> void:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await get_tree().process_frame

	var hud := main_scene.get_node("HUD/TutorialHUD") as Control
	var prompt_panel := hud.get_node("PromptPanel") as Panel
	var battle_panel := hud.get_node("BattlePanel") as Panel
	var step_label := hud.get_node("PromptPanel/StepLabel") as Label
	var prompt_label := hud.get_node("PromptPanel/PromptLabel") as Label
	var status_label := hud.get_node("BattlePanel/StatusLabel") as Label
	var dash_label := hud.get_node("BattlePanel/DashLabel") as Label
	var progress_label := hud.get_node("BattlePanel/ProgressLabel") as Label

	_assert_control_inside_panel_safe_area(step_label, prompt_panel)
	_assert_control_inside_panel_safe_area(prompt_label, prompt_panel)
	_assert_control_inside_panel_safe_area(status_label, battle_panel)
	_assert_control_inside_panel_safe_area(dash_label, battle_panel)
	_assert_control_inside_panel_safe_area(progress_label, battle_panel)
	assert_string_contains(prompt_label.text, "Space")

	var controller_event := InputEventJoypadButton.new()
	controller_event.button_index = JOY_BUTTON_A
	controller_event.pressed = true
	hud.call("_input", controller_event)
	assert_string_contains(prompt_label.text, "左摇杆")
	assert_string_contains(prompt_label.text, "A / Cross")

	var keyboard_event := InputEventKey.new()
	keyboard_event.keycode = KEY_SPACE
	keyboard_event.physical_keycode = KEY_SPACE
	keyboard_event.pressed = true
	hud.call("_input", keyboard_event)
	assert_string_contains(prompt_label.text, "Space")
	assert_eq(prompt_label.text.find("左摇杆"), -1)
	assert_true(_action_has_joypad_event(&"move_left"))
	assert_true(_action_has_joypad_event(&"move_right"))
	assert_true(_action_has_joypad_event(&"jump"))
	assert_true(_action_has_joypad_event(&"attack"))
	assert_true(_action_has_joypad_event(&"dash"))


# 保护教程房灰盒节点：跳跃引导、dash 门、木桩、出口阻挡和出口区都必须存在。
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
	assert_eq(jump_platform.position, Vector2(-144, 84))
	_assert_jump_guide_platform_matches_player_jump(room, jump_platform)


# 保护教程顺序：移动跳跃、dash、攻击、出口、完成必须按位置和命中事件推进。
func test_tutorial_flow_progresses_in_order_and_unlocks_exit() -> void:
	var room: Node2D = await _spawn_tutorial_room_world()
	var player: CharacterBody2D = await _spawn_player_into_room(room, Vector2(-320, 96))
	var dummy: StaticBody2D = room.get_node("TutorialDummy") as StaticBody2D
	var exit_art := room.get_node_or_null("ExitBarrier/BarrierArt") as Sprite2D

	assert_eq(room.call("get_current_step_id"), &"move_jump")
	assert_false(room.call("is_exit_unlocked"))
	assert_not_null(exit_art)
	if exit_art != null:
		assert_eq(exit_art.texture.resource_path, GATE_LOCKED_TEXTURE_PATH)

	player.global_position = Vector2(-80, 60)
	await _advance_process_frames(2)
	assert_eq(room.call("get_current_step_id"), &"dash")

	player.global_position = Vector2(252, 96)
	await _advance_process_frames(2)
	assert_eq(room.call("get_current_step_id"), &"attack")

	dummy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(2)
	assert_eq(room.call("get_current_step_id"), &"exit")
	assert_true(room.call("is_exit_unlocked"))
	if exit_art != null:
		assert_eq(exit_art.texture.resource_path, GATE_OPEN_TEXTURE_PATH)
		assert_eq(exit_art.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.seal_gate_open")
	var exit_vfx := room.get_node_or_null("ExitBarrier/GateUnlockVfxArt") as AnimatedSprite2D
	assert_not_null(exit_vfx)
	if exit_vfx != null:
		assert_not_null(exit_vfx.sprite_frames)
		assert_eq(exit_vfx.sprite_frames.resource_path, GATE_UNLOCK_VFX_FRAMES_PATH)
		assert_eq(exit_vfx.animation, &"seal_magic")
		assert_eq(exit_vfx.get_meta("runtime_source", ""), "vfx_seal_magic_atlas_ai01.gate_unlock_feedback")
		assert_true(exit_vfx.visible)

	player.global_position = Vector2(796, 96)
	await _advance_process_frames(2)
	assert_eq(room.call("get_current_step_id"), &"complete")


# 保护攻击教学反馈：玩家攻击最显眼的红色封印柱时，也必须能打开出口。
func test_attack_step_allows_red_exit_barrier_to_unlock_exit() -> void:
	var room: Node2D = await _spawn_tutorial_room_world()
	var player: CharacterBody2D = await _spawn_player_into_room(room, Vector2(-320, 96))
	var exit_barrier: StaticBody2D = room.get_node("ExitBarrier") as StaticBody2D
	var exit_barrier_shape: CollisionShape2D = room.get_node("ExitBarrier/CollisionShape2D") as CollisionShape2D
	var exit_art := room.get_node_or_null("ExitBarrier/BarrierArt") as Sprite2D

	assert_not_null(exit_barrier)
	assert_not_null(exit_barrier_shape)
	assert_not_null(exit_art)
	assert_true(exit_barrier.has_method("receive_attack"))

	player.global_position = Vector2(-80, 60)
	await _advance_process_frames(2)
	player.global_position = Vector2(252, 96)
	await _advance_process_frames(2)
	assert_eq(room.call("get_current_step_id"), &"attack")

	exit_barrier.call("receive_attack", Vector2.RIGHT, 120.0)
	await _advance_process_frames(2)

	assert_eq(room.call("get_current_step_id"), &"exit")
	assert_true(room.call("is_exit_unlocked"))
	assert_true(exit_barrier_shape.disabled)
	if exit_art != null:
		assert_eq(exit_art.texture.resource_path, GATE_OPEN_TEXTURE_PATH)
		assert_eq(exit_art.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.seal_gate_open")
	var exit_vfx := room.get_node_or_null("ExitBarrier/GateUnlockVfxArt") as AnimatedSprite2D
	assert_not_null(exit_vfx)
	if exit_vfx != null:
		assert_not_null(exit_vfx.sprite_frames)
		assert_eq(exit_vfx.sprite_frames.resource_path, GATE_UNLOCK_VFX_FRAMES_PATH)
		assert_eq(exit_vfx.get_meta("runtime_source", ""), "vfx_seal_magic_atlas_ai01.gate_unlock_feedback")
		assert_true(exit_vfx.visible)


# 保护教程第一跳的真实手感：玩家从平台左侧起跳，应能用当前配置实际落到引导平台。
func test_jump_guide_platform_is_reachable_with_current_player_config() -> void:
	var room: Node2D = await _spawn_tutorial_room_world()
	var player: CharacterBody2D = await _spawn_player_into_room(room, Vector2(-252, 96))
	var reached_platform := false

	Input.action_press("move_right")
	Input.action_press("jump")

	for _i in range(90):
		await get_tree().physics_frame
		if player.is_on_floor() and player.global_position.x >= -212.0 and player.global_position.y <= 68.0:
			reached_platform = true
			break

	Input.action_release("jump")
	Input.action_release("move_right")

	assert_true(reached_platform, "当前跳跃参数必须能实际跳上 JumpGuidePlatform。")


# 保护教程台阶语义：平台不能低成普通地面块，玩家必须能从下方通过，再选择跳到上方。
func test_jump_guide_platform_allows_passing_underneath() -> void:
	var room: Node2D = await _spawn_tutorial_room_world()
	var player: CharacterBody2D = await _spawn_player_into_room(room, Vector2(-252, 96))
	var passed_under_platform := false

	Input.action_press("move_right")
	for _i in range(120):
		await get_tree().physics_frame
		if player.global_position.x > -56.0:
			passed_under_platform = true
			break
	Input.action_release("move_right")

	assert_true(passed_under_platform)


# 保护教程 dash 门价值：普通奔跑不能稳定穿过，dash 可以通过并保持落地。
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


# 测试辅助：统一生成教程房和玩家，减少流程测试里的铺场噪音。
# 直接实例化教程房，用于验证房间自身流程，不启动完整 Main。
func _spawn_tutorial_room_world() -> Node2D:
	var room_scene: PackedScene = load(TUTORIAL_ROOM_SCENE_PATH) as PackedScene
	var room: Node2D = room_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().physics_frame
	return room


# 断言 Label 保留在当前小型 HUD 面板内，防止再次贴边或跑出框体。
func _assert_control_inside_panel_safe_area(control: Control, panel: Control) -> void:
	var horizontal_margin := 10.0
	var top_margin := 4.0
	assert_true(control.position.x >= horizontal_margin, "%s left safe area" % control.name)
	assert_true(control.position.y >= top_margin, "%s top safe area" % control.name)
	assert_true(control.position.x + control.size.x <= panel.size.x - horizontal_margin, "%s right safe area" % control.name)


# 教程提示写了手柄按键时，InputMap 也必须真的有 joypad 事件。
func _action_has_joypad_event(action: StringName) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			return true
	return false


# 在教程房中生成玩家并绑定房间，让位置触发和 HUD 上下文能正常工作。
func _spawn_player_into_room(room: Node2D, spawn_position: Vector2) -> CharacterBody2D:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	room.add_child(player)
	if room.has_method("bind_player"):
		room.call("bind_player", player)
	await _wait_until_player_is_settled(player, 64)
	return player


# 物理帧推进 helper 用于 dash 门、落地和玩家移动状态。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# process 帧推进 helper 用于等待房间位置触发和 HUD 文案更新。
func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


# 等待玩家稳定落地，避免教程位置触发在出生下落阶段误判。
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


# 保护教程平台高度：跳跃引导台阶必须低于当前玩家配置的稳定可达高度，
# 同时触发阈值应匹配玩家站上平台后的原点高度，避免“跳上去了但教程不推进”。
func _assert_jump_guide_platform_matches_player_jump(room: Node2D, jump_platform: StaticBody2D) -> void:
	var floor_start: StaticBody2D = room.get_node_or_null("FloorStart") as StaticBody2D
	var floor_shape_node: CollisionShape2D = floor_start.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var platform_shape_node: CollisionShape2D = jump_platform.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var player_config: PlayerConfig = load("res://scenes/player/player_placeholder_config.tres") as PlayerConfig
	var flow_config: RoomFlowConfig = load("res://assets/configs/rooms/tutorial_room_flow.tres") as RoomFlowConfig

	assert_not_null(floor_start)
	assert_not_null(floor_shape_node)
	assert_not_null(platform_shape_node)
	assert_not_null(player_config)
	assert_not_null(flow_config)
	if floor_start == null or floor_shape_node == null or platform_shape_node == null or player_config == null or flow_config == null:
		return

	var floor_shape := floor_shape_node.shape as RectangleShape2D
	var platform_shape := platform_shape_node.shape as RectangleShape2D
	assert_not_null(floor_shape)
	assert_not_null(platform_shape)
	if floor_shape == null or platform_shape == null:
		return

	var floor_top := floor_start.position.y - floor_shape.size.y * 0.5
	var platform_top := jump_platform.position.y - platform_shape.size.y * 0.5
	var vertical_gap := floor_top - platform_top
	var expected_full_jump_height := pow(absf(player_config.jump_velocity), 2.0) / (2.0 * player_config.rise_gravity)
	var player_half_height := 20.0
	var platform_player_origin_y := platform_top - player_half_height
	var floor_player_origin_y := floor_top - player_half_height
	var move_jump_goal_y := float(flow_config.thresholds.get(&"move_jump_goal_y", 0.0))

	assert_lte(vertical_gap, expected_full_jump_height - 8.0)
	assert_gte(move_jump_goal_y, platform_player_origin_y + 8.0)
	assert_lt(move_jump_goal_y, floor_player_origin_y)
