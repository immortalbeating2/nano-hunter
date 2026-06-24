extends SceneTree

# 把 image gen UI / 九宫格候选整理成 Godot Theme 候选和 UI 接入规则。

const STYLEBOX_INDEX_PATH := "res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json"
const OUT_DIR := "res://assets/art/ui/editor_ui_skin"
const OUT_THEME := "res://assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres"
const OUT_RULES := "res://assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json"
const STYLEBOX_MAPPINGS := [
	{"index": 0, "theme_type": "PanelContainer", "style_name": "panel", "usage": "default_panel"},
	{"index": 0, "theme_type": "Panel", "style_name": "panel", "usage": "runtime_panel"},
	{"index": 1, "theme_type": "Button", "style_name": "normal", "usage": "button_normal"},
	{"index": 2, "theme_type": "Button", "style_name": "hover", "usage": "button_hover"},
	{"index": 3, "theme_type": "Button", "style_name": "pressed", "usage": "button_pressed"},
	{"index": 4, "theme_type": "Button", "style_name": "disabled", "usage": "button_disabled"},
	{"index": 5, "theme_type": "PopupPanel", "style_name": "panel", "usage": "popup_panel"},
	{"index": 6, "theme_type": "TooltipPanel", "style_name": "panel", "usage": "tooltip_panel"},
	{"index": 7, "theme_type": "AcceptDialog", "style_name": "panel", "usage": "dialog_panel"},
]
const STANDALONE_UI_PANELS := [
	{
		"id": "stage16_pause_panel_ui_ai01",
		"path": "res://assets/art/ui/stage16_pause_panel_ui_ai01.png",
		"recommended_control": "PanelContainer",
		"layout_role": "pause_menu_panel",
	},
	{
		"id": "stage16_completion_panel_ui_ai01",
		"path": "res://assets/art/ui/stage16_completion_panel_ui_ai01.png",
		"recommended_control": "PanelContainer",
		"layout_role": "completion_panel",
	},
	{
		"id": "stage15_boss_hud_frame_ai01",
		"path": "res://assets/art/ui/stage15_boss_hud_frame_ai01.png",
		"recommended_control": "TextureRect",
		"layout_role": "boss_hud_frame",
	},
	{
		"id": "stage14_ability_status_hud_ai01",
		"path": "res://assets/art/ui/stage14_ability_status_hud_ai01.png",
		"recommended_control": "TextureRect",
		"layout_role": "ability_status_hud",
	},
]


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：根据 StyleBox index 构建 Theme，并写出 UI 规则 sidecar。
func _run() -> int:
	var stylebox_index := _read_json(STYLEBOX_INDEX_PATH)
	if stylebox_index.is_empty():
		return 1
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var items: Array = stylebox_index.get("items", [])
	var theme := Theme.new()
	var mappings: Array[Dictionary] = []
	for mapping: Dictionary in STYLEBOX_MAPPINGS:
		var index := int(mapping["index"])
		if index < 0 or index >= items.size():
			push_error("StyleBox mapping index out of range: %s" % index)
			return 1
		var item: Dictionary = items[index]
		var resource_path := String(item.get("resource", ""))
		var stylebox := ResourceLoader.load(resource_path)
		if stylebox == null or not stylebox is StyleBoxTexture:
			push_error("Cannot load mapped StyleBoxTexture: %s" % resource_path)
			return 1
		var theme_type := String(mapping["theme_type"])
		var style_name := String(mapping["style_name"])
		theme.set_stylebox(style_name, theme_type, stylebox)
		mappings.append({
			"usage": String(mapping["usage"]),
			"theme_type": theme_type,
			"style_name": style_name,
			"stylebox_resource": resource_path,
			"source_region": item.get("region", []),
			"margin": int(item.get("margin", 0)),
			"manual_review_required": true,
		})

	var save_error := ResourceSaver.save(theme, OUT_THEME)
	if save_error != OK:
		push_error("Failed to save UI Theme candidate: %s" % save_error)
		return 1

	var rules := {
		"version": 1,
		"status": "placeholder_ready",
		"theme_resource": OUT_THEME,
		"source_stylebox_index": STYLEBOX_INDEX_PATH,
		"stylebox_mappings": mappings,
		"standalone_panels": _build_standalone_panel_rules(),
		"manual_review_required": true,
		"boundary": "First-pass UI skin rules. Theme mapping, text-safe areas, stretch behavior and runtime layout must be reviewed before replacing DemoShell or HUD UI.",
	}
	if not _write_json(OUT_RULES, rules):
		return 1

	print("Editor UI skin Theme written: %s" % OUT_THEME)
	print("Editor UI skin rules written: %s" % OUT_RULES)
	return 0


# 为 standalone UI 图生成保守 text-safe area，供后续运行时 UI 接入复核。
func _build_standalone_panel_rules() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for spec: Dictionary in STANDALONE_UI_PANELS:
		var path := String(spec["path"])
		var texture := ResourceLoader.load(path)
		if texture == null or not texture is Texture2D:
			push_error("Cannot load standalone UI panel: %s" % path)
			continue
		var texture_size := (texture as Texture2D).get_size()
		var inset_x := int(round(texture_size.x * 0.12))
		var inset_y := int(round(texture_size.y * 0.14))
		var safe_rect := [
			inset_x,
			inset_y,
			max(1, int(texture_size.x) - inset_x * 2),
			max(1, int(texture_size.y) - inset_y * 2),
		]
		rows.append({
			"id": String(spec["id"]),
			"texture": path,
			"size": [int(texture_size.x), int(texture_size.y)],
			"recommended_control": String(spec["recommended_control"]),
			"layout_role": String(spec["layout_role"]),
			"text_safe_rect": safe_rect,
			"min_runtime_size": [max(160, int(texture_size.x / 4.0)), max(64, int(texture_size.y / 4.0))],
			"manual_review_required": true,
			"notes": [
				"conservative_text_safe_area_candidate",
				"pseudo_text_cleanup_required_before_runtime_use",
				"contrast_and_640x360_readability_review_required",
			],
		})
	return rows


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


# 写出 JSON sidecar。
func _write_json(path: String, data: Dictionary) -> bool:
	var absolute_path := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write JSON file: %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
	return true
