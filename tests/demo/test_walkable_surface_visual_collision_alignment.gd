# 全生产房间可踩面审计：视觉真实 alpha 边缘必须贴合物理接触面，碰撞权威层不得进入成品画面。
extends GutTest

const WORLD_MAP_PATH := "res://assets/configs/world_map/alpha_demo_world_map.json"
const FORMAL_TERRAIN_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const PHASE2_SOLID_TEXTURE_PATH := "res://assets/art/textures/dac_continuous_stone_underlay.png"
const PHASE2_GROUND_ATLAS_PATH := "res://assets/art/tilesets/shrine_trial_tileset_ai01.png"
const PHASE2_GROUND_REGION := Rect2(0, 0, 192, 64)
const PHASE2_GROUND_ALPHA_TOP_INSET := 37.0
const PHASE2_PLATFORM_TEXTURE_PATH := "res://assets/art/tilesets/tutorial_jump_platform_visual_ai02.png"
const PHASE2_PLATFORM_ALPHA_TOP_INSET := 23.0
const REPORT_DIR := "res://tests/artifacts/local/runtime-visual-integrity"
const REPORT_PATH := "%s/walkable_surface_2d_report.json" % REPORT_DIR
const EXPECTED_ROOM_COUNT := 44
const EXPECTED_FORMAL_ROOM_COUNT := 38
const EXPECTED_STATIC_FLOOR_ROOM_COUNT := 6
const MAX_WALKABLE_EDGE_GAP := 0.25
const MAX_CELL_CENTERING_GAP := 0.25
const MAX_CEILING_EDGE_GAP := 2.25
const MAX_ALPHA_CAP_INSET := 12.25
const ALPHA_THRESHOLD := 0.05

var _alpha_bounds_cache: Dictionary = {}
var _audit_entries: Array[Dictionary] = []
var _collision_inventory: Array[Dictionary] = []


# TileSet collision polygon 使用格心局部坐标；满格地形若写成 0..tile_size，
# 会在运行态整体向右偏移半格，即使顶沿 Y 测试仍然可以通过。
func test_formal_terrain_collision_polygons_are_centered_on_cells() -> void:
	var tile_set := load(FORMAL_TERRAIN_TILESET_PATH) as TileSet
	assert_not_null(tile_set)
	if tile_set == null:
		return

	var failures: Array[String] = []
	var expected_left := -float(tile_set.tile_size.x) * 0.5
	var expected_right := float(tile_set.tile_size.x) * 0.5
	for source_index: int in range(tile_set.get_source_count()):
		var source_id := tile_set.get_source_id(source_index)
		var source := tile_set.get_source(source_id) as TileSetAtlasSource
		if source == null:
			continue
		for tile_index: int in range(source.get_tiles_count()):
			var atlas_coords := source.get_tile_id(tile_index)
			var tile_data := source.get_tile_data(atlas_coords, 0)
			if tile_data == null:
				continue
			for polygon_index: int in range(tile_data.get_collision_polygons_count(0)):
				var points := tile_data.get_collision_polygon_points(0, polygon_index)
				var min_x := INF
				var max_x := -INF
				for point: Vector2 in points:
					min_x = minf(min_x, point.x)
					max_x = maxf(max_x, point.x)
				if (
					absf(min_x - expected_left) > MAX_CELL_CENTERING_GAP
					or absf(max_x - expected_right) > MAX_CELL_CENTERING_GAP
				):
					failures.append(
						"source=%d tile=%s polygon=%d: X bounds %.2f..%.2f，期望 %.2f..%.2f"
						% [source_id, atlas_coords, polygon_index, min_x, max_x, expected_left, expected_right]
					)

	assert_true(failures.is_empty(), "\n" + "\n".join(failures))


