extends SceneTree

# Tutorial terrain 正式房间模板生成。
# ponytail: 只服务 tutorial_room，推广到其它房间时再抽通用铺设器。

const ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_PLATFORM_SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"
const ENTRY_LANDMARK_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/017_shrine_gate_prop_atlas_ai01_auto_018_c02.atlas_texture.tres")
const DASH_LANDMARK_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/001_shrine_gate_prop_atlas_ai01_auto_002_c01.atlas_texture.tres")
const ASSET_ID := "formal_terrain_kit_ai01"
const SURFACE_ASSET_ID := "shrine_trial_tileset_ai01"
const THIN_PLATFORM_SURFACE_ASSET_ID := "tutorial_thin_platform_visual_ai01"
const TILE_WORLD_SIZE := 64.0
const TILE_OFFSET := Vector2(0.0, 0.0)
const THIN_TILE_OFFSET := Vector2(0.0, -16.0)
const TILE_SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)

const GROUND_UNDERLAY_NAME := "GroundUnderlayVisual"
const SURFACE_LAYER_NAME := "GroundSurfaceVisual"
const THIN_PLATFORM_SURFACE_LAYER_NAME := "ThinPlatformSurfaceVisual"
const TERRAIN_LAYER_NAME := "TerrainCollisionVisual"
const PLATFORM_LAYER_NAME := "PlatformCollisionVisual"
const DOOR_LAYER_NAME := "DoorVisual"
const BACKGROUND_LAYER_NAME := "BackgroundVisual"
const DECOR_LAYER_NAME := "DecorVisual"
const FOREGROUND_LAYER_NAME := "ForegroundVisual"
const LANDMARK_ROOT_NAME := "TutorialLandmarks"
const BACKGROUND_PRIMARY_NAME := "TutorialShrineBackgroundArt"
const BACKGROUND_REPEAT_NAME := "TutorialShrineBackgroundArtLeft"
const OLD_LAYER_NAMES := [
	"FormalTerrainTilemapDecor",
	"FormalForegroundEdgeDecor",
	"FormalTerrainKitTutorialTrial",
	"FormalTerrainKitTutorialThinTrial",
]
const LEGACY_TERRAIN_BODY_NAMES := [
	"LeftWall",
	"RightWall",
	"FloorStart",
	"JumpGuidePlatform",
	"DashGateLeft",
	"DashGateRight",
	"DashGateCeiling",
	"CombatFloor",
	"ExitFloor",
]

const FLAT_SOURCE := 0
const CLIFF_SOURCE := 1
const DOOR_SOURCE := 2
const DECOR_SOURCE := 3

const FLAT_CENTER_A := Vector2i(0, 0)
const FLAT_CENTER_B := Vector2i(1, 0)
const GROUND_LEFT_CAP := Vector2i(2, 0)
const GROUND_RIGHT_CAP := Vector2i(3, 0)
const PLATFORM_CENTER := Vector2i(0, 2)
const PLATFORM_LEFT_CAP := Vector2i(1, 2)
const PLATFORM_RIGHT_CAP := Vector2i(2, 2)
const CLIFF_FACE := Vector2i(0, 1)
const LEFT_WALL_SIDE := Vector2i(0, 2)
const RIGHT_WALL_SIDE := Vector2i(1, 2)
const SUPPORT_TRIM := Vector2i(2, 2)
const DOOR_LEFT_JAMB := Vector2i(0, 0)
const DOOR_RIGHT_JAMB := Vector2i(1, 0)
const DOOR_TOP_THIN_SOLID := Vector2i(2, 1)
const DOOR_SAFE_LANDING := Vector2i(0, 2)
const DOOR_PEDESTAL := Vector2i(2, 2)
const DECOR_CRACK := Vector2i(3, 0)
const DECOR_VINE := Vector2i(1, 0)
const DECOR_TALISMAN := Vector2i(2, 1)
const DECOR_HANGING := Vector2i(3, 1)
const SURFACE_GROUND_LEFT := Vector2i(0, 0)
const SURFACE_GROUND_CENTER := Vector2i(1, 0)
const SURFACE_GROUND_RIGHT := Vector2i(2, 0)
const SURFACE_PLATFORM_LEFT := Vector2i(0, 1)
const SURFACE_PLATFORM_CENTER := Vector2i(1, 1)
const SURFACE_PLATFORM_RIGHT := Vector2i(2, 1)
const THIN_SURFACE_PLATFORM_LEFT := Vector2i(0, 0)
const THIN_SURFACE_PLATFORM_CENTER := Vector2i(1, 0)
const THIN_SURFACE_PLATFORM_RIGHT := Vector2i(2, 0)

