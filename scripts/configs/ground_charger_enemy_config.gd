extends Resource
class_name GroundChargerEnemyConfig

# GroundChargerEnemyConfig 记录地面冲锋敌的巡逻、触发、冲锋和恢复节奏。
# 这些参数直接决定 Stage 9 小区域的接敌压力。

@export var patrol_distance: float = 24.0
@export var patrol_speed: float = 2.0
@export var touch_damage: int = 1
@export var trigger_distance: float = 96.0
@export var charge_speed: float = 220.0
@export var charge_duration: float = 0.35
@export var recovery_duration: float = 0.45
