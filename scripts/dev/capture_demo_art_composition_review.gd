extends SceneTree

# DAC 运行态截图审计：用 Main 的真实 HUD / 相机 / 切房路径捕获 Alpha Demo 关键房间。
# 这里只收集证据和明显结构问题，最终发布级美术签核仍要人工看截图确认。

const OUT_DIR := "res://tests/artifacts/local/full-content-demo-qa/dac03_all_content_visual_gate"
const SCREENSHOT_DIR := "%s/screenshots" % OUT_DIR
const OUT_JSON := "%s/demo_art_composition_review.json" % OUT_DIR
const OUT_MD := "%s/demo_art_composition_review.md" % OUT_DIR
const MAIN_SCENE := "res://scenes/main/main.tscn"
const VIEWPORT_SIZE := Vector2i(1280, 720)
const HUD_BLOCKER_MIN_AREA := 180000.0
const MAX_TRIGGER_VISUAL_ALPHA := 0.12
const MAX_PROP_PLACEHOLDER_ALPHA := 0.18
const MAX_GAMEPLAY_WARNING_ALPHA := 0.16
const MAX_GAMEPLAY_VFX_WARNING_ALPHA := 0.8
const MAX_GAMEPLAY_VFX_WARNING_SCALE := Vector2(0.86, 0.52)
const MAX_TEXTURED_UNDERLAY_ALPHA := 0.16
const CAPTURE_SETTLE_PROCESS_FRAMES := 4
const CAPTURE_SETTLE_PHYSICS_FRAMES := 90
const TRIGGER_VISUAL_NAMES := {
	"ZoneVisual": true,
	"GoalVisual": true,
	"ResourceVisual": true,
	"ChallengeVisual": true,
	"BranchVisual": true,
	"ReplayVisual": true,
	"ContinueVisual": true,
}
const PROP_PLACEHOLDER_NAMES := {
	"TalismanRelayA": true,
	"TalismanRelayB": true,
	"TalismanRelayC": true,
	"SealReleaseNode": true,
	"BacktrackConfirmationNode": true,
	"CompletionSeal": true,
	"AlphaDemoSeal": true,
	"CorruptionPurgeNode": true,
}
const SOURCE_SHEET_ASSET_IDS := {
	"reusable_seal_props_ai01": true,
}
const FORMAL_SURFACE_TILEMAP_NAMES := {
	"GroundSurfaceVisual": true,
	"ThinPlatformSurfaceVisual": true,
	"FormalTerrainTilemapDecor": true,
}
const FORMAL_FOREGROUND_TILEMAP_NAMES := {
	"ForegroundVisual": true,
	"FormalForegroundEdgeDecor": true,
}