const MAIN_GROUND_START := Vector2i(-7, 2)
const MAIN_GROUND_LENGTH := 23
const JUMP_PLATFORM_START := Vector2i(-4, 1)
const JUMP_PLATFORM_LENGTH := 2
const DASH_CEILING_START := Vector2i(2, 1)
const DASH_CEILING_LENGTH := 2
const EXIT_SAFE_CELLS := [
	Vector2i(10, 2),
	Vector2i(11, 2),
	Vector2i(12, 2),
	Vector2i(13, 2),
	Vector2i(14, 2),
]
const LEFT_WALL_START := Vector2i(-8, -3)
const RIGHT_WALL_START := Vector2i(16, -3)
const WALL_LENGTH := 6
const GROUND_TOP_Y := 160.0
const GROUND_SURFACE_OFFSET := Vector2(0.0, -7.0)
const DASH_CEILING_VISUAL_TOP_Y := 80.0


func _init() -> void:
	var result := _run()
	quit(result)


func _run() -> int:
	var tileset := load(TILESET_PATH) as TileSet
	if tileset == null:
		push_error("Missing formal terrain kit TileSet: %s" % TILESET_PATH)
		return 1
	var surface_tileset := load(SURFACE_TILESET_PATH) as TileSet
	if surface_tileset == null:
		push_error("Missing tutorial surface TileSet: %s" % SURFACE_TILESET_PATH)
		return 1
	var thin_platform_surface_tileset := load(THIN_PLATFORM_SURFACE_TILESET_PATH) as TileSet
	if thin_platform_surface_tileset == null:
		push_error("Missing tutorial thin platform surface TileSet: %s" % THIN_PLATFORM_SURFACE_TILESET_PATH)
		return 1

	var packed := load(ROOM_PATH) as PackedScene
	if packed == null:
		push_error("Missing room scene: %s" % ROOM_PATH)
		return 1

	var root := packed.instantiate()
	_apply_template(root, tileset, surface_tileset, thin_platform_surface_tileset)

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

	print("tutorial terrain room template applied: %s" % ROOM_PATH)
	return 0


func _apply_template(root: Node, tileset: TileSet, surface_tileset: TileSet, thin_platform_surface_tileset: TileSet) -> void:
	_hide_old_tile_layers(root)
	_disable_legacy_terrain_collision(root)
	_retire_ground_underlay(root)

	var terrain := _ensure_layer(root, TERRAIN_LAYER_NAME, tileset, TILE_OFFSET, true, 1, "tilemap_collision_authority_static_terrain")
	var platform := _ensure_layer(root, PLATFORM_LAYER_NAME, tileset, THIN_TILE_OFFSET, true, 2, "tilemap_one_way_collision_authority_platform")
	var surface := _ensure_surface_layer(root, surface_tileset)
	var thin_platform_surface := _ensure_thin_platform_surface_layer(root, thin_platform_surface_tileset)
	var door := _ensure_layer(root, DOOR_LAYER_NAME, tileset, TILE_OFFSET, false, 3, "door_frame_visual_only_exit_logic_kept_separate")
	var background := _ensure_layer(root, BACKGROUND_LAYER_NAME, tileset, TILE_OFFSET, false, -1, "background_visual_only_not_walkable")
	var decor := _ensure_layer(root, DECOR_LAYER_NAME, tileset, TILE_OFFSET, false, 4, "decor_visual_only_not_walkable")
	var foreground := _ensure_layer(root, FOREGROUND_LAYER_NAME, tileset, TILE_OFFSET, false, 6, "foreground_visual_only_not_walkable")

	terrain.modulate = Color(1.0, 1.0, 1.0, 0.08)
	platform.modulate = Color(1.0, 1.0, 1.0, 0.08)
	surface.modulate = Color(1.0, 1.0, 1.0, 1.0)
	thin_platform_surface.modulate = Color(1.0, 1.0, 1.0, 1.0)
	door.modulate = Color(1.0, 1.0, 1.0, 0.96)
	background.modulate = Color(0.72, 0.82, 0.9, 0.36)
	decor.modulate = Color(1.0, 1.0, 1.0, 0.72)
	foreground.modulate = Color(1.0, 1.0, 1.0, 0.58)

	# ponytail: 单房间蓝图表，先把第一关排版做稳；多房间时再抽生成器。
	_paint_ground_run(terrain, MAIN_GROUND_START, MAIN_GROUND_LENGTH)
	_paint_platform_run(platform, JUMP_PLATFORM_START, JUMP_PLATFORM_LENGTH)
	_paint_wall_run(terrain, LEFT_WALL_START, WALL_LENGTH, LEFT_WALL_SIDE)
	_paint_wall_run(terrain, RIGHT_WALL_START, WALL_LENGTH, RIGHT_WALL_SIDE)
	_paint_thin_ceiling_run(terrain, DASH_CEILING_START, DASH_CEILING_LENGTH)
	_paint_surface_layer(surface)
	_paint_thin_platform_surface_layer(thin_platform_surface)
	_paint_door_layer(door)
	_paint_background_layer(background)
	_paint_decor_layer(decor)
	_paint_foreground_layer(foreground)
	_configure_background_art(root)
	_ensure_tutorial_landmarks(root)
	_configure_training_target(root)


