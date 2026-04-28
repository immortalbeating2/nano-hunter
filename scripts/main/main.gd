extends Node2D

# Main 负责把当前阶段的房间链路串成真正可玩的主入口。
# 它只管理房间切换、出生点解析、checkpoint 恢复，以及 Room / Player / HUD 的绑定，
# 不负责单个房间内部的教学、战斗或门控细节。

const BASE_VIEWPORT_SIZE := Vector2i(640, 360)
const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")
const TUTORIAL_ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const COMBAT_TRIAL_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const GOAL_TRIAL_ROOM_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const STAGE10_BRANCH_ROOM_PATH := "res://scenes/rooms/stage10_zone_branch_room.tscn"
const STAGE10_CHALLENGE_ROOM_PATH := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const STAGE11_DEMO_END_ROOM_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const STAGE13_ROOM_PREFIX := "res://scenes/rooms/stage13_"
const STAGE14_ROOM_PREFIX := "res://scenes/rooms/stage14_"
const STAGE15_ROOM_PREFIX := "res://scenes/rooms/stage15_"
const STAGE15_COMPLETION_ROOM_PATH := "res://scenes/rooms/stage15_completion_room.tscn"

# 默认输入绑定由 Main 兜底创建，保证独立运行测试或新机器启动时输入契约完整。
const INPUT_BINDINGS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_SPACE, KEY_W, KEY_UP],
	"attack": [KEY_J],
	"dash": [KEY_K],
	"recover": [KEY_L],
}

# 主场景固定节点缓存：Runtime 承载当前玩家，Room 承载当前房间，HUD 只消费快照。
@onready var runtime: Node2D = $Runtime
@onready var fallback_player_spawn: Marker2D = $PlayerSpawn
@onready var tutorial_hud: Control = $HUD/TutorialHUD

# Main 持有跨房间运行期状态；单房间内部状态仍由各房间脚本自己维护。
var room: Node2D
var _current_room_path := TUTORIAL_ROOM_PATH
var _current_spawn_id: StringName = &"tutorial_start"
var _checkpoint_room_path := ""
var _checkpoint_spawn_id: StringName = &""
var _is_short_chain_completed := false
var _is_demo_completed := false
var _air_dash_unlocked := false
var _stage14_backtrack_reward_ids: Dictionary = {}
var _stage15_boss_defeated := false


# 主入口初始化只做一次：窗口基线、默认输入契约和首房间加载。
func _ready() -> void:
	_configure_window_defaults()
	_ensure_default_input_bindings()
	room = get_node_or_null("Room") as Node2D
	_change_room(TUTORIAL_ROOM_PATH, &"tutorial_start")


# 固定窗口最小尺寸，保证灰盒 HUD 与房间构图在桌面运行时不被压得不可读。
func _configure_window_defaults() -> void:
	get_window().min_size = BASE_VIEWPORT_SIZE


# 创建缺失的默认输入动作，保护新机器、测试入口和导入缓存清理后的启动体验。
func _ensure_default_input_bindings() -> void:
	for action_name in INPUT_BINDINGS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		if not InputMap.action_get_events(action_name).is_empty():
			continue

		for keycode: Key in INPUT_BINDINGS[action_name]:
			var event := InputEventKey.new()
			event.keycode = keycode
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name, event)


# 运行时实例装配：每次换房后都重新生成玩家，并把房间和 HUD 绑定到同一份运行时对象上。
func _spawn_placeholder_player(spawn_id: StringName) -> void:
	_clear_runtime()

	var player: CharacterBody2D = PLAYER_PLACEHOLDER_SCENE.instantiate() as CharacterBody2D
	if player == null:
		return

	player.position = _resolve_spawn_position(spawn_id)
	runtime.add_child(player)
	if player.has_signal("defeated"):
		player.defeated.connect(_on_player_defeated)
	_apply_room_camera_limits(player)
	_bind_runtime_dependencies(player)


