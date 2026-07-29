extends "res://scripts/combat/base_enemy.gd"

# MiasmaCasterEnemy 是阶段 13 的第 4 类普通敌人。
# 它用“定向腐瘴弹体 + 近身压力范围”区别于近战、冲锋和空中威胁，
# 只发射单发直线弹体，不扩展成复杂弹幕或 Boss 行为。

# 配置资源保存 Stage13 远程压制的可调半径、脉冲节奏和触碰伤害。
const MiasmaCasterEnemyConfig := preload("res://scripts/configs/miasma_caster_enemy_config.gd")
const DEFEAT_FRAMES := preload("res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_miasma_caster_defeat_runtime_sheet_ai02.spriteframes.tres")
const MIASMA_PROJECTILE_SCENE: PackedScene = preload("res://scenes/combat/miasma_projectile.tscn")

# 场景实例通过该字段绑定配置；脚本不会在运行中修改资源。
@export var config: MiasmaCasterEnemyConfig

# 远程压制参数同时驱动压力视觉与单发弹体。
var _touch_damage := 1
var _projectile_range := 184.0
var _projectile_damage := 1
var _projectile_speed := 120.0
var _cast_interval := 1.4
var _miasma_pressure_radius := 56.0
var _pulse_interval := 1.4

# 脉冲与施法使用独立计时器，避免调视觉时改变攻击频率。
var _pulse_elapsed := 0.0
var _cast_elapsed := 0.0
var _projectiles_spawned := 0
var _player: CharacterBody2D


# 初始化时同步远程压制配置，保证直接实例化和场景加载表现一致。
func _ready() -> void:
	# 初始化时同步配置，保证测试直接实例化也能读到场景期望数值。
	super._ready()
	_apply_config()


# 物理帧更新瘴气压力、定向施法与沿用的触碰伤害。
func _physics_process(delta: float) -> void:
	if is_defeated():
		_hide_pressure_visuals()
		return

	_pulse_elapsed = fmod(_pulse_elapsed + delta, _pulse_interval)
	_update_pressure_visual()
	_try_cast_projectile(delta)
	_deal_touch_damage(_touch_damage)


# 房间基类注入当前玩家；Caster 不主动搜索 Main 或场景树。
func bind_player(player: CharacterBody2D) -> void:
	_player = player


# 从配置资源读取 Stage13 当前实际使用的压制参数。
func _apply_config() -> void:
	if config == null:
		return

	_touch_damage = config.touch_damage
	_projectile_range = config.projectile_range
	_projectile_damage = config.projectile_damage
	_projectile_speed = config.projectile_speed
	_cast_interval = config.cast_interval
	_miasma_pressure_radius = config.miasma_pressure_radius
	_pulse_interval = config.pulse_interval


# 公开触碰伤害读值，确认瘴气投射敌仍复用 BaseEnemy 的伤害通道。
func get_touch_damage() -> int:
	# 触碰伤害仍走 BaseEnemy 统一契约，不在瘴气投射敌里另建伤害系统。
	return _touch_damage


# 公开真实弹体的起手与飞行边界。
func get_projectile_range() -> float:
	return _projectile_range


# 公开瘴气压力半径，供 Stage13 遭遇测试区分远程压制敌。
func get_miasma_pressure_radius() -> float:
	# 压制半径用于视觉提示和测试断言，帮助区分它与普通近战敌。
	return _miasma_pressure_radius


func get_cast_interval() -> float:
	return _cast_interval


func get_projectiles_spawned_count() -> int:
	return _projectiles_spawned


# 风雷追击在原击败前斩散场上余弹；其它上下文直接走 BaseEnemy。
func receive_elemental_attack(
	hit_direction: Vector2,
	knockback_force: float,
	attack_context: Dictionary
) -> void:
	if attack_context.get("reaction_id", StringName()) == &"wind_thunder_pierce":
		_disperse_active_projectiles()
	super.receive_elemental_attack(hit_direction, knockback_force, attack_context)


# Caster 不另存弹体列表，直接清理同房间现存的同类弹体即可。
func _disperse_active_projectiles() -> void:
	var projectile_parent := get_parent()
	if projectile_parent == null:
		return
	for child: Node in projectile_parent.get_children():
		if child is MiasmaProjectile and not bool(child.call("is_spent")):
			child.call("receive_attack", Vector2.ZERO, 0.0)


# 玩家进入范围后按固定间隔发射一枚直线弹体；离开范围不会积攒瞬发连射。
func _try_cast_projectile(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	if _player.global_position.distance_to(global_position) > _projectile_range:
		_cast_elapsed = minf(_cast_elapsed, _cast_interval * 0.5)
		return

	_cast_elapsed += delta
	if _cast_elapsed < _cast_interval:
		return
	_cast_elapsed = 0.0

	var projectile := MIASMA_PROJECTILE_SCENE.instantiate() as Area2D
	var projectile_parent := get_parent()
	if projectile == null or projectile_parent == null:
		return

	projectile_parent.add_child(projectile)
	var direction := (_player.global_position - global_position).normalized()
	projectile.global_position = global_position + Vector2(0.0, -18.0) + direction * 22.0
	projectile.call(
		"configure",
		direction,
		_projectile_damage,
		_projectile_range,
		_projectile_speed
	)
	_projectiles_spawned += 1


# 更新压力范围视觉；旧 Polygon 只保留为隐藏调试层，正式读值走腐瘴专用 VFX 子资源。
func _update_pressure_visual() -> void:
	var pressure_visual := get_node_or_null("MiasmaPressureVisual") as Polygon2D
	var pressure_vfx := get_node_or_null("MiasmaPressureVfxVisual") as AnimatedSprite2D

	var t := _pulse_elapsed / maxf(_pulse_interval, 0.01)
	if pressure_visual != null:
		pressure_visual.visible = false
		pressure_visual.color = Color(0.454902, 0.839216, 0.690196, 0.055 + 0.035 * sin(t * TAU))
	if pressure_vfx != null:
		pressure_vfx.visible = true
		pressure_vfx.modulate = Color(1.0, 1.0, 1.0, 0.17 + 0.03 * sin(t * TAU))


# 敌人被击败后清理压制提示，避免房间门控已清除但视觉还残留。
func _hide_pressure_visuals() -> void:
	var pressure_visual := get_node_or_null("MiasmaPressureVisual") as CanvasItem
	var pressure_vfx := get_node_or_null("MiasmaPressureVfxVisual") as AnimatedSprite2D
	if pressure_visual != null:
		pressure_visual.visible = false
	if pressure_vfx != null:
		pressure_vfx.visible = false


# 施法者清除时同步移除压力范围，并播放可见 defeat。
func _play_defeat_animation() -> void:
	_hide_pressure_visuals()
	_play_runtime_animation(
		DEFEAT_FRAMES,
		&"miasma_caster_defeat",
		"enemy_miasma_caster_defeat_runtime_sheet_ai02",
		true
	)