func _hide_old_tile_layers(root: Node) -> void:
	for layer_name: String in OLD_LAYER_NAMES:
		var layer := root.get_node_or_null(NodePath(layer_name)) as TileMapLayer
		if layer == null:
			continue
		layer.visible = false
		layer.set("collision_enabled", false)
		layer.set_meta(&"asset_binding_note", "hidden_after_tutorial_room_terrain_template")


func _disable_legacy_terrain_collision(root: Node) -> void:
	for body_name: String in LEGACY_TERRAIN_BODY_NAMES:
		var body := root.get_node_or_null(NodePath(body_name)) as StaticBody2D
		if body == null:
			continue
		body.collision_layer = 0
		body.collision_mask = 0
		body.set_meta(&"terrain_collision_authority", "replaced_by_tilemap_layer")
		var shape_node := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_node != null:
			shape_node.disabled = true
			shape_node.set_meta(&"disabled_reason", "terrain_collision_replaced_by_tilemap_layer")
		for child: Node in body.get_children():
			var polygon := child as Polygon2D
			if polygon != null:
				polygon.visible = false
				polygon.set_meta(&"asset_binding_note", "hidden_after_tilemap_collision_template")


func _retire_ground_underlay(root: Node) -> void:
	var underlay := root.get_node_or_null(NodePath(GROUND_UNDERLAY_NAME)) as Polygon2D
	if underlay != null:
		underlay.visible = false
		underlay.set_meta(&"asset_binding_note", "retired_grid_texture_replaced_by_ground_surface_visual")


func _ensure_layer(root: Node, layer_name: String, tileset: TileSet, offset: Vector2, collision_enabled: bool, z_index: int, note: String) -> TileMapLayer:
	var layer := root.get_node_or_null(NodePath(layer_name)) as TileMapLayer
	if layer == null:
		layer = TileMapLayer.new()
		layer.name = layer_name
		root.add_child(layer)
		layer.owner = root

	layer.visible = true
	layer.tile_set = tileset
	layer.position = offset
	layer.scale = TILE_SCALE
	layer.z_index = z_index
	layer.set("collision_enabled", collision_enabled)
	layer.set_meta(&"asset_id", ASSET_ID)
	layer.set_meta(&"asset_binding_note", note)
	layer.set_meta(&"terrain_template_layer", true)
	layer.clear()
	return layer


func _ensure_surface_layer(root: Node, tileset: TileSet) -> TileMapLayer:
	var layer := root.get_node_or_null(NodePath(SURFACE_LAYER_NAME)) as TileMapLayer
	if layer == null:
		layer = TileMapLayer.new()
		layer.name = SURFACE_LAYER_NAME
		root.add_child(layer)
		layer.owner = root
	layer.visible = true
	layer.tile_set = tileset
	layer.position = GROUND_SURFACE_OFFSET
	layer.scale = Vector2.ONE
	layer.z_index = 2
	layer.set("collision_enabled", false)
	layer.set_meta(&"asset_id", SURFACE_ASSET_ID)
	layer.set_meta(&"asset_binding_note", "continuous_ground_surface_visual_only_collision_kept_in_formal_layer")
	layer.set_meta(&"terrain_template_layer", true)
	layer.clear()
	return layer


