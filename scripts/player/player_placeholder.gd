extends CharacterBody2D

# PlayerPlaceholder 是当前原型期唯一的玩家运行时实现。
# 它统一承载移动、跳跃、地面攻击、空中攻击、dash、受击与 HUD 快照读值，
# 但不负责房间推进、敌人管理或正式存档。


signal health_changed(current_health: int, max_health: int)
signal defeated
# Recovery Charge 是 Stage15 的战斗容错资源；信号只通知 HUD 和测试，不扩展成正式经济系统。
signal recovery_charge_changed(charge_ratio: float, ready: bool)
signal recovery_charge_spent(restored_health: int)


const STATE_IDLE: StringName = &"idle"
const STATE_RUN: StringName = &"run"
const STATE_JUMP_RISE: StringName = &"jump_rise"
const STATE_JUMP_FALL: StringName = &"jump_fall"
const STATE_LAND: StringName = &"land"
const STATE_ATTACK: StringName = &"attack"
const STATE_AIR_ATTACK: StringName = &"air_attack"
const STATE_DASH: StringName = &"dash"

const FLOOR_VELOCITY_TOLERANCE := 0.5
# 命中与击败奖励拆开，便于 Stage15 调整 Boss 容错节奏而不触碰攻击判定本身。
const RECOVERY_CHARGE_PER_HIT := 0.35
const RECOVERY_CHARGE_DEFEAT_BONUS := 0.65

const DEFAULT_PLAYER_CONFIG := preload("res://scenes/player/player_placeholder_config.tres")

# PlayerConfig 负责手感调参；运行期只复制字段，不反向修改资源。
@export var player_config: PlayerConfig

# 移动、跳跃、攻击、冲刺与受击参数来自 PlayerConfig，是玩家可玩手感的集中读值区。
var max_run_speed: float = 180.0
var ground_acceleration: float = 900.0
var ground_deceleration: float = 1200.0
var air_acceleration: float = 700.0
var jump_velocity: float = -340.0
var jump_cut_ratio: float = 0.25
var rise_gravity: float = 950.0
var fall_gravity: float = 1350.0
var max_fall_speed: float = 520.0
var coyote_time_window: float = 0.12
var jump_buffer_window: float = 0.12
var landing_state_duration: float = 0.08
var attack_startup_duration: float = 0.05
var attack_active_duration: float = 0.08
var attack_recovery_duration: float = 0.1
var attack_hitbox_size: Vector2 = Vector2(44.0, 28.0)
var attack_hitbox_offset: Vector2 = Vector2(26.0, -4.0)
var attack_knockback_force: float = 120.0
var dash_duration: float = 0.24
var dash_speed: float = 440.0
var dash_cooldown: float = 0.22
var dash_body_color: Color = Color(0.901961, 0.956863, 1.0, 1.0)
var max_health: int = 3
var damage_invulnerability_duration: float = 0.35
var damage_knockback_speed: float = 260.0
var damage_knockback_lift: float = -150.0
var damage_flash_color: Color = Color(1.0, 0.756863, 0.756863, 1.0)

# 当前状态和生命是 HUD、测试和房间逻辑会读取的稳定公开状态。
var current_state: StringName = STATE_IDLE
var current_health: int = 3
var recovery_charge_heal_amount: int = 1

# 场景节点缓存只服务玩家自身表现，不作为外部系统入口。
@onready var _body_polygon: Polygon2D = $Body
@onready var _stage12_slash_visual: Sprite2D = get_node_or_null("Stage12SlashPreview") as Sprite2D

