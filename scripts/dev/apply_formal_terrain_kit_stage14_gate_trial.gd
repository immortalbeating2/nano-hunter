extends SceneTree

# Stage14 Air Dash gate 正式 24x9 蓝图生成。
# ponytail: 单房间显式蓝图；三类样板稳定前不抽通用关卡生成器。

const ROOM_PATH := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const ROOM_SCRIPT_PATH := "res://scripts/rooms/stage14_air_dash_gate_room.gd"
const TERRAIN_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"
const CLIFF_MASS_TEXTURE_PATH := "res://assets/art/textures/dac_continuous_stone_underlay.png"

const TERRAIN_SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)
const PLATFORM_OFFSET := Vector2(0.0, -16.0)
const SURFACE_OFFSET := Vector2(0.0, -7.0)
const TERRAIN_LAYER_NAME := "TerrainCollisionVisual"
const PLATFORM_LAYER_NAME := "PlatformCollisionVisual"
const SURFACE_LAYER_NAME := "GroundSurfaceVisual"
const THIN_SURFACE_LAYER_NAME := "ThinPlatformSurfaceVisual"
const CLIFF_ROOT_NAME := "CliffMassVisual"
const VISUAL_ONLY_TILE_LAYERS := ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]
const OLD_LAYER_NAMES := [
	"MiasmaTilesetPreview",
	"ShrineTrialTilesetPreview",
	"FormalTerrainTilemapDecor",
	"FormalForegroundEdgeDecor",
	"FormalTerrainKitSemanticTrial",
]
const LEGACY_TERRAIN_BODY_NAMES := ["LeftWall", "Floor"]

const LOWER_FLOOR_START := Vector2i(-8, 3)
const LOWER_FLOOR_LENGTH := 14
const RIGHT_CLIFF_START := Vector2i(6, 1)
const RIGHT_CLIFF_WIDTH := 10
const RIGHT_CLIFF_HEIGHT := 4
const STEP_PLATFORM_START := Vector2i(-6, 2)
const STEP_PLATFORM_LENGTH := 3
const LAUNCH_PLATFORM_START := Vector2i(-1, 1)
const LAUNCH_PLATFORM_LENGTH := 4
const RIGHT_LEDGE_START := Vector2i(6, 1)
const RIGHT_LEDGE_LENGTH := 10

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


func _init() -> void:
	var result := _run()
	quit(result)


func _run() -> int:
	var terrain_tileset := load(TERRAIN_TILESET_PATH) as TileSet
	var surface_tileset := load(SURFACE_TILESET_PATH) as TileSet
	var thin_surface_tileset := load(THIN_SURFACE_TILESET_PATH) as TileSet
	var room_script := load(ROOM_SCRIPT_PATH) as Script
	var packed := load(ROOM_PATH) as PackedScene
	if terrain_tileset == null or surface_tileset == null or thin_surface_tileset == null or room_script == null or packed == null:
		push_error("Stage14 gate formal blueprint resources are incomplete.")
		return 1

	var root := packed.instantiate()
	root.set_script(room_script)
	_apply_template(root, terrain_tileset, surface_tileset, thin_surface_tileset)
	var repacked := PackedScene.new()
	var pack_result := repacked.pack(root)
	root.free()
	if pack_result != OK:
		push_error("Failed to pack %s: %s" % [ROOM_PATH, pack_result])
		return 1
	var save_result := ResourceSaver.save(repacked, ROOM_PATH)
	if save_result != OK:
		push_error("Failed to save %s: %s" % [ROOM_PATH, save_result])
		return 1
	print("stage14 gate formal room blueprint applied: %s" % ROOM_PATH)
	return 0


