extends SceneTree

# 全内容流程证据捕获：加载生产 Main.tscn，沿真实房间切换契约推进主线。
# ponytail: 这是 dev-only 证据脚本，不做真人导航 AI；若要“全手操 replay”，继续用 MCP 输入录制层补。

const OUT_DIR := "res://tests/artifacts/local/full-content-demo-qa/full_flow_route_evidence"
const SCREENSHOT_DIR := "%s/screenshots" % OUT_DIR
const OUT_JSON := "%s/full_content_flow_evidence.json" % OUT_DIR
const OUT_MD := "%s/full_content_flow_evidence.md" % OUT_DIR
const MAIN_SCENE := "res://scenes/main/main.tscn"
const WORLD_MAP_LAYOUT := "res://assets/configs/world_map/alpha_demo_world_map.json"

const MAIN_ROUTE := [
	{"id": "tutorial", "path": "res://scenes/rooms/tutorial_room.tscn", "expect": "res://scenes/rooms/combat_trial_room.tscn"},
	{"id": "combat_trial", "path": "res://scenes/rooms/combat_trial_room.tscn", "expect": "res://scenes/rooms/goal_trial_room.tscn"},
	{"id": "goal_trial", "path": "res://scenes/rooms/goal_trial_room.tscn", "expect": "res://scenes/rooms/stage9_zone_entry_room.tscn"},
	{"id": "stage9_entry", "path": "res://scenes/rooms/stage9_zone_entry_room.tscn", "expect": "res://scenes/rooms/stage9_zone_combat_room.tscn"},
	{"id": "stage9_combat", "path": "res://scenes/rooms/stage9_zone_combat_room.tscn", "expect": "res://scenes/rooms/stage9_zone_charger_room.tscn"},
	{"id": "stage9_charger", "path": "res://scenes/rooms/stage9_zone_charger_room.tscn", "expect": "res://scenes/rooms/stage9_zone_switch_room.tscn"},
	{"id": "stage9_switch", "path": "res://scenes/rooms/stage9_zone_switch_room.tscn", "expect": "res://scenes/rooms/stage9_zone_final_room.tscn"},
	{"id": "stage9_final", "path": "res://scenes/rooms/stage9_zone_final_room.tscn", "expect": "res://scenes/rooms/stage10_zone_aerial_room.tscn"},
	{"id": "stage10_aerial", "path": "res://scenes/rooms/stage10_zone_aerial_room.tscn", "expect": "res://scenes/rooms/stage10_zone_challenge_room.tscn"},
	{"id": "stage10_challenge", "path": "res://scenes/rooms/stage10_zone_challenge_room.tscn", "expect": "res://scenes/rooms/stage11_demo_end_room.tscn"},
	{"id": "stage11_end", "path": "res://scenes/rooms/stage11_demo_end_room.tscn", "expect": "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"},
	{"id": "stage13_entry", "path": "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn", "expect": "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"},
	{"id": "stage13_caster", "path": "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn", "expect": "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"},
	{"id": "stage13_miasma", "path": "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn", "expect": "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"},
	{"id": "stage13_gate", "path": "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn", "expect": "res://scenes/rooms/stage13_miasma_marsh_crossfire_room.tscn"},
	{"id": "stage13_crossfire", "path": "res://scenes/rooms/stage13_miasma_marsh_crossfire_room.tscn", "expect": "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"},
	{"id": "stage13_checkpoint", "path": "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn", "expect": "res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn"},
	{"id": "stage13_pressure", "path": "res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn", "expect": "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"},
	{"id": "stage13_branch_hub", "path": "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn", "expect": "res://scenes/rooms/stage13_miasma_marsh_return_room.tscn"},
	{"id": "stage13_return", "path": "res://scenes/rooms/stage13_miasma_marsh_return_room.tscn", "expect": "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"},
	{"id": "stage13_goal", "path": "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn", "expect": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn"},
	{"id": "stage14_shrine", "path": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn", "expect": "res://scenes/rooms/stage14_air_dash_gate_room.tscn"},
	{"id": "stage14_gate", "path": "res://scenes/rooms/stage14_air_dash_gate_room.tscn", "expect": "res://scenes/rooms/stage14_backtrack_hub_room.tscn"},
	{"id": "stage14_hub", "path": "res://scenes/rooms/stage14_backtrack_hub_room.tscn", "expect": "res://scenes/rooms/stage14_loop_return_room.tscn"},
	{"id": "stage14_loop_return", "path": "res://scenes/rooms/stage14_loop_return_room.tscn", "expect": "res://scenes/rooms/stage15_seal_pressure_room.tscn"},
	{"id": "stage15_pressure", "path": "res://scenes/rooms/stage15_seal_pressure_room.tscn", "expect": "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"},
	{"id": "stage15_gauntlet", "path": "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn", "expect": "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn"},
	{"id": "stage15_boss", "path": "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn", "expect": "res://scenes/rooms/stage15_completion_room.tscn"},
	{"id": "stage15_completion", "path": "res://scenes/rooms/stage15_completion_room.tscn", "expect": "res://scenes/rooms/stage16_seal_release_threshold_room.tscn"},
	{"id": "stage16_threshold", "path": "res://scenes/rooms/stage16_seal_release_threshold_room.tscn", "expect": "res://scenes/rooms/stage16_talisman_relay_room.tscn"},
	{"id": "stage16_relay", "path": "res://scenes/rooms/stage16_talisman_relay_room.tscn", "expect": "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn"},
	{"id": "stage16_backtrack", "path": "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn", "expect": "res://scenes/rooms/stage16_corruption_purge_room.tscn"},
	{"id": "stage16_purge", "path": "res://scenes/rooms/stage16_corruption_purge_room.tscn", "expect": "res://scenes/rooms/stage16_alpha_demo_end_room.tscn"},
	{"id": "stage16_end", "path": "res://scenes/rooms/stage16_alpha_demo_end_room.tscn", "expect": ""},
]

const OPTIONAL_ROOMS := [
	{"id": "stage10_branch", "path": "res://scenes/rooms/stage10_zone_branch_room.tscn"},
	{"id": "stage13_resource_branch", "path": "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"},
	{"id": "stage13_challenge_branch", "path": "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn"},
	{"id": "stage15_challenge_branch", "path": "res://scenes/rooms/stage15_challenge_branch_room.tscn"},
]

# 雷泽主路包含一次岔路回环；重复经过坡道 / 岔口是生产拓扑的一部分，唯一房间覆盖仍为 6。
const WASTE_ROUTE := [
	{"id": "stage25_entry", "path": "res://scenes/rooms/stage25_thunder_waste_entry_room.tscn", "expect": "res://scenes/rooms/stage25_thunder_waste_stormfield_room.tscn"},
	{"id": "stage25_storm", "path": "res://scenes/rooms/stage25_thunder_waste_stormfield_room.tscn", "expect": "res://scenes/rooms/stage25_thunder_waste_slope_room.tscn"},
	{"id": "stage25_slope", "path": "res://scenes/rooms/stage25_thunder_waste_slope_room.tscn", "expect": "res://scenes/rooms/stage25_thunder_waste_fork_room.tscn"},
	{"id": "stage25_fork_branch", "path": "res://scenes/rooms/stage25_thunder_waste_fork_room.tscn", "expect": "res://scenes/rooms/stage25_thunder_waste_relay_room.tscn"},
	{"id": "stage25_relay", "path": "res://scenes/rooms/stage25_thunder_waste_relay_room.tscn", "expect": "res://scenes/rooms/stage25_thunder_waste_slope_room.tscn"},
	{"id": "stage25_slope_return", "path": "res://scenes/rooms/stage25_thunder_waste_slope_room.tscn", "expect": "res://scenes/rooms/stage25_thunder_waste_fork_room.tscn"},
	{"id": "stage25_fork_main", "path": "res://scenes/rooms/stage25_thunder_waste_fork_room.tscn", "expect": "res://scenes/rooms/stage25_thunder_waste_outlook_room.tscn"},
	{"id": "stage25_outlook", "path": "res://scenes/rooms/stage25_thunder_waste_outlook_room.tscn", "expect": "res://scenes/rooms/stage11_demo_end_room.tscn"},
]

var _main: Node2D
var _issues: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(640, 360)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))

	var packed_scene := load(MAIN_SCENE) as PackedScene
	if packed_scene == null:
		push_error("Missing Main.tscn")
		quit(1)
		return

	_main = packed_scene.instantiate() as Node2D
	root.add_child(_main)
	await _settle()
	_main.call("start_demo")
	await _settle()
	_hide_shell()

	var route_results: Array[Dictionary] = []
	for step: Dictionary in MAIN_ROUTE:
		route_results.append(await _drive_route_step(step))

	var optional_results: Array[Dictionary] = []
	for step: Dictionary in OPTIONAL_ROOMS:
		optional_results.append(await _capture_optional_room(step))

	var waste_route_results: Array[Dictionary] = []
	_main.call("transition_to_room", str(WASTE_ROUTE[0].path), &"stage25_entry_start")
	await _settle()
	_hide_shell()
	for step: Dictionary in WASTE_ROUTE:
		waste_route_results.append(await _drive_route_step(step))

	var coverage := _build_production_room_coverage(route_results, optional_results, waste_route_results)
	if int(coverage.get("expected_count", 0)) != 44:
		_add_issue("P0", "world_map", "unexpected_production_room_count", str(coverage))
	if not Array(coverage.get("missing_paths", [])).is_empty():
		_add_issue("P0", "world_map", "production_rooms_not_covered", str(coverage.get("missing_paths", [])))
	if not Array(coverage.get("unexpected_paths", [])).is_empty():
		_add_issue("P0", "world_map", "non_production_rooms_in_evidence", str(coverage.get("unexpected_paths", [])))

	var snapshot: Dictionary = _main.call("get_demo_progress_snapshot")
	var report := {
		"review_id": "full_content_flow_route_evidence",
		"generated_at": Time.get_datetime_string_from_system(),
		"route_count": route_results.size(),
		"optional_count": optional_results.size(),
		"waste_transition_count": waste_route_results.size(),
		"production_room_coverage": coverage,
		"route": route_results,
		"optional": optional_results,
		"waste_route": waste_route_results,
		"issues": _issues,
		"issue_counts": _count_issues(_issues),
		"final_snapshot": snapshot,
		"boundary": "Production Main / real room transition driver covering 44 world-map rooms. This is automated state/transition evidence, not a human-input route playtest or art approval.",
	}
	_write_text(OUT_JSON, JSON.stringify(report, "\t"))
	_write_text(OUT_MD, _build_markdown(report))
	print("Full flow evidence: %s" % OUT_MD)
	print("Full flow issue counts: %s" % JSON.stringify(report.issue_counts))
	quit(0 if _issues.is_empty() else 1)


