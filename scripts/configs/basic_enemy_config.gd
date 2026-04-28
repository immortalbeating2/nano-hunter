extends Resource
class_name BasicEnemyConfig

# BasicEnemyConfig 是基础近战敌的最小配置资源，只覆盖巡逻和触碰伤害。

# 巡逻半径和速度直接影响 Stage6-8 的低压战斗节奏。
@export var patrol_distance: float = 40.0
@export var patrol_speed: float = 2.2

# 触碰伤害保持为 1，用于验证玩家受击、无敌帧和失败重试闭环。
@export var touch_damage: int = 1
