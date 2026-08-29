extends Control

# DemoShell 是 Stage16 Alpha Demo 的最小外壳。
# 它持有主菜单、暂停菜单和探索地图显示状态，并通过 Main 的公开接口读写试玩流程。

@onready var main_menu: Panel = $MainMenu
@onready var pause_menu: Panel = $PauseMenu
@onready var world_map_panel: Panel = $WorldMapPanel
@onready var detail_panel: Panel = $DetailPanel
@onready var detail_scrim: ColorRect = $DetailScrim
@onready var bounty_frame_art: TextureRect = $DetailPanel/BountyFrameArt
@onready var completion_panel: Panel = $CompletionPanel
@onready var failure_panel: Panel = $FailurePanel
@onready var title_background: TextureRect = $TitleBackground
@onready var focus_band: ColorRect = $MainMenu/FocusBand
@onready var action_focus_band: ColorRect = $ActionFocusBand
@onready var main_menu_margin_container: MarginContainer = $MainMenu/MarginContainer
@onready var pause_panel_margin_container: MarginContainer = $PauseMenu/MarginContainer
@onready var failure_panel_margin_container: MarginContainer = $FailurePanel/MarginContainer
@onready var detail_margin_container: MarginContainer = $DetailPanel/MarginContainer
@onready var main_menu_vbox: VBoxContainer = $MainMenu/MarginContainer/VBoxContainer
@onready var pause_vbox: VBoxContainer = $PauseMenu/MarginContainer/VBoxContainer
@onready var detail_vbox: VBoxContainer = $DetailPanel/MarginContainer/VBoxContainer
@onready var title_wordmark: TextureRect = $MainMenu/MarginContainer/VBoxContainer/TitleWordmark
@onready var detail_title_label: Label = $DetailPanel/MarginContainer/VBoxContainer/DetailTitleLabel
@onready var detail_body_label: Label = $DetailPanel/MarginContainer/VBoxContainer/DetailBodyLabel
@onready var detail_back_button: Button = $DetailPanel/MarginContainer/VBoxContainer/DetailBackButton
@onready var pause_title_label: Label = $PauseMenu/MarginContainer/VBoxContainer/TitleLabel
@onready var start_button: Button = $MainMenu/MarginContainer/VBoxContainer/StartButton
@onready var continue_button: Button = $MainMenu/MarginContainer/VBoxContainer/ContinueButton
@onready var level_select_button: Button = $MainMenu/MarginContainer/VBoxContainer/LevelSelectButton
@onready var settings_button: Button = $MainMenu/MarginContainer/VBoxContainer/SettingsButton
@onready var controls_button: Button = $MainMenu/MarginContainer/VBoxContainer/ControlsButton
@onready var quit_button: Button = $MainMenu/MarginContainer/VBoxContainer/QuitButton
@onready var resume_button: Button = $PauseMenu/MarginContainer/VBoxContainer/ResumeButton
@onready var map_button: Button = $PauseMenu/MarginContainer/VBoxContainer/MapButton
@onready var travel_button: Button = $PauseMenu/MarginContainer/VBoxContainer/TravelButton
@onready var build_button: Button = $PauseMenu/MarginContainer/VBoxContainer/BuildButton
@onready var restart_button: Button = $PauseMenu/MarginContainer/VBoxContainer/RestartButton
@onready var world_map_view: Control = $WorldMapPanel/WorldMapView
@onready var map_current_room_label: Label = $WorldMapPanel/CurrentRoomLabel
@onready var map_back_button: Button = $WorldMapPanel/MapBackButton
@onready var failure_label: Label = $FailurePanel/MarginContainer/VBoxContainer/FailureLabel
@onready var failure_continue_button: Button = $FailurePanel/MarginContainer/VBoxContainer/FailureContinueButton

const InputBindingFormatter := preload("res://scripts/ui/input_binding_formatter.gd")

# DemoShell 只缓存 Main 引用并读取快照；Stage16 进度状态仍由 Main 负责。
var _main: Node
var _is_pause_menu_open := false
var _detail_returns_to_game := false
var _detail_returns_to_pause := false
var _main_menu_buttons: Array[Button] = []
var _level_select_scroll: ScrollContainer
var _level_select_list: VBoxContainer
var _bounty_scroll: ScrollContainer
var _bounty_list: VBoxContainer
var _detail_context_icon: TextureRect
var _build_slot_row: HBoxContainer
var _pause_return_focus: Button
var _focus_band_tween: Tween
var _action_focus_band_tween: Tween
var _action_buttons: Array[Button] = []
var _action_focus_sync_pending := false
var _title_flow_active := true
var _transparent_detail_style := StyleBoxEmpty.new()