# 根据当前房间声明的相机边界限制玩家相机，避免换房后看见灰盒外部空间。
func _apply_room_camera_limits(player: CharacterBody2D) -> void:
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return

	if room == null or not room.has_method("get_camera_limits"):
		return

	var camera_limits: Rect2i = room.call("get_camera_limits")
	var room_world_offset := Vector2i(room.global_position.round())
	var world_camera_limits := Rect2i(camera_limits.position + room_world_offset, camera_limits.size)

	camera.limit_enabled = true
	camera.limit_left = world_camera_limits.position.x
	camera.limit_top = world_camera_limits.position.y
	camera.limit_right = world_camera_limits.end.x
	camera.limit_bottom = world_camera_limits.end.y


# 把跨房间状态注入新玩家，并把当前 Room / Player / Main 三方重新挂到 HUD。
func _bind_runtime_dependencies(player: CharacterBody2D) -> void:
	if player.has_method("set_air_dash_unlocked"):
		player.call("set_air_dash_unlocked", _air_dash_unlocked)

	if room != null and room.has_method("bind_player"):
		room.call("bind_player", player)

	if room != null and room.has_method("bind_main"):
		room.call("bind_main", self)

	if tutorial_hud == null:
		return

	if tutorial_hud.has_method("bind_room"):
		tutorial_hud.call("bind_room", room)

	if tutorial_hud.has_method("bind_player"):
		tutorial_hud.call("bind_player", player)

	if tutorial_hud.has_method("bind_main"):
		tutorial_hud.call("bind_main", self)


# 公开给测试与房间脚本使用的最小切房入口。
func transition_to_room(room_path: String, spawn_id: StringName) -> void:
	_change_room(room_path, spawn_id)


# Demo 重开只清理本轮推进状态，保留全局输入和场景结构，方便终点房反复试玩。
func restart_demo() -> void:
	_is_demo_completed = false
	_stage15_boss_defeated = false
	_checkpoint_room_path = ""
	_checkpoint_spawn_id = &""
	_change_room(TUTORIAL_ROOM_PATH, &"tutorial_start")


# 输出主流程稳定快照，供 HUD、GUT 和 MCP 复核读取，不暴露 Main 私有字段。
func get_demo_progress_snapshot() -> Dictionary:
	# 快照是 HUD、测试和 MCP 复核的统一读值入口，不让外部直接依赖 Main 私有字段名。
	return {
		"demo_completed": _is_demo_completed,
		"goal_text": _get_demo_goal_text(),
		"goal_hint_text": _get_demo_goal_hint_text(),
		"replay_available": _is_demo_completed,
		"air_dash_unlocked": _air_dash_unlocked,
		"stage14_backtrack_reward_count": get_stage14_backtrack_reward_count(),
		"stage15_boss_defeated": _stage15_boss_defeated,
		"stage15_recovery_charge_ready": _is_stage15_recovery_charge_ready(),
	}


# 解锁 Stage14 空中冲刺，并立即同步到当前房间里已经生成的玩家实例。
func unlock_air_dash() -> void:
	_air_dash_unlocked = true
	var player := _get_runtime_player()
	if player != null and player.has_method("set_air_dash_unlocked"):
		player.call("set_air_dash_unlocked", true)


# 公开查询空中冲刺是否已进入跨房间主流程状态。
func is_air_dash_unlocked() -> bool:
	return _air_dash_unlocked


# 记录 Stage14 回溯收益，使用 reward_id 去重，防止换房或重复触发刷计数。
func collect_stage14_backtrack_reward(reward_id: StringName) -> void:
	if reward_id == StringName() or _stage14_backtrack_reward_ids.has(reward_id):
		return

	_stage14_backtrack_reward_ids[reward_id] = true


# 返回已确认的 Stage14 回溯收益数量，HUD 和主线测试都依赖这个读值。
func get_stage14_backtrack_reward_count() -> int:
	return _stage14_backtrack_reward_ids.size()


# 标记 Stage15 Boss 已击败；实际胜利房间跳转仍由房间脚本发起。
func mark_stage15_boss_defeated() -> void:
	# Boss 房只报告胜利事件；Main 把它转成 demo 进度快照，供完成房和 HUD 继续读取。
	_stage15_boss_defeated = true


