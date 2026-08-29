extends Panel
class_name SealResonanceHud

# 符印共鸣盘只把 Player 的公开 HUD 快照翻译为三态视觉。
# 它可以缓存上一次身份以播放一次性反馈，但不拥有序列计时，也不反向写入玩法状态。

signal layout_changed

const STATE_IDLE := &"idle"
const STATE_PRIMED := &"primed"
const STATE_RESOLVED := &"resolved"
const IDLE_SIZE := Vector2(232.0, 116.0)
const ACTIVE_SIZE := Vector2(324.0, 156.0)
const REACTION_LABEL_DURATION := 0.85
const ANCHOR_CONTRACT_PATH := "res://assets/art/ui/hud_seal_resonance_v2/seal_resonance_anchor_contract.json"
const ICON_MASK_SHADER_PATH := "res://assets/shaders/ui/seal_resonance_icon_circle_mask.gdshader"
const STATIC_ANCHOR_TOLERANCE := 0.5
const SYMBOL_CORE_ALPHA_THRESHOLD := 16
const SYMBOL_CELL_SIZE := 256.0
const SYMBOL_MINIMUM_CORE_INSET := 2.0
const LABEL_CIRCLE_GAP := 8.0
const ELEMENT_FEEDBACK_MAXIMUM_SCALE := 1.03

const ELEMENT_THUNDER := &"thunder"
const ELEMENT_WIND := &"wind"
const STANCE_SWIFT := &"swift"
const STANCE_WARD := &"ward"
const REACTION_PIERCE := &"wind_thunder_pierce"
const REACTION_SCATTER := &"thunder_wind_scatter"

const IDLE_ANCHORS := {
	&"element": {"center": Vector2(64.75, 51.25), "radius": 30.0, "size": Vector2(60.0, 60.0), "slot": Rect2(34.75, 21.25, 60.0, 60.0)},
	&"stance": {"center": Vector2(144.75, 53.25), "radius": 18.0, "size": Vector2(36.0, 36.0), "slot": Rect2(126.75, 35.25, 36.0, 36.0)},
}
const ACTIVE_ANCHORS := {
	&"element": {"center": Vector2(58.5, 54.0), "radius": 31.0, "size": Vector2(62.0, 62.0), "slot": Rect2(27.5, 23.0, 62.0, 62.0)},
	&"stance": {"center": Vector2(140.25, 55.75), "radius": 19.0, "size": Vector2(38.0, 38.0), "slot": Rect2(121.25, 36.75, 38.0, 38.0)},
	&"sequence_a": {"center": Vector2(158.0, 124.5), "radius": 14.5, "size": Vector2(29.0, 29.0), "slot": Rect2(143.5, 110.0, 29.0, 29.0)},
	&"sequence_b": {"center": Vector2(216.25, 124.5), "radius": 14.5, "size": Vector2(29.0, 29.0), "slot": Rect2(201.75, 110.0, 29.0, 29.0)},
	&"reaction": {"center": Vector2(287.0, 126.0), "radius": 17.0, "size": Vector2(34.0, 34.0), "slot": Rect2(270.0, 109.0, 34.0, 34.0)},
}
const IDLE_LABEL_ZONES := {
	&"element": Rect2(172.0, 14.0, 52.0, 40.0),
	&"stance": Rect2(172.0, 52.0, 52.0, 40.0),
}
const ACTIVE_LABEL_ZONES := {
	&"element": Rect2(172.0, 14.0, 42.0, 34.0),
	&"stance": Rect2(170.0, 46.0, 48.0, 32.0),
	&"reaction": Rect2(164.0, 76.0, 54.0, 24.0),
}
const ACTIVE_LINK_CORRIDOR := Rect2(174.0, 104.5, 25.0, 40.0)

