extends SceneTree

# 正式地图 Batch 2：按五种房间职责重排 Stage9 小区域。
# 生成器只翻译已冻结网格，不从碰撞 bounds 随机猜 tile。

const TERRAIN_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"
const CHECKPOINT_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/015_shrine_gate_prop_atlas_ai01_auto_016_c02.atlas_texture.tres"
const TERRAIN_SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)
const PLATFORM_OFFSET := Vector2(0, -16)
const SURFACE_OFFSET := Vector2(0, -7)
const OLD_LAYERS := ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]
const VISUAL_ONLY_LAYERS := ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]
const FLAT_A := Vector2i(0, 0)
const FLAT_B := Vector2i(1, 0)
const LEFT_CAP := Vector2i(2, 0)
const RIGHT_CAP := Vector2i(3, 0)
const PLATFORM_CENTER := Vector2i(0, 2)
const PLATFORM_LEFT := Vector2i(1, 2)
const PLATFORM_RIGHT := Vector2i(2, 2)
const SURFACE_LEFT := Vector2i(0, 0)
const SURFACE_CENTER := Vector2i(1, 0)
const SURFACE_RIGHT := Vector2i(2, 0)

const SPECS := [
	{
		"path": "res://scenes/rooms/stage9_zone_entry_room.tscn",
		"limits": Rect2i(-384, -192, 1152, 384), "floor": Vector2i(-6, 2), "length": 18,
		"platforms": [{"start": Vector2i(3, 1), "length": 3}], "background": Vector2(192, 0), "background_scale": Vector2(0.72, 0.72),
		"previous": "res://scenes/rooms/goal_trial_room.tscn", "previous_spawn": &"goal_return",
		"spawns": {&"zone_entry_start": Vector2(-256, 140), &"zone_entry_return": Vector2(640, 140)},
		"left_exit": Vector2(-352, 96), "exit": Vector2(720, 96),
	},
	{
		"path": "res://scenes/rooms/stage9_zone_combat_room.tscn",
		"limits": Rect2i(-384, -256, 1280, 512), "floor": Vector2i(-6, 3), "length": 20,
		"platforms": [{"start": Vector2i(-1, 2), "length": 4}, {"start": Vector2i(6, 2), "length": 3}], "background": Vector2(256, 0), "background_scale": Vector2(0.78, 0.78),
		"previous": "res://scenes/rooms/stage9_zone_entry_room.tscn", "previous_spawn": &"zone_entry_return",
		"spawns": {&"zone_combat_start": Vector2(-256, 204), &"zone_combat_return": Vector2(640, 204)},
		"left_exit": Vector2(-352, 160), "exit": Vector2(800, 160), "gate": Vector2(704, 168),
		"nodes": {"BasicMeleeEnemy": Vector2(32, 200)},
	},
	{
		"path": "res://scenes/rooms/stage9_zone_charger_room.tscn",
		"limits": Rect2i(-384, -256, 1408, 512), "floor": Vector2i(-6, 3), "length": 22,
		"platforms": [{"start": Vector2i(2, 2), "length": 4}, {"start": Vector2i(10, 2), "length": 3}], "background": Vector2(320, 0), "background_scale": Vector2(0.86, 0.86),
		"previous": "res://scenes/rooms/stage9_zone_combat_room.tscn", "previous_spawn": &"zone_combat_return",
		"spawns": {&"zone_charger_start": Vector2(-256, 204), &"zone_charger_return": Vector2(768, 204)},
		"left_exit": Vector2(-352, 160), "exit": Vector2(928, 160), "gate": Vector2(832, 168),
		"nodes": {"GroundChargerEnemy": Vector2(192, 200)},
	},
	{
		"path": "res://scenes/rooms/stage9_zone_switch_room.tscn",
		"limits": Rect2i(-384, -320, 1280, 576), "floor": Vector2i(-6, 3), "length": 20,
		"platforms": [{"start": Vector2i(0, 2), "length": 3}, {"start": Vector2i(4, 1), "length": 4}], "background": Vector2(256, -16), "background_scale": Vector2(0.78, 0.78),
		"previous": "res://scenes/rooms/stage9_zone_charger_room.tscn", "previous_spawn": &"zone_charger_return",
		"spawns": {&"zone_switch_start": Vector2(-256, 204), &"zone_switch_return": Vector2(640, 204)},
		"left_exit": Vector2(-352, 160), "exit": Vector2(800, 160), "gate": Vector2(704, 168),
		"nodes": {"GateSwitch": Vector2(352, 56)},
	},
	{
		"path": "res://scenes/rooms/stage9_zone_final_room.tscn",
		"limits": Rect2i(-384, -320, 1536, 576), "floor": Vector2i(-6, 3), "length": 24,
		"platforms": [{"start": Vector2i(0, 2), "length": 5}, {"start": Vector2i(8, 2), "length": 4}], "background": Vector2(384, -16), "background_scale": Vector2(0.94, 0.94),
		"previous": "res://scenes/rooms/stage9_zone_switch_room.tscn", "previous_spawn": &"zone_switch_return",
		"spawns": {&"zone_final_start": Vector2(-256, 204), &"zone_final_return": Vector2(960, 204)},
		"left_exit": Vector2(-352, 160), "exit": Vector2(1120, 160), "gate": Vector2(1024, 168),
		"nodes": {"BasicMeleeEnemy": Vector2(128, 120), "GroundChargerEnemy": Vector2(512, 200)},
	},
]


