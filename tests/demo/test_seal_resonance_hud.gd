extends GutTest

# 符印共鸣盘红测：锁定公开快照翻译、两种反应语义和降低动态效果边界。

const HUD_SCENE_PATH := "res://scenes/ui/tutorial_hud.tscn"
const ANCHOR_CONTRACT_PATH := "res://assets/art/ui/hud_seal_resonance_v2/seal_resonance_anchor_contract.json"
const SYMBOL_ATLAS_PATH := "res://assets/art/ui/hud_seal_resonance_v2/seal_resonance_symbols_warden_ai02.png"
const ICON_MASK_SHADER_PATH := "res://assets/shaders/ui/seal_resonance_icon_circle_mask.gdshader"
const ANCHOR_TOLERANCE := 0.5
const ALPHA_CORE_THRESHOLD := 16
const SYMBOL_CELL_SIZE := Vector2i(256, 256)
const SYMBOL_FOCAL_POINT := Vector2(128.0, 128.0)
const SYMBOL_FOCAL_TOLERANCE := 0.5
const FINAL_RASTER_FOCAL_TOLERANCE_LOGICAL := 0.8
const FINAL_RASTER_FOCAL_TOLERANCE_PHYSICAL := 1.25
const SYMBOL_OPTICAL_RADIUS_MIN := 57.0
const SYMBOL_OPTICAL_RADIUS_MAX := 63.0
const SYMBOL_OPTICAL_PAIR_RATIO_MIN := 0.96
const SYMBOL_OPTICAL_PAIR_RATIO_MAX := 1.04
const REACTION_TO_SEQUENCE_OPTICAL_RATIO_MIN := 1.14
const REACTION_TO_SEQUENCE_OPTICAL_RATIO_MAX := 1.21
const SYMBOL_DARK_INTERIOR_LUMA_MAX := 0.12
const SYMBOL_DARK_INTERIOR_ALPHA_MIN := 96
const SYMBOL_DARK_COMPONENT_MAX_AREA := 2
const SYMBOL_DARK_COMPONENT_MAX_COUNT := 0
const MICRO_GLYPH_SAMPLE_SIZES := [29, 34]
const MICRO_GLYPH_MIN_EDGE_CONTRAST := 0.18
const LABEL_CIRCLE_GAP := 8.0
const IDLE_ANCHORS := {
	"element": {"path": "ContentRoot/ElementGlyph", "center": Vector2(64.75, 51.25), "radius": 30.0, "size": Vector2(60.0, 60.0), "slot": Rect2(34.75, 21.25, 60.0, 60.0)},
	"stance": {"path": "ContentRoot/StanceGlyph", "center": Vector2(144.75, 53.25), "radius": 18.0, "size": Vector2(36.0, 36.0), "slot": Rect2(126.75, 35.25, 36.0, 36.0)},
}
const ACTIVE_ANCHORS := {
	"element": {"path": "ContentRoot/ElementGlyph", "center": Vector2(58.5, 54.0), "radius": 31.0, "size": Vector2(62.0, 62.0), "slot": Rect2(27.5, 23.0, 62.0, 62.0)},
	"stance": {"path": "ContentRoot/StanceGlyph", "center": Vector2(140.25, 55.75), "radius": 19.0, "size": Vector2(38.0, 38.0), "slot": Rect2(121.25, 36.75, 38.0, 38.0)},
	"sequence_a": {"path": "ContentRoot/SequenceRoot/SequenceSlotA", "center": Vector2(158.0, 124.5), "radius": 14.5, "size": Vector2(29.0, 29.0), "slot": Rect2(143.5, 110.0, 29.0, 29.0)},
	"sequence_b": {"path": "ContentRoot/SequenceRoot/SequenceSlotB", "center": Vector2(216.25, 124.5), "radius": 14.5, "size": Vector2(29.0, 29.0), "slot": Rect2(201.75, 110.0, 29.0, 29.0)},
	"reaction": {"path": "ContentRoot/SequenceRoot/ReactionGlyph", "center": Vector2(287.0, 126.0), "radius": 17.0, "size": Vector2(34.0, 34.0), "slot": Rect2(270.0, 109.0, 34.0, 34.0)},
}
const ACTIVE_LABEL_ZONES := {
	"ElementLabel": Rect2(172.0, 14.0, 42.0, 34.0),
	"StanceLabel": Rect2(170.0, 46.0, 48.0, 32.0),
	"ReactionLabel": Rect2(164.0, 76.0, 54.0, 24.0),
}
const ACTIVE_LINK_CORRIDOR := Rect2(174.0, 104.5, 25.0, 40.0)


