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
const GateStateVfx := preload("res://scripts/rooms/gate_state_vfx.gd")
const SEAL_GATE_LOCKED_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres")
const SEAL_GATE_OPEN_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/003_shrine_gate_prop_atlas_ai01_auto_004_c01.atlas_texture.tres")

# 导出字段由场景配置，用来描述当前房间的下一房、出生点、HUD 阶段和 checkpoint 行为。
@export var flow_config: RoomFlowConfig
@export var camera_limits: Rect2i = CAMERA_LIMITS
@export var next_room_path := ""
@export var next_spawn_id: StringName = &""
@export var previous_room_path := ""
@export var previous_spawn_id: StringName = &""
@export var spawn_positions: Dictionary = {}
@export var checkpoint_spawn_id: StringName = &""
@export var default_step_id: StringName = &"room"
@export var cleared_step_id: StringName = &"clear"
@export var checkpoint_on_ready := false
@export var checkpoint_requires_down_input := false
@export var require_all_enemies_defeated := false
@export var exit_zone_node_name: StringName = &"ExitZone"
@export var exit_requires_down_input := false
@export var exit_requires_proximity := false
@export var exit_requires_gate_unlocked := true
@export var restore_forward_gate_on_bind := true
@export var shortcut_room_path := ""
@export var shortcut_spawn_id: StringName = &""
@export var shortcut_requires_air_dash := false
@export var shortcut_required_reward_id: StringName = &""
@export var shortcut_requires_down_input := false
@export var narrative_stele_title := ""
@export_multiline var narrative_stele_text := ""

# 运行期状态保存玩家引用、当前 HUD 步骤、门控状态、敌人清场计数、checkpoint 去重和切房去重。
var _player: CharacterBody2D
var _current_step: StringName = &"room"
var _gate_unlocked := true
var _remaining_required_enemy_count := 0
var _checkpoint_activated := false
var _transition_requested := false
var _main: Node
var _narrative_stele_active := false


# 初始化时按房间资源确定默认步骤、门是否默认锁住，以及是否进房即激活 checkpoint。
func _ready() -> void:
	_current_step = default_step_id
	_gate_unlocked = _get_gate_shape() == null
	_bind_enemy_signals()
	_apply_gate_lock_state()
	if checkpoint_on_ready and not checkpoint_requires_down_input and checkpoint_spawn_id != StringName():
		# 动态换房时 Main 会在 add_child 之后立刻绑定信号；延后一帧可避免 ready 阶段的 checkpoint 信号被错过。
		call_deferred("activate_checkpoint")
	_emit_hud_context()


# 区域房间只在“门已开 + 玩家走到出口区”时触发推进。
func _process(_delta: float) -> void:
	if _player == null or _transition_requested:
		return

	_update_narrative_stele()
	_try_activate_checkpoint_zone()
	if _try_request_shortcut():
		return

	if _try_request_previous_room():
		return

	if exit_requires_gate_unlocked and not _gate_unlocked:
		return

	var exit_zone := get_node_or_null(str(exit_zone_node_name)) as Node2D
	if exit_zone == null:
		return

	if exit_requires_down_input:
		if _player.global_position.distance_to(exit_zone.global_position) > 56.0 or not _is_down_confirmation_pressed():
			return
	elif exit_requires_proximity:
		if _player.global_position.distance_to(exit_zone.global_position) > 56.0:
			return
	elif _player.global_position.x < exit_zone.global_position.x - 36.0:
		return

	_transition_requested = true
	_handle_exit_reached()


# 接收 Main 注入的玩家实例，并继续转交给房间内可绑定的敌人和机关。
func bind_player(player: CharacterBody2D) -> void:
	# 房间基类把玩家继续传给子节点，敌人和机关就不需要依赖 Main 的内部结构。
	_player = player
	for child in get_children():
		if child.has_method("bind_player"):
			child.call("bind_player", player)


# 接收 Main 引用，同时恢复本房确实完成过的向前门控；支路与捷径仍只读取各自探索收益。
func bind_main(main: Node) -> void:
	_main = main
	if (
		restore_forward_gate_on_bind
		and
		_main != null
		and _main.has_method("is_room_forward_route_completed")
		and bool(_main.call("is_room_forward_route_completed", scene_file_path))
	):
		unlock_gate(cleared_step_id)


