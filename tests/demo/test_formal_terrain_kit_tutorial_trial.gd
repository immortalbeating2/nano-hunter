extends GutTest

# Tutorial terrain 正式房间模板契约。
# 静态地形由 TileMapLayer collision 接管；门、触发器和敌人仍保持独立节点。

const ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_PLATFORM_SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"
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
const ENTRY_LANDMARK_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/017_shrine_gate_prop_atlas_ai01_auto_018_c02.atlas_texture.tres"
const DASH_LANDMARK_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/001_shrine_gate_prop_atlas_ai01_auto_002_c01.atlas_texture.tres"
const TRAINING_TARGET_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/006_shrine_gate_prop_atlas_ai01_auto_007_c01.atlas_texture.tres"
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
const TILE_OFFSET := Vector2(0.0, 0.0)
const THIN_TILE_OFFSET := Vector2(0.0, -16.0)
const MAIN_GROUND_START := Vector2i(-7, 2)
const MAIN_GROUND_LENGTH := 23
const JUMP_PLATFORM_START := Vector2i(-4, 1)
const JUMP_PLATFORM_LENGTH := 2
const DASH_CEILING_START := Vector2i(2, 1)
const DASH_CEILING_LENGTH := 2
const LEFT_WALL_START := Vector2i(-8, -3)
const RIGHT_WALL_START := Vector2i(16, -3)
const WALL_LENGTH := 6
const EXIT_SAFE_CELLS := [
	Vector2i(10, 2),
	Vector2i(11, 2),
	Vector2i(12, 2),
	Vector2i(13, 2),
	Vector2i(14, 2),
]
const GROUND_TOP_Y := 160.0
const GROUND_SURFACE_OFFSET := Vector2(0.0, -7.0)
const GROUND_CENTER_ALPHA_TOP_Y := 39.0
const PLAYER_COLLISION_HALF_HEIGHT := 20.0
const DASH_CEILING_VISUAL_TOP_Y := 80.0
const ROOM_LEFT_X := -512.0
const ROOM_RIGHT_X := 1024.0
const ROOM_TOP_Y := -192.0
const ROOM_BOTTOM_Y := 192.0


func test_tutorial_template_layers_have_correct_collision_authority() -> void:
	var room := _instantiate_room()
	var terrain := room.get_node_or_null(TERRAIN_LAYER_NAME) as TileMapLayer
	var platform := room.get_node_or_null(PLATFORM_LAYER_NAME) as TileMapLayer
	var thin_surface := room.get_node_or_null(THIN_PLATFORM_SURFACE_LAYER_NAME) as TileMapLayer
	assert_not_null(terrain)
	assert_not_null(platform)
	assert_not_null(thin_surface)
	if terrain == null or platform == null or thin_surface == null:
		return

	assert_false(terrain.visible, "碰撞权威层只保留 physics，不得进入成品画面。")
	assert_true(bool(terrain.get("collision_enabled")))
	assert_eq(terrain.position, TILE_OFFSET)
	assert_eq(terrain.scale, Vector2(1.0 / 6.0, 1.0 / 6.0))
	assert_eq(terrain.get_meta("asset_id", ""), "formal_terrain_kit_ai01")
	assert_eq(terrain.get_meta("asset_binding_note", ""), "tilemap_collision_authority_static_terrain")
	assert_eq(terrain.tile_set.resource_path, TILESET_PATH)

	assert_false(platform.visible, "薄平台碰撞权威层只保留 physics，不得形成幽灵台阶。")
	assert_true(bool(platform.get("collision_enabled")))
	assert_eq(platform.position, THIN_TILE_OFFSET)
	assert_eq(platform.scale, Vector2(1.0 / 6.0, 1.0 / 6.0))
	assert_eq(platform.get_meta("asset_binding_note", ""), "tilemap_one_way_collision_authority_platform")

	assert_true(thin_surface.visible)
	assert_false(bool(thin_surface.get("collision_enabled")), "薄平台可见层不能参与碰撞。")
	assert_eq(thin_surface.tile_set.resource_path, THIN_PLATFORM_SURFACE_TILESET_PATH)
	assert_eq(thin_surface.get_meta("asset_id", ""), "tutorial_thin_platform_visual_ai01")
	assert_eq(thin_surface.get_meta("asset_binding_note", ""), "thin_platform_surface_visual_only_collision_kept_in_formal_layer")

	for layer_name: String in [DOOR_LAYER_NAME, BACKGROUND_LAYER_NAME, DECOR_LAYER_NAME, FOREGROUND_LAYER_NAME]:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		assert_not_null(layer, "模板层存在：%s" % layer_name)
		if layer != null:
			assert_true(layer.visible)
			assert_false(bool(layer.get("collision_enabled")), "非地形层必须 visual-only：%s" % layer_name)