func _drive_route_step(step: Dictionary) -> Dictionary:
	_dismiss_detail_panel()
	paused = false
	var expected_path := str(step.path)
	if _room_path() != expected_path:
		_add_issue("P0", str(step.id), "unexpected_room_before_step", "expected=%s actual=%s" % [expected_path, _room_path()])
		_main.call("transition_to_room", expected_path, &"")
		await _settle()
		_hide_shell()

	var captures: Dictionary = {}
	captures.entry = await _capture(str(step.id), "entry")
	await _prepare_room(str(step.id))
	captures.mid = await _capture(str(step.id), "mid")
	await _trigger_room_exit(str(step.id))
	await _settle()
	_hide_shell()
	captures.exit = await _capture(str(step.id), "exit")

	var actual_next := _room_path()
	var expected_next := str(step.expect)
	if not expected_next.is_empty() and actual_next != expected_next:
		_add_issue("P0", str(step.id), "transition_failed", "expected_next=%s actual=%s" % [expected_next, actual_next])

	return {
		"id": str(step.id),
		"path": expected_path,
		"expected_next": expected_next,
		"actual_after_exit": actual_next,
		"screenshots": captures,
		"player": _player_snapshot(),
		"hud": _hud_snapshot(),
	}


func _capture_optional_room(step: Dictionary) -> Dictionary:
	_main.call("transition_to_room", str(step.path), &"")
	await _settle()
	_hide_shell()
	var captures := {
		"entry": await _capture(str(step.id), "entry"),
	}
	await _prepare_room(str(step.id))
	captures.mid = await _capture(str(step.id), "mid")
	captures.exit = await _capture(str(step.id), "exit")
	return {
		"id": str(step.id),
		"path": str(step.path),
		"internal": bool(step.get("internal", false)),
		"screenshots": captures,
		"player": _player_snapshot(),
		"hud": _hud_snapshot(),
	}


