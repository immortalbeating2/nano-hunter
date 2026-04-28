extends Resource
class_name SporeShooterEnemyConfig

# SporeShooterEnemyConfig 只暴露阶段 13 远程压制需要的最小参数。
# 当前还没有真实弹体系统，因此 projectile_range 先作为压力读值和测试契约。

# 触碰伤害沿用普通敌人闭环，避免远程敌人提前引入独立伤害经济。
@export var touch_damage := 1

# projectile_range 是未来弹体系统边界，现在只给测试和设计读值使用。
@export var projectile_range := 184.0

# 压制半径控制占位危险圈大小，用来表达“不要长期贴近”的空间压力。
@export var spore_pressure_radius := 56.0

# 脉冲间隔只影响占位视觉呼吸，不影响真实伤害频率。
@export var pulse_interval := 1.4
