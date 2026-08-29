# 符印共鸣盘真实窗口复核：固定捕获七档布局、五种语义状态、四组双帧反馈与两类上下文教程。
# 脚本只调用 HUD 的公开快照及既有翻译入口，不写 Player / Main 状态，也不把机器截图冒充真人签核。
extends SceneTree

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const OUT_DIR := "res://tests/artifacts/local/seal-resonance-hud"
const LAYOUT_DIR := "%s/layouts" % OUT_DIR
const STATE_DIR := "%s/semantic-states" % OUT_DIR
const FEEDBACK_DIR := "%s/feedback" % OUT_DIR
const TUTORIAL_DIR := "%s/tutorial" % OUT_DIR
const DESIGN_QA_DIR := "%s/design-qa" % OUT_DIR
const CROP_DIR := "%s/crops" % OUT_DIR
const PIXEL_GATE_DIR := "%s/pixel-gates" % OUT_DIR
const OUT_REPORT := "%s/seal_resonance_hud_review.json" % OUT_DIR
const ANCHOR_CONTRACT_PATH := "res://assets/art/ui/hud_seal_resonance_v2/seal_resonance_anchor_contract.json"
const REVIEW_VIEWPORT := Vector2i(1280, 720)
const FINAL_RASTER_FOCAL_TOLERANCE_LOGICAL_PX := 0.8
const FINAL_RASTER_FOCAL_TOLERANCE_PHYSICAL_PX := 1.25
const SEQUENCE_OPTICAL_PAIR_RATIO_RANGE := Vector2(0.94, 1.06)
# 低于 1x 逻辑缩放时 34px 反应印只剩约 27 个物理像素，离散采样会压缩光学比；
# 仍要求它不小于序列印，并在 1x 及以上恢复接近 34/29 的比例。
const REACTION_TO_SEQUENCE_OPTICAL_RATIO_RANGE := Vector2(1.05, 1.23)
const VIEWPORT_MATRIX := [
	Vector2i(640, 360),
	Vector2i(1024, 576),
	Vector2i(1280, 720),
	Vector2i(1672, 941),
	Vector2i(2048, 1152),
	Vector2i(2560, 1080),
	Vector2i(2560, 1440),
]
const SEMANTIC_CASES := [
	{
		"name": "idle_thunder_swift",
		"expected_state": &"idle",
		"snapshot": {"current_element_id": &"thunder", "current_stance_id": &"swift", "element_sequence": {}},
	},
	{
		"name": "idle_wind_ward",
		"expected_state": &"idle",
		"snapshot": {"current_element_id": &"wind", "current_stance_id": &"ward", "element_sequence": {}},
	},
	{
		"name": "primed_wind",
		"expected_state": &"primed",
		"snapshot": {"current_element_id": &"wind", "current_stance_id": &"swift", "element_sequence": {"element_ids": [&"wind"], "window_remaining": 1.4, "window_duration": 2.0}},
	},
	{
		"name": "resolved_wind_thunder",
		"expected_state": &"resolved",
		"snapshot": {"current_element_id": &"thunder", "current_stance_id": &"swift", "element_sequence": {"element_ids": [&"wind", &"thunder"], "window_remaining": 1.1, "window_duration": 2.0}},
	},
	{
		"name": "resolved_thunder_wind",
		"expected_state": &"resolved",
		"snapshot": {"current_element_id": &"wind", "current_stance_id": &"ward", "element_sequence": {"element_ids": [&"thunder", &"wind"], "window_remaining": 1.1, "window_duration": 2.0}},
	},
]
const TUTORIAL_STEPS := [
	{"id": &"move_jump", "title": "教程 1/5 · 移动与跳跃", "prompt": "移动与跳跃。"},
	{"id": &"dash", "title": "教程 2/5 · 冲刺穿门", "prompt": "冲刺穿过低顶门槛。"},
	{"id": &"attack", "title": "教程 3/5 · 基础攻击", "prompt": "攻击训练目标。"},
	{"id": &"stance", "title": "教程 4/5 · 疾御换印", "prompt": "姿态切换。"},
	{"id": &"exit", "title": "教程 5/5 · 离开教程区", "prompt": "离开教程区。"},
]

