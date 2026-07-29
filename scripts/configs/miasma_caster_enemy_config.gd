extends Resource
class_name MiasmaCasterEnemyConfig

# MiasmaCasterEnemyConfig 只暴露阶段 13 远程压制与单发弹体需要的最小参数。

# 触碰伤害沿用普通敌人闭环，避免远程敌人提前引入独立伤害经济。
@export var touch_damage := 1

# 弹体只在该距离内起手，并在飞过同样距离后消失。
@export var projectile_range := 184.0

@export var projectile_damage := 1
@export var projectile_speed := 120.0
@export var cast_interval := 1.4

# 压制半径控制占位危险圈大小，用来表达“不要长期贴近”的空间压力。
@export var miasma_pressure_radius := 56.0

# 脉冲间隔只影响压力光环呼吸，真实施法节奏使用 cast_interval。
@export var pulse_interval := 1.4
