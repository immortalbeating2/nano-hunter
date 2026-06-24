extends SceneTree

# 生成最终美术复核 Workbench。
# 该场景把 final-art review queue 转成 Godot 编辑器可打开的审图工作台。

const REVIEW_QUEUE_PATH := "res://docs/assets/final-art-review-queue.json"
const OUT_SCENE := "res://scenes/dev/final_art_review_workbench.tscn"
const OUT_MANIFEST := "res://docs/assets/final-art-review-workbench-manifest.json"

const FAMILY_LABELS := {
	"animation": "动画帧 / 序列帧",
	"characters": "角色 / Boss / 拆件",
	"environment": "关卡地图 / 场景",
	"icons": "图标",
	"promo_logo_cg": "宣传 / LOGO / CG",
	"props_equipment": "道具与装备",
	"story": "叙事 / 分镜",
	"style": "风格板",
	"textures": "贴图",
	"ui": "UI / 界面",
	"vfx": "特效",
}


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：读取最终复核队列，生成 Godot 场景和独立 manifest。
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
		push_error("Failed to pack final art review workbench: %s" % pack_error)
		root.free()
		return 1
	var save_error := ResourceSaver.save(scene, OUT_SCENE)
	if save_error != OK:
		push_error("Failed to save final art review workbench: %s" % save_error)
		root.free()
		return 1

	var manifest := {
		"version": 1,
		"status": "manual_review_queue_ready",
		"scene": OUT_SCENE,
		"purpose": "Godot editor-facing final-art review workbench for the Nano Hunter image-gen asset package.",
		"boundary": "Review workbench only. It proves review cards and preview textures are available; it does not approve final art, licensing, runtime replacement, animation timing, UI readability or gameplay fit.",
		"counts": counts,
		"sources": {
			"final_art_review_queue": REVIEW_QUEUE_PATH,
		},
	}
	if not _write_json(OUT_MANIFEST, manifest):
		root.free()
		return 1

	root.free()
	print("Final art review workbench built: %s" % OUT_SCENE)
	print("Final art review workbench manifest written: %s" % OUT_MANIFEST)
	return 0


# 创建基础 Control 和滚动容器。
func _make_root() -> Control:
	var root := Control.new()
	root.name = "FinalArtReviewWorkbench"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.custom_minimum_size = Vector2(1700, 1050)
	root.set_meta("final_art_review_workbench_scene", true)

	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(scroll)
	scroll.owner = root

	var content := VBoxContainer.new()
	content.name = "Content"
	content.custom_minimum_size = Vector2(1600, 0)
	content.add_theme_constant_override("separation", 20)
	scroll.add_child(content)
	content.owner = root
	return root


# 添加总览标题和复核边界。
func _add_header(parent: VBoxContainer, queue: Dictionary) -> void:
	var summary: Dictionary = queue.get("summary", {})
	_add_label(parent, "Nano Hunter Final Art Review Workbench", 28)
	_add_label(parent, "用途：在 Godot 编辑器中逐项复核角色、关卡、UI、图标、道具、VFX、动画帧、贴图、宣传图、CG 与分镜资产。", 16)
	_add_label(parent, "边界：该工作台只证明复核入口和预览资源可用，不代表 final ready、授权完成、运行时替换完成或玩法读值完成。", 14)
	_add_label(parent, "当前队列：assets=%s, manual_review=%s, final_ready=%s" % [
		summary.get("asset_count", 0),
		summary.get("manual_review_required_count", 0),
		summary.get("final_ready_count", 0),
	], 14)

	var family_counts: Dictionary = summary.get("family_counts", {})
	var families := family_counts.keys()
	families.sort()
	var parts: Array[String] = []
	for family: String in families:
		parts.append("%s=%s" % [family, family_counts.get(family, 0)])
	_add_label(parent, "Family counts: %s" % ", ".join(parts), 13)


# 按 priority 和 family 分组添加复核卡片。
func _add_review_cards(parent: VBoxContainer, entries: Array) -> Dictionary:
	var priority_counts := {}
	var family_counts := {}
	var texture_cards := 0
	var blocker_total := 0
	var manual_review_count := 0
	var final_ready_count := 0

	for entry: Dictionary in entries:
		var priority := String(entry.get("priority", "unknown"))
		var family := String(entry.get("family", "unknown"))
		priority_counts[priority] = int(priority_counts.get(priority, 0)) + 1
		family_counts[family] = int(family_counts.get(family, 0)) + 1
		blocker_total += int(entry.get("blocker_count", 0))
		if bool(entry.get("final_ready", false)):
			final_ready_count += 1
		else:
			manual_review_count += 1

	var priority_order := _priority_order(priority_counts)
	for priority: String in priority_order:
		_add_section_title(parent, "%s / review assets: %s" % [priority, priority_counts.get(priority, 0)])
		var priority_entries := _entries_for_priority(entries, priority)
		var family_order := _family_order(priority_entries)
		for family: String in family_order:
			var family_entries := _entries_for_family(priority_entries, family)
			_add_label(parent, "%s / %s：%s" % [family, FAMILY_LABELS.get(family, "未分类"), family_entries.size()], 18)
			var grid := _make_grid(parent, 3)
			for entry: Dictionary in family_entries:
				_add_review_card(grid, entry)
				texture_cards += 1

	return {
		"entry_count": entries.size(),
		"texture_card_count": texture_cards,
		"manual_review_required_count": manual_review_count,
		"final_ready_count": final_ready_count,
		"blocker_total": blocker_total,
		"priority_counts": priority_counts,
		"family_counts": family_counts,
	}