func _init() -> void:
	var terrain := load(TERRAIN_TILESET_PATH) as TileSet
	var surface := load(SURFACE_TILESET_PATH) as TileSet
	var thin := load(THIN_TILESET_PATH) as TileSet
	var checkpoint := load(CHECKPOINT_TEXTURE_PATH) as Texture2D
	if terrain == null or surface == null or thin == null or checkpoint == null:
		push_error("Stage9 Batch 2 resources are incomplete.")
		quit(1)
		return
	for spec: Dictionary in SPECS:
		if not _apply_room(spec, terrain, surface, thin, checkpoint):
			quit(1)
			return
	print("formal map Batch 2 applied: Stage9 five-room zone")
	quit(0)


func _apply_room(spec: Dictionary, terrain_set: TileSet, surface_set: TileSet, thin_set: TileSet, checkpoint_texture: Texture2D) -> bool:
	var packed := load(str(spec.path)) as PackedScene
	if packed == null:
		return false
	var root := packed.instantiate() as Node2D
	root.set("camera_limits", spec.limits)
	root.set("previous_room_path", spec.previous)
	root.set("previous_spawn_id", spec.previous_spawn)
	root.set("spawn_positions", spec.spawns)
	_hide_old_content(root)
	var terrain := _layer(root, "TerrainCollisionVisual", terrain_set, Vector2.ZERO, TERRAIN_SCALE, true, 1)
	var platform := _layer(root, "PlatformCollisionVisual", terrain_set, PLATFORM_OFFSET, TERRAIN_SCALE, true, 2)
	var surface := _layer(root, "GroundSurfaceVisual", surface_set, SURFACE_OFFSET, Vector2.ONE, false, 2)
	var thin_surface := _layer(root, "ThinPlatformSurfaceVisual", thin_set, Vector2.ZERO, Vector2.ONE, false, 2)
	terrain.modulate = Color(1, 1, 1, 0.08)
	platform.modulate = Color(1, 1, 1, 0.08)
	surface.modulate = Color(0.76, 0.84, 0.79, 0.92)
	thin_surface.modulate = Color(0.72, 0.82, 0.76, 0.92)
	_paint_solid(terrain, spec.floor, int(spec.length))
	_paint_surface(surface, spec.floor, int(spec.length))
	for platform_spec: Dictionary in spec.platforms:
		_paint_platform(platform, platform_spec.start, int(platform_spec.length))
		_paint_surface(thin_surface, platform_spec.start, int(platform_spec.length))
	for layer_name: String in VISUAL_ONLY_LAYERS:
		_layer(root, layer_name, terrain_set, Vector2.ZERO, TERRAIN_SCALE, false, -1)
	_disable_legacy(root)
	_configure_background(root, spec.background, spec.background_scale)
	_ensure_left_exit(root, spec.left_exit)
	_set_position(root, "ExitZone", spec.exit)
	_hide_zone(root, "ExitZone")
	_hide_zone(root, "LeftExitZone")
	if spec.has("gate"):
		_set_position(root, "GateBarrier", spec.gate)
		_configure_gate(root)
	for node_name: String in spec.get("nodes", {}).keys():
		_set_position(root, node_name, spec.nodes[node_name])
	if str(spec.path).ends_with("stage9_zone_entry_room.tscn"):
		_ensure_checkpoint(root, "RegionCheckpoint", Vector2(-160, 128), true, checkpoint_texture)
	if str(spec.path).ends_with("stage9_zone_charger_room.tscn"):
		_ensure_checkpoint(root, "CheckpointPoint", Vector2(704, 192), false, checkpoint_texture)
	var output := PackedScene.new()
	var result := output.pack(root)
	root.free()
	return result == OK and ResourceSaver.save(output, str(spec.path)) == OK


func _layer(root: Node, name: String, tileset: TileSet, position: Vector2, scale: Vector2, collision: bool, z: int) -> TileMapLayer:
	var layer := root.get_node_or_null(NodePath(name)) as TileMapLayer
	if layer == null:
		layer = TileMapLayer.new()
		layer.name = name
		root.add_child(layer)
		layer.owner = root
	layer.visible = true
	layer.tile_set = tileset
	layer.position = position
	layer.scale = scale
	layer.z_index = z
	layer.set("collision_enabled", collision)
	layer.clear()
	layer.set_meta(&"terrain_template_layer", true)
	return layer


