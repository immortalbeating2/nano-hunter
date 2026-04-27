extends Node2D

# Stage9RoomBase 是阶段 9 线性小区域的统一房间基类。
# 它负责门控、房间出口推进、checkpoint 触发和 HUD 上下文，
# 具体敌人组合与房间摆设继续交给各自场景。


signal room_transition_requested(target_room_path: String, spawn_id: StringName)
signal hud_context_changed(step_title: String, prompt_text: String)
signal checkpoint_requested(room_path: String, spawn_id: StringName)
signal goal_completed

const CAMERA_LIMITS := Rect2i(-320, -192, 960, 384)
const RoomFlowConfig := preload("res://scripts/configs/room_flow_config.gd")

@export var flow_config: RoomFlowConfig
@export var next_room_path := ""
@export var next_spawn_id: StringName = &""
@export var checkpoint_spawn_id: StringName = &""
@export var default_step_id: StringName = &"room"
@export var cleared_step_id: StringName = &"clear"
@export var checkpoint_on_ready := false

var _player: CharacterBody2D
var _current_step: StringName = &"room"
var _gate_unlocked := true
var _checkpoint_activated := false
var _transition_requested := false


# 初始化时按房间资源确定默认步骤、门是否默认锁住，以及是否进房即激活 checkpoint。
func _ready() -> void:
	_current_step = default_step_id
	_gate_unlocked = _get_gate_shape() == null
	_bind_enemy_signals()
	_apply_gate_lock_state()
	if checkpoint_on_ready and checkpoint_spawn_id != StringName():
		# 动态换房时 Main 会在 add_child 之后立刻绑定信号；延后一帧可避免 ready 阶段的 checkpoint 信号被错过。
		call_deferred("activate_checkpoint")
	_emit_hud_context()


# 区域房间只在“门已开 + 玩家走到出口区”时触发推进。
func _process(_delta: float) -> void:
	if _player == null or _transition_requested:
		return

	if not _gate_unlocked:
		return

	var exit_zone: Area2D = get_node_or_null("ExitZone") as Area2D
	if exit_zone == null:
		return

	if _player.global_position.x >= exit_zone.global_position.x - 36.0:
		_transition_requested = true
		_handle_exit_reached()


func bind_player(player: CharacterBody2D) -> void:
	# 房间基类把玩家继续传给子节点，敌人和机关就不需要依赖 Main 的内部结构。
	_player = player
	for child in get_children():
		if child.has_method("bind_player"):
			child.call("bind_player", player)


func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS


func get_current_step_id() -> StringName:
	return _current_step


func get_current_step_title() -> String:
	if flow_config != null:
		return flow_config.get_step_title(_current_step, "区域推进中")

	return "区域推进中"


func get_current_prompt_text() -> String:
	if flow_config != null:
		return flow_config.get_step_prompt(_current_step, "")

	return ""


func get_spawn_position(spawn_id: StringName) -> Vector2:
	if flow_config != null:
		return flow_config.get_spawn_position(spawn_id, Vector2(-224, 96))

	return Vector2(-224, 96)


func get_hud_context() -> Dictionary:
	# HUD 上下文保持最小字段集：步骤、标题、提示和 dash 可用性。
	# Stage10/13 会在此基础上 merge 自己的区域读值。
	return {
		"step_id": _current_step,
		"step_title": get_current_step_title(),
		"prompt_text": get_current_prompt_text(),
		"dash_available": true,
	}


func should_reset_on_player_defeat() -> bool:
	return true


func is_gate_unlocked() -> bool:
	return _gate_unlocked


func activate_checkpoint() -> void:
	# checkpoint 只向 Main 汇报“下一次失败回到哪里”，不在房间里保存玩家状态。
	if _checkpoint_activated or checkpoint_spawn_id == StringName():
		return

	_checkpoint_activated = true
	checkpoint_requested.emit(scene_file_path, checkpoint_spawn_id)


func unlock_gate(next_step_id: StringName = StringName()) -> void:
	# 门控解锁和 HUD 步骤推进绑在一起，避免玩家看到门已开但提示仍停在清房前。
	_gate_unlocked = true
	if next_step_id != StringName():
		_current_step = next_step_id
	_apply_gate_lock_state()
	_emit_hud_context()


func _handle_enemy_defeated() -> void:
	unlock_gate(cleared_step_id)


func _handle_exit_reached() -> void:
	# 有 next_room_path 的房间推进到下一房；没有下一房的房间视为区域目标完成。
	if not next_room_path.is_empty():
		room_transition_requested.emit(next_room_path, next_spawn_id)
		return

	goal_completed.emit()


func _bind_enemy_signals() -> void:
	# 当前小区域只需要“一只或多只敌人被击败后开门”的最小规则；
	# 如果后续需要全清计数，应在这里扩展，而不是散落到各房间。
	for child in get_children():
		if child.has_signal("defeated"):
			var callback := Callable(self, "_on_enemy_defeated")
			if not child.is_connected("defeated", callback):
				child.connect("defeated", callback)


func _on_enemy_defeated() -> void:
	_handle_enemy_defeated()


func _emit_hud_context() -> void:
	hud_context_changed.emit(get_current_step_title(), get_current_prompt_text())


func _apply_gate_lock_state() -> void:
	# 碰撞与颜色一起更新，确保自动化和人工复核读到同一个门控状态。
	var gate_shape := _get_gate_shape()
	if gate_shape != null:
		gate_shape.disabled = _gate_unlocked

	var gate_visual := _get_gate_visual()
	if gate_visual != null:
		gate_visual.color = Color(0.258824, 0.694118, 0.478431, 1.0) if _gate_unlocked else Color(0.776471, 0.321569, 0.262745, 1.0)


func _get_gate_shape() -> CollisionShape2D:
	return get_node_or_null("GateBarrier/CollisionShape2D") as CollisionShape2D


func _get_gate_visual() -> Polygon2D:
	return get_node_or_null("GateBarrier/BarrierVisual") as Polygon2D
