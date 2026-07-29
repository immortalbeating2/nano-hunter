extends SceneTree

# 正式地图 Batch 1：test_room / combat_trial_room / goal_trial_room。
# ponytail: 一个批次脚本共享铺层小函数，房间差异仍保留在三个显式方法中。

const TEST_ROOM_PATH := "res://scenes/rooms/test_room.tscn"
const COMBAT_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const GOAL_ROOM_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const TERRAIN_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"

const TERRAIN_SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)
const PLATFORM_OFFSET := Vector2(0.0, -16.0)
const SURFACE_OFFSET := Vector2(0.0, -7.0)
const OLD_TILE_LAYERS := ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]
const VISUAL_ONLY_TILE_LAYERS := ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]

const FLAT_SOURCE := 0
const FLAT_CENTER_A := Vector2i(0, 0)
const FLAT_CENTER_B := Vector2i(1, 0)
const GROUND_LEFT_CAP := Vector2i(2, 0)
const GROUND_RIGHT_CAP := Vector2i(3, 0)
const PLATFORM_CENTER := Vector2i(0, 2)
const PLATFORM_LEFT_CAP := Vector2i(1, 2)
const PLATFORM_RIGHT_CAP := Vector2i(2, 2)
const SURFACE_LEFT := Vector2i(0, 0)
const SURFACE_CENTER := Vector2i(1, 0)
const SURFACE_RIGHT := Vector2i(2, 0)
const TEST_SURFACE_COLOR := Color(0.58, 0.62, 0.61, 0.9)
const TEST_MASS_COLOR := Color(0.34, 0.38, 0.39, 0.62)


func _init() -> void:
	var terrain_tileset := load(TERRAIN_TILESET_PATH) as TileSet
	var surface_tileset := load(SURFACE_TILESET_PATH) as TileSet
	var thin_surface_tileset := load(THIN_SURFACE_TILESET_PATH) as TileSet
	if terrain_tileset == null or surface_tileset == null or thin_surface_tileset == null:
		push_error("Batch 1 formal map tilesets are incomplete.")
		quit(1)
		return

	var jobs := [
		{"path": TEST_ROOM_PATH, "method": Callable(self, "_apply_test_room")},
		{"path": COMBAT_ROOM_PATH, "method": Callable(self, "_apply_combat_room")},
		{"path": GOAL_ROOM_PATH, "method": Callable(self, "_apply_goal_room")},
	]
	for job: Dictionary in jobs:
		if not _apply_and_save(str(job.path), job.method, terrain_tileset, surface_tileset, thin_surface_tileset):
			quit(1)
			return
	print("formal map Batch 1 applied: 3 rooms")
	quit(0)


func _apply_and_save(path: String, method: Callable, terrain_tileset: TileSet, surface_tileset: TileSet, thin_surface_tileset: TileSet) -> bool:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Cannot load Batch 1 room: %s" % path)
		return false
	var root := packed.instantiate()
	method.call(root, terrain_tileset, surface_tileset, thin_surface_tileset)
	var repacked := PackedScene.new()
	var pack_result := repacked.pack(root)
	root.free()
	if pack_result != OK:
		push_error("Cannot pack Batch 1 room: %s" % path)
		return false
	return ResourceSaver.save(repacked, path) == OK


