extends Node2D

const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")

@onready var runtime: Node2D = $Runtime
@onready var player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
	_spawn_placeholder_player()


func _spawn_placeholder_player() -> void:
	var player: CharacterBody2D = PLAYER_PLACEHOLDER_SCENE.instantiate() as CharacterBody2D

	if player == null:
		return

	player.position = player_spawn.position
	runtime.add_child(player)
