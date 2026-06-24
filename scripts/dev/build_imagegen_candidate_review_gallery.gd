extends SceneTree

# 生成 image_gen raw candidate 的 Godot 审图场景。
# 该场景只展示尚未进入 selected sources 的候选，方便人工决定是否重建图集。

const CANDIDATE_REPORT_PATH := "res://docs/assets/imagegen-candidate-pool-report.json"
const OUT_SCENE := "res://scenes/dev/imagegen_candidate_review_gallery.tscn"
const OUT_MANIFEST := "res://docs/assets/imagegen-candidate-review-gallery-manifest.json"


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：读取候选池报告，生成可打开的审图场景和 manifest。
func _run() -> int:
	var report := _read_json(CANDIDATE_REPORT_PATH)
	if report.is_empty():
		return 1

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/dev"))

	var root := _make_root()
	var content := root.get_node("Scroll/Content") as VBoxContainer
	_add_header(content, report)

	var counts := _add_candidate_cards(content, report)

	var scene := PackedScene.new()
	var pack_error := scene.pack(root)
	if pack_error != OK:
		push_error("Failed to pack candidate review gallery: %s" % pack_error)
		root.free()
		return 1
	var save_error := ResourceSaver.save(scene, OUT_SCENE)
	if save_error != OK:
		push_error("Failed to save candidate review gallery: %s" % save_error)
		root.free()
		return 1

	var manifest := {
		"version": 1,
		"status": "review_required",
		"scene": OUT_SCENE,
		"purpose": "Godot editor-facing review scene for raw image_gen candidates not yet used by selected sources.",
		"boundary": "Raw candidate review only; not selected-source promotion, atlas rebuild, final art approval or runtime integration.",
		"counts": counts,
		"sources": {
			"candidate_report": CANDIDATE_REPORT_PATH,
		},
	}
	if not _write_json(OUT_MANIFEST, manifest):
		root.free()
		return 1

	root.free()
	print("Imagegen candidate review gallery built: %s" % OUT_SCENE)
	print("Imagegen candidate review gallery manifest written: %s" % OUT_MANIFEST)
	return 0


# 创建基础 Control 和滚动容器。
func _make_root() -> Control:
	var root := Control.new()
	root.name = "ImagegenCandidateReviewGallery"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.custom_minimum_size = Vector2(1600, 1000)
	root.set_meta("candidate_review_gallery_scene", true)

	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(scroll)
	scroll.owner = root

	var content := VBoxContainer.new()
	content.name = "Content"
	content.custom_minimum_size = Vector2(1500, 0)
	content.add_theme_constant_override("separation", 20)
	scroll.add_child(content)
	content.owner = root
	return root


# 添加审图页标题和候选池摘要。
func _add_header(parent: VBoxContainer, report: Dictionary) -> void:
	var summary: Dictionary = report.get("summary", {})
	_add_label(parent, "Nano Hunter ImageGen Candidate Review Gallery", 28)
	_add_label(parent, "用途：集中查看尚未进入 selected sources 的 raw candidates，供人工审图和后续重建图集使用。", 16)
	_add_label(parent, "边界：候选存在不等于已选中、不等于已重建、不等于最终清稿或运行时接入。", 14)
	_add_label(parent, "候选池：raw=%s, selected_sources=%s, unselected=%s, review_assets=%s" % [
		summary.get("candidate_png_count", 0),
		summary.get("selected_source_count", 0),
		summary.get("unselected_candidate_count", 0),
		summary.get("review_required_item_count", 0),
	], 14)


# 按 Batch / asset 展示全部 unselected candidates。
func _add_candidate_cards(parent: VBoxContainer, report: Dictionary) -> Dictionary:
	var items: Array = report.get("items", [])
	var groups := {}
	var total_candidates := 0
	var asset_count := 0
	var batch_counts := {}
	for item: Dictionary in items:
		var unselected: Array = item.get("unselected_candidate_indices", [])
		if unselected.is_empty():
			continue
		asset_count += 1
		var batch := String(item.get("batch", "unknown"))
		if not groups.has(batch):
			groups[batch] = []
		groups[batch].append(item)
		batch_counts[batch] = int(batch_counts.get(batch, 0)) + unselected.size()
		total_candidates += unselected.size()

	var batches := groups.keys()
	batches.sort()
	for batch: String in batches:
		_add_section_title(parent, "%s / unselected candidates: %s" % [batch, batch_counts.get(batch, 0)])
		var assets: Array = groups[batch]
		assets.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return String(a.get("asset_id", "")) < String(b.get("asset_id", ""))
		)
		for item: Dictionary in assets:
			_add_asset_candidate_group(parent, item)

	return {
		"unselected_candidates": total_candidates,
		"review_required_assets": asset_count,
		"batch_counts": batch_counts,
	}


