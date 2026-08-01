extends SceneTree

# Tutorial 房间级 terrain 模板运行态截图复核。
# ponytail: 只截第一关三个关键点；推广到其它房间时再抽通用复核器。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const OUT_DIR := "res://tests/artifacts/local/formal-terrain-kit/tutorial_room_template_review"
const OUT_START_IMAGE := "%s/tutorial_start_floor.png" % OUT_DIR
const OUT_PLATFORM_IMAGE := "%s/tutorial_jump_platform.png" % OUT_DIR
const OUT_GATE_IMAGE := "%s/tutorial_dash_gate_block.png" % OUT_DIR
const OUT_TRAINING_IMAGE := "%s/tutorial_training_exit.png" % OUT_DIR
const OUT_REPORT := "%s/tutorial_room_template_review.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(1280, 720)
const GROUND_UNDERLAY_NAME := "GroundUnderlayVisual"
const SURFACE_LAYER_NAME := "GroundSurfaceVisual"
const THIN_PLATFORM_SURFACE_LAYER_NAME := "ThinPlatformSurfaceVisual"
const TERRAIN_LAYER_NAME := "TerrainCollisionVisual"
const PLATFORM_LAYER_NAME := "PlatformCollisionVisual"
const LANDMARK_ROOT_NAME := "TutorialLandmarks"
const BACKGROUND_PRIMARY_NAME := "TutorialShrineBackgroundArt"
const BACKGROUND_REPEAT_NAME := "TutorialShrineBackgroundArtLeft"
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
const VISUAL_ONLY_LAYER_NAMES := [
	"DoorVisual",
	"BackgroundVisual",
	"DecorVisual",
	"ForegroundVisual",
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
const LOGIC_COLLISION_NODE_NAMES := [
	"ExitBarrier/CollisionShape2D",
	"ExitZone/CollisionShape2D",
	"TutorialDummy/CollisionShape2D",
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


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var result := await _capture()
	quit(result)


func _capture() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	root.size = VIEWPORT_SIZE

	var packed := load(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Cannot load Main scene: %s" % MAIN_SCENE_PATH)
		return 1

	var main := packed.instantiate() as Node2D
	root.add_child(main)
	await _wait_process_frames(4)
	if main.has_method("start_demo"):
		main.call("start_demo")
	await _wait_physics_frames(24)
	_hide_demo_shell(main)

	var room := main.get_node_or_null("Room") as Node2D
	var player := main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var terrain_layer := room.get_node_or_null(TERRAIN_LAYER_NAME) as TileMapLayer if room != null else null
	var platform_layer := room.get_node_or_null(PLATFORM_LAYER_NAME) as TileMapLayer if room != null else null
	var surface_layer := room.get_node_or_null(SURFACE_LAYER_NAME) as TileMapLayer if room != null else null
	var thin_surface_layer := room.get_node_or_null(THIN_PLATFORM_SURFACE_LAYER_NAME) as TileMapLayer if room != null else null
	var collision_authority_ok := (
		terrain_layer != null
		and platform_layer != null
		and not terrain_layer.visible
		and not platform_layer.visible
		and bool(terrain_layer.get("collision_enabled"))
		and bool(platform_layer.get("collision_enabled"))
	)
	var visual_only_layers_ok := room != null and _visual_only_layers_ok(room)
	var legacy_collision_disabled := room != null and _legacy_terrain_collision_disabled(room)
	var logic_collision_kept := room != null and _logic_collision_kept(room)
	var grid_blueprint_ok := terrain_layer != null and platform_layer != null and _grid_blueprint_ok(terrain_layer, platform_layer)
	var surface_visual_ok := surface_layer != null and thin_surface_layer != null and terrain_layer != null and _surface_visual_ok(surface_layer, thin_surface_layer, terrain_layer)
	var ground_underlay_retired := room != null and _ground_underlay_retired(room)
	var landmark_layout_ok := room != null and _landmark_layout_ok(room)
	var background_coverage_ok := room != null and _background_coverage_ok(room)
	var start_floor_ok := player != null and player.is_on_floor()
	var start_ground_alignment_ok := player != null and surface_layer != null and _player_matches_visible_ground(player, surface_layer)
	var start_save_ok := _save_screenshot(OUT_START_IMAGE)

	var platform_floor_ok := false
	var platform_save_ok := false
	if player != null:
		player.global_position = Vector2(-144.0, 40.0)
		await _wait_physics_frames(40)
		platform_floor_ok = player.is_on_floor() and player.global_position.y <= 60.0
		platform_save_ok = _save_screenshot(OUT_PLATFORM_IMAGE)

	var gate_blocks_without_dash := false
	var gate_save_ok := false
	if player != null:
		player.global_position = Vector2(84.0, 96.0)
		player.velocity = Vector2.ZERO
		await _wait_physics_frames(4)
		Input.action_press("move_right")
		await _wait_physics_frames(24)
		Input.action_release("move_right")
		gate_blocks_without_dash = player.global_position.x < 212.0
		gate_save_ok = _save_screenshot(OUT_GATE_IMAGE)

	var training_floor_ok := false
	var training_target_ok := false
	var training_save_ok := false
	if player != null and room != null:
		player.global_position = Vector2(432.0, 96.0)
		player.velocity = Vector2.ZERO
		await _wait_physics_frames(16)
		training_floor_ok = player.is_on_floor()
		var dummy := room.get_node_or_null("TutorialDummy") as StaticBody2D
		var dummy_art := room.get_node_or_null("TutorialDummy/DummyArt") as Sprite2D
		training_target_ok = (
			dummy != null
			and dummy_art != null
			and absf(dummy.position.y - GROUND_TOP_Y) <= 0.01
			and dummy_art.get_meta("terrain_landmark_role", "") == "training_attack_target"
		)
		training_save_ok = _save_screenshot(OUT_TRAINING_IMAGE)

	var ok := (
		room != null
		and player != null
		and collision_authority_ok
		and visual_only_layers_ok
		and legacy_collision_disabled
		and logic_collision_kept
		and grid_blueprint_ok
		and surface_visual_ok
		and ground_underlay_retired
		and landmark_layout_ok
		and background_coverage_ok
		and start_floor_ok
		and start_ground_alignment_ok
		and platform_floor_ok
		and gate_blocks_without_dash
		and training_floor_ok
		and training_target_ok
		and start_save_ok
		and platform_save_ok
		and gate_save_ok
		and training_save_ok
	)

	_write_json(OUT_REPORT, {
		"ok": ok,
		"review_id": "tutorial_room_terrain_template_review",
		"start_image": OUT_START_IMAGE,
		"platform_image": OUT_PLATFORM_IMAGE,
		"gate_image": OUT_GATE_IMAGE,
		"training_image": OUT_TRAINING_IMAGE,
		"terrain_layer_visible": terrain_layer != null and terrain_layer.visible,
		"terrain_layer_collision_enabled": terrain_layer != null and bool(terrain_layer.get("collision_enabled")),
		"platform_layer_visible": platform_layer != null and platform_layer.visible,
		"platform_layer_collision_enabled": platform_layer != null and bool(platform_layer.get("collision_enabled")),
		"visual_only_layers_ok": visual_only_layers_ok,
		"legacy_collision_disabled": legacy_collision_disabled,
		"logic_collision_kept": logic_collision_kept,
		"grid_blueprint_ok": grid_blueprint_ok,
		"surface_visual_ok": surface_visual_ok,
		"thin_platform_surface_visible": thin_surface_layer != null and thin_surface_layer.visible,
		"ground_underlay_retired": ground_underlay_retired,
		"landmark_layout_ok": landmark_layout_ok,
		"background_coverage_ok": background_coverage_ok,
		"start_floor_ok": start_floor_ok,
		"start_ground_alignment_ok": start_ground_alignment_ok,
		"platform_floor_ok": platform_floor_ok,
		"gate_blocks_without_dash": gate_blocks_without_dash,
		"training_floor_ok": training_floor_ok,
		"training_target_ok": training_target_ok,
		"display_server": DisplayServer.get_name(),
	})

	main.queue_free()
	return 0 if ok else 1


func _visual_only_layers_ok(room: Node) -> bool:
	for layer_name: String in VISUAL_ONLY_LAYER_NAMES:
		var layer := room.get_node_or_null(NodePath(layer_name)) as TileMapLayer
		if layer == null or not layer.visible or bool(layer.get("collision_enabled")):
			return false
	return true


func _legacy_terrain_collision_disabled(room: Node) -> bool:
	for body_name: String in LEGACY_TERRAIN_BODY_NAMES:
		var body := room.get_node_or_null(NodePath(body_name)) as StaticBody2D
		if body == null or body.collision_layer != 0 or body.collision_mask != 0:
			return false
		var shape := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape == null or not shape.disabled:
			return false
	return true


func _logic_collision_kept(room: Node) -> bool:
	for node_name: String in LOGIC_COLLISION_NODE_NAMES:
		var shape := room.get_node_or_null(NodePath(node_name)) as CollisionShape2D
		if shape == null or shape.disabled:
			return false
	return true


func _grid_blueprint_ok(terrain_layer: TileMapLayer, platform_layer: TileMapLayer) -> bool:
	for offset: int in range(MAIN_GROUND_LENGTH):
		var cell := Vector2i(MAIN_GROUND_START.x + offset, MAIN_GROUND_START.y)
		if terrain_layer.get_cell_source_id(cell) != 0:
			return false
		var atlas := terrain_layer.get_cell_atlas_coords(cell)
		if offset == 0 and atlas != Vector2i(2, 0):
			return false
		if offset == MAIN_GROUND_LENGTH - 1 and atlas != Vector2i(3, 0):
			return false
		if offset > 0 and offset < MAIN_GROUND_LENGTH - 1 and not [Vector2i(0, 0), Vector2i(1, 0)].has(atlas):
			return false
	for offset: int in range(JUMP_PLATFORM_LENGTH):
		var cell := Vector2i(JUMP_PLATFORM_START.x + offset, JUMP_PLATFORM_START.y)
		if platform_layer.get_cell_source_id(cell) != 0:
			return false
	for cell: Vector2i in EXIT_SAFE_CELLS:
		if terrain_layer.get_cell_source_id(cell) != 0:
			return false
	return true


func _surface_visual_ok(surface_layer: TileMapLayer, thin_surface_layer: TileMapLayer, terrain_layer: TileMapLayer) -> bool:
	if (
		not surface_layer.visible
		or bool(surface_layer.get("collision_enabled"))
		or surface_layer.position != GROUND_SURFACE_OFFSET
		or surface_layer.z_index <= terrain_layer.z_index
		or surface_layer.get_meta("asset_id", "") != "shrine_trial_tileset_ai01"
		or not thin_surface_layer.visible
		or bool(thin_surface_layer.get("collision_enabled"))
		or thin_surface_layer.z_index <= terrain_layer.z_index
		or thin_surface_layer.get_meta("asset_id", "") != "tutorial_thin_platform_visual_ai01"
	):
		return false
	for offset: int in range(MAIN_GROUND_LENGTH):
		var cell := Vector2i(MAIN_GROUND_START.x + offset, MAIN_GROUND_START.y)
		if surface_layer.get_cell_source_id(cell) != 0:
			return false
		var expected := Vector2i(1, 0)
		if offset == 0:
			expected = Vector2i(0, 0)
		elif offset == MAIN_GROUND_LENGTH - 1:
			expected = Vector2i(2, 0)
		if surface_layer.get_cell_atlas_coords(cell) != expected:
			return false
	for offset: int in range(JUMP_PLATFORM_LENGTH):
		var cell := Vector2i(JUMP_PLATFORM_START.x + offset, JUMP_PLATFORM_START.y)
		if surface_layer.get_cell_source_id(cell) != -1:
			return false
		if thin_surface_layer.get_cell_source_id(cell) != 0:
			return false
		var expected := Vector2i(1, 0)
		if offset == 0:
			expected = Vector2i(0, 0)
		elif offset == JUMP_PLATFORM_LENGTH - 1:
			expected = Vector2i(2, 0)
		if thin_surface_layer.get_cell_atlas_coords(cell) != expected:
			return false
	for offset: int in range(DASH_CEILING_LENGTH):
		var cell := Vector2i(DASH_CEILING_START.x + offset, DASH_CEILING_START.y)
		if surface_layer.get_cell_source_id(cell) != -1:
			return false
		var expected := Vector2i(0, 0) if offset == 0 else Vector2i(2, 0)
		if thin_surface_layer.get_cell_source_id(cell) != 0 or thin_surface_layer.get_cell_atlas_coords(cell) != expected:
			return false
	return true


# 玩家 40px 高碰撞盒的脚底必须与主地面中段的真实 alpha 顶边重合。
func _player_matches_visible_ground(player: CharacterBody2D, surface: TileMapLayer) -> bool:
	var center_cell := Vector2i(0, MAIN_GROUND_START.y)
	var center_global := surface.to_global(surface.map_to_local(center_cell))
	var visible_ground_top := center_global.y - 32.0 + GROUND_CENTER_ALPHA_TOP_Y
	var player_bottom := player.global_position.y + PLAYER_COLLISION_HALF_HEIGHT
	return absf(player_bottom - visible_ground_top) <= 0.25 and absf(visible_ground_top - GROUND_TOP_Y) <= 0.25


func _ground_underlay_retired(room: Node) -> bool:
	var underlay := room.get_node_or_null(NodePath(GROUND_UNDERLAY_NAME)) as Polygon2D
	return (
		underlay != null
		and not underlay.visible
		and underlay.get_meta("asset_binding_note", "") == "retired_grid_texture_replaced_by_ground_surface_visual"
	)


# 运行态确认三个视觉地标都落在地面顶面，且没有被误接成碰撞对象。
func _landmark_layout_ok(room: Node) -> bool:
	var landmarks := room.get_node_or_null(NodePath(LANDMARK_ROOT_NAME)) as Node2D
	if landmarks == null or not bool(landmarks.get_meta("visual_only", false)):
		return false
	var entry := landmarks.get_node_or_null("EntryStoneLantern") as Sprite2D
	var dash_marker := landmarks.get_node_or_null("DashGateSealShrine") as Sprite2D
	return (
		_visual_marker_bottom_matches(entry, GROUND_TOP_Y, "entry_orientation")
		and _visual_marker_bottom_matches(dash_marker, DASH_CEILING_VISUAL_TOP_Y, "dash_gate_marker")
	)


# 单张背景在运行态必须覆盖房间边界，并且旧重复贴图保持隐藏。
func _background_coverage_ok(room: Node) -> bool:
	var primary := room.get_node_or_null(NodePath(BACKGROUND_PRIMARY_NAME)) as Sprite2D
	var repeated := room.get_node_or_null(NodePath(BACKGROUND_REPEAT_NAME)) as Sprite2D
	if primary == null or repeated == null or not primary.visible or repeated.visible or primary.texture == null:
		return false
	var half_size := Vector2(primary.texture.get_width(), primary.texture.get_height()) * primary.scale * 0.5
	return (
		primary.get_meta("asset_binding_note", "") == "single_sprite_full_room_coverage_no_repeat_seam"
		and primary.position.x - half_size.x <= ROOM_LEFT_X
		and primary.position.x + half_size.x >= ROOM_RIGHT_X
		and primary.position.y - half_size.y <= ROOM_TOP_Y
		and primary.position.y + half_size.y >= ROOM_BOTTOM_Y
	)


# 地标只校验可见底边和语义；碰撞始终由既有地形或独立玩法节点负责。
func _visual_marker_bottom_matches(sprite: Sprite2D, support_y: float, role: String) -> bool:
	if sprite == null or not sprite.visible or sprite.texture == null:
		return false
	if bool(sprite.get_meta("gameplay_collision", true)) or sprite.get_meta("terrain_landmark_role", "") != role:
		return false
	var visual_bottom := sprite.global_position.y + float(sprite.texture.get_height()) * absf(sprite.global_scale.y) * 0.5
	return absf(visual_bottom - support_y) <= 0.75


func _hide_demo_shell(main: Node) -> void:
	var shell := main.get_node_or_null("HUD/DemoShell")
	if shell == null:
		return
	for path: NodePath in ["MainMenu", "TitleBackground"]:
		var item := shell.get_node_or_null(path) as CanvasItem
		if item != null:
			item.visible = false


func _wait_process_frames(count: int) -> void:
	for _i: int in range(count):
		await process_frame


func _wait_physics_frames(count: int) -> void:
	for _i: int in range(count):
		await physics_frame


func _save_screenshot(path: String) -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	var image := root.get_texture().get_image()
	return image != null and not image.is_empty() and image.save_png(path) == OK


func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE)
	if file == null:
		push_error("Cannot write report: %s" % path)
		return
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
