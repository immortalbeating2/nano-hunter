extends GutTest

# Stage16 专项 GUT 保护 Alpha Demo 打包候选的退出条件：
# 五房终局封印链、Stage15 接入、Main 进度快照、完整重开、Demo shell、HUD 完成态、
# 灰盒主线 driver，以及资产 / QA / release notes 文档门禁。

const Stage16AlphaDemoGrayboxDriver := preload("res://tests/stage16/support/stage16_alpha_demo_graybox_driver.gd")
const InputBindingFormatter := preload("res://scripts/ui/input_binding_formatter.gd")

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const STAGE14_AIR_DASH_GATE_ROOM_PATH := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const STAGE15_COMPLETION_ROOM_PATH := "res://scenes/rooms/stage15_completion_room.tscn"
const STAGE16_SEAL_RELEASE_THRESHOLD_ROOM_PATH := "res://scenes/rooms/stage16_seal_release_threshold_room.tscn"
const STAGE16_TALISMAN_RELAY_ROOM_PATH := "res://scenes/rooms/stage16_talisman_relay_room.tscn"
const STAGE16_BACKTRACK_CONFIRMATION_ROOM_PATH := "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn"
const STAGE16_CORRUPTION_PURGE_ROOM_PATH := "res://scenes/rooms/stage16_corruption_purge_room.tscn"
const STAGE16_ALPHA_DEMO_END_ROOM_PATH := "res://scenes/rooms/stage16_alpha_demo_end_room.tscn"
const ASSET_MANIFEST_PATH := "res://docs/assets/asset-manifest.md"
const QA_CHECKLIST_PATH := "res://docs/deliverables/stage16-alpha-demo-candidate/qa-checklist.md"
const RELEASE_NOTES_PATH := "res://docs/deliverables/stage16-alpha-demo-candidate/release-notes.md"
const STAGE16_SEAL_RELEASE_LOCKED_TEXTURE_PATH := "res://assets/art/editor_resources/stage16_seal_release_threshold_ai01/000_stage16_seal_release_threshold_ai01_state_locked.atlas_texture.tres"
const STAGE16_SEAL_RELEASE_ACTIVE_TEXTURE_PATH := "res://assets/art/editor_resources/stage16_seal_release_threshold_ai01/001_stage16_seal_release_threshold_ai01_state_active.atlas_texture.tres"
const STAGE16_SEAL_RELEASE_RELEASED_TEXTURE_PATH := "res://assets/art/editor_resources/stage16_seal_release_threshold_ai01/002_stage16_seal_release_threshold_ai01_state_released.atlas_texture.tres"
const SHRINE_GATE_LOCKED_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres"
const SHRINE_CHAIN_ANCHOR_LEFT_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/018_shrine_gate_prop_atlas_ai01_auto_019_c02.atlas_texture.tres"
const SHRINE_CHAIN_ANCHOR_RIGHT_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/019_shrine_gate_prop_atlas_ai01_auto_020_c02.atlas_texture.tres"
const SHRINE_RELAY_FOCUS_BASE_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/020_shrine_gate_prop_atlas_ai01_auto_021_c02.atlas_texture.tres"
const SHRINE_PURGE_FOCUS_BASE_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/017_shrine_gate_prop_atlas_ai01_auto_018_c02.atlas_texture.tres"
const STAGE16_COMPLETION_PANEL_UI_ART_PATH := "res://assets/art/ui/stage16_completion_panel_ui_ai01.png"

const STAGE16_ROOM_PATHS := [
	STAGE16_SEAL_RELEASE_THRESHOLD_ROOM_PATH,
	STAGE16_TALISMAN_RELAY_ROOM_PATH,
	STAGE16_BACKTRACK_CONFIRMATION_ROOM_PATH,
	STAGE16_CORRUPTION_PURGE_ROOM_PATH,
	STAGE16_ALPHA_DEMO_END_ROOM_PATH,
]

const FORMAL_ROOM_IDS := [
	"F01", "F02", "F03", "F04", "F05", "F06", "F07", "F08", "F09",
	"F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18",
]


# 输入清理保护 Demo shell 暂停 / 继续和重开测试不会被上一条残留动作污染。
func before_each() -> void:
	for action_name in ["move_left", "move_right", "jump", "attack", "dash", "recover", "ui_down", "ui_cancel", "ui_accept"]:
		_release_action_if_present(action_name)


# 每条 Stage16 测试结束后释放输入，保证灰盒 driver 和 HUD 断言相互独立。
func after_each() -> void:
	before_each()


# 保护 Stage16 房间集合：五个终局封印链房间必须存在，并可作为资源加载。
func test_stage16_five_room_resources_exist() -> void:
	for room_path in STAGE16_ROOM_PATHS:
		assert_true(ResourceLoader.exists(room_path), "缺少 Stage16 房间资源：%s" % room_path)


# 方案 B 正式完成房返回 F03；Stage16 五房只保留 reserve 独立测试入口。
func test_stage15_completion_room_returns_to_formal_waystation() -> void:
	var room := await _spawn_room(STAGE15_COMPLETION_ROOM_PATH)
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var transitions: Array = []

	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target_room_path: String, spawn_id: StringName) -> void:
		transitions.append({"target": target_room_path, "spawn": spawn_id})
	)

	player.global_position = room.get_node("WaystationZone").global_position
	await _advance_process_frames(2)
	assert_true(transitions.is_empty(), "F18 归驿法坛必须等待玩家按下方向确认。")

	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")

	assert_eq(transitions.size(), 1)
	if transitions.is_empty():
		return
	assert_eq(transitions[0].get("target"), "res://scenes/rooms/stage11_demo_end_room.tscn")
	assert_eq(transitions[0].get("spawn"), &"stage11_demo_end_start")


# 保护 Main 快照契约：Stage16 完成态、release notes 和 QA checklist 必须是稳定读值。
func test_main_snapshot_exposes_stage16_release_notes_and_qa_flags() -> void:
	var main_scene := await _spawn_main_scene()
	assert_true(main_scene.has_method("get_demo_progress_snapshot"))

	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")
	assert_true(snapshot.has("stage16_alpha_demo_completed"))
	assert_true(snapshot.has("stage16_release_notes_ready"))
	assert_true(snapshot.has("stage16_qa_checklist_ready"))
	assert_false(bool(snapshot.get("stage16_alpha_demo_completed", true)))
	assert_true(bool(snapshot.get("stage16_release_notes_ready", false)))
	assert_true(bool(snapshot.get("stage16_qa_checklist_ready", false)))


# 保护完整重开语义：restart_demo 必须清理 Stage14 / Stage15 / Stage16 运行期进度。
func test_restart_demo_clears_stage14_stage15_and_stage16_runtime_state() -> void:
	var main_scene := await _spawn_main_scene()

	if main_scene.has_method("unlock_air_dash"):
		main_scene.call("unlock_air_dash")
	if main_scene.has_method("collect_stage14_backtrack_reward"):
		main_scene.call("collect_stage14_backtrack_reward", &"stage16_restart_probe_one")
		main_scene.call("collect_stage14_backtrack_reward", &"stage16_restart_probe_two")
	if main_scene.has_method("mark_stage15_boss_defeated"):
		main_scene.call("mark_stage15_boss_defeated")
	if main_scene.has_method("mark_stage16_alpha_demo_completed"):
		main_scene.call("mark_stage16_alpha_demo_completed")

	assert_true(main_scene.has_method("restart_demo"))
	main_scene.call("restart_demo")
	await _advance_process_frames(4)

	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")
	assert_false(bool(snapshot.get("air_dash_unlocked", true)))
	assert_eq(int(snapshot.get("stage14_backtrack_reward_count", -1)), 0)
	assert_false(bool(snapshot.get("stage15_boss_defeated", true)))
	assert_false(bool(snapshot.get("stage16_alpha_demo_completed", true)))
	assert_eq(_get_room_path(main_scene), "res://scenes/rooms/tutorial_room.tscn")


