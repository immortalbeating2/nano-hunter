extends Node2D

# 本场景在真实窗口中逐项驱动两个生产 Boss 的状态同步函数，保存运行时截图和机器可读连续性报告。
# 它只做审查，不修改 Boss 玩法、碰撞、伤害或生产场景绑定。

const SEAL_GUARDIAN_SCENE := preload("res://scenes/enemies/seal_guardian_boss.tscn")
const KUI_THUNDER_BOSS_SCENE := preload("res://scenes/enemies/kui_thunder_boss.tscn")
const MODEL_LOCK_MANIFEST_PATH := "res://docs/assets/character-creature-model-locks.json"
const OUT_DIR := "res://tests/artifacts/local/character-creature-model-lock/runtime-continuity"
const CANVAS_SIZE := Vector2i(1280, 720)
const REVIEW_OWNER_SCALE := Vector2(1.75, 1.75)

const SEAL_CASES: Array[Dictionary] = [
	{"label": "phase1_idle", "phase": 1, "state": &"idle"},
	{"label": "phase1_close_warning", "phase": 1, "state": &"close_pressure", "planned": &"ground_impact"},
	{"label": "phase1_air_warning", "phase": 1, "state": &"close_pressure", "planned": &"air_punish"},
	{"label": "phase1_ground_impact", "phase": 1, "state": &"ground_impact"},
	{"label": "phase1_air_punish", "phase": 1, "state": &"air_punish"},
	{"label": "phase1_recovery", "phase": 1, "state": &"recovery"},
	{"label": "guard_break", "phase": 1, "state": &"staggered"},
	{"label": "hit", "phase": 1, "state": &"idle", "hit": true},
	{"label": "phase_transition", "phase": 2, "state": &"idle", "transition": true},
	{"label": "phase2_idle", "phase": 2, "state": &"idle"},
	{"label": "defeated", "phase": 2, "state": &"defeated"},
]

const KUI_CASES: Array[Dictionary] = [
	{"label": "phase1_idle", "phase": 1, "state": &"idle"},
	{"label": "phase1_close_warning", "phase": 1, "state": &"close_pressure", "planned": &"ground_impact"},
	{"label": "phase1_lightning_warning", "phase": 1, "state": &"close_pressure", "planned": &"air_punish"},
	{"label": "phase1_close_attack", "phase": 1, "state": &"ground_impact"},
	{"label": "phase1_lightning_attack", "phase": 1, "state": &"air_punish"},
	{"label": "phase1_recovery", "phase": 1, "state": &"recovery"},
	{"label": "guard_break", "phase": 1, "state": &"staggered"},
	{"label": "scatter_stagger", "phase": 1, "state": &"staggered", "scatter": true},
	{"label": "hit", "phase": 1, "state": &"idle", "hit": true},
	{"label": "phase_transition", "phase": 2, "state": &"idle", "transition": true},
	{"label": "phase2_idle", "phase": 2, "state": &"idle"},
	{"label": "phase2_close_warning", "phase": 2, "state": &"close_pressure", "planned": &"ground_impact"},
	{"label": "phase2_lightning_warning", "phase": 2, "state": &"close_pressure", "planned": &"air_punish"},
	{"label": "phase2_close_attack", "phase": 2, "state": &"ground_impact"},
	{"label": "phase2_lightning_attack", "phase": 2, "state": &"air_punish"},
	{"label": "phase2_recovery", "phase": 2, "state": &"recovery"},
	{"label": "defeated", "phase": 2, "state": &"defeated"},
]

var _title_label: Label
var _state_label: Label
var _contract_label: Label
var _seal_boss: StaticBody2D
var _kui_boss: StaticBody2D
var _model_lock_by_asset: Dictionary = {}
var _records: Array[Dictionary] = []
var _root_markers: Array[Vector2] = []
var _canvas_size := Vector2(CANVAS_SIZE)
var _ground_y := 548.0


