extends "res://scripts/combat/base_enemy.gd"


const AerialSentinelEnemyConfig := preload("res://scripts/configs/aerial_sentinel_enemy_config.gd")

@export var config: AerialSentinelEnemyConfig

var _hover_amplitude: float = 18.0
var _hover_speed: float = 2.4
var _touch_damage: int = 1
var _air_attack_lane_height: float = 88.0

var _spawn_position := Vector2.ZERO
var _hover_elapsed := 0.0


func _ready() -> void:
	_apply_config()
	_spawn_position = position


func _physics_process(delta: float) -> void:
	if is_defeated():
		return

	_hover_elapsed += delta
	position.y = _spawn_position.y + sin(_hover_elapsed * _hover_speed) * _hover_amplitude
	_deal_touch_damage(_touch_damage)


func _apply_config() -> void:
	if config == null:
		return

	# Stage 10 第三类普通敌人只暴露空中攻击验证需要的最小配置。
	_hover_amplitude = config.hover_amplitude
	_hover_speed = config.hover_speed
	_touch_damage = config.touch_damage
	_air_attack_lane_height = config.air_attack_lane_height


func get_hover_amplitude() -> float:
	return _hover_amplitude


func get_air_attack_lane_height() -> float:
	return _air_attack_lane_height


func get_touch_damage() -> int:
	return _touch_damage