func test_idle_primed_and_resolved_snapshots_hide_input_and_debug_copy() -> void:
	var panel := await _spawn_panel()
	assert_true(panel.has_method("apply_snapshot"), "ElementPanel 必须挂载 SealResonanceHud。")
	assert_true(panel.has_method("get_visual_snapshot"), "SealResonanceHud 必须公开可验证的视觉快照。")
	if not panel.has_method("apply_snapshot") or not panel.has_method("get_visual_snapshot"):
		return

	panel.call("apply_snapshot", _snapshot(&"thunder", &"swift", [], 0.0, 2.0))
	var idle: Dictionary = panel.call("get_visual_snapshot")
	assert_eq(idle.get("state"), &"idle")
	assert_eq(idle.get("size"), Vector2(232.0, 116.0))
	assert_eq(idle.get("element_id"), &"thunder")
	assert_eq(idle.get("stance_id"), &"swift")
	assert_false(str(idle.get("visible_text", "")).contains("Q"))
	assert_false(str(idle.get("visible_text", "")).contains("E"))
	assert_false(str(idle.get("visible_text", "")).contains("序列："))

	panel.call("apply_snapshot", _snapshot(&"wind", &"ward", [&"wind"], 9.0, 2.0))
	var primed: Dictionary = panel.call("get_visual_snapshot")
	assert_eq(primed.get("state"), &"primed")
	assert_eq(primed.get("size"), Vector2(324.0, 156.0))
	assert_eq(float(primed.get("window_ratio", -1.0)), 1.0)

	panel.call("apply_snapshot", _snapshot(&"thunder", &"ward", [&"wind", &"thunder"], -1.0, 2.0))
	var resolved: Dictionary = panel.call("get_visual_snapshot")
	assert_eq(resolved.get("state"), &"resolved")
	assert_eq(resolved.get("size"), Vector2(324.0, 156.0))
	assert_eq(float(resolved.get("window_ratio", -1.0)), 0.0)
	assert_eq(resolved.get("reaction_id"), &"wind_thunder_pierce")

	panel.call("apply_snapshot", _snapshot(&"wind", &"ward", [&"thunder", &"wind"], 1.0, 2.0))
	var reverse: Dictionary = panel.call("get_visual_snapshot")
	assert_eq(reverse.get("reaction_id"), &"thunder_wind_scatter")
	assert_ne(reverse.get("reaction_id"), resolved.get("reaction_id"), "反应顺序不能只替换显示文字。")


func test_selected_command_seal_layout_keeps_every_semantic_mark_readable() -> void:
	var panel := await _spawn_panel()
	assert_true(panel.has_method("apply_snapshot"))
	if not panel.has_method("apply_snapshot"):
		return

	panel.call("apply_snapshot", _snapshot(&"thunder", &"swift", [], 0.0, 2.0))
	var element_glyph := panel.get_node("ContentRoot/ElementGlyph") as TextureRect
	var stance_glyph := panel.get_node("ContentRoot/StanceGlyph") as TextureRect
	var element_label := panel.get_node("ContentRoot/ElementLabel") as Label
	var stance_label := panel.get_node("ContentRoot/StanceLabel") as Label
	assert_eq(element_glyph.size, Vector2(60.0, 60.0), "idle 主元素印必须使用冻结内圆直径。")
	assert_eq(stance_glyph.size, Vector2(36.0, 36.0), "idle 姿态印必须使用冻结内圆直径。")
	assert_gte(element_label.get_theme_font_size("font_size"), 26)
	assert_gte(stance_label.get_theme_font_size("font_size"), 20)

	panel.call("apply_snapshot", _snapshot(&"thunder", &"swift", [&"wind", &"thunder"], 1.0, 2.0))
	var slot_a := panel.get_node("ContentRoot/SequenceRoot/SequenceSlotA") as TextureRect
	var slot_b := panel.get_node("ContentRoot/SequenceRoot/SequenceSlotB") as TextureRect
	var reaction := panel.get_node("ContentRoot/SequenceRoot/ReactionGlyph") as TextureRect
	var link := panel.get_node("ContentRoot/SequenceRoot/SequenceLink") as ColorRect
	assert_eq(element_glyph.size, Vector2(62.0, 62.0), "active 主元素印必须使用冻结内圆直径。")
	assert_eq(stance_glyph.size, Vector2(38.0, 38.0), "active 姿态印必须使用冻结内圆直径。")
	assert_eq(slot_a.size, Vector2(29.0, 29.0), "第一序列印必须使用冻结内圆直径。")
	assert_eq(slot_b.size, Vector2(29.0, 29.0), "第二序列印必须使用冻结内圆直径。")
	assert_eq(reaction.size, Vector2(34.0, 34.0), "反应印必须使用冻结内圆直径。")
	assert_gte(link.size.y, 40.0, "灵力链需要足够厚的可视轨道承载衰减和方向。")


