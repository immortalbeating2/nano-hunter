extends GutTest

# Stage17 资产收口测试保护“正式运行接入不再依赖隐藏 Preview”的边界。
# 开发画廊仍可使用 Preview 命名；这里只扫描正式场景和运行资源。

const DISPOSITION_DOC := "res://docs/assets/2026-07-12-final-asset-disposition.md"
const RUNTIME_SOURCE_REPORT := "res://docs/assets/runtime-source-safety-report.json"
const FINAL_ACCEPTANCE_REPORT := "res://docs/assets/final-art-acceptance-gates.json"
const FINALIZATION_REVIEWS := "res://docs/assets/asset-finalization-review-records.json"
const RUNTIME_MAP_REPORT := "res://docs/assets/asset-runtime-integration-map.json"
const P0_RUNTIME_PLAN := "res://docs/assets/p0-runtime-replacement-plan.json"
const P0_REHEARSAL_MANIFEST := "res://docs/assets/p0-runtime-replacement-rehearsal-manifest.json"
const P0_TARGET_MATRIX := "res://docs/assets/p0-target-scene-replacement-matrix.json"
const P0_SCENE_BATCHES := "res://docs/assets/p0-scene-replacement-batches.json"
const ASSET_PACKAGE_REPORT := "res://docs/assets/asset-package-audit-report.json"
const SOURCE_ONLY_BINDING_NODE_NAMES := [
	"LunaReadabilityArt",
	"SealGuardianArt",
	"AttackWarningArt",
	"SealGuardianRoomArt",
	"BossWarningRoomArt",
	"AbilityStatusFrameArt",
	"BossHudFrameArt",
]
const NON_RUNTIME_P0_ASSET_IDS := [
	"stage16_luna_player_readability_ai01",
	"stage14_air_dash_icon_ai01",
	"stage14_air_dash_shrine_ai01",
	"stage14_air_dash_gate_ai01",
	"stage15_seal_guardian_ai01",
	"stage15_boss_attack_warning_ai01",
	"stage15_recovery_charge_icon_ai01",
	"luna_run_sheet_ai01",
	"luna_air_dash_sheet_ai01",
	"luna_attack_01_sheet_ai01",
	"luna_idle_sheet_ai01",
	"seal_guardian_boss_sheet_ai01",
	"miasma_marsh_tileset_ai01",
	"luna_jump_fall_sheet_ai01",
	"luna_hit_death_sheet_ai01",
	"enemies_core_sheet_ai01",
	"stage15_boss_hud_frame_ai01",
	"stage14_ability_status_hud_ai01",
	"vfx_combat_atlas_ai01",
]
const RETIRED_SVG_PATHS := [
	"assets/art/characters/player/stage12_player_silhouette.svg",
	"assets/art/characters/enemies/stage12_basic_melee_silhouette.svg",
	"assets/art/characters/enemies/stage12_ground_charger_silhouette.svg",
	"assets/art/characters/enemies/stage12_aerial_sentinel_silhouette.svg",
	"assets/art/characters/enemies/stage13_miasma_caster_silhouette.svg",
	"assets/art/vfx/stage12_slash_vfx.svg",
	"assets/art/vfx/stage12_hit_spark_vfx.svg",
	"assets/art/vfx/stage13_miasma_hazard_warning_01.svg",
	"assets/art/ui/stage12_checkpoint_gate_goal_icons.svg",
	"assets/art/environment/biome_02_miasma_marsh/stage13_miasma_marsh_background_01.svg",
	"assets/art/environment/biome_02_miasma_marsh/stage13_miasma_marsh_tiles_01.svg",
	"assets/art/props/stage13_miasma_marsh_goal_device_01.svg",
	"assets/art/props/stage13_seal_gate_01.svg",
	"assets/art/props/stage13_seal_node_01.svg",
]