func _ensure_thin_platform_surface_layer(root: Node, tileset: TileSet) -> TileMapLayer:
	var layer := root.get_node_or_null(NodePath(THIN_PLATFORM_SURFACE_LAYER_NAME)) as TileMapLayer
	if layer == null:
		layer = TileMapLayer.new()
		layer.name = THIN_PLATFORM_SURFACE_LAYER_NAME
		root.add_child(layer)
		layer.owner = root
	layer.visible = true
	layer.tile_set = tileset
	layer.position = Vector2.ZERO
	layer.scale = Vector2.ONE
	layer.z_index = 3
	layer.set("collision_enabled", false)
	layer.set_meta(&"asset_id", THIN_PLATFORM_SURFACE_ASSET_ID)
	layer.set_meta(&"asset_binding_note", "thin_platform_surface_visual_only_collision_kept_in_formal_layer")
	layer.set_meta(&"terrain_template_layer", true)
	layer.clear()
	return layer


func _paint_ground_run(layer: TileMapLayer, start: Vector2i, count: int) -> void:
	for offset: int in range(count):
		var atlas := FLAT_CENTER_A if posmod(offset, 2) == 0 else FLAT_CENTER_B
		if offset == 0:
			atlas = GROUND_LEFT_CAP
		elif offset == count - 1:
			atlas = GROUND_RIGHT_CAP
		layer.set_cell(Vector2i(start.x + offset, start.y), FLAT_SOURCE, atlas, 0)


func _paint_platform_run(layer: TileMapLayer, start: Vector2i, count: int) -> void:
	for offset: int in range(count):
		var atlas := PLATFORM_CENTER
		if offset == 0:
			atlas = PLATFORM_LEFT_CAP
		elif offset == count - 1:
			atlas = PLATFORM_RIGHT_CAP
		layer.set_cell(Vector2i(start.x + offset, start.y), FLAT_SOURCE, atlas, 0)


func _paint_wall_run(layer: TileMapLayer, start: Vector2i, count: int, atlas: Vector2i) -> void:
	for offset: int in range(count):
		layer.set_cell(Vector2i(start.x, start.y + offset), CLIFF_SOURCE, atlas, 0)


func _paint_thin_ceiling_run(layer: TileMapLayer, start: Vector2i, count: int) -> void:
	for offset: int in range(count):
		layer.set_cell(Vector2i(start.x + offset, start.y), DOOR_SOURCE, DOOR_TOP_THIN_SOLID, 0)


func _paint_surface_layer(layer: TileMapLayer) -> void:
	for offset: int in range(MAIN_GROUND_LENGTH):
		var atlas := SURFACE_GROUND_CENTER
		if offset == 0:
			atlas = SURFACE_GROUND_LEFT
		elif offset == MAIN_GROUND_LENGTH - 1:
			atlas = SURFACE_GROUND_RIGHT
		layer.set_cell(Vector2i(MAIN_GROUND_START.x + offset, MAIN_GROUND_START.y), 0, atlas, 0)


func _paint_thin_platform_surface_layer(layer: TileMapLayer) -> void:
	for offset: int in range(JUMP_PLATFORM_LENGTH):
		var atlas := THIN_SURFACE_PLATFORM_CENTER
		if offset == 0:
			atlas = THIN_SURFACE_PLATFORM_LEFT
		elif offset == JUMP_PLATFORM_LENGTH - 1:
			atlas = THIN_SURFACE_PLATFORM_RIGHT
		layer.set_cell(Vector2i(JUMP_PLATFORM_START.x + offset, JUMP_PLATFORM_START.y), 0, atlas, 0)
	for offset: int in range(DASH_CEILING_LENGTH):
		var atlas := THIN_SURFACE_PLATFORM_LEFT
		if offset == DASH_CEILING_LENGTH - 1:
			atlas = THIN_SURFACE_PLATFORM_RIGHT
		layer.set_cell(Vector2i(DASH_CEILING_START.x + offset, DASH_CEILING_START.y), 0, atlas, 0)


func _paint_door_layer(layer: TileMapLayer) -> void:
	# ponytail: 这间教学房已有 ExitBarrier 表达门禁；孤立门框 tile 会被误读成漂浮柱。
	layer.clear()


func _paint_background_layer(layer: TileMapLayer) -> void:
	layer.clear()


