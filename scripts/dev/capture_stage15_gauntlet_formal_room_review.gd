extends SceneTree

# Stage15 mixed gauntlet 正式战斗场运行态复核。
# ponytail: 四个固定视角覆盖三敌空间与清场门控，不建设通用战斗截图框架。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const ROOM_PATH := "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"
const SPAWN_ID := &"stage15_mixed_gauntlet_start"
const OUT_DIR := "res://tests/artifacts/local/formal-terrain-kit/stage15_gauntlet_formal_review"
const OUT_ENTRY := "%s/stage15_gauntlet_01_entry_branch.png" % OUT_DIR
const OUT_CHARGER := "%s/stage15_gauntlet_02_charger_lane.png" % OUT_DIR
const OUT_AERIAL := "%s/stage15_gauntlet_03_aerial_layer.png" % OUT_DIR
const OUT_GATE := "%s/stage15_gauntlet_04_cleared_gate.png" % OUT_DIR
const OUT_REPORT := "%s/stage15_gauntlet_formal_review.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(1280, 720)

const TERRAIN_LAYER_NAME := "TerrainCollisionVisual"
const PLATFORM_LAYER_NAME := "PlatformCollisionVisual"
const SURFACE_LAYER_NAME := "GroundSurfaceVisual"
const THIN_SURFACE_LAYER_NAME := "ThinPlatformSurfaceVisual"
const VISUAL_ONLY_LAYER_NAMES := ["DoorVisual", "BackgroundVisual", "DecorVisual", "ForegroundVisual"]
const OLD_TILE_LAYERS := ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]
const FLOOR_START := Vector2i(-8, 3)
const FLOOR_LENGTH := 26
const PLATFORM_STARTS := [Vector2i(-7, 2), Vector2i(5, 2), Vector2i(11, 2)]
const PLATFORM_LENGTH := 4
const PLAYER_HALF_HEIGHT := 20.0
const FLOOR_TOP_Y := 224.0
const PLATFORM_TOP_Y := 144.0
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
	var started := await _start_room(main)
	var room := main.get_node_or_null("Room") as Node2D
	var player := main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	if not started or room == null or player == null:
		main.queue_free()
		return 1

	var terrain := room.get_node_or_null(TERRAIN_LAYER_NAME) as TileMapLayer
	var platform := room.get_node_or_null(PLATFORM_LAYER_NAME) as TileMapLayer
	var surface := room.get_node_or_null(SURFACE_LAYER_NAME) as TileMapLayer
	var thin_surface := room.get_node_or_null(THIN_SURFACE_LAYER_NAME) as TileMapLayer
	var layer_contract_ok := _layer_contract_ok(terrain, platform, surface, thin_surface)
	var blueprint_ok := _blueprint_ok(terrain, platform, surface, thin_surface)
	var legacy_retired_ok := _legacy_retired_ok(room)
	var background_ok := _background_ok(room)
	var flow_ok := _flow_ok(room)
	var entrance_safe := player.is_on_floor() and player.global_position.x > -432.0
	var entrance_ground_alignment_ok := _player_matches_surface(player, surface, Vector2i(-6, 3), FLOOR_TOP_Y)
	var branch_not_auto_triggered := main.get_node_or_null("Room") == room
	await _wait_process_frames(8)
	var entry_save_ok := _save_screenshot(OUT_ENTRY)

	player.global_position = Vector2(448.0, 80.0)
	player.velocity = Vector2.ZERO
	await _wait_until_settled(player, 90)
	var charger := room.get_node_or_null("GroundChargerEnemy")
	await _wait_physics_frames(20)
	var charger_upper_safe := player.is_on_floor() and absf(_player_bottom(player) - PLATFORM_TOP_Y) <= 0.5 and charger != null and not bool(charger.call("is_charge_active"))
	player.global_position = Vector2(520.0, 160.0)
	player.velocity = Vector2.ZERO
	await _wait_until_settled(player, 90)
	await _wait_physics_frames(6)
	var charger_floor_pressure := charger != null and bool(charger.call("is_charge_active"))
	await _wait_process_frames(8)
	var charger_save_ok := _save_screenshot(OUT_CHARGER)

	player.global_position = Vector2(760.0, 80.0)
	player.velocity = Vector2.ZERO
	await _wait_until_settled(player, 90)
	var aerial := room.get_node_or_null("AerialSentinelEnemy") as Node2D
	var aerial_layer_ok := (
		player.is_on_floor()
		and absf(_player_bottom(player) - PLATFORM_TOP_Y) <= 0.5
		and aerial != null
		and aerial.position.x > 800.0
		and aerial.position.y < PLATFORM_TOP_Y
	)
	await _wait_process_frames(8)
	var aerial_save_ok := _save_screenshot(OUT_AERIAL)

	for enemy_name: String in ["BasicMeleeEnemy", "GroundChargerEnemy", "AerialSentinelEnemy"]:
		var enemy := room.get_node_or_null(enemy_name)
		if enemy != null and enemy.has_method("receive_attack"):
			enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _wait_process_frames(6)
	var gate_unlocked := bool(room.call("is_gate_unlocked")) and int(room.call("get_remaining_required_enemy_count")) == 0
	player.global_position = Vector2(960.0, 160.0)
	player.velocity = Vector2.ZERO
	await _wait_until_settled(player, 90)
	var gate_safe_zone_ok := player.is_on_floor() and absf(_player_bottom(player) - FLOOR_TOP_Y) <= 0.5 and player.global_position.x < 988.0
	await _wait_process_frames(8)
	var gate_save_ok := _save_screenshot(OUT_GATE)

	var ok := (
		layer_contract_ok
		and blueprint_ok
		and legacy_retired_ok
		and background_ok
		and flow_ok
		and entrance_safe
		and entrance_ground_alignment_ok
		and branch_not_auto_triggered
		and charger_upper_safe
		and charger_floor_pressure
		and aerial_layer_ok
		and gate_unlocked
		and gate_safe_zone_ok
		and entry_save_ok
		and charger_save_ok
		and aerial_save_ok
		and gate_save_ok
	)
	_write_json(OUT_REPORT, {
		"ok": ok,
		"review_id": "stage15_gauntlet_formal_room_review",
		"entry_image": OUT_ENTRY,
		"charger_image": OUT_CHARGER,
		"aerial_image": OUT_AERIAL,
		"gate_image": OUT_GATE,
		"layer_contract_ok": layer_contract_ok,
		"blueprint_ok": blueprint_ok,
		"legacy_retired_ok": legacy_retired_ok,
		"background_ok": background_ok,
		"flow_ok": flow_ok,
		"entrance_safe": entrance_safe,
		"entrance_ground_alignment_ok": entrance_ground_alignment_ok,
		"branch_not_auto_triggered": branch_not_auto_triggered,
		"charger_upper_safe": charger_upper_safe,
		"charger_floor_pressure": charger_floor_pressure,
		"aerial_layer_ok": aerial_layer_ok,
		"gate_unlocked_after_three_enemy_clear": gate_unlocked,
		"gate_safe_zone_ok": gate_safe_zone_ok,
		"display_server": DisplayServer.get_name(),
	})
	main.queue_free()
	return 0 if ok else 1


