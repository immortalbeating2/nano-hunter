extends SceneTree

# 正式地图 Batch 6：Stage13 支路、回环与区域终点五房。

const TERRAIN_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"
const GATE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres"
const SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)
const PLATFORM_OFFSET := Vector2(0, -16)
const SURFACE_OFFSET := Vector2(0, -7)
const OLD := ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]

const SPECS := [
	{
		"path": "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn", "limits": Rect2i(-384, -320, 1536, 576),
		"floor": Vector2i(-6, 3), "length": 24, "platforms": [{"start": Vector2i(0, 2), "length": 4}, {"start": Vector2i(5, 1), "length": 4}],
		"background": Vector2(384, -16), "background_scale": Vector2(0.94, 0.94),
		"previous": "res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn", "previous_spawn": &"stage13_pressure_return", "left_exit": Vector2(-352, 160),
		"spawns": {&"stage13_branch_hub_start": Vector2(-256, 204), &"stage13_resource_branch_return": Vector2(768, 204), &"stage13_challenge_branch_return": Vector2(832, 204), &"stage13_branch_hub_return": Vector2(896, 204)},
		"nodes": {"ResourceBranchZone": Vector2(128, 120), "ChallengeBranchZone": Vector2(448, 56), "ExitZone": Vector2(1120, 160)},
	},
	{
		"path": "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn", "limits": Rect2i(-384, -256, 1152, 512),
		"floor": Vector2i(-6, 3), "length": 18, "platforms": [{"start": Vector2i(2, 2), "length": 4}, {"start": Vector2i(7, 1), "length": 4}],
		"background": Vector2(192, 0), "background_scale": Vector2(0.78, 0.78),
		"previous": "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn", "previous_spawn": &"stage13_resource_branch_return", "left_exit": Vector2(-352, 160),
		"spawns": {&"stage13_resource_branch_start": Vector2(-256, 204)},
		"next": "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn", "next_spawn": &"stage13_checkpoint_from_resource_branch", "persistent_reward": &"marsh_relic",
		"nodes": {"Stage13Reward": Vector2(512, 56), "ExitZone": Vector2(736, 160)},
	},
	{
		"path": "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn", "limits": Rect2i(-384, -320, 1536, 576),
		"floor": Vector2i(-6, 3), "length": 24, "platforms": [{"start": Vector2i(0, 2), "length": 4}, {"start": Vector2i(5, 1), "length": 4}, {"start": Vector2i(12, 2), "length": 4}],
		"background": Vector2(384, -16), "background_scale": Vector2(0.94, 0.94),
		"previous": "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn", "previous_spawn": &"stage13_challenge_branch_return", "left_exit": Vector2(-352, 160),
		"spawns": {&"stage13_challenge_branch_start": Vector2(-256, 204)},
		"next": "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn", "next_spawn": &"stage13_goal_from_challenge_branch", "persistent_reward": &"warden_sigil",
		"nodes": {"MiasmaCasterEnemy": Vector2(512, 56), "Stage13Reward": Vector2(1040, 192), "ExitZone": Vector2(1120, 160)},
		"gate": Vector2(960, 168), "require_all": true,
	},
	{
		"path": "res://scenes/rooms/stage13_miasma_marsh_return_room.tscn", "limits": Rect2i(-384, -256, 1280, 512),
		"floor": Vector2i(-6, 3), "length": 20, "platforms": [{"start": Vector2i(2, 2), "length": 4}, {"start": Vector2i(8, 2), "length": 4}],
		"background": Vector2(256, 0), "background_scale": Vector2(0.82, 0.82),
		"previous": "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn", "previous_spawn": &"stage13_branch_hub_return", "left_exit": Vector2(-352, 160),
		"spawns": {&"stage13_return_start": Vector2(-256, 204), &"stage13_return_return": Vector2(640, 204)},
		"nodes": {"ExitZone": Vector2(800, 160)},
	},
	{
		"path": "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn", "limits": Rect2i(-384, -256, 1280, 512),
		"floor": Vector2i(-6, 3), "length": 20, "platforms": [{"start": Vector2i(8, 2), "length": 5}],
		"background": Vector2(256, 0), "background_scale": Vector2(0.82, 0.82),
		"previous": "res://scenes/rooms/stage13_miasma_marsh_return_room.tscn", "previous_spawn": &"stage13_return_return", "left_exit": Vector2(-352, 160),
		"spawns": {&"stage13_goal_start": Vector2(-256, 204), &"stage13_goal_return": Vector2(640, 204), &"stage13_goal_from_challenge_branch": Vector2(640, 204)},
		"nodes": {"GoalDevice": Vector2(640, 112), "GoalZone": Vector2(704, 96)},
	},
]


