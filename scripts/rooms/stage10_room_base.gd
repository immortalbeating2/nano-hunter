extends "res://scripts/rooms/stage9_room_base.gd"

# Stage10RoomBase 在 stage9 线性房间基类之上追加“支路 / 挑战房 / 轻量成长反馈”。
# 它只记录本区域内的收集与恢复读值，不把这些数据扩成正式经济或存档系统。

# 导出字段描述支路目标和房间角色，具体入口 / 奖励节点仍由场景摆放决定。
@export var optional_branch_room_path := ""
@export var challenge_room_path := ""
@export var air_attack_value_marker := false
@export var optional_reward_room := false
@export var challenge_reward_room := false

# 运行期状态只记录本房间内的收集、恢复和切房去重，不跨房间持久化。
var _collected_pickup_ids: Dictionary = {}
var _recovery_point_activated := false
var _branch_transition_requested := false


# 对外暴露的都是“当前房间是否具备某类 stage10 价值”的稳定读值。
func get_optional_branch_room_path() -> String:
	# Main / 测试通过该路径确认主线能进入可选支路。
	return optional_branch_room_path


# 公开挑战房路径，供主线测试确认挑战支路仍可抵达。
func get_challenge_room_path() -> String:
	# 挑战房路径暂作设计读值，当前主线仍以场景出口链路推进。
	return challenge_room_path


# 公开空中攻击价值标记，说明该房间用于验证 Stage10 战斗变化。
func has_air_attack_value_marker() -> bool:
	# 该标记说明房间被设计为突出空中攻击价值，而不是新增能力门。
	return air_attack_value_marker


# 公开是否为可选奖励房，供 HUD 和测试区分支路收益角色。
func is_optional_reward_room() -> bool:
	# 可选奖励房读值用于 HUD 和测试区分支路收益类型。
	return optional_reward_room


# 公开是否为挑战奖励房，确保挑战收益不会被误判为主线必拿。
func is_challenge_reward_room() -> bool:
	# 挑战奖励房读值用于确认挑战支路没有混入主线必拿收益。
	return challenge_reward_room


# 收集 Stage10 拾取物并按 ID 去重，避免多帧位置触发重复计数。
func collect_stage10_pickup(pickup_id: StringName) -> void:
	# 收集按 ID 去重，让位置触发在多帧内稳定只计一次。
	if pickup_id == StringName() or _collected_pickup_ids.has(pickup_id):
		return

	_collected_pickup_ids[pickup_id] = true
	_emit_hud_context()


# 激活 Stage10 恢复点，补满玩家生命并刷新 HUD 收益状态。
func activate_recovery_point() -> void:
	# 恢复点在 Stage10 只做“支路收益”反馈，触发后立即补满生命但不写入正式存档。
	_recovery_point_activated = true
	if _player != null and _player.has_method("restore_full_health"):
		_player.call("restore_full_health")
	_emit_hud_context()


# 成长快照是 HUD、测试和人工复核的统一读取入口。
func get_stage10_progress_snapshot() -> Dictionary:
	return {
		"collectible_count": _collected_pickup_ids.size(),
		"recovery_point_activated": _recovery_point_activated,
		"optional_reward_room": optional_reward_room,
		"challenge_reward_room": challenge_reward_room,
	}


# 在 Stage9 基础 HUD 上追加 Stage10 的收集、恢复点和奖励房状态。
func get_hud_context() -> Dictionary:
	# 在 Stage9 基础 HUD 上追加 Stage10 成长反馈字段。
	var context := super.get_hud_context()
	context.merge(get_stage10_progress_snapshot(), true)
	return context


# 位置触发层统一处理：支路入口、收集物和恢复点都在这里判定。
func _process(delta: float) -> void:
	_update_stage10_triggers()
	super._process(delta)


# 集中检查 Stage10 的支路、收集物和恢复点位置触发。
func _update_stage10_triggers() -> void:
	# 所有 Stage10 灰盒触发集中在这里，便于后续替换为正式交互组件。
	if _player == null:
		return

	_try_request_optional_branch()
	_try_collect_pickup("BranchCollectible", &"branch_reward")
	_try_collect_pickup("ChallengeCollectible", &"challenge_reward")
	_try_activate_recovery_point()


# 检查玩家是否进入可选支路入口，并通过标准房间信号请求切房。
func _try_request_optional_branch() -> void:
	# 支路入口用距离判断而不是 Area 信号，方便测试直接移动玩家到入口点复现。
	if _branch_transition_requested or optional_branch_room_path.is_empty():
		return

	var branch_zone: Node2D = get_node_or_null("BranchZone") as Node2D
	if branch_zone == null:
		return

	if _player.global_position.distance_to(branch_zone.global_position) > 48.0:
		return

	_branch_transition_requested = true
	room_transition_requested.emit(optional_branch_room_path, &"stage10_branch_start")


# 收集物一旦触发就立刻隐藏，避免房间脚本与 HUD 出现重复计数。
func _try_collect_pickup(node_name: String, pickup_id: StringName) -> void:
	if _collected_pickup_ids.has(pickup_id):
		return

	var pickup: Node2D = get_node_or_null(node_name) as Node2D
	if pickup == null:
		return

	if _player.global_position.distance_to(pickup.global_position) > 40.0:
		return

	collect_stage10_pickup(pickup_id)
	pickup.visible = false


# 检查玩家是否靠近恢复点，并在首次触发时执行恢复收益。
func _try_activate_recovery_point() -> void:
	# 恢复点只允许激活一次，避免 HUD 反复播放同一份收益反馈。
	if _recovery_point_activated:
		return

	var recovery_point: Node2D = get_node_or_null("RecoveryPoint") as Node2D
	if recovery_point == null:
		return

	if _player.global_position.distance_to(recovery_point.global_position) > 44.0:
		return

	activate_recovery_point()