# 运行时计时器与临时状态按动作窗口、能力、受击反馈和恢复充能分组维护。
var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _landing_state_timer := 0.0
var _was_on_floor := false
var _facing_direction := 1.0
var _attack_elapsed := 0.0
var _attack_was_active := false
var _attack_hit_ids: Dictionary = {}
var _dash_elapsed := 0.0
var _dash_cooldown_remaining := 0.0
var _dash_direction := 1.0
var _air_dash_unlocked := false
var _air_dash_available := false
var _current_dash_started_in_air := false
var _body_idle_color := Color(1.0, 1.0, 1.0, 1.0)
var _damage_invulnerability_remaining := 0.0
var _is_defeated := false
var _dash_feedback_active := false
var _recovery_charge_amount := 0.0


# 启动时只把只读配置复制到运行时字段，后续状态更新都基于这些值工作。
func _ready() -> void:
	_apply_player_config()
	current_state = STATE_IDLE
	current_health = max_health
	_was_on_floor = false
	_facing_direction = 1.0
	if _body_polygon != null:
		_body_idle_color = _body_polygon.color


# 配置同步层只负责把 Resource 转成运行时数字，不在这里做玩法判断。
func _apply_player_config() -> void:
	var resolved_config := _get_resolved_player_config()

	# Stage 8 先把玩家关键参数收口到只读 Resource，运行期只复制值，不反向写回配置。
	max_run_speed = resolved_config.max_run_speed
	ground_acceleration = resolved_config.ground_acceleration
	ground_deceleration = resolved_config.ground_deceleration
	air_acceleration = resolved_config.air_acceleration
	jump_velocity = resolved_config.jump_velocity
	jump_cut_ratio = resolved_config.jump_cut_ratio
	rise_gravity = resolved_config.rise_gravity
	fall_gravity = resolved_config.fall_gravity
	max_fall_speed = resolved_config.max_fall_speed
	coyote_time_window = resolved_config.coyote_time_window
	jump_buffer_window = resolved_config.jump_buffer_window
	landing_state_duration = resolved_config.landing_state_duration
	attack_startup_duration = resolved_config.attack_startup_duration
	attack_active_duration = resolved_config.attack_active_duration
	attack_recovery_duration = resolved_config.attack_recovery_duration
	attack_hitbox_size = resolved_config.attack_hitbox_size
	attack_hitbox_offset = resolved_config.attack_hitbox_offset
	attack_knockback_force = resolved_config.attack_knockback_force
	dash_duration = resolved_config.dash_duration
	dash_speed = resolved_config.dash_speed
	dash_cooldown = resolved_config.dash_cooldown
	dash_body_color = resolved_config.dash_body_color
	max_health = resolved_config.max_health
	damage_invulnerability_duration = resolved_config.damage_invulnerability_duration
	damage_knockback_speed = resolved_config.damage_knockback_speed
	damage_knockback_lift = resolved_config.damage_knockback_lift
	damage_flash_color = resolved_config.damage_flash_color


# 返回本轮实际使用的玩家配置；未显式指定时回落到默认资源。
func _get_resolved_player_config() -> PlayerConfig:
	if player_config != null:
		return player_config

	player_config = DEFAULT_PLAYER_CONFIG
	return player_config


# 每帧更新顺序固定为：先处理无敌时间，再采样输入，再做状态专属逻辑，最后统一 move_and_slide。
# 这个顺序保证测试与人工调参时，状态切换来源比较稳定可追。
func _physics_process(delta: float) -> void:
	_update_damage_invulnerability(delta)

	var jump_pressed := Input.is_action_just_pressed("jump")
	var jump_released := Input.is_action_just_released("jump")
	var attack_pressed := Input.is_action_just_pressed("attack")
	var dash_pressed := Input.is_action_just_pressed("dash")
	var recover_pressed := InputMap.has_action("recover") and Input.is_action_just_pressed("recover")
	var was_grounded := is_on_floor()

	_update_jump_window_timers(delta, was_grounded, jump_pressed)
	_update_dash_cooldown(delta)
	if _is_attacking():
		_update_attack_state(delta, was_grounded)
	elif _is_dashing():
		_update_dash_state(delta, was_grounded)
	else:
		_apply_horizontal_movement(delta)
		_apply_vertical_motion(delta, was_grounded)

		if _can_start_dash(was_grounded, dash_pressed):
			_start_dash()
		elif recover_pressed:
			spend_recovery_charge()
		elif _can_start_attack(was_grounded, attack_pressed):
			_start_attack()
		elif _can_start_jump(was_grounded):
			_start_jump()

	if jump_released and velocity.y < 0.0:
		velocity.y *= jump_cut_ratio

	move_and_slide()

	var is_grounded := is_on_floor()
	_update_landing_state(delta, was_grounded, is_grounded)
	_update_current_state(is_grounded)
	_was_on_floor = is_grounded