func test_v2_anchor_contract_freezes_reference_and_native_to_logical_mapping() -> void:
	assert_true(FileAccess.file_exists(ANCHOR_CONTRACT_PATH), "五语义锚点必须有独立机器可读合同，不能只散落在脚本坐标中。")
	if not FileAccess.file_exists(ANCHOR_CONTRACT_PATH):
		return
	var parsed_variant: Variant = JSON.parse_string(FileAccess.get_file_as_string(ANCHOR_CONTRACT_PATH))
	assert_true(parsed_variant is Dictionary, "锚点合同必须是合法 JSON object。")
	if not parsed_variant is Dictionary:
		return
	var contract := parsed_variant as Dictionary
	assert_eq(String(contract.get("contract_id", "")), "seal_resonance_semantic_anchors_v2")
	assert_eq(int(contract.get("schema_version", 0)), 2)
	assert_eq(
		String((contract.get("reference", {}) as Dictionary).get("sha256", "")),
		"3d25aee0f20cd7a7302962b1444f88ec2620cce19ac4b1b72183e29fc0f6268f",
	)
	var active := (contract.get("states", {}) as Dictionary).get("active", {}) as Dictionary
	assert_eq(active.get("native_frame_size"), [1296.0, 624.0])
	assert_eq(active.get("logical_frame_size"), [324.0, 156.0])
	assert_eq(((active.get("anchors", {}) as Dictionary).get("sequence_b", {}) as Dictionary).get("logical_center"), [216.25, 124.5])
	var pixel_gate := contract.get("symbol_pixel_gate", {}) as Dictionary
	assert_eq(int(pixel_gate.get("alpha_core_threshold", 0)), ALPHA_CORE_THRESHOLD)
	assert_eq(pixel_gate.get("normalized_focal_point"), [128.0, 128.0])
	assert_eq(float(pixel_gate.get("focal_tolerance_px", 99.0)), SYMBOL_FOCAL_TOLERANCE)
	assert_eq(float(pixel_gate.get("final_raster_focal_tolerance_logical_px", 99.0)), FINAL_RASTER_FOCAL_TOLERANCE_LOGICAL)
	assert_eq(float(pixel_gate.get("final_raster_focal_tolerance_physical_px", 99.0)), FINAL_RASTER_FOCAL_TOLERANCE_PHYSICAL)
	assert_eq(float(pixel_gate.get("optical_percentile", 0.0)), 0.95)
	assert_eq(float(pixel_gate.get("target_optical_radius_px", 0.0)), 60.0)
	assert_eq(pixel_gate.get("optical_radius_range_px"), [SYMBOL_OPTICAL_RADIUS_MIN, SYMBOL_OPTICAL_RADIUS_MAX])
	assert_eq(float(pixel_gate.get("maximum_core_radius_px", 0.0)), 104.0)
	assert_eq(float(pixel_gate.get("sequence_runtime_circle_diameter_px", 0.0)), 29.0)
	assert_eq(float(pixel_gate.get("reaction_runtime_circle_diameter_px", 0.0)), 34.0)
	assert_eq(pixel_gate.get("reaction_to_sequence_optical_ratio_range"), [REACTION_TO_SEQUENCE_OPTICAL_RATIO_MIN, REACTION_TO_SEQUENCE_OPTICAL_RATIO_MAX])
	assert_eq(float(pixel_gate.get("dark_interior_luminance_max", 99.0)), SYMBOL_DARK_INTERIOR_LUMA_MAX)
	assert_eq(int(pixel_gate.get("dark_interior_alpha_min", 0)), SYMBOL_DARK_INTERIOR_ALPHA_MIN)
	assert_eq(int(pixel_gate.get("isolated_dark_component_max_area_px", 0)), SYMBOL_DARK_COMPONENT_MAX_AREA)
	assert_eq(int(pixel_gate.get("isolated_dark_component_max_count", -1)), SYMBOL_DARK_COMPONENT_MAX_COUNT)
	assert_eq(pixel_gate.get("micro_sample_sizes_px"), [29.0, 34.0])
	assert_eq(float(pixel_gate.get("minimum_micro_edge_contrast", 0.0)), MICRO_GLYPH_MIN_EDGE_CONTRAST)
	assert_eq(String(pixel_gate.get("micro_resample_filter", "")), "lanczos")
	assert_eq(float(contract.get("label_circle_gap_px", 0.0)), LABEL_CIRCLE_GAP)
	assert_false(bool((contract.get("motion_envelopes", {}) as Dictionary).get("position_translation_allowed", true)))


