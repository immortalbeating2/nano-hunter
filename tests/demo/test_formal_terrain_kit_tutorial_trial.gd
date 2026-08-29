extends GutTest

# Tutorial 正式房间模板契约。
# Blueprint V2 的 Phase2GrayboxLayout 接管静态地形；旧 TileMap 只保留追溯数据。

const ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const JUMP_PLATFORM_SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_jump_platform_visual_ai02.tileset.tres"
const DASH_GATE_LINTEL_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_dash_gate_lintel_visual_ai01.tileset.tres"
const GROUND_UNDERLAY_NAME := "GroundUnderlayVisual"
const SURFACE_LAYER_NAME := "GroundSurfaceVisual"
const THIN_PLATFORM_SURFACE_LAYER_NAME := "ThinPlatformSurfaceVisual"
const DASH_GATE_LINTEL_LAYER_NAME := "DashGateLintelVisual"
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
	"CombatFloor",
	"ExitFloor",
]
const GROUND_TOP_Y := 160.0
const PLAYER_COLLISION_HALF_HEIGHT := 20.0
const DASH_CEILING_VISUAL_TOP_Y := 80.0
const ROOM_LEFT_X := -512.0
const ROOM_RIGHT_X := 1024.0
const ROOM_TOP_Y := -192.0
const ROOM_BOTTOM_Y := 192.0


func test_tutorial_template_layers_have_correct_collision_authority() -> void:
	var room := _instantiate_room()
	var layout := room.get_node_or_null("Phase2GrayboxLayout")
	var terrain := room.get_node_or_null(TERRAIN_LAYER_NAME) as TileMapLayer
	var platform := room.get_node_or_null(PLATFORM_LAYER_NAME) as TileMapLayer
	var thin_surface := room.get_node_or_null(THIN_PLATFORM_SURFACE_LAYER_NAME) as TileMapLayer
	var lintel_surface := room.get_node_or_null(DASH_GATE_LINTEL_LAYER_NAME) as TileMapLayer
	assert_not_null(layout)
	assert_not_null(terrain)
	assert_not_null(platform)
	assert_not_null(thin_surface)
	assert_not_null(lintel_surface)
	if layout == null or terrain == null or platform == null or thin_surface == null or lintel_surface == null:
		return

	assert_eq(int(layout.call("get_segment_count")), 4)
	assert_eq(layout.call("get_layout_profile"), &"tutorial_four_beats_safe_recovery")
	assert_eq(int(layout.call("get_runtime_platform_count")), 6)
	assert_false(terrain.visible, "旧 TileMap 碰撞层不得进入成品画面。")
	assert_false(bool(terrain.get("collision_enabled")))
	assert_eq(terrain.get_meta("asset_id", ""), "formal_terrain_kit_ai01")
	assert_eq(terrain.tile_set.resource_path, TILESET_PATH)

	assert_false(platform.visible, "旧薄平台 TileMap 不得形成幽灵台阶。")
	assert_false(bool(platform.get("collision_enabled")))

	assert_false(thin_surface.visible, "旧薄平台表面已由 Phase2 动态表面取代。")
	assert_false(bool(thin_surface.get("collision_enabled")), "薄平台可见层不能参与碰撞。")
	assert_eq(thin_surface.tile_set.resource_path, JUMP_PLATFORM_SURFACE_TILESET_PATH)
	assert_eq(thin_surface.get_meta("asset_id", ""), "tutorial_jump_platform_visual_ai02")
	assert_eq(thin_surface.get_meta("physics_affordance", ""), "one_way_platform")
	assert_eq(thin_surface.get_meta("asset_binding_note", ""), "one_way_jump_platform_visual_only_collision_kept_in_platform_layer")

	assert_true(lintel_surface.visible)
	assert_false(bool(lintel_surface.get("collision_enabled")), "门楣可见层不能参与碰撞。")
	assert_eq(lintel_surface.tile_set.resource_path, DASH_GATE_LINTEL_TILESET_PATH)
	assert_eq(lintel_surface.get_meta("asset_id", ""), "tutorial_dash_gate_lintel_visual_ai01")
	assert_eq(lintel_surface.get_meta("physics_affordance", ""), "thin_solid")

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

	var dash_ceiling := room.get_node_or_null("DashGateCeiling") as StaticBody2D
	var dash_ceiling_shape := room.get_node_or_null("DashGateCeiling/CollisionShape2D") as CollisionShape2D
	assert_not_null(dash_ceiling)
	assert_not_null(dash_ceiling_shape)
	if dash_ceiling != null:
		assert_eq(dash_ceiling.collision_layer, 1, "独立门楣仍承担低顶实体碰撞。")
	if dash_ceiling_shape != null:
		assert_false(dash_ceiling_shape.disabled)


