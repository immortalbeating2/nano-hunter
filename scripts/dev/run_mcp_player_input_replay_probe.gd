extends SceneTree

# 运行已有 input-only replay probe。
# ponytail: wrapper 只负责启动 Main 和等待 probe，导航逻辑仍在 mcp_player_input_replay_probe.gd。

const MAIN_SCENE := "res://scenes/main/main.tscn"
const PROBE_SCRIPT := "res://scripts/dev/mcp_player_input_replay_probe.gd"
const REPORT_JSON := "res://tests/artifacts/local/full-content-demo-qa/mcp_2026_07_01/player_input_replay/player_input_replay_probe.json"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(640, 360)
	var main := load(MAIN_SCENE).instantiate() as Node2D
	root.add_child(main)
	await _settle()

	var shell := main.get_node_or_null("HUD/DemoShell")
	if shell != null and shell.has_method("start_demo"):
		shell.call("start_demo")
	await _settle()

	var probe: Node = (load(PROBE_SCRIPT) as Script).new()
	root.add_child(probe)
	probe.start(main)
	while not probe.is_finished():
		await process_frame

	var exit_code := 0
	var report_file := FileAccess.open(REPORT_JSON, FileAccess.READ)
	if report_file == null:
		push_error("Missing replay report: %s" % REPORT_JSON)
		exit_code = 1
	else:
		var parsed: Variant = JSON.parse_string(report_file.get_as_text())
		var counts: Dictionary = parsed.get("issue_counts", {}) if parsed is Dictionary else {}
		if int(counts.get("P0", 0)) > 0 or int(counts.get("P1", 0)) > 0:
			exit_code = 1
		print("input_replay_done=%s issue_counts=%s rooms_seen=%s" % [
			parsed.get("done", false) if parsed is Dictionary else false,
			JSON.stringify(counts),
			parsed.get("rooms_seen", 0) if parsed is Dictionary else 0,
		])
	quit(exit_code)


func _settle() -> void:
	for _i: int in range(6):
		await process_frame
