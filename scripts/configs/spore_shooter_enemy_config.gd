extends Resource
class_name SporeShooterEnemyConfig

# SporeShooterEnemyConfig 只暴露阶段 13 远程压制需要的最小参数。
# 当前还没有真实弹体系统，因此 projectile_range 先作为压力读值和测试契约。

@export var touch_damage := 1
@export var projectile_range := 184.0
@export var spore_pressure_radius := 56.0
@export var pulse_interval := 1.4
