extends Node2D

const BASE_VIEWPORT_SIZE := Vector2i(640, 360)
const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")

@onready var runtime: Node2D = $Runtime
@onready var player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
	_configure_window_defaults()
	_spawn_placeholder_player()


func _configure_window_defaults() -> void:
	get_window().min_size = BASE_VIEWPORT_SIZE


func _spawn_placeholder_player() -> void:
	if runtime.get_child_count() > 0:
		return

	var player: CharacterBody2D = PLAYER_PLACEHOLDER_SCENE.instantiate() as CharacterBody2D

	if player == null:
		return

	player.position = player_spawn.position
	runtime.add_child(player)
