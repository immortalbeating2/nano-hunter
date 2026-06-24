extends SceneTree

# 加载 image gen 九宫格 StyleBoxTexture 候选资源，验证 region 与 margin。

const INDEX_FILES := [
	"res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json",
]


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：逐个索引加载 StyleBoxTexture，确保资源和九切边距可用。
func _run() -> int:
	var checked := 0
	for index_file: String in INDEX_FILES:
		var count := _audit_index(index_file)
		if count < 0:
			return 1
		checked += count
	print("Editor StyleBoxTexture resources OK: %s" % checked)
	return 0


# 审计单个 stylebox index 中列出的全部资源。
func _audit_index(index_file: String) -> int:
	var index := _read_json(index_file)
	if index.is_empty():
		return -1
	var checked := 0
	for item: Dictionary in index.get("items", []):
		if not _audit_stylebox(item):
			return -1
		checked += 1
	if checked != int(index.get("count", -1)):
		push_error("StyleBoxTexture index count mismatch: %s" % index_file)
		return -1
	return checked


# 加载一个 StyleBoxTexture，并验证 texture、region 和 margin。
func _audit_stylebox(item: Dictionary) -> bool:
	var path := String(item["resource"])
	var resource := ResourceLoader.load(path)
	if resource == null or not resource is StyleBoxTexture:
		push_error("Cannot load StyleBoxTexture resource: %s" % path)
		return false
	var stylebox := resource as StyleBoxTexture
	if stylebox.texture == null:
		push_error("StyleBoxTexture missing texture: %s" % path)
		return false
	var region_array: Array = item.get("region", [])
	if region_array.size() != 4:
		push_error("Invalid StyleBoxTexture region in index: %s" % path)
		return false
	var expected_region := Rect2(
		float(region_array[0]),
		float(region_array[1]),
		float(region_array[2]),
		float(region_array[3])
	)
	if stylebox.region_rect != expected_region:
		push_error("StyleBoxTexture region mismatch: %s" % path)
		return false
	var expected_margin := float(item.get("margin", 0))
	if expected_margin <= 0.0:
		push_error("StyleBoxTexture margin is not positive: %s" % path)
		return false
	if stylebox.texture_margin_left != expected_margin:
		push_error("StyleBoxTexture left margin mismatch: %s" % path)
		return false
	if stylebox.texture_margin_top != expected_margin:
		push_error("StyleBoxTexture top margin mismatch: %s" % path)
		return false
	if stylebox.texture_margin_right != expected_margin:
		push_error("StyleBoxTexture right margin mismatch: %s" % path)
		return false
	if stylebox.texture_margin_bottom != expected_margin:
		push_error("StyleBoxTexture bottom margin mismatch: %s" % path)
		return false
	return true


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