# 保护 Demo shell 最小契约：主菜单入口、暂停、继续和重开应由 Main 提供稳定接口。
func test_demo_shell_exposes_start_pause_resume_and_restart_contract() -> void:
	var main_scene := await _spawn_main_scene()

	assert_true(main_scene.has_method("start_demo"))
	assert_true(main_scene.has_method("pause_demo"))
	assert_true(main_scene.has_method("resume_demo"))
	assert_true(main_scene.has_method("is_demo_paused"))
	assert_true(main_scene.has_method("restart_demo"))
	if not (
		main_scene.has_method("start_demo")
		and main_scene.has_method("pause_demo")
		and main_scene.has_method("resume_demo")
		and main_scene.has_method("is_demo_paused")
	):
		return

	main_scene.call("start_demo")
	await _advance_process_frames(2)
	main_scene.call("pause_demo")
	await _advance_process_frames(2)
	assert_true(bool(main_scene.call("is_demo_paused")))

	main_scene.call("resume_demo")
	await _advance_process_frames(2)
	assert_false(bool(main_scene.call("is_demo_paused")))

	main_scene.call("restart_demo")
	await _advance_process_frames(2)
	assert_eq(_get_room_path(main_scene), "res://scenes/rooms/tutorial_room.tscn")


# 保护 DemoShell 的 image gen UI 壳资源：暂停已从旧整图预览迁移到批准的 02 NinePatch 外框。
func test_demo_shell_references_imagegen_ui_shell_assets() -> void:
	var main_scene := await _spawn_main_scene()
	var demo_shell := main_scene.get_node_or_null("HUD/DemoShell")
	assert_not_null(demo_shell)
	if demo_shell == null:
		return

	var expected_textures := {
		"TitleBackground": "res://assets/art/ui/main_menu_shell_ai02.png",
		"MainMenu/MenuIconStrip": "res://assets/art/ui/stage16_demo_menu_icons_ai01.png",
		"CompletionPanel/CompletionPanelArt": "res://assets/art/ui/stage16_completion_panel_ui_ai01.png",
	}
	for node_path: String in expected_textures.keys():
		var texture_rect := demo_shell.get_node_or_null(NodePath(node_path)) as TextureRect
		assert_not_null(texture_rect, "缺少 DemoShell UI 资产节点：%s" % node_path)
		if texture_rect == null:
			continue
		assert_not_null(texture_rect.texture, "DemoShell UI 资产节点没有纹理：%s" % node_path)
		if texture_rect.texture != null:
			assert_eq(texture_rect.texture.resource_path, expected_textures[node_path])
	var menu_icon_strip := demo_shell.get_node_or_null("MainMenu/MenuIconStrip") as TextureRect
	assert_not_null(menu_icon_strip)
	if menu_icon_strip != null:
		assert_false(menu_icon_strip.visible, "整张菜单 icon sheet 只保留资源引用，不能压缩成运行态装饰条。")
	var pause_menu := demo_shell.get_node_or_null("PauseMenu") as Panel
	assert_not_null(pause_menu)
	assert_null(demo_shell.get_node_or_null("PauseMenu/PausePanelArt"), "旧暂停整图预览已由可伸缩外框替代。")
	if pause_menu != null:
		var pause_style := pause_menu.get_theme_stylebox("panel") as StyleBoxTexture
		assert_not_null(pause_style)
		if pause_style != null and pause_style.texture != null:
			assert_eq(pause_style.texture.resource_path, "res://assets/art/ui/hud_warden_official_v4/pause_frame_base_warden_official_ai01.png")
			assert_almost_eq(float(pause_style.texture.get_width()) / float(pause_style.texture.get_height()), 1.05, 0.01)
		_assert_warden_official_ornament_layer(pause_menu)
	var failure_panel := demo_shell.get_node_or_null("FailurePanel") as Panel
	assert_not_null(failure_panel)
	if failure_panel != null:
		var failure_style := failure_panel.get_theme_stylebox("panel") as StyleBoxTexture
		assert_not_null(failure_style)
		if failure_style != null and failure_style.texture != null:
			assert_eq(failure_style.texture.resource_path, "res://assets/art/ui/hud_warden_official_v4/pause_frame_base_warden_official_ai01.png")
		_assert_warden_official_ornament_layer(failure_panel)
	var pause_title_label := demo_shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer/TitleLabel") as Label
	var completion_label := demo_shell.get_node_or_null("CompletionPanel/MarginContainer/CompletionLabel") as Label
	var resume_button := demo_shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer/ResumeButton") as Button
	var restart_button := demo_shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer/RestartButton") as Button
	var failure_continue_button := demo_shell.get_node_or_null("FailurePanel/MarginContainer/VBoxContainer/FailureContinueButton") as Button
	assert_not_null(pause_title_label)
	assert_not_null(completion_label)
	assert_not_null(resume_button)
	assert_not_null(restart_button)
	assert_not_null(failure_continue_button)
	if pause_title_label != null:
		assert_gt(pause_title_label.get_theme_color("font_color").r, 0.7)
	if completion_label != null:
		assert_lt(completion_label.get_theme_color("font_color").r, 0.5)
	if resume_button != null:
		assert_null(resume_button.icon, "暂停操作项使用固定几何文字按钮，不再混入方形 icon sheet。")
	if restart_button != null:
		assert_null(restart_button.icon, "重开操作项使用固定几何文字按钮，不再混入方形 icon sheet。")
	if failure_continue_button != null:
		assert_null(failure_continue_button.icon, "失败继续操作项使用固定几何文字按钮。")


