extends SceneTree

# 生成运行时来源复核 Workbench。
# 该场景把 runtime-source-review-queue 转成 Godot 编辑器可打开的审图工作台。

const REVIEW_QUEUE_PATH := "res://docs/assets/runtime-source-review-queue.json"
const OUT_SCENE := "res://scenes/dev/runtime_source_review_workbench.tscn"
const OUT_MANIFEST := "res://docs/assets/runtime-source-review-workbench-manifest.json"


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：读取来源复核队列，生成 Godot 场景和 manifest。
func _run() -> int:
	var queue := _read_json(REVIEW_QUEUE_PATH)
	if queue.is_empty():
		return 1

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/dev"))

	var entries: Array = queue.get("entries", [])
	var root := _make_root()
	var content := root.get_node("Scroll/Content") as VBoxContainer
	_add_header(content, queue)
	var counts := _add_review_cards(content, entries)

	var scene := PackedScene.new()
	var pack_error := scene.pack(root)
	if pack_error != OK:
		push_error("Failed to pack runtime source review workbench: %s" % pack_error)
		root.free()
		return 1
	var save_error := ResourceSaver.save(scene, OUT_SCENE)
	if save_error != OK:
		push_error("Failed to save runtime source review workbench: %s" % save_error)
		root.free()
		return 1

	var manifest := {
		"version": 1,
		"status": "runtime_source_review_workbench_ready",
		"scene": OUT_SCENE,
		"purpose": "Godot editor-facing review workbench for runtime-bound image_gen source-risk assets.",
		"boundary": "Review workbench only. It previews current runtime outputs and raw candidates; it does not approve source, final art, licensing or runtime replacement.",
		"counts": counts,
		"sources": {
			"runtime_source_review_queue": REVIEW_QUEUE_PATH,
		},
	}
	if not _write_json(OUT_MANIFEST, manifest):
		root.free()
		return 1

	root.free()
	print("Runtime source review workbench built: %s" % OUT_SCENE)
	print("Runtime source review workbench manifest written: %s" % OUT_MANIFEST)
	return 0


# 创建基础 Control 和滚动容器。
func _make_root() -> Control:
	var root := Control.new()
	root.name = "RuntimeSourceReviewWorkbench"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.custom_minimum_size = Vector2(1800, 1050)
	root.set_meta("runtime_source_review_workbench_scene", true)

	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(scroll)
	scroll.owner = root

	var content := VBoxContainer.new()
	content.name = "Content"
	content.custom_minimum_size = Vector2(1700, 0)
	content.add_theme_constant_override("separation", 20)
	scroll.add_child(content)
	content.owner = root
	return root


# 添加总览标题和来源复核边界。
func _add_header(parent: VBoxContainer, queue: Dictionary) -> void:
	var summary: Dictionary = queue.get("summary", {})
	_add_label(parent, "Nano Hunter Runtime Source Review Workbench", 28)
	_add_label(parent, "用途：集中查看已进入运行时引用的 image_gen 资产、当前输出和所有候选来源，辅助人工审图、来源确认或重生图。", 16)
	_add_label(parent, "边界：该工作台只证明预览入口可用，不代表来源确认、授权完成、最终清稿或 final-ready。", 14)
	_add_label(parent, "当前队列：review_required=%s, unsafe=%s" % [
		summary.get("runtime_review_required_count", 0),
		summary.get("unsafe_item_count", 0),
	], 14)

	var strategy_counts: Dictionary = summary.get("strategy_counts", {})
	var strategies := strategy_counts.keys()
	strategies.sort()
	var parts: Array[String] = []
	for strategy: String in strategies:
		parts.append("%s=%s" % [strategy, strategy_counts.get(strategy, 0)])
	_add_label(parent, "Strategy counts: %s" % ", ".join(parts), 13)


# 按复核策略分组添加资产卡。
func _add_review_cards(parent: VBoxContainer, entries: Array) -> Dictionary:
	var strategy_counts := {}
	var current_output_count := 0
	var candidate_count := 0
	var selected_candidate_count := 0

	for entry: Dictionary in entries:
		var strategy := String(entry.get("review_strategy", "unknown"))
		strategy_counts[strategy] = int(strategy_counts.get(strategy, 0)) + 1

	var strategies := strategy_counts.keys()
	strategies.sort()
	for strategy: String in strategies:
		_add_section_title(parent, "%s / assets: %s" % [strategy, strategy_counts.get(strategy, 0)])
		for entry: Dictionary in entries:
			if String(entry.get("review_strategy", "unknown")) != strategy:
				continue
			var counts := _add_asset_card(parent, entry)
			current_output_count += int(counts.get("current_output_count", 0))
			candidate_count += int(counts.get("candidate_count", 0))
			selected_candidate_count += int(counts.get("selected_candidate_count", 0))

	return {
		"entry_count": entries.size(),
		"current_output_count": current_output_count,
		"candidate_count": candidate_count,
		"selected_candidate_count": selected_candidate_count,
		"strategy_counts": strategy_counts,
	}