# 房间只保留四类地形结构：下层回落、起跳台、Air Dash 缺口和右侧崖台。
func _apply_template(root: Node, terrain_tileset: TileSet, surface_tileset: TileSet, thin_surface_tileset: TileSet) -> void:
	_hide_old_tile_layers(root)
	_disable_legacy_terrain_collision(root)
	_configure_room_nodes(root)
	_configure_background(root)

	var terrain := _ensure_layer(root, TERRAIN_LAYER_NAME, terrain_tileset, Vector2.ZERO, TERRAIN_SCALE, true, 1, "tilemap_collision_authority_static_terrain")
	var platform := _ensure_layer(root, PLATFORM_LAYER_NAME, terrain_tileset, PLATFORM_OFFSET, TERRAIN_SCALE, true, 2, "tilemap_one_way_collision_authority_platform")
	var surface := _ensure_layer(root, SURFACE_LAYER_NAME, surface_tileset, SURFACE_OFFSET, Vector2.ONE, false, 2, "continuous_surface_visual_aligned_to_collision")
	var thin_surface := _ensure_layer(root, THIN_SURFACE_LAYER_NAME, thin_surface_tileset, Vector2.ZERO, Vector2.ONE, false, 2, "thin_platform_surface_visual_aligned_to_one_way_collision")
	terrain.modulate = Color(1.0, 1.0, 1.0, 0.08)
	platform.modulate = Color(1.0, 1.0, 1.0, 0.08)

	_paint_solid_run(terrain, LOWER_FLOOR_START, LOWER_FLOOR_LENGTH)
	_paint_solid_rect(terrain, RIGHT_CLIFF_START, RIGHT_CLIFF_WIDTH, RIGHT_CLIFF_HEIGHT)
	_paint_platform_run(platform, STEP_PLATFORM_START, STEP_PLATFORM_LENGTH)
	_paint_platform_run(platform, LAUNCH_PLATFORM_START, LAUNCH_PLATFORM_LENGTH)
	_paint_surface_run(surface, LOWER_FLOOR_START, LOWER_FLOOR_LENGTH)
	_paint_surface_run(surface, RIGHT_LEDGE_START, RIGHT_LEDGE_LENGTH)
	_paint_thin_surface_run(thin_surface, STEP_PLATFORM_START, STEP_PLATFORM_LENGTH)
	_paint_thin_surface_run(thin_surface, LAUNCH_PLATFORM_START, LAUNCH_PLATFORM_LENGTH)

	for layer_name: String in VISUAL_ONLY_TILE_LAYERS:
		var layer := _ensure_layer(root, layer_name, terrain_tileset, Vector2.ZERO, TERRAIN_SCALE, false, -1, "formal_room_visual_layer_kept_empty")
		layer.clear()
	_ensure_cliff_mass(root)


func _hide_old_tile_layers(root: Node) -> void:
	for layer_name: String in OLD_LAYER_NAMES:
		var layer := root.get_node_or_null(NodePath(layer_name)) as TileMapLayer
		if layer != null:
			layer.visible = false
			layer.set("collision_enabled", false)
			layer.set_meta(&"asset_binding_note", "hidden_after_stage14_gate_formal_blueprint")


func _disable_legacy_terrain_collision(root: Node) -> void:
	for body_name: String in LEGACY_TERRAIN_BODY_NAMES:
		var body := root.get_node_or_null(NodePath(body_name)) as StaticBody2D
		if body == null:
			continue
		body.collision_layer = 0
		body.collision_mask = 0
		body.set_meta(&"terrain_collision_authority", "replaced_by_tilemap_layer")
		var shape := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape != null:
			shape.disabled = true
			shape.set_meta(&"disabled_reason", "terrain_collision_replaced_by_tilemap_layer")
		for child: Node in body.get_children():
			if child is Polygon2D:
				(child as Polygon2D).visible = false


func _ensure_layer(root: Node, layer_name: String, tileset: TileSet, offset: Vector2, layer_scale: Vector2, collision_enabled: bool, z_index: int, note: String) -> TileMapLayer:
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
	layer.set_meta(&"terrain_template_layer", true)
	layer.set_meta(&"asset_binding_note", note)
	layer.set_meta(&"asset_id", _asset_id_for_tileset(tileset))
	layer.clear()
	return layer


func _asset_id_for_tileset(tileset: TileSet) -> String:
	if tileset.resource_path == SURFACE_TILESET_PATH:
		return "shrine_trial_tileset_ai01"
	if tileset.resource_path == THIN_SURFACE_TILESET_PATH:
		return "tutorial_thin_platform_visual_ai01"
	return "formal_terrain_kit_ai01"


