extends SceneTree

# 审计正式 UI 场景是否引用目标 Theme；Battle / Tutorial 保持 v5，符印共鸣盘验证 v2 官印双框与六枚 AtlasTexture。
# Pause / Failure 继续验证既有 v4 独立装饰层和共享焦点带，避免 HUD 专项误伤已冻结合同。

const SHELL_THEME := "res://assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres"
const HUD_THEME := "res://assets/art/ui/hud_warden_official_v4.theme.tres"
const LEGACY_PANEL_STYLE := "res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/000_menu_ninepatch_ui_ai_01_auto_001_c_01.stylebox_texture.tres"
const WARDEN_V4_STYLEBOX_ROOT := "res://assets/art/ui/styleboxes/hud_warden_official_v4/"
const WARDEN_V5_STYLEBOX_ROOT := "res://assets/art/ui/styleboxes/hud_warden_integrated_v5/"
const WARDEN_V5_FRAME_ROOT := "res://assets/art/ui/hud_warden_integrated_v5/"
const SEAL_RESONANCE_STYLEBOX_ROOT := "res://assets/art/ui/styleboxes/hud_seal_resonance_v2/"
const SEAL_RESONANCE_FRAME_ROOT := "res://assets/art/ui/hud_seal_resonance_v2/"
const SEAL_RESONANCE_ATLAS_ROOT := "res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/"
const SEAL_RESONANCE_SYMBOLS := SEAL_RESONANCE_FRAME_ROOT + "seal_resonance_symbols_warden_ai02.png"
const LEGACY_V5_ELEMENT_FRAME := WARDEN_V5_FRAME_ROOT + "element_frame_integrated_warden_ai01.png"
const ACTION_FOCUS_SHADER := "res://assets/shaders/ui/main_menu_focus_band.gdshader"
const SEAL_RESONANCE_GLYPHS := {
	"wind": Rect2(0.0, 0.0, 256.0, 256.0),
	"thunder": Rect2(256.0, 0.0, 256.0, 256.0),
	"swift": Rect2(512.0, 0.0, 256.0, 256.0),
	"ward": Rect2(0.0, 256.0, 256.0, 256.0),
	"wind_thunder_pierce": Rect2(256.0, 256.0, 256.0, 256.0),
	"thunder_wind_scatter": Rect2(512.0, 256.0, 256.0, 256.0),
}
const SCENE_SPECS := [
	{
		"scene": "res://scenes/ui/demo_shell.tscn",
		"theme": SHELL_THEME,
		"panels": ["MainMenu", "PauseMenu", "FailurePanel", "CompletionPanel"],
		"panel_styles": {
			"PauseMenu": WARDEN_V4_STYLEBOX_ROOT + "pause_frame_base_warden_official_ai01.stylebox_texture.tres",
			"FailurePanel": WARDEN_V4_STYLEBOX_ROOT + "pause_frame_base_warden_official_ai01.stylebox_texture.tres",
			"CompletionPanel": LEGACY_PANEL_STYLE,
		},
		"ornament_panels": ["PauseMenu", "FailurePanel"],
		"shared_focus_band": "ActionFocusBand",
		"textures": {
			"TitleBackground": "res://assets/art/ui/main_menu_shell_ai02.png",
			"MainMenu/MarginContainer/VBoxContainer/TitleWordmark": "res://assets/art/ui/main_menu_wordmark_ai01.png",
			"MainMenu/MenuIconStrip": "res://assets/art/ui/stage16_demo_menu_icons_ai01.png",
			"CompletionPanel/CompletionPanelArt": "res://assets/art/ui/stage16_completion_panel_ui_ai01.png",
		},
	},
	{
		"scene": "res://scenes/ui/tutorial_hud.tscn",
		"theme": HUD_THEME,
		"panels": ["PromptPanel", "BattlePanel", "ElementPanel"],
		"panel_styles": {
			"PromptPanel": WARDEN_V5_STYLEBOX_ROOT + "tutorial_content_safe.stylebox_empty.tres",
			"BattlePanel": WARDEN_V5_STYLEBOX_ROOT + "battle_content_safe.stylebox_empty.tres",
			"ElementPanel": SEAL_RESONANCE_STYLEBOX_ROOT + "seal_resonance_idle_content_safe.stylebox_empty.tres",
		},
		"ornament_panels": [],
		"forbidden_ornament_panels": ["PromptPanel", "BattlePanel", "ElementPanel"],
		"textures": {
			"PromptPanel/FrameArt": WARDEN_V5_FRAME_ROOT + "tutorial_frame_integrated_warden_ai01.png",
			"BattlePanel/FrameArt": WARDEN_V5_FRAME_ROOT + "battle_frame_integrated_warden_ai01.png",
			"BattlePanel/FrameArtExpanded": WARDEN_V5_FRAME_ROOT + "battle_frame_integrated_warden_expanded_ai01.png",
			"ElementPanel/FrameArt": SEAL_RESONANCE_FRAME_ROOT + "seal_resonance_idle_frame_warden_ai02.png",
			"ElementPanel/FrameArtActive": SEAL_RESONANCE_FRAME_ROOT + "seal_resonance_active_frame_warden_ai02.png",
		},
		"integrated_frame_contracts": {
			"PromptPanel/FrameArt": "02_warden_integrated_frame_assembly",
			"BattlePanel/FrameArt": "02_warden_integrated_frame_assembly",
			"BattlePanel/FrameArtExpanded": "02_warden_integrated_frame_assembly",
			"ElementPanel/FrameArt": "seal_resonance_v2_command_seal",
			"ElementPanel/FrameArtActive": "seal_resonance_v2_command_seal",
		},
		"forbidden_nodes": ["ElementPanel/ElementStatusLabel"],
		"seal_resonance_panel": "ElementPanel",
	},
]


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：加载每个运行时 UI 场景并检查 Theme 与 Panel 样式资源。
func _run() -> int:
	var checked_scenes := 0
	var checked_panels := 0
	var checked_textures := 0
	var checked_ornament_layers := 0
	var checked_atlas_regions := 0
	for spec: Dictionary in SCENE_SPECS:
		var expected_theme_path := String(spec["theme"])
		var expected_theme := ResourceLoader.load(expected_theme_path)
		if expected_theme == null or not expected_theme is Theme:
			push_error("Cannot load expected UI Theme: %s" % expected_theme_path)
			return 1
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
		if root_control.theme.resource_path != expected_theme_path:
			push_error("Runtime UI Theme mismatch: %s" % spec["scene"])
			root.queue_free()
			return 1
		var expected_panel_styles: Dictionary = spec.get("panel_styles", {})
		for panel_path: String in spec["panels"]:
			var node := root.get_node_or_null(NodePath(panel_path))
			if node == null or not node is Control:
				push_error("Runtime UI panel missing: %s/%s" % [spec["scene"], panel_path])
				root.queue_free()
				return 1
			var panel := node as Control
			if panel_path == "MainMenu":
				var title_menu_style := panel.get_theme_stylebox("panel")
				if title_menu_style == null or not title_menu_style is StyleBoxEmpty:
					var actual_class := "null" if title_menu_style == null else title_menu_style.get_class()
					push_error("C2 MainMenu must use an empty panel style: %s/%s (actual=%s)" % [spec["scene"], panel_path, actual_class])
					root.queue_free()
					return 1
				checked_panels += 1
				continue
			var expected_style_path := String(expected_panel_styles.get(panel_path, ""))
			if expected_style_path.is_empty():
				push_error("Runtime UI panel has no audited StyleBox contract: %s/%s" % [spec["scene"], panel_path])
				root.queue_free()
				return 1
			if not panel.has_theme_stylebox_override("panel"):
				push_error("Runtime UI panel missing StyleBox override: %s/%s" % [spec["scene"], panel_path])
				root.queue_free()
				return 1
			var stylebox := panel.get_theme_stylebox("panel")
			if stylebox == null or stylebox.resource_path != expected_style_path:
				var actual_path := "null" if stylebox == null else stylebox.resource_path
				push_error("Runtime UI panel StyleBox mismatch: %s/%s (expected=%s, actual=%s)" % [spec["scene"], panel_path, expected_style_path, actual_path])
				root.queue_free()
				return 1
			checked_panels += 1
		for panel_path: String in spec.get("ornament_panels", []):
			var ornament_layer := root.get_node_or_null(NodePath(panel_path + "/OrnamentLayer")) as Control
			if ornament_layer == null:
				push_error("Runtime UI ornament layer missing: %s/%s" % [spec["scene"], panel_path])
				root.queue_free()
				return 1
			if not bool(ornament_layer.get_meta("non_stretch_visual_layer", false)):
				push_error("Runtime UI ornament layer must be non-stretch: %s/%s" % [spec["scene"], panel_path])
				root.queue_free()
				return 1
			if String(ornament_layer.get_meta("visual_anchor_contract", "")) != "02_warden_seal_chains_tassel":
				push_error("Runtime UI visual anchor mismatch: %s/%s" % [spec["scene"], panel_path])
				root.queue_free()
				return 1
			for ornament in ornament_layer.get_children():
				if ornament is TextureRect and (ornament as TextureRect).stretch_mode != TextureRect.STRETCH_KEEP_ASPECT_CENTERED:
					push_error("Runtime UI ornament may not stretch: %s/%s/%s" % [spec["scene"], panel_path, ornament.name])
					root.queue_free()
					return 1
			checked_ornament_layers += 1
		for panel_path: String in spec.get("forbidden_ornament_panels", []):
			if root.get_node_or_null(NodePath(panel_path + "/OrnamentLayer")) != null:
				push_error("Integrated HUD frame may not retain overlay ornament layer: %s/%s" % [spec["scene"], panel_path])
				root.queue_free()
				return 1
		for forbidden_node_path: String in spec.get("forbidden_nodes", []):
			if root.get_node_or_null(NodePath(forbidden_node_path)) != null:
				push_error("Retired runtime UI node still exists: %s/%s" % [spec["scene"], forbidden_node_path])
				root.queue_free()
				return 1
		var textures: Dictionary = spec.get("textures", {})
		var integrated_frame_contracts: Dictionary = spec.get("integrated_frame_contracts", {})
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
			if integrated_frame_contracts.has(texture_node_path):
				if texture_rect.stretch_mode != TextureRect.STRETCH_KEEP_ASPECT_CENTERED:
					push_error("Integrated HUD frame must preserve aspect ratio: %s/%s" % [spec["scene"], texture_node_path])
					root.queue_free()
					return 1
				var frame_panel := texture_rect.get_parent()
				var expected_contract := String(integrated_frame_contracts[texture_node_path])
				if String(frame_panel.get_meta("visual_assembly_contract", "")) != expected_contract:
					push_error("Integrated HUD frame contract mismatch: %s/%s" % [spec["scene"], texture_node_path])
					root.queue_free()
					return 1
			checked_textures += 1
		var seal_panel_path := String(spec.get("seal_resonance_panel", ""))
		if not seal_panel_path.is_empty():
			var seal_panel := root.get_node_or_null(NodePath(seal_panel_path)) as Panel
			if seal_panel == null:
				push_error("Seal resonance HUD panel missing: %s/%s" % [spec["scene"], seal_panel_path])
				root.queue_free()
				return 1
			var metadata_ok := (
				String(seal_panel.get_meta("hud_role", "")) == "seal_resonance"
				and String(seal_panel.get_meta("asset_id_idle", "")) == "seal_resonance_idle_frame_warden_ai02"
				and String(seal_panel.get_meta("asset_id_active", "")) == "seal_resonance_active_frame_warden_ai02"
				and String(seal_panel.get_meta("visual_assembly_contract", "")) == "seal_resonance_v2_command_seal"
			)
			if not metadata_ok:
				push_error("Seal resonance HUD metadata contract mismatch: %s/%s" % [spec["scene"], seal_panel_path])
				root.queue_free()
				return 1
		var shared_focus_path := String(spec.get("shared_focus_band", ""))
		if not shared_focus_path.is_empty():
			var focus_bands := root.find_children("ActionFocusBand", "ColorRect", true, false)
			var focus_band := root.get_node_or_null(NodePath(shared_focus_path)) as ColorRect
			if focus_band == null or focus_bands.size() != 1:
				push_error("Pause / Failure must share exactly one ActionFocusBand: %s" % spec["scene"])
				root.queue_free()
				return 1
			var focus_material := focus_band.material as ShaderMaterial
			if (
				String(focus_band.get_meta("focus_role", "")) != "shared_pause_failure_focus"
				or focus_material == null
				or focus_material.shader == null
				or focus_material.shader.resource_path != ACTION_FOCUS_SHADER
			):
				push_error("Pause / Failure shared focus contract mismatch: %s" % spec["scene"])
				root.queue_free()
				return 1
		root.queue_free()
		checked_scenes += 1

	for glyph_name: String in SEAL_RESONANCE_GLYPHS:
		var atlas_path := "%s%s.atlas_texture.tres" % [SEAL_RESONANCE_ATLAS_ROOT, glyph_name]
		var atlas_texture := ResourceLoader.load(atlas_path) as AtlasTexture
		if atlas_texture == null or atlas_texture.atlas == null:
			push_error("Cannot load seal resonance AtlasTexture: %s" % atlas_path)
			return 1
		if atlas_texture.atlas.resource_path != SEAL_RESONANCE_SYMBOLS:
			push_error("Seal resonance AtlasTexture source mismatch: %s" % atlas_path)
			return 1
		if atlas_texture.region != SEAL_RESONANCE_GLYPHS[glyph_name]:
			push_error("Seal resonance AtlasTexture region mismatch: %s" % atlas_path)
			return 1
		checked_atlas_regions += 1

	var tutorial_scene_text := FileAccess.get_file_as_string("res://scenes/ui/tutorial_hud.tscn")
	if tutorial_scene_text.contains(LEGACY_V5_ELEMENT_FRAME):
		push_error("Retired v5 Element frame still has a production scene consumer")
		return 1
	if tutorial_scene_text.contains("ElementStatusLabel"):
		push_error("Retired ElementStatusLabel still has a production scene consumer")
		return 1

	print("Runtime UI skin binding OK: %s scenes, %s panels, %s textures, %s Atlas regions, %s non-stretch ornament layers; retired Element consumers=0" % [checked_scenes, checked_panels, checked_textures, checked_atlas_regions, checked_ornament_layers])
	return 0
