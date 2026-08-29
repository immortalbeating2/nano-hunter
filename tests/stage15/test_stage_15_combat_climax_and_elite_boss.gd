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
const BASIC_MELEE_ENEMY_SCENE_PATH := "res://scenes/combat/basic_melee_enemy.tscn"
const GROUND_CHARGER_ENEMY_SCENE_PATH := "res://scenes/combat/ground_charger_enemy.tscn"
const AERIAL_SENTINEL_ENEMY_SCENE_PATH := "res://scenes/combat/aerial_sentinel_enemy.tscn"
const MIASMA_CASTER_ENEMY_SCENE_PATH := "res://scenes/combat/miasma_caster_enemy.tscn"
const ENEMY_BASIC_MELEE_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_basic_melee_runtime_sheet_ai01.spriteframes.tres"
const ENEMY_GROUND_CHARGER_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_runtime_sheet_ai01.spriteframes.tres"
const ENEMY_AERIAL_SENTINEL_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_aerial_sentinel_runtime_sheet_ai01.spriteframes.tres"
const ENEMY_MIASMA_CASTER_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_miasma_caster_runtime_sheet_ai01.spriteframes.tres"
const ENEMY_BASIC_MELEE_DEFEAT_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_basic_melee_defeat_runtime_sheet_ai02.spriteframes.tres"
const ENEMY_GROUND_CHARGER_DEFEAT_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_defeat_runtime_sheet_ai02.spriteframes.tres"
const ENEMY_AERIAL_SENTINEL_DEFEAT_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_aerial_sentinel_defeat_runtime_sheet_ai02.spriteframes.tres"
const ENEMY_MIASMA_CASTER_DEFEAT_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_miasma_caster_defeat_runtime_sheet_ai02.spriteframes.tres"
const SEAL_GUARDIAN_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.spriteframes.tres"
const SEAL_GUARDIAN_WARNING_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_warning_runtime_sheet_ai01.spriteframes.tres"
const SEAL_GUARDIAN_ATTACK_BODY_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_attack_body_runtime_sheet_ai02.spriteframes.tres"
const SEAL_GUARDIAN_DEFEAT_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_defeat_runtime_sheet_ai01.spriteframes.tres"
const SEAL_GUARDIAN_ATTACK_VFX_SPRITEFRAMES_PATH := "res://assets/art/vfx/atlases/seal_guardian_attack_vfx_atlas_ai01.spriteframes.tres"
const SEAL_GUARDIAN_FORMAL_MOTION_SPRITEFRAMES_PATH := "res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_formal_motion_runtime_sheet_ai01.spriteframes.tres"
const SEAL_GUARDIAN_FORMAL_VFX_SPRITEFRAMES_PATH := "res://assets/art/vfx/atlases/stage27_seal_guardian_vfx_runtime_ai01.spriteframes.tres"
const VFX_SEAL_MAGIC_SPRITEFRAMES_PATH := "res://assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.spriteframes.tres"
const MIASMA_PURGE_WARNING_SPRITEFRAMES_PATH := "res://assets/art/vfx/atlases/miasma_purge_warning_vfx_runtime_ai01.spriteframes.tres"
const STAGE15_PRESSURE_FOCUS_ART_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/010_shrine_gate_prop_atlas_ai01_auto_011_c02.atlas_texture.tres"
const EQUIPMENT_REWARD_ORB_ATLAS_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/009_equipment_pickup_atlas_ai01_auto_010_c01.atlas_texture.tres"
const EQUIPMENT_BOSS_CORE_SHARD_ATLAS_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/019_equipment_pickup_atlas_ai01_auto_020_c02.atlas_texture.tres"

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


