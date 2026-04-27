extends Control

# TutorialHUD 是当前原型期统一的运行时 HUD。
# 它只负责把主流程、房间和玩家暴露出来的稳定快照翻译成文本，
# 不直接驱动房间推进，也不反向写入玩家或主流程状态。

@onready var step_label: Label = $PromptPanel/StepLabel
@onready var prompt_label: Label = $PromptPanel/PromptLabel
@onready var status_label: Label = $BattlePanel/StatusLabel
@onready var dash_label: Label = $BattlePanel/DashLabel
@onready var progress_label: Label = $BattlePanel/ProgressLabel

var _main: Node
var _room: Node
var _player: CharacterBody2D


# 初始化只放默认占位文案，真正内容以后续 bind_main / bind_room / bind_player 为准。
func _ready() -> void:
	status_label.text = "生命：■■■"
	step_label.text = "教程 1/4 · 移动与跳跃"
	if prompt_label.text.is_empty():
		prompt_label.text = "正在等待教程房间..."
	_update_dash_status()
	_update_progress_status()


func _process(_delta: float) -> void:
	_update_dash_status()
	_update_progress_status()


# HUD 的绑定顺序允许主流程、房间和玩家分别到位，因此每次绑定后都要主动同步一次显示。
func bind_main(main: Node) -> void:
	_main = main
	_update_progress_status()


func bind_room(room: Node) -> void:
	if _room != null:
		_disconnect_room_signals(_room)

	_room = room

	if _room != null:
		_connect_room_signals(_room)

	_sync_from_sources()


func bind_player(player: CharacterBody2D) -> void:
	if _player != null and _player.has_signal("health_changed"):
		var callback := Callable(self, "_on_player_health_changed")
		if _player.is_connected("health_changed", callback):
			_player.disconnect("health_changed", callback)

	_player = player
	if _player != null and _player.has_signal("health_changed"):
		_player.connect("health_changed", Callable(self, "_on_player_health_changed"))

	_sync_from_sources()


# 房间上下文负责教程标题、提示词和成长读值；玩家快照负责生命与 dash 冷却；
# 主流程快照负责 stage11 的 demo 目标与完成反馈。
func _sync_from_sources() -> void:
	_apply_room_context(_get_room_hud_context())
	_update_health_status()
	_update_dash_status()
	_update_progress_status()


func _on_tutorial_step_changed(step_id: StringName, prompt_text: String) -> void:
	var room_context := _get_room_hud_context()
	step_label.text = str(room_context.get("step_title", str(step_id)))
	prompt_label.text = str(room_context.get("prompt_text", prompt_text))
	_update_dash_status()
	_update_progress_status()


func _on_hud_context_changed(step_title: String, prompt_text: String) -> void:
	_apply_room_context({
		"step_title": step_title,
		"prompt_text": prompt_text,
		"dash_available": _get_room_hud_context().get("dash_available", true),
	})
	_update_dash_status()
	_update_progress_status()


func _on_player_health_changed(_current_health: int, _max_health: int) -> void:
	_update_health_status()


# dash 状态显示保持最小规则：未开放 / 等待玩家 / 冷却中 / 就绪。
func _update_dash_status() -> void:
	if dash_label == null:
		return

	var room_context := _get_room_hud_context()
	var has_dash_access := bool(room_context.get("dash_available", true))

	if not has_dash_access:
		dash_label.text = "冲刺：未开放"
		return

	var player_status := _get_player_hud_status()
	if player_status.is_empty():
		dash_label.text = "冲刺：等待玩家"
		return

	var cooldown_remaining := float(player_status.get("dash_cooldown_remaining", 0.0))
	dash_label.text = "冲刺：冷却中" if cooldown_remaining > 0.01 else "冲刺：就绪"


func _update_health_status() -> void:
	if status_label == null:
		return

	var player_status := _get_player_hud_status()
	var current_health := int(player_status.get("current_health", 3))
	var max_health := int(player_status.get("max_health", 3))

	status_label.text = "生命：%s" % _build_health_icons(current_health, max_health)


# Demo 进度和 stage10 成长反馈都通过稳定快照组装成最小可读文案，
# HUD 只做翻译与拼接，不反向控制任何房间或主流程状态。
func _update_progress_status() -> void:
	if progress_label == null:
		return

	var lines: Array[String] = []
	var demo_snapshot := _get_main_demo_snapshot()
	if not demo_snapshot.is_empty():
		lines.append(str(demo_snapshot.get("goal_text", "")))
		var goal_hint := str(demo_snapshot.get("goal_hint_text", ""))
		if not goal_hint.is_empty():
			lines.append(goal_hint)

	var room_context := _get_room_hud_context()
	if room_context.has("stage14_backtrack_reward_count"):
		var air_dash_text := "已获得" if bool(demo_snapshot.get("air_dash_unlocked", false)) else "未获得"
		var reward_count := int(room_context.get("stage14_backtrack_reward_count", demo_snapshot.get("stage14_backtrack_reward_count", 0)))
		lines.append("空中冲刺：%s  回溯收益：%d/3" % [air_dash_text, reward_count])
	elif room_context.has("collectible_count") or room_context.has("recovery_point_activated"):
		var collectible_count := int(room_context.get("collectible_count", 0))
		var recovery_text := "已激活" if bool(room_context.get("recovery_point_activated", false)) else "未激活"
		lines.append("收集：%d  恢复：%s" % [collectible_count, recovery_text])
	elif lines.is_empty():
		lines.append("目标：继续推进 Demo")

	progress_label.text = "\n".join(lines)


func _build_health_icons(current_health: int, max_health: int) -> String:
	var filled := ""
	var empty := ""
	for _i in range(max(current_health, 0)):
		filled += "■"
	for _i in range(max(max_health - current_health, 0)):
		empty += "□"

	return filled + empty


func _connect_room_signals(room: Node) -> void:
	if room.has_signal("hud_context_changed"):
		room.connect("hud_context_changed", Callable(self, "_on_hud_context_changed"))

	if room.has_signal("tutorial_step_changed"):
		room.connect("tutorial_step_changed", Callable(self, "_on_tutorial_step_changed"))


func _disconnect_room_signals(room: Node) -> void:
	var hud_callback := Callable(self, "_on_hud_context_changed")
	if room.has_signal("hud_context_changed") and room.is_connected("hud_context_changed", hud_callback):
		room.disconnect("hud_context_changed", hud_callback)

	var tutorial_callback := Callable(self, "_on_tutorial_step_changed")
	if room.has_signal("tutorial_step_changed") and room.is_connected("tutorial_step_changed", tutorial_callback):
		room.disconnect("tutorial_step_changed", tutorial_callback)


func _get_room_hud_context() -> Dictionary:
	if _room == null or not _room.has_method("get_hud_context"):
		return {}

	var context: Variant = _room.call("get_hud_context")
	return context if context is Dictionary else {}


func _get_player_hud_status() -> Dictionary:
	if _player == null or not _player.has_method("get_hud_status_snapshot"):
		return {}

	var status: Variant = _player.call("get_hud_status_snapshot")
	return status if status is Dictionary else {}


func _get_main_demo_snapshot() -> Dictionary:
	if _main == null or not _main.has_method("get_demo_progress_snapshot"):
		return {}

	var snapshot: Variant = _main.call("get_demo_progress_snapshot")
	return snapshot if snapshot is Dictionary else {}


func _apply_room_context(context: Dictionary) -> void:
	if context.has("step_title"):
		step_label.text = str(context["step_title"])
	if context.has("prompt_text"):
		prompt_label.text = str(context["prompt_text"])