func test_six_symbol_cells_share_one_alpha_focal_point_and_radial_keyline() -> void:
	var atlas := load(SYMBOL_ATLAS_PATH) as Texture2D
	assert_not_null(atlas, "六枚符号 atlas 必须可加载。")
	if atlas == null:
		return
	var image := atlas.get_image()
	assert_false(image.is_empty(), "六枚符号 atlas 必须可读取真实像素。")
	assert_eq(image.get_size(), Vector2i(768, 512))
	var symbol_ids := ["wind", "thunder", "swift", "ward", "wind_thunder_pierce", "thunder_wind_scatter"]
	for index: int in range(symbol_ids.size()):
		var origin := Vector2i((index % 3) * SYMBOL_CELL_SIZE.x, (index / 3) * SYMBOL_CELL_SIZE.y)
		var metrics := _alpha_core_metrics(image, origin)
		var centroid: Vector2 = metrics["centroid"]
		var focal_error := centroid.distance_to(SYMBOL_FOCAL_POINT)
		assert_lte(focal_error, SYMBOL_FOCAL_TOLERANCE, "%s Alpha 核心质心误差 %.3fpx 超过冻结门槛。" % [symbol_ids[index], focal_error])
		assert_lte(float(metrics["max_radius"]), 104.0, "%s 最远 Alpha 核心超过 104px 安全 keyline。" % symbol_ids[index])
		assert_eq(int(metrics["border_core_pixels"]), 0, "%s Alpha 核心不得触碰单元格边界。" % symbol_ids[index])


func test_symbol_optical_weight_scales_with_the_runtime_circle_diameter() -> void:
	var atlas := load(SYMBOL_ATLAS_PATH) as Texture2D
	assert_not_null(atlas, "六枚符号 atlas 必须可加载。")
	if atlas == null:
		return
	var image := atlas.get_image()
	var symbol_ids := ["wind", "thunder", "swift", "ward", "wind_thunder_pierce", "thunder_wind_scatter"]
	var optical_radii: Dictionary = {}
	for index: int in range(symbol_ids.size()):
		var origin := Vector2i((index % 3) * SYMBOL_CELL_SIZE.x, (index / 3) * SYMBOL_CELL_SIZE.y)
		var metrics := _alpha_core_metrics(image, origin)
		var optical_radius := float(metrics["optical_radius"])
		optical_radii[symbol_ids[index]] = optical_radius
		assert_between(
			optical_radius,
			SYMBOL_OPTICAL_RADIUS_MIN,
			SYMBOL_OPTICAL_RADIUS_MAX,
			"%s 光学半径 %.3fpx 未落入冻结区间；不能再用最远尖端冒充视觉大小。" % [symbol_ids[index], optical_radius],
		)

	_assert_optical_pair_ratio(optical_radii, "wind", "thunder")
	_assert_optical_pair_ratio(optical_radii, "swift", "ward")
	_assert_optical_pair_ratio(optical_radii, "wind_thunder_pierce", "thunder_wind_scatter")

	var sequence_mean := (float(optical_radii["wind"]) + float(optical_radii["thunder"])) * 0.5 * 14.5
	for reaction_id: String in ["wind_thunder_pierce", "thunder_wind_scatter"]:
		var runtime_ratio := float(optical_radii[reaction_id]) * 17.0 / sequence_mean
		assert_between(
			runtime_ratio,
			REACTION_TO_SEQUENCE_OPTICAL_RATIO_MIN,
			REACTION_TO_SEQUENCE_OPTICAL_RATIO_MAX,
			"%s 在 34px 大圆中的光学直径必须约为两个 29px 序列印均值的 34/29 倍，实际 %.4f。" % [reaction_id, runtime_ratio],
		)