func _start_room(main: Node) -> bool:
	if not main.has_method("start_demo_at_room"):
		return false
	var progress := {"air_dash_unlocked": true, "stage14_backtrack_reward_count": 3}
	var started := bool(main.call("start_demo_at_room", ROOM_PATH, SPAWN_ID, progress))
	await _wait_process_frames(6)
	await _wait_physics_frames(50)
	_hide_demo_shell(main)
	return started


func _layer_contract_ok(terrain: TileMapLayer, platform: TileMapLayer, surface: TileMapLayer, thin_surface: TileMapLayer) -> bool:
	if terrain == null or platform == null or surface == null or thin_surface == null:
		return false
	if not bool(terrain.get("collision_enabled")) or not bool(platform.get("collision_enabled")):
		return false
	if bool(surface.get("collision_enabled")) or bool(thin_surface.get("collision_enabled")):
		return false
	var room := terrain.get_parent()
	for layer_name: String in VISUAL_ONLY_LAYER_NAMES:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		if layer == null or bool(layer.get("collision_enabled")) or not layer.get_used_cells().is_empty():
			return false
	return true


func _blueprint_ok(terrain: TileMapLayer, platform: TileMapLayer, surface: TileMapLayer, thin_surface: TileMapLayer) -> bool:
	if terrain == null or platform == null or surface == null or thin_surface == null:
		return false
	if terrain.get_used_cells().size() != FLOOR_LENGTH or surface.get_used_cells().size() != FLOOR_LENGTH:
		return false
	if platform.get_used_cells().size() != PLATFORM_LENGTH * 3 or thin_surface.get_used_cells().size() != PLATFORM_LENGTH * 3:
		return false
	for offset: int in range(FLOOR_LENGTH):
		if terrain.get_cell_source_id(Vector2i(FLOOR_START.x + offset, FLOOR_START.y)) != 0:
			return false
	for start: Vector2i in PLATFORM_STARTS:
		for offset: int in range(PLATFORM_LENGTH):
			if platform.get_cell_source_id(Vector2i(start.x + offset, start.y)) != 0:
				return false
	return true


func _legacy_retired_ok(room: Node2D) -> bool:
	for body_name: String in ["LeftWall", "Floor"]:
		var body := room.get_node_or_null(body_name) as StaticBody2D
		var shape := body.get_node_or_null("CollisionShape2D") as CollisionShape2D if body != null else null
		if body == null or shape == null or body.collision_layer != 0 or body.collision_mask != 0 or not shape.disabled:
			return false
	for layer_name: String in OLD_TILE_LAYERS:
		var layer := room.get_node_or_null(layer_name) as TileMapLayer
		if layer == null or layer.visible or bool(layer.get("collision_enabled")):
			return false
	return true


func _background_ok(room: Node2D) -> bool:
	var background := room.get_node_or_null("GauntletBackgroundArt") as Sprite2D
	if background == null or background.texture == null or not background.visible:
		return false
	var limits: Rect2i = room.call("get_camera_limits")
	var half_size := Vector2(background.texture.get_width(), background.texture.get_height()) * background.scale * 0.5
	return background.position.x - half_size.x <= limits.position.x and background.position.x + half_size.x >= limits.end.x


func _flow_ok(room: Node2D) -> bool:
	return (
		room.get("challenge_branch_room_path") == "res://scenes/rooms/stage15_challenge_branch_room.tscn"
		and room.get("next_room_path") == "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn"
		and bool(room.get("require_all_enemies_defeated"))
		and int(room.call("get_remaining_required_enemy_count")) == 3
		and room.get_node_or_null("ChallengeBranchZone/ChallengeMarkerArt") != null
		and room.get_node_or_null("GateBarrier/GateArt") != null
	)


func _player_matches_surface(player: CharacterBody2D, surface: TileMapLayer, cell: Vector2i, expected_top: float) -> bool:
	var center_global := surface.to_global(surface.map_to_local(cell))
	var visible_top := center_global.y - 32.0 + GROUND_CENTER_ALPHA_TOP_Y
	return absf(_player_bottom(player) - visible_top) <= 0.5 and absf(visible_top - expected_top) <= 0.5


func _player_bottom(player: CharacterBody2D) -> float:
	return player.global_position.y + PLAYER_HALF_HEIGHT


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