# 扩大房间边界并把既有逻辑节点放到新蓝图对应的安全位置。
func _configure_room_nodes(root: Node) -> void:
	root.set("next_room_path", "res://scenes/rooms/stage14_backtrack_hub_room.tscn")
	root.set("next_spawn_id", &"stage14_backtrack_hub_start")
	root.set("previous_room_path", "res://scenes/rooms/stage14_air_dash_shrine_room.tscn")
	root.set("previous_spawn_id", &"stage14_shrine_return")
	root.set("checkpoint_spawn_id", &"stage14_air_dash_gate_start")
	root.set("default_step_id", &"stage14_air_dash_gate")
	root.set("air_dash_gate_room", true)
	root.set("spawn_positions", {
		&"stage14_air_dash_gate_start": Vector2(-384.0, 160.0),
		&"stage14_shrine_return": Vector2(-384.0, 160.0),
	})
	var backdrop := root.get_node_or_null("Backdrop") as Polygon2D
	if backdrop != null:
		backdrop.polygon = PackedVector2Array([
			Vector2(-512, -288), Vector2(1024, -288), Vector2(1024, 288), Vector2(-512, 288),
		])
	var sensor := root.get_node_or_null("AirDashGateSensor") as Marker2D
	var gate := root.get_node_or_null("GateBarrier") as StaticBody2D
	var exit_zone := root.get_node_or_null("ExitZone") as Area2D
	var left_exit := root.get_node_or_null("LeftExitZone") as Area2D
	if sensor != null:
		sensor.position = Vector2(160.0, 54.0)
		sensor.z_index = 2
	if gate != null:
		gate.position = Vector2(672.0, 40.0)
		gate.z_index = 2
	if exit_zone != null:
		exit_zone.position = Vector2(928.0, 32.0)
		_set_zone_visual_hidden(exit_zone)
	if left_exit != null:
		left_exit.position = Vector2(-480.0, 160.0)
		_set_zone_visual_hidden(left_exit)


func _set_zone_visual_hidden(zone: Node) -> void:
	var visual := zone.get_node_or_null("ZoneVisual") as CanvasItem
	if visual != null:
		visual.visible = false


# 单张背景覆盖完整 24x9 房间，避免重复贴图接缝。
func _configure_background(root: Node) -> void:
	var background := root.get_node_or_null("ShrineGateBackgroundArt") as Sprite2D
	if background == null:
		return
	background.visible = true
	background.position = Vector2(256.0, 0.0)
	background.scale = Vector2(0.92, 0.92)
	background.modulate = Color(1.0, 1.0, 1.0, 0.52)
	background.set_meta(&"asset_binding_note", "single_sprite_full_room_coverage_no_repeat_seam")


# 右侧崖台用一块连续暗体承托表面，不再用离散柱子拼接边界。
func _ensure_cliff_mass(root: Node) -> void:
	var cliff_root := root.get_node_or_null(NodePath(CLIFF_ROOT_NAME)) as Node2D
	if cliff_root == null:
		cliff_root = Node2D.new()
		cliff_root.name = CLIFF_ROOT_NAME
		root.add_child(cliff_root)
		cliff_root.owner = root
	for child: Node in cliff_root.get_children():
		child.free()
	cliff_root.z_index = 1
	cliff_root.set_meta(&"visual_only", true)
	cliff_root.set_meta(&"asset_binding_note", "continuous_right_cliff_mass_not_walkable_decoration")
	var mass := Polygon2D.new()
	mass.name = "RightCliffMass"
	mass.color = Color(0.28, 0.32, 0.36, 0.46)
	mass.texture = load(CLIFF_MASS_TEXTURE_PATH) as Texture2D
	mass.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	mass.polygon = PackedVector2Array([
		Vector2(416, 96), Vector2(1024, 96), Vector2(1024, 288), Vector2(416, 288),
	])
	cliff_root.add_child(mass)
	mass.owner = root
	mass.set_meta(&"asset_id", "dac_continuous_stone_underlay")


func _paint_solid_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	for offset: int in range(length):
		var atlas := FLAT_CENTER_A if posmod(offset, 2) == 0 else FLAT_CENTER_B
		if offset == 0:
			atlas = GROUND_LEFT_CAP
		elif offset == length - 1:
			atlas = GROUND_RIGHT_CAP
		layer.set_cell(Vector2i(start.x + offset, start.y), FLAT_SOURCE, atlas, 0)


func _paint_solid_rect(layer: TileMapLayer, start: Vector2i, width: int, height: int) -> void:
	for y_offset: int in range(height):
		for x_offset: int in range(width):
			var atlas := FLAT_CENTER_A if posmod(x_offset + y_offset, 2) == 0 else FLAT_CENTER_B
			layer.set_cell(Vector2i(start.x + x_offset, start.y + y_offset), FLAT_SOURCE, atlas, 0)


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


func _paint_thin_surface_run(layer: TileMapLayer, start: Vector2i, length: int) -> void:
	_paint_surface_run(layer, start, length)