# Main 用统一前进目标识别“完成房间”而不是普通回程、支路或捷径切换。
func get_forward_room_path() -> String:
	return next_room_path


# 返回 Stage9 系列房间统一相机边界。
func get_camera_limits() -> Rect2i:
	# Main 通过该接口同步相机边界，保持房间脚本不直接操作 Camera2D。
	return camera_limits


# 公开当前 HUD 步骤 ID，供测试和 HUD 上下文读取。
func get_current_step_id() -> StringName:
	# 当前步骤 ID 同时服务 HUD 文案和测试断言。
	return _current_step


# 返回当前步骤标题，优先读取流程配置资源。
func get_current_step_title() -> String:
	# 标题优先来自配置资源，缺失时回退到通用区域推进文本。
	if _narrative_stele_active and not narrative_stele_title.is_empty():
		return narrative_stele_title

	if flow_config != null:
		return flow_config.get_step_title(_current_step, "区域推进中")

	return "区域推进中"


# 返回当前步骤提示，允许灰盒房间没有额外提示文案。
func get_current_prompt_text() -> String:
	# 提示文本允许为空，避免每个灰盒房都被迫写重复说明。
	if _narrative_stele_active and not narrative_stele_text.is_empty():
		return narrative_stele_text

	if flow_config != null:
		return flow_config.get_step_prompt(_current_step, "")

	return ""


# 根据 spawn_id 返回房间出生点，配置缺失时回落到左侧安全区。
func get_spawn_position(spawn_id: StringName) -> Vector2:
	# 出生点由配置资源提供，回退点保持在房间左侧安全区域。
	var fallback := _get_scene_spawn_position(spawn_id, Vector2(-224, 96))
	if flow_config != null:
		return flow_config.get_spawn_position(spawn_id, fallback)

	return fallback


