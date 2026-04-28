extends Resource
class_name GroundChargerEnemyConfig

# GroundChargerEnemyConfig 记录地面冲锋敌的巡逻、触发、冲锋和恢复节奏。
# 这些参数直接决定 Stage 9 小区域的接敌压力。

# 巡逻参数用于冲锋前的低压预读，避免敌人从静止状态突然启动。
@export var patrol_distance: float = 24.0
@export var patrol_speed: float = 2.0

# 触碰伤害保持 1，让 Stage9 主要考验读招而不是高额惩罚。
@export var touch_damage: int = 1

# 触发距离、冲锋速度和持续时间共同决定玩家需要反应的窗口。
@export var trigger_distance: float = 96.0
@export var charge_speed: float = 220.0
@export var charge_duration: float = 0.35

# 恢复时间给玩家反击或通过的机会，是冲锋敌可读性的关键参数。
@export var recovery_duration: float = 0.45
