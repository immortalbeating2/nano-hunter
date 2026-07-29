extends SceneTree

# Alpha Demo 正式关卡重排运行态复核：
# 使用生产 Main.tscn 验证样板房正向推进、左侧返回、出入口地面覆盖和强视觉读值。

const OUT_DIR := "res://tests/artifacts/local/demo-level-formal-remap/phase06_mcp_review"
const SCREENSHOT_DIR := "%s/screenshots" % OUT_DIR
const OUT_MD := "%s/demo_formal_remap_mcp_review.md" % OUT_DIR
const OUT_JSON := "%s/demo_formal_remap_mcp_review.json" % OUT_DIR
const MAIN_SCENE := "res://scenes/main/main.tscn"
const MCP_BOUNDARY := "Godot MCP Pro direct tool get_project_info returned editor-not-connected in this Codex session; CLI project info succeeded and this script ran production Main.tscn."
const STAGE14_SHRINE_RUNTIME_TEXTURE := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/001_shrine_gate_prop_atlas_ai01_auto_002_c01.atlas_texture.tres"
const STAGE14_GATE_LOCKED_TEXTURE := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres"
const STAGE16_RELAY_GATE_LOCKED_TEXTURE := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres"

const REVIEW_LINKS := [
	{
		"id": "combat_to_tutorial",
		"room": "res://scenes/rooms/combat_trial_room.tscn",
		"spawn": &"combat_entry",
		"expected_forward": "res://scenes/rooms/goal_trial_room.tscn",
		"expected_previous": "res://scenes/rooms/tutorial_room.tscn",
	},
	{
		"id": "goal_to_combat",
		"room": "res://scenes/rooms/goal_trial_room.tscn",
		"spawn": &"goal_entry",
		"expected_forward": "res://scenes/rooms/stage9_zone_entry_room.tscn",
		"expected_previous": "res://scenes/rooms/combat_trial_room.tscn",
	},
	{
		"id": "stage9_entry_to_goal",
		"room": "res://scenes/rooms/stage9_zone_entry_room.tscn",
		"spawn": &"zone_entry_start",
		"expected_forward": "res://scenes/rooms/stage9_zone_combat_room.tscn",
		"expected_previous": "res://scenes/rooms/goal_trial_room.tscn",
	},
	{
		"id": "stage13_caster_to_entry",
		"room": "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn",
		"spawn": &"stage13_miasma_start",
		"expected_forward": "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn",
		"expected_previous": "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn",
	},
	{
		"id": "stage14_gate_to_shrine",
		"room": "res://scenes/rooms/stage14_air_dash_gate_room.tscn",
		"spawn": &"stage14_air_dash_gate_start",
		"expected_forward": "res://scenes/rooms/stage14_backtrack_hub_room.tscn",
		"expected_previous": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn",
	},
	{
		"id": "stage16_relay_to_threshold",
		"room": "res://scenes/rooms/stage16_talisman_relay_room.tscn",
		"spawn": &"stage16_talisman_relay_start",
		"expected_forward": "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn",
		"expected_previous": "res://scenes/rooms/stage16_seal_release_threshold_room.tscn",
	},
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
	if _main.has_method("start_demo"):
		_main.call("start_demo")
	await _settle()
	_hide_demo_shell()

	var rows: Array[Dictionary] = []
	for link: Dictionary in REVIEW_LINKS:
		rows.append(await _review_link(link))

	var report := {
		"project_path": ProjectSettings.globalize_path("res://"),
		"main_scene": MAIN_SCENE,
		"generated_at": Time.get_datetime_string_from_system(),
		"rooms_reviewed": rows.size(),
		"bidirectional_pass_count": _count_bidirectional_passes(rows),
		"route_end_safety_issues": _count_issue_code("route_end_safety"),
		"visual_readability_issues": _count_issue_code("visual_readability"),
		"mcp_direct_or_cli_boundary": MCP_BOUNDARY,
		"rows": rows,
		"issues": _issues,
		"issue_counts": _count_issues(),
	}
	_write_text(OUT_JSON, JSON.stringify(report, "\t"))
	_write_text(OUT_MD, _build_markdown(report))
	print("Formal remap MCP review: %s" % OUT_MD)
	print("Formal remap issue counts: %s" % JSON.stringify(report.issue_counts))
	quit(0 if _issues.is_empty() else 1)


func _review_link(link: Dictionary) -> Dictionary:
	var id := str(link.id)
	var room_path := str(link.room)
	var expected_forward := str(link.expected_forward)
	var expected_previous := str(link.expected_previous)
	var screenshots := {}

	_main.call("transition_to_room", room_path, link.spawn)
	await _settle()
	_hide_demo_shell()
	screenshots.entry = await _capture(id, "entry")
	_inspect_current_room(id)
	if id == "stage14_gate_to_shrine":
		screenshots.gate_focus = await _capture_stage14_gate_focus(id)

	await _prepare_forward_progress(id)
	await _move_to_right_transition()
	await _settle()
	_hide_demo_shell()
	var actual_forward := _room_path()
	screenshots.right_exit = await _capture(id, "right_exit")
	if actual_forward != expected_forward:
		_add_issue("P0", id, "forward_transition_failed", "expected=%s actual=%s" % [expected_forward, actual_forward])

	_main.call("transition_to_room", room_path, link.spawn)
	await _settle()
	_hide_demo_shell()
	await _move_to_left_return()
	await _settle()
	_hide_demo_shell()
	var actual_previous := _room_path()
	screenshots.left_return = await _capture(id, "left_return")
	if actual_previous != expected_previous:
		_add_issue("P0", id, "previous_transition_failed", "expected=%s actual=%s" % [expected_previous, actual_previous])

	return {
		"id": id,
		"room": room_path,
		"expected_forward": expected_forward,
		"actual_forward": actual_forward,
		"expected_previous": expected_previous,
		"actual_previous": actual_previous,
		"bidirectional_pass": actual_forward == expected_forward and actual_previous == expected_previous,
		"screenshots": screenshots,
	}


func _inspect_current_room(id: String) -> void:
	var room := _room()
	if room == null:
		_add_issue("P0", id, "missing_room", "Main has no current Room node")
		return

	var left_exit := room.get_node_or_null("LeftExitZone") as Node2D
	if left_exit == null:
		_add_issue("P0", id, "missing_left_exit", "room lacks LeftExitZone")
	else:
		_check_floor_covers_edges(id, left_exit)

	for polygon: Polygon2D in _find_polygons(room):
		if not polygon.visible:
			continue
		var node_name := polygon.name.to_lower()
		var is_goal_or_gate := node_name.find("goal") >= 0 or node_name.find("barrier") >= 0 or node_name.find("ledge") >= 0
		var is_solid_green := polygon.color.g > 0.55 and polygon.color.r < 0.35 and polygon.color.a >= 0.5
		if is_goal_or_gate and is_solid_green:
			_add_issue("P1", id, "visual_readability", "solid green placeholder polygon: %s" % str(polygon.get_path()))

	if id == "stage14_gate_to_shrine":
		_check_sprite_texture(id, room, "AirDashGateSensor/ShrineEchoArt", STAGE14_SHRINE_RUNTIME_TEXTURE)
		_check_sprite_texture(id, room, "GateBarrier/GateArt", STAGE14_GATE_LOCKED_TEXTURE)
	if id == "stage16_relay_to_threshold":
		_check_sprite_texture(id, room, "GateBarrier/GateArt", STAGE16_RELAY_GATE_LOCKED_TEXTURE)


func _check_sprite_texture(id: String, room: Node, node_path: String, expected_texture: String) -> void:
	var sprite := room.get_node_or_null(NodePath(node_path)) as Sprite2D
	if sprite == null:
		_add_issue("P1", id, "visual_readability", "missing runtime art node: %s" % node_path)
		return
	if sprite.texture == null:
		_add_issue("P1", id, "visual_readability", "missing runtime art texture: %s" % node_path)
		return
	if sprite.texture.resource_path != expected_texture:
		_add_issue(
			"P1",
			id,
			"visual_readability",
			"unexpected runtime art texture: %s actual=%s expected=%s" % [
				node_path,
				sprite.texture.resource_path,
				expected_texture,
			]
		)


func _capture_stage14_gate_focus(id: String) -> String:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		return ""
	var gate := room.get_node_or_null("GateBarrier") as Node2D
	if gate != null:
		player.global_position = gate.global_position + Vector2(-120.0, 36.0)
		await _settle()
	return await _capture(id, "gate_focus")


func _check_floor_covers_edges(id: String, left_exit: Node2D) -> void:
	var room := _room()
	var floor := room.get_node_or_null("Floor") as StaticBody2D
	var floor_shape := room.get_node_or_null("Floor/CollisionShape2D") as CollisionShape2D
	var right_target := _right_transition_zone(room)
	if floor == null or floor_shape == null or right_target == null:
		_add_issue("P0", id, "route_end_safety", "missing Floor, Floor collision, or right transition node")
		return

	var rectangle := floor_shape.shape as RectangleShape2D
	if rectangle == null:
		_add_issue("P0", id, "route_end_safety", "Floor collision is not RectangleShape2D")
		return

	var floor_left_edge := floor.position.x - rectangle.size.x * 0.5
	var floor_right_edge := floor.position.x + rectangle.size.x * 0.5
	if floor_left_edge > left_exit.position.x + 36.0:
		_add_issue("P0", id, "route_end_safety", "floor does not cover left return edge")
	if floor_right_edge < right_target.position.x - 36.0:
		_add_issue("P0", id, "route_end_safety", "floor does not cover right transition edge")


func _prepare_forward_progress(id: String) -> void:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		return

	if id == "stage14_gate_to_shrine" and _main.has_method("unlock_air_dash"):
		_main.call("unlock_air_dash")

	_defeat_targets(room)
	await _activate_named_nodes(room, player, [
		"AirDashGateSensor",
		"SealReleaseNode",
		"TalismanRelayA",
		"TalismanRelayB",
		"TalismanRelayC",
	])
	if room.has_method("unlock_gate") and id not in ["stage14_gate_to_shrine", "stage16_relay_to_threshold"]:
		room.call("unlock_gate", &"clear")
	await _settle()


func _move_to_right_transition() -> void:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		return

	var target := _right_transition_zone(room)
	if target != null:
		player.global_position = target.global_position


func _move_to_left_return() -> void:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		return

	var left_exit := room.get_node_or_null("LeftExitZone") as Node2D
	if left_exit != null:
		player.global_position = left_exit.global_position


func _right_transition_zone(room: Node) -> Node2D:
	var exit_zone := room.get_node_or_null("ExitZone") as Node2D
	if exit_zone != null:
		return exit_zone

	return room.get_node_or_null("GoalZone") as Node2D


func _activate_named_nodes(room: Node, player: CharacterBody2D, names: Array[String]) -> void:
	for node_name: String in names:
		if not is_instance_valid(room) or not is_instance_valid(player):
			return
		var marker := room.get_node_or_null(NodePath(node_name)) as Node2D
		if marker == null:
			continue
		player.global_position = marker.global_position
		await _settle()


func _defeat_targets(room: Node) -> void:
	for child: Node in room.get_children():
		if child.has_method("receive_attack"):
			child.call("receive_attack", Vector2.RIGHT, 120.0)


func _find_polygons(root_node: Node) -> Array[Polygon2D]:
	var result: Array[Polygon2D] = []
	var stack: Array[Node] = [root_node]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is Polygon2D:
			result.append(node as Polygon2D)
		for child: Node in node.get_children():
			stack.append(child)
	return result


func _capture(id: String, phase: String) -> String:
	await _settle()
	var screenshot_path := "%s/%s_%s.png" % [SCREENSHOT_DIR, id, phase]
	if DisplayServer.get_name() != "headless":
		var viewport_texture := root.get_texture()
		var viewport_image := viewport_texture.get_image() if viewport_texture != null else null
		if viewport_image != null:
			viewport_image.save_png(screenshot_path)
	return screenshot_path


func _settle() -> void:
	for _i: int in range(4):
		await process_frame


func _hide_demo_shell() -> void:
	var shell := _main.get_node_or_null("HUD/DemoShell")
	if shell == null:
		return
	for path: NodePath in ["MainMenu", "TitleBackground"]:
		var item := shell.get_node_or_null(path) as CanvasItem
		if item != null:
			item.visible = false


func _room() -> Node2D:
	return _main.get_node_or_null("Room") as Node2D


func _player() -> CharacterBody2D:
	return _main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


func _room_path() -> String:
	var current_room := _room()
	return current_room.scene_file_path if current_room != null else ""


func _count_bidirectional_passes(rows: Array[Dictionary]) -> int:
	var count := 0
	for row: Dictionary in rows:
		if bool(row.bidirectional_pass):
			count += 1
	return count


func _count_issue_code(code: String) -> int:
	var count := 0
	for issue: Dictionary in _issues:
		if str(issue.code) == code:
			count += 1
	return count


func _count_issues() -> Dictionary:
	var counts := {"P0": 0, "P1": 0, "P2": 0}
	for issue: Dictionary in _issues:
		var severity := str(issue.severity)
		counts[severity] = int(counts.get(severity, 0)) + 1
	return counts


func _add_issue(severity: String, room_id: String, code: String, note: String) -> void:
	_issues.append({"severity": severity, "room": room_id, "code": code, "note": note})


func _build_markdown(report: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("# Alpha Demo Formal Remap MCP Review")
	lines.append("")
	lines.append("- project_path: `%s`" % str(report.project_path))
	lines.append("- main_scene: `%s`" % str(report.main_scene))
	lines.append("- generated_at: `%s`" % str(report.generated_at))
	lines.append("- rooms_reviewed: `%s`" % int(report.rooms_reviewed))
	lines.append("- bidirectional_pass_count: `%s`" % int(report.bidirectional_pass_count))
	lines.append("- route_end_safety_issues: `%s`" % int(report.route_end_safety_issues))
	lines.append("- visual_readability_issues: `%s`" % int(report.visual_readability_issues))
	lines.append("- MCP_direct_or_CLI_boundary: %s" % str(report.mcp_direct_or_cli_boundary))
	lines.append("")
	lines.append("| Room | Forward | Previous | Pass | Entry | Right Exit | Left Return |")
	lines.append("| --- | --- | --- | ---: | --- | --- | --- |")
	for row: Dictionary in report.rows:
		lines.append("| `%s` | `%s` -> `%s` | `%s` -> `%s` | %s | `%s` | `%s` | `%s` |" % [
			str(row.id),
			str(row.expected_forward),
			str(row.actual_forward),
			str(row.expected_previous),
			str(row.actual_previous),
			bool(row.bidirectional_pass),
			str(row.screenshots.entry),
			str(row.screenshots.right_exit),
			str(row.screenshots.left_return),
		])
	lines.append("")
	lines.append("## Issues")
	lines.append("")
	if _issues.is_empty():
		lines.append("- 无 P0/P1/P2。")
	else:
		for issue: Dictionary in _issues:
			lines.append("- %s `%s` `%s`: %s" % [issue.severity, issue.room, issue.code, issue.note])
	return "\n".join(lines) + "\n"


func _write_text(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write %s" % path)
		return
	file.store_string(content)