# 汇总 Stage9 基础 HUD 上下文，后续阶段基类会在此基础上追加字段。
func get_hud_context() -> Dictionary:
	# HUD 上下文保持最小字段集：步骤、标题、提示和 dash 可用性。
	# Stage10/13 会在此基础上 merge 自己的区域读值。
	return {
		"step_id": _current_step,
		"step_title": get_current_step_title(),
		"prompt_text": get_current_prompt_text(),
		"dash_available": true,
		"shortcut_available": is_shortcut_available(),
		"shortcut_target": shortcut_room_path,
			"shortcut_requires_down_input": shortcut_requires_down_input,
			"exit_requires_down_input": exit_requires_down_input,
			"checkpoint_requires_down_input": checkpoint_requires_down_input,
			"narrative_stele_active": _narrative_stele_active,
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


# 需要明确休整的房间只在玩家靠近 CheckpointZone 并新按下“下”时激活恢复点。
func _try_activate_checkpoint_zone() -> void:
	if not checkpoint_requires_down_input or _checkpoint_activated:
		return
	var checkpoint_zone := get_node_or_null("CheckpointZone") as Node2D
	if checkpoint_zone == null or _player.global_position.distance_to(checkpoint_zone.global_position) > 56.0:
		return
	if not _is_down_confirmation_pressed():
		return
	activate_checkpoint()


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


# 普通房间允许玩家从左侧返回上一房；Boss 锁门等例外不放 LeftExitZone 或不配置 previous_room_path。
func _try_request_previous_room() -> bool:
	if previous_room_path.is_empty():
		return false

	var left_exit_zone := get_node_or_null("LeftExitZone") as Node2D
	if left_exit_zone == null:
		return false

	if _player.global_position.x > left_exit_zone.global_position.x + 36.0:
		return false

	_transition_requested = true
	room_transition_requested.emit(previous_room_path, previous_spawn_id)
	return true


# 查询当前房间的可选捷径是否满足能力与探索收益条件。
func is_shortcut_available() -> bool:
	if shortcut_room_path.is_empty():
		return false
	if shortcut_requires_air_dash and not _is_air_dash_unlocked():
		return false
	if shortcut_required_reward_id != StringName() and not _has_exploration_reward(shortcut_required_reward_id):
		return false
	return true


# 玩家进入 ShortcutZone 且条件满足时，按房间配置选择是否需要“下”确认，再复用标准切房信号。
func _try_request_shortcut() -> bool:
	if not is_shortcut_available():
		return false

	var shortcut_zone := get_node_or_null("ShortcutZone") as Node2D
	if shortcut_zone == null or _player.global_position.distance_to(shortcut_zone.global_position) > 48.0:
		return false
	if shortcut_requires_down_input and not _is_down_confirmation_pressed():
		return false

	_transition_requested = true
	room_transition_requested.emit(shortcut_room_path, shortcut_spawn_id)
	return true


# 主动门、祭坛和法坛共用“下”键的新按下边沿，避免按住输入跨房连续触发。
func _is_down_confirmation_pressed() -> bool:
	return Input.is_action_just_pressed("ui_down")


# 叙事碑只在玩家靠近时临时接管提示区，离开后恢复房间原有目标文本。
func _update_narrative_stele() -> void:
	var stele := get_node_or_null("NarrativeStele") as Node2D
	var is_active := stele != null and not narrative_stele_text.is_empty() and _player.global_position.distance_to(stele.global_position) <= 72.0
	if is_active == _narrative_stele_active:
		return

	_narrative_stele_active = is_active
	_emit_hud_context()


# Air Dash 状态直接读取 Main 已注入的新玩家，避免为捷径复制第二份能力状态。
func _is_air_dash_unlocked() -> bool:
	return _player != null and _player.has_method("is_air_dash_unlocked") and bool(_player.call("is_air_dash_unlocked"))


# 探索收益由 Main 跨房保存；孤立房间测试没有 Main 时按未取得处理。
func _has_exploration_reward(reward_id: StringName) -> bool:
	return _main != null and _main.has_method("has_exploration_reward") and bool(_main.call("has_exploration_reward", reward_id))


# 读取场景直接声明的出生点；后段房间不一定都有独立 RoomFlowConfig。
func _get_scene_spawn_position(spawn_id: StringName, fallback: Vector2) -> Vector2:
	var value: Variant = spawn_positions.get(spawn_id, fallback)
	if value is Vector2:
		return value

	return fallback


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


# 根据门控状态同步碰撞与正式门贴图，保证可玩和可看状态一致。
func _apply_gate_lock_state() -> void:
	# 碰撞、旧占位颜色和正式门贴图一起更新，确保自动化和人工复核读到同一个门控状态。
	var gate_shape := _get_gate_shape()
	if gate_shape != null:
		gate_shape.disabled = _gate_unlocked

	var gate_visual := _get_gate_visual()
	if gate_visual != null:
		gate_visual.color = Color(0.258824, 0.694118, 0.478431, 1.0) if _gate_unlocked else Color(0.776471, 0.321569, 0.262745, 1.0)

	var gate_art := _get_gate_art()
	if gate_art != null:
		gate_art.texture = SEAL_GATE_OPEN_TEXTURE if _gate_unlocked else SEAL_GATE_LOCKED_TEXTURE
		if str(gate_art.get_meta("asset_id", "")).is_empty():
			gate_art.set_meta("asset_id", "shrine_gate_prop_atlas_ai01")
		gate_art.set_meta("runtime_source", "shrine_gate_prop_atlas_ai01.seal_gate_open" if _gate_unlocked else "shrine_gate_prop_atlas_ai01.seal_gate_locked")

	GateStateVfx.sync_unlock_feedback(get_node_or_null("GateBarrier"), _gate_unlocked)


# 查找可选门控碰撞节点；缺失时房间视为无门默认可通行。
func _get_gate_shape() -> CollisionShape2D:
	# 门控碰撞节点允许缺失；无门房间会被视为默认已解锁。
	return get_node_or_null("GateBarrier/CollisionShape2D") as CollisionShape2D


# 查找可选门控视觉节点；缺失时只保留碰撞状态。
func _get_gate_visual() -> Polygon2D:
	# 门控视觉同样是可选节点，方便早期房间逐步补齐占位资产。
	return get_node_or_null("GateBarrier/BarrierVisual") as Polygon2D


# 查找正式门禁贴图节点；历史房间里命名有 BarrierArt 和 GateArt 两种。
func _get_gate_art() -> Sprite2D:
	var barrier_art := get_node_or_null("GateBarrier/BarrierArt") as Sprite2D
	if barrier_art != null:
		return barrier_art

	return get_node_or_null("GateBarrier/GateArt") as Sprite2D