# 基础移动层：只有在不处于攻击 / dash 等专属状态时才接管水平与垂直速度。
func _update_jump_window_timers(delta: float, was_grounded: bool, jump_pressed: bool) -> void:
	if jump_pressed:
		_jump_buffer_timer = jump_buffer_window
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

	if was_grounded:
		_coyote_timer = coyote_time_window
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)


# 根据左右输入更新水平速度，并在有输入时同步朝向给攻击与 dash 使用。
func _apply_horizontal_movement(delta: float) -> void:
	var input_axis := Input.get_axis("move_left", "move_right")
	var acceleration := air_acceleration

	if absf(input_axis) > 0.01:
		_facing_direction = signf(input_axis)

	if is_on_floor():
		acceleration = ground_acceleration

	if absf(input_axis) > 0.01:
		velocity.x = move_toward(velocity.x, input_axis * max_run_speed, acceleration * delta)
	else:
		var deceleration := ground_deceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)


# 根据上升 / 下落阶段套用不同重力，保持跳跃手感和最大下落速度稳定。
func _apply_vertical_motion(delta: float, was_grounded: bool) -> void:
	if was_grounded and velocity.y > 0.0:
		velocity.y = 0.0
		return

	var gravity := fall_gravity if velocity.y >= 0.0 else rise_gravity
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)


# 判断当前帧是否允许跳跃起手，统一处理跳跃缓冲、土狼时间和动作锁定。
func _can_start_jump(was_grounded: bool) -> bool:
	if _is_attacking() or _is_dashing():
		return false

	if _jump_buffer_timer <= 0.0:
		return false

	return was_grounded or _coyote_timer > 0.0


# 判断普通攻击是否能起手；参数保留地面状态，便于后续分地面 / 空中规则扩展。
func _can_start_attack(was_grounded: bool, attack_pressed: bool) -> bool:
	return attack_pressed and not _is_attacking() and not _is_dashing()


# 判断 dash 是否能起手，区分地面 dash 冷却和 Stage14 空中 dash 一次性消耗。
func _can_start_dash(was_grounded: bool, dash_pressed: bool) -> bool:
	if not dash_pressed:
		return false

	if _is_attacking() or _is_dashing():
		return false

	if was_grounded:
		if _dash_cooldown_remaining > 0.0:
			return false

		return current_state == STATE_IDLE or current_state == STATE_RUN or current_state == STATE_LAND

	return _air_dash_unlocked and _air_dash_available


# 主动动作起手层：jump / attack / dash 都在这里清理与自己冲突的临时状态。
func _start_jump() -> void:
	velocity.y = jump_velocity
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_landing_state_timer = 0.0
	current_state = STATE_JUMP_RISE


# 进入攻击动作窗口，清空上一次命中缓存并启动 Stage12 slash 视觉反馈。
func _start_attack() -> void:
	_attack_elapsed = 0.0
	_attack_was_active = false
	_attack_hit_ids.clear()
	_landing_state_timer = 0.0
	_jump_buffer_timer = 0.0
	current_state = STATE_ATTACK if is_on_floor() else STATE_AIR_ATTACK
	_show_stage12_slash_visual()
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * 0.02)


