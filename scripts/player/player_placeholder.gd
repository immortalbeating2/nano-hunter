extends CharacterBody2D


const STATE_IDLE: StringName = &"idle"
const STATE_RUN: StringName = &"run"
const STATE_JUMP_RISE: StringName = &"jump_rise"
const STATE_JUMP_FALL: StringName = &"jump_fall"
const STATE_LAND: StringName = &"land"
const STATE_ATTACK: StringName = &"attack"

const FLOOR_VELOCITY_TOLERANCE := 0.5

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
@export var attack_startup_duration: float = 0.05
@export var attack_active_duration: float = 0.08
@export var attack_recovery_duration: float = 0.1
@export var attack_hitbox_size := Vector2(44.0, 28.0)
@export var attack_hitbox_offset := Vector2(26.0, -4.0)
@export var attack_knockback_force: float = 120.0

var current_state: StringName = STATE_IDLE

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _landing_state_timer := 0.0
var _was_on_floor := false
var _facing_direction := 1.0
var _attack_elapsed := 0.0
var _attack_was_active := false
var _attack_hit_ids: Dictionary = {}


func _ready() -> void:
	current_state = STATE_IDLE
	_was_on_floor = false
	_facing_direction = 1.0


func _physics_process(delta: float) -> void:
	var jump_pressed := Input.is_action_just_pressed("jump")
	var jump_released := Input.is_action_just_released("jump")
	var attack_pressed := Input.is_action_just_pressed("attack")
	var was_grounded := is_on_floor()

	_update_jump_window_timers(delta, was_grounded, jump_pressed)
	if _is_attacking():
		_update_attack_state(delta, was_grounded)
	else:
		_apply_horizontal_movement(delta)
		_apply_vertical_motion(delta, was_grounded)

		if _can_start_attack(was_grounded, attack_pressed):
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
	if _is_attacking():
		return false

	if _jump_buffer_timer <= 0.0:
		return false

	return was_grounded or _coyote_timer > 0.0


func _can_start_attack(was_grounded: bool, attack_pressed: bool) -> bool:
	return was_grounded and attack_pressed and not _is_attacking()


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
