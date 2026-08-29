extends "res://scripts/rooms/stage10_room_base.gd"

# Stage13MiasmaMarshRoomBase 负责第二小区域的共同契约：
# 瘴泽妖域支路、腐瘴危险、封印门控和区域奖励快照。
# 它继续复用 Stage9/10 的房间推进、checkpoint 和 HUD 上下文。

# 导出字段描述 Stage13 支路、奖励房角色、瘴气伤害和封印门控存在性。
@export var resource_branch_room_path := ""
@export var challenge_branch_room_path := ""
@export var resource_reward_branch := false
@export var challenge_reward_branch := false
@export var miasma_damage := 1
@export var seal_gate := false
@export var persistent_reward_id: StringName = &""
@export var air_dash_fast_route_room_path := ""
@export var air_dash_fast_route_spawn_id: StringName = &""
@export var grants_wind_seal := false
@export var air_dash_revisit_reward_id: StringName = &""
@export var shortcut_revisit_reward_id: StringName = &""
@export var air_dash_fast_route_reward_id: StringName = &""
@export var challenge_branch_requires_down_input := false
@export var reward_requires_down_input := false
@export var wind_seal_requires_down_input := false
@export var air_dash_revisit_reward_requires_down_input := false
@export var seal_node_requires_down_input := false
@export var seal_node_requires_air_dash := false
@export var seal_node_required_reward_id: StringName = &""
@export var goal_requires_down_input := false

# 运行期状态保存本房间奖励去重、镇妖印节点、支路请求和瘴气伤害去重。
var _stage13_collected_reward_ids: Dictionary = {}
var _seal_node_activated := false
var _resource_branch_requested := false
var _challenge_branch_requested := false
var _miasma_damage_dealt := false
var _air_dash_fast_route_requested := false
var _wind_seal_granted := false
var _stage14_revisit_reward_ids: Dictionary = {}
var _air_dash_revisit_reward_available := false


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


# 查询房间是否含瘴气危险，节点存在即可视为危险已布置。
func has_miasma_hazard() -> bool:
	# 瘴气危险既可由节点存在推断，也可作为 HUD / 测试的区域特征读值。
	return get_node_or_null("MiasmaHazard") != null


# 查询房间是否存在封印门控，支持导出字段和节点存在两种声明方式。
func has_seal_gate() -> bool:
	# 封印门既可由导出字段声明，也可由镇妖印节点存在自动推断。
	return seal_gate or get_node_or_null("SealNode") != null


# 公开镇妖印节点是否已激活，供 HUD 和测试确认局部门控状态。
func is_seal_node_activated() -> bool:
	# HUD 和测试通过该读值确认局部门控是否已被解除。
	return _seal_node_activated


# 查询本房的风印神龛是否已结算，供 F05 HUD、回访恢复和回归测试读取。
func is_wind_seal_granted() -> bool:
	return _wind_seal_granted


# 激活镇妖印节点并解开当前房间门控，不创建跨房间钥匙状态。
func activate_seal_node() -> void:
	# 镇妖印节点是 Stage13 的局部门控钥匙：触发后只解当前房间门，不创建全局钥匙系统。
	if _seal_node_activated:
		return

	_seal_node_activated = true
	unlock_gate(&"seal_released")
	_emit_hud_context()


# 收集 Stage13 支路奖励并去重，避免位置触发多帧重复计数。
func collect_stage13_reward(reward_id: StringName) -> void:
	# 支路奖励按 ID 去重，保证资源支路和挑战支路能分别计数而不会重复刷收益。
	if reward_id == StringName() or _stage13_collected_reward_ids.has(reward_id):
		return

	_stage13_collected_reward_ids[reward_id] = true
	if persistent_reward_id != StringName() and _main != null and _main.has_method("collect_exploration_reward"):
		_main.call("collect_exploration_reward", persistent_reward_id)
	_emit_hud_context()


# 输出 Stage13 区域状态快照，供 HUD、GUT 和人工复核统一读取。
func get_stage13_progress_snapshot() -> Dictionary:
	# Stage13 快照服务 HUD、测试和人工复核；它描述区域状态，不直接驱动流程。
	return {
		"branch_reward_count": _stage13_collected_reward_ids.size(),
		"seal_node_activated": _seal_node_activated,
		"resource_reward_branch": resource_reward_branch,
		"challenge_reward_branch": challenge_reward_branch,
		"miasma_hazard_present": has_miasma_hazard(),
		"persistent_reward_id": persistent_reward_id,
		"persistent_reward_collected": persistent_reward_id != StringName() and _main != null and _main.has_method("has_exploration_reward") and bool(_main.call("has_exploration_reward", persistent_reward_id)),
		"air_dash_fast_route_available": is_air_dash_fast_route_available(),
		"wind_seal_granted": _wind_seal_granted,
		"air_dash_revisit_reward_count": _stage14_revisit_reward_ids.size(),
	}


# F09 上层高速线只在 Air Dash 已取得时显示为可用，真正切房仍要求玩家以冲刺状态触发。
func is_air_dash_fast_route_available() -> bool:
	return not air_dash_fast_route_room_path.is_empty() and _is_air_dash_unlocked()