# 进入 dash 动作窗口，记录方向、消耗空中 dash 并锁定纵向速度。
func _start_dash() -> void:
	var input_axis := Input.get_axis("move_left", "move_right")
	_dash_direction = _facing_direction if absf(input_axis) <= 0.01 else signf(input_axis)
	_facing_direction = _dash_direction
	_dash_elapsed = 0.0001
	_current_dash_started_in_air = not is_on_floor()
	if _current_dash_started_in_air:
		_air_dash_available = false
	_landing_state_timer = 0.0
	_jump_buffer_timer = 0.0
	current_state = STATE_DASH
	velocity.x = dash_speed * _dash_direction
	velocity.y = 0.0
	_set_dash_feedback_active(true)


# 攻击与冲刺的持续期逻辑必须独立更新，避免普通移动逻辑把动作感打散。
func _update_attack_state(delta: float, was_grounded: bool) -> void:
	_apply_attack_movement(delta, was_grounded)

	_attack_elapsed += delta

	if _attack_is_active() and not _attack_was_active:
		_perform_attack_hits()
		_attack_was_active = true

	if _attack_elapsed >= _get_attack_total_duration():
		_finish_attack()


# 攻击期间只保留有限惯性，防止玩家在攻击窗口内获得额外位移优势。
func _apply_attack_movement(delta: float, was_grounded: bool) -> void:
	if was_grounded:
		velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, air_acceleration * delta)

	_apply_vertical_motion(delta, was_grounded)


# dash 持续期间维持水平高速，并在计时结束时回到普通移动层。
func _update_dash_state(delta: float, was_grounded: bool) -> void:
	velocity.x = dash_speed * _dash_direction
	# 阶段 4 的 dash 只允许从地面起手，但持续期内保持平直位移，
	# 这样才能稳定承担“穿过短门槛 / 快速接敌”的最小能力差异价值。
	velocity.y = 0.0

	_dash_elapsed += delta
	if _dash_elapsed >= dash_duration:
		_finish_dash()


# 攻击判定统一走 shape query，并通过 receive_attack 契约把伤害传给敌人或其父节点。
func _perform_attack_hits() -> void:
	var space_state := get_world_2d().direct_space_state
	var hit_shape := RectangleShape2D.new()
	hit_shape.size = attack_hitbox_size

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = hit_shape
	query.transform = Transform2D(0.0, get_attack_hitbox_center())
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [get_rid()]

	for result in space_state.intersect_shape(query):
		var collider: Object = result.get("collider")
		if collider == null:
			continue

		var receiver := _resolve_attack_receiver(collider)
		if receiver == null:
			continue

		var receiver_id := receiver.get_instance_id()
		if _attack_hit_ids.has(receiver_id):
			continue

		_attack_hit_ids[receiver_id] = true
		receiver.call(
			"receive_attack",
			Vector2(_facing_direction, 0.0),
			attack_knockback_force
		)
		# 恢复充能跟随真实命中结算，避免空挥也能获得 Stage15 容错资源。
		var charge_gain := RECOVERY_CHARGE_PER_HIT
		if receiver.has_method("is_defeated") and bool(receiver.call("is_defeated")):
			charge_gain += RECOVERY_CHARGE_DEFEAT_BONUS
		add_recovery_charge(charge_gain)


# 从物理查询命中的对象解析真正能接收攻击的节点，兼容敌人父子节点结构。
func _resolve_attack_receiver(collider: Object) -> Object:
	# 攻击查询可能命中敌人的 StaticBody，也可能命中其子节点；
	# 这里向上找一层 receive_attack，保持场景结构可微调。
	if collider.has_method("receive_attack"):
		return collider

	if collider is Node:
		var parent := (collider as Node).get_parent()
		if parent != null and parent.has_method("receive_attack"):
			return parent

	return null


