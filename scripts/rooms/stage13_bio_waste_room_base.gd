extends "res://scripts/rooms/stage10_room_base.gd"

# Stage13BioWasteRoomBase 负责第二小区域的共同契约：
# 生物废液区支路、废液危险、净化门控和区域奖励快照。
# 它继续复用 Stage9/10 的房间推进、checkpoint 和 HUD 上下文。

# 导出字段描述 Stage13 支路、奖励房角色、酸液伤害和净化门控存在性。
@export var resource_branch_room_path := ""
@export var challenge_branch_room_path := ""
@export var resource_reward_branch := false
@export var challenge_reward_branch := false
@export var acid_damage := 1
@export var purification_gate := false

# 运行期状态保存本房间奖励去重、净化节点、支路请求和酸液伤害去重。
var _stage13_collected_reward_ids: Dictionary = {}
var _purification_node_activated := false
var _resource_branch_requested := false
var _challenge_branch_requested := false
var _acid_damage_dealt := false


# 公开资源支路路径，供区域 hub、测试和流程文档核对支路入口。
func get_resource_branch_room_path() -> String:
	# 资源支路路径用于确认区域 hub 能进入低风险收益房。
	return resource_branch_room_path


# 公开挑战支路路径，供区域 hub 和灰盒 driver 验证高压支路入口。
func get_challenge_branch_room_path() -> String:
	# 挑战支路路径用于确认区域 hub 能进入高压收益房。
	return challenge_branch_room_path


# 标记当前房是否承担资源奖励支路角色。
func is_resource_reward_branch() -> bool:
	# 该读值标记当前房间是否承担资源支路奖励角色。
	return resource_reward_branch


# 标记当前房是否承担挑战奖励支路角色。
func is_challenge_reward_branch() -> bool:
	# 该读值标记当前房间是否承担挑战支路奖励角色。
	return challenge_reward_branch


# 查询房间是否含酸液危险，节点存在即可视为危险已布置。
func has_acid_hazard() -> bool:
	# 酸液危险既可由节点存在推断，也可作为 HUD / 测试的区域特征读值。
	return get_node_or_null("AcidHazard") != null


# 查询房间是否存在净化门控，支持导出字段和节点存在两种声明方式。
func has_purification_gate() -> bool:
	# 净化门既可由导出字段声明，也可由净化节点存在自动推断。
	return purification_gate or get_node_or_null("PurificationNode") != null


# 公开净化节点是否已激活，供 HUD 和测试确认局部门控状态。
func is_purification_node_activated() -> bool:
	# HUD 和测试通过该读值确认局部门控是否已被解除。
	return _purification_node_activated


# 激活净化节点并解开当前房间门控，不创建跨房间钥匙状态。
func activate_purification_node() -> void:
	# 净化节点是 Stage13 的局部门控钥匙：触发后只解当前房间门，不创建全局钥匙系统。
	if _purification_node_activated:
		return

	_purification_node_activated = true
	unlock_gate(&"purified")
	_emit_hud_context()


# 收集 Stage13 支路奖励并去重，避免位置触发多帧重复计数。
func collect_stage13_reward(reward_id: StringName) -> void:
	# 支路奖励按 ID 去重，保证资源支路和挑战支路能分别计数而不会重复刷收益。
	if reward_id == StringName() or _stage13_collected_reward_ids.has(reward_id):
		return

	_stage13_collected_reward_ids[reward_id] = true
	_emit_hud_context()


# 输出 Stage13 区域状态快照，供 HUD、GUT 和人工复核统一读取。
func get_stage13_progress_snapshot() -> Dictionary:
	# Stage13 快照服务 HUD、测试和人工复核；它描述区域状态，不直接驱动流程。
	return {
		"branch_reward_count": _stage13_collected_reward_ids.size(),
		"purification_node_activated": _purification_node_activated,
		"resource_reward_branch": resource_reward_branch,
		"challenge_reward_branch": challenge_reward_branch,
		"acid_hazard_present": has_acid_hazard(),
	}


# 在父类 HUD 上下文基础上追加 Stage13 的支路、危险和净化状态。
func get_hud_context() -> Dictionary:
	# 在 Stage10 上下文基础上追加 Stage13 支路、危险和净化状态。
	var context := super.get_hud_context()
	context.merge(get_stage13_progress_snapshot(), true)
	return context


# 每帧先处理 Stage13 独有触发，再执行通用房间出口推进。
func _process(delta: float) -> void:
	# Stage13 先处理本区域独有触发，再交回父类处理通用出口推进。
	_update_stage13_triggers()
	super._process(delta)


