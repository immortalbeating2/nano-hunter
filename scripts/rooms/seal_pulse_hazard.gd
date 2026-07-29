extends Area2D
class_name SealPulseHazard

# 封印脉冲阵以“休止 -> 预警 -> 激活”循环制造时机危险。
# 它不改变地形碰撞，也不保存跨房状态。

enum Phase {
	REST,
	WARNING,
	ACTIVE,
}

@export var rest_duration := 1.1
@export var warning_duration := 0.65
@export var active_duration := 0.32
@export var damage := 1

@onready var warning_visual: CanvasItem = get_node_or_null("WarningVisual") as CanvasItem
@onready var active_visual: CanvasItem = get_node_or_null("ActiveVisual") as CanvasItem

var _phase := Phase.REST
var _phase_elapsed := 0.0
var _damage_dealt_this_cycle := false
var _player: CharacterBody2D


func _ready() -> void:
	_sync_visuals()


func bind_player(player: CharacterBody2D) -> void:
	_player = player


func _physics_process(delta: float) -> void:
	_phase_elapsed += delta
	var duration := _get_phase_duration()
	while _phase_elapsed >= duration:
		_phase_elapsed -= duration
		_advance_phase()
		duration = _get_phase_duration()

	if _phase == Phase.ACTIVE:
		_try_deal_damage()


func get_phase_id() -> StringName:
	match _phase:
		Phase.WARNING:
			return &"warning"
		Phase.ACTIVE:
			return &"active"
		_:
			return &"rest"


func is_damage_active() -> bool:
	return _phase == Phase.ACTIVE


func get_damage_amount() -> int:
	return damage


func _get_phase_duration() -> float:
	match _phase:
		Phase.WARNING:
			return maxf(warning_duration, 0.01)
		Phase.ACTIVE:
			return maxf(active_duration, 0.01)
		_:
			return maxf(rest_duration, 0.01)


func _advance_phase() -> void:
	match _phase:
		Phase.REST:
			_phase = Phase.WARNING
		Phase.WARNING:
			_phase = Phase.ACTIVE
			_damage_dealt_this_cycle = false
		Phase.ACTIVE:
			_phase = Phase.REST
	_sync_visuals()


func _try_deal_damage() -> void:
	if _damage_dealt_this_cycle or _player == null or not is_instance_valid(_player):
		return
	if not overlaps_body(_player):
		return

	_damage_dealt_this_cycle = true
	if _player.has_method("receive_damage"):
		_player.call("receive_damage", damage, Vector2.UP)


func _sync_visuals() -> void:
	if warning_visual != null:
		warning_visual.visible = _phase == Phase.WARNING
	if active_visual != null:
		active_visual.visible = _phase == Phase.ACTIVE
