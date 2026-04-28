extends "res://scripts/combat/base_enemy.gd"

# AerialSentinelEnemy 是阶段 10 的第三类普通敌人。
# 它只验证“悬浮高度 + 空中攻击价值”这组最小战斗变化，
# 不在本阶段扩成完整飞行 AI。


# 配置资源只保存悬浮和伤害参数，保持空中敌人仍是轻量普通敌。
const AerialSentinelEnemyConfig := preload("res://scripts/configs/aerial_sentinel_enemy_config.gd")

# 场景可替换配置资源；运行时不回写配置。
@export var config: AerialSentinelEnemyConfig

# 悬浮参数决定空中威胁的可读性，lane 高度用于测试空中攻击价值。
var _hover_amplitude: float = 18.0
var _hover_speed: float = 2.4
var _touch_damage: int = 1
var _air_attack_lane_height: float = 88.0

# 出生点和计时器让悬浮围绕原点摆动，不改变房间横向布局。
var _spawn_position := Vector2.ZERO
var _hover_elapsed := 0.0


# 运行态保持单一节奏：围绕出生点做悬浮摆动，并持续转发触碰伤害。
func _ready() -> void:
	_apply_config()
	_spawn_position = position


# 物理帧更新悬浮位置并结算触碰伤害，保持空中敌行为简单可测。
func _physics_process(delta: float) -> void:
	if is_defeated():
		return

	# 悬浮只改变 y 轴，让玩家能明确理解它是“空中威胁”，而不是横向追踪敌。
	_hover_elapsed += delta
	position.y = _spawn_position.y + sin(_hover_elapsed * _hover_speed) * _hover_amplitude
	_deal_touch_damage(_touch_damage)


# 从配置资源读取 Stage10 空中敌人的最小行为参数。
func _apply_config() -> void:
	if config == null:
		return

	# Stage 10 第三类普通敌人只暴露空中攻击验证需要的最小配置。
	_hover_amplitude = config.hover_amplitude
	_hover_speed = config.hover_speed
	_touch_damage = config.touch_damage
	_air_attack_lane_height = config.air_attack_lane_height


# 公开悬浮幅度读值，供配置同步和空中威胁边界测试使用。
func get_hover_amplitude() -> float:
	# 悬浮幅度读值用于确认配置同步，也帮助测试判断视觉压力边界。
	return _hover_amplitude


# 公开空中攻击 lane 高度，保护 Stage10 的空中攻击验证目标。
func get_air_attack_lane_height() -> float:
	# 空中攻击 lane 高度用于保护“必须离地处理该敌人”的阶段目标。
	return _air_attack_lane_height


# 公开触碰伤害读值，确认空中敌仍使用统一受击 / 伤害契约。
func get_touch_damage() -> int:
	# 触碰伤害仍由 BaseEnemy 统一处理，getter 只暴露同步后的配置结果。
	return _touch_damage
