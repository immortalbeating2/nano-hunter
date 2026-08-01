# 全生产房间可踩面审计：视觉真实 alpha 边缘必须贴合物理接触面，碰撞权威层不得进入成品画面。
extends GutTest

const WORLD_MAP_PATH := "res://assets/configs/world_map/alpha_demo_world_map.json"
const EXPECTED_ROOM_COUNT := 44
const EXPECTED_FORMAL_ROOM_COUNT := 38
const EXPECTED_STATIC_FLOOR_ROOM_COUNT := 6
const MAX_WALKABLE_EDGE_GAP := 0.25
const MAX_CEILING_EDGE_GAP := 2.25
const ALPHA_THRESHOLD := 0.05

var _alpha_bounds_cache: Dictionary = {}


func test_all_production_room_walkable_visuals_match_collision() -> void:
	var failures: Array[String] = []
	var room_paths := _production_room_paths()
	var formal_room_count := 0
	var static_floor_room_count := 0

	assert_eq(room_paths.size(), EXPECTED_ROOM_COUNT)
	for room_path: String in room_paths:
		var packed := load(room_path) as PackedScene
		if packed == null:
			failures.append("%s: 场景无法加载" % room_path)
			continue
		var room := packed.instantiate() as Node2D
		var terrain := room.get_node_or_null("TerrainCollisionVisual") as TileMapLayer
		if terrain != null:
			formal_room_count += 1
			_audit_formal_room(room, room_path, failures)
		else:
			static_floor_room_count += 1
			_audit_static_floor(room, room_path, failures)
		room.free()

	assert_eq(formal_room_count, EXPECTED_FORMAL_ROOM_COUNT)
	assert_eq(static_floor_room_count, EXPECTED_STATIC_FLOOR_ROOM_COUNT)
	assert_true(failures.is_empty(), "\n" + "\n".join(failures))


