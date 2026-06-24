extends SceneTree

# 加载 image gen 资产接入演示场景，验证资源已被真实 Godot 节点消费。

const MANIFEST_PATH := "res://docs/assets/imagegen-asset-integration-showcase-manifest.json"
const EXPECTED_COUNTS := {
	"animated_sprite_nodes": 10,
	"tilemap_layer_nodes": 2,
	"stylebox_nodes": 4,
	"atlas_sprite_nodes": 8,
}


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：加载场景、检查 manifest 计数、递归验证各类节点。
func _run() -> int:
	var manifest := _read_json(MANIFEST_PATH)
	if manifest.is_empty():
		return 1

	var scene_path := String(manifest.get("scene", ""))
	var scene := ResourceLoader.load(scene_path)
	if scene == null or not scene is PackedScene:
		push_error("Cannot load integration showcase scene: %s" % scene_path)
		return 1
	var instance := (scene as PackedScene).instantiate()
	if instance == null:
		push_error("Cannot instantiate integration showcase scene: %s" % scene_path)
		return 1
	if not instance.has_meta("imagegen_asset_integration_showcase"):
		push_error("Integration showcase root missing metadata.")
		instance.free()
		return 1

	var manifest_counts: Dictionary = manifest.get("counts", {})
	for key: String in EXPECTED_COUNTS.keys():
		var expected := int(EXPECTED_COUNTS[key])
		var actual := int(manifest_counts.get(key, -1))
		if actual != expected:
			push_error("Manifest count mismatch for %s: expected %s got %s" % [key, expected, actual])
			instance.free()
			return 1

	var counts := {
		"animated_sprite_nodes": 0,
		"tilemap_layer_nodes": 0,
		"stylebox_nodes": 0,
		"atlas_sprite_nodes": 0,
	}
	if not _audit_node_recursive(instance, counts):
		instance.free()
		return 1
	for key: String in EXPECTED_COUNTS.keys():
		var expected := int(EXPECTED_COUNTS[key])
		var actual := int(counts.get(key, -1))
		if actual != expected:
			push_error("Scene count mismatch for %s: expected %s got %s" % [key, expected, actual])
			instance.free()
			return 1

	print("Imagegen asset integration showcase OK: %s" % scene_path)
	instance.free()
	return 0


# 递归验证所有带 integration_kind 元数据的节点。
func _audit_node_recursive(node: Node, counts: Dictionary) -> bool:
	if node.has_meta("integration_kind"):
		var kind := String(node.get_meta("integration_kind"))
		match kind:
			"animated_sprite":
				if not _audit_animated_sprite(node):
					return false
				counts["animated_sprite_nodes"] = int(counts["animated_sprite_nodes"]) + 1
			"tilemap_layer":
				if not _audit_tilemap_layer(node):
					return false
				counts["tilemap_layer_nodes"] = int(counts["tilemap_layer_nodes"]) + 1
			"stylebox_panel":
				if not _audit_stylebox_panel(node):
					return false
				counts["stylebox_nodes"] = int(counts["stylebox_nodes"]) + 1
			"atlas_sprite":
				if not _audit_atlas_sprite(node):
					return false
				counts["atlas_sprite_nodes"] = int(counts["atlas_sprite_nodes"]) + 1
			_:
				push_error("Unknown integration kind: %s" % kind)
				return false
	for child: Node in node.get_children():
		if not _audit_node_recursive(child, counts):
			return false
	return true


# 验证 AnimatedSprite2D 确实绑定 SpriteFrames，并且动画至少有一帧。
func _audit_animated_sprite(node: Node) -> bool:
	var animated := node as AnimatedSprite2D
	if animated == null or animated.sprite_frames == null:
		push_error("Invalid AnimatedSprite2D integration node: %s" % node.name)
		return false
	if animated.animation.is_empty():
		push_error("AnimatedSprite2D missing animation: %s" % node.name)
		return false
	if animated.sprite_frames.get_frame_count(animated.animation) <= 0:
		push_error("AnimatedSprite2D animation has no frames: %s" % node.name)
		return false
	return true


# 验证 TileMapLayer 绑定 TileSet 并放置了 tile。
func _audit_tilemap_layer(node: Node) -> bool:
	var layer := node as TileMapLayer
	if layer == null or layer.tile_set == null:
		push_error("Invalid TileMapLayer integration node: %s" % node.name)
		return false
	if layer.tile_set.get_source_count() <= 0:
		push_error("TileMapLayer TileSet has no sources: %s" % node.name)
		return false
	if layer.get_used_cells().is_empty():
		push_error("TileMapLayer has no used cells: %s" % node.name)
		return false
	return true


# 验证 PanelContainer 绑定 StyleBoxTexture。
func _audit_stylebox_panel(node: Node) -> bool:
	var panel := node as PanelContainer
	if panel == null:
		push_error("Invalid stylebox panel node: %s" % node.name)
		return false
	if not panel.has_theme_stylebox_override("panel"):
		push_error("Stylebox panel missing override: %s" % node.name)
		return false
	var stylebox := panel.get_theme_stylebox("panel")
	if stylebox == null or not stylebox is StyleBoxTexture:
		push_error("Stylebox panel override is not StyleBoxTexture: %s" % node.name)
		return false
	var stylebox_texture := stylebox as StyleBoxTexture
	if stylebox_texture.texture == null:
		push_error("StyleBoxTexture missing backing texture: %s" % node.name)
		return false
	return true


# 验证 Sprite2D 绑定 AtlasTexture / Texture2D。
func _audit_atlas_sprite(node: Node) -> bool:
	var sprite := node as Sprite2D
	if sprite == null or sprite.texture == null:
		push_error("Invalid atlas sprite node: %s" % node.name)
		return false
	if sprite.texture.get_width() <= 0 or sprite.texture.get_height() <= 0:
		push_error("Atlas sprite texture has invalid size: %s" % node.name)
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