var _main: Node2D
var _hud: Control
var _seal_panel: Panel
var _captures: Array[Dictionary] = []
var _errors: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Seal resonance review requires a real window; headless display is rejected")
		quit(1)
		return
	for directory: String in [LAYOUT_DIR, STATE_DIR, FEEDBACK_DIR, TUTORIAL_DIR, DESIGN_QA_DIR, CROP_DIR, PIXEL_GATE_DIR]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	root.size = REVIEW_VIEWPORT

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
		push_error("TutorialHUD missing from production Main")
		quit(1)
		return
	_seal_panel = _hud.get_node_or_null("ElementPanel") as Panel
	if _seal_panel == null or not _seal_panel.has_method("apply_snapshot") or not _seal_panel.has_method("get_visual_snapshot"):
		push_error("Production ElementPanel is not SealResonanceHud")
		quit(1)
		return

	# 冻结世界逻辑，保留 HUD 子树的 Tween 与 Shader 时间；由本脚本显式喂入每个复核快照。
	_main.process_mode = Node.PROCESS_MODE_DISABLED
	_hud.process_mode = Node.PROCESS_MODE_ALWAYS
	_hud.set_process(false)
	_hud.set_process_input(false)
	_seal_panel.set_process(false)

	await _capture_layout_matrix()
	await _capture_semantic_states()
	await _capture_selected_option_qa_state()
	await _capture_glyph_pixel_gate_matrix()
	var feedback_pairs := await _capture_feedback_pairs()
	await _capture_five_step_tutorials()
	await _capture_wind_unlock_tutorial()

	var capture_ok := true
	for capture: Dictionary in _captures:
		capture_ok = capture_ok and bool(capture.get("ok", false))
	var feedback_ok := true
	for pair: Dictionary in feedback_pairs:
		feedback_ok = feedback_ok and bool(pair.get("ok", false))
	var category_counts := _category_counts()
	var required_counts_ok := (
		int(category_counts.get("layout", 0)) == VIEWPORT_MATRIX.size()
		and int(category_counts.get("semantic_state", 0)) == SEMANTIC_CASES.size()
		and int(category_counts.get("feedback", 0)) == 8
		and int(category_counts.get("tutorial_step", 0)) == TUTORIAL_STEPS.size() * 2
		and int(category_counts.get("wind_tutorial", 0)) == 3
		and int(category_counts.get("design_qa", 0)) == 1
		and int(category_counts.get("pixel_gate", 0)) == VIEWPORT_MATRIX.size() + 3
	)
	var report := {
		"review_id": "seal_resonance_hud_runtime_review",
		"generated_at": Time.get_datetime_string_from_system(true),
		"display_driver": DisplayServer.get_name(),
		"godot_version": Engine.get_version_info(),
		"viewport_matrix": VIEWPORT_MATRIX.map(func(size: Vector2i) -> Array[int]: return [size.x, size.y]),
		"capture_count": _captures.size(),
		"category_counts": category_counts,
		"captures": _captures,
		"feedback_pairs": feedback_pairs,
		"semantic_anchor_contract": ANCHOR_CONTRACT_PATH,
		"errors": _errors,
		"ok": capture_ok and feedback_ok and required_counts_ok and _errors.is_empty(),
		"boundary": "真实窗口机器证据包含五个圆框的 glyph-only 最终渲染 Alpha 质心、圆内余量、越界像素、文字区和连接带门槛；它仍不替代真人审美、物理阅读距离、实体手柄、来源条款、授权和 Gate26H。",
	}
	_write_json(OUT_REPORT, report)
	print(
		"seal_resonance_hud_review captures=%d layouts=%d states=%d feedback_frames=%d tutorial_frames=%d wind_frames=%d design_qa=%d pixel_gates=%d ok=%s report=%s"
		% [
			_captures.size(),
			int(category_counts.get("layout", 0)),
			int(category_counts.get("semantic_state", 0)),
			int(category_counts.get("feedback", 0)),
			int(category_counts.get("tutorial_step", 0)),
			int(category_counts.get("wind_tutorial", 0)),
			int(category_counts.get("design_qa", 0)),
			int(category_counts.get("pixel_gate", 0)),
			report["ok"],
			OUT_REPORT,
		]
	)
	_main.queue_free()
	await process_frame
	quit(0 if bool(report["ok"]) else 1)


func _capture_layout_matrix() -> void:
	_hud.call("set_reduced_motion_enabled", false)
	for viewport_size: Vector2i in VIEWPORT_MATRIX:
		root.size = viewport_size
		await _wait_frames(4)
		_hud.call("_layout_runtime_hud_for_viewport", Vector2(viewport_size))
		_seal_panel.call("apply_snapshot", SEMANTIC_CASES[2]["snapshot"])
		_hud.call("_layout_runtime_hud_for_viewport", Vector2(viewport_size))
		# 静态布局证据必须等待 0.22s 反馈 Tween 完全收束，不能把动画中间帧当圆心基准。
		await _wait_frames(18)
		var entry := _save_capture(
			"layout",
			"layout_%dx%d" % [viewport_size.x, viewport_size.y],
			LAYOUT_DIR,
			viewport_size,
			_seal_panel,
		)
		entry["expected_state"] = "primed"
		entry["ok"] = bool(entry["ok"]) and String(entry["visual_snapshot"].get("state", "")) == "primed"


func _capture_semantic_states() -> void:
	await _set_review_viewport()
	_hud.call("set_reduced_motion_enabled", false)
	for case: Dictionary in SEMANTIC_CASES:
		_seal_panel.call("apply_snapshot", case["snapshot"])
		_hud.call("_layout_runtime_hud_for_viewport", Vector2(REVIEW_VIEWPORT))
		await _wait_frames(18)
		var entry := _save_capture("semantic_state", String(case["name"]), STATE_DIR, REVIEW_VIEWPORT, _seal_panel)
		entry["expected_state"] = String(case["expected_state"])
		entry["ok"] = bool(entry["ok"]) and String(entry["visual_snapshot"].get("state", "")) == String(case["expected_state"])


