extends StaticBody2D


signal defeated

@export var patrol_distance: float = 40.0
@export var patrol_speed: float = 2.2
@export var touch_damage: int = 1

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var _body_polygon: Polygon2D = $Body

var _spawn_position := Vector2.ZERO
var _patrol_elapsed := 0.0
var _is_defeated := false


func _ready() -> void:
	_spawn_position = position


func _process(delta: float) -> void:
	if _is_defeated:
		return

	_patrol_elapsed += delta
	position.x = _spawn_position.x + sin(_patrol_elapsed * patrol_speed) * patrol_distance


func _physics_process(_delta: float) -> void:
	if _is_defeated or _hurtbox == null:
		return

	for body in _hurtbox.get_overlapping_bodies():
		var receiver := _resolve_damage_receiver(body)
		if receiver == null:
			continue

		var receiver_node := receiver as Node2D
		if receiver_node == null:
			continue

		var hit_direction: Vector2 = receiver_node.global_position - global_position
		receiver.call("receive_damage", touch_damage, hit_direction)


func receive_attack(_hit_direction: Vector2, _knockback_force: float) -> void:
	if _is_defeated:
		return

	_is_defeated = true
	if _collision_shape != null:
		_collision_shape.disabled = true
	if _hurtbox_shape != null:
		_hurtbox_shape.disabled = true
	if _body_polygon != null:
		_body_polygon.color = Color(0.572549, 0.294118, 0.294118, 0.45)
	defeated.emit()


func is_defeated() -> bool:
	return _is_defeated


func _resolve_damage_receiver(candidate: Object) -> Node:
	if candidate == null:
		return null

	if candidate.has_method("receive_damage"):
		return candidate as Node

	if candidate is Node:
		var parent := (candidate as Node).get_parent()
		if parent != null and parent.has_method("receive_damage"):
			return parent

	return null
