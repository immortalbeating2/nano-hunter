extends SceneTree

# DemoShell 主菜单布局复核：在不同 16:9 尺寸下捕获普通态与鼠标悬停态，检查面板居中且不遮挡标题背景主体。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const OUT_DIR := "res://tests/artifacts/local/demo-shell-layout-hover-review"
const OUT_REPORT := "%s/demo_shell_layout_hover_review_report.json" % OUT_DIR
const VIEWPORT_SIZES := [
	Vector2i(640, 360),
	Vector2i(1024, 576),
	Vector2i(2048, 1152),
]


func _init() -> void:
	_run.call_deferred()


# 主入口：逐个尺寸加载生产 Main 场景，模拟鼠标悬停开始按钮并写出结构化报告。
func _run() -> void:
	var result := await _capture_all()
	quit(result)


# 对多个分辨率执行相同检查，避免只在默认尺寸下误判主菜单适配。
func _capture_all() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	var cases: Array[Dictionary] = []
	var all_ok := true
	for viewport_size: Vector2i in VIEWPORT_SIZES:
		var case_report := await _capture_one(viewport_size)
		cases.append(case_report)
		all_ok = all_ok and bool(case_report.get("ok", false))

	_write_json(OUT_REPORT, {
		"ok": all_ok,
		"review_id": "demo_shell_layout_hover_review",
		"cases": cases,
	})
	return 0 if all_ok else 1


# 加载真实主场景，捕获普通态与 hover 态，并记录主菜单 / 按钮矩形。
func _capture_one(viewport_size: Vector2i) -> Dictionary:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	await _wait_frames(8)

	var packed_scene := ResourceLoader.load(MAIN_SCENE_PATH) as PackedScene
	if packed_scene == null:
		return _error_case(viewport_size, "cannot_load_main_scene")

	var main_scene := packed_scene.instantiate() as Node2D
	if main_scene == null:
		return _error_case(viewport_size, "cannot_instantiate_main_scene")

	root.add_child(main_scene)
	await _wait_frames(8)

	var actual_viewport_size := root.get_visible_rect().size
	var main_menu := main_scene.get_node_or_null("HUD/DemoShell/MainMenu") as Panel
	var start_button := main_scene.get_node_or_null("HUD/DemoShell/MainMenu/MarginContainer/VBoxContainer/StartButton") as Button
	if main_menu == null or start_button == null:
		main_scene.queue_free()
		await _wait_frames(2)
		return _error_case(viewport_size, "missing_menu_or_start_button")

	var suffix := "%sx%s" % [viewport_size.x, viewport_size.y]
	var normal_image := "%s/menu_normal_%s.png" % [OUT_DIR, suffix]
	var hover_image := "%s/menu_hover_%s.png" % [OUT_DIR, suffix]
	var normal_save_ok := _save_screenshot(normal_image)

	var menu_rect := main_menu.get_global_rect()
	var button_rect := start_button.get_global_rect()
	var button_center := button_rect.get_center()
	root.warp_mouse(button_center)
	var motion_event := InputEventMouseMotion.new()
	motion_event.position = button_center
	motion_event.global_position = button_center
	Input.parse_input_event(motion_event)
	await _wait_frames(8)

	var hover_save_ok := _save_screenshot(hover_image)
	var menu_size_ok := (
		menu_rect.size.x >= 280.0
		and menu_rect.size.x <= minf(actual_viewport_size.x - 24.0, 570.0)
		and menu_rect.size.y >= 280.0
		and menu_rect.size.y <= minf(actual_viewport_size.y - 24.0, 440.0)
	)
	var menu_center_delta_x := absf(menu_rect.get_center().x - actual_viewport_size.x * 0.5)
	var menu_composition_ok := (
		menu_center_delta_x <= maxf(2.0, actual_viewport_size.x * 0.03)
		and menu_rect.get_center().y >= actual_viewport_size.y * 0.48
		and menu_rect.get_center().y <= actual_viewport_size.y * 0.66
		and (menu_rect.size.x * menu_rect.size.y) <= 570.0 * 440.0
	)
	var menu_inside_viewport_ok := (
		menu_rect.position.x >= 8.0
		and menu_rect.position.y >= 8.0
		and menu_rect.end.x <= actual_viewport_size.x - 8.0
		and menu_rect.end.y <= actual_viewport_size.y - 8.0
	)
	var button_height_ok := button_rect.size.y >= 26.0 and button_rect.size.y <= 38.0
	var button_width_ok := button_rect.size.x >= 220.0 and button_rect.size.x <= 500.0
	var mouse_inside_button := button_rect.has_point(button_center)
	var ok := (
		normal_save_ok
		and hover_save_ok
		and menu_size_ok
		and menu_composition_ok
		and menu_inside_viewport_ok
		and button_height_ok
		and button_width_ok
		and mouse_inside_button
	)

	var case_report := {
		"ok": ok,
		"requested_window_size": {"x": viewport_size.x, "y": viewport_size.y},
		"actual_viewport_size": {"x": actual_viewport_size.x, "y": actual_viewport_size.y},
		"normal_image": normal_image,
		"hover_image": hover_image,
		"normal_save_ok": normal_save_ok,
		"hover_save_ok": hover_save_ok,
		"menu_rect": _rect_to_dict(menu_rect),
		"menu_center_delta_x": menu_center_delta_x,
		"menu_size_ok": menu_size_ok,
		"menu_composition_ok": menu_composition_ok,
		"menu_inside_viewport_ok": menu_inside_viewport_ok,
		"button_rect": _rect_to_dict(button_rect),
		"button_height_ok": button_height_ok,
		"button_width_ok": button_width_ok,
		"button_hovered_after_mouse_move": start_button.is_hovered(),
		"mouse_position_inside_button_rect": mouse_inside_button,
	}
	main_scene.queue_free()
	await _wait_frames(2)
	return case_report


# 推进若干帧，等待 Main ready、UI 容器布局和鼠标 hover 状态完成刷新。
func _wait_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


# 保存当前 viewport 截图；空图直接视为失败，避免把无效截图当作人工复核证据。
func _save_screenshot(path: String) -> bool:
	var image := root.get_texture().get_image()
	return image != null and not image.is_empty() and image.save_png(path) == OK


# 写出结构化报告，便于后续 session 不打开截图也能判断本轮结论。
func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE)
	if file == null:
		push_error("Cannot write report: %s" % path)
		return
	file.store_string(JSON.stringify(data, "\t", false) + "\n")


# 失败分支也保持同一报告结构，方便脚本调用方定位失败尺寸。
func _error_case(viewport_size: Vector2i, reason: String) -> Dictionary:
	return {
		"ok": false,
		"requested_window_size": {"x": viewport_size.x, "y": viewport_size.y},
		"reason": reason,
	}


# 将 Rect2 转成 JSON 友好的字段，避免报告里出现不可解析的 Godot 字符串。
func _rect_to_dict(rect: Rect2) -> Dictionary:
	return {
		"x": rect.position.x,
		"y": rect.position.y,
		"width": rect.size.x,
		"height": rect.size.y,
	}
