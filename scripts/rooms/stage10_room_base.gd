extends "res://scripts/rooms/stage9_room_base.gd"


@export var optional_branch_room_path := ""
@export var challenge_room_path := ""
@export var air_attack_value_marker := false
@export var optional_reward_room := false
@export var challenge_reward_room := false

var _collected_pickup_ids: Dictionary = {}
var _recovery_point_activated := false
var _branch_transition_requested := false


func get_optional_branch_room_path() -> String:
	return optional_branch_room_path


func get_challenge_room_path() -> String:
	return challenge_room_path


func has_air_attack_value_marker() -> bool:
	return air_attack_value_marker


func is_optional_reward_room() -> bool:
	return optional_reward_room


func is_challenge_reward_room() -> bool:
	return challenge_reward_room


func collect_stage10_pickup(pickup_id: StringName) -> void:
	if pickup_id == StringName() or _collected_pickup_ids.has(pickup_id):
		return

	_collected_pickup_ids[pickup_id] = true
	_emit_hud_context()


func activate_recovery_point() -> void:
	_recovery_point_activated = true
	if _player != null and _player.has_method("restore_full_health"):
		_player.call("restore_full_health")
	_emit_hud_context()


func get_stage10_progress_snapshot() -> Dictionary:
	return {
		"collectible_count": _collected_pickup_ids.size(),
		"recovery_point_activated": _recovery_point_activated,
		"optional_reward_room": optional_reward_room,
		"challenge_reward_room": challenge_reward_room,
	}


func get_hud_context() -> Dictionary:
	var context := super.get_hud_context()
	context.merge(get_stage10_progress_snapshot(), true)
	return context


func _process(delta: float) -> void:
	_update_stage10_triggers()
	super._process(delta)


func _update_stage10_triggers() -> void:
	if _player == null:
		return

	_try_request_optional_branch()
	_try_collect_pickup("BranchCollectible", &"branch_reward")
	_try_collect_pickup("ChallengeCollectible", &"challenge_reward")
	_try_activate_recovery_point()


func _try_request_optional_branch() -> void:
	if _branch_transition_requested or optional_branch_room_path.is_empty():
		return

	var branch_zone: Node2D = get_node_or_null("BranchZone") as Node2D
	if branch_zone == null:
		return

	if _player.global_position.distance_to(branch_zone.global_position) > 48.0:
		return

	_branch_transition_requested = true
	room_transition_requested.emit(optional_branch_room_path, &"stage10_branch_start")


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


func _try_activate_recovery_point() -> void:
	if _recovery_point_activated:
		return

	var recovery_point: Node2D = get_node_or_null("RecoveryPoint") as Node2D
	if recovery_point == null:
		return

	if _player.global_position.distance_to(recovery_point.global_position) > 44.0:
		return

	activate_recovery_point()
