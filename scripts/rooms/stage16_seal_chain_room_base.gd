extends "res://scripts/rooms/stage14_backtracking_room_base.gd"

# Stage16SealChainRoomBase 负责 Alpha Demo 候选末段封印链房间的共同契约。
# 它只做房间内的灰盒触发、HUD 快照和标准出口推进，不新增剧情系统或敌人类别。

# 房间角色由场景配置，HUD 和验证脚本用这些字段定位当前封印链节点。
@export var stage16_room_role := ""
@export var seal_chain_step: StringName = &"stage16_chain"
@export var require_backtrack_confirmation := false
@export var required_backtrack_reward_count := 3
@export var required_talisman_relay_count := 0
@export var final_alpha_demo_room := false

# 运行期状态只记录本房间内的封印触发、符印中继、回溯确认和净化反馈。
var _seal_released := false
var _talisman_relay_ids: Dictionary = {}
var _backtrack_confirmed := false
var _corruption_purged := false


# 汇总 Stage16 封印链快照，供 HUD、灰盒 driver 和人工复核读取。
func get_stage16_progress_snapshot() -> Dictionary:
	var relay_count := _talisman_relay_ids.size()
	return {
		"stage16_room_role": stage16_room_role,
		"stage16_seal_chain_step": seal_chain_step,
		"stage16_seal_released": _seal_released,
		"stage16_talisman_relay_count": relay_count,
		"stage16_talisman_relay_required": required_talisman_relay_count,
		"stage16_backtrack_confirmed": _backtrack_confirmed,
		"stage16_backtrack_reward_count": get_stage14_backtrack_reward_count(),
		"stage16_backtrack_required": required_backtrack_reward_count,
		"stage16_corruption_purged": _corruption_purged,
		"stage16_alpha_demo_complete_room": final_alpha_demo_room,
	}


# 在既有 HUD 上下文上追加 Stage16 末段封印链状态。
func get_hud_context() -> Dictionary:
	var context := super.get_hud_context()
	context.merge(get_stage16_progress_snapshot(), true)
	return context


# 初始化时根据本房间是否有局部门控，恢复 GateBarrier 的锁定状态。
func _ready() -> void:
	super._ready()
	if _requires_stage16_gate_lock():
		_gate_unlocked = false
		_apply_gate_lock_state()
	_emit_hud_context()


# 每帧先处理 Stage16 灰盒触发，再交回父类处理通用出口推进。
func _process(delta: float) -> void:
	_update_stage16_triggers()
	super._process(delta)


# Stage16 只使用位置触发，便于自动化测试直接移动玩家复现链路。
func _update_stage16_triggers() -> void:
	if _player == null:
		return

	_try_release_seal()
	_try_activate_talisman_relay("TalismanRelayA", &"stage16_relay_a")
	_try_activate_talisman_relay("TalismanRelayB", &"stage16_relay_b")
	_try_activate_talisman_relay("TalismanRelayC", &"stage16_relay_c")
	_try_confirm_backtrack()
	_try_purge_corruption()


# 接近封印阈值节点后打开当前门控，表达 Boss 后封印链已经可被释放。
func _try_release_seal() -> void:
	if _seal_released:
		return

	var seal_node := get_node_or_null("SealReleaseNode") as Node2D
	if seal_node == null:
		return

	if _player.global_position.distance_to(seal_node.global_position) > 48.0:
		return

	_seal_released = true
	unlock_gate(&"stage16_seal_released")


# 激活符印中继节点，达到本房间需求数量后打开门控。
func _try_activate_talisman_relay(node_name: String, relay_id: StringName) -> void:
	if _talisman_relay_ids.has(relay_id):
		return

	var relay_node := get_node_or_null(node_name) as Node2D
	if relay_node == null:
		return

	if _player.global_position.distance_to(relay_node.global_position) > 44.0:
		return

	_talisman_relay_ids[relay_id] = true
	relay_node.visible = false
	if _talisman_relay_ids.size() >= required_talisman_relay_count:
		unlock_gate(&"stage16_talisman_relay_complete")
	else:
		_emit_hud_context()


# 回溯确认房优先读取 Main 中的 Stage14 收益计数；缺失时允许本房间作为灰盒链路继续推进。
func _try_confirm_backtrack() -> void:
	if _backtrack_confirmed:
		return

	var confirm_node := get_node_or_null("BacktrackConfirmationNode") as Node2D
	if confirm_node == null:
		return

	if _player.global_position.distance_to(confirm_node.global_position) > 48.0:
		return

	if require_backtrack_confirmation and get_stage14_backtrack_reward_count() < required_backtrack_reward_count and _main != null:
		_emit_hud_context()
		return

	_backtrack_confirmed = true
	unlock_gate(&"stage16_backtrack_confirmed")


# 妖瘴净化节点只影响本房间门控和 HUD，不写入全局状态。
func _try_purge_corruption() -> void:
	if _corruption_purged:
		return

	var purge_node := get_node_or_null("CorruptionPurgeNode") as Node2D
	if purge_node == null:
		return

	if _player.global_position.distance_to(purge_node.global_position) > 48.0:
		return

	_corruption_purged = true
	unlock_gate(&"stage16_corruption_purged")


# 带局部目标节点的房间默认锁门，终点房没有门控时保持标准出口完成逻辑。
func _requires_stage16_gate_lock() -> bool:
	return get_node_or_null("GateBarrier") != null and (
		get_node_or_null("SealReleaseNode") != null
		or required_talisman_relay_count > 0
		or get_node_or_null("BacktrackConfirmationNode") != null
		or get_node_or_null("CorruptionPurgeNode") != null
	)