# 资源坐标检查不能替代 PhysicsServer 结果：从教程薄平台左右边缘内外各落下一次，
# 防止 TileData 看似对齐、实际碰撞仍整体偏移半格。
func test_tutorial_platform_runtime_physics_matches_visible_edges() -> void:
	var packed := load("res://scenes/rooms/tutorial_room.tscn") as PackedScene
	assert_not_null(packed)
	if packed == null:
		return
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().physics_frame
	await get_tree().physics_frame

	var layout := room.get_node("Phase2GrayboxLayout")
	var platform_rect: Rect2 = (layout.get("one_way_rects") as Array)[0]
	var probes := [
		{"label": "left_inside", "x": platform_rect.position.x + 10.0, "should_land": true},
		{"label": "left_outside", "x": platform_rect.position.x - 10.0, "should_land": false},
		{"label": "right_inside", "x": platform_rect.end.x - 10.0, "should_land": true},
		{"label": "right_outside", "x": platform_rect.end.x + 10.0, "should_land": false},
	]
	var failures: Array[String] = []
	for probe_data: Dictionary in probes:
		var result: Dictionary = await _drop_runtime_probe(room, float(probe_data["x"]))
		var landed_on_platform := bool(result["on_floor"]) and float(result["final_y"]) < 110.0
		if landed_on_platform != bool(probe_data["should_land"]):
			failures.append(
				"%s x=%.1f: platform_land=%s final_y=%.2f，期望 %s"
				% [
					probe_data["label"],
					probe_data["x"],
					landed_on_platform,
					result["final_y"],
					probe_data["should_land"],
				]
			)
	assert_true(failures.is_empty(), "\n" + "\n".join(failures))


# 同一可见资产不能同时教玩家“可从下方穿越”和“实体阻挡”两种互斥规则。
func test_walkable_visual_assets_have_one_physics_affordance() -> void:
	var bindings: Dictionary = {}
	var failures: Array[String] = []
	for room_path: String in _production_room_paths():
		var packed := load(room_path) as PackedScene
		if packed == null:
			continue
		var room := packed.instantiate() as Node2D
		var terrain := room.get_node_or_null("TerrainCollisionVisual") as TileMapLayer
		var platform := room.get_node_or_null("PlatformCollisionVisual") as TileMapLayer
		var thin_surface := room.get_node_or_null("ThinPlatformSurfaceVisual") as TileMapLayer
		if terrain != null and platform != null and thin_surface != null:
			_validate_visual_role_contract(room_path, thin_surface, "one_way_platform", failures)
			_collect_asset_role(bindings, room_path, thin_surface, "one_way_platform", platform.get_used_cells())
			var solid_cells: Array[Vector2i] = []
			for cell: Vector2i in thin_surface.get_used_cells():
				if platform.get_cell_source_id(cell) < 0 and terrain.get_cell_source_id(cell) >= 0:
					solid_cells.append(cell)
			_collect_asset_role(bindings, room_path, thin_surface, "thin_solid", solid_cells)
			if not solid_cells.is_empty():
				failures.append("%s/%s: 单向跳台资产覆盖了实体碰撞格 %s" % [room_path, thin_surface.name, solid_cells])
		var lintel_surface := room.get_node_or_null("DashGateLintelVisual") as TileMapLayer
		if terrain != null and lintel_surface != null:
			_validate_visual_role_contract(room_path, lintel_surface, "thin_solid", failures)
			_collect_asset_role(bindings, room_path, lintel_surface, "thin_solid", lintel_surface.get_used_cells())
		room.free()

	for asset_id_variant: Variant in bindings.keys():
		var asset_id := str(asset_id_variant)
		var entry: Dictionary = bindings[asset_id]
		var roles: Array = entry.get("roles", [])
		if roles.size() > 1:
			failures.append("asset=%s 跨互斥物理角色 %s；来源=%s" % [asset_id, roles, entry.get("rooms", [])])
	assert_true(failures.is_empty(), "\n" + "\n".join(failures))


func test_all_production_room_walkable_visuals_match_collision() -> void:
	var failures: Array[String] = []
	var room_paths := _production_room_paths()
	var formal_room_count := 0
	var static_floor_room_count := 0
	_audit_entries.clear()
	_collision_inventory.clear()

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
			if room.get_node_or_null("Phase2GrayboxLayout") != null:
				add_child(room)
				await get_tree().process_frame
				_audit_phase2_room(room, room_path, failures)
			else:
				_audit_formal_room(room, room_path, failures)
		else:
			static_floor_room_count += 1
			_audit_static_floor(room, room_path, failures)
		_inventory_collision_nodes(room, room_path)
		room.free()

	assert_eq(formal_room_count, EXPECTED_FORMAL_ROOM_COUNT)
	assert_eq(static_floor_room_count, EXPECTED_STATIC_FLOOR_ROOM_COUNT)
	assert_true(
		_write_2d_report(room_paths.size(), formal_room_count, static_floor_room_count, failures),
		"二维地形审计报告必须可以写入 ignored 本地证据目录",
	)
	assert_true(failures.is_empty(), "\n" + "\n".join(failures))


