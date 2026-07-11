extends SceneTree

# 降低带正式 Sprite 的道具 Polygon 底板透明度，去掉黄色/绿色方块感。

const DAC_REPORT_PATH := "res://tests/artifacts/local/full-content-demo-qa/dac03_all_content_visual_gate/demo_art_composition_review.json"
const PROP_PLACEHOLDER_NAMES := {
	"TalismanRelayA": true,
	"TalismanRelayB": true,
	"TalismanRelayC": true,
	"SealReleaseNode": true,
	"BacktrackConfirmationNode": true,
	"CompletionSeal": true,
	"AlphaDemoSeal": true,
	"CorruptionPurgeNode": true,
}


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
			continue
		var root := packed_scene.instantiate()
		var touched := _polish_props(root)
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
		print("%s | prop bases=%d" % [scene_path, touched])

	print("DAC prop polygon polish complete: scenes=%d nodes=%d" % [updated_scene_count, updated_node_count])
	quit(0)


func _polish_props(node: Node) -> int:
	var touched := 0
	if node is Polygon2D and PROP_PLACEHOLDER_NAMES.has(str(node.name)):
		var polygon := node as Polygon2D
		var color := polygon.color
		color.a = 0.0
		polygon.color = color
		polygon.set_meta(&"asset_binding_note", "dac_subtle_prop_base_marker")
		touched += 1

	for child: Node in node.get_children():
		touched += _polish_props(child)
	return touched