func _prepare_room(step_id: String) -> void:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		_add_issue("P0", step_id, "missing_runtime_nodes", "room or player missing")
		return

	if step_id == "tutorial":
		player.global_position = Vector2(-48.0, 32.0)
		await _settle()
		player.global_position = Vector2(252.0, 96.0)
		await _settle()
		var dummy := room.get_node_or_null("TutorialDummy")
		if dummy != null and dummy.has_method("receive_attack"):
			dummy.call("receive_attack", Vector2.RIGHT, 120.0)
		await _settle()
		if player.has_method("cycle_current_stance"):
			player.call("cycle_current_stance")
		await _settle()
		return

	_defeat_targets(room)
	if step_id == "stage25_relay":
		var relay := room.get_node_or_null("StormRelay")
		if relay != null and relay.has_method("receive_elemental_attack"):
			relay.call("receive_elemental_attack", Vector2.RIGHT, 120.0, {
				"element_id": &"thunder",
				"reaction_id": &"wind_thunder_pierce",
			})
	if step_id == "stage25_outlook":
		var thunder_boss := room.get_node_or_null("KuiThunderBoss")
		if thunder_boss != null and thunder_boss.has_method("receive_attack"):
			var hit_count := int(thunder_boss.call("get_max_health")) if thunder_boss.has_method("get_max_health") else 24
			for _hit_index in range(hit_count):
				thunder_boss.call("receive_attack", Vector2.RIGHT, 120.0)
	await _activate_named_nodes(room, player, [
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
	if step_id == "stage16_backtrack" and _main.has_method("collect_stage14_backtrack_reward"):
		_main.call("collect_stage14_backtrack_reward", &"stage14_reward_one")
		_main.call("collect_stage14_backtrack_reward", &"stage14_reward_two")
		_main.call("collect_stage14_backtrack_reward", &"stage14_reward_three")
	await _settle()


func _trigger_room_exit(step_id: String) -> void:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		return

	if step_id == "stage11_end":
		_move_to_node(room, player, "GoalZone")
		await _settle()
		_dismiss_detail_panel()
		paused = false
		await process_frame
		_move_to_node(room, player, "ContinueZone")
		return

	if step_id == "stage15_boss":
		var boss := room.get_node_or_null("SealGuardianBoss")
		if boss != null and boss.has_method("receive_attack"):
			for _i in range(24):
				boss.call("receive_attack", Vector2.RIGHT, 120.0)
		return

	if step_id == "stage16_end":
		_move_to_node(room, player, "ExitZone")
		return
	if step_id == "stage25_fork_branch":
		_move_to_node(room, player, "BranchZone")
		return

	if room.get_node_or_null("GoalZone") != null:
		_move_to_node(room, player, "GoalZone")
		return

	_move_to_node(room, player, "ExitZone")


func _activate_named_nodes(room: Node, player: CharacterBody2D, names: Array[String]) -> void:
	var initial_path := room.scene_file_path if room != null else ""
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
			var hit_count := int(child.call("get_max_health")) if child.has_method("get_max_health") else 1
			for _hit_index in range(maxi(hit_count, 1)):
				child.call("receive_attack", Vector2.RIGHT, 120.0)


func _move_to_node(room: Node, player: CharacterBody2D, node_name: String) -> void:
	var node := room.get_node_or_null(NodePath(node_name)) as Node2D
	if node == null:
		return
	player.global_position = node.global_position


func _capture(step_id: String, phase: String) -> String:
	await _settle()
	var screenshot_path := "%s/%s_%s.png" % [SCREENSHOT_DIR, step_id, phase]
	if DisplayServer.get_name() != "headless":
		var viewport_texture := root.get_texture()
		var viewport_image := viewport_texture.get_image() if viewport_texture != null else null
		if viewport_image != null:
			viewport_image.save_png(screenshot_path)
	return screenshot_path


func _settle() -> void:
	for _i: int in range(4):
		await process_frame
	_dismiss_detail_panel()
	paused = false
	await process_frame


func _hide_shell() -> void:
	var shell := _main.get_node_or_null("HUD/DemoShell")
	if shell == null:
		return
	_dismiss_detail_panel()
	var menu := shell.get_node_or_null("MainMenu") as CanvasItem
	var title := shell.get_node_or_null("TitleBackground") as CanvasItem
	if menu != null:
		menu.visible = false
	if title != null:
		title.visible = false


# 自动路线按正式“返回”按钮确认一次性叙事 / 详情面板，避免暂停树吞掉后续房间信号。
func _dismiss_detail_panel() -> void:
	if _main == null:
		return
	var shell := _main.get_node_or_null("HUD/DemoShell")
	if shell == null:
		return
	var detail_panel := shell.get_node_or_null("DetailPanel") as Control
	if detail_panel == null or not detail_panel.visible:
		return
	var back_button := shell.get_node_or_null(
		"DetailPanel/MarginContainer/VBoxContainer/DetailBackButton"
	) as Button
	if back_button != null:
		back_button.pressed.emit()
	else:
		detail_panel.visible = false


func _room() -> Node2D:
	return _main.get_node_or_null("Room") as Node2D


func _player() -> CharacterBody2D:
	return _main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


func _room_path() -> String:
	var current_room := _room()
	return current_room.scene_file_path if current_room != null else ""


func _player_snapshot() -> Dictionary:
	var player := _player()
	if player == null:
		return {}
	return {
		"position": {"x": player.global_position.x, "y": player.global_position.y},
		"velocity": {"x": player.velocity.x, "y": player.velocity.y},
		"health": player.call("get_current_health") if player.has_method("get_current_health") else null,
	}


func _hud_snapshot() -> Dictionary:
	return {
		"step": _label_text("HUD/TutorialHUD/PromptPanel/StepLabel"),
		"prompt": _label_text("HUD/TutorialHUD/PromptPanel/PromptLabel"),
		"progress": _label_text("HUD/TutorialHUD/BattlePanel/ProgressLabel"),
	}


func _label_text(path: NodePath) -> String:
	var label := _main.get_node_or_null(path) as Label
	return label.text if label != null else ""


func _add_issue(severity: String, room_id: String, code: String, note: String) -> void:
	_issues.append({"severity": severity, "room": room_id, "code": code, "note": note})


func _count_issues(issues: Array[Dictionary]) -> Dictionary:
	var counts := {"P0": 0, "P1": 0, "P2": 0}
	for issue: Dictionary in issues:
		var severity := str(issue.severity)
		counts[severity] = int(counts.get(severity, 0)) + 1
	return counts


# 世界图是生产房间唯一事实源；路线报告不得以旧常量或内部 test_room 凑数。
func _build_production_room_coverage(
	route_results: Array[Dictionary],
	optional_results: Array[Dictionary],
	waste_route_results: Array[Dictionary]
) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WORLD_MAP_LAYOUT))
	var expected_paths: Array[String] = []
	if parsed is Dictionary:
		for room: Dictionary in parsed.get("rooms", []):
			expected_paths.append(String(room.get("path", "")))
	var covered_set: Dictionary = {}
	for rows: Array in [route_results, optional_results, waste_route_results]:
		for row: Dictionary in rows:
			covered_set[String(row.get("path", ""))] = true
	var covered_paths: Array[String] = []
	for path: Variant in covered_set.keys():
		covered_paths.append(String(path))
	expected_paths.sort()
	covered_paths.sort()
	var missing_paths: Array[String] = []
	for path: String in expected_paths:
		if not covered_set.has(path):
			missing_paths.append(path)
	var expected_set: Dictionary = {}
	for path: String in expected_paths:
		expected_set[path] = true
	var unexpected_paths: Array[String] = []
	for path: String in covered_paths:
		if not expected_set.has(path):
			unexpected_paths.append(path)
	return {
		"ok": expected_paths.size() == 44 and missing_paths.is_empty() and unexpected_paths.is_empty(),
		"expected_count": expected_paths.size(),
		"covered_unique_count": covered_paths.size(),
		"expected_paths": expected_paths,
		"covered_paths": covered_paths,
		"missing_paths": missing_paths,
		"unexpected_paths": unexpected_paths,
	}