func _hide_old_content(root: Node) -> void:
	for name: String in OLD_LAYERS:
		var layer := root.get_node_or_null(NodePath(name)) as TileMapLayer
		if layer != null:
			layer.visible = false
			layer.set("collision_enabled", false)
	for name: String in ["MaterialTextureArt", "MaterialTexturePreviewArt"]:
		var item := root.get_node_or_null(NodePath(name)) as CanvasItem
		if item != null:
			item.visible = false


func _disable_legacy(root: Node) -> void:
	for name: String in ["LeftWall", "RightWall", "Floor"]:
		var body := root.get_node_or_null(NodePath(name)) as StaticBody2D
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


func _configure_background(root: Node, position: Vector2, scale: Vector2) -> void:
	var background := root.get_node_or_null("DemoBackgroundArt") as Sprite2D
	var backdrop := root.get_node_or_null("Backdrop") as Polygon2D
	if background == null:
		return
	background.visible = true
	background.z_index = -3
	background.position = position
	background.scale = scale
	background.modulate = Color(1, 1, 1, 0.5)
	background.set_meta(&"asset_binding_note", "single_miasma_background_room_crop_no_repeat")
	if backdrop != null and background.texture != null:
		backdrop.z_index = -4
		var size := background.texture.get_size() * scale
		var rect := Rect2(position - size * 0.5, size)
		backdrop.polygon = PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])


func _ensure_left_exit(root: Node, position: Vector2) -> void:
	var zone := root.get_node_or_null("LeftExitZone") as Area2D
	if zone == null:
		zone = Area2D.new()
		zone.name = "LeftExitZone"
		root.add_child(zone)
		zone.owner = root
	var shape_node := zone.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "CollisionShape2D"
		zone.add_child(shape_node)
		shape_node.owner = root
	var shape := RectangleShape2D.new()
	shape.size = Vector2(96, 128)
	shape_node.shape = shape
	zone.position = position


func _ensure_checkpoint(root: Node, marker_name: String, position: Vector2, visible: bool, texture: Texture2D) -> void:
	var marker := root.get_node_or_null(NodePath(marker_name)) as Marker2D
	if marker == null:
		marker = Marker2D.new()
		marker.name = marker_name
		root.add_child(marker)
		marker.owner = root
	marker.position = position
	var art := marker.get_node_or_null("CheckpointArt") as Sprite2D
	if art == null:
		art = Sprite2D.new()
		art.name = "CheckpointArt"
		marker.add_child(art)
		art.owner = root
	art.visible = visible
	art.z_index = 4
	art.scale = Vector2(0.28, 0.28)
	art.texture = texture
	art.set_meta("asset_id", "shrine_gate_prop_atlas_ai01")
	art.set_meta("runtime_source", "shrine_gate_prop_atlas_ai01.checkpoint_active")


func _configure_gate(root: Node) -> void:
	var gate := root.get_node_or_null("GateBarrier") as Node2D
	if gate == null:
		return
	var visual := gate.get_node_or_null("BarrierVisual") as CanvasItem
	if visual != null:
		visual.visible = false
	var art := gate.get_node_or_null("BarrierArt") as Sprite2D
	if art != null:
		art.scale = Vector2(0.72, 0.72)


func _hide_zone(root: Node, path: String) -> void:
	var zone := root.get_node_or_null(NodePath(path))
	var visual := zone.get_node_or_null("ZoneVisual") as CanvasItem if zone != null else null
	if visual != null:
		visual.visible = false


func _set_position(root: Node, path: String, position: Vector2) -> void:
	var node := root.get_node_or_null(NodePath(path)) as Node2D
	if node != null:
		node.position = position


func _paint_solid(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var atlas := FLAT_A if posmod(offset, 2) == 0 else FLAT_B
		if offset == 0:
			atlas = LEFT_CAP
		elif offset == length - 1:
			atlas = RIGHT_CAP
		layer.set_cell(start + Vector2i(offset, 0), 0, atlas, 0)


func _paint_platform(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var atlas := PLATFORM_CENTER
		if offset == 0:
			atlas = PLATFORM_LEFT
		elif offset == length - 1:
			atlas = PLATFORM_RIGHT
		layer.set_cell(start + Vector2i(offset, 0), 0, atlas, 0)


func _paint_surface(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var atlas := SURFACE_CENTER
		if offset == 0:
			atlas = SURFACE_LEFT
		elif offset == length - 1:
			atlas = SURFACE_RIGHT
		layer.set_cell(start + Vector2i(offset, 0), 0, atlas, 0)
