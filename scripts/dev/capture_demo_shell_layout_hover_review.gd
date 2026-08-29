extends SceneTree

# DemoShell C2 主菜单布局复核：捕获多分辨率、符光双帧与跨行 hover，检查唯一光带持续流动并追踪真实焦点。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const OUT_DIR := "res://tests/artifacts/local/demo-shell-layout-hover-review"
const OUT_REPORT := "%s/demo_shell_layout_hover_review_report.json" % OUT_DIR
const VIEWPORT_SIZES := [
	Vector2i(640, 360),
	Vector2i(1024, 576),
	Vector2i(1672, 941),
	Vector2i(2048, 1152),
	Vector2i(2560, 1080),
]


func _init() -> void:
	_run.call_deferred()


# 主入口：逐个尺寸加载生产 Main 场景，模拟跨行焦点并写出结构化报告。
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


# 加载真实主场景，捕获普通态、符光双帧和“设置”hover 态。
func _capture_one(viewport_size: Vector2i) -> Dictionary:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(viewport_size)
	root.content_scale_size = viewport_size
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
	var focus_band := main_scene.get_node_or_null("HUD/DemoShell/MainMenu/FocusBand") as ColorRect
	var start_button := main_scene.get_node_or_null("HUD/DemoShell/MainMenu/MarginContainer/VBoxContainer/StartButton") as Button
	var settings_button := main_scene.get_node_or_null("HUD/DemoShell/MainMenu/MarginContainer/VBoxContainer/SettingsButton") as Button
	if main_menu == null or focus_band == null or start_button == null or settings_button == null:
		main_scene.queue_free()
		await _wait_frames(2)
		return _error_case(viewport_size, "missing_menu_focus_band_or_buttons")

	var suffix := "%sx%s" % [viewport_size.x, viewport_size.y]
	var normal_image := "%s/menu_normal_%s.png" % [OUT_DIR, suffix]
	var hover_image := "%s/menu_hover_%s.png" % [OUT_DIR, suffix]
	var flow_a_image := "%s/menu_flow_a_%s.png" % [OUT_DIR, suffix]
	var flow_b_image := "%s/menu_flow_b_%s.png" % [OUT_DIR, suffix]
	var outside_point := Vector2(2.0, 2.0)
	var outside_motion := InputEventMouseMotion.new()
	outside_motion.position = outside_point
	outside_motion.global_position = outside_point
	root.push_input(outside_motion, true)
	await _wait_frames(4)
	var normal_hovered_buttons := _hovered_button_names(main_menu)
	var flow_frame_a := root.get_texture().get_image()
	var normal_save_ok := _save_image(flow_frame_a, normal_image)

	var menu_rect := main_menu.get_global_rect()
	var button_rect := start_button.get_global_rect()
	var initial_band_rect := focus_band.get_global_rect()
	var flow_a_save_ok := true
	if viewport_size == Vector2i(1672, 941):
		flow_a_save_ok = _save_image(flow_frame_a, flow_a_image)
	await _wait_frames(12)
	var flow_frame_b := root.get_texture().get_image()
	var flow_b_save_ok := true
	if viewport_size == Vector2i(1672, 941):
		flow_b_save_ok = _save_image(flow_frame_b, flow_b_image)
	var flow_changed_sample_count := _count_changed_samples(flow_frame_a, flow_frame_b, initial_band_rect)
	var settings_rect := settings_button.get_global_rect()
	var button_center := settings_rect.get_center()
	var motion_event := InputEventMouseMotion.new()
	motion_event.position = button_center
	motion_event.global_position = button_center
	root.push_input(motion_event, true)
	await _wait_frames(20)

	var hover_save_ok := _save_screenshot(hover_image)
	var tracked_band_rect := focus_band.get_global_rect()
	var focus_band_track_delta_y := absf(tracked_band_rect.get_center().y - settings_rect.end.y)
	var focus_band_tracks_settings := (
		focus_band.visible
		and focus_band_track_delta_y <= 2.5
		and absf(tracked_band_rect.size.x - settings_rect.size.x) <= 2.5
		and root.gui_get_focus_owner() == settings_button
	)
	var menu_size_ok := (
		menu_rect.size.x >= 300.0
		and menu_rect.size.x <= minf(actual_viewport_size.x - 12.0, 900.0)
		and menu_rect.size.y >= 300.0
		and menu_rect.size.y <= minf(actual_viewport_size.y - 12.0, 980.0)
	)
	var menu_target_delta_x := absf(menu_rect.get_center().x - actual_viewport_size.x * 0.745)
	var menu_composition_ok := (
		menu_target_delta_x <= maxf(2.0, actual_viewport_size.x * 0.03)
		and menu_rect.get_center().y >= actual_viewport_size.y * 0.50
		and menu_rect.get_center().y <= actual_viewport_size.y * 0.56
		and (menu_rect.size.x * menu_rect.size.y) <= 900.0 * 980.0
	)
	var menu_inside_viewport_ok := (
		menu_rect.position.x >= 8.0
		and menu_rect.position.y >= 8.0
		and menu_rect.end.x <= actual_viewport_size.x - 8.0
		and menu_rect.end.y <= actual_viewport_size.y - 8.0
	)
	var button_height_ok := button_rect.size.y >= 28.0 and button_rect.size.y <= 62.0
	var button_width_ok := button_rect.size.x >= 220.0 and button_rect.size.x <= 720.0
	var mouse_inside_button := settings_rect.has_point(button_center)
	var hovered_buttons_after_mouse_move := _hovered_button_names(main_menu)
	var shared_focus_band_count := main_menu.find_children("FocusBand", "ColorRect", true, false).size()
	var ok := (
		normal_save_ok
		and hover_save_ok
		and flow_a_save_ok
		and flow_b_save_ok
		and flow_changed_sample_count > 8
		and normal_hovered_buttons.is_empty()
		and menu_size_ok
		and menu_composition_ok
		and menu_inside_viewport_ok
		and button_height_ok
		and button_width_ok
		and mouse_inside_button
		and settings_button.is_hovered()
		and focus_band_tracks_settings
		and shared_focus_band_count == 1
	)

	var case_report := {
		"ok": ok,
		"requested_window_size": {"x": viewport_size.x, "y": viewport_size.y},
		"actual_viewport_size": {"x": actual_viewport_size.x, "y": actual_viewport_size.y},
		"normal_image": normal_image,
		"hover_image": hover_image,
		"flow_a_image": flow_a_image if viewport_size == Vector2i(1672, 941) else "",
		"flow_b_image": flow_b_image if viewport_size == Vector2i(1672, 941) else "",
		"normal_save_ok": normal_save_ok,
		"normal_hovered_buttons": normal_hovered_buttons,
		"hover_save_ok": hover_save_ok,
		"flow_changed_sample_count": flow_changed_sample_count,
		"menu_rect": _rect_to_dict(menu_rect),
		"menu_target_delta_x": menu_target_delta_x,
		"menu_size_ok": menu_size_ok,
		"menu_composition_ok": menu_composition_ok,
		"menu_inside_viewport_ok": menu_inside_viewport_ok,
		"button_rect": _rect_to_dict(button_rect),
		"button_height_ok": button_height_ok,
		"button_width_ok": button_width_ok,
		"initial_focus_band_rect": _rect_to_dict(initial_band_rect),
		"tracked_focus_band_rect": _rect_to_dict(tracked_band_rect),
		"focus_band_track_delta_y": focus_band_track_delta_y,
		"focus_band_tracks_settings": focus_band_tracks_settings,
		"shared_focus_band_count": shared_focus_band_count,
		"button_hovered_after_mouse_move": settings_button.is_hovered(),
		"hovered_buttons_after_mouse_move": hovered_buttons_after_mouse_move,
		"mouse_position_inside_button_rect": mouse_inside_button,
	}
	main_scene.queue_free()
	await _wait_frames(2)
	return case_report


