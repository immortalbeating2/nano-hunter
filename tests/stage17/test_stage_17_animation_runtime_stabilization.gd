extends GutTest

# Stage17 专项测试保护玩家、普通敌人与 Boss 的动作运行态契约。
# 测试只实例化生产场景并观察状态、帧和可见性，不新增测试专用运行接口。

const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const BOSS_SCENE_PATH := "res://scenes/enemies/seal_guardian_boss.tscn"
const LUNA_JUMP_STATE_ASSET_ID := "luna_jump_state_runtime_sheet_ai04"

const ENEMY_CASES := [
	{
		"scene": "res://scenes/combat/basic_melee_enemy.tscn",
		"cycle": &"basic_melee_cycle",
		"defeat": &"basic_melee_defeat",
		"defeat_asset": "enemy_basic_melee_defeat_runtime_sheet_ai02",
	},
	{
		"scene": "res://scenes/combat/ground_charger_enemy.tscn",
		"cycle": &"ground_charger_cycle",
		"defeat": &"ground_charger_defeat",
		"defeat_asset": "enemy_ground_charger_defeat_runtime_sheet_ai02",
	},
	{
		"scene": "res://scenes/combat/aerial_sentinel_enemy.tscn",
		"cycle": &"aerial_sentinel_cycle",
		"defeat": &"aerial_sentinel_defeat",
		"defeat_asset": "enemy_aerial_sentinel_defeat_runtime_sheet_ai02",
	},
	{
		"scene": "res://scenes/combat/miasma_caster_enemy.tscn",
		"cycle": &"miasma_caster_cycle",
		"defeat": &"miasma_caster_defeat",
		"defeat_asset": "enemy_miasma_caster_defeat_runtime_sheet_ai02",
	},
]


# 每条测试前释放输入，避免 Input 单例把动作状态泄漏到下一条测试。
func before_each() -> void:
	_reset_input_actions()


# 每条测试后再次释放输入，保证失败测试也不会污染后续运行。
func after_each() -> void:
	_reset_input_actions()


# Luna 所有动作必须共用场景固定 transform，不能按动作补偿缩放或锚点。
func test_luna_runtime_transform_never_changes_between_actions() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var visual := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D

	for state: StringName in [&"idle", &"run", &"jump_rise", &"jump_fall", &"land", &"attack", &"air_attack", &"dash"]:
		player.set("current_state", state)
		player.call("_update_runtime_animation_visual")
		assert_eq(visual.position, Vector2(0.0, -16.0), "动作 %s 改变了 Luna runtime position。" % state)
		assert_eq(visual.scale, Vector2(0.45, 0.45), "动作 %s 改变了 Luna runtime scale。" % state)


# 攻击必须在 0.23 秒 gameplay 窗口内显示 startup / active / recovery 关键帧，VFX 只在 active 后出现。
func test_luna_attack_uses_startup_active_recovery_keyframes_within_point_23_seconds() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var visual := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var slash := player.get_node("AttackSlashVfxVisual") as AnimatedSprite2D
	var observed_frames: Dictionary = {}
	var active_vfx_seen := false

	player.call("_start_attack")
	await _advance_physics_frames(1)
	assert_eq(visual.frame, 4, "攻击 startup 必须从可读蓄势帧 4 开始。")
	assert_false(slash.visible, "startup 阶段不应提前显示 slash VFX。")

	for _i in range(20):
		if player.call("get_current_state_id") != &"attack":
			break
		observed_frames[visual.frame] = true
		if visual.frame == 6 or visual.frame == 7:
			active_vfx_seen = active_vfx_seen or slash.visible
		await _advance_physics_frames(1)

	for expected_frame: int in [4, 6, 7, 8, 10, 12]:
		assert_true(observed_frames.has(expected_frame), "攻击缺少关键帧 %d。" % expected_frame)
	assert_true(active_vfx_seen, "攻击 active 阶段必须显示 slash VFX。")
	assert_false(slash.visible, "攻击结束后必须隐藏 slash VFX。")


