extends SceneTree

# 正式地图 Batch 1 三房运行态复核。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const TEST_ROOM_PATH := "res://scenes/rooms/test_room.tscn"
const COMBAT_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const GOAL_ROOM_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const OUT_DIR := "res://tests/artifacts/local/formal-map-batch1-review"
const OUT_TEST := "%s/01_test_room_dash_sandbox.png" % OUT_DIR
const OUT_COMBAT_LOCKED := "%s/02_combat_trial_locked.png" % OUT_DIR
const OUT_COMBAT_OPEN := "%s/03_combat_trial_open.png" % OUT_DIR
const OUT_GOAL_LOCKED := "%s/04_goal_trial_locked.png" % OUT_DIR
const OUT_GOAL_ROUTE := "%s/05_goal_trial_elevated_route.png" % OUT_DIR
const OUT_REPORT := "%s/formal_map_batch1_review.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(1280, 720)
const PLAYER_HALF_HEIGHT := 20.0
const GROUND_CENTER_ALPHA_TOP_Y := 39.0


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var result := await _capture()
	quit(result)


func _capture() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	root.size = VIEWPORT_SIZE
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		return 1
	var main := packed.instantiate() as Node2D
	root.add_child(main)
	await _wait_process_frames(4)
	_hide_demo_shell(main)

	var test_started := await _start_room(main, TEST_ROOM_PATH, &"")
	var test_room := main.get_node_or_null("Room") as Node2D
	var test_ok := test_started and test_room != null and _test_room_ok(test_room)
	await _wait_process_frames(8)
	var test_save_ok := _save_screenshot(OUT_TEST)

	var combat_started := await _start_room(main, COMBAT_ROOM_PATH, &"combat_entry")
	var combat_room := main.get_node_or_null("Room") as Node2D
	var player := main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var combat_surface := combat_room.get_node_or_null("GroundSurfaceVisual") as TileMapLayer if combat_room != null else null
	var combat_entry_ok := (
		combat_started
		and combat_room != null
		and player != null
		and player.is_on_floor()
		and not bool(combat_room.call("is_exit_unlocked"))
		and _player_matches_surface(player, combat_surface, Vector2i(-4, 2), 160.0)
	)
	await _wait_process_frames(8)
	var combat_locked_save_ok := _save_screenshot(OUT_COMBAT_LOCKED)
	var combat_enemy := combat_room.get_node_or_null("BasicMeleeEnemy") if combat_room != null else null
	if combat_enemy != null:
		combat_enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _wait_process_frames(5)
	player.global_position = Vector2(576.0, 140.0)
	player.velocity = Vector2.ZERO
	await _wait_physics_frames(24)
	var combat_open_ok := bool(combat_room.call("is_exit_unlocked")) and player.is_on_floor()
	await _wait_process_frames(8)
	var combat_open_save_ok := _save_screenshot(OUT_COMBAT_OPEN)

	var goal_started := await _start_room(main, GOAL_ROOM_PATH, &"goal_entry")
	var goal_room := main.get_node_or_null("Room") as Node2D
	player = main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var goal_surface := goal_room.get_node_or_null("GroundSurfaceVisual") as TileMapLayer if goal_room != null else null
	var goal_entry_ok := (
		goal_started
		and goal_room != null
		and player != null
		and player.is_on_floor()
		and not bool(goal_room.call("is_goal_unlocked"))
		and _player_matches_surface(player, goal_surface, Vector2i(-4, 3), 224.0)
	)
	await _wait_process_frames(8)
	var goal_locked_save_ok := _save_screenshot(OUT_GOAL_LOCKED)
	var goal_enemy := goal_room.get_node_or_null("BasicMeleeEnemy") if goal_room != null else null
	if goal_enemy != null:
		goal_enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _wait_process_frames(4)
	player.global_position = Vector2(800.0, 204.0)
	player.velocity = Vector2.ZERO
	await _wait_process_frames(4)
	var floor_does_not_complete := main.get_node_or_null("Room") == goal_room
	player.global_position = Vector2(704.0, 124.0)
	player.velocity = Vector2.ZERO
	await _wait_physics_frames(40)
	var elevated_route_ok := (
		main.get_node_or_null("Room") == goal_room
		and bool(goal_room.call("is_goal_unlocked"))
		and player.is_on_floor()
		and absf(player.global_position.y + PLAYER_HALF_HEIGHT - 144.0) <= 0.5
	)
	await _wait_process_frames(8)
	var goal_route_save_ok := _save_screenshot(OUT_GOAL_ROUTE)

	var ok := (
		test_ok
		and combat_entry_ok
		and combat_open_ok
		and goal_entry_ok
		and floor_does_not_complete
		and elevated_route_ok
		and test_save_ok
		and combat_locked_save_ok
		and combat_open_save_ok
		and goal_locked_save_ok
		and goal_route_save_ok
	)
	_write_json(OUT_REPORT, {
		"ok": ok,
		"review_id": "formal_map_batch1_review",
		"test_room_ok": test_ok,
		"combat_entry_ok": combat_entry_ok,
		"combat_open_ok": combat_open_ok,
		"goal_entry_ok": goal_entry_ok,
		"goal_floor_does_not_complete": floor_does_not_complete,
		"goal_elevated_route_ok": elevated_route_ok,
		"images": [OUT_TEST, OUT_COMBAT_LOCKED, OUT_COMBAT_OPEN, OUT_GOAL_LOCKED, OUT_GOAL_ROUTE],
		"display_server": DisplayServer.get_name(),
	})
	main.queue_free()
	return 0 if ok else 1