# test_room 是非主线机制沙盒，保留精确 shape collision，只清理与碰撞不一致的试铺层。
func _apply_test_room(root: Node, _terrain: TileSet, _surface: TileSet, _thin: TileSet) -> void:
	_hide_old_tile_layers(root)
	_hide_material_art(root)
	var backdrop := root.get_node_or_null("Backdrop") as Polygon2D
	if backdrop != null:
		backdrop.z_index = -4
		_set_backdrop_rect(backdrop, Rect2(-520, -296, 1040, 592))
	var background := root.get_node_or_null("DemoBackgroundArt") as Sprite2D
	if background != null:
		background.z_index = -3
		background.position = Vector2.ZERO
		background.scale = Vector2(0.62, 0.62)
		background.modulate = Color(1.0, 1.0, 1.0, 0.5)
		background.set_meta(&"asset_binding_note", "single_sprite_test_sandbox_coverage")
	var goal_visual := root.get_node_or_null("GoalVisual") as CanvasItem
	if goal_visual != null:
		goal_visual.visible = false
	for path: String in ["Floor/FloorVisual", "FloorRight/FloorVisual", "MidPlatform/PlatformVisual", "DashGapLeft/PlatformVisual", "DashGapRight/PlatformVisual", "DashGateCeiling/CeilingVisual"]:
		var visual := root.get_node_or_null(NodePath(path)) as Polygon2D
		if visual != null:
			visual.visible = true
			visual.color = TEST_MASS_COLOR
			visual.set_meta(&"asset_binding_note", "shape_exact_visual_surface_for_test_sandbox")
	_configure_test_wall(root, "LeftWall/LeftWallVisual")
	_configure_test_wall(root, "RightWall/RightWallVisual")
	_add_test_collision_edge(root, "Floor", "FloorTopEdge", -192.0, 192.0, -16.0, true)
	_add_test_collision_edge(root, "FloorRight", "FloorTopEdge", -192.0, 192.0, -16.0, true)
	_add_test_collision_edge(root, "MidPlatform", "PlatformTopEdge", -112.0, 112.0, -12.0, true)
	_add_test_collision_edge(root, "DashGapLeft", "PlatformTopEdge", -44.0, 44.0, -16.0, true)
	_add_test_collision_edge(root, "DashGapRight", "PlatformTopEdge", -44.0, 44.0, -16.0, true)
	_add_test_collision_edge(root, "DashGateCeiling", "CeilingBottomEdge", -48.0, 48.0, 4.0, false)


func _apply_combat_room(root: Node, terrain_tileset: TileSet, surface_tileset: TileSet, thin_surface_tileset: TileSet) -> void:
	_prepare_production_room(root, terrain_tileset, surface_tileset, thin_surface_tileset, Vector2i(-6, 2), 18, [])
	_configure_backdrop(root, Rect2(-384, -192, 1152, 384))
	_configure_background(root, Vector2(192, 0), Vector2(0.7, 0.7))
	_set_position(root, "BasicMeleeEnemy", Vector2(-40, 152))
	_set_position(root, "ExitBarrier", Vector2(512, 104))
	_set_position(root, "ExitZone", Vector2(704, 96))
	_set_position(root, "LeftExitZone", Vector2(-352, 96))
	_configure_gate_art(root, "ExitBarrier")
	_hide_zone_visual(root, "ExitZone")
	_hide_zone_visual(root, "LeftExitZone")
	_disable_legacy_bodies(root, ["LeftWall", "RightWall", "Floor"])


func _apply_goal_room(root: Node, terrain_tileset: TileSet, surface_tileset: TileSet, thin_surface_tileset: TileSet) -> void:
	_prepare_production_room(root, terrain_tileset, surface_tileset, thin_surface_tileset, Vector2i(-6, 3), 20, [Vector2i(9, 2)])
	_configure_backdrop(root, Rect2(-384, -256, 1280, 512))
	_configure_background(root, Vector2(256, 0), Vector2(0.77, 0.77))
	_set_position(root, "BasicMeleeEnemy", Vector2(-32, 216))
	_set_position(root, "GoalBarrier", Vector2(320, 168))
	_set_position(root, "GoalZone", Vector2(800, 104))
	_set_position(root, "LeftExitZone", Vector2(-352, 160))
	_configure_gate_art(root, "GoalBarrier")
	_hide_zone_visual(root, "GoalZone")
	_hide_zone_visual(root, "LeftExitZone")
	_disable_legacy_bodies(root, ["LeftWall", "RightWall", "Floor", "GoalLedge"])


