extends SceneTree

# FP-01 最终美术精修读值复核：加载本轮 visual preview 目标房间，保存截图和 JSON 报告。
# 本脚本只验证可见视觉层、资源引用和 no-collision 边界；不替代人工审美判断。

const OUT_DIR := "res://tests/artifacts/local/final-art-polish/fp01_runtime_readability"
const OUT_REPORT := "%s/fp01_runtime_readability_report.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(960, 540)
const SAMPLE_STEP := 8
const MIN_VISIBLE_RATIO := 0.08
const MIN_COLOR_BUCKETS := 4

const SCENE_SPECS := [
	{
		"id": "stage13_miasma_marsh_entry",
		"path": "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn",
		"visuals": [
			{"node": "MiasmaBackgroundArt", "asset_id": "biome02_miasma_marsh_background_ai01"},
			{"node": "FormalTerrainTilemapDecor", "asset_id": "dac_formal_terrain_tileset_ai01_64"},
			{"node": "FormalForegroundEdgeDecor", "asset_id": "dac_formal_terrain_tileset_ai01_64"},
		],
	},
	{
		"id": "stage14_air_dash_shrine",
		"path": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn",
		"visuals": [
			{"node": "ShrineTrialBackgroundArt", "asset_id": "biome01_shrine_trial_background_ai01"},
			{"node": "AirDashShrine/ShrineArt", "asset_id": "shrine_gate_prop_atlas_ai01"},
			{"node": "AirDashShrine/GateEchoArt", "asset_id": "shrine_gate_prop_atlas_ai01"},
			{"node": "AirDashShrine/AirDashTrailArt", "asset_id": "stage14_air_dash_trail_ai01"},
			{"node": "FormalTerrainTilemapDecor", "asset_id": "dac_formal_terrain_tileset_ai01_64"},
			{"node": "FormalForegroundEdgeDecor", "asset_id": "dac_formal_terrain_tileset_ai01_64"},
		],
	},
	{
		"id": "stage14_air_dash_gate",
		"path": "res://scenes/rooms/stage14_air_dash_gate_room.tscn",
		"visuals": [
			{"node": "ShrineGateBackgroundArt", "asset_id": "biome01_shrine_trial_background_ai01"},
			{"node": "AirDashGateSensor/ShrineEchoArt", "asset_id": "shrine_gate_prop_atlas_ai01"},
			{"node": "GateBarrier/GateArt", "asset_id": "shrine_gate_prop_atlas_ai01"},
			{"node": "FormalTerrainTilemapDecor", "asset_id": "dac_formal_terrain_tileset_ai01_64"},
			{"node": "FormalForegroundEdgeDecor", "asset_id": "dac_formal_terrain_tileset_ai01_64"},
		],
	},
	{
		"id": "stage15_seal_guardian_boss",
		"path": "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn",
		"visuals": [
			{"node": "SealGuardianBossRoomBackgroundArt", "asset_id": "stage15_seal_guardian_boss_room_ai01"},
			{"node": "SealGuardianBoss/SealGuardianRuntimeAnimationVisual", "asset_id": "seal_guardian_formal_motion_runtime_sheet_ai01"},
			{"node": "FormalTerrainTilemapDecor", "asset_id": "dac_formal_terrain_tileset_ai01_64"},
			{"node": "FormalForegroundEdgeDecor", "asset_id": "dac_formal_terrain_tileset_ai01_64"},
		],
	},
	{
		"id": "stage16_seal_release_threshold",
		"path": "res://scenes/rooms/stage16_seal_release_threshold_room.tscn",
		"visuals": [
			{"node": "SealReleaseBackgroundArt", "asset_id": "biome01_shrine_trial_background_ai01"},
			{"node": "SealReleaseNode/SealReleaseThresholdArt", "asset_id": "stage16_seal_release_threshold_ai01"},
			{"node": "GateBarrier/GateArt", "asset_id": "shrine_gate_prop_atlas_ai01"},
			{"node": "FormalTerrainTilemapDecor", "asset_id": "dac_formal_terrain_tileset_ai01_64"},
			{"node": "FormalForegroundEdgeDecor", "asset_id": "dac_formal_terrain_tileset_ai01_64"},
		],
	},
]