func test_tutorial_legacy_static_terrain_collision_is_disabled_but_logic_nodes_remain() -> void:
	var room := _instantiate_room()
	for body_name: String in LEGACY_TERRAIN_BODY_NAMES:
		var body := room.get_node_or_null(NodePath(body_name)) as StaticBody2D
		var shape_node := body.get_node_or_null("CollisionShape2D") as CollisionShape2D if body != null else null
		assert_not_null(body, "旧地形 authoring 节点保留：%s" % body_name)
		assert_not_null(shape_node, "旧地形 shape 保留用于房间元素追溯：%s" % body_name)
		if body != null:
			assert_eq(body.collision_layer, 0, "旧地形 body 不再参与碰撞：%s" % body_name)
			assert_eq(body.collision_mask, 0, "旧地形 body 不再参与碰撞：%s" % body_name)
			assert_eq(body.get_meta("terrain_collision_authority", ""), "replaced_by_tilemap_layer")
		if shape_node != null:
			assert_true(shape_node.disabled, "旧地形 CollisionShape2D 已禁用：%s" % body_name)

	var exit_barrier_shape := room.get_node_or_null("ExitBarrier/CollisionShape2D") as CollisionShape2D
	var exit_zone_shape := room.get_node_or_null("ExitZone/CollisionShape2D") as CollisionShape2D
	var dummy := room.get_node_or_null("TutorialDummy") as StaticBody2D
	assert_not_null(exit_barrier_shape)
	assert_not_null(exit_zone_shape)
	assert_not_null(dummy)
	if exit_barrier_shape != null:
		assert_false(exit_barrier_shape.disabled, "能力门仍由独立节点控制。")
	if exit_zone_shape != null:
		assert_false(exit_zone_shape.disabled, "出口触发器仍由独立节点控制。")
	if dummy != null:
		assert_ne(dummy.collision_layer, 0, "训练目标仍保留独立碰撞。")


func test_tutorial_grid_blueprint_has_continuous_ground_platform_caps_and_safe_exit() -> void:
	var room := _instantiate_room()
	var terrain := room.get_node_or_null(TERRAIN_LAYER_NAME) as TileMapLayer
	var platform := room.get_node_or_null(PLATFORM_LAYER_NAME) as TileMapLayer
	var surface := room.get_node_or_null(SURFACE_LAYER_NAME) as TileMapLayer
	var thin_surface := room.get_node_or_null(THIN_PLATFORM_SURFACE_LAYER_NAME) as TileMapLayer
	var door := room.get_node_or_null(DOOR_LAYER_NAME) as TileMapLayer
	assert_not_null(terrain)
	assert_not_null(platform)
	assert_not_null(surface)
	assert_not_null(thin_surface)
	assert_not_null(door)
	if terrain == null or platform == null or surface == null or thin_surface == null or door == null:
		return

	_assert_ground_run(terrain)
	_assert_wall_run(terrain, LEFT_WALL_START, 1)
	_assert_wall_run(terrain, RIGHT_WALL_START, 1)
	_assert_dash_ceiling(terrain)
	_assert_platform_run(platform)
	_assert_exit_safe_landing(terrain)
	_assert_ground_surface_layer(surface, terrain)
	_assert_thin_platform_surface_layer(thin_surface, terrain)
	_assert_door_layer(door)
	_assert_ground_underlay_retired(room)
	_assert_visual_layers_do_not_look_walkable(room)
	assert_null(room.get_node_or_null("ShrineTrialTilesetPreview"))
	_assert_old_trial_layers_hidden(room)