const IDLE_STYLE := preload("res://assets/art/ui/styleboxes/hud_seal_resonance_v2/seal_resonance_idle_content_safe.stylebox_empty.tres")
const ACTIVE_STYLE := preload("res://assets/art/ui/styleboxes/hud_seal_resonance_v2/seal_resonance_active_content_safe.stylebox_empty.tres")
const GLYPH_TEXTURES := {
	ELEMENT_WIND: preload("res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/wind.atlas_texture.tres"),
	ELEMENT_THUNDER: preload("res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/thunder.atlas_texture.tres"),
	STANCE_SWIFT: preload("res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/swift.atlas_texture.tres"),
	STANCE_WARD: preload("res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/ward.atlas_texture.tres"),
	REACTION_PIERCE: preload("res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/wind_thunder_pierce.atlas_texture.tres"),
	REACTION_SCATTER: preload("res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/thunder_wind_scatter.atlas_texture.tres"),
}
const GLYPH_UV_REGIONS := {
	ELEMENT_WIND: Vector4(0.0, 0.0, 1.0 / 3.0, 0.5),
	ELEMENT_THUNDER: Vector4(1.0 / 3.0, 0.0, 1.0 / 3.0, 0.5),
	STANCE_SWIFT: Vector4(2.0 / 3.0, 0.0, 1.0 / 3.0, 0.5),
	STANCE_WARD: Vector4(0.0, 0.5, 1.0 / 3.0, 0.5),
	REACTION_PIERCE: Vector4(1.0 / 3.0, 0.5, 1.0 / 3.0, 0.5),
	REACTION_SCATTER: Vector4(2.0 / 3.0, 0.5, 1.0 / 3.0, 0.5),
}

@onready var frame_art: TextureRect = $FrameArt
@onready var frame_art_active: TextureRect = $FrameArtActive
@onready var element_glyph: TextureRect = $ContentRoot/ElementGlyph
@onready var element_label: Label = $ContentRoot/ElementLabel
@onready var stance_glyph: TextureRect = $ContentRoot/StanceGlyph
@onready var stance_label: Label = $ContentRoot/StanceLabel
@onready var sequence_root: Control = $ContentRoot/SequenceRoot
@onready var sequence_slot_a: TextureRect = $ContentRoot/SequenceRoot/SequenceSlotA
@onready var sequence_link: ColorRect = $ContentRoot/SequenceRoot/SequenceLink
@onready var sequence_slot_b: TextureRect = $ContentRoot/SequenceRoot/SequenceSlotB
@onready var reaction_glyph: TextureRect = $ContentRoot/SequenceRoot/ReactionGlyph
@onready var reaction_label: Label = $ContentRoot/SequenceRoot/ReactionLabel

var _display_state := StringName()
var _element_id := ELEMENT_THUNDER
var _stance_id := STANCE_SWIFT
var _sequence_ids: Array[StringName] = []
var _reaction_id := StringName()
var _window_ratio := 0.0
var _reduced_motion_enabled := false
var _has_identity := false
var _last_switch_feedback := StringName()
var _reaction_label_remaining := 0.0
var _element_base_position := Vector2.ZERO
var _stance_base_position := Vector2.ZERO
var _element_tween: Tween
var _stance_tween: Tween
var _symbol_pixel_metrics_cache := {}


func _ready() -> void:
	apply_snapshot({})


# 调用方可逐帧传入快照；只有状态尺寸变化才会发出 layout_changed。
func apply_snapshot(snapshot: Dictionary) -> void:
	var sequence_variant: Variant = snapshot.get("element_sequence", {})
	var sequence: Dictionary = sequence_variant if sequence_variant is Dictionary else {}
	var raw_ids_variant: Variant = sequence.get("element_ids", [])
	var raw_ids: Array = raw_ids_variant if raw_ids_variant is Array else []
	_sequence_ids = _normalize_sequence_ids(raw_ids)

	var next_state := STATE_IDLE
	if _sequence_ids.size() == 1:
		next_state = STATE_PRIMED
	elif _sequence_ids.size() >= 2:
		next_state = STATE_RESOLVED
	_apply_state(next_state)
	_apply_identity(snapshot)
	_apply_sequence(sequence)


# 同一 reduced-motion 设置同时关闭灵力链的时间流动和两种位移/旋转反馈。
func set_reduced_motion_enabled(enabled: bool) -> void:
	_reduced_motion_enabled = enabled
	var link_material := sequence_link.material as ShaderMaterial
	if link_material != null:
		link_material.set_shader_parameter("motion_amount", 0.0 if enabled else 1.0)
	if enabled:
		_reset_feedback_visuals()


func get_display_state() -> StringName:
	return _display_state