# Air Dash 保持 0.24 秒玩法时长，并手动走完六个姿态而不是自然播放前几帧。
func test_luna_air_dash_uses_six_readable_frames_and_does_not_end_standing() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var visual := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var observed_frames: Dictionary = {}
	var last_dash_frame := -1

	player.call("_start_dash")
	player.call("_update_runtime_animation_visual")
	assert_false(visual.is_playing(), "手动关键帧状态必须暂停 SpriteFrames 自然播放。")

	for _i in range(20):
		if player.call("get_current_state_id") != &"dash":
			break
		observed_frames[visual.frame] = true
		last_dash_frame = visual.frame
		await _advance_physics_frames(1)

	assert_gte(observed_frames.size(), 6, "Air Dash 必须观察到至少六个可读姿态。")
	for expected_frame: int in [0, 2, 4, 6, 7, 8]:
		assert_true(observed_frames.has(expected_frame), "Air Dash 缺少关键帧 %d。" % expected_frame)
	assert_eq(last_dash_frame, 8, "Air Dash 最后姿态不能提前回到站立帧。")


# 跳跃动作必须跟随物理相位，不允许一条长动画在空中自行回站姿。
func test_luna_jump_animation_follows_start_rise_fall_land_phases() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var visual := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D

	player.call("_start_jump")
	player.call("_update_runtime_animation_visual")
	assert_eq(visual.get_meta("asset_id", ""), LUNA_JUMP_STATE_ASSET_ID)
	assert_eq(visual.animation, &"jump_start")

	await _advance_physics_frames(16)
	assert_eq(player.call("get_current_state_id"), &"jump_rise")
	assert_eq(visual.animation, &"rise_hold")

	player.velocity.y = 120.0
	player.call("_update_current_state", false)
	player.call("_update_runtime_animation_visual")
	assert_eq(player.call("get_current_state_id"), &"jump_fall")
	assert_eq(visual.animation, &"fall_hold")

	player.set("current_state", &"land")
	player.set("_landing_state_timer", 0.05)
	player.call("_update_runtime_animation_visual")
	assert_eq(visual.animation, &"land")


# 受击动作在 0.20 秒结束，但 0.35 秒无敌仍应阻止第二次伤害。
func test_luna_hit_react_ends_before_invulnerability() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var visual := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D

	player.call("receive_damage", 1, Vector2.LEFT)
	assert_eq(visual.get_meta("asset_id", ""), "luna_hit_react_runtime_sheet_ai03")
	await _advance_physics_frames(13)

	assert_ne(visual.get_meta("asset_id", ""), "luna_hit_react_runtime_sheet_ai03", "受击视觉不应占满无敌时间。")
	var health_during_invulnerability := int(player.call("get_current_health"))
	player.call("receive_damage", 1, Vector2.LEFT)
	assert_eq(player.call("get_current_health"), health_during_invulnerability, "受击视觉结束时无敌仍应有效。")

	await _advance_physics_frames(10)
	player.call("receive_damage", 1, Vector2.LEFT)
	assert_eq(player.call("get_current_health"), health_during_invulnerability - 1)


# 四类普通敌人的现有 cycle 必须在 ready 后真正播放并推进帧。
func test_all_regular_enemy_cycles_start_and_advance() -> void:
	for enemy_case: Dictionary in ENEMY_CASES:
		var enemy := await _spawn_scene(str(enemy_case.get("scene")))
		var visual := enemy.get_node("EnemyRuntimeAnimationVisual") as AnimatedSprite2D
		var frame_before := visual.frame

		assert_eq(visual.animation, enemy_case.get("cycle"))
		assert_true(visual.is_playing(), "%s 的默认 cycle 未启动。" % enemy_case.get("scene"))
		var frame_advanced := await _wait_for_animation_frame_change(visual, frame_before, 30)
		assert_true(frame_advanced, "%s 的默认 cycle 没有推进帧。" % enemy_case.get("scene"))


