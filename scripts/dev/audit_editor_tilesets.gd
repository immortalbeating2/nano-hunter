extends SceneTree

# 加载 image gen 生成的 Godot TileSet 候选资源，验证 source 和 tile 数量。

const MANIFEST_PATH := "res://docs/assets/asset-atlas-build-manifest.json"
const TILESET_DIR := "res://assets/art/tilesets/editor_tilesets"
const PHYSICS_LAYER := 0


func _init() -> void:
	var result := _run()
	quit(result)


func _run() -> int:
	var manifest := _read_json(MANIFEST_PATH)
	if manifest.is_empty():
		return 1

	var checked := 0
	for item: Dictionary in manifest.get("outputs", []):
		if String(item.get("kind", "")) != "tileset_sheet":
			continue
		if not _audit_tileset(item):
			return 1
		checked += 1

	print("Editor TileSet resources OK: %s" % checked)
	return 0


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


func _audit_tileset(item: Dictionary) -> bool:
	var id := String(item["id"])
	var path := "%s/%s.tileset.tres" % [TILESET_DIR, id]
	var resource := ResourceLoader.load(path)
	if resource == null or not resource is TileSet:
		push_error("Cannot load TileSet resource: %s" % path)
		return false
	var tile_set := resource as TileSet
	if tile_set.get_source_count() != 1:
		push_error("TileSet source count mismatch for %s: %s" % [id, tile_set.get_source_count()])
		return false
	var source_id := tile_set.get_source_id(0)
	var source := tile_set.get_source(source_id)
	if source == null or not source is TileSetAtlasSource:
		push_error("TileSet source is not TileSetAtlasSource: %s" % id)
		return false
	var atlas_source := source as TileSetAtlasSource
	var expected_target := int(item.get("expected_target", 0))
	if atlas_source.get_tiles_count() != expected_target:
		push_error("Tile count mismatch for %s: expected %s got %s" % [id, expected_target, atlas_source.get_tiles_count()])
		return false
	var cell_array: Array = item.get("cell", [])
	var expected_size := Vector2i(int(cell_array[0]), int(cell_array[1]))
	if atlas_source.texture_region_size != expected_size:
		push_error("Tile region size mismatch for %s" % id)
		return false
	if tile_set.get_physics_layers_count() < 1:
		push_error("TileSet missing physics layer: %s" % id)
		return false
	if tile_set.get_terrain_sets_count() < 1:
		push_error("TileSet missing terrain set: %s" % id)
		return false
	if not _audit_rules(id, atlas_source, expected_target):
		return false
	return true


func _audit_rules(id: String, atlas_source: TileSetAtlasSource, expected_target: int) -> bool:
	var rules_path := "%s/%s.tileset_rules.json" % [TILESET_DIR, id]
	var rules := _read_json(rules_path)
	if rules.is_empty():
		return false
	if int(rules.get("tile_count", 0)) != expected_target:
		push_error("TileSet rules tile count mismatch for %s" % id)
		return false
	var entries: Array = rules.get("rules", [])
	if entries.size() != expected_target:
		push_error("TileSet rules entry count mismatch for %s: %s" % [id, entries.size()])
		return false
	var collision_ready := 0
	var hazard_visual_only := 0
	for entry: Dictionary in entries:
		var coords_array: Array = entry.get("atlas_coords", [])
		if coords_array.size() != 2:
			push_error("Invalid atlas_coords in TileSet rules for %s" % id)
			return false
		var coords := Vector2i(int(coords_array[0]), int(coords_array[1]))
		var tile_data := atlas_source.get_tile_data(coords, 0)
		if tile_data == null:
			push_error("Missing TileData for TileSet rules entry %s at %s" % [id, coords])
			return false
		var collision_role := String(entry.get("collision_role", ""))
		var polygon_count := tile_data.get_collision_polygons_count(PHYSICS_LAYER)
		if collision_role == "solid":
			if polygon_count != 1:
				push_error("Solid tile collision mismatch for %s at %s" % [id, coords])
				return false
			collision_ready += 1
		elif collision_role == "one_way_platform":
			if polygon_count != 1 or not tile_data.is_collision_polygon_one_way(PHYSICS_LAYER, 0):
				push_error("One-way platform collision mismatch for %s at %s" % [id, coords])
				return false
			collision_ready += 1
		elif collision_role == "hazard_visual_only":
			if polygon_count != 0:
				push_error("Hazard visual-only tile should not have physics collision for %s at %s" % [id, coords])
				return false
			hazard_visual_only += 1
		else:
			if polygon_count != 0:
				push_error("Visual-only tile should not have physics collision for %s at %s" % [id, coords])
				return false
	if collision_ready <= 0:
		push_error("TileSet has no collision-ready tiles: %s" % id)
		return false
	if id.contains("miasma") and hazard_visual_only <= 0:
		push_error("Miasma TileSet should record hazard visual-only tiles: %s" % id)
		return false
	return true