const WORLD_MAP_ASPECT := 1511.0 / 1041.0
const PAUSE_PANEL_ASPECT := 1.05
const BOUNTY_PANEL_ASPECT := 1306.0 / 1205.0
const FOCUS_BAND_MOVE_DURATION := 0.18
const DETAIL_PARCHMENT_STYLE: StyleBox = preload("res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/000_menu_ninepatch_ui_ai_01_auto_001_c_01.stylebox_texture.tres")
const DETAIL_PARCHMENT_TEXT_COLOR := Color(0.168627, 0.109804, 0.070588, 1.0)
const BOUNTY_TITLE_COLOR := Color(0.94, 0.84, 0.62, 1.0)
const BOUNTY_BODY_COLOR := Color(0.82, 0.88, 0.84, 1.0)
const WAYSTATION_UI_ATLAS: Texture2D = preload("res://assets/art/ui/stage28_waystation_ui_runtime_ai01.png")
const STAGE31_PERSISTENCE_TRAVEL_UI_ATLAS: Texture2D = preload("res://assets/art/ui/stage31_persistence_travel_ui_runtime_ai01.png")
const STAGE30_REWARD_ATLAS: Texture2D = preload("res://assets/art/vfx/atlases/stage30_thunder_absorption_reward_vfx_runtime_ai01.png")
const WAYSTATION_UI_ICON_INDEX := {
	&"waystation_clerk_portrait": 0,
	&"bounty_caster_hunt": 1,
	&"bounty_demon_bone_evidence": 2,
	&"bounty_seal_pulse_cleanup": 3,
	&"build_marsh_relic": 4,
	&"build_warden_sigil": 5,
	&"build_caster_core": 6,
	&"build_guardian_core": 7,
	&"slot_empty": 8,
	&"slot_equipped": 9,
}
const STAGE31_UI_ICON_INDEX := {
	&"continue_load": 0,
	&"new_game": 1,
	&"save_success": 2,
	&"save_error": 3,
	&"waystation_main": 4,
	&"thunder_outpost": 5,
	&"travel_available": 6,
	&"travel_locked": 7,
	&"checkpoint": 8,
	&"backup": 9,
	&"return": 10,
	&"paused_save": 11,
	&"current_waystation": 12,
	&"current_outpost": 13,
	&"save_pending": 14,
	&"valid_save": 15,
}
const LEVEL_SELECT_ENTRIES := [
	{"label": "01 教程起点", "path": "res://scenes/rooms/tutorial_room.tscn", "spawn": "tutorial_start"},
	{"label": "02 战斗试炼", "path": "res://scenes/rooms/combat_trial_room.tscn", "spawn": "combat_entry"},
	{"label": "03 目标试炼", "path": "res://scenes/rooms/goal_trial_room.tscn", "spawn": "goal_entry"},
	{"label": "04 Stage9 区域入口", "path": "res://scenes/rooms/stage9_zone_entry_room.tscn", "spawn": "zone_entry_start"},
	{"label": "05 Stage9 战斗房", "path": "res://scenes/rooms/stage9_zone_combat_room.tscn", "spawn": "zone_combat_start"},
	{"label": "06 Stage9 冲锋房", "path": "res://scenes/rooms/stage9_zone_charger_room.tscn", "spawn": "zone_charger_start"},
	{"label": "07 Stage9 机关房", "path": "res://scenes/rooms/stage9_zone_switch_room.tscn", "spawn": "zone_switch_start"},
	{"label": "08 Stage9 终点房", "path": "res://scenes/rooms/stage9_zone_final_room.tscn", "spawn": "zone_final_start"},
	{"label": "09 Stage10 空战主线", "path": "res://scenes/rooms/stage10_zone_aerial_room.tscn", "spawn": "stage10_aerial_start"},
	{"label": "10 Stage10 挑战房", "path": "res://scenes/rooms/stage10_zone_challenge_room.tscn", "spawn": "stage10_challenge_start"},
	{"label": "11 Stage11 镇妖驿厅", "path": "res://scenes/rooms/stage11_demo_end_room.tscn", "spawn": "stage11_demo_end_start"},
	{"label": "12 Stage13 瘴泽入口", "path": "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn", "spawn": "stage13_entry_start"},
	{"label": "13 Stage13 远程敌房", "path": "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn", "spawn": "stage13_caster_start"},
	{"label": "14 Stage13 瘴气房", "path": "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn", "spawn": "stage13_miasma_start"},
	{"label": "15 Stage13 封印门房", "path": "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn", "spawn": "stage13_gate_start"},
	{"label": "16 Stage13 交叉火力", "path": "res://scenes/rooms/stage13_miasma_marsh_crossfire_room.tscn", "spawn": "stage13_crossfire_start"},
	{"label": "17 Stage13 检查点", "path": "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn", "spawn": "stage13_checkpoint_start"},
	{"label": "18 Stage13 压力房", "path": "res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn", "spawn": "stage13_pressure_start"},
	{"label": "19 Stage13 支路枢纽", "path": "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn", "spawn": "stage13_branch_hub_start"},
	{"label": "20 Stage13 回流房", "path": "res://scenes/rooms/stage13_miasma_marsh_return_room.tscn", "spawn": "stage13_return_start"},
	{"label": "21 Stage13 区域目标", "path": "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn", "spawn": "stage13_goal_start"},
	{"label": "22 Stage14 空冲神龛", "path": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn", "spawn": "stage14_air_dash_shrine_start"},
	{"label": "23 Stage14 空冲门禁", "path": "res://scenes/rooms/stage14_air_dash_gate_room.tscn", "spawn": "stage14_air_dash_gate_start", "progress": {"air_dash_unlocked": true}},
	{"label": "24 Stage14 回溯枢纽", "path": "res://scenes/rooms/stage14_backtrack_hub_room.tscn", "spawn": "stage14_backtrack_hub_start", "progress": {"air_dash_unlocked": true}},
	{"label": "25 Stage14 回环出口", "path": "res://scenes/rooms/stage14_loop_return_room.tscn", "spawn": "stage14_loop_return_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3}},
	{"label": "26 Stage15 封印压力", "path": "res://scenes/rooms/stage15_seal_pressure_room.tscn", "spawn": "stage15_seal_pressure_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3}},
	{"label": "27 Stage15 混合遭遇", "path": "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn", "spawn": "stage15_mixed_gauntlet_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3}},
	{"label": "28 Stage15 Boss", "path": "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn", "spawn": "stage15_boss_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3}},
	{"label": "29 Stage15 完成房", "path": "res://scenes/rooms/stage15_completion_room.tscn", "spawn": "stage15_completion_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3, "stage15_boss_defeated": true}},
	{"label": "30 Stage16 封印阈值", "path": "res://scenes/rooms/stage16_seal_release_threshold_room.tscn", "spawn": "stage16_seal_release_threshold_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3, "stage15_boss_defeated": true}},
	{"label": "31 Stage16 符印中继", "path": "res://scenes/rooms/stage16_talisman_relay_room.tscn", "spawn": "stage16_talisman_relay_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3, "stage15_boss_defeated": true}},
	{"label": "32 Stage16 回溯确认", "path": "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn", "spawn": "stage16_backtrack_confirmation_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3, "stage15_boss_defeated": true}},
	{"label": "33 Stage16 妖瘴净化", "path": "res://scenes/rooms/stage16_corruption_purge_room.tscn", "spawn": "stage16_corruption_purge_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3, "stage15_boss_defeated": true}},
	{"label": "34 Stage16 Alpha 终点", "path": "res://scenes/rooms/stage16_alpha_demo_end_room.tscn", "spawn": "stage16_alpha_demo_end_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3, "stage15_boss_defeated": true}},
	{"label": "35 Stage25 荒原界碑", "path": "res://scenes/rooms/stage25_thunder_waste_entry_room.tscn", "spawn": "stage25_entry_start", "progress": {"wind_seal_unlocked": true, "current_element_id": "wind"}},
	{"label": "36 Stage25 雷雨洼地", "path": "res://scenes/rooms/stage25_thunder_waste_stormfield_room.tscn", "spawn": "stage25_storm_start", "progress": {"wind_seal_unlocked": true, "current_element_id": "wind"}},
	{"label": "37 Stage25 引雷坡道", "path": "res://scenes/rooms/stage25_thunder_waste_slope_room.tscn", "spawn": "stage25_slope_start", "progress": {"wind_seal_unlocked": true, "current_element_id": "wind"}},
	{"label": "38 Stage25 风蚀岔口", "path": "res://scenes/rooms/stage25_thunder_waste_fork_room.tscn", "spawn": "stage25_fork_start", "progress": {"wind_seal_unlocked": true, "current_element_id": "wind"}},
	{"label": "39 Stage25 接地祭柱", "path": "res://scenes/rooms/stage25_thunder_waste_relay_room.tscn", "spawn": "stage25_relay_start", "progress": {"wind_seal_unlocked": true, "current_element_id": "wind"}},
	{"label": "40 Stage25 驿路远眺", "path": "res://scenes/rooms/stage25_thunder_waste_outlook_room.tscn", "spawn": "stage25_outlook_start", "progress": {"wind_seal_unlocked": true, "current_element_id": "wind"}},
	{"label": "DEBUG 北极星全能力巡检", "path": "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn", "spawn": "stage15_boss_start", "debug_only": true, "progress": {"air_dash_unlocked": true, "wind_seal_unlocked": true, "current_element_id": "wind", "current_stance_id": "swift", "stage14_backtrack_reward_count": 3, "exploration_rewards": ["marsh_relic", "warden_sigil", "caster_core", "guardian_core"], "equipped_build_ids": ["caster_core", "guardian_core"], "active_build_id": "caster_core"}},
	{"label": "支线 Stage10 资源房", "path": "res://scenes/rooms/stage10_zone_branch_room.tscn", "spawn": "stage10_branch_start"},
	{"label": "支线 Stage13 资源房", "path": "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn", "spawn": "stage13_resource_branch_start"},
	{"label": "支线 Stage13 挑战房", "path": "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn", "spawn": "stage13_challenge_branch_start"},
	{"label": "支线 Stage15 挑战房", "path": "res://scenes/rooms/stage15_challenge_branch_room.tscn", "spawn": "stage15_challenge_branch_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3}},
]


# 初始化最小菜单，并让 UI 在暂停状态下仍可响应按钮。
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_main_menu_buttons = [start_button, continue_button, level_select_button, settings_button, controls_button, quit_button]
	_action_buttons = [resume_button, map_button, travel_button, build_button, restart_button, failure_continue_button]
	_ensure_level_select_list()
	_ensure_bounty_list()
	detail_panel.visibility_changed.connect(_sync_detail_scrim_visibility)
	resized.connect(_layout_title_menu)
	_layout_title_menu()
	_connect_buttons()
	_pause_return_focus = build_button
	_open_main_menu()
	_sync_detail_scrim_visibility()


# 共享操作焦点只在暂停或失败面板可见时存在；离开两类面板立即收起。
func _process(_delta: float) -> void:
	if action_focus_band.visible and not pause_menu.visible and not failure_panel.visible:
		_hide_action_focus_band()


# C2 主菜单固定在右侧雾区；详情弹窗按视口响应式居中，避免 2K 画面仍显示成小卡片。
func _layout_title_menu() -> void:
	var viewport_size := get_viewport_rect().size
	var title_menu_width := clampf(viewport_size.x * 0.35, 300.0, 900.0)
	var title_menu_height := clampf(viewport_size.y * 0.61, 300.0, 980.0)
	var title_button_font_size := int(roundf(clampf(title_menu_width * 0.056, 17.0, 42.0)))
	var title_button_height := maxf(clampf(title_menu_height * 0.064, 28.0, 62.0), title_button_font_size + 11.0)
	var title_wordmark_height := clampf(title_menu_height * 0.165, 64.0, 140.0)
	var title_separation := clampf(
		(title_menu_height - title_wordmark_height - title_button_height * 6.0) / 6.0,
		6.0,
		50.0
	)
	var title_menu_margin_x := clampf(title_menu_width * 0.04, 12.0, 36.0)
	var title_wordmark_width := clampf(title_menu_width * 0.78, 220.0, 720.0)
	var title_button_width := clampf(title_menu_width * 0.92, 220.0, 720.0)
	var compact_panel_width := clampf(viewport_size.x * 0.28, 300.0, 560.0)
	var compact_panel_height := clampf(viewport_size.y * 0.32, 288.0, 430.0)
	var compact_center_y_offset := clampf(viewport_size.y * 0.06, 24.0, 70.0)
	var compact_button_height := clampf(compact_panel_height / 12.0, 28.0, 36.0)
	var compact_button_font_size := int(roundf(clampf(compact_panel_width * 0.034, 14.0, 19.0)))
	var detail_width := minf(
		clampf(viewport_size.x * 0.42, 360.0, 1120.0),
		maxf(viewport_size.x - 32.0, 0.0)
	)
	var detail_height := minf(
		clampf(viewport_size.y * 0.56, 300.0, 760.0),
		maxf(viewport_size.y - 24.0, 0.0)
	)
	var bounty_detail_active := bounty_frame_art != null and bounty_frame_art.visible
	if bounty_detail_active:
		detail_height = minf(
			clampf(viewport_size.y * 0.64, 480.0, 900.0),
			maxf(viewport_size.y - 24.0, 0.0)
		)
		detail_width = minf(
			clampf(detail_height * BOUNTY_PANEL_ASPECT, 360.0, 980.0),
			maxf(viewport_size.x - 32.0, 0.0)
		)
	var detail_title_font_size := int(roundf(clampf(detail_width * 0.026, 16.0, 30.0)))
	var detail_body_font_size := int(roundf(clampf(detail_width * 0.019, 13.0, 22.0)))
	var detail_button_font_size := int(roundf(clampf(detail_width * 0.018, 14.0, 21.0)))
	var detail_button_height := clampf(detail_height * 0.09, 44.0, 72.0)
	# 02 官印框按生成源比例布局；只在小窗口为可操作性放宽高度占比，避免 2K 实机再次占屏过高。
	var pause_width := clampf(viewport_size.x * 0.26, 272.0, 680.0)
	var pause_height := pause_width / PAUSE_PANEL_ASPECT
	var pause_height_limit_ratio := 0.72 if viewport_size.y < 600.0 else 0.47
	var pause_height_limit := viewport_size.y * pause_height_limit_ratio
	if pause_height > pause_height_limit:
		pause_height = pause_height_limit
		pause_width = pause_height * PAUSE_PANEL_ASPECT
	var pause_button_height := clampf(pause_height * 0.08, 30.0, 46.0)
	var pause_button_font_size := int(roundf(clampf(pause_width * 0.045, 18.0, 30.0)))
	var pause_button_width := clampf(pause_width * 0.72, 176.0, 480.0)
	var world_map_width := clampf(viewport_size.x * 0.86, 520.0, 1600.0)
	var world_map_height := clampf(viewport_size.y * 0.82, 358.0, 1100.0)
	if world_map_width / world_map_height > WORLD_MAP_ASPECT:
		world_map_width = world_map_height * WORLD_MAP_ASPECT
	else:
		world_map_height = world_map_width / WORLD_MAP_ASPECT
	var failure_width := clampf(viewport_size.x * 0.26, 360.0, 680.0)
	var failure_height := clampf(viewport_size.y * 0.22, 220.0, 320.0)

	main_menu.anchor_left = 0.745
	main_menu.anchor_top = 0.515
	main_menu.anchor_right = 0.745
	main_menu.anchor_bottom = 0.515
	main_menu.offset_left = -title_menu_width * 0.5
	main_menu.offset_right = title_menu_width * 0.5
	main_menu.offset_top = -title_menu_height * 0.5
	main_menu.offset_bottom = title_menu_height * 0.5
	if detail_panel != null:
		detail_panel.anchor_left = 0.5
		detail_panel.anchor_top = 0.5
		detail_panel.anchor_right = 0.5
		detail_panel.anchor_bottom = 0.5
		detail_panel.offset_left = -detail_width * 0.5
		detail_panel.offset_right = detail_width * 0.5
		detail_panel.offset_top = compact_center_y_offset - detail_height * 0.5
		detail_panel.offset_bottom = compact_center_y_offset + detail_height * 0.5
	if detail_margin_container != null:
		var detail_margin_x := clampf(detail_width * 0.1, 52.0, 96.0) if bounty_detail_active else 34.0
		var detail_margin_top := clampf(detail_height * 0.12, 72.0, 108.0) if bounty_detail_active else 24.0
		var detail_margin_bottom := clampf(detail_height * 0.20, 112.0, 180.0) if bounty_detail_active else 22.0
		detail_margin_container.offset_left = detail_margin_x
		detail_margin_container.offset_top = detail_margin_top
		detail_margin_container.offset_right = -detail_margin_x
		detail_margin_container.offset_bottom = -detail_margin_bottom
	if pause_menu != null:
		pause_menu.anchor_left = 0.5
		pause_menu.anchor_top = 0.5
		pause_menu.anchor_right = 0.5
		pause_menu.anchor_bottom = 0.5
		pause_menu.offset_left = -pause_width * 0.5
		pause_menu.offset_right = pause_width * 0.5
		pause_menu.offset_top = -pause_height * 0.5
		pause_menu.offset_bottom = pause_height * 0.5
	if world_map_panel != null:
		world_map_panel.anchor_left = 0.5
		world_map_panel.anchor_top = 0.5
		world_map_panel.anchor_right = 0.5
		world_map_panel.anchor_bottom = 0.5
		world_map_panel.offset_left = -world_map_width * 0.5
		world_map_panel.offset_right = world_map_width * 0.5
		world_map_panel.offset_top = -world_map_height * 0.5
		world_map_panel.offset_bottom = world_map_height * 0.5
	if failure_panel != null:
		failure_panel.anchor_left = 0.5
		failure_panel.anchor_top = 0.5
		failure_panel.anchor_right = 0.5
		failure_panel.anchor_bottom = 0.5
		failure_panel.offset_left = -failure_width * 0.5
		failure_panel.offset_right = failure_width * 0.5
		failure_panel.offset_top = compact_center_y_offset - failure_height * 0.5
		failure_panel.offset_bottom = compact_center_y_offset + failure_height * 0.5
	if failure_panel_margin_container != null:
		var failure_margin_x := clampf(failure_width * 0.12, 34.0, 72.0)
		var failure_margin_top := clampf(failure_height * 0.18, 38.0, 58.0)
		var failure_margin_bottom := clampf(failure_height * 0.16, 30.0, 46.0)
		failure_panel_margin_container.anchor_right = 1.0
		failure_panel_margin_container.anchor_bottom = 1.0
		failure_panel_margin_container.offset_left = failure_margin_x
		failure_panel_margin_container.offset_top = failure_margin_top
		failure_panel_margin_container.offset_right = -failure_margin_x
		failure_panel_margin_container.offset_bottom = -failure_margin_bottom
	if pause_panel_margin_container != null:
		var pause_margin_x := clampf(pause_width * 0.10, 34.0, 72.0)
		var pause_margin_top := clampf(pause_height * 0.14, 44.0, 92.0)
		var pause_margin_bottom := clampf(pause_height * 0.07, 22.0, 46.0)
		pause_panel_margin_container.anchor_right = 1.0
		pause_panel_margin_container.anchor_bottom = 1.0
		pause_panel_margin_container.offset_left = pause_margin_x
		pause_panel_margin_container.offset_top = pause_margin_top
		pause_panel_margin_container.offset_right = -pause_margin_x
		pause_panel_margin_container.offset_bottom = -pause_margin_bottom
	if main_menu_margin_container != null:
		main_menu_margin_container.anchor_right = 1.0
		main_menu_margin_container.anchor_bottom = 1.0
		main_menu_margin_container.offset_left = title_menu_margin_x
		main_menu_margin_container.offset_top = 0.0
		main_menu_margin_container.offset_right = -title_menu_margin_x
		main_menu_margin_container.offset_bottom = 0.0
	if main_menu_vbox != null:
		main_menu_vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		main_menu_vbox.add_theme_constant_override("separation", int(roundf(title_separation)))

	if title_wordmark != null:
		title_wordmark.custom_minimum_size = Vector2(title_wordmark_width, title_wordmark_height)
		title_wordmark.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if pause_title_label != null:
		pause_title_label.add_theme_font_size_override("font_size", pause_button_font_size + 4)
	if pause_vbox != null:
		pause_vbox.add_theme_constant_override("separation", int(roundf(clampf(pause_height * 0.02, 8.0, 16.0))))
	if failure_label != null:
		failure_label.add_theme_font_size_override("font_size", max(12, compact_button_font_size - 2))
	for button: Button in _main_menu_buttons:
		if button == null:
			continue
		button.custom_minimum_size = Vector2(title_button_width, title_button_height)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.add_theme_font_size_override("font_size", title_button_font_size)
	call_deferred("_sync_main_menu_focus_band", true)
	call_deferred("_sync_action_focus_band_after_layout")
	if failure_continue_button != null:
		failure_continue_button.custom_minimum_size = Vector2(clampf(failure_width * 0.58, 210.0, 360.0), clampf(failure_height * 0.16, 36.0, 48.0))
		failure_continue_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		failure_continue_button.add_theme_font_size_override("font_size", int(roundf(clampf(failure_width * 0.044, 18.0, 28.0))))
	for button: Button in [resume_button, map_button, travel_button, build_button, restart_button]:
		if button == null:
			continue
		button.custom_minimum_size = Vector2(pause_button_width, pause_button_height)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.add_theme_font_size_override("font_size", pause_button_font_size)
	if _level_select_scroll != null:
		_level_select_scroll.custom_minimum_size = Vector2(0.0, clampf(detail_height * 0.48, 128.0, 176.0))
	if _level_select_list != null:
		_level_select_list.add_theme_constant_override("separation", int(roundf(clampf(compact_button_height * 0.16, 4.0, 6.0))))
		for child: Node in _level_select_list.get_children():
			var button := child as Button
			if button == null:
				continue
			button.custom_minimum_size = Vector2(0.0, maxf(24.0, compact_button_height - 4.0))
			button.add_theme_font_size_override("font_size", max(11, compact_button_font_size - 2))
	if detail_title_label != null:
		detail_title_label.add_theme_font_size_override("font_size", detail_title_font_size)
	if detail_body_label != null:
		detail_body_label.add_theme_font_size_override("font_size", detail_body_font_size)
	if detail_back_button != null:
		detail_back_button.custom_minimum_size = Vector2(clampf(detail_width * 0.46, 220.0, 520.0), detail_button_height)
		detail_back_button.add_theme_font_size_override("font_size", detail_button_font_size)
	if _detail_context_icon != null:
		var context_icon_size := clampf(detail_width * 0.09, 64.0, 96.0)
		_detail_context_icon.custom_minimum_size = Vector2(context_icon_size, context_icon_size * 0.875)
	if _bounty_scroll != null:
		_bounty_scroll.custom_minimum_size = Vector2(
			0.0,
			clampf(detail_height * 0.28, 176.0, 240.0)
			if bounty_detail_active
			else clampf(detail_height * 0.36, 128.0, 280.0)
		)


# Menu / Esc 负责打开暂停；B / ui_cancel 只在已显示界面内返回，避免与游戏中冲刺冲突。
func _unhandled_input(event: InputEvent) -> void:
	var pause_pressed := event.is_action_pressed("pause")
	var cancel_pressed := event.is_action_pressed("ui_cancel")
	if not pause_pressed and not cancel_pressed:
		return

	if world_map_panel.visible:
		_on_map_back_pressed()
		return

	if detail_panel.visible:
		_close_detail_panel()
		return

	if main_menu.visible:
		return

	if _is_pause_menu_open:
		_resume_demo()
	elif pause_pressed:
		_open_pause_menu()


# Main 在 _ready 中注入自身，DemoShell 不主动搜索场景树，避免形成隐藏依赖。
func bind_main(main: Node) -> void:
	_main = main
	refresh_save_state()
	_sync_gameplay_hud_visibility()


# 标题流程包含主菜单、控制说明和选关页；只有真正进入运行态后才允许游戏 HUD 显示。
func _set_title_flow_active(is_active: bool) -> void:
	_title_flow_active = is_active
	_sync_gameplay_hud_visibility()


func _sync_gameplay_hud_visibility() -> void:
	if _main != null and _main.has_method("set_gameplay_hud_visible"):
		_main.call("set_gameplay_hud_visible", not _title_flow_active)


# 公开给 Main 的开始入口；按钮与测试都复用同一条路径。
func start_demo() -> void:
	_on_start_pressed()


# 公开给 Main 的暂停入口；暂停状态和菜单显示仍由 DemoShell 持有。
func pause_demo() -> void:
	if main_menu.visible:
		return

	_open_pause_menu()


# 公开给 Main 的继续入口；不修改任何主流程进度。
func resume_demo() -> void:
	_resume_demo()


# 公开给 Main 的暂停读值；测试不需要知道菜单节点细节。
func is_demo_paused() -> bool:
	return _is_pause_menu_open or get_tree().paused


# 连接按钮事件；按钮只调用本脚本，再由本脚本触达 Main 的最小公开接口。
func _connect_buttons() -> void:
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	level_select_button.pressed.connect(_open_level_select_panel)
	settings_button.pressed.connect(_on_settings_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	detail_back_button.pressed.connect(_close_detail_panel)
	resume_button.pressed.connect(_on_resume_pressed)
	map_button.pressed.connect(_on_map_pressed)
	travel_button.pressed.connect(_on_travel_pressed)
	build_button.pressed.connect(_on_build_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	map_back_button.pressed.connect(_on_map_back_pressed)
	failure_continue_button.pressed.connect(_on_failure_continue_pressed)
	for button: Button in _main_menu_buttons:
		button.focus_entered.connect(_move_focus_band_to.bind(button))
		button.mouse_entered.connect(_focus_main_menu_button.bind(button))
	for button: Button in _action_buttons:
		button.focus_entered.connect(_move_action_focus_band_to.bind(button))
		button.mouse_entered.connect(_focus_action_button.bind(button))


# 鼠标与手柄共用真实 UI 焦点，保证画面始终只有一条当前符光。
func _focus_main_menu_button(button: Button) -> void:
	if not button.disabled:
		button.grab_focus()


# Shader 负责内部流动；这里仅用一个节点平滑追踪目标按钮底边。
func _move_focus_band_to(button: Button, immediate := false) -> void:
	if button == null or button.disabled or not main_menu.visible:
		return
	var menu_rect := main_menu.get_global_rect()
	var button_rect := button.get_global_rect()
	var band_height := clampf(button_rect.size.y * 0.9, 28.0, 58.0)
	var target_position := button_rect.position - menu_rect.position
	target_position.y += button_rect.size.y - band_height * 0.5
	var target_size := Vector2(button_rect.size.x, band_height)
	if _focus_band_tween != null:
		_focus_band_tween.kill()
	if immediate or not focus_band.visible:
		focus_band.position = target_position
		focus_band.size = target_size
		focus_band.visible = true
		return
	focus_band.visible = true
	_focus_band_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_focus_band_tween.tween_property(focus_band, "position", target_position, FOCUS_BAND_MOVE_DURATION)
	_focus_band_tween.tween_property(focus_band, "size", target_size, FOCUS_BAND_MOVE_DURATION)


# 分辨率变化后重新读取容器排版结果，不另存一套易漂移的坐标。
func _sync_main_menu_focus_band(immediate := false) -> void:
	var focus_owner := get_viewport().gui_get_focus_owner() as Button
	if focus_owner not in _main_menu_buttons or focus_owner.disabled:
		focus_owner = start_button
	_move_focus_band_to(focus_owner, immediate)


# 暂停和失败复用同一真实焦点；鼠标悬停也先转换为 Godot UI 焦点。
func _focus_action_button(button: Button) -> void:
	if button != null and not button.disabled and _is_action_surface_visible(button):
		button.grab_focus()


# Shader 内部持续流动，脚本只把唯一 ActionFocusBand 平滑移动到当前操作项底边。
func _move_action_focus_band_to(button: Button, immediate := false) -> void:
	if button == null or button.disabled or not _is_action_surface_visible(button):
		return
	var shell_rect := get_global_rect()
	var button_rect := button.get_global_rect()
	var band_height := clampf(button_rect.size.y * 0.88, 24.0, 52.0)
	var target_position := button_rect.position - shell_rect.position
	target_position.y += button_rect.size.y - band_height * 0.5
	var target_size := Vector2(button_rect.size.x, band_height)
	if _action_focus_band_tween != null:
		_action_focus_band_tween.kill()
	if immediate or not action_focus_band.visible:
		action_focus_band.position = target_position
		action_focus_band.size = target_size
		action_focus_band.visible = true
		return
	action_focus_band.visible = true
	_action_focus_band_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_action_focus_band_tween.tween_property(action_focus_band, "position", target_position, FOCUS_BAND_MOVE_DURATION)
	_action_focus_band_tween.tween_property(action_focus_band, "size", target_size, FOCUS_BAND_MOVE_DURATION)


func _is_action_surface_visible(button: Button) -> bool:
	if button == failure_continue_button:
		return failure_panel.visible
	return button in _action_buttons and pause_menu.visible


func _sync_action_focus_band(immediate := false) -> void:
	if failure_panel.visible:
		_move_action_focus_band_to(failure_continue_button, immediate)
		return
	if not pause_menu.visible:
		_hide_action_focus_band()
		return
	var focus_owner := get_viewport().gui_get_focus_owner() as Button
	if focus_owner not in _action_buttons or focus_owner == failure_continue_button or focus_owner.disabled:
		focus_owner = resume_button
	_move_action_focus_band_to(focus_owner, immediate)


# Container 会在下一帧重新计算长文案和按钮位置；等待一次布局后再锁定最终底边。
func _sync_action_focus_band_after_layout() -> void:
	if _action_focus_sync_pending:
		return
	_action_focus_sync_pending = true
	get_tree().process_frame.connect(_flush_action_focus_band_sync, CONNECT_ONE_SHOT)


func _flush_action_focus_band_sync() -> void:
	_action_focus_sync_pending = false
	_sync_action_focus_band(true)


func _hide_action_focus_band() -> void:
	if _action_focus_band_tween != null:
		_action_focus_band_tween.kill()
	action_focus_band.visible = false


# 运行时生成测试选关列表，避免把 dev-only 房间清单硬塞进场景资源。
func _ensure_level_select_list() -> void:
	if _level_select_list != null or detail_vbox == null:
		return

	_level_select_scroll = ScrollContainer.new()
	_level_select_scroll.name = "LevelSelectScroll"
	_level_select_scroll.visible = false
	_level_select_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_level_select_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_vbox.add_child(_level_select_scroll)
	detail_vbox.move_child(_level_select_scroll, detail_back_button.get_index())

	_level_select_list = VBoxContainer.new()
	_level_select_list.name = "LevelSelectList"
	_level_select_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_level_select_scroll.add_child(_level_select_list)

	for entry: Dictionary in _build_level_select_entries():
		if bool(entry.get("debug_only", false)) and not OS.is_debug_build():
			continue
		var button := Button.new()
		button.text = str(entry.get("label", "未命名关卡"))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_ALL
		_copy_button_skin(button)
		button.pressed.connect(_on_level_select_entry_pressed.bind(entry))
		_level_select_list.add_child(button)


# 正式 F01-F18 始终排在前面；旧房只保留为明确标注的开发测试入口。
func _build_level_select_entries() -> Array[Dictionary]:
	var entries_by_path := {}
	for entry: Dictionary in LEVEL_SELECT_ENTRIES:
		if not bool(entry.get("debug_only", false)):
			entries_by_path[str(entry.get("path", ""))] = entry

	var entries: Array[Dictionary] = []
	var formal_paths := {}
	if world_map_view != null and world_map_view.has_method("get_formal_room_definitions"):
		var definitions: Array = world_map_view.call("get_formal_room_definitions")
		for definition: Dictionary in definitions:
			var room_path := str(definition.get("path", ""))
			if not entries_by_path.has(room_path):
				continue
			var formal_entry: Dictionary = (entries_by_path[room_path] as Dictionary).duplicate(true)
			formal_entry["label"] = "%s · %s" % [definition.get("id", "?"), definition.get("title", "未命名关卡")]
			entries.append(formal_entry)
			formal_paths[room_path] = true

	for entry: Dictionary in LEVEL_SELECT_ENTRIES:
		var room_path := str(entry.get("path", ""))
		if formal_paths.has(room_path) and not bool(entry.get("debug_only", false)):
			continue
		var legacy_entry := entry.duplicate(true)
		if not bool(legacy_entry.get("debug_only", false)):
			legacy_entry["label"] = "开发留存 · %s" % str(legacy_entry.get("label", "未命名关卡"))
		entries.append(legacy_entry)
	return entries


# 悬赏榜复用详情面板与按钮皮肤，不额外建立一套菜单场景。
func _ensure_bounty_list() -> void:
	if _bounty_list != null or detail_vbox == null:
		return

	_detail_context_icon = TextureRect.new()
	_detail_context_icon.name = "WaystationContextIcon"
	_detail_context_icon.visible = false
	_detail_context_icon.custom_minimum_size = Vector2(64.0, 56.0)
	_detail_context_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_detail_context_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_detail_context_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_detail_context_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_vbox.add_child(_detail_context_icon)
	detail_vbox.move_child(_detail_context_icon, detail_back_button.get_index())

	_build_slot_row = HBoxContainer.new()
	_build_slot_row.name = "BuildSlotRow"
	_build_slot_row.visible = false
	_build_slot_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_build_slot_row.add_theme_constant_override("separation", 12)
	detail_vbox.add_child(_build_slot_row)
	detail_vbox.move_child(_build_slot_row, detail_back_button.get_index())

	_bounty_scroll = ScrollContainer.new()
	_bounty_scroll.name = "BountyScroll"
	_bounty_scroll.visible = false
	_bounty_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bounty_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_vbox.add_child(_bounty_scroll)
	detail_vbox.move_child(_bounty_scroll, detail_back_button.get_index())

	_bounty_list = VBoxContainer.new()
	_bounty_list.name = "BountyList"
	_bounty_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bounty_scroll.add_child(_bounty_list)


# 驿厅榜单只渲染 Main 快照；按钮回传固定 id 后再次读取最新状态。
func show_bounty_board(snapshot: Dictionary) -> void:
	_ensure_bounty_list()
	_set_bounty_detail_style(true)
	_detail_returns_to_game = true
	_detail_returns_to_pause = false
	detail_back_button.text = "返回驿厅"
	detail_title_label.text = "镇妖驿站 · 悬赏榜"
	detail_body_label.text = "已接 %d/3 · 完成 %d · 回交 %d" % [
		int(snapshot.get("accepted_count", 0)),
		int(snapshot.get("completed_count", 0)),
		int(snapshot.get("turned_in_count", 0)),
	]
	if bool(snapshot.get("waystation_intel_unlocked", false)):
		detail_body_label.text += "\n雷泽荒原路引已解锁。"
	detail_body_label.custom_minimum_size = Vector2(0.0, clampf(detail_panel.size.y * 0.08, 52.0, 72.0))
	_detail_context_icon.texture = _waystation_ui_texture(&"waystation_clerk_portrait")
	_detail_context_icon.visible = true
	_build_slot_row.visible = false
	if _level_select_scroll != null:
		_level_select_scroll.visible = false
	_bounty_scroll.visible = true
	_rebuild_bounty_list(snapshot)
	title_background.visible = false
	main_menu.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	completion_panel.visible = false
	detail_panel.visible = true
	_is_pause_menu_open = false
	get_tree().paused = true

	var focus_target := detail_back_button
	for child: Node in _bounty_list.get_children():
		var button := child as Button
		if button != null and not button.disabled:
			focus_target = button
			break
	focus_target.grab_focus()


func _rebuild_bounty_list(snapshot: Dictionary) -> void:
	for child: Node in _bounty_list.get_children():
		_bounty_list.remove_child(child)
		child.queue_free()

	for entry: Dictionary in snapshot.get("entries", []):
		var state := StringName(entry.get("state", &"available"))
		var action_label := "接取"
		var disabled := false
		match state:
			&"accepted":
				action_label = "追踪中"
				disabled = true
			&"completed":
				action_label = "回交"
			&"turned_in":
				action_label = "已回交"
				disabled = true

		var button := Button.new()
		button.text = "%s · %s\n%s" % [
			action_label,
			str(entry.get("title", "未命名悬赏")),
			str(entry.get("objective", "")),
		]
		button.disabled = disabled
		button.icon = _waystation_ui_texture(StringName(entry.get("icon_id", &"")))
		button.expand_icon = true
		button.custom_minimum_size.y = clampf(detail_panel.size.y * 0.09, 44.0, 72.0)
		button.tooltip_text = "%s · 奖励：%s" % [entry.get("objective", ""), entry.get("reward", "")]
		button.set_meta("icon_id", entry.get("icon_id", StringName()))
		button.set_meta("state_id", entry.get("state_id", state))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_ALL
		_copy_button_skin(button)
		button.pressed.connect(_on_bounty_entry_pressed.bind(StringName(entry.get("id", &""))))
		_bounty_list.add_child(button)
	_wire_detail_list_focus()


func _on_bounty_entry_pressed(bounty_id: StringName) -> void:
	if _main == null or not _main.has_method("advance_bounty"):
		return
	var snapshot: Variant = _main.call("advance_bounty", bounty_id)
	if snapshot is Dictionary:
		show_bounty_board(snapshot)


# 两槽 Build 复用悬赏榜的滚动选择容器，避免再造第三套详情列表。
func show_build_loadout(snapshot: Dictionary) -> void:
	_ensure_bounty_list()
	_set_bounty_detail_style(false)
	_detail_returns_to_game = false
	_detail_returns_to_pause = true
	_pause_return_focus = build_button
	detail_back_button.text = "返回暂停"
	detail_title_label.text = "圣物调谐 · 两槽 Build"
	detail_body_label.text = "已取得 %d · 槽位 %d/%d" % [
		int(snapshot.get("available_count", 0)),
		int(snapshot.get("equipped_count", 0)),
		int(snapshot.get("slot_limit", 2)),
	]
	var status_message := str(snapshot.get("status_message", ""))
	if not status_message.is_empty():
		detail_body_label.text += "\n%s" % status_message
	detail_body_label.custom_minimum_size = Vector2(0.0, clampf(detail_panel.size.y * 0.08, 52.0, 72.0))
	_detail_context_icon.visible = false
	_rebuild_build_slots(snapshot)
	_build_slot_row.visible = true
	if _level_select_scroll != null:
		_level_select_scroll.visible = false
	_bounty_scroll.visible = true
	_rebuild_build_list(snapshot)
	title_background.visible = false
	main_menu.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	completion_panel.visible = false
	detail_panel.visible = true
	_is_pause_menu_open = true
	get_tree().paused = true

	var focus_target := detail_back_button
	for child: Node in _bounty_list.get_children():
		var button := child as Button
		if button != null:
			focus_target = button
			break
	focus_target.grab_focus()


func _rebuild_build_list(snapshot: Dictionary) -> void:
	for child: Node in _bounty_list.get_children():
		_bounty_list.remove_child(child)
		child.queue_free()

	for entry: Dictionary in snapshot.get("entries", []):
		var equipped := bool(entry.get("equipped", false))
		var action_label := "卸下 槽%d" % int(entry.get("slot", 0)) if equipped else "装备"
		var button := Button.new()
		button.text = "%s · %s\n%s" % [
			action_label,
			str(entry.get("label", "未命名圣物")),
			str(entry.get("effect", "")),
		]
		button.set_meta("build_id", entry.get("id", StringName()))
		button.set_meta("icon_id", entry.get("icon_id", StringName()))
		button.set_meta("state_id", entry.get("state_id", &"available"))
		button.icon = _waystation_ui_texture(StringName(entry.get("icon_id", &"")))
		button.expand_icon = true
		button.custom_minimum_size.y = clampf(detail_panel.size.y * 0.09, 44.0, 72.0)
		button.tooltip_text = "%s · 来源：%s" % [entry.get("effect", ""), entry.get("source", "")]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_ALL
		_copy_button_skin(button)
		button.pressed.connect(_on_build_entry_pressed.bind(StringName(entry.get("id", &""))))
		_bounty_list.add_child(button)
	_wire_detail_list_focus()


# 动态榜单显式串起上下焦点；否则 ScrollContainer 会让手柄从首项直接跳到返回按钮。
func _wire_detail_list_focus() -> void:
	var buttons: Array[Button] = []
	for child: Node in _bounty_list.get_children():
		var button := child as Button
		if button != null and not button.disabled:
			buttons.append(button)
	if buttons.is_empty():
		detail_back_button.focus_neighbor_top = NodePath()
		detail_back_button.focus_neighbor_bottom = NodePath()
		return
	for index in range(buttons.size()):
		var button := buttons[index]
		var previous: Control = buttons[index - 1] if index > 0 else detail_back_button
		var next: Control = buttons[index + 1] if index + 1 < buttons.size() else detail_back_button
		button.focus_neighbor_top = button.get_path_to(previous)
		button.focus_neighbor_bottom = button.get_path_to(next)
	detail_back_button.focus_neighbor_top = detail_back_button.get_path_to(buttons[-1])
	detail_back_button.focus_neighbor_bottom = detail_back_button.get_path_to(buttons[0])


func _rebuild_build_slots(snapshot: Dictionary) -> void:
	for child: Node in _build_slot_row.get_children():
		_build_slot_row.remove_child(child)
		child.queue_free()
	for slot: Dictionary in snapshot.get("slots", []):
		var equipped := StringName(slot.get("state_id", &"empty")) == &"equipped"
		var frame := TextureRect.new()
		frame.custom_minimum_size = Vector2(52.0, 52.0)
		frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		frame.texture = _waystation_ui_texture(&"slot_equipped" if equipped else &"slot_empty")
		frame.tooltip_text = "槽位 %d · %s" % [int(slot.get("slot", 0)), "已装备" if equipped else "空槽"]
		frame.set_meta("slot", slot.get("slot", 0))
		frame.set_meta("state_id", slot.get("state_id", &"empty"))
		if equipped:
			var icon := TextureRect.new()
			icon.position = Vector2(12.0, 12.0)
			icon.size = Vector2(28.0, 28.0)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.texture = _waystation_ui_texture(StringName(slot.get("icon_id", &"")))
			frame.add_child(icon)
		_build_slot_row.add_child(frame)


func _waystation_ui_texture(icon_id: StringName) -> AtlasTexture:
	if icon_id == &"build_thunder_beast_core":
		var reward_texture := AtlasTexture.new()
		reward_texture.atlas = STAGE30_REWARD_ATLAS
		reward_texture.region = Rect2(0, 256, 256, 256)
		return reward_texture
	var index := int(WAYSTATION_UI_ICON_INDEX.get(icon_id, 8))
	var texture := AtlasTexture.new()
	texture.atlas = WAYSTATION_UI_ATLAS
	texture.region = Rect2((index % 4) * 160, floori(index / 4.0) * 160, 160, 160)
	return texture


func _stage31_ui_texture(icon_id: StringName) -> AtlasTexture:
	var index := int(STAGE31_UI_ICON_INDEX.get(icon_id, 14))
	var texture := AtlasTexture.new()
	texture.atlas = STAGE31_PERSISTENCE_TRAVEL_UI_ATLAS
	texture.region = Rect2((index % 4) * 160, floori(index / 4.0) * 160, 160, 160)
	return texture


func _on_build_entry_pressed(build_id: StringName) -> void:
	if _main == null or not _main.has_method("toggle_build_equipped"):
		return
	var snapshot: Variant = _main.call("toggle_build_equipped", build_id)
	if snapshot is Dictionary:
		show_build_loadout(snapshot)


# 选关、详情与暂停按钮复用既有面板按钮皮肤，避免继承 C2 主菜单的无框样式。
func _copy_button_skin(button: Button) -> void:
	var skin_source := detail_back_button
	for state: String in ["normal", "hover", "pressed", "focus"]:
		var stylebox := skin_source.get_theme_stylebox(state)
		if stylebox != null:
			button.add_theme_stylebox_override(state, stylebox)
	for color_name: String in ["font_color", "font_hover_color", "font_pressed_color"]:
		button.add_theme_color_override(color_name, skin_source.get_theme_color(color_name))
	button.add_theme_font_size_override("font_size", max(14, skin_source.get_theme_font_size("font_size")))
	button.add_theme_constant_override(
		"icon_max_width",
		int(roundf(clampf(button.custom_minimum_size.y - 12.0, 32.0, 60.0)))
	)
	var normal_style := skin_source.get_theme_stylebox("normal")
	if normal_style != null:
		button.add_theme_stylebox_override("disabled", normal_style)
	button.add_theme_color_override("font_disabled_color", skin_source.get_theme_color("font_color"))


# 详情弹窗显隐统一驱动暗幕，避免高细节驿站场景穿透正文阅读区。
func _sync_detail_scrim_visibility() -> void:
	if detail_scrim != null and detail_panel != null:
		detail_scrim.visible = detail_panel.visible


# 显示主菜单并暂停场景模拟，等待玩家明确开始本轮 Demo。
func _open_main_menu() -> void:
	_set_title_flow_active(true)
	title_background.visible = true
	main_menu.visible = true
	detail_panel.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	_is_pause_menu_open = false
	_detail_returns_to_game = false
	_detail_returns_to_pause = false
	detail_back_button.text = "返回"
	# 主菜单保持可见覆盖层，但不暂停场景树；这样既保留开始入口，也不破坏既有灰盒 driver 从 Main.tscn 直接推进的自动化。
	get_tree().paused = false
	refresh_save_state()
	_refresh_completion_panel()
	start_button.grab_focus()
	call_deferred("_sync_main_menu_focus_band", true)


# 开始按钮从教程起点建立正式会话；旧 Main 仍回退到统一重开入口。
func _on_start_pressed() -> void:
	if _main != null and _main.has_method("start_new_game"):
		_main.call("start_new_game")
	elif _main != null and _main.has_method("restart_demo"):
		_main.call("restart_demo")
	_set_title_flow_active(false)

	title_background.visible = false
	main_menu.visible = false
	detail_panel.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	_is_pause_menu_open = false
	get_tree().paused = false
	_refresh_completion_panel()


func _on_continue_pressed() -> void:
	if _main == null or not _main.has_method("continue_saved_game"):
		_open_detail_panel("继续游戏", "当前 Main 未提供本地存档入口。")
		return
	var result: Variant = _main.call("continue_saved_game")
	if not (result is Dictionary) or not bool(result.get("ok", false)):
		var message := str(result.get("message", "没有可继续的有效存档。")) if result is Dictionary else "没有可继续的有效存档。"
		_open_detail_panel("继续游戏", message)
		return
	_set_title_flow_active(false)
	title_background.visible = false
	main_menu.visible = false
	detail_panel.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	_is_pause_menu_open = false
	get_tree().paused = false
	_refresh_completion_panel()


# 控制说明保留完整 action 表，但显示文本始终从当前 InputMap 生成。
func _on_controls_pressed() -> void:
	_open_detail_panel(
		"控制说明",
		"左移：%s\n右移：%s\n跳跃：%s\n下穿平台：按住 %s，并按 %s\n攻击：%s\n冲刺：%s\n恢复：%s\n元素切换：%s\n姿态切换：%s\n暂停：%s"
		% [
			_action_binding_pair(&"move_left"),
			_action_binding_pair(&"move_right"),
			_action_binding_pair(&"jump"),
			_action_binding_pair(&"ui_down"),
			_action_binding_pair(&"jump"),
			_action_binding_pair(&"attack"),
			_action_binding_pair(&"dash"),
			_action_binding_pair(&"recover"),
			_action_binding_pair(&"element_switch"),
			_action_binding_pair(&"stance_switch"),
			_action_binding_pair(&"pause"),
		]
	)


# Settings 与 Controls 共用 formatter，保证任一真实重绑定在两个入口同步可见。
func _on_settings_pressed() -> void:
	var reduced_motion := bool(ProjectSettings.get_setting("accessibility/reduced_motion", false))
	_open_detail_panel(
		"设置",
		"元素切换：%s\n姿态切换：%s\n降低动态效果：%s\n窗口缩放按 640x360 基准适配，音量设置将在音频包接入后开放。"
		% [
			_action_binding_pair(&"element_switch"),
			_action_binding_pair(&"stance_switch"),
			"开启" if reduced_motion else "关闭",
		]
	)


func _action_binding_pair(action: StringName) -> String:
	return "%s · %s" % [
		InputBindingFormatter.action_label(action, InputBindingFormatter.DEVICE_KEYBOARD),
		InputBindingFormatter.action_label(action, InputBindingFormatter.DEVICE_CONTROLLER),
	]


func _open_level_select_panel() -> void:
	_open_detail_panel("选择关卡", "测试入口：点击后从对应房间启动。", true)


func _open_detail_panel(title: String, body: String, show_level_select := false) -> void:
	_detail_returns_to_game = false
	_detail_returns_to_pause = false
	detail_back_button.text = "返回"
	detail_title_label.text = title
	detail_body_label.text = body
	detail_body_label.custom_minimum_size = Vector2(0.0, 36.0 if show_level_select else 124.0)
	if _level_select_scroll != null:
		_level_select_scroll.visible = show_level_select
	if _bounty_scroll != null:
		_bounty_scroll.visible = false
	_hide_waystation_detail_art()
	main_menu.visible = false
	detail_panel.visible = true
	detail_back_button.grab_focus()


func _close_detail_panel() -> void:
	if _level_select_scroll != null:
		_level_select_scroll.visible = false
	if _bounty_scroll != null:
		_bounty_scroll.visible = false
	_hide_waystation_detail_art()
	detail_panel.visible = false
	if _detail_returns_to_pause:
		_detail_returns_to_pause = false
		detail_back_button.text = "返回"
		main_menu.visible = false
		pause_menu.visible = true
		_is_pause_menu_open = true
		get_tree().paused = true
		if _pause_return_focus != null and not _pause_return_focus.disabled:
			_pause_return_focus.grab_focus()
		else:
			resume_button.grab_focus()
		_refresh_build_button()
		_refresh_travel_button()
		return
	if _detail_returns_to_game:
		_detail_returns_to_game = false
		detail_back_button.text = "返回"
		title_background.visible = false
		main_menu.visible = false
		get_tree().paused = false
		return
	main_menu.visible = true
	refresh_save_state()
	start_button.grab_focus()


func _on_level_select_entry_pressed(entry: Dictionary) -> void:
	if _main == null or not _main.has_method("start_demo_at_room"):
		detail_body_label.text = "当前 Main 未暴露测试选关入口。"
		return

	var room_path := str(entry.get("path", ""))
	var spawn_id := StringName(str(entry.get("spawn", "")))
	var progress: Dictionary = entry.get("progress", {})
	var started := bool(_main.call("start_demo_at_room", room_path, spawn_id, progress))
	if not started:
		detail_body_label.text = "无法加载关卡：%s" % room_path
		return
	_set_title_flow_active(false)

	title_background.visible = false
	main_menu.visible = false
	detail_panel.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	_is_pause_menu_open = false
	_detail_returns_to_game = false
	get_tree().paused = false
	_refresh_completion_panel()


func _on_quit_pressed() -> void:
	get_tree().quit()


# 暂停菜单只负责暂停显示和继续 / 重开命令，不承担正式设置页职责。
func _open_pause_menu() -> void:
	_set_title_flow_active(false)
	title_background.visible = false
	detail_panel.visible = false
	pause_menu.visible = true
	world_map_panel.visible = false
	failure_panel.visible = false
	_is_pause_menu_open = true
	get_tree().paused = true
	_refresh_build_button()
	_refresh_travel_button()
	_refresh_completion_panel()
	resume_button.grab_focus()
	call_deferred("_sync_action_focus_band_after_layout")


# 继续按钮恢复当前运行态，不修改 Main 进度。
func _on_resume_pressed() -> void:
	_resume_demo()


# 地图入口只读取 Main 的探索快照，并保持场景树暂停。
func _on_map_pressed() -> void:
	if _main == null or not _main.has_method("get_world_map_snapshot"):
		return

	var snapshot: Variant = _main.call("get_world_map_snapshot")
	if not (snapshot is Dictionary):
		return

	if world_map_view != null:
		if world_map_view.has_method("set_room_scope"):
			world_map_view.call("set_room_scope", &"formal")
		if world_map_view.has_method("set_map_snapshot"):
			world_map_view.call("set_map_snapshot", snapshot)
	if map_current_room_label != null:
		var room_label := "未知房间"
		var room_count := 0
		if world_map_view != null and world_map_view.has_method("get_current_room_label"):
			room_label = str(world_map_view.call("get_current_room_label"))
		if world_map_view != null and world_map_view.has_method("get_room_count"):
			room_count = int(world_map_view.call("get_room_count"))
		var visited_count := Array(snapshot.get("visited_room_paths", [])).size()
		if world_map_view != null and world_map_view.has_method("get_visited_room_count"):
			visited_count = int(world_map_view.call("get_visited_room_count"))
		map_current_room_label.text = "当前位置：%s  ·  已发现 %d / %d" % [
			room_label,
			visited_count,
			room_count,
		]

	pause_menu.visible = false
	world_map_panel.visible = true
	failure_panel.visible = false
	completion_panel.visible = false
	_is_pause_menu_open = true
	get_tree().paused = true
	_hide_action_focus_band()
	map_back_button.grab_focus()


# 从地图回到暂停菜单，不恢复游戏模拟。
func _on_map_back_pressed() -> void:
	world_map_panel.visible = false
	pause_menu.visible = true
	_is_pause_menu_open = true
	get_tree().paused = true
	map_button.grab_focus()
	call_deferred("_sync_action_focus_band_after_layout")
	_refresh_completion_panel()


# 双点传送复用详情面板；Main 决定发现、起点和保存门控，UI 只呈现结果。
func _on_travel_pressed() -> void:
	if _main == null or not _main.has_method("get_waystation_travel_snapshot"):
		return
	var snapshot: Variant = _main.call("get_waystation_travel_snapshot")
	if snapshot is Dictionary:
		show_waystation_travel(snapshot)


func show_waystation_travel(snapshot: Dictionary) -> void:
	_ensure_bounty_list()
	_set_bounty_detail_style(false)
	_detail_returns_to_game = false
	_detail_returns_to_pause = true
	_pause_return_focus = travel_button
	detail_back_button.text = "返回暂停"
	detail_title_label.text = "镇妖驿站 · 双点传送"
	var current_label := "非驿站区域"
	for entry: Dictionary in snapshot.get("entries", []):
		if bool(entry.get("current", false)):
			current_label = str(entry.get("label", "未知驿站"))
			break
	detail_body_label.text = "当前位置：%s · 已发现 %d/2" % [
		current_label,
		int(snapshot.get("discovered_count", 0)),
	]
	var status_message := str(snapshot.get("status_message", ""))
	if not status_message.is_empty():
		detail_body_label.text += "\n%s" % status_message
	detail_body_label.custom_minimum_size = Vector2(0.0, clampf(detail_panel.size.y * 0.08, 52.0, 72.0))
	var current_id := StringName(snapshot.get("current_travel_point_id", StringName()))
	_detail_context_icon.texture = _stage31_ui_texture(
		&"current_waystation" if current_id == &"waystation_main" else &"current_outpost"
	)
	_detail_context_icon.visible = current_id != StringName()
	_build_slot_row.visible = false
	if _level_select_scroll != null:
		_level_select_scroll.visible = false
	_bounty_scroll.visible = true
	_rebuild_travel_list(snapshot)
	title_background.visible = false
	main_menu.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	completion_panel.visible = false
	detail_panel.visible = true
	_is_pause_menu_open = true
	get_tree().paused = true

	var focus_target := detail_back_button
	for child: Node in _bounty_list.get_children():
		var button := child as Button
		if button != null and not button.disabled:
			focus_target = button
			break
	focus_target.grab_focus()
	await get_tree().process_frame
	if is_instance_valid(focus_target):
		_bounty_scroll.ensure_control_visible(focus_target)


func _rebuild_travel_list(snapshot: Dictionary) -> void:
	for child: Node in _bounty_list.get_children():
		_bounty_list.remove_child(child)
		child.queue_free()
	for entry: Dictionary in snapshot.get("entries", []):
		var state_id := StringName(entry.get("state_id", &"locked"))
		var travel_id := StringName(entry.get("id", StringName()))
		var button := Button.new()
		button.disabled = state_id != &"available"
		var action_label := "传送"
		if state_id == &"current":
			action_label = "当前位置"
		elif state_id == &"locked":
			action_label = "尚未发现"
		button.text = "%s · %s" % [action_label, str(entry.get("label", "未知驿站"))]
		var icon_id := StringName(entry.get("icon_id", &"travel_locked"))
		if state_id == &"locked":
			icon_id = &"travel_locked"
		elif state_id == &"current":
			icon_id = &"current_waystation" if travel_id == &"waystation_main" else &"current_outpost"
		button.icon = _stage31_ui_texture(icon_id)
		button.expand_icon = true
		button.custom_minimum_size.y = clampf(detail_panel.size.y * 0.09, 44.0, 72.0)
		button.tooltip_text = "目标未发现" if state_id == &"locked" else str(entry.get("room_path", ""))
		button.set_meta("travel_id", travel_id)
		button.set_meta("state_id", state_id)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_NONE if button.disabled else Control.FOCUS_ALL
		_copy_button_skin(button)
		button.pressed.connect(_on_travel_entry_pressed.bind(travel_id))
		_bounty_list.add_child(button)
	_wire_detail_list_focus()


func _on_travel_entry_pressed(travel_id: StringName) -> void:
	if _main == null or not _main.has_method("request_waystation_travel"):
		return
	var result: Variant = _main.call("request_waystation_travel", travel_id)
	if not (result is Dictionary):
		return
	if bool(result.get("ok", false)):
		_resume_demo()
		return
	show_waystation_travel(result)


# 保留旧调谐焦点循环，再打开复用详情面板的两槽选择列表。
func _on_build_pressed() -> void:
	if _main != null and _main.has_method("cycle_active_build"):
		_main.call("cycle_active_build")
	if _main != null and _main.has_method("open_build_loadout"):
		_main.call("open_build_loadout")
	_refresh_build_button()


# 重开按钮调用 Main.restart_demo，并回到可操作状态。
func _on_restart_pressed() -> void:
	if _main != null and _main.has_method("restart_demo"):
		_main.call("restart_demo")
	_set_title_flow_active(false)

	title_background.visible = false
	main_menu.visible = false
	detail_panel.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	_hide_action_focus_band()
	_is_pause_menu_open = false
	get_tree().paused = false
	_refresh_completion_panel()


# 从暂停菜单回到试玩；主菜单流程不走这里，避免开始前误恢复模拟。
func _resume_demo() -> void:
	_set_title_flow_active(false)
	detail_panel.visible = false
	if _level_select_scroll != null:
		_level_select_scroll.visible = false
	if _bounty_scroll != null:
		_bounty_scroll.visible = false
	_hide_waystation_detail_art()
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	_hide_action_focus_band()
	_is_pause_menu_open = false
	_detail_returns_to_game = false
	_detail_returns_to_pause = false
	get_tree().paused = false
	_refresh_completion_panel()


# Main 在战败或跌落重生后调用这里，给玩家明确但不阻断输入的恢复提示。
func show_failure_notice(message: String) -> void:
	_set_title_flow_active(false)
	title_background.visible = false
	main_menu.visible = false
	detail_panel.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = true
	_is_pause_menu_open = false
	get_tree().paused = false
	if failure_label != null:
		failure_label.text = message
	if failure_continue_button != null:
		failure_continue_button.grab_focus()
		call_deferred("_sync_action_focus_band_after_layout")
	_refresh_completion_panel()


# 复用主菜单详情面板显示一次性剧情；关闭后回到运行态而不是主菜单。
func show_story_event(title: String, body: String) -> void:
	_set_title_flow_active(false)
	_detail_returns_to_game = true
	_detail_returns_to_pause = false
	detail_back_button.text = "继续"
	detail_title_label.text = title
	detail_body_label.text = body
	detail_body_label.custom_minimum_size = Vector2(0.0, 164.0)
	if _level_select_scroll != null:
		_level_select_scroll.visible = false
	if _bounty_scroll != null:
		_bounty_scroll.visible = false
	_hide_waystation_detail_art()
	title_background.visible = false
	main_menu.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	completion_panel.visible = false
	detail_panel.visible = true
	_is_pause_menu_open = false
	get_tree().paused = true
	detail_back_button.grab_focus()


func _hide_waystation_detail_art() -> void:
	_set_bounty_detail_style(false)
	if _detail_context_icon != null:
		_detail_context_icon.visible = false
	if _build_slot_row != null:
		_build_slot_row.visible = false


# 悬赏榜独占新官印框；其余共享详情页继续使用旧纸本容器，避免蓝图未冻结时扩大改动面。
func _set_bounty_detail_style(active: bool) -> void:
	if bounty_frame_art.visible == active:
		return
	bounty_frame_art.visible = active
	detail_panel.add_theme_stylebox_override("panel", _transparent_detail_style if active else DETAIL_PARCHMENT_STYLE)
	detail_title_label.add_theme_color_override("font_color", BOUNTY_TITLE_COLOR if active else DETAIL_PARCHMENT_TEXT_COLOR)
	detail_body_label.add_theme_color_override("font_color", BOUNTY_BODY_COLOR if active else DETAIL_PARCHMENT_TEXT_COLOR)
	_layout_title_menu()


func _on_failure_continue_pressed() -> void:
	failure_panel.visible = false
	_hide_action_focus_band()


# Main 在保存结果变化后调用此入口；Continue 只对有效主档或有效备份开放。
func refresh_save_state() -> void:
	if continue_button == null:
		return
	var save_status := {}
	if _main != null and _main.has_method("get_save_status_snapshot"):
		var candidate: Variant = _main.call("get_save_status_snapshot")
		if candidate is Dictionary:
			save_status = candidate
	var valid := bool(save_status.get("valid", false))
	continue_button.disabled = not valid
	continue_button.focus_mode = Control.FOCUS_ALL if valid else Control.FOCUS_NONE
	continue_button.text = "继续游戏"
	if valid and bool(save_status.get("from_backup", false)):
		continue_button.text = "继续游戏 · 备份"
	elif not valid and (bool(save_status.get("corrupted_primary", false)) or bool(save_status.get("corrupted_backup", false))):
		continue_button.text = "继续游戏 · 存档损坏"
	_refresh_completion_panel()


# 完成态面板只根据 Main 快照显示，不参与流程状态写入。
func _refresh_completion_panel() -> void:
	if completion_panel == null:
		return

	if _main == null or not _main.has_method("get_demo_progress_snapshot"):
		completion_panel.visible = false
		return

	var snapshot: Variant = _main.call("get_demo_progress_snapshot")
	if snapshot is Dictionary:
		_refresh_completion_panel_from_snapshot(snapshot)
	else:
		completion_panel.visible = false


# 使用同一份快照刷新完成态 UI，避免状态文案和完成面板分叉。
func _refresh_completion_panel_from_snapshot(snapshot: Dictionary) -> void:
	if completion_panel == null:
		return
	completion_panel.visible = (
		bool(snapshot.get("stage16_alpha_demo_completed", false))
		and not main_menu.visible
		and not pause_menu.visible
		and not detail_panel.visible
		and not world_map_panel.visible
	)


func _refresh_build_button() -> void:
	if build_button == null:
		return
	if _main == null or not _main.has_method("get_active_build_label"):
		build_button.text = "圣物：尚未调谐"
		build_button.disabled = true
		build_button.focus_mode = Control.FOCUS_NONE
		return

	var build_label := str(_main.call("get_active_build_label"))
	var available_count := int(_main.call("get_available_build_count")) if _main.has_method("get_available_build_count") else 0
	var equipped_count := (
		Array(_main.call("get_equipped_build_ids")).size()
		if _main.has_method("get_equipped_build_ids")
		else (1 if not build_label.contains("尚未") else 0)
	)
	build_button.text = "圣物：%s · %d/2" % [build_label, equipped_count]
	build_button.disabled = available_count == 0
	build_button.focus_mode = Control.FOCUS_NONE if build_button.disabled else Control.FOCUS_ALL


func _refresh_travel_button() -> void:
	if travel_button == null:
		return
	if _main == null or not _main.has_method("get_waystation_travel_snapshot"):
		travel_button.text = "驿站传送：不可用"
		travel_button.disabled = true
		travel_button.focus_mode = Control.FOCUS_NONE
		return
	var snapshot: Variant = _main.call("get_waystation_travel_snapshot")
	if not (snapshot is Dictionary):
		travel_button.disabled = true
		travel_button.focus_mode = Control.FOCUS_NONE
		return
	var current_id := StringName(snapshot.get("current_travel_point_id", StringName()))
	travel_button.disabled = current_id == StringName()
	travel_button.focus_mode = Control.FOCUS_NONE if travel_button.disabled else Control.FOCUS_ALL
	travel_button.text = "驿站传送 · %d/2" % int(snapshot.get("discovered_count", 0)) if not travel_button.disabled else "驿站传送：仅限驿站"