# 收束攻击窗口，清理命中表与临时视觉，保证下一次攻击重新判定。
func _finish_attack() -> void:
	# 收尾时必须同时清空命中表和视觉预览，否则下一次攻击会漏判或残留 slash 图形。
	_attack_elapsed = 0.0
	_attack_was_active = false
	_attack_hit_ids.clear()
	_hide_stage12_slash_visual()
	current_state = STATE_IDLE


# 结束 dash 并进入冷却，同时关闭 dash 颜色反馈。
func _finish_dash() -> void:
	# dash 结束后立即进入冷却，并把速度往普通地面移动收束，避免能力门控后仍残留高速。
	_dash_elapsed = 0.0
	_dash_cooldown_remaining = dash_cooldown
	velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * 0.02)
	current_state = STATE_IDLE
	_current_dash_started_in_air = false
	_set_dash_feedback_active(false)


# 显示 Stage12 临时攻击视觉，朝向和位置跟随当前攻击判定中心。
func _show_stage12_slash_visual() -> void:
	if _stage12_slash_visual == null:
		return

	# Stage 12 的 slash 只做轻量可读性，不参与攻击判定或伤害结算。
	_stage12_slash_visual.visible = true
	_stage12_slash_visual.position.x = absf(attack_hitbox_offset.x) * _facing_direction + 6.0 * _facing_direction
	_stage12_slash_visual.position.y = attack_hitbox_offset.y
	_stage12_slash_visual.flip_h = _facing_direction < 0.0


# 隐藏 Stage12 临时攻击视觉，避免攻击结束后残留在玩家身上。
func _hide_stage12_slash_visual() -> void:
	if _stage12_slash_visual != null:
		_stage12_slash_visual.visible = false


# 维护落地反馈和空中 dash 恢复；落地是 Stage14 能力循环的恢复节点。
func _update_landing_state(delta: float, was_grounded: bool, is_grounded: bool) -> void:
	if _air_dash_unlocked and is_grounded and not _is_dashing():
		_air_dash_available = true

	# 落地态只是一小段可读反馈；攻击落地不显示 landing，避免覆盖攻击状态。
	if _is_attacking():
		_landing_state_timer = 0.0
		return

	if is_grounded and not was_grounded and _was_on_floor == false and velocity.y >= 0.0:
		_landing_state_timer = landing_state_duration
	elif _landing_state_timer > 0.0:
		_landing_state_timer = maxf(_landing_state_timer - delta, 0.0)


# 根据动作锁定、地面状态和速度刷新公开状态，供 HUD、测试和房间逻辑读取。
func _update_current_state(is_grounded: bool) -> void:
	# 状态优先级从高到低是攻击、dash、地面、空中；
	# 这样 HUD 和测试读到的 current_state 与玩家实际控制锁定一致。
	if _is_attacking():
		if current_state != STATE_AIR_ATTACK:
			current_state = STATE_ATTACK
		return

	if _is_dashing():
		current_state = STATE_DASH
		return

	if is_grounded:
		if _landing_state_timer > 0.0:
			current_state = STATE_LAND
			return

		if absf(velocity.x) > FLOOR_VELOCITY_TOLERANCE:
			current_state = STATE_RUN
			return

		current_state = STATE_IDLE
		return

	if velocity.y < 0.0:
		current_state = STATE_JUMP_RISE
	else:
		current_state = STATE_JUMP_FALL


# 查询玩家是否处在攻击起手、有效帧或收招窗口中。
func _is_attacking() -> bool:
	return _attack_elapsed > 0.0 or current_state == STATE_ATTACK or current_state == STATE_AIR_ATTACK


# 查询玩家是否处在 dash 窗口中，用于阻止动作互相覆盖。
func _is_dashing() -> bool:
	return _dash_elapsed > 0.0 or current_state == STATE_DASH


# 对外读值层：测试、HUD 与房间逻辑都应该优先消费这些稳定接口，而不是直接探测内部字段。
func _update_dash_cooldown(delta: float) -> void:
	_dash_cooldown_remaining = maxf(_dash_cooldown_remaining - delta, 0.0)


