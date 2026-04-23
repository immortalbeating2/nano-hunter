extends StaticBody2D


signal hit_registered(hit_count: int)

@export var hit_flash_duration: float = 0.14
@export var hit_offset_distance: float = 12.0
@export var hit_scale := Vector2(1.08, 0.92)

var last_hit_direction := Vector2.ZERO
var last_knockback_force := 0.0
var hit_count: int = 0

var _hit_feedback_timer := 0.0


func _ready() -> void:
	_reset_feedback_visuals()


func _process(delta: float) -> void:
	if _hit_feedback_timer <= 0.0:
		return

	_hit_feedback_timer = maxf(_hit_feedback_timer - delta, 0.0)
	if _hit_feedback_timer <= 0.0:
		_reset_feedback_visuals()


func receive_attack(hit_direction: Vector2, knockback_force: float) -> void:
	hit_count += 1
	last_hit_direction = hit_direction
	last_knockback_force = knockback_force
	_hit_feedback_timer = hit_flash_duration
	hit_registered.emit(hit_count)

	var direction := hit_direction.normalized()
	$Body.position = direction * hit_offset_distance
	$Body.color = Color(1.0, 0.92, 0.68, 1.0)
	$Body.scale = hit_scale


func _reset_feedback_visuals() -> void:
	$Body.position = Vector2.ZERO
	$Body.color = Color(0.654902, 0.498039, 0.298039, 1.0)
	$Body.scale = Vector2.ONE
