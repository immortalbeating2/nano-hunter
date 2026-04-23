extends Control


@onready var step_label: Label = $PromptPanel/StepLabel
@onready var prompt_label: Label = $PromptPanel/PromptLabel
@onready var status_label: Label = $BattlePanel/StatusLabel
@onready var dash_label: Label = $BattlePanel/DashLabel

var _room: Node
var _player: CharacterBody2D


func _ready() -> void:
	status_label.text = "生命：■■■"
	step_label.text = "教程 1/4 · 移动与跳跃"
	if prompt_label.text.is_empty():
		prompt_label.text = "正在等待教程房间..."
	_update_dash_status()


func _process(_delta: float) -> void:
	_update_dash_status()


func bind_room(room: Node) -> void:
	if _room != null:
		_disconnect_room_signals(_room)

	_room = room

	if _room != null:
		_connect_room_signals(_room)

	_sync_from_room()


func bind_player(player: CharacterBody2D) -> void:
	if _player != null and _player.has_signal("health_changed"):
		var callback := Callable(self, "_on_player_health_changed")
		if _player.is_connected("health_changed", callback):
			_player.disconnect("health_changed", callback)

	_player = player
	if _player != null and _player.has_signal("health_changed"):
		_player.connect("health_changed", Callable(self, "_on_player_health_changed"))

	_update_health_status()
	_update_dash_status()


func _sync_from_room() -> void:
	if _room == null:
		return

	if _room.has_method("get_current_step_title"):
		step_label.text = _room.call("get_current_step_title")

	if _room.has_method("get_current_prompt_text"):
		prompt_label.text = _room.call("get_current_prompt_text")

	_update_health_status()
	_update_dash_status()


func _on_tutorial_step_changed(step_id: StringName, prompt_text: String) -> void:
	if _room != null and _room.has_method("get_current_step_title"):
		step_label.text = _room.call("get_current_step_title")
	else:
		step_label.text = str(step_id)

	prompt_label.text = prompt_text
	_update_dash_status()


func _on_hud_context_changed(step_title: String, prompt_text: String) -> void:
	step_label.text = step_title
	prompt_label.text = prompt_text
	_update_dash_status()


func _on_player_health_changed(_current_health: int, _max_health: int) -> void:
	_update_health_status()


func _update_dash_status() -> void:
	if dash_label == null:
		return

	var has_dash_access := true
	if _room != null and _room.has_method("is_dash_available_in_hud"):
		has_dash_access = _room.call("is_dash_available_in_hud")

	if not has_dash_access:
		dash_label.text = "冲刺：未开放"
		return

	if _player == null:
		dash_label.text = "冲刺：等待玩家"
		return

	var cooldown_remaining: float = _player.get("_dash_cooldown_remaining")
	dash_label.text = "冲刺：冷却中" if cooldown_remaining > 0.01 else "冲刺：就绪"


func _update_health_status() -> void:
	if status_label == null:
		return

	var current_health := 3
	var max_health := 3
	if _player != null:
		current_health = _player.get("current_health")
		max_health = _player.get("max_health")

	status_label.text = "生命：%s" % _build_health_icons(current_health, max_health)


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
