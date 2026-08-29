extends SceneTree

# 正式地图 Batch 8：Stage15 Pressure、Challenge、Boss、Completion 四房。

const FORMAL_DEMO_RECOVERY_LOCKED := true
const FORMAL_DEMO_RECOVERY_PROGRAM_ID := "formal_demo_recovery_b"

const TERRAIN_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_jump_platform_visual_ai02.tileset.tres"
const GATE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres"
const SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)
const PLATFORM_OFFSET := Vector2(0, -16)
const SURFACE_OFFSET := Vector2(0, -7)
const OLD := ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]

const SPECS := [
	{
		"path": "res://scenes/rooms/stage15_seal_pressure_room.tscn", "limits": Rect2i(-384, -320, 1536, 576),
		"floor": Vector2i(-6, 3), "length": 24, "platforms": [{"start": Vector2i(1, 2), "length": 4}, {"start": Vector2i(8, 1), "length": 4}, {"start": Vector2i(14, 2), "length": 4}],
		"background": Vector2(384, -16), "background_scale": Vector2(0.94, 0.94), "background_name": "SealPressureBackgroundArt",
		"previous": "res://scenes/rooms/stage14_loop_return_room.tscn", "previous_spawn": &"stage14_loop_return_return", "left_exit": Vector2(-352, 160),
		"spawns": {&"stage15_seal_pressure_start": Vector2(-256, 204), &"stage15_pressure_return": Vector2(960, 204)},
		"nodes": {"PressureSigil": Vector2(128, 106), "PressureFocusArt": Vector2(128, 120), "PressureSigilArt": Vector2(128, 106), "GroundChargerEnemy": Vector2(448, 200), "MiasmaCasterEnemy": Vector2(832, 56), "ExitZone": Vector2(1120, 160)},
		"gate": Vector2(1024, 168), "require_all": true,
	},
	{
		"path": "res://scenes/rooms/stage15_challenge_branch_room.tscn", "limits": Rect2i(-384, -320, 1664, 640),
		"floor": Vector2i(-6, 4), "length": 26, "platforms": [{"start": Vector2i(0, 3), "length": 4}, {"start": Vector2i(6, 2), "length": 4}, {"start": Vector2i(12, 1), "length": 4}],
		"background": Vector2(448, 0), "background_scale": Vector2(1.02, 1.02), "background_name": "ChallengeBackgroundArt",
		"previous": "res://scenes/rooms/stage14_backtrack_hub_room.tscn", "previous_spawn": &"stage14_hub_from_stage15_shortcut", "left_exit": Vector2(-352, 224),
		"spawns": {&"stage15_challenge_start": Vector2(-256, 268), &"stage15_challenge_from_stage14_shortcut": Vector2(-256, 268)},
		"nodes": {"MiasmaHazard": Vector2(448, 276), "MiasmaCasterEnemy": Vector2(128, 184), "AerialSentinelEnemy": Vector2(768, 120), "Stage13Reward": Vector2(1088, 256), "Stage13RewardArt": Vector2(1088, 256), "GateBarrier": Vector2(1152, 232), "ExitZone": Vector2(1248, 224)},
	},
	{
		"path": "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn", "limits": Rect2i(-384, -320, 1792, 640),
		"floor": Vector2i(-6, 4), "length": 28, "platforms": [{"start": Vector2i(1, 3), "length": 4}, {"start": Vector2i(15, 3), "length": 4}],
		"background": Vector2(512, 0), "background_scale": Vector2(1.1, 1.1), "background_name": "SealGuardianBossRoomBackgroundArt",
		"previous": "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn", "previous_spawn": &"stage15_boss_return", "left_exit": Vector2(-352, 224),
		"spawns": {&"stage15_boss_start": Vector2(-256, 268), &"stage15_boss_return": Vector2(1216, 268)},
		"nodes": {"SealGuardianBoss": Vector2(512, 248), "GateBarrier": Vector2(1280, 232), "ExitZone": Vector2(1376, 224)},
		"boss": true,
	},
	{
		"path": "res://scenes/rooms/stage15_completion_room.tscn", "limits": Rect2i(-384, -256, 1152, 512),
		"floor": Vector2i(-6, 3), "length": 18, "platforms": [{"start": Vector2i(4, 2), "length": 5}],
		"background": Vector2(192, 0), "background_scale": Vector2(0.78, 0.78), "background_name": "CompletionBackgroundArt",
		"previous": "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn", "previous_spawn": &"stage15_boss_return", "left_exit": Vector2(-352, 160),
		"spawns": {&"stage15_completion_start": Vector2(-256, 204), &"stage15_completion_return": Vector2(576, 204)},
		"nodes": {"CompletionSeal": Vector2(320, 112), "ExitZone": Vector2(736, 160)},
	},
]


