extends Control

# TutorialHUD 是当前原型期统一的运行时 HUD。
# 它只负责把主流程、房间和玩家暴露出来的稳定快照翻译成文本，
# 不直接驱动房间推进，也不反向写入玩家或主流程状态。

@onready var step_label: Label = $PromptPanel/StepLabel
@onready var prompt_panel: Panel = $PromptPanel
@onready var prompt_label: Label = $PromptPanel/PromptLabel
@onready var battle_panel: Panel = $BattlePanel
@onready var status_label: Label = $BattlePanel/StatusLabel
@onready var health_bar_back: ColorRect = $BattlePanel/HealthBarBack
@onready var health_bar_fill: ColorRect = $BattlePanel/HealthBarFill
@onready var dash_label: Label = $BattlePanel/DashLabel
@onready var dash_bar_back: ColorRect = $BattlePanel/DashBarBack
@onready var dash_bar_fill: ColorRect = $BattlePanel/DashBarFill
@onready var objective_icon: TextureRect = $BattlePanel/ObjectiveIcon
@onready var recovery_charge_icon: TextureRect = $BattlePanel/RecoveryChargeIcon
@onready var recovery_label: Label = $BattlePanel/RecoveryLabel
@onready var recovery_bar_back: ColorRect = $BattlePanel/RecoveryBarBack
@onready var recovery_bar_fill: ColorRect = $BattlePanel/RecoveryBarFill
@onready var recovery_meter_frame_art: TextureRect = $BattlePanel/RecoveryMeterFrameArt
@onready var boss_label: Label = $BattlePanel/BossLabel
@onready var boss_bar_back: ColorRect = $BattlePanel/BossBarBack
@onready var boss_bar_fill: ColorRect = $BattlePanel/BossBarFill
@onready var boss_meter_frame_art: TextureRect = $BattlePanel/BossMeterFrameArt
@onready var progress_label: Label = $BattlePanel/ProgressLabel

const INPUT_MODE_KEYBOARD := "keyboard"
const INPUT_MODE_CONTROLLER := "controller"
const DASH_COOLDOWN_FALLBACK := 0.22
const COLOR_HEALTH_READY := Color(0.886275, 0.286275, 0.337255, 1.0)
const COLOR_HEALTH_LOW := Color(1.0, 0.18, 0.16, 1.0)
const COLOR_DASH_READY := Color(0.224, 0.784, 0.725, 1.0)
const COLOR_DASH_COOLDOWN := Color(0.467, 0.647, 0.698, 1.0)
const COLOR_BAR_LOCKED := Color(0.26, 0.28, 0.30, 0.7)
const COLOR_RECOVERY_CHARGING := Color(0.922, 0.729, 0.306, 1.0)
const COLOR_RECOVERY_READY := Color(0.435, 0.906, 0.576, 1.0)
const BATTLE_PANEL_DEFAULT_HEIGHT := 64.0
const BATTLE_PANEL_RECOVERY_HEIGHT := 82.0
const BATTLE_PANEL_BOSS_HEIGHT := 104.0
const PROMPT_PANEL_FULL_HEIGHT := 48.0
const PROMPT_PANEL_COMPACT_HEIGHT := 26.0
const PROMPT_PANEL_FULL_WIDTH := 316.0
const PROMPT_PANEL_COMPACT_WIDTH := 156.0
const PROMPT_PANEL_RIGHT_OFFSET := 238.0
const PROMPT_PANEL_HORIZONTAL_PADDING := 12.0
const HUD_REFERENCE_VIEWPORT := Vector2(1280.0, 720.0)
const HUD_MAX_SCALE := 2.0
const TUTORIAL_PROMPTS_KEYBOARD := {
	&"move_jump": "移动：A/D 或 ←/→。跳跃：Space / W / ↑。",
	&"dash": "冲刺：K。按住方向穿过低顶门槛。",
	&"attack": "攻击：J。命中训练目标或封印柱打开出口。",
	&"exit": "出口已打开，继续向右离开教程区。",
	&"complete": "教程完成，继续进入实战。",
}
const TUTORIAL_PROMPTS_CONTROLLER := {
	&"move_jump": "移动：左摇杆 / 十字键。跳跃：A / Cross。",
	&"dash": "冲刺：B / Circle 或 RB。按住方向穿过门槛。",
	&"attack": "攻击：X / Square。命中目标或封印柱打开出口。",
	&"exit": "出口已打开，用左摇杆 / 十字键向右离开。",
	&"complete": "教程完成，继续进入实战。",
}

