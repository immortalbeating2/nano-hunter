extends "res://scripts/combat/base_enemy.gd"

# SporeShooterEnemy 是阶段 13 的第 4 类普通敌人。
# 它用“远程孢子压制范围”区别于近战、冲锋和空中威胁，
# 当前只建立可读压力契约，不实现复杂弹幕或 Boss 行为。

# 配置资源保存 Stage13 远程压制的可调半径、脉冲节奏和触碰伤害。
const SporeShooterEnemyConfig := preload("res://scripts/configs/spore_shooter_enemy_config.gd")

# 场景实例通过该字段绑定配置；脚本不会在运行中修改资源。
@export var config: SporeShooterEnemyConfig

# 远程压制参数目前只驱动读值和占位视觉，不生成真实弹体。
var _touch_damage := 1
var _projectile_range := 184.0
var _spore_pressure_radius := 56.0
var _pulse_interval := 1.4

# 脉冲计时器用于驱动危险范围的呼吸透明度。
var _pulse_elapsed := 0.0


# 初始化时同步远程压制配置，保证直接实例化和场景加载表现一致。
func _ready() -> void:
	# 初始化时同步配置，保证测试直接实例化也能读到场景期望数值。
	_apply_config()


# 物理帧更新孢子压力视觉并沿用触碰伤害，当前阶段不生成真实弹体。
func _physics_process(delta: float) -> void:
	if is_defeated():
		return

	# 当前阶段先用脉冲视觉表达远程压制范围，不生成真实弹体，避免把普通敌人扩成弹幕系统。
	_pulse_elapsed = fmod(_pulse_elapsed + delta, _pulse_interval)
	_update_pressure_visual()
	_deal_touch_damage(_touch_damage)


# 从配置资源读取 Stage13 当前实际使用的压制参数。
func _apply_config() -> void:
	if config == null:
		return

	_touch_damage = config.touch_damage
	_projectile_range = config.projectile_range
	_spore_pressure_radius = config.spore_pressure_radius
	_pulse_interval = config.pulse_interval


# 公开触碰伤害读值，确认孢子敌仍复用 BaseEnemy 的伤害通道。
func get_touch_damage() -> int:
	# 触碰伤害仍走 BaseEnemy 统一契约，不在孢子敌里另建伤害系统。
	return _touch_damage


# 公开远程压制范围，作为未来弹体系统的边界占位。
func get_projectile_range() -> float:
	# projectile_range 目前是压力读值和未来弹体系统预留边界，不代表已生成弹体。
	return _projectile_range


# 公开孢子压力半径，供 Stage13 遭遇测试区分远程压制敌。
func get_spore_pressure_radius() -> float:
	# 压制半径用于视觉提示和测试断言，帮助区分它与普通近战敌。
	return _spore_pressure_radius


# 更新占位压力范围视觉；缺少节点时允许静默跳过，避免旧场景加载失败。
func _update_pressure_visual() -> void:
	var pressure_visual := get_node_or_null("SporePressureVisual") as Polygon2D
	if pressure_visual == null:
		return

	# alpha 轻微呼吸即可提示危险半径；实际伤害仍走 BaseEnemy 的触碰伤害契约。
	var t := _pulse_elapsed / maxf(_pulse_interval, 0.01)
	pressure_visual.color = Color(0.619608, 0.858824, 0.321569, 0.22 + 0.18 * sin(t * TAU))
