extends SceneTree

# 暂停交互候选实机图：在真实 Main 背景上输出三套固定几何焦点语言，不改生产场景的最终选型。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const OUT_DIR := "res://tests/artifacts/local/pause-interaction-options"
const VIEWPORT_SIZE := Vector2i(1280, 720)
const BUTTON_SIZE := Vector2(344.0, 50.0)
const PAUSE_SIZE := Vector2(460.0, 480.0)
const FOCUS_SHADER := preload("res://assets/shaders/ui/main_menu_focus_band.gdshader")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	root.content_scale_size = VIEWPORT_SIZE
	root.size = VIEWPORT_SIZE
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	await _wait_frames(6)

	var packed := load(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Cannot load Main for pause interaction review.")
		quit(1)
		return
	var main := packed.instantiate() as Node2D
	root.add_child(main)
	await _wait_frames(8)
	main.call("start_demo")
	await _wait_frames(6)
	main.call("pause_demo")
	main.call("set_gameplay_hud_visible", false)
	await _wait_frames(6)

	var shell := main.get_node_or_null("HUD/DemoShell") as Control
	var pause := main.get_node_or_null("HUD/DemoShell/PauseMenu") as Panel
	var margin := main.get_node_or_null("HUD/DemoShell/PauseMenu/MarginContainer") as MarginContainer
	var vbox := main.get_node_or_null("HUD/DemoShell/PauseMenu/MarginContainer/VBoxContainer") as VBoxContainer
	if shell == null or pause == null or margin == null or vbox == null:
		push_error("Pause review nodes are incomplete.")
		quit(1)
		return

	var buttons: Array[Button] = []
	for node_name: String in ["ResumeButton", "MapButton", "TravelButton", "BuildButton", "RestartButton"]:
		var button := vbox.get_node_or_null(node_name) as Button
		if button == null:
			push_error("Missing pause action: %s" % node_name)
			quit(1)
			return
		buttons.append(button)

	_add_dim_layer(shell, pause)
	_apply_review_layout(pause, margin, vbox, buttons)
	var results := [
		await _capture_option_a(pause, buttons),
		await _capture_option_b(pause, buttons),
		await _capture_option_c(pause, buttons),
	]
	var all_ok := results.all(func(value: Variant) -> bool: return bool(value))
	print("pause_interaction_options count=3 ok=%s" % str(all_ok).to_lower())
	main.queue_free()
	await _wait_frames(2)
	quit(0 if all_ok else 1)


func _add_dim_layer(shell: Control, pause: Panel) -> void:
	var dim := ColorRect.new()
	dim.name = "PauseConceptDim"
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.008, 0.025, 0.035, 0.68)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(dim)
	shell.move_child(dim, pause.get_index())


func _apply_review_layout(pause: Panel, margin: MarginContainer, vbox: VBoxContainer, buttons: Array[Button]) -> void:
	pause.anchor_left = 0.5
	pause.anchor_top = 0.5
	pause.anchor_right = 0.5
	pause.anchor_bottom = 0.5
	pause.offset_left = -PAUSE_SIZE.x * 0.5
	pause.offset_top = -PAUSE_SIZE.y * 0.5
	pause.offset_right = PAUSE_SIZE.x * 0.5
	pause.offset_bottom = PAUSE_SIZE.y * 0.5
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 48.0
	margin.offset_top = 52.0
	margin.offset_right = -48.0
	margin.offset_bottom = -42.0
	vbox.add_theme_constant_override("separation", 13)
	var title := vbox.get_node_or_null("TitleLabel") as Label
	if title != null:
		title.text = "暂 停"
		title.add_theme_font_size_override("font_size", 28)
		title.add_theme_color_override("font_color", Color(0.93, 0.82, 0.55, 1.0))
		title.custom_minimum_size = Vector2(0.0, 46.0)
	for button: Button in buttons:
		button.custom_minimum_size = BUTTON_SIZE
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.add_theme_font_size_override("font_size", 22)
		button.icon = null
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	buttons[0].grab_focus()


func _capture_option_a(pause: Panel, buttons: Array[Button]) -> bool:
	_clear_transients(pause)
	pause.add_theme_stylebox_override("panel", _panel_style(Color(0.012, 0.047, 0.063, 0.965), Color(0.55, 0.43, 0.22, 0.9), 1, 14))
	var normal := _button_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 8)
	var hover := _button_style(Color(0.04, 0.20, 0.22, 0.30), Color(0.25, 0.78, 0.82, 0.25), 1, 8)
	for button: Button in buttons:
		_apply_button_styles(button, normal, hover, hover, normal)
		button.add_theme_color_override("font_color", Color(0.66, 0.72, 0.74, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.91, 0.97, 0.98, 1.0))
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	buttons[0].grab_focus()
	await _wait_frames(3)
	var band := ColorRect.new()
	band.name = "ConceptSharedFlowBand"
	band.set_meta("pause_concept_transient", true)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = FOCUS_SHADER
	material.set_shader_parameter("glow_color", Color(0.22, 0.9, 0.95, 1.0))
	material.set_shader_parameter("intensity", 0.92)
	band.material = material
	var button_rect := buttons[0].get_global_rect()
	var pause_rect := pause.get_global_rect()
	band.position = button_rect.position - pause_rect.position + Vector2(0.0, button_rect.size.y - 14.0)
	band.size = Vector2(button_rect.size.x, 30.0)
	pause.add_child(band)
	await _wait_frames(12)
	return _save("%s/a_shared_flow_band.png" % OUT_DIR)