# HUD 只缓存绑定对象并读取公开快照，不拥有任何房间或玩家推进状态。
var _main: Node
var _room: Node
var _player: CharacterBody2D
var _input_mode := INPUT_MODE_KEYBOARD


# 初始化只放默认占位文案，真正内容以后续 bind_main / bind_room / bind_player 为准。
func _ready() -> void:
	resized.connect(_layout_runtime_hud)
	_layout_runtime_hud()
	status_label.text = "生命"
	dash_label.text = "冲刺"
	step_label.text = "教程 1/4 · 移动与跳跃"
	if prompt_label.text.is_empty():
		prompt_label.text = "正在等待教程房间..."
	_sync_prompt_panel_layout()
	_update_health_status()
	_update_dash_status()
	_update_progress_status()


# 运行态 HUD 按真实视口放大整个面板，保留内部 640 基准网格不逐项重排。
func _layout_runtime_hud() -> void:
	var hud_scale := _runtime_hud_scale(get_viewport_rect().size)
	for panel: Control in [battle_panel, prompt_panel]:
		if panel != null:
			panel.scale = Vector2(hud_scale, hud_scale)


# ponytail: 单一比例阈值；如果后续做完整 HUD 皮肤系统，再换成 Theme 尺寸表。
func _runtime_hud_scale(viewport_size: Vector2) -> float:
	return clampf(minf(viewport_size.x / HUD_REFERENCE_VIEWPORT.x, viewport_size.y / HUD_REFERENCE_VIEWPORT.y), 1.0, HUD_MAX_SCALE)


# 逐帧刷新轻量状态文本，兜住信号漏连或房间切换瞬间的 HUD 同步问题。
func _process(_delta: float) -> void:
	# 逐帧刷新轻量文本，保证 dash 冷却、恢复充能和 Boss 生命不依赖信号完整性。
	_update_dash_status()
	_update_progress_status()


# 记录最近输入设备；教程提示词从同一份房间上下文重新翻译，不让键鼠和手柄文案分叉。
func _input(event: InputEvent) -> void:
	var next_mode := _input_mode
	if event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
		next_mode = INPUT_MODE_CONTROLLER
	elif event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.35:
		next_mode = INPUT_MODE_CONTROLLER
	elif event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		next_mode = INPUT_MODE_KEYBOARD

	if next_mode == _input_mode:
		return

	_input_mode = next_mode
	_apply_room_context(_get_room_hud_context())


# HUD 的绑定顺序允许主流程、房间和玩家分别到位，因此每次绑定后都要主动同步一次显示。
func bind_main(main: Node) -> void:
	_main = main
	_update_progress_status()


# 绑定当前房间并重接 HUD 展示信号；换房时旧房间不能继续写提示文案。
func bind_room(room: Node) -> void:
	# 换房时必须断开旧房间信号，避免 queued free 前的旧房间继续覆盖 HUD 文案。
	if _room != null:
		_disconnect_room_signals(_room)

	_room = room

	if _room != null:
		_connect_room_signals(_room)

	_sync_from_sources()


# 绑定当前玩家实例；玩家每次换房重生，所以生命信号和快照来源都要重新指向。
func bind_player(player: CharacterBody2D) -> void:
	# 玩家会在每次换房后重生，因此 HUD 需要重新连接生命信号并改读新的快照来源。
	if _player != null and _player.has_signal("health_changed"):
		var callback := Callable(self, "_on_player_health_changed")
		if _player.is_connected("health_changed", callback):
			_player.disconnect("health_changed", callback)

	_player = player
	if _player != null and _player.has_signal("health_changed"):
		_player.connect("health_changed", Callable(self, "_on_player_health_changed"))

	_sync_from_sources()