func test_micro_hud_symbols_have_no_isolated_dark_texture_specks() -> void:
	var atlas := load(SYMBOL_ATLAS_PATH) as Texture2D
	assert_not_null(atlas, "六枚符号 atlas 必须可加载。")
	if atlas == null:
		return
	var image := atlas.get_image()
	var symbol_ids := ["wind", "thunder", "swift", "ward", "wind_thunder_pierce", "thunder_wind_scatter"]
	for index: int in range(symbol_ids.size()):
		var origin := Vector2i((index % 3) * SYMBOL_CELL_SIZE.x, (index / 3) * SYMBOL_CELL_SIZE.y)
		var artifacts := _isolated_dark_interior_components(image, origin)
		assert_lte(
			artifacts.size(),
			SYMBOL_DARK_COMPONENT_MAX_COUNT,
			"%s 含有 %d 个独立暗斑；微型 HUD 禁止把材质噪声缩成黑点。" % [symbol_ids[index], artifacts.size()],
		)
		for sample_size: int in MICRO_GLYPH_SAMPLE_SIZES:
			var quality := _micro_glyph_quality(image, origin, sample_size)
			assert_lte(
				int(quality["isolated_dark_components"]),
				SYMBOL_DARK_COMPONENT_MAX_COUNT,
				"%s 缩到 %dpx 后仍出现独立黑点。" % [symbol_ids[index], sample_size],
			)
			assert_gte(
				float(quality["edge_contrast"]),
				MICRO_GLYPH_MIN_EDGE_CONTRAST,
				"%s 缩到 %dpx 后边缘对比 %.3f 过低，图案会发糊。" % [symbol_ids[index], sample_size, float(quality["edge_contrast"])],
			)

func test_every_runtime_glyph_uses_the_shared_circle_safety_mask() -> void:
	var panel := await _spawn_panel()
	var paths := [
		"ContentRoot/ElementGlyph",
		"ContentRoot/StanceGlyph",
		"ContentRoot/SequenceRoot/SequenceSlotA",
		"ContentRoot/SequenceRoot/SequenceSlotB",
		"ContentRoot/SequenceRoot/ReactionGlyph",
	]
	for path: String in paths:
		var glyph := panel.get_node(path) as TextureRect
		var material := glyph.material as ShaderMaterial
		assert_not_null(material, "%s 必须使用圆形安全遮罩。" % path)
		if material == null:
			continue
		assert_not_null(material.shader)
		if material.shader != null:
			assert_eq(material.shader.resource_path, ICON_MASK_SHADER_PATH)


func test_circle_mask_normalizes_uv_against_each_current_atlas_region() -> void:
	var panel := await _spawn_panel()
	panel.call("apply_snapshot", _snapshot(&"thunder", &"swift", [&"wind", &"thunder"], 1.0, 2.0))
	_assert_mask_region(panel, "ContentRoot/ElementGlyph", Vector4(1.0 / 3.0, 0.0, 1.0 / 3.0, 0.5))
	_assert_mask_region(panel, "ContentRoot/StanceGlyph", Vector4(2.0 / 3.0, 0.0, 1.0 / 3.0, 0.5))
	_assert_mask_region(panel, "ContentRoot/SequenceRoot/SequenceSlotA", Vector4(0.0, 0.0, 1.0 / 3.0, 0.5))
	_assert_mask_region(panel, "ContentRoot/SequenceRoot/SequenceSlotB", Vector4(1.0 / 3.0, 0.0, 1.0 / 3.0, 0.5))
	_assert_mask_region(panel, "ContentRoot/SequenceRoot/ReactionGlyph", Vector4(1.0 / 3.0, 0.5, 1.0 / 3.0, 0.5))

	panel.call("apply_snapshot", _snapshot(&"wind", &"ward", [&"thunder", &"wind"], 1.0, 2.0))
	_assert_mask_region(panel, "ContentRoot/ElementGlyph", Vector4(0.0, 0.0, 1.0 / 3.0, 0.5))
	_assert_mask_region(panel, "ContentRoot/StanceGlyph", Vector4(0.0, 0.5, 1.0 / 3.0, 0.5))
	_assert_mask_region(panel, "ContentRoot/SequenceRoot/ReactionGlyph", Vector4(2.0 / 3.0, 0.5, 1.0 / 3.0, 0.5))


func test_element_feedback_never_translates_the_alpha_focal_center() -> void:
	var panel := await _spawn_panel()
	panel.call("set_reduced_motion_enabled", false)
	panel.call("apply_snapshot", _snapshot(&"thunder", &"swift", [], 0.0, 2.0))
	await get_tree().process_frame
	panel.call("apply_snapshot", _snapshot(&"wind", &"swift", [], 0.0, 2.0))
	var glyph := panel.get_node("ContentRoot/ElementGlyph") as TextureRect
	for frame_index: int in range(16):
		var center := _control_rect_in_panel(panel, glyph).get_center()
		assert_lte(center.distance_to(IDLE_ANCHORS["element"]["center"]), ANCHOR_TOLERANCE, "元素反馈第 %d 帧发生了位置漂移。" % frame_index)
		await get_tree().process_frame


