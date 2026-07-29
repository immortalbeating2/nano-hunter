extends SceneTree

# 正式地图 Batch 7：Stage14 Shrine、Backtrack Hub、Loop Return 三房。

const TERRAIN_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"
const SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)
const PLATFORM_OFFSET := Vector2(0, -16)
const SURFACE_OFFSET := Vector2(0, -7)
const OLD := ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]

const SPECS := [
	{
		"path": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn", "limits": Rect2i(-384, -256, 1280, 512),
		"floor": Vector2i(-6, 3), "length": 20, "platforms": [{"start": Vector2i(4, 2), "length": 4}],
		"background": Vector2(256, 0), "background_scale": Vector2(0.82, 0.82),
		"previous": "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn", "previous_spawn": &"stage13_goal_return", "left_exit": Vector2(-352, 160),
		"spawns": {&"stage14_air_dash_shrine_start": Vector2(-256, 204), &"stage14_shrine_return": Vector2(640, 204)},
		"nodes": {"AirDashShrine": Vector2(320, 120), "ExitZone": Vector2(800, 160)},
	},
	{
		"path": "res://scenes/rooms/stage14_backtrack_hub_room.tscn", "limits": Rect2i(-384, -320, 1664, 640),
		"floor": Vector2i(-6, 4), "length": 26, "platforms": [{"start": Vector2i(0, 3), "length": 4}, {"start": Vector2i(6, 2), "length": 4}, {"start": Vector2i(12, 1), "length": 4}],
		"background": Vector2(448, 0), "background_scale": Vector2(1.02, 1.02),
		"previous": "res://scenes/rooms/stage14_air_dash_gate_room.tscn", "previous_spawn": &"stage14_gate_return", "left_exit": Vector2(-352, 224),
		"spawns": {&"stage14_backtrack_hub_start": Vector2(-256, 268), &"stage14_hub_return": Vector2(1088, 268), &"stage14_hub_from_stage15_shortcut": Vector2(1088, 268)},
		"shortcut": "res://scenes/rooms/stage15_challenge_branch_room.tscn", "shortcut_spawn": &"stage15_challenge_from_stage14_shortcut", "shortcut_reward": &"warden_sigil",
		"nodes": {"BacktrackRewardOne": Vector2(128, 184), "BacktrackRewardTwo": Vector2(512, 120), "BacktrackRewardThree": Vector2(896, 56), "ExitZone": Vector2(1248, 224)},
	},
	{
		"path": "res://scenes/rooms/stage14_loop_return_room.tscn", "limits": Rect2i(-384, -256, 1280, 512),
		"floor": Vector2i(-6, 3), "length": 20, "platforms": [{"start": Vector2i(3, 2), "length": 4}, {"start": Vector2i(9, 1), "length": 4}],
		"background": Vector2(256, 0), "background_scale": Vector2(0.82, 0.82),
		"previous": "res://scenes/rooms/stage14_backtrack_hub_room.tscn", "previous_spawn": &"stage14_hub_return", "left_exit": Vector2(-352, 160),
		"spawns": {&"stage14_loop_return_start": Vector2(-256, 204), &"stage14_loop_return_return": Vector2(640, 204)},
		"nodes": {"GoalZone": Vector2(704, 56)},
	},
]


func _init() -> void:
	var terrain := load(TERRAIN_PATH) as TileSet
	var surface := load(SURFACE_PATH) as TileSet
	var thin := load(THIN_PATH) as TileSet
	if terrain == null or surface == null or thin == null:
		quit(1)
		return
	for spec: Dictionary in SPECS:
		if not _apply(spec, terrain, surface, thin):
			quit(1)
			return
	if not _patch_spawn("res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn", &"stage13_goal_return", Vector2(640, 204)):
		quit(1)
		return
	if not _patch_spawn("res://scenes/rooms/stage14_air_dash_gate_room.tscn", &"stage14_gate_return", Vector2(864, 60)):
		quit(1)
		return
	print("formal map Batch 7 applied: Stage14 remaining rooms")
	quit(0)