# 房间上下文负责教程标题、提示词和成长读值；玩家快照负责生命与 dash 冷却；
# 主流程快照负责 stage11 的 demo 目标与完成反馈。
func _sync_from_sources() -> void:
	_apply_room_context(_get_room_hud_context())
	_update_health_status()
	_update_dash_status()
	_update_progress_status()


# 响应教程房步骤变化，只刷新提示区并保留其他状态由快照层统一维护。
func _on_tutorial_step_changed(step_id: StringName, prompt_text: String) -> void:
	# 教程步骤信号只刷新提示区；战斗状态和进度仍从快照统一读取。
	var room_context := _get_room_hud_context()
	room_context["step_id"] = step_id
	step_label.text = str(room_context.get("step_title", str(step_id)))
	prompt_label.text = _format_prompt_text(str(room_context.get("prompt_text", prompt_text)), _context_step_id(room_context))
	_sync_prompt_panel_layout()
	_update_dash_status()
	_update_progress_status()


# 响应通用房间 HUD 文案变化，服务教程外的挑战房、Boss 房和终点房。
func _on_hud_context_changed(step_title: String, prompt_text: String) -> void:
	# 通用 HUD 上下文信号服务非教程房标题和提示词，同时保留房间自己的 dash 可见性规则。
	var room_context := _get_room_hud_context()
	room_context["step_title"] = step_title
	room_context["prompt_text"] = prompt_text
	_apply_room_context(room_context)
	_update_dash_status()
	_update_progress_status()


# 玩家生命变化时只刷新生命行，不在 HUD 内处理失败或 checkpoint 恢复。
func _on_player_health_changed(_current_health: int, _max_health: int) -> void:
	# 生命信号只触发生命行刷新，不在 HUD 中处理死亡、重生或 checkpoint 逻辑。
	_update_health_status()


# dash 状态显示保持最小规则：未开放 / 等待玩家 / 冷却中 / 就绪。
func _update_dash_status() -> void:
	if dash_label == null or dash_bar_back == null or dash_bar_fill == null:
		return

	var room_context := _get_room_hud_context()
	var has_dash_access := bool(room_context.get("dash_available", true))
	dash_label.text = "冲刺"

	if not has_dash_access:
		dash_bar_fill.color = COLOR_BAR_LOCKED
		_set_bar_fill(dash_bar_fill, dash_bar_back, 0.0)
		return

	var player_status := _get_player_hud_status()
	if player_status.is_empty():
		_set_bar_fill(dash_bar_fill, dash_bar_back, 0.0)
		return

	var cooldown_remaining := float(player_status.get("dash_cooldown_remaining", 0.0))
	var cooldown_total := maxf(float(player_status.get("dash_cooldown", DASH_COOLDOWN_FALLBACK)), 0.01)
	var dash_ready := bool(player_status.get("dash_ready", cooldown_remaining <= 0.01))
	var cooldown_ratio := 1.0 if dash_ready else clampf(1.0 - cooldown_remaining / cooldown_total, 0.0, 1.0)

	dash_label.text = "冲刺" if dash_ready else "冷却"
	dash_bar_fill.color = COLOR_DASH_READY if dash_ready else COLOR_DASH_COOLDOWN
	_set_bar_fill(dash_bar_fill, dash_bar_back, cooldown_ratio)


# 从玩家快照刷新生命显示，缺失玩家时使用原型期默认三格生命。
func _update_health_status() -> void:
	if status_label == null or health_bar_back == null or health_bar_fill == null:
		return

	var player_status := _get_player_hud_status()
	var current_health := int(player_status.get("current_health", 3))
	var max_health := int(player_status.get("max_health", 3))

	status_label.text = "生命"
	health_bar_fill.color = COLOR_HEALTH_LOW if current_health <= 1 else COLOR_HEALTH_READY
	_set_bar_fill(health_bar_fill, health_bar_back, float(maxi(current_health, 0)) / float(maxi(max_health, 1)))


