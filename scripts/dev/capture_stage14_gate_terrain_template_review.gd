extends SceneTree

# Stage14 Air Dash gate 正式样板运行态复核。
# ponytail: 只验证本房间四个关键节拍，不抽取通用截图框架。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const STAGE14_GATE_ROOM_PATH := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const SPAWN_ID := &"stage14_air_dash_gate_start"
const OUT_DIR := "res://tests/artifacts/local/formal-terrain-kit/stage14_gate_template_review"
const OUT_LAYOUT_IMAGE := "%s/stage14_gate_01_locked_layout.png" % OUT_DIR
const OUT_FALLBACK_IMAGE := "%s/stage14_gate_02_normal_jump_fallback.png" % OUT_DIR
const OUT_DASH_LANDING_IMAGE := "%s/stage14_gate_03_air_dash_landing.png" % OUT_DIR
const OUT_GATE_IMAGE := "%s/stage14_gate_04_open_gate_safe_zone.png" % OUT_DIR
const OUT_REPORT := "%s/stage14_gate_template_review.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(1280, 720)

const TERRAIN_LAYER_NAME := "TerrainCollisionVisual"
const PLATFORM_LAYER_NAME := "PlatformCollisionVisual"
const SURFACE_LAYER_NAME := "GroundSurfaceVisual"
const THIN_SURFACE_LAYER_NAME := "ThinPlatformSurfaceVisual"
const CLIFF_MASS_PATH := "CliffMassVisual/RightCliffMass"
const VISUAL_ONLY_LAYER_NAMES := ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]
const OLD_LAYER_NAMES := [
	"FormalTerrainTilemapDecor",
	"FormalForegroundEdgeDecor",
	"FormalTerrainKitSemanticTrial",
]
const LEGACY_TERRAIN_BODY_NAMES := ["LeftWall", "Floor"]
const LOGIC_COLLISION_NODE_NAMES := [
	"GateBarrier/CollisionShape2D",
	"ExitZone/CollisionShape2D",
	"LeftExitZone/CollisionShape2D",
]

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
const PLAYER_COLLISION_HALF_HEIGHT := 20.0
const LOWER_FLOOR_TOP_Y := 224.0
const LAUNCH_PLATFORM_TOP_Y := 80.0
const RIGHT_LEDGE_TOP_Y := 96.0
const GROUND_CENTER_ALPHA_TOP_Y := 39.0


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
	_hide_demo_shell(main)

	var locked_started := await _start_room(main, false)
	var room := main.get_node_or_null("Room") as Node2D
	var player := main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var terrain := room.get_node_or_null(TERRAIN_LAYER_NAME) as TileMapLayer if room != null else null
	var platform := room.get_node_or_null(PLATFORM_LAYER_NAME) as TileMapLayer if room != null else null
	var surface := room.get_node_or_null(SURFACE_LAYER_NAME) as TileMapLayer if room != null else null
	var thin_surface := room.get_node_or_null(THIN_SURFACE_LAYER_NAME) as TileMapLayer if room != null else null

	var layer_authority_ok := _layer_authority_ok(terrain, platform, surface, thin_surface)
	var visual_only_ok := room != null and _visual_only_layers_ok(room)
	var old_layers_ok := room != null and _old_layers_hidden_without_collision(room)
	var legacy_collision_disabled := room != null and _legacy_terrain_collision_disabled(room)
	var logic_collision_kept := room != null and _logic_collision_kept(room)
	var blueprint_ok := room != null and _blueprint_ok(room, terrain, platform, surface, thin_surface)
	var background_coverage_ok := room != null and _background_coverage_ok(room)
	var entrance_safe := locked_started and player != null and player.is_on_floor() and player.global_position.x > -432.0
	var entrance_ground_alignment_ok := player != null and surface != null and _player_matches_surface(player, surface, Vector2i(-6, 3), LOWER_FLOOR_TOP_Y)
	await _wait_process_frames(8)
	var layout_save_ok := _save_screenshot(OUT_LAYOUT_IMAGE)

	var launch_ready := player != null and await _place_player_on_launch(player)
	var normal_result := await _attempt_gap_crossing(player, false) if launch_ready else {}
	var fallback_safe := (
		launch_ready
		and not bool(normal_result.get("crossed_upper", false))
		and player.is_on_floor()
		and player.global_position.x < 416.0
		and _player_bottom(player) > 160.0
	)
	await _wait_process_frames(8)
	var fallback_save_ok := _save_screenshot(OUT_FALLBACK_IMAGE)

	var unlocked_started := await _start_room(main, true)
	room = main.get_node_or_null("Room") as Node2D
	player = main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	surface = room.get_node_or_null(SURFACE_LAYER_NAME) as TileMapLayer if room != null else null
	var dash_launch_ready := player != null and await _place_player_on_launch(player)
	var dash_result := await _attempt_gap_crossing(player, true) if dash_launch_ready else {}
	var gate_unlocked := room != null and bool(room.call("is_air_dash_gate_unlocked"))
	var dash_landing_safe := (
		dash_launch_ready
		and bool(dash_result.get("dash_started", false))
		and bool(dash_result.get("crossed_upper", false))
		and player.is_on_floor()
		and player.global_position.x > 428.0
		and player.global_position.x < 640.0
		and _player_bottom(player) <= RIGHT_LEDGE_TOP_Y + 0.5
	)
	var dash_ground_alignment_ok := player != null and surface != null and _player_matches_surface(player, surface, Vector2i(8, 1), RIGHT_LEDGE_TOP_Y)
	await _wait_process_frames(8)
	var dash_landing_save_ok := _save_screenshot(OUT_DASH_LANDING_IMAGE)

	var gate_approach_result := await _walk_to_gate_review(player) if dash_landing_safe else {}
	var gate_safe_zone_ok := (
		bool(gate_approach_result.get("reached", false))
		and player.is_on_floor()
		and player.global_position.x >= 720.0
		and player.global_position.x < 840.0
		and absf(_player_bottom(player) - RIGHT_LEDGE_TOP_Y) <= 0.5
	)
	await _wait_process_frames(8)
	var gate_save_ok := _save_screenshot(OUT_GATE_IMAGE)

	var ok := (
		locked_started
		and unlocked_started
		and layer_authority_ok
		and visual_only_ok
		and old_layers_ok
		and legacy_collision_disabled
		and logic_collision_kept
		and blueprint_ok
		and background_coverage_ok
		and entrance_safe
		and entrance_ground_alignment_ok
		and fallback_safe
		and gate_unlocked
		and dash_landing_safe
		and dash_ground_alignment_ok
		and gate_safe_zone_ok
		and layout_save_ok
		and fallback_save_ok
		and dash_landing_save_ok
		and gate_save_ok
	)

	_write_json(OUT_REPORT, {
		"ok": ok,
		"review_id": "stage14_gate_formal_room_review",
		"layout_image": OUT_LAYOUT_IMAGE,
		"fallback_image": OUT_FALLBACK_IMAGE,
		"dash_landing_image": OUT_DASH_LANDING_IMAGE,
		"gate_image": OUT_GATE_IMAGE,
		"layer_authority_ok": layer_authority_ok,
		"visual_only_layers_ok": visual_only_ok,
		"old_layers_hidden_without_collision": old_layers_ok,
		"legacy_collision_disabled": legacy_collision_disabled,
		"logic_collision_kept": logic_collision_kept,
		"blueprint_ok": blueprint_ok,
		"background_coverage_ok": background_coverage_ok,
		"entrance_safe": entrance_safe,
		"entrance_ground_alignment_ok": entrance_ground_alignment_ok,
		"normal_jump_fallback_safe": fallback_safe,
		"normal_jump_result": normal_result,
		"air_dash_gate_unlocked": gate_unlocked,
		"air_dash_landing_safe": dash_landing_safe,
		"air_dash_ground_alignment_ok": dash_ground_alignment_ok,
		"air_dash_result": dash_result,
		"gate_safe_zone_ok": gate_safe_zone_ok,
		"gate_approach_result": gate_approach_result,
		"display_server": DisplayServer.get_name(),
	})

	_release_movement_inputs()
	main.queue_free()
	return 0 if ok else 1