# 普通敌人击败后应立即解除门控碰撞，但保留可见 defeat 反馈。
func test_regular_enemy_defeat_keeps_visual_feedback_without_blocking_room_clear() -> void:
	for enemy_case: Dictionary in ENEMY_CASES:
		var enemy := await _spawn_scene(str(enemy_case.get("scene")))
		var visual := enemy.get_node("EnemyRuntimeAnimationVisual") as AnimatedSprite2D

		enemy.call("receive_attack", Vector2.RIGHT, 120.0)
		await _advance_process_frames(1)
		assert_true(enemy.call("is_defeated"))
		assert_true(enemy.get_node("CollisionShape2D").disabled)
		assert_true(enemy.get_node("Hurtbox/CollisionShape2D").disabled)
		assert_true(visual.visible, "%s 击败后不应立即隐形。" % enemy_case.get("scene"))
		assert_eq(visual.animation, enemy_case.get("defeat"))
		assert_eq(visual.get_meta("asset_id", ""), enemy_case.get("defeat_asset"))


# Ground Charger 必须先读招，再冲锋、恢复，最后回到 patrol cycle。
func test_ground_charger_animation_follows_patrol_telegraph_charge_and_recover() -> void:
	var enemy := await _spawn_scene("res://scenes/combat/ground_charger_enemy.tscn")
	var visual := enemy.get_node("EnemyRuntimeAnimationVisual") as AnimatedSprite2D
	var target := CharacterBody2D.new()
	target.global_position = enemy.global_position + Vector2(32.0, 0.0)
	enemy.get_parent().add_child(target)
	autofree(target)

	enemy.call("bind_player", target)
	await _advance_physics_frames(1)
	assert_false(enemy.call("is_charge_active"), "telegraph 期间不应开始位移冲锋。")
	assert_eq(visual.animation, &"ground_charger_telegraph")

	await _advance_physics_frames(9)
	assert_true(enemy.call("is_charge_active"))
	assert_eq(visual.animation, &"ground_charger_charge")

	await _advance_physics_frames(24)
	assert_false(enemy.call("is_charge_active"))
	assert_eq(visual.animation, &"ground_charger_recover")

	await _advance_physics_frames(32)
	assert_eq(visual.animation, &"ground_charger_cycle")


# Boss 的攻击恢复和护印击破硬直必须是两个可见、独立计时的状态。
func test_boss_attack_recovery_and_stagger_are_visible_and_distinct() -> void:
	var attack_fixture := await _spawn_boss_with_player()
	var attack_boss: Node2D = attack_fixture.get("boss")
	var attack_visual := attack_boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var recovery_seen := false

	for _i in range(80):
		await _advance_physics_frames(1)
		if attack_boss.call("get_boss_state") == &"recovery":
			recovery_seen = true
			assert_true(attack_visual.visible)
			assert_eq(attack_visual.animation, &"recovery")
			break
	assert_true(recovery_seen, "Boss strike 后没有进入独立 recovery。")

	var stagger_boss := await _spawn_scene(BOSS_SCENE_PATH)
	var stagger_visual := stagger_boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	for _i in range(int(stagger_boss.call("get_max_guard"))):
		stagger_boss.call("receive_attack", Vector2.RIGHT, 120.0)

	assert_eq(stagger_boss.call("get_boss_state"), &"staggered")
	assert_true(stagger_visual.visible, "Boss staggered 不能落入隐藏分支。")
	assert_eq(stagger_visual.animation, &"guard_break")
	assert_eq(stagger_visual.get_meta("asset_id", ""), "seal_guardian_formal_motion_runtime_sheet_ai01")


