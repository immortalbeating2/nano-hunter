extends Node

# MCP 输入式 replay 探针：只通过 Input action 驱动玩家，不调用房间切换或改玩家坐标。
# ponytail: 简单节拍器足够暴露阻塞点；真导航 AI 等它证明需要再说。

const OUT_DIR := "res://tests/artifacts/local/full-content-demo-qa/mcp_2026_07_01/player_input_replay"
const SCREENSHOT_DIR := "%s/screenshots" % OUT_DIR
const OUT_JSON := "%s/player_input_replay_probe.json" % OUT_DIR
const OUT_MD := "%s/player_input_replay_probe.md" % OUT_DIR

const ROOM_TIMEOUT := 48.0
const TOTAL_TIMEOUT := 480.0
const MID_CAPTURE_DELAY := 4.0

var _main: Node2D
var _running := false
var _finished := false
var _elapsed := 0.0
var _room_elapsed := 0.0
var _current_room_path := ""
var _current_room_id := ""
var _room_index := 0
var _last_player_x := 0.0
var _stuck_elapsed := 0.0
var _mid_captured := false
var _rows: Array[Dictionary] = []
var _issues: Array[Dictionary] = []
var _tap_timers := {"jump": 0.0, "attack": 0.0, "dash": 0.0, "recover": 0.0}
var _tap_active := {"jump": false, "attack": false, "dash": false, "recover": false}


func start(main: Node2D) -> void:
	_main = main
	_running = true
	_finished = false
	_elapsed = 0.0
	_room_elapsed = 0.0
	_room_index = 0
	_rows.clear()
	_issues.clear()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))
	set_physics_process(true)
	_release_all()
	_enter_current_room("entry")


func is_finished() -> bool:
	return _finished


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not _running or _finished:
		return

	_elapsed += delta
	_room_elapsed += delta
	_drive_input(delta)
	_check_room_change()
	_capture_midpoint()
	_check_completion()
	_check_timeout()


func _drive_input(delta: float) -> void:
	_focus_failure_continue(delta)
	var enemy := _nearest_active_enemy() if _should_use_combat_steering() else null
	var attack_period := 0.32
	if enemy != null:
		attack_period = _drive_toward_enemy(enemy)
	else:
		_set_horizontal_input(1.0)
	_update_stuck_timer(delta)
	_tick_tap("attack", delta, attack_period)
	_tick_tap("dash", delta, 0.58)
	_tick_tap("recover", delta, 2.0)
	var jump_period := 0.74 if _stuck_elapsed < 1.2 else 0.36
	_tick_tap("jump", delta, jump_period)


func _drive_toward_enemy(enemy: Node2D) -> float:
	var player := _player()
	if player == null:
		_set_horizontal_input(1.0)
		return 0.32

	var delta_to_enemy := enemy.global_position - player.global_position
	if absf(delta_to_enemy.x) <= 58.0 and absf(delta_to_enemy.y) <= 64.0:
		_set_horizontal_input(0.0)
		return 0.16

	_set_horizontal_input(signf(delta_to_enemy.x))
	return 0.22


func _set_horizontal_input(axis: float) -> void:
	if axis > 0.1:
		Input.action_release("move_left")
		Input.action_press("move_right")
	elif axis < -0.1:
		Input.action_release("move_right")
		Input.action_press("move_left")
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")


func _nearest_active_enemy() -> Node2D:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		return null

	var best_enemy: Node2D = null
	var best_distance := INF
	for child: Node in room.get_children():
		if not child is Node2D or not child.has_method("receive_attack"):
			continue
		if child.has_method("is_defeated") and bool(child.call("is_defeated")):
			continue

		var enemy := child as Node2D
		var distance := player.global_position.distance_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best_enemy = enemy
	return best_enemy


func _should_use_combat_steering() -> bool:
	var room := _room()
	if room == null:
		return false

	if room.scene_file_path.ends_with("stage15_seal_guardian_boss_room.tscn"):
		return true

	if not room.has_method("get_remaining_required_enemy_count"):
		return false

	return int(room.call("get_remaining_required_enemy_count")) > 0


func _focus_failure_continue(delta: float) -> void:
	var button := _failure_continue_button()
	if button == null or not button.visible:
		return

	button.grab_focus()
	_tick_tap("ui_accept", delta, 0.36)


func _tick_tap(action: String, delta: float, period: float) -> void:
	_tap_timers[action] = float(_tap_timers.get(action, 0.0)) + delta
	if bool(_tap_active.get(action, false)):
		Input.action_release(action)
		_tap_active[action] = false
		return
	if float(_tap_timers.get(action, 0.0)) < period:
		return
	_tap_timers[action] = 0.0
	Input.action_press(action)
	_tap_active[action] = true


func _update_stuck_timer(delta: float) -> void:
	var player := _player()
	if player == null:
		_stuck_elapsed += delta
		return
	var dx := player.global_position.x - _last_player_x
	if dx > 2.0:
		_stuck_elapsed = 0.0
	else:
		_stuck_elapsed += delta
	_last_player_x = player.global_position.x


func _check_room_change() -> void:
	var path := _room_path()
	if path.is_empty() or path == _current_room_path:
		return
	_capture(_current_room_id, "exit")
	_enter_current_room("entry")


func _enter_current_room(phase: String) -> void:
	_current_room_path = _room_path()
	_current_room_id = _room_id(_current_room_path)
	_room_elapsed = 0.0
	_stuck_elapsed = 0.0
	_mid_captured = false
	var player := _player()
	_last_player_x = player.global_position.x if player != null else 0.0
	_rows.append({
		"index": _room_index,
		"id": _current_room_id,
		"path": _current_room_path,
		"entered_at": _elapsed,
		"screenshots": {phase: _capture(_current_room_id, phase)},
	})
	_room_index += 1
	_write_report(false)


