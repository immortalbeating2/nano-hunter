extends SceneTree

# 从 image gen TileSet sheet 生成 Godot TileSet 候选资源。

const MANIFEST_PATH := "res://docs/assets/asset-atlas-build-manifest.json"
const OUT_DIR := "res://assets/art/tilesets/editor_tilesets"
const SEMANTICS_DIR := "res://assets/art/tilesets"
const PHYSICS_LAYER := 0
const SOLID_CATEGORIES := ["ground", "wall", "transition"]
const ONE_WAY_CATEGORIES := ["platform_edge"]
const HAZARD_CATEGORIES := ["hazard"]
const DECORATIVE_CATEGORIES := ["decor", "ornament"]


func _init() -> void:
	var result := _run()
	quit(result)


func _run() -> int:
	var manifest := _read_json(MANIFEST_PATH)
	if manifest.is_empty():
		return 1

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var built := 0
	for item: Dictionary in manifest.get("outputs", []):
		if String(item.get("kind", "")) != "tileset_sheet":
			continue
		if not _build_tileset(item):
			return 1
		built += 1

	print("Editor TileSet resources built: %s" % built)
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


func _build_tileset(item: Dictionary) -> bool:
	var id := String(item["id"])
	var output := _to_res_path(String(item["output"]))
	var semantics := _read_json("%s/%s.semantics.json" % [SEMANTICS_DIR, id])
	if semantics.is_empty():
		return false
	var texture := load(output)
	if texture == null or not texture is Texture2D:
		push_error("Cannot load TileSet texture for %s: %s" % [id, output])
		return false

	var cell_array: Array = item.get("cell", [])
	if cell_array.size() != 2:
		push_error("Invalid TileSet cell for %s" % id)
		return false
	var cell_size := Vector2i(int(cell_array[0]), int(cell_array[1]))
	var expected_target := int(item.get("expected_target", 0))
	var columns := int(item.get("columns", 1))

	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = cell_size
	for index in range(expected_target):
		var coords := Vector2i(index % columns, index / columns)
		source.create_tile(coords)

	var tile_set := TileSet.new()
	tile_set.tile_size = cell_size
	_configure_tile_set_layers(tile_set)
	tile_set.add_source(source, 0)
	var rule_summary := _apply_tile_rules(id, tile_set, source, semantics, cell_size, columns, expected_target)
	if rule_summary.is_empty():
		return false

	var save_path := "%s/%s.tileset.tres" % [OUT_DIR, id]
	var error := ResourceSaver.save(tile_set, save_path)
	if error != OK:
		push_error("Failed to save TileSet %s to %s: %s" % [id, save_path, error])
		return false
	if not _write_rules_json(id, rule_summary):
		return false
	print("wrote %s" % save_path)
	return true


func _configure_tile_set_layers(tile_set: TileSet) -> void:
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(PHYSICS_LAYER, 1)
	tile_set.set_physics_layer_collision_mask(PHYSICS_LAYER, 1)
	tile_set.add_terrain_set()
	tile_set.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS)
	var terrain_names := [
		"solid",
		"one_way_platform",
		"hazard_visual_only",
		"decorative_visual_only",
	]
	var terrain_colors := [
		Color(0.55, 0.78, 1.0, 1.0),
		Color(0.72, 0.9, 0.55, 1.0),
		Color(0.9, 0.35, 0.7, 1.0),
		Color(0.8, 0.8, 0.8, 1.0),
	]
	for index in range(terrain_names.size()):
		tile_set.add_terrain(0)
		tile_set.set_terrain_name(0, index, terrain_names[index])
		tile_set.set_terrain_color(0, index, terrain_colors[index])


