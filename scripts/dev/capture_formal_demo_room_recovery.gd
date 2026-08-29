extends SceneTree

# 方案 B 正式 18 房自动证据捕获。
# 每房保存入口、核心玩法区和出口三个视角；截图与结构报告只用于诊断，不替代真人灰盒签核。

const PROGRAM_PATH := "res://assets/configs/world_map/formal_demo_room_program.json"
const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const TELEMETRY_SCRIPT := preload("res://scripts/dev/room_playtest_telemetry.gd")
const OUT_DIR := "res://tests/artifacts/local/room-design-recovery/final-candidate"
const SCREENSHOT_DIR := "%s/screenshots" % OUT_DIR
const REPORT_PATH := "%s/capture-report.json" % OUT_DIR
const TELEMETRY_PATH := "%s/automation-telemetry.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(1280, 720)
const CAPTURE_PHASES := ["entry", "core", "exit"]
const EVIDENCE_BOUNDARY := "automated_capture_is_diagnostic_evidence_not_human_playtest_acceptance"

var _main: Node
var _telemetry


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = VIEWPORT_SIZE
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))
	var program := _read_json(PROGRAM_PATH)
	if program.is_empty() or program.get("formal_rooms", []).size() != 18:
		push_error("方案 B room program 缺失或不是 18 房。")
		quit(1)
		return

	_telemetry = TELEMETRY_SCRIPT.new()
	_telemetry.start_session({"tester": "automation_capture", "program_id": program.get("program_id", "")})
	_main = load(MAIN_SCENE_PATH).instantiate()
	root.add_child(_main)
	await _settle(5)
	var demo_shell := _main.get_node_or_null("HUD/DemoShell")
	if demo_shell != null and demo_shell.has_method("start_demo"):
		demo_shell.call("start_demo")
		await _settle(8)

	var rows: Array[Dictionary] = []
	for definition: Dictionary in program.get("formal_rooms", []):
		rows.append(await _capture_room(definition))

	var screenshot_count := 0
	for row: Dictionary in rows:
		for capture: Dictionary in row.get("captures", []):
			if bool(capture.get("saved", false)):
				screenshot_count += 1
	var report := {
		"review_id": "formal_demo_room_recovery_b_capture",
		"generated_at": Time.get_datetime_string_from_system(),
		"program_id": program.get("program_id", ""),
		"formal_room_count": rows.size(),
		"capture_slot_count": rows.size() * CAPTURE_PHASES.size(),
		"screenshot_count": screenshot_count,
		"display_server": DisplayServer.get_name(),
		"human_acceptance": "pending_external_playtest",
		"boundary": EVIDENCE_BOUNDARY,
		"rooms": rows,
	}
	_write_json(REPORT_PATH, report)
	_telemetry.save_json(TELEMETRY_PATH)
	print("Formal demo recovery capture: rooms=%d slots=%d screenshots=%d display=%s" % [
		rows.size(), rows.size() * CAPTURE_PHASES.size(), screenshot_count, DisplayServer.get_name()
	])
	print("Capture report: %s" % REPORT_PATH)
	quit(0 if rows.size() == 18 else 1)


func _capture_room(definition: Dictionary) -> Dictionary:
	var room_id := str(definition.get("id", ""))
	var room_path := str(definition.get("path", ""))
	_main.call("transition_to_room", room_path, &"")
	_hide_demo_shell()
	await _settle(8)
	var room := _main.get("room") as Node2D
	var player := _main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	if room == null or player == null:
		return {"id": room_id, "path": room_path, "error": "missing_runtime_room_or_player", "captures": []}

	var safe_floor_y := float(room.get_meta("safe_floor_y", player.global_position.y))
	var camera_limits := _room_camera_limits(room)
	var positions := _capture_positions(camera_limits, safe_floor_y)
	_telemetry.enter_room(room_id, room_path, &"capture_entry", &"right", positions[0])
	var captures: Array[Dictionary] = []
	for index: int in range(CAPTURE_PHASES.size()):
		player.global_position = positions[index]
		player.velocity = Vector2.ZERO
		await _settle(5)
		captures.append(_capture_frame(room_id, CAPTURE_PHASES[index], positions[index]))
	_telemetry.leave_room(&"right", "capture_next", positions[2])

	return {
		"id": room_id,
		"title": str(definition.get("title", "")),
		"path": room_path,
		"role": str(definition.get("role", "")),
		"camera_limits": [camera_limits.position.x, camera_limits.position.y, camera_limits.size.x, camera_limits.size.y],
		"transition_visual_type": str(room.get_meta("transition_visual_type", "")),
		"normal_exit_uses_generic_door": bool(room.get_meta("normal_exit_uses_generic_door", true)),
		"captures": captures,
	}


func _capture_frame(room_id: String, phase: String, position: Vector2) -> Dictionary:
	var path := "%s/%s_%s.png" % [SCREENSHOT_DIR, room_id.to_lower(), phase]
	var saved := false
	var status := "unavailable_in_headless_renderer"
	if DisplayServer.get_name() != "headless":
		var texture := root.get_texture()
		var image := texture.get_image() if texture != null else null
		if image != null and not image.is_empty():
			saved = image.save_png(path) == OK
			status = "captured" if saved else "save_failed"
	return {
		"phase": phase,
		"player_position": [position.x, position.y],
		"path": path,
		"saved": saved,
		"status": status,
	}


func _room_camera_limits(room: Node) -> Rect2i:
	if room.has_method("get_camera_limits"):
		return room.call("get_camera_limits") as Rect2i
	return Rect2i(-640, -360, 1280, 720)


func _capture_positions(limits: Rect2i, safe_floor_y: float) -> Array[Vector2]:
	var margin := minf(160.0, maxf(64.0, float(limits.size.x) * 0.12))
	return [
		Vector2(float(limits.position.x) + margin, safe_floor_y),
		Vector2(float(limits.position.x) + float(limits.size.x) * 0.5, safe_floor_y),
		Vector2(float(limits.end.x) - margin, safe_floor_y),
	]


func _hide_demo_shell() -> void:
	for path in [
		"HUD/DemoShell/MainMenu",
		"HUD/DemoShell/TitleBackground",
		"HUD/DemoShell/DetailPanel",
		"HUD/DemoShell/PauseMenu",
		"HUD/DemoShell/WorldMapPanel",
		"HUD/DemoShell/FailurePanel",
		"HUD/DemoShell/CompletionPanel",
	]:
		var node := _main.get_node_or_null(path) as CanvasItem
		if node != null:
			node.visible = false


func _settle(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await process_frame


func _read_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _write_json(path: String, value: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(value, "  "))
