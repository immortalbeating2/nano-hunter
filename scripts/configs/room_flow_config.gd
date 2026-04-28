extends Resource
class_name RoomFlowConfig

# RoomFlowConfig 把房间文案、出生点和灰盒阈值从脚本里抽出来。
# 它不负责流程推进，只给房间脚本提供可调数据和默认值回退。

# 文案字典由房间 HUD 读取，允许同一房间在不同阶段显示不同目标和提示。
@export var step_titles: Dictionary = {}
@export var step_prompts: Dictionary = {}

# dash 可见性用于早期教程 HUD，不代表正式技能 UI 系统。
@export var step_dash_visibility: Dictionary = {}

# 出生点和阈值保持字典形式，方便灰盒阶段按房间小步扩展。
@export var spawn_positions: Dictionary = {}
@export var thresholds: Dictionary = {}


# 读取指定步骤标题；配置缺失时使用调用方提供的默认标题。
func get_step_title(step_id: StringName, fallback: String = "") -> String:
	# 标题缺失时回退脚本默认值，避免配置资源缺字段导致 HUD 空白。
	return str(step_titles.get(step_id, fallback))


# 读取指定步骤提示；配置缺失时使用调用方提供的默认提示。
func get_step_prompt(step_id: StringName, fallback: String = "") -> String:
	# 提示文本同样允许回退，让房间脚本在配置不完整时仍可运行。
	return str(step_prompts.get(step_id, fallback))


# 查询某一步是否显示 dash 提示，主要服务早期教程 HUD。
func is_dash_visible(step_id: StringName, default_value: bool = true) -> bool:
	# 该读值只服务教程 HUD 的 dash 提示可见性，不控制玩家真实能力。
	return bool(step_dash_visibility.get(step_id, default_value))


# 读取指定出生点；配置值类型错误时回退到调用方默认点。
func get_spawn_position(spawn_id: StringName, fallback: Vector2 = Vector2.ZERO) -> Vector2:
	# 出生点允许继续用字典配置；如果配置被误填成非 Vector2，就回退到脚本默认点。
	var value: Variant = spawn_positions.get(spawn_id, fallback)
	if value is Vector2:
		return value

	return fallback


# 读取灰盒阈值参数；类型校验交给具体房间按用途处理。
func get_threshold(name: StringName, fallback: Variant = null) -> Variant:
	# 阈值保留 Variant，是为了让早期房间能共享距离、数量和开关类灰盒参数。
	return thresholds.get(name, fallback)
