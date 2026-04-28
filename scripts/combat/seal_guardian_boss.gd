extends StaticBody2D
class_name SealGuardianBoss

# SealGuardianBoss 是 Stage15 首个精英 Boss 原型的运行时脚本。
# 它只负责单体 Boss 的生命、护印、预警攻击、受击和重置契约；房间推进由外层脚本接线。

# Boss 信号分为生命、护印、阶段、状态和击败事件，供房间、HUD、测试与 MCP 复核读取。
signal health_changed(current_health: int, max_health: int)
signal guard_changed(current_guard: int, max_guard: int)
signal phase_changed(phase_index: int)
signal state_changed(state_id: StringName)
signal attack_started(state_id: StringName)
signal defeated

# 状态名保持少量且语义稳定，避免 HUD 和测试直接依赖复杂内部状态机。
const STATE_IDLE: StringName = &"idle"
const STATE_CLOSE_PRESSURE: StringName = &"close_pressure"
const STATE_GROUND_IMPACT: StringName = &"ground_impact"
const STATE_AIR_PUNISH: StringName = &"air_punish"
const STATE_STAGGERED: StringName = &"staggered"
const STATE_DEFEATED: StringName = &"defeated"

# 导出参数是 Stage15 原型的调参面板：生命、护印、读招时长、伤害窗口和占位颜色。
@export var max_health: int = 8
@export var max_guard: int = 3
@export var touch_damage: int = 1
@export var aggro_distance: float = 180.0
@export var attack_range: float = 72.0
@export var windup_duration: float = 0.45
@export var strike_duration: float = 0.18
@export var recovery_duration: float = 0.55
@export var stagger_duration: float = 0.7
@export var hit_flash_duration: float = 0.12
@export var idle_color: Color = Color(0.72, 0.64, 0.92, 1.0)
@export var windup_color: Color = Color(0.95, 0.72, 0.38, 1.0)
@export var strike_color: Color = Color(1.0, 0.48, 0.38, 1.0)
@export var stagger_color: Color = Color(0.62, 0.82, 1.0, 1.0)
@export var defeated_color: Color = Color(0.36, 0.28, 0.42, 0.45)

# 公开状态由 HUD 和测试读取；真正的胜负推进仍通过 defeated 信号交给 Boss 房。
var current_health: int = 8
var current_guard: int = 3
var current_state: StringName = STATE_IDLE

# 私有运行时状态记录目标玩家、当前阶段、状态计时和最近一次受击参数。
var _player: Node2D
var _phase_index := 1
var _state_elapsed := 0.0
var _hit_flash_remaining := 0.0
var _strike_has_dealt_damage := false
var _last_hit_direction := Vector2.ZERO
var _last_knockback_force := 0.0

# 节点缓存只服务 Boss 自身表现和攻击命中，不作为外部系统的读取入口。
@onready var _body_canvas: CanvasItem = get_node_or_null("Body") as CanvasItem
@onready var _attack_area: Area2D = get_node_or_null("AttackArea") as Area2D
@onready var _collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D


# 场景实例化后统一初始化 Boss 状态，保证测试直接实例化和房间加载一致。
func _ready() -> void:
	# 场景实例化后统一走 reset_boss，保证测试直接实例化和房间加载获得同一份初始状态。
	reset_boss()


# 每个物理帧推进 Boss 状态机；击败后不再处理攻击循环。
func _physics_process(delta: float) -> void:
	if current_state == STATE_DEFEATED:
		return

	_update_hit_flash(delta)
	_update_phase()
	_update_attack_loop(delta)


# 接收 Boss 房注入的玩家引用，用于距离触发、空中惩罚和伤害方向计算。
func bind_player(player: Node2D) -> void:
	# 房间在玩家重生后重新注入引用，Boss 不主动查找 Main 或 Runtime。
	_player = player


# 接收玩家攻击，扣生命和护印，并在护印耗尽时进入短暂硬直。
func receive_attack(hit_direction: Vector2, knockback_force: float) -> void:
	# 玩家攻击沿用普通敌人的 receive_attack 契约，Boss 在这里额外处理护印和击败。
	if current_state == STATE_DEFEATED:
		return

	# Boss 在玩家攻击契约上额外消耗护印，形成可读的短暂硬直节奏。
	_last_hit_direction = hit_direction
	_last_knockback_force = knockback_force
	current_health = maxi(current_health - 1, 0)
	current_guard = maxi(current_guard - 1, 0)
	_hit_flash_remaining = hit_flash_duration
	_refresh_body_color()
	health_changed.emit(current_health, max_health)
	guard_changed.emit(current_guard, max_guard)

	if current_health <= 0:
		_enter_defeated()
	elif current_guard <= 0:
		_enter_state(STATE_STAGGERED)


