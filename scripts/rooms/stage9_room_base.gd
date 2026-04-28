extends Node2D

# Stage9RoomBase 是阶段 9 线性小区域的统一房间基类。
# 它负责门控、房间出口推进、checkpoint 触发和 HUD 上下文，
# 具体敌人组合与房间摆设继续交给各自场景。

# 房间信号是 Main 与 HUD 读取流程变化的稳定契约，子类不直接操作 Main 内部状态。
signal room_transition_requested(target_room_path: String, spawn_id: StringName)
signal hud_context_changed(step_title: String, prompt_text: String)
signal checkpoint_requested(room_path: String, spawn_id: StringName)
signal goal_completed

# Stage9 系列房间共享一套相机范围和流程配置资源类型。
const CAMERA_LIMITS := Rect2i(-320, -192, 960, 384)
const RoomFlowConfig := preload("res://scripts/configs/room_flow_config.gd")

# 导出字段由场景配置，用来描述当前房间的下一房、出生点、HUD 阶段和 checkpoint 行为。
@export var flow_config: RoomFlowConfig
@export var next_room_path := ""
@export var next_spawn_id: StringName = &""
@export var checkpoint_spawn_id: StringName = &""
@export var default_step_id: StringName = &"room"
@export var cleared_step_id: StringName = &"clear"
@export var checkpoint_on_ready := false
@export var require_all_enemies_defeated := false

# 运行期状态保存玩家引用、当前 HUD 步骤、门控状态、敌人清场计数、checkpoint 去重和切房去重。
var _player: CharacterBody2D
var _current_step: StringName = &"room"
var _gate_unlocked := true
var _remaining_required_enemy_count := 0
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


# 接收 Main 注入的玩家实例，并继续转交给房间内可绑定的敌人和机关。
func bind_player(player: CharacterBody2D) -> void:
	# 房间基类把玩家继续传给子节点，敌人和机关就不需要依赖 Main 的内部结构。
	_player = player
	for child in get_children():
		if child.has_method("bind_player"):
			child.call("bind_player", player)


# 返回 Stage9 系列房间统一相机边界。
func get_camera_limits() -> Rect2i:
	# Main 通过该接口同步相机边界，保持房间脚本不直接操作 Camera2D。
	return CAMERA_LIMITS


# 公开当前 HUD 步骤 ID，供测试和 HUD 上下文读取。
func get_current_step_id() -> StringName:
	# 当前步骤 ID 同时服务 HUD 文案和测试断言。
	return _current_step


# 返回当前步骤标题，优先读取流程配置资源。
func get_current_step_title() -> String:
	# 标题优先来自配置资源，缺失时回退到通用区域推进文本。
	if flow_config != null:
		return flow_config.get_step_title(_current_step, "区域推进中")

	return "区域推进中"


# 返回当前步骤提示，允许灰盒房间没有额外提示文案。
func get_current_prompt_text() -> String:
	# 提示文本允许为空，避免每个灰盒房都被迫写重复说明。
	if flow_config != null:
		return flow_config.get_step_prompt(_current_step, "")

	return ""


# 根据 spawn_id 返回房间出生点，配置缺失时回落到左侧安全区。
func get_spawn_position(spawn_id: StringName) -> Vector2:
	# 出生点由配置资源提供，回退点保持在房间左侧安全区域。
	if flow_config != null:
		return flow_config.get_spawn_position(spawn_id, Vector2(-224, 96))

	return Vector2(-224, 96)


# 汇总 Stage9 基础 HUD 上下文，后续阶段基类会在此基础上追加字段。
func get_hud_context() -> Dictionary:
	# HUD 上下文保持最小字段集：步骤、标题、提示和 dash 可用性。
	# Stage10/13 会在此基础上 merge 自己的区域读值。
	return {
		"step_id": _current_step,
		"step_title": get_current_step_title(),
		"prompt_text": get_current_prompt_text(),
		"dash_available": true,
	}


# 公开失败后是否由 Main 重载房间，Stage9 之后默认支持 checkpoint 重试。
func should_reset_on_player_defeat() -> bool:
	# Stage9 之后房间默认支持失败回到 checkpoint，Main 用该读值决定重置范围。
	return true


# 公开门控状态，供测试、能力门和 HUD 读值使用。
func is_gate_unlocked() -> bool:
	# 测试和能力门子类通过该读值判断当前通行状态。
	return _gate_unlocked


