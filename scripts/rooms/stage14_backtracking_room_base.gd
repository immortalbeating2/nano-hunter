extends "res://scripts/rooms/stage13_bio_waste_room_base.gd"

# Stage14BacktrackingRoomBase 负责阶段 14 第一条回溯链路的共同契约：
# 空中冲刺获得点、空中冲刺能力门，以及 3 个明确可数的回溯收益点。
# 它仍复用 Stage13 的房间推进和 HUD 上下文，不扩展成完整地图或任务系统。
@export var air_dash_shrine_room := false
@export var air_dash_gate_room := false

var _main: Node
var _air_dash_granted := false
var _stage14_reward_ids: Dictionary = {}


func bind_main(main: Node) -> void:
	_main = main


func has_air_dash_been_granted() -> bool:
	return _air_dash_granted


func is_air_dash_gate_unlocked() -> bool:
	return is_gate_unlocked()


func get_stage14_backtrack_reward_count() -> int:
	if _main != null and _main.has_method("get_stage14_backtrack_reward_count"):
		return int(_main.call("get_stage14_backtrack_reward_count"))

	return _stage14_reward_ids.size()


func get_hud_context() -> Dictionary:
	var context := super.get_hud_context()
	# HUD 只需要知道当前能力门/收益进度，不直接读取房间节点，避免 UI 绑定具体场景结构。
	context.merge({
		"air_dash_gate_room": air_dash_gate_room,
		"air_dash_granted": _air_dash_granted or _is_air_dash_unlocked(),
		"stage14_backtrack_reward_count": get_stage14_backtrack_reward_count(),
	}, true)
	return context


func _ready() -> void:
	super._ready()
	if air_dash_gate_room:
		# 能力门初始状态必须从 Main / Player 的运行期能力状态恢复，
		# 否则玩家跨房间回来时会看到已解锁能力却仍被灰盒门挡住。
		_gate_unlocked = _is_air_dash_unlocked()
		_apply_gate_lock_state()


func _process(delta: float) -> void:
	_update_stage14_triggers()
	super._process(delta)


func _update_stage14_triggers() -> void:
	if _player == null:
		return

	# Stage14 触发顺序固定为：先获得能力，再打开能力门，最后尝试收集回溯收益。
	_try_grant_air_dash()
	_try_unlock_air_dash_gate()
	_try_collect_stage14_reward("BacktrackRewardOne", &"stage14_reward_one")
	_try_collect_stage14_reward("BacktrackRewardTwo", &"stage14_reward_two")
	_try_collect_stage14_reward("BacktrackRewardThree", &"stage14_reward_three")


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


func _try_unlock_air_dash_gate() -> void:
	if not air_dash_gate_room or _gate_unlocked:
		return

	if not _is_air_dash_unlocked():
		return

	unlock_gate(&"stage14_air_dash_gate_open")


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


func _is_air_dash_unlocked() -> bool:
	# Main 是跨房间的权威状态；Player 兜底用于单房间测试和运行时刚解锁后的即时读值。
	if _main != null and _main.has_method("is_air_dash_unlocked") and bool(_main.call("is_air_dash_unlocked")):
		return true

	return _player != null and _player.has_method("is_air_dash_unlocked") and bool(_player.call("is_air_dash_unlocked"))