func test_v2_frame_art_slots_own_the_actual_idle_and_active_glyph_geometry() -> void:
	var panel := await _spawn_panel()
	panel.call("apply_snapshot", _snapshot(&"thunder", &"swift", [], 0.0, 2.0))
	for role: String in IDLE_ANCHORS:
		_assert_semantic_anchor(panel, role, IDLE_ANCHORS[role] as Dictionary)

	panel.call("apply_snapshot", _snapshot(&"thunder", &"swift", [&"wind", &"thunder"], 1.0, 2.0))
	for role: String in ACTIVE_ANCHORS:
		_assert_semantic_anchor(panel, role, ACTIVE_ANCHORS[role] as Dictionary)

	for label_name: String in ACTIVE_LABEL_ZONES:
		var label_path := "ContentRoot/SequenceRoot/ReactionLabel" if label_name == "ReactionLabel" else "ContentRoot/%s" % label_name
		var label := panel.get_node(label_path) as Label
		var actual_rect := _control_rect_in_panel(panel, label)
		var safe_zone: Rect2 = ACTIVE_LABEL_ZONES[label_name]
		assert_true(safe_zone.encloses(actual_rect), "%s 必须完整位于独立文字安全区 %s，实际 %s。" % [label_name, safe_zone, actual_rect])
		assert_lte(label.get_minimum_size().x, actual_rect.size.x + 0.1, "%s 文本最小宽度不得溢出自身框。" % label_name)
	var stance_label := panel.get_node("ContentRoot/StanceLabel") as Label
	var stance_label_rect := _control_rect_in_panel(panel, stance_label)
	var stance_contract := ACTIVE_ANCHORS["stance"] as Dictionary
	var stance_circle_right := float((stance_contract["center"] as Vector2).x) + float(stance_contract["radius"])
	assert_gte(stance_label_rect.position.x - stance_circle_right, LABEL_CIRCLE_GAP, "疾印 / 御印文字与姿态圆框净距必须 >= 8px。")

	var link := panel.get_node("ContentRoot/SequenceRoot/SequenceLink") as ColorRect
	var link_rect := _control_rect_in_panel(panel, link)
	assert_true(ACTIVE_LINK_CORRIDOR.encloses(link_rect), "灵力链只能位于 A/B 圆框之间的走廊，实际 %s。" % link_rect)
	var sequence_a_center: Vector2 = (ACTIVE_ANCHORS["sequence_a"] as Dictionary)["center"]
	var sequence_b_center: Vector2 = (ACTIVE_ANCHORS["sequence_b"] as Dictionary)["center"]
	assert_false(link_rect.has_point(sequence_a_center), "灵力链不得盖住第一步圆心。")
	assert_false(link_rect.has_point(sequence_b_center), "灵力链不得盖住第二步圆心。")


func test_reduced_motion_keeps_element_and_stance_feedback_semantically_distinct() -> void:
	var panel := await _spawn_panel()
	assert_true(panel.has_method("set_reduced_motion_enabled"), "SealResonanceHud 必须接收全局降低动态效果设置。")
	assert_true(panel.has_method("apply_snapshot"))
	assert_true(panel.has_method("get_visual_snapshot"))
	if not panel.has_method("set_reduced_motion_enabled") or not panel.has_method("apply_snapshot") or not panel.has_method("get_visual_snapshot"):
		return

	panel.call("apply_snapshot", _snapshot(&"thunder", &"swift", [], 0.0, 2.0))
	panel.call("set_reduced_motion_enabled", true)
	panel.call("apply_snapshot", _snapshot(&"wind", &"ward", [&"wind"], 1.0, 2.0))
	var reduced: Dictionary = panel.call("get_visual_snapshot")
	assert_true(reduced.get("reduced_motion", false))
	assert_eq(float(reduced.get("link_motion_amount", -1.0)), 0.0)
	assert_eq(reduced.get("last_switch_feedback"), &"element")

	panel.call("apply_snapshot", _snapshot(&"wind", &"swift", [&"wind"], 1.0, 2.0))
	var stance_changed: Dictionary = panel.call("get_visual_snapshot")
	assert_eq(stance_changed.get("last_switch_feedback"), &"stance")
	assert_ne(stance_changed.get("last_switch_feedback"), reduced.get("last_switch_feedback"))