func _start_room(main: Node, path: String, spawn_id: StringName) -> bool:
	var started := bool(main.call("start_demo_at_room", path, spawn_id, {}))
	await _wait_process_frames(6)
	await _wait_physics_frames(50)
	_hide_demo_shell(main)
	return started


func _test_room_ok(room: Node2D) -> bool:
	var background := room.get_node_or_null("DemoBackgroundArt") as Sprite2D
	if background == null or background.position != Vector2.ZERO or background.scale != Vector2(0.62, 0.62):
		return false
	for layer_name: String in ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		if layer == null or layer.visible or bool(layer.get("collision_enabled")):
			return false
	for path: String in ["Floor/FloorVisual", "FloorRight/FloorVisual", "MidPlatform/PlatformVisual", "DashGapLeft/PlatformVisual", "DashGapRight/PlatformVisual", "DashGateCeiling/CeilingVisual"]:
		var visual := room.get_node_or_null(path) as Polygon2D
		if visual == null or not visual.visible or visual.color.a < 0.24:
			return false
	return true


func _player_matches_surface(player: CharacterBody2D, surface: TileMapLayer, cell: Vector2i, expected_top: float) -> bool:
	if surface == null:
		return false
	var center_global := surface.to_global(surface.map_to_local(cell))
	var visible_top := center_global.y - 32.0 + GROUND_CENTER_ALPHA_TOP_Y
	return absf(player.global_position.y + PLAYER_HALF_HEIGHT - visible_top) <= 0.5 and absf(visible_top - expected_top) <= 0.5


func _hide_demo_shell(main: Node) -> void:
	var shell := main.get_node_or_null("HUD/DemoShell")
	if shell == null:
		return
	for path: NodePath in ["MainMenu", "TitleBackground"]:
		var item := shell.get_node_or_null(path) as CanvasItem
		if item != null:
			item.visible = false


func _wait_process_frames(count: int) -> void:
	for _i: int in range(count):
		await process_frame


func _wait_physics_frames(count: int) -> void:
	for _i: int in range(count):
		await physics_frame


func _save_screenshot(path: String) -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	var image := root.get_texture().get_image()
	return image != null and not image.is_empty() and image.save_png(path) == OK


func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t", false) + "\n")