# 四段教学必须靠落地地标建立节拍，不能继续只剩背景、两块平台和出口门。
func test_tutorial_four_beats_use_grounded_noncolliding_landmarks() -> void:
	var room := _instantiate_room()
	var landmarks := room.get_node_or_null(LANDMARK_ROOT_NAME) as Node2D
	assert_not_null(landmarks, "教学房需要独立的 visual-only 节拍地标根节点。")
	if landmarks == null:
		return

	assert_eq(landmarks.z_index, 1, "地标应位于背景之上、可踩地表和玩家之下。")
	assert_true(bool(landmarks.get_meta("visual_only", false)))
	assert_true(bool(landmarks.get_meta("room_beat_landmarks", false)))
	assert_eq(landmarks.get_child_count(), 2, "跳跃平台本身就是第二段地标；额外只保留入口灯和冲刺神龛。")

	_assert_landmark(
		landmarks,
		"EntryStoneLantern",
		ENTRY_LANDMARK_TEXTURE_PATH,
		"entry_orientation",
		Vector2(-448.0, -320.0),
	)
	_assert_mounted_landmark(
		landmarks,
		"DashGateSealShrine",
		DASH_LANDMARK_TEXTURE_PATH,
		"dash_gate_marker",
		Vector2(160.0, 224.0),
		DASH_CEILING_VISUAL_TOP_Y,
	)

	var dummy := room.get_node_or_null("TutorialDummy") as StaticBody2D
	var dummy_art := room.get_node_or_null("TutorialDummy/DummyArt") as Sprite2D
	assert_not_null(dummy)
	assert_not_null(dummy_art)
	if dummy == null or dummy_art == null:
		return
	assert_almost_eq(dummy.position.y, GROUND_TOP_Y, 0.01, "训练目标碰撞脚底必须落在主地面顶面。")
	assert_eq(dummy_art.texture.resource_path, TRAINING_TARGET_TEXTURE_PATH, "第四段使用人工复核过的试炼碑，不再使用误标链门切片。")
	assert_eq(dummy_art.get_meta("terrain_landmark_role", ""), "training_attack_target")
	assert_true(bool(dummy_art.get_meta("gameplay_collision_owned_by_parent", false)))
	_assert_sprite_grounded(dummy_art, GROUND_TOP_Y, "训练目标视觉脚底")


# 单张背景必须覆盖整个 24x6 教学房，不能再用重复贴图留下竖向接缝或右侧空白。
func test_tutorial_background_uses_single_room_cover_without_repeat_seams() -> void:
	var room := _instantiate_room()
	var primary := room.get_node_or_null(BACKGROUND_PRIMARY_NAME) as Sprite2D
	var repeated := room.get_node_or_null(BACKGROUND_REPEAT_NAME) as Sprite2D
	assert_not_null(primary)
	assert_not_null(repeated)
	if primary == null or repeated == null:
		return
	assert_true(primary.visible)
	assert_false(repeated.visible, "重复背景必须退役，避免同一张图硬拼接。")
	assert_eq(primary.position, Vector2(256.0, 0.0))
	assert_eq(primary.scale, Vector2(0.92, 0.92))
	assert_eq(primary.get_meta("asset_binding_note", ""), "single_sprite_full_room_coverage_no_repeat_seam")
	var half_size := Vector2(primary.texture.get_width(), primary.texture.get_height()) * primary.scale * 0.5
	assert_true(primary.position.x - half_size.x <= ROOM_LEFT_X)
	assert_true(primary.position.x + half_size.x >= ROOM_RIGHT_X)
	assert_true(primary.position.y - half_size.y <= ROOM_TOP_Y)
	assert_true(primary.position.y + half_size.y >= ROOM_BOTTOM_Y)