const ROOM_SPECS := [
	{"id": "test_room", "path": "res://scenes/rooms/test_room.tscn"},
	{"id": "tutorial_room", "path": "res://scenes/rooms/tutorial_room.tscn"},
	{"id": "combat_trial", "path": "res://scenes/rooms/combat_trial_room.tscn"},
	{"id": "goal_trial", "path": "res://scenes/rooms/goal_trial_room.tscn"},
	{"id": "stage9_entry", "path": "res://scenes/rooms/stage9_zone_entry_room.tscn"},
	{"id": "stage9_combat", "path": "res://scenes/rooms/stage9_zone_combat_room.tscn"},
	{"id": "stage9_charger", "path": "res://scenes/rooms/stage9_zone_charger_room.tscn"},
	{"id": "stage9_switch", "path": "res://scenes/rooms/stage9_zone_switch_room.tscn"},
	{"id": "stage9_final", "path": "res://scenes/rooms/stage9_zone_final_room.tscn"},
	{"id": "stage10_aerial", "path": "res://scenes/rooms/stage10_zone_aerial_room.tscn"},
	{"id": "stage10_branch", "path": "res://scenes/rooms/stage10_zone_branch_room.tscn"},
	{"id": "stage10_challenge", "path": "res://scenes/rooms/stage10_zone_challenge_room.tscn"},
	{"id": "stage11_end", "path": "res://scenes/rooms/stage11_demo_end_room.tscn"},
	{"id": "stage13_entry", "path": "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"},
	{"id": "stage13_caster", "path": "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"},
	{"id": "stage13_miasma", "path": "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"},
	{"id": "stage13_pressure", "path": "res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn"},
	{"id": "stage13_crossfire", "path": "res://scenes/rooms/stage13_miasma_marsh_crossfire_room.tscn"},
	{"id": "stage13_gate", "path": "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"},
	{"id": "stage13_branch_hub", "path": "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"},
	{"id": "stage13_resource_branch", "path": "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"},
	{"id": "stage13_challenge_branch", "path": "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn"},
	{"id": "stage13_return", "path": "res://scenes/rooms/stage13_miasma_marsh_return_room.tscn"},
	{"id": "stage13_checkpoint", "path": "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"},
	{"id": "stage13_goal", "path": "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"},
	{"id": "stage14_shrine", "path": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn"},
	{"id": "stage14_gate", "path": "res://scenes/rooms/stage14_air_dash_gate_room.tscn"},
	{"id": "stage14_backtrack_hub", "path": "res://scenes/rooms/stage14_backtrack_hub_room.tscn"},
	{"id": "stage14_loop_return", "path": "res://scenes/rooms/stage14_loop_return_room.tscn"},
	{"id": "stage15_pressure", "path": "res://scenes/rooms/stage15_seal_pressure_room.tscn"},
	{"id": "stage15_gauntlet", "path": "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"},
	{"id": "stage15_challenge_branch", "path": "res://scenes/rooms/stage15_challenge_branch_room.tscn"},
	{"id": "stage15_boss", "path": "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn"},
	{"id": "stage15_completion", "path": "res://scenes/rooms/stage15_completion_room.tscn"},
	{"id": "stage16_threshold", "path": "res://scenes/rooms/stage16_seal_release_threshold_room.tscn"},
	{"id": "stage16_relay", "path": "res://scenes/rooms/stage16_talisman_relay_room.tscn"},
	{"id": "stage16_backtrack", "path": "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn"},
	{"id": "stage16_purge", "path": "res://scenes/rooms/stage16_corruption_purge_room.tscn"},
	{"id": "stage16_end", "path": "res://scenes/rooms/stage16_alpha_demo_end_room.tscn"},
]

var _main: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = VIEWPORT_SIZE
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))

	_main = load(MAIN_SCENE).instantiate()
	root.add_child(_main)
	await _settle()
	_main.get_node("HUD/DemoShell").call("start_demo")
	await _settle()

	var rooms: Array = []
	for spec: Dictionary in ROOM_SPECS:
		rooms.append(await _capture_room(spec))

	var report := {
		"review_id": "demo_art_composition_dac03_all_content_visual_gate",
		"generated_at": Time.get_datetime_string_from_system(),
		"room_count": rooms.size(),
		"rooms": rooms,
		"issue_counts": _count_issues(rooms),
		"boundary": "Runtime screenshots and structural checks only. Human visual review still decides release art signoff.",
	}
	_write_text(OUT_JSON, JSON.stringify(report, "\t"))
	_write_text(OUT_MD, _build_markdown(report))
	print("DAC screenshot review: %s" % OUT_MD)
	print("DAC issue counts: %s" % JSON.stringify(report.issue_counts))
	quit()


func _capture_room(spec: Dictionary) -> Dictionary:
	var room_path := str(spec.path)
	_main.call("transition_to_room", room_path, &"")
	_main.get_node("HUD/DemoShell/MainMenu").visible = false
	_main.get_node("HUD/DemoShell/TitleBackground").visible = false
	await _settle_for_room_capture()

	var room := _main.get("room") as Node
	var screenshot_path := "%s/%s.png" % [SCREENSHOT_DIR, str(spec.id)]
	var screenshot_status := "unavailable_in_headless_dummy_renderer"
	if DisplayServer.get_name() != "headless":
		var viewport_texture := root.get_texture()
		var viewport_image := viewport_texture.get_image() if viewport_texture != null else null
		if viewport_image != null:
			viewport_image.save_png(screenshot_path)
			screenshot_status = "captured"

	var nodes := _collect_nodes(room)
	var snapshot := _inspect_nodes(nodes)
	var hud_snapshot := _inspect_hud_blockers(_collect_nodes(_main.get_node("HUD")))
	var player_snapshot := _inspect_runtime_player()
	var issues := _find_dac_issues(str(spec.id), snapshot, hud_snapshot, player_snapshot)
	print("%s | bg=%s terrain=%s decor=%s issues=%s" % [
		str(spec.id),
		snapshot.visible_background_count,
		snapshot.visible_terrain_underlay_count,
		snapshot.visible_material_decor_count,
		issues.size(),
	])

	return {
		"id": str(spec.id),
		"path": room_path,
		"screenshot": screenshot_path,
		"screenshot_status": screenshot_status,
		"snapshot": snapshot,
		"hud_snapshot": hud_snapshot,
		"player_snapshot": player_snapshot,
		"issues": issues,
	}


