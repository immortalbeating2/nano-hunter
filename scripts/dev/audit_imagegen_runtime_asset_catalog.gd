@tool
extends SceneTree

const SCENE_PATH := "res://scenes/dev/imagegen_runtime_asset_catalog.tscn"
const MANIFEST_PATH := "res://docs/assets/imagegen-runtime-asset-catalog-manifest.json"
const EXPECTED_COUNT := 55


func _initialize() -> void:
	var manifest := _read_json(MANIFEST_PATH)
	if manifest.is_empty():
		push_error("Runtime asset catalog manifest missing")
		quit(1)
		return
	var packed: PackedScene = load(SCENE_PATH)
	if packed == null:
		push_error("Runtime asset catalog scene missing")
		quit(1)
		return
	var root := packed.instantiate()
	if not bool(root.get_meta("imagegen_runtime_asset_catalog", false)):
		push_error("Runtime asset catalog root meta missing")
		quit(1)
		return
	var preloader := root.get_node_or_null("RuntimeResources") as ResourcePreloader
	if preloader == null:
		push_error("RuntimeResources preloader missing")
		quit(1)
		return
	var names := preloader.get_resource_list()
	if names.size() != EXPECTED_COUNT:
		push_error("Runtime resource count expected %s got %s" % [EXPECTED_COUNT, names.size()])
		quit(1)
		return
	var manifest_entries: Array = manifest.get("entries", [])
	if manifest_entries.size() != EXPECTED_COUNT:
		push_error("Runtime manifest entry count expected %s got %s" % [EXPECTED_COUNT, manifest_entries.size()])
		quit(1)
		return
	for entry: Dictionary in manifest_entries:
		var asset_id := str(entry.get("asset_id", ""))
		var resource_path := str(entry.get("resource_path", ""))
		if not preloader.has_resource(asset_id):
			push_error("Missing preloaded resource for %s" % asset_id)
			quit(1)
			return
		var resource: Resource = preloader.get_resource(asset_id)
		if resource == null:
			push_error("Null preloaded resource for %s" % asset_id)
			quit(1)
			return
		var loaded: Resource = load(resource_path)
		if loaded == null:
			push_error("Manifest resource path failed to load for %s: %s" % [asset_id, resource_path])
			quit(1)
			return
		if str(entry.get("catalog_resource_type", "")) == "":
			push_error("Empty catalog resource type for %s" % asset_id)
			root.free()
			quit(1)
			return
	print("Imagegen runtime asset catalog OK: %s resources" % names.size())
	root.free()
	quit(0)


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
