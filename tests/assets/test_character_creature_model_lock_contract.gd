extends GutTest

# 本专项回归保护角色 / 怪物 / Boss 的中央模型锁与生产绑定边界：
# 自动几何由 Python 像素审计负责；这里验证 Godot 可读契约、活跃绑定完整性和 Seal Guardian 跨状态连续性。
const MODEL_LOCK_MANIFEST_PATH := "res://docs/assets/character-creature-model-locks.json"
const SEAL_GUARDIAN_SCENE := preload("res://scenes/enemies/seal_guardian_boss.tscn")
const KUI_THUNDER_BOSS_SCENE := preload("res://scenes/enemies/kui_thunder_boss.tscn")
const SEAL_GUARDIAN_FORMAL_FRAMES := preload("res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_formal_motion_runtime_sheet_ai01.spriteframes.tres")
const PRODUCTION_BINDING_ROOTS: Array[String] = [
	"res://scripts",
	"res://scenes",
]
const PRODUCTION_BINDING_EXCLUSIONS: Array[String] = [
	"res://scripts/assets",
	"res://scripts/dev",
	"res://scenes/dev",
	"res://tests",
]


func test_central_contract_covers_every_live_body_family_and_sidecar() -> void:
	var manifest := _read_json(MODEL_LOCK_MANIFEST_PATH)
	assert_eq(manifest.get("contract_kind", ""), "character_creature_model_lock_v1")
	assert_eq(int(manifest.get("version", 0)), 2)
	var family_count := 0
	var asset_count := 0
	var active_count := 0
	var rejected_count := 0
	for family_value: Variant in manifest.get("families", []):
		var family := family_value as Dictionary
		family_count += 1
		assert_eq(family.get("identity_review_status", ""), "pending_gate26h")
		assert_true(bool(family.get("identity_lock_ready", false)))
		var semantic_contract := family.get("semantic_anchor_contract", {}) as Dictionary
		var core_anchor_id := str(semantic_contract.get("core_anchor_id", ""))
		var required_anchors := semantic_contract.get("required_anchors", []) as Array
		assert_true(required_anchors.has("root"))
		assert_true(required_anchors.has("foot_contact"))
		assert_true(required_anchors.has("head_top"))
		assert_true(required_anchors.has(core_anchor_id))
		assert_true(required_anchors.has("front_contour"))
		assert_true(required_anchors.has("rear_contour"))
		var canonical_found := false
		for asset_value: Variant in family.get("assets", []):
			var asset := asset_value as Dictionary
			asset_count += 1
			var asset_id := str(asset.get("asset_id", ""))
			var status := str(asset.get("status", "active"))
			if status == "active":
				active_count += 1
			else:
				rejected_count += 1
			if asset_id == str(family.get("canonical_reference", "")) and status == "active":
				canonical_found = true
			var asset_root := str(family.get("asset_root", ""))
			var frames_sidecar := _read_json("res://%s/%s.frames.json" % [asset_root, asset_id])
			var source_sidecar := _read_json("res://%s/%s.source.json" % [asset_root, asset_id])
			_assert_sidecar_lock(frames_sidecar, family, asset)
			_assert_sidecar_lock(source_sidecar, family, asset)
		assert_true(canonical_found, "%s needs one active canonical reference" % family.get("model_id", ""))
	assert_eq(family_count, 8)
	assert_eq(asset_count, 26)
	assert_eq(active_count, 25)
	assert_eq(rejected_count, 1)