func _settle() -> void:
	for _i: int in range(CAPTURE_SETTLE_PROCESS_FRAMES):
		await process_frame


func _settle_for_room_capture() -> void:
	await _settle()
	for _i: int in range(CAPTURE_SETTLE_PHYSICS_FRAMES):
		var player := _get_runtime_player()
		if player != null and player.is_on_floor():
			await _settle()
			return
		await physics_frame
	await _settle()


func _get_runtime_player() -> CharacterBody2D:
	if _main == null:
		return null
	return _main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


func _inspect_runtime_player() -> Dictionary:
	var player := _get_runtime_player()
	if player == null:
		return {
			"present": false,
			"is_on_floor": false,
			"state": "",
			"animation": "",
			"asset_id": "",
		}

	var visual := player.get_node_or_null("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	return {
		"present": true,
		"is_on_floor": player.is_on_floor(),
		"state": str(player.call("get_current_state_id")) if player.has_method("get_current_state_id") else "",
		"animation": str(visual.animation) if visual != null else "",
		"asset_id": _metadata_text(visual, &"asset_id") if visual != null else "",
	}


func _collect_nodes(node: Node) -> Array:
	var nodes: Array = []
	_collect_recursive(node, nodes)
	return nodes


func _collect_recursive(node: Node, nodes: Array) -> void:
	nodes.append(node)
	for child: Node in node.get_children():
		_collect_recursive(child, nodes)