func _audit_formal_room(room: Node2D, room_path: String, failures: Array[String]) -> void:
	var terrain := room.get_node_or_null("TerrainCollisionVisual") as TileMapLayer
	var platform := room.get_node_or_null("PlatformCollisionVisual") as TileMapLayer
	var ground_surface := room.get_node_or_null("GroundSurfaceVisual") as TileMapLayer
	var thin_surface := room.get_node_or_null("ThinPlatformSurfaceVisual") as TileMapLayer
	if terrain == null or platform == null or ground_surface == null or thin_surface == null:
		failures.append("%s: 正式地形四层不完整" % room_path)
		return

	for collision_layer: TileMapLayer in [terrain, platform]:
		if collision_layer.visible:
			failures.append("%s/%s: 碰撞权威层仍在成品画面中渲染" % [room_path, collision_layer.name])
		if not bool(collision_layer.get("collision_enabled")):
			failures.append("%s/%s: 碰撞权威层未启用 physics" % [room_path, collision_layer.name])
	for visual_layer: TileMapLayer in [ground_surface, thin_surface]:
		if not visual_layer.visible or bool(visual_layer.get("collision_enabled")):
			failures.append("%s/%s: 可见地表层必须 visible 且 visual-only" % [room_path, visual_layer.name])

	for cell: Vector2i in ground_surface.get_used_cells():
		if terrain.get_cell_source_id(cell) < 0:
			failures.append("%s/GroundSurfaceVisual%s: 缺少对应地形碰撞" % [room_path, cell])
			continue
		var visual_bounds := _visual_alpha_y_bounds(ground_surface, cell)
		var collision_bounds := _collision_y_bounds(terrain, cell)
		if visual_bounds.x == INF or collision_bounds.x == INF:
			failures.append("%s/GroundSurfaceVisual%s: 无法读取视觉或碰撞边缘" % [room_path, cell])
		elif absf(visual_bounds.x - collision_bounds.x) > MAX_WALKABLE_EDGE_GAP:
			failures.append(
				"%s/GroundSurfaceVisual%s: 视觉顶边 %.2f 与碰撞顶边 %.2f 错位 %.2fpx"
				% [room_path, cell, visual_bounds.x, collision_bounds.x, absf(visual_bounds.x - collision_bounds.x)]
			)

	for cell: Vector2i in platform.get_used_cells():
		if thin_surface.get_cell_source_id(cell) < 0:
			failures.append("%s/PlatformCollisionVisual%s: 缺少薄平台视觉" % [room_path, cell])
			continue
		var visual_bounds := _visual_alpha_y_bounds(thin_surface, cell)
		var collision_bounds := _collision_y_bounds(platform, cell)
		if visual_bounds.x == INF or collision_bounds.x == INF:
			failures.append("%s/ThinPlatformSurfaceVisual%s: 无法读取视觉或碰撞边缘" % [room_path, cell])
		elif absf(visual_bounds.x - collision_bounds.x) > MAX_WALKABLE_EDGE_GAP:
			failures.append(
				"%s/ThinPlatformSurfaceVisual%s: 视觉顶边 %.2f 与落脚面 %.2f 错位 %.2fpx"
				% [room_path, cell, visual_bounds.x, collision_bounds.x, absf(visual_bounds.x - collision_bounds.x)]
			)

	for cell: Vector2i in thin_surface.get_used_cells():
		if platform.get_cell_source_id(cell) >= 0:
			continue
		if terrain.get_cell_source_id(cell) < 0:
			failures.append("%s/ThinPlatformSurfaceVisual%s: 没有任何对应碰撞" % [room_path, cell])
			continue
		var visual_bounds := _visual_alpha_y_bounds(thin_surface, cell)
		var collision_bounds := _collision_y_bounds(terrain, cell)
		var nearest_gap := minf(
			minf(absf(visual_bounds.x - collision_bounds.x), absf(visual_bounds.y - collision_bounds.x)),
			minf(absf(visual_bounds.x - collision_bounds.y), absf(visual_bounds.y - collision_bounds.y))
		)
		if nearest_gap > MAX_CEILING_EDGE_GAP:
			failures.append("%s/ThinPlatformSurfaceVisual%s: 薄边与实体边缘错位 %.2fpx" % [room_path, cell, nearest_gap])

	_audit_collision_tilemaps(room, room_path, terrain, platform, failures)
	_audit_retired_collision_bodies(room, room_path, failures)


func _audit_static_floor(room: Node2D, room_path: String, failures: Array[String]) -> void:
	var floor_body := room.get_node_or_null("Floor") as StaticBody2D
	var shape_node := room.get_node_or_null("Floor/CollisionShape2D") as CollisionShape2D
	var floor_visual := room.get_node_or_null("Floor/FloorVisual") as Polygon2D
	var rectangle := shape_node.shape as RectangleShape2D if shape_node != null else null
	if floor_body == null or rectangle == null or floor_visual == null:
		failures.append("%s: 静态地面视觉/碰撞契约不完整" % room_path)
		return
	var polygon_top := INF
	for point: Vector2 in floor_visual.polygon:
		polygon_top = minf(polygon_top, floor_visual.to_global(point).y)
	var collision_top := shape_node.to_global(Vector2(0.0, -rectangle.size.y * 0.5)).y
	if absf(polygon_top - collision_top) > MAX_WALKABLE_EDGE_GAP:
		failures.append("%s/Floor: 视觉顶边 %.2f 与碰撞顶边 %.2f 错位" % [room_path, polygon_top, collision_top])


func _audit_collision_tilemaps(
	room: Node,
	room_path: String,
	terrain: TileMapLayer,
	platform: TileMapLayer,
	failures: Array[String],
) -> void:
	var stack: Array[Node] = [room]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is TileMapLayer and bool(node.get("collision_enabled")) and node != terrain and node != platform:
			failures.append("%s/%s: 出现第三个启用碰撞的 TileMapLayer" % [room_path, room.get_path_to(node)])
		for child: Node in node.get_children():
			stack.append(child)


