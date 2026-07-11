extends SceneTree

# 将 formal terrain kit 的 4 张规则网格源图包装成一个 Godot TileSet 候选资源。
# 该资源用于正式房间模板；静态地形可由 TileMapLayer collision 接管。

const ASSET_ID := "formal_terrain_kit_ai01"
const OUT_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const OUT_RULES_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset_rules.json"
const OUT_SEMANTICS_PATH := "res://assets/art/tilesets/formal_terrain_kit/formal_terrain_kit_ai01.semantics.json"
const OUT_REGIONS_PATH := "res://assets/art/tilesets/formal_terrain_kit/formal_terrain_kit_ai01.regions.json"
const PHYSICS_LAYER := 0
const CELL := Vector2i(384, 384)
const COLUMNS := 4
const ROWS := 3

const SOURCES := [
	{
		"id": 0,
		"name": "flat_edges",
		"texture": "res://assets/art/tilesets/formal_terrain_kit/grid/formal_terrain_flat_edges_ai01_grid.png",
		"entries": [
			["flat_ground_center_a", "ground"],
			["flat_ground_center_b", "ground"],
			["flat_ground_left_cap", "ground"],
			["flat_ground_right_cap", "ground"],
			["outer_corner_top_left", "transition"],
			["outer_corner_top_right", "transition"],
			["inner_corner_bottom_left", "transition"],
			["inner_corner_bottom_right", "transition"],
			["one_way_platform_center", "platform_edge"],
			["one_way_platform_left_cap", "platform_edge"],
			["one_way_platform_right_cap", "platform_edge"],
			["floor_medallion_slab", "ground"],
		],
	},
	{
		"id": 1,
		"name": "stairs_cliffs",
		"texture": "res://assets/art/tilesets/formal_terrain_kit/grid/formal_terrain_stairs_cliffs_ai01_grid.png",
		"entries": [
			["stair_ramp_ascending_right", "transition"],
			["stair_ramp_ascending_left", "transition"],
			["short_stair_right", "transition"],
			["short_stair_left", "transition"],
			["cliff_face_center", "wall"],
			["cliff_face_alt", "wall"],
			["cliff_edge_left", "transition"],
			["cliff_edge_right", "transition"],
			["left_wall_side", "wall"],
			["right_wall_side", "wall"],
			["underside_support_trim", "decor"],
			["broken_floating_platform", "platform_edge"],
		],
	},
	{
		"id": 2,
		"name": "door_transitions",
		"texture": "res://assets/art/tilesets/formal_terrain_kit/grid/formal_terrain_door_transitions_ai01_grid.png",
		"entries": [
			["left_room_doorway_jamb", "transition"],
			["right_room_doorway_jamb", "transition"],
			["sealed_gate_inactive", "decor"],
			["sealed_gate_active", "decor"],
			["left_doorway_floor_transition", "ground"],
			["right_doorway_floor_transition", "ground"],
			["broken_arch_top_trim", "thin_solid_ceiling"],
			["broken_arch_vertical_side", "decor"],
			["doorway_safe_landing_pad", "ground"],
			["return_path_marker_base", "decor"],
			["door_control_pedestal_inactive", "decor"],
			["door_control_pedestal_active", "decor"],
		],
	},
	{
		"id": 3,
		"name": "decor_props",
		"texture": "res://assets/art/tilesets/formal_terrain_kit/grid/formal_terrain_decor_props_ai01_grid.png",
		"entries": [
			["small_moss_tuft", "decor"],
			["medium_moss_vines", "decor"],
			["broken_stone_rubble", "decor"],
			["cracked_stone_shards", "decor"],
			["spirit_lantern", "decor"],
			["stone_incense_burner", "decor"],
			["talisman_stake", "decor"],
			["hanging_cloth_chain_trim", "decor"],
			["miasma_puddle_edge", "hazard"],
			["seal_glyph_floor_decal", "ornament"],
			["short_shrine_plinth", "decor"],
			["broken_pillar_stump", "decor"],
		],
	},
]


func _init() -> void:
	var result := _run()
	quit(result)