# 正式场景节点名不再允许以 Preview 伪装成运行接入证据。
func test_production_scenes_have_no_preview_named_nodes() -> void:
	var failures := PackedStringArray()
	for scene_path: String in _collect_files("res://scenes", PackedStringArray(["tscn"]), PackedStringArray(["res://scenes/dev"])):
		var lines := FileAccess.get_file_as_string(scene_path).split("\n")
		for line_index: int in range(lines.size()):
			var line: String = lines[line_index]
			if line.begins_with("[node name=\"") and line.contains("Preview"):
				failures.append("%s:%d %s" % [scene_path, line_index + 1, line])

	assert_eq(failures.size(), 0, "正式场景仍有 Preview 节点：\n%s" % "\n".join(failures))


# 已被正式动画、VFX 或拆分 UI 替代的方向稿节点不得继续伪装成场景接入。
func test_production_scenes_have_no_known_source_only_binding_nodes() -> void:
	var failures := PackedStringArray()
	for scene_path: String in _collect_files("res://scenes", PackedStringArray(["tscn"]), PackedStringArray(["res://scenes/dev"])):
		var content := FileAccess.get_file_as_string(scene_path)
		for node_name: String in SOURCE_ONLY_BINDING_NODE_NAMES:
			if content.contains("[node name=\"%s\"" % node_name):
				failures.append("%s -> %s" % [scene_path, node_name])
	assert_eq(failures.size(), 0, "正式场景仍有 source-only 绑定节点：\n%s" % "\n".join(failures))


# 退役 SVG 不得继续被正式运行资源引用。
func test_retired_svg_assets_have_no_runtime_references() -> void:
	var failures := PackedStringArray()
	var searchable_files := PackedStringArray()
	searchable_files.append_array(_collect_files("res://scenes", PackedStringArray(["tscn"]), PackedStringArray(["res://scenes/dev"])))
	searchable_files.append_array(_collect_files("res://scripts", PackedStringArray(["gd"])))
	searchable_files.append_array(_collect_files("res://tests", PackedStringArray(["gd"])))
	searchable_files.append_array(_collect_files("res://assets", PackedStringArray(["tres", "res"])))

	for file_path: String in searchable_files:
		if file_path == get_script().resource_path:
			continue
		var content := FileAccess.get_file_as_string(file_path)
		for retired_path: String in RETIRED_SVG_PATHS:
			if content.contains(retired_path) or content.contains("res://%s" % retired_path):
				failures.append("%s -> %s" % [file_path, retired_path])

	assert_eq(failures.size(), 0, "退役 SVG 仍被运行资源引用：\n%s" % "\n".join(failures))


# 删除门禁通过后，退役源文件及其导入旁车必须从仓库中物理移除。
func test_retired_svg_assets_are_deleted_after_validation() -> void:
	var remaining := PackedStringArray()
	for retired_path: String in RETIRED_SVG_PATHS:
		for candidate_path: String in [retired_path, "%s.import" % retired_path]:
			if FileAccess.file_exists("res://%s" % candidate_path):
				remaining.append(candidate_path)

	assert_eq(remaining.size(), 0, "退役 SVG 或导入旁车仍存在：\n%s" % "\n".join(remaining))


# 玩家运行脚本不得再保留已退役 Stage12 slash Preview 的状态分支。
func test_player_runtime_does_not_reference_stage12_slash_preview() -> void:
	var player_script := FileAccess.get_file_as_string("res://scripts/player/player_placeholder.gd")
	assert_false(player_script.contains("Stage12SlashPreview"))
	assert_false(player_script.contains("_stage12_slash_visual"))


# 最终处置必须有单一文档，明确保留、开发、归档和验证后删除四种结果。
func test_final_disposition_document_records_all_disposition_classes() -> void:
	assert_true(FileAccess.file_exists(DISPOSITION_DOC))
	var content := FileAccess.get_file_as_string(DISPOSITION_DOC)
	for disposition: String in ["runtime_keep", "source_dev_keep", "archive_keep", "delete_after_validation"]:
		assert_true(content.contains(disposition), "最终处置清单缺少分类：%s" % disposition)


