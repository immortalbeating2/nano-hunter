extends GutTest


func test_project_points_to_a_loadable_stage_1_main_scene() -> void:
	var main_scene_path: String = ProjectSettings.get_setting("application/run/main_scene", "")

	assert_eq(main_scene_path, "res://scenes/main/main.tscn")

	var packed_scene: PackedScene = load(main_scene_path) as PackedScene
	assert_not_null(packed_scene)

	var main_scene: Node = packed_scene.instantiate()
	add_child_autofree(main_scene)
	assert_not_null(main_scene)
	assert_true(main_scene is Node2D)

	assert_eq(main_scene.name, "Main")

	var runtime: Node2D = main_scene.get_node_or_null("Runtime") as Node2D
	var player_spawn: Marker2D = main_scene.get_node_or_null("PlayerSpawn") as Marker2D

	assert_not_null(runtime)
	assert_not_null(player_spawn)
	assert_eq(player_spawn.position, Vector2(-320, 96))


func test_main_scene_spawns_placeholder_player_at_spawn_point() -> void:
	var packed_scene: PackedScene = load("res://scenes/main/main.tscn") as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node = packed_scene.instantiate()
	add_child_autofree(main_scene)

	var runtime: Node2D = main_scene.get_node_or_null("Runtime") as Node2D
	var player_spawn: Marker2D = main_scene.get_node_or_null("PlayerSpawn") as Marker2D

	assert_not_null(runtime)
	assert_not_null(player_spawn)
	assert_eq(runtime.get_child_count(), 1)

	var placeholder_player: CharacterBody2D = runtime.get_child(0) as CharacterBody2D

	assert_not_null(placeholder_player)
	assert_eq(placeholder_player.position, player_spawn.position)

	main_scene.free()


func test_test_room_scene_has_required_boundary_nodes() -> void:
	var packed_scene: PackedScene = load("res://scenes/rooms/test_room.tscn") as PackedScene

	assert_not_null(packed_scene)

	var test_room: Node = packed_scene.instantiate()

	assert_not_null(test_room.get_node_or_null("Backdrop"))
	assert_not_null(test_room.get_node_or_null("Floor"))
	assert_not_null(test_room.get_node_or_null("LeftWall"))
	assert_not_null(test_room.get_node_or_null("RightWall"))

	test_room.free()


func test_main_scene_instances_test_room() -> void:
	var packed_scene: PackedScene = load("res://scenes/main/main.tscn") as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node = packed_scene.instantiate()
	add_child_autofree(main_scene)

	assert_not_null(main_scene.get_node_or_null("TestRoom"))


func test_placeholder_player_scene_has_required_nodes() -> void:
	var packed_scene: PackedScene = load("res://scenes/player/player_placeholder.tscn") as PackedScene

	assert_not_null(packed_scene)

	var player_scene: Node = packed_scene.instantiate()

	assert_true(player_scene is CharacterBody2D)
	assert_true(player_scene.get_node_or_null("Body") is Polygon2D)
	assert_not_null(player_scene.get_node_or_null("CollisionShape2D") as CollisionShape2D)
	var camera: Camera2D = player_scene.get_node_or_null("Camera2D") as Camera2D
	assert_not_null(camera)
	assert_true(camera.enabled)

	player_scene.free()
