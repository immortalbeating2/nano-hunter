extends Resource
class_name AerialSentinelEnemyConfig

# AerialSentinelEnemyConfig 只暴露 Stage 10 空中威胁验证所需的悬浮和伤害参数。

# 悬浮参数决定敌人的可读运动，不负责追踪或弹幕行为。
@export var hover_amplitude: float = 18.0
@export var hover_speed: float = 2.4

# 触碰伤害仍保持轻量，避免空中教学房过早变成高惩罚遭遇。
@export var touch_damage: int = 1

# 空中攻击 lane 高度用于测试玩家是否必须进入空中攻击窗口。
@export var air_attack_lane_height: float = 88.0
