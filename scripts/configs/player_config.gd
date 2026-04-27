extends Resource
class_name PlayerConfig

# PlayerConfig 是玩家手感和战斗读值的单一调参入口。
# 运行时代码只从这里复制数值，不反向写入，方便阶段回归测试比较配置是否稳定。

@export_group("移动")
@export var max_run_speed: float = 180.0
@export var ground_acceleration: float = 900.0
@export var ground_deceleration: float = 1200.0
@export var air_acceleration: float = 700.0
@export var jump_velocity: float = -340.0
@export_range(0.1, 1.0, 0.05) var jump_cut_ratio: float = 0.25
@export var rise_gravity: float = 950.0
@export var fall_gravity: float = 1350.0
@export var max_fall_speed: float = 520.0
@export var coyote_time_window: float = 0.12
@export var jump_buffer_window: float = 0.12
@export var landing_state_duration: float = 0.08

@export_group("攻击")
# 攻击时长拆成 startup / active / recovery，便于同时调手感和命中窗口。
@export var attack_startup_duration: float = 0.05
@export var attack_active_duration: float = 0.08
@export var attack_recovery_duration: float = 0.10
@export var attack_hitbox_size: Vector2 = Vector2(44.0, 28.0)
@export var attack_hitbox_offset: Vector2 = Vector2(26.0, -4.0)
@export var attack_knockback_force: float = 120.0

@export_group("冲刺")
# dash 参数同时服务能力门控和战斗接敌，因此必须保持可调且易读。
@export var dash_duration: float = 0.24
@export var dash_speed: float = 440.0
@export var dash_cooldown: float = 0.22
@export var dash_body_color: Color = Color(0.901961, 0.956863, 1.0, 1.0)

@export_group("生命")
# 生命与受击反馈仍是原型期最小闭环，不在这里承载正式成长系统。
@export var max_health: int = 3
@export var damage_invulnerability_duration: float = 0.35
@export var damage_knockback_speed: float = 260.0
@export var damage_knockback_lift: float = -150.0
@export var damage_flash_color: Color = Color(1.0, 0.756863, 0.756863, 1.0)
