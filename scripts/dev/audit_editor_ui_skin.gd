extends SceneTree

# 审计 image gen UI skin Theme 候选和 UI 接入规则。

const RULES_PATH := "res://assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json"


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：加载 rules、Theme 和所有映射资源。
func _run() -> int:
	var rules := _read_json(RULES_PATH)
	if rules.is_empty():
		return 1
	var theme_path := String(rules.get("theme_resource", ""))
	var theme := ResourceLoader.load(theme_path)
	if theme == null or not theme is Theme:
		push_error("Cannot load UI Theme candidate: %s" % theme_path)
		return 1
	var mapped := _audit_stylebox_mappings(theme as Theme, rules.get("stylebox_mappings", []))
	if mapped < 0:
		return 1
	var panels := _audit_panel_rules(rules.get("standalone_panels", []))
	if panels < 0:
		return 1
	if mapped != 9:
		push_error("Expected 9 UI stylebox mappings, got %s" % mapped)
		return 1
	if panels != 4:
		push_error("Expected 4 standalone UI panel rules, got %s" % panels)
		return 1
	print("Editor UI skin OK: %s style mappings, %s standalone panels" % [mapped, panels])
	return 0


# 验证 Theme 中每个 stylebox 映射都存在且能取回。
func _audit_stylebox_mappings(theme: Theme, mappings: Array) -> int:
	var checked := 0
	for mapping: Dictionary in mappings:
		var theme_type := String(mapping.get("theme_type", ""))
		var style_name := String(mapping.get("style_name", ""))
		var resource_path := String(mapping.get("stylebox_resource", ""))
		if theme_type.is_empty() or style_name.is_empty() or resource_path.is_empty():
			push_error("Invalid UI stylebox mapping")
			return -1
		if not theme.has_stylebox(style_name, theme_type):
			push_error("Theme missing stylebox mapping: %s/%s" % [theme_type, style_name])
			return -1
		var mapped := theme.get_stylebox(style_name, theme_type)
		var loaded := ResourceLoader.load(resource_path)
		if mapped == null or loaded == null:
			push_error("Cannot load mapped UI stylebox: %s" % resource_path)
			return -1
		if mapped.resource_path != loaded.resource_path:
			push_error("Theme stylebox resource mismatch: %s" % resource_path)
			return -1
		var margin := int(mapping.get("margin", 0))
		if margin <= 0:
			push_error("UI stylebox margin must be positive: %s" % resource_path)
			return -1
		checked += 1
	return checked


# 验证 standalone UI panel 规则中的 texture、尺寸和 text-safe area。
func _audit_panel_rules(panels: Array) -> int:
	var checked := 0
	for panel: Dictionary in panels:
		var texture_path := String(panel.get("texture", ""))
		var texture := ResourceLoader.load(texture_path)
		if texture == null or not texture is Texture2D:
			push_error("Cannot load standalone UI texture: %s" % texture_path)
			return -1
		var texture_size := (texture as Texture2D).get_size()
		var size_array: Array = panel.get("size", [])
		var safe_rect_array: Array = panel.get("text_safe_rect", [])
		if size_array.size() != 2 or safe_rect_array.size() != 4:
			push_error("Invalid standalone UI panel rule: %s" % texture_path)
			return -1
		if int(size_array[0]) != int(texture_size.x) or int(size_array[1]) != int(texture_size.y):
			push_error("Standalone UI size mismatch: %s" % texture_path)
			return -1
		var safe_rect := Rect2i(
			int(safe_rect_array[0]),
			int(safe_rect_array[1]),
			int(safe_rect_array[2]),
			int(safe_rect_array[3])
		)
		if safe_rect.position.x < 0 or safe_rect.position.y < 0:
			push_error("Standalone UI text-safe rect negative: %s" % texture_path)
			return -1
		if safe_rect.size.x <= 0 or safe_rect.size.y <= 0:
			push_error("Standalone UI text-safe rect empty: %s" % texture_path)
			return -1
		if safe_rect.end.x > int(texture_size.x) or safe_rect.end.y > int(texture_size.y):
			push_error("Standalone UI text-safe rect exceeds texture: %s" % texture_path)
			return -1
		checked += 1
	return checked


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