# 自动化快照从真实节点、纹理和 ShaderMaterial 读值，不复制一套伪视觉状态。
func get_visual_snapshot() -> Dictionary:
	var link_material := sequence_link.material as ShaderMaterial
	var actual_window_ratio := 0.0
	var motion_amount := 0.0
	var reaction_mode := 0.0
	if link_material != null:
		actual_window_ratio = float(link_material.get_shader_parameter("window_ratio"))
		motion_amount = float(link_material.get_shader_parameter("motion_amount"))
		reaction_mode = float(link_material.get_shader_parameter("reaction_mode"))
	var visible_labels: Array[String] = [element_label.text, stance_label.text]
	if reaction_label.visible:
		visible_labels.append(reaction_label.text)
	return {
		"state": _display_state,
		"size": size,
		"element_id": _element_id,
		"stance_id": _stance_id,
		"sequence_ids": _sequence_ids.duplicate(),
		"window_ratio": actual_window_ratio,
		"reaction_id": _reaction_id,
		"reaction_glyph_path": reaction_glyph.texture.resource_path if reaction_glyph.texture != null else "",
		"reaction_label_visible": reaction_label.visible,
		"reaction_label_remaining": _reaction_label_remaining,
		"visible_text": " ".join(visible_labels),
		"idle_frame_visible": frame_art.visible,
		"active_frame_visible": frame_art_active.visible,
		"link_motion_amount": motion_amount,
		"reaction_mode": reaction_mode,
		"last_switch_feedback": _last_switch_feedback,
		"reduced_motion": _reduced_motion_enabled,
		"semantic_anchor_contract": ANCHOR_CONTRACT_PATH,
		"semantic_anchor_report": get_semantic_anchor_report(),
	}


# 运行态报告同时读取 Control 变换与 AtlasTexture 的真实 Alpha 核心；矩形居中不再等于视觉通过。
func get_semantic_anchor_report() -> Dictionary:
	var layout: Dictionary = IDLE_ANCHORS if _display_state == STATE_IDLE else ACTIVE_ANCHORS
	var anchors := {}
	var anchors_ok := true
	var visible_anchor_count := 0
	for role_variant: Variant in layout:
		var role := StringName(role_variant)
		var contract := layout[role] as Dictionary
		var control := _control_for_anchor(role)
		var actual_rect := _control_rect_in_panel_space(control)
		var actual_center := actual_rect.get_center()
		var layout_rect := _layout_rect_for_anchor(role, control)
		var layout_center := layout_rect.get_center()
		var target_center: Vector2 = contract["center"]
		var layout_delta := layout_center - target_center
		var center_error := layout_delta.length()
		var actual_delta := actual_center - target_center
		var actual_center_error := actual_delta.length()
		var slot: Rect2 = contract["slot"]
		var inside_slot := slot.grow(0.1).encloses(layout_rect)
		var motion_tolerance := STATIC_ANCHOR_TOLERANCE
		var maximum_scale := ELEMENT_FEEDBACK_MAXIMUM_SCALE if role == &"element" else 1.0
		var motion_growth := control.size.x * (maximum_scale - 1.0) * 0.5
		var motion_envelope := slot.grow(motion_growth + 0.01)
		var actual_inside_motion_envelope := motion_envelope.grow(0.1).encloses(actual_rect)
		var visible := _anchor_has_visible_texture(control)
		if visible:
			visible_anchor_count += 1
		var circle_radius := float(contract["radius"])
		var pixel_gate := _pixel_gate_for_control(control, target_center, circle_radius, visible)
		var mask_shader_path := _mask_shader_path(control)
		var mask_ok := mask_shader_path == ICON_MASK_SHADER_PATH
		var entry_ok := (
			center_error <= STATIC_ANCHOR_TOLERANCE
			and inside_slot
			and actual_center_error <= motion_tolerance
			and actual_inside_motion_envelope
			and bool(pixel_gate.get("ok", false))
			and mask_ok
		)
		anchors_ok = anchors_ok and entry_ok
		anchors[String(role)] = {
			"visible": visible,
			"target_center": _vector_to_report(target_center),
			"layout_center": _vector_to_report(layout_center),
			"actual_center": _vector_to_report(actual_center),
			"delta": _vector_to_report(layout_delta),
			"actual_delta": _vector_to_report(actual_delta),
			"center_error": center_error,
			"actual_center_error": actual_center_error,
			"tolerance": STATIC_ANCHOR_TOLERANCE,
			"motion_tolerance": motion_tolerance,
			"layout_rect": _rect_to_report(layout_rect),
			"actual_rect": _rect_to_report(actual_rect),
			"slot_safe_rect": _rect_to_report(slot),
			"motion_envelope": _rect_to_report(motion_envelope),
			"inside_slot": inside_slot,
			"actual_inside_motion_envelope": actual_inside_motion_envelope,
			"circle_inner_radius": circle_radius,
			"pixel_focal_center": pixel_gate.get("focal_center", _vector_to_report(target_center)),
			"pixel_focal_center_error": pixel_gate.get("focal_center_error", 0.0),
			"pixel_core_radius_px": pixel_gate.get("core_radius_px", 0.0),
			"pixel_core_inset_px": pixel_gate.get("core_inset_px", circle_radius),
			"pixel_core_inside_circle": pixel_gate.get("inside_circle", true),
			"pixel_metrics_valid": pixel_gate.get("metrics_valid", not visible),
			"mask_shader_path": mask_shader_path,
			"mask_ok": mask_ok,
			"ok": entry_ok,
		}

	var labels := _label_gate_report()
	var link := _link_gate_report()
	return {
		"contract_path": ANCHOR_CONTRACT_PATH,
		"state": _display_state,
		"visible_anchor_count": visible_anchor_count,
		"anchors": anchors,
		"labels": labels,
		"sequence_link": link,
		"ok": anchors_ok and bool(labels.get("ok", false)) and bool(link.get("ok", false)),
	}


