extends SceneTree

# 给缺少 TileMapLayer 的 DAC 房间补正式地形装饰层。
# ponytail: 只补视觉 tile layer，不接管碰撞；碰撞继续由现有 StaticBody2D 负责。

const DAC_REPORT_PATH := "res://tests/artifacts/local/full-content-demo-qa/dac03_all_content_visual_gate/demo_art_composition_review.json"
const FORMAL_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/dac_formal_terrain_tileset_ai01_64.tileset.tres"
const FORMAL_ASSET_ID := "dac_formal_terrain_tileset_ai01_64"
const FORMAL_TILEMAP_NAME := "FormalTerrainTilemapDecor"
const FOREGROUND_DECOR_NAME := "FormalForegroundEdgeDecor"
const FORMAL_TILEMAP_NOTE := "dac_formal_imagegen_tileset_terrain_decor"
const FOREGROUND_DECOR_NOTE := "dac_formal_foreground_edge_decor"
const UNDERLAY_NOTE := "dac_formal_tileset_underlay_support"
const TILE_SIZE := 64.0
const SOURCE_ID := 0
const BACKGROUND_COVERAGE_SCALE := Vector2(0.58, 0.58)
const UNDERLAY_ALPHA := 0.08
const FORMAL_TILEMAP_ALPHA := 0.92
const FOREGROUND_DECOR_ALPHA := 0.46
const TERRAIN_VISUAL_OFFSET := Vector2(0.0, 16.0)
const FOREGROUND_DECOR_STRIDE := 6
const FLAT_STONE_PALETTE := [
	Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3),
	Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3), Vector2i(7, 3),
	Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4),
]
const FOREGROUND_EDGE_PALETTE := [
	Vector2i(3, 4), Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4),
]

# 正式大石板层只覆盖地面主体；薄平台 / 门禁不刷成 64px 实心块，避免读作空气墙或悬浮地面。
const TERRAIN_NODE_NAMES := {
	"FloorVisual": true,
	"DaisVisual": true,
	"CeilingVisual": true,
	"WallVisual": true,
}


func _init() -> void:
	var rooms := _load_rooms()
	if rooms.is_empty():
		quit(1)
		return

	var formal_tileset := load(FORMAL_TILESET_PATH) as TileSet
	if formal_tileset == null:
		push_error("Missing formal TileSet resource: %s" % FORMAL_TILESET_PATH)
		quit(1)
		return

	var updated_scenes := 0
	var updated_tilemaps := 0
	var updated_cells := 0
	var updated_backgrounds := 0
	for room: Dictionary in rooms:
		var scene_path := str(room.get("path", ""))
		var room_id := str(room.get("id", ""))
		var packed_scene := load(scene_path) as PackedScene
		if packed_scene == null:
			push_warning("Skip missing scene: %s" % scene_path)
			continue

		var root := packed_scene.instantiate()
		var result := _apply_formal_tilemap(root, formal_tileset)
		var hidden_previews := _hide_tileset_previews(root)
		var backgrounds := _scale_backgrounds(root)
		if int(result.cells) <= 0 and int(result.foreground_cells) <= 0 and hidden_previews <= 0 and backgrounds <= 0:
			root.free()
			continue

		var repacked := PackedScene.new()
		var pack_result := repacked.pack(root)
		root.free()
		if pack_result != OK:
			push_error("Failed to pack scene %s: %s" % [scene_path, pack_result])
			quit(1)
			return
		var save_result := ResourceSaver.save(repacked, scene_path)
		if save_result != OK:
			push_error("Failed to save scene %s: %s" % [scene_path, save_result])
			quit(1)
			return

		updated_scenes += 1
		updated_tilemaps += int(result.tilemap_added)
		updated_cells += int(result.cells) + int(result.foreground_cells)
		updated_backgrounds += backgrounds
		print("%s | tilemap_added=%s cells=%d foreground=%d previews_hidden=%d backgrounds=%d" % [scene_path, result.tilemap_added, result.cells, result.foreground_cells, hidden_previews, backgrounds])

	print("DAC formal terrain tilemap pass complete: scenes=%d tilemaps=%d cells=%d backgrounds=%d" % [updated_scenes, updated_tilemaps, updated_cells, updated_backgrounds])
	quit(0)


func _load_rooms() -> Array:
	var report_file := FileAccess.open(DAC_REPORT_PATH, FileAccess.READ)
	if report_file == null:
		push_error("DAC report missing: %s" % DAC_REPORT_PATH)
		return []
	var parsed: Variant = JSON.parse_string(report_file.get_as_text())
	if not (parsed is Dictionary) or not parsed.has("rooms"):
		push_error("DAC report has no rooms array: %s" % DAC_REPORT_PATH)
		return []
	return parsed.rooms


