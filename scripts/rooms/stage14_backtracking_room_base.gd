extends "res://scripts/rooms/stage13_bio_waste_room_base.gd"

# Stage14BacktrackingRoomBase 负责阶段 14 第一条回溯链路的共同契约：
# 空中冲刺获得点、空中冲刺能力门，以及 3 个明确可数的回溯收益点。
# 它仍复用 Stage13 的房间推进和 HUD 上下文，不扩展成完整地图或任务系统。

# 房间角色由场景勾选：神龛房负责授予能力，能力门房负责验证能力。
@export var air_dash_shrine_room := false
@export var air_dash_gate_room := false

# Main 是能力持久化权威，房间本地状态只用于单房间即时反馈和测试。
var _main: Node
var _air_dash_granted := false
var _stage14_reward_ids: Dictionary = {}


# 接收 Main 引用，用于写入跨房间能力解锁和回溯收益计数。
func bind_main(main: Node) -> void:
	# Main 在换房后注入自身引用，让房间能写入能力解锁和回溯收益。
	_main = main


# 公开本房是否已经触发过空中冲刺授予。
func has_air_dash_been_granted() -> bool:
	# 该读值只说明本房间是否触发过神龛授予，不等同于全局能力状态。
	return _air_dash_granted


# 公开能力门是否已打开，复用父类门控读值。
func is_air_dash_gate_unlocked() -> bool:
	# 能力门状态复用基类门控读值，避免 Stage14 自建第二套门系统。
	return is_gate_unlocked()


# 公开 Stage14 回溯收益总数，优先以 Main 的跨房间计数为准。
func get_stage14_backtrack_reward_count() -> int:
	# 优先读取 Main 的全局计数，缺 Main 时回退本房间字典以支持孤立测试。
	if _main != null and _main.has_method("get_stage14_backtrack_reward_count"):
		return int(_main.call("get_stage14_backtrack_reward_count"))

	return _stage14_reward_ids.size()


# 在父类 HUD 上下文上追加空中冲刺门、神龛和回溯收益状态。
func get_hud_context() -> Dictionary:
	var context := super.get_hud_context()
	# HUD 只需要知道当前能力门/收益进度，不直接读取房间节点，避免 UI 绑定具体场景结构。
	context.merge({
		"air_dash_gate_room": air_dash_gate_room,
		"air_dash_granted": _air_dash_granted or _is_air_dash_unlocked(),
		"stage14_backtrack_reward_count": get_stage14_backtrack_reward_count(),
	}, true)
	return context


# 初始化 Stage14 房间，并按已有能力状态恢复能力门开关。
func _ready() -> void:
	super._ready()
	if air_dash_gate_room:
		# 能力门初始状态必须从 Main / Player 的运行期能力状态恢复，
		# 否则玩家跨房间回来时会看到已解锁能力却仍被灰盒门挡住。
		_gate_unlocked = _is_air_dash_unlocked()
		_apply_gate_lock_state()


# 每帧先处理 Stage14 能力 / 奖励触发，再交回父类通用推进。
func _process(delta: float) -> void:
	# 先处理 Stage14 能力 / 奖励触发，再交给父类推进出口和旧区域逻辑。
	_update_stage14_triggers()
	super._process(delta)


# 集中处理空中冲刺授予、能力门解锁和三个回溯收益点。
func _update_stage14_triggers() -> void:
	if _player == null:
		return

	# Stage14 触发顺序固定为：先获得能力，再打开能力门，最后尝试收集回溯收益。
	_try_grant_air_dash()
	_try_unlock_air_dash_gate()
	_try_collect_stage14_reward("BacktrackRewardOne", &"stage14_reward_one")
	_try_collect_stage14_reward("BacktrackRewardTwo", &"stage14_reward_two")
	_try_collect_stage14_reward("BacktrackRewardThree", &"stage14_reward_three")


# 检查玩家是否靠近神龛，并授予空中冲刺能力。
func _try_grant_air_dash() -> void:
	if not air_dash_shrine_room or _air_dash_granted:
		return

	var shrine := get_node_or_null("AirDashShrine") as Node2D
	if shrine == null:
		return

	if _player.global_position.distance_to(shrine.global_position) > 48.0:
		return

	# 能力状态同时写入 Player 和 Main：Player 负责即时手感，Main 负责跨房间持久化。
	_air_dash_granted = true
	if _player.has_method("set_air_dash_unlocked"):
		_player.call("set_air_dash_unlocked", true)
	if _main != null and _main.has_method("unlock_air_dash"):
		_main.call("unlock_air_dash")
	_emit_hud_context()


# 检查能力门是否应因空中冲刺已解锁而打开。
func _try_unlock_air_dash_gate() -> void:
	# 能力门不依赖玩家位置，只要能力状态恢复为已解锁，门就应立即打开。
	if not air_dash_gate_room or _gate_unlocked:
		return

	if not _is_air_dash_unlocked():
		return

	unlock_gate(&"stage14_air_dash_gate_open")


# 检查指定回溯收益点是否被玩家触达，并同步到 Main 计数。
func _try_collect_stage14_reward(node_name: String, reward_id: StringName) -> void:
	if _stage14_reward_ids.has(reward_id):
		return

	var reward := get_node_or_null(node_name) as Node2D
	if reward == null:
		return

	if _player.global_position.distance_to(reward.global_position) > 44.0:
		return

	# 回溯收益点以 reward_id 去重，允许测试或玩家停留在节点附近时不会重复计数。
	_stage14_reward_ids[reward_id] = true
	reward.visible = false
	if _main != null and _main.has_method("collect_stage14_backtrack_reward"):
		_main.call("collect_stage14_backtrack_reward", reward_id)
	_emit_hud_context()


# 查询空中冲刺是否已解锁，优先读取 Main，缺失时回退玩家实例。
func _is_air_dash_unlocked() -> bool:
	# Main 是跨房间的权威状态；Player 兜底用于单房间测试和运行时刚解锁后的即时读值。
	if _main != null and _main.has_method("is_air_dash_unlocked") and bool(_main.call("is_air_dash_unlocked")):
		return true

	return _player != null and _player.has_method("is_air_dash_unlocked") and bool(_player.call("is_air_dash_unlocked"))