func _process(delta: float) -> void:
	if _reaction_label_remaining <= 0.0:
		return
	_reaction_label_remaining = maxf(_reaction_label_remaining - delta, 0.0)
	if is_zero_approx(_reaction_label_remaining):
		reaction_label.visible = false
		set_process(false)


func _apply_state(next_state: StringName) -> void:
	if next_state == _display_state:
		return
	_display_state = next_state
	_reset_feedback_visuals()
	var is_idle := next_state == STATE_IDLE
	size = IDLE_SIZE if is_idle else ACTIVE_SIZE
	frame_art.visible = is_idle
	frame_art_active.visible = not is_idle
	add_theme_stylebox_override("panel", IDLE_STYLE if is_idle else ACTIVE_STYLE)
	_layout_dynamic_content()
	layout_changed.emit()


func _apply_identity(snapshot: Dictionary) -> void:
	var next_element := _normalize_element_id(snapshot.get("current_element_id", ELEMENT_THUNDER))
	var next_stance := _normalize_stance_id(snapshot.get("current_stance_id", STANCE_SWIFT))
	var element_changed := _has_identity and next_element != _element_id
	var stance_changed := _has_identity and next_stance != _stance_id

	_element_id = next_element
	_stance_id = next_stance
	element_glyph.texture = GLYPH_TEXTURES[_element_id]
	stance_glyph.texture = GLYPH_TEXTURES[_stance_id]
	_apply_icon_mask_region(element_glyph, _element_id)
	_apply_icon_mask_region(stance_glyph, _stance_id)
	element_label.text = "风" if _element_id == ELEMENT_WIND else "雷"
	stance_label.text = "御印" if _stance_id == STANCE_WARD else "疾印"
	_has_identity = true

	# 两种反馈各自持有 Tween；同时变化时都播放，并以元素换轨作为最近的主反馈。
	if stance_changed:
		_play_stance_feedback()
	if element_changed:
		_play_element_feedback()


func _apply_sequence(sequence: Dictionary) -> void:
	var remaining := float(sequence.get("window_remaining", 0.0))
	var duration := maxf(float(sequence.get("window_duration", 0.0)), 0.001)
	_window_ratio = clampf(remaining / duration, 0.0, 1.0) if not _sequence_ids.is_empty() else 0.0
	var next_reaction_id := _reaction_for_sequence(_sequence_ids)
	var is_new_reaction := not next_reaction_id.is_empty() and next_reaction_id != _reaction_id
	_reaction_id = next_reaction_id

	sequence_root.visible = _display_state != STATE_IDLE
	sequence_slot_a.texture = GLYPH_TEXTURES[_sequence_ids[0]] if not _sequence_ids.is_empty() else null
	sequence_slot_b.texture = GLYPH_TEXTURES[_sequence_ids[1]] if _sequence_ids.size() >= 2 else null
	reaction_glyph.texture = GLYPH_TEXTURES[_reaction_id] if GLYPH_TEXTURES.has(_reaction_id) else null
	if not _sequence_ids.is_empty():
		_apply_icon_mask_region(sequence_slot_a, _sequence_ids[0])
	if _sequence_ids.size() >= 2:
		_apply_icon_mask_region(sequence_slot_b, _sequence_ids[1])
	if not _reaction_id.is_empty():
		_apply_icon_mask_region(reaction_glyph, _reaction_id)
	reaction_glyph.visible = reaction_glyph.texture != null
	if _reaction_id.is_empty():
		_reaction_label_remaining = 0.0
		reaction_label.visible = false
		set_process(false)
	elif is_new_reaction:
		reaction_label.text = "贯穿" if _reaction_id == REACTION_PIERCE else "破势"
		reaction_label.visible = true
		_reaction_label_remaining = REACTION_LABEL_DURATION
		set_process(true)

	var link_material := sequence_link.material as ShaderMaterial
	if link_material != null:
		link_material.set_shader_parameter("window_ratio", _window_ratio)
		link_material.set_shader_parameter("motion_amount", 0.0 if _reduced_motion_enabled else 1.0)
		link_material.set_shader_parameter("reaction_mode", _reaction_mode_for_id(_reaction_id))


