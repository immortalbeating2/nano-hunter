extends GutTest

# 阶段 14 回归测试保护第一条真实回溯契约：
# 获得 1 个探索能力、回到旧空间、打开能力门，并保证能力状态能跨房间保留。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const STAGE13_GOAL_ROOM_PATH := "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"
const STAGE14_SHRINE_ROOM_PATH := "res://scenes/rooms/stage14_air_dash_shrine_room.tscn"
const STAGE14_GATE_ROOM_PATH := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const STAGE14_HUB_ROOM_PATH := "res://scenes/rooms/stage14_backtrack_hub_room.tscn"
const STAGE14_LOOP_RETURN_ROOM_PATH := "res://scenes/rooms/stage14_loop_return_room.tscn"
const ASSET_MANIFEST_PATH := "res://docs/assets/asset-manifest.md"
const MIASMA_TILESET_RESOURCE_PATH := "res://assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres"
const LUNA_RUN_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.spriteframes.tres"
const LUNA_RUN_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_run_runtime_sheet_ai01.spriteframes.tres"
const LUNA_AIR_DASH_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.spriteframes.tres"
const LUNA_ATTACK_01_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.spriteframes.tres"
const LUNA_IDLE_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/luna_idle_sheet_ai01.spriteframes.tres"
const LUNA_IDLE_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_idle_runtime_sheet_ai01.spriteframes.tres"
const LUNA_JUMP_FALL_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/luna_jump_fall_sheet_ai01.spriteframes.tres"
const LUNA_JUMP_FALL_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_fall_runtime_sheet_ai01.spriteframes.tres"
const LUNA_ATTACK_BODY_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_attack_body_runtime_sheet_ai02.spriteframes.tres"
const LUNA_AIR_DASH_BODY_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_air_dash_body_runtime_sheet_ai02.spriteframes.tres"
const LUNA_HIT_REACT_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_hit_react_runtime_sheet_ai01.spriteframes.tres"
const LUNA_DEATH_IDLE_RUNTIME_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_death_idle_runtime_sheet_ai01.spriteframes.tres"
const LUNA_HIT_DEATH_SPRITEFRAMES_PATH := "res://assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.spriteframes.tres"
const VFX_SEAL_MAGIC_SPRITEFRAMES_PATH := "res://assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.spriteframes.tres"
const VFX_COMBAT_SPRITEFRAMES_PATH := "res://assets/art/vfx/atlases/vfx_combat_atlas_ai01.spriteframes.tres"
const LUNA_ATTACK_SLASH_VFX_SPRITEFRAMES_PATH := "res://assets/art/vfx/atlases/luna_attack_slash_vfx_runtime_ai01.spriteframes.tres"
const LUNA_ATTACK_SEAL_ARC_VFX_SPRITEFRAMES_PATH := "res://assets/art/vfx/atlases/luna_attack_seal_arc_vfx_runtime_ai01.spriteframes.tres"


# 输入清理：Stage14 空中冲刺测试依赖 dash / jump 状态从干净输入开始。
func before_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("attack")
	Input.action_release("dash")


# 每条 Stage14 测试结束释放输入，避免空中冲刺剩余输入影响下一条。
func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("attack")
	Input.action_release("dash")


# 保护 Air Dash public interface：默认锁定，HUD 快照也必须显示未解锁不可用。
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


# 保护 Air Dash 使用规则：未解锁不能空中 dash，解锁后空中只能用一次。
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


# 保护落地恢复：空中 dash 消耗后，玩家落地必须恢复一次可用机会。
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


# 保护 Stage14 房间集合和能力门：门房默认阻挡，能力解锁后自动开门。
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