func _start_room(main: Node, air_dash_unlocked: bool) -> bool:
	if not main.has_method("start_demo_at_room"):
		return false
	var progress := {"air_dash_unlocked": air_dash_unlocked}
	var started := bool(main.call("start_demo_at_room", STAGE14_GATE_ROOM_PATH, SPAWN_ID, progress))
	await _wait_process_frames(6)
	await _wait_physics_frames(50)
	_hide_demo_shell(main)
	return started


# 把 Luna 放到最后一段起跳台，等待真实 one-way platform 接住角色。
func _place_player_on_launch(player: CharacterBody2D) -> bool:
	_release_movement_inputs()
	player.global_position = Vector2(136.0, -32.0)
	player.velocity = Vector2.ZERO
	await _wait_until_settled(player, 90)
	return player.is_on_floor() and absf(_player_bottom(player) - LAUNCH_PLATFORM_TOP_Y) <= 0.5


# 普通跳和 Air Dash 使用同一条输入路线；成功路线在首次安全落地时立即停下。
func _attempt_gap_crossing(player: CharacterBody2D, use_air_dash: bool) -> Dictionary:
	var min_y := player.global_position.y
	var max_x := player.global_position.x
	var dash_started := false
	var crossed_upper := false
	Input.action_press("move_right")
	Input.action_press("jump")
	for _i: int in range(44):
		await _wait_physics_frames(1)
		min_y = minf(min_y, player.global_position.y)
		max_x = maxf(max_x, player.global_position.x)
	Input.action_release("jump")
	if use_air_dash:
		Input.action_press("dash")
		await _wait_physics_frames(2)
		dash_started = player.call("get_current_state_id") == &"dash"
		Input.action_release("dash")
	for _i: int in range(100):
		await _wait_physics_frames(1)
		min_y = minf(min_y, player.global_position.y)
		max_x = maxf(max_x, player.global_position.x)
		if use_air_dash and player.is_on_floor() and player.global_position.x > 428.0 and _player_bottom(player) <= RIGHT_LEDGE_TOP_Y + 0.5:
			crossed_upper = true
			break
	Input.action_release("move_right")
	await _wait_until_settled(player, 90)
	return {
		"dash_started": dash_started,
		"crossed_upper": crossed_upper,
		"min_y": min_y,
		"max_x": max_x,
		"final_x": player.global_position.x,
		"final_y": player.global_position.y,
		"final_bottom": _player_bottom(player),
	}