func _paint_decor_layer(layer: TileMapLayer) -> void:
	layer.clear()


func _paint_foreground_layer(layer: TileMapLayer) -> void:
	layer.clear()


# 入口灯和冲刺神龛补足首尾节拍；跳跃平台、训练目标和出口门本身已经是清晰玩法地标。
func _ensure_tutorial_landmarks(root: Node) -> void:
	var landmarks := root.get_node_or_null(NodePath(LANDMARK_ROOT_NAME)) as Node2D
	if landmarks == null:
		landmarks = Node2D.new()
		landmarks.name = LANDMARK_ROOT_NAME
		root.add_child(landmarks)
		landmarks.owner = root
	for child: Node in landmarks.get_children():
		child.free()

	landmarks.z_index = 1
	landmarks.set_meta(&"visual_only", true)
	landmarks.set_meta(&"room_beat_landmarks", true)
	landmarks.set_meta(&"asset_binding_note", "tutorial_room_formal_beat_landmarks")

	_create_bottom_aligned_landmark(
		landmarks,
		root,
		"EntryStoneLantern",
		ENTRY_LANDMARK_TEXTURE,
		-432.0,
		0.32,
		GROUND_TOP_Y,
		"entry_orientation",
		"manual_review_index_17_stone_lantern_unlit",
		Color(0.58, 0.68, 0.76, 0.58),
	)
	_create_bottom_aligned_landmark(
		landmarks,
		root,
		"DashGateSealShrine",
		DASH_LANDMARK_TEXTURE,
		192.0,
		0.24,
		DASH_CEILING_VISUAL_TOP_Y,
		"dash_gate_marker",
		"shrine_gate_prop_atlas_ai01.air_dash_shrine_active",
		Color(0.78, 0.92, 1.0, 0.92),
	)


# 以指定支撑面计算锚点，既可用于地面摆件，也可用于安装在实体低顶上的神龛。
func _create_bottom_aligned_landmark(
	parent: Node2D,
	owner: Node,
	node_name: String,
	texture: Texture2D,
	world_x: float,
	uniform_scale: float,
	support_y: float,
	role: String,
	runtime_source: String,
	modulate_color: Color,
) -> void:
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = texture
	sprite.position = Vector2(world_x, support_y - float(texture.get_height()) * uniform_scale * 0.5)
	sprite.scale = Vector2.ONE * uniform_scale
	sprite.modulate = modulate_color
	sprite.set_meta(&"asset_id", "shrine_gate_prop_atlas_ai01")
	sprite.set_meta(&"runtime_source", runtime_source)
	sprite.set_meta(&"terrain_landmark_role", role)
	sprite.set_meta(&"gameplay_collision", false)
	sprite.set_meta(&"asset_binding_note", "tutorial_room_visual_only_grounded_landmark")
	parent.add_child(sprite)
	sprite.owner = owner


# 教学房只保留一张完整背景，覆盖 24x6 房间边界并消除重复贴图接缝。
func _configure_background_art(root: Node) -> void:
	var primary := root.get_node_or_null(NodePath(BACKGROUND_PRIMARY_NAME)) as Sprite2D
	var repeated := root.get_node_or_null(NodePath(BACKGROUND_REPEAT_NAME)) as Sprite2D
	if primary != null:
		primary.visible = true
		primary.position = Vector2(256.0, 0.0)
		primary.scale = Vector2(0.92, 0.92)
		primary.modulate = Color(1.0, 1.0, 1.0, 0.52)
		primary.set_meta(&"asset_binding_note", "single_sprite_full_room_coverage_no_repeat_seam")
	if repeated != null:
		repeated.visible = false
		repeated.set_meta(&"asset_binding_note", "retired_repeated_background_after_full_room_cover")


# 教学攻击目标本体由 training_dummy.tscn 统一维护；这里只校正房间实例的碰撞脚底。
func _configure_training_target(root: Node) -> void:
	var dummy := root.get_node_or_null("TutorialDummy") as StaticBody2D
	if dummy == null:
		return
	dummy.position.y = GROUND_TOP_Y


func _cell_x(world_x: float, offset: Vector2 = TILE_OFFSET) -> int:
	return roundi((world_x - offset.x) / TILE_WORLD_SIZE)


func _cell_y(world_y: float, offset: Vector2 = TILE_OFFSET) -> int:
	return roundi((world_y - offset.y) / TILE_WORLD_SIZE)
