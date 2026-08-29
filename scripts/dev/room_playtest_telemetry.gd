class_name RoomPlaytestTelemetry
extends RefCounted

# 方案 B 房间灰盒遥测器。
# 调用方显式上报事件；本类只聚合诊断证据，不判断关卡体验是否通过。

const SCHEMA := "nano_hunter_room_playtest_v1"
const HUMAN_ACCEPTANCE := "pending_external_playtest"
const EVIDENCE_BOUNDARY := "telemetry_and_screenshots_are_diagnostic_evidence_not_human_acceptance"

var _session_metadata: Dictionary = {}
var _session_started_msec := 0
var _events: Array[Dictionary] = []
var _room_visits: Array[Dictionary] = []
var _active_visit: Dictionary = {}
var _death_count := 0
var _failure_count := 0
var _map_open_count := 0
var _exit_misfire_count := 0
var _ability_routes: Array[Dictionary] = []
var _last_direction := ""


# 开始一轮全新试玩；显式时间参数让自动测试和真人记录使用同一数据格式。
func start_session(metadata: Dictionary = {}, timestamp_msec := -1) -> void:
	_session_metadata = metadata.duplicate(true)
	_session_started_msec = _resolve_time(timestamp_msec)
	_events.clear()
	_room_visits.clear()
	_active_visit.clear()
	_death_count = 0
	_failure_count = 0
	_map_open_count = 0
	_exit_misfire_count = 0
	_ability_routes.clear()
	_last_direction = ""
	_append_event(&"session_started", {}, _session_started_msec)


# 每次切房后由试玩驱动调用，保留入口方向、出生点和真实进入时间。
func enter_room(
	formal_room_id: String,
	room_path: String,
	spawn_id: StringName,
	entry_direction: StringName,
	position: Vector2,
	timestamp_msec := -1
) -> void:
	var now := _resolve_time(timestamp_msec)
	if not _active_visit.is_empty():
		_close_active_visit(&"unknown", "", position, now)
	_active_visit = {
		"formal_room_id": formal_room_id,
		"room_path": room_path,
		"spawn_id": str(spawn_id),
		"entered_msec": now,
		"entry_direction": str(entry_direction),
		"entry_position": _vector_to_array(position),
		"direction_reversal_count": 0,
	}
	_last_direction = ""
	_append_event(&"room_entered", _active_visit.duplicate(true), now)


# 离开房间时结算停留时间；target id 允许直接统计回访和逆行路径。
func leave_room(exit_direction: StringName, target_room_id: String, position: Vector2, timestamp_msec := -1) -> void:
	var now := _resolve_time(timestamp_msec)
	_close_active_visit(exit_direction, target_room_id, position, now)
	_append_event(&"room_left", {
		"exit_direction": str(exit_direction),
		"target_room_id": target_room_id,
		"position": _vector_to_array(position),
	}, now)


# 只统计明确的左右方向变化，停止、跳跃和垂直速度不会制造方向反转噪声。
func record_direction_sample(direction: StringName, timestamp_msec := -1) -> void:
	var normalized := str(direction)
	if normalized not in ["left", "right"]:
		return
	if not _last_direction.is_empty() and normalized != _last_direction and not _active_visit.is_empty():
		_active_visit["direction_reversal_count"] = int(_active_visit.get("direction_reversal_count", 0)) + 1
	_last_direction = normalized
	_append_event(&"direction_sample", {"direction": normalized}, _resolve_time(timestamp_msec))


func record_death(position: Vector2, reason: StringName, timestamp_msec := -1) -> void:
	_death_count += 1
	_append_event(&"death", {"reason": str(reason), "position": _vector_to_array(position)}, _resolve_time(timestamp_msec))


func record_failure(reason: StringName, position: Vector2, timestamp_msec := -1) -> void:
	_failure_count += 1
	_append_event(&"failure", {"reason": str(reason), "position": _vector_to_array(position)}, _resolve_time(timestamp_msec))


func record_map_open(timestamp_msec := -1) -> void:
	_map_open_count += 1
	_append_event(&"map_opened", {}, _resolve_time(timestamp_msec))


# 触碰出口却未发出切房请求视为误触；成功触发也保留样本用于计算出口发现时间。
func record_exit_contact(exit_id: StringName, emitted_transition: bool, position: Vector2, timestamp_msec := -1) -> void:
	if not emitted_transition:
		_exit_misfire_count += 1
	_append_event(&"exit_contact", {
		"exit_id": str(exit_id),
		"emitted_transition": emitted_transition,
		"position": _vector_to_array(position),
	}, _resolve_time(timestamp_msec))


func record_ability_route(
	ability_id: StringName,
	from_room_id: String,
	to_room_id: String,
	shortcut_id: StringName,
	timestamp_msec := -1
) -> void:
	var now := _resolve_time(timestamp_msec)
	var route := {
		"ability_id": str(ability_id),
		"from_room_id": from_room_id,
		"to_room_id": to_room_id,
		"shortcut_id": str(shortcut_id),
		"discovery_msec": maxi(0, now - _session_started_msec),
	}
	_ability_routes.append(route)
	_append_event(&"ability_route_discovered", route, now)


# 快照不会关闭当前房间，方便长时间试玩过程中随时落盘。
func get_snapshot(timestamp_msec := -1) -> Dictionary:
	var now := _resolve_time(timestamp_msec)
	var active := _active_visit.duplicate(true)
	if not active.is_empty():
		active["elapsed_msec"] = maxi(0, now - int(active.get("entered_msec", now)))
	return {
		"schema": SCHEMA,
		"human_acceptance": HUMAN_ACCEPTANCE,
		"human_approved": false,
		"boundary": EVIDENCE_BOUNDARY,
		"session_metadata": _session_metadata.duplicate(true),
		"session_started_msec": _session_started_msec,
		"session_duration_msec": maxi(0, now - _session_started_msec),
		"room_visits": _room_visits.duplicate(true),
		"active_room_visit": active,
		"death_count": _death_count,
		"failure_count": _failure_count,
		"map_open_count": _map_open_count,
		"exit_misfire_count": _exit_misfire_count,
		"ability_routes": _ability_routes.duplicate(true),
		"events": _events.duplicate(true),
	}


func save_json(path: String, timestamp_msec := -1) -> Error:
	var absolute_dir := ProjectSettings.globalize_path(path.get_base_dir())
	var mkdir_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if mkdir_error != OK:
		return mkdir_error
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(get_snapshot(timestamp_msec), "  "))
	return OK


func _close_active_visit(exit_direction: StringName, target_room_id: String, position: Vector2, now: int) -> void:
	if _active_visit.is_empty():
		return
	_active_visit["left_msec"] = now
	_active_visit["duration_msec"] = maxi(0, now - int(_active_visit.get("entered_msec", now)))
	_active_visit["exit_direction"] = str(exit_direction)
	_active_visit["target_room_id"] = target_room_id
	_active_visit["exit_position"] = _vector_to_array(position)
	_room_visits.append(_active_visit.duplicate(true))
	_active_visit.clear()
	_last_direction = ""


func _append_event(event_type: StringName, payload: Dictionary, timestamp_msec: int) -> void:
	_events.append({
		"type": str(event_type),
		"timestamp_msec": timestamp_msec,
		"session_elapsed_msec": maxi(0, timestamp_msec - _session_started_msec),
		"payload": payload.duplicate(true),
	})


func _resolve_time(timestamp_msec: int) -> int:
	return Time.get_ticks_msec() if timestamp_msec < 0 else timestamp_msec


func _vector_to_array(value: Vector2) -> Array[float]:
	return [value.x, value.y]