func _audit_phase2_room(room: Node2D, room_path: String, failures: Array[String]) -> void:
	var layout := room.get_node("Phase2GrayboxLayout")
	for old_layer_name: String in ["TerrainCollisionVisual", "PlatformCollisionVisual", "GroundSurfaceVisual", "ThinPlatformSurfaceVisual"]:
		var old_layer := room.get_node(old_layer_name) as TileMapLayer
		if old_layer.visible or bool(old_layer.get("collision_enabled")):
			failures.append("%s/%s: Phase2 旧 TileMap 必须隐藏且关闭碰撞" % [room_path, old_layer_name])

	var platform_count := 0
	for child: Node in layout.get_children():
		if not child is StaticBody2D:
			continue
		platform_count += 1
		var body := child as StaticBody2D
		var collision := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
		var rectangle := collision.shape as RectangleShape2D if collision != null else null
		var surface_name := "OneWaySurfaceVisual" if collision != null and collision.one_way_collision else "GroundSurfaceVisual"
		var surface := body.get_node_or_null(surface_name) as NinePatchRect
		if body.collision_layer != 1 or rectangle == null or surface == null:
			failures.append("%s/%s: Phase2 碰撞或同源表面不完整" % [room_path, body.name])
			continue
		var alpha_top_inset := PHASE2_PLATFORM_ALPHA_TOP_INSET if collision.one_way_collision else PHASE2_GROUND_ALPHA_TOP_INSET
		var expected_position := Vector2(-rectangle.size.x * 0.5, -rectangle.size.y * 0.5 - alpha_top_inset)
		if not surface.position.is_equal_approx(expected_position) or not is_equal_approx(surface.size.x, rectangle.size.x):
			failures.append("%s/%s: 表面尺寸或顶边未与碰撞同源" % [room_path, body.name])
		var body_visual := body.get_node_or_null("TerrainBodyVisual") as Polygon2D
		if collision.one_way_collision:
			if surface.texture == null or surface.texture.resource_path != PHASE2_PLATFORM_TEXTURE_PATH:
				failures.append("%s/%s: 单向平台未使用批准的跳台资产" % [room_path, body.name])
			if body_visual != null:
				failures.append("%s/%s: 单向平台不应伪装成实体地块" % [room_path, body.name])
		else:
			var ground_surface := surface.texture as AtlasTexture
			if ground_surface == null or ground_surface.atlas.resource_path != PHASE2_GROUND_ATLAS_PATH or ground_surface.region != PHASE2_GROUND_REGION:
				failures.append("%s/%s: 实体地面未使用批准的地面顶沿" % [room_path, body.name])
			if body_visual == null or body_visual.texture == null or body_visual.texture.resource_path != PHASE2_SOLID_TEXTURE_PATH:
				failures.append("%s/%s: 实体地块缺少同源石质填充" % [room_path, body.name])
	_audit_entries.append({
		"room": room_path,
		"role": "phase2_runtime_geometry",
		"platform_count": platform_count,
		"verdict": "pass" if platform_count == int(layout.call("get_runtime_platform_count")) else "fail",
	})
	if platform_count != int(layout.call("get_runtime_platform_count")):
		failures.append("%s: Phase2 运行平台数量与蓝图矩形不一致" % room_path)


func _drop_runtime_probe(room: Node2D, world_x: float) -> Dictionary:
	var probe := CharacterBody2D.new()
	probe.name = "RuntimeEdgeProbe"
	probe.collision_layer = 2
	probe.collision_mask = 1
	probe.position = Vector2(world_x, 40.0)
	var shape_node := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(4.0, 8.0)
	shape_node.shape = rectangle
	probe.add_child(shape_node)
	room.add_child(probe)
	await get_tree().physics_frame

	for _frame: int in range(90):
		probe.velocity.y = minf(probe.velocity.y + 1600.0 / 60.0, 600.0)
		probe.move_and_slide()
		await get_tree().physics_frame
		if probe.is_on_floor():
			break
	var result := {
		"final_y": probe.global_position.y,
		"on_floor": probe.is_on_floor(),
	}
	probe.queue_free()
	await get_tree().physics_frame
	return result