# 添加单个运行时资产复核组。
func _add_asset_card(parent: VBoxContainer, entry: Dictionary) -> Dictionary:
	var asset_id := String(entry.get("asset_id", "unknown"))
	var target_kind := String(entry.get("target_kind", "unknown"))
	var strategy := String(entry.get("review_strategy", "unknown"))
	var selected_indices: Array = entry.get("selected_candidate_indices", [])
	var target_scenes: Array = entry.get("target_scenes", [])
	_add_label(parent, "%s / %s / %s" % [asset_id, target_kind, strategy], 18)
	_add_label(parent, "selected=%s / scenes=%s" % [str(selected_indices), ", ".join(target_scenes)], 12)
	_add_label(parent, String(entry.get("next_action", "")), 12)

	var grid := _make_grid(parent, 4)
	var current_output_count := 0
	var candidate_count := 0
	var selected_candidate_count := 0

	var output_path := _to_res_path(String(entry.get("output_path", "")))
	if not output_path.is_empty():
		_add_texture_card(grid, asset_id, "current_output", output_path, "current output")
		current_output_count += 1

	var candidates: Array = entry.get("candidates", [])
	for candidate: Dictionary in candidates:
		var candidate_path := _to_res_path(String(candidate.get("path", "")))
		if candidate_path.is_empty():
			continue
		var index := int(candidate.get("index", -1))
		var status := String(candidate.get("status", "unknown"))
		var selected := bool(candidate.get("selected", false))
		var label := "candidate_%02d / %s%s" % [index, status, " / selected" if selected else ""]
		_add_texture_card(grid, asset_id, "candidate", candidate_path, label)
		candidate_count += 1
		if selected:
			selected_candidate_count += 1

	return {
		"current_output_count": current_output_count,
		"candidate_count": candidate_count,
		"selected_candidate_count": selected_candidate_count,
	}


# 创建固定列数网格。
func _make_grid(parent: VBoxContainer, columns: int) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	parent.add_child(grid)
	grid.owner = parent.owner
	return grid


# 添加输出或候选预览卡。
func _add_texture_card(parent: GridContainer, asset_id: String, kind: String, texture_path: String, label_text: String) -> void:
	var panel := PanelContainer.new()
	panel.name = "RuntimeSource_%s_%s" % [kind, _safe_node_name(asset_id + "_" + label_text)]
	panel.custom_minimum_size = Vector2(390, 330)
	panel.set_meta("runtime_source_review_kind", kind)
	panel.set_meta("runtime_source_review_asset_id", asset_id)
	panel.set_meta("runtime_source_review_resource", texture_path)
	parent.add_child(panel)
	panel.owner = parent.owner

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.owner = parent.owner

	var title := Label.new()
	title.text = "%s / %s" % [asset_id, label_text]
	title.clip_text = true
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(title)
	title.owner = parent.owner

	var texture_rect := TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(360, 230)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture := ResourceLoader.load(texture_path)
	if texture != null and texture is Texture2D:
		texture_rect.texture = texture
	else:
		title.text = "%s / missing texture" % title.text
	box.add_child(texture_rect)
	texture_rect.owner = parent.owner

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


# 把项目相对路径转换成 res://。
func _to_res_path(path: String) -> String:
	if path.is_empty():
		return ""
	if path.begins_with("res://"):
		return path
	if path.is_absolute_path():
		var project_root := ProjectSettings.globalize_path("res://")
		var normalized_root := project_root.replace("\\", "/").trim_suffix("/")
		var normalized_path := path.replace("\\", "/")
		if normalized_path.begins_with(normalized_root):
			return "res://" + normalized_path.substr(normalized_root.length()).trim_prefix("/")
		return path
	return "res://%s" % path


# 生成稳定 Node 名称片段。
func _safe_node_name(text: String) -> String:
	var safe := text.to_lower()
	for token: String in [" ", "/", "\\", ".", ":", "-", "__"]:
		safe = safe.replace(token, "_")
	return safe.strip_edges().left(72)