func _apply_tile_rules(
	id: String,
	tile_set: TileSet,
	source: TileSetAtlasSource,
	semantics: Dictionary,
	cell_size: Vector2i,
	columns: int,
	expected_target: int
) -> Dictionary:
	var entries: Array = semantics.get("entries", [])
	if entries.size() != expected_target:
		push_error("TileSet semantics count mismatch for %s: expected %s got %s" % [id, expected_target, entries.size()])
		return {}

	var rules: Array[Dictionary] = []
	var counts := {
		"solid": 0,
		"one_way_platform": 0,
		"hazard_visual_only": 0,
		"decorative_visual_only": 0,
		"unclassified_visual_only": 0,
	}
	for entry: Dictionary in entries:
		var index := int(entry.get("index", -1))
		if index < 0 or index >= expected_target:
			push_error("Invalid TileSet semantic index for %s: %s" % [id, index])
			return {}
		var coords := Vector2i(index % columns, index / columns)
		var tile_data := source.get_tile_data(coords, 0)
		if tile_data == null:
			push_error("Missing TileData for %s at %s" % [id, coords])
			return {}
		var category := String(entry.get("category", "unknown"))
		var collision_role := _collision_role_for(category)
		_apply_collision(tile_data, collision_role, cell_size)
		_apply_terrain(tile_data, collision_role)
		counts[collision_role] = int(counts.get(collision_role, 0)) + 1
		rules.append({
			"index": index,
			"atlas_coords": [coords.x, coords.y],
			"semantic_name": String(entry.get("semantic_name", "")),
			"category": category,
			"collision_role": collision_role,
			"collision_polygon_count": tile_data.get_collision_polygons_count(PHYSICS_LAYER),
			"manual_review_required": true,
			"notes": _rules_notes_for(collision_role),
		})

	return {
		"version": 1,
		"asset_id": id,
		"tileset_resource": "%s/%s.tileset.tres" % [OUT_DIR, id],
		"source_semantics": "%s/%s.semantics.json" % [SEMANTICS_DIR, id],
		"tile_size": [cell_size.x, cell_size.y],
		"tile_count": expected_target,
		"physics_layer_count": tile_set.get_physics_layers_count(),
		"terrain_set_count": tile_set.get_terrain_sets_count(),
		"counts": counts,
		"manual_review_required": true,
		"boundary": "Conservative first-pass TileSet rules. Collision and hazard boundaries must be reviewed before runtime TileMap replacement.",
		"rules": rules,
	}


func _collision_role_for(category: String) -> String:
	if category in SOLID_CATEGORIES:
		return "solid"
	if category in ONE_WAY_CATEGORIES:
		return "one_way_platform"
	if category in HAZARD_CATEGORIES:
		return "hazard_visual_only"
	if category in DECORATIVE_CATEGORIES:
		return "decorative_visual_only"
	return "unclassified_visual_only"


func _apply_collision(tile_data: TileData, collision_role: String, cell_size: Vector2i) -> void:
	if collision_role == "solid":
		tile_data.set_collision_polygons_count(PHYSICS_LAYER, 1)
		tile_data.set_collision_polygon_points(PHYSICS_LAYER, 0, PackedVector2Array([
			Vector2(0, 0),
			Vector2(cell_size.x, 0),
			Vector2(cell_size.x, cell_size.y),
			Vector2(0, cell_size.y),
		]))
	elif collision_role == "one_way_platform":
		tile_data.set_collision_polygons_count(PHYSICS_LAYER, 1)
		tile_data.set_collision_polygon_points(PHYSICS_LAYER, 0, PackedVector2Array([
			Vector2(0, 0),
			Vector2(cell_size.x, 0),
			Vector2(cell_size.x, 8),
			Vector2(0, 8),
		]))
		tile_data.set_collision_polygon_one_way(PHYSICS_LAYER, 0, true)
		tile_data.set_collision_polygon_one_way_margin(PHYSICS_LAYER, 0, 4.0)
	else:
		tile_data.set_collision_polygons_count(PHYSICS_LAYER, 0)


func _apply_terrain(tile_data: TileData, collision_role: String) -> void:
	tile_data.set_terrain_set(0)
	if collision_role == "solid":
		tile_data.set_terrain(0)
	elif collision_role == "one_way_platform":
		tile_data.set_terrain(1)
	elif collision_role == "hazard_visual_only":
		tile_data.set_terrain(2)
	else:
		tile_data.set_terrain(3)


func _rules_notes_for(collision_role: String) -> Array[String]:
	if collision_role == "solid":
		return ["full_cell_collision_candidate", "manual_edge_fit_required"]
	if collision_role == "one_way_platform":
		return ["top_strip_one_way_collision_candidate", "manual_jump_through_review_required"]
	if collision_role == "hazard_visual_only":
		return ["no_physics_collision", "damage_area_must_be_authored_in_runtime_scene"]
	if collision_role == "decorative_visual_only":
		return ["no_physics_collision", "safe_for_visual_decoration_after_review"]
	return ["no_physics_collision", "manual_classification_required"]


func _write_rules_json(id: String, data: Dictionary) -> bool:
	var path := "%s/%s.tileset_rules.json" % [OUT_DIR, id]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write TileSet rules JSON: %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t") + "\n")
	return true


func _to_res_path(value: String) -> String:
	if value.begins_with("res://"):
		return value
	if value.is_absolute_path():
		var project_root := ProjectSettings.globalize_path("res://")
		var normalized_root := project_root.replace("\\", "/").trim_suffix("/")
		var normalized_value := value.replace("\\", "/")
		if normalized_value.begins_with(normalized_root):
			return "res://" + normalized_value.substr(normalized_root.length()).trim_prefix("/")
		return value
	return "res://" + value