# 重置 Boss 的生命、护印、阶段和碰撞状态，供失败重试与测试复用。
func reset_boss() -> void:
	# 失败重试和直接测试实例化都复用这套初始化，避免 Boss 房和测试各写一份重置逻辑。
	current_health = max_health
	current_guard = max_guard
	_phase_index = 1
	_state_elapsed = 0.0
	_hit_flash_remaining = 0.0
	_strike_has_dealt_damage = false
	_last_hit_direction = Vector2.ZERO
	_last_knockback_force = 0.0
	if _collision_shape != null:
		_collision_shape.disabled = false
	_enter_state(STATE_IDLE)
	health_changed.emit(current_health, max_health)
	guard_changed.emit(current_guard, max_guard)
	phase_changed.emit(_phase_index)


# 公开 Boss 是否已击败，房间胜利流程只依赖该稳定读值。
func is_defeated() -> bool:
	# 房间只通过这个读值判断是否已经完成，不直接比较 current_state 字符串。
	return current_state == STATE_DEFEATED


# 公开当前生命值，供 Boss HUD、测试和 MCP 复核读取。
func get_current_health() -> int:
	# 当前生命用于 Boss HUD、测试断言和运行态复核。
	return current_health


# 公开生命上限，避免外部硬编码 Boss 默认生命。
func get_max_health() -> int:
	# 最大生命用于 HUD 比例和测试循环，不让外部硬编码默认值。
	return max_health


# 公开当前护印值，表达进入硬直前还需要多少次命中。
func get_current_guard() -> int:
	# 护印表示进入短暂硬直前还需要多少次命中，是 Stage15 的轻量读招反馈。
	return current_guard


# 公开护印上限，供 HUD 或测试计算护印比例。
func get_max_guard() -> int:
	# 最大护印供 HUD 或调试面板计算护印比例，当前阶段不扩展为正式架势系统。
	return max_guard


# 公开当前阶段编号；Stage15 只用它表示半血后的轻量升温。
func get_phase_index() -> int:
	# 阶段编号只表达半血后轻量升温，不代表正式多阶段 Boss 框架。
	return _phase_index


# 兼容旧测试和调试入口，返回当前 Boss 状态名。
func get_current_state_id() -> StringName:
	# 旧测试和调试入口保留该别名，避免外部直接读 current_state 字段。
	return current_state


# Public Interface 指定的状态读取入口，HUD 和 MCP 复核优先使用。
func get_boss_state() -> StringName:
	# Public Interface 指定的 Boss 状态入口，HUD 和 MCP 复核优先使用它。
	return current_state


# 公开最近一次命中方向，用于验证攻击契约参数没有丢失。
func get_last_hit_direction() -> Vector2:
	# 最近命中方向用于验证 receive_attack 参数没有在 Boss 内部丢失。
	return _last_hit_direction


# 公开最近一次击退力，保留给测试确认 receive_attack 参数传递。
func get_last_knockback_force() -> float:
	# 最近击退力同样作为攻击契约的可测试读值，不直接参与当前 Boss 位移。
	return _last_knockback_force


# 汇总 Boss 状态快照，方便未来 HUD 或调试面板一次读取。
func get_status_snapshot() -> Dictionary:
	# 快照供未来调试面板或 HUD 使用，当前测试仍优先覆盖稳定的单项 public interface。
	return {
		"current_health": current_health,
		"max_health": max_health,
		"current_guard": current_guard,
		"max_guard": max_guard,
		"phase_index": _phase_index,
		"current_state": String(current_state),
		"is_defeated": is_defeated()
	}


# 推进 Boss 的简化线性状态机：预警、出招、硬直、待机。
func _update_attack_loop(delta: float) -> void:
	# 状态机保持线性节奏：接近预警、出招、短暂硬直、回到待机。
	match current_state:
		STATE_IDLE:
			if _can_start_attack():
				_enter_state(STATE_CLOSE_PRESSURE)
		STATE_CLOSE_PRESSURE:
			_state_elapsed += delta
			if _state_elapsed >= windup_duration:
				_enter_state(_choose_strike_state())
		STATE_GROUND_IMPACT, STATE_AIR_PUNISH:
			_state_elapsed += delta
			if not _strike_has_dealt_damage:
				_strike_has_dealt_damage = true
				_deal_strike_damage()
			if _state_elapsed >= strike_duration:
				_enter_state(STATE_STAGGERED)
		STATE_STAGGERED:
			_state_elapsed += delta
			if _state_elapsed >= _get_phase_adjusted_recovery_duration():
				current_guard = max_guard
				guard_changed.emit(current_guard, max_guard)
				_enter_state(STATE_IDLE)


# 判断玩家是否进入压迫距离，控制 Boss 是否从待机进入预警。
func _can_start_attack() -> bool:
	# 只有玩家进入压迫距离后才开始预警，避免 Boss 房出生后无提示立刻出招。
	if _player == null:
		return false

	return global_position.distance_to(_player.global_position) <= aggro_distance