func _capture_option_b(pause: Panel, buttons: Array[Button]) -> bool:
	_clear_transients(pause)
	pause.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.052, 0.055, 0.975), Color(0.67, 0.51, 0.25, 0.95), 2, 12))
	var normal := _button_style(Color(0.018, 0.075, 0.078, 0.96), Color(0.48, 0.38, 0.20, 0.92), 2, 7)
	var hover := _button_style(Color(0.025, 0.13, 0.14, 0.98), Color(0.82, 0.64, 0.28, 1.0), 2, 7)
	var pressed := _button_style(Color(0.01, 0.04, 0.05, 1.0), Color(0.61, 0.88, 0.88, 1.0), 2, 7)
	var focus := _button_style(Color(0.04, 0.20, 0.21, 0.42), Color(0.26, 0.91, 0.94, 0.95), 2, 7)
	for button: Button in buttons:
		_apply_button_styles(button, normal, hover, pressed, focus)
		button.add_theme_color_override("font_color", Color(0.78, 0.80, 0.77, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.98, 0.94, 0.75, 1.0))
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	buttons[0].grab_focus()
	await _wait_frames(8)
	return _save("%s/b_fixed_talisman_plaques.png" % OUT_DIR)


func _capture_option_c(pause: Panel, buttons: Array[Button]) -> bool:
	_clear_transients(pause)
	pause.add_theme_stylebox_override("panel", _panel_style(Color(0.009, 0.038, 0.052, 0.97), Color(0.27, 0.55, 0.58, 0.85), 1, 10))
	var normal := _button_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 4)
	var hover := _button_style(Color(0.04, 0.18, 0.19, 0.34), Color(0, 0, 0, 0), 0, 4)
	var focus := _button_style(Color(0.055, 0.24, 0.25, 0.36), Color(0, 0, 0, 0), 0, 4)
	for button: Button in buttons:
		_apply_button_styles(button, normal, hover, hover, focus)
		button.add_theme_color_override("font_color", Color(0.64, 0.70, 0.72, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.92, 0.96, 0.90, 1.0))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("outline_size", 1)
	buttons[0].grab_focus()
	await _wait_frames(3)
	var first_rect := buttons[0].get_global_rect()
	var last_rect := buttons[-1].get_global_rect()
	var pause_rect := pause.get_global_rect()
	var rail := ColorRect.new()
	rail.name = "ConceptSealRail"
	rail.set_meta("pause_concept_transient", true)
	rail.color = Color(0.20, 0.78, 0.82, 0.72)
	rail.position = Vector2(first_rect.position.x - pause_rect.position.x - 22.0, first_rect.position.y - pause_rect.position.y + 4.0)
	rail.size = Vector2(2.0, last_rect.end.y - first_rect.position.y - 8.0)
	rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause.add_child(rail)
	var marker := Label.new()
	marker.name = "ConceptSealMarker"
	marker.set_meta("pause_concept_transient", true)
	marker.text = "◆"
	marker.add_theme_font_size_override("font_size", 20)
	marker.add_theme_color_override("font_color", Color(0.32, 0.93, 0.94, 1.0))
	marker.position = Vector2(rail.position.x - 9.0, first_rect.get_center().y - pause_rect.position.y - 14.0)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause.add_child(marker)
	await _wait_frames(8)
	return _save("%s/c_seal_rail_cursor.png" % OUT_DIR)


func _apply_button_styles(button: Button, normal: StyleBox, hover: StyleBox, pressed: StyleBox, focus: StyleBox) -> void:
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("disabled", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", focus)


func _panel_style(background: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 18
	return style


func _button_style(background: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 28.0
	style.content_margin_top = 6.0
	style.content_margin_right = 28.0
	style.content_margin_bottom = 6.0
	return style


func _clear_transients(pause: Panel) -> void:
	for child: Node in pause.get_children():
		if bool(child.get_meta("pause_concept_transient", false)):
			child.queue_free()


func _save(path: String) -> bool:
	var image := root.get_texture().get_image()
	return image != null and not image.is_empty() and image.save_png(path) == OK


func _wait_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame
