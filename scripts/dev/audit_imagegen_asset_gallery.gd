extends SceneTree

# 加载 image gen 资产 Gallery 场景与 manifest，验证 Godot 编辑器预览入口可用。

const MANIFEST_PATH := "res://docs/assets/imagegen-asset-gallery-manifest.json"
const EXPECTED_COUNTS := {
	"queue_outputs": 55,
	"atlas_textures": 302,
	"tilesets": 2,
	"styleboxes": 8,
	"spine_parts": 48,
}


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：检查 manifest、加载 PackedScene，并确认核心计数没有漂移。
func _run() -> int:
	var manifest := _read_json(MANIFEST_PATH)
	if manifest.is_empty():
		return 1

	var scene_path := String(manifest.get("scene", ""))
	var scene := ResourceLoader.load(scene_path)
	if scene == null or not scene is PackedScene:
		push_error("Cannot load imagegen asset gallery scene: %s" % scene_path)
		return 1
	var instance := (scene as PackedScene).instantiate()
	if instance == null:
		push_error("Cannot instantiate imagegen asset gallery scene: %s" % scene_path)
		return 1
	if not instance.has_meta("asset_gallery_scene"):
		push_error("Gallery scene root missing asset_gallery_scene metadata.")
		instance.free()
		return 1

	var counts: Dictionary = manifest.get("counts", {})
	for key: String in EXPECTED_COUNTS.keys():
		var expected := int(EXPECTED_COUNTS[key])
		var actual := int(counts.get(key, -1))
		if actual != expected:
			push_error("Gallery count mismatch for %s: expected %s got %s" % [key, expected, actual])
			instance.free()
			return 1

	var preview_counts := _count_preview_nodes(instance)
	if int(preview_counts.get("queue_output", 0)) != int(EXPECTED_COUNTS["queue_outputs"]):
		push_error("Queue preview node count mismatch: %s" % preview_counts)
		instance.free()
		return 1
	if int(preview_counts.get("atlas_texture", 0)) != int(EXPECTED_COUNTS["atlas_textures"]):
		push_error("AtlasTexture preview node count mismatch: %s" % preview_counts)
		instance.free()
		return 1
	if int(preview_counts.get("tileset_sheet", 0)) != int(EXPECTED_COUNTS["tilesets"]):
		push_error("TileSet preview node count mismatch: %s" % preview_counts)
		instance.free()
		return 1
	if int(preview_counts.get("stylebox", 0)) != int(EXPECTED_COUNTS["styleboxes"]):
		push_error("StyleBox preview node count mismatch: %s" % preview_counts)
		instance.free()
		return 1
	if int(preview_counts.get("spine_cutout", 0)) != 2:
		push_error("Spine cutout preview asset count mismatch: %s" % preview_counts)
		instance.free()
		return 1

	var resource_counts := {"texture_previews": 0, "stylebox_previews": 0}
	if not _audit_preview_resources(instance, resource_counts):
		instance.free()
		return 1
	var expected_texture_previews := (
		int(EXPECTED_COUNTS["queue_outputs"])
		+ int(EXPECTED_COUNTS["atlas_textures"])
		+ int(EXPECTED_COUNTS["tilesets"])
		+ 2
	)
	if int(resource_counts["texture_previews"]) != expected_texture_previews:
		push_error("Texture preview load count mismatch: expected %s got %s" % [expected_texture_previews, resource_counts["texture_previews"]])
		instance.free()
		return 1
	if int(resource_counts["stylebox_previews"]) != int(EXPECTED_COUNTS["styleboxes"]):
		push_error("StyleBox preview load count mismatch: expected %s got %s" % [EXPECTED_COUNTS["styleboxes"], resource_counts["stylebox_previews"]])
		instance.free()
		return 1

	print("Imagegen asset gallery OK: %s" % scene_path)
	instance.free()
	return 0


# 统计预览节点的元数据分类，确认场景确实包含可浏览条目。
func _count_preview_nodes(root: Node) -> Dictionary:
	var result := {}
	_count_preview_nodes_recursive(root, result)
	return result