func _init() -> void:
	_run.call_deferred()


# 主入口：逐个房间截图并聚合报告。
func _run() -> void:
	var result := await _capture_all()
	quit(result)


# 加载每个目标房间，居中渲染，保存截图和结构化检查结果。
func _capture_all() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	root.size = VIEWPORT_SIZE

	var scene_reports: Array = []
	var ok := true
	for spec: Dictionary in SCENE_SPECS:
		var scene_report := await _capture_scene(spec)
		scene_reports.append(scene_report)
		ok = ok and bool(scene_report.get("ok", false))

	var report := {
		"ok": ok,
		"review_id": "final_art_polish_fp01_runtime_readability",
		"viewport_size": [VIEWPORT_SIZE.x, VIEWPORT_SIZE.y],
		"scene_count": scene_reports.size(),
		"scenes": scene_reports,
		"manual_review_guidance": "Open screenshots and confirm visual previews do not hide player paths, exits, enemies, hazards, or HUD-critical UI.",
		"boundary": "Runtime readability smoke only; visual quality, atlas semantics, TileSet collision and UI polish continue in later FP batches.",
	}
	if not _write_json(OUT_REPORT, report):
		return 1
	if not ok:
		push_error("FP-01 runtime readability review failed: %s" % report)
		return 1

	print("FP-01 runtime readability review OK: %s" % OUT_REPORT)
	return 0


# 单房间截图：用偏移把灰盒坐标系放进 viewport 中央。
func _capture_scene(spec: Dictionary) -> Dictionary:
	var scene_path := str(spec.get("path", ""))
	var packed_scene := ResourceLoader.load(scene_path) as PackedScene
	if packed_scene == null:
		return {"ok": false, "scene": scene_path, "error": "cannot_load_scene"}

	var holder := Node2D.new()
	holder.position = Vector2(480, 270)
	root.add_child(holder)
	var instance := packed_scene.instantiate()
	if instance == null:
		holder.free()
		return {"ok": false, "scene": scene_path, "error": "cannot_instantiate_scene"}
	holder.add_child(instance)

	await process_frame
	await process_frame
	await process_frame

	var image := root.get_texture().get_image()
	var image_path := "%s/%s.png" % [OUT_DIR, str(spec.get("id", "scene"))]
	var image_report := _analyze_image(image)
	var save_ok := image != null and not image.is_empty() and image.save_png(image_path) == OK
	var visual_reports := _inspect_visuals(instance, spec.get("visuals", []))
	var visuals_ok := true
	for visual_report: Dictionary in visual_reports:
		visuals_ok = visuals_ok and bool(visual_report.get("ok", false))

	holder.free()
	return {
		"ok": save_ok and bool(image_report.get("ok", false)) and visuals_ok,
		"scene": scene_path,
		"image": image_path,
		"image_saved": save_ok,
		"image_stats": image_report,
		"visuals": visual_reports,
	}


# 检查目标运行态视觉节点存在、可见性符合预期、asset_id 正确，并且没有误挂物理子节点。
func _inspect_visuals(scene: Node, visuals: Array) -> Array:
	var reports: Array = []
	for visual: Dictionary in visuals:
		var node_path := str(visual.get("node", ""))
		var expected_asset_id := str(visual.get("asset_id", ""))
		var expected_visible := bool(visual.get("visible", true))
		var node := scene.get_node_or_null(NodePath(node_path))
		var node_report := _inspect_visual_node(node, expected_asset_id, expected_visible)
		node_report["node"] = node_path
		reports.append(node_report)
	return reports