# 保护 Stage15 正常主线路径：地面覆盖到出口前，挑战支路不挡在右移必经线上。
func test_stage15_reachable_room_floors_and_optional_branch_route_are_playable() -> void:
	for room_path: String in [STAGE15_ANTE_ROOM_PATH, STAGE15_MIXED_GAUNTLET_ROOM_PATH, STAGE15_CHALLENGE_ROOM_PATH, STAGE15_COMPLETE_ROOM_PATH]:
		var room := await _spawn_room(room_path)
		_assert_floor_reaches_exit(room)

	var gauntlet := await _spawn_room(STAGE15_MIXED_GAUNTLET_ROOM_PATH)
	var branch_zone := gauntlet.get_node_or_null("ChallengeBranchZone") as Area2D
	assert_not_null(branch_zone)
	if branch_zone != null:
		assert_lt(branch_zone.position.x, -120.0)
		_assert_sprite_references_asset(
			gauntlet,
			"ChallengeBranchZone/ChallengeMarkerArt",
			"equipment_pickup_atlas_ai01",
			EQUIPMENT_BOSS_CORE_SHARD_ATLAS_TEXTURE_PATH
		)
		var challenge_visual := gauntlet.get_node_or_null("ChallengeBranchZone/ChallengeVisual") as Polygon2D
		assert_not_null(challenge_visual, "Stage15 挑战支路触发区只保留隐藏编辑参考，运行态读值交给 ChallengeMarkerArt。")
		if challenge_visual != null:
			assert_false(challenge_visual.visible)