func _ready() -> void:
	set_meta("review_complete", false)
	set_meta("review_ok", false)
	get_window().size = CANVAS_SIZE
	_load_model_lock_contract()
	call_deferred("_run_review")


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, _canvas_size), Color("07151d"), true)
	draw_rect(Rect2(0.0, _ground_y, _canvas_size.x, _canvas_size.y - _ground_y), Color("0b222b"), true)
	draw_line(Vector2(48.0, _ground_y), Vector2(_canvas_size.x - 48.0, _ground_y), Color("4de6ec"), 2.0)
	for marker: Vector2 in _root_markers:
		draw_circle(marker, 7.0, Color("f0bc42"))
		draw_line(marker - Vector2(13.0, 0.0), marker + Vector2(13.0, 0.0), Color.WHITE, 1.0)
		draw_line(marker - Vector2(0.0, 13.0), marker + Vector2(0.0, 13.0), Color.WHITE, 1.0)


func _build_review_overlay() -> void:
	var overlay := CanvasLayer.new()
	overlay.layer = 10
	add_child(overlay)

	var top_panel := ColorRect.new()
	top_panel.position = Vector2(24.0, 20.0)
	top_panel.size = Vector2(_canvas_size.x - 48.0, 172.0)
	top_panel.color = Color(0.02, 0.08, 0.11, 0.94)
	overlay.add_child(top_panel)

	_title_label = Label.new()
	_title_label.position = Vector2(48.0, 34.0)
	_title_label.size = Vector2(_canvas_size.x - 96.0, 48.0)
	_title_label.add_theme_font_size_override("font_size", 34)
	_title_label.add_theme_color_override("font_color", Color("dceff2"))
	_title_label.text = "BOSS MODEL LOCK — TRUE WINDOW CONTINUITY REVIEW"
	overlay.add_child(_title_label)

	_state_label = Label.new()
	_state_label.position = Vector2(48.0, 88.0)
	_state_label.size = Vector2(_canvas_size.x - 96.0, 46.0)
	_state_label.add_theme_font_size_override("font_size", 24)
	_state_label.add_theme_color_override("font_color", Color("63e2d6"))
	overlay.add_child(_state_label)

	_contract_label = Label.new()
	_contract_label.position = Vector2(48.0, 140.0)
	_contract_label.size = Vector2(_canvas_size.x - 96.0, 36.0)
	_contract_label.add_theme_font_size_override("font_size", 18)
	_contract_label.add_theme_color_override("font_color", Color("9eb8bf"))
	_contract_label.text = "gold=root contract  cyan=review ground  technical identity lock only; Gate26H / final_ready remain manual"
	overlay.add_child(_contract_label)


func _load_model_lock_contract() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MODEL_LOCK_MANIFEST_PATH))
	if not parsed is Dictionary:
		push_error("Cannot parse model-lock manifest: %s" % MODEL_LOCK_MANIFEST_PATH)
		return
	for family_value: Variant in (parsed as Dictionary).get("families", []):
		var family := family_value as Dictionary
		for asset_value: Variant in family.get("assets", []):
			var asset := asset_value as Dictionary
			var asset_id := str(asset.get("asset_id", ""))
			_model_lock_by_asset[asset_id] = {
				"model_id": str(family.get("model_id", "")),
				"cell": family.get("cell", []),
				"center_x": float(family.get("center_x", 0.0)),
				"root_y": int(family.get("root_y", 0)),
				"identity_lock_ready": bool(asset.get("identity_lock_ready", family.get("identity_lock_ready", false))),
				"runtime_binding_allowed": bool(asset.get("runtime_binding_allowed", family.get("runtime_binding_allowed", false))),
				"status": str(asset.get("status", "active")),
			}