func _init() -> void:
	var terrain := load(TERRAIN_PATH) as TileSet
	var surface := load(SURFACE_PATH) as TileSet
	var thin := load(THIN_PATH) as TileSet
	var gate := load(GATE_PATH) as Texture2D
	if terrain == null or surface == null or thin == null or gate == null:
		quit(1)
		return
	for spec: Dictionary in SPECS:
		if not _apply(spec, terrain, surface, thin, gate):
			quit(1)
			return
	print("formal map Batch 6 applied: Stage13 branches and goal")
	quit(0)


func _apply(spec: Dictionary, terrain_set: TileSet, surface_set: TileSet, thin_set: TileSet, gate_texture: Texture2D) -> bool:
	var packed := load(str(spec.path)) as PackedScene
	if packed == null:
		return false
	var root := packed.instantiate() as Node2D
	root.set("camera_limits", spec.limits)
	root.set("previous_room_path", spec.previous)
	root.set("previous_spawn_id", spec.previous_spawn)
	root.set("spawn_positions", spec.spawns)
	if spec.has("next"):
		root.set("next_room_path", spec.next)
		root.set("next_spawn_id", spec.next_spawn)
	if spec.has("persistent_reward"):
		root.set("persistent_reward_id", spec.persistent_reward)
	if spec.has("require_all"):
		root.set("require_all_enemies_defeated", bool(spec.require_all))
	_hide_old(root)
	var terrain := _layer(root, "TerrainCollisionVisual", terrain_set, Vector2.ZERO, SCALE, true, 1)
	var platform := _layer(root, "PlatformCollisionVisual", terrain_set, PLATFORM_OFFSET, SCALE, true, 2)
	var surface := _layer(root, "GroundSurfaceVisual", surface_set, SURFACE_OFFSET, Vector2.ONE, false, 2)
	var thin_surface := _layer(root, "ThinPlatformSurfaceVisual", thin_set, Vector2.ZERO, Vector2.ONE, false, 2)
	terrain.modulate = Color(1, 1, 1, 0.08)
	platform.modulate = Color(1, 1, 1, 0.08)
	surface.modulate = Color(0.74, 0.84, 0.78, 0.92)
	thin_surface.modulate = Color(0.7, 0.82, 0.75, 0.92)
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
	if spec.has("gate"):
		_gate(root, spec.gate, gate_texture)
	for zone_name: String in ["ExitZone", "LeftExitZone", "ResourceBranchZone", "ChallengeBranchZone", "GoalZone"]:
		_hide_zone(root, zone_name)
	var output := PackedScene.new()
	var result := output.pack(root)
	root.free()
	return result == OK and ResourceSaver.save(output, str(spec.path)) == OK


func _layer(root: Node, name: String, set: TileSet, position: Vector2, scale: Vector2, collision: bool, z: int) -> TileMapLayer:
	var layer := root.get_node_or_null(NodePath(name)) as TileMapLayer
	if layer == null:
		layer = TileMapLayer.new()
		layer.name = name
		root.add_child(layer)
		layer.owner = root
	layer.visible = not collision
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
	for name: String in ["MaterialTextureArt", "MiasmaTileSheetArt"]:
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
	var art := root.get_node_or_null("MiasmaBackgroundArt") as Sprite2D
	var backdrop := root.get_node_or_null("Backdrop") as Polygon2D
	if art == null:
		return
	art.z_index = -3
	art.position = position
	art.scale = scale
	art.modulate = Color(1, 1, 1, 0.5)
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


func _gate(root: Node, position: Vector2, texture: Texture2D) -> void:
	var gate := root.get_node_or_null("GateBarrier") as StaticBody2D
	if gate == null:
		gate = StaticBody2D.new()
		gate.name = "GateBarrier"
		root.add_child(gate)
		gate.owner = root
	var shape_node := gate.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "CollisionShape2D"
		gate.add_child(shape_node)
		shape_node.owner = root
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 128)
	shape_node.shape = shape
	var art := gate.get_node_or_null("BarrierArt") as Sprite2D
	if art == null:
		art = Sprite2D.new()
		art.name = "BarrierArt"
		gate.add_child(art)
		art.owner = root
	art.scale = Vector2(0.72, 0.72)
	art.texture = texture
	art.set_meta("asset_id", "shrine_gate_prop_atlas_ai01")
	art.set_meta("runtime_source", "shrine_gate_prop_atlas_ai01.seal_gate_locked")
	gate.position = position


func _hide_zone(root: Node, name: String) -> void:
	var zone := root.get_node_or_null(NodePath(name))
	if zone == null:
		return
	for visual_name: String in ["ZoneVisual", "ResourceVisual", "ChallengeVisual", "GoalVisual"]:
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