# 保护 C2 主菜单构图：无框菜单位于右侧雾区，六项入口共用一条流动符光且没有冗余图标或提示。
func test_demo_shell_main_menu_uses_c2_right_side_layout() -> void:
	var main_scene := await _spawn_main_scene()
	var demo_shell := main_scene.get_node_or_null("HUD/DemoShell")
	assert_not_null(demo_shell)
	if demo_shell == null:
		return
	var save_suffix := Time.get_ticks_usec()
	assert_true(bool(main_scene.call(
		"set_save_paths_for_testing",
		"user://stage16_menu_missing_%d.json" % save_suffix,
		"user://stage16_menu_missing_%d.backup.json" % save_suffix,
	)))
	demo_shell.call("refresh_save_state")

	var main_menu := demo_shell.get_node_or_null("MainMenu") as Panel
	var detail_panel := demo_shell.get_node_or_null("DetailPanel") as Panel
	var margin_container := demo_shell.get_node_or_null("MainMenu/MarginContainer") as MarginContainer
	var focus_band := demo_shell.get_node_or_null("MainMenu/FocusBand") as ColorRect
	var title_wordmark := demo_shell.get_node_or_null("MainMenu/MarginContainer/VBoxContainer/TitleWordmark") as TextureRect
	var status_label := demo_shell.get_node_or_null("MainMenu/MarginContainer/VBoxContainer/StatusLabel")
	var detail_title_label := demo_shell.get_node_or_null("DetailPanel/MarginContainer/VBoxContainer/DetailTitleLabel") as Label
	var detail_body_label := demo_shell.get_node_or_null("DetailPanel/MarginContainer/VBoxContainer/DetailBodyLabel") as Label
	var detail_back_button := demo_shell.get_node_or_null("DetailPanel/MarginContainer/VBoxContainer/DetailBackButton") as Button
	var start_button := demo_shell.get_node_or_null("MainMenu/MarginContainer/VBoxContainer/StartButton") as Button
	var continue_button := demo_shell.get_node_or_null("MainMenu/MarginContainer/VBoxContainer/ContinueButton") as Button
	var level_select_button := demo_shell.get_node_or_null("MainMenu/MarginContainer/VBoxContainer/LevelSelectButton") as Button
	var settings_button := demo_shell.get_node_or_null("MainMenu/MarginContainer/VBoxContainer/SettingsButton") as Button
	var controls_button := demo_shell.get_node_or_null("MainMenu/MarginContainer/VBoxContainer/ControlsButton") as Button
	var quit_button := demo_shell.get_node_or_null("MainMenu/MarginContainer/VBoxContainer/QuitButton") as Button
	assert_not_null(main_menu)
	assert_not_null(detail_panel)
	assert_not_null(margin_container)
	assert_not_null(focus_band)
	assert_not_null(title_wordmark)
	assert_null(status_label, "C2 主菜单不应保留存档状态提示。")
	assert_eq(demo_shell.find_children("FocusBand", "ColorRect", true, false).size(), 1)
	assert_not_null(detail_title_label)
	assert_not_null(detail_body_label)
	assert_not_null(detail_back_button)
	assert_not_null(start_button)
	assert_not_null(continue_button)
	assert_not_null(level_select_button)
	assert_not_null(settings_button)
	assert_not_null(controls_button)
	assert_not_null(quit_button)
	if main_menu == null or margin_container == null or start_button == null:
		return

	assert_almost_eq(main_menu.anchor_left, 0.745, 0.001)
	assert_almost_eq(main_menu.anchor_top, 0.515, 0.001)
	assert_almost_eq(main_menu.anchor_right, 0.745, 0.001)
	assert_almost_eq(main_menu.anchor_bottom, 0.515, 0.001)
	assert_eq(main_menu.grow_horizontal, Control.GROW_DIRECTION_BOTH)
	assert_eq(main_menu.grow_vertical, Control.GROW_DIRECTION_BOTH)
	assert_lte(absf((main_menu.offset_left + main_menu.offset_right) * 0.5), 1.0)
	var main_menu_width := main_menu.offset_right - main_menu.offset_left
	var main_menu_height := main_menu.offset_bottom - main_menu.offset_top
	assert_gte(main_menu_width, 300.0)
	assert_lte(main_menu_width, 900.0)
	assert_gte(main_menu_height, 300.0)
	assert_lte(main_menu_height, 980.0)
	assert_lte(main_menu_width * main_menu_height, 900.0 * 980.0)
	if title_wordmark != null:
		assert_not_null(title_wordmark.texture)
		assert_eq(title_wordmark.texture.resource_path, "res://assets/art/ui/main_menu_wordmark_ai01.png")
		assert_eq(title_wordmark.get_meta("asset_id"), "main_menu_wordmark_ai01")
		assert_eq(title_wordmark.stretch_mode, TextureRect.STRETCH_SCALE)
		assert_eq(title_wordmark.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
	if focus_band != null:
		assert_true(focus_band.visible)
		assert_eq(focus_band.mouse_filter, Control.MOUSE_FILTER_IGNORE)
		var shader_material := focus_band.material as ShaderMaterial
		assert_not_null(shader_material)
		if shader_material != null:
			assert_not_null(shader_material.shader)
			if shader_material.shader != null:
				assert_eq(shader_material.shader.resource_path, "res://assets/shaders/ui/main_menu_focus_band.gdshader")
				assert_string_contains(shader_material.shader.code, "TIME")
		assert_almost_eq(focus_band.get_global_rect().get_center().y, start_button.get_global_rect().end.y, 1.5)
		assert_almost_eq(focus_band.size.x, start_button.size.x, 1.5)
	if detail_panel != null:
		assert_false(detail_panel.visible)
		assert_eq(detail_panel.anchor_left, 0.5)
		assert_eq(detail_panel.anchor_top, 0.5)
		assert_eq(detail_panel.anchor_right, 0.5)
		assert_eq(detail_panel.anchor_bottom, 0.5)
		assert_lte(absf((detail_panel.offset_left + detail_panel.offset_right) * 0.5), 1.0)
		var viewport_size: Vector2 = demo_shell.get_viewport_rect().size
		var detail_width: float = detail_panel.offset_right - detail_panel.offset_left
		var detail_height: float = detail_panel.offset_bottom - detail_panel.offset_top
		assert_between(detail_width / viewport_size.x, 0.32, 0.46)
		assert_between(detail_height / viewport_size.y, 0.42, 0.60)
	assert_eq(margin_container.anchor_right, 1.0)
	assert_eq(margin_container.anchor_bottom, 1.0)
	assert_gte(start_button.custom_minimum_size.y, 28.0)
	assert_lte(start_button.custom_minimum_size.y, 62.0)
	assert_gte(start_button.custom_minimum_size.x, 220.0)
	assert_lte(start_button.custom_minimum_size.x, 720.0)
	assert_eq(start_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
	assert_true(start_button.get_theme_stylebox("normal") is StyleBoxFlat)
	assert_true(start_button.get_theme_stylebox("hover") is StyleBoxFlat)
	assert_true(start_button.get_theme_stylebox("pressed") is StyleBoxFlat)
	var normal_style := start_button.get_theme_stylebox("normal") as StyleBoxFlat
	var focus_style := start_button.get_theme_stylebox("focus") as StyleBoxFlat
	assert_not_null(normal_style)
	assert_not_null(focus_style)
	if normal_style != null:
		assert_almost_eq(normal_style.bg_color.a, 0.0, 0.001)
	if focus_style != null:
		assert_eq(focus_style.border_width_bottom, 0)
	for state: String in ["hover", "pressed"]:
		var state_style := start_button.get_theme_stylebox(state) as StyleBoxFlat
		assert_not_null(state_style)
		if state_style != null:
			assert_eq(state_style.border_width_bottom, 0)
	assert_eq(start_button.text, "开始游戏")
	assert_null(start_button.icon)
	if continue_button != null:
		assert_true(continue_button.disabled)
		assert_eq(continue_button.focus_mode, Control.FOCUS_NONE)
		assert_eq(continue_button.custom_minimum_size, start_button.custom_minimum_size)
		assert_eq(continue_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
		assert_eq(continue_button.text, "继续游戏")
		assert_null(continue_button.icon)
	if level_select_button != null:
		assert_false(level_select_button.disabled)
		assert_eq(level_select_button.custom_minimum_size, start_button.custom_minimum_size)
		assert_eq(level_select_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
		assert_eq(level_select_button.text, "选择关卡")
	if settings_button != null:
		assert_false(settings_button.disabled)
		assert_eq(settings_button.custom_minimum_size, start_button.custom_minimum_size)
		assert_eq(settings_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
		assert_eq(settings_button.text, "设置")
		settings_button.grab_focus()
		await get_tree().create_timer(0.25).timeout
		assert_same(demo_shell.get_node("MainMenu/FocusBand"), focus_band)
		assert_almost_eq(focus_band.get_global_rect().get_center().y, settings_button.get_global_rect().end.y, 2.0)
	if controls_button != null:
		assert_false(controls_button.disabled)
		assert_eq(controls_button.custom_minimum_size, start_button.custom_minimum_size)
		assert_eq(controls_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
		assert_eq(controls_button.text, "控制说明")
	if quit_button != null:
		assert_false(quit_button.disabled)
		assert_eq(quit_button.custom_minimum_size, start_button.custom_minimum_size)
		assert_eq(quit_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
		assert_eq(quit_button.text, "退出游戏")
	if continue_button != null and detail_panel != null and detail_title_label != null and detail_body_label != null:
		continue_button.emit_signal("pressed")
		assert_false(main_menu.visible)
		assert_true(detail_panel.visible)
		assert_eq(detail_title_label.text, "继续游戏")
		assert_string_contains(detail_body_label.text, "没有可继续")
		assert_lt(detail_title_label.get_theme_color("font_color").r, 0.5)
		assert_lt(detail_body_label.get_theme_color("font_color").r, 0.5)
	if detail_back_button != null and detail_panel != null:
		_assert_button_icon_resource(
			detail_back_button,
			"res://assets/art/editor_resources/stage16_demo_menu_icons_ai01/004_stage16_demo_menu_icons_ai01_back.atlas_texture.tres"
		)
		detail_back_button.emit_signal("pressed")
		assert_true(main_menu.visible)
		assert_false(detail_panel.visible)
	if controls_button != null and detail_panel != null and detail_title_label != null and detail_body_label != null:
		controls_button.emit_signal("pressed")
		assert_true(detail_panel.visible)
		assert_eq(detail_title_label.text, "控制说明")
		var expected_attack_binding := "攻击：%s · %s" % [
			InputBindingFormatter.action_label(&"attack", InputBindingFormatter.DEVICE_KEYBOARD),
			InputBindingFormatter.action_label(&"attack", InputBindingFormatter.DEVICE_CONTROLLER),
		]
		assert_string_contains(detail_body_label.text, expected_attack_binding)
		assert_string_contains(detail_body_label.text, "下穿平台：按住")
	if settings_button != null and detail_title_label != null and detail_body_label != null:
		settings_button.emit_signal("pressed")
		assert_eq(detail_title_label.text, "设置")
		var expected_element_switch_binding := "元素切换：%s · %s" % [
			InputBindingFormatter.action_label(&"element_switch", InputBindingFormatter.DEVICE_KEYBOARD),
			InputBindingFormatter.action_label(&"element_switch", InputBindingFormatter.DEVICE_CONTROLLER),
		]
		var reduced_motion_label := "开启" if bool(ProjectSettings.get_setting("accessibility/reduced_motion", false)) else "关闭"
		assert_string_contains(detail_body_label.text, expected_element_switch_binding)
		assert_string_contains(detail_body_label.text, "降低动态效果：%s" % reduced_motion_label)


# 保护暂停菜单布局：暂停发生在运行态 HUD 上，不能沿用早期固定左上角坐标。
func test_demo_shell_pause_menu_uses_centered_runtime_layout() -> void:
	var main_scene := await _spawn_main_scene()
	var demo_shell := main_scene.get_node_or_null("HUD/DemoShell")
	assert_not_null(demo_shell)
	if demo_shell == null:
		return

	var pause_menu := demo_shell.get_node_or_null("PauseMenu") as Panel
	var pause_margin_container := demo_shell.get_node_or_null("PauseMenu/MarginContainer") as MarginContainer
	var resume_button := demo_shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer/ResumeButton") as Button
	var map_button := demo_shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer/MapButton") as Button
	var build_button := demo_shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer/BuildButton") as Button
	var restart_button := demo_shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer/RestartButton") as Button
	assert_not_null(pause_menu)
	assert_not_null(pause_margin_container)
	assert_not_null(resume_button)
	assert_not_null(map_button)
	assert_not_null(build_button)
	assert_not_null(restart_button)
	if pause_menu == null or pause_margin_container == null or resume_button == null or map_button == null or build_button == null or restart_button == null:
		return

	main_scene.call("start_demo")
	await _advance_process_frames(2)
	demo_shell.call("pause_demo")
	await _advance_process_frames(2)

	assert_true(pause_menu.visible)
	assert_eq(pause_menu.anchor_left, 0.5)
	assert_eq(pause_menu.anchor_top, 0.5)
	assert_eq(pause_menu.anchor_right, 0.5)
	assert_eq(pause_menu.anchor_bottom, 0.5)
	assert_eq(pause_menu.grow_horizontal, Control.GROW_DIRECTION_BOTH)
	assert_eq(pause_menu.grow_vertical, Control.GROW_DIRECTION_BOTH)
	assert_lte(absf((pause_menu.offset_left + pause_menu.offset_right) * 0.5), 1.0)
	assert_lte(absf((pause_menu.offset_top + pause_menu.offset_bottom) * 0.5), 1.0)
	var pause_width := pause_menu.offset_right - pause_menu.offset_left
	var pause_height := pause_menu.offset_bottom - pause_menu.offset_top
	var viewport_size: Vector2 = demo_shell.get_viewport_rect().size
	assert_between(pause_width / viewport_size.x, 0.24, 0.28)
	assert_between(pause_height / viewport_size.y, 0.40, 0.47)
	assert_almost_eq(pause_width / pause_height, 1.05, 0.02)
	assert_eq(pause_margin_container.anchor_right, 1.0)
	assert_eq(pause_margin_container.anchor_bottom, 1.0)
	assert_gte(resume_button.custom_minimum_size.x, 176.0)
	assert_eq(resume_button.custom_minimum_size, map_button.custom_minimum_size)
	assert_eq(resume_button.custom_minimum_size, build_button.custom_minimum_size)
	assert_eq(resume_button.custom_minimum_size, restart_button.custom_minimum_size)
	assert_eq(resume_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
	assert_eq(map_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
	assert_eq(build_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
	assert_eq(restart_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)


# 保护测试选关入口：主菜单应能跳到指定房间，并仍复用 Main 的玩家、HUD 和能力状态装配。
func test_demo_shell_level_select_starts_selected_room_for_testing() -> void:
	var main_scene := await _spawn_main_scene()
	var demo_shell := main_scene.get_node_or_null("HUD/DemoShell")
	assert_not_null(demo_shell)
	if demo_shell == null:
		return

	var title_background := demo_shell.get_node_or_null("TitleBackground") as TextureRect
	var main_menu := demo_shell.get_node_or_null("MainMenu") as Panel
	var detail_panel := demo_shell.get_node_or_null("DetailPanel") as Panel
	var detail_title_label := demo_shell.get_node_or_null("DetailPanel/MarginContainer/VBoxContainer/DetailTitleLabel") as Label
	var detail_body_label := demo_shell.get_node_or_null("DetailPanel/MarginContainer/VBoxContainer/DetailBodyLabel") as Label
	var level_select_button := demo_shell.get_node_or_null("MainMenu/MarginContainer/VBoxContainer/LevelSelectButton") as Button
	var level_select_scroll := demo_shell.get_node_or_null("DetailPanel/MarginContainer/VBoxContainer/LevelSelectScroll") as ScrollContainer
	var level_select_list := demo_shell.get_node_or_null("DetailPanel/MarginContainer/VBoxContainer/LevelSelectScroll/LevelSelectList") as VBoxContainer
	assert_not_null(title_background)
	assert_not_null(main_menu)
	assert_not_null(detail_panel)
	assert_not_null(detail_title_label)
	assert_not_null(detail_body_label)
	assert_not_null(level_select_button)
	assert_not_null(level_select_scroll)
	assert_not_null(level_select_list)
	if (
		title_background == null
		or main_menu == null
		or detail_panel == null
		or detail_title_label == null
		or detail_body_label == null
		or level_select_button == null
		or level_select_scroll == null
		or level_select_list == null
	):
		return

	assert_true(main_scene.has_method("start_demo_at_room"))
	level_select_button.emit_signal("pressed")
	await _advance_process_frames(2)

	assert_false(main_menu.visible)
	assert_true(detail_panel.visible)
	assert_true(level_select_scroll.visible)
	assert_eq(detail_title_label.text, "选择关卡")
	assert_string_contains(detail_body_label.text, "测试入口")
	assert_gt(level_select_list.get_child_count(), 10)
	for index: int in range(FORMAL_ROOM_IDS.size()):
		var formal_button := level_select_list.get_child(index) as Button
		assert_not_null(formal_button)
		if formal_button != null:
			assert_true(formal_button.text.begins_with("%s · " % FORMAL_ROOM_IDS[index]))

	var stage14_gate_button := _find_button_by_text(level_select_list, "F14 · 空冲证明")
	assert_not_null(stage14_gate_button)
	if stage14_gate_button == null:
		return

	stage14_gate_button.emit_signal("pressed")
	await _advance_process_frames(4)

	assert_eq(_get_room_path(main_scene), STAGE14_AIR_DASH_GATE_ROOM_PATH)
	assert_false(title_background.visible)
	assert_false(main_menu.visible)
	assert_false(detail_panel.visible)
	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")
	assert_true(bool(snapshot.get("air_dash_unlocked", false)))
	var player := main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_not_null(player)
	var step_label := main_scene.get_node_or_null("HUD/TutorialHUD/PromptPanel/StepLabel") as Label
	assert_not_null(step_label)
	if step_label != null:
		assert_true(step_label.text.begins_with("F14 · "))
	if player != null and player.has_method("is_air_dash_unlocked"):
		assert_true(bool(player.call("is_air_dash_unlocked")))


# 保护真实开始流程：开始后标题背景必须隐藏，否则玩家会只看到菜单背景而看不到游戏。
func test_demo_shell_hides_title_background_after_start() -> void:
	var main_scene := await _spawn_main_scene()
	var demo_shell := main_scene.get_node_or_null("HUD/DemoShell")
	assert_not_null(demo_shell)
	if demo_shell == null:
		return

	var title_background := demo_shell.get_node_or_null("TitleBackground") as TextureRect
	var main_menu := demo_shell.get_node_or_null("MainMenu") as Panel
	assert_not_null(title_background)
	assert_not_null(main_menu)
	if title_background == null or main_menu == null:
		return

	assert_true(title_background.visible)
	assert_true(main_menu.visible)
	main_scene.call("start_demo")
	await _advance_process_frames(2)
	assert_false(title_background.visible)
	assert_false(main_menu.visible)
	assert_eq(_get_room_path(main_scene), "res://scenes/rooms/tutorial_room.tscn")


# 保护跌落恢复：玩家低于房间相机底部后应回到出生点，并显示明确的失败提示。
func test_main_resets_player_and_shows_notice_after_fall_out_of_bounds() -> void:
	var main_scene := await _spawn_main_scene()
	main_scene.call("start_demo")
	await _advance_process_frames(2)
	# 房间生成的 0.2 秒接触重建保护不属于正常跌落路径，先在安全位置显式结束该窗口。
	main_scene.call("_process", 0.25)

	var player := main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_not_null(player)
	if player == null:
		return

	player.global_position = Vector2(-220.0, 420.0)
	await _advance_process_frames(2)

	var reset_player := main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var failure_panel := main_scene.get_node_or_null("HUD/DemoShell/FailurePanel") as Panel
	var failure_label := main_scene.get_node_or_null("HUD/DemoShell/FailurePanel/MarginContainer/VBoxContainer/FailureLabel") as Label
	var failure_continue_button := main_scene.get_node_or_null("HUD/DemoShell/FailurePanel/MarginContainer/VBoxContainer/FailureContinueButton") as Button
	assert_not_null(reset_player)
	assert_not_null(failure_panel)
	assert_not_null(failure_label)
	assert_not_null(failure_continue_button)
	if reset_player == null or failure_panel == null or failure_label == null or failure_continue_button == null:
		return

	assert_lt(reset_player.global_position.y, 200.0)
	assert_true(failure_panel.visible)
	assert_eq(failure_panel.anchor_left, 0.5)
	assert_eq(failure_panel.anchor_top, 0.5)
	assert_eq(failure_panel.anchor_right, 0.5)
	assert_eq(failure_panel.anchor_bottom, 0.5)
	assert_lte(absf((failure_panel.offset_left + failure_panel.offset_right) * 0.5), 1.0)
	assert_gte(failure_panel.offset_right - failure_panel.offset_left, 300.0)
	assert_lte(failure_panel.offset_right - failure_panel.offset_left, 700.0)
	assert_gte(failure_panel.offset_bottom - failure_panel.offset_top, 160.0)
	assert_gte(failure_continue_button.custom_minimum_size.x, 180.0)
	assert_eq(failure_continue_button.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
	assert_string_contains(failure_label.text, "跌落")
	assert_gt(failure_label.get_theme_color("font_color").r, 0.7)


# 暂停和失败操作项必须保持固定几何；焦点只能改光色/描边，不能从方块突然变成长条或越出面板。
func test_pause_and_failure_actions_keep_fixed_geometry_inside_their_panels() -> void:
	var main_scene := await _spawn_main_scene()
	main_scene.call("start_demo")
	await _advance_process_frames(2)
	main_scene.call("pause_demo")
	await _advance_process_frames(2)

	var shell := main_scene.get_node_or_null("HUD/DemoShell")
	var pause_panel := shell.get_node_or_null("PauseMenu") as Panel
	var pause_vbox := shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer") as VBoxContainer
	assert_not_null(pause_panel)
	assert_not_null(pause_vbox)
	if pause_panel == null or pause_vbox == null:
		return
	assert_true(pause_panel.visible)
	_assert_control_is_inside_panel(pause_panel, pause_vbox, "暂停按钮列必须完整位于暂停外框内。")

	var pause_buttons: Array[Button] = [
		shell.get_node("PauseMenu/MarginContainer/VBoxContainer/ResumeButton") as Button,
		shell.get_node("PauseMenu/MarginContainer/VBoxContainer/MapButton") as Button,
		shell.get_node("PauseMenu/MarginContainer/VBoxContainer/TravelButton") as Button,
		shell.get_node("PauseMenu/MarginContainer/VBoxContainer/BuildButton") as Button,
		shell.get_node("PauseMenu/MarginContainer/VBoxContainer/RestartButton") as Button,
	]
	for button: Button in pause_buttons:
		_assert_button_states_keep_same_minimum_geometry(button)
		assert_null(button.icon, "%s 不再使用会挤压文字或漂出按钮的方形图标。" % button.name)

	shell.call("show_failure_notice", "已跌落，回到最近检查点。")
	await _advance_process_frames(1)
	var failure_panel := shell.get_node_or_null("FailurePanel") as Panel
	var failure_vbox := shell.get_node_or_null("FailurePanel/MarginContainer/VBoxContainer") as VBoxContainer
	var failure_button := shell.get_node_or_null("FailurePanel/MarginContainer/VBoxContainer/FailureContinueButton") as Button
	assert_not_null(failure_panel)
	assert_not_null(failure_vbox)
	assert_not_null(failure_button)
	if failure_panel == null or failure_vbox == null or failure_button == null:
		return
	_assert_control_is_inside_panel(failure_panel, failure_vbox, "失败提示与继续按钮必须完整位于失败外框内。")
	_assert_button_states_keep_same_minimum_geometry(failure_button)
	assert_null(failure_button.icon, "失败继续按钮不再使用漂浮方形图标。")


# A 方案要求暂停和失败共用一条 Shader 符光；每个按钮各放一条会造成多焦点与视觉噪音。
func test_pause_and_failure_share_one_flowing_action_focus_band() -> void:
	var main_scene := await _spawn_main_scene()
	main_scene.call("start_demo")
	await _advance_process_frames(2)
	main_scene.call("pause_demo")
	await _advance_process_frames(2)

	var shell := main_scene.get_node_or_null("HUD/DemoShell")
	var band := shell.get_node_or_null("ActionFocusBand") as ColorRect
	var resume_button := shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer/ResumeButton") as Button
	var map_button := shell.get_node_or_null("PauseMenu/MarginContainer/VBoxContainer/MapButton") as Button
	var failure_button := shell.get_node_or_null("FailurePanel/MarginContainer/VBoxContainer/FailureContinueButton") as Button
	assert_not_null(band)
	assert_not_null(resume_button)
	assert_not_null(map_button)
	assert_not_null(failure_button)
	if band == null or resume_button == null or map_button == null or failure_button == null:
		return

	assert_eq(shell.find_children("ActionFocusBand", "ColorRect", true, false).size(), 1)
	assert_true(band.visible)
	assert_eq(band.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	var material := band.material as ShaderMaterial
	assert_not_null(material)
	if material != null:
		assert_not_null(material.shader)
		if material.shader != null:
			assert_eq(material.shader.resource_path, "res://assets/shaders/ui/main_menu_focus_band.gdshader")
	assert_almost_eq(band.get_global_rect().get_center().y, resume_button.get_global_rect().end.y, 2.0)

	map_button.grab_focus()
	await _advance_process_frames(20)
	assert_almost_eq(band.get_global_rect().get_center().y, map_button.get_global_rect().end.y, 2.0)

	shell.call("show_failure_notice", "已跌落，回到最近检查点。")
	await _advance_process_frames(2)
	assert_true(band.visible)
	assert_almost_eq(band.get_global_rect().get_center().y, failure_button.get_global_rect().end.y, 2.0)


# 保护 Stage16 终点房完成反馈：终点房应直接引用 Alpha Demo completion 候选图。
func test_stage16_end_room_references_alpha_demo_completion_art() -> void:
	var room := await _spawn_room(STAGE16_ALPHA_DEMO_END_ROOM_PATH)
	var completion_art := room.get_node_or_null("AlphaDemoCompletionArt") as Sprite2D
	assert_not_null(completion_art)
	if completion_art == null:
		return

	assert_eq(completion_art.get_meta("asset_id", ""), "stage16_alpha_demo_completion_ai01")
	assert_not_null(completion_art.texture)
	if completion_art.texture != null:
		assert_eq(completion_art.texture.resource_path, "res://assets/art/ui/stage16_alpha_demo_completion_ai01.png")
		var completion_width := completion_art.texture.get_width() * completion_art.scale.x
		assert_gte(completion_art.global_position.x - completion_width * 0.5, -4.0)
		assert_lte(completion_art.global_position.x + completion_width * 0.5, 304.0)
		assert_lte(completion_art.scale.x, 0.19, "Stage16 completion art must fit the 640 baseline view.")
		assert_eq(completion_art.scale.x, completion_art.scale.y)
	_assert_sprite_references_asset(
		room,
		"CompletionPanelEchoArt",
		"stage16_completion_panel_ui_ai01",
		STAGE16_COMPLETION_PANEL_UI_ART_PATH
	)
	var completion_message := room.get_node_or_null("CompletionMessageLabel") as Label
	assert_not_null(completion_message)
	if completion_message != null:
		assert_string_contains(completion_message.text, "Alpha Demo")
		assert_gt(completion_message.get_theme_color("font_color").r, 0.8)
		assert_gte(completion_message.offset_right - completion_message.offset_left, 180.0)
		assert_lte(completion_message.offset_top, 90.0)
	assert_null(room.get_node_or_null("ShrineTrialTilesetPreview"))


# 保护 Stage16 符印 relay VFX 资源：relay / purge 房间应引用同一套符印传递候选图。
func test_stage16_relay_and_purge_rooms_reference_talisman_relay_art() -> void:
	var relay_room := await _spawn_room(STAGE16_TALISMAN_RELAY_ROOM_PATH)
	var expected_regions := {
		"TalismanRelayA/RelayArt": Rect2(0, 0, 512, 512),
		"TalismanRelayB/RelayArt": Rect2(512, 0, 512, 512),
		"TalismanRelayC/RelayArt": Rect2(1024, 0, 512, 512),
	}
	for relay_path in expected_regions.keys():
		_assert_sprite_references_asset(
			relay_room,
			relay_path,
			"stage16_talisman_relay_ai01",
			"res://assets/art/vfx/stage16_talisman_relay_ai01.png"
		)
		_assert_sprite_uses_region(relay_room, relay_path, expected_regions[relay_path])
		var relay_base_path := "%s/RelayFocusBaseArt" % relay_path.get_base_dir()
		_assert_sprite_references_asset(
			relay_room,
			relay_base_path,
			"shrine_gate_prop_atlas_ai01",
			SHRINE_RELAY_FOCUS_BASE_TEXTURE_PATH
		)
		var relay_art := relay_room.get_node_or_null(NodePath(relay_path)) as Sprite2D
		var relay_base := relay_room.get_node_or_null(NodePath(relay_base_path)) as Sprite2D
		if relay_art != null:
			assert_gte(relay_art.scale.x, 0.06, "Stage16 relay art must remain readable at runtime distance.")
			assert_lte(relay_art.scale.x, 0.08, "Stage16 relay art must not grow enough to hide the path or gate.")
			assert_eq(relay_art.scale.x, relay_art.scale.y)
		if relay_base != null:
			assert_eq(relay_base.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.seal_ring_idle")
			assert_eq(relay_base.get_meta("asset_binding_note", ""), "formal_demo_relay_focus_prop")
			assert_lte(relay_base.scale.x, 0.2)
			assert_lte(relay_base.scale.y, 0.2)
			assert_gte(relay_base.z_index, 1)
			if relay_art != null:
				assert_gt(relay_art.z_index, relay_base.z_index)
	_assert_sprite_references_asset(
		relay_room,
		"GateBarrier/GateArt",
		"shrine_gate_prop_atlas_ai01",
		SHRINE_GATE_LOCKED_TEXTURE_PATH
	)
	var gate_art := relay_room.get_node_or_null("GateBarrier/GateArt") as Sprite2D
	if gate_art != null:
		assert_eq(gate_art.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.seal_gate_locked")

	var purge_room := await _spawn_room(STAGE16_CORRUPTION_PURGE_ROOM_PATH)
	_assert_sprite_references_asset(
		purge_room,
		"CorruptionPurgeNode/TalismanRelayEchoArt",
		"stage16_talisman_relay_ai01",
		"res://assets/art/vfx/stage16_talisman_relay_ai01.png"
	)
	_assert_sprite_uses_region(
		purge_room,
		"CorruptionPurgeNode/TalismanRelayEchoArt",
		Rect2(512, 512, 512, 512)
	)
	_assert_sprite_references_asset(
		purge_room,
		"CorruptionPurgeNode/PurgeFocusBaseArt",
		"shrine_gate_prop_atlas_ai01",
		SHRINE_PURGE_FOCUS_BASE_TEXTURE_PATH
	)
	var purge_echo := purge_room.get_node_or_null("CorruptionPurgeNode/TalismanRelayEchoArt") as Sprite2D
	var purge_base := purge_room.get_node_or_null("CorruptionPurgeNode/PurgeFocusBaseArt") as Sprite2D
	if purge_base != null:
		assert_eq(purge_base.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.miasma_ward_purged")
		assert_eq(purge_base.get_meta("asset_binding_note", ""), "formal_demo_purge_focus_prop")
		assert_lte(purge_base.scale.x, 0.24)
		assert_lte(purge_base.scale.y, 0.24)
		assert_gte(purge_base.z_index, 1)
		if purge_echo != null:
			assert_gt(purge_echo.z_index, purge_base.z_index)


# 保护 Stage16 妖瘴净化 VFX 资源：purge 房间应直接引用 corruption purge 候选图。
func test_stage16_corruption_purge_room_references_corruption_purge_art() -> void:
	var purge_room := await _spawn_room(STAGE16_CORRUPTION_PURGE_ROOM_PATH)
	var miasma_floor_tint := purge_room.get_node_or_null("CorruptionMiasma") as Polygon2D
	assert_not_null(miasma_floor_tint)
	if miasma_floor_tint != null:
		assert_lte(miasma_floor_tint.color.a, 0.06)
	_assert_sprite_references_asset(
		purge_room,
		"CorruptionMiasma/PurgeArt",
		"stage16_corruption_purge_ai01",
		"res://assets/art/vfx/stage16_corruption_purge_ai01.png"
	)
	_assert_sprite_uses_region(
		purge_room,
		"CorruptionMiasma/PurgeArt",
		Rect2(512, 512, 512, 512)
	)
	assert_null(purge_room.get_node_or_null("ShrineTrialTilesetPreview"))


# 保护 Stage16 腐化雾 author：视觉危险必须有独立 Area 边界，避免后续只剩不可调图片。
func test_stage16_corruption_miasma_declares_hazard_author_area() -> void:
	var purge_room := await _spawn_room(STAGE16_CORRUPTION_PURGE_ROOM_PATH)
	var hazard_area := purge_room.get_node_or_null("CorruptionMiasma/CorruptionMiasmaHazardArea") as Area2D
	assert_not_null(hazard_area)
	if hazard_area == null:
		return

	assert_eq(hazard_area.get_meta("authoring_role", ""), "layout_hazard_area")
	assert_false(hazard_area.monitoring)
	var collision_shape := hazard_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	assert_not_null(collision_shape)
	if collision_shape == null:
		return

	var rectangle_shape := collision_shape.shape as RectangleShape2D
	assert_not_null(rectangle_shape)
	if rectangle_shape == null:
		return
	assert_eq(rectangle_shape.size, Vector2(208, 80))


# 保护 Stage16 第一房封印阈值道具：只保留拆分后的运行态道具，不改变碰撞或门控。
func test_stage16_seal_release_threshold_room_references_threshold_art() -> void:
	var threshold_room := await _spawn_room(STAGE16_SEAL_RELEASE_THRESHOLD_ROOM_PATH)
	_assert_sprite_references_asset(
		threshold_room,
		"SealReleaseNode/SealReleaseThresholdArt",
		"stage16_seal_release_threshold_ai01",
		STAGE16_SEAL_RELEASE_LOCKED_TEXTURE_PATH
	)
	_assert_seal_release_prop_readable(threshold_room, "SealReleaseNode/SealReleaseThresholdArt")
	assert_null(threshold_room.get_node_or_null("SealReleaseNode/ReusableSealPropsPreviewArt"))
	_assert_split_chain_anchor_prop(
		threshold_room,
		"SealReleaseNode/SealChainAnchorLeftArt",
		"shrine_gate_prop_atlas_ai01.chain_anchor_left",
		SHRINE_CHAIN_ANCHOR_LEFT_TEXTURE_PATH
	)
	_assert_split_chain_anchor_prop(
		threshold_room,
		"SealReleaseNode/SealChainAnchorRightArt",
		"shrine_gate_prop_atlas_ai01.chain_anchor_right",
		SHRINE_CHAIN_ANCHOR_RIGHT_TEXTURE_PATH
	)
	assert_null(threshold_room.get_node_or_null("ShrineTrialTilesetPreview"))


# 保护 Stage15 completion 和 Stage16 回溯确认房 visual replacement：补封印道具与神龛 TileSet，不改变门控。
func test_stage15_completion_and_stage16_backtrack_confirmation_reference_visual_stack() -> void:
	var completion_room := await _spawn_room(STAGE15_COMPLETION_ROOM_PATH)
	_assert_sprite_references_asset(
		completion_room,
		"CompletionSeal/SealCompletionArt",
		"stage16_seal_release_threshold_ai01",
		STAGE16_SEAL_RELEASE_ACTIVE_TEXTURE_PATH
	)
	_assert_seal_release_prop_readable(completion_room, "CompletionSeal/SealCompletionArt")
	assert_null(completion_room.get_node_or_null("CompletionSeal/ReusableSealPropsPreviewArt"))
	_assert_split_chain_anchor_prop(
		completion_room,
		"CompletionSeal/SealChainAnchorLeftArt",
		"shrine_gate_prop_atlas_ai01.chain_anchor_left",
		SHRINE_CHAIN_ANCHOR_LEFT_TEXTURE_PATH
	)
	_assert_split_chain_anchor_prop(
		completion_room,
		"CompletionSeal/SealChainAnchorRightArt",
		"shrine_gate_prop_atlas_ai01.chain_anchor_right",
		SHRINE_CHAIN_ANCHOR_RIGHT_TEXTURE_PATH
	)
	assert_null(completion_room.get_node_or_null("ShrineTrialTilesetPreview"))

	var backtrack_room := await _spawn_room(STAGE16_BACKTRACK_CONFIRMATION_ROOM_PATH)
	_assert_sprite_references_asset(
		backtrack_room,
		"BacktrackConfirmationNode/BacktrackConfirmationArt",
		"stage16_seal_release_threshold_ai01",
		STAGE16_SEAL_RELEASE_RELEASED_TEXTURE_PATH
	)
	_assert_seal_release_prop_readable(backtrack_room, "BacktrackConfirmationNode/BacktrackConfirmationArt")
	assert_null(backtrack_room.get_node_or_null("BacktrackConfirmationNode/ReusableSealPropsPreviewArt"))
	_assert_split_chain_anchor_prop(
		backtrack_room,
		"BacktrackConfirmationNode/SealChainAnchorLeftArt",
		"shrine_gate_prop_atlas_ai01.chain_anchor_left",
		SHRINE_CHAIN_ANCHOR_LEFT_TEXTURE_PATH
	)
	_assert_split_chain_anchor_prop(
		backtrack_room,
		"BacktrackConfirmationNode/SealChainAnchorRightArt",
		"shrine_gate_prop_atlas_ai01.chain_anchor_right",
		SHRINE_CHAIN_ANCHOR_RIGHT_TEXTURE_PATH
	)
	assert_null(backtrack_room.get_node_or_null("ShrineTrialTilesetPreview"))


# 保护 HUD 完成态优先级：Alpha Demo 完成后不应继续显示旧 Boss 目标、旧收集行或旧恢复充能行。
func test_stage16_completion_hud_hides_old_boss_collectible_and_recovery_lines() -> void:
	assert_true(ResourceLoader.exists(STAGE16_ALPHA_DEMO_END_ROOM_PATH), "缺少 Stage16 终点房，无法验证 HUD 完成态")
	if not ResourceLoader.exists(STAGE16_ALPHA_DEMO_END_ROOM_PATH):
		return

	var main_scene := await _spawn_main_scene()
	main_scene.call("transition_to_room", STAGE16_ALPHA_DEMO_END_ROOM_PATH, &"stage16_alpha_demo_end_start")
	await _advance_process_frames(4)

	if main_scene.has_method("mark_stage16_alpha_demo_completed"):
		main_scene.call("mark_stage16_alpha_demo_completed")
	await _advance_process_frames(4)

	var progress_label := main_scene.get_node("HUD/TutorialHUD/BattlePanel/ProgressLabel") as Label
	assert_not_null(progress_label)
	assert_string_contains(progress_label.text, "Alpha Demo")
	assert_string_contains(progress_label.text, "已完成")
	assert_eq(progress_label.text.find("主目标：击败封印守卫"), -1)
	assert_eq(progress_label.text.find("收集："), -1)
	assert_eq(progress_label.text.find("恢复充能"), -1)
	assert_eq(progress_label.text.find("恢复：未激活"), -1)


# 保护灰盒主线：测试侧 driver 必须能从生产 Main.tscn 推进到 Stage16 终点。
func test_stage16_graybox_driver_reaches_alpha_demo_end() -> void:
	var result: Dictionary = await Stage16AlphaDemoGrayboxDriver.drive_to_stage16_alpha_demo_end(self)

	assert_true(
		bool(result.get("success", false)),
		"Stage16 driver 失败：%s；最后房间：%s；策略：%s；HUD：%s" % [
			result.get("failure_reason", ""),
			result.get("last_room_path", ""),
			result.get("last_strategy_step", ""),
			result.get("last_progress_label", ""),
		]
	)
	assert_eq(result.get("last_room_path", ""), STAGE16_ALPHA_DEMO_END_ROOM_PATH)


# 保护文档门禁：manifest、QA checklist 和 release notes 必须包含 Stage16 Alpha Demo 关键条目。
func test_stage16_manifest_qa_checklist_and_release_notes_contain_required_entries() -> void:
	var manifest := _read_text_file(ASSET_MANIFEST_PATH)
	var qa_checklist := _read_text_file(QA_CHECKLIST_PATH)
	var release_notes := _read_text_file(RELEASE_NOTES_PATH)

	for term in [
		"stage16_seal_release_threshold",
		"stage16_talisman_relay",
		"stage16_backtrack_confirmation",
		"stage16_corruption_purge",
		"stage16_alpha_demo_completion",
		"stage16_minimal_bgm",
	]:
		assert_string_contains(manifest, term)

	for term in [
		"Main.tscn",
		"Stage16 五房链路",
		"暂停",
		"重开",
		"Godot MCP",
		"release notes",
	]:
		if not qa_checklist.is_empty():
			assert_string_contains(qa_checklist, term)

	for term in [
		"Alpha Demo",
		"Stage16",
		"20-28",
		"验证命令",
		"已知问题",
		"试玩入口",
	]:
		if not release_notes.is_empty():
			assert_string_contains(release_notes, term)


# Main fixture 固定加载生产入口，覆盖真实切房、玩家注入和 HUD 绑定。
func _spawn_main_scene() -> Node2D:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)

	var main_scene := packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await _advance_process_frames(2)
	return main_scene


# 单房间 fixture 用于观察房间自己的 transition payload，不经过 Main 转译。
func _spawn_room(scene_path: String) -> Node2D:
	var packed_scene: PackedScene = load(scene_path) as PackedScene
	assert_not_null(packed_scene, "Missing room scene: %s" % scene_path)

	if packed_scene == null:
		return null

	var room := packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


# 玩家 fixture 提供最小地板，让出口触发和 HUD 绑定从稳定落地状态开始。
func _spawn_player_with_floor(spawn_position: Vector2) -> CharacterBody2D:
	var world := Node2D.new()
	add_child_autofree(world)

	var floor := StaticBody2D.new()
	floor.position = Vector2(0, 160)
	world.add_child(floor)

	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(1024, 32)
	floor_shape.shape = rectangle
	floor.add_child(floor_shape)

	var player_scene: PackedScene = load("res://scenes/player/player_placeholder.tscn") as PackedScene
	assert_not_null(player_scene)

	var player := player_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	world.add_child(player)
	await _advance_physics_frames(16)
	return player


# 物理帧推进用于玩家 fixture 落地。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# process 帧推进用于等待房间触发、HUD 更新和 Main 切房。
func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


# 释放输入前先确认动作存在，避免新机器或单测入口还未由 Main 创建默认输入时报引擎错误。
func _release_action_if_present(action_name: StringName) -> void:
	if InputMap.has_action(action_name):
		Input.action_release(action_name)


# 读取当前 Main 房间路径，用于重开和 driver 断言。
func _get_room_path(main_scene: Node2D) -> String:
	var room := main_scene.get_node_or_null("Room") as Node2D
	return room.scene_file_path if room != null else ""


# 在动态生成的测试选关列表中按文字找按钮，避免测试依赖按钮索引。
func _find_button_by_text(root: Node, button_text: String) -> Button:
	for child: Node in root.get_children():
		var button := child as Button
		if button != null and button.text == button_text:
			return button
		var nested := _find_button_by_text(child, button_text)
		if nested != null:
			return nested

	return null


# 读取文档文本；缺失文件时让测试以明确路径失败。
func _read_text_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "无法读取文件：%s" % path)
	return file.get_as_text() if file != null else ""


# 资产接入断言 helper：保护 Sprite2D 节点、asset_id metadata 和实际资源路径三者一致。
func _assert_sprite_references_asset(parent: Node, node_path: String, asset_id: String, resource_path: String) -> void:
	var sprite := parent.get_node_or_null(NodePath(node_path)) as Sprite2D
	assert_not_null(sprite, "缺少 Sprite2D 资产节点：%s" % node_path)
	if sprite == null:
		return

	assert_eq(sprite.get_meta("asset_id", ""), asset_id)
	assert_not_null(sprite.texture, "Sprite2D 没有纹理：%s" % node_path)
	if sprite.texture != null:
		assert_eq(sprite.texture.resource_path, resource_path)


# 封印链前景装饰只允许使用已拆分 AtlasTexture，不能退回整张 reusable source sheet。
func _assert_split_chain_anchor_prop(parent: Node, node_path: String, runtime_source: String, resource_path: String) -> void:
	_assert_sprite_references_asset(parent, node_path, "shrine_gate_prop_atlas_ai01", resource_path)
	var sprite := parent.get_node_or_null(NodePath(node_path)) as Sprite2D
	if sprite == null:
		return

	assert_true(sprite.visible)
	assert_eq(sprite.get_meta("runtime_source", ""), runtime_source)
	assert_eq(sprite.get_meta("asset_binding_note", ""), "formal_demo_split_foreground_prop")
	assert_gte(sprite.z_index, 1)
	assert_lte(sprite.scale.x, 0.24)
	assert_lte(sprite.scale.y, 0.24)
	assert_gte(sprite.position.y, 36.0)


# 02 官印框只允许底框 NinePatch；官印、链条、官牌和朱砂印必须留在保持比例的独立层。
func _assert_warden_official_ornament_layer(panel: Panel) -> void:
	var ornament_layer := panel.get_node_or_null("OrnamentLayer") as Control
	assert_not_null(ornament_layer, "%s 缺少独立官印装饰层。" % panel.name)
	if ornament_layer == null:
		return
	assert_true(bool(ornament_layer.get_meta("non_stretch_visual_layer", false)))
	assert_eq(String(ornament_layer.get_meta("visual_anchor_contract", "")), "02_warden_seal_chains_tassel")
	var ornaments := ornament_layer.find_children("*", "TextureRect", true, false)
	assert_gte(ornaments.size(), 2)
	for ornament_variant: Variant in ornaments:
		var ornament := ornament_variant as TextureRect
		assert_eq(ornament.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)


# 面板 containment 用全局矩形判断，覆盖 Container 计算出的真实最小尺寸而非场景初始 offset。
func _assert_control_is_inside_panel(panel: Control, control: Control, message: String) -> void:
	assert_true(panel.get_global_rect().encloses(control.get_global_rect()), message)


# 四态允许换颜色和描边，但 content margin / 最小几何必须一致，避免焦点态视觉突然换宽高。
func _assert_button_states_keep_same_minimum_geometry(button: Button) -> void:
	var normal := button.get_theme_stylebox("normal")
	assert_not_null(normal, "%s 缺少 normal 样式。" % button.name)
	if normal == null:
		return
	var expected_minimum := normal.get_minimum_size()
	for state: String in ["hover", "pressed", "focus"]:
		var state_style := button.get_theme_stylebox(state)
		assert_not_null(state_style, "%s 缺少 %s 样式。" % [button.name, state])
		if state_style != null:
			assert_eq(state_style.get_minimum_size(), expected_minimum, "%s 的 %s 态不得改变按钮几何。" % [button.name, state])


# DemoShell 按钮只接入语义匹配的切片图标，避免整张 icon sheet 上屏或错配主菜单语义。
func _assert_button_icon_resource(button: Button, resource_path: String) -> void:
	assert_not_null(button.icon, "按钮缺少运行态图标：%s" % button.name)
	if button.icon == null:
		return

	assert_eq(button.icon.resource_path, resource_path)
	assert_true(button.expand_icon)


# 封印释放三状态在 640 基准镜头下不能小到像噪点，也不能悬在地表上方太远。
func _assert_seal_release_prop_readable(parent: Node, node_path: String) -> void:
	var sprite := parent.get_node_or_null(NodePath(node_path)) as Sprite2D
	assert_not_null(sprite, "缺少封印释放运行态节点：%s" % node_path)
	if sprite == null:
		return

	assert_gte(sprite.scale.x, 0.08, "Stage16 seal release prop must remain readable at runtime distance.")
	assert_lte(sprite.scale.x, 0.095, "Stage16 seal release prop must not cover path or gate.")
	assert_eq(sprite.scale.x, sprite.scale.y)
	assert_gte(sprite.position.y, 0.0)


# VFX sheet 运行时只能显示具体 frame region，避免把整张候选表缩小后直接上屏。
func _assert_sprite_uses_region(parent: Node, node_path: String, expected_region: Rect2) -> void:
	var sprite := parent.get_node_or_null(NodePath(node_path)) as Sprite2D
	assert_not_null(sprite, "缺少 Sprite2D 区域资产节点：%s" % node_path)
	if sprite == null:
		return

	assert_true(sprite.region_enabled, "Sprite2D 未启用 region：%s" % node_path)
	assert_eq(sprite.region_rect, expected_region)