func _run() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/art/tilesets/editor_tilesets"))
	var tile_set := TileSet.new()
	tile_set.tile_size = CELL
	_configure_tile_set_layers(tile_set)

	var semantics_entries: Array[Dictionary] = []
	var region_entries: Array[Dictionary] = []
	var rules: Array[Dictionary] = []
	var counts := {
		"solid": 0,
		"thin_solid": 0,
		"one_way_platform": 0,
		"hazard_visual_only": 0,
		"decorative_visual_only": 0,
	}

	for source_spec: Dictionary in SOURCES:
		var source_id := int(source_spec["id"])
		var source_name := String(source_spec["name"])
		var texture_path := String(source_spec["texture"])
		var texture := load(texture_path) as Texture2D
		if texture == null:
			push_error("Missing formal terrain texture: %s" % texture_path)
			return 1

		var atlas := TileSetAtlasSource.new()
		atlas.texture = texture
		atlas.texture_region_size = CELL
		for index in range(COLUMNS * ROWS):
			var coords := Vector2i(index % COLUMNS, index / COLUMNS)
			atlas.create_tile(coords)
		tile_set.add_source(atlas, source_id)

		for index in range(COLUMNS * ROWS):
			var coords := Vector2i(index % COLUMNS, index / COLUMNS)
			var entry: Array = source_spec["entries"][index]
			var semantic_name := "%s_%s" % [source_name, String(entry[0])]
			var category := String(entry[1])
			var collision_role := _collision_role_for(category)
			var tile_data := atlas.get_tile_data(coords, 0)
			_apply_collision(tile_data, collision_role)
			_apply_terrain(tile_data, collision_role)
			counts[collision_role] = int(counts[collision_role]) + 1
			var region := [coords.x * CELL.x, coords.y * CELL.y, CELL.x, CELL.y]
			semantics_entries.append({
				"index": semantics_entries.size(),
				"source_id": source_id,
				"source_name": source_name,
				"atlas_coords": [coords.x, coords.y],
				"semantic_name": semantic_name,
				"category": category,
				"collision_role": collision_role,
				"region": region,
			})
			region_entries.append({
				"index": region_entries.size(),
				"name": semantic_name,
				"source_id": source_id,
				"source_name": source_name,
				"texture": texture_path,
				"region": region,
			})
			rules.append({
				"index": rules.size(),
				"source_id": source_id,
				"atlas_coords": [coords.x, coords.y],
				"semantic_name": semantic_name,
				"category": category,
				"collision_role": collision_role,
				"collision_polygon_count": tile_data.get_collision_polygons_count(PHYSICS_LAYER),
				"manual_review_required": true,
				"notes": _rules_notes_for(collision_role),
			})

	var save_error := ResourceSaver.save(tile_set, OUT_TILESET_PATH)
	if save_error != OK:
		push_error("Failed to save formal terrain TileSet: %s" % save_error)
		return 1

	var tile_count := SOURCES.size() * COLUMNS * ROWS
	var source_records: Array[Dictionary] = []
	for source_item: Dictionary in SOURCES:
		source_records.append({
			"id": int(source_item["id"]),
			"name": String(source_item["name"]),
			"texture": String(source_item["texture"]),
		})
	_write_json(OUT_SEMANTICS_PATH, {
		"version": 1,
		"asset_id": ASSET_ID,
		"kind": "multi_source_tileset_sheet",
		"tile_size": [CELL.x, CELL.y],
		"columns": COLUMNS,
		"rows": ROWS,
		"tile_count": tile_count,
		"sources": source_records,
		"boundary": "Formal terrain kit source TileSet. Static tutorial terrain may use TileMapLayer collision after room-level review.",
		"entries": semantics_entries,
	})
	_write_json(OUT_REGIONS_PATH, {
		"version": 1,
		"asset_id": ASSET_ID,
		"tile_size": [CELL.x, CELL.y],
		"entry_count": tile_count,
		"entries": region_entries,
	})
	_write_json(OUT_RULES_PATH, {
		"version": 1,
		"asset_id": ASSET_ID,
		"tileset_resource": OUT_TILESET_PATH,
		"source_semantics": OUT_SEMANTICS_PATH,
		"tile_size": [CELL.x, CELL.y],
		"tile_count": tile_count,
		"source_count": SOURCES.size(),
		"physics_layer_count": tile_set.get_physics_layers_count(),
		"terrain_set_count": tile_set.get_terrain_sets_count(),
		"counts": counts,
		"manual_review_required": true,
		"boundary": "Collision roles are conservative candidates; approved room templates may make TileMapLayer collision authoritative for static terrain.",
		"rules": rules,
	})

	print("built=%s sources=%d tiles=%d" % [OUT_TILESET_PATH, SOURCES.size(), tile_count])
	return 0


