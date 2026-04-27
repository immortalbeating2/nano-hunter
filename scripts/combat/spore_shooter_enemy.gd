extends "res://scripts/combat/base_enemy.gd"

# SporeShooterEnemy 是阶段 13 的第 4 类普通敌人。
# 它用“远程孢子压制范围”区别于近战、冲锋和空中威胁，
# 当前只建立可读压力契约，不实现复杂弹幕或 Boss 行为。

const SporeShooterEnemyConfig := preload("res://scripts/configs/spore_shooter_enemy_config.gd")

@export var config: SporeShooterEnemyConfig

var _touch_damage := 1
var _projectile_range := 184.0
var _spore_pressure_radius := 56.0
var _pulse_interval := 1.4
var _pulse_elapsed := 0.0


func _ready() -> void:
	_apply_config()


func _physics_process(delta: float) -> void:
	if is_defeated():
		return

	# 当前阶段先用脉冲视觉表达远程压制范围，不生成真实弹体，避免把普通敌人扩成弹幕系统。
	_pulse_elapsed = fmod(_pulse_elapsed + delta, _pulse_interval)
	_update_pressure_visual()
	_deal_touch_damage(_touch_damage)


func _apply_config() -> void:
	if config == null:
		return

	_touch_damage = config.touch_damage
	_projectile_range = config.projectile_range
	_spore_pressure_radius = config.spore_pressure_radius
	_pulse_interval = config.pulse_interval


func get_touch_damage() -> int:
	return _touch_damage


func get_projectile_range() -> float:
	return _projectile_range


func get_spore_pressure_radius() -> float:
	return _spore_pressure_radius


func _update_pressure_visual() -> void:
	var pressure_visual := get_node_or_null("SporePressureVisual") as Polygon2D
	if pressure_visual == null:
		return

	# alpha 轻微呼吸即可提示危险半径；实际伤害仍走 BaseEnemy 的触碰伤害契约。
	var t := _pulse_elapsed / maxf(_pulse_interval, 0.01)
	pressure_visual.color = Color(0.619608, 0.858824, 0.321569, 0.22 + 0.18 * sin(t * TAU))