# 在父类 HUD 上下文基础上追加 Stage13 的支路、危险和封印状态。
func get_hud_context() -> Dictionary:
	# 在 Stage10 上下文基础上追加 Stage13 支路、危险和封印状态。
	var context := super.get_hud_context()
	if not resource_branch_room_path.is_empty() and str(context.get("prompt_text", "")).is_empty():
		context["prompt_text"] = "下层资源支路：按住下方向并跳跃，穿过单向平台。"
	context.merge(get_stage13_progress_snapshot(), true)
	return context


# 每帧先处理 Stage13 独有触发，再执行通用房间出口推进。
func _process(delta: float) -> void:
	# Stage13 先处理本区域独有触发，再交回父类处理通用出口推进。
	_update_stage13_triggers()
	super._process(delta)


# 初始化 Stage13 房间，并在存在封印门时覆盖父类默认开门状态。
func _ready() -> void:
	super._ready()
	if has_seal_gate() and not _seal_node_activated:
		# 带封印门的房间必须覆盖父类默认门状态，确保玩家先看见“被封住”的目标。
		_gate_unlocked = false
		_apply_gate_lock_state()


# 注入 Main 时恢复已经取得的风印，避免回访 F05 时神龛重新亮起或重复结算。
func bind_main(main: Node) -> void:
	super.bind_main(main)
	if (
		grants_wind_seal
		and _main != null
		and _main.has_method("is_wind_seal_unlocked")
		and bool(_main.call("is_wind_seal_unlocked"))
	):
		_wind_seal_granted = true
		_apply_wind_seal_shrine_state()
	_restore_stage14_revisit_rewards()
	if shortcut_revisit_reward_id != StringName() and _stage14_revisit_reward_ids.has(shortcut_revisit_reward_id):
		_seal_node_activated = true
		unlock_gate(&"seal_released")


# 集中处理瘴气、镇妖印节点、支路入口、奖励和 Stage14 入口触发。
func _update_stage13_triggers() -> void:
	if _player == null:
		return

	# 连续边界与单向地形仍可位置触发；明确选择的挑战和遗物复用现有 ui_down 确认。
	_try_apply_miasma_hazard()
	_try_activate_seal_node()
	_try_grant_wind_seal()
	_try_collect_air_dash_revisit_reward()
	_try_request_air_dash_fast_route()
	if _transition_requested:
		return
	_try_request_resource_branch()
	_try_request_challenge_branch()
	_try_collect_stage13_reward("Stage13Reward", &"stage13_reward")
	_try_request_stage14_from_goal_zone()


# F05 先完成远程敌教学，再触达神龛取得风印；清场前不会提前越过教学顺序。
func _try_grant_wind_seal() -> void:
	if not grants_wind_seal or _wind_seal_granted or not _gate_unlocked:
		return

	var shrine := get_node_or_null("WindSealShrine") as Node2D
	if shrine == null or _player.global_position.distance_to(shrine.global_position) > 44.0:
		return
	if wind_seal_requires_down_input and not _is_down_confirmation_pressed():
		return

	_wind_seal_granted = true
	if _main != null and _main.has_method("unlock_wind_seal"):
		_main.call("unlock_wind_seal")
	if _player.has_method("set_wind_seal_unlocked"):
		_player.call("set_wind_seal_unlocked", true)
	_apply_wind_seal_shrine_state()
	_emit_hud_context()


# 神龛只承担一次性能力授予反馈；碰撞和出口均不依赖它的可见状态。
func _apply_wind_seal_shrine_state() -> void:
	var shrine := get_node_or_null("WindSealShrine") as Node2D
	if shrine != null:
		shrine.visible = not _wind_seal_granted


# F06 的可选回访奖励必须由一次真实空中 Dash 触达，持有能力或普通跳跃都不结算。
func _try_collect_air_dash_revisit_reward() -> void:
	if air_dash_revisit_reward_id == StringName() or _stage14_revisit_reward_ids.has(air_dash_revisit_reward_id):
		return

	var reward := get_node_or_null("AirDashRevisitReward") as Node2D
	if reward == null:
		return
	if not _air_dash_revisit_reward_available:
		if not _is_air_dash_unlocked() or _player.is_on_floor() or not _player.has_method("get_current_state_id"):
			return
		if _player.call("get_current_state_id") != &"dash" or _player.global_position.distance_to(reward.global_position) > 56.0:
			return
		_air_dash_revisit_reward_available = true
		if not air_dash_revisit_reward_requires_down_input:
			_collect_stage14_revisit_reward(air_dash_revisit_reward_id)
			_apply_air_dash_revisit_reward_state()
		return
	if _player.global_position.distance_to(reward.global_position) > 72.0:
		return
	if air_dash_revisit_reward_requires_down_input and not _is_down_confirmation_pressed():
		return

	_collect_stage14_revisit_reward(air_dash_revisit_reward_id)
	_apply_air_dash_revisit_reward_state()