# 为单个 asset 生成候选卡片组。
func _add_asset_candidate_group(parent: VBoxContainer, item: Dictionary) -> void:
	var asset_id := String(item.get("asset_id", "unknown"))
	var target_kind := String(item.get("target_kind", "unknown"))
	var unselected: Array = item.get("unselected_candidate_indices", [])
	_add_label(parent, "%s / %s / unselected: %s" % [asset_id, target_kind, unselected.size()], 18)
	var grid := _make_grid(parent, 4)

	var candidates: Array = item.get("candidates", [])
	var candidate_by_index := {}
	for candidate: Dictionary in candidates:
		candidate_by_index[int(candidate.get("index", -1))] = candidate

	for index_value: Variant in unselected:
		var index := int(index_value)
		if not candidate_by_index.has(index):
			continue
		var candidate: Dictionary = candidate_by_index[index]
		var title := "%s candidate_%02d" % [asset_id, index]
		var path := _to_res_path(String(candidate.get("path", "")))
		var details := "%sx%s %s" % [
			candidate.get("width", "?"),
			candidate.get("height", "?"),
			candidate.get("mode", "?"),
		]
		_add_candidate_card(grid, title, path, details)


# 创建固定列数网格。
func _make_grid(parent: VBoxContainer, columns: int) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	parent.add_child(grid)
	grid.owner = parent.owner
	return grid


# 添加一张候选预览卡。
func _add_candidate_card(parent: GridContainer, title: String, texture_path: String, details: String) -> void:
	var panel := PanelContainer.new()
	panel.name = "Candidate_%s" % _safe_node_name(title)
	panel.custom_minimum_size = Vector2(340, 300)
	panel.set_meta("candidate_review_kind", "raw_candidate")
	panel.set_meta("candidate_review_resource", texture_path)
	parent.add_child(panel)
	panel.owner = parent.owner

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.owner = parent.owner

	var label := Label.new()
	label.text = title
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(label)
	label.owner = parent.owner

	var texture_rect := TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(310, 210)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture := ResourceLoader.load(texture_path)
	if texture != null and texture is Texture2D:
		texture_rect.texture = texture
	else:
		label.text = "%s / missing texture" % title
	box.add_child(texture_rect)
	texture_rect.owner = parent.owner

	var details_label := Label.new()
	details_label.text = details
	details_label.clip_text = true
	details_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(details_label)
	details_label.owner = parent.owner

	var path_label := Label.new()
	path_label.text = texture_path
	path_label.clip_text = true
	path_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(path_label)
	path_label.owner = parent.owner


# 添加分节标题。
func _add_section_title(parent: VBoxContainer, text: String) -> void:
	var label := _add_label(parent, text, 22)
	label.add_theme_color_override("font_color", Color(0.95, 0.86, 0.58, 1.0))


# 添加普通标签。
func _add_label(parent: VBoxContainer, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	label.owner = parent.owner
	return label


# 读取 JSON 并确保顶层为 Dictionary。
func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing JSON file: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open JSON file: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("JSON is not a dictionary: %s" % path)
		return {}
	return parsed


# 写出 JSON manifest。
func _write_json(path: String, data: Dictionary) -> bool:
	var absolute_path := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write JSON file: %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
	return true


# 将项目相对路径转换为 res:// 路径。
func _to_res_path(value: String) -> String:
	if value.begins_with("res://"):
		return value
	if value.is_absolute_path():
		var project_root := ProjectSettings.globalize_path("res://")
		var normalized_root := project_root.replace("\\", "/").trim_suffix("/")
		var normalized_value := value.replace("\\", "/")
		if normalized_value.begins_with(normalized_root):
			return "res://" + normalized_value.substr(normalized_root.length()).trim_prefix("/")
		return value
	return "res://" + value


# 生成稳定节点名片段。
func _safe_node_name(value: String) -> String:
	var safe := value.to_lower()
	for token: String in [" ", "/", "\\", ".", ":", "-", "__"]:
		safe = safe.replace(token, "_")
	return safe.strip_edges().left(72)