# 开门后只走到门后安全区，不触发右侧出口，截图同时保留门前与门后地面。
func _walk_to_gate_review(player: CharacterBody2D) -> Dictionary:
	Input.action_press("move_right")
	var reached := false
	for _i: int in range(120):
		await _wait_physics_frames(1)
		if player.global_position.x >= 760.0:
			reached = true
			break
	Input.action_release("move_right")
	await _wait_until_settled(player, 60)
	return {
		"reached": reached,
		"final_x": player.global_position.x,
		"final_y": player.global_position.y,
		"final_bottom": _player_bottom(player),
	}


func _layer_authority_ok(terrain: TileMapLayer, platform: TileMapLayer, surface: TileMapLayer, thin_surface: TileMapLayer) -> bool:
	return (
		terrain != null
		and platform != null
		and surface != null
		and thin_surface != null
		and terrain.visible
		and platform.visible
		and bool(terrain.get("collision_enabled"))
		and bool(platform.get("collision_enabled"))
		and surface.visible
		and thin_surface.visible
		and not bool(surface.get("collision_enabled"))
		and not bool(thin_surface.get("collision_enabled"))
	)


func _visual_only_layers_ok(room: Node) -> bool:
	for layer_name: String in VISUAL_ONLY_LAYER_NAMES:
		var layer := room.get_node_or_null(NodePath(layer_name)) as TileMapLayer
		if layer == null or not layer.visible or bool(layer.get("collision_enabled")) or not layer.get_used_cells().is_empty():
			return false
	return true


func _old_layers_hidden_without_collision(room: Node) -> bool:
	for layer_name: String in OLD_LAYER_NAMES:
		var layer := room.get_node_or_null(NodePath(layer_name)) as TileMapLayer
		if layer == null or layer.visible or bool(layer.get("collision_enabled")):
			return false
	return true


func _legacy_terrain_collision_disabled(room: Node) -> bool:
	for body_name: String in LEGACY_TERRAIN_BODY_NAMES:
		var body := room.get_node_or_null(NodePath(body_name)) as StaticBody2D
		var shape := body.get_node_or_null("CollisionShape2D") as CollisionShape2D if body != null else null
		if body == null or shape == null or body.collision_layer != 0 or body.collision_mask != 0 or not shape.disabled:
			return false
	return true


