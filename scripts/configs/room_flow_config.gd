extends Resource
class_name RoomFlowConfig


@export var step_titles: Dictionary = {}
@export var step_prompts: Dictionary = {}
@export var step_dash_visibility: Dictionary = {}
@export var spawn_positions: Dictionary = {}
@export var thresholds: Dictionary = {}


func get_step_title(step_id: StringName, fallback: String = "") -> String:
	return str(step_titles.get(step_id, fallback))


func get_step_prompt(step_id: StringName, fallback: String = "") -> String:
	return str(step_prompts.get(step_id, fallback))


func is_dash_visible(step_id: StringName, default_value: bool = true) -> bool:
	return bool(step_dash_visibility.get(step_id, default_value))


func get_spawn_position(spawn_id: StringName, fallback: Vector2 = Vector2.ZERO) -> Vector2:
	var value: Variant = spawn_positions.get(spawn_id, fallback)
	if value is Vector2:
		return value

	return fallback


func get_threshold(name: StringName, fallback: Variant = null) -> Variant:
	return thresholds.get(name, fallback)
