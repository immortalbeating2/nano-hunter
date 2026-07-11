extends GutTest

# 正式 terrain kit 资源契约：只验证源图已包装成可加载 TileSet。
# 运行时房间替换、碰撞精修和视觉审美复核不在本测试里完成。

const TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const RULES_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset_rules.json"
const SEMANTICS_PATH := "res://assets/art/tilesets/formal_terrain_kit/formal_terrain_kit_ai01.semantics.json"
const REGIONS_PATH := "res://assets/art/tilesets/formal_terrain_kit/formal_terrain_kit_ai01.regions.json"
const EXPECTED_SOURCE_COUNT := 4
const EXPECTED_TILE_COUNT := 48
const EXPECTED_TILE_SIZE := Vector2i(384, 384)


func test_formal_terrain_kit_tileset_loads_with_expected_sources() -> void:
	var tile_set := load(TILESET_PATH) as TileSet
	assert_not_null(tile_set)
	if tile_set == null:
		return

	assert_eq(tile_set.tile_size, EXPECTED_TILE_SIZE)
	assert_eq(tile_set.get_source_count(), EXPECTED_SOURCE_COUNT)
	assert_eq(tile_set.get_physics_layers_count(), 1)
	assert_eq(tile_set.get_terrain_sets_count(), 1)

	var total_tiles := 0
	for index in range(tile_set.get_source_count()):
		var source_id := tile_set.get_source_id(index)
		var source := tile_set.get_source(source_id) as TileSetAtlasSource
		assert_not_null(source, "source is atlas: %s" % source_id)
		if source != null:
			assert_eq(source.texture_region_size, EXPECTED_TILE_SIZE)
			assert_eq(source.get_tiles_count(), 12)
			total_tiles += source.get_tiles_count()
	assert_eq(total_tiles, EXPECTED_TILE_COUNT)


func test_formal_terrain_kit_metadata_matches_tileset_rules() -> void:
	var rules := _read_json(RULES_PATH)
	var semantics := _read_json(SEMANTICS_PATH)
	var regions := _read_json(REGIONS_PATH)
	assert_eq(int(rules.get("tile_count", 0)), EXPECTED_TILE_COUNT)
	assert_eq(int(semantics.get("tile_count", 0)), EXPECTED_TILE_COUNT)
	assert_eq(int(regions.get("entry_count", 0)), EXPECTED_TILE_COUNT)
	var counts := rules.get("counts", {}) as Dictionary
	assert_eq({
		"decorative_visual_only": int(counts.get("decorative_visual_only", -1)),
		"hazard_visual_only": int(counts.get("hazard_visual_only", -1)),
		"one_way_platform": int(counts.get("one_way_platform", -1)),
		"solid": int(counts.get("solid", -1)),
		"thin_solid": int(counts.get("thin_solid", -1)),
	}, {
		"decorative_visual_only": 18,
		"hazard_visual_only": 1,
		"one_way_platform": 4,
		"solid": 24,
		"thin_solid": 1,
	})


func test_formal_terrain_kit_collision_roles_are_encoded() -> void:
	var tile_set := load(TILESET_PATH) as TileSet
	var rules := _read_json(RULES_PATH)
	assert_not_null(tile_set)
	if tile_set == null:
		return

	for rule: Dictionary in rules.get("rules", []):
		var source := tile_set.get_source(int(rule["source_id"])) as TileSetAtlasSource
		assert_not_null(source)
		if source == null:
			continue

		var coords_array: Array = rule["atlas_coords"]
		var tile_data := source.get_tile_data(Vector2i(int(coords_array[0]), int(coords_array[1])), 0)
		assert_not_null(tile_data)
		if tile_data == null:
			continue

		var collision_role := String(rule["collision_role"])
		var polygon_count := tile_data.get_collision_polygons_count(0)
		if collision_role in ["solid", "thin_solid", "one_way_platform"]:
			assert_eq(polygon_count, 1, "collision candidate exists: %s" % rule["semantic_name"])
		else:
			assert_eq(polygon_count, 0, "visual-only tile has no collision: %s" % rule["semantic_name"])
		if collision_role == "one_way_platform":
			assert_true(tile_data.is_collision_polygon_one_way(0, 0))


func _read_json(path: String) -> Dictionary:
	assert_true(FileAccess.file_exists(path), "json exists: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert_eq(typeof(parsed), TYPE_DICTIONARY)
	return parsed as Dictionary
