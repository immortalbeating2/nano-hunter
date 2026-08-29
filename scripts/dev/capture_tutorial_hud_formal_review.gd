# 正式 HUD 运行态复核：覆盖七档窗口、整框高度变体、五种教程提醒状态和 reduced-motion 双帧证据。
extends SceneTree

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const OUT_DIR := "res://tests/artifacts/local/runtime-visual-integrity/hud-formal-review"
const LAYOUT_DIR := "%s/layouts" % OUT_DIR
const STATE_DIR := "%s/states" % OUT_DIR
const CROP_DIR := "%s/attention-crops" % OUT_DIR
const FRAME_VARIANT_DIR := "%s/frame-variants" % OUT_DIR
const OUT_REPORT := "%s/tutorial_hud_formal_review.json" % OUT_DIR
const INITIAL_VIEWPORT := Vector2i(1280, 720)
const VIEWPORT_MATRIX := [
	Vector2i(640, 360),
	Vector2i(1024, 576),
	Vector2i(1280, 720),
	Vector2i(1672, 941),
	Vector2i(2048, 1152),
	Vector2i(2560, 1080),
	Vector2i(2560, 1440),
]
const LONGEST_PROMPT := "移动：左摇杆 / 十字键。跳跃：A / Cross；随后按住方向使用 B / Circle 或 RB 穿过低顶门槛。"

