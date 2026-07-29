extends SceneTree

# 验证 P0 runtime replacement rehearsal 场景中的资源绑定。

const MANIFEST_PATH := "res://docs/assets/p0-runtime-replacement-rehearsal-manifest.json"
const PLAN_PATH := "res://docs/assets/p0-runtime-replacement-plan.json"


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：加载场景、核对 manifest、递归验证节点资源。
func _run() -> int:
	var manifest := _read_json(MANIFEST_PATH)
	if manifest.is_empty():
		return 1
	var plan := _read_json(PLAN_PATH)
	if plan.is_empty():
		return 1
	var expected_counts := _expected_counts(plan)

	var counts: Dictionary = manifest.get("counts", {})
	for key: String in expected_counts.keys():
		var expected := int(expected_counts[key])
		var actual := int(counts.get(key, -1))
		if actual != expected:
			push_error("P0 rehearsal manifest count mismatch for %s: expected %s got %s" % [key, expected, actual])
			return 1

	var scene_path := String(manifest.get("scene", ""))
	var scene := ResourceLoader.load(scene_path)
	if scene == null or not scene is PackedScene:
		push_error("Cannot load P0 runtime replacement rehearsal scene: %s" % scene_path)
		return 1
	var instance := (scene as PackedScene).instantiate()
	if instance == null:
		push_error("Cannot instantiate P0 runtime replacement rehearsal scene: %s" % scene_path)
		return 1
	if not instance.has_meta("p0_runtime_replacement_rehearsal_scene"):
		push_error("P0 runtime replacement rehearsal root missing metadata.")
		instance.free()
		return 1

	var actual_counts := {
		"entry_count": 0,
		"texture2d_nodes": 0,
		"spriteframes_nodes": 0,
		"tileset_nodes": 0,
		"stylebox_nodes": 0,
		"atlastexture_nodes": 0,
	}
	if not _audit_recursive(instance, actual_counts):
		instance.free()
		return 1
	for key: String in expected_counts.keys():
		var expected := int(expected_counts[key])
		var actual := int(actual_counts.get(key, -1))
		if actual != expected:
			push_error("P0 rehearsal scene count mismatch for %s: expected %s got %s" % [key, expected, actual])
			instance.free()
			return 1

	print("P0 runtime replacement rehearsal OK: %s nodes" % actual_counts["entry_count"])
	instance.free()
	return 0


# 从当前 P0 运行计划推导排练节点数量，避免历史固定数量掩盖计划收缩。
func _expected_counts(plan: Dictionary) -> Dictionary:
	var counts := {
		"entry_count": 0,
		"texture2d_nodes": 0,
		"spriteframes_nodes": 0,
		"tileset_nodes": 0,
		"stylebox_nodes": 0,
		"atlastexture_nodes": 0,
	}
	for entry: Dictionary in plan.get("entries", []):
		counts["entry_count"] = int(counts["entry_count"]) + 1
		match String(entry.get("catalog_resource_type", "unknown")):
			"SpriteFrames":
				counts["spriteframes_nodes"] = int(counts["spriteframes_nodes"]) + 1
			"TileSet":
				counts["tileset_nodes"] = int(counts["tileset_nodes"]) + 1
			"StyleBoxTexture":
				counts["stylebox_nodes"] = int(counts["stylebox_nodes"]) + 1
			"AtlasTexture":
				counts["atlastexture_nodes"] = int(counts["atlastexture_nodes"]) + 1
			_:
				counts["texture2d_nodes"] = int(counts["texture2d_nodes"]) + 1
	return counts


# 递归验证所有 rehearsal 节点。
func _audit_recursive(node: Node, counts: Dictionary) -> bool:
	if node.has_meta("p0_rehearsal_kind"):
		var kind := String(node.get_meta("p0_rehearsal_kind"))
		counts["entry_count"] = int(counts["entry_count"]) + 1
		match kind:
			"texture2d":
				if not _audit_texture_node(node):
					return false
				counts["texture2d_nodes"] = int(counts["texture2d_nodes"]) + 1
			"atlastexture":
				if not _audit_texture_node(node):
					return false
				counts["atlastexture_nodes"] = int(counts["atlastexture_nodes"]) + 1
			"spriteframes":
				if not _audit_spriteframes_node(node):
					return false
				counts["spriteframes_nodes"] = int(counts["spriteframes_nodes"]) + 1
			"tileset":
				if not _audit_tileset_node(node):
					return false
				counts["tileset_nodes"] = int(counts["tileset_nodes"]) + 1
			"stylebox":
				if not _audit_stylebox_node(node):
					return false
				counts["stylebox_nodes"] = int(counts["stylebox_nodes"]) + 1
			_:
				push_error("Unknown P0 rehearsal kind: %s" % kind)
				return false
	for child: Node in node.get_children():
		if not _audit_recursive(child, counts):
			return false
	return true


# 验证 Sprite2D 纹理节点。
func _audit_texture_node(node: Node) -> bool:
	var sprite := node as Sprite2D
	if sprite == null or sprite.texture == null:
		push_error("Invalid rehearsal texture node: %s" % node.name)
		return false
	if sprite.texture.get_width() <= 0 or sprite.texture.get_height() <= 0:
		push_error("Rehearsal texture has invalid size: %s" % node.name)
		return false
	return true


# 验证 AnimatedSprite2D 节点。
func _audit_spriteframes_node(node: Node) -> bool:
	var animated := node as AnimatedSprite2D
	if animated == null or animated.sprite_frames == null:
		push_error("Invalid rehearsal SpriteFrames node: %s" % node.name)
		return false
	if animated.animation.is_empty():
		push_error("Rehearsal AnimatedSprite2D missing animation: %s" % node.name)
		return false
	if animated.sprite_frames.get_frame_count(animated.animation) <= 0:
		push_error("Rehearsal AnimatedSprite2D has no frames: %s" % node.name)
		return false
	return true


# 验证 TileMapLayer 节点。
func _audit_tileset_node(node: Node) -> bool:
	var layer := node as TileMapLayer
	if layer == null or layer.tile_set == null:
		push_error("Invalid rehearsal TileMapLayer node: %s" % node.name)
		return false
	if layer.tile_set.get_source_count() <= 0:
		push_error("Rehearsal TileSet has no sources: %s" % node.name)
		return false
	if layer.get_used_cells().is_empty():
		push_error("Rehearsal TileMapLayer has no cells: %s" % node.name)
		return false
	return true


# 验证 StyleBoxTexture 节点。
func _audit_stylebox_node(node: Node) -> bool:
	var panel := node as PanelContainer
	if panel == null:
		push_error("Invalid rehearsal StyleBox node: %s" % node.name)
		return false
	if not panel.has_theme_stylebox_override("panel"):
		push_error("Rehearsal StyleBox panel missing override: %s" % node.name)
		return false
	var stylebox := panel.get_theme_stylebox("panel")
	if stylebox == null or not stylebox is StyleBoxTexture:
		push_error("Rehearsal StyleBox panel override invalid: %s" % node.name)
		return false
	return true


# 读取 JSON 并确保顶层为 Dictionary。
func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing JSON file: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open JSON file: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("JSON is not a dictionary: %s" % path)
		return {}
	return parsed