func _audit_formal_room(room: Node2D, room_path: String, failures: Array[String]) -> void:
	var terrain := room.get_node_or_null("TerrainCollisionVisual") as TileMapLayer
	var platform := room.get_node_or_null("PlatformCollisionVisual") as TileMapLayer
	var ground_surface := room.get_node_or_null("GroundSurfaceVisual") as TileMapLayer
	var thin_surface := room.get_node_or_null("ThinPlatformSurfaceVisual") as TileMapLayer
	var lintel_surface := room.get_node_or_null("DashGateLintelVisual") as TileMapLayer
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
	if lintel_surface != null and (not lintel_surface.visible or bool(lintel_surface.get("collision_enabled"))):
		failures.append("%s/%s: 门楣可见层必须 visible 且 visual-only" % [room_path, lintel_surface.name])
	_validate_visual_role_contract(room_path, thin_surface, "one_way_platform", failures)
	if lintel_surface != null:
		_validate_visual_role_contract(room_path, lintel_surface, "thin_solid", failures)

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
		_audit_cell_horizontal_alignment(room_path, ground_surface, terrain, cell, "ground", failures)

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
		_audit_cell_horizontal_alignment(room_path, thin_surface, platform, cell, "one_way_platform", failures)

	for cell: Vector2i in thin_surface.get_used_cells():
		if platform.get_cell_source_id(cell) >= 0:
			continue
		failures.append("%s/ThinPlatformSurfaceVisual%s: 单向跳台资产没有对应 one-way 碰撞" % [room_path, cell])

	if lintel_surface != null:
		for cell: Vector2i in lintel_surface.get_used_cells():
			if terrain.get_cell_source_id(cell) < 0:
				failures.append("%s/DashGateLintelVisual%s: 没有对应实体碰撞" % [room_path, cell])
				continue
			if platform.get_cell_source_id(cell) >= 0:
				failures.append("%s/DashGateLintelVisual%s: 实体门楣不能覆盖 one-way 碰撞" % [room_path, cell])
			var visual_bounds := _visual_alpha_y_bounds(lintel_surface, cell)
			var collision_bounds := _collision_y_bounds(terrain, cell)
			var top_gap := absf(visual_bounds.x - collision_bounds.x)
			if top_gap > MAX_CEILING_EDGE_GAP:
				failures.append("%s/DashGateLintelVisual%s: 视觉顶边 %.2f 与实体碰撞顶边 %.2f 错位 %.2fpx" % [room_path, cell, visual_bounds.x, collision_bounds.x, top_gap])
			_audit_cell_horizontal_alignment(room_path, lintel_surface, terrain, cell, "thin_solid", failures)

	_audit_exposed_terrain_coverage(room, room_path, terrain, ground_surface, thin_surface, lintel_surface, failures)
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
	var polygon_points: Array[Vector2] = []
	for point: Vector2 in floor_visual.polygon:
		polygon_points.append(floor_visual.to_global(point))
	var polygon_bounds := _bounds_from_points(polygon_points)
	var half_size := rectangle.size * 0.5
	var collision_bounds := _bounds_from_points([
		shape_node.to_global(Vector2(-half_size.x, -half_size.y)),
		shape_node.to_global(Vector2(half_size.x, -half_size.y)),
		shape_node.to_global(Vector2(half_size.x, half_size.y)),
		shape_node.to_global(Vector2(-half_size.x, half_size.y)),
	])
	var polygon_top := polygon_bounds.position.y
	var collision_top := collision_bounds.position.y
	if absf(polygon_top - collision_top) > MAX_WALKABLE_EDGE_GAP:
		failures.append("%s/Floor: 视觉顶边 %.2f 与碰撞顶边 %.2f 错位" % [room_path, polygon_top, collision_top])
	var left_gap := absf(polygon_bounds.position.x - collision_bounds.position.x)
	var right_gap := absf(polygon_bounds.end.x - collision_bounds.end.x)
	var horizontal_ok := left_gap <= MAX_CELL_CENTERING_GAP and right_gap <= MAX_CELL_CENTERING_GAP
	_audit_entries.append({
		"room": room_path,
		"role": "static_floor",
		"visual_node": "Floor/FloorVisual",
		"collision_node": "Floor/CollisionShape2D",
		"visual_bounds": _rect_to_report(polygon_bounds),
		"collision_bounds": _rect_to_report(collision_bounds),
		"left_gap": left_gap,
		"right_gap": right_gap,
		"verdict": "pass" if horizontal_ok else "fail",
	})
	if not horizontal_ok:
		failures.append(
			"%s/Floor: 视觉与碰撞左右边缘错位 left=%.2fpx right=%.2fpx"
			% [room_path, left_gap, right_gap]
		)


