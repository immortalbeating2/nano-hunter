# 44 房可踩面运行态复核：以统一总览相机捕获真实 PhysicsServer debug-collision 叠层。
extends SceneTree

const WORLD_MAP_PATH := "res://assets/configs/world_map/alpha_demo_world_map.json"
const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const OUT_DIR := "res://tests/artifacts/local/runtime-visual-integrity/collision-debug"
const SCREENSHOT_DIR := "%s/screenshots" % OUT_DIR
const OUT_REPORT := "%s/walkable_surface_runtime_report.json" % OUT_DIR
const EXPECTED_ROOM_COUNT := 44
const VIEWPORT_SIZE := Vector2i(1280, 720)
const CAPTURE_MARGIN := Vector2(56.0, 40.0)
const MIN_CAMERA_ZOOM := 0.35
const MAX_CAMERA_ZOOM := 1.0

var _main: Node2D
var _audit_camera: Camera2D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = VIEWPORT_SIZE
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))
	var world_map: Dictionary = _load_world_map()
	var room_specs: Array = world_map.get("rooms", [])
	if room_specs.size() != EXPECTED_ROOM_COUNT:
		push_error("World map room count %d != %d" % [room_specs.size(), EXPECTED_ROOM_COUNT])
		quit(1)
		return

	var packed := load(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Cannot load Main: %s" % MAIN_SCENE_PATH)
		quit(1)
		return
	_main = packed.instantiate() as Node2D
	root.add_child(_main)
	await _wait_process_frames(4)
	if _main.has_method("start_demo"):
		_main.call("start_demo")
	await _wait_physics_frames(12)
	_hide_hud()
	_create_audit_camera()

	var rooms: Array[Dictionary] = []
	var all_ok := true
	for spec: Dictionary in room_specs:
		var room_result := await _capture_room(spec)
		rooms.append(room_result)
		all_ok = all_ok and bool(room_result.get("ok", false))

	var report := {
		"review_id": "walkable_surface_runtime_debug_collision",
		"generated_at": Time.get_datetime_string_from_system(true),
		"capture_command": "godot --path . --debug-collisions -s scripts/dev/capture_walkable_surface_2d_review.gd",
		"display_server": DisplayServer.get_name(),
		"viewport_size": [VIEWPORT_SIZE.x, VIEWPORT_SIZE.y],
		"room_count": rooms.size(),
		"captured_count": _count_captured(rooms),
		"ok": all_ok and rooms.size() == EXPECTED_ROOM_COUNT and _count_captured(rooms) == EXPECTED_ROOM_COUNT,
		"rooms": rooms,
		"boundary": "逐房真实运行态 debug-collision 总览截图与权威节点结构证据；不替代真人路线手感与美术签核。",
	}
	_write_json(OUT_REPORT, report)
	print(
		"walkable_surface_runtime_review rooms=%d captured=%d ok=%s report=%s"
		% [rooms.size(), report["captured_count"], report["ok"], OUT_REPORT]
	)
	_main.queue_free()
	await process_frame
	quit(0 if bool(report["ok"]) else 1)


func _capture_room(spec: Dictionary) -> Dictionary:
	var room_id := str(spec.get("id", "unknown"))
	var room_path := str(spec.get("path", ""))
	_main.call("transition_to_room", room_path, &"")
	await _wait_physics_frames(8)
	await _wait_process_frames(3)
	_hide_hud()

	var room := _main.get_node_or_null("Room") as Node2D
	var limits := _room_limits(room)
	_frame_room(limits)
	await _wait_process_frames(3)

	var screenshot_path := "%s/room_%s.png" % [SCREENSHOT_DIR, room_id.to_lower()]
	var screenshot_status := "unavailable_in_headless_display"
	var screenshot_sha256 := ""
	if DisplayServer.get_name() != "headless":
		var image := root.get_texture().get_image()
		if image != null and not image.is_empty() and image.save_png(screenshot_path) == OK:
			screenshot_status = "captured"
			screenshot_sha256 = FileAccess.get_sha256(ProjectSettings.globalize_path(screenshot_path))

	var authority := _inspect_collision_authority(room)
	var camera_current := root.get_camera_2d() == _audit_camera
	var ok := (
		room != null
		and screenshot_status == "captured"
		and not screenshot_sha256.is_empty()
		and camera_current
		and bool(authority.get("ok", false))
	)
	print(
		"room=%s path=%s capture=%s authority=%s camera=%s"
		% [room_id, room_path, screenshot_status, authority.get("kind", "missing"), camera_current]
	)
	return {
		"id": room_id,
		"title": str(spec.get("title", "")),
		"path": room_path,
		"region": str(spec.get("region", "")),
		"camera_limits": _rect_to_report(limits),
		"camera_zoom": [_audit_camera.zoom.x, _audit_camera.zoom.y],
		"camera_current": camera_current,
		"screenshot": screenshot_path,
		"screenshot_status": screenshot_status,
		"screenshot_sha256": screenshot_sha256,
		"collision_authority": authority,
		"ok": ok,
	}


func _inspect_collision_authority(room: Node2D) -> Dictionary:
	if room == null:
		return {"kind": "missing_room", "ok": false}
	var terrain := room.get_node_or_null("TerrainCollisionVisual") as TileMapLayer
	var platform := room.get_node_or_null("PlatformCollisionVisual") as TileMapLayer
	if terrain != null or platform != null:
		var unexpected := _unexpected_collision_tilemaps(room, terrain, platform)
		return {
			"kind": "formal_tilemap",
			"terrain_present": terrain != null,
			"terrain_collision_enabled": terrain != null and bool(terrain.get("collision_enabled")),
			"terrain_visible": terrain != null and terrain.visible,
			"terrain_cell_count": terrain.get_used_cells().size() if terrain != null else 0,
			"platform_present": platform != null,
			"platform_collision_enabled": platform != null and bool(platform.get("collision_enabled")),
			"platform_visible": platform != null and platform.visible,
			"platform_cell_count": platform.get_used_cells().size() if platform != null else 0,
			"unexpected_collision_tilemaps": unexpected,
			"ok": (
				terrain != null
				and platform != null
				and bool(terrain.get("collision_enabled"))
				and bool(platform.get("collision_enabled"))
				and not terrain.visible
				and not platform.visible
				and unexpected.is_empty()
			),
		}

	var floor_body := room.get_node_or_null("Floor") as StaticBody2D
	var floor_shape := room.get_node_or_null("Floor/CollisionShape2D") as CollisionShape2D
	return {
		"kind": "static_floor",
		"floor_present": floor_body != null,
		"floor_layer": floor_body.collision_layer if floor_body != null else 0,
		"floor_mask": floor_body.collision_mask if floor_body != null else 0,
		"floor_shape_enabled": floor_shape != null and not floor_shape.disabled,
		"ok": (
			floor_body != null
			and floor_shape != null
			and not floor_shape.disabled
			and floor_body.collision_layer != 0
		),
	}


func _unexpected_collision_tilemaps(
	room: Node,
	terrain: TileMapLayer,
	platform: TileMapLayer,
) -> Array[String]:
	var result: Array[String] = []
	var stack: Array[Node] = [room]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is TileMapLayer and bool(node.get("collision_enabled")) and node != terrain and node != platform:
			result.append(str(room.get_path_to(node)))
		for child: Node in node.get_children():
			stack.append(child)
	return result


func _create_audit_camera() -> void:
	_audit_camera = Camera2D.new()
	_audit_camera.name = "WalkableSurfaceAuditCamera"
	_audit_camera.position_smoothing_enabled = false
	_audit_camera.enabled = true
	_main.add_child(_audit_camera)
	_audit_camera.make_current()


func _frame_room(limits: Rect2) -> void:
	var usable_size := Vector2(VIEWPORT_SIZE) - CAPTURE_MARGIN * 2.0
	var safe_size := Vector2(maxf(limits.size.x, 1.0), maxf(limits.size.y, 1.0))
	var fit_zoom := minf(usable_size.x / safe_size.x, usable_size.y / safe_size.y)
	fit_zoom = clampf(fit_zoom, MIN_CAMERA_ZOOM, MAX_CAMERA_ZOOM)
	_audit_camera.global_position = limits.get_center()
	_audit_camera.zoom = Vector2.ONE * fit_zoom
	_audit_camera.make_current()


func _room_limits(room: Node2D) -> Rect2:
	if room != null and room.has_method("get_camera_limits"):
		var limits: Rect2i = room.call("get_camera_limits")
		return Rect2(limits)
	return Rect2(Vector2(-640.0, -360.0), Vector2(VIEWPORT_SIZE))


func _hide_hud() -> void:
	var hud := _main.get_node_or_null("HUD") as CanvasLayer
	if hud != null:
		hud.visible = false


func _load_world_map() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WORLD_MAP_PATH))
	return parsed as Dictionary if parsed is Dictionary else {}


func _count_captured(rooms: Array[Dictionary]) -> int:
	var count := 0
	for room: Dictionary in rooms:
		if room.get("screenshot_status", "") == "captured":
			count += 1
	return count


func _rect_to_report(rect: Rect2) -> Dictionary:
	return {
		"left": rect.position.x,
		"top": rect.position.y,
		"right": rect.end.x,
		"bottom": rect.end.y,
		"width": rect.size.x,
		"height": rect.size.y,
	}


func _wait_process_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _wait_physics_frames(count: int) -> void:
	for _frame: int in range(count):
		await physics_frame


func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write report: %s" % path)
		return
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
