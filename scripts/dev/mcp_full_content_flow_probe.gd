extends Node

# MCP 运行态全流程探针：在 Godot MCP Pro 正在运行的 Main 节点上复核生产房间链路。
# ponytail: 路线直接读取上一层 full-flow 报告，避免维护第二份 34 房路径表。

const ROUTE_JSON := "res://tests/artifacts/local/full-content-demo-qa/full_flow_route_evidence/full_content_flow_evidence.json"
const OUT_DIR := "res://tests/artifacts/local/full-content-demo-qa/mcp_2026_07_01/full_flow_probe"
const SCREENSHOT_DIR := "%s/screenshots" % OUT_DIR
const OUT_JSON := "%s/mcp_full_content_flow_probe.json" % OUT_DIR
const OUT_MD := "%s/mcp_full_content_flow_probe.md" % OUT_DIR

var _main: Node2D
var _issues: Array[Dictionary] = []


func run(main: Node2D) -> Dictionary:
	_main = main
	_issues.clear()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))

	if _main == null:
		_add_issue("P0", "bootstrap", "missing_main", "MCP running scene has no Main node")
		return _write_report([])

	if _main.has_method("start_demo"):
		_main.call("start_demo")
	await _settle()
	_hide_shell()

	var route := _load_route()
	var rows: Array[Dictionary] = []
	for item: Dictionary in route:
		rows.append(await _drive_step(item))

	return _write_report(rows)


func _load_route() -> Array:
	var file := FileAccess.open(ROUTE_JSON, FileAccess.READ)
	if file == null:
		_add_issue("P0", "bootstrap", "missing_route_json", "Run capture_full_content_flow_evidence.gd first")
		return []

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_add_issue("P0", "bootstrap", "bad_route_json", "Route report is not a JSON object")
		return []

	var route: Array = parsed.get("route", [])
	if route.is_empty():
		_add_issue("P0", "bootstrap", "empty_route", "Route report has no route rows")
	return route


func _drive_step(item: Dictionary) -> Dictionary:
	var room_id := str(item.get("id", "unknown"))
	var room_path := str(item.get("path", ""))
	var expected_next := str(item.get("expected_next", ""))

	if room_path.is_empty():
		_add_issue("P0", room_id, "missing_room_path", "Route row has no path")
		return {}

	if _room_path() != room_path and _main.has_method("transition_to_room"):
		_main.call("transition_to_room", room_path, &"")
		await _settle()
		_hide_shell()

	var shots := {
		"entry": await _capture(room_id, "entry"),
	}
	await _prepare_room(room_id)
	shots["mid"] = await _capture(room_id, "mid")
	await _trigger_exit(room_id)
	await _settle()
	_hide_shell()
	shots["exit"] = await _capture(room_id, "exit")

	var actual_next := _room_path()
	if not expected_next.is_empty() and actual_next != expected_next:
		_add_issue("P0", room_id, "transition_failed", "expected=%s actual=%s" % [expected_next, actual_next])

	return {
		"id": room_id,
		"path": room_path,
		"expected_next": expected_next,
		"actual_after_exit": actual_next,
		"screenshots": shots,
		"hud": _hud_snapshot(),
		"player": _player_snapshot(),
	}


func _prepare_room(room_id: String) -> void:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		_add_issue("P0", room_id, "missing_runtime_nodes", "Room or PlayerPlaceholder missing")
		return

	if room_id == "tutorial":
		player.global_position = Vector2(-48.0, 32.0)
		await _settle()
		player.global_position = Vector2(252.0, 96.0)
		await _settle()
		var dummy := room.get_node_or_null("TutorialDummy")
		if dummy != null and dummy.has_method("receive_attack"):
			dummy.call("receive_attack", Vector2.RIGHT, 120.0)
		await _settle()
		return

	_defeat_targets(room)
	await _activate_nodes(room, player, [
		"GateSwitch",
		"SealNode",
		"AirDashShrine",
		"AirDashGateSensor",
		"BacktrackRewardOne",
		"BacktrackRewardTwo",
		"BacktrackRewardThree",
		"SealReleaseNode",
		"TalismanRelayA",
		"TalismanRelayB",
		"TalismanRelayC",
		"BacktrackConfirmationNode",
		"CorruptionPurgeNode",
	])

	if _main.has_method("unlock_air_dash"):
		_main.call("unlock_air_dash")
	if room_id == "stage16_backtrack" and _main.has_method("collect_stage14_backtrack_reward"):
		_main.call("collect_stage14_backtrack_reward", &"stage14_reward_one")
		_main.call("collect_stage14_backtrack_reward", &"stage14_reward_two")
		_main.call("collect_stage14_backtrack_reward", &"stage14_reward_three")
	await _settle()


func _trigger_exit(room_id: String) -> void:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		return

	if room_id == "stage11_end":
		_move_to(room, player, "GoalZone")
		await _settle()
		_move_to(room, player, "ContinueZone")
		return

	if room_id == "stage15_boss":
		var boss := room.get_node_or_null("SealGuardianBoss")
		if boss != null and boss.has_method("receive_attack"):
			for _i: int in range(24):
				boss.call("receive_attack", Vector2.RIGHT, 120.0)
		return

	if room_id == "stage16_end":
		_move_to(room, player, "ExitZone")
		return

	if room.get_node_or_null("GoalZone") != null:
		_move_to(room, player, "GoalZone")
		return

	_move_to(room, player, "ExitZone")


