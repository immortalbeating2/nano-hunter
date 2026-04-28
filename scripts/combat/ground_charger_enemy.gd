extends "res://scripts/combat/base_enemy.gd"

# GroundChargerEnemy 是阶段 9 的第二类普通敌人。
# 它通过“巡逻 -> 发现玩家 -> 直线冲锋 -> 恢复”这条固定节奏，
# 给线性小区域提供比基础近战更强的进场压力。


# 配置资源集中记录冲锋敌的巡逻、触发、冲刺和恢复数值。
const GroundChargerEnemyConfig := preload("res://scripts/configs/ground_charger_enemy_config.gd")

# 场景实例通过该字段选择调参资源；脚本运行中只读取一次。
@export var config: GroundChargerEnemyConfig

# 行为参数分成巡逻、伤害、触发、冲锋和恢复五组，便于 Stage9 调节接敌压力。
var _patrol_distance: float = 24.0
var _patrol_speed: float = 2.0
var _touch_damage: int = 1
var _trigger_distance: float = 96.0
var _charge_speed: float = 220.0
var _charge_duration: float = 0.35
var _recovery_duration: float = 0.45

# 运行时状态保存玩家引用、出生点、各段计时和当前冲锋方向。
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


# 物理帧推进巡逻、冲锋和恢复三段节奏，并统一结算触碰伤害。
func _physics_process(delta: float) -> void:
	if is_defeated():
		return

	if _charge_active:
		# 冲锋期不重新追踪玩家，保留“看准时机躲开”的可学习性。
		_charge_elapsed += delta
		position.x += _charge_direction * _charge_speed * delta
		if _charge_elapsed >= _charge_duration:
			_charge_active = false
			_recovery_remaining = _recovery_duration
	elif _recovery_remaining > 0.0:
		_recovery_remaining = maxf(_recovery_remaining - delta, 0.0)
	else:
		# 巡逻段围绕出生点轻微摆动，既能表现活物，也不改变房间布局读值。
		_patrol_elapsed += delta
		position.x = _spawn_position.x + sin(_patrol_elapsed * _patrol_speed) * _patrol_distance
		if _can_start_charge():
			_start_charge()

	_deal_touch_damage(_touch_damage)


# 接收房间注入的玩家引用，供冲锋触发和方向判定使用。
func bind_player(player: CharacterBody2D) -> void:
	# 房间或 Main 在玩家生成后注入引用，敌人本身不主动查找全局玩家。
	_player = player


# 公开当前是否正在冲锋，供测试和调试确认行为窗口。
func is_charge_active() -> bool:
	# HUD 和测试用该读值确认当前是否处于不可转向的冲锋窗口。
	return _charge_active


# 公开触发距离，保护 Stage9 冲锋敌配置同步。
func get_trigger_distance() -> float:
	# 触发距离是 Stage9 自动化验证的核心调参结果。
	return _trigger_distance


# 公开冲锋速度，供遭遇节奏测试读取。
func get_charge_speed() -> float:
	# 冲锋速度读值用于确认配置资源已正确同步到运行时实例。
	return _charge_speed


# 公开触碰伤害读值，确认冲锋敌没有绕开 BaseEnemy 伤害契约。
func get_touch_damage() -> int:
	# 触碰伤害保持最小闭环，不在冲锋敌中扩展独立攻击系统。
	return _touch_damage


# 从配置资源同步当前原型所需的全部冲锋参数。
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


# 判断玩家是否进入同高度、近距离的冲锋触发带。
func _can_start_charge() -> bool:
	if _player == null:
		return false

	var offset := _player.global_position - global_position
	# 只在同一高度带触发，避免玩家在上层平台时被地面敌人无意义追击。
	if absf(offset.y) > 40.0:
		return false

	return absf(offset.x) <= _trigger_distance


# 冲锋方向只取玩家相对位置的水平符号，不在阶段 9 引入更复杂的预判或转向系统。
func _start_charge() -> void:
	_charge_active = true
	_charge_elapsed = 0.0
	var direction_to_player := signf(_player.global_position.x - global_position.x)
	_charge_direction = direction_to_player if absf(direction_to_player) > 0.01 else 1.0
