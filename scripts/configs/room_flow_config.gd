extends Resource
class_name RoomFlowConfig

# RoomFlowConfig 把房间文案、出生点和灰盒阈值从脚本里抽出来。
# 它不负责流程推进，只给房间脚本提供可调数据和默认值回退。

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
	# 出生点允许继续用字典配置；如果配置被误填成非 Vector2，就回退到脚本默认点。
	var value: Variant = spawn_positions.get(spawn_id, fallback)
	if value is Vector2:
		return value

	return fallback


func get_threshold(name: StringName, fallback: Variant = null) -> Variant:
	return thresholds.get(name, fallback)
