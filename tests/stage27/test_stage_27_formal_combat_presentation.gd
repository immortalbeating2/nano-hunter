extends GutTest

# Stage27 回归保护 Luna / Seal Guardian 正式动作映射、四类 VFX 与 debug-only 巡检入口。

const PLAYER_SCENE := preload("res://scenes/player/player_placeholder.tscn")
const BOSS_SCENE := preload("res://scenes/enemies/seal_guardian_boss.tscn")
const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const LUNA_FORMAL_FRAMES := preload("res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_formal_combat_body_runtime_sheet_ai01.spriteframes.tres")
const CORE_VFX_FRAMES := preload("res://assets/art/vfx/atlases/stage27_core_combat_vfx_runtime_ai01.spriteframes.tres")
const BOSS_FORMAL_FRAMES := preload("res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_formal_motion_runtime_sheet_ai01.spriteframes.tres")
const BOSS_VFX_FRAMES := preload("res://assets/art/vfx/atlases/stage27_seal_guardian_vfx_runtime_ai01.spriteframes.tres")


func after_each() -> void:
	get_tree().paused = false


func test_luna_formal_library_and_four_vfx_shapes_exist() -> void:
	for animation_name: StringName in [
		&"ward_attack", &"air_attack", &"apex", &"wind_thunder_finisher",
		&"thunder_wind_finisher", &"element_switch", &"stance_switch", &"recover",
	]:
		assert_true(LUNA_FORMAL_FRAMES.has_animation(animation_name), String(animation_name))
	for animation_name: StringName in [
		&"wind_attack", &"thunder_attack", &"wind_thunder_pierce", &"thunder_wind_scatter",
	]:
		assert_true(CORE_VFX_FRAMES.has_animation(animation_name), String(animation_name))


func test_luna_uses_stance_air_and_sequence_specific_clips_without_changing_hitbox_owner() -> void:
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	var body := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var vfx := player.get_node("AttackSlashVfxVisual") as AnimatedSprite2D
	var seal_vfx := player.get_node("AttackSealArcVfxVisual") as AnimatedSprite2D
	player.call("set_wind_seal_unlocked", true)
	player.current_state = &"attack"
	player.set("_attack_elapsed", 0.1)

	player.call("set_current_stance_id", &"ward")
	player.call("_update_runtime_animation_visual")
	assert_eq(body.sprite_frames, LUNA_FORMAL_FRAMES)
	assert_eq(body.animation, &"ward_attack")
	assert_true(seal_vfx.visible)

	player.current_state = &"air_attack"
	player.call("set_current_stance_id", &"swift")
	player.call("_update_runtime_animation_visual")
	assert_eq(body.animation, &"air_attack")
	assert_false(seal_vfx.visible)

	player.set("_active_attack_reaction_id", &"wind_thunder_pierce")
	player.call("_update_runtime_animation_visual")
	assert_eq(body.animation, &"wind_thunder_finisher")
	assert_eq(vfx.sprite_frames, CORE_VFX_FRAMES)
	assert_eq(vfx.animation, &"wind_thunder_pierce")
	assert_false(bool(vfx.get_meta("gameplay_collision")))
	assert_false(bool(vfx.get_meta("damage_source")))

	player.set("_active_attack_reaction_id", &"thunder_wind_scatter")
	player.call("_update_runtime_animation_visual")
	assert_eq(body.animation, &"thunder_wind_finisher")
	assert_eq(vfx.animation, &"thunder_wind_scatter")


func test_seal_guardian_uses_formal_motion_and_state_vfx() -> void:
	var boss := BOSS_SCENE.instantiate() as StaticBody2D
	add_child_autofree(boss)
	await get_tree().process_frame
	var body := boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var vfx := boss.get_node("SealGuardianAttackVfxVisual") as AnimatedSprite2D

	for animation_name: StringName in [
		&"close_pressure", &"air_warning", &"ground_impact", &"air_punish",
		&"recovery", &"guard_break", &"phase_transition", &"hit", &"defeat",
	]:
		assert_true(BOSS_FORMAL_FRAMES.has_animation(animation_name), String(animation_name))
	for animation_name: StringName in [&"warning", &"impact", &"guard_break", &"phase_transition", &"defeat"]:
		assert_true(BOSS_VFX_FRAMES.has_animation(animation_name), String(animation_name))

	boss.call("_enter_state", &"close_pressure")
	assert_eq(body.sprite_frames, BOSS_FORMAL_FRAMES)
	assert_eq(body.animation, &"close_pressure")
	assert_eq(vfx.animation, &"warning")

	boss.call("_enter_state", &"air_punish")
	assert_eq(body.animation, &"air_punish")
	assert_eq(vfx.animation, &"impact")

	boss.call("_enter_state", &"staggered")
	assert_eq(body.animation, &"guard_break")
	assert_eq(vfx.animation, &"guard_break")
	assert_false(bool(vfx.get_meta("damage_source")))

	boss.set("_phase_transition_visual_remaining", 0.4)
	boss.call("_sync_runtime_animation_visual")
	boss.call("_sync_attack_vfx_visual")
	assert_eq(body.animation, &"phase_transition")
	assert_eq(vfx.animation, &"phase_transition")


func test_debug_build_exposes_full_ability_patrol_preset() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	var list := main.get_node("HUD/DemoShell/DetailPanel/MarginContainer/VBoxContainer/LevelSelectScroll/LevelSelectList")
	var labels: Array[String] = []
	for child: Node in list.get_children():
		if child is Button:
			labels.append((child as Button).text)
	assert_true(labels.has("DEBUG 北极星全能力巡检"))