# 公开查询 Stage15 Boss 结果，避免完成房直接读取 Main 私有变量。
func is_stage15_boss_defeated() -> bool:
	return _stage15_boss_defeated


# 房间切换逻辑必须同时覆盖：首次进入、同房间重生，以及真正的场景替换。
func _change_room(room_path: String, spawn_id: StringName) -> void:
	var room_scene: PackedScene = load(room_path) as PackedScene
	if room_scene == null:
		return

	if room == null:
		room = get_node_or_null("Room") as Node2D

	_current_room_path = room_path
	_current_spawn_id = spawn_id

	if room != null and room.scene_file_path == room_path:
		_bind_room_signals()
		_spawn_placeholder_player(spawn_id)
		return

	if room != null:
		remove_child(room)
		room.queue_free()
		room = null

	room = room_scene.instantiate() as Node2D
	if room == null:
		return

	room.name = "Room"
	add_child(room)
	move_child(room, 0)
	_bind_room_signals()
	_spawn_placeholder_player(spawn_id)


# Main 只消费房间约定好的统一信号，不在这里写分房间的硬编码推进逻辑。
func _bind_room_signals() -> void:
	_ensure_room_signal_binding()


# 按房间统一契约安全连接信号，支持同一房间重生时重复调用。
func _ensure_room_signal_binding() -> void:
	if room == null:
		return

	var transition_callback := Callable(self, "_on_room_transition_requested")
	if room.has_signal("room_transition_requested") and not room.is_connected("room_transition_requested", transition_callback):
		room.connect("room_transition_requested", transition_callback)

	var complete_callback := Callable(self, "_on_goal_completed")
	if room.has_signal("goal_completed") and not room.is_connected("goal_completed", complete_callback):
		room.connect("goal_completed", complete_callback)

	var checkpoint_callback := Callable(self, "_on_checkpoint_requested")
	if room.has_signal("checkpoint_requested") and not room.is_connected("checkpoint_requested", checkpoint_callback):
		room.connect("checkpoint_requested", checkpoint_callback)


# 解析房间出生点；房间未实现契约时回落到主场景默认出生点。
func _resolve_spawn_position(spawn_id: StringName) -> Vector2:
	if room != null and room.has_method("get_spawn_position"):
		return room.call("get_spawn_position", spawn_id)

	if fallback_player_spawn != null:
		return fallback_player_spawn.position

	return Vector2.ZERO


# 清空当前运行时子节点，确保换房时不会留下旧玩家、旧 hitbox 或旧信号来源。
func _clear_runtime() -> void:
	for child in runtime.get_children():
		runtime.remove_child(child)
		child.queue_free()


# 失败与 checkpoint 恢复仍保持“最小原型规则”：优先回最近 checkpoint，否则按当前房间的重置策略处理。
func _on_room_transition_requested(target_room_path: String, spawn_id: StringName) -> void:
	if _is_demo_completed and target_room_path == TUTORIAL_ROOM_PATH:
		restart_demo()
		return

	transition_to_room(target_room_path, spawn_id)


# 玩家失败后优先回 checkpoint，没有 checkpoint 时按当前房间的失败规则决定是否重置。
func _on_player_defeated() -> void:
	if not _checkpoint_room_path.is_empty():
		_change_room(_checkpoint_room_path, _checkpoint_spawn_id)
		return

	if room == null:
		return

	if room.has_method("should_reset_on_player_defeat") and room.call("should_reset_on_player_defeat"):
		_change_room(_current_room_path, _current_spawn_id)


# 从 Runtime 容器取当前玩家实例；每次换房都会生成新实例，因此不能长期缓存。
func _get_runtime_player() -> CharacterBody2D:
	return runtime.get_node_or_null("PlayerPlaceholder") as CharacterBody2D


# 把玩家恢复充能 ready 状态转成 Main 快照字段，供 HUD 展示 stage15 战斗容错。
func _is_stage15_recovery_charge_ready() -> bool:
	# Recovery Charge 不由 Main 持久化；快照只转述当前玩家是否已经满充能。
	var player := _get_runtime_player()
	if player == null or not player.has_method("can_spend_recovery_charge"):
		return false

	return bool(player.call("can_spend_recovery_charge"))