func _spawn_panel() -> Panel:
	var packed := load(HUD_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var hud := packed.instantiate() as Control
	add_child_autofree(hud)
	await get_tree().process_frame
	return hud.get_node("ElementPanel") as Panel


func _snapshot(element_id: StringName, stance_id: StringName, sequence_ids: Array, remaining: float, duration: float) -> Dictionary:
	var reaction_id := StringName()
	var reaction_label := ""
	if sequence_ids == [&"wind", &"thunder"]:
		reaction_id = &"wind_thunder_pierce"
		reaction_label = "追击贯穿"
	elif sequence_ids == [&"thunder", &"wind"]:
		reaction_id = &"thunder_wind_scatter"
		reaction_label = "散射破势"
	return {
		"current_element_id": element_id,
		"current_element_label": "风" if element_id == &"wind" else "雷",
		"current_stance_id": stance_id,
		"current_stance_label": "御印" if stance_id == &"ward" else "疾印",
		"element_sequence": {
			"element_ids": sequence_ids,
			"window_remaining": remaining,
			"window_duration": duration,
			"reaction_id": reaction_id,
			"reaction_label": reaction_label,
		},
	}


func _assert_semantic_anchor(panel: Panel, role: String, contract: Dictionary) -> void:
	var control := panel.get_node(String(contract["path"])) as Control
	var actual_rect := _control_rect_in_panel(panel, control)
	var actual_center := actual_rect.get_center()
	var target_center: Vector2 = contract["center"]
	var distance := actual_center.distance_to(target_center)
	assert_lte(distance, ANCHOR_TOLERANCE, "%s 圆心误差必须 <= %.1fpx；target=%s actual=%s delta=%s。" % [role, ANCHOR_TOLERANCE, target_center, actual_center, actual_center - target_center])
	assert_eq(actual_rect.size, contract["size"], "%s 必须使用经原尺寸目检冻结的内圈留白尺寸。" % role)
	var slot: Rect2 = contract["slot"]
	assert_true(slot.grow(0.1).encloses(actual_rect), "%s 图标包围盒必须完整位于对应圆框槽 %s，实际 %s。" % [role, slot, actual_rect])


func _alpha_core_metrics(image: Image, origin: Vector2i) -> Dictionary:
	var weighted_sum := Vector2.ZERO
	var weight_total := 0.0
	var core_points: Array[Vector3] = []
	var border_core_pixels := 0
	for local_y: int in range(SYMBOL_CELL_SIZE.y):
		for local_x: int in range(SYMBOL_CELL_SIZE.x):
			var alpha := image.get_pixel(origin.x + local_x, origin.y + local_y).a
			if roundi(alpha * 255.0) < ALPHA_CORE_THRESHOLD:
				continue
			var point := Vector2(local_x + 0.5, local_y + 0.5)
			weighted_sum += point * alpha
			weight_total += alpha
			core_points.append(Vector3(point.x, point.y, alpha))
			if local_x == 0 or local_y == 0 or local_x == SYMBOL_CELL_SIZE.x - 1 or local_y == SYMBOL_CELL_SIZE.y - 1:
				border_core_pixels += 1
	if core_points.is_empty() or is_zero_approx(weight_total):
		return {"centroid": Vector2(-999.0, -999.0), "max_radius": 999.0, "border_core_pixels": border_core_pixels}
	var centroid := weighted_sum / weight_total
	var max_radius := 0.0
	var weighted_radii: Array[Vector2] = []
	for sample: Vector3 in core_points:
		var point := Vector2(sample.x, sample.y)
		var radius := point.distance_to(centroid)
		max_radius = maxf(max_radius, radius)
		weighted_radii.append(Vector2(radius, sample.z))
	weighted_radii.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	var accumulated_weight := 0.0
	var robust_radius := 0.0
	for sample: Vector2 in weighted_radii:
		accumulated_weight += sample.y
		if accumulated_weight >= weight_total * 0.95:
			robust_radius = sample.x
			break
	var equivalent_alpha_radius := sqrt(weight_total / PI)
	var optical_radius := sqrt(robust_radius * equivalent_alpha_radius)
	return {
		"centroid": centroid,
		"max_radius": max_radius,
		"robust_radius": robust_radius,
		"equivalent_alpha_radius": equivalent_alpha_radius,
		"optical_radius": optical_radius,
		"border_core_pixels": border_core_pixels,
	}


func _isolated_dark_interior_components(image: Image, origin: Vector2i) -> Array[Dictionary]:
	var dark_points: Dictionary = {}
	for local_y: int in range(1, SYMBOL_CELL_SIZE.y - 1):
		for local_x: int in range(1, SYMBOL_CELL_SIZE.x - 1):
			var color := image.get_pixel(origin.x + local_x, origin.y + local_y)
			if color.a * 255.0 < SYMBOL_DARK_INTERIOR_ALPHA_MIN:
				continue
			var luminance := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			if luminance > SYMBOL_DARK_INTERIOR_LUMA_MAX:
				continue
			# 只统计被图形包围的暗像素；透明背景和合法外轮廓不计入。
			var enclosed := true
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var found_visible := false
				var cursor := Vector2i(local_x, local_y) + direction
				while cursor.x >= 0 and cursor.y >= 0 and cursor.x < SYMBOL_CELL_SIZE.x and cursor.y < SYMBOL_CELL_SIZE.y:
					if image.get_pixel(origin.x + cursor.x, origin.y + cursor.y).a * 255.0 >= SYMBOL_DARK_INTERIOR_ALPHA_MIN:
						found_visible = true
						break
					cursor += direction
				if not found_visible:
					enclosed = false
					break
			if enclosed:
				dark_points[Vector2i(local_x, local_y)] = true

	var components: Array[Dictionary] = []
	while not dark_points.is_empty():
		var seed: Vector2i = dark_points.keys()[0]
		var pending: Array[Vector2i] = [seed]
		dark_points.erase(seed)
		var area := 0
		while not pending.is_empty():
			var point: Vector2i = pending.pop_back()
			area += 1
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor: Vector2i = point + direction
				if dark_points.erase(neighbor):
					pending.append(neighbor)
		if area <= SYMBOL_DARK_COMPONENT_MAX_AREA:
			components.append({"seed": seed, "area": area})
	return components


func _micro_glyph_quality(image: Image, origin: Vector2i, sample_size: int) -> Dictionary:
	var cell := image.get_region(Rect2i(origin, SYMBOL_CELL_SIZE))
	cell.resize(sample_size, sample_size, Image.INTERPOLATE_LANCZOS)
	var canvas := Image.create(SYMBOL_CELL_SIZE.x, SYMBOL_CELL_SIZE.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.0, 0.0, 0.0, 0.0))
	var paste_origin := Vector2i((SYMBOL_CELL_SIZE.x - sample_size) / 2, (SYMBOL_CELL_SIZE.y - sample_size) / 2)
	canvas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), paste_origin)
	var dark_components := _isolated_dark_interior_components(canvas, Vector2i.ZERO)
	var edge_samples := 0
	var edge_contrast_total := 0.0
	for y: int in range(1, sample_size - 1):
		for x: int in range(1, sample_size - 1):
			var color := cell.get_pixel(x, y)
			if color.a <= 0.1:
				continue
			var max_neighbor_delta := 0.0
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor := cell.get_pixelv(Vector2i(x, y) + direction)
				max_neighbor_delta = maxf(max_neighbor_delta, absf(color.a - neighbor.a))
			if max_neighbor_delta > 0.05:
				edge_samples += 1
				edge_contrast_total += max_neighbor_delta
	return {
		"isolated_dark_components": dark_components.size(),
		"edge_contrast": edge_contrast_total / maxf(1.0, float(edge_samples)),
	}