# 设计 QA 使用与选定第 2 版完全一致的 1672x941 视口和“风→雷贯穿”状态。
func _capture_selected_option_qa_state() -> void:
	var viewport_size := Vector2i(1672, 941)
	root.size = viewport_size
	await _wait_frames(4)
	_hud.call("set_reduced_motion_enabled", false)
	_seal_panel.call("apply_snapshot", SEMANTIC_CASES[3]["snapshot"])
	_hud.call("_layout_runtime_hud_for_viewport", Vector2(viewport_size))
	await _wait_frames(18)
	var entry := _save_capture(
		"design_qa",
		"selected_option_02_resolved_1672x941",
		DESIGN_QA_DIR,
		viewport_size,
		_seal_panel,
	)
	entry["expected_state"] = "resolved"
	entry["ok"] = bool(entry["ok"]) and String(entry["visual_snapshot"].get("state", "")) == "resolved"


func _capture_glyph_pixel_gate_matrix() -> void:
	_hud.call("set_reduced_motion_enabled", false)
	for viewport_size: Vector2i in VIEWPORT_MATRIX:
		root.size = viewport_size
		await _wait_frames(4)
		_seal_panel.call("apply_snapshot", SEMANTIC_CASES[3]["snapshot"])
		_hud.call("_layout_runtime_hud_for_viewport", Vector2(viewport_size))
		await _wait_frames(18)
		await _save_glyph_layer(
			"resolved_%dx%d" % [viewport_size.x, viewport_size.y],
			viewport_size,
			"static_resolved_pierce",
		)

	# 反向序列使用另一枚反应图；必须单独复核，不能用贯穿印替它签核。
	await _set_review_viewport()
	_seal_panel.call("apply_snapshot", SEMANTIC_CASES[4]["snapshot"])
	await _wait_frames(18)
	await _save_glyph_layer("resolved_scatter_1280x720", REVIEW_VIEWPORT, "static_resolved_scatter")

	await _set_review_viewport()
	_seal_panel.call("apply_snapshot", SEMANTIC_CASES[0]["snapshot"])
	await _wait_frames(16)
	_seal_panel.call("apply_snapshot", {"current_element_id": &"wind", "current_stance_id": &"swift", "element_sequence": {}})
	await _wait_frames(1)
	await _save_glyph_layer("element_feedback_early", REVIEW_VIEWPORT, "element_feedback")

	_seal_panel.call("apply_snapshot", SEMANTIC_CASES[0]["snapshot"])
	await _wait_frames(16)
	_seal_panel.call("apply_snapshot", {"current_element_id": &"thunder", "current_stance_id": &"ward", "element_sequence": {}})
	await _wait_frames(1)
	await _save_glyph_layer("stance_feedback_early", REVIEW_VIEWPORT, "stance_feedback")


# 把生产 HUD 的真实 glyph 节点留在原 Canvas 变换中，隐藏其余 CanvasItem 并捕获透明背景最终像素。
func _save_glyph_layer(name: String, viewport_size: Vector2i, sample_kind: String) -> Dictionary:
	var prior_transparent := root.transparent_bg
	var visibility_states := _isolate_glyph_layer()
	root.transparent_bg = true
	await _wait_frames(2)
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [PIXEL_GATE_DIR, name]
	var saved := image != null and not image.is_empty() and image.save_png(path) == OK
	var pixel_report := _glyph_layer_pixel_report(image, viewport_size) if saved else {"ok": false, "error": "empty_or_unsaved_image"}
	_restore_canvas_visibility(visibility_states)
	root.transparent_bg = prior_transparent
	await _wait_frames(2)
	if not saved:
		_errors.append("%s: cannot save glyph-only pixel gate" % name)
	var entry := {
		"category": "pixel_gate",
		"name": name,
		"sample_kind": sample_kind,
		"viewport": [viewport_size.x, viewport_size.y],
		"path": path,
		"sha256": FileAccess.get_sha256(ProjectSettings.globalize_path(path)) if saved else "",
		"pixel_report": pixel_report,
		"ok": saved and bool(pixel_report.get("ok", false)),
	}
	_captures.append(entry)
	return entry


func _isolate_glyph_layer() -> Array[Dictionary]:
	var glyphs: Array[TextureRect] = [
		_hud.get_node("ElementPanel/ContentRoot/ElementGlyph") as TextureRect,
		_hud.get_node("ElementPanel/ContentRoot/StanceGlyph") as TextureRect,
		_hud.get_node("ElementPanel/ContentRoot/SequenceRoot/SequenceSlotA") as TextureRect,
		_hud.get_node("ElementPanel/ContentRoot/SequenceRoot/SequenceSlotB") as TextureRect,
		_hud.get_node("ElementPanel/ContentRoot/SequenceRoot/ReactionGlyph") as TextureRect,
	]
	var keep := {}
	for glyph: TextureRect in glyphs:
		var current: Node = glyph
		while current != null:
			keep[current] = true
			current = current.get_parent()
	var states: Array[Dictionary] = []
	for node: Node in _main.find_children("*", "CanvasItem", true, false):
		var item := node as CanvasItem
		if item == null or keep.has(item):
			continue
		states.append({"item": item, "visible": item.visible})
		item.visible = false
	return states


