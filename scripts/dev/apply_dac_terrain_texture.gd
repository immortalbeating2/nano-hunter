extends SceneTree

# 将 DAC 审计覆盖房间中的连续碰撞 underlay 从纯色 Polygon2D 升级为贴图 Polygon2D。
# 这一步只改变视觉材质，不改变 StaticBody2D / CollisionShape2D / 房间推进逻辑。

const DAC_REPORT_PATH := "res://tests/artifacts/local/full-content-demo-qa/dac03_all_content_visual_gate/demo_art_composition_review.json"
const TERRAIN_TEXTURE_PATH := "res://assets/art/textures/dac_continuous_stone_underlay.png"
const TERRAIN_NODE_NAMES := {
	"FloorVisual": true,
	"PlatformVisual": true,
	"DaisVisual": true,
	"CeilingVisual": true,
	"WallVisual": true,
}
const TEXTURED_TERRAIN_NOTE := "dac_textured_terrain_underlay_staticbody_author"
const TERRAIN_UNDERLAY_ALPHA := 0.16


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

	var terrain_texture := load(TERRAIN_TEXTURE_PATH) as Texture2D
	if terrain_texture == null:
		push_error("Terrain texture missing: %s" % TERRAIN_TEXTURE_PATH)
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
		var touched := _apply_texture(root, terrain_texture)
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
		print("%s | textured terrain nodes=%d" % [scene_path, touched])

	print("DAC terrain texture pass complete: scenes=%d nodes=%d" % [updated_scene_count, updated_node_count])
	quit(0)


func _apply_texture(node: Node, terrain_texture: Texture2D) -> int:
	var touched := 0
	if node is Polygon2D and TERRAIN_NODE_NAMES.has(str(node.name)):
		var polygon := node as Polygon2D
		if polygon.visible:
			polygon.texture = terrain_texture
			polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
			polygon.texture_scale = Vector2(1.0, 1.0)
			polygon.color = Color(1.0, 1.0, 1.0, TERRAIN_UNDERLAY_ALPHA)
			polygon.set_meta(&"asset_binding_note", TEXTURED_TERRAIN_NOTE)
			touched += 1

	for child: Node in node.get_children():
		touched += _apply_texture(child, terrain_texture)
	return touched
