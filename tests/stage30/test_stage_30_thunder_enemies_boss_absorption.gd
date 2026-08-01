extends GutTest

# Stage30 回归保护雷蚀獠、夔影雷骸、雷吸收捷径和雷兽妖核的最小正式链路。

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player_placeholder.tscn")
const THUNDER_FANG_SCENE := preload("res://scenes/enemies/thunder_fang_enemy.tscn")
const KUI_BOSS_SCENE := preload("res://scenes/enemies/kui_thunder_boss.tscn")
const STORM_ROOM_SCENE := preload("res://scenes/rooms/stage25_thunder_waste_stormfield_room.tscn")
const OUTLOOK_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_outlook_room.tscn"

const ENEMY_BODY_FRAME_PATHS := [
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_thunder_fang_locomotion_runtime_ai01.spriteframes.tres",
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_thunder_fang_attack_runtime_ai01.spriteframes.tres",
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_thunder_fang_reaction_runtime_ai01.spriteframes.tres",
]
const BOSS_BODY_FRAME_PATHS := [
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_kui_boss_phase1_presence_runtime_ai01.spriteframes.tres",
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_kui_boss_phase1_attacks_runtime_ai01.spriteframes.tres",
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_kui_boss_transition_reaction_runtime_ai01.spriteframes.tres",
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_kui_boss_phase2_presence_runtime_ai01.spriteframes.tres",
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_kui_boss_phase2_resolution_runtime_ai01.spriteframes.tres",
]
const VFX_FRAME_PATHS := [
	"res://assets/art/vfx/atlases/stage30_thunder_fang_vfx_runtime_ai01.spriteframes.tres",
	"res://assets/art/vfx/atlases/stage30_kui_boss_combat_vfx_runtime_ai01.spriteframes.tres",
	"res://assets/art/vfx/atlases/stage30_kui_boss_state_vfx_runtime_ai01.spriteframes.tres",
	"res://assets/art/vfx/atlases/stage30_thunder_absorption_reward_vfx_runtime_ai01.spriteframes.tres",
]


class ThunderCapabilityMain:
	extends Node

	var unlocked := false

	func is_thunder_absorption_unlocked() -> bool:
		return unlocked


func after_each() -> void:
	get_tree().paused = false


func test_stage30_body_and_vfx_packs_meet_formal_frame_floor() -> void:
	assert_eq(_count_frames(ENEMY_BODY_FRAME_PATHS), 48)
	assert_eq(_count_frames(BOSS_BODY_FRAME_PATHS), 80)
	assert_eq(_count_frames(VFX_FRAME_PATHS), 64)

	var enemy_vfx := load(VFX_FRAME_PATHS[0]) as SpriteFrames
	for animation_name: StringName in [&"warning", &"attack", &"guard_break", &"stagger"]:
		assert_true(enemy_vfx.has_animation(animation_name))
	var reward_vfx := load(VFX_FRAME_PATHS[3]) as SpriteFrames
	for animation_name: StringName in [&"absorption_unlock", &"thunder_beast_core", &"demon_resonance", &"shortcut_curtain"]:
		assert_true(reward_vfx.has_animation(animation_name))


func test_thunder_fang_variants_keep_two_hit_and_sequence_counters() -> void:
	var ordinary := await _spawn(THUNDER_FANG_SCENE)
	ordinary.call("receive_attack", Vector2.RIGHT, 120.0)
	assert_eq(int((ordinary.call("get_status_snapshot") as Dictionary).get("current_health")), 1)
	assert_false(bool(ordinary.call("is_defeated")))
	ordinary.call("receive_attack", Vector2.RIGHT, 120.0)
	assert_true(bool(ordinary.call("is_defeated")))

	var charged := await _spawn(THUNDER_FANG_SCENE)
	charged.call("_enter_state", &"warning")
	charged.call("receive_elemental_attack", Vector2.RIGHT, 120.0, {
		"element_id": &"thunder",
		"reaction_id": &"wind_thunder_pierce",
	})
	assert_true(bool(charged.call("is_defeated")))

	var scattered := await _spawn(THUNDER_FANG_SCENE)
	var start_x: float = float(scattered.position.x)
	scattered.call("receive_elemental_attack", Vector2.RIGHT, 160.0, {
		"element_id": &"wind",
		"reaction_id": &"thunder_wind_scatter",
	})
	assert_eq(int((scattered.call("get_status_snapshot") as Dictionary).get("current_health")), 1)
	assert_gt(scattered.position.x, start_x)
	assert_eq((scattered.get_node("ThunderFangVfxVisual") as AnimatedSprite2D).animation, &"stagger")