func _restore_canvas_visibility(states: Array[Dictionary]) -> void:
	for state: Dictionary in states:
		var item := state.get("item") as CanvasItem
		if is_instance_valid(item):
			item.visible = bool(state.get("visible", false))


func _glyph_layer_pixel_report(image: Image, viewport_size: Vector2i) -> Dictionary:
	if image == null or image.is_empty():
		return {"ok": false, "error": "empty_image"}
	var canvas_scale := float(_hud.call("_canvas_scale_for_physical_viewport", Vector2(viewport_size)))
	var panel_transform := _seal_panel.get_global_transform_with_canvas()
	var logical_to_physical := maxf(panel_transform.x.length(), panel_transform.y.length()) * canvas_scale
	if logical_to_physical <= 0.0:
		return {"ok": false, "error": "invalid_panel_scale"}
	var semantic := _seal_panel.call("get_semantic_anchor_report") as Dictionary
	var anchors := semantic.get("anchors", {}) as Dictionary
	var entries := {}
	var all_ok := true
	var visible_count := 0
	for role: String in anchors:
		var anchor := anchors[role] as Dictionary
		if not bool(anchor.get("visible", false)):
			continue
		visible_count += 1
		var target_local := _array_to_vector2(anchor.get("target_center", [0.0, 0.0]))
		var target_physical := (panel_transform * target_local) * canvas_scale
		var circle_radius := float(anchor.get("circle_inner_radius", 0.0))
		var radius_physical := circle_radius * logical_to_physical
		var metrics := _alpha_metrics_in_circle(image, target_physical, radius_physical, logical_to_physical)
		entries[role] = metrics
		all_ok = all_ok and bool(metrics.get("ok", false))
	var optical_scale_gate := _sequence_optical_scale_gate(entries)
	all_ok = all_ok and bool(optical_scale_gate.get("ok", false))
	return {
		"alpha_core_threshold": 16,
		"focal_tolerance_logical_px": FINAL_RASTER_FOCAL_TOLERANCE_LOGICAL_PX,
		"focal_tolerance_physical_px": FINAL_RASTER_FOCAL_TOLERANCE_PHYSICAL_PX,
		"minimum_core_inset_logical_px": 2.0,
		"visible_anchor_count": visible_count,
		"anchors": entries,
		"sequence_optical_scale_gate": optical_scale_gate,
		"ok": all_ok and visible_count >= 2,
	}


func _alpha_metrics_in_circle(image: Image, center: Vector2, radius_physical: float, logical_to_physical: float) -> Dictionary:
	var extent := ceili(radius_physical + logical_to_physical * 3.0)
	var bounds := Rect2i(
		Vector2i(floori(center.x) - extent, floori(center.y) - extent),
		Vector2i(extent * 2 + 1, extent * 2 + 1),
	).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var weighted_sum := Vector2.ZERO
	var weight_total := 0.0
	var core_points: Array[Vector2] = []
	for y: int in range(bounds.position.y, bounds.end.y):
		for x: int in range(bounds.position.x, bounds.end.x):
			var alpha := image.get_pixel(x, y).a
			if roundi(alpha * 255.0) < 16:
				continue
			var point := Vector2(x + 0.5, y + 0.5)
			weighted_sum += point * alpha
			weight_total += alpha
			core_points.append(point)
	if core_points.is_empty() or is_zero_approx(weight_total):
		return {"ok": false, "error": "no_core_pixels", "core_pixel_count": 0}
	var centroid := weighted_sum / weight_total
	var weighted_radii: Array[Vector2] = []
	var max_radius_physical := 0.0
	var outside_inset_circle := 0
	var inset_radius_physical := radius_physical - 2.0 * logical_to_physical
	for point: Vector2 in core_points:
		var radius := point.distance_to(centroid)
		max_radius_physical = maxf(max_radius_physical, radius)
		weighted_radii.append(Vector2(radius, image.get_pixelv(Vector2i(floori(point.x), floori(point.y))).a))
		if point.distance_to(center) > inset_radius_physical + 0.001:
			outside_inset_circle += 1
	var focal_error_physical := centroid.distance_to(center)
	var focal_error := focal_error_physical / logical_to_physical
	# 栅格质心只能落在像素中心；同时记录到目标附近最近可表示像素中心的误差，
	# 避免把纯粹的半像素量化误判为资产错位。
	var quantized_focal_error_physical := 999.0
	for candidate_x: int in [floori(center.x), ceili(center.x)]:
		for candidate_y: int in [floori(center.y), ceili(center.y)]:
			quantized_focal_error_physical = minf(
				quantized_focal_error_physical,
				centroid.distance_to(Vector2(candidate_x + 0.5, candidate_y + 0.5)),
			)
	weighted_radii.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	var accumulated_weight := 0.0
	var robust_radius_physical := 0.0
	for sample: Vector2 in weighted_radii:
		accumulated_weight += sample.y
		if accumulated_weight >= weight_total * 0.95:
			robust_radius_physical = sample.x
			break
	var equivalent_alpha_radius_physical := sqrt(weight_total / PI)
	var optical_radius_logical := sqrt(robust_radius_physical * equivalent_alpha_radius_physical) / logical_to_physical
	var core_radius := max_radius_physical / logical_to_physical
	var circle_radius := radius_physical / logical_to_physical
	var core_inset := circle_radius - core_radius
	return {
		"target_center_physical": _vector_to_report(center),
		"alpha_centroid_physical": _vector_to_report(centroid),
		"focal_error_logical_px": focal_error,
		"focal_error_physical_px": focal_error_physical,
		"quantized_focal_error_physical_px": quantized_focal_error_physical,
		"optical_radius_logical_px": optical_radius_logical,
		"core_radius_logical_px": core_radius,
		"circle_inner_radius_logical_px": circle_radius,
		"core_inset_logical_px": core_inset,
		"outside_inset_circle_core_pixels": outside_inset_circle,
		"core_pixel_count": core_points.size(),
		"ok": (
			(
				quantized_focal_error_physical <= FINAL_RASTER_FOCAL_TOLERANCE_PHYSICAL_PX
				or (
					circle_radius >= 30.0
					and focal_error <= 1.1
					and focal_error_physical <= 2.25
				)
			)
			and core_inset + 0.001 >= 2.0
			and outside_inset_circle == 0
		),
	}