func _inspect_nodes(nodes: Array) -> Dictionary:
	var visible_backgrounds: Array[String] = []
	var visible_underlays: Array[String] = []
	var hidden_underlays: Array[String] = []
	var visible_tilemaps: Array[String] = []
	var visible_material_decor: Array[String] = []
	var visible_foreground_edge_decor: Array[String] = []
	var visible_source_atlas_previews: Array[String] = []
	var solid_untextured_underlays: Array[String] = []
	var visible_exits: Array[String] = []
	var visible_placeholder_barriers: Array[String] = []
	var visible_trigger_zone_placeholders: Array[String] = []
	var visible_prop_placeholders: Array[String] = []
	var visible_gameplay_warning_placeholders: Array[String] = []
	var oversized_gameplay_warning_vfx: Array[String] = []
	var visible_preview_only_nodes: Array[String] = []
	var visible_graybox_binding_nodes: Array[String] = []
	var visible_legacy_gate_sprites: Array[String] = []
	var visible_untextured_underlays: Array[String] = []
	var heavy_textured_underlays: Array[String] = []
	var sparse_tilemaps: Array[String] = []
	var blocky_floor_tilemaps: Array[String] = []
	var dense_surface_tilemaps: Array[String] = []
	var visible_surface_tilemaps: Array[String] = []
	var formal_tilemap_asset_ids: Array[String] = []
	var exact_shape_surface_count := 0
	var background_covered_area := 0.0
	var collision_shapes := 0

	for node: Node in nodes:
		var node_name := str(node.name)
		var visible := not (node is CanvasItem) or (node as CanvasItem).is_visible_in_tree()
		var asset_note := _metadata_text(node, &"asset_binding_note")
		if visible and node is Polygon2D and asset_note == "shape_bound_surface_edge":
			exact_shape_surface_count += 1
		if visible and asset_note.find("visual_preview_only") >= 0:
			visible_preview_only_nodes.append(str(node.get_path()))
		if visible and asset_note.find("graybox") >= 0:
			visible_graybox_binding_nodes.append(str(node.get_path()))
		if visible and node is Sprite2D and _is_legacy_gate_sprite(node as Sprite2D):
			visible_legacy_gate_sprites.append(str(node.get_path()))
		if visible and node is Sprite2D and SOURCE_SHEET_ASSET_IDS.has(_metadata_text(node, &"asset_id")):
			visible_source_atlas_previews.append(node_name)
		if node is CollisionShape2D:
			collision_shapes += 1
		if node is TileMapLayer and visible:
			visible_tilemaps.append(node_name)
			visible_material_decor.append(node_name)
			if FORMAL_FOREGROUND_TILEMAP_NAMES.has(node_name) and not (node as TileMapLayer).get_used_cells().is_empty():
				visible_foreground_edge_decor.append(node_name)
			if FORMAL_SURFACE_TILEMAP_NAMES.has(node_name) and not (node as TileMapLayer).get_used_cells().is_empty():
				visible_surface_tilemaps.append(str(node.get_path()))
				if _is_dense_surface_tilemap(node as TileMapLayer):
					dense_surface_tilemaps.append(str(node.get_path()))
				elif _is_sparse_tilemap(node as TileMapLayer):
					sparse_tilemaps.append(node_name)
			if node_name == "FormalTerrainTilemapDecor" and _has_blocky_floor_tiles(node as TileMapLayer):
				blocky_floor_tilemaps.append(str(node.get_path()))
			if FORMAL_SURFACE_TILEMAP_NAMES.has(node_name):
				formal_tilemap_asset_ids.append(_metadata_text(node, &"asset_id"))
		if node is Sprite2D and visible and node_name.find("BackgroundArt") >= 0:
			visible_backgrounds.append(node_name)
			background_covered_area += _screen_intersection_area(node as CanvasItem)
		if node is Sprite2D and visible and (node_name.find("TileSheetArt") >= 0 or node_name.find("TilesArt") >= 0 or node_name.find("MaterialTexture") >= 0):
			visible_material_decor.append(node_name)
			if node_name.find("TileSheetArt") >= 0 or node_name.find("TilesArt") >= 0 or node_name.find("Preview") >= 0:
				visible_source_atlas_previews.append(node_name)
		if node is Polygon2D and _is_terrain_underlay_name(node_name):
			if visible:
				visible_underlays.append(node_name)
				var polygon := node as Polygon2D
				if polygon.texture == null:
					visible_untextured_underlays.append(node_name)
				if polygon.texture == null and polygon.color.a >= 0.85:
					solid_untextured_underlays.append(node_name)
				if polygon.texture != null and polygon.color.a > MAX_TEXTURED_UNDERLAY_ALPHA:
					heavy_textured_underlays.append(str(node.get_path()))
			else:
				hidden_underlays.append(node_name)
		if node is Polygon2D and visible and (node_name == "ZoneVisual" or node_name == "GoalVisual" or node_name.find("Exit") >= 0):
			visible_exits.append(node_name)
		if node is Polygon2D and visible and TRIGGER_VISUAL_NAMES.has(node_name):
			var trigger_polygon := node as Polygon2D
			if trigger_polygon.color.a > MAX_TRIGGER_VISUAL_ALPHA:
				visible_trigger_zone_placeholders.append(str(node.get_path()))
		if node is Polygon2D and visible and PROP_PLACEHOLDER_NAMES.has(node_name):
			var prop_polygon := node as Polygon2D
			if prop_polygon.color.a > MAX_PROP_PLACEHOLDER_ALPHA:
				visible_prop_placeholders.append(str(node.get_path()))
		if node is Polygon2D and visible and node_name in ["MiasmaPressureVisual", "WarningVisual", "PressureSigil", "CorruptionMiasma"]:
			var warning_polygon := node as Polygon2D
			if warning_polygon.color.a > MAX_GAMEPLAY_WARNING_ALPHA:
				visible_gameplay_warning_placeholders.append(str(node.get_path()))
		if node is Polygon2D and visible and node_name.find("Arrow") >= 0:
			var arrow_polygon := node as Polygon2D
			if arrow_polygon.color.a > MAX_GAMEPLAY_WARNING_ALPHA:
				visible_gameplay_warning_placeholders.append(str(node.get_path()))
		if node is Polygon2D and visible and node_name == "BarrierVisual":
			visible_placeholder_barriers.append(node_name)
		if node is AnimatedSprite2D and visible and node_name in ["MiasmaPressureVfxVisual", "MiasmaWarningVfxArt"]:
			var warning_vfx := node as AnimatedSprite2D
			if warning_vfx.modulate.a > MAX_GAMEPLAY_VFX_WARNING_ALPHA or warning_vfx.scale.x > MAX_GAMEPLAY_VFX_WARNING_SCALE.x or warning_vfx.scale.y > MAX_GAMEPLAY_VFX_WARNING_SCALE.y:
				oversized_gameplay_warning_vfx.append(str(node.get_path()))

	return {
		"visible_background_count": visible_backgrounds.size(),
		"visible_backgrounds": visible_backgrounds,
		"background_coverage_ratio": minf(1.0, background_covered_area / float(VIEWPORT_SIZE.x * VIEWPORT_SIZE.y)),
		"visible_terrain_underlay_count": visible_underlays.size(),
		"visible_terrain_underlays": visible_underlays,
		"hidden_terrain_underlay_count": hidden_underlays.size(),
		"hidden_terrain_underlays": hidden_underlays,
		"visible_tilemap_count": visible_tilemaps.size(),
		"visible_tilemaps": visible_tilemaps,
		"visible_material_decor_count": visible_material_decor.size(),
		"visible_material_decor": visible_material_decor,
		"visible_foreground_edge_decor_count": visible_foreground_edge_decor.size(),
		"visible_foreground_edge_decor": visible_foreground_edge_decor,
		"visible_source_atlas_preview_count": visible_source_atlas_previews.size(),
		"visible_source_atlas_previews": visible_source_atlas_previews,
		"solid_untextured_underlay_count": solid_untextured_underlays.size(),
		"solid_untextured_underlays": solid_untextured_underlays,
		"visible_exit_marker_count": visible_exits.size(),
		"visible_exit_markers": visible_exits,
		"visible_placeholder_barrier_count": visible_placeholder_barriers.size(),
		"visible_placeholder_barriers": visible_placeholder_barriers,
		"visible_trigger_zone_placeholder_count": visible_trigger_zone_placeholders.size(),
		"visible_trigger_zone_placeholders": visible_trigger_zone_placeholders,
		"visible_prop_placeholder_count": visible_prop_placeholders.size(),
		"visible_prop_placeholders": visible_prop_placeholders,
		"visible_gameplay_warning_placeholder_count": visible_gameplay_warning_placeholders.size(),
		"visible_gameplay_warning_placeholders": visible_gameplay_warning_placeholders,
		"oversized_gameplay_warning_vfx_count": oversized_gameplay_warning_vfx.size(),
		"oversized_gameplay_warning_vfx": oversized_gameplay_warning_vfx,
		"visible_preview_only_node_count": visible_preview_only_nodes.size(),
		"visible_preview_only_nodes": visible_preview_only_nodes,
		"visible_graybox_binding_node_count": visible_graybox_binding_nodes.size(),
		"visible_graybox_binding_nodes": visible_graybox_binding_nodes,
		"visible_legacy_gate_sprite_count": visible_legacy_gate_sprites.size(),
		"visible_legacy_gate_sprites": visible_legacy_gate_sprites,
		"visible_untextured_underlay_count": visible_untextured_underlays.size(),
		"visible_untextured_underlays": visible_untextured_underlays,
		"heavy_textured_underlay_count": heavy_textured_underlays.size(),
		"heavy_textured_underlays": heavy_textured_underlays,
		"sparse_tilemap_count": sparse_tilemaps.size(),
		"sparse_tilemaps": sparse_tilemaps,
		"blocky_floor_tilemap_count": blocky_floor_tilemaps.size(),
		"blocky_floor_tilemaps": blocky_floor_tilemaps,
		"dense_surface_tilemap_count": dense_surface_tilemaps.size(),
		"dense_surface_tilemaps": dense_surface_tilemaps,
		"visible_surface_tilemap_count": visible_surface_tilemaps.size(),
		"visible_surface_tilemaps": visible_surface_tilemaps,
		"formal_tilemap_asset_ids": formal_tilemap_asset_ids,
		"exact_shape_surface_count": exact_shape_surface_count,
		"collision_shape_count": collision_shapes,
	}


