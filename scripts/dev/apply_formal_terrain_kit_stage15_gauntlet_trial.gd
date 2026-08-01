extends SceneTree

# Stage15 mixed gauntlet 正式 26x9 战斗场蓝图生成。
# ponytail: 单房间显式蓝图；三类样板稳定后再判断是否提取 helper。

const ROOM_PATH := "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"
const ROOM_SCRIPT_PATH := "res://scripts/rooms/stage15_mixed_gauntlet_room.gd"
const TERRAIN_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres"
const THIN_SURFACE_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/tutorial_thin_platform_visual_ai01.tileset.tres"

const TERRAIN_SCALE := Vector2(1.0 / 6.0, 1.0 / 6.0)
const PLATFORM_OFFSET := Vector2(0.0, -16.0)
const SURFACE_OFFSET := Vector2(0.0, -7.0)
const TERRAIN_LAYER_NAME := "TerrainCollisionVisual"
const PLATFORM_LAYER_NAME := "PlatformCollisionVisual"
const SURFACE_LAYER_NAME := "GroundSurfaceVisual"
const THIN_SURFACE_LAYER_NAME := "ThinPlatformSurfaceVisual"
const VISUAL_ONLY_TILE_LAYERS := ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]
const OLD_TILE_LAYERS := ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]
const LEGACY_TERRAIN_BODY_NAMES := ["LeftWall", "Floor"]

const FLOOR_START := Vector2i(-8, 3)
const FLOOR_LENGTH := 26
const BRANCH_PLATFORM_START := Vector2i(-7, 2)
const CHARGER_PLATFORM_START := Vector2i(5, 2)
const AERIAL_PLATFORM_START := Vector2i(11, 2)
const PLATFORM_LENGTH := 4

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
		push_error("Stage15 gauntlet formal blueprint resources are incomplete.")
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
	print("stage15 gauntlet formal room blueprint applied: %s" % ROOM_PATH)
	return 0


# 战斗场只保留连续地面和三段有明确用途的 one-way 平台。
func _apply_template(root: Node, terrain_tileset: TileSet, surface_tileset: TileSet, thin_surface_tileset: TileSet) -> void:
	_hide_old_visuals(root)
	_disable_legacy_terrain_collision(root)
	_configure_room_contract(root)
	_configure_room_nodes(root)
	_configure_background(root)

	var terrain := _ensure_layer(root, TERRAIN_LAYER_NAME, terrain_tileset, Vector2.ZERO, TERRAIN_SCALE, true, 1, "tilemap_collision_authority_static_terrain")
	var platform := _ensure_layer(root, PLATFORM_LAYER_NAME, terrain_tileset, PLATFORM_OFFSET, TERRAIN_SCALE, true, 2, "tilemap_one_way_collision_authority_combat_platform")
	var surface := _ensure_layer(root, SURFACE_LAYER_NAME, surface_tileset, SURFACE_OFFSET, Vector2.ONE, false, 2, "continuous_combat_floor_surface_aligned_to_collision")
	var thin_surface := _ensure_layer(root, THIN_SURFACE_LAYER_NAME, thin_surface_tileset, Vector2.ZERO, Vector2.ONE, false, 2, "thin_combat_platform_surface_aligned_to_one_way_collision")
	terrain.modulate = Color(1.0, 1.0, 1.0, 0.08)
	platform.modulate = Color(1.0, 1.0, 1.0, 0.08)

	_paint_solid_run(terrain, FLOOR_START, FLOOR_LENGTH)
	_paint_surface_run(surface, FLOOR_START, FLOOR_LENGTH)
	for start: Vector2i in [BRANCH_PLATFORM_START, CHARGER_PLATFORM_START, AERIAL_PLATFORM_START]:
		_paint_platform_run(platform, start, PLATFORM_LENGTH)
		_paint_surface_run(thin_surface, start, PLATFORM_LENGTH)

	for layer_name: String in VISUAL_ONLY_TILE_LAYERS:
		var layer := _ensure_layer(root, layer_name, terrain_tileset, Vector2.ZERO, TERRAIN_SCALE, false, -1, "formal_combat_room_visual_layer_kept_empty")
		layer.clear()