func _audit_retired_collision_bodies(room: Node, room_path: String, failures: Array[String]) -> void:
	var stack: Array[Node] = [room]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is CollisionObject2D and node.get_meta("terrain_collision_authority", "") == "replaced_by_tilemap_layer":
			var body := node as CollisionObject2D
			if body.collision_layer != 0 or body.collision_mask != 0:
				failures.append("%s/%s: 退役地形碰撞仍启用 layer/mask" % [room_path, room.get_path_to(body)])
			for child: Node in body.get_children():
				if child is CollisionShape2D and not (child as CollisionShape2D).disabled:
					failures.append("%s/%s: 退役 CollisionShape2D 仍启用" % [room_path, room.get_path_to(child)])
		for child: Node in node.get_children():
			stack.append(child)


func _visual_alpha_y_bounds(layer: TileMapLayer, cell: Vector2i) -> Vector2:
	var source := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
	if source == null:
		return Vector2(INF, -INF)
	var atlas_coords := layer.get_cell_atlas_coords(cell)
	var alternative := layer.get_cell_alternative_tile(cell)
	var tile_data := source.get_tile_data(atlas_coords, alternative)
	if tile_data == null:
		return Vector2(INF, -INF)
	var region := source.get_tile_texture_region(atlas_coords)
	var cache_key := "%s:%s" % [source.texture.resource_path, region]
	var alpha_bounds: Vector2i = _alpha_bounds_cache.get(cache_key, Vector2i(-1, -1))
	if alpha_bounds.x < 0:
		alpha_bounds = _find_alpha_y_bounds(source.texture.get_image(), region)
		_alpha_bounds_cache[cache_key] = alpha_bounds
	if alpha_bounds.x < 0:
		return Vector2(INF, -INF)
	var center_y := layer.to_global(layer.map_to_local(cell)).y
	var scale_y := absf(layer.global_scale.y)
	var top := center_y + (float(alpha_bounds.x - tile_data.texture_origin.y) - float(region.size.y) * 0.5) * scale_y
	var bottom := center_y + (float(alpha_bounds.y + 1 - tile_data.texture_origin.y) - float(region.size.y) * 0.5) * scale_y
	return Vector2(top, bottom)


func _collision_y_bounds(layer: TileMapLayer, cell: Vector2i) -> Vector2:
	var source := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
	if source == null:
		return Vector2(INF, -INF)
	var tile_data := source.get_tile_data(layer.get_cell_atlas_coords(cell), layer.get_cell_alternative_tile(cell))
	if tile_data == null or tile_data.get_collision_polygons_count(0) == 0:
		return Vector2(INF, -INF)
	var min_y := INF
	var max_y := -INF
	for polygon_index: int in range(tile_data.get_collision_polygons_count(0)):
		for point: Vector2 in tile_data.get_collision_polygon_points(0, polygon_index):
			min_y = minf(min_y, point.y)
			max_y = maxf(max_y, point.y)
	var center_y := layer.to_global(layer.map_to_local(cell)).y
	var scale_y := absf(layer.global_scale.y)
	return Vector2(center_y + min_y * scale_y, center_y + max_y * scale_y)


func _find_alpha_y_bounds(image: Image, region: Rect2i) -> Vector2i:
	var min_y := -1
	var max_y := -1
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			if image.get_pixel(x, y).a > ALPHA_THRESHOLD:
				if min_y < 0:
					min_y = y - region.position.y
				max_y = y - region.position.y
	return Vector2i(min_y, max_y)


func _production_room_paths() -> Array[String]:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WORLD_MAP_PATH))
	var result: Array[String] = []
	if not parsed is Dictionary:
		return result
	for room_data: Dictionary in (parsed as Dictionary).get("rooms", []):
		result.append(str(room_data.get("path", "")))
	return result
