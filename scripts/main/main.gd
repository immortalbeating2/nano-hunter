extends Node2D

const BASE_VIEWPORT_SIZE := Vector2i(640, 360)
const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")

@onready var test_room: Node2D = $TestRoom
@onready var runtime: Node2D = $Runtime
@onready var player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
	_configure_window_defaults()
	_spawn_placeholder_player()


func _configure_window_defaults() -> void:
	get_window().min_size = BASE_VIEWPORT_SIZE


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

	camera.limit_enabled = true
	camera.limit_left = camera_limits.position.x
	camera.limit_top = camera_limits.position.y
	camera.limit_right = camera_limits.end.x
	camera.limit_bottom = camera_limits.end.y
