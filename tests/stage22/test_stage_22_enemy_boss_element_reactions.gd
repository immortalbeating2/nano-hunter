extends GutTest

# Stage22 回归保护 Stage21 攻击上下文和四类既有敌对对象的最小元素反应。

const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const CASTER_SCENE_PATH := "res://scenes/combat/miasma_caster_enemy.tscn"
const CHARGER_SCENE_PATH := "res://scenes/combat/ground_charger_enemy.tscn"
const BOSS_SCENE_PATH := "res://scenes/enemies/seal_guardian_boss.tscn"


class ElementContextTarget:
	extends StaticBody2D

	var ordinary_hits := 0
	var elemental_hits := 0
	var last_context: Dictionary = {}

	func receive_attack(_hit_direction: Vector2, _knockback_force: float) -> void:
		ordinary_hits += 1

	func receive_elemental_attack(
		_hit_direction: Vector2,
		_knockback_force: float,
		attack_context: Dictionary
	) -> void:
		elemental_hits += 1
		last_context = attack_context.duplicate(true)


func after_each() -> void:
	get_tree().paused = false
	if InputMap.has_action("attack"):
		Input.action_release("attack")


func test_player_real_hit_forwards_frozen_stage21_attack_context() -> void:
	var world := Node2D.new()
	add_child_autofree(world)
	var player := _instantiate(PLAYER_SCENE_PATH) as CharacterBody2D
	world.add_child(player)
	player.call("set_wind_seal_unlocked", true)
	player.call("_start_attack")
	player.call("_finish_attack")
	player.call("set_current_element_id", &"thunder")
	player.call("set_current_stance_id", &"ward")
	player.call("_start_attack")

	var target := ElementContextTarget.new()
	var target_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(24.0, 48.0)
	target_shape.shape = rectangle
	target.add_child(target_shape)
	target.global_position = player.call("get_attack_hitbox_center")
	world.add_child(target)
	await get_tree().physics_frame

	player.call("_perform_attack_hits")
	assert_eq(target.elemental_hits, 1)
	assert_eq(target.ordinary_hits, 0)
	assert_eq(target.last_context.get("element_id"), &"thunder")
	assert_eq(target.last_context.get("stance_id"), &"ward")
	assert_eq(target.last_context.get("reaction_id"), &"wind_thunder_pierce")


func test_wind_thunder_caster_counter_disperses_existing_projectiles() -> void:
	var world := Node2D.new()
	add_child_autofree(world)
	var caster := _instantiate(CASTER_SCENE_PATH) as StaticBody2D
	world.add_child(caster)
	var player := CharacterBody2D.new()
	player.position = Vector2(40.0, 0.0)
	world.add_child(player)
	caster.call("bind_player", player)
	caster.call("_try_cast_projectile", float(caster.call("get_cast_interval")))
	var projectile := _find_miasma_projectile(world)
	assert_not_null(projectile)

	assert_true(caster.has_method("receive_elemental_attack"))
	if caster.has_method("receive_elemental_attack"):
		caster.call(
			"receive_elemental_attack",
			Vector2.RIGHT,
			120.0,
			{"element_id": &"thunder", "stance_id": &"swift", "reaction_id": &"wind_thunder_pierce"}
		)
	assert_true(bool(caster.call("is_defeated")))
	assert_true(bool(projectile.call("is_spent")), "追击破法应清除场上余弹")


func test_thunder_wind_charger_break_cancels_charge_and_moves_defeat_feedback() -> void:
	var world := Node2D.new()
	add_child_autofree(world)
	var charger := _instantiate(CHARGER_SCENE_PATH) as StaticBody2D
	world.add_child(charger)
	var player := CharacterBody2D.new()
	player.position = Vector2(40.0, 0.0)
	world.add_child(player)
	charger.call("bind_player", player)
	charger.call("_begin_charge")
	var start_x := charger.position.x

	assert_true(charger.has_method("receive_elemental_attack"))
	if charger.has_method("receive_elemental_attack"):
		charger.call(
			"receive_elemental_attack",
			Vector2.RIGHT,
			140.0,
			{"element_id": &"wind", "stance_id": &"ward", "reaction_id": &"thunder_wind_scatter"}
		)
	assert_true(bool(charger.call("is_defeated")))
	assert_false(bool(charger.call("is_charge_active")))
	assert_gt(charger.position.x, start_x + 24.0)


func test_wind_thunder_breaks_boss_guard_only_during_warning_window() -> void:
	var ordinary_boss := await _spawn_boss_in_warning()
	ordinary_boss.call("receive_attack", Vector2.RIGHT, 120.0)
	assert_eq(int(ordinary_boss.call("get_current_guard")), ordinary_boss.max_guard - 1)
	assert_eq(ordinary_boss.call("get_boss_state"), &"close_pressure")

	var reaction_boss := await _spawn_boss_in_warning()
	assert_true(reaction_boss.has_method("receive_elemental_attack"))
	if reaction_boss.has_method("receive_elemental_attack"):
		reaction_boss.call(
			"receive_elemental_attack",
			Vector2.RIGHT,
			120.0,
			{"element_id": &"thunder", "stance_id": &"swift", "reaction_id": &"wind_thunder_pierce"}
		)
	assert_eq(int(reaction_boss.call("get_current_health")), reaction_boss.max_health - 1)
	assert_eq(int(reaction_boss.call("get_current_guard")), 0)
	assert_eq(reaction_boss.call("get_boss_state"), &"staggered")


func test_thunder_wind_desynchronizes_active_seal_pulse_but_plain_wind_does_not() -> void:
	var hazard := SealPulseHazard.new()
	add_child_autofree(hazard)
	hazard.rest_duration = 0.2
	hazard.warning_duration = 0.2
	hazard.active_duration = 0.2
	hazard.call("_physics_process", 0.41)
	assert_eq(hazard.call("get_phase_id"), &"active")

	assert_true(hazard.has_method("receive_elemental_attack"))
	if hazard.has_method("receive_elemental_attack"):
		hazard.call(
			"receive_elemental_attack",
			Vector2.RIGHT,
			120.0,
			{"element_id": &"wind", "stance_id": &"swift", "reaction_id": StringName()}
		)
	assert_eq(hazard.call("get_phase_id"), &"active", "普通风击不应改变封印节奏")

	if hazard.has_method("receive_elemental_attack"):
		hazard.call(
			"receive_elemental_attack",
			Vector2.RIGHT,
			210.0,
			{"element_id": &"wind", "stance_id": &"ward", "reaction_id": &"thunder_wind_scatter"}
		)
	assert_eq(hazard.call("get_phase_id"), &"rest")
	assert_false(bool(hazard.call("is_damage_active")))


func _spawn_boss_in_warning() -> StaticBody2D:
	var boss := _instantiate(BOSS_SCENE_PATH) as StaticBody2D
	add_child_autofree(boss)
	var player := CharacterBody2D.new()
	player.position = boss.position + Vector2(40.0, 0.0)
	add_child_autofree(player)
	boss.call("bind_player", player)
	boss.call("_physics_process", 0.0)
	assert_eq(boss.call("get_boss_state"), &"close_pressure")
	return boss


func _find_miasma_projectile(parent: Node) -> Area2D:
	for child: Node in parent.get_children():
		if child is MiasmaProjectile:
			return child as Area2D
	return null


func _instantiate(path: String) -> Node:
	var packed := load(path) as PackedScene
	assert_not_null(packed, "场景存在：%s" % path)
	return packed.instantiate() if packed != null else null