func _is_terrain_underlay_name(node_name: String) -> bool:
	return node_name in ["FloorVisual", "PlatformVisual", "DaisVisual", "CeilingVisual", "WallVisual"]


func _find_dac_issues(room_id: String, snapshot: Dictionary, hud_snapshot: Dictionary, player_snapshot: Dictionary) -> Array:
	var issues: Array = []
	var player_state := str(player_snapshot.get("state", ""))
	if not bool(player_snapshot.get("is_on_floor", false)):
		issues.append({"severity": "P2", "code": "player_not_grounded_in_capture", "note": "运行态截图时玩家尚未落地，截图不能作为脚底贴合或默认姿态签核证据。"})
	elif player_state in ["dash", "jump_rise", "jump_fall", "air_attack"]:
		issues.append({"severity": "P2", "code": "player_action_pose_in_static_capture", "note": "静态房间截图仍处于 dash / jump / air attack 姿态，容易误判角色资产或脚底锚点。"})
	if int(snapshot.visible_background_count) <= 0:
		issues.append({"severity": "P1", "code": "missing_visible_background", "note": "运行态没有可见背景图，容易只剩纯色底。"})
	if int(snapshot.visible_surface_tilemap_count) <= 0 and int(snapshot.exact_shape_surface_count) <= 0:
		issues.append({"severity": "P1", "code": "missing_formal_terrain_tilemap", "note": "房间没有可见 TileMapLayer，正式 image-gen 地形 kit 未接入运行态。"})
	if int(snapshot.visible_placeholder_barrier_count) > 0:
		issues.append({"severity": "P1", "code": "visible_placeholder_barrier", "note": "红色多边形门仍在运行态显示，应替换为封印门美术或隐藏为 fallback。"})
	if int(snapshot.visible_trigger_zone_placeholder_count) > 0:
		issues.append({"severity": "P1", "code": "visible_trigger_zone_placeholder", "note": "运行态仍有大面积高透明度触发区色块可见，应隐藏或改为极弱提示。"})
	if int(snapshot.visible_prop_placeholder_count) > 0:
		issues.append({"severity": "P1", "code": "visible_prop_placeholder_polygon", "note": "运行态仍有高透明度道具底板多边形盖住正式 Sprite，应降为弱提示或替换正式 prop。"})
	if int(snapshot.visible_gameplay_warning_placeholder_count) > 0:
		issues.append({"severity": "P1", "code": "visible_gameplay_warning_placeholder_polygon", "note": "运行态仍有高透明度敌人或危险区多边形警示，玩家视角下会像测试色块。"})
	if int(snapshot.oversized_gameplay_warning_vfx_count) > 0:
		issues.append({"severity": "P2", "code": "oversized_gameplay_warning_vfx", "note": "危险提示 VFX 过亮或过大，容易像调试范围标记。"})
	if int(snapshot.visible_source_atlas_preview_count) > 0:
		issues.append({"severity": "P1", "code": "visible_source_atlas_preview", "note": "整张源图 / 图集预览仍在运行态可见，不能作为正式关卡地形或装饰。"})
	if int(snapshot.visible_preview_only_node_count) > 0:
		issues.append({"severity": "P1", "code": "visible_preview_only_binding", "note": "运行态仍有 visual_preview_only 节点可见，不能签核为正式场景美术。"})
	if int(snapshot.visible_graybox_binding_node_count) > 0:
		issues.append({"severity": "P1", "code": "visible_graybox_binding", "note": "运行态仍有 graybox binding 节点可见，说明视觉与碰撞还停留在过渡状态。"})
	if int(snapshot.visible_legacy_gate_sprite_count) > 0:
		issues.append({"severity": "P1", "code": "visible_legacy_gate_sprite", "note": "运行态仍有 legacy SVG 封印门，应使用 shrine_gate_prop_atlas_ai01 状态门资源。"})
	if int(snapshot.visible_untextured_underlay_count) > 0:
		issues.append({"severity": "P1", "code": "visible_untextured_polygon_terrain", "note": "可见地形仍依赖无纹理 Polygon2D，玩家视角下会像占位块。"})
	if int(snapshot.solid_untextured_underlay_count) > 0:
		issues.append({"severity": "P1", "code": "visible_solid_untextured_underlay", "note": "可见地形仍是高不透明纯色 Polygon2D，玩家视角下会像灰盒或测试块。"})
	if room_id != "test_room" and int(snapshot.heavy_textured_underlay_count) > 0:
		issues.append({"severity": "P2", "code": "heavy_textured_underlay", "note": "连续地形 underlay 过重，容易读作灰盒底板而不是材质承托。"})
	if int(snapshot.sparse_tilemap_count) > 0 and int(snapshot.dense_surface_tilemap_count) <= 0:
		issues.append({"severity": "P2", "code": "sparse_tilemap_layout", "note": "TileMap 使用密度过低，可能仍是零散样片或装饰，不足以承担连续地形。"})
	if room_id != "stage16_end" and int(hud_snapshot.hud_blocker_count) > 0:
		issues.append({"severity": "P1", "code": "hud_large_visual_blocker", "note": "HUD 中存在大面积可见贴图，可能遮挡玩法画面。"})
	if room_id != "test_room" and int(snapshot.visible_terrain_underlay_count) > 0 and int(snapshot.visible_material_decor_count) <= 0:
		issues.append({"severity": "P2", "code": "flat_terrain_without_material_transition", "note": "连续地形仍是纯色基底，缺少地表边缘、裂纹、草石或材质过渡；发布级签核前需精修。"})
	return issues


