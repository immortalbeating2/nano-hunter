extends SceneTree

# 将出口、目标、支路等 Area2D 的调试色块降到极弱提示，避免运行画面出现绿/红大方块。

const DAC_REPORT_PATH := "res://tests/artifacts/local/full-content-demo-qa/dac03_all_content_visual_gate/demo_art_composition_review.json"
const TRIGGER_VISUAL_NAMES := {
	"ZoneVisual": true,
	"GoalVisual": true,
	"ResourceVisual": true,
	"ChallengeVisual": true,
	"BranchVisual": true,
	"ReplayVisual": true,
	"ContinueVisual": true,
}
const SUBTLE_TRIGGER_ALPHA := 0.025


func _init() -> void:
	var report_file := FileAccess.open(DAC_REPORT_PATH, FileAccess.READ)
	if report_file == null:
		push_error("DAC report missing: %s" % DAC_REPORT_PATH)
		quit(1)
		return
	var parsed: Variant = JSON.parse_string(report_file.get_as_text())
	if not (parsed is Dictionary) or not parsed.has("rooms"):
		push_error("DAC report has no rooms array: %s" % DAC_REPORT_PATH)
		quit(1)
		return

	var updated_scene_count := 0
	var updated_node_count := 0
	for room: Dictionary in parsed.rooms:
		var scene_path := str(room.get("path", ""))
		if scene_path.is_empty():
			continue
		var packed_scene := load(scene_path) as PackedScene
		if packed_scene == null:
			push_warning("Skip missing scene: %s" % scene_path)
			continue
		var root := packed_scene.instantiate()
		var touched := _polish_triggers(root)
		if touched <= 0:
			root.free()
			continue

		var repacked := PackedScene.new()
		var pack_result := repacked.pack(root)
		root.free()
		if pack_result != OK:
			push_error("Failed to pack scene %s: %s" % [scene_path, pack_result])
			quit(1)
			return
		var save_result := ResourceSaver.save(repacked, scene_path)
		if save_result != OK:
			push_error("Failed to save scene %s: %s" % [scene_path, save_result])
			quit(1)
			return
		updated_scene_count += 1
		updated_node_count += touched
		print("%s | trigger visuals=%d" % [scene_path, touched])

	print("DAC trigger visual polish complete: scenes=%d nodes=%d" % [updated_scene_count, updated_node_count])
	quit(0)


func _polish_triggers(node: Node) -> int:
	var touched := 0
	if node is Polygon2D and TRIGGER_VISUAL_NAMES.has(str(node.name)):
		var polygon := node as Polygon2D
		var color := polygon.color
		color.a = SUBTLE_TRIGGER_ALPHA
		polygon.color = color
		polygon.set_meta(&"asset_binding_note", "dac_subtle_trigger_readability_marker")
		touched += 1

	for child: Node in node.get_children():
		touched += _polish_triggers(child)
	return touched
