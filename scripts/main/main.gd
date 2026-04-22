extends Node2D

const BASE_VIEWPORT_SIZE := Vector2i(640, 360)
const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")

const INPUT_BINDINGS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_SPACE, KEY_W, KEY_UP],
	"dash": [KEY_K],
}

@onready var test_room: Node2D = $TestRoom
@onready var runtime: Node2D = $Runtime
@onready var player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
	_configure_window_defaults()
	_ensure_default_input_bindings()
	_spawn_placeholder_player()


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


func _spawn_placeholder_player() -> void:
	var player: CharacterBody2D = PLAYER_PLACEHOLDER_SCENE.instantiate() as CharacterBody2D

	if player == null:
		return

	player.position = player_spawn.position
	_apply_test_room_camera_limits(player)
	runtime.add_child(player)


func _apply_test_room_camera_limits(player: CharacterBody2D) -> void:
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D

	if camera == null:
		return

	if test_room == null or not test_room.has_method("get_camera_limits"):
		return

	var camera_limits: Rect2i = test_room.call("get_camera_limits")
	var room_world_offset := Vector2i(test_room.global_position.round())
	var world_camera_limits := Rect2i(camera_limits.position + room_world_offset, camera_limits.size)

	camera.limit_enabled = true
	camera.limit_left = world_camera_limits.position.x
	camera.limit_top = world_camera_limits.position.y
	camera.limit_right = world_camera_limits.end.x
	camera.limit_bottom = world_camera_limits.end.y
