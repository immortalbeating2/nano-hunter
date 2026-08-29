extends "res://scripts/rooms/stage13_miasma_marsh_room_base.gd"

# Stage15BossRoom 把既有房间契约适配成单个精英 Boss 房。
# 它负责监听 Boss 击败、同步 Main 进度快照，并向 HUD 暴露 Boss 状态。

# 本地击败锁防止 Boss defeated 信号和父类敌人清场回调重复触发胜利流程。
var _boss_defeated := false
var _boss_encounter_started := false

@export var boss_entry_requires_down_input := false


# 公开 Boss 入口读招缓冲距离；按场景出生点与 Boss 位置计算，避免另写一份坐标真相。
func get_boss_read_buffer_distance() -> float:
	var boss := _get_boss() as Node2D
	var start_value: Variant = spawn_positions.get(&"stage15_boss_start", Vector2.ZERO)
	var start := Vector2.ZERO
	if start_value is Vector2:
		start = start_value
	return absf(boss.position.x - start.x) if boss != null else 0.0


# 估算失败提示、房间重建与重新接敌的上限，用于验证不会重跑 F16；不作为战斗计时器。
func get_retry_return_estimate_seconds() -> float:
	return minf(25.0, 1.5 + get_boss_read_buffer_distance() / 180.0)


func is_boss_encounter_completed() -> bool:
	return _boss_defeated


func is_boss_encounter_started() -> bool:
	return _boss_encounter_started


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
	_boss_encounter_started = not boss_entry_requires_down_input
	_set_boss_active(_boss_encounter_started)
	_apply_boss_entry_state()


# 已击败后的回访直接恢复完成态，隐藏战斗实体并保持右侧战后出口开放。
func bind_main(main: Node) -> void:
	super.bind_main(main)
	if _main != null and _main.has_method("is_stage15_boss_defeated") and bool(_main.call("is_stage15_boss_defeated")):
		_boss_defeated = true
		_boss_encounter_started = true
		_apply_boss_entry_state()
		_disable_completed_boss()
		unlock_gate(cleared_step_id)


# 每帧广播 Boss 动态 HUD 信息，再执行父类出口判定。
func _process(delta: float) -> void:
	# Boss 生命和状态是动态 HUD 信息，逐帧广播保证运行态复核能及时读到。
	_try_start_boss_encounter()
	_emit_hud_context()
	super._process(delta)


func _try_start_boss_encounter() -> void:
	if _boss_encounter_started or _player == null:
		return
	var entry_zone := get_node_or_null("BossEntryZone") as Node2D
	if entry_zone == null or _player.global_position.distance_to(entry_zone.global_position) > 56.0:
		return
	if boss_entry_requires_down_input and not _is_down_confirmation_pressed():
		return
	_boss_encounter_started = true
	_set_boss_active(true)
	_apply_boss_entry_state()
	_emit_hud_context()


func _set_boss_active(active: bool) -> void:
	var boss := _get_boss()
	if boss == null:
		return
	boss.set_process(active)
	boss.set_physics_process(active)


func _apply_boss_entry_state() -> void:
	var barrier_shape := get_node_or_null("BossEntryBarrier/CollisionShape2D") as CollisionShape2D
	if barrier_shape != null:
		barrier_shape.disabled = _boss_encounter_started
	var barrier_art := get_node_or_null("BossEntryBarrier/BarrierArt") as CanvasItem
	if barrier_art != null:
		barrier_art.modulate = Color(0.45, 1.0, 0.9, 0.35) if _boss_encounter_started else Color.WHITE


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


func _disable_completed_boss() -> void:
	var boss := _get_boss()
	if boss == null:
		return
	if boss is CanvasItem:
		(boss as CanvasItem).visible = false
	boss.set_process(false)
	boss.set_physics_process(false)
	for child: Node in boss.find_children("*", "CollisionShape2D", true, false):
		(child as CollisionShape2D).set_deferred("disabled", true)


# 查找 Boss 节点；节点名是 Boss 房、HUD 和测试之间的最小稳定约定。
func _get_boss() -> Node:
	# Boss 节点名是当前 Boss 房与 HUD / 测试之间的最小稳定约定。
	return get_node_or_null("SealGuardianBoss")
