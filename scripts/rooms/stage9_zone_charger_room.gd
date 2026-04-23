extends "res://scripts/rooms/stage9_room_base.gd"


func _handle_enemy_defeated() -> void:
	activate_checkpoint()
	unlock_gate(cleared_step_id)