func _layout_dynamic_content() -> void:
	if _display_state == STATE_IDLE:
		_place_centered(element_glyph, IDLE_ANCHORS[&"element"] as Dictionary)
		element_label.position = Vector2(174.0, 18.0)
		element_label.size = Vector2(48.0, 34.0)
		_place_centered(stance_glyph, IDLE_ANCHORS[&"stance"] as Dictionary)
		stance_label.position = Vector2(174.0, 54.0)
		stance_label.size = Vector2(48.0, 34.0)
		sequence_root.position = Vector2.ZERO
		sequence_root.size = IDLE_SIZE
		sequence_root.visible = false
	else:
		_place_centered(element_glyph, ACTIVE_ANCHORS[&"element"] as Dictionary)
		element_label.position = Vector2(172.0, 16.0)
		element_label.size = Vector2(42.0, 30.0)
		_place_centered(stance_glyph, ACTIVE_ANCHORS[&"stance"] as Dictionary)
		stance_label.position = Vector2(170.0, 48.0)
		stance_label.size = Vector2(46.0, 28.0)
		sequence_root.position = Vector2.ZERO
		sequence_root.size = ACTIVE_SIZE
		_place_centered(sequence_slot_a, ACTIVE_ANCHORS[&"sequence_a"] as Dictionary)
		sequence_link.position = ACTIVE_LINK_CORRIDOR.position
		sequence_link.size = ACTIVE_LINK_CORRIDOR.size
		_place_centered(sequence_slot_b, ACTIVE_ANCHORS[&"sequence_b"] as Dictionary)
		_place_centered(reaction_glyph, ACTIVE_ANCHORS[&"reaction"] as Dictionary)
		reaction_label.position = Vector2(164.0, 77.0)
		reaction_label.size = Vector2(54.0, 22.0)
	_element_base_position = element_glyph.position
	_stance_base_position = stance_glyph.position
	for glyph: TextureRect in [element_glyph, stance_glyph, sequence_slot_a, sequence_slot_b, reaction_glyph]:
		glyph.pivot_offset = glyph.size * 0.5


func _place_centered(control: Control, contract: Dictionary) -> void:
	var control_size: Vector2 = contract["size"]
	var center: Vector2 = contract["center"]
	control.size = control_size
	control.position = center - control_size * 0.5


func _control_for_anchor(role: StringName) -> TextureRect:
	match role:
		&"element":
			return element_glyph
		&"stance":
			return stance_glyph
		&"sequence_a":
			return sequence_slot_a
		&"sequence_b":
			return sequence_slot_b
		&"reaction":
			return reaction_glyph
	return element_glyph


func _anchor_has_visible_texture(control: TextureRect) -> bool:
	return control.visible and control.is_visible_in_tree() and control.texture != null


func _layout_rect_for_anchor(role: StringName, control: TextureRect) -> Rect2:
	if role == &"element":
		return Rect2(_element_base_position, control.size)
	if role == &"stance":
		return Rect2(_stance_base_position, control.size)
	return Rect2(sequence_root.position + control.position, control.size)