# Boss 单次攻击只能结算一次伤害，同时 body 与 VFX 必须进入后半恢复帧。
func test_boss_attack_body_and_vfx_reach_late_frames_and_damage_once() -> void:
	var fixture := await _spawn_boss_with_player()
	var boss: Node2D = fixture.get("boss")
	var player: CharacterBody2D = fixture.get("player")
	var body := boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var vfx := boss.get_node("SealGuardianAttackVfxVisual") as AnimatedSprite2D
	var starting_health := int(player.call("get_current_health"))
	var max_body_frame := -1
	var max_vfx_frame := -1

	for _i in range(75):
		await _advance_physics_frames(1)
		if body.visible and (boss.call("get_boss_state") == &"ground_impact" or boss.call("get_boss_state") == &"air_punish" or boss.call("get_boss_state") == &"recovery"):
			max_body_frame = maxi(max_body_frame, body.frame)
		if vfx.visible:
			max_vfx_frame = maxi(max_vfx_frame, vfx.frame)

	assert_eq(player.call("get_current_health"), starting_health - 1, "Boss 单次 attack cycle 只能结算一次伤害。")
	assert_gte(max_body_frame, 2, "Boss body 没有进入四帧动作的后半段。")
	assert_gte(max_vfx_frame, 2, "Boss VFX 没有进入四帧动作的后半段。")


# 构造带地板的真实玩家，供攻击、Dash、跳跃和受击状态在物理帧中运行。
func _spawn_player_with_floor(spawn_position: Vector2, parent: Node = null) -> CharacterBody2D:
	var world := parent
	if world == null:
		world = Node2D.new()
		add_child_autofree(world)

	var floor := StaticBody2D.new()
	floor.position = Vector2(0.0, 160.0)
	world.add_child(floor)
	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(1024.0, 32.0)
	floor_shape.shape = rectangle
	floor.add_child(floor_shape)

	var packed_scene := load(PLAYER_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)
	var player := packed_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	world.add_child(player)
	await _wait_until_player_is_settled(player, 64)
	return player


# 实例化生产场景并等待 ready，用于普通敌人与 Boss 行为测试。
func _spawn_scene(scene_path: String) -> Node2D:
	var packed_scene := load(scene_path) as PackedScene
	assert_not_null(packed_scene, "无法加载生产场景：%s" % scene_path)
	var instance := packed_scene.instantiate() as Node2D
	add_child_autofree(instance)
	await _advance_process_frames(1)
	return instance


# 构造共享世界中的真实玩家和 Boss，使用生产 receive_damage 与距离判定。
func _spawn_boss_with_player() -> Dictionary:
	var world := Node2D.new()
	add_child_autofree(world)
	var player := await _spawn_player_with_floor(Vector2(0.0, 96.0), world)
	var packed_scene := load(BOSS_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)
	var boss := packed_scene.instantiate() as Node2D
	boss.position = Vector2(40.0, 160.0)
	world.add_child(boss)
	await _advance_process_frames(1)
	boss.call("bind_player", player)
	return {"boss": boss, "player": player}


# 等待玩家稳定落地，避免测试在出生物理状态未收敛时起手动作。
func _wait_until_player_is_settled(player: CharacterBody2D, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.is_on_floor() and absf(player.velocity.y) <= 0.1:
			await _advance_physics_frames(2)
			return
		await _advance_physics_frames(1)
	fail_test("玩家未在预期帧数内稳定落地。")


# 统一推进物理帧，服务玩法计时、AI 状态和 AnimatedSprite2D 运行观察。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# 统一推进 process 帧，服务 ready、资源播放和 deferred 状态生效。
func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


# 动画帧率低于测试进程帧率时按状态等待，避免固定帧数在不同机器上产生假失败。
func _wait_for_animation_frame_change(visual: AnimatedSprite2D, initial_frame: int, max_frames: int) -> bool:
	for _i in range(max_frames):
		await get_tree().process_frame
		if visual.frame != initial_frame:
			return true
	return false


# 输入清理覆盖当前玩家动作，避免 GUT 测试之间共享按键状态。
func _reset_input_actions() -> void:
	for action: StringName in [&"move_left", &"move_right", &"jump", &"attack", &"dash", &"recover"]:
		if InputMap.has_action(action):
			Input.action_release(action)