func _audit_cell_horizontal_alignment(
	room_path: String,
	visual_layer: TileMapLayer,
	collision_layer: TileMapLayer,
	cell: Vector2i,
	role: String,
	failures: Array[String],
) -> void:
	var footprint_bounds := _visual_texture_bounds(visual_layer, cell)
	var alpha_bounds := _visual_alpha_bounds(visual_layer, cell)
	var collision_bounds := _collision_bounds(collision_layer, cell)
	if not _rect_is_valid(footprint_bounds) or not _rect_is_valid(alpha_bounds) or not _rect_is_valid(collision_bounds):
		failures.append(
			"%s/%s%s: 无法读取二维视觉 footprint、alpha 或碰撞 bounds"
			% [room_path, visual_layer.name, cell]
		)
		return

	var left_gap := absf(footprint_bounds.position.x - collision_bounds.position.x)
	var right_gap := absf(footprint_bounds.end.x - collision_bounds.end.x)
	var alpha_left_inset := maxf(alpha_bounds.position.x - footprint_bounds.position.x, 0.0)
	var alpha_right_inset := maxf(footprint_bounds.end.x - alpha_bounds.end.x, 0.0)
	var footprint_ok := left_gap <= MAX_CELL_CENTERING_GAP and right_gap <= MAX_CELL_CENTERING_GAP
	var alpha_support_ok := alpha_left_inset <= MAX_ALPHA_CAP_INSET and alpha_right_inset <= MAX_ALPHA_CAP_INSET
	var verdict := "pass" if footprint_ok and alpha_support_ok else "fail"
	_audit_entries.append({
		"room": room_path,
		"role": role,
		"cell": [cell.x, cell.y],
		"visual_layer": String(visual_layer.name),
		"collision_layer": String(collision_layer.name),
		"visual_footprint_bounds": _rect_to_report(footprint_bounds),
		"visual_alpha_bounds": _rect_to_report(alpha_bounds),
		"collision_bounds": _rect_to_report(collision_bounds),
		"left_gap": left_gap,
		"right_gap": right_gap,
		"alpha_left_inset": alpha_left_inset,
		"alpha_right_inset": alpha_right_inset,
		"verdict": verdict,
	})
	if not footprint_ok:
		failures.append(
			"%s/%s%s: 格心二维 footprint 与碰撞左右错位 left=%.2fpx right=%.2fpx"
			% [room_path, visual_layer.name, cell, left_gap, right_gap]
		)
	if not alpha_support_ok:
		failures.append(
			"%s/%s%s: 可见 alpha 离碰撞格边过远 left=%.2fpx right=%.2fpx"
			% [room_path, visual_layer.name, cell, alpha_left_inset, alpha_right_inset]
		)


func _collect_asset_role(bindings: Dictionary, room_path: String, layer: TileMapLayer, role: String, cells: Array[Vector2i]) -> void:
	if cells.is_empty():
		return
	var asset_id := str(layer.get_meta("asset_id", ""))
	if asset_id.is_empty() and layer.tile_set != null:
		asset_id = layer.tile_set.resource_path
	var entry: Dictionary = bindings.get(asset_id, {"roles": [], "rooms": []})
	var roles: Array = entry["roles"]
	var rooms: Array = entry["rooms"]
	if not roles.has(role):
		roles.append(role)
	var room_role := "%s:%s" % [room_path, role]
	if not rooms.has(room_role):
		rooms.append(room_role)
	bindings[asset_id] = entry