func _label_gate_report() -> Dictionary:
	var zones: Dictionary = IDLE_LABEL_ZONES if _display_state == STATE_IDLE else ACTIVE_LABEL_ZONES
	var labels_by_role := {
		&"element": element_label,
		&"stance": stance_label,
		&"reaction": reaction_label,
	}
	var entries := {}
	var all_ok := true
	var occupied: Array[Rect2] = []
	for role_variant: Variant in zones:
		var role := StringName(role_variant)
		var label := labels_by_role[role] as Label
		var actual_rect := _control_rect_in_panel_space(label)
		var safe_zone: Rect2 = zones[role]
		# 非整数视口会产生约 0.0001px 的 Canvas 逆变换误差；0.1px 只吸收浮点噪声，不放宽 2px 视觉门槛。
		var inside_zone := safe_zone.grow(0.1).encloses(actual_rect)
		var minimum_width_fits := label.get_minimum_size().x <= actual_rect.size.x + 0.1
		var anchor_contract: Dictionary = (IDLE_ANCHORS if _display_state == STATE_IDLE else ACTIVE_ANCHORS).get(role, {})
		var circle_gap := INF
		if not anchor_contract.is_empty():
			circle_gap = _rect_to_circle_gap(actual_rect, anchor_contract["center"], float(anchor_contract["radius"]))
		elif role == &"reaction" and _display_state != STATE_IDLE:
			circle_gap = _rect_to_circle_gap(actual_rect, ACTIVE_ANCHORS[&"reaction"]["center"], float(ACTIVE_ANCHORS[&"reaction"]["radius"]))
		var circle_gap_ok := circle_gap >= LABEL_CIRCLE_GAP
		var no_overlap := true
		for prior_rect: Rect2 in occupied:
			no_overlap = no_overlap and not prior_rect.intersects(actual_rect)
		occupied.append(actual_rect)
		var entry_ok := inside_zone and minimum_width_fits and no_overlap and circle_gap_ok
		all_ok = all_ok and entry_ok
		entries[String(role)] = {
			"visible": label.visible and label.is_visible_in_tree(),
			"actual_rect": _rect_to_report(actual_rect),
			"safe_rect": _rect_to_report(safe_zone),
			"inside_zone": inside_zone,
			"minimum_width_fits": minimum_width_fits,
			"no_overlap": no_overlap,
			"circle_gap_px": circle_gap,
			"minimum_circle_gap_px": LABEL_CIRCLE_GAP,
			"circle_gap_ok": circle_gap_ok,
			"ok": entry_ok,
		}
	return {"entries": entries, "ok": all_ok}


func _link_gate_report() -> Dictionary:
	if _display_state == STATE_IDLE:
		return {"required": false, "ok": true}
	var actual_rect := _control_rect_in_panel_space(sequence_link)
	var sequence_a_center: Vector2 = ACTIVE_ANCHORS[&"sequence_a"]["center"]
	var sequence_b_center: Vector2 = ACTIVE_ANCHORS[&"sequence_b"]["center"]
	var reaction_slot: Rect2 = ACTIVE_ANCHORS[&"reaction"]["slot"]
	var inside_corridor := ACTIVE_LINK_CORRIDOR.grow(0.1).encloses(actual_rect)
	var covers_sequence_a := actual_rect.has_point(sequence_a_center)
	var covers_sequence_b := actual_rect.has_point(sequence_b_center)
	var touches_reaction := actual_rect.intersects(reaction_slot)
	return {
		"required": true,
		"actual_rect": _rect_to_report(actual_rect),
		"corridor": _rect_to_report(ACTIVE_LINK_CORRIDOR),
		"inside_corridor": inside_corridor,
		"covers_sequence_a_center": covers_sequence_a,
		"covers_sequence_b_center": covers_sequence_b,
		"touches_reaction_slot": touches_reaction,
		"ok": inside_corridor and not covers_sequence_a and not covers_sequence_b and not touches_reaction,
	}


func _control_rect_in_panel_space(control: Control) -> Rect2:
	var inverse_panel_transform := get_global_transform_with_canvas().affine_inverse()
	var control_transform := control.get_global_transform_with_canvas()
	var corners: Array[Vector2] = [
		inverse_panel_transform * (control_transform * Vector2.ZERO),
		inverse_panel_transform * (control_transform * Vector2(control.size.x, 0.0)),
		inverse_panel_transform * (control_transform * control.size),
		inverse_panel_transform * (control_transform * Vector2(0.0, control.size.y)),
	]
	var rect := Rect2(corners[0], Vector2.ZERO)
	for corner: Vector2 in corners.slice(1):
		rect = rect.expand(corner)
	return rect.abs()


