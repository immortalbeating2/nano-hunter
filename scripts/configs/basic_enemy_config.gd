extends Resource
class_name BasicEnemyConfig

# BasicEnemyConfig 是基础近战敌的最小配置资源，只覆盖巡逻和触碰伤害。

@export var patrol_distance: float = 40.0
@export var patrol_speed: float = 2.2
@export var touch_damage: int = 1