func _ensure_layer(root: Node, layer_name: String, tileset: TileSet, offset: Vector2, layer_scale: Vector2, collision_enabled: bool, z_index: int, note: String) -> TileMapLayer:
	var layer := root.get_node_or_null(NodePath(layer_name)) as TileMapLayer
	if layer == null:
		layer = TileMapLayer.new()
		layer.name = layer_name
		root.add_child(layer)
		layer.owner = root
	layer.visible = not collision_enabled
	layer.tile_set = tileset
	layer.position = offset
	layer.scale = layer_scale
	layer.z_index = z_index
	layer.set("collision_enabled", collision_enabled)
	layer.set_meta(&"terrain_template_layer", true)
	layer.set_meta(&"asset_binding_note", note)
	layer.clear()
	return layer


# 重打包时显式恢复流程字段，防止脚本替换剥掉场景导出值。
func _configure_room_contract(root: Node) -> void:
	root.set("challenge_branch_room_path", "res://scenes/rooms/stage15_challenge_branch_room.tscn")
	root.set("next_room_path", "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn")
	root.set("next_spawn_id", &"stage15_boss_start")
	root.set("checkpoint_spawn_id", &"stage15_mixed_gauntlet_return")
	root.set("default_step_id", &"stage15_mixed_gauntlet")
	root.set("cleared_step_id", &"stage15_mixed_gauntlet_clear")
	root.set("checkpoint_on_ready", true)
	root.set("require_all_enemies_defeated", true)
	root.set("spawn_positions", {
		&"stage15_mixed_gauntlet_start": Vector2(-384.0, 160.0),
		&"stage15_mixed_gauntlet_return": Vector2(-208.0, 160.0),
	})


func _configure_room_nodes(root: Node) -> void:
	var backdrop := root.get_node_or_null("Backdrop") as Polygon2D
	if backdrop != null:
		backdrop.z_index = -4
		backdrop.polygon = PackedVector2Array([
			Vector2(-512, -288), Vector2(1152, -288), Vector2(1152, 288), Vector2(-512, 288),
		])
	var branch := root.get_node_or_null("ChallengeBranchZone") as Area2D
	if branch != null:
		branch.position = Vector2(-352.0, 104.0)
		var branch_visual := branch.get_node_or_null("ChallengeVisual") as CanvasItem
		if branch_visual != null:
			branch_visual.visible = false
	var basic := root.get_node_or_null("BasicMeleeEnemy") as Node2D
	var charger := root.get_node_or_null("GroundChargerEnemy") as Node2D
	var aerial := root.get_node_or_null("AerialSentinelEnemy") as Node2D
	if basic != null:
		basic.position = Vector2(64.0, 216.0)
	if charger != null:
		charger.position = Vector2(448.0, 216.0)
	if aerial != null:
		aerial.position = Vector2(832.0, 104.0)
	var gate := root.get_node_or_null("GateBarrier") as StaticBody2D
	if gate != null:
		gate.position = Vector2(1024.0, 168.0)
		gate.z_index = 2
		var gate_art := gate.get_node_or_null("GateArt") as Sprite2D
		if gate_art != null:
			gate_art.scale = Vector2(0.72, 0.72)
	var exit_zone := root.get_node_or_null("ExitZone") as Area2D
	if exit_zone != null:
		exit_zone.position = Vector2(1104.0, 160.0)
		var zone_visual := exit_zone.get_node_or_null("ZoneVisual") as CanvasItem
		if zone_visual != null:
			zone_visual.visible = false


# 单张 Boss arena 背景覆盖 26x9 房间，避免旧 0.58 缩放留下硬边。
func _configure_background(root: Node) -> void:
	var background := root.get_node_or_null("GauntletBackgroundArt") as Sprite2D
	if background == null:
		return
	background.visible = true
	background.z_index = -3
	background.position = Vector2(320.0, 0.0)
	background.scale = Vector2(1.02, 1.02)
	background.modulate = Color(1.0, 1.0, 1.0, 0.52)
	background.set_meta(&"asset_binding_note", "single_sprite_full_combat_room_coverage_no_repeat_seam")


func _hide_old_visuals(root: Node) -> void:
	for layer_name: String in OLD_TILE_LAYERS:
		var layer := root.get_node_or_null(NodePath(layer_name)) as TileMapLayer
		if layer != null:
			layer.visible = false
			layer.set("collision_enabled", false)
			layer.set_meta(&"asset_binding_note", "hidden_after_stage15_gauntlet_formal_blueprint")
	for node_name: String in ["MaterialTextureArt"]:
		var item := root.get_node_or_null(NodePath(node_name)) as CanvasItem
		if item != null:
			item.visible = false


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
			if child is CanvasItem:
				(child as CanvasItem).visible = false


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
