extends CharacterBody2D


const STATE_IDLE: StringName = &"idle"
const STATE_RUN: StringName = &"run"
const STATE_JUMP_RISE: StringName = &"jump_rise"
const STATE_JUMP_FALL: StringName = &"jump_fall"
const STATE_LAND: StringName = &"land"

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

var current_state: StringName = STATE_IDLE

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _landing_state_timer := 0.0
var _was_on_floor := false


func _ready() -> void:
	current_state = STATE_IDLE
	_was_on_floor = false


func _physics_process(delta: float) -> void:
	var jump_pressed := Input.is_action_just_pressed("jump")
	var jump_released := Input.is_action_just_released("jump")
	var was_grounded := is_on_floor()

	_update_jump_window_timers(delta, was_grounded, jump_pressed)
	_apply_horizontal_movement(delta)
	_apply_vertical_motion(delta, was_grounded)

	if _can_start_jump(was_grounded):
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
	if _jump_buffer_timer <= 0.0:
		return false

	return was_grounded or _coyote_timer > 0.0


func _start_jump() -> void:
	velocity.y = jump_velocity
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_landing_state_timer = 0.0
	current_state = STATE_JUMP_RISE


func _update_landing_state(delta: float, was_grounded: bool, is_grounded: bool) -> void:
	if is_grounded and not was_grounded and _was_on_floor == false and velocity.y >= 0.0:
		_landing_state_timer = landing_state_duration
	elif _landing_state_timer > 0.0:
		_landing_state_timer = maxf(_landing_state_timer - delta, 0.0)


func _update_current_state(is_grounded: bool) -> void:
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