# 初始化 Stage13 房间，并在存在净化门时覆盖父类默认开门状态。
func _ready() -> void:
	super._ready()
	if has_purification_gate() and not _purification_node_activated:
		# 带净化门的房间必须覆盖父类默认门状态，确保玩家先看见“被封住”的目标。
		_gate_unlocked = false
		_apply_gate_lock_state()


# 集中处理酸液、净化节点、支路入口、奖励和 Stage14 入口触发。
func _update_stage13_triggers() -> void:
	if _player == null:
		return

	# 本阶段所有交互仍用位置触发，便于灰盒快速调房间，不提前引入复杂交互组件。
	_try_apply_acid_hazard()
	_try_activate_purification_node()
	_try_request_resource_branch()
	_try_request_challenge_branch()
	_try_collect_stage13_reward("Stage13Reward", &"stage13_reward")
	_try_request_stage14_from_goal_zone()


# 检查玩家是否触碰酸液危险；当前房间只造成一次伤害。
func _try_apply_acid_hazard() -> void:
	# 酸液只在当前房间第一次造成伤害，用于验证危险反馈和 checkpoint 恢复，不做持续 DOT。
	if _acid_damage_dealt:
		return

	var acid_hazard := get_node_or_null("AcidHazard") as Node2D
	if acid_hazard == null:
		return

	if _player.global_position.distance_to(acid_hazard.global_position) > 44.0:
		return

	_acid_damage_dealt = true
	if _player.has_method("receive_damage"):
		_player.call("receive_damage", acid_damage, Vector2.UP)


# 检查玩家是否接近净化节点，并触发局部门控解除。
func _try_activate_purification_node() -> void:
	# 玩家接近符印节点后立即解门，保持门控验证短小清楚。
	if _purification_node_activated:
		return

	var purification_node := get_node_or_null("PurificationNode") as Node2D
	if purification_node == null:
		return

	if _player.global_position.distance_to(purification_node.global_position) > 44.0:
		return

	activate_purification_node()


# 检查玩家是否进入资源支路入口，并发出切房请求。
func _try_request_resource_branch() -> void:
	# 两条支路分别使用独立防重复开关，避免玩家站在入口时连续发出切房信号。
	if _resource_branch_requested or resource_branch_room_path.is_empty():
		return

	var branch_zone := get_node_or_null("ResourceBranchZone") as Node2D
	if branch_zone == null:
		return

	if _player.global_position.distance_to(branch_zone.global_position) > 48.0:
		return

	_resource_branch_requested = true
	room_transition_requested.emit(resource_branch_room_path, &"stage13_resource_branch_start")


# 检查玩家是否进入挑战支路入口，并发出切房请求。
func _try_request_challenge_branch() -> void:
	# 挑战支路与资源支路共享返回主线契约，但入口和收益类型保持分离。
	if _challenge_branch_requested or challenge_branch_room_path.is_empty():
		return

	var branch_zone := get_node_or_null("ChallengeBranchZone") as Node2D
	if branch_zone == null:
		return

	if _player.global_position.distance_to(branch_zone.global_position) > 48.0:
		return

	_challenge_branch_requested = true
	room_transition_requested.emit(challenge_branch_room_path, &"stage13_challenge_branch_start")


# 检查指定奖励节点是否被玩家触达，并记录对应 reward_id。
func _try_collect_stage13_reward(node_name: String, reward_id: StringName) -> void:
	# 奖励节点隐藏只是最小视觉反馈；真正的获得状态保存在快照字典中。
	if _stage13_collected_reward_ids.has(reward_id):
		return

	var reward := get_node_or_null(node_name) as Node2D
	if reward == null:
		return

	if _player.global_position.distance_to(reward.global_position) > 40.0:
		return

	collect_stage13_reward(reward_id)
	reward.visible = false


# 检查区域终点 GoalZone 是否触发进入 Stage14 的主线切房。
func _try_request_stage14_from_goal_zone() -> void:
	# 区域终点房通过 GoalZone 进入 Stage14，避免普通 ExitZone 与终点演出职责混在一起。
	if _transition_requested or next_room_path.is_empty():
		return

	var goal_zone := get_node_or_null("GoalZone") as Node2D
	if goal_zone == null:
		return

	if _player.global_position.distance_to(goal_zone.global_position) > 64.0:
		return

	_transition_requested = true
	room_transition_requested.emit(next_room_path, next_spawn_id)
