extends "res://scripts/rooms/stage10_room_base.gd"

# Stage13BioWasteRoomBase 负责第二小区域的共同契约：
# 生物废液区支路、废液危险、净化门控和区域奖励快照。
# 它继续复用 Stage9/10 的房间推进、checkpoint 和 HUD 上下文。

@export var resource_branch_room_path := ""
@export var challenge_branch_room_path := ""
@export var resource_reward_branch := false
@export var challenge_reward_branch := false
@export var acid_damage := 1
@export var purification_gate := false

var _stage13_collected_reward_ids: Dictionary = {}
var _purification_node_activated := false
var _resource_branch_requested := false
var _challenge_branch_requested := false
var _acid_damage_dealt := false


func get_resource_branch_room_path() -> String:
	return resource_branch_room_path


func get_challenge_branch_room_path() -> String:
	return challenge_branch_room_path


func is_resource_reward_branch() -> bool:
	return resource_reward_branch


func is_challenge_reward_branch() -> bool:
	return challenge_reward_branch


func has_acid_hazard() -> bool:
	return get_node_or_null("AcidHazard") != null


func has_purification_gate() -> bool:
	return purification_gate or get_node_or_null("PurificationNode") != null


func is_purification_node_activated() -> bool:
	return _purification_node_activated


func activate_purification_node() -> void:
	if _purification_node_activated:
		return

	_purification_node_activated = true
	unlock_gate(&"purified")
	_emit_hud_context()


func collect_stage13_reward(reward_id: StringName) -> void:
	if reward_id == StringName() or _stage13_collected_reward_ids.has(reward_id):
		return

	_stage13_collected_reward_ids[reward_id] = true
	_emit_hud_context()


func get_stage13_progress_snapshot() -> Dictionary:
	return {
		"branch_reward_count": _stage13_collected_reward_ids.size(),
		"purification_node_activated": _purification_node_activated,
		"resource_reward_branch": resource_reward_branch,
		"challenge_reward_branch": challenge_reward_branch,
		"acid_hazard_present": has_acid_hazard(),
	}


func get_hud_context() -> Dictionary:
	var context := super.get_hud_context()
	context.merge(get_stage13_progress_snapshot(), true)
	return context


func _process(delta: float) -> void:
	_update_stage13_triggers()
	super._process(delta)


func _ready() -> void:
	super._ready()
	if has_purification_gate() and not _purification_node_activated:
		_gate_unlocked = false
		_apply_gate_lock_state()


func _update_stage13_triggers() -> void:
	if _player == null:
		return

	_try_apply_acid_hazard()
	_try_activate_purification_node()
	_try_request_resource_branch()
	_try_request_challenge_branch()
	_try_collect_stage13_reward("Stage13Reward", &"stage13_reward")


func _try_apply_acid_hazard() -> void:
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


func _try_activate_purification_node() -> void:
	if _purification_node_activated:
		return

	var purification_node := get_node_or_null("PurificationNode") as Node2D
	if purification_node == null:
		return

	if _player.global_position.distance_to(purification_node.global_position) > 44.0:
		return

	activate_purification_node()


func _try_request_resource_branch() -> void:
	if _resource_branch_requested or resource_branch_room_path.is_empty():
		return

	var branch_zone := get_node_or_null("ResourceBranchZone") as Node2D
	if branch_zone == null:
		return

	if _player.global_position.distance_to(branch_zone.global_position) > 48.0:
		return

	_resource_branch_requested = true
	room_transition_requested.emit(resource_branch_room_path, &"stage13_resource_branch_start")


func _try_request_challenge_branch() -> void:
	if _challenge_branch_requested or challenge_branch_room_path.is_empty():
		return

	var branch_zone := get_node_or_null("ChallengeBranchZone") as Node2D
	if branch_zone == null:
		return

	if _player.global_position.distance_to(branch_zone.global_position) > 48.0:
		return

	_challenge_branch_requested = true
	room_transition_requested.emit(challenge_branch_room_path, &"stage13_challenge_branch_start")


func _try_collect_stage13_reward(node_name: String, reward_id: StringName) -> void:
	if _stage13_collected_reward_ids.has(reward_id):
		return

	var reward := get_node_or_null(node_name) as Node2D
	if reward == null:
		return

	if _player.global_position.distance_to(reward.global_position) > 40.0:
		return

	collect_stage13_reward(reward_id)
	reward.visible = false