# 保护 Stage15 pressure 房运行态读值：封印压力提示不应继续显示大块 Polygon 占位。
func test_stage15_pressure_room_uses_vfx_asset_for_pressure_sigil() -> void:
	var room := await _spawn_room(STAGE15_ANTE_ROOM_PATH)
	var legacy_sigil := room.get_node_or_null("PressureSigil") as Polygon2D

	assert_not_null(legacy_sigil)
	assert_false(legacy_sigil.visible)
	_assert_sprite_references_asset(
		room,
		"PressureFocusArt",
		"shrine_gate_prop_atlas_ai01",
		STAGE15_PRESSURE_FOCUS_ART_PATH
	)
	var pressure_focus := room.get_node_or_null("PressureFocusArt") as Sprite2D
	assert_not_null(pressure_focus)
	if pressure_focus != null:
		assert_eq(pressure_focus.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.seal_pillar_intact")
		assert_eq(pressure_focus.position, Vector2(128, 120))
		assert_gte(pressure_focus.z_index, 1)
		assert_lte(pressure_focus.scale.x, 0.4)
	_assert_animated_sprite_references_asset(
		room,
		"PressureSigilArt",
		"vfx_seal_magic_atlas_ai01",
		VFX_SEAL_MAGIC_SPRITEFRAMES_PATH,
		&"seal_magic"
	)
	var pressure_sigil_art := room.get_node_or_null("PressureSigilArt") as AnimatedSprite2D
	assert_not_null(pressure_sigil_art)
	if pressure_sigil_art != null:
		assert_lt(pressure_sigil_art.modulate.a, 0.51)
		assert_lt(pressure_sigil_art.scale.x, 0.46)
		assert_lt(pressure_sigil_art.scale.y, 0.46)
		if pressure_focus != null:
			assert_gt(pressure_sigil_art.z_index, pressure_focus.z_index)


# 保护 Stage15 支路腐瘴危险读值：不继续显示绿色几何 SVG / Polygon 占位。
func test_stage15_challenge_hazard_warning_uses_miasma_purge_vfx_asset() -> void:
	var room := await _spawn_room(STAGE15_CHALLENGE_ROOM_PATH)
	var warning_polygon := room.get_node_or_null("MiasmaHazard/WarningVisual") as Polygon2D
	var warning_svg := room.get_node_or_null("MiasmaHazard/MiasmaWarningArt") as Sprite2D
	var reward_marker := room.get_node_or_null("Stage13Reward") as Marker2D

	assert_not_null(warning_polygon)
	assert_null(warning_svg)
	assert_not_null(reward_marker)
	if warning_polygon != null:
		assert_false(warning_polygon.visible)
	_assert_animated_sprite_references_asset(
		room,
		"MiasmaHazard/MiasmaWarningVfxArt",
		"miasma_purge_warning_vfx_runtime_ai01",
		MIASMA_PURGE_WARNING_SPRITEFRAMES_PATH,
		&"miasma_purge_warning"
	)
	var warning_vfx := room.get_node_or_null("MiasmaHazard/MiasmaWarningVfxArt") as AnimatedSprite2D
	assert_not_null(warning_vfx)
	if warning_vfx != null:
		assert_between(warning_vfx.modulate.a, 0.5, 0.8)
		assert_between(warning_vfx.scale.x, 0.6, 0.85)
		assert_between(warning_vfx.scale.y, 0.3, 0.45)
	_assert_sprite_references_asset(
		room,
		"Stage13RewardArt",
		"equipment_pickup_atlas_ai01",
		EQUIPMENT_REWARD_ORB_ATLAS_TEXTURE_PATH
	)


# 保护 Stage15 Boss 正式运行资产：方向稿与静态预警绑定退出正式场景。
func test_stage15_boss_scene_and_room_use_runtime_boss_art_assets() -> void:
	var boss := await _spawn_seal_guardian()
	assert_null(boss.get_node_or_null("SealGuardianArt"))
	assert_null(boss.get_node_or_null("AttackWarningArt"))
	assert_null(boss.get_node_or_null("SealGuardianAnimationPreview"))
	_assert_animated_sprite_references_asset(
		boss,
		"SealGuardianRuntimeAnimationVisual",
		"seal_guardian_formal_motion_runtime_sheet_ai01",
		SEAL_GUARDIAN_FORMAL_MOTION_SPRITEFRAMES_PATH,
		&"close_pressure"
	)
	var runtime_visual := boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	assert_true(runtime_visual.visible)
	_assert_animated_sprite_references_asset(
		boss,
		"SealGuardianAttackVfxVisual",
		"seal_guardian_attack_vfx_atlas_ai01",
		SEAL_GUARDIAN_ATTACK_VFX_SPRITEFRAMES_PATH,
		&"boss_attack_vfx"
	)
	var attack_vfx_visual := boss.get_node("SealGuardianAttackVfxVisual") as AnimatedSprite2D
	assert_false(attack_vfx_visual.visible)
	assert_false(attack_vfx_visual.get_meta("gameplay_collision", true))
	assert_false(attack_vfx_visual.get_meta("damage_source", true))
	assert_null(boss.get_node_or_null("SealMagicVfxPreview"))
	assert_null(boss.get_node_or_null("CombatVfxPreview"))

	var room := await _spawn_room(STAGE15_BOSS_ROOM_PATH)
	assert_null(room.get_node_or_null("SealGuardianRoomArt"))
	assert_null(room.get_node_or_null("BossWarningRoomArt"))
	assert_null(room.get_node_or_null("SealGuardianRoomAnimationPreview"))
	assert_null(room.get_node_or_null("SealGuardianTilesetPreview"))

	var enemy_scene := load(BASIC_MELEE_ENEMY_SCENE_PATH) as PackedScene
	assert_not_null(enemy_scene)
	var enemy := enemy_scene.instantiate()
	add_child(enemy)
	assert_null(enemy.get_node_or_null("EnemiesCoreAnimationPreview"))
	_assert_animated_sprite_references_asset(
		enemy,
		"EnemyRuntimeAnimationVisual",
		"enemy_basic_melee_runtime_sheet_ai01",
		ENEMY_BASIC_MELEE_RUNTIME_SPRITEFRAMES_PATH,
		&"basic_melee_cycle"
	)
	enemy.queue_free()


# 保护普通敌人正式替换边界：四个单体 clips 只替换视觉层，不改变 AI、攻击窗口或碰撞契约。
func test_enemy_runtime_visuals_reference_single_enemy_clips() -> void:
	var cases := [
		{
			"scene": BASIC_MELEE_ENEMY_SCENE_PATH,
			"asset_id": "enemy_basic_melee_runtime_sheet_ai01",
			"resource": ENEMY_BASIC_MELEE_RUNTIME_SPRITEFRAMES_PATH,
			"animation": &"basic_melee_cycle",
			"defeat_asset_id": "enemy_basic_melee_defeat_runtime_sheet_ai02",
			"defeat_resource": ENEMY_BASIC_MELEE_DEFEAT_SPRITEFRAMES_PATH,
			"defeat_animation": &"basic_melee_defeat"
		},
		{
			"scene": GROUND_CHARGER_ENEMY_SCENE_PATH,
			"asset_id": "enemy_ground_charger_runtime_sheet_ai01",
			"resource": ENEMY_GROUND_CHARGER_RUNTIME_SPRITEFRAMES_PATH,
			"animation": &"ground_charger_cycle",
			"defeat_asset_id": "enemy_ground_charger_defeat_runtime_sheet_ai02",
			"defeat_resource": ENEMY_GROUND_CHARGER_DEFEAT_SPRITEFRAMES_PATH,
			"defeat_animation": &"ground_charger_defeat"
		},
		{
			"scene": AERIAL_SENTINEL_ENEMY_SCENE_PATH,
			"asset_id": "enemy_aerial_sentinel_runtime_sheet_ai01",
			"resource": ENEMY_AERIAL_SENTINEL_RUNTIME_SPRITEFRAMES_PATH,
			"animation": &"aerial_sentinel_cycle",
			"defeat_asset_id": "enemy_aerial_sentinel_defeat_runtime_sheet_ai02",
			"defeat_resource": ENEMY_AERIAL_SENTINEL_DEFEAT_SPRITEFRAMES_PATH,
			"defeat_animation": &"aerial_sentinel_defeat"
		},
		{
			"scene": MIASMA_CASTER_ENEMY_SCENE_PATH,
			"asset_id": "enemy_miasma_caster_runtime_sheet_ai01",
			"resource": ENEMY_MIASMA_CASTER_RUNTIME_SPRITEFRAMES_PATH,
			"animation": &"miasma_caster_cycle",
			"defeat_asset_id": "enemy_miasma_caster_defeat_runtime_sheet_ai02",
			"defeat_resource": ENEMY_MIASMA_CASTER_DEFEAT_SPRITEFRAMES_PATH,
			"defeat_animation": &"miasma_caster_defeat"
		}
	]

	for enemy_case: Dictionary in cases:
		var packed_scene := load(str(enemy_case.get("scene"))) as PackedScene
		assert_not_null(packed_scene)
		if packed_scene == null:
			continue

		var enemy := packed_scene.instantiate()
		add_child_autofree(enemy)
		await get_tree().process_frame
		_assert_animated_sprite_references_asset(
			enemy,
			"EnemyRuntimeAnimationVisual",
			str(enemy_case.get("asset_id")),
			str(enemy_case.get("resource")),
			enemy_case.get("animation") as StringName
		)
		if str(enemy_case.get("scene")) == MIASMA_CASTER_ENEMY_SCENE_PATH:
			var pressure_polygon := enemy.get_node_or_null("MiasmaPressureVisual") as Polygon2D
			assert_not_null(pressure_polygon)
			if pressure_polygon != null:
				assert_false(pressure_polygon.visible)
			var pressure_vfx := enemy.get_node_or_null("MiasmaPressureVfxVisual") as AnimatedSprite2D
			_assert_animated_sprite_references_asset(
				enemy,
				"MiasmaPressureVfxVisual",
				"miasma_purge_warning_vfx_runtime_ai01",
				MIASMA_PURGE_WARNING_SPRITEFRAMES_PATH,
				&"miasma_purge_warning"
			)
			if pressure_vfx != null:
				assert_false(pressure_vfx.get_meta("gameplay_collision", true))
				assert_false(pressure_vfx.get_meta("damage_source", true))
				assert_lt(pressure_vfx.modulate.a, 0.22)
				assert_lt(pressure_vfx.scale.x, 0.37)
				assert_lt(pressure_vfx.scale.y, 0.24)
		var visual := enemy.get_node_or_null("EnemyRuntimeAnimationVisual") as AnimatedSprite2D
		assert_not_null(visual)
		if visual == null:
			continue

		assert_true(visual.visible)
		assert_gte(visual.scale.x, 0.5)
		assert_gte(visual.scale.y, 0.5)
		assert_gte(visual.modulate.a, 0.95)
		_assert_enemy_runtime_visual_not_mixed_with_legacy_layers(enemy)
		enemy.call("receive_attack", Vector2.RIGHT, 120.0)
		assert_true(enemy.call("is_defeated"))
		assert_true(visual.visible)
		assert_eq(visual.get_meta("asset_id", ""), enemy_case.get("defeat_asset_id"))
		assert_not_null(visual.sprite_frames)
		if visual.sprite_frames != null:
			assert_eq(visual.sprite_frames.resource_path, enemy_case.get("defeat_resource"))
		assert_eq(visual.animation, enemy_case.get("defeat_animation"))


# 保护 Boss 正式替换动作边界：运行态只接入通过审查的 body clips，不使用旧 blocked attack VFX frames。
func test_seal_guardian_runtime_visual_uses_ready_clips_only() -> void:
	var boss := await _spawn_seal_guardian()
	var visual := boss.get_node_or_null("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var attack_vfx_visual := boss.get_node_or_null("SealGuardianAttackVfxVisual") as AnimatedSprite2D
	assert_not_null(visual)
	assert_not_null(attack_vfx_visual)
	if visual == null or attack_vfx_visual == null:
		return

	assert_true(visual.visible)
	_assert_seal_guardian_runtime_visual_not_mixed_with_legacy_layers(boss)
	assert_eq(visual.get_meta("asset_id", ""), "seal_guardian_formal_motion_runtime_sheet_ai01")
	assert_not_null(visual.sprite_frames)
	if visual.sprite_frames != null:
		assert_eq(visual.sprite_frames.resource_path, SEAL_GUARDIAN_FORMAL_MOTION_SPRITEFRAMES_PATH)
	assert_eq(visual.animation, &"close_pressure")
	assert_false(attack_vfx_visual.visible)
	assert_false(attack_vfx_visual.get_meta("gameplay_collision", true))
	assert_false(attack_vfx_visual.get_meta("damage_source", true))

	var dummy_player := Node2D.new()
	add_child_autofree(dummy_player)
	dummy_player.global_position = boss.global_position
	boss.call("bind_player", dummy_player)
	await _advance_physics_frames(2)
	assert_eq(boss.call("get_boss_state"), &"close_pressure")
	assert_true(visual.visible)
	assert_eq(visual.get_meta("asset_id", ""), "seal_guardian_formal_motion_runtime_sheet_ai01")
	assert_not_null(visual.sprite_frames)
	if visual.sprite_frames != null:
		assert_eq(visual.sprite_frames.resource_path, SEAL_GUARDIAN_FORMAL_MOTION_SPRITEFRAMES_PATH)
	assert_true(visual.animation == &"close_pressure" or visual.animation == &"air_warning")
	assert_true(attack_vfx_visual.visible)
	assert_eq(attack_vfx_visual.animation, &"warning")

	await _advance_physics_frames(30)
	if boss.call("get_boss_state") == &"ground_impact" or boss.call("get_boss_state") == &"air_punish":
		assert_true(visual.visible)
		assert_eq(visual.get_meta("asset_id", ""), "seal_guardian_formal_motion_runtime_sheet_ai01")
		assert_not_null(visual.sprite_frames)
		if visual.sprite_frames != null:
			assert_eq(visual.sprite_frames.resource_path, SEAL_GUARDIAN_FORMAL_MOTION_SPRITEFRAMES_PATH)
		assert_true(visual.animation == &"ground_impact" or visual.animation == &"air_punish")
		assert_ne(visual.sprite_frames.resource_path, SEAL_GUARDIAN_SPRITEFRAMES_PATH)
		assert_true(attack_vfx_visual.visible)
		assert_eq(attack_vfx_visual.get_meta("asset_id", ""), "stage27_seal_guardian_vfx_runtime_ai01")
		assert_not_null(attack_vfx_visual.sprite_frames)
		if attack_vfx_visual.sprite_frames != null:
			assert_eq(attack_vfx_visual.sprite_frames.resource_path, SEAL_GUARDIAN_FORMAL_VFX_SPRITEFRAMES_PATH)
		assert_eq(attack_vfx_visual.animation, &"impact")
		assert_false(attack_vfx_visual.get_meta("gameplay_collision", true))
		assert_false(attack_vfx_visual.get_meta("damage_source", true))

	var max_health := int(boss.call("get_max_health"))
	for _i in range(max_health):
		boss.call("receive_attack", Vector2.RIGHT, 120.0)
	assert_eq(boss.call("get_boss_state"), &"defeated")
	assert_true(visual.visible)
	assert_eq(visual.get_meta("asset_id", ""), "seal_guardian_formal_motion_runtime_sheet_ai01")
	assert_not_null(visual.sprite_frames)
	if visual.sprite_frames != null:
		assert_eq(visual.sprite_frames.resource_path, SEAL_GUARDIAN_FORMAL_MOTION_SPRITEFRAMES_PATH)
	assert_eq(visual.animation, &"defeat")
	assert_true(attack_vfx_visual.visible)
	assert_eq(attack_vfx_visual.sprite_frames.resource_path, SEAL_GUARDIAN_FORMAL_VFX_SPRITEFRAMES_PATH)
	assert_eq(attack_vfx_visual.animation, &"defeat")


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

	_defeat_named_enemy(room, "MiasmaCasterEnemy")
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


# 保护 Stage15 HUD：混合遭遇显示恢复充能条，Boss 房显示恢复充能条和 Boss 血条。
func test_stage15_hud_displays_recovery_charge_and_boss_status() -> void:
	var main_scene := await _spawn_main_scene()

	main_scene.call("transition_to_room", STAGE15_MIXED_GAUNTLET_ROOM_PATH, &"stage15_mixed_gauntlet_start")
	await _advance_process_frames(4)

	var progress_label := main_scene.get_node("HUD/TutorialHUD/BattlePanel/ProgressLabel") as Label
	var recovery_bar_back := main_scene.get_node("HUD/TutorialHUD/BattlePanel/RecoveryBarBack") as ColorRect
	var recovery_bar_fill := main_scene.get_node("HUD/TutorialHUD/BattlePanel/RecoveryBarFill") as ColorRect
	var boss_label := main_scene.get_node("HUD/TutorialHUD/BattlePanel/BossLabel") as Label
	var boss_bar_fill := main_scene.get_node("HUD/TutorialHUD/BattlePanel/BossBarFill") as ColorRect
	assert_not_null(progress_label)
	assert_true(recovery_bar_back.visible)
	assert_true(recovery_bar_fill.visible)
	assert_false(boss_bar_fill.visible)
	assert_eq(progress_label.text.find("收集："), -1)

	main_scene.call("transition_to_room", STAGE15_BOSS_ROOM_PATH, &"stage15_boss_start")
	await _advance_process_frames(4)

	var player := _get_player(main_scene)
	player.call("add_recovery_charge", 1.0)
	await _advance_process_frames(2)

	assert_gt(recovery_bar_fill.size.x, 0.0)
	assert_true(boss_label.visible)
	assert_true(boss_bar_fill.visible)
	assert_gt(boss_bar_fill.size.x, 0.0)
	assert_string_contains(boss_label.text, "封印守卫")
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
				_defeat_room_enemies(room)
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


# 地面覆盖 helper：防止正式可达房间在出口前留下空白断路。
func _assert_floor_reaches_exit(room: Node2D) -> void:
	var exit_zone := room.get_node_or_null("ExitZone") as Area2D
	assert_not_null(exit_zone)
	if exit_zone == null:
		return
	var layout := room.get_node_or_null("Phase2GrayboxLayout")
	if layout != null:
		var floor_right_edge := -INF
		for rect: Rect2 in layout.get("solid_rects"):
			floor_right_edge = maxf(floor_right_edge, rect.end.x)
		for rect: Rect2 in layout.get("one_way_rects"):
			floor_right_edge = maxf(floor_right_edge, rect.end.x)
		assert_gte(floor_right_edge, exit_zone.position.x - 36.0)
		return

	var terrain := room.get_node_or_null("TerrainCollisionVisual") as TileMapLayer
	if terrain != null and bool(terrain.get("collision_enabled")) and not terrain.get_used_cells().is_empty():
		var tile_width := float(terrain.tile_set.tile_size.x) * absf(terrain.global_scale.x)
		var floor_right_edge := -INF
		for cell: Vector2i in terrain.get_used_cells():
			var cell_left := terrain.to_global(terrain.map_to_local(cell)).x
			floor_right_edge = maxf(floor_right_edge, cell_left + tile_width)
		assert_gte(floor_right_edge, exit_zone.position.x - 36.0)
		return

	var floor := room.get_node_or_null("Floor") as StaticBody2D
	var floor_shape := room.get_node_or_null("Floor/CollisionShape2D") as CollisionShape2D
	assert_not_null(floor)
	assert_not_null(floor_shape)
	if floor == null or floor_shape == null:
		return
	var rectangle := floor_shape.shape as RectangleShape2D
	assert_not_null(rectangle)
	if rectangle == null:
		return

	var floor_right_edge := floor.position.x + rectangle.size.x * 0.5
	assert_gte(floor_right_edge, exit_zone.position.x - 36.0)


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


# 资产接入断言 helper：保护 Sprite2D 节点、asset_id metadata 和实际资源路径三者一致。
func _assert_sprite_references_asset(parent: Node, node_path: String, asset_id: String, resource_path: String) -> void:
	var sprite := parent.get_node_or_null(NodePath(node_path)) as Sprite2D
	assert_not_null(sprite, "缺少 Sprite2D 资产节点：%s" % node_path)
	if sprite == null:
		return

	assert_eq(sprite.get_meta("asset_id", ""), asset_id)
	assert_not_null(sprite.texture, "Sprite2D 没有纹理：%s" % node_path)
	if sprite.texture != null:
		assert_eq(sprite.texture.resource_path, resource_path)


# 资产接入断言 helper：保护 AnimatedSprite2D、asset_id metadata、SpriteFrames 路径和默认动画一致。
func _assert_animated_sprite_references_asset(parent: Node, node_path: String, asset_id: String, resource_path: String, animation_name: StringName) -> void:
	var animated_sprite := parent.get_node_or_null(NodePath(node_path)) as AnimatedSprite2D
	assert_not_null(animated_sprite, "缺少 AnimatedSprite2D 资产节点：%s" % node_path)
	if animated_sprite == null:
		return

	assert_eq(animated_sprite.get_meta("asset_id", ""), asset_id)
	assert_not_null(animated_sprite.sprite_frames, "AnimatedSprite2D 没有 SpriteFrames：%s" % node_path)
	if animated_sprite.sprite_frames != null:
		assert_eq(animated_sprite.sprite_frames.resource_path, resource_path)
		assert_true(animated_sprite.sprite_frames.has_animation(animation_name))
		assert_gt(animated_sprite.sprite_frames.get_frame_count(animation_name), 0)
	assert_eq(animated_sprite.animation, animation_name)


# 正式运行时动画存在时，旧灰盒 body、Stage12/13 轮廓和低透明 source sprite 不应继续叠在怪物身上。
func _assert_enemy_runtime_visual_not_mixed_with_legacy_layers(enemy: Node) -> void:
	for node_name: String in [
		"Body",
		"Stage12Silhouette",
		"Stage12ThreatMark",
		"Stage12ChargeMark",
		"Stage12AirMark",
		"Stage13Silhouette",
		"MiasmaPressureVisual",
	]:
		var legacy_visual := enemy.get_node_or_null(node_name) as CanvasItem
		if legacy_visual != null:
			assert_false(legacy_visual.visible, "旧敌人视觉层仍在运行态显示：%s" % node_name)


func _assert_seal_guardian_runtime_visual_not_mixed_with_legacy_layers(boss: Node) -> void:
	for node_name: String in [
		"Body",
		"SealHalo",
		"GuardianMask",
		"Stage15SealMark",
	]:
		var legacy_visual := boss.get_node_or_null(node_name) as CanvasItem
		if legacy_visual != null:
			assert_false(legacy_visual.visible, "旧 Boss 视觉层仍在运行态显示：%s" % node_name)