func _activate_nodes(room: Node, player: CharacterBody2D, names: Array[String]) -> void:
	var initial_path := ""
	if room != null:
		initial_path = room.scene_file_path
	for node_name: String in names:
		if not is_instance_valid(room) or not is_instance_valid(player) or _room_path() != initial_path:
			return
		var marker := room.get_node_or_null(NodePath(node_name)) as Node2D
		if marker == null:
			continue
		player.global_position = marker.global_position
		await _settle()


func _defeat_targets(room: Node) -> void:
	for child: Node in room.get_children():
		if child.name == "SealGuardianBoss":
			continue
		if child.has_method("receive_attack"):
			child.call("receive_attack", Vector2.RIGHT, 120.0)


func _move_to(room: Node, player: CharacterBody2D, node_name: String) -> void:
	var marker := room.get_node_or_null(NodePath(node_name)) as Node2D
	if marker != null:
		player.global_position = marker.global_position


func _capture(room_id: String, phase: String) -> String:
	await _settle()
	var path := "%s/%s_%s.png" % [SCREENSHOT_DIR, room_id, phase]
	get_viewport().get_texture().get_image().save_png(path)
	return path


func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw


func _hide_shell() -> void:
	var shell: Node = null
	if _main != null:
		shell = _main.get_node_or_null("HUD/DemoShell")
	if shell == null:
		return
	var menu := shell.get_node_or_null("MainMenu") as CanvasItem
	var title := shell.get_node_or_null("TitleBackground") as CanvasItem
	if menu != null:
		menu.visible = false
	if title != null:
		title.visible = false


func _room() -> Node2D:
	if _main == null:
		return null
	return _main.get_node_or_null("Room") as Node2D


func _player() -> CharacterBody2D:
	if _main == null:
		return null
	return _main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


func _room_path() -> String:
	var room := _room()
	if room == null:
		return ""
	return room.scene_file_path


func _hud_snapshot() -> Dictionary:
	return {
		"step": _label("HUD/TutorialHUD/PromptPanel/StepLabel"),
		"prompt": _label("HUD/TutorialHUD/PromptPanel/PromptLabel"),
		"progress": _label("HUD/TutorialHUD/BattlePanel/ProgressLabel"),
	}


func _label(path: NodePath) -> String:
	var label: Label = null
	if _main != null:
		label = _main.get_node_or_null(path) as Label
	if label == null:
		return ""
	return label.text


func _player_snapshot() -> Dictionary:
	var player := _player()
	if player == null:
		return {}
	return {
		"position": {"x": player.global_position.x, "y": player.global_position.y},
		"velocity": {"x": player.velocity.x, "y": player.velocity.y},
		"health": _player_health(player),
	}


func _player_health(player: CharacterBody2D) -> Variant:
	if player.has_method("get_current_health"):
		return player.call("get_current_health")
	return null


func _write_report(rows: Array[Dictionary]) -> Dictionary:
	var report := {
		"review_id": "mcp_full_content_flow_probe",
		"generated_at": Time.get_datetime_string_from_system(),
		"route_count": rows.size(),
		"rows": rows,
		"issues": _issues,
		"issue_counts": _count_issues(),
		"final_snapshot": _final_snapshot(),
		"boundary": "Executed inside the Godot MCP Pro running game scene. Uses production room triggers, not a human navigation AI.",
	}
	_write_text(OUT_JSON, JSON.stringify(report, "\t"))
	_write_text(OUT_MD, _markdown(report))
	return report


func _markdown(report: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("# MCP Full Content Flow Probe")
	lines.append("")
	var counts: Dictionary = report.get("issue_counts", {})
	lines.append("- 生成时间：%s" % str(report.get("generated_at", "")))
	lines.append("- 主线房间：%s" % int(report.get("route_count", 0)))
	lines.append("- P0 / P1 / P2：%s / %s / %s" % [counts.get("P0", 0), counts.get("P1", 0), counts.get("P2", 0)])
	lines.append("- 边界：%s" % str(report.get("boundary", "")))
	lines.append("")
	lines.append("| Room | Expected Next | Actual After Exit | Entry | Mid | Exit |")
	lines.append("| --- | --- | --- | --- | --- | --- |")
	for row: Dictionary in report.get("rows", []):
		var screenshots: Dictionary = row.get("screenshots", {})
		lines.append("| `%s` | `%s` | `%s` | `%s` | `%s` | `%s` |" % [
			str(row.get("id", "")),
			str(row.get("expected_next", "")),
			str(row.get("actual_after_exit", "")),
			str(screenshots.get("entry", "")),
			str(screenshots.get("mid", "")),
			str(screenshots.get("exit", "")),
		])
	lines.append("")
	lines.append("## Issues")
	lines.append("")
	if _issues.is_empty():
		lines.append("- 无 P0/P1/P2。")
	else:
		for issue: Dictionary in _issues:
			lines.append("- %s `%s` `%s`：%s" % [
				issue.get("severity", ""),
				issue.get("room", ""),
				issue.get("code", ""),
				issue.get("note", ""),
			])
	return "\n".join(lines) + "\n"


func _add_issue(severity: String, room: String, code: String, note: String) -> void:
	_issues.append({"severity": severity, "room": room, "code": code, "note": note})


func _count_issues() -> Dictionary:
	var counts := {"P0": 0, "P1": 0, "P2": 0}
	for issue: Dictionary in _issues:
		var severity := str(issue.get("severity", ""))
		counts[severity] = int(counts.get(severity, 0)) + 1
	return counts


func _final_snapshot() -> Dictionary:
	if _main != null and _main.has_method("get_demo_progress_snapshot"):
		return _main.call("get_demo_progress_snapshot")
	return {}


func _write_text(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(content)