func _sequence_optical_scale_gate(entries: Dictionary) -> Dictionary:
	for role: String in [&"sequence_a", &"sequence_b", &"reaction"]:
		if not entries.has(role):
			return {"applicable": false, "ok": true}
	var sequence_a := float((entries[&"sequence_a"] as Dictionary).get("optical_radius_logical_px", 0.0))
	var sequence_b := float((entries[&"sequence_b"] as Dictionary).get("optical_radius_logical_px", 0.0))
	var reaction := float((entries[&"reaction"] as Dictionary).get("optical_radius_logical_px", 0.0))
	if sequence_a <= 0.0 or sequence_b <= 0.0 or reaction <= 0.0:
		return {"applicable": true, "ok": false, "error": "invalid_optical_radius"}
	var pair_ratio := sequence_a / sequence_b
	var reaction_ratio := reaction / ((sequence_a + sequence_b) * 0.5)
	return {
		"applicable": true,
		"sequence_a_optical_radius_logical_px": sequence_a,
		"sequence_b_optical_radius_logical_px": sequence_b,
		"reaction_optical_radius_logical_px": reaction,
		"sequence_pair_ratio": pair_ratio,
		"sequence_pair_ratio_range": [SEQUENCE_OPTICAL_PAIR_RATIO_RANGE.x, SEQUENCE_OPTICAL_PAIR_RATIO_RANGE.y],
		"reaction_to_sequence_ratio": reaction_ratio,
		"reaction_to_sequence_ratio_range": [REACTION_TO_SEQUENCE_OPTICAL_RATIO_RANGE.x, REACTION_TO_SEQUENCE_OPTICAL_RATIO_RANGE.y],
		"ok": (
			pair_ratio >= SEQUENCE_OPTICAL_PAIR_RATIO_RANGE.x
			and pair_ratio <= SEQUENCE_OPTICAL_PAIR_RATIO_RANGE.y
			and reaction_ratio >= REACTION_TO_SEQUENCE_OPTICAL_RATIO_RANGE.x
			and reaction_ratio <= REACTION_TO_SEQUENCE_OPTICAL_RATIO_RANGE.y
		),
	}


func _array_to_vector2(value: Variant) -> Vector2:
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO


func _capture_feedback_pairs() -> Array[Dictionary]:
	await _set_review_viewport()
	var pairs: Array[Dictionary] = []

	_hud.call("set_reduced_motion_enabled", false)
	_seal_panel.call("apply_snapshot", SEMANTIC_CASES[0]["snapshot"])
	await _wait_frames(16)
	_seal_panel.call("apply_snapshot", {"current_element_id": &"wind", "current_stance_id": &"swift", "element_sequence": {}})
	await _wait_frames(1)
	var element_a := _save_capture("feedback", "element_switch_a", FEEDBACK_DIR, REVIEW_VIEWPORT, _hud.get_node("ElementPanel/ContentRoot/ElementGlyph") as Control)
	await _wait_frames(12)
	var element_b := _save_capture("feedback", "element_switch_b", FEEDBACK_DIR, REVIEW_VIEWPORT, _hud.get_node("ElementPanel/ContentRoot/ElementGlyph") as Control)
	pairs.append(_feedback_pair("element_switch", element_a, element_b, true))

	_seal_panel.call("apply_snapshot", {"current_element_id": &"wind", "current_stance_id": &"swift", "element_sequence": {}})
	await _wait_frames(16)
	_seal_panel.call("apply_snapshot", {"current_element_id": &"wind", "current_stance_id": &"ward", "element_sequence": {}})
	await _wait_frames(1)
	var stance_a := _save_capture("feedback", "stance_switch_a", FEEDBACK_DIR, REVIEW_VIEWPORT, _hud.get_node("ElementPanel/ContentRoot/StanceGlyph") as Control)
	await _wait_frames(12)
	var stance_b := _save_capture("feedback", "stance_switch_b", FEEDBACK_DIR, REVIEW_VIEWPORT, _hud.get_node("ElementPanel/ContentRoot/StanceGlyph") as Control)
	pairs.append(_feedback_pair("stance_switch", stance_a, stance_b, true))

	var primed_snapshot: Dictionary = SEMANTIC_CASES[2]["snapshot"]
	_seal_panel.call("apply_snapshot", primed_snapshot)
	_hud.call("_layout_runtime_hud_for_viewport", Vector2(REVIEW_VIEWPORT))
	await _wait_frames(2)
	var link_a := _save_capture("feedback", "sequence_link_a", FEEDBACK_DIR, REVIEW_VIEWPORT, _hud.get_node("ElementPanel/ContentRoot/SequenceRoot/SequenceLink") as Control)
	await _wait_frames(12)
	var link_b := _save_capture("feedback", "sequence_link_b", FEEDBACK_DIR, REVIEW_VIEWPORT, _hud.get_node("ElementPanel/ContentRoot/SequenceRoot/SequenceLink") as Control)
	pairs.append(_feedback_pair("sequence_link", link_a, link_b, true))

	_hud.call("set_reduced_motion_enabled", true)
	_seal_panel.call("apply_snapshot", primed_snapshot)
	await _wait_frames(2)
	var reduced_a := _save_capture("feedback", "reduced_motion_a", FEEDBACK_DIR, REVIEW_VIEWPORT, _hud.get_node("ElementPanel/ContentRoot/SequenceRoot/SequenceLink") as Control)
	await _wait_frames(12)
	var reduced_b := _save_capture("feedback", "reduced_motion_b", FEEDBACK_DIR, REVIEW_VIEWPORT, _hud.get_node("ElementPanel/ContentRoot/SequenceRoot/SequenceLink") as Control)
	pairs.append(_feedback_pair("reduced_motion", reduced_a, reduced_b, false))
	_hud.call("set_reduced_motion_enabled", false)
	return pairs


func _capture_five_step_tutorials() -> void:
	await _set_review_viewport()
	_seal_panel.call("apply_snapshot", SEMANTIC_CASES[0]["snapshot"])
	for mode: String in ["keyboard", "controller"]:
		_set_input_mode(mode)
		for step: Dictionary in TUTORIAL_STEPS:
			_hud.call("_render_room_context", {
				"step_id": step["id"],
				"step_title": step["title"],
				"prompt_text": step["prompt"],
			})
			await _wait_frames(2)
			var entry := _save_capture(
				"tutorial_step",
				"tutorial_%s_%s" % [mode, String(step["id"])],
				TUTORIAL_DIR,
				REVIEW_VIEWPORT,
				_hud.get_node("PromptPanel") as Control,
			)
			entry["tutorial_snapshot"] = _hud.call("get_contextual_tutorial_snapshot")
			entry["expected_input_mode"] = mode
			entry["ok"] = (
				bool(entry["ok"])
				and String(entry["tutorial_snapshot"].get("step_id", "")) == String(step["id"])
				and String(entry["tutorial_snapshot"].get("input_mode", "")) == mode
			)


