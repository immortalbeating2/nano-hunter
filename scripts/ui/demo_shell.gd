extends Control

# DemoShell 是 Stage16 Alpha Demo 的最小外壳。
# 它只持有主菜单 / 暂停菜单显示状态，并通过 Main 的公开接口开始或重开试玩。

@onready var main_menu: Panel = $MainMenu
@onready var pause_menu: Panel = $PauseMenu
@onready var completion_panel: Panel = $CompletionPanel
@onready var status_label: Label = $MainMenu/MarginContainer/VBoxContainer/StatusLabel
@onready var start_button: Button = $MainMenu/MarginContainer/VBoxContainer/StartButton
@onready var resume_button: Button = $PauseMenu/MarginContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PauseMenu/MarginContainer/VBoxContainer/RestartButton

# DemoShell 只缓存 Main 引用并读取快照；Stage16 进度状态仍由 Main 负责。
var _main: Node
var _is_pause_menu_open := false


# 初始化最小菜单，并让 UI 在暂停状态下仍可响应按钮。
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_buttons()
	_open_main_menu()


# Esc / pause 输入只切换暂停菜单；主菜单显示时不再叠加暂停层。
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
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
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)


# 显示主菜单并暂停场景模拟，等待玩家明确开始本轮 Demo。
func _open_main_menu() -> void:
	main_menu.visible = true
	pause_menu.visible = false
	_is_pause_menu_open = false
	# 主菜单保持可见覆盖层，但不暂停场景树；这样既保留开始入口，也不破坏既有灰盒 driver 从 Main.tscn 直接推进的自动化。
	get_tree().paused = false
	_refresh_status_text()
	_refresh_completion_panel()


# 开始按钮从教程起点重开一轮试玩，复用 Main.restart_demo 的统一清理语义。
func _on_start_pressed() -> void:
	if _main != null and _main.has_method("restart_demo"):
		_main.call("restart_demo")

	main_menu.visible = false
	pause_menu.visible = false
	_is_pause_menu_open = false
	get_tree().paused = false
	_refresh_completion_panel()


# 暂停菜单只负责暂停显示和继续 / 重开命令，不承担正式设置页职责。
func _open_pause_menu() -> void:
	pause_menu.visible = true
	_is_pause_menu_open = true
	get_tree().paused = true
	_refresh_completion_panel()


# 继续按钮恢复当前运行态，不修改 Main 进度。
func _on_resume_pressed() -> void:
	_resume_demo()


# 重开按钮调用 Main.restart_demo，并回到可操作状态。
func _on_restart_pressed() -> void:
	if _main != null and _main.has_method("restart_demo"):
		_main.call("restart_demo")

	main_menu.visible = false
	pause_menu.visible = false
	_is_pause_menu_open = false
	get_tree().paused = false
	_refresh_completion_panel()


# 从暂停菜单回到试玩；主菜单流程不走这里，避免开始前误恢复模拟。
func _resume_demo() -> void:
	pause_menu.visible = false
	_is_pause_menu_open = false
	get_tree().paused = false
	_refresh_completion_panel()


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