func _capture_midpoint() -> void:
	if _mid_captured or _room_elapsed < MID_CAPTURE_DELAY:
		return
	_mid_captured = true
	_append_screenshot("mid", _capture(_current_room_id, "mid"))
	_write_report(false)


func _append_screenshot(phase: String, path: String) -> void:
	if _rows.is_empty():
		return
	var row: Dictionary = _rows[_rows.size() - 1]
	var shots: Dictionary = row.get("screenshots", {})
	shots[phase] = path
	row["screenshots"] = shots
	_rows[_rows.size() - 1] = row


func _check_completion() -> void:
	var snapshot := _snapshot()
	if bool(snapshot.get("stage16_alpha_demo_completed", false)):
		_append_screenshot("complete", _capture(_current_room_id, "complete"))
		_finish()


func _check_timeout() -> void:
	if _elapsed >= TOTAL_TIMEOUT:
		_add_issue("P0", _current_room_id, "total_timeout", "input replay exceeded total timeout")
		_finish()
		return
	if _room_elapsed < ROOM_TIMEOUT:
		return
	_add_issue("P0", _current_room_id, "room_timeout", "input replay did not naturally leave room in %.1fs" % ROOM_TIMEOUT)
	_append_screenshot("timeout", _capture(_current_room_id, "timeout"))
	_finish()


func _finish() -> void:
	_release_all()
	_running = false
	_finished = true
	set_physics_process(false)
	_write_report(true)


func _capture(room_id: String, phase: String) -> String:
	var safe_id := room_id if not room_id.is_empty() else "unknown"
	var path := "%s/%03d_%s_%s.png" % [SCREENSHOT_DIR, _room_index, safe_id, phase]
	get_viewport().get_texture().get_image().save_png(path)
	return path


func _release_all() -> void:
	for action: String in ["move_left", "move_right", "jump", "attack", "dash", "recover", "ui_accept"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _room_path() -> String:
	var room := _room()
	if room == null:
		return ""
	return room.scene_file_path


func _room_id(path: String) -> String:
	if path.is_empty():
		return "missing_room"
	var file := path.get_file().replace(".tscn", "")
	for prefix: String in ["stage13_miasma_marsh_", "stage14_air_dash_", "stage15_seal_guardian_", "stage15_mixed_", "stage16_alpha_demo_", "stage16_"]:
		file = file.replace(prefix, "")
	return file


func _room() -> Node2D:
	if _main == null:
		return null
	return _main.get_node_or_null("Room") as Node2D


func _player() -> CharacterBody2D:
	if _main == null:
		return null
	return _main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


func _failure_continue_button() -> Button:
	if _main == null:
		return null
	return _main.get_node_or_null("HUD/DemoShell/FailurePanel/MarginContainer/VBoxContainer/FailureContinueButton") as Button


func _snapshot() -> Dictionary:
	if _main != null and _main.has_method("get_demo_progress_snapshot"):
		return _main.call("get_demo_progress_snapshot")
	return {}


func _add_issue(severity: String, room: String, code: String, note: String) -> void:
	_issues.append({"severity": severity, "room": room, "code": code, "note": note})


func _count_issues() -> Dictionary:
	var counts := {"P0": 0, "P1": 0, "P2": 0}
	for issue: Dictionary in _issues:
		var severity := str(issue.get("severity", ""))
		counts[severity] = int(counts.get(severity, 0)) + 1
	return counts


func _write_report(done: bool) -> void:
	var report := {
		"review_id": "mcp_player_input_replay_probe",
		"generated_at": Time.get_datetime_string_from_system(),
		"done": done,
		"elapsed": _elapsed,
		"rooms_seen": _rows.size(),
		"current_room": _current_room_path,
		"issue_counts": _count_issues(),
		"issues": _issues,
		"rows": _rows,
		"final_snapshot": _snapshot(),
		"boundary": "Input-only replay probe: uses Input.action_press/release plus UI focus for visible failure continue; does not call transition_to_room or move the player.",
	}
	_write_text(OUT_JSON, JSON.stringify(report, "\t"))
	_write_text(OUT_MD, _markdown(report))


func _markdown(report: Dictionary) -> String:
	var counts: Dictionary = report.get("issue_counts", {})
	var lines: Array[String] = []
	lines.append("# MCP Player Input Replay Probe")
	lines.append("")
	lines.append("- 生成时间：%s" % str(report.get("generated_at", "")))
	lines.append("- 完成：%s" % str(report.get("done", false)))
	lines.append("- 用时：%.2fs" % float(report.get("elapsed", 0.0)))
	lines.append("- 房间数：%d" % int(report.get("rooms_seen", 0)))
	lines.append("- P0 / P1 / P2：%s / %s / %s" % [counts.get("P0", 0), counts.get("P1", 0), counts.get("P2", 0)])
	lines.append("- 边界：%s" % str(report.get("boundary", "")))
	lines.append("")
	lines.append("| # | Room | Path | Screenshots |")
	lines.append("| --- | --- | --- | --- |")
	for row: Dictionary in report.get("rows", []):
		lines.append("| %d | `%s` | `%s` | `%s` |" % [
			int(row.get("index", 0)),
			str(row.get("id", "")),
			str(row.get("path", "")),
			JSON.stringify(row.get("screenshots", {})),
		])
	lines.append("")
	lines.append("## Issues")
	lines.append("")
	if _issues.is_empty():
		lines.append("- 无。")
	else:
		for issue: Dictionary in _issues:
			lines.append("- %s `%s` `%s`：%s" % [
				issue.get("severity", ""),
				issue.get("room", ""),
				issue.get("code", ""),
				issue.get("note", ""),
			])
	return "\n".join(lines) + "\n"


func _write_text(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(content)