func _validate_visual_role_contract(
	room_path: String,
	layer: TileMapLayer,
	expected_role: String,
	failures: Array[String]
) -> void:
	if layer.tile_set == null:
		failures.append("%s/%s: 缺少 TileSet 语义契约" % [room_path, layer.name])
		return
	var declared_role := str(layer.tile_set.get_meta("physics_affordance", ""))
	var allowed_roles: PackedStringArray = layer.tile_set.get_meta("allowed_surface_roles", PackedStringArray())
	var tileset_asset_id := str(layer.tile_set.get_meta("asset_id", ""))
	var layer_asset_id := str(layer.get_meta("asset_id", tileset_asset_id))
	if declared_role != expected_role:
		failures.append("%s/%s: TileSet role=%s，期望 %s" % [room_path, layer.name, declared_role, expected_role])
	if not allowed_roles.has(expected_role):
		failures.append("%s/%s: allowed_surface_roles 未声明 %s" % [room_path, layer.name, expected_role])
	if tileset_asset_id.is_empty() or layer_asset_id != tileset_asset_id:
		failures.append("%s/%s: layer asset_id=%s 与 TileSet asset_id=%s 不一致" % [room_path, layer.name, layer_asset_id, tileset_asset_id])
	if layer.has_meta("physics_affordance") and str(layer.get_meta("physics_affordance")) != expected_role:
		failures.append("%s/%s: layer physics_affordance 与 %s 不一致" % [room_path, layer.name, expected_role])


# 反向检查碰撞权威：只有上方没有实体格的 exposed top 才是潜在可踩面；
# 墙体内部和被上层实体遮住的格子不要求额外地表视觉。
func _audit_exposed_terrain_coverage(
	room: Node2D,
	room_path: String,
	terrain: TileMapLayer,
	ground_surface: TileMapLayer,
	thin_surface: TileMapLayer,
	lintel_surface: TileMapLayer,
	failures: Array[String],
) -> void:
	var camera_limits := Rect2i()
	var has_camera_limits := false
	if room.has_method("get_camera_limits"):
		camera_limits = room.call("get_camera_limits")
		has_camera_limits = true
	for cell: Vector2i in terrain.get_used_cells():
		if terrain.get_cell_source_id(cell + Vector2i.UP) >= 0:
			continue
		var has_ground_visual := ground_surface.get_cell_source_id(cell) >= 0
		var has_thin_visual := thin_surface.get_cell_source_id(cell) >= 0
		var has_lintel_visual := lintel_surface != null and lintel_surface.get_cell_source_id(cell) >= 0
		var covered := has_ground_visual or has_thin_visual or has_lintel_visual
		var collision_bounds := _collision_bounds(terrain, cell)
		var scaled_cell_height := float(terrain.tile_set.tile_size.y) * absf(terrain.global_scale.y)
		var touches_outer_wall := (
			has_camera_limits
			and (
				collision_bounds.position.x <= float(camera_limits.position.x) + MAX_WALKABLE_EDGE_GAP
				or collision_bounds.end.x >= float(camera_limits.end.x) - MAX_WALKABLE_EDGE_GAP
			)
		)
		var is_camera_top_boundary := (
			_rect_is_valid(collision_bounds)
			and has_camera_limits
			and touches_outer_wall
			and collision_bounds.position.y <= float(camera_limits.position.y) + scaled_cell_height + MAX_WALKABLE_EDGE_GAP
		)
		var verdict := "pass" if covered else ("exception" if is_camera_top_boundary else "fail")
		_audit_entries.append({
			"room": room_path,
			"role": "exposed_terrain_coverage",
			"cell": [cell.x, cell.y],
			"collision_layer": String(terrain.name),
			"visual_layer": (
				String(ground_surface.name)
				if has_ground_visual
				else (String(thin_surface.name) if has_thin_visual else (String(lintel_surface.name) if has_lintel_visual else ""))
			),
			"exception_reason": "outer_boundary_wall_top" if is_camera_top_boundary else "",
			"verdict": verdict,
		})
		if verdict == "fail":
			failures.append(
				"%s/TerrainCollisionVisual%s: exposed top 没有 GroundSurfaceVisual、ThinPlatformSurfaceVisual 或 DashGateLintelVisual"
				% [room_path, cell]
			)


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


# 逐房保存所有 TileMap 与 CollisionObject2D 的活动状态，确保门禁、Area、移动体和遗留 shape
# 都出现在报告里；是否属于可踩地形仍由上面的双向 surface 契约判定。
func _inventory_collision_nodes(room: Node, room_path: String) -> void:
	var stack: Array[Node] = [room]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is TileMapLayer:
			var tile_layer := node as TileMapLayer
			_collision_inventory.append({
				"room": room_path,
				"node": String(room.get_path_to(tile_layer)),
				"type": "TileMapLayer",
				"classification": _classify_tilemap_collision(tile_layer),
				"collision_enabled": bool(tile_layer.get("collision_enabled")),
				"visible": tile_layer.visible,
				"used_cell_count": tile_layer.get_used_cells().size(),
			})
		elif node is CollisionObject2D:
			var collision_object := node as CollisionObject2D
			_collision_inventory.append({
				"room": room_path,
				"node": String(room.get_path_to(collision_object)),
				"type": collision_object.get_class(),
				"classification": _classify_collision_object(collision_object),
				"collision_layer": collision_object.collision_layer,
				"collision_mask": collision_object.collision_mask,
				"active_shape_count": _active_collision_shape_count(collision_object),
				"terrain_collision_authority": String(collision_object.get_meta("terrain_collision_authority", "")),
			})
		for child: Node in node.get_children():
			stack.append(child)