func _prepare_production_room(root: Node, terrain_tileset: TileSet, surface_tileset: TileSet, thin_surface_tileset: TileSet, floor_start: Vector2i, floor_length: int, platform_starts: Array) -> void:
	_hide_old_tile_layers(root)
	_hide_material_art(root)
	var terrain := _ensure_layer(root, "TerrainCollisionVisual", terrain_tileset, Vector2.ZERO, TERRAIN_SCALE, true, 1)
	var platform := _ensure_layer(root, "PlatformCollisionVisual", terrain_tileset, PLATFORM_OFFSET, TERRAIN_SCALE, true, 2)
	var surface := _ensure_layer(root, "GroundSurfaceVisual", surface_tileset, SURFACE_OFFSET, Vector2.ONE, false, 2)
	var thin_surface := _ensure_layer(root, "ThinPlatformSurfaceVisual", thin_surface_tileset, Vector2.ZERO, Vector2.ONE, false, 2)
	terrain.modulate = Color(1, 1, 1, 0.08)
	platform.modulate = Color(1, 1, 1, 0.08)
	_paint_solid_run(terrain, floor_start, floor_length)
	_paint_surface_run(surface, floor_start, floor_length)
	for start: Vector2i in platform_starts:
		_paint_platform_run(platform, start, 4)
		_paint_surface_run(thin_surface, start, 4)
	for layer_name: String in VISUAL_ONLY_TILE_LAYERS:
		_ensure_layer(root, layer_name, terrain_tileset, Vector2.ZERO, TERRAIN_SCALE, false, -1)


func _ensure_layer(root: Node, layer_name: String, tileset: TileSet, offset: Vector2, layer_scale: Vector2, collision_enabled: bool, z_index: int) -> TileMapLayer:
	var layer := root.get_node_or_null(NodePath(layer_name)) as TileMapLayer
	if layer == null:
		layer = TileMapLayer.new()
		layer.name = layer_name
		root.add_child(layer)
		layer.owner = root
	layer.visible = true
	layer.tile_set = tileset
	layer.position = offset
	layer.scale = layer_scale
	layer.z_index = z_index
	layer.set("collision_enabled", collision_enabled)
	layer.clear()
	layer.set_meta(&"terrain_template_layer", true)
	return layer


func _hide_old_tile_layers(root: Node) -> void:
	for layer_name: String in OLD_TILE_LAYERS:
		var layer := root.get_node_or_null(NodePath(layer_name)) as TileMapLayer
		if layer != null:
			layer.visible = false
			layer.set("collision_enabled", false)


func _hide_material_art(root: Node) -> void:
	for node_name: String in ["MaterialTextureArt"]:
		var item := root.get_node_or_null(NodePath(node_name)) as CanvasItem
		if item != null:
			item.visible = false


func _disable_legacy_bodies(root: Node, body_names: Array) -> void:
	for body_name: String in body_names:
		var body := root.get_node_or_null(NodePath(body_name)) as StaticBody2D
		if body == null:
			continue
		body.collision_layer = 0
		body.collision_mask = 0
		var shape := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape != null:
			shape.disabled = true
		for child: Node in body.get_children():
			if child is CanvasItem:
				(child as CanvasItem).visible = false


func _configure_backdrop(root: Node, rect: Rect2) -> void:
	var backdrop := root.get_node_or_null("Backdrop") as Polygon2D
	if backdrop != null:
		backdrop.z_index = -4
		_set_backdrop_rect(backdrop, rect)


func _configure_background(root: Node, position: Vector2, scale: Vector2) -> void:
	var background := root.get_node_or_null("DemoBackgroundArt") as Sprite2D
	if background != null:
		background.visible = true
		background.z_index = -3
		background.position = position
		background.scale = scale
		background.modulate = Color(1, 1, 1, 0.5)
		background.set_meta(&"asset_binding_note", "single_sprite_full_room_coverage_no_repeat_seam")
		var backdrop := root.get_node_or_null("Backdrop") as Polygon2D
		if backdrop != null and background.texture != null:
			var texture_size := background.texture.get_size() * scale
			_set_backdrop_rect(backdrop, Rect2(position - texture_size * 0.5, texture_size))


func _set_backdrop_rect(backdrop: Polygon2D, rect: Rect2) -> void:
	backdrop.polygon = PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])