# 递归统计带 asset_gallery_kind 元数据的节点。
func _count_preview_nodes_recursive(node: Node, result: Dictionary) -> void:
	if node.has_meta("asset_gallery_kind"):
		var kind := String(node.get_meta("asset_gallery_kind"))
		result[kind] = int(result.get(kind, 0)) + 1
	for child: Node in node.get_children():
		_count_preview_nodes_recursive(child, result)


# 验证每张预览卡实际绑定了可加载资源，而不是只有一个空节点。
func _audit_preview_resources(root: Node, counts: Dictionary) -> bool:
	var ok := true
	if root.has_meta("asset_gallery_kind"):
		var kind := String(root.get_meta("asset_gallery_kind"))
		var resource_path := String(root.get_meta("asset_gallery_resource", ""))
		if resource_path.is_empty():
			push_error("Preview card missing resource path: %s" % root.name)
			return false
		if kind == "stylebox":
			ok = _audit_stylebox_preview(root, resource_path, counts)
		else:
			ok = _audit_texture_preview(root, resource_path, counts)
		if not ok:
			return false
	for child: Node in root.get_children():
		if not _audit_preview_resources(child, counts):
			return false
	return true


# 检查普通纹理预览卡：ResourceLoader 和 TextureRect 两侧都必须有有效纹理。
func _audit_texture_preview(node: Node, resource_path: String, counts: Dictionary) -> bool:
	var resource := ResourceLoader.load(resource_path)
	if resource == null or not resource is Texture2D:
		push_error("Preview texture resource is not Texture2D: %s" % resource_path)
		return false
	var texture := resource as Texture2D
	if texture.get_width() <= 0 or texture.get_height() <= 0:
		push_error("Preview texture has invalid size: %s" % resource_path)
		return false

	var texture_rect := _find_first_texture_rect(node)
	if texture_rect == null:
		push_error("Preview card has no TextureRect: %s" % resource_path)
		return false
	if texture_rect.texture == null:
		push_error("Preview TextureRect has no texture: %s" % resource_path)
		return false
	if texture_rect.texture.get_width() <= 0 or texture_rect.texture.get_height() <= 0:
		push_error("Preview TextureRect texture has invalid size: %s" % resource_path)
		return false
	counts["texture_previews"] = int(counts.get("texture_previews", 0)) + 1
	return true


# 检查九宫格预览卡：PanelContainer 必须覆写并加载 StyleBoxTexture。
func _audit_stylebox_preview(node: Node, resource_path: String, counts: Dictionary) -> bool:
	var resource := ResourceLoader.load(resource_path)
	if resource == null or not resource is StyleBoxTexture:
		push_error("Preview stylebox resource is not StyleBoxTexture: %s" % resource_path)
		return false
	var panel := node as PanelContainer
	if panel == null:
		push_error("StyleBox preview node is not PanelContainer: %s" % resource_path)
		return false
	if not panel.has_theme_stylebox_override("panel"):
		push_error("StyleBox preview missing panel override: %s" % resource_path)
		return false
	var stylebox := panel.get_theme_stylebox("panel")
	if stylebox == null or not stylebox is StyleBoxTexture:
		push_error("StyleBox preview override is not StyleBoxTexture: %s" % resource_path)
		return false
	var stylebox_texture := stylebox as StyleBoxTexture
	if stylebox_texture.texture == null:
		push_error("StyleBox preview has no backing texture: %s" % resource_path)
		return false
	if stylebox_texture.region_rect.size.x <= 0.0 or stylebox_texture.region_rect.size.y <= 0.0:
		push_error("StyleBox preview has invalid region: %s" % resource_path)
		return false
	counts["stylebox_previews"] = int(counts.get("stylebox_previews", 0)) + 1
	return true


# 查找预览卡下的第一个 TextureRect。
func _find_first_texture_rect(node: Node) -> TextureRect:
	if node is TextureRect:
		return node as TextureRect
	for child: Node in node.get_children():
		var found := _find_first_texture_rect(child)
		if found != null:
			return found
	return null


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