# Main 同时记录旧的短链路完成态与新的 demo 完成态，
# 但只有真正进入 stage11 终点房时，才把本轮试玩标记为已完成。
func _on_goal_completed() -> void:
	_is_short_chain_completed = true
	if room != null and room.scene_file_path == STAGE11_DEMO_END_ROOM_PATH:
		_is_demo_completed = true


# 房间请求 checkpoint 时只记录房间路径与出生点，不在 Main 内保存更多房间状态。
func _on_checkpoint_requested(room_path: String, spawn_id: StringName) -> void:
	# checkpoint 仍然只记录运行期最近的恢复点，不扩展成正式存档系统。
	_checkpoint_room_path = room_path
	_checkpoint_spawn_id = spawn_id


# Demo 主链路的目标文案只做“当前处于哪个关键节点”的最小收束，
# 不把它扩成另一层配置系统。
func _get_demo_goal_text() -> String:
	# Stage 13 仍沿用早期灰盒命名；这里先保证玩家目标可读，
	# 后续资产和命名会按总设计北极星逐步回到南北朝镇妖语境。
	if room != null and room.scene_file_path == STAGE15_COMPLETION_ROOM_PATH and _stage15_boss_defeated:
		return "Stage15 已完成：封印守卫已击败，战斗高潮闭环成立"

	if room != null and room.scene_file_path.begins_with(STAGE15_ROOM_PREFIX):
		return "主目标：击败封印守卫并稳定完成战斗高潮"

	if room != null and room.scene_file_path.begins_with(STAGE14_ROOM_PREFIX):
		return "主目标：取得空中二段冲刺并回头打开能力门"

	if room != null and room.scene_file_path.begins_with(STAGE13_ROOM_PREFIX):
		return "主目标：探索生物废液区并抵达第二小区域终点"

	if _is_demo_completed:
		return "Demo 已完成：可向左返回并重开试玩"

	if room == null:
		return "主目标：正在加载 Demo"

	match room.scene_file_path:
		STAGE10_BRANCH_ROOM_PATH:
			return "主目标：带着支路收益返回主线"
		STAGE10_CHALLENGE_ROOM_PATH:
			return "主目标：完成挑战并前往 Demo 终点"
		STAGE11_DEMO_END_ROOM_PATH:
			return "主目标：抵达终点并完成 Demo"
		_:
			return "主目标：继续向右推进并完成 Demo"


# 按当前阶段和房间给 HUD 生成一条短提示，帮助玩家理解当下最关键的操作。
func _get_demo_goal_hint_text() -> String:
	# 提示文案只标注当前房间最可能卡住玩家的点，不在 HUD 里写完整教程。
	if room != null and room.scene_file_path == STAGE15_COMPLETION_ROOM_PATH and _stage15_boss_defeated:
		return "提示：阶段完成反馈已触发，后续可进入 Alpha Demo 打包候选复核"

	if room != null and room.scene_file_path.begins_with(STAGE15_ROOM_PREFIX):
		return "提示：攻击积累恢复充能，满后按 L 恢复 1 点生命"

	if room != null and room.scene_file_path.begins_with(STAGE14_ROOM_PREFIX):
		return "提示：空中按冲刺可越过能力门，落地后恢复一次空中冲刺"

	if room != null and room.scene_file_path.begins_with(STAGE13_ROOM_PREFIX):
		return "提示：留意酸液、孢子投射敌和净化门控"

	if _is_demo_completed:
		return "提示：向左回到重开入口后，可从教程重新开始"

	if room == null:
		return ""

	match room.scene_file_path:
		STAGE10_BRANCH_ROOM_PATH:
			return "提示：支路会给出恢复点与收集收益"
		STAGE10_CHALLENGE_ROOM_PATH:
			return "提示：通过挑战房后，右侧出口会接入终点"
		STAGE11_DEMO_END_ROOM_PATH:
			return "提示：向右抵达终点，完成后可向左返回重开"
		_:
			return ""
