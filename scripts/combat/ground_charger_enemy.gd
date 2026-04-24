extends "res://scripts/combat/base_enemy.gd"

# GroundChargerEnemy 是阶段 9 的第二类普通敌人。
# 它通过“巡逻 -> 发现玩家 -> 直线冲锋 -> 恢复”这条固定节奏，
# 给线性小区域提供比基础近战更强的进场压力。


const GroundChargerEnemyConfig := preload("res://scripts/configs/ground_charger_enemy_config.gd")

@export var config: GroundChargerEnemyConfig

var _patrol_distance: float = 24.0
var _patrol_speed: float = 2.0
var _touch_damage: int = 1
var _trigger_distance: float = 96.0
var _charge_speed: float = 220.0
var _charge_duration: float = 0.35
var _recovery_duration: float = 0.45

var _player: CharacterBody2D
var _spawn_position := Vector2.ZERO
var _patrol_elapsed := 0.0
var _charge_elapsed := 0.0
var _recovery_remaining := 0.0
var _charge_direction := 1.0
var _charge_active := false


# 冲锋敌人的主循环要么处在冲锋 / 恢复中，要么回到巡逻并等待下一次触发。
func _ready() -> void:
	_apply_config()
	_spawn_position = position


func _physics_process(delta: float) -> void:
	if is_defeated():
		return

	if _charge_active:
		_charge_elapsed += delta
		position.x += _charge_direction * _charge_speed * delta
		if _charge_elapsed >= _charge_duration:
			_charge_active = false
			_recovery_remaining = _recovery_duration
	elif _recovery_remaining > 0.0:
		_recovery_remaining = maxf(_recovery_remaining - delta, 0.0)
	else:
		_patrol_elapsed += delta
		position.x = _spawn_position.x + sin(_patrol_elapsed * _patrol_speed) * _patrol_distance
		if _can_start_charge():
			_start_charge()

	_deal_touch_damage(_touch_damage)


func bind_player(player: CharacterBody2D) -> void:
	_player = player


func is_charge_active() -> bool:
	return _charge_active


func get_trigger_distance() -> float:
	return _trigger_distance


func get_charge_speed() -> float:
	return _charge_speed


func get_touch_damage() -> int:
	return _touch_damage


func _apply_config() -> void:
	if config == null:
		return

	# Stage 9 把第 2 类敌人的关键行为参数继续收口到只读 Resource，
	# 避免回退到脚本级硬编码。
	_patrol_distance = config.patrol_distance
	_patrol_speed = config.patrol_speed
	_touch_damage = config.touch_damage
	_trigger_distance = config.trigger_distance
	_charge_speed = config.charge_speed
	_charge_duration = config.charge_duration
	_recovery_duration = config.recovery_duration


func _can_start_charge() -> bool:
	if _player == null:
		return false

	var offset := _player.global_position - global_position
	if absf(offset.y) > 40.0:
		return false

	return absf(offset.x) <= _trigger_distance


# 冲锋方向只取玩家相对位置的水平符号，不在阶段 9 引入更复杂的预判或转向系统。
func _start_charge() -> void:
	_charge_active = true
	_charge_elapsed = 0.0
	var direction_to_player := signf(_player.global_position.x - global_position.x)
	_charge_direction = direction_to_player if absf(direction_to_player) > 0.01 else 1.0
