extends "res://scripts/combat/base_enemy.gd"

# MiasmaCasterEnemy 是阶段 13 的第 4 类普通敌人。
# 它用“远程瘴气压制范围”区别于近战、冲锋和空中威胁，
# 当前只建立可读压力契约，不实现复杂弹幕或 Boss 行为。

# 配置资源保存 Stage13 远程压制的可调半径、脉冲节奏和触碰伤害。
const MiasmaCasterEnemyConfig := preload("res://scripts/configs/miasma_caster_enemy_config.gd")
const DEFEAT_FRAMES := preload("res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_miasma_caster_defeat_runtime_sheet_ai02.spriteframes.tres")

# 场景实例通过该字段绑定配置；脚本不会在运行中修改资源。
@export var config: MiasmaCasterEnemyConfig

# 远程压制参数目前只驱动读值和占位视觉，不生成真实弹体。
var _touch_damage := 1
var _projectile_range := 184.0
var _miasma_pressure_radius := 56.0
var _pulse_interval := 1.4

# 脉冲计时器用于驱动危险范围的呼吸透明度。
var _pulse_elapsed := 0.0


# 初始化时同步远程压制配置，保证直接实例化和场景加载表现一致。
func _ready() -> void:
	# 初始化时同步配置，保证测试直接实例化也能读到场景期望数值。
	super._ready()
	_apply_config()


# 物理帧更新瘴气压力视觉并沿用触碰伤害，当前阶段不生成真实弹体。
func _physics_process(delta: float) -> void:
	if is_defeated():
		_hide_pressure_visuals()
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
	_miasma_pressure_radius = config.miasma_pressure_radius
	_pulse_interval = config.pulse_interval


# 公开触碰伤害读值，确认瘴气投射敌仍复用 BaseEnemy 的伤害通道。
func get_touch_damage() -> int:
	# 触碰伤害仍走 BaseEnemy 统一契约，不在瘴气投射敌里另建伤害系统。
	return _touch_damage


# 公开远程压制范围，作为未来弹体系统的边界占位。
func get_projectile_range() -> float:
	# projectile_range 目前是压力读值和未来弹体系统预留边界，不代表已生成弹体。
	return _projectile_range


# 公开瘴气压力半径，供 Stage13 遭遇测试区分远程压制敌。
func get_miasma_pressure_radius() -> float:
	# 压制半径用于视觉提示和测试断言，帮助区分它与普通近战敌。
	return _miasma_pressure_radius


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


# 施法者清除时同步移除压力范围，并播放可见 defeat；真实投射物仍不属于 Stage17。
func _play_defeat_animation() -> void:
	_hide_pressure_visuals()
	_play_runtime_animation(
		DEFEAT_FRAMES,
		&"miasma_caster_defeat",
		"enemy_miasma_caster_defeat_runtime_sheet_ai02",
		true
	)
