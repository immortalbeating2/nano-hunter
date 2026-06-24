extends SceneTree

# 从 image gen 九宫格 sheet 生成 Godot StyleBoxTexture 候选资源。

const STYLEBOX_SPECS := [
	{
		"id": "menu_ninepatch_ui_ai01",
		"metadata": "res://assets/art/ui/menu_ninepatch_ui_ai01.regions.json",
		"out_dir": "res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01",
		"margin": 24,
	}
]


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：按九宫格规格逐个生成 StyleBoxTexture，并输出索引文件。
func _run() -> int:
	var total := 0
	for spec: Dictionary in STYLEBOX_SPECS:
		var count := _build_styleboxes(spec)
		if count < 0:
			return 1
		total += count
	print("Editor StyleBoxTexture resources built: %s" % total)
	return 0


# 读取 regions metadata，并为每个 region 生成一个 StyleBoxTexture。
func _build_styleboxes(spec: Dictionary) -> int:
	var id := String(spec["id"])
	var metadata := _read_json(String(spec["metadata"]))
	if metadata.is_empty():
		return -1
	var texture_path := _to_res_path(String(metadata["output"]))
	var texture := load(texture_path)
	if texture == null or not texture is Texture2D:
		push_error("Cannot load StyleBox texture for %s: %s" % [id, texture_path])
		return -1

	var out_dir := String(spec["out_dir"])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	var margin := int(spec.get("margin", 24))
	var index_rows: Array[Dictionary] = []
	var written := 0
	for frame: Dictionary in metadata.get("frames", []):
		var region_array: Array = frame.get("region", [])
		if region_array.size() != 4:
			push_error("Invalid ninepatch region for %s" % id)
			return -1
		var region := Rect2(
			float(region_array[0]),
			float(region_array[1]),
			float(region_array[2]),
			float(region_array[3])
		)
		var safe_margin := _safe_margin(margin, region)
		var stylebox := StyleBoxTexture.new()
		stylebox.texture = texture
		stylebox.region_rect = region
		stylebox.texture_margin_left = safe_margin
		stylebox.texture_margin_top = safe_margin
		stylebox.texture_margin_right = safe_margin
		stylebox.texture_margin_bottom = safe_margin
		stylebox.content_margin_left = safe_margin
		stylebox.content_margin_top = safe_margin
		stylebox.content_margin_right = safe_margin
		stylebox.content_margin_bottom = safe_margin

		var name := _safe_resource_name(int(frame["index"]), String(frame["name"]))
		var save_path := "%s/%s.stylebox_texture.tres" % [out_dir, name]
		var error := ResourceSaver.save(stylebox, save_path)
		if error != OK:
			push_error("Failed to save StyleBoxTexture %s: %s" % [save_path, error])
			return -1
		index_rows.append({
			"asset_id": id,
			"name": String(frame["name"]),
			"resource": save_path,
			"texture": texture_path,
			"region": region_array,
			"margin": safe_margin,
		})
		written += 1

	var index_path := "%s/%s.styleboxes.index.json" % [out_dir, id]
	var file := FileAccess.open(index_path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write stylebox index: %s" % index_path)
		return -1
	file.store_string(JSON.stringify({
		"id": id,
		"kind": "stylebox_texture_set",
		"source_metadata": String(spec["metadata"]),
		"count": written,
		"items": index_rows,
	}, "\t"))
	file.store_string("\n")
	print("wrote %s StyleBoxTexture resources for %s" % [written, id])
	return written


# 给自动生成资源使用稳定、可排序的文件名。
func _safe_resource_name(index: int, name: String) -> String:
	var safe := name.to_snake_case()
	for character: String in [" ", "/", "\\", ":", "*", "?", "\"", "<", ">", "|"]:
		safe = safe.replace(character, "_")
	return "%03d_%s" % [index, safe]


# 保守限制九切边距，避免边距超过 region 的一半。
func _safe_margin(requested: int, region: Rect2) -> int:
	var max_margin := int(min(region.size.x, region.size.y) / 3.0)
	return max(1, min(requested, max_margin))


# 读取 JSON 并确保顶层是 Dictionary。
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


# 把绝对路径或项目相对路径统一转成 res://。
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