func test_tutorial_grid_blueprint_has_continuous_ground_platform_caps_and_safe_exit() -> void:
	var room := _instantiate_room()
	var layout := room.get_node_or_null("Phase2GrayboxLayout")
	var lintel_surface := room.get_node_or_null(DASH_GATE_LINTEL_LAYER_NAME) as TileMapLayer
	var door := room.get_node_or_null(DOOR_LAYER_NAME) as TileMapLayer
	assert_not_null(layout)
	assert_not_null(lintel_surface)
	assert_not_null(door)
	if layout == null or lintel_surface == null or door == null:
		return

	var solid_rects: Array[Rect2] = layout.get("solid_rects")
	var one_way_rects: Array[Rect2] = layout.get("one_way_rects")
	assert_eq(solid_rects, [
		Rect2(-512, 144, 320, 64),
		Rect2(-192, 160, 128, 64),
		Rect2(-64, 160, 320, 64),
		Rect2(256, 160, 480, 64),
		Rect2(736, 160, 288, 64),
	])
	assert_eq(one_way_rects, [Rect2(-240, 80, 160, 16)])
	_assert_dash_gate_lintel_layer(lintel_surface)
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
	assert_eq(primary.get_meta("asset_binding_note", ""), "single_sprite_full_room_coverage_no_repeat_seam")
	var half_size := Vector2(primary.texture.get_width(), primary.texture.get_height()) * primary.scale * 0.5
	assert_true(primary.position.x - half_size.x <= ROOM_LEFT_X)
	assert_true(primary.position.x + half_size.x >= ROOM_RIGHT_X)
	assert_true(primary.position.y - half_size.y <= ROOM_TOP_Y)
	assert_true(primary.position.y + half_size.y >= ROOM_BOTTOM_Y)


# 运行态玩家碰撞脚底必须落在当前 Phase2 几何真源上。
func test_tutorial_spawn_feet_match_phase2_ground_top() -> void:
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
	var layout := main.get_node_or_null("Room/Phase2GrayboxLayout")
	assert_not_null(player)
	assert_not_null(layout)
	if player == null or layout == null:
		return
	var player_bottom := player.global_position.y + PLAYER_COLLISION_HALF_HEIGHT
	var support_top := INF
	var solid_rects: Array[Rect2] = layout.get("solid_rects")
	var one_way_rects: Array[Rect2] = layout.get("one_way_rects")
	for rect: Rect2 in solid_rects + one_way_rects:
		if player.global_position.x >= rect.position.x and player.global_position.x <= rect.end.x:
			if rect.position.y >= player.global_position.y:
				support_top = minf(support_top, rect.position.y)
	assert_false(is_inf(support_top), "出生点下方必须有 Phase2 支撑。")
	assert_almost_eq(player_bottom, support_top, 0.25, "Luna 脚底必须和当前碰撞顶面对齐。")


func _instantiate_room() -> Node2D:
	var packed := load(ROOM_PATH) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return null
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room


func _assert_door_layer(layer: TileMapLayer) -> void:
	assert_false(bool(layer.get("collision_enabled")), "门框视觉不参与碰撞。")
	assert_eq(layer.get_used_cells().size(), 0, "tutorial_room 不再铺孤立门框 / 小台座 tile。")


func _assert_dash_gate_lintel_layer(surface: TileMapLayer) -> void:
	assert_true(surface.visible)
	assert_false(bool(surface.get("collision_enabled")), "门楣可见层只负责读值，不参与碰撞。")
	assert_eq(surface.tile_set.resource_path, DASH_GATE_LINTEL_TILESET_PATH)
	assert_eq(surface.get_meta("asset_id", ""), "tutorial_dash_gate_lintel_visual_ai01")
	assert_eq(surface.get_meta("physics_affordance", ""), "thin_solid")
	assert_eq(surface.get_used_cells().size(), 2, "门楣可见层保留左右两块实体读值。")


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