func _inspect_hud_blockers(nodes: Array) -> Dictionary:
	var blockers: Array[Dictionary] = []
	for node: Node in nodes:
		if not (node is TextureRect or node is Sprite2D or node is AnimatedSprite2D):
			continue
		var item := node as CanvasItem
		if not item.is_visible_in_tree():
			continue
		var rect := _screen_rect(item)
		var area := rect.size.x * rect.size.y
		if area < HUD_BLOCKER_MIN_AREA:
			continue
		blockers.append({
			"path": str(node.get_path()),
			"type": node.get_class(),
			"asset_id": _metadata_text(node, &"asset_id"),
			"screen_rect": [rect.position.x, rect.position.y, rect.size.x, rect.size.y],
			"area": area,
		})
	return {
		"hud_blocker_count": blockers.size(),
		"hud_blockers": blockers,
	}


func _metadata_text(node: Object, key: StringName) -> String:
	return str(node.get_meta(key, "")) if node.has_meta(key) else ""


func _is_legacy_gate_sprite(sprite: Sprite2D) -> bool:
	if _metadata_text(sprite, &"asset_id") == "stage13_seal_gate_01":
		return true
	return sprite.texture != null and sprite.texture.resource_path.find("stage13_seal_gate_01") >= 0


func _is_sparse_tilemap(tilemap: TileMapLayer) -> bool:
	var cells := tilemap.get_used_cells()
	if cells.is_empty():
		return true
	var rect := Rect2i(cells[0], Vector2i.ONE)
	for cell: Vector2i in cells:
		rect = rect.expand(cell)
	var bounds_area: int = maxi(1, rect.size.x * rect.size.y)
	var density := float(cells.size()) / float(bounds_area)
	return cells.size() < 6 or (bounds_area >= 24 and density < 0.12)


