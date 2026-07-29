extends Area2D
class_name MiasmaProjectile

# 腐瘴弹体只负责直线飞行、一次伤害和风印斩散。
# 施法节奏、目标选择与房间门控仍由 Caster 和房间脚本负责。

signal dispersed

@export var speed := 120.0
@export var damage := 1
@export var max_distance := 184.0

@onready var projectile_visual: AnimatedSprite2D = get_node_or_null("ProjectileVisual") as AnimatedSprite2D

var _direction := Vector2.LEFT
var _origin := Vector2.ZERO
var _spent := false


func _ready() -> void:
	_origin = global_position
	if projectile_visual != null:
		projectile_visual.play(&"miasma_purge_warning")


# Caster 在生成后注入方向和配置；弹体不持有玩家或敌人引用。
func configure(
	direction: Vector2,
	projectile_damage: int,
	distance_limit: float,
	projectile_speed: float
) -> void:
	_direction = direction.normalized() if not direction.is_zero_approx() else Vector2.LEFT
	damage = maxi(projectile_damage, 1)
	max_distance = maxf(distance_limit, 1.0)
	speed = maxf(projectile_speed, 1.0)
	_origin = global_position


func _physics_process(delta: float) -> void:
	if _spent:
		return

	global_position += _direction * speed * delta
	if global_position.distance_to(_origin) >= max_distance:
		_spend()
		return

	for body: Node2D in get_overlapping_bodies():
		var receiver := _resolve_damage_receiver(body)
		if receiver == null:
			continue
		var hit_direction := receiver.global_position - global_position
		receiver.call("receive_damage", damage, hit_direction)
		_spend()
		return


# 玩家只有在风印使攻击查询包含 Area2D 时才能走到该契约。
func receive_attack(_hit_direction: Vector2, _knockback_force: float) -> void:
	if _spent:
		return
	_spent = true
	dispersed.emit()
	queue_free()


func is_spent() -> bool:
	return _spent


func get_damage_amount() -> int:
	return damage


func _spend() -> void:
	if _spent:
		return
	_spent = true
	queue_free()


func _resolve_damage_receiver(candidate: Object) -> Node2D:
	if candidate == null:
		return null
	if candidate.has_method("receive_damage"):
		return candidate as Node2D
	if candidate is Node:
		var parent := (candidate as Node).get_parent()
		if parent != null and parent.has_method("receive_damage"):
			return parent as Node2D
	return null