func _apply_formal_tilemap(root: Node, formal_tileset: TileSet) -> Dictionary:
	var underlays: Array[Polygon2D] = []
	_collect_underlays(root, underlays)
	if underlays.is_empty():
		return {"tilemap_added": false, "cells": 0}

	var tilemap := root.get_node_or_null(FORMAL_TILEMAP_NAME) as TileMapLayer
	var tilemap_added := false
	if tilemap == null:
		tilemap = TileMapLayer.new()
		tilemap.name = FORMAL_TILEMAP_NAME
		root.add_child(tilemap)
		tilemap.owner = root
		tilemap_added = true

	tilemap.tile_set = formal_tileset
	tilemap.position = TERRAIN_VISUAL_OFFSET
	tilemap.modulate = Color(1.0, 1.0, 1.0, FORMAL_TILEMAP_ALPHA)
	tilemap.set_meta(&"asset_id", FORMAL_ASSET_ID)
	tilemap.set_meta(&"asset_binding_note", FORMAL_TILEMAP_NOTE)
	tilemap.set("collision_enabled", false)
	tilemap.clear()

	var foreground := root.get_node_or_null(FOREGROUND_DECOR_NAME) as TileMapLayer
	if foreground == null:
		foreground = TileMapLayer.new()
		foreground.name = FOREGROUND_DECOR_NAME
		root.add_child(foreground)
		foreground.owner = root

	foreground.tile_set = formal_tileset
	foreground.position = TERRAIN_VISUAL_OFFSET
	foreground.modulate = Color(1.0, 1.0, 1.0, FOREGROUND_DECOR_ALPHA)
	foreground.z_index = 2
	foreground.set_meta(&"asset_id", FORMAL_ASSET_ID)
	foreground.set_meta(&"asset_binding_note", FOREGROUND_DECOR_NOTE)
	foreground.set("collision_enabled", false)
	foreground.clear()

	var cells := 0
	var foreground_cells := 0
	for underlay: Polygon2D in underlays:
		underlay.color = Color(1.0, 1.0, 1.0, UNDERLAY_ALPHA)
		underlay.set_meta(&"asset_binding_note", UNDERLAY_NOTE)
		cells += _paint_underlay(tilemap, underlay)
		foreground_cells += _paint_foreground_edge(foreground, underlay)

	return {"tilemap_added": tilemap_added, "cells": cells, "foreground_cells": foreground_cells}


func _collect_underlays(node: Node, out: Array[Polygon2D]) -> void:
	if node is Polygon2D and TERRAIN_NODE_NAMES.has(str(node.name)) and (node as Polygon2D).visible:
		out.append(node as Polygon2D)
	for child: Node in node.get_children():
		_collect_underlays(child, out)


func _paint_underlay(tilemap: TileMapLayer, underlay: Polygon2D) -> int:
	if str(underlay.name) == "WallVisual" or str(underlay.name) == "CeilingVisual":
		return 0

	var rect := _global_polygon_rect(underlay)
	if rect.size == Vector2.ZERO:
		return 0

	var start_x := floori(rect.position.x / TILE_SIZE)
	var end_x := ceili(rect.end.x / TILE_SIZE) - 1
	var start_y := floori(rect.position.y / TILE_SIZE)
	var cells := 0
	for x: int in range(start_x, end_x + 1):
		var atlas: Vector2i = FLAT_STONE_PALETTE[posmod(x - start_x, FLAT_STONE_PALETTE.size())]
		tilemap.set_cell(Vector2i(x, start_y), SOURCE_ID, atlas, 0)
		cells += 1
	return cells


func _paint_foreground_edge(tilemap: TileMapLayer, underlay: Polygon2D) -> int:
	var node_name := str(underlay.name)
	if node_name == "WallVisual" or node_name == "CeilingVisual":
		return 0

	var rect := _global_polygon_rect(underlay)
	if rect.size.x < TILE_SIZE * 1.5:
		return 0

	var start_x := floori(rect.position.x / TILE_SIZE)
	var end_x := ceili(rect.end.x / TILE_SIZE) - 1
	var top_y := floori(rect.position.y / TILE_SIZE) - 1
	var cells := 0
	for x: int in range(start_x, end_x + 1):
		if posmod(x - start_x, FOREGROUND_DECOR_STRIDE) != 0:
			continue
		var atlas: Vector2i = FOREGROUND_EDGE_PALETTE[posmod(x - start_x, FOREGROUND_EDGE_PALETTE.size())]
		tilemap.set_cell(Vector2i(x, top_y), SOURCE_ID, atlas, 0)
		cells += 1
	return cells


func _global_polygon_rect(polygon: Polygon2D) -> Rect2:
	var points := polygon.polygon
	if points.is_empty():
		return Rect2()
	var transform := polygon.global_transform
	var rect := Rect2(transform * points[0], Vector2.ZERO)
	for point: Vector2 in points:
		rect = rect.expand(transform * point)
	return rect


func _hide_tileset_previews(node: Node) -> int:
	var touched := 0
	if node is TileMapLayer and str(node.name).ends_with("TilesetPreview") and (node as TileMapLayer).visible:
		(node as TileMapLayer).visible = false
		node.set_meta(&"asset_binding_note", "hidden_runtime_tileset_reference_not_terrain")
		touched += 1
	for child: Node in node.get_children():
		touched += _hide_tileset_previews(child)
	return touched


func _scale_backgrounds(node: Node) -> int:
	var touched := 0
	if node is Sprite2D and str(node.name).find("BackgroundArt") >= 0:
		var sprite := node as Sprite2D
		if sprite.visible and sprite.scale.x < BACKGROUND_COVERAGE_SCALE.x:
			sprite.scale = BACKGROUND_COVERAGE_SCALE
			sprite.set_meta(&"asset_binding_note", "dac_background_camera_coverage_scaled")
			touched += 1

	for child: Node in node.get_children():
		touched += _scale_backgrounds(child)
	return touched
