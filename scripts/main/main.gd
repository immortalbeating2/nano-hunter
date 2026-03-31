extends Node2D

@onready var runtime: Node = $Runtime
@onready var player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
	_spawn_placeholder_player()


func _spawn_placeholder_player() -> void:
	var player_scene: PackedScene = preload("res://scenes/player/player_placeholder.tscn")
	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D

	if player == null:
		return

	runtime.add_child(player)
	player.position = player_spawn.position