# 节点级检查保持保守：只证明资源引用和边界，不评判最终美术质量。
func _inspect_visual_node(node: Node, expected_asset_id: String, expected_visible: bool) -> Dictionary:
	if node == null:
		return {"ok": false, "exists": false, "expected_asset_id": expected_asset_id, "expected_visible": expected_visible}
	var asset_id := str(node.get_meta("asset_id", ""))
	var resource_path := _resource_path_for(node)
	var metadata_note := str(node.get_meta("asset_binding_note", ""))
	var runtime_source := str(node.get_meta("runtime_source", ""))
	var has_collision_child := _has_collision_or_area_child(node)
	var visible := _is_node_visible(node)
	var resource_ok := resource_path != ""
	var metadata_ok := not metadata_note.is_empty() or not runtime_source.is_empty()
	var ok := (
		asset_id == expected_asset_id
		and visible == expected_visible
		and resource_ok
		and metadata_ok
		and not has_collision_child
	)
	return {
		"ok": ok,
		"exists": true,
		"type": node.get_class(),
		"asset_id": asset_id,
		"expected_asset_id": expected_asset_id,
		"resource_path": resource_path,
		"visible": visible,
		"expected_visible": expected_visible,
		"metadata_note": metadata_note,
		"runtime_source": runtime_source,
		"has_collision_or_area_child": has_collision_child,
	}


# 抽取 Sprite2D / TextureRect / TileMapLayer 等常见视觉节点的资源路径。
func _resource_path_for(node: Node) -> String:
	if node is Sprite2D:
		var sprite := node as Sprite2D
		return sprite.texture.resource_path if sprite.texture != null else ""
	if node is TextureRect:
		var rect := node as TextureRect
		return rect.texture.resource_path if rect.texture != null else ""
	if node is TileMapLayer:
		var layer := node as TileMapLayer
		return layer.tile_set.resource_path if layer.tile_set != null else ""
	if node is AnimatedSprite2D:
		var animated := node as AnimatedSprite2D
		return animated.sprite_frames.resource_path if animated.sprite_frames != null else ""
	return ""


# Godot 视觉节点常见可见性检查。
func _is_node_visible(node: Node) -> bool:
	if node is CanvasItem:
		return (node as CanvasItem).visible
	return true


# 防止 preview art 节点自己携带 Area / Collision 子节点，碰撞仍应由灰盒节点负责。
func _has_collision_or_area_child(node: Node) -> bool:
	for child in node.get_children():
		if child is Area2D or child is CollisionShape2D or child is CollisionPolygon2D or child is StaticBody2D:
			return true
		if _has_collision_or_area_child(child):
			return true
	return false


# 简单采样截图，避免空画面或纯色画面误判。
func _analyze_image(image: Image) -> Dictionary:
	if image == null or image.is_empty():
		return {"ok": false, "error": "empty_image"}
	var samples := 0
	var visible_samples := 0
	var buckets := {}
	for y in range(0, image.get_height(), SAMPLE_STEP):
		for x in range(0, image.get_width(), SAMPLE_STEP):
			var color := image.get_pixel(x, y)
			samples += 1
			if color.a > 0.05 and (color.r + color.g + color.b) > 0.08:
				visible_samples += 1
			var bucket := "%02d_%02d_%02d" % [
				int(clampf(color.r, 0.0, 1.0) * 15.0),
				int(clampf(color.g, 0.0, 1.0) * 15.0),
				int(clampf(color.b, 0.0, 1.0) * 15.0),
			]
			buckets[bucket] = true
	var visible_ratio := float(visible_samples) / float(maxi(samples, 1))
	return {
		"ok": visible_ratio >= MIN_VISIBLE_RATIO and buckets.size() >= MIN_COLOR_BUCKETS,
		"samples": samples,
		"visible_samples": visible_samples,
		"visible_ratio": visible_ratio,
		"varied_color_buckets": buckets.size(),
		"requirements": {
			"min_visible_ratio": MIN_VISIBLE_RATIO,
			"min_color_buckets": MIN_COLOR_BUCKETS,
		},
	}


# 写出 JSON 报告。
func _write_json(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write JSON file: %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
	return true