# 保护 Stage14 Air Dash 静态道具资产：神龛和能力门房间应引用当前项目内的 image gen 道具图。
func test_stage14_air_dash_rooms_reference_shrine_and_gate_art() -> void:
	var shrine_room := await _spawn_room(STAGE14_SHRINE_ROOM_PATH)
	_assert_sprite_references_asset(
		shrine_room,
		"AirDashShrine/ShrineArt",
		"stage14_air_dash_shrine_ai01",
		"res://assets/art/props/stage14_air_dash_shrine_ai01.png"
	)
	_assert_sprite_references_asset(
		shrine_room,
		"AirDashShrine/GatePreviewArt",
		"stage14_air_dash_gate_ai01",
		"res://assets/art/props/stage14_air_dash_gate_ai01.png"
	)
	_assert_sprite_references_asset(
		shrine_room,
		"AirDashShrine/AirDashTrailPreviewArt",
		"stage14_air_dash_trail_ai01",
		"res://assets/art/vfx/stage14_air_dash_trail_ai01.png"
	)

	var gate_room := await _spawn_room(STAGE14_GATE_ROOM_PATH)
	_assert_sprite_references_asset(
		gate_room,
		"AirDashGateSensor/ShrineEchoArt",
		"stage14_air_dash_shrine_ai01",
		"res://assets/art/props/stage14_air_dash_shrine_ai01.png"
	)
	_assert_sprite_references_asset(
		gate_room,
		"GateBarrier/GateArt",
		"stage14_air_dash_gate_ai01",
		"res://assets/art/props/stage14_air_dash_gate_ai01.png"
	)
	_assert_tileset_preview_references_asset(gate_room, "MiasmaTilesetPreview")


# 保护玩家可读性方向稿和 Air Dash trail 资源：玩家场景应直接引用当前项目 image gen 资源。
func test_stage14_player_scene_references_luna_readability_and_dash_trail_art() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	_assert_sprite_references_asset(
		player,
		"LunaReadabilityArt",
		"stage16_luna_player_readability_ai01",
		"res://assets/art/characters/player/stage16_luna_player_readability_ai01.png"
	)
	_assert_sprite_references_asset(
		player,
		"AirDashTrailArt",
		"stage14_air_dash_trail_ai01",
		"res://assets/art/vfx/stage14_air_dash_trail_ai01.png"
	)
	var air_dash_trail := player.get_node("AirDashTrailArt") as Sprite2D
	assert_false(air_dash_trail.visible)
	assert_false(air_dash_trail.get_meta("gameplay_collision", true))
	assert_false(air_dash_trail.get_meta("damage_source", true))
	_assert_animated_sprite_references_asset(
		player,
		"LunaRuntimeAnimationVisual",
		"luna_idle_runtime_sheet_ai01",
		LUNA_IDLE_RUNTIME_SPRITEFRAMES_PATH,
		&"idle"
	)
	var runtime_visual := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	assert_true(runtime_visual.visible)
	assert_true(runtime_visual.is_playing())
	_assert_animated_sprite_references_asset(
		player,
		"LunaRunAnimationPreview",
		"luna_run_sheet_ai01",
		LUNA_RUN_SPRITEFRAMES_PATH,
		&"run"
	)
	_assert_animated_sprite_references_asset(
		player,
		"LunaAirDashAnimationPreview",
		"luna_air_dash_sheet_ai01",
		LUNA_AIR_DASH_SPRITEFRAMES_PATH,
		&"air_dash"
	)
	_assert_animated_sprite_references_asset(
		player,
		"LunaAttackAnimationPreview",
		"luna_attack_01_sheet_ai01",
		LUNA_ATTACK_01_SPRITEFRAMES_PATH,
		&"attack_01"
	)
	_assert_animated_sprite_references_asset(
		player,
		"LunaIdleAnimationPreview",
		"luna_idle_sheet_ai01",
		LUNA_IDLE_SPRITEFRAMES_PATH,
		&"idle"
	)
	_assert_animated_sprite_references_asset(
		player,
		"LunaJumpFallAnimationPreview",
		"luna_jump_fall_sheet_ai01",
		LUNA_JUMP_FALL_SPRITEFRAMES_PATH,
		&"jump_fall"
	)
	_assert_animated_sprite_references_asset(
		player,
		"LunaHitDeathAnimationPreview",
		"luna_hit_death_sheet_ai01",
		LUNA_HIT_DEATH_SPRITEFRAMES_PATH,
		&"hit_death"
	)
	_assert_animated_sprite_references_asset(
		player,
		"SealMagicVfxPreview",
		"vfx_seal_magic_atlas_ai01",
		VFX_SEAL_MAGIC_SPRITEFRAMES_PATH,
		&"seal_magic"
	)
	_assert_animated_sprite_references_asset(
		player,
		"CombatVfxPreview",
		"vfx_combat_atlas_ai01",
		VFX_COMBAT_SPRITEFRAMES_PATH,
		&"combat_vfx"
	)
	_assert_animated_sprite_references_asset(
		player,
		"AttackSlashVfxVisual",
		"luna_attack_slash_vfx_runtime_ai01",
		LUNA_ATTACK_SLASH_VFX_SPRITEFRAMES_PATH,
		&"attack_slash"
	)
	_assert_animated_sprite_references_asset(
		player,
		"AttackSealArcVfxVisual",
		"luna_attack_seal_arc_vfx_runtime_ai01",
		LUNA_ATTACK_SEAL_ARC_VFX_SPRITEFRAMES_PATH,
		&"attack_seal_arc"
	)
	var attack_slash_vfx := player.get_node("AttackSlashVfxVisual") as AnimatedSprite2D
	var attack_seal_arc_vfx := player.get_node("AttackSealArcVfxVisual") as AnimatedSprite2D
	var legacy_slash := player.get_node("Stage12SlashPreview") as Sprite2D
	assert_false(attack_slash_vfx.visible)
	assert_false(attack_seal_arc_vfx.visible)
	assert_false(legacy_slash.visible)
	assert_false(attack_slash_vfx.get_meta("gameplay_collision", true))
	assert_false(attack_slash_vfx.get_meta("damage_source", true))
	assert_false(attack_seal_arc_vfx.get_meta("gameplay_collision", true))
	assert_false(attack_seal_arc_vfx.get_meta("damage_source", true))
	assert_false(legacy_slash.get_meta("gameplay_collision", true))
	assert_false(legacy_slash.get_meta("damage_source", true))
	assert_false(_has_collision_or_area_child(attack_slash_vfx))
	assert_false(_has_collision_or_area_child(attack_seal_arc_vfx))


