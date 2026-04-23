extends CharacterBody2D


signal health_changed(current_health: int, max_health: int)
signal defeated


const STATE_IDLE: StringName = &"idle"
const STATE_RUN: StringName = &"run"
const STATE_JUMP_RISE: StringName = &"jump_rise"
const STATE_JUMP_FALL: StringName = &"jump_fall"
const STATE_LAND: StringName = &"land"
const STATE_ATTACK: StringName = &"attack"
const STATE_DASH: StringName = &"dash"

const FLOOR_VELOCITY_TOLERANCE := 0.5

const DEFAULT_PLAYER_CONFIG := preload("res://scenes/player/player_placeholder_config.tres")

@export var player_config: PlayerConfig

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

var current_state: StringName = STATE_IDLE
var current_health: int = 3

@onready var _body_polygon: Polygon2D = $Body

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
var _body_idle_color := Color(1.0, 1.0, 1.0, 1.0)
var _damage_invulnerability_remaining := 0.0
var _is_defeated := false
var _dash_feedback_active := false


func _ready() -> void:
	_apply_player_config()
	current_state = STATE_IDLE
	current_health = max_health
	_was_on_floor = false
	_facing_direction = 1.0
	if _body_polygon != null:
		_body_idle_color = _body_polygon.color


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


func _get_resolved_player_config() -> PlayerConfig:
	if player_config != null:
		return player_config

	player_config = DEFAULT_PLAYER_CONFIG
	return player_config


func _physics_process(delta: float) -> void:
	_update_damage_invulnerability(delta)

	var jump_pressed := Input.is_action_just_pressed("jump")
	var jump_released := Input.is_action_just_released("jump")
	var attack_pressed := Input.is_action_just_pressed("attack")
	var dash_pressed := Input.is_action_just_pressed("dash")
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


func _update_jump_window_timers(delta: float, was_grounded: bool, jump_pressed: bool) -> void:
	if jump_pressed:
		_jump_buffer_timer = jump_buffer_window
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

	if was_grounded:
		_coyote_timer = coyote_time_window
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)


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


func _apply_vertical_motion(delta: float, was_grounded: bool) -> void:
	if was_grounded and velocity.y > 0.0:
		velocity.y = 0.0
		return

	var gravity := fall_gravity if velocity.y >= 0.0 else rise_gravity
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)


func _can_start_jump(was_grounded: bool) -> bool:
	if _is_attacking() or _is_dashing():
		return false

	if _jump_buffer_timer <= 0.0:
		return false

	return was_grounded or _coyote_timer > 0.0


func _can_start_attack(was_grounded: bool, attack_pressed: bool) -> bool:
	return was_grounded and attack_pressed and not _is_attacking() and not _is_dashing()


func _can_start_dash(was_grounded: bool, dash_pressed: bool) -> bool:
	if not dash_pressed or not was_grounded:
		return false

	if _dash_cooldown_remaining > 0.0 or _is_attacking() or _is_dashing():
		return false

	return current_state == STATE_IDLE or current_state == STATE_RUN or current_state == STATE_LAND


func _start_jump() -> void:
	velocity.y = jump_velocity
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_landing_state_timer = 0.0
	current_state = STATE_JUMP_RISE


func _start_attack() -> void:
	_attack_elapsed = 0.0
	_attack_was_active = false
	_attack_hit_ids.clear()
	_landing_state_timer = 0.0
	_jump_buffer_timer = 0.0
	current_state = STATE_ATTACK
	velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * 0.02)


func _start_dash() -> void:
	var input_axis := Input.get_axis("move_left", "move_right")
	_dash_direction = _facing_direction if absf(input_axis) <= 0.01 else signf(input_axis)
	_facing_direction = _dash_direction
	_dash_elapsed = 0.0001
	_landing_state_timer = 0.0
	_jump_buffer_timer = 0.0
	current_state = STATE_DASH
	velocity.x = dash_speed * _dash_direction
	velocity.y = 0.0
	_set_dash_feedback_active(true)


func _update_attack_state(delta: float, was_grounded: bool) -> void:
	_apply_attack_movement(delta, was_grounded)

	_attack_elapsed += delta

	if _attack_is_active() and not _attack_was_active:
		_perform_attack_hits()
		_attack_was_active = true

	if _attack_elapsed >= _get_attack_total_duration():
		_finish_attack()


func _apply_attack_movement(delta: float, was_grounded: bool) -> void:
	if was_grounded:
		velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, air_acceleration * delta)

	_apply_vertical_motion(delta, was_grounded)