func _capture_wind_unlock_tutorial() -> void:
	await _set_review_viewport()
	_set_input_mode("keyboard")
	_hud.call("_apply_room_context", {
		"step_id": &"exit",
		"step_title": "城墙甬道 · 继续推进",
		"prompt_text": "出口已打开，继续向右。",
	})
	_hud.call("_sync_wind_switch_tutorial", {"wind_seal_unlocked": false, "current_element_id": &"thunder"})
	_hud.call("_sync_wind_switch_tutorial", {"wind_seal_unlocked": true, "current_element_id": &"wind"})
	await _wait_frames(2)
	var keyboard := _save_capture("wind_tutorial", "wind_unlock_keyboard", TUTORIAL_DIR, REVIEW_VIEWPORT, _hud.get_node("PromptPanel") as Control)
	keyboard["tutorial_snapshot"] = _hud.call("get_contextual_tutorial_snapshot")
	keyboard["ok"] = bool(keyboard["ok"]) and bool(keyboard["tutorial_snapshot"].get("active", false)) and String(keyboard["tutorial_snapshot"].get("input_mode", "")) == "keyboard" and String(keyboard["tutorial_snapshot"].get("body", "")).contains("Q")

	_set_input_mode("controller")
	await _wait_frames(2)
	var controller := _save_capture("wind_tutorial", "wind_unlock_controller", TUTORIAL_DIR, REVIEW_VIEWPORT, _hud.get_node("PromptPanel") as Control)
	controller["tutorial_snapshot"] = _hud.call("get_contextual_tutorial_snapshot")
	controller["ok"] = bool(controller["ok"]) and bool(controller["tutorial_snapshot"].get("active", false)) and String(controller["tutorial_snapshot"].get("input_mode", "")) == "controller" and String(controller["tutorial_snapshot"].get("body", "")).contains("LB / L1")

	_hud.call("_sync_wind_switch_tutorial", {"wind_seal_unlocked": true, "current_element_id": &"thunder"})
	await _wait_frames(2)
	var restored := _save_capture("wind_tutorial", "wind_switch_room_prompt_restored", TUTORIAL_DIR, REVIEW_VIEWPORT, _hud.get_node("PromptPanel") as Control)
	restored["tutorial_snapshot"] = _hud.call("get_contextual_tutorial_snapshot")
	restored["ok"] = (
		bool(restored["ok"])
		and not bool(restored["tutorial_snapshot"].get("active", true))
		and String(restored["tutorial_snapshot"].get("title", "")) == "城墙甬道 · 继续推进"
		and String(restored["tutorial_snapshot"].get("step_id", "")) == "exit"
	)


# 每张正式图统一记录散列、物理矩形、安全区、FrameArt、glyph、Shader 与三面板相交关系。
func _save_capture(category: String, name: String, directory: String, viewport_size: Vector2i, crop_control: Control) -> Dictionary:
	var full_path := "%s/%s.png" % [directory, name]
	var crop_path := "%s/%s_crop.png" % [CROP_DIR, name]
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.save_png(full_path) != OK:
		_errors.append("%s: cannot save full screenshot" % name)
		var failed := {"category": category, "name": name, "ok": false, "path": full_path}
		_captures.append(failed)
		return failed

	var canvas_scale := float(_hud.call("_canvas_scale_for_physical_viewport", Vector2(viewport_size)))
	var crop_rect := _physical_global_rect(crop_control, canvas_scale).grow(2.0)
	var pixel_rect := Rect2i(
		Vector2i(floori(crop_rect.position.x), floori(crop_rect.position.y)),
		Vector2i(maxi(ceili(crop_rect.size.x), 1), maxi(ceili(crop_rect.size.y), 1)),
	).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var crop := image.get_region(pixel_rect)
	var crop_ok := crop != null and not crop.is_empty() and crop.save_png(crop_path) == OK
	if not crop_ok:
		_errors.append("%s: cannot save crop" % name)

	var battle_rect := _physical_global_rect(_hud.get_node("BattlePanel") as Control, canvas_scale)
	var prompt_rect := _physical_global_rect(_hud.get_node("PromptPanel") as Control, canvas_scale)
	var element_rect := _physical_global_rect(_seal_panel, canvas_scale)
	var safe_rects: Dictionary = _hud.call("get_hud_content_safe_rects")
	var element_safe_local: Rect2 = safe_rects.get("ElementPanel", Rect2())
	var element_safe_physical := Rect2(
		(element_rect.position + element_safe_local.position * _seal_panel.scale.x * canvas_scale),
		element_safe_local.size * _seal_panel.scale.x * canvas_scale,
	)
	var visual_snapshot: Dictionary = _seal_panel.call("get_visual_snapshot")
	var semantic_anchor_gate := visual_snapshot.get("semantic_anchor_report", {}) as Dictionary
	var semantic_anchor_ok := bool(semantic_anchor_gate.get("ok", false))
	var frame_report := _frame_report(element_rect)
	var entry := {
		"category": category,
		"name": name,
		"viewport": [viewport_size.x, viewport_size.y],
		"path": full_path,
		"sha256": FileAccess.get_sha256(ProjectSettings.globalize_path(full_path)),
		"image_size": [image.get_width(), image.get_height()],
		"crop_path": crop_path,
		"crop_sha256": FileAccess.get_sha256(ProjectSettings.globalize_path(crop_path)) if crop_ok else "",
		"crop_rect": _rect_to_report(Rect2(pixel_rect)),
		"element_rect": _rect_to_report(element_rect),
		"content_safe_rect": _rect_to_report(element_safe_physical),
		"frame_art": frame_report,
		"glyphs": _glyph_report(),
		"shader": _shader_report(),
		"visual_snapshot": visual_snapshot,
		"semantic_anchor_gate": semantic_anchor_gate,
		"intersects_battle": element_rect.intersects(battle_rect),
		"intersects_prompt": element_rect.intersects(prompt_rect),
		"battle_rect": _rect_to_report(battle_rect),
		"prompt_rect": _rect_to_report(prompt_rect),
		"inside_viewport": _rect_inside_viewport(element_rect, viewport_size),
		"ok": crop_ok and semantic_anchor_ok and not element_rect.intersects(battle_rect) and not element_rect.intersects(prompt_rect) and _rect_inside_viewport(element_rect, viewport_size),
	}
	_captures.append(entry)
	return entry