func test_kui_boss_reuses_guard_contract_with_absorption_and_scatter_bonus() -> void:
	var ordinary := await _spawn(KUI_BOSS_SCENE)
	ordinary.call("receive_elemental_attack", Vector2.RIGHT, 120.0, {
		"element_id": &"thunder",
		"reaction_id": StringName(),
		"thunder_absorption_unlocked": false,
	})
	assert_eq(int(ordinary.call("get_current_health")), 11)
	assert_eq(int(ordinary.call("get_current_guard")), 3)

	var absorbed := await _spawn(KUI_BOSS_SCENE)
	absorbed.call("receive_elemental_attack", Vector2.RIGHT, 120.0, {
		"element_id": &"thunder",
		"reaction_id": StringName(),
		"thunder_absorption_unlocked": true,
	})
	assert_eq(int(absorbed.call("get_current_health")), 11)
	assert_eq(int(absorbed.call("get_current_guard")), 2)

	var scattered := await _spawn(KUI_BOSS_SCENE)
	scattered.set("current_guard", 1)
	scattered.call("receive_elemental_attack", Vector2.RIGHT, 120.0, {
		"element_id": &"wind",
		"reaction_id": &"thunder_wind_scatter",
	})
	var snapshot := scattered.call("get_status_snapshot") as Dictionary
	assert_eq(scattered.call("get_boss_state"), &"staggered")
	assert_true(bool(snapshot.get("scatter_stagger_bonus")))
	assert_eq(float(scattered.call("_get_stagger_duration")), 1.2)


func test_absorption_shortcut_and_core_reuse_existing_capability_and_build_paths() -> void:
	var room := await _spawn(STORM_ROOM_SCENE)
	var capability := ThunderCapabilityMain.new()
	add_child_autofree(capability)
	room.call("bind_main", capability)
	assert_false(bool(room.call("is_shortcut_available")))
	capability.unlocked = true
	room.call("bind_main", capability)
	assert_true(bool(room.call("is_shortcut_available")))
	assert_eq(str(room.shortcut_room_path), "res://scenes/rooms/stage25_thunder_waste_fork_room.tscn")
	assert_eq((room.get_node("AbsorptionStormCurtainArt") as AnimatedSprite2D).frame, 2)

	var player := await _spawn(PLAYER_SCENE)
	player.set("_active_attack_reaction_id", &"thunder_wind_scatter")
	var base_force := float(player.call("get_effective_attack_knockback_force"))
	player.call("set_equipped_build_ids", [&"thunder_beast_core"], &"thunder_beast_core")
	assert_eq(float(player.call("get_effective_attack_knockback_force")), base_force * 1.2)


func test_boss_room_awards_absorption_core_and_story_once() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	assert_true(bool(main.call("start_demo_at_room", OUTLOOK_ROOM_PATH, &"stage25_outlook_start")))
	await get_tree().process_frame
	var room := main.get_node("Room") as Node2D
	var boss := room.get_node("KuiThunderBoss")
	assert_false(bool(room.call("is_gate_unlocked")))
	assert_eq(int(room.call("get_remaining_required_enemy_count")), 1)

	for _hit: int in range(int(boss.call("get_max_health"))):
		boss.call("receive_attack", Vector2.RIGHT, 120.0)
	var snapshot := main.call("get_demo_progress_snapshot") as Dictionary
	assert_true(bool(snapshot.get("stage30_boss_defeated")))
	assert_true(bool(snapshot.get("thunder_absorption_unlocked")))
	assert_true(bool(snapshot.get("thunder_beast_core_collected")))
	assert_eq(int(snapshot.get("story_event_count")), 1)
	assert_true(bool(room.call("is_gate_unlocked")))
	assert_eq(int(room.call("get_remaining_required_enemy_count")), 0)
	assert_true((room.get_node("Stage30RewardVfx") as AnimatedSprite2D).visible)

	main.call("mark_stage30_boss_defeated")
	assert_eq(int((main.call("get_demo_progress_snapshot") as Dictionary).get("story_event_count")), 1)


func _count_frames(paths: Array) -> int:
	var total := 0
	for path: String in paths:
		var frames := load(path) as SpriteFrames
		assert_not_null(frames, "SpriteFrames 可加载：%s" % path)
		if frames == null:
			continue
		for animation_name: StringName in frames.get_animation_names():
			total += frames.get_frame_count(animation_name)
	return total


func _spawn(scene: PackedScene) -> Node:
	var instance := scene.instantiate()
	add_child_autofree(instance)
	await get_tree().process_frame
	return instance