# 返回当前队列中实际存在的 priority，按 P0、P1、P2、其它排序。
func _priority_order(priority_counts: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for priority: String in ["P0", "P1", "P2", "P3"]:
		if priority_counts.has(priority):
			result.append(priority)
	var extras := priority_counts.keys()
	extras.sort()
	for priority: String in extras:
		if not result.has(priority):
			result.append(priority)
	return result


# 过滤指定 priority 的条目。
func _entries_for_priority(entries: Array, priority: String) -> Array:
	var result: Array = []
	for entry: Dictionary in entries:
		if String(entry.get("priority", "unknown")) == priority:
			result.append(entry)
	return result


# 返回条目中实际存在的 family，按名称稳定排序。
func _family_order(entries: Array) -> Array[String]:
	var seen := {}
	for entry: Dictionary in entries:
		seen[String(entry.get("family", "unknown"))] = true
	var result: Array[String] = []
	var keys := seen.keys()
	keys.sort()
	for family: String in keys:
		result.append(family)
	return result


# 过滤指定 family 的条目。
func _entries_for_family(entries: Array, family: String) -> Array:
	var result: Array = []
	for entry: Dictionary in entries:
		if String(entry.get("family", "unknown")) == family:
			result.append(entry)
	return result


# 创建固定列数网格。
func _make_grid(parent: VBoxContainer, columns: int) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	parent.add_child(grid)
	grid.owner = parent.owner
	return grid


# 添加单个资产复核卡片。
func _add_review_card(parent: GridContainer, entry: Dictionary) -> void:
	var asset_id := String(entry.get("asset_id", "unknown"))
	var texture_path := _to_res_path(String(entry.get("output_path", "")))
	var blockers: Array = entry.get("blockers", [])
	var actions: Array = entry.get("next_actions", [])

	var panel := PanelContainer.new()
	panel.name = "Review_%s" % _safe_node_name(asset_id)
	panel.custom_minimum_size = Vector2(500, 420)
	panel.set_meta("final_art_review_kind", "asset_review_card")
	panel.set_meta("final_art_review_asset_id", asset_id)
	panel.set_meta("final_art_review_resource", texture_path)
	panel.set_meta("final_art_review_priority", String(entry.get("priority", "unknown")))
	panel.set_meta("final_art_review_family", String(entry.get("family", "unknown")))
	panel.set_meta("final_art_review_blocker_count", int(entry.get("blocker_count", blockers.size())))
	parent.add_child(panel)
	panel.owner = parent.owner

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.owner = parent.owner

	_add_child_label(box, "%s / %s / %s" % [
		String(entry.get("priority", "unknown")),
		asset_id,
		String(entry.get("target_kind", "unknown")),
	], 15, Color(0.95, 0.86, 0.58, 1.0))
	_add_child_label(box, "%s blockers / %s" % [
		entry.get("blocker_count", blockers.size()),
		String(entry.get("review_status", "unknown")),
	], 13, Color(1.0, 0.78, 0.62, 1.0))

	var texture_rect := TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(460, 230)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture := ResourceLoader.load(texture_path)
	if texture != null and texture is Texture2D:
		texture_rect.texture = texture
	box.add_child(texture_rect)
	texture_rect.owner = parent.owner

	_add_child_label(box, _join_limited("Blockers", blockers, 3), 12, Color(0.92, 0.92, 0.88, 1.0))
	_add_child_label(box, _join_limited("Next", actions, 2), 12, Color(0.82, 0.9, 1.0))
	_add_child_label(box, texture_path, 11, Color(0.78, 0.78, 0.78, 1.0))


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


# 在卡片内部添加可换行标签。
func _add_child_label(parent: VBoxContainer, text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	parent.add_child(label)
	label.owner = parent.owner
	return label


# 将 blockers / actions 压缩成卡片内可读的短文本。
func _join_limited(prefix: String, values: Array, limit: int) -> String:
	var parts: Array[String] = []
	var count: int = min(values.size(), limit)
	for index: int in range(count):
		parts.append(String(values[index]))
	if values.size() > limit:
		parts.append("+%s more" % (values.size() - limit))
	return "%s: %s" % [prefix, " | ".join(parts)]


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


# 将项目相对路径或绝对路径转换为 res:// 路径。
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