func _frame_report(element_rect: Rect2) -> Dictionary:
	var idle := _hud.get_node("ElementPanel/FrameArt") as TextureRect
	var active := _hud.get_node("ElementPanel/FrameArtActive") as TextureRect
	return {
		"idle_visible": idle.visible,
		"active_visible": active.visible,
		"idle_path": idle.texture.resource_path if idle.texture != null else "",
		"active_path": active.texture.resource_path if active.texture != null else "",
		"idle_stretch_mode": idle.stretch_mode,
		"active_stretch_mode": active.stretch_mode,
		"visible_draw_rect": _rect_to_report(_keep_aspect_draw_rect(active.texture if active.visible else idle.texture, element_rect)),
	}


func _glyph_report() -> Dictionary:
	var paths := {
		"element": "ElementPanel/ContentRoot/ElementGlyph",
		"stance": "ElementPanel/ContentRoot/StanceGlyph",
		"sequence_a": "ElementPanel/ContentRoot/SequenceRoot/SequenceSlotA",
		"sequence_b": "ElementPanel/ContentRoot/SequenceRoot/SequenceSlotB",
		"reaction": "ElementPanel/ContentRoot/SequenceRoot/ReactionGlyph",
	}
	var report := {}
	for role: String in paths:
		var glyph := _hud.get_node(paths[role]) as TextureRect
		report[role] = {
			"visible": glyph.visible and glyph.is_visible_in_tree(),
			"path": glyph.texture.resource_path if glyph.texture != null else "",
			"stretch_mode": glyph.stretch_mode,
		}
	return report


func _shader_report() -> Dictionary:
	var link := _hud.get_node("ElementPanel/ContentRoot/SequenceRoot/SequenceLink") as ColorRect
	var material := link.material as ShaderMaterial
	return {
		"shader_path": material.shader.resource_path if material != null and material.shader != null else "",
		"window_ratio": float(material.get_shader_parameter("window_ratio")) if material != null else -1.0,
		"motion_amount": float(material.get_shader_parameter("motion_amount")) if material != null else -1.0,
		"reaction_mode": float(material.get_shader_parameter("reaction_mode")) if material != null else -1.0,
	}


func _feedback_pair(label: String, first: Dictionary, second: Dictionary, expect_change: bool) -> Dictionary:
	var changed := String(first.get("crop_sha256", "")) != String(second.get("crop_sha256", ""))
	return {
		"label": label,
		"first_crop_sha256": first.get("crop_sha256", ""),
		"second_crop_sha256": second.get("crop_sha256", ""),
		"expect_change": expect_change,
		"changed": changed,
		"ok": bool(first.get("ok", false)) and bool(second.get("ok", false)) and changed == expect_change,
	}


func _set_input_mode(mode: String) -> void:
	if mode == "controller":
		var joy_event := InputEventJoypadButton.new()
		joy_event.button_index = JOY_BUTTON_RIGHT_SHOULDER
		joy_event.pressed = true
		_hud.call("_input", joy_event)
		return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = KEY_E
	key_event.pressed = true
	_hud.call("_input", key_event)


func _set_review_viewport() -> void:
	root.size = REVIEW_VIEWPORT
	await _wait_frames(4)
	_hud.call("_layout_runtime_hud_for_viewport", Vector2(REVIEW_VIEWPORT))


func _physical_global_rect(control: Control, canvas_scale: float) -> Rect2:
	var global_rect := control.get_global_rect()
	return Rect2(global_rect.position * canvas_scale, global_rect.size * canvas_scale)


func _keep_aspect_draw_rect(texture: Texture2D, container_rect: Rect2) -> Rect2:
	if texture == null or container_rect.size.x <= 0.0 or container_rect.size.y <= 0.0:
		return Rect2()
	var texture_ratio := float(texture.get_width()) / maxf(float(texture.get_height()), 1.0)
	var container_ratio := container_rect.size.x / maxf(container_rect.size.y, 1.0)
	var draw_size := container_rect.size
	if texture_ratio >= container_ratio:
		draw_size.y = draw_size.x / texture_ratio
	else:
		draw_size.x = draw_size.y * texture_ratio
	return Rect2(container_rect.position + (container_rect.size - draw_size) * 0.5, draw_size)


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


func _vector_to_report(value: Vector2) -> Array[float]:
	return [value.x, value.y]


func _category_counts() -> Dictionary:
	var counts := {}
	for capture: Dictionary in _captures:
		var category := String(capture.get("category", "unknown"))
		counts[category] = int(counts.get(category, 0)) + 1
	return counts


func _hide_demo_shell() -> void:
	var shell := _main.get_node_or_null("HUD/DemoShell")
	if shell == null:
		return
	for node_path: NodePath in ["MainMenu", "TitleBackground", "PauseMenu", "FailurePanel", "CompletionPanel"]:
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
