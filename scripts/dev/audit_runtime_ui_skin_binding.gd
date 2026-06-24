extends SceneTree

# 审计正式 UI 场景是否已经引用 image gen UI Theme 与九宫格 StyleBox。

const EXPECTED_THEME := "res://assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres"
const EXPECTED_PANEL_STYLE := "res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/000_menu_ninepatch_ui_ai_01_auto_001_c_01.stylebox_texture.tres"
const SCENE_SPECS := [
	{
		"scene": "res://scenes/ui/demo_shell.tscn",
		"panels": ["MainMenu", "PauseMenu", "CompletionPanel"],
		"textures": {
			"TitleBackground": "res://assets/art/ui/stage16_title_background_ai01.png",
			"MainMenu/MenuIconStrip": "res://assets/art/ui/stage16_demo_menu_icons_ai01.png",
			"PauseMenu/PausePanelArt": "res://assets/art/ui/stage16_pause_panel_ui_ai01.png",
			"CompletionPanel/CompletionPanelArt": "res://assets/art/ui/stage16_completion_panel_ui_ai01.png",
		},
	},
	{
		"scene": "res://scenes/ui/tutorial_hud.tscn",
		"panels": ["PromptPanel", "BattlePanel"],
		"textures": {},
	},
]


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：加载每个运行时 UI 场景并检查 Theme 与 Panel 样式资源。
func _run() -> int:
	var expected_theme := ResourceLoader.load(EXPECTED_THEME)
	var expected_panel_style := ResourceLoader.load(EXPECTED_PANEL_STYLE)
	if expected_theme == null or not expected_theme is Theme:
		push_error("Cannot load expected UI Theme: %s" % EXPECTED_THEME)
		return 1
	if expected_panel_style == null or not expected_panel_style is StyleBox:
		push_error("Cannot load expected panel StyleBox: %s" % EXPECTED_PANEL_STYLE)
		return 1

	var checked_scenes := 0
	var checked_panels := 0
	var checked_textures := 0
	for spec: Dictionary in SCENE_SPECS:
		var packed := ResourceLoader.load(String(spec["scene"]))
		if packed == null or not packed is PackedScene:
			push_error("Cannot load runtime UI scene: %s" % spec["scene"])
			return 1
		var root := (packed as PackedScene).instantiate()
		if root == null or not root is Control:
			push_error("Runtime UI scene root is not Control: %s" % spec["scene"])
			return 1
		var root_control := root as Control
		if root_control.theme == null:
			push_error("Runtime UI scene missing Theme: %s" % spec["scene"])
			root.queue_free()
			return 1
		if root_control.theme.resource_path != EXPECTED_THEME:
			push_error("Runtime UI Theme mismatch: %s" % spec["scene"])
			root.queue_free()
			return 1
		for panel_path: String in spec["panels"]:
			var node := root.get_node_or_null(NodePath(panel_path))
			if node == null or not node is Control:
				push_error("Runtime UI panel missing: %s/%s" % [spec["scene"], panel_path])
				root.queue_free()
				return 1
			var panel := node as Control
			if not panel.has_theme_stylebox_override("panel"):
				push_error("Runtime UI panel missing StyleBox override: %s/%s" % [spec["scene"], panel_path])
				root.queue_free()
				return 1
			var stylebox := panel.get_theme_stylebox("panel")
			if stylebox == null or stylebox.resource_path != EXPECTED_PANEL_STYLE:
				push_error("Runtime UI panel StyleBox mismatch: %s/%s" % [spec["scene"], panel_path])
				root.queue_free()
				return 1
			checked_panels += 1
		var textures: Dictionary = spec.get("textures", {})
		for texture_node_path: String in textures.keys():
			var expected_texture := String(textures[texture_node_path])
			var node := root.get_node_or_null(NodePath(texture_node_path))
			if node == null or not node is TextureRect:
				push_error("Runtime UI texture node missing: %s/%s" % [spec["scene"], texture_node_path])
				root.queue_free()
				return 1
			var texture_rect := node as TextureRect
			if texture_rect.texture == null or texture_rect.texture.resource_path != expected_texture:
				push_error("Runtime UI texture mismatch: %s/%s" % [spec["scene"], texture_node_path])
				root.queue_free()
				return 1
			checked_textures += 1
		root.queue_free()
		checked_scenes += 1

	print("Runtime UI skin binding OK: %s scenes, %s panels, %s textures" % [checked_scenes, checked_panels, checked_textures])
	return 0
