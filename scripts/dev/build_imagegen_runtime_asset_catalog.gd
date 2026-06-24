@tool
extends SceneTree

const RUNTIME_MAP_PATH := "res://docs/assets/asset-runtime-integration-map.json"
const ATLAS_MANIFEST_PATH := "res://docs/assets/asset-atlas-build-manifest.json"
const EDITOR_ATLAS_INDEX_PATH := "res://assets/art/editor_resources/editor_atlas_textures.index.json"
const STYLEBOX_INDEX_PATH := "res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json"
const SPINE_EXPORT_INDEX_PATH := "res://assets/art/spine_parts/spine_exports/spine_cutout_exports.index.json"
const SCENE_PATH := "res://scenes/dev/imagegen_runtime_asset_catalog.tscn"
const MANIFEST_PATH := "res://docs/assets/imagegen-runtime-asset-catalog-manifest.json"


func _initialize() -> void:
	var runtime_map: Dictionary = _read_json(RUNTIME_MAP_PATH)
	var atlas_manifest: Dictionary = _read_json(ATLAS_MANIFEST_PATH)
	var editor_atlas_index: Dictionary = _read_json(EDITOR_ATLAS_INDEX_PATH)
	var stylebox_index: Dictionary = _read_json(STYLEBOX_INDEX_PATH)
	var spine_export_index: Dictionary = _read_json(SPINE_EXPORT_INDEX_PATH)

	var spriteframes_by_id: Dictionary = _build_spriteframes_index(atlas_manifest)
	var atlas_resource_by_id: Dictionary = _build_first_resource_index(editor_atlas_index)
	var stylebox_resource_by_id: Dictionary = _build_stylebox_index(stylebox_index)
	var tileset_by_id: Dictionary = _build_tileset_index()
	var spine_texture_by_id: Dictionary = _build_spine_texture_index(atlas_manifest, spine_export_index)

	var root := Node.new()
	root.name = "ImageGenRuntimeAssetCatalog"
	root.set_meta("imagegen_runtime_asset_catalog", true)
	root.set_meta("catalog_status", "runtime_catalog_ready_manual_replacement_required")
	root.set_meta("source_map", RUNTIME_MAP_PATH)

	var preloader := ResourcePreloader.new()
	preloader.name = "RuntimeResources"
	root.add_child(preloader)
	preloader.owner = root

	var entries: Array = []
	var type_counts: Dictionary = {}
	var track_counts: Dictionary = {}
	var missing: Array[String] = []

	for item: Dictionary in runtime_map.get("entries", []):
		var asset_id := str(item.get("asset_id", ""))
		var resource_path := _select_resource_path(item, spriteframes_by_id, atlas_resource_by_id, stylebox_resource_by_id, tileset_by_id, spine_texture_by_id)
		var resource: Resource = load(resource_path) if resource_path != "" else null
		if resource == null:
			missing.append(asset_id)
			continue
		preloader.add_resource(asset_id, resource)
		var actual_type := resource.get_class()
		var track := str(item.get("track", "unknown"))
		type_counts[actual_type] = int(type_counts.get(actual_type, 0)) + 1
		track_counts[track] = int(track_counts.get(track, 0)) + 1
		entries.append({
			"asset_id": asset_id,
			"track": track,
			"target_kind": item.get("target_kind", ""),
			"recommended_resource_type": item.get("recommended_resource_type", ""),
			"catalog_resource_type": actual_type,
			"resource_path": resource_path,
			"target_system": item.get("target_system", ""),
			"integration_status": "runtime_catalog_ready_manual_replacement_required"
		})

	var packed := PackedScene.new()
	var pack_error := packed.pack(root)
	if pack_error != OK:
		push_error("Failed to pack runtime asset catalog: %s" % pack_error)
		quit(1)
		return
	var save_error := ResourceSaver.save(packed, SCENE_PATH)
	if save_error != OK:
		push_error("Failed to save runtime asset catalog: %s" % save_error)
		root.free()
		quit(1)
		return

	var manifest := {
		"version": 1,
		"status": "runtime_catalog_ready_manual_replacement_required",
		"scene": SCENE_PATH,
		"source_map": RUNTIME_MAP_PATH,
		"boundary": "Runtime catalog only. It proves resources can be loaded through a Godot ResourcePreloader; it does not replace gameplay scene references or approve final art.",
		"counts": {
			"resource_count": preloader.get_resource_list().size(),
			"entry_count": entries.size(),
			"track_counts": track_counts,
			"resource_type_counts": type_counts,
			"missing_count": missing.size()
		},
		"missing": missing,
		"entries": entries
	}
	_write_json(MANIFEST_PATH, manifest)
	print("Imagegen runtime asset catalog built: %s resources" % preloader.get_resource_list().size())
	root.free()
	quit(0)


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.store_string("\n")


func _build_spriteframes_index(atlas_manifest: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for item: Dictionary in atlas_manifest.get("outputs", []):
		if item.has("sprite_frames"):
			result[str(item.get("id", ""))] = _to_res_path(str(item.get("sprite_frames", "")))
	return result


func _build_first_resource_index(editor_atlas_index: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for asset: Dictionary in editor_atlas_index.get("assets", []):
		var resources: Array = asset.get("resources", [])
		if not resources.is_empty():
			result[str(asset.get("id", ""))] = str(resources[0].get("resource", ""))
	return result


func _build_stylebox_index(stylebox_index: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var items: Array = stylebox_index.get("items", [])
	if not items.is_empty():
		result[str(stylebox_index.get("id", ""))] = str(items[0].get("resource", ""))
	return result


func _build_tileset_index() -> Dictionary:
	return {
		"miasma_marsh_tileset_ai01": "res://assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres",
		"shrine_trial_tileset_ai01": "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
	}


func _build_spine_texture_index(atlas_manifest: Dictionary, spine_export_index: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var outputs_by_id: Dictionary = {}
	for item: Dictionary in atlas_manifest.get("outputs", []):
		outputs_by_id[str(item.get("id", ""))] = _to_res_path(str(item.get("output", "")))
	for asset: Dictionary in spine_export_index.get("assets", []):
		var asset_id := str(asset.get("asset_id", ""))
		if outputs_by_id.has(asset_id):
			result[asset_id] = outputs_by_id[asset_id]
	return result


func _select_resource_path(item: Dictionary, spriteframes_by_id: Dictionary, atlas_resource_by_id: Dictionary, stylebox_resource_by_id: Dictionary, tileset_by_id: Dictionary, spine_texture_by_id: Dictionary) -> String:
	var asset_id := str(item.get("asset_id", ""))
	var recommended := str(item.get("recommended_resource_type", ""))
	if recommended == "SpriteFrames" and spriteframes_by_id.has(asset_id):
		return str(spriteframes_by_id[asset_id])
	if recommended == "TileSet" and tileset_by_id.has(asset_id):
		return str(tileset_by_id[asset_id])
	if recommended == "StyleBoxTexture" and stylebox_resource_by_id.has(asset_id):
		return str(stylebox_resource_by_id[asset_id])
	if recommended == "AtlasTexture" and atlas_resource_by_id.has(asset_id):
		return str(atlas_resource_by_id[asset_id])
	if recommended.begins_with("Spine-style") and spine_texture_by_id.has(asset_id):
		return str(spine_texture_by_id[asset_id])
	return _to_res_path(str(item.get("output_path", "")))


func _to_res_path(path: String) -> String:
	if path.begins_with("res://"):
		return path
	return "res://" + path