# 推进若干帧，等待 Main ready、UI 容器布局和鼠标 hover 状态完成刷新。
func _wait_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


# 返回当前主菜单内处于 hover 的按钮名，防止窗口缩放后的旧鼠标位置污染普通态截图。
func _hovered_button_names(main_menu: Control) -> Array[String]:
	var hovered: Array[String] = []
	for node: Node in main_menu.find_children("*", "Button", true, false):
		var button := node as Button
		if button != null and button.is_hovered():
			hovered.append(button.name)
	return hovered


# 保存当前 viewport 截图；空图直接视为失败，避免把无效截图当作人工复核证据。
func _save_screenshot(path: String) -> bool:
	return _save_image(root.get_texture().get_image(), path)


func _save_image(image: Image, path: String) -> bool:
	return image != null and not image.is_empty() and image.save_png(path) == OK


# 只采样符光矩形，证明静止焦点下的像素仍随 Shader TIME 变化。
func _count_changed_samples(first: Image, second: Image, rect: Rect2) -> int:
	if first == null or second == null or first.is_empty() or second.is_empty():
		return 0
	var from_x := maxi(0, floori(rect.position.x))
	var from_y := maxi(0, floori(rect.position.y))
	var to_x := mini(first.get_width(), ceili(rect.end.x))
	var to_y := mini(first.get_height(), ceili(rect.end.y))
	var changed := 0
	for y: int in range(from_y, to_y, 2):
		for x: int in range(from_x, to_x, 2):
			var a := first.get_pixel(x, y)
			var b := second.get_pixel(x, y)
			var delta := absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)
			if delta > 0.02:
				changed += 1
	return changed


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
