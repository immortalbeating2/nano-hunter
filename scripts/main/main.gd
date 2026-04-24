extends Node2D

# Main 负责把当前阶段的房间链路串成实际可玩的主入口。
# 它只管理房间切换、出生点解析、checkpoint 恢复，以及 Room / Player / HUD 的绑定，
# 不负责单个房间内部的教学、战斗或门控细节。

const BASE_VIEWPORT_SIZE := Vector2i(640, 360)
const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")
const TUTORIAL_ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const COMBAT_TRIAL_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const GOAL_TRIAL_ROOM_PATH := "res://scenes/rooms/goal_trial_room.tscn"

const INPUT_BINDINGS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_SPACE, KEY_W, KEY_UP],
	"attack": [KEY_J],
	"dash": [KEY_K],
}

@onready var runtime: Node2D = $Runtime
@onready var fallback_player_spawn: Marker2D = $PlayerSpawn
@onready var tutorial_hud: Control = $HUD/TutorialHUD

var room: Node2D
var _current_room_path := TUTORIAL_ROOM_PATH
var _current_spawn_id: StringName = &"tutorial_start"
var _checkpoint_room_path := ""
var _checkpoint_spawn_id: StringName = &""
var _is_short_chain_completed := false


# 主入口初始化只做一次：窗口基线、默认输入契约和首房间加载。
func _ready() -> void:
	_configure_window_defaults()
	_ensure_default_input_bindings()
	room = get_node_or_null("Room") as Node2D
	_change_room(TUTORIAL_ROOM_PATH, &"tutorial_start")


func _configure_window_defaults() -> void:
	get_window().min_size = BASE_VIEWPORT_SIZE


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


func _bind_runtime_dependencies(player: CharacterBody2D) -> void:
	if room != null and room.has_method("bind_player"):
		room.call("bind_player", player)

	if tutorial_hud == null:
		return

	if tutorial_hud.has_method("bind_room"):
		tutorial_hud.call("bind_room", room)

	if tutorial_hud.has_method("bind_player"):
		tutorial_hud.call("bind_player", player)


# 公开给测试与房间脚本使用的最小切房入口。
func transition_to_room(room_path: String, spawn_id: StringName) -> void:
	_change_room(room_path, spawn_id)


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


func _resolve_spawn_position(spawn_id: StringName) -> Vector2:
	if room != null and room.has_method("get_spawn_position"):
		return room.call("get_spawn_position", spawn_id)

	if fallback_player_spawn != null:
		return fallback_player_spawn.position

	return Vector2.ZERO


func _clear_runtime() -> void:
	for child in runtime.get_children():
		runtime.remove_child(child)
		child.queue_free()


# 失败与 checkpoint 恢复仍保持“最小原型规则”：优先回最近 checkpoint，否则按当前房间的重置策略处理。
func _on_room_transition_requested(target_room_path: String, spawn_id: StringName) -> void:
	transition_to_room(target_room_path, spawn_id)


func _on_player_defeated() -> void:
	if not _checkpoint_room_path.is_empty():
		_change_room(_checkpoint_room_path, _checkpoint_spawn_id)
		return

	if room == null:
		return

	if room.has_method("should_reset_on_player_defeat") and room.call("should_reset_on_player_defeat"):
		_change_room(_current_room_path, _current_spawn_id)


func _get_runtime_player() -> CharacterBody2D:
	return runtime.get_node_or_null("PlayerPlaceholder") as CharacterBody2D


func _on_goal_completed() -> void:
	# 阶段 7 只在 Main 层记录“短链路已经完成”这个事实，
	# 更具体的完成表现继续交给目标房与 HUD 负责。
	_is_short_chain_completed = true


func _on_checkpoint_requested(room_path: String, spawn_id: StringName) -> void:
	# Stage 9 之后的 checkpoint 只记录运行期最近的区域恢复点，
	# 这里故意不扩展成正式存档系统。
	_checkpoint_room_path = room_path
	_checkpoint_spawn_id = spawn_id