func _run_review() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_canvas_size = get_viewport_rect().size
	_ground_y = _canvas_size.y * 0.74
	_build_review_overlay()
	queue_redraw()
	var out_absolute := ProjectSettings.globalize_path(OUT_DIR)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(out_absolute)
	if mkdir_error != OK:
		push_error("Cannot create runtime continuity evidence directory: %s" % out_absolute)
		_finish_review(false, "")
		return

	_seal_boss = SEAL_GUARDIAN_SCENE.instantiate() as StaticBody2D
	_kui_boss = KUI_THUNDER_BOSS_SCENE.instantiate() as StaticBody2D
	add_child(_seal_boss)
	add_child(_kui_boss)
	_seal_boss.scale = REVIEW_OWNER_SCALE
	_kui_boss.scale = REVIEW_OWNER_SCALE
	_seal_boss.set_physics_process(false)
	_kui_boss.set_physics_process(false)
	await get_tree().process_frame

	await _run_boss_cases(
		_seal_boss,
		"seal_guardian",
		"seal_guardian_model_v1",
		SEAL_CASES
	)
	await _run_boss_cases(
		_kui_boss,
		"kui_thunder_boss",
		"kui_thunder_boss_model_v1",
		KUI_CASES
	)

	var all_rows_ok := true
	for row: Dictionary in _records:
		if not bool(row.get("ok", false)):
			all_rows_ok = false
	var counts_ok := (
		_count_rows_for_boss("seal_guardian") == SEAL_CASES.size()
		and _count_rows_for_boss("kui_thunder_boss") == KUI_CASES.size()
	)
	var continuity_ok := (
		_root_offsets_are_continuous("seal_guardian")
		and _root_offsets_are_continuous("kui_thunder_boss")
	)

	await _show_summary(all_rows_ok and counts_ok and continuity_ok)
	var summary_capture := await _save_screenshot("runtime_continuity_summary.png")
	var overall_ok := all_rows_ok and counts_ok and continuity_ok and bool(summary_capture.get("saved", false))
	var report := {
		"contract_kind": "boss_model_lock_runtime_continuity_v1",
		"created_at": Time.get_datetime_string_from_system(false, true),
		"scene": "res://scenes/dev/boss_model_lock_runtime_continuity_review.tscn",
		"display_server": DisplayServer.get_name(),
		"renderer": str(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")),
		"headless": DisplayServer.get_name().to_lower() == "headless",
		"production_sources": [
			"res://scenes/enemies/seal_guardian_boss.tscn",
			"res://scenes/enemies/kui_thunder_boss.tscn",
		],
		"checks": {
			"all_state_rows_pass": all_rows_ok,
			"expected_state_counts": counts_ok,
			"root_offsets_continuous": continuity_ok,
			"real_window_renderer": DisplayServer.get_name().to_lower() != "headless",
			"summary_screenshot_saved": bool(summary_capture.get("saved", false)),
		},
		"state_counts": {
			"seal_guardian": _count_rows_for_boss("seal_guardian"),
			"kui_thunder_boss": _count_rows_for_boss("kui_thunder_boss"),
			"total": _records.size(),
		},
		"records": _records,
		"summary_screenshot": summary_capture,
		"technical_identity_lock_status": "pass" if overall_ok else "fail",
		"human_identity_status": "pending_gate26h",
		"final_ready_status": "not_granted_by_this_review",
	}
	var report_path := "%s/boss_runtime_continuity_report.json" % OUT_DIR
	var report_written := _write_json(report_path, report)
	overall_ok = overall_ok and report_written and not bool(report.get("headless", true))
	_finish_review(overall_ok, report_path)


func _run_boss_cases(
	boss: StaticBody2D,
	boss_id: String,
	expected_model_id: String,
	cases: Array[Dictionary]
) -> void:
	_seal_boss.visible = boss == _seal_boss
	_kui_boss.visible = boss == _kui_boss
	for state_case: Dictionary in cases:
		var record := await _apply_case_and_capture(boss, boss_id, expected_model_id, state_case)
		_records.append(record)


func _apply_case_and_capture(
	boss: StaticBody2D,
	boss_id: String,
	expected_model_id: String,
	state_case: Dictionary
) -> Dictionary:
	boss.set("_phase_index", int(state_case.get("phase", 1)))
	boss.set("_phase_transition_visual_remaining", 0.0)
	boss.set("_hit_flash_remaining", 0.0)
	if boss_id == "kui_thunder_boss":
		boss.set("_scatter_stagger_bonus", bool(state_case.get("scatter", false)))
	boss.set("current_state", &"__model_lock_review_reset__")
	boss.call("_enter_state", state_case.get("state", &"idle"))
	boss.set("_planned_strike_state", state_case.get("planned", &"ground_impact"))
	_set_mid_state_elapsed(boss, state_case.get("state", &"idle"))
	if bool(state_case.get("hit", false)):
		boss.set("_hit_flash_remaining", 0.4)
	if bool(state_case.get("transition", false)):
		boss.set("_phase_transition_visual_remaining", 0.4)
	boss.call("_sync_runtime_animation_visual")
	boss.call("_sync_attack_vfx_visual")

	var visual := boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var asset_id := str(visual.get_meta("asset_id", ""))
	var lock := _model_lock_by_asset.get(asset_id, {}) as Dictionary
	_align_visual_root_to_ground(boss, visual, lock)
	var root_global := _visual_root_global(visual, lock)
	_root_markers = [root_global]
	queue_redraw()
	_state_label.text = "%s  /  %s  /  state=%s  animation=%s  frame=%d" % [
		boss_id,
		state_case.get("label", ""),
		boss.call("get_boss_state"),
		visual.animation,
		visual.frame,
	]
	_contract_label.text = "asset=%s  model=%s  root_delta=%.3f px  technical lock only; Gate26H / final_ready remain manual" % [
		asset_id,
		lock.get("model_id", "unregistered"),
		absf(root_global.y - _ground_y),
	]

	await get_tree().process_frame
	var screenshot_name := "%s__%s.png" % [boss_id, state_case.get("label", "state")]
	var capture := await _save_screenshot(screenshot_name)
	root_global = _visual_root_global(visual, lock)
	var root_owner := boss.to_local(root_global)
	var resource_path := visual.sprite_frames.resource_path if visual.sprite_frames != null else ""
	var checks := {
		"registered_asset": not lock.is_empty(),
		"expected_model": str(lock.get("model_id", "")) == expected_model_id,
		"identity_lock_ready": bool(lock.get("identity_lock_ready", false)),
		"runtime_binding_allowed": bool(lock.get("runtime_binding_allowed", false)),
		"active_asset": str(lock.get("status", "")) == "active",
		"animation_exists": visual.sprite_frames != null and visual.sprite_frames.has_animation(visual.animation),
		"visible": visual.visible,
		"root_on_review_ground": absf(root_global.y - _ground_y) <= 0.75,
		"screenshot_saved": bool(capture.get("saved", false)),
	}
	var ok := true
	for value: Variant in checks.values():
		if not bool(value):
			ok = false
	return {
		"boss_id": boss_id,
		"expected_model_id": expected_model_id,
		"case": str(state_case.get("label", "")),
		"phase": int(state_case.get("phase", 1)),
		"state": str(boss.call("get_boss_state")),
		"animation": str(visual.animation),
		"frame": visual.frame,
		"asset_id": asset_id,
		"sprite_frames": resource_path,
		"visual_position": [visual.position.x, visual.position.y],
		"visual_scale": [visual.scale.x, visual.scale.y],
		"review_owner_scale": [boss.scale.x, boss.scale.y],
		"root_global": [root_global.x, root_global.y],
		"root_local_to_owner": [root_owner.x, root_owner.y],
		"root_ground_delta": absf(root_global.y - _ground_y),
		"model_lock": lock,
		"screenshot": capture,
		"checks": checks,
		"ok": ok,
	}


func _set_mid_state_elapsed(boss: StaticBody2D, state: StringName) -> void:
	var elapsed := 0.0
	match state:
		&"close_pressure":
			elapsed = float(boss.get("windup_duration")) * 0.55
		&"ground_impact", &"air_punish":
			elapsed = float(boss.get("strike_duration")) * 0.55
		&"recovery":
			elapsed = float(boss.call("_get_phase_adjusted_recovery_duration")) * 0.55
		&"staggered":
			elapsed = float(boss.call("_get_stagger_duration")) * 0.55
	boss.set("_state_elapsed", elapsed)


func _align_visual_root_to_ground(
	boss: StaticBody2D,
	visual: AnimatedSprite2D,
	lock: Dictionary
) -> void:
	boss.position = Vector2(_canvas_size.x * 0.5, _ground_y)
	var root_global := _visual_root_global(visual, lock)
	boss.position.y += _ground_y - root_global.y


func _visual_root_global(visual: AnimatedSprite2D, lock: Dictionary) -> Vector2:
	var cell := lock.get("cell", []) as Array
	if cell.size() != 2:
		return visual.global_position
	var local_root := Vector2(
		float(lock.get("center_x", 0.0)) - float(cell[0]) * 0.5,
		float(lock.get("root_y", 0)) - float(cell[1]) * 0.5
	)
	return visual.to_global(local_root + visual.offset)


func _show_summary(overall_ok: bool) -> void:
	_seal_boss.visible = true
	_kui_boss.visible = true
	_prepare_summary_boss(_seal_boss, _canvas_size.x * 0.31, 1)
	_prepare_summary_boss(_kui_boss, _canvas_size.x * 0.70, 2)
	var seal_visual := _seal_boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var kui_visual := _kui_boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var seal_lock := _model_lock_by_asset.get(str(seal_visual.get_meta("asset_id", "")), {}) as Dictionary
	var kui_lock := _model_lock_by_asset.get(str(kui_visual.get_meta("asset_id", "")), {}) as Dictionary
	var seal_root := _visual_root_global(seal_visual, seal_lock)
	var kui_root := _visual_root_global(kui_visual, kui_lock)
	_root_markers = [seal_root, kui_root]
	queue_redraw()
	_title_label.text = "BOSS MODEL LOCK CONTINUITY — %s" % ("PASS" if overall_ok else "FAIL")
	_state_label.text = "Seal Guardian %d/%d states  |  Kui Thunder Boss %d/%d states  |  total %d" % [
		_count_rows_for_boss("seal_guardian"),
		SEAL_CASES.size(),
		_count_rows_for_boss("kui_thunder_boss"),
		KUI_CASES.size(),
		_records.size(),
	]
	_contract_label.text = "all body assets registered + identity_lock_ready + runtime_binding_allowed; Gate26H identity art and final_ready remain open"
	await get_tree().process_frame


func _prepare_summary_boss(boss: StaticBody2D, x_position: float, phase: int) -> void:
	boss.set("_phase_index", phase)
	boss.set("_phase_transition_visual_remaining", 0.0)
	boss.set("_hit_flash_remaining", 0.0)
	if boss == _kui_boss:
		boss.set("_scatter_stagger_bonus", false)
	boss.set("current_state", &"__model_lock_review_reset__")
	boss.call("_enter_state", &"idle")
	boss.call("_sync_runtime_animation_visual")
	boss.call("_sync_attack_vfx_visual")
	var visual := boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var lock := _model_lock_by_asset.get(str(visual.get_meta("asset_id", "")), {}) as Dictionary
	boss.position = Vector2(x_position, _ground_y)
	var root_global := _visual_root_global(visual, lock)
	boss.position.y += _ground_y - root_global.y


func _save_screenshot(file_name: String) -> Dictionary:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var relative_path := "%s/%s" % [OUT_DIR, file_name]
	if image == null or image.is_empty():
		return {"path": relative_path, "saved": false, "size": [0, 0]}
	var save_error := image.save_png(ProjectSettings.globalize_path(relative_path))
	return {
		"path": relative_path,
		"saved": save_error == OK,
		"size": [image.get_width(), image.get_height()],
	}


func _count_rows_for_boss(boss_id: String) -> int:
	var count := 0
	for row: Dictionary in _records:
		if str(row.get("boss_id", "")) == boss_id:
			count += 1
	return count


func _root_offsets_are_continuous(boss_id: String) -> bool:
	var baseline: Vector2
	var has_baseline := false
	for row: Dictionary in _records:
		if str(row.get("boss_id", "")) != boss_id:
			continue
		var values := row.get("root_local_to_owner", []) as Array
		if values.size() != 2:
			return false
		var offset := Vector2(float(values[0]), float(values[1]))
		if not has_baseline:
			baseline = offset
			has_baseline = true
		elif baseline.distance_to(offset) > 0.05:
			return false
	return has_baseline


func _write_json(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write runtime continuity report: %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
	return true


func _finish_review(ok: bool, report_path: String) -> void:
	set_meta("review_complete", true)
	set_meta("review_ok", ok)
	set_meta("report_path", report_path)
	print(
		"BOSS_MODEL_LOCK_RUNTIME_CONTINUITY_%s: states=%d report=%s" % [
			"OK" if ok else "FAILED",
			_records.size(),
			report_path,
		]
	)
	if not ok:
		push_error("Boss model-lock runtime continuity review failed; inspect report and screenshots.")