func _apply(spec: Dictionary, terrain_set: TileSet, surface_set: TileSet, thin_set: TileSet) -> bool:
	var packed := load(str(spec.path)) as PackedScene
	if packed == null:
		return false
	var root := packed.instantiate() as Node2D
	root.set("camera_limits", spec.limits)
	root.set("previous_room_path", spec.previous)
	root.set("previous_spawn_id", spec.previous_spawn)
	root.set("spawn_positions", spec.spawns)
	if spec.has("shortcut"):
		root.set("shortcut_room_path", spec.shortcut)
		root.set("shortcut_spawn_id", spec.shortcut_spawn)
		root.set("shortcut_required_reward_id", spec.shortcut_reward)
	_hide_old(root)
	var terrain := _layer(root, "TerrainCollisionVisual", terrain_set, Vector2.ZERO, SCALE, true, 1)
	var platform := _layer(root, "PlatformCollisionVisual", terrain_set, PLATFORM_OFFSET, SCALE, true, 2)
	var surface := _layer(root, "GroundSurfaceVisual", surface_set, SURFACE_OFFSET, Vector2.ONE, false, 2)
	var thin_surface := _layer(root, "ThinPlatformSurfaceVisual", thin_set, Vector2.ZERO, Vector2.ONE, false, 2)
	terrain.modulate = Color(1, 1, 1, 0.08)
	platform.modulate = Color(1, 1, 1, 0.08)
	surface.modulate = Color(0.8, 0.82, 0.86, 0.94)
	thin_surface.modulate = Color(0.76, 0.8, 0.84, 0.94)
	_paint(terrain, spec.floor, int(spec.length), false)
	_paint_surface(surface, spec.floor, int(spec.length))
	for platform_spec: Dictionary in spec.platforms:
		_paint(platform, platform_spec.start, int(platform_spec.length), true)
		_paint_surface(thin_surface, platform_spec.start, int(platform_spec.length))
	for name: String in ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]:
		_layer(root, name, terrain_set, Vector2.ZERO, SCALE, false, -1)
	_disable_legacy(root)
	_background(root, spec.background, spec.background_scale)
	for node_name: String in spec.nodes.keys():
		_position(root, node_name, spec.nodes[node_name])
	_left_exit(root, spec.left_exit)
	for zone_name: String in ["ExitZone", "LeftExitZone", "GoalZone"]:
		_hide_zone(root, zone_name)
	var output := PackedScene.new()
	var result := output.pack(root)
	root.free()
	return result == OK and ResourceSaver.save(output, str(spec.path)) == OK


func _patch_spawn(path: String, spawn_id: StringName, position: Vector2) -> bool:
	var packed := load(path) as PackedScene
	if packed == null:
		return false
	var root := packed.instantiate() as Node2D
	var spawns: Dictionary = root.get("spawn_positions").duplicate(true)
	spawns[spawn_id] = position
	root.set("spawn_positions", spawns)
	var output := PackedScene.new()
	var result := output.pack(root)
	root.free()
	return result == OK and ResourceSaver.save(output, path) == OK


func _layer(root: Node, name: String, set: TileSet, position: Vector2, scale: Vector2, collision: bool, z: int) -> TileMapLayer:
	var layer := root.get_node_or_null(NodePath(name)) as TileMapLayer
	if layer == null:
		layer = TileMapLayer.new()
		layer.name = name
		root.add_child(layer)
		layer.owner = root
	layer.visible = true
	layer.tile_set = set
	layer.position = position
	layer.scale = scale
	layer.z_index = z
	layer.set("collision_enabled", collision)
	layer.clear()
	return layer


func _hide_old(root: Node) -> void:
	for name: String in OLD:
		var layer := root.get_node_or_null(NodePath(name)) as TileMapLayer
		if layer != null:
			layer.visible = false
			layer.set("collision_enabled", false)
	for name: String in ["MaterialTextureArt", "ShrineTrialTileSheetArt", "AirDashShrineRoomArt", "MiasmaHazardRoomArt", "ShrineTrialParallaxArt"]:
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


func _background(root: Node, position: Vector2, scale: Vector2) -> void:
	var art := root.get_node_or_null("ShrineTrialBackgroundArt") as Sprite2D
	var backdrop := root.get_node_or_null("Backdrop") as Polygon2D
	if art == null:
		return
	art.z_index = -3
	art.position = position
	art.scale = scale
	art.modulate = Color(1, 1, 1, 0.56)
	if backdrop != null:
		backdrop.z_index = -4
		var size := art.texture.get_size() * scale
		var rect := Rect2(position - size * 0.5, size)
		backdrop.polygon = PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])


func _left_exit(root: Node, position: Vector2) -> void:
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


func _hide_zone(root: Node, name: String) -> void:
	var zone := root.get_node_or_null(NodePath(name))
	if zone == null:
		return
	for visual_name: String in ["ZoneVisual", "GoalVisual"]:
		var visual := zone.get_node_or_null(NodePath(visual_name)) as CanvasItem
		if visual != null:
			visual.visible = false


func _position(root: Node, path: String, position: Vector2) -> void:
	var node := root.get_node_or_null(NodePath(path)) as Node2D
	if node != null:
		node.position = position


func _paint(layer: TileMapLayer, start: Vector2i, length: int, platform: bool) -> void:
	for offset: int in range(length):
		var atlas := Vector2i(0, 2) if platform else (Vector2i(0, 0) if posmod(offset, 2) == 0 else Vector2i(1, 0))
		if offset == 0:
			atlas = Vector2i(1, 2) if platform else Vector2i(2, 0)
		elif offset == length - 1:
			atlas = Vector2i(2, 2) if platform else Vector2i(3, 0)
		layer.set_cell(start + Vector2i(offset, 0), 0, atlas, 0)


func _paint_surface(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var atlas := Vector2i(1, 0)
		if offset == 0:
			atlas = Vector2i(0, 0)
		elif offset == length - 1:
			atlas = Vector2i(2, 0)
		layer.set_cell(start + Vector2i(offset, 0), 0, atlas, 0)