# 来源安全与最终门禁必须消费同一轮结果，不能再出现来源待复核但最终门禁全绿。
func test_runtime_source_review_items_block_final_source_traceability_gate() -> void:
	var runtime_report := _read_json_report(RUNTIME_SOURCE_REPORT)
	var final_report := _read_json_report(FINAL_ACCEPTANCE_REPORT)
	var final_by_asset := {}
	for entry: Dictionary in final_report.get("entries", []):
		final_by_asset[str(entry.get("asset_id", ""))] = entry

	var review_items: Array = runtime_report.get("summary", {}).get("runtime_review_required_items", [])
	for asset_id: String in review_items:
		assert_true(final_by_asset.has(asset_id), "最终门禁缺少来源待复核资产：%s" % asset_id)
		if not final_by_asset.has(asset_id):
			continue
		var source_gate: Dictionary = final_by_asset[asset_id].get("gates", {}).get("source_traceability", {})
		assert_eq(source_gate.get("status", ""), "blocked", "%s 的来源门禁未被阻塞。" % asset_id)
		assert_true(
			Array(source_gate.get("blockers", [])).has("runtime_source_safety_review_required"),
			"%s 的来源门禁缺少统一 blocker。" % asset_id
		)


# 已有资产级人工 finalization 记录必须被来源审计消费，不能因 raw candidate 不在仓库而重新退回未确认。
func test_asset_finalization_reviews_resolve_runtime_source_gate() -> void:
	var runtime_report := _read_json_report(RUNTIME_SOURCE_REPORT)
	var finalization_report := _read_json_report(FINALIZATION_REVIEWS)
	var approved_ids := {}
	for record: Dictionary in finalization_report.get("records", []):
		if record.get("review_status", "") == "approved_for_final_ready" and record.get("final_approval_status", "") == "approved":
			approved_ids[str(record.get("asset_id", ""))] = true

	var matched_count := 0
	for item: Dictionary in runtime_report.get("items", []):
		var asset_id := str(item.get("asset_id", ""))
		if not approved_ids.has(asset_id):
			continue
		matched_count += 1
		assert_eq(item.get("source_status", ""), "asset_finalization_review_confirmed", "%s 未消费 finalization 记录。" % asset_id)
		assert_true(
			item.get("runtime_source_gate", "") in ["runtime_reference_source_confirmed", "planned_replacement_source_confirmed"],
			"%s 的 runtime source gate 未被人工 finalization 关闭。" % asset_id
		)

	assert_gt(matched_count, 0, "运行来源报告未覆盖任何已批准资产。")


# P0 运行计划不得把开发画廊或 art-direction 资产当成正式运行替换目标。
func test_p0_runtime_plan_excludes_dev_only_tracks_and_scenes() -> void:
	var plan := _read_json_report(P0_RUNTIME_PLAN)
	var planned_ids := {}
	for entry: Dictionary in plan.get("entries", []):
		planned_ids[str(entry.get("asset_id", ""))] = true
		assert_true(str(entry.get("track", "")).begins_with("runtime_"), "非运行轨道混入 P0 计划：%s" % entry.get("asset_id", ""))
		for scene: Dictionary in entry.get("target_scene_status", []):
			assert_false(str(scene.get("scene", "")).begins_with("scenes/dev/"), "开发场景混入 P0 计划：%s" % entry.get("asset_id", ""))
	for asset_id: String in NON_RUNTIME_P0_ASSET_IDS:
		assert_false(planned_ids.has(asset_id), "source/archive 资产仍混入 P0 运行计划：%s" % asset_id)