# 运行态玩家碰撞脚底必须和主地面的真实不透明像素顶面重合，而不是只落在同一网格行。
func test_tutorial_spawn_feet_match_visible_ground_top() -> void:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	for _i: int in range(4):
		await get_tree().process_frame
	main.call("start_demo")
	for _i: int in range(30):
		await get_tree().physics_frame

	var player := main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var surface := main.get_node_or_null("Room/GroundSurfaceVisual") as TileMapLayer
	assert_not_null(player)
	assert_not_null(surface)
	if player == null or surface == null:
		return
	var player_bottom := player.global_position.y + PLAYER_COLLISION_HALF_HEIGHT
	var visible_ground_top := _visible_ground_top(surface)
	assert_almost_eq(player_bottom, GROUND_TOP_Y, 0.25, "玩家碰撞脚底保持在正式主地面基线。")
	assert_almost_eq(visible_ground_top, GROUND_TOP_Y, 0.25, "主地面不透明像素顶面必须落在同一基线。")
	assert_almost_eq(player_bottom, visible_ground_top, 0.25, "Luna 脚底和视觉地面必须吻合。")


func _instantiate_room() -> Node2D:
	var packed := load(ROOM_PATH) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return null
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room


func _assert_ground_run(layer: TileMapLayer) -> void:
	var flat_cells := _cells_for_source(layer, 0)
	assert_eq(flat_cells.size(), MAIN_GROUND_LENGTH, "主路平地只能是一条连续 run，不能有额外碎块。")
	for offset: int in range(MAIN_GROUND_LENGTH):
		var cell := Vector2i(MAIN_GROUND_START.x + offset, MAIN_GROUND_START.y)
		assert_true(flat_cells.has(cell), "主路平地连续：%s" % cell)
		var atlas := layer.get_cell_atlas_coords(cell)
		if offset == 0:
			assert_eq(atlas, Vector2i(2, 0), "主路左 cap 只出现在起点。")
		elif offset == MAIN_GROUND_LENGTH - 1:
			assert_eq(atlas, Vector2i(3, 0), "主路右 cap 只出现在终点。")
		else:
			assert_true(atlas in [Vector2i(0, 0), Vector2i(1, 0)], "主路中段不能出现 cap：%s" % cell)
		_assert_solid_collision(layer, cell, "主路平地有碰撞：%s" % cell)


func _assert_wall_run(layer: TileMapLayer, start: Vector2i, source_id: int) -> void:
	for offset: int in range(WALL_LENGTH):
		var cell := Vector2i(start.x, start.y + offset)
		assert_true(layer.get_used_cells().has(cell), "边界墙连续：%s" % cell)
		assert_eq(layer.get_cell_source_id(cell), source_id, "边界墙使用 wall/cliff source：%s" % cell)
		_assert_solid_collision(layer, cell, "边界墙有碰撞：%s" % cell)


func _assert_dash_ceiling(layer: TileMapLayer) -> void:
	for offset: int in range(DASH_CEILING_LENGTH):
		var cell := Vector2i(DASH_CEILING_START.x + offset, DASH_CEILING_START.y)
		assert_true(layer.get_used_cells().has(cell), "dash 门低顶连续：%s" % cell)
		assert_eq(layer.get_cell_source_id(cell), 2)
		assert_eq(layer.get_cell_atlas_coords(cell), Vector2i(2, 1))
		_assert_solid_collision(layer, cell, "dash 门低顶是实体碰撞：%s" % cell)


