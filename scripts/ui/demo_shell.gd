extends Control

# DemoShell 是 Stage16 Alpha Demo 的最小外壳。
# 它持有主菜单、暂停菜单和探索地图显示状态，并通过 Main 的公开接口读写试玩流程。

@onready var main_menu: Panel = $MainMenu
@onready var pause_menu: Panel = $PauseMenu
@onready var world_map_panel: Panel = $WorldMapPanel
@onready var detail_panel: Panel = $DetailPanel
@onready var completion_panel: Panel = $CompletionPanel
@onready var failure_panel: Panel = $FailurePanel
@onready var title_background: TextureRect = $TitleBackground
@onready var main_menu_margin_container: MarginContainer = $MainMenu/MarginContainer
@onready var pause_panel_margin_container: MarginContainer = $PauseMenu/MarginContainer
@onready var failure_panel_margin_container: MarginContainer = $FailurePanel/MarginContainer
@onready var main_menu_vbox: VBoxContainer = $MainMenu/MarginContainer/VBoxContainer
@onready var detail_vbox: VBoxContainer = $DetailPanel/MarginContainer/VBoxContainer
@onready var title_label: Label = $MainMenu/MarginContainer/VBoxContainer/TitleLabel
@onready var status_label: Label = $MainMenu/MarginContainer/VBoxContainer/StatusLabel
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
@onready var build_button: Button = $PauseMenu/MarginContainer/VBoxContainer/BuildButton
@onready var restart_button: Button = $PauseMenu/MarginContainer/VBoxContainer/RestartButton
@onready var world_map_view: Control = $WorldMapPanel/WorldMapView
@onready var map_current_room_label: Label = $WorldMapPanel/CurrentRoomLabel
@onready var map_back_button: Button = $WorldMapPanel/MapBackButton
@onready var failure_label: Label = $FailurePanel/MarginContainer/VBoxContainer/FailureLabel
@onready var failure_continue_button: Button = $FailurePanel/MarginContainer/VBoxContainer/FailureContinueButton

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

const WORLD_MAP_ASPECT := 1511.0 / 1041.0
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
	{"label": "支线 Stage10 资源房", "path": "res://scenes/rooms/stage10_zone_branch_room.tscn", "spawn": "stage10_branch_start"},
	{"label": "支线 Stage13 资源房", "path": "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn", "spawn": "stage13_resource_branch_start"},
	{"label": "支线 Stage13 挑战房", "path": "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn", "spawn": "stage13_challenge_branch_start"},
	{"label": "支线 Stage15 挑战房", "path": "res://scenes/rooms/stage15_challenge_branch_room.tscn", "spawn": "stage15_challenge_branch_start", "progress": {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3}},
]


# 初始化最小菜单，并让 UI 在暂停状态下仍可响应按钮。
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_main_menu_buttons = [start_button, continue_button, level_select_button, settings_button, controls_button, quit_button]
	_ensure_level_select_list()
	_ensure_bounty_list()
	resized.connect(_layout_title_menu)
	_layout_title_menu()
	_connect_buttons()
	for button: Button in [resume_button, map_button, build_button, restart_button]:
		_copy_button_skin(button)
	_open_main_menu()