# 判断当前攻击计时是否处在有效命中帧。
func _attack_is_active() -> bool:
	var active_start := attack_startup_duration
	var active_end := active_start + attack_active_duration
	return _attack_elapsed >= active_start and _attack_elapsed < active_end


# 计算完整攻击窗口长度，统一起手、有效帧和收招三段配置。
func _get_attack_total_duration() -> float:
	return attack_startup_duration + attack_active_duration + attack_recovery_duration


# 返回当前攻击判定中心；空中攻击会略微上移以覆盖空中威胁。
func get_attack_hitbox_center() -> Vector2:
	# 空中攻击的判定中心略微上移，用来体现 Stage 10 “空中攻击打空中威胁”的价值。
	if current_state == STATE_AIR_ATTACK:
		return global_position + Vector2(
			attack_hitbox_offset.x * _facing_direction,
			attack_hitbox_offset.y - 14.0
		)

	return global_position + Vector2(
		attack_hitbox_offset.x * _facing_direction,
		attack_hitbox_offset.y
	)


# 公开当前状态枚举，供测试和房间脚本避免直接读取可变字段。
func get_current_state_id() -> StringName:
	return current_state


# 公开空中攻击是否仍在动作窗口内，服务 Stage10 空中威胁测试。
func is_air_attack_active_or_recovering() -> bool:
	return current_state == STATE_AIR_ATTACK and _is_attacking()


# 受击层负责统一生命、击退、无敌时间与 defeated 信号，不把这些逻辑分散给房间或敌人。
func receive_damage(amount: int, hit_direction: Vector2 = Vector2.ZERO) -> void:
	if amount <= 0 or _is_defeated or _damage_invulnerability_remaining > 0.0:
		return

	current_health = maxi(current_health - amount, 0)
	_damage_invulnerability_remaining = damage_invulnerability_duration
	_apply_damage_knockback(hit_direction)
	_refresh_body_color()
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		_is_defeated = true
		defeated.emit()


# 恢复满生命并清除 defeated / 无敌残留，用于 checkpoint 和测试重置。
func restore_full_health() -> void:
	current_health = max_health
	_is_defeated = false
	_damage_invulnerability_remaining = 0.0
	_refresh_body_color()
	health_changed.emit(current_health, max_health)


# 公开当前生命值，供敌人、HUD 和 GUT 做稳定读值。
func get_current_health() -> int:
	return current_health


# 公开生命上限，避免外部直接依赖配置资源。
func get_max_health() -> int:
	return max_health


# 查询地面 dash 是否处于可用状态；死亡和 dash 中都视为不可用。
func is_dash_ready() -> bool:
	return _dash_cooldown_remaining <= 0.0 and not _is_dashing() and not _is_defeated


# 注入 Stage14 空中 dash 解锁状态，并在解锁时给当前空中 dash 一次可用机会。
func set_air_dash_unlocked(is_unlocked: bool) -> void:
	_air_dash_unlocked = is_unlocked
	_air_dash_available = is_unlocked


# 公开空中 dash 是否已解锁，用于 Main 快照与能力门控判断。
func is_air_dash_unlocked() -> bool:
	return _air_dash_unlocked


# 查询当前是否还能使用一次空中 dash；落地恢复，起手消耗。
func is_air_dash_available() -> bool:
	return _air_dash_unlocked and _air_dash_available and not _is_dashing() and not _is_defeated


# 增加 Stage15 恢复充能，并在比例或 ready 状态变化时通知 HUD。
func add_recovery_charge(amount: float) -> void:
	# 公开入口供真实命中、测试 fixture 和未来奖励节点增加充能；死亡时不再积累资源。
	if amount <= 0.0 or _is_defeated:
		return

	_recovery_charge_amount = clampf(_recovery_charge_amount + amount, 0.0, 1.0)
	recovery_charge_changed.emit(get_recovery_charge_ratio(), can_spend_recovery_charge())


