extends SceneTree

# 加载 image gen 图集拆分出的 AtlasTexture 资源，验证 Godot 能识别为可用资源。

const INDEX_PATH := "res://assets/art/editor_resources/editor_atlas_textures.index.json"


func _init() -> void:
	var result := _run()
	quit(result)


func _run() -> int:
	if not FileAccess.file_exists(INDEX_PATH):
		push_error("Missing editor AtlasTexture index: %s" % INDEX_PATH)
		return 1

	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	if file == null:
		push_error("Cannot open editor AtlasTexture index: %s" % INDEX_PATH)
		return 1

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Editor AtlasTexture index is not a dictionary.")
		return 1

	var index: Dictionary = parsed
	var checked := 0
	for asset: Dictionary in index.get("assets", []):
		for entry: Dictionary in asset.get("resources", []):
			checked += 1
			var path := String(entry.get("resource", ""))
			var resource := ResourceLoader.load(path)
			if resource == null:
				push_error("Cannot load AtlasTexture resource: %s" % path)
				return 1
			if not resource is AtlasTexture:
				push_error("Resource is not AtlasTexture: %s" % path)
				return 1
			var atlas_texture := resource as AtlasTexture
			if atlas_texture.atlas == null:
				push_error("AtlasTexture has no atlas: %s" % path)
				return 1
			if atlas_texture.region.size.x <= 0.0 or atlas_texture.region.size.y <= 0.0:
				push_error("AtlasTexture has invalid region: %s" % path)
				return 1

	var expected := int(index.get("resource_count", -1))
	if expected != checked:
		push_error("Index count mismatch: expected %s checked %s" % [expected, checked])
		return 1

	print("Editor AtlasTexture resources OK: %s" % checked)
	return 0