# 精确机制沙盒不能把 shape 改成整格；顶沿和 cap 直接贴合原 shape bounds。
func _add_test_collision_edge(root: Node, body_path: String, edge_name: String, left: float, right: float, y: float, caps_up: bool) -> void:
	var body := root.get_node_or_null(NodePath(body_path)) as Node2D
	if body == null:
		return
	var old_edge := body.get_node_or_null(NodePath(edge_name))
	if old_edge != null:
		old_edge.free()
	var edge := Polygon2D.new()
	edge.name = edge_name
	var edge_top := y - 4.0
	var edge_bottom := y + 4.0
	edge.polygon = PackedVector2Array([Vector2(left, edge_top), Vector2(right, edge_top), Vector2(right, edge_bottom), Vector2(left, edge_bottom)])
	edge.color = TEST_SURFACE_COLOR
	edge.z_index = 2
	edge.set_meta(&"asset_binding_note", "shape_bound_surface_edge")
	body.add_child(edge)
	edge.owner = root
	var cap_direction := 1.0 if caps_up else -1.0
	for cap_x: float in [left, right]:
		var cap := Polygon2D.new()
		cap.name = "LeftCap" if cap_x == left else "RightCap"
		cap.polygon = PackedVector2Array([
			Vector2(cap_x - 4.0, y),
			Vector2(cap_x + 4.0, y),
			Vector2(cap_x + 4.0, y + 12.0 * cap_direction),
			Vector2(cap_x - 4.0, y + 12.0 * cap_direction),
		])
		cap.color = TEST_SURFACE_COLOR.darkened(0.12)
		cap.z_index = 2
		edge.add_child(cap)
		cap.owner = root


func _configure_test_wall(root: Node, visual_path: String) -> void:
	var visual := root.get_node_or_null(NodePath(visual_path)) as Polygon2D
	if visual == null:
		return
	var source := root.get_node_or_null("Floor/FloorVisual") as Polygon2D
	visual.texture = source.texture if source != null else null
	visual.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	visual.color = TEST_MASS_COLOR
	visual.set_meta(&"asset_binding_note", "shape_exact_wall_mass_for_test_sandbox")


func _set_position(root: Node, node_path: String, position: Vector2) -> void:
	var node := root.get_node_or_null(NodePath(node_path)) as Node2D
	if node != null:
		node.position = position


func _configure_gate_art(root: Node, gate_path: String) -> void:
	var gate := root.get_node_or_null(NodePath(gate_path)) as Node2D
	var art := gate.get_node_or_null("BarrierArt") as Sprite2D if gate != null else null
	if art == null and gate != null:
		art = gate.get_node_or_null("GateArt") as Sprite2D
	if art != null:
		art.scale = Vector2(0.72, 0.72)
	var visual := gate.get_node_or_null("BarrierVisual") as CanvasItem if gate != null else null
	if visual != null:
		visual.visible = false


func _hide_zone_visual(root: Node, zone_path: String) -> void:
	var zone := root.get_node_or_null(NodePath(zone_path))
	var visual := zone.get_node_or_null("ZoneVisual") as CanvasItem if zone != null else null
	if visual != null:
		visual.visible = false


func _paint_solid_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var atlas := FLAT_CENTER_A if posmod(offset, 2) == 0 else FLAT_CENTER_B
		if offset == 0:
			atlas = GROUND_LEFT_CAP
		elif offset == length - 1:
			atlas = GROUND_RIGHT_CAP
		layer.set_cell(Vector2i(start.x + offset, start.y), FLAT_SOURCE, atlas, 0)


func _paint_platform_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var atlas := PLATFORM_CENTER
		if offset == 0:
			atlas = PLATFORM_LEFT_CAP
		elif offset == length - 1:
			atlas = PLATFORM_RIGHT_CAP
		layer.set_cell(Vector2i(start.x + offset, start.y), FLAT_SOURCE, atlas, 0)


func _paint_surface_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var atlas := SURFACE_CENTER
		if offset == 0:
			atlas = SURFACE_LEFT
		elif offset == length - 1:
			atlas = SURFACE_RIGHT
		layer.set_cell(Vector2i(start.x + offset, start.y), 0, atlas, 0)