# 查询恢复充能是否已经满格且玩家仍能行动。
func can_spend_recovery_charge() -> bool:
	# ready 表示资源已满且玩家仍可行动；是否能治疗由 spend_recovery_charge 再判断当前生命。
	return not _is_defeated and _recovery_charge_amount >= 1.0


# 消耗满格恢复充能治疗 1 点生命；满血时不消费，避免误操作损失资源。
func spend_recovery_charge() -> bool:
	# 满血不消费充能，防止玩家误按 recover 丢掉已经积累的容错机会。
	if not can_spend_recovery_charge() or current_health >= max_health:
		return false

	var previous_health := current_health
	current_health = mini(current_health + recovery_charge_heal_amount, max_health)
	_recovery_charge_amount = 0.0
	if current_health != previous_health:
		health_changed.emit(current_health, max_health)
	recovery_charge_changed.emit(get_recovery_charge_ratio(), can_spend_recovery_charge())
	recovery_charge_spent.emit(current_health - previous_health)
	return true


# 返回恢复充能比例，隐藏内部累计单位，便于后续调参不破坏 HUD 契约。
func get_recovery_charge_ratio() -> float:
	# HUD 和 Main 快照只读取比例，避免后续调整命中奖励单位时破坏显示契约。
	return clampf(_recovery_charge_amount, 0.0, 1.0)


# 汇总玩家 HUD 所需状态，作为 UI 层唯一推荐读值入口。
func get_hud_status_snapshot() -> Dictionary:
	# HUD 只消费快照，不直接读取玩家内部字段；这样后续替换玩家实现时可保留显示契约。
	return {
		"current_health": current_health,
		"max_health": max_health,
		"dash_ready": is_dash_ready(),
		"dash_cooldown_remaining": _dash_cooldown_remaining,
		"air_dash_unlocked": _air_dash_unlocked,
		"air_dash_available": is_air_dash_available(),
		"recovery_charge_ratio": get_recovery_charge_ratio(),
		"recovery_charge_ready": can_spend_recovery_charge(),
		"current_state": String(current_state),
		"is_defeated": _is_defeated
	}


# 切换 dash 视觉反馈标记，并交给统一颜色刷新逻辑决定最终颜色。
func _set_dash_feedback_active(is_active: bool) -> void:
	_dash_feedback_active = is_active
	_refresh_body_color()


# 更新受击无敌倒计时；计时结束时恢复身体颜色。
func _update_damage_invulnerability(delta: float) -> void:
	# 无敌计时结束后刷新颜色，确保受击闪烁不会永久盖住 dash 高亮。
	_damage_invulnerability_remaining = maxf(_damage_invulnerability_remaining - delta, 0.0)
	if _damage_invulnerability_remaining <= 0.0:
		_refresh_body_color()


# 根据受击方向施加击退；方向缺失时用玩家朝向反推，保证反馈可读。
func _apply_damage_knockback(hit_direction: Vector2) -> void:
	# 如果敌人没有给出明确方向，就按玩家当前朝向反推击退，保证反馈始终可见。
	var direction := hit_direction.normalized()
	var horizontal_direction := signf(direction.x)

	if absf(horizontal_direction) <= 0.01:
		horizontal_direction = -_facing_direction

	velocity.x = damage_knockback_speed * horizontal_direction
	velocity.y = damage_knockback_lift


# 按当前受击与 dash 反馈优先级刷新玩家占位身体颜色。
func _refresh_body_color() -> void:
	if _body_polygon == null:
		return

	if _damage_invulnerability_remaining > 0.0:
		_body_polygon.color = damage_flash_color
		return

	# 阶段 6 继续沿用最小可读性反馈：优先显示受击无敌，再回落到 dash 高亮。
	_body_polygon.color = dash_body_color if _dash_feedback_active else _body_idle_color