func test_production_bindings_use_all_active_assets_and_no_rejected_reference() -> void:
	var manifest := _read_json(MODEL_LOCK_MANIFEST_PATH)
	var production_text := ""
	var allowed_assets: Dictionary = {}
	for root_path: String in PRODUCTION_BINDING_ROOTS:
		production_text += _read_source_tree(root_path)
	for family_value: Variant in manifest.get("families", []):
		var family := family_value as Dictionary
		for asset_value: Variant in family.get("assets", []):
			var asset := asset_value as Dictionary
			var asset_id := str(asset.get("asset_id", ""))
			var status := str(asset.get("status", "active"))
			var runtime_allowed := bool(
				asset.get("runtime_binding_allowed", family.get("runtime_binding_allowed", false))
			)
			var resource_path := "res://%s/%s.spriteframes.tres" % [family.get("asset_root", ""), asset_id]
			if status == "active" and runtime_allowed:
				allowed_assets[asset_id] = true
				assert_true(production_text.contains(resource_path), "%s is not bound by production code or scenes" % asset_id)
			else:
				assert_false(production_text.contains(asset_id), "%s must not remain in production bindings" % asset_id)

	var path_pattern := RegEx.new()
	path_pattern.compile(
		"res://assets/art/characters/(?:player|enemies)/sprite_sheets/runtime_replacement/([A-Za-z0-9_]+)\\.spriteframes\\.tres"
	)
	for result: RegExMatch in path_pattern.search_all(production_text):
		var asset_id := result.get_string(1)
		assert_true(allowed_assets.has(asset_id), "unknown or blocked production body: %s" % asset_id)


func test_seal_guardian_all_live_states_keep_one_formal_model_lock_body() -> void:
	var boss := SEAL_GUARDIAN_SCENE.instantiate() as StaticBody2D
	add_child_autofree(boss)
	await get_tree().process_frame
	var visual := boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var states: Array[StringName] = [
		&"idle",
		&"close_pressure",
		&"ground_impact",
		&"air_punish",
		&"recovery",
		&"staggered",
		&"defeated",
	]
	for state: StringName in states:
		boss.call("_enter_state", state)
		assert_eq(visual.sprite_frames, SEAL_GUARDIAN_FORMAL_FRAMES, String(state))
		assert_eq(
			visual.get_meta("asset_id", ""),
			"seal_guardian_formal_motion_runtime_sheet_ai01",
			String(state)
		)
		assert_ne(visual.animation, &"idle", String(state))

	boss.call("_enter_state", &"idle")
	boss.set("_phase_transition_visual_remaining", 0.4)
	boss.call("_sync_runtime_animation_visual")
	assert_eq(visual.sprite_frames, SEAL_GUARDIAN_FORMAL_FRAMES)
	assert_eq(visual.animation, &"phase_transition")
	boss.set("_phase_transition_visual_remaining", 0.0)
	boss.set("_hit_flash_remaining", 0.2)
	boss.call("_sync_runtime_animation_visual")
	assert_eq(visual.sprite_frames, SEAL_GUARDIAN_FORMAL_FRAMES)
	assert_eq(visual.animation, &"hit")