func _pixel_gate_for_control(control: TextureRect, target_center: Vector2, circle_radius: float, visible: bool) -> Dictionary:
	if not visible:
		return {
			"metrics_valid": true,
			"focal_center": _vector_to_report(target_center),
			"focal_center_error": 0.0,
			"core_radius_px": 0.0,
			"core_inset_px": circle_radius,
			"inside_circle": true,
			"ok": true,
		}
	var metrics := _symbol_pixel_metrics(control.texture)
	if not bool(metrics.get("valid", false)):
		return {
			"metrics_valid": false,
			"focal_center": _vector_to_report(Vector2(-999.0, -999.0)),
			"focal_center_error": 999.0,
			"core_radius_px": 999.0,
			"core_inset_px": -999.0,
			"inside_circle": false,
			"ok": false,
		}
	var normalized_focal: Vector2 = metrics["centroid"]
	var local_focal := Vector2(
		normalized_focal.x / SYMBOL_CELL_SIZE * control.size.x,
		normalized_focal.y / SYMBOL_CELL_SIZE * control.size.y,
	)
	var panel_transform := get_global_transform_with_canvas().affine_inverse() * control.get_global_transform_with_canvas()
	var actual_focal := panel_transform * local_focal
	var transform_scale := maxf(panel_transform.x.length(), panel_transform.y.length())
	var local_pixel_scale := maxf(control.size.x, control.size.y) / SYMBOL_CELL_SIZE
	var core_radius := float(metrics["max_radius"]) * local_pixel_scale * transform_scale
	var focal_error := actual_focal.distance_to(target_center)
	var core_inset := circle_radius - core_radius
	var inside_circle := core_inset + 0.001 >= SYMBOL_MINIMUM_CORE_INSET
	return {
		"metrics_valid": true,
		"focal_center": _vector_to_report(actual_focal),
		"focal_center_error": focal_error,
		"core_radius_px": core_radius,
		"core_inset_px": core_inset,
		"inside_circle": inside_circle,
		"ok": focal_error <= STATIC_ANCHOR_TOLERANCE and inside_circle,
	}


func _symbol_pixel_metrics(texture: Texture2D) -> Dictionary:
	if texture == null:
		return {"valid": false}
	var cache_key := texture.resource_path
	if _symbol_pixel_metrics_cache.has(cache_key):
		return (_symbol_pixel_metrics_cache[cache_key] as Dictionary).duplicate()
	var image := texture.get_image()
	if image == null or image.is_empty():
		return {"valid": false}
	if image.get_size() != Vector2i(256, 256) and texture is AtlasTexture:
		var atlas_texture := texture as AtlasTexture
		if atlas_texture.atlas != null:
			var atlas_image := atlas_texture.atlas.get_image()
			var region := Rect2i(atlas_texture.region)
			if atlas_image != null and not atlas_image.is_empty() and Rect2i(Vector2i.ZERO, atlas_image.get_size()).encloses(region):
				image = atlas_image.get_region(region)
	if image.get_size() != Vector2i(256, 256):
		return {"valid": false}
	var weighted_sum := Vector2.ZERO
	var weight_total := 0.0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			if roundi(alpha * 255.0) < SYMBOL_CORE_ALPHA_THRESHOLD:
				continue
			weighted_sum += Vector2(x + 0.5, y + 0.5) * alpha
			weight_total += alpha
	if is_zero_approx(weight_total):
		return {"valid": false}
	var centroid := weighted_sum / weight_total
	var max_radius := 0.0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			if roundi(alpha * 255.0) < SYMBOL_CORE_ALPHA_THRESHOLD:
				continue
			max_radius = maxf(max_radius, Vector2(x + 0.5, y + 0.5).distance_to(centroid))
	var report := {"valid": true, "centroid": centroid, "max_radius": max_radius}
	_symbol_pixel_metrics_cache[cache_key] = report
	return report.duplicate()


func _mask_shader_path(control: TextureRect) -> String:
	var material := control.material as ShaderMaterial
	if material == null or material.shader == null:
		return ""
	return material.shader.resource_path


func _apply_icon_mask_region(control: TextureRect, glyph_id: StringName) -> void:
	var material := control.material as ShaderMaterial
	if material == null or not GLYPH_UV_REGIONS.has(glyph_id):
		return
	material.set_shader_parameter("region_uv_rect", GLYPH_UV_REGIONS[glyph_id])


func _rect_to_circle_gap(rect: Rect2, center: Vector2, radius: float) -> float:
	var delta_x := maxf(maxf(rect.position.x - center.x, center.x - rect.end.x), 0.0)
	var delta_y := maxf(maxf(rect.position.y - center.y, center.y - rect.end.y), 0.0)
	return Vector2(delta_x, delta_y).length() - radius


func _vector_to_report(value: Vector2) -> Array[float]:
	return [value.x, value.y]


