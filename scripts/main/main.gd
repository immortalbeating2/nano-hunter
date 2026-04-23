extends Node2D

const BASE_VIEWPORT_SIZE := Vector2i(640, 360)
const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")
const TUTORIAL_ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const COMBAT_TRIAL_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"

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


func _ready() -> void:
	_configure_window_defaults()
	_ensure_default_input_bindings()
	room = get_node_or_null("Room") as Node2D
	_change_room(TUTORIAL_ROOM_PATH, &"tutorial_start")


func _process(_delta: float) -> void:
	_ensure_room_signal_binding()
	if _should_enter_combat_trial():
		_change_room(COMBAT_TRIAL_ROOM_PATH, &"combat_entry")


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


func transition_to_room(room_path: String, spawn_id: StringName) -> void:
	_change_room(room_path, spawn_id)


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


func _bind_room_signals() -> void:
	_ensure_room_signal_binding()


func _ensure_room_signal_binding() -> void:
	if room == null:
		return

	var callback := Callable(self, "_on_room_transition_requested")
	if room.scene_file_path == TUTORIAL_ROOM_PATH and not room.is_connected("room_transition_requested", callback):
		room.connect("room_transition_requested", Callable(self, "_on_room_transition_requested"))


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


func _on_room_transition_requested(target_room_path: String, spawn_id: StringName) -> void:
	transition_to_room(target_room_path, spawn_id)


func _on_player_defeated() -> void:
	if room == null:
		return

	if room.has_method("should_reset_on_player_defeat") and room.call("should_reset_on_player_defeat"):
		_change_room(_current_room_path, _current_spawn_id)


func _should_enter_combat_trial() -> bool:
	if _current_room_path != TUTORIAL_ROOM_PATH or room == null:
		return false

	var player := _get_runtime_player()
	if player == null:
		return false

	if room.has_method("get_current_step_id") and room.call("get_current_step_id") == &"complete":
		return true

	var tutorial_dummy: Node = room.get_node_or_null("TutorialDummy")
	if tutorial_dummy == null:
		return false

	return tutorial_dummy.get("hit_count") > 0 and player.global_position.x >= 796.0


func _get_runtime_player() -> CharacterBody2D:
	return runtime.get_node_or_null("PlayerPlaceholder") as CharacterBody2D