var _main: Node2D
var _hud: Control


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for directory: String in [LAYOUT_DIR, STATE_DIR, CROP_DIR, FRAME_VARIANT_DIR]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	root.size = INITIAL_VIEWPORT

	var packed := load(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Cannot load Main: %s" % MAIN_SCENE_PATH)
		quit(1)
		return
	_main = packed.instantiate() as Node2D
	root.add_child(_main)
	await _wait_frames(5)
	if _main.has_method("start_demo"):
		_main.call("start_demo")
	await _wait_frames(10)
	_hide_demo_shell()
	_hud = _main.get_node_or_null("HUD/TutorialHUD") as Control
	if _hud == null:
		push_error("TutorialHUD missing")
		quit(1)
		return

	var layouts: Array[Dictionary] = []
	var layout_ok := true
	for viewport_size: Vector2i in VIEWPORT_MATRIX:
		var layout_result := await _capture_layout(viewport_size)
		layouts.append(layout_result)
		layout_ok = layout_ok and bool(layout_result.get("ok", false))
	var frame_variants := await _capture_battle_frame_variants(Vector2i(2048, 1152))
	var frame_variants_ok := true
	for frame_variant: Dictionary in frame_variants:
		frame_variants_ok = frame_variants_ok and bool(frame_variant.get("ok", false))

	root.size = INITIAL_VIEWPORT
	await _wait_frames(4)
	_hud.call("_layout_runtime_hud_for_viewport", Vector2(INITIAL_VIEWPORT))
	var states: Array[Dictionary] = []
	states.append(await _capture_attention_pair("idle", &"move_jump", false, 0.3, true))
	states.append(await _capture_attention_pair("enter", &"dash", false, 0.0, true))
	states.append(await _capture_attention_pair("waiting", &"attack", false, 5.0, true))
	states.append(await _capture_attention_pair("complete", &"complete", false, 0.0, true))
	states.append(await _capture_attention_pair("reduced_motion_waiting", &"attack", true, 5.0, false))
	var states_ok := true
	for state: Dictionary in states:
		states_ok = states_ok and bool(state.get("ok", false))

	var shared_attention_count := _hud.find_children("TutorialAttention", "ColorRect", true, false).size()
	var report := {
		"review_id": "tutorial_hud_formal_runtime_review",
		"generated_at": Time.get_datetime_string_from_system(true),
		"layout_count": layouts.size(),
		"state_pair_count": states.size(),
		"shared_attention_count": shared_attention_count,
		"layouts": layouts,
		"frame_variants": frame_variants,
		"states": states,
		"ok": layout_ok and frame_variants_ok and states_ok and shared_attention_count == 1,
		"boundary": "物理像素布局、可见行数和共享 Shader 双帧证据；不替代真人阅读距离与动态节奏签核。",
	}
	_write_json(OUT_REPORT, report)
	print(
		"tutorial_hud_formal_review layouts=%d frame_variants=%d states=%d attention=%d ok=%s report=%s"
		% [layouts.size(), frame_variants.size(), states.size(), shared_attention_count, report["ok"], OUT_REPORT]
	)
	_main.queue_free()
	await process_frame
	quit(0 if bool(report["ok"]) else 1)


func _capture_layout(viewport_size: Vector2i) -> Dictionary:
	root.size = viewport_size
	await _wait_frames(4)
	_set_review_text("教程 2/5 · 低顶门槛与手柄提示", LONGEST_PROMPT)
	_hud.call("set_reduced_motion_enabled", false)
	_hud.call("_set_attention_step", &"dash")
	_hud.call("_process", 0.3)
	_hud.call("_layout_runtime_hud_for_viewport", Vector2(viewport_size))
	await _wait_frames(3)

	var screenshot_path := "%s/%dx%d.png" % [LAYOUT_DIR, viewport_size.x, viewport_size.y]
	var screenshot := _save_full_screenshot(screenshot_path)
	var battle := _hud.get_node("BattlePanel") as Control
	var prompt := _hud.get_node("PromptPanel") as Control
	var element := _hud.get_node("ElementPanel") as Control
	var prompt_label := _hud.get_node("PromptPanel/PromptLabel") as Label
	var canvas_scale := float(_hud.call("_canvas_scale_for_physical_viewport", Vector2(viewport_size)))
	var battle_rect := _physical_rect(battle, canvas_scale)
	var prompt_rect := _physical_rect(prompt, canvas_scale)
	var element_rect := _physical_rect(element, canvas_scale)
	var panels_inside := (
		_rect_inside_viewport(battle_rect, viewport_size)
		and _rect_inside_viewport(prompt_rect, viewport_size)
		and _rect_inside_viewport(element_rect, viewport_size)
	)
	var top_panels_separate := not battle_rect.intersects(element_rect)
	var prompt_separate := not prompt_rect.intersects(battle_rect) and not prompt_rect.intersects(element_rect)
	var prompt_reflow_ok := (
		viewport_size.x >= 1180
		or prompt_rect.position.y >= maxf(battle_rect.end.y, element_rect.end.y) + 7.5
	)
	var all_prompt_lines_visible := prompt_label.get_visible_line_count() == prompt_label.get_line_count()
	var body_font_px := float(prompt_label.get_theme_font_size("font_size")) * prompt.scale.x * canvas_scale
	var title_label := _hud.get_node("PromptPanel/StepLabel") as Label
	var title_font_px := float(title_label.get_theme_font_size("font_size")) * prompt.scale.x * canvas_scale
	var minimum_body_font_px := 13.5 if viewport_size.x <= 1024 else 15.9
	var minimum_title_font_px := 17.5 if viewport_size.x <= 1024 else 19.9
	var content_safe_report := _content_safe_report()
	var ok := (
		bool(screenshot.get("ok", false))
		and panels_inside
		and top_panels_separate
		and prompt_separate
		and prompt_reflow_ok
		and all_prompt_lines_visible
		and bool(content_safe_report.get("ok", false))
		and body_font_px >= minimum_body_font_px
		and title_font_px >= minimum_title_font_px
	)
	return {
		"viewport": [viewport_size.x, viewport_size.y],
		"screenshot": screenshot,
		"canvas_scale": canvas_scale,
		"hud_panel_scale": prompt.scale.x,
		"body_font_px": body_font_px,
		"title_font_px": title_font_px,
		"minimum_body_font_px": minimum_body_font_px,
		"minimum_title_font_px": minimum_title_font_px,
		"battle_rect": _rect_to_report(battle_rect),
		"prompt_rect": _rect_to_report(prompt_rect),
		"element_rect": _rect_to_report(element_rect),
		"panels_inside": panels_inside,
		"top_panels_separate": top_panels_separate,
		"prompt_separate": prompt_separate,
		"prompt_reflow_ok": prompt_reflow_ok,
		"content_safe": content_safe_report,
		"prompt_line_count": prompt_label.get_line_count(),
		"prompt_visible_line_count": prompt_label.get_visible_line_count(),
		"ok": ok,
	}


# 普通与 Boss 增高态分别截图，确保运行时通过整张换框而不是拉伸同一张官印框体。
func _capture_battle_frame_variants(viewport_size: Vector2i) -> Array[Dictionary]:
	root.size = viewport_size
	await _wait_frames(4)
	_set_review_text("教程 2/5 · 低顶门槛与手柄提示", LONGEST_PROMPT)
	_hud.call("_layout_runtime_hud_for_viewport", Vector2(viewport_size))
	var previous_process_mode := _hud.process_mode
	_hud.process_mode = Node.PROCESS_MODE_DISABLED
	var variants: Array[Dictionary] = []
	var cases := [
		{
			"name": "default",
			"context": {},
			"expects_expanded": false,
		},
		{
			"name": "boss_expanded",
			"context": {
				"stage15_boss_room": true,
				"stage15_boss_name": "封印守卫",
				"stage15_boss_health": 72,
				"stage15_boss_max_health": 100,
			},
			"expects_expanded": true,
		},
	]
	for case: Dictionary in cases:
		_hud.call("_update_boss_meter", case["context"])
		_hud.call("_layout_runtime_hud_for_viewport", Vector2(viewport_size))
		await _wait_frames(3)
		var screenshot_path := "%s/%s_%dx%d.png" % [FRAME_VARIANT_DIR, case["name"], viewport_size.x, viewport_size.y]
		var screenshot := _save_full_screenshot(screenshot_path)
		var default_frame := _hud.get_node("BattlePanel/FrameArt") as TextureRect
		var expanded_frame := _hud.get_node("BattlePanel/FrameArtExpanded") as TextureRect
		var expects_expanded := bool(case["expects_expanded"])
		var visibility_ok := default_frame.visible != expects_expanded and expanded_frame.visible == expects_expanded
		variants.append({
			"name": case["name"],
			"viewport": [viewport_size.x, viewport_size.y],
			"screenshot": screenshot,
			"default_frame_visible": default_frame.visible,
			"expanded_frame_visible": expanded_frame.visible,
			"battle_panel_rect": _rect_to_report(_physical_rect(_hud.get_node("BattlePanel") as Control, float(_hud.call("_canvas_scale_for_physical_viewport", Vector2(viewport_size))))),
			"ok": bool(screenshot.get("ok", false)) and visibility_ok,
		})
	_hud.call("_update_boss_meter", {})
	_hud.process_mode = previous_process_mode
	return variants


func _content_safe_report() -> Dictionary:
	if not _hud.has_method("get_hud_content_safe_rects"):
		return {"ok": false, "violations": ["missing_get_hud_content_safe_rects"]}
	var safe_rects: Dictionary = _hud.call("get_hud_content_safe_rects")
	var controls_by_panel := {
		"PromptPanel": ["StepLabel", "PromptLabel"],
		"BattlePanel": [
			"HealthIcon", "StatusLabel", "HealthMeterFrameArt", "HealthBarBack", "HealthBarFill",
			"DashIcon", "DashLabel", "DashMeterFrameArt", "DashBarBack", "DashBarFill",
			"RecoveryChargeIcon", "RecoveryLabel", "RecoveryMeterFrameArt", "RecoveryBarBack", "RecoveryBarFill",
			"BossLabel", "BossMeterFrameArt", "BossBarBack", "BossBarFill", "ObjectiveIcon", "ProgressLabel",
		],
		"ElementPanel": [
			"ContentRoot/ElementGlyph",
			"ContentRoot/ElementLabel",
			"ContentRoot/StanceGlyph",
			"ContentRoot/StanceLabel",
			"ContentRoot/SequenceRoot",
		],
	}
	var violations: Array[String] = []
	var entries: Array[Dictionary] = []
	for panel_name_variant: Variant in controls_by_panel.keys():
		var panel_name := str(panel_name_variant)
		var panel := _hud.get_node_or_null(panel_name) as Panel
		var safe_rect: Rect2 = safe_rects.get(panel_name, Rect2())
		if panel == null or safe_rect.size.x <= 0.0 or safe_rect.size.y <= 0.0:
			violations.append("%s: missing panel or safe rect" % panel_name)
			continue
		for child_name_variant: Variant in controls_by_panel[panel_name]:
			var child_name := str(child_name_variant)
			var control := panel.get_node_or_null(child_name) as Control
			if control == null or not control.visible:
				continue
			var control_rect := Rect2(control.position, control.size)
			var enclosed := safe_rect.grow(0.05).encloses(control_rect)
			entries.append({
				"panel": panel_name,
				"control": child_name,
				"safe_rect": _rect_to_report(safe_rect),
				"control_rect": _rect_to_report(control_rect),
				"enclosed": enclosed,
			})
			if not enclosed:
				violations.append("%s/%s outside content-safe rect" % [panel_name, child_name])
	return {
		"ok": violations.is_empty(),
		"checked_control_count": entries.size(),
		"violations": violations,
		"entries": entries,
	}


func _capture_attention_pair(
	label: String,
	step_id: StringName,
	reduced_motion: bool,
	forced_elapsed: float,
	expect_crop_change: bool,
) -> Dictionary:
	_set_review_text(_state_title(label), _state_prompt(label))
	_hud.call("set_reduced_motion_enabled", reduced_motion)
	# 先切到其它步骤，确保同一 step 的复核也会重新进入目标状态。
	_hud.call("_set_attention_step", &"move_jump" if step_id != &"move_jump" else &"dash")
	_hud.call("_set_attention_step", step_id)
	if forced_elapsed > 0.0:
		_hud.call("_process", forced_elapsed)
	await _wait_frames(1)
	var first := _save_state_frame("%s_a" % label)
	await _wait_frames(8)
	var second := _save_state_frame("%s_b" % label)
	var crop_changed: bool = str(first.get("crop_sha256", "")) != str(second.get("crop_sha256", ""))
	var state_snapshot: Dictionary = _hud.call("get_tutorial_attention_snapshot")
	var expected_state := &"waiting" if label.contains("waiting") else StringName(label)
	var first_state: Dictionary = first.get("state_snapshot", {})
	var state_ok := StringName(str(first_state.get("state", ""))) == expected_state
	var ok: bool = (
		bool(first.get("ok", false))
		and bool(second.get("ok", false))
		and crop_changed == expect_crop_change
		and state_ok
	)
	return {
		"label": label,
		"expected_state": expected_state,
		"state_snapshot": state_snapshot,
		"reduced_motion": reduced_motion,
		"expect_crop_change": expect_crop_change,
		"crop_changed": crop_changed,
		"first": first,
		"second": second,
		"ok": ok,
	}


func _save_state_frame(stem: String) -> Dictionary:
	var full_path := "%s/%s.png" % [STATE_DIR, stem]
	var crop_path := "%s/%s.png" % [CROP_DIR, stem]
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.save_png(full_path) != OK:
		return {"ok": false, "full_path": full_path, "crop_path": crop_path}
	var attention := _hud.get_node("TutorialAttention") as Control
	var canvas_scale := float(_hud.call("_canvas_scale_for_physical_viewport", Vector2(INITIAL_VIEWPORT)))
	var crop_rect := _physical_rect(attention, canvas_scale).grow(2.0)
	var pixel_rect := Rect2i(
		Vector2i(floori(crop_rect.position.x), floori(crop_rect.position.y)),
		Vector2i(ceili(crop_rect.size.x), ceili(crop_rect.size.y)),
	).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var crop := image.get_region(pixel_rect)
	var crop_ok := crop != null and not crop.is_empty() and crop.save_png(crop_path) == OK
	var state_snapshot: Dictionary = _hud.call("get_tutorial_attention_snapshot")
	return {
		"ok": crop_ok,
		"full_path": full_path,
		"full_sha256": FileAccess.get_sha256(ProjectSettings.globalize_path(full_path)),
		"crop_path": crop_path,
		"crop_sha256": FileAccess.get_sha256(ProjectSettings.globalize_path(crop_path)) if crop_ok else "",
		"crop_rect": _rect_to_report(Rect2(pixel_rect)),
		"state_snapshot": state_snapshot,
	}


func _save_full_screenshot(path: String) -> Dictionary:
	if DisplayServer.get_name() == "headless":
		return {"ok": false, "path": path, "reason": "headless_display"}
	var image := root.get_texture().get_image()
	var ok := image != null and not image.is_empty() and image.save_png(path) == OK
	return {
		"ok": ok,
		"path": path,
		"sha256": FileAccess.get_sha256(ProjectSettings.globalize_path(path)) if ok else "",
	}


func _set_review_text(title: String, body: String) -> void:
	(_hud.get_node("PromptPanel/StepLabel") as Label).text = title
	(_hud.get_node("PromptPanel/PromptLabel") as Label).text = body
	_hud.call("_sync_prompt_panel_layout")


func _state_title(label: String) -> String:
	match label:
		"idle":
			return "教程 1/5 · 当前指引"
		"enter":
			return "教程 2/5 · 新步骤进入"
		"waiting":
			return "教程 3/5 · 等待操作"
		"complete":
			return "教程完成 · 封印已解"
		_:
			return "降低动态效果 · 静态提醒"


func _state_prompt(label: String) -> String:
	if label == "complete":
		return "出口已打开，继续进入实战。"
	if label.contains("waiting"):
		return "攻击：J / X。当前提示会低频呼吸，但不遮挡战斗画面。"
	return "移动、跳跃与冲刺提示共享同一条符光焦点。"


func _physical_rect(control: Control, canvas_scale: float) -> Rect2:
	return Rect2(control.position * canvas_scale, control.size * control.scale * canvas_scale)


func _rect_inside_viewport(rect: Rect2, viewport_size: Vector2i) -> bool:
	return (
		rect.position.x >= -0.1
		and rect.position.y >= -0.1
		and rect.end.x <= float(viewport_size.x) + 0.1
		and rect.end.y <= float(viewport_size.y) + 0.1
	)


func _rect_to_report(rect: Rect2) -> Dictionary:
	return {
		"x": rect.position.x,
		"y": rect.position.y,
		"width": rect.size.x,
		"height": rect.size.y,
		"right": rect.end.x,
		"bottom": rect.end.y,
	}


func _hide_demo_shell() -> void:
	var shell := _main.get_node_or_null("HUD/DemoShell")
	if shell == null:
		return
	for node_path: NodePath in ["MainMenu", "TitleBackground"]:
		var item := shell.get_node_or_null(node_path) as CanvasItem
		if item != null:
			item.visible = false


func _wait_frames(count: int) -> void:
	for _frame: int in range(count):
		await process_frame


func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write report: %s" % path)
		return
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
