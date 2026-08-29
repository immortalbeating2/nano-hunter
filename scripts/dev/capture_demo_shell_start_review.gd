extends SceneTree

# DemoShell 启动入口复核：保存主菜单和开始后的截图，并确认标题背景不会盖住游戏。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const OUT_DIR := "res://tests/artifacts/local/demo-shell-start-review"
const OUT_MENU_IMAGE := "%s/demo_shell_menu.png" % OUT_DIR
const OUT_CONTROLS_IMAGE := "%s/demo_shell_controls.png" % OUT_DIR
const OUT_STARTED_IMAGE := "%s/demo_shell_started.png" % OUT_DIR
const OUT_PAUSE_IMAGE := "%s/demo_shell_pause.png" % OUT_DIR
const OUT_FAILURE_IMAGE := "%s/demo_shell_failure.png" % OUT_DIR
const OUT_REPORT := "%s/demo_shell_start_review_report.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(2048, 1152)


func _init() -> void:
	_run.call_deferred()


# 主入口：加载真实 Main 场景，分别捕获主菜单态和点击开始后的运行态。
func _run() -> void:
	var result := await _capture()
	quit(result)


# 复用生产 Main.tscn，不构造平行 UI；只检查本次 bug 涉及的背景遮挡和菜单显示。
func _capture() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	root.size = VIEWPORT_SIZE

	var packed_scene := ResourceLoader.load(MAIN_SCENE_PATH) as PackedScene
	if packed_scene == null:
		push_error("Cannot load Main scene: %s" % MAIN_SCENE_PATH)
		return 1

	var main_scene := packed_scene.instantiate() as Node2D
	if main_scene == null:
		push_error("Cannot instantiate Main scene: %s" % MAIN_SCENE_PATH)
		return 1
	root.add_child(main_scene)
	await _wait_frames(8)

	var demo_shell := main_scene.get_node_or_null("HUD/DemoShell")
	var title_background := main_scene.get_node_or_null("HUD/DemoShell/TitleBackground") as TextureRect
	var main_menu := main_scene.get_node_or_null("HUD/DemoShell/MainMenu") as Panel
	var detail_panel := main_scene.get_node_or_null("HUD/DemoShell/DetailPanel") as Panel
	var detail_title_label := main_scene.get_node_or_null("HUD/DemoShell/DetailPanel/MarginContainer/VBoxContainer/DetailTitleLabel") as Label
	var detail_body_label := main_scene.get_node_or_null("HUD/DemoShell/DetailPanel/MarginContainer/VBoxContainer/DetailBodyLabel") as Label
	var controls_button := main_scene.get_node_or_null("HUD/DemoShell/MainMenu/MarginContainer/VBoxContainer/ControlsButton") as Button
	var detail_back_button := main_scene.get_node_or_null("HUD/DemoShell/DetailPanel/MarginContainer/VBoxContainer/DetailBackButton") as Button
	var pause_menu := main_scene.get_node_or_null("HUD/DemoShell/PauseMenu") as Panel
	var pause_title_label := main_scene.get_node_or_null("HUD/DemoShell/PauseMenu/MarginContainer/VBoxContainer/TitleLabel") as Label
	var failure_panel := main_scene.get_node_or_null("HUD/DemoShell/FailurePanel") as Panel
	var failure_label := main_scene.get_node_or_null("HUD/DemoShell/FailurePanel/MarginContainer/VBoxContainer/FailureLabel") as Label
	var resume_button := main_scene.get_node_or_null("HUD/DemoShell/PauseMenu/MarginContainer/VBoxContainer/ResumeButton") as Button
	var failure_continue_button := main_scene.get_node_or_null("HUD/DemoShell/FailurePanel/MarginContainer/VBoxContainer/FailureContinueButton") as Button
	var action_focus_band := main_scene.get_node_or_null("HUD/DemoShell/ActionFocusBand") as ColorRect
	var tutorial_hud := main_scene.get_node_or_null("HUD/TutorialHUD") as Control
	var battle_panel := main_scene.get_node_or_null("HUD/TutorialHUD/BattlePanel") as Panel
	var prompt_panel := main_scene.get_node_or_null("HUD/TutorialHUD/PromptPanel") as Panel
	var menu_save_ok := _save_screenshot(OUT_MENU_IMAGE)
	if controls_button != null:
		controls_button.emit_signal("pressed")
	await _wait_frames(4)
	var controls_save_ok := _save_screenshot(OUT_CONTROLS_IMAGE)
	var controls_detail_visible := detail_panel != null and detail_panel.visible
	var controls_detail_text_ok := (
		detail_title_label != null
		and detail_body_label != null
		and detail_title_label.text == "控制说明"
		and detail_body_label.text.contains("攻击 J")
	)
	if detail_back_button != null:
		detail_back_button.emit_signal("pressed")
	await _wait_frames(4)
	var menu_visible_after_detail_back := main_menu != null and main_menu.visible

	if main_scene.has_method("start_demo"):
		main_scene.call("start_demo")
	await _wait_frames(8)

	var player := main_scene.get_node_or_null("Runtime/PlayerPlaceholder")
	var started_save_ok := _save_screenshot(OUT_STARTED_IMAGE)
	var hud_viewport_size := root.get_visible_rect().size
	var expected_hud_scale := 1.0
	if tutorial_hud != null and tutorial_hud.has_method("_runtime_hud_scale"):
		expected_hud_scale = float(tutorial_hud.call("_runtime_hud_scale", hud_viewport_size))
	var battle_panel_rect := Rect2()
	var prompt_panel_rect := Rect2()
	var runtime_hud_layout_ok := false
	if battle_panel != null and prompt_panel != null:
		battle_panel_rect = battle_panel.get_global_rect()
		prompt_panel_rect = prompt_panel.get_global_rect()
		runtime_hud_layout_ok = (
			absf(battle_panel.scale.x - expected_hud_scale) <= 0.01
			and absf(prompt_panel.scale.x - expected_hud_scale) <= 0.01
			and battle_panel_rect.size.x >= 190.0 * expected_hud_scale
			and prompt_panel_rect.size.x >= 300.0 * expected_hud_scale
		)
	if demo_shell != null and demo_shell.has_method("pause_demo"):
		demo_shell.call("pause_demo")
	await _wait_frames(4)
	var pause_save_ok := _save_screenshot(OUT_PAUSE_IMAGE)
	var pause_visible := pause_menu != null and pause_menu.visible
	var pause_text_ok := pause_title_label != null and pause_title_label.get_theme_color("font_color").r > 0.7
	var pause_focus_band_ok := (
		action_focus_band != null
		and action_focus_band.visible
		and resume_button != null
		and absf(action_focus_band.get_global_rect().get_center().y - resume_button.get_global_rect().end.y) <= 2.0
	)
	var pause_rect := Rect2()
	var pause_layout_ok := false
	if pause_menu != null:
		var viewport_size := root.get_visible_rect().size
		pause_rect = pause_menu.get_global_rect()
		var pause_center_delta_x := absf(pause_rect.get_center().x - viewport_size.x * 0.5)
		var pause_center_delta_y := absf(pause_rect.get_center().y - viewport_size.y * 0.5)
		pause_layout_ok = (
			pause_rect.size.x >= 260.0
			and pause_rect.size.y >= 180.0
			and pause_center_delta_x <= 2.0
			and pause_center_delta_y <= 2.0
		)
	if demo_shell != null and demo_shell.has_method("resume_demo"):
		demo_shell.call("resume_demo")
	await _wait_frames(4)
	if demo_shell != null and demo_shell.has_method("show_failure_notice"):
		demo_shell.call("show_failure_notice", "已跌落，回到最近检查点。")
	await _wait_frames(4)
	var failure_save_ok := _save_screenshot(OUT_FAILURE_IMAGE)
	var failure_visible := failure_panel != null and failure_panel.visible
	var failure_text_ok := failure_label != null and failure_label.get_theme_color("font_color").r > 0.7
	var failure_focus_band_ok := (
		action_focus_band != null
		and action_focus_band.visible
		and failure_continue_button != null
		and absf(action_focus_band.get_global_rect().get_center().y - failure_continue_button.get_global_rect().end.y) <= 2.0
	)
	var failure_rect := Rect2()
	var failure_layout_ok := false
	if failure_panel != null:
		var viewport_size := root.get_visible_rect().size
		failure_rect = failure_panel.get_global_rect()
		var failure_center_delta := absf(failure_rect.get_center().x - viewport_size.x * 0.5)
		failure_layout_ok = failure_rect.size.x >= 300.0 and failure_rect.size.y >= 180.0 and failure_center_delta <= 2.0
	var started_background_visible := title_background != null and title_background.visible
	var started_menu_visible := main_menu != null and main_menu.visible
	var ok := (
		demo_shell != null
		and title_background != null
		and main_menu != null
		and detail_panel != null
		and pause_menu != null
		and failure_panel != null
		and menu_save_ok
		and controls_save_ok
		and controls_detail_visible
		and controls_detail_text_ok
		and menu_visible_after_detail_back
		and started_save_ok
		and pause_save_ok
		and failure_save_ok
		and pause_visible
		and pause_text_ok
		and pause_layout_ok
		and pause_focus_band_ok
		and failure_visible
		and failure_text_ok
		and failure_layout_ok
		and failure_focus_band_ok
		and runtime_hud_layout_ok
		and not started_background_visible
		and not started_menu_visible
		and player != null
	)

	_write_json(OUT_REPORT, {
		"ok": ok,
		"review_id": "demo_shell_start_review",
		"menu_image": OUT_MENU_IMAGE,
		"controls_image": OUT_CONTROLS_IMAGE,
		"started_image": OUT_STARTED_IMAGE,
		"pause_image": OUT_PAUSE_IMAGE,
		"failure_image": OUT_FAILURE_IMAGE,
		"title_background_visible_after_start": started_background_visible,
		"main_menu_visible_after_start": started_menu_visible,
		"pause_menu_visible_after_pause": pause_visible,
		"pause_text_ok": pause_text_ok,
		"pause_layout_ok": pause_layout_ok,
		"pause_focus_band_ok": pause_focus_band_ok,
		"failure_panel_visible_after_notice": failure_visible,
		"failure_text_ok": failure_text_ok,
		"failure_layout_ok": failure_layout_ok,
		"failure_focus_band_ok": failure_focus_band_ok,
		"shared_action_focus_band_count": demo_shell.find_children("ActionFocusBand", "ColorRect", true, false).size() if demo_shell != null else 0,
		"viewport_size": {
			"width": root.get_visible_rect().size.x,
			"height": root.get_visible_rect().size.y,
		},
		"failure_panel_rect": {
			"x": failure_rect.position.x,
			"y": failure_rect.position.y,
			"width": failure_rect.size.x,
			"height": failure_rect.size.y,
		},
		"pause_panel_rect": {
			"x": pause_rect.position.x,
			"y": pause_rect.position.y,
			"width": pause_rect.size.x,
			"height": pause_rect.size.y,
		},
		"runtime_hud_layout_ok": runtime_hud_layout_ok,
		"runtime_hud_expected_scale": expected_hud_scale,
		"battle_panel_rect": {
			"x": battle_panel_rect.position.x,
			"y": battle_panel_rect.position.y,
			"width": battle_panel_rect.size.x,
			"height": battle_panel_rect.size.y,
		},
		"prompt_panel_rect": {
			"x": prompt_panel_rect.position.x,
			"y": prompt_panel_rect.position.y,
			"width": prompt_panel_rect.size.x,
			"height": prompt_panel_rect.size.y,
		},
		"controls_detail_visible": controls_detail_visible,
		"controls_detail_text_ok": controls_detail_text_ok,
		"menu_visible_after_detail_back": menu_visible_after_detail_back,
		"player_exists_after_start": player != null,
	})

	main_scene.queue_free()
	return 0 if ok else 1


# 推进若干帧，等待 Main ready、房间替换和 HUD 初始化完成。
func _wait_frames(count: int) -> void:
	for _index in count:
		await process_frame


# 保存当前 viewport 截图；空图直接视为失败。
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