# Demo 进度和 stage10 成长反馈都通过稳定快照组装成最小可读文案，
# HUD 只做翻译与拼接，不反向控制任何房间或主流程状态。
func _update_progress_status() -> void:
	if progress_label == null:
		return

	var lines: Array[String] = []
	var demo_snapshot := _get_main_demo_snapshot()
	var room_context := _get_room_hud_context()
	var player_status := _get_player_hud_status()
	_update_recovery_meter(player_status, _should_show_recovery_meter(room_context))
	_update_boss_meter(room_context)

	if not demo_snapshot.is_empty():
		lines.append(str(demo_snapshot.get("goal_text", "")))
		var goal_hint := str(demo_snapshot.get("goal_hint_text", ""))
		if not goal_hint.is_empty() and not room_context.has("stage15_boss_room"):
			lines.append(goal_hint)

	if bool(demo_snapshot.get("stage16_alpha_demo_completed", false)):
		# Alpha Demo 完成态是 Stage16 的最高优先级反馈；这里直接返回，避免旧 Boss、收集或恢复充能行继续混入。
		var release_text := "已准备" if bool(demo_snapshot.get("stage16_release_notes_ready", false)) else "待补充"
		var qa_text := "已准备" if bool(demo_snapshot.get("stage16_qa_checklist_ready", false)) else "待补充"
		lines.append("Release notes：%s  QA checklist：%s" % [release_text, qa_text])
		progress_label.text = "\n".join(lines)
		return

	if room_context.has("stage15_boss_room"):
		# Boss 房优先显示恢复充能和 Boss 生命，帮助人工复核同时观察容错与读招压力。
		if demo_snapshot.is_empty():
			lines.append(str(room_context.get("stage15_boss_name", "封印守卫")))
	elif _is_stage15_completion_room():
		# 完成房只保留阶段完成反馈，避免父类遗留的收集 / 恢复字段稀释 Boss 击败结果。
		pass
	elif _is_stage15_room():
		pass
	elif room_context.has("stage14_backtrack_reward_count"):
		var air_dash_text := "已获得" if bool(demo_snapshot.get("air_dash_unlocked", false)) else "未获得"
		var reward_count := int(room_context.get("stage14_backtrack_reward_count", demo_snapshot.get("stage14_backtrack_reward_count", 0)))
		lines.append("空中冲刺：%s  回溯收益：%d/3" % [air_dash_text, reward_count])
	elif room_context.has("collectible_count") or room_context.has("recovery_point_activated"):
		var collectible_count := int(room_context.get("collectible_count", 0))
		var recovery_text := "已激活" if bool(room_context.get("recovery_point_activated", false)) else "未激活"
		lines.append("收集：%d  恢复：%s" % [collectible_count, recovery_text])
	elif lines.is_empty():
		lines.append("目标：继续推进 Demo")

	progress_label.text = "\n".join(lines)


# 通过房间资源路径判断是否处于 Stage15，避免依赖某个具体房间基类。
func _is_stage15_room() -> bool:
	# Stage15 普房可能复用旧房间基类并带旧收集字段，因此用资源路径作为阶段判定。
	if _room == null:
		return false

	# 完成房应优先显示阶段完成反馈，不再追加战斗中的恢复充能行。
	if _is_stage15_completion_room():
		return false

	return _room.scene_file_path.begins_with("res://scenes/rooms/stage15_")


# 查询当前是否为 Stage15 完成房，集中隔离完成反馈和战斗中 HUD 行。
func _is_stage15_completion_room() -> bool:
	return _room != null and _room.scene_file_path == "res://scenes/rooms/stage15_completion_room.tscn"