func _init() -> void:
	if FORMAL_DEMO_RECOVERY_LOCKED:
		push_error("该历史生成器已由 formal_demo_recovery_b 冻结，禁止覆盖 F01–F18。")
		quit(2)
		return
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
	if not _patch_spawn("res://scenes/rooms/stage15_mixed_gauntlet_room.tscn", &"stage15_boss_return", Vector2(960, 204)):
		quit(1)
		return
	print("formal map Batch 8 applied: Stage15 remaining rooms")
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
	if spec.has("require_all"):
		root.set("require_all_enemies_defeated", bool(spec.require_all))
	_hide_old(root)
	var terrain := _layer(root, "TerrainCollisionVisual", terrain_set, Vector2.ZERO, SCALE, true, 1)
	var platform := _layer(root, "PlatformCollisionVisual", terrain_set, PLATFORM_OFFSET, SCALE, true, 2)
	var surface := _layer(root, "GroundSurfaceVisual", surface_set, SURFACE_OFFSET, Vector2.ONE, false, 2)
	var thin_surface := _layer(root, "ThinPlatformSurfaceVisual", thin_set, Vector2.ZERO, Vector2.ONE, false, 2)
	terrain.modulate = Color(1, 1, 1, 0.08)
	platform.modulate = Color(1, 1, 1, 0.08)
	surface.modulate = Color(0.82, 0.78, 0.78, 0.94)
	thin_surface.modulate = Color(0.84, 0.76, 0.76, 0.94)
	_paint(terrain, spec.floor, int(spec.length), false)
	_paint_surface(surface, spec.floor, int(spec.length))
	for platform_spec: Dictionary in spec.platforms:
		_paint(platform, platform_spec.start, int(platform_spec.length), true)
		_paint_surface(thin_surface, platform_spec.start, int(platform_spec.length))
	for name: String in ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]:
		_layer(root, name, terrain_set, Vector2.ZERO, SCALE, false, -1)
	_disable_legacy(root, bool(spec.get("boss", false)))
	_background(root, str(spec.background_name), spec.background, spec.background_scale)
	for node_name: String in spec.nodes.keys():
		_position(root, node_name, spec.nodes[node_name])
	_left_exit(root, spec.left_exit)
	if spec.has("gate"):
		_gate(root, spec.gate, gate_texture)
	elif root.has_node("GateBarrier"):
		_gate(root, (root.get_node("GateBarrier") as Node2D).position, gate_texture)
	for zone_name: String in ["ExitZone", "LeftExitZone"]:
		_hide_zone(root, zone_name)
	if root.has_node("MiasmaHazard/MiasmaWarningVfxArt"):
		var warning := root.get_node("MiasmaHazard/MiasmaWarningVfxArt") as AnimatedSprite2D
		warning.modulate = Color(1, 1, 1, 0.72)
		warning.scale = Vector2(0.78, 0.38)
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
	for name: String in ["MaterialTextureArt"]:
		var item := root.get_node_or_null(NodePath(name)) as CanvasItem
		if item != null:
			item.visible = false


func _disable_legacy(root: Node, boss: bool) -> void:
	var names: Array[String] = ["LeftWall", "RightWall", "Floor"]
	if boss:
		names.append("SealDais")
	for name: String in names:
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


func _background(root: Node, name: String, position: Vector2, scale: Vector2) -> void:
	var art := root.get_node_or_null(NodePath(name)) as Sprite2D
	var backdrop := root.get_node_or_null("Backdrop") as Polygon2D
	if art == null:
		return
	art.z_index = -3
	art.position = position
	art.scale = scale
	art.modulate = Color(1, 1, 1, 0.58)
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
	var art := gate.get_node_or_null("GateArt") as Sprite2D
	if art == null:
		art = gate.get_node_or_null("BarrierArt") as Sprite2D
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
	var visual := zone.get_node_or_null("ZoneVisual") as CanvasItem if zone != null else null
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
