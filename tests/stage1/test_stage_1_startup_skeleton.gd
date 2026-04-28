extends GutTest

# 阶段 1 回归测试保护项目启动骨架、主入口、占位玩家与基础房间契约。
# 后续重构 Main、Room、Camera 或基础场景结构时，至少要继续满足这里的启动基线。


# 保护基础显示配置：首屏分辨率、整数缩放和清屏色是后续所有视觉复核的共同前提。
func test_project_uses_stage_1_display_scaling_defaults() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width", 0), 640)
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_height", 0), 360)
	assert_eq(ProjectSettings.get_setting("display/window/size/window_width_override", 0), 1280)
	assert_eq(ProjectSettings.get_setting("display/window/size/window_height_override", 0), 720)
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode", ""), "viewport")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/aspect", ""), "keep")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/scale_mode", ""), "integer")
	assert_eq(
		ProjectSettings.get_setting(
			"rendering/environment/defaults/default_clear_color",
			Color(0.3, 0.3, 0.3, 1)
		),
		Color(0.0745098, 0.129412, 0.219608, 1)
	)


# 保护窗口最小尺寸：Main 实例化后必须把窗口限制到基础 viewport，避免缩得比灰盒视野还小。
func test_main_scene_sets_window_minimum_size_to_base_viewport() -> void:
	var previous_min_size: Vector2i = get_window().min_size
	var packed_scene: PackedScene = load("res://scenes/main/main.tscn") as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node = packed_scene.instantiate()
	add_child_autofree(main_scene)
	await get_tree().process_frame

	assert_eq(get_window().min_size, Vector2i(640, 360))

	get_window().min_size = previous_min_size


# 保护项目主入口：project.godot 必须指向可加载的 Main 场景，并包含 Runtime、Room、Spawn 三个基础节点。
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
	var room: Node2D = main_scene.get_node_or_null("Room") as Node2D
	var player_spawn: Marker2D = main_scene.get_node_or_null("PlayerSpawn") as Marker2D

	assert_not_null(runtime)
	assert_not_null(room)
	assert_not_null(player_spawn)
	assert_eq(player_spawn.position, Vector2(-320, 96))


# 保护玩家出生契约：Main 加载后只能生成一个占位玩家，并放在 PlayerSpawn 标记点。
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


# 保护测试房灰盒边界：早期移动和战斗测试依赖地板、左右墙和背景节点稳定存在。
func test_test_room_scene_has_required_boundary_nodes() -> void:
	var packed_scene: PackedScene = load("res://scenes/rooms/test_room.tscn") as PackedScene

	assert_not_null(packed_scene)

	var test_room: Node = packed_scene.instantiate()
	add_child_autofree(test_room)

	assert_true(test_room.get_node_or_null("Backdrop") is Polygon2D)
	var floor: StaticBody2D = test_room.get_node_or_null("Floor") as StaticBody2D
	var left_wall: StaticBody2D = test_room.get_node_or_null("LeftWall") as StaticBody2D
	var right_wall: StaticBody2D = test_room.get_node_or_null("RightWall") as StaticBody2D

	assert_not_null(floor)
	assert_not_null(left_wall)
	assert_not_null(right_wall)
	assert_not_null(floor.get_node_or_null("CollisionShape2D") as CollisionShape2D)
	assert_not_null(left_wall.get_node_or_null("CollisionShape2D") as CollisionShape2D)
	assert_not_null(right_wall.get_node_or_null("CollisionShape2D") as CollisionShape2D)


# 保护 Main 房间契约：默认房间必须暴露相机边界接口，并保留可读背景。
func test_main_scene_instances_main_room_contract() -> void:
	var packed_scene: PackedScene = load("res://scenes/main/main.tscn") as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node = packed_scene.instantiate()
	add_child_autofree(main_scene)

	var room: Node2D = main_scene.get_node_or_null("Room") as Node2D

	assert_not_null(room)
	assert_true(room.has_method("get_camera_limits"))
	assert_true(room.get_node_or_null("Backdrop") is Polygon2D)


# 保护测试房相机边界：早期自动化使用该矩形确认玩家和房间都在可见范围内。
func test_test_room_exposes_stage_1_camera_limits() -> void:
	var packed_scene: PackedScene = load("res://scenes/rooms/test_room.tscn") as PackedScene

	assert_not_null(packed_scene)

	var test_room: Node = packed_scene.instantiate()
	add_child_autofree(test_room)

	assert_true(test_room.has_method("get_camera_limits"))

	var camera_limits: Rect2i = test_room.call("get_camera_limits")

	assert_eq(camera_limits, Rect2i(-512, -192, 1024, 384))


# 保护相机应用流程：Main 必须把房间局部 camera limits 写入玩家 Camera2D。
func test_main_scene_applies_main_room_camera_limits_to_placeholder_camera() -> void:
	var packed_scene: PackedScene = load("res://scenes/main/main.tscn") as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node = packed_scene.instantiate()
	add_child_autofree(main_scene)
	await get_tree().process_frame

	var runtime: Node2D = main_scene.get_node_or_null("Runtime") as Node2D
	var room: Node2D = main_scene.get_node_or_null("Room") as Node2D

	assert_not_null(runtime)
	assert_not_null(room)
	assert_eq(runtime.get_child_count(), 1)

	var player: CharacterBody2D = runtime.get_child(0) as CharacterBody2D

	assert_not_null(player)

	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D

	assert_not_null(camera)
	assert_true(camera.limit_enabled)
	var camera_limits: Rect2i = room.call("get_camera_limits")
	assert_eq(camera.limit_left, camera_limits.position.x)
	assert_eq(camera.limit_top, camera_limits.position.y)
	assert_eq(camera.limit_right, camera_limits.end.x)
	assert_eq(camera.limit_bottom, camera_limits.end.y)


# 保护房间平移后的相机换算：房间局部边界必须转换成世界坐标再写给 Camera2D。
func test_main_scene_offsets_camera_limits_when_main_room_is_translated() -> void:
	var packed_scene: PackedScene = load("res://scenes/main/main.tscn") as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node = packed_scene.instantiate()
	var room: Node2D = main_scene.get_node_or_null("Room") as Node2D

	assert_not_null(room)

	room.position = Vector2(64, 32)
	add_child_autofree(main_scene)
	await get_tree().process_frame

	var runtime: Node2D = main_scene.get_node_or_null("Runtime") as Node2D

	assert_not_null(runtime)
	assert_eq(runtime.get_child_count(), 1)

	var player: CharacterBody2D = runtime.get_child(0) as CharacterBody2D

	assert_not_null(player)

	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D

	assert_not_null(camera)
	assert_true(camera.limit_enabled)
	var camera_limits: Rect2i = room.call("get_camera_limits")
	var world_camera_limits := Rect2i(camera_limits.position + Vector2i(64, 32), camera_limits.size)
	assert_eq(camera.limit_left, world_camera_limits.position.x)
	assert_eq(camera.limit_top, world_camera_limits.position.y)
	assert_eq(camera.limit_right, world_camera_limits.end.x)
	assert_eq(camera.limit_bottom, world_camera_limits.end.y)


# 保护占位玩家场景结构：后续玩家控制和相机测试都依赖 Body、CollisionShape2D 和 Camera2D。
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
