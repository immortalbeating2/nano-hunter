extends "res://scripts/combat/base_enemy.gd"

# BasicMeleeEnemy 是最基础的近战压力模板。
# 它只做低强度往返巡逻，把触碰伤害与受击契约继续交给 BaseEnemy。


# 配置资源让 Stage6-8 的基础敌人数值能在不改脚本的情况下稳定回归。
const BasicEnemyConfig := preload("res://scripts/configs/basic_enemy_config.gd")

# 单个敌人实例可以覆盖配置资源，但运行时只读不写。
@export var config: BasicEnemyConfig

# 巡逻与触碰伤害是基础敌人的全部可调行为面。
var _patrol_distance: float = 40.0
var _patrol_speed: float = 2.2
var _touch_damage: int = 1

# 出生点和计时器共同驱动正弦巡逻，避免位置累计误差影响测试。
var _spawn_position := Vector2.ZERO
var _patrol_elapsed := 0.0


# 近战模板的运行态只有两层：读配置，然后按固定正弦巡逻。
func _ready() -> void:
	_apply_config()
	_spawn_position = position


# 每帧按出生点做轻量巡逻，保持基础敌人在房间设计的压力范围内。
func _process(delta: float) -> void:
	if is_defeated():
		return

	# 使用正弦围绕出生点摆动，让敌人永远留在灰盒房间设计的压力区间内。
	_patrol_elapsed += delta
	position.x = _spawn_position.x + sin(_patrol_elapsed * _patrol_speed) * _patrol_distance


# 物理帧转发触碰伤害，依赖玩家无敌时间限制连续受击。
func _physics_process(_delta: float) -> void:
	# 基础敌人没有主动攻击动作，触碰伤害就是当前阶段唯一伤害来源。
	_deal_touch_damage(_touch_damage)


# 配置入口继续限定为“当前阶段真正用到的最小行为参数”。
func _apply_config() -> void:
	if config == null:
		return

	# 模板实例只从只读配置资源同步当前阶段需要的最小参数。
	_patrol_distance = config.patrol_distance
	_patrol_speed = config.patrol_speed
	_touch_damage = config.touch_damage


# 公开巡逻距离读值，供配置同步测试确认实例参数。
func get_patrol_distance() -> float:
	# 测试通过 getter 读取配置同步结果，不直接碰私有字段。
	return _patrol_distance


# 公开巡逻速度读值，保护 Stage8 参数数据化结果。
func get_patrol_speed() -> float:
	# 巡逻速度是 Stage8 配置数据化验证的一部分。
	return _patrol_speed


# 公开触碰伤害读值，确认基础敌人仍走最小生命闭环。
func get_touch_damage() -> int:
	# 触碰伤害读值用于确认敌人仍沿用最小生命 / 受击闭环。
	return _touch_damage