func _build_markdown(report: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("# Full Content Flow Evidence")
	lines.append("")
	lines.append("- 生成时间：%s" % str(report.generated_at))
	lines.append("- 主线房间：%s" % int(report.route_count))
	lines.append("- 正式支路房：%s" % int(report.optional_count))
	lines.append("- 雷泽转换步骤：%s" % int(report.waste_transition_count))
	lines.append("- 世界图生产房覆盖：%s / %s" % [report.production_room_coverage.covered_unique_count, report.production_room_coverage.expected_count])
	lines.append("- P0 / P1 / P2：%s / %s / %s" % [report.issue_counts.P0, report.issue_counts.P1, report.issue_counts.P2])
	lines.append("- 边界：%s" % str(report.boundary))
	lines.append("")
	lines.append("| Room | Expected Next | Actual After Exit | Entry | Mid | Exit |")
	lines.append("| --- | --- | --- | --- | --- | --- |")
	for row: Dictionary in report.route:
		lines.append("| `%s` | `%s` | `%s` | `%s` | `%s` | `%s` |" % [
			str(row.id),
			str(row.expected_next),
			str(row.actual_after_exit),
			str(row.screenshots.entry),
			str(row.screenshots.mid),
			str(row.screenshots.exit),
		])
	lines.append("")
	lines.append("## Optional Production Rooms")
	lines.append("")
	lines.append("| Room | Path | Internal | Entry | Mid |")
	lines.append("| --- | --- | ---: | --- | --- |")
	for row: Dictionary in report.optional:
		lines.append("| `%s` | `%s` | %s | `%s` | `%s` |" % [
			str(row.id),
			str(row.path),
			bool(row.internal),
			str(row.screenshots.entry),
			str(row.screenshots.mid),
		])
	lines.append("")
	lines.append("## Thunder Waste Route")
	lines.append("")
	lines.append("| Step | Expected Next | Actual After Exit | Entry | Mid | Exit |")
	lines.append("| --- | --- | --- | --- | --- | --- |")
	for row: Dictionary in report.waste_route:
		lines.append("| `%s` | `%s` | `%s` | `%s` | `%s` | `%s` |" % [
			str(row.id),
			str(row.expected_next),
			str(row.actual_after_exit),
			str(row.screenshots.entry),
			str(row.screenshots.mid),
			str(row.screenshots.exit),
		])
	lines.append("")
	lines.append("## Issues")
	lines.append("")
	if _issues.is_empty():
		lines.append("- 无 P0/P1/P2。")
	else:
		for issue: Dictionary in _issues:
			lines.append("- %s `%s` `%s`：%s" % [issue.severity, issue.room, issue.code, issue.note])
	return "\n".join(lines) + "\n"


func _write_text(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write %s" % path)
		return
	file.store_string(content)