# F07 仍复用标准 ShortcutZone；成功请求跨区捷径时同时记下唯一必需回访事实。
func _try_request_shortcut() -> bool:
	var requested := super._try_request_shortcut()
	if requested and shortcut_revisit_reward_id != StringName():
		_collect_stage14_revisit_reward(shortcut_revisit_reward_id)
	return requested


# 三处回访共用 Main 的持久化去重入口，本房字典只负责即时 HUD 与隐藏反馈。
func _collect_stage14_revisit_reward(reward_id: StringName) -> void:
	if reward_id == StringName() or _stage14_revisit_reward_ids.has(reward_id):
		return
	_stage14_revisit_reward_ids[reward_id] = true
	if _main != null and _main.has_method("collect_stage14_backtrack_reward"):
		_main.call("collect_stage14_backtrack_reward", reward_id)
	_emit_hud_context()


# 回访已结算状态从 Main 恢复，避免换房后 F06 奖励重新出现。
func _restore_stage14_revisit_rewards() -> void:
	if _main == null or not _main.has_method("has_stage14_backtrack_reward"):
		return
	for reward_id: StringName in [air_dash_revisit_reward_id, shortcut_revisit_reward_id, air_dash_fast_route_reward_id]:
		if reward_id != StringName() and bool(_main.call("has_stage14_backtrack_reward", reward_id)):
			_stage14_revisit_reward_ids[reward_id] = true
	_apply_air_dash_revisit_reward_state()


func _apply_air_dash_revisit_reward_state() -> void:
	var reward := get_node_or_null("AirDashRevisitReward") as Node2D
	if reward != null and air_dash_revisit_reward_id != StringName():
		reward.visible = not _stage14_revisit_reward_ids.has(air_dash_revisit_reward_id)


# Air Dash 高速线复用标准切房信号；要求空中 dash 是为了让上层路线形成真实动作差异。
func _try_request_air_dash_fast_route() -> void:
	if _air_dash_fast_route_requested or not is_air_dash_fast_route_available():
		return

	var fast_zone := get_node_or_null("AirDashFastRouteZone") as Node2D
	if fast_zone == null or _player.global_position.distance_to(fast_zone.global_position) > 64.0:
		return
	if _player.is_on_floor() or not _player.has_method("get_current_state_id"):
		return
	if _player.call("get_current_state_id") != &"dash":
		return

	_air_dash_fast_route_requested = true
	_transition_requested = true
	if air_dash_fast_route_reward_id != StringName():
		_collect_stage14_revisit_reward(air_dash_fast_route_reward_id)
	room_transition_requested.emit(air_dash_fast_route_room_path, air_dash_fast_route_spawn_id)


# 检查玩家是否触碰瘴气危险；当前房间只造成一次伤害。
func _try_apply_miasma_hazard() -> void:
	# 瘴气只在当前房间第一次造成伤害，用于验证危险反馈和 checkpoint 恢复，不做持续 DOT。
	if _miasma_damage_dealt:
		return

	var miasma_hazard := get_node_or_null("MiasmaHazard") as Node2D
	if miasma_hazard == null:
		return

	if _player.global_position.distance_to(miasma_hazard.global_position) > 44.0:
		return

	_miasma_damage_dealt = true
	if _player.has_method("receive_damage"):
		_player.call("receive_damage", miasma_damage, Vector2.UP)


# 检查玩家是否接近镇妖印节点，并触发局部门控解除。
func _try_activate_seal_node() -> void:
	# 玩家接近符印节点后立即解门，保持门控验证短小清楚。
	if _seal_node_activated:
		return

	var seal_node := get_node_or_null("SealNode") as Node2D
	if seal_node == null:
		return
	if seal_node_requires_air_dash and not _is_air_dash_unlocked():
		return
	if seal_node_required_reward_id != StringName() and not _has_exploration_reward(seal_node_required_reward_id):
		return

	if _player.global_position.distance_to(seal_node.global_position) > 44.0:
		return
	if seal_node_requires_down_input and not _is_down_confirmation_pressed():
		return

	activate_seal_node()


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
	_transition_requested = true
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
	if challenge_branch_requires_down_input and not _is_down_confirmation_pressed():
		return

	_challenge_branch_requested = true
	_transition_requested = true
	room_transition_requested.emit(challenge_branch_room_path, &"stage13_challenge_branch_start")


# 检查指定奖励节点是否被玩家触达，并记录对应 reward_id。
func _try_collect_stage13_reward(node_name: String, reward_id: StringName) -> void:
	# 奖励节点隐藏只是最小视觉反馈；真正的获得状态保存在快照字典中。
	if _stage13_collected_reward_ids.has(reward_id):
		return

	var reward := get_node_or_null(node_name) as Node2D
	if reward == null:
		return
	if challenge_reward_branch and not _gate_unlocked:
		return

	if _player.global_position.distance_to(reward.global_position) > 40.0:
		return
	if reward_requires_down_input and not _is_down_confirmation_pressed():
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
	if goal_requires_down_input and not _is_down_confirmation_pressed():
		return

	_transition_requested = true
	room_transition_requested.emit(next_room_path, next_spawn_id)