# 公开全清门控剩余敌人数，供 Stage15 战斗高潮测试和后续 HUD 调试读取。
func get_remaining_required_enemy_count() -> int:
	# 默认房间不启用全清门控时该值为 0；启用后随 defeated 信号递减。
	return _remaining_required_enemy_count


# 激活本房 checkpoint，并通过标准信号把恢复点交给 Main 保存。
func activate_checkpoint() -> void:
	# checkpoint 只向 Main 汇报“下一次失败回到哪里”，不在房间里保存玩家状态。
	if _checkpoint_activated or checkpoint_spawn_id == StringName():
		return

	_checkpoint_activated = true
	checkpoint_requested.emit(scene_file_path, checkpoint_spawn_id)


# 解锁当前房间门控，并可选推进 HUD 步骤。
func unlock_gate(next_step_id: StringName = StringName()) -> void:
	# 门控解锁和 HUD 步骤推进绑在一起，避免玩家看到门已开但提示仍停在清房前。
	_gate_unlocked = true
	if next_step_id != StringName():
		_current_step = next_step_id
	_apply_gate_lock_state()
	_emit_hud_context()


# 处理敌人 defeated 信号；默认任意敌人死亡即可开门，Stage15 高压房可要求全清。
func _handle_enemy_defeated() -> void:
	# 早期区域保留“任意敌人死亡即开门”的短链路，Stage15 通过导出开关升级为全清门控。
	if require_all_enemies_defeated:
		_remaining_required_enemy_count = max(0, _remaining_required_enemy_count - 1)
		if _remaining_required_enemy_count > 0:
			_emit_hud_context()
			return

	unlock_gate(cleared_step_id)


# 处理玩家到达出口区：有下一房则切房，否则广播区域目标完成。
func _handle_exit_reached() -> void:
	# 有 next_room_path 的房间推进到下一房；没有下一房的房间视为区域目标完成。
	if not next_room_path.is_empty():
		room_transition_requested.emit(next_room_path, next_spawn_id)
		return

	goal_completed.emit()


# 连接房间内敌人的 defeated 信号，让门控解锁逻辑集中在房间基类。
func _bind_enemy_signals() -> void:
	# 当前小区域只需要“一只或多只敌人被击败后开门”的最小规则；
	# Stage15 会通过 require_all_enemies_defeated 把同一套信号升级为全清计数。
	_remaining_required_enemy_count = 0
	for child in get_children():
		if child.has_signal("defeated"):
			if require_all_enemies_defeated:
				_remaining_required_enemy_count += 1
			var callback := Callable(self, "_on_enemy_defeated")
			if not child.is_connected("defeated", callback):
				child.connect("defeated", callback)


# 敌人 defeated 信号回调，只转交给可覆写的清敌处理入口。
func _on_enemy_defeated() -> void:
	# 信号回调只做转发，方便子类集中 override _handle_enemy_defeated。
	_handle_enemy_defeated()


# 广播当前房间 HUD 文案，避免 HUD 每帧主动轮询步骤变化。
func _emit_hud_context() -> void:
	# HUD 通过信号被动刷新，避免每帧从房间轮询文案变化。
	hud_context_changed.emit(get_current_step_title(), get_current_prompt_text())


# 根据门控状态同步碰撞与占位颜色，保证可玩和可看状态一致。
func _apply_gate_lock_state() -> void:
	# 碰撞与颜色一起更新，确保自动化和人工复核读到同一个门控状态。
	var gate_shape := _get_gate_shape()
	if gate_shape != null:
		gate_shape.disabled = _gate_unlocked

	var gate_visual := _get_gate_visual()
	if gate_visual != null:
		gate_visual.color = Color(0.258824, 0.694118, 0.478431, 1.0) if _gate_unlocked else Color(0.776471, 0.321569, 0.262745, 1.0)


# 查找可选门控碰撞节点；缺失时房间视为无门默认可通行。
func _get_gate_shape() -> CollisionShape2D:
	# 门控碰撞节点允许缺失；无门房间会被视为默认已解锁。
	return get_node_or_null("GateBarrier/CollisionShape2D") as CollisionShape2D


# 查找可选门控视觉节点；缺失时只保留碰撞状态。
func _get_gate_visual() -> Polygon2D:
	# 门控视觉同样是可选节点，方便早期房间逐步补齐占位资产。
	return get_node_or_null("GateBarrier/BarrierVisual") as Polygon2D