func _assert_optical_pair_ratio(optical_radii: Dictionary, first_id: String, second_id: String) -> void:
	var first := float(optical_radii[first_id])
	var second := float(optical_radii[second_id])
	var ratio := first / second
	assert_between(
		ratio,
		SYMBOL_OPTICAL_PAIR_RATIO_MIN,
		SYMBOL_OPTICAL_PAIR_RATIO_MAX,
		"相同尺寸圆框内的 %s / %s 必须具有相同光学尺度，实际比例 %.4f。" % [first_id, second_id, ratio],
	)


func _assert_mask_region(panel: Panel, node_path: String, expected: Vector4) -> void:
	var glyph := panel.get_node(node_path) as TextureRect
	var material := glyph.material as ShaderMaterial
	assert_not_null(material)
	if material != null:
		assert_eq(material.get_shader_parameter("region_uv_rect"), expected, "%s 圆形遮罩必须使用当前 AtlasTexture 的局部 UV。" % node_path)


func _control_rect_in_panel(panel: Panel, control: Control) -> Rect2:
	var inverse_panel_transform := panel.get_global_transform_with_canvas().affine_inverse()
	var control_transform := control.get_global_transform_with_canvas()
	var corners := [
		inverse_panel_transform * (control_transform * Vector2.ZERO),
		inverse_panel_transform * (control_transform * Vector2(control.size.x, 0.0)),
		inverse_panel_transform * (control_transform * control.size),
		inverse_panel_transform * (control_transform * Vector2(0.0, control.size.y)),
	]
	var rect := Rect2(corners[0], Vector2.ZERO)
	for corner: Vector2 in corners.slice(1):
		rect = rect.expand(corner)
	return rect.abs()