# 标题菜单使用居中锚点与紧凑体量，避免宽屏下漂到左侧或再次覆盖整张标题背景。
func _layout_title_menu() -> void:
	var viewport_size := get_viewport_rect().size
	var panel_width := clampf(viewport_size.x * 0.28, 300.0, 560.0)
	var panel_height := clampf(viewport_size.y * 0.32, 288.0, 430.0)
	var panel_center_y_offset := clampf(viewport_size.y * 0.06, 24.0, 70.0)
	var button_height := clampf(panel_height / 12.0, 28.0, 36.0)
	var title_font_size := int(roundf(clampf(panel_width * 0.047, 17.0, 27.0)))
	var button_font_size := int(roundf(clampf(panel_width * 0.034, 14.0, 19.0)))
	var menu_margin_x := clampf(panel_width * 0.075, 30.0, 44.0)
	var menu_margin_y := clampf(panel_height * 0.075, 22.0, 34.0)
	var button_width := clampf(panel_width - (menu_margin_x * 2.0) - 52.0, 196.0, 420.0)
	var detail_width := minf(panel_width + 40.0, 460.0)
	var detail_height := minf(panel_height, 300.0)
	var pause_width := clampf(viewport_size.x * 0.22, 260.0, 360.0)
	var pause_height := clampf(viewport_size.y * 0.38, 280.0, 340.0)
	var world_map_width := clampf(viewport_size.x * 0.86, 520.0, 1600.0)
	var world_map_height := clampf(viewport_size.y * 0.82, 358.0, 1100.0)
	if world_map_width / world_map_height > WORLD_MAP_ASPECT:
		world_map_width = world_map_height * WORLD_MAP_ASPECT
	else:
		world_map_height = world_map_width / WORLD_MAP_ASPECT
	var failure_width := clampf(viewport_size.x * 0.24, 300.0, 460.0)
	var failure_height := clampf(viewport_size.y * 0.20, 180.0, 260.0)

	main_menu.anchor_left = 0.5
	main_menu.anchor_top = 0.5
	main_menu.anchor_right = 0.5
	main_menu.anchor_bottom = 0.5
	main_menu.offset_left = -panel_width * 0.5
	main_menu.offset_right = panel_width * 0.5
	main_menu.offset_top = panel_center_y_offset - panel_height * 0.5
	main_menu.offset_bottom = panel_center_y_offset + panel_height * 0.5
	if detail_panel != null:
		detail_panel.anchor_left = 0.5
		detail_panel.anchor_top = 0.5
		detail_panel.anchor_right = 0.5
		detail_panel.anchor_bottom = 0.5
		detail_panel.offset_left = -detail_width * 0.5
		detail_panel.offset_right = detail_width * 0.5
		detail_panel.offset_top = panel_center_y_offset - detail_height * 0.5
		detail_panel.offset_bottom = panel_center_y_offset + detail_height * 0.5
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
		failure_panel.offset_top = panel_center_y_offset - failure_height * 0.5
		failure_panel.offset_bottom = panel_center_y_offset + failure_height * 0.5
	if failure_panel_margin_container != null:
		var failure_margin_x := clampf(failure_width * 0.09, 18.0, 32.0)
		var failure_margin_y := clampf(failure_height * 0.14, 18.0, 30.0)
		failure_panel_margin_container.anchor_right = 1.0
		failure_panel_margin_container.anchor_bottom = 1.0
		failure_panel_margin_container.offset_left = failure_margin_x
		failure_panel_margin_container.offset_top = failure_margin_y
		failure_panel_margin_container.offset_right = -failure_margin_x
		failure_panel_margin_container.offset_bottom = -failure_margin_y
	if pause_panel_margin_container != null:
		var pause_margin_x := clampf(pause_width * 0.10, 22.0, 34.0)
		var pause_margin_y := clampf(pause_height * 0.12, 20.0, 30.0)
		pause_panel_margin_container.anchor_right = 1.0
		pause_panel_margin_container.anchor_bottom = 1.0
		pause_panel_margin_container.offset_left = pause_margin_x
		pause_panel_margin_container.offset_top = pause_margin_y
		pause_panel_margin_container.offset_right = -pause_margin_x
		pause_panel_margin_container.offset_bottom = -pause_margin_y
	if main_menu_margin_container != null:
		main_menu_margin_container.anchor_right = 1.0
		main_menu_margin_container.anchor_bottom = 1.0
		main_menu_margin_container.offset_left = menu_margin_x
		main_menu_margin_container.offset_top = menu_margin_y
		main_menu_margin_container.offset_right = -menu_margin_x
		main_menu_margin_container.offset_bottom = -menu_margin_y
	if main_menu_vbox != null:
		main_menu_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		main_menu_vbox.add_theme_constant_override("separation", int(roundf(clampf(panel_height * 0.016, 4.0, 8.0))))

	if title_label != null:
		title_label.add_theme_font_size_override("font_size", title_font_size)
	if status_label != null:
		status_label.add_theme_font_size_override("font_size", max(11, button_font_size - 3))
	if pause_title_label != null:
		pause_title_label.add_theme_font_size_override("font_size", max(14, button_font_size + 1))
	if failure_label != null:
		failure_label.add_theme_font_size_override("font_size", max(12, button_font_size - 2))
	for button: Button in _main_menu_buttons:
		if button == null:
			continue
		button.custom_minimum_size = Vector2(button_width, button_height)
		button.add_theme_font_size_override("font_size", button_font_size)
	if failure_continue_button != null:
		failure_continue_button.custom_minimum_size = Vector2(clampf(failure_width - 120.0, 180.0, 280.0), button_height)
		failure_continue_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		failure_continue_button.add_theme_font_size_override("font_size", button_font_size)
	for button: Button in [resume_button, map_button, build_button, restart_button]:
		if button == null:
			continue
		button.custom_minimum_size = Vector2(clampf(pause_width - 96.0, 176.0, 280.0), button_height)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.add_theme_font_size_override("font_size", button_font_size)
	if _level_select_scroll != null:
		_level_select_scroll.custom_minimum_size = Vector2(0.0, clampf(detail_height * 0.48, 128.0, 176.0))
	if _level_select_list != null:
		_level_select_list.add_theme_constant_override("separation", int(roundf(clampf(button_height * 0.16, 4.0, 6.0))))
		for child: Node in _level_select_list.get_children():
			var button := child as Button
			if button == null:
				continue
			button.custom_minimum_size = Vector2(0.0, maxf(24.0, button_height - 4.0))
			button.add_theme_font_size_override("font_size", max(11, button_font_size - 2))