func _rect_to_report(value: Rect2) -> Dictionary:
	return {
		"x": value.position.x,
		"y": value.position.y,
		"width": value.size.x,
		"height": value.size.y,
		"right": value.end.x,
		"bottom": value.end.y,
	}


func _play_element_feedback() -> void:
	_last_switch_feedback = &"element"
	if _element_tween != null and _element_tween.is_valid():
		_element_tween.kill()
	element_glyph.position = _element_base_position
	element_glyph.scale = Vector2.ONE
	element_glyph.rotation = 0.0
	if _reduced_motion_enabled:
		_element_tween = create_tween()
		element_glyph.modulate = Color(0.62, 1.0, 0.94, 1.0)
		_element_tween.tween_property(element_glyph, "modulate", Color.WHITE, 0.12)
	else:
		element_glyph.modulate = Color(0.72, 1.0, 0.96, 0.35)
		element_glyph.scale = Vector2(0.94, 0.94)
		_element_tween = create_tween()
		_element_tween.tween_property(element_glyph, "scale", Vector2(ELEMENT_FEEDBACK_MAXIMUM_SCALE, ELEMENT_FEEDBACK_MAXIMUM_SCALE), 0.10)
		_element_tween.parallel().tween_property(element_glyph, "modulate", Color.WHITE, 0.22)
		_element_tween.tween_property(element_glyph, "scale", Vector2.ONE, 0.12)


func _play_stance_feedback() -> void:
	_last_switch_feedback = &"stance"
	if _stance_tween != null and _stance_tween.is_valid():
		_stance_tween.kill()
	stance_glyph.position = _stance_base_position
	stance_glyph.scale = Vector2.ONE
	stance_glyph.rotation = 0.0
	_stance_tween = create_tween().set_parallel(true)
	if _reduced_motion_enabled:
		stance_glyph.modulate = Color(1.0, 0.86, 0.52, 1.0)
		_stance_tween.tween_property(stance_glyph, "modulate", Color.WHITE, 0.12)
	else:
		stance_glyph.modulate = Color(1.0, 0.92, 0.72, 1.0)
		stance_glyph.scale = Vector2(0.86, 0.86)
		stance_glyph.rotation = -0.08
		_stance_tween.tween_property(stance_glyph, "scale", Vector2.ONE, 0.24)
		_stance_tween.tween_property(stance_glyph, "rotation", 0.0, 0.24)
		_stance_tween.tween_property(stance_glyph, "modulate", Color.WHITE, 0.24)


func _reset_feedback_visuals() -> void:
	if _element_tween != null and _element_tween.is_valid():
		_element_tween.kill()
	if _stance_tween != null and _stance_tween.is_valid():
		_stance_tween.kill()
	if element_glyph != null:
		element_glyph.position = _element_base_position
		element_glyph.scale = Vector2.ONE
		element_glyph.rotation = 0.0
		element_glyph.modulate = Color.WHITE
	if stance_glyph != null:
		stance_glyph.position = _stance_base_position
		stance_glyph.scale = Vector2.ONE
		stance_glyph.rotation = 0.0
		stance_glyph.modulate = Color.WHITE


func _normalize_sequence_ids(raw_ids: Array) -> Array[StringName]:
	var normalized: Array[StringName] = []
	var start_index := maxi(raw_ids.size() - 2, 0)
	for index in range(start_index, raw_ids.size()):
		normalized.append(_normalize_element_id(raw_ids[index]))
	return normalized


func _normalize_element_id(raw_id: Variant) -> StringName:
	var normalized := StringName(str(raw_id))
	return normalized if normalized == ELEMENT_WIND or normalized == ELEMENT_THUNDER else ELEMENT_THUNDER


func _normalize_stance_id(raw_id: Variant) -> StringName:
	var normalized := StringName(str(raw_id))
	return normalized if normalized == STANCE_SWIFT or normalized == STANCE_WARD else STANCE_SWIFT


func _reaction_for_sequence(ids: Array[StringName]) -> StringName:
	if ids == [ELEMENT_WIND, ELEMENT_THUNDER]:
		return REACTION_PIERCE
	if ids == [ELEMENT_THUNDER, ELEMENT_WIND]:
		return REACTION_SCATTER
	return StringName()


func _reaction_mode_for_id(reaction_id: StringName) -> float:
	if reaction_id == REACTION_PIERCE:
		return 1.0
	if reaction_id == REACTION_SCATTER:
		return 2.0
	return 0.0
