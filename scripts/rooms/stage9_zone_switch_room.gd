extends "res://scripts/rooms/stage9_room_base.gd"


var _switch_activated := false


func _process(delta: float) -> void:
	if not _switch_activated and _player != null:
		var switch_zone: Area2D = get_node_or_null("GateSwitch") as Area2D
		if switch_zone != null and _player.global_position.distance_to(switch_zone.global_position) <= 56.0:
			activate_gate_switch()

	super._process(delta)


func activate_gate_switch() -> void:
	if _switch_activated:
		return

	_switch_activated = true
	unlock_gate(cleared_step_id)