func _logic_collision_kept(room: Node) -> bool:
	for node_name: String in LOGIC_COLLISION_NODE_NAMES:
		var shape := room.get_node_or_null(NodePath(node_name)) as CollisionShape2D
		if shape == null:
			return false
	return true


func _blueprint_ok(room: Node2D, terrain: TileMapLayer, platform: TileMapLayer, surface: TileMapLayer, thin_surface: TileMapLayer) -> bool:
	if terrain == null or platform == null or surface == null or thin_surface == null:
		return false
	if terrain.get_used_cells().size() != LOWER_FLOOR_LENGTH + RIGHT_CLIFF_WIDTH * RIGHT_CLIFF_HEIGHT:
		return false
	if platform.get_used_cells().size() != STEP_PLATFORM_LENGTH + LAUNCH_PLATFORM_LENGTH:
		return false
	if surface.get_used_cells().size() != LOWER_FLOOR_LENGTH + RIGHT_LEDGE_LENGTH:
		return false
	if thin_surface.get_used_cells().size() != STEP_PLATFORM_LENGTH + LAUNCH_PLATFORM_LENGTH:
		return false
	for offset: int in range(LOWER_FLOOR_LENGTH):
		if terrain.get_cell_source_id(Vector2i(LOWER_FLOOR_START.x + offset, LOWER_FLOOR_START.y)) != 0:
			return false
	for y_offset: int in range(RIGHT_CLIFF_HEIGHT):
		for x_offset: int in range(RIGHT_CLIFF_WIDTH):
			if terrain.get_cell_source_id(Vector2i(RIGHT_CLIFF_START.x + x_offset, RIGHT_CLIFF_START.y + y_offset)) != 0:
				return false
	var mass := room.get_node_or_null(CLIFF_MASS_PATH) as Polygon2D
	return mass != null and mass.polygon == PackedVector2Array([
		Vector2(416, 96), Vector2(1024, 96), Vector2(1024, 288), Vector2(416, 288),
	])


func _background_coverage_ok(room: Node2D) -> bool:
	var background := room.get_node_or_null("ShrineGateBackgroundArt") as Sprite2D
	if background == null or not background.visible or background.texture == null:
		return false
	var limits: Rect2i = room.call("get_camera_limits")
	var half_size := Vector2(background.texture.get_width(), background.texture.get_height()) * background.scale * 0.5
	return (
		background.position == Vector2(256.0, 0.0)
		and background.position.x - half_size.x <= limits.position.x
		and background.position.x + half_size.x >= limits.end.x
		and background.position.y - half_size.y <= limits.position.y
		and background.position.y + half_size.y >= limits.end.y
	)


# 玩家 40px 碰撞盒脚底与 shrine surface 的真实 alpha 顶边必须共线。
func _player_matches_surface(player: CharacterBody2D, surface: TileMapLayer, cell: Vector2i, expected_top: float) -> bool:
	var center_global := surface.to_global(surface.map_to_local(cell))
	var visible_top := center_global.y - 32.0 + GROUND_CENTER_ALPHA_TOP_Y
	return absf(_player_bottom(player) - visible_top) <= 0.5 and absf(visible_top - expected_top) <= 0.5


func _player_bottom(player: CharacterBody2D) -> float:
	return player.global_position.y + PLAYER_COLLISION_HALF_HEIGHT


func _wait_until_settled(player: CharacterBody2D, max_frames: int) -> void:
	await _wait_physics_frames(2)
	for _i: int in range(max_frames):
		if player.is_on_floor() and absf(player.velocity.x) <= 0.1 and absf(player.velocity.y) <= 0.1:
			await _wait_physics_frames(2)
			return
		await _wait_physics_frames(1)


func _hide_demo_shell(main: Node) -> void:
	var shell := main.get_node_or_null("HUD/DemoShell")
	if shell == null:
		return
	for path: NodePath in ["MainMenu", "TitleBackground"]:
		var item := shell.get_node_or_null(path) as CanvasItem
		if item != null:
			item.visible = false


func _release_movement_inputs() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("dash")


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