# 在出招有效帧结算一次伤害，避免同一次攻击窗口重复扣血。
func _deal_strike_damage() -> void:
	# 出招阶段只结算一次伤害，具体玩家实现通过 receive_damage 契约解耦。
	var receiver := _find_damage_receiver()
	if receiver == null:
		return

	var receiver_node := receiver as Node2D
	var hit_direction := Vector2.ZERO
	if receiver_node != null:
		hit_direction = receiver_node.global_position - global_position
	receiver.call("receive_damage", touch_damage, hit_direction)


# 根据玩家高度选择地面冲击或空中惩罚，回应 Air Dash 进入战斗后的风险。
func _choose_strike_state() -> StringName:
	# 玩家位于 Boss 上方时切换为空中惩罚，回应 Stage14 Air Dash 进入战斗后的风险。
	if _player != null and _player.global_position.y < global_position.y - 24.0:
		return STATE_AIR_PUNISH

	return STATE_GROUND_IMPACT


# 寻找本次出招应命中的玩家 damage 接收者，优先使用 AttackArea 重叠结果。
func _find_damage_receiver() -> Node:
	# 优先用 AttackArea 的重叠结果；缺少攻击区域时退回距离判定，保持灰盒可测。
	if _attack_area != null:
		for body in _attack_area.get_overlapping_bodies():
			var receiver := _resolve_damage_receiver(body)
			if receiver != null:
				return receiver

	if _player != null and global_position.distance_to(_player.global_position) <= attack_range:
		return _resolve_damage_receiver(_player)

	return null


# 将玩家本体或碰撞子节点统一解析为 receive_damage 持有者。
func _resolve_damage_receiver(candidate: Object) -> Node:
	# 碰撞可能命中玩家本体或子节点，向父节点兜底以保留场景结构可调空间。
	if candidate == null:
		return null

	if candidate.has_method("receive_damage"):
		return candidate as Node

	if candidate is Node:
		var parent := (candidate as Node).get_parent()
		if parent != null and parent.has_method("receive_damage"):
			return parent

	return null


# 生命进入半血线后切到轻量二阶段，只提高节奏不新增招式系统。
func _update_phase() -> void:
	# 半血后只缩短收招制造升温，不在 Stage15 引入正式多阶段 Boss 系统。
	if _phase_index >= 2:
		return

	if current_health > maxi(max_health / 2, 1):
		return

	_phase_index = 2
	phase_changed.emit(_phase_index)


# 按当前阶段返回恢复时长，二阶段略短以制造后半段压迫。
func _get_phase_adjusted_recovery_duration() -> float:
	# 二阶段缩短恢复时长，让同一套招式自然提高压迫感。
	return recovery_duration * 0.75 if _phase_index >= 2 else recovery_duration


# 统一切换 Boss 状态，并清理计时和单次出招伤害标记。
func _enter_state(next_state: StringName) -> void:
	# 所有状态切换统一清理计时和单次伤害标记，避免分支重复维护边界条件。
	if current_state == next_state:
		return

	current_state = next_state
	_state_elapsed = 0.0
	_strike_has_dealt_damage = false
	if next_state == STATE_CLOSE_PRESSURE:
		attack_started.emit(next_state)
	state_changed.emit(current_state)
	_refresh_body_color()


# 进入击败状态，关闭碰撞并广播 defeated，由 Boss 房决定后续流程。
func _enter_defeated() -> void:
	# 击败后关闭碰撞并广播 defeated；Boss 自身不直接切房，由房间决定胜利流程。
	current_health = 0
	current_guard = 0
	current_state = STATE_DEFEATED
	_state_elapsed = 0.0
	_strike_has_dealt_damage = false
	if _collision_shape != null:
		_collision_shape.disabled = true
	health_changed.emit(current_health, max_health)
	guard_changed.emit(current_guard, max_guard)
	state_changed.emit(current_state)
	_refresh_body_color()
	defeated.emit()


# 更新命中闪色计时，到期后恢复当前状态对应的颜色。
func _update_hit_flash(delta: float) -> void:
	# 命中闪色是最小受击反馈，结束后交回当前状态颜色。
	if _hit_flash_remaining <= 0.0:
		return

	_hit_flash_remaining = maxf(_hit_flash_remaining - delta, 0.0)
	if _hit_flash_remaining <= 0.0:
		_refresh_body_color()


# 按当前 Boss 状态刷新占位颜色，让预警、出招、硬直和击败都能被看见。
func _refresh_body_color() -> void:
	# 颜色直接表达当前读招状态，保证占位阶段也能看出预警、出招、硬直和击败。
	if _body_canvas == null:
		return

	if _hit_flash_remaining > 0.0:
		_body_canvas.set("color", Color(1.0, 0.92, 0.72, 1.0))
		return

	match current_state:
		STATE_CLOSE_PRESSURE:
			_body_canvas.set("color", windup_color)
		STATE_GROUND_IMPACT, STATE_AIR_PUNISH:
			_body_canvas.set("color", strike_color)
		STATE_STAGGERED:
			_body_canvas.set("color", stagger_color)
		STATE_DEFEATED:
			_body_canvas.set("color", defeated_color)
		_:
			_body_canvas.set("color", idle_color)
