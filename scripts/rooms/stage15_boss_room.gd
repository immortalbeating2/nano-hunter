extends "res://scripts/rooms/stage13_bio_waste_room_base.gd"

# Stage15BossRoom 把既有房间契约适配成单个精英 Boss 房。
# 它负责监听 Boss 击败、同步 Main 进度快照，并向 HUD 暴露 Boss 状态。

# Main 只用于写入 Stage15 完成快照；Boss 房仍通过标准房间信号推进切房。
var _main: Node
# 本地击败锁防止 Boss defeated 信号和父类敌人清场回调重复触发胜利流程。
var _boss_defeated := false


# 接收 Main 引用，用于 Boss 击败时写入 Stage15 主流程快照。
func bind_main(main: Node) -> void:
	# Main 在每次换房重生玩家后重新注入，房间不主动查找场景树外部节点。
	_main = main


# 汇总 Boss 房 HUD 上下文，在父类字段基础上追加 Boss 生命、状态和击败标记。
func get_hud_context() -> Dictionary:
	# HUD 通过房间上下文读取 Boss 状态，而不是直接寻找 Boss 节点，降低场景结构耦合。
	var context := super.get_hud_context()
	var boss := _get_boss()
	context.merge({
		"stage15_boss_room": true,
		"stage15_boss_name": "封印守卫",
		"stage15_boss_defeated": _boss_defeated,
		"stage15_boss_health": int(boss.call("get_current_health")) if boss != null else 0,
		"stage15_boss_max_health": int(boss.call("get_max_health")) if boss != null else 0,
		"stage15_boss_state": String(boss.call("get_boss_state")) if boss != null else "missing",
	}, true)
	return context


# 初始化 Boss 房，连接 Boss defeated 信号到本房胜利流程。
func _ready() -> void:
	# Boss 仍沿用普通敌人的 defeated 信号，房间在这里把“敌人击败”翻译为阶段完成。
	super._ready()
	var boss := _get_boss()
	if boss != null and boss.has_signal("defeated"):
		var callback := Callable(self, "_on_boss_defeated")
		if not boss.is_connected("defeated", callback):
			boss.connect("defeated", callback)


# 每帧广播 Boss 动态 HUD 信息，再执行父类出口判定。
func _process(delta: float) -> void:
	# Boss 生命和状态是动态 HUD 信息，逐帧广播保证运行态复核能及时读到。
	_emit_hud_context()
	super._process(delta)


# 统一父类敌人清场回调和 Boss defeated 回调，防止出现两套胜利逻辑。
func _on_enemy_defeated() -> void:
	# 父类可能把任意 defeated 子节点视为清场，本房统一收束到 Boss 胜利流程。
	_on_boss_defeated()


# 处理 Boss 胜利：写 Main 快照、开门，并可选切到完成房。
func _on_boss_defeated() -> void:
	# 胜利必须先更新 Main 快照，再发切房信号，避免完成房 HUD 读到旧状态。
	if _boss_defeated:
		return

	_boss_defeated = true
	if _main != null and _main.has_method("mark_stage15_boss_defeated"):
		_main.call("mark_stage15_boss_defeated")

	unlock_gate(cleared_step_id)
	if not next_room_path.is_empty():
		room_transition_requested.emit(next_room_path, next_spawn_id)


# 查找 Boss 节点；节点名是 Boss 房、HUD 和测试之间的最小稳定约定。
func _get_boss() -> Node:
	# Boss 节点名是当前 Boss 房与 HUD / 测试之间的最小稳定约定。
	return get_node_or_null("SealGuardianBoss")