# 保护 Luna movement 正式替换候选：只有通过 runtime audit 的 sheet 才进入玩家运行时动画节点。
func test_stage14_player_runtime_animation_visual_switches_idle_run_and_jump_fall() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var runtime_visual := player.get_node_or_null("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	assert_not_null(runtime_visual)
	if runtime_visual == null:
		return

	assert_true(runtime_visual.visible)
	assert_eq(runtime_visual.get_meta("asset_id", ""), "luna_idle_runtime_sheet_ai01")
	assert_eq(runtime_visual.sprite_frames.resource_path, LUNA_IDLE_RUNTIME_SPRITEFRAMES_PATH)
	assert_eq(runtime_visual.animation, &"idle")

	Input.action_press("move_right")
	await _advance_physics_frames(8)
	Input.action_release("move_right")

	assert_eq(player.call("get_current_state_id"), &"run")
	assert_true(runtime_visual.visible)
	assert_eq(runtime_visual.get_meta("asset_id", ""), "luna_run_runtime_sheet_ai01")
	assert_eq(runtime_visual.sprite_frames.resource_path, LUNA_RUN_RUNTIME_SPRITEFRAMES_PATH)
	assert_eq(runtime_visual.animation, &"run")
	assert_true(runtime_visual.is_playing())

	Input.action_press("jump")
	await _advance_physics_frames(2)
	Input.action_release("jump")
	await _advance_physics_frames(2)

	assert_true(
		player.call("get_current_state_id") == &"jump_rise"
		or player.call("get_current_state_id") == &"jump_fall"
	)
	assert_true(runtime_visual.visible)
	assert_eq(runtime_visual.get_meta("asset_id", ""), "luna_jump_fall_runtime_sheet_ai01")
	assert_eq(runtime_visual.sprite_frames.resource_path, LUNA_JUMP_FALL_RUNTIME_SPRITEFRAMES_PATH)
	assert_eq(runtime_visual.animation, &"jump_fall")
	assert_true(runtime_visual.is_playing())


# 保护 Luna attack body 与独立攻击 VFX 正式替换边界：不改变命中窗口或攻击参数。
func test_stage14_player_runtime_animation_visual_uses_attack_body_candidate() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var runtime_visual := player.get_node_or_null("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var attack_slash_vfx := player.get_node_or_null("AttackSlashVfxVisual") as AnimatedSprite2D
	var attack_seal_arc_vfx := player.get_node_or_null("AttackSealArcVfxVisual") as AnimatedSprite2D
	var legacy_slash := player.get_node_or_null("Stage12SlashPreview") as Sprite2D
	assert_not_null(runtime_visual)
	assert_not_null(attack_slash_vfx)
	assert_not_null(attack_seal_arc_vfx)
	assert_not_null(legacy_slash)
	if runtime_visual == null or attack_slash_vfx == null or attack_seal_arc_vfx == null or legacy_slash == null:
		return

	Input.action_press("attack")
	await _advance_physics_frames(2)
	Input.action_release("attack")

	assert_true(
		player.call("get_current_state_id") == &"attack"
		or player.call("get_current_state_id") == &"air_attack"
	)
	assert_true(runtime_visual.visible)
	assert_eq(runtime_visual.get_meta("asset_id", ""), "luna_attack_body_runtime_sheet_ai02")
	assert_eq(runtime_visual.sprite_frames.resource_path, LUNA_ATTACK_BODY_RUNTIME_SPRITEFRAMES_PATH)
	assert_eq(runtime_visual.animation, &"attack_body")
	assert_true(runtime_visual.is_playing())
	assert_true(attack_slash_vfx.visible)
	assert_eq(attack_slash_vfx.get_meta("asset_id", ""), "luna_attack_slash_vfx_runtime_ai01")
	assert_eq(attack_slash_vfx.sprite_frames.resource_path, LUNA_ATTACK_SLASH_VFX_SPRITEFRAMES_PATH)
	assert_eq(attack_slash_vfx.animation, &"attack_slash")
	assert_true(attack_slash_vfx.is_playing())
	assert_false(attack_slash_vfx.get_meta("gameplay_collision", true))
	assert_false(attack_slash_vfx.get_meta("damage_source", true))
	assert_false(_has_collision_or_area_child(attack_slash_vfx))
	assert_true(attack_seal_arc_vfx.visible)
	assert_eq(attack_seal_arc_vfx.get_meta("asset_id", ""), "luna_attack_seal_arc_vfx_runtime_ai01")
	assert_eq(attack_seal_arc_vfx.sprite_frames.resource_path, LUNA_ATTACK_SEAL_ARC_VFX_SPRITEFRAMES_PATH)
	assert_eq(attack_seal_arc_vfx.animation, &"attack_seal_arc")
	assert_true(attack_seal_arc_vfx.is_playing())
	assert_false(attack_seal_arc_vfx.get_meta("gameplay_collision", true))
	assert_false(attack_seal_arc_vfx.get_meta("damage_source", true))
	assert_false(_has_collision_or_area_child(attack_seal_arc_vfx))
	assert_false(legacy_slash.visible)

	await _advance_physics_frames(24)
	assert_ne(player.call("get_current_state_id"), &"attack")
	assert_false(attack_slash_vfx.visible)
	assert_false(attack_seal_arc_vfx.visible)
	assert_false(legacy_slash.visible)


# 保护 Luna Air Dash 正式替换边界：dash 使用 clean body layer，不接旧的 baked trail 预览 sheet。
func test_stage14_player_runtime_animation_visual_uses_clean_air_dash_body_candidate() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var runtime_visual := player.get_node_or_null("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var air_dash_trail := player.get_node_or_null("AirDashTrailArt") as Sprite2D
	assert_not_null(runtime_visual)
	assert_not_null(air_dash_trail)
	if runtime_visual == null or air_dash_trail == null:
		return

	assert_false(air_dash_trail.visible)
	Input.action_press("dash")
	await _advance_physics_frames(2)
	Input.action_release("dash")

	assert_eq(player.call("get_current_state_id"), &"dash")
	assert_true(runtime_visual.visible)
	assert_eq(runtime_visual.get_meta("asset_id", ""), "luna_air_dash_body_runtime_sheet_ai02")
	assert_eq(runtime_visual.sprite_frames.resource_path, LUNA_AIR_DASH_BODY_RUNTIME_SPRITEFRAMES_PATH)
	assert_eq(runtime_visual.animation, &"air_dash_body")
	assert_true(runtime_visual.is_playing())
	assert_ne(runtime_visual.sprite_frames.resource_path, LUNA_AIR_DASH_SPRITEFRAMES_PATH)
	assert_true(air_dash_trail.visible)
	assert_eq(air_dash_trail.get_meta("asset_id", ""), "stage14_air_dash_trail_ai01")
	assert_not_null(air_dash_trail.texture)
	if air_dash_trail.texture != null:
		assert_eq(air_dash_trail.texture.resource_path, "res://assets/art/vfx/stage14_air_dash_trail_ai01.png")
	assert_false(air_dash_trail.get_meta("gameplay_collision", true))
	assert_false(air_dash_trail.get_meta("damage_source", true))
	assert_lt(air_dash_trail.position.x, 0.0)

	await _advance_physics_frames(24)
	assert_ne(player.call("get_current_state_id"), &"dash")
	assert_false(air_dash_trail.visible)


# 保护 Luna 受击与死亡正式替换边界：运行时只切换视觉层，不改变生命、无敌、击退或 checkpoint 流程。
func test_stage14_player_runtime_animation_visual_uses_hit_and_death_candidates() -> void:
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var runtime_visual := player.get_node_or_null("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	assert_not_null(runtime_visual)
	if runtime_visual == null:
		return

	player.call("receive_damage", 1, Vector2.LEFT)
	await _advance_physics_frames(1)

	assert_true(runtime_visual.visible)
	assert_eq(runtime_visual.get_meta("asset_id", ""), "luna_hit_react_runtime_sheet_ai01")
	assert_eq(runtime_visual.sprite_frames.resource_path, LUNA_HIT_REACT_RUNTIME_SPRITEFRAMES_PATH)
	assert_eq(runtime_visual.animation, &"hit_react")
	assert_true(runtime_visual.is_playing())

	var lethal_player := await _spawn_player_with_floor(Vector2(120.0, 0.0))
	var lethal_visual := lethal_player.get_node_or_null("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	assert_not_null(lethal_visual)
	if lethal_visual == null:
		return

	lethal_player.call("receive_damage", int(lethal_player.call("get_max_health")), Vector2.LEFT)
	await _advance_physics_frames(1)

	assert_true(lethal_visual.visible)
	assert_eq(lethal_visual.get_meta("asset_id", ""), "luna_death_idle_runtime_sheet_ai01")
	assert_eq(lethal_visual.sprite_frames.resource_path, LUNA_DEATH_IDLE_RUNTIME_SPRITEFRAMES_PATH)
	assert_eq(lethal_visual.animation, &"death_idle")
	assert_true(lethal_visual.is_playing())

	lethal_player.call("restore_full_health")
	await _advance_physics_frames(1)

	assert_ne(lethal_visual.get_meta("asset_id", ""), "luna_death_idle_runtime_sheet_ai01")
	assert_ne(lethal_visual.get_meta("asset_id", ""), "luna_hit_react_runtime_sheet_ai01")
	assert_ne(lethal_visual.sprite_frames.resource_path, LUNA_DEATH_IDLE_RUNTIME_SPRITEFRAMES_PATH)
	assert_ne(lethal_visual.sprite_frames.resource_path, LUNA_HIT_REACT_RUNTIME_SPRITEFRAMES_PATH)


# 保护能力获得与回溯收益：神龛授予 Air Dash，hub 能累计 3 个奖励。
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


# 保护 Stage13 到 Stage14 的接入：Stage13 目标房 GoalZone 必须进入 Air Dash 神龛房。
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


# 保护 Stage14 灰盒主线：从 Stage13 终点获得能力、收集奖励并到达回环房。
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


# 保护运行态出生和 HUD 优先级：Stage14 房间出生应落地，HUD 应优先显示空中冲刺状态。
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


# 保护资产规划：Air Dash 图标、神龛、能力门和回溯奖励都必须写入 manifest。
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


# Stage14 灰盒 driver 通过真实 Main 和房间节点推进回溯链路。
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


# 主场景 helper 固定加载生产入口，覆盖 Main 的房间切换、玩家注入和 HUD 绑定。
func _spawn_main_scene() -> Node2D:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)

	var main_scene := packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await _advance_process_frames(2)
	return main_scene


# 单房间 helper 至少等待一帧 ready，让门控、checkpoint 和节点可见性完成初始化。
func _spawn_room(scene_path: String) -> Node2D:
	var packed_scene: PackedScene = load(scene_path) as PackedScene
	assert_not_null(packed_scene, "Missing room scene: %s" % scene_path)

	if packed_scene == null:
		return null

	var room := packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


# 玩家 helper 使用真实 PlayerPlaceholder 和简单地板，专门保护跳跃、落地与空中冲刺状态机。
func _spawn_player_with_floor(spawn_position: Vector2) -> CharacterBody2D:
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


# 空中冲刺测试需要真实离地状态；这里用输入触发跳跃，而不是直接改内部状态。
func _jump_until_airborne(player: CharacterBody2D) -> void:
	Input.action_press("jump")
	await _advance_physics_frames(2)
	Input.action_release("jump")
	for _i in range(20):
		if not player.is_on_floor():
			return
		await _advance_physics_frames(1)

	fail_test("玩家没有在 Stage14 空中冲刺测试中进入离地状态")


# 等待玩家稳定落地，避免刚接触地面的一帧误判空中冲刺已恢复。
func _wait_until_player_is_settled(player: CharacterBody2D, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.is_on_floor() and absf(player.velocity.x) <= 0.1 and absf(player.velocity.y) <= 0.1:
			await _advance_physics_frames(2)
			return
		await _advance_physics_frames(1)

	fail_test("玩家在预期帧数内没有稳定落地")


# 物理帧推进 helper 用于跳跃、空中 dash 和落地恢复。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# process 帧推进 helper 用于等待房间位置触发、HUD 更新和切房。
func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


# 读取当前 Main 房间，集中处理节点路径。
func _get_room(main_scene: Node2D) -> Node2D:
	return main_scene.get_node_or_null("Room") as Node2D


# 读取当前运行时玩家，切房和重生后每次重新获取。
func _get_player(main_scene: Node2D) -> CharacterBody2D:
	return main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


# 读取当前房间路径，用于灰盒 driver 分支判断。
func _get_room_path(main_scene: Node2D) -> String:
	var room := _get_room(main_scene)
	return room.scene_file_path if room != null else ""


# 读取 manifest 文本，测试只锁定关键资产条目是否已规划。
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


# 动画预览断言 helper：只保护隐藏 AnimatedSprite2D 预览资源，不要求它替换玩家控制器动画。
func _assert_animated_sprite_references_asset(parent: Node, node_path: String, asset_id: String, resource_path: String, animation_name: StringName) -> void:
	var sprite := parent.get_node_or_null(NodePath(node_path)) as AnimatedSprite2D
	assert_not_null(sprite, "缺少 AnimatedSprite2D 资产节点：%s" % node_path)
	if sprite == null:
		return

	assert_eq(sprite.get_meta("asset_id", ""), asset_id)
	assert_not_null(sprite.sprite_frames, "AnimatedSprite2D 没有 SpriteFrames：%s" % node_path)
	if sprite.sprite_frames != null:
		assert_eq(sprite.sprite_frames.resource_path, resource_path)
		assert_true(sprite.sprite_frames.has_animation(animation_name))
		assert_gt(sprite.sprite_frames.get_frame_count(animation_name), 0)
	assert_eq(sprite.animation, animation_name)


# VFX 视觉节点不得挂 Area2D 或 CollisionShape2D，避免美术层和玩法判定混用。
func _has_collision_or_area_child(node: Node) -> bool:
	if node == null:
		return true
	for child in node.get_children():
		if child is Area2D or child is CollisionShape2D or child is CollisionPolygon2D:
			return true
		if _has_collision_or_area_child(child):
			return true
	return false


# TileSet 预览断言 helper：Stage14 门房只绑定可见 tile 预览，正式碰撞仍由灰盒门体控制。
func _assert_tileset_preview_references_asset(parent: Node, node_path: String) -> void:
	var layer := parent.get_node_or_null(NodePath(node_path)) as TileMapLayer
	assert_not_null(layer, "缺少 TileMapLayer 资产节点：%s" % node_path)
	if layer == null:
		return

	assert_eq(layer.get_meta("asset_id", ""), "miasma_marsh_tileset_ai01")
	assert_not_null(layer.tile_set, "TileMapLayer 没有 TileSet：%s" % node_path)
	if layer.tile_set != null:
		assert_eq(layer.tile_set.resource_path, MIASMA_TILESET_RESOURCE_PATH)
		assert_gt(layer.tile_set.get_source_count(), 0)
	assert_gt(layer.get_used_cells().size(), 0)
