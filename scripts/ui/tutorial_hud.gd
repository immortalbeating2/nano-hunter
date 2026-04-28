extends Control

# TutorialHUD 是当前原型期统一的运行时 HUD。
# 它只负责把主流程、房间和玩家暴露出来的稳定快照翻译成文本，
# 不直接驱动房间推进，也不反向写入玩家或主流程状态。

@onready var step_label: Label = $PromptPanel/StepLabel
@onready var prompt_label: Label = $PromptPanel/PromptLabel
@onready var status_label: Label = $BattlePanel/StatusLabel
@onready var dash_label: Label = $BattlePanel/DashLabel
@onready var progress_label: Label = $BattlePanel/ProgressLabel

# HUD 只缓存绑定对象并读取公开快照，不拥有任何房间或玩家推进状态。
var _main: Node
var _room: Node
var _player: CharacterBody2D


# 初始化只放默认占位文案，真正内容以后续 bind_main / bind_room / bind_player 为准。
func _ready() -> void:
	status_label.text = "生命：■■■"
	step_label.text = "教程 1/4 · 移动与跳跃"
	if prompt_label.text.is_empty():
		prompt_label.text = "正在等待教程房间..."
	_update_dash_status()
	_update_progress_status()


# 逐帧刷新轻量状态文本，兜住信号漏连或房间切换瞬间的 HUD 同步问题。
func _process(_delta: float) -> void:
	# 逐帧刷新轻量文本，保证 dash 冷却、恢复充能和 Boss 生命不依赖信号完整性。
	_update_dash_status()
	_update_progress_status()


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
	step_label.text = str(room_context.get("step_title", str(step_id)))
	prompt_label.text = str(room_context.get("prompt_text", prompt_text))
	_update_dash_status()
	_update_progress_status()


# 响应通用房间 HUD 文案变化，服务教程外的挑战房、Boss 房和终点房。
func _on_hud_context_changed(step_title: String, prompt_text: String) -> void:
	# 通用 HUD 上下文信号服务非教程房标题和提示词，同时保留房间自己的 dash 可见性规则。
	_apply_room_context({
		"step_title": step_title,
		"prompt_text": prompt_text,
		"dash_available": _get_room_hud_context().get("dash_available", true),
	})
	_update_dash_status()
	_update_progress_status()


# 玩家生命变化时只刷新生命行，不在 HUD 内处理失败或 checkpoint 恢复。
func _on_player_health_changed(_current_health: int, _max_health: int) -> void:
	# 生命信号只触发生命行刷新，不在 HUD 中处理死亡、重生或 checkpoint 逻辑。
	_update_health_status()


# dash 状态显示保持最小规则：未开放 / 等待玩家 / 冷却中 / 就绪。
func _update_dash_status() -> void:
	if dash_label == null:
		return

	var room_context := _get_room_hud_context()
	var has_dash_access := bool(room_context.get("dash_available", true))

	if not has_dash_access:
		dash_label.text = "冲刺：未开放"
		return

	var player_status := _get_player_hud_status()
	if player_status.is_empty():
		dash_label.text = "冲刺：等待玩家"
		return

	var cooldown_remaining := float(player_status.get("dash_cooldown_remaining", 0.0))
	dash_label.text = "冲刺：冷却中" if cooldown_remaining > 0.01 else "冲刺：就绪"


# 从玩家快照刷新生命显示，缺失玩家时使用原型期默认三格生命。
func _update_health_status() -> void:
	if status_label == null:
		return

	var player_status := _get_player_hud_status()
	var current_health := int(player_status.get("current_health", 3))
	var max_health := int(player_status.get("max_health", 3))

	status_label.text = "生命：%s" % _build_health_icons(current_health, max_health)


# Demo 进度和 stage10 成长反馈都通过稳定快照组装成最小可读文案，
# HUD 只做翻译与拼接，不反向控制任何房间或主流程状态。
func _update_progress_status() -> void:
	if progress_label == null:
		return

	var lines: Array[String] = []
	var demo_snapshot := _get_main_demo_snapshot()
	if not demo_snapshot.is_empty():
		lines.append(str(demo_snapshot.get("goal_text", "")))
		var goal_hint := str(demo_snapshot.get("goal_hint_text", ""))
		if not goal_hint.is_empty():
			lines.append(goal_hint)

	var room_context := _get_room_hud_context()
	var player_status := _get_player_hud_status()
	if room_context.has("stage15_boss_room"):
		# Boss 房优先显示恢复充能和 Boss 生命，帮助人工复核同时观察容错与读招压力。
		_append_recovery_charge_line(lines, player_status)
		var boss_name := str(room_context.get("stage15_boss_name", "封印守卫"))
		var boss_health := int(room_context.get("stage15_boss_health", 0))
		var boss_max_health := int(room_context.get("stage15_boss_max_health", 0))
		var boss_state := str(room_context.get("stage15_boss_state", "idle"))
		lines.append("%s：%d/%d  状态：%s" % [boss_name, boss_health, boss_max_health, boss_state])
	elif _is_stage15_completion_room():
		# 完成房只保留阶段完成反馈，避免父类遗留的收集 / 恢复字段稀释 Boss 击败结果。
		pass
	elif _is_stage15_room():
		_append_recovery_charge_line(lines, player_status)
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


# 将 Stage15 恢复充能追加到进度文本中，普通房与 Boss 房共用同一显示规则。
func _append_recovery_charge_line(lines: Array[String], player_status: Dictionary) -> void:
	# 恢复充能只显示百分比和满充状态，不暴露玩家内部累计浮点细节。
	var charge_ratio := float(player_status.get("recovery_charge_ratio", 0.0))
	var charge_text := "已满" if bool(player_status.get("recovery_charge_ready", false)) else "%d%%" % int(round(charge_ratio * 100.0))
	lines.append("恢复充能：%s" % charge_text)


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


# 构建原型期生命文本图标，正式 HUD 资产接入前保持测试稳定。
func _build_health_icons(current_health: int, max_health: int) -> String:
	# 生命图标构建保持纯函数，便于后续替换为正式 HUD 资产前仍可稳定测试。
	var filled := ""
	var empty := ""
	for _i in range(max(current_health, 0)):
		filled += "■"
	for _i in range(max(max_health - current_health, 0)):
		empty += "□"

	return filled + empty


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
		prompt_label.text = str(context["prompt_text"])