func _assert_platform_run(layer: TileMapLayer) -> void:
	var flat_cells := _cells_for_source(layer, 0)
	assert_eq(flat_cells.size(), JUMP_PLATFORM_LENGTH, "跳跃平台只能是一条短 run。")
	for offset: int in range(JUMP_PLATFORM_LENGTH):
		var cell := Vector2i(JUMP_PLATFORM_START.x + offset, JUMP_PLATFORM_START.y)
		assert_true(flat_cells.has(cell), "跳跃平台连续：%s" % cell)
		var atlas := layer.get_cell_atlas_coords(cell)
		if offset == 0:
			assert_eq(atlas, Vector2i(1, 2), "平台左 cap")
		elif offset == JUMP_PLATFORM_LENGTH - 1:
			assert_eq(atlas, Vector2i(2, 2), "平台右 cap")
		else:
			assert_eq(atlas, Vector2i(0, 2), "平台中段")
		var tile_data := _tile_data(layer, cell)
		assert_not_null(tile_data)
		if tile_data != null:
			assert_eq(tile_data.get_collision_polygons_count(0), 1)
			assert_true(tile_data.is_collision_polygon_one_way(0, 0), "跳跃平台必须是 one-way：%s" % cell)


func _assert_exit_safe_landing(layer: TileMapLayer) -> void:
	for cell: Vector2i in EXIT_SAFE_CELLS:
		assert_true(layer.get_used_cells().has(cell), "出口前后安全落点必须连续：%s" % cell)
		assert_eq(layer.get_cell_source_id(cell), 0)
		assert_true(layer.get_cell_atlas_coords(cell) in [Vector2i(0, 0), Vector2i(1, 0)], "出口安全落点不能是断崖 cap：%s" % cell)


func _assert_door_layer(layer: TileMapLayer) -> void:
	assert_false(bool(layer.get("collision_enabled")), "门框视觉不参与碰撞。")
	assert_eq(layer.get_used_cells().size(), 0, "tutorial_room 不再铺孤立门框 / 小台座 tile。")


func _assert_ground_surface_layer(surface: TileMapLayer, terrain: TileMapLayer) -> void:
	assert_true(surface.visible)
	assert_false(bool(surface.get("collision_enabled")), "可见地表层只负责读值，不参与碰撞。")
	assert_eq(surface.tile_set.resource_path, SURFACE_TILESET_PATH)
	assert_eq(surface.get_meta("asset_id", ""), "shrine_trial_tileset_ai01")
	assert_true(surface.z_index > terrain.z_index, "可见地表必须盖住碰撞层散砖。")
	assert_eq(surface.position, GROUND_SURFACE_OFFSET, "可见地表根据真实 alpha top 校正到碰撞脚底基线。")
	assert_almost_eq(_visible_ground_top(surface), GROUND_TOP_Y, 0.25)
	for offset: int in range(MAIN_GROUND_LENGTH):
		var cell := Vector2i(MAIN_GROUND_START.x + offset, MAIN_GROUND_START.y)
		assert_true(surface.get_used_cells().has(cell), "主路可见地表必须覆盖每个网格：%s" % cell)
		var expected := Vector2i(1, 0)
		if offset == 0:
			expected = Vector2i(0, 0)
		elif offset == MAIN_GROUND_LENGTH - 1:
			expected = Vector2i(2, 0)
		assert_eq(surface.get_cell_atlas_coords(cell), expected, "主路只能使用 left / center / right 三类地面件：%s" % cell)
	for offset: int in range(JUMP_PLATFORM_LENGTH):
		var cell := Vector2i(JUMP_PLATFORM_START.x + offset, JUMP_PLATFORM_START.y)
		assert_false(surface.get_used_cells().has(cell), "厚平台素材不能再覆盖跳台：%s" % cell)
	for offset: int in range(DASH_CEILING_LENGTH):
		var cell := Vector2i(DASH_CEILING_START.x + offset, DASH_CEILING_START.y)
		assert_false(surface.get_used_cells().has(cell), "厚平台素材不能再覆盖 dash 门低顶：%s" % cell)