# 连接 HUD 需要的房间展示信号；房间推进信号仍由 Main 统一消费。
func _connect_room_signals(room: Node) -> void:
	# HUD 只连接自己需要的房间展示信号；房间推进信号由 Main 消费。
	if room.has_signal("hud_context_changed"):
		room.connect("hud_context_changed", Callable(self, "_on_hud_context_changed"))

	if room.has_signal("tutorial_step_changed"):
		room.connect("tutorial_step_changed", Callable(self, "_on_tutorial_step_changed"))


# 断开旧房间展示信号，防止换房后旧节点延迟信号覆盖当前 HUD。
func _disconnect_room_signals(room: Node) -> void:
	# 旧房间信号必须安全断开，避免换房后一帧内出现提示文本回跳。
	var hud_callback := Callable(self, "_on_hud_context_changed")
	if room.has_signal("hud_context_changed") and room.is_connected("hud_context_changed", hud_callback):
		room.disconnect("hud_context_changed", hud_callback)

	var tutorial_callback := Callable(self, "_on_tutorial_step_changed")
	if room.has_signal("tutorial_step_changed") and room.is_connected("tutorial_step_changed", tutorial_callback):
		room.disconnect("tutorial_step_changed", tutorial_callback)


# 安全读取房间 HUD 上下文；缺失契约或返回类型错误时回落为空字典。
func _get_room_hud_context() -> Dictionary:
	# 房间 HUD 上下文必须是 Dictionary；缺失或异常时回落为空字典。
	if _room == null or not _room.has_method("get_hud_context"):
		return {}

	var context: Variant = _room.call("get_hud_context")
	return context if context is Dictionary else {}


# 安全读取玩家 HUD 快照；HUD 不直接依赖玩家内部变量名。
func _get_player_hud_status() -> Dictionary:
	# 玩家状态只通过公开快照读取，HUD 不直接访问玩家内部计时器和资源。
	if _player == null or not _player.has_method("get_hud_status_snapshot"):
		return {}

	var status: Variant = _player.call("get_hud_status_snapshot")
	return status if status is Dictionary else {}


# 安全读取 Main demo 快照，用于目标文案、阶段状态和完成反馈。
func _get_main_demo_snapshot() -> Dictionary:
	# Main 快照负责 demo 目标、阶段状态和完成反馈；缺失时 HUD 继续显示房间级信息。
	if _main == null or not _main.has_method("get_demo_progress_snapshot"):
		return {}

	var snapshot: Variant = _main.call("get_demo_progress_snapshot")
	return snapshot if snapshot is Dictionary else {}


# 把房间上下文字段应用到提示区，不碰战斗状态和主流程进度行。
func _apply_room_context(context: Dictionary) -> void:
	# 房间上下文只写提示区文本，进度和战斗状态由专门刷新函数拼接。
	if context.has("step_title"):
		step_label.text = str(context["step_title"])
	if context.has("prompt_text"):
		prompt_label.text = _format_prompt_text(str(context["prompt_text"]), _context_step_id(context))
	_sync_prompt_panel_layout()


# 空正文房间只保留标题条，避免正式截图里出现大块空提示面板。
func _sync_prompt_panel_layout() -> void:
	if prompt_panel == null or prompt_label == null:
		return

	var has_prompt := not prompt_label.text.strip_edges().is_empty()
	prompt_label.visible = has_prompt
	prompt_panel.size.y = PROMPT_PANEL_FULL_HEIGHT if has_prompt else PROMPT_PANEL_COMPACT_HEIGHT
	var panel_width := PROMPT_PANEL_FULL_WIDTH if has_prompt else PROMPT_PANEL_COMPACT_WIDTH
	prompt_panel.offset_left = PROMPT_PANEL_RIGHT_OFFSET - panel_width
	prompt_panel.offset_right = PROMPT_PANEL_RIGHT_OFFSET
	step_label.offset_right = panel_width - PROMPT_PANEL_HORIZONTAL_PADDING
	prompt_label.offset_right = panel_width - PROMPT_PANEL_HORIZONTAL_PADDING