# 运行接入扫描必须覆盖全部正式场景，不能只检查预先猜测的候选房间。
func test_runtime_map_discovers_actual_production_scene_references() -> void:
	var runtime_map := _read_json_report(RUNTIME_MAP_REPORT)
	var seal_magic_entry := {}
	var entries_by_asset := {}
	for entry: Dictionary in runtime_map.get("entries", []):
		entries_by_asset[str(entry.get("asset_id", ""))] = entry
		if entry.get("asset_id", "") == "vfx_seal_magic_atlas_ai01":
			seal_magic_entry = entry
	assert_false(seal_magic_entry.is_empty())
	assert_true(
		Array(seal_magic_entry.get("direct_scene_references", [])).has("scenes/rooms/stage15_seal_pressure_room.tscn"),
		"运行接入图未发现 Stage15 pressure 的真实 seal magic 引用。"
	)
	for asset_id: String in NON_RUNTIME_P0_ASSET_IDS:
		assert_true(entries_by_asset.has(asset_id), "运行接入图缺少处置资产：%s" % asset_id)
		if entries_by_asset.has(asset_id):
			assert_false(str(entries_by_asset[asset_id].get("track", "")).begins_with("runtime_"), "source/archive 资产仍被标为运行轨道：%s" % asset_id)


# P0 下游排练、场景矩阵和批次必须跟随当前运行计划，不能保留历史 30 项硬编码。
func test_p0_dependent_reports_follow_current_runtime_plan() -> void:
	var plan := _read_json_report(P0_RUNTIME_PLAN)
	var rehearsal := _read_json_report(P0_REHEARSAL_MANIFEST)
	var matrix := _read_json_report(P0_TARGET_MATRIX)
	var batches := _read_json_report(P0_SCENE_BATCHES)
	var expected_asset_count := Array(plan.get("entries", [])).size()

	assert_eq(int(rehearsal.get("counts", {}).get("entry_count", -1)), expected_asset_count)
	assert_eq(int(matrix.get("summary", {}).get("unique_asset_count", -1)), expected_asset_count)
	assert_eq(int(batches.get("summary", {}).get("unique_asset_count", -1)), expected_asset_count)
	assert_eq(int(batches.get("summary", {}).get("missing_scene_count", -1)), 0)
	assert_eq(int(batches.get("summary", {}).get("unbatched_scene_count", -1)), 0)


# UI 运行接入审计必须承认 Theme 内的传递 StyleBox 绑定，不要求场景保留未使用 ext_resource。
func test_asset_package_accepts_theme_transitive_stylebox_binding() -> void:
	var package_report := _read_json_report(ASSET_PACKAGE_REPORT)
	var ui_skin: Dictionary = package_report.get("runtime_ui_skin_binding", {})
	assert_true(bool(ui_skin.get("present", false)))
	assert_eq(Array(ui_skin.get("missing", [])).size(), 0)


# 递归收集目标扩展名文件；排除目录只按完整 res:// 前缀判断。
func _collect_files(
	directory_path: String,
	extensions: PackedStringArray,
	excluded_prefixes: PackedStringArray = PackedStringArray()
) -> PackedStringArray:
	var results := PackedStringArray()
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return results

	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry != "." and entry != "..":
			var child_path := directory_path.path_join(entry)
			if directory.current_is_dir():
				if not _has_excluded_prefix(child_path, excluded_prefixes):
					results.append_array(_collect_files(child_path, extensions, excluded_prefixes))
			elif extensions.has(entry.get_extension().to_lower()):
				results.append(child_path)
		entry = directory.get_next()
	directory.list_dir_end()
	results.sort()
	return results


# 排除开发目录，防止资产画廊的合法 Preview 被误判为正式接入。
func _has_excluded_prefix(path: String, excluded_prefixes: PackedStringArray) -> bool:
	for prefix: String in excluded_prefixes:
		if path == prefix or path.begins_with("%s/" % prefix):
			return true
	return false


# 读取机器报告；解析失败时返回空字典并让调用方断言给出具体缺口。
func _read_json_report(path: String) -> Dictionary:
	assert_true(FileAccess.file_exists(path), "缺少资产报告：%s" % path)
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_true(parsed is Dictionary, "资产报告不是合法 JSON 对象：%s" % path)
	return parsed as Dictionary if parsed is Dictionary else {}