func _assert_thin_platform_surface_layer(surface: TileMapLayer, terrain: TileMapLayer) -> void:
	assert_true(surface.visible)
	assert_false(bool(surface.get("collision_enabled")), "薄平台可见层只负责读值，不参与碰撞。")
	assert_eq(surface.tile_set.resource_path, THIN_PLATFORM_SURFACE_TILESET_PATH)
	assert_eq(surface.get_meta("asset_id", ""), "tutorial_thin_platform_visual_ai01")
	assert_true(surface.z_index > terrain.z_index, "薄平台可见层必须盖住低透明碰撞层。")
	for offset: int in range(JUMP_PLATFORM_LENGTH):
		var cell := Vector2i(JUMP_PLATFORM_START.x + offset, JUMP_PLATFORM_START.y)
		assert_true(surface.get_used_cells().has(cell), "跳台可见地表存在：%s" % cell)
		var expected := Vector2i(1, 0)
		if offset == 0:
			expected = Vector2i(0, 0)
		elif offset == JUMP_PLATFORM_LENGTH - 1:
			expected = Vector2i(2, 0)
		assert_eq(surface.get_cell_atlas_coords(cell), expected, "跳台只使用薄平台 left / center / right：%s" % cell)
	for offset: int in range(DASH_CEILING_LENGTH):
		var cell := Vector2i(DASH_CEILING_START.x + offset, DASH_CEILING_START.y)
		assert_true(surface.get_used_cells().has(cell), "dash 门低顶可见薄边存在：%s" % cell)
		var expected := Vector2i(0, 0)
		if offset == DASH_CEILING_LENGTH - 1:
			expected = Vector2i(2, 0)
		assert_eq(surface.get_cell_atlas_coords(cell), expected, "dash 门低顶也必须使用薄平台件：%s" % cell)


func _assert_ground_underlay_retired(room: Node2D) -> void:
	var underlay := room.get_node_or_null(GROUND_UNDERLAY_NAME) as Polygon2D
	assert_not_null(underlay)
	if underlay == null:
		return
	assert_false(underlay.visible, "带格线的 underlay 不能再冒充连续主地面。")
	assert_eq(underlay.get_meta("asset_binding_note", ""), "retired_grid_texture_replaced_by_ground_surface_visual")


func _assert_visual_layers_do_not_look_walkable(room: Node2D) -> void:
	for layer_name: String in [BACKGROUND_LAYER_NAME, DECOR_LAYER_NAME, FOREGROUND_LAYER_NAME]:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		assert_not_null(layer)
		if layer == null:
			continue
		assert_false(bool(layer.get("collision_enabled")), "视觉层不能有碰撞：%s" % layer_name)
		assert_eq(layer.get_used_cells().size(), 0, "tutorial_room 的背景 / 装饰 / 前景 TileMap 不再乱贴误读资产：%s" % layer_name)
		for cell: Vector2i in layer.get_used_cells():
			assert_eq(layer.get_cell_source_id(cell), 3, "视觉层只能使用装饰源，不能摆成可踩路或柱子：%s %s" % [layer_name, cell])


func _assert_old_trial_layers_hidden(room: Node2D) -> void:
	for layer_name: String in OLD_LAYER_NAMES:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		assert_not_null(layer, "旧层保留用于回退：%s" % layer_name)
		if layer != null:
			assert_false(layer.visible, "旧试铺层不能叠加：%s" % layer_name)
			assert_false(bool(layer.get("collision_enabled")), "旧试铺层不能参与碰撞：%s" % layer_name)


# 单个节拍地标必须语义明确、落地，并且绝不携带独立碰撞。
func _assert_landmark(
	landmarks: Node2D,
	node_name: String,
	texture_path: String,
	role: String,
	x_range: Vector2,
) -> void:
	var sprite := landmarks.get_node_or_null(NodePath(node_name)) as Sprite2D
	assert_not_null(sprite, "节拍地标存在：%s" % node_name)
	if sprite == null:
		return
	assert_true(sprite.visible)
	assert_not_null(sprite.texture)
	if sprite.texture != null:
		assert_eq(sprite.texture.resource_path, texture_path, "地标使用人工挑选的单件 AtlasTexture：%s" % node_name)
	assert_eq(sprite.get_meta("asset_id", ""), "shrine_gate_prop_atlas_ai01")
	assert_eq(sprite.get_meta("terrain_landmark_role", ""), role)
	assert_false(bool(sprite.get_meta("gameplay_collision", true)), "地标不能拥有玩法碰撞：%s" % node_name)
	assert_true(sprite.position.x >= x_range.x and sprite.position.x <= x_range.y, "地标位于对应教学段：%s" % node_name)
	_assert_sprite_grounded(sprite, GROUND_TOP_Y, "%s 视觉脚底" % node_name)
	_assert_no_collision_descendants(sprite, node_name)


