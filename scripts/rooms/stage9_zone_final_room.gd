extends "res://scripts/rooms/stage9_room_base.gd"


var _remaining_enemy_count := 0


func _ready() -> void:
	_remaining_enemy_count = _count_active_enemies()
	super._ready()
	if _remaining_enemy_count > 0:
		_gate_unlocked = false
		_apply_gate_lock_state()
		_emit_hud_context()


func _handle_enemy_defeated() -> void:
	_remaining_enemy_count = max(_remaining_enemy_count - 1, 0)
	if _remaining_enemy_count == 0:
		unlock_gate(cleared_step_id)


func _count_active_enemies() -> int:
	var count := 0
	for child in get_children():
		if child.has_signal("defeated"):
			count += 1
	return count