func _classify_tilemap_collision(layer: TileMapLayer) -> String:
	if not bool(layer.get("collision_enabled")):
		return "visual_only_or_retired_tilemap"
	if layer.name == "TerrainCollisionVisual":
		return "terrain_collision_authority"
	if layer.name == "PlatformCollisionVisual":
		return "one_way_platform_collision_authority"
	return "unexpected_collision_tilemap"


func _classify_collision_object(collision_object: CollisionObject2D) -> String:
	if collision_object.get_meta("terrain_collision_authority", "") == "replaced_by_tilemap_layer":
		return "retired_terrain_authoring_body"
	if collision_object is Area2D:
		return "logic_or_hazard_area"
	if collision_object is CharacterBody2D:
		return "character_or_enemy_body"
	if collision_object is AnimatableBody2D:
		return "moving_platform_or_dynamic_body"
	if collision_object.name == "Floor":
		return "static_floor_authority"
	return "static_logic_barrier_or_prop"


func _active_collision_shape_count(collision_object: CollisionObject2D) -> int:
	var count := 0
	for child: Node in collision_object.get_children():
		if child is CollisionShape2D and not (child as CollisionShape2D).disabled:
			count += 1
		elif child is CollisionPolygon2D and not (child as CollisionPolygon2D).disabled:
			count += 1
	return count


func _visual_alpha_y_bounds(layer: TileMapLayer, cell: Vector2i) -> Vector2:
	var bounds := _visual_alpha_bounds(layer, cell)
	if not _rect_is_valid(bounds):
		return Vector2(INF, -INF)
	return Vector2(bounds.position.y, bounds.end.y)


func _visual_alpha_bounds(layer: TileMapLayer, cell: Vector2i) -> Rect2:
	var source := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
	if source == null:
		return _invalid_rect()
	var atlas_coords := layer.get_cell_atlas_coords(cell)
	var alternative := layer.get_cell_alternative_tile(cell)
	var tile_data := source.get_tile_data(atlas_coords, alternative)
	if tile_data == null:
		return _invalid_rect()
	var region := source.get_tile_texture_region(atlas_coords)
	var cache_key := "%s:%s" % [source.texture.resource_path, region]
	var alpha_bounds: Rect2i = _alpha_bounds_cache.get(cache_key, Rect2i(-1, -1, 0, 0))
	if alpha_bounds.position.x < 0:
		alpha_bounds = _find_alpha_bounds(source.texture.get_image(), region)
		_alpha_bounds_cache[cache_key] = alpha_bounds
	if alpha_bounds.position.x < 0:
		return _invalid_rect()
	var local_position := (
		layer.map_to_local(cell)
		+ Vector2(alpha_bounds.position - tile_data.texture_origin)
		- Vector2(region.size) * 0.5
	)
	return _global_bounds_for_local_rect(layer, Rect2(local_position, Vector2(alpha_bounds.size)))


func _visual_texture_bounds(layer: TileMapLayer, cell: Vector2i) -> Rect2:
	var source := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
	if source == null:
		return _invalid_rect()
	var atlas_coords := layer.get_cell_atlas_coords(cell)
	var tile_data := source.get_tile_data(atlas_coords, layer.get_cell_alternative_tile(cell))
	if tile_data == null:
		return _invalid_rect()
	var region := source.get_tile_texture_region(atlas_coords)
	var local_position := (
		layer.map_to_local(cell)
		- Vector2(tile_data.texture_origin)
		- Vector2(region.size) * 0.5
	)
	return _global_bounds_for_local_rect(layer, Rect2(local_position, Vector2(region.size)))


func _collision_y_bounds(layer: TileMapLayer, cell: Vector2i) -> Vector2:
	var bounds := _collision_bounds(layer, cell)
	if not _rect_is_valid(bounds):
		return Vector2(INF, -INF)
	return Vector2(bounds.position.y, bounds.end.y)


