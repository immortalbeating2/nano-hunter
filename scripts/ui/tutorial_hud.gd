extends Control


const STEP_MOVE_JUMP: StringName = &"move_jump"
const STEP_DASH: StringName = &"dash"
const STEP_ATTACK: StringName = &"attack"
const STEP_EXIT: StringName = &"exit"
const STEP_COMPLETE: StringName = &"complete"

const STEP_ORDER := {
	STEP_MOVE_JUMP: 0,
	STEP_DASH: 1,
	STEP_ATTACK: 2,
	STEP_EXIT: 3,
	STEP_COMPLETE: 4,
}

const STEP_TITLES := {
	STEP_MOVE_JUMP: "教程 1/4 · 移动与跳跃",
	STEP_DASH: "教程 2/4 · 冲刺穿门",
	STEP_ATTACK: "教程 3/4 · 基础攻击",
	STEP_EXIT: "教程 4/4 · 离开教程区",
	STEP_COMPLETE: "教程完成",
}

@onready var step_label: Label = $PromptPanel/StepLabel
@onready var prompt_label: Label = $PromptPanel/PromptLabel
@onready var status_label: Label = $BattlePanel/StatusLabel
@onready var dash_label: Label = $BattlePanel/DashLabel

var _room: Node
var _player: CharacterBody2D


func _ready() -> void:
	status_label.text = "生命：■■■"
	step_label.text = STEP_TITLES[STEP_MOVE_JUMP]
	if prompt_label.text.is_empty():
		prompt_label.text = "正在等待教程房间..."
	_update_dash_status()


func _process(_delta: float) -> void:
	_update_dash_status()


func bind_room(room: Node) -> void:
	if _room != null and _room.has_signal("tutorial_step_changed"):
		var callback := Callable(self, "_on_tutorial_step_changed")
		if _room.is_connected("tutorial_step_changed", callback):
			_room.disconnect("tutorial_step_changed", callback)

	_room = room

	if _room != null and _room.has_signal("tutorial_step_changed"):
		_room.connect("tutorial_step_changed", Callable(self, "_on_tutorial_step_changed"))

	_sync_from_room()


func bind_player(player: CharacterBody2D) -> void:
	_player = player
	_update_dash_status()


func _sync_from_room() -> void:
	if _room == null:
		return

	if _room.has_method("get_current_step_id"):
		var current_step: StringName = _room.call("get_current_step_id")
		step_label.text = STEP_TITLES.get(current_step, "教程进行中")

	if _room.has_method("get_current_prompt_text"):
		prompt_label.text = _room.call("get_current_prompt_text")

	_update_dash_status()


func _on_tutorial_step_changed(step_id: StringName, prompt_text: String) -> void:
	step_label.text = STEP_TITLES.get(step_id, "教程进行中")
	prompt_label.text = prompt_text
	_update_dash_status()


func _update_dash_status() -> void:
	if dash_label == null:
		return

	var current_step: StringName = STEP_MOVE_JUMP
	if _room != null and _room.has_method("get_current_step_id"):
		current_step = _room.call("get_current_step_id")

	var has_dash_access: bool = STEP_ORDER.get(current_step, 0) >= STEP_ORDER[STEP_DASH]

	if not has_dash_access:
		dash_label.text = "冲刺：未开放"
		return

	if _player == null:
		dash_label.text = "冲刺：等待玩家"
		return

	var cooldown_remaining: float = _player.get("_dash_cooldown_remaining")
	dash_label.text = "冲刺：冷却中" if cooldown_remaining > 0.01 else "冲刺：就绪"