# Esc / pause 输入在地图内先返回暂停菜单；主菜单显示时不叠加暂停层。
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
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
		else:
			_open_pause_menu()


# Main 在 _ready 中注入自身，DemoShell 不主动搜索场景树，避免形成隐藏依赖。
func bind_main(main: Node) -> void:
	_main = main
	_refresh_status_text()


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
	continue_button.pressed.connect(_open_detail_panel.bind("继续游戏", "当前 Demo 暂无存档。\n请选择开始游戏，从教程起点进入。"))
	level_select_button.pressed.connect(_open_level_select_panel)
	settings_button.pressed.connect(_open_detail_panel.bind("设置", "当前使用默认键鼠配置。\n窗口缩放按 640x360 基准适配，音量设置将在音频包接入后开放。"))
	controls_button.pressed.connect(_on_controls_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	detail_back_button.pressed.connect(_close_detail_panel)
	resume_button.pressed.connect(_on_resume_pressed)
	map_button.pressed.connect(_on_map_pressed)
	build_button.pressed.connect(_on_build_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	map_back_button.pressed.connect(_on_map_back_pressed)
	failure_continue_button.pressed.connect(_on_failure_continue_pressed)


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

	for entry: Dictionary in LEVEL_SELECT_ENTRIES:
		var button := Button.new()
		button.text = str(entry.get("label", "未命名关卡"))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_ALL
		_copy_button_skin(button)
		button.pressed.connect(_on_level_select_entry_pressed.bind(entry))
		_level_select_list.add_child(button)


# 悬赏榜复用详情面板与按钮皮肤，不额外建立一套菜单场景。
func _ensure_bounty_list() -> void:
	if _bounty_list != null or detail_vbox == null:
		return

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
	detail_body_label.custom_minimum_size = Vector2(0.0, 44.0)
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
		button.text = "%s · %s｜%s" % [
			action_label,
			str(entry.get("title", "未命名悬赏")),
			str(entry.get("objective", "")),
		]
		button.disabled = disabled
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_ALL
		_copy_button_skin(button)
		button.pressed.connect(_on_bounty_entry_pressed.bind(StringName(entry.get("id", &""))))
		_bounty_list.add_child(button)


func _on_bounty_entry_pressed(bounty_id: StringName) -> void:
	if _main == null or not _main.has_method("advance_bounty"):
		return
	var snapshot: Variant = _main.call("advance_bounty", bounty_id)
	if snapshot is Dictionary:
		show_bounty_board(snapshot)


# 两槽 Build 复用悬赏榜的滚动选择容器，避免再造第三套详情列表。
func show_build_loadout(snapshot: Dictionary) -> void:
	_ensure_bounty_list()
	_detail_returns_to_game = false
	_detail_returns_to_pause = true
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
	detail_body_label.custom_minimum_size = Vector2(0.0, 44.0)
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
		button.text = "%s · %s｜%s" % [
			action_label,
			str(entry.get("label", "未命名圣物")),
			str(entry.get("effect", "")),
		]
		button.set_meta("build_id", entry.get("id", StringName()))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_ALL
		_copy_button_skin(button)
		button.pressed.connect(_on_build_entry_pressed.bind(StringName(entry.get("id", &""))))
		_bounty_list.add_child(button)


func _on_build_entry_pressed(build_id: StringName) -> void:
	if _main == null or not _main.has_method("toggle_build_equipped"):
		return
	var snapshot: Variant = _main.call("toggle_build_equipped", build_id)
	if snapshot is Dictionary:
		show_build_loadout(snapshot)


# 选关按钮复用主菜单按钮皮肤，只缩小高度；后续正式关卡 UI 再换专用资产。
func _copy_button_skin(button: Button) -> void:
	for state: String in ["normal", "hover", "pressed", "focus"]:
		var stylebox := start_button.get_theme_stylebox(state)
		if stylebox != null:
			button.add_theme_stylebox_override(state, stylebox)
	for color_name: String in ["font_color", "font_hover_color", "font_pressed_color"]:
		button.add_theme_color_override(color_name, start_button.get_theme_color(color_name))
	var normal_style := start_button.get_theme_stylebox("normal")
	if normal_style != null:
		button.add_theme_stylebox_override("disabled", normal_style)
	button.add_theme_color_override("font_disabled_color", start_button.get_theme_color("font_color"))


# 显示主菜单并暂停场景模拟，等待玩家明确开始本轮 Demo。
func _open_main_menu() -> void:
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
	_refresh_status_text()
	_refresh_completion_panel()


# 开始按钮从教程起点重开一轮试玩，复用 Main.restart_demo 的统一清理语义。
func _on_start_pressed() -> void:
	if _main != null and _main.has_method("restart_demo"):
		_main.call("restart_demo")

	title_background.visible = false
	main_menu.visible = false
	detail_panel.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	_is_pause_menu_open = false
	get_tree().paused = false
	_refresh_completion_panel()


# 控制说明复用同一个详情面板；真正按键重绑定留给后续设置系统。
func _on_controls_pressed() -> void:
	_open_detail_panel("控制说明", "移动 A/D 或 方向键\n跳跃 Space / W / ↑\n攻击 J\n冲刺 Shift\n暂停 Esc")


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
	main_menu.visible = false
	detail_panel.visible = true


func _close_detail_panel() -> void:
	if _level_select_scroll != null:
		_level_select_scroll.visible = false
	if _bounty_scroll != null:
		_bounty_scroll.visible = false
	detail_panel.visible = false
	if _detail_returns_to_pause:
		_detail_returns_to_pause = false
		detail_back_button.text = "返回"
		main_menu.visible = false
		pause_menu.visible = true
		_is_pause_menu_open = true
		get_tree().paused = true
		build_button.grab_focus()
		_refresh_build_button()
		return
	if _detail_returns_to_game:
		_detail_returns_to_game = false
		detail_back_button.text = "返回"
		title_background.visible = false
		main_menu.visible = false
		get_tree().paused = false
		return
	main_menu.visible = true
	_refresh_status_text()


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
	title_background.visible = false
	detail_panel.visible = false
	pause_menu.visible = true
	world_map_panel.visible = false
	failure_panel.visible = false
	_is_pause_menu_open = true
	get_tree().paused = true
	_refresh_build_button()
	_refresh_completion_panel()


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

	if world_map_view != null and world_map_view.has_method("set_map_snapshot"):
		world_map_view.call("set_map_snapshot", snapshot)
	if map_current_room_label != null:
		var room_label := "未知房间"
		if world_map_view != null and world_map_view.has_method("get_current_room_label"):
			room_label = str(world_map_view.call("get_current_room_label"))
		map_current_room_label.text = "当前位置：%s  ·  已发现 %d / 38" % [room_label, Array(snapshot.get("visited_room_paths", [])).size()]

	pause_menu.visible = false
	world_map_panel.visible = true
	failure_panel.visible = false
	completion_panel.visible = false
	_is_pause_menu_open = true
	get_tree().paused = true
	map_back_button.grab_focus()


# 从地图回到暂停菜单，不恢复游戏模拟。
func _on_map_back_pressed() -> void:
	world_map_panel.visible = false
	pause_menu.visible = true
	_is_pause_menu_open = true
	get_tree().paused = true
	map_button.grab_focus()
	_refresh_completion_panel()


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

	title_background.visible = false
	main_menu.visible = false
	detail_panel.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	_is_pause_menu_open = false
	get_tree().paused = false
	_refresh_completion_panel()


# 从暂停菜单回到试玩；主菜单流程不走这里，避免开始前误恢复模拟。
func _resume_demo() -> void:
	detail_panel.visible = false
	if _level_select_scroll != null:
		_level_select_scroll.visible = false
	if _bounty_scroll != null:
		_bounty_scroll.visible = false
	pause_menu.visible = false
	world_map_panel.visible = false
	failure_panel.visible = false
	_is_pause_menu_open = false
	_detail_returns_to_game = false
	_detail_returns_to_pause = false
	get_tree().paused = false
	_refresh_completion_panel()


# Main 在战败或跌落重生后调用这里，给玩家明确但不阻断输入的恢复提示。
func show_failure_notice(message: String) -> void:
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
	_refresh_completion_panel()


# 复用主菜单详情面板显示一次性剧情；关闭后回到运行态而不是主菜单。
func show_story_event(title: String, body: String) -> void:
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


func _on_failure_continue_pressed() -> void:
	failure_panel.visible = false


# 主菜单状态文案只读取 Main 快照，帮助人工复核 Stage16 完成态和重开语义。
func _refresh_status_text() -> void:
	if status_label == null:
		return

	if _main == null or not _main.has_method("get_demo_progress_snapshot"):
		status_label.text = "Alpha Demo 候选"
		return

	var snapshot: Variant = _main.call("get_demo_progress_snapshot")
	if not (snapshot is Dictionary):
		status_label.text = "Alpha Demo 候选"
		return

	status_label.text = "已完成" if bool(snapshot.get("stage16_alpha_demo_completed", false)) else "从教程起点开始"
	_refresh_completion_panel_from_snapshot(snapshot)


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
	completion_panel.visible = bool(snapshot.get("stage16_alpha_demo_completed", false))


func _refresh_build_button() -> void:
	if build_button == null:
		return
	if _main == null or not _main.has_method("get_active_build_label"):
		build_button.text = "圣物：尚未调谐"
		build_button.disabled = true
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