func test_kui_boss_all_live_states_keep_registered_model_lock_bodies() -> void:
	var manifest := _read_json(MODEL_LOCK_MANIFEST_PATH)
	var allowed_assets: Dictionary = {}
	for family_value: Variant in manifest.get("families", []):
		var family := family_value as Dictionary
		if str(family.get("model_id", "")) != "kui_thunder_boss_model_v1":
			continue
		for asset_value: Variant in family.get("assets", []):
			var asset := asset_value as Dictionary
			if str(asset.get("status", "active")) == "active":
				allowed_assets[str(asset.get("asset_id", ""))] = true
	assert_eq(allowed_assets.size(), 5)

	var boss := KUI_THUNDER_BOSS_SCENE.instantiate() as StaticBody2D
	add_child_autofree(boss)
	await get_tree().process_frame
	var visual := boss.get_node("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var state_cases: Array[Dictionary] = [
		{"label": "phase1_idle", "phase": 1, "state": &"idle"},
		{"label": "phase1_close_warning", "phase": 1, "state": &"close_pressure", "planned": &"ground_impact"},
		{"label": "phase1_lightning_warning", "phase": 1, "state": &"close_pressure", "planned": &"air_punish"},
		{"label": "phase1_close_attack", "phase": 1, "state": &"ground_impact"},
		{"label": "phase1_lightning_attack", "phase": 1, "state": &"air_punish"},
		{"label": "phase1_recovery", "phase": 1, "state": &"recovery"},
		{"label": "guard_break", "phase": 1, "state": &"staggered"},
		{"label": "scatter_stagger", "phase": 1, "state": &"staggered", "scatter": true},
		{"label": "phase2_idle", "phase": 2, "state": &"idle"},
		{"label": "phase2_close_warning", "phase": 2, "state": &"close_pressure", "planned": &"ground_impact"},
		{"label": "phase2_lightning_warning", "phase": 2, "state": &"close_pressure", "planned": &"air_punish"},
		{"label": "phase2_close_attack", "phase": 2, "state": &"ground_impact"},
		{"label": "phase2_lightning_attack", "phase": 2, "state": &"air_punish"},
		{"label": "phase2_recovery", "phase": 2, "state": &"recovery"},
		{"label": "defeated", "phase": 2, "state": &"defeated"},
	]
	for state_case: Dictionary in state_cases:
		boss.set("_phase_index", int(state_case.get("phase", 1)))
		boss.set("_planned_strike_state", state_case.get("planned", &"ground_impact"))
		boss.set("_scatter_stagger_bonus", bool(state_case.get("scatter", false)))
		boss.set("_phase_transition_visual_remaining", 0.0)
		boss.set("_hit_flash_remaining", 0.0)
		boss.call("_enter_state", state_case["state"])
		var asset_id := str(visual.get_meta("asset_id", ""))
		assert_true(allowed_assets.has(asset_id), "%s -> %s" % [state_case["label"], asset_id])
		assert_true(visual.sprite_frames.has_animation(visual.animation), str(state_case["label"]))

	for overlay_case: Dictionary in [
		{"label": "hit", "property": "_hit_flash_remaining"},
		{"label": "phase_transition", "property": "_phase_transition_visual_remaining"},
	]:
		boss.set("_phase_index", 2)
		boss.call("_enter_state", &"idle")
		boss.set(overlay_case["property"], 0.4)
		boss.call("_sync_runtime_animation_visual")
		var asset_id := str(visual.get_meta("asset_id", ""))
		assert_true(allowed_assets.has(asset_id), "%s -> %s" % [overlay_case["label"], asset_id])


func _assert_sidecar_lock(payload: Dictionary, family: Dictionary, asset: Dictionary) -> void:
	var lock := payload.get("model_lock", {}) as Dictionary
	assert_eq(lock.get("contract_kind", ""), "character_creature_model_lock_v1")
	assert_eq(int(lock.get("contract_version", 0)), 2)
	assert_eq(lock.get("model_id", ""), family.get("model_id", ""))
	assert_eq(lock.get("canonical_reference", ""), family.get("canonical_reference", ""))
	assert_eq(lock.get("cell", []), family.get("cell", []))
	assert_eq(
		bool(lock.get("runtime_binding_allowed", false)),
		bool(asset.get("runtime_binding_allowed", family.get("runtime_binding_allowed", false)))
	)
	assert_eq(
		bool(lock.get("identity_lock_ready", false)),
		bool(asset.get("identity_lock_ready", family.get("identity_lock_ready", false)))
	)
	assert_eq(lock.get("semantic_anchor_contract", {}), family.get("semantic_anchor_contract", {}))
	assert_eq(lock.get("asset_status", ""), asset.get("status", "active"))


func _read_json(path: String) -> Dictionary:
	assert_true(FileAccess.file_exists(path), "missing JSON: %s" % path)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_true(parsed is Dictionary, "invalid JSON object: %s" % path)
	return parsed as Dictionary


func _read_source_tree(path: String) -> String:
	if _is_excluded_production_path(path):
		return ""
	var combined := ""
	for file_name: String in DirAccess.get_files_at(path):
		var extension := file_name.get_extension().to_lower()
		if extension == "gd" or extension == "tscn":
			combined += FileAccess.get_file_as_string(path.path_join(file_name)) + "\n"
	for directory_name: String in DirAccess.get_directories_at(path):
		combined += _read_source_tree(path.path_join(directory_name))
	return combined


func _is_excluded_production_path(path: String) -> bool:
	for excluded_path: String in PRODUCTION_BINDING_EXCLUSIONS:
		if path == excluded_path or path.begins_with(excluded_path + "/"):
			return true
	return false