# 教程提示按最近输入设备翻译；非教程房或未知步骤继续显示房间原文。
func _format_prompt_text(raw_text: String, step_id: StringName) -> String:
	var prompts := TUTORIAL_PROMPTS_CONTROLLER if _input_mode == INPUT_MODE_CONTROLLER else TUTORIAL_PROMPTS_KEYBOARD
	return str(prompts.get(step_id, raw_text))


# 房间上下文的 step_id 可能来自 StringName 或字符串，统一收敛后再查提示表。
func _context_step_id(context: Dictionary) -> StringName:
	if not context.has("step_id"):
		return &""

	var step_id: Variant = context["step_id"]
	return step_id if step_id is StringName else StringName(str(step_id))


# 用一个原生 ColorRect 宽度表达资源比例；边框和填充节点保持在同一套固定 HUD 网格里。
func _set_bar_fill(fill: ColorRect, back: ColorRect, ratio: float) -> void:
	if fill == null or back == null:
		return

	fill.size.x = maxf(back.size.x - 2.0, 0.0) * clampf(ratio, 0.0, 1.0)


# Stage15 才展示恢复充能槽，避免早期教程和普通房间被无关资源占满视野。
func _should_show_recovery_meter(room_context: Dictionary) -> bool:
	return room_context.has("stage15_boss_room") or _is_stage15_room()


# 恢复充能改为资源条显示；只有 ready / charge 颜色变化，不再用百分比文字占 HUD 空间。
func _update_recovery_meter(player_status: Dictionary, is_visible: bool) -> void:
	for control: CanvasItem in [recovery_charge_icon, recovery_label, recovery_bar_back, recovery_bar_fill, recovery_meter_frame_art]:
		if control != null:
			control.visible = is_visible

	if not is_visible:
		_set_bar_fill(recovery_bar_fill, recovery_bar_back, 0.0)
		return

	var charge_ratio := float(player_status.get("recovery_charge_ratio", 0.0))
	var charge_ready := bool(player_status.get("recovery_charge_ready", false))
	recovery_bar_fill.color = COLOR_RECOVERY_READY if charge_ready else COLOR_RECOVERY_CHARGING
	_set_bar_fill(recovery_bar_fill, recovery_bar_back, charge_ratio)


# Boss 生命只在 Boss 房显示为血条；目标文案随之下移，避免资源条与任务文本重叠。
func _update_boss_meter(room_context: Dictionary) -> void:
	var has_boss := room_context.has("stage15_boss_room")
	var has_recovery := _should_show_recovery_meter(room_context)
	for control: CanvasItem in [boss_label, boss_bar_back, boss_bar_fill, boss_meter_frame_art]:
		if control != null:
			control.visible = has_boss

	var panel_height := BATTLE_PANEL_BOSS_HEIGHT if has_boss else BATTLE_PANEL_RECOVERY_HEIGHT if has_recovery else BATTLE_PANEL_DEFAULT_HEIGHT
	if battle_panel != null:
		battle_panel.size.y = panel_height

	var progress_y := 82.0 if has_boss else 64.0 if has_recovery else 45.0
	var show_objective_icon := not has_boss and not has_recovery
	var progress_x := 26.0 if show_objective_icon else 11.0
	progress_label.position = Vector2(progress_x, progress_y)
	progress_label.size = Vector2(184.0 - progress_x, panel_height - progress_y - 6.0)
	if objective_icon != null:
		objective_icon.visible = show_objective_icon
		objective_icon.position = Vector2(11.0, progress_y + 3.0)

	if not has_boss:
		_set_bar_fill(boss_bar_fill, boss_bar_back, 0.0)
		return

	var boss_name := str(room_context.get("stage15_boss_name", "封印守卫"))
	var boss_health := int(room_context.get("stage15_boss_health", 0))
	var boss_max_health := int(room_context.get("stage15_boss_max_health", 0))
	boss_label.text = boss_name
	_set_bar_fill(boss_bar_fill, boss_bar_back, float(maxi(boss_health, 0)) / float(maxi(boss_max_health, 1)))