func _configure_tile_set_layers(tile_set: TileSet) -> void:
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(PHYSICS_LAYER, 1)
	tile_set.set_physics_layer_collision_mask(PHYSICS_LAYER, 1)
	tile_set.add_terrain_set()
	tile_set.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS)
	var terrain_names := ["solid", "thin_solid", "one_way_platform", "hazard_visual_only", "decorative_visual_only"]
	var terrain_colors := [
		Color(0.55, 0.78, 1.0, 1.0),
		Color(0.65, 0.78, 1.0, 1.0),
		Color(0.72, 0.9, 0.55, 1.0),
		Color(0.9, 0.35, 0.7, 1.0),
		Color(0.8, 0.8, 0.8, 1.0),
	]
	for index in range(terrain_names.size()):
		tile_set.add_terrain(0)
		tile_set.set_terrain_name(0, index, terrain_names[index])
		tile_set.set_terrain_color(0, index, terrain_colors[index])


func _collision_role_for(category: String) -> String:
	if category in ["ground", "wall", "transition"]:
		return "solid"
	if category == "thin_solid_ceiling":
		return "thin_solid"
	if category == "platform_edge":
		return "one_way_platform"
	if category == "hazard":
		return "hazard_visual_only"
	return "decorative_visual_only"


func _apply_collision(tile_data: TileData, collision_role: String) -> void:
	if collision_role == "solid":
		tile_data.set_collision_polygons_count(PHYSICS_LAYER, 1)
		tile_data.set_collision_polygon_points(PHYSICS_LAYER, 0, PackedVector2Array([
			Vector2(0, 0),
			Vector2(CELL.x, 0),
			Vector2(CELL.x, CELL.y),
			Vector2(0, CELL.y),
		]))
	elif collision_role == "thin_solid":
		tile_data.set_collision_polygons_count(PHYSICS_LAYER, 1)
		tile_data.set_collision_polygon_points(PHYSICS_LAYER, 0, PackedVector2Array([
			Vector2(0, 36),
			Vector2(CELL.x, 36),
			Vector2(CELL.x, 84),
			Vector2(0, 84),
		]))
	elif collision_role == "one_way_platform":
		tile_data.set_collision_polygons_count(PHYSICS_LAYER, 1)
		tile_data.set_collision_polygon_points(PHYSICS_LAYER, 0, PackedVector2Array([
			Vector2(0, 0),
			Vector2(CELL.x, 0),
			Vector2(CELL.x, 16),
			Vector2(0, 16),
		]))
		tile_data.set_collision_polygon_one_way(PHYSICS_LAYER, 0, true)
		tile_data.set_collision_polygon_one_way_margin(PHYSICS_LAYER, 0, 8.0)
	else:
		tile_data.set_collision_polygons_count(PHYSICS_LAYER, 0)


func _apply_terrain(tile_data: TileData, collision_role: String) -> void:
	tile_data.set_terrain_set(0)
	if collision_role == "solid":
		tile_data.set_terrain(0)
	elif collision_role == "thin_solid":
		tile_data.set_terrain(1)
	elif collision_role == "one_way_platform":
		tile_data.set_terrain(2)
	elif collision_role == "hazard_visual_only":
		tile_data.set_terrain(3)
	else:
		tile_data.set_terrain(4)


func _rules_notes_for(collision_role: String) -> Array[String]:
	if collision_role == "solid":
		return ["full_cell_collision_candidate", "manual_edge_fit_required"]
	if collision_role == "thin_solid":
		return ["thin_ceiling_collision_candidate", "manual_gate_clearance_review_required"]
	if collision_role == "one_way_platform":
		return ["top_strip_one_way_collision_candidate", "manual_jump_through_review_required"]
	if collision_role == "hazard_visual_only":
		return ["no_physics_collision", "damage_area_must_be_authored_in_runtime_scene"]
	return ["no_physics_collision", "safe_for_visual_decoration_after_review"]


func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write JSON: %s" % path)
		return
	file.store_string(JSON.stringify(data, "\t") + "\n")