func _collision_bounds(layer: TileMapLayer, cell: Vector2i) -> Rect2:
	var source := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
	if source == null:
		return _invalid_rect()
	var tile_data := source.get_tile_data(layer.get_cell_atlas_coords(cell), layer.get_cell_alternative_tile(cell))
	if tile_data == null or tile_data.get_collision_polygons_count(0) == 0:
		return _invalid_rect()
	var points: Array[Vector2] = []
	var local_center := layer.map_to_local(cell)
	for polygon_index: int in range(tile_data.get_collision_polygons_count(0)):
		for point: Vector2 in tile_data.get_collision_polygon_points(0, polygon_index):
			points.append(layer.to_global(local_center + point))
	return _bounds_from_points(points)


func _find_alpha_bounds(image: Image, region: Rect2i) -> Rect2i:
	var min_x := region.end.x
	var min_y := region.end.y
	var max_x := -1
	var max_y := -1
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			if image.get_pixel(x, y).a > ALPHA_THRESHOLD:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < 0 or max_y < 0:
		return Rect2i(-1, -1, 0, 0)
	return Rect2i(
		Vector2i(min_x - region.position.x, min_y - region.position.y),
		Vector2i(max_x - min_x + 1, max_y - min_y + 1),
	)


func _global_bounds_for_local_rect(layer: TileMapLayer, local_rect: Rect2) -> Rect2:
	return _bounds_from_points([
		layer.to_global(local_rect.position),
		layer.to_global(Vector2(local_rect.end.x, local_rect.position.y)),
		layer.to_global(local_rect.end),
		layer.to_global(Vector2(local_rect.position.x, local_rect.end.y)),
	])


func _bounds_from_points(points: Array[Vector2]) -> Rect2:
	if points.is_empty():
		return _invalid_rect()
	var min_point := Vector2(INF, INF)
	var max_point := Vector2(-INF, -INF)
	for point: Vector2 in points:
		min_point.x = minf(min_point.x, point.x)
		min_point.y = minf(min_point.y, point.y)
		max_point.x = maxf(max_point.x, point.x)
		max_point.y = maxf(max_point.y, point.y)
	return Rect2(min_point, max_point - min_point)


func _invalid_rect() -> Rect2:
	return Rect2(Vector2(INF, INF), Vector2.ZERO)


func _rect_is_valid(bounds: Rect2) -> bool:
	return bounds.position.x != INF and bounds.position.y != INF


func _rect_to_report(bounds: Rect2) -> Dictionary:
	return {
		"left": bounds.position.x,
		"top": bounds.position.y,
		"right": bounds.end.x,
		"bottom": bounds.end.y,
	}


func _write_2d_report(
	room_count: int,
	formal_room_count: int,
	static_floor_room_count: int,
	failures: Array[String],
) -> bool:
	var absolute_dir := ProjectSettings.globalize_path(REPORT_DIR)
	if DirAccess.make_dir_recursive_absolute(absolute_dir) != OK:
		return false
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file == null:
		return false
	var failed_entry_count := 0
	var exception_entry_count := 0
	for entry: Dictionary in _audit_entries:
		if entry.get("verdict", "fail") == "fail":
			failed_entry_count += 1
		elif entry.get("verdict", "fail") == "exception":
			exception_entry_count += 1
	file.store_string(JSON.stringify({
		"review_id": "walkable_surface_2d_alignment",
		"room_count": room_count,
		"formal_room_count": formal_room_count,
		"static_floor_room_count": static_floor_room_count,
		"entry_count": _audit_entries.size(),
		"failed_entry_count": failed_entry_count,
		"exception_entry_count": exception_entry_count,
		"collision_inventory_count": _collision_inventory.size(),
		"ok": failures.is_empty() and failed_entry_count == 0,
		"failures": failures,
		"entries": _audit_entries,
		"collision_inventory": _collision_inventory,
		"boundary": "自动二维几何与 alpha 承托审计；不替代真人对路线读值和美术风格的签核。",
	}, "\t") + "\n")
	return true


func _production_room_paths() -> Array[String]:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WORLD_MAP_PATH))
	var result: Array[String] = []
	if not parsed is Dictionary:
		return result
	for room_data: Dictionary in (parsed as Dictionary).get("rooms", []):
		result.append(str(room_data.get("path", "")))
	return result
