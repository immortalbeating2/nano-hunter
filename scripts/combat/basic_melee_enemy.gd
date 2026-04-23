extends "res://scripts/combat/base_enemy.gd"


const BasicEnemyConfig := preload("res://scripts/configs/basic_enemy_config.gd")

@export var config: BasicEnemyConfig

var _patrol_distance: float = 40.0
var _patrol_speed: float = 2.2
var _touch_damage: int = 1

var _spawn_position := Vector2.ZERO
var _patrol_elapsed := 0.0


func _ready() -> void:
	_apply_config()
	_spawn_position = position


func _process(delta: float) -> void:
	if is_defeated():
		return

	_patrol_elapsed += delta
	position.x = _spawn_position.x + sin(_patrol_elapsed * _patrol_speed) * _patrol_distance


func _physics_process(_delta: float) -> void:
	_deal_touch_damage(_touch_damage)


func _apply_config() -> void:
	if config == null:
		return

	# 模板实例只从只读配置资源同步当前阶段需要的最小参数。
	_patrol_distance = config.patrol_distance
	_patrol_speed = config.patrol_speed
	_touch_damage = config.touch_damage


func get_patrol_distance() -> float:
	return _patrol_distance


func get_patrol_speed() -> float:
	return _patrol_speed


func get_touch_damage() -> int:
	return _touch_damage