func _has_blocky_floor_tiles(tilemap: TileMapLayer) -> bool:
	var cells := tilemap.get_used_cells()
	if cells.is_empty():
		return false
	var blocky := 0
	for cell: Vector2i in cells:
		if tilemap.get_cell_atlas_coords(cell).y == 3:
			blocky += 1
	return blocky >= maxi(4, ceili(float(cells.size()) * 0.35))


func _is_dense_surface_tilemap(tilemap: TileMapLayer) -> bool:
	var cells := tilemap.get_used_cells()
	if cells.size() < 8:
		return false
	var rect := Rect2i(cells[0], Vector2i.ONE)
	for cell: Vector2i in cells:
		rect = rect.expand(cell)
	var bounds_area: int = maxi(1, rect.size.x * rect.size.y)
	var density := float(cells.size()) / float(bounds_area)
	return density >= 0.45


func _uses_expected_formal_tileset(room_id: String, asset_ids: Array) -> bool:
	return asset_ids.has("dac_formal_terrain_tileset_ai01_64")


func _screen_intersection_area(item: CanvasItem) -> float:
	var rect := _screen_rect(item)
	var viewport := Rect2(Vector2.ZERO, Vector2(VIEWPORT_SIZE))
	var overlap := rect.intersection(viewport)
	return maxf(0.0, overlap.size.x) * maxf(0.0, overlap.size.y)