func _update_dash_state(delta: float, was_grounded: bool) -> void:
	velocity.x = dash_speed * _dash_direction
	# 阶段 4 的 dash 只允许从地面起手，但持续期内保持平直位移，
	# 这样才能稳定承担“穿过短门槛 / 快速接敌”的最小能力差异价值。
	velocity.y = 0.0

	_dash_elapsed += delta
	if _dash_elapsed >= dash_duration:
		_finish_dash()


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


func _resolve_attack_receiver(collider: Object) -> Object:
	if collider.has_method("receive_attack"):
		return collider

	if collider is Node:
		var parent := (collider as Node).get_parent()
		if parent != null and parent.has_method("receive_attack"):
			return parent

	return null


func _finish_attack() -> void:
	_attack_elapsed = 0.0
	_attack_was_active = false
	_attack_hit_ids.clear()
	current_state = STATE_IDLE


func _finish_dash() -> void:
	_dash_elapsed = 0.0
	_dash_cooldown_remaining = dash_cooldown
	velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * 0.02)
	current_state = STATE_IDLE
	_set_dash_feedback_active(false)


func _update_landing_state(delta: float, was_grounded: bool, is_grounded: bool) -> void:
	if _is_attacking():
		_landing_state_timer = 0.0
		return

	if is_grounded and not was_grounded and _was_on_floor == false and velocity.y >= 0.0:
		_landing_state_timer = landing_state_duration
	elif _landing_state_timer > 0.0:
		_landing_state_timer = maxf(_landing_state_timer - delta, 0.0)


func _update_current_state(is_grounded: bool) -> void:
	if _is_attacking():
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


func _is_attacking() -> bool:
	return _attack_elapsed > 0.0 or current_state == STATE_ATTACK


func _is_dashing() -> bool:
	return _dash_elapsed > 0.0 or current_state == STATE_DASH


func _update_dash_cooldown(delta: float) -> void:
	_dash_cooldown_remaining = maxf(_dash_cooldown_remaining - delta, 0.0)


func _attack_is_active() -> bool:
	var active_start := attack_startup_duration
	var active_end := active_start + attack_active_duration
	return _attack_elapsed >= active_start and _attack_elapsed < active_end


func _get_attack_total_duration() -> float:
	return attack_startup_duration + attack_active_duration + attack_recovery_duration


func get_attack_hitbox_center() -> Vector2:
	return global_position + Vector2(
		attack_hitbox_offset.x * _facing_direction,
		attack_hitbox_offset.y
	)


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


func restore_full_health() -> void:
	current_health = max_health
	_is_defeated = false
	_damage_invulnerability_remaining = 0.0
	_refresh_body_color()
	health_changed.emit(current_health, max_health)


func get_current_health() -> int:
	return current_health


func get_max_health() -> int:
	return max_health


func is_dash_ready() -> bool:
	return _dash_cooldown_remaining <= 0.0 and not _is_dashing() and not _is_defeated


func get_hud_status_snapshot() -> Dictionary:
	return {
		"current_health": current_health,
		"max_health": max_health,
		"dash_ready": is_dash_ready(),
		"dash_cooldown_remaining": _dash_cooldown_remaining,
		"current_state": String(current_state),
		"is_defeated": _is_defeated
	}


func _set_dash_feedback_active(is_active: bool) -> void:
	_dash_feedback_active = is_active
	_refresh_body_color()


func _update_damage_invulnerability(delta: float) -> void:
	_damage_invulnerability_remaining = maxf(_damage_invulnerability_remaining - delta, 0.0)
	if _damage_invulnerability_remaining <= 0.0:
		_refresh_body_color()


func _apply_damage_knockback(hit_direction: Vector2) -> void:
	var direction := hit_direction.normalized()
	var horizontal_direction := signf(direction.x)

	if absf(horizontal_direction) <= 0.01:
		horizontal_direction = -_facing_direction

	velocity.x = damage_knockback_speed * horizontal_direction
	velocity.y = damage_knockback_lift


func _refresh_body_color() -> void:
	if _body_polygon == null:
		return

	if _damage_invulnerability_remaining > 0.0:
		_body_polygon.color = damage_flash_color
		return

	# 阶段 6 继续沿用最小可读性反馈：优先显示受击无敌，再回落到 dash 高亮。
	_body_polygon.color = dash_body_color if _dash_feedback_active else _body_idle_color
