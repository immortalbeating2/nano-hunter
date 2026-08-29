# 正式 HUD 回归：保护物理字号、响应式安全区、02 视觉锚点和唯一共享教程注意层。
extends GutTest

const HUD_SCENE_PATH := "res://scenes/ui/tutorial_hud.tscn"
const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const VIEWPORT_MATRIX := [
	Vector2(640.0, 360.0),
	Vector2(1024.0, 576.0),
	Vector2(1280.0, 720.0),
	Vector2(1672.0, 941.0),
	Vector2(2048.0, 1152.0),
	Vector2(2560.0, 1080.0),
	Vector2(2560.0, 1440.0),
]
const LONGEST_PROMPT := "移动：左摇杆 / 十字键。跳跃：A / Cross；随后按住方向使用 B / Circle 或 RB 穿过低顶门槛。"
const SEAL_RESONANCE_FRAME_PATHS := {
	"idle": "res://assets/art/ui/hud_seal_resonance_v2/seal_resonance_idle_frame_warden_ai02.png",
	"active": "res://assets/art/ui/hud_seal_resonance_v2/seal_resonance_active_frame_warden_ai02.png",
}
const SEAL_RESONANCE_SYMBOL_ATLAS_PATH := "res://assets/art/ui/hud_seal_resonance_v2/seal_resonance_symbols_warden_ai02.png"
const SEAL_RESONANCE_ICON_MASK_SHADER_PATH := "res://assets/shaders/ui/seal_resonance_icon_circle_mask.gdshader"
const SEAL_RESONANCE_GLYPH_CONTRACTS := {
	&"wind": {
		"path": "res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/wind.atlas_texture.tres",
		"region": Rect2(0.0, 0.0, 256.0, 256.0),
	},
	&"thunder": {
		"path": "res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/thunder.atlas_texture.tres",
		"region": Rect2(256.0, 0.0, 256.0, 256.0),
	},
	&"swift": {
		"path": "res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/swift.atlas_texture.tres",
		"region": Rect2(512.0, 0.0, 256.0, 256.0),
	},
	&"ward": {
		"path": "res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/ward.atlas_texture.tres",
		"region": Rect2(0.0, 256.0, 256.0, 256.0),
	},
	&"wind_thunder_pierce": {
		"path": "res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/wind_thunder_pierce.atlas_texture.tres",
		"region": Rect2(256.0, 256.0, 256.0, 256.0),
	},
	&"thunder_wind_scatter": {
		"path": "res://assets/art/editor_resources/seal_resonance_symbols_warden_ai02/thunder_wind_scatter.atlas_texture.tres",
		"region": Rect2(512.0, 256.0, 256.0, 256.0),
	},
}


func test_formal_hud_uses_readable_font_tokens_and_compact_panels() -> void:
	var hud := await _spawn_hud()
	var battle_panel := hud.get_node("BattlePanel") as Panel
	var prompt_panel := hud.get_node("PromptPanel") as Panel
	var element_panel := hud.get_node("ElementPanel") as Panel
	var step_label := hud.get_node("PromptPanel/StepLabel") as Label
	var body_labels: Array[Label] = [
		hud.get_node("PromptPanel/PromptLabel") as Label,
		hud.get_node("BattlePanel/StatusLabel") as Label,
		hud.get_node("BattlePanel/DashLabel") as Label,
		hud.get_node("BattlePanel/ProgressLabel") as Label,
	]

	assert_gte(step_label.get_theme_font_size("font_size"), 22)
	for label: Label in body_labels:
		assert_gte(label.get_theme_font_size("font_size"), 17, "%s 的 1280p 逻辑字号" % label.name)
	assert_gte(prompt_panel.size.x, 440.0)
	assert_lte(prompt_panel.size.x, 520.0)
	assert_gte(prompt_panel.size.y, 104.0)
	assert_lte(prompt_panel.size.y, 130.0)
	assert_gte(battle_panel.size.x, 296.0)
	assert_lte(battle_panel.size.x, 320.0)
	assert_gte(battle_panel.size.y, 104.0)
	assert_lte(battle_panel.size.y, 120.0)
	assert_eq(element_panel.size, Vector2(232.0, 116.0), "idle 共鸣盘必须保留第 2 版大印层级且控制横向占比。")


# 02 方向获批时同时收紧了屏幕占比；标准 16:9 不得再回到旧版的大面积顶栏。
func test_direction_02_hud_stays_inside_approved_screen_occupancy() -> void:
	var hud := await _spawn_hud()
	for viewport_size: Vector2 in VIEWPORT_MATRIX:
		if viewport_size.x < 1024.0 or viewport_size.x / viewport_size.y > 1.9:
			continue
		hud.call("_layout_runtime_hud_for_viewport", viewport_size)
		await get_tree().process_frame
		var battle_rect := _visual_rect(hud, hud.get_node("BattlePanel") as Control, viewport_size)
		var prompt_rect := _visual_rect(hud, hud.get_node("PromptPanel") as Control, viewport_size)
		var element_rect := _visual_rect(hud, hud.get_node("ElementPanel") as Control, viewport_size)
		assert_between(battle_rect.size.x / viewport_size.x, 0.22, 0.25, "BattlePanel width @ %s" % viewport_size)
		assert_between(element_rect.size.x / viewport_size.x, 0.17, 0.20, "idle ElementPanel width @ %s" % viewport_size)
		assert_between(prompt_rect.size.x / viewport_size.x, 0.34, 0.405, "PromptPanel width @ %s" % viewport_size)
		assert_between(battle_rect.size.y / viewport_size.y, 0.14, 0.17, "BattlePanel height @ %s" % viewport_size)
		assert_between(element_rect.size.y / viewport_size.y, 0.15, 0.17, "idle ElementPanel height @ %s" % viewport_size)
		assert_between(prompt_rect.size.y / viewport_size.y, 0.14, 0.19, "PromptPanel height @ %s" % viewport_size)


func test_formal_hud_reflows_inside_all_supported_viewports() -> void:
	var hud := await _spawn_hud()
	assert_true(hud.has_method("_layout_runtime_hud_for_viewport"))
	if not hud.has_method("_layout_runtime_hud_for_viewport"):
		return
	var prompt_label := hud.get_node("PromptPanel/PromptLabel") as Label
	prompt_label.text = LONGEST_PROMPT
	hud.call("_sync_prompt_panel_layout")

	for viewport_size: Vector2 in VIEWPORT_MATRIX:
		hud.call("_layout_runtime_hud_for_viewport", viewport_size)
		await get_tree().process_frame
		var battle_panel := hud.get_node("BattlePanel") as Panel
		var prompt_panel := hud.get_node("PromptPanel") as Panel
		var element_panel := hud.get_node("ElementPanel") as Panel
		for panel: Panel in [battle_panel, prompt_panel, element_panel]:
			_assert_visual_rect_inside_viewport(hud, panel, viewport_size)
		_assert_no_visual_overlap(hud, battle_panel, element_panel, viewport_size)
		if viewport_size.x < 1180.0:
			assert_gte(
				_visual_rect(hud, prompt_panel, viewport_size).position.y,
				maxf(
					_visual_rect(hud, battle_panel, viewport_size).end.y,
					_visual_rect(hud, element_panel, viewport_size).end.y,
				) + 8.0,
				"%s 窄屏教程面板必须下移重排" % viewport_size,
			)
		assert_eq(
			prompt_label.get_visible_line_count(),
			prompt_label.get_line_count(),
			"%s 最长提示不得截断" % viewport_size,
		)


func test_prompt_and_battle_panels_keep_their_integrated_frame_assemblies_without_overlay_ornaments() -> void:
	var hud := await _spawn_hud()
	var prompt_panel := hud.get_node("PromptPanel") as Panel
	var battle_panel := hud.get_node("BattlePanel") as Panel
	var element_panel := hud.get_node("ElementPanel") as Panel
	var prompt_label := hud.get_node("PromptPanel/PromptLabel") as Label
	prompt_label.text = LONGEST_PROMPT
	hud.call("_sync_prompt_panel_layout")
	await get_tree().process_frame


	assert_null(prompt_panel.get_node_or_null("OrnamentLayer"), "PromptPanel 的官印、链路、官牌和朱砂印必须在一体化框体内完成装配。")
	assert_null(battle_panel.get_node_or_null("OrnamentLayer"), "BattlePanel 不得继续用前景套件覆盖完整底框。")
	var expected_frame_paths := {
		"PromptPanel": "res://assets/art/ui/hud_warden_integrated_v5/tutorial_frame_integrated_warden_ai01.png",
		"BattlePanel": "res://assets/art/ui/hud_warden_integrated_v5/battle_frame_integrated_warden_ai01.png",
	}
	for panel: Panel in [prompt_panel, battle_panel]:
		assert_eq(
			String(panel.get_meta("visual_assembly_contract", "")),
			"02_warden_integrated_frame_assembly",
			"%s 必须声明一体化框体装配契约。" % panel.name,
		)
		var frame_art := panel.get_node_or_null("FrameArt") as TextureRect
		assert_not_null(frame_art, "%s 缺少一体化 FrameArt。" % panel.name)
		if frame_art != null:
			assert_eq(frame_art.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "%s 必须等比缩放完整框体。" % panel.name)
			assert_not_null(frame_art.texture)
			if frame_art.texture != null:
				assert_eq(frame_art.texture.resource_path, expected_frame_paths[panel.name])
	var expanded_frame := battle_panel.get_node_or_null("FrameArtExpanded") as TextureRect
	assert_not_null(expanded_frame, "BattlePanel 必须为恢复 / Boss 增高状态提供同构整框。")
	if expanded_frame != null:
		assert_eq(expanded_frame.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		assert_false(expanded_frame.visible)
		assert_eq(expanded_frame.texture.resource_path, "res://assets/art/ui/hud_warden_integrated_v5/battle_frame_integrated_warden_expanded_ai01.png")

	_assert_panel_uses_texture_safe_area(prompt_panel, [
		hud.get_node("PromptPanel/StepLabel") as Control,
		prompt_label,
	])
	_assert_panel_uses_texture_safe_area(battle_panel, [
		hud.get_node("BattlePanel/HealthIcon") as Control,
		hud.get_node("BattlePanel/StatusLabel") as Control,
		hud.get_node("BattlePanel/HealthMeterFrameArt") as Control,
		hud.get_node("BattlePanel/HealthBarBack") as Control,
		hud.get_node("BattlePanel/HealthBarFill") as Control,
		hud.get_node("BattlePanel/DashIcon") as Control,
		hud.get_node("BattlePanel/DashLabel") as Control,
		hud.get_node("BattlePanel/DashMeterFrameArt") as Control,
		hud.get_node("BattlePanel/DashBarBack") as Control,
		hud.get_node("BattlePanel/DashBarFill") as Control,
		hud.get_node("BattlePanel/ObjectiveIcon") as Control,
		hud.get_node("BattlePanel/ProgressLabel") as Control,
	])
	assert_not_null(element_panel, "ElementPanel 继续承担符印共鸣盘的稳定节点职责。")


# BattlePanel 增高时必须切换另一张完整框体，避免官印、链路和侧翼被同一张纹理纵向拉伸。
func test_battle_panel_switches_whole_frame_when_recovery_or_boss_rows_expand() -> void:
	var hud := await _spawn_hud()
	var default_frame := hud.get_node_or_null("BattlePanel/FrameArt") as TextureRect
	var expanded_frame := hud.get_node_or_null("BattlePanel/FrameArtExpanded") as TextureRect
	assert_not_null(default_frame)
	assert_not_null(expanded_frame)
	if default_frame == null or expanded_frame == null:
		return

	assert_true(default_frame.visible)
	assert_false(expanded_frame.visible)
	hud.call("_update_boss_meter", {"stage15_boss_room": true})
	assert_false(default_frame.visible, "Boss / 恢复行出现后不得继续拉伸普通整框。")
	assert_true(expanded_frame.visible, "Boss / 恢复行出现后必须切换同构增高整框。")
	hud.call("_update_boss_meter", {})
	assert_true(default_frame.visible)
	assert_false(expanded_frame.visible)


# 标题流程不属于游戏内 HUD：主菜单及其详情页都不得让教程注意框越层显示。
func test_title_flow_hides_the_complete_gameplay_hud_until_game_start() -> void:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame

	var hud := main.get_node_or_null("HUD/TutorialHUD") as Control
	var start_button := main.get_node_or_null("HUD/DemoShell/MainMenu/MarginContainer/VBoxContainer/StartButton") as Button
	assert_not_null(hud)
	assert_not_null(start_button)
	if hud == null or start_button == null:
		return

	assert_false(hud.is_visible_in_tree(), "主菜单打开时完整 TutorialHUD（包括 TutorialAttention）必须隐藏。")
	start_button.pressed.emit()
	await get_tree().process_frame
	assert_true(hud.is_visible_in_tree(), "开始游戏后 TutorialHUD 必须恢复。")


# 三块正式 HUD 已按 2K 实机尺寸放大，不能继续复用 192x96 小图块；左侧安全区也必须给文字留出呼吸距离。
func test_prompt_and_battle_panels_keep_high_resolution_sources_and_inset_text_safe_areas() -> void:
	var hud := await _spawn_hud()
	var expected_paths := {
		"PromptPanel": "res://assets/art/ui/hud_warden_integrated_v5/tutorial_frame_integrated_warden_ai01.png",
		"BattlePanel": "res://assets/art/ui/hud_warden_integrated_v5/battle_frame_integrated_warden_ai01.png",
	}
	var expected_ratios := {
		"PromptPanel": 3.9,
		"BattlePanel": 2.7,
	}
	for panel_name: String in ["PromptPanel", "BattlePanel"]:
		var panel := hud.get_node(panel_name) as Panel
		var stylebox := panel.get_theme_stylebox("panel")
		assert_not_null(stylebox, "%s 必须使用独立的内容安全区 StyleBox。" % panel_name)
		if stylebox == null:
			continue
		var frame_art := panel.get_node_or_null("FrameArt") as TextureRect
		assert_not_null(frame_art, "%s 缺少一体化 FrameArt。" % panel_name)
		if frame_art == null:
			continue
		var source := frame_art.texture
		assert_not_null(source, "%s 缺少正式面板源图。" % panel_name)
		if source == null:
			continue
		assert_eq(source.resource_path, expected_paths[panel_name], "%s 必须绑定用户批准的 02 镇妖官印资产。" % panel_name)
		var source_region := source.get_size()
		var expected_ratio := float(expected_ratios[panel_name])
		assert_almost_eq(source_region.x / source_region.y, expected_ratio, expected_ratio * 0.01, "%s 源图比例漂移不得超过 1%%。" % panel_name)
		assert_gte(source_region.x, 512.0, "%s 不得继续放大 192px 宽低清源图。" % panel_name)
		assert_gte(source_region.y, 160.0, "%s 源图高度不足以支撑 2K HUD 边框细节。" % panel_name)
		assert_gte(stylebox.get_content_margin(SIDE_LEFT), 40.0, "%s 文字需要向右内收。" % panel_name)
		assert_gte(stylebox.get_content_margin(SIDE_RIGHT), 28.0, "%s 右侧也要保留边框距离。" % panel_name)


func test_direction_02_hud_unifies_font_icons_and_meter_rails() -> void:
	var hud := await _spawn_hud()
	var expected_texture_paths := {
		"BattlePanel/HealthIcon": "res://assets/art/ui/hud_warden_official_v4/hud_icon_health_warden_official_ai01.png",
		"BattlePanel/DashIcon": "res://assets/art/ui/hud_warden_official_v4/hud_icon_dash_warden_official_ai01.png",
		"BattlePanel/ObjectiveIcon": "res://assets/art/ui/hud_warden_official_v4/hud_icon_objective_warden_official_ai01.png",
		"BattlePanel/RecoveryChargeIcon": "res://assets/art/ui/hud_warden_official_v4/hud_icon_recovery_warden_official_ai01.png",
		"BattlePanel/HealthMeterFrameArt": "res://assets/art/ui/hud_warden_official_v4/hud_meter_rail_warden_official_ai01.png",
		"BattlePanel/DashMeterFrameArt": "res://assets/art/ui/hud_warden_official_v4/hud_meter_rail_warden_official_ai01.png",
		"BattlePanel/RecoveryMeterFrameArt": "res://assets/art/ui/hud_warden_official_v4/hud_meter_rail_warden_official_ai01.png",
		"BattlePanel/BossMeterFrameArt": "res://assets/art/ui/hud_warden_official_v4/hud_meter_rail_warden_official_ai01.png",
	}
	for node_path: String in expected_texture_paths:
		var texture_rect := hud.get_node_or_null(node_path) as TextureRect
		assert_not_null(texture_rect, "%s 缺少统一资源承载节点。" % node_path)
		if texture_rect == null:
			continue
		assert_not_null(texture_rect.texture, "%s 缺少 02 统一资源。" % node_path)
		if texture_rect.texture != null:
			assert_eq(texture_rect.texture.resource_path, expected_texture_paths[node_path], "%s 仍在混用旧 HUD 图集。" % node_path)

	var hud_font := hud.get_theme_default_font()
	assert_not_null(hud_font, "HUD 必须显式绑定东方书卷字体栈，不能依赖引擎默认字体。")


# 控件矩形落在 StyleBox 安全区还不够：文字基线不能贴着安全区边缘。
func test_hud_text_keeps_inner_breathing_room() -> void:
	var hud := await _spawn_hud()
	var prompt_label := hud.get_node("PromptPanel/PromptLabel") as Label
	var step_label := hud.get_node("PromptPanel/StepLabel") as Label
	prompt_label.text = LONGEST_PROMPT
	hud.call("_sync_prompt_panel_layout")
	hud.call("_update_element_status")
	await get_tree().process_frame

	var safe_rects: Dictionary = hud.call("get_hud_content_safe_rects")
	var prompt_safe := safe_rects["PromptPanel"] as Rect2
	for label: Label in [step_label, prompt_label]:
		assert_gte(label.position.x, prompt_safe.position.x + 10.0, "%s 左侧必须在装饰安全区内再内收。" % label.name)
		assert_lte(label.position.x + label.size.x, prompt_safe.end.x - 10.0, "%s 右侧必须和边框留出呼吸距离。" % label.name)
	assert_lte(prompt_label.position.y + prompt_label.size.y, prompt_safe.end.y - 10.0, "教程正文不得贴住下边框。")
	assert_eq(prompt_label.get_visible_line_count(), prompt_label.get_line_count(), "最长教程提示不得因内收而裁切。")



func test_seal_resonance_panel_uses_two_complete_frames_six_symbols_and_safe_dynamic_content() -> void:
	var hud := await _spawn_hud()
	var panel := hud.get_node("ElementPanel") as Panel
	assert_eq(String(panel.get_meta("hud_role", "")), "seal_resonance")
	assert_eq(String(panel.get_meta("visual_assembly_contract", "")), "seal_resonance_v2_command_seal")
	var idle_frame := panel.get_node_or_null("FrameArt") as TextureRect
	var active_frame := panel.get_node_or_null("FrameArtActive") as TextureRect
	assert_not_null(idle_frame)
	assert_not_null(active_frame)
	if idle_frame == null or active_frame == null:
		return
	assert_eq(idle_frame.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	assert_eq(active_frame.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	assert_not_null(idle_frame.texture, "idle FrameArt 不能是空 TextureRect。")
	assert_not_null(active_frame.texture, "active FrameArt 不能是空 TextureRect。")
	if idle_frame.texture == null or active_frame.texture == null:
		return
	assert_eq(idle_frame.texture.resource_path, SEAL_RESONANCE_FRAME_PATHS["idle"])
	assert_eq(active_frame.texture.resource_path, SEAL_RESONANCE_FRAME_PATHS["active"])
	_assert_six_distinct_seal_resonance_atlas_textures()
	assert_true(panel.has_method("apply_snapshot"))
	assert_true(panel.has_method("get_visual_snapshot"))
	if not panel.has_method("apply_snapshot") or not panel.has_method("get_visual_snapshot"):
		return

	panel.call("apply_snapshot", _seal_snapshot(&"wind", &"ward", []))
	_assert_glyph_texture(panel, "ContentRoot/ElementGlyph", &"wind")
	_assert_glyph_texture(panel, "ContentRoot/StanceGlyph", &"ward")
	_assert_all_visible_dynamic_controls_inside_panel_safe_area(panel)

	panel.call("apply_snapshot", _seal_snapshot(&"thunder", &"swift", []))
	_assert_glyph_texture(panel, "ContentRoot/ElementGlyph", &"thunder")
	_assert_glyph_texture(panel, "ContentRoot/StanceGlyph", &"swift")
	_assert_all_visible_dynamic_controls_inside_panel_safe_area(panel)

	panel.call("apply_snapshot", {
		"current_element_id": &"wind",
		"current_element_label": "风",
		"current_stance_id": &"ward",
		"current_stance_label": "御印",
		"element_sequence": {
			"element_ids": [&"wind"],
			"window_remaining": 1.0,
			"window_duration": 2.0,
			"reaction_id": StringName(),
			"reaction_label": "",
		},
	})
	var visual: Dictionary = panel.call("get_visual_snapshot")
	assert_eq(visual.get("state"), &"primed")
	assert_eq(panel.size, Vector2(324.0, 156.0))
	assert_false(idle_frame.visible)
	assert_true(active_frame.visible)
	_assert_glyph_texture(panel, "ContentRoot/ElementGlyph", &"wind")
	_assert_glyph_texture(panel, "ContentRoot/StanceGlyph", &"ward")
	_assert_all_visible_dynamic_controls_inside_panel_safe_area(panel)

	panel.call("apply_snapshot", _seal_snapshot(&"thunder", &"swift", [&"wind", &"thunder"]))
	_assert_glyph_texture(panel, "ContentRoot/SequenceRoot/SequenceSlotA", &"wind")
	_assert_glyph_texture(panel, "ContentRoot/SequenceRoot/SequenceSlotB", &"thunder")
	_assert_glyph_texture(panel, "ContentRoot/SequenceRoot/ReactionGlyph", &"wind_thunder_pierce")
	_assert_all_visible_dynamic_controls_inside_panel_safe_area(panel)

	panel.call("apply_snapshot", _seal_snapshot(&"wind", &"ward", [&"thunder", &"wind"]))
	_assert_glyph_texture(panel, "ContentRoot/SequenceRoot/SequenceSlotA", &"thunder")
	_assert_glyph_texture(panel, "ContentRoot/SequenceRoot/SequenceSlotB", &"wind")
	_assert_glyph_texture(panel, "ContentRoot/SequenceRoot/ReactionGlyph", &"thunder_wind_scatter")
	_assert_all_visible_dynamic_controls_inside_panel_safe_area(panel)


func test_seal_resonance_snapshot_exposes_a_failing_closed_five_anchor_gate() -> void:
	var hud := await _spawn_hud()
	var panel := hud.get_node("ElementPanel") as Panel
	panel.call("apply_snapshot", _seal_snapshot(&"thunder", &"swift", [&"wind", &"thunder"]))
	var snapshot: Dictionary = panel.call("get_visual_snapshot")
	assert_true(snapshot.has("semantic_anchor_report"), "真实窗口与 formal HUD 必须消费逐槽锚点报告，不能继续只看整体安全区。")
	if not snapshot.has("semantic_anchor_report"):
		return
	var report := snapshot.get("semantic_anchor_report", {}) as Dictionary
	assert_eq(int(report.get("visible_anchor_count", 0)), 5)
	assert_true(bool(report.get("ok", false)), "五个可见符号、三处文字和连接带必须全部通过才允许 runtime report ok=true。")
	var anchors := report.get("anchors", {}) as Dictionary
	assert_eq(anchors.size(), 5)
	for role: String in [&"element", &"stance", &"sequence_a", &"sequence_b", &"reaction"]:
		assert_true(anchors.has(role), "锚点报告缺少 %s。" % role)
		if anchors.has(role):
			var entry := anchors[role] as Dictionary
			assert_lte(float(entry.get("center_error", 999.0)), 0.5, "%s 控件圆心误差超冻结门槛。" % role)
			assert_true(bool(entry.get("inside_slot", false)), "%s 包围盒没有落入本槽。" % role)
			assert_true(bool(entry.get("pixel_core_inside_circle", false)), "%s Alpha 核心没有完整落在圆内。" % role)
			assert_gte(float(entry.get("pixel_core_inset_px", -999.0)), 2.0, "%s Alpha 核心与金属内缘不足 2px。" % role)
			assert_lte(float(entry.get("pixel_focal_center_error", 999.0)), 0.5, "%s 实际 Alpha 质心偏离圆心。" % role)
			assert_eq(String(entry.get("mask_shader_path", "")), SEAL_RESONANCE_ICON_MASK_SHADER_PATH)


func test_tutorial_attention_is_one_shared_layer_with_motion_reduction() -> void:
	var hud := await _spawn_hud()
	var matches := hud.find_children("TutorialAttention", "ColorRect", true, false)
	assert_eq(matches.size(), 1)
	if matches.size() != 1:
		return
	var attention := matches[0] as ColorRect
	assert_not_null(attention.material as ShaderMaterial)
	assert_true(hud.has_method("get_tutorial_attention_state"))
	assert_true(hud.has_method("set_reduced_motion_enabled"))
	if not hud.has_method("get_tutorial_attention_state") or not hud.has_method("set_reduced_motion_enabled"):
		return

	hud.call("_on_tutorial_step_changed", &"dash", "冲刺")
	assert_eq(hud.call("get_tutorial_attention_state"), &"enter")
	hud.call("_process", 5.0)
	assert_eq(hud.call("get_tutorial_attention_state"), &"waiting")

	var input_event := InputEventKey.new()
	input_event.keycode = KEY_K
	input_event.pressed = true
	hud.call("_input", input_event)
	assert_eq(hud.call("get_tutorial_attention_state"), &"idle")

	hud.call("_on_tutorial_step_changed", &"complete", "完成")
	assert_eq(hud.call("get_tutorial_attention_state"), &"complete")
	hud.call("set_reduced_motion_enabled", true)
	var material := attention.material as ShaderMaterial
	assert_eq(float(material.get_shader_parameter("motion_amount")), 0.0)


# 首次绑定已解锁存档只能建立 baseline；只有同一玩家绑定内观察到 false -> true 才能出现风印教学。
func test_wind_switch_prompt_observation_baseline_does_not_backfill_unlocked_save() -> void:
	var hud := await _spawn_hud()
	var packed_player := load(PLAYER_SCENE_PATH) as PackedScene
	assert_not_null(packed_player)
	if packed_player == null:
		return

	var unlocked_player := packed_player.instantiate() as CharacterBody2D
	add_child_autofree(unlocked_player)
	unlocked_player.call("set_wind_seal_unlocked", true)
	hud.call("bind_player", unlocked_player)
	hud.call("_process", 0.0)
	assert_true(hud.has_method("get_contextual_tutorial_snapshot"))
	if not hud.has_method("get_contextual_tutorial_snapshot"):
		return
	var contextual: Dictionary = hud.call("get_contextual_tutorial_snapshot")
	assert_false(bool(contextual.get("active", true)), "已解锁存档首次绑定不得补弹旧教学。")

	var locked_player := packed_player.instantiate() as CharacterBody2D
	add_child_autofree(locked_player)
	hud.call("bind_player", locked_player)
	hud.call("_process", 0.0)
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_false(bool(contextual.get("active", true)))
	locked_player.call("set_wind_seal_unlocked", true)
	hud.call("_process", 0.0)
	contextual = hud.call("get_contextual_tutorial_snapshot")
	assert_true(bool(contextual.get("active", false)), "锁定新游戏重新绑定后必须能观察到真正解锁边沿。")
	assert_eq(contextual.get("step_id"), &"wind_switch")
	locked_player.call("cycle_current_element")
	hud.call("_process", 0.0)
	assert_false(bool((hud.call("get_contextual_tutorial_snapshot") as Dictionary).get("active", true)))


func _seal_snapshot(element_id: StringName, stance_id: StringName, sequence_ids: Array) -> Dictionary:
	var reaction_id := StringName()
	var reaction_label := ""
	if sequence_ids == [&"wind", &"thunder"]:
		reaction_id = &"wind_thunder_pierce"
		reaction_label = "追击贯穿"
	elif sequence_ids == [&"thunder", &"wind"]:
		reaction_id = &"thunder_wind_scatter"
		reaction_label = "散射破势"
	return {
		"current_element_id": element_id,
		"current_element_label": "风" if element_id == &"wind" else "雷",
		"current_stance_id": stance_id,
		"current_stance_label": "御印" if stance_id == &"ward" else "疾印",
		"element_sequence": {
			"element_ids": sequence_ids,
			"window_remaining": 1.0,
			"window_duration": 2.0,
			"reaction_id": reaction_id,
			"reaction_label": reaction_label,
		},
	}


func _assert_six_distinct_seal_resonance_atlas_textures() -> void:
	var loaded_resources: Array[AtlasTexture] = []
	for glyph_id: StringName in SEAL_RESONANCE_GLYPH_CONTRACTS:
		var contract: Dictionary = SEAL_RESONANCE_GLYPH_CONTRACTS[glyph_id]
		var resource_path := str(contract["path"])
		assert_true(ResourceLoader.exists(resource_path), "%s 必须有独立 AtlasTexture 资源。" % glyph_id)
		if not ResourceLoader.exists(resource_path):
			continue
		var glyph_texture := load(resource_path) as AtlasTexture
		assert_not_null(glyph_texture, "%s 必须加载为 AtlasTexture。" % glyph_id)
		if glyph_texture == null:
			continue
		assert_eq(glyph_texture.resource_path, resource_path)
		assert_not_null(glyph_texture.atlas, "%s AtlasTexture 必须引用 symbols atlas。" % glyph_id)
		if glyph_texture.atlas != null:
			assert_eq(glyph_texture.atlas.resource_path, SEAL_RESONANCE_SYMBOL_ATLAS_PATH)
		assert_eq(glyph_texture.region, contract["region"])
		assert_false(loaded_resources.has(glyph_texture), "%s 不得与另一语义共用 AtlasTexture。" % glyph_id)
		loaded_resources.append(glyph_texture)
	assert_eq(loaded_resources.size(), 6, "风、雷、疾、御、贯穿、散射必须分别拥有资源。")


func _assert_glyph_texture(panel: Panel, node_path: String, glyph_id: StringName) -> void:
	var glyph := panel.get_node_or_null(node_path) as TextureRect
	assert_not_null(glyph, "%s 缺少 %s glyph 节点。" % [node_path, glyph_id])
	if glyph == null:
		return
	assert_not_null(glyph.texture, "%s 必须显示 %s 的 AtlasTexture。" % [node_path, glyph_id])
	if glyph.texture == null:
		return
	var contract: Dictionary = SEAL_RESONANCE_GLYPH_CONTRACTS[glyph_id]
	assert_true(glyph.texture is AtlasTexture, "%s 必须是 AtlasTexture。" % node_path)
	assert_eq(glyph.texture.resource_path, str(contract["path"]), "%s 的语义映射错误。" % node_path)
	var material := glyph.material as ShaderMaterial
	assert_not_null(material, "%s 必须使用共用圆形安全遮罩。" % node_path)
	if material != null:
		assert_not_null(material.shader)
		if material.shader != null:
			assert_eq(material.shader.resource_path, SEAL_RESONANCE_ICON_MASK_SHADER_PATH)


func _assert_all_visible_dynamic_controls_inside_panel_safe_area(panel: Panel) -> void:
	# 符印共鸣盘是 L 形五槽器物，单一矩形 StyleBox 安全区无法表达底部反应圆。
	# 该组件必须改由逐槽圆心、包围盒、文字区和连接带合同 fail closed。
	if panel.has_method("get_semantic_anchor_report"):
		var anchor_report := panel.call("get_semantic_anchor_report") as Dictionary
		assert_true(bool(anchor_report.get("ok", false)), "符印共鸣盘逐槽视觉门槛必须通过：%s" % anchor_report)
		return
	var content_root := panel.get_node_or_null("ContentRoot") as Control
	assert_not_null(content_root, "动态内容必须由 ContentRoot 承载。")
	if content_root == null:
		return
	var stylebox := panel.get_theme_stylebox("panel")
	assert_not_null(stylebox, "当前符印共鸣盘状态必须提供对应 StyleBox 安全区。")
	if stylebox == null:
		return
	var safe_rect := Rect2(
		Vector2(stylebox.get_content_margin(SIDE_LEFT), stylebox.get_content_margin(SIDE_TOP)),
		panel.size - Vector2(
			stylebox.get_content_margin(SIDE_LEFT) + stylebox.get_content_margin(SIDE_RIGHT),
			stylebox.get_content_margin(SIDE_TOP) + stylebox.get_content_margin(SIDE_BOTTOM),
		),
	)
	_assert_visible_dynamic_descendants_inside_safe_rect(panel, content_root, safe_rect)


func _assert_visible_dynamic_descendants_inside_safe_rect(panel: Panel, parent: Node, safe_rect: Rect2) -> void:
	for child: Node in parent.get_children():
		var control := child as Control
		if control != null and control.is_visible_in_tree():
			var local_rect := _control_rect_in_panel_space(panel, control)
			assert_true(
				safe_rect.encloses(local_rect),
				"%s 必须完整位于 %s 的当前安全区 %s，实际 %s" % [control.get_path(), panel.name, safe_rect, local_rect],
			)
		_assert_visible_dynamic_descendants_inside_safe_rect(panel, child, safe_rect)


func _control_rect_in_panel_space(panel: Panel, control: Control) -> Rect2:
	var inverse_panel_transform := panel.get_global_transform_with_canvas().affine_inverse()
	var global_rect := control.get_global_rect()
	var top_left := inverse_panel_transform * global_rect.position
	var bottom_right := inverse_panel_transform * global_rect.end
	return Rect2(top_left, bottom_right - top_left).abs()


func _spawn_hud() -> Control:
	var packed := load(HUD_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var hud := packed.instantiate() as Control
	add_child_autofree(hud)
	await get_tree().process_frame
	return hud


func _visual_rect(hud: Control, control: Control, viewport_size: Vector2) -> Rect2:
	var canvas_scale := float(hud.call("_canvas_scale_for_physical_viewport", viewport_size))
	return Rect2(control.position * canvas_scale, control.size * control.scale * canvas_scale)


func _assert_visual_rect_inside_viewport(hud: Control, control: Control, viewport_size: Vector2) -> void:
	var rect := _visual_rect(hud, control, viewport_size)
	assert_gte(rect.position.x, 0.0, "%s left @ %s" % [control.name, viewport_size])
	assert_gte(rect.position.y, 0.0, "%s top @ %s" % [control.name, viewport_size])
	assert_lte(rect.end.x, viewport_size.x, "%s right @ %s" % [control.name, viewport_size])
	assert_lte(rect.end.y, viewport_size.y, "%s bottom @ %s" % [control.name, viewport_size])


func _assert_no_visual_overlap(hud: Control, left: Control, right: Control, viewport_size: Vector2) -> void:
	assert_false(
		_visual_rect(hud, left, viewport_size).intersects(_visual_rect(hud, right, viewport_size)),
		"top panels overlap @ %s" % viewport_size,
	)


func _assert_panel_uses_texture_safe_area(panel: Panel, controls: Array) -> void:
	var stylebox := panel.get_theme_stylebox("panel")
	assert_not_null(stylebox, "%s 必须提供独立内容安全区 StyleBox。" % panel.name)
	if stylebox == null:
		return
	for side: int in [SIDE_LEFT, SIDE_RIGHT]:
		assert_gte(stylebox.get_content_margin(side), 24.0, "%s horizontal content margin side=%d" % [panel.name, side])
	for side: int in [SIDE_TOP, SIDE_BOTTOM]:
		assert_gte(stylebox.get_content_margin(side), 10.0, "%s vertical content margin side=%d" % [panel.name, side])
	var safe_rect := Rect2(
		Vector2(stylebox.get_content_margin(SIDE_LEFT), stylebox.get_content_margin(SIDE_TOP)),
		panel.size - Vector2(
			stylebox.get_content_margin(SIDE_LEFT) + stylebox.get_content_margin(SIDE_RIGHT),
			stylebox.get_content_margin(SIDE_TOP) + stylebox.get_content_margin(SIDE_BOTTOM),
		),
	)
	for control_variant: Variant in controls:
		var control := control_variant as Control
		if control == null or not control.visible:
			continue
		var control_rect := Rect2(control.position, control.size)
		assert_true(safe_rect.encloses(control_rect), "%s 必须完整位于 %s 的装饰内容安全区 %s，实际 %s" % [control.name, panel.name, safe_rect, control_rect])