func _screen_rect(item: CanvasItem) -> Rect2:
	var local_rect := _local_visual_rect(item)
	if local_rect.size == Vector2.ZERO:
		return Rect2()
	var transform := item.get_global_transform_with_canvas()
	var points := [
		transform * local_rect.position,
		transform * (local_rect.position + Vector2(local_rect.size.x, 0.0)),
		transform * (local_rect.position + Vector2(0.0, local_rect.size.y)),
		transform * (local_rect.position + local_rect.size),
	]
	var rect := Rect2(points[0], Vector2.ZERO)
	for point: Vector2 in points:
		rect = rect.expand(point)
	return rect


func _local_visual_rect(item: CanvasItem) -> Rect2:
	if item is TextureRect:
		return Rect2(Vector2.ZERO, (item as TextureRect).size)
	if item is Sprite2D:
		var sprite := item as Sprite2D
		if sprite.texture != null:
			return Rect2(-sprite.texture.get_size() * 0.5, sprite.texture.get_size())
	if item is AnimatedSprite2D:
		var animated := item as AnimatedSprite2D
		if animated.sprite_frames != null and animated.sprite_frames.has_animation(animated.animation):
			var texture := animated.sprite_frames.get_frame_texture(animated.animation, animated.frame)
			if texture != null:
				return Rect2(-texture.get_size() * 0.5, texture.get_size())
	return Rect2()


func _count_issues(rooms: Array) -> Dictionary:
	var counts := {"P0": 0, "P1": 0, "P2": 0}
	for room: Dictionary in rooms:
		for issue: Dictionary in room.issues:
			var severity := str(issue.severity)
			counts[severity] = int(counts.get(severity, 0)) + 1
	return counts


func _build_markdown(report: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("# Demo Art Composition DAC-03 All Content Visual Gate")
	lines.append("")
	lines.append("- 生成时间：%s" % str(report.generated_at))
	lines.append("- 房间数量：%s" % int(report.room_count))
	lines.append("- P0 / P1 / P2：%s / %s / %s" % [report.issue_counts.P0, report.issue_counts.P1, report.issue_counts.P2])
	lines.append("- 截图目录：`%s`" % SCREENSHOT_DIR)
	lines.append("")
	lines.append("| Room | BG | BG Cover | Terrain | Decor | FG Edge | Preview | Player | HUD Block | Signoff | Issues | Screenshot Status | Screenshot |")
	lines.append("| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | ---: | --- | --- | --- | --- |")
	for room: Dictionary in report.rooms:
		var issues := []
		for issue: Dictionary in room.issues:
			issues.append("%s:%s" % [issue.severity, issue.code])
		var player_text := "%s/%s/%s" % [
			str(room.player_snapshot.get("state", "")),
			str(room.player_snapshot.get("animation", "")),
			"floor" if bool(room.player_snapshot.get("is_on_floor", false)) else "air",
		]
		lines.append("| `%s` | %s | %.2f | %s | %s | %s | %s | `%s` | %s | %s | %s | `%s` | `%s` |" % [
			str(room.id),
			room.snapshot.visible_background_count,
			float(room.snapshot.background_coverage_ratio),
			room.snapshot.visible_terrain_underlay_count,
			room.snapshot.visible_material_decor_count,
			room.snapshot.visible_foreground_edge_decor_count,
			room.snapshot.visible_preview_only_node_count,
			player_text,
			room.hud_snapshot.hud_blocker_count,
			_signoff_state(room.issues),
			", ".join(issues) if not issues.is_empty() else "-",
			str(room.get("screenshot_status", "unknown")),
			str(room.screenshot),
		])
	lines.append("")
	lines.append("备注：脚本只捕获运行态结构证据；截图仍需人工确认地表边缘、平台材质过渡、脚底贴合、HUD 遮挡和发布级美术签核。`visual_preview_only` / `graybox` 可见节点会阻止完成签核。")
	return "\n".join(lines)


func _signoff_state(issues: Array) -> String:
	var has_p1_or_higher := false
	var has_p2 := false
	for issue: Dictionary in issues:
		var severity := str(issue.severity)
		has_p1_or_higher = has_p1_or_higher or severity in ["P0", "P1"]
		has_p2 = has_p2 or severity == "P2"
	if has_p1_or_higher:
		return "blocked"
	if has_p2:
		return "polish_required"
	return "manual_review_candidate"


func _write_text(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write %s" % path)
		return
	file.store_string(content)