# 冲刺神龛安装在实体低顶上方，不落在玩家行走线上，也不额外增加碰撞。
func _assert_mounted_landmark(
	landmarks: Node2D,
	node_name: String,
	texture_path: String,
	role: String,
	x_range: Vector2,
	support_y: float,
) -> void:
	var sprite := landmarks.get_node_or_null(NodePath(node_name)) as Sprite2D
	assert_not_null(sprite, "安装式地标存在：%s" % node_name)
	if sprite == null:
		return
	assert_true(sprite.visible)
	assert_not_null(sprite.texture)
	if sprite.texture != null:
		assert_eq(sprite.texture.resource_path, texture_path)
	assert_eq(sprite.get_meta("terrain_landmark_role", ""), role)
	assert_false(bool(sprite.get_meta("gameplay_collision", true)))
	assert_true(sprite.position.x >= x_range.x and sprite.position.x <= x_range.y)
	var visual_bottom := sprite.global_position.y + float(sprite.texture.get_height()) * absf(sprite.global_scale.y) * 0.5
	assert_almost_eq(visual_bottom, support_y, 0.75, "冲刺神龛底边必须贴住低顶。")
	_assert_no_collision_descendants(sprite, node_name)


# 用纹理框底边检查锚点，防止资产再次悬空或嵌入地面。
func _assert_sprite_grounded(sprite: Sprite2D, ground_y: float, label: String) -> void:
	if sprite.texture == null:
		return
	var visual_bottom := sprite.global_position.y + float(sprite.texture.get_height()) * absf(sprite.global_scale.y) * 0.5
	assert_almost_eq(visual_bottom, ground_y, 0.75, "%s 必须和可见地面顶面对齐。" % label)


# visual-only 地标树中不允许混入 StaticBody、Area 或 CollisionShape。
func _assert_no_collision_descendants(node: Node, label: String) -> void:
	for child: Node in node.get_children():
		assert_false(child is CollisionObject2D or child is CollisionShape2D or child is CollisionPolygon2D, "地标不能携带碰撞节点：%s/%s" % [label, child.name])
		_assert_no_collision_descendants(child, label)


# 中段地面切片的 alpha 顶边在 64px region 内为 y=39，用它换算实际可见地表高度。
func _visible_ground_top(surface: TileMapLayer) -> float:
	var center_cell := Vector2i(0, MAIN_GROUND_START.y)
	var center_global := surface.to_global(surface.map_to_local(center_cell))
	return center_global.y - 32.0 + GROUND_CENTER_ALPHA_TOP_Y


func _cells_for_source(layer: TileMapLayer, source_id: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell: Vector2i in layer.get_used_cells():
		if layer.get_cell_source_id(cell) == source_id:
			result.append(cell)
	return result


func _assert_solid_collision(layer: TileMapLayer, cell: Vector2i, label: String) -> void:
	var tile_data := _tile_data(layer, cell)
	assert_not_null(tile_data)
	if tile_data != null:
		assert_eq(tile_data.get_collision_polygons_count(0), 1, label)
		assert_false(tile_data.is_collision_polygon_one_way(0, 0), label)


func _tile_data(layer: TileMapLayer, cell: Vector2i) -> TileData:
	var source := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
	assert_not_null(source)
	if source == null:
		return null
	return source.get_tile_data(layer.get_cell_atlas_coords(cell), 0)
