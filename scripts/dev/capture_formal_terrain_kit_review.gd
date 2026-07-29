extends SceneTree

# formal terrain kit 本地复核截图：只验证新 TileSet 可被 TileMapLayer 消费。
# 输出在 tests/artifacts/local/，不作为正式房间替换。

const OUT_DIR := "res://tests/artifacts/local/formal-terrain-kit/review"
const OUT_IMAGE := "%s/formal_terrain_kit_review.png" % OUT_DIR
const OUT_REPORT := "%s/formal_terrain_kit_review.json" % OUT_DIR
const OUT_SCENE := "%s/formal_terrain_kit_review.tscn" % OUT_DIR
const TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres"
const VIEWPORT_SIZE := Vector2i(1280, 720)


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = VIEWPORT_SIZE
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	var tile_set := load(TILESET_PATH) as TileSet
	if tile_set == null:
		push_error("Missing formal terrain kit TileSet")
		quit(1)
		return

	var holder := Node2D.new()
	holder.position = Vector2(70, 70)
	holder.scale = Vector2(0.32, 0.32)
	root.add_child(holder)

	var layer := TileMapLayer.new()
	layer.name = "FormalTerrainKitReviewLayer"
	layer.tile_set = tile_set
	layer.set_meta(&"asset_id", "formal_terrain_kit_ai01")
	layer.set_meta(&"asset_binding_note", "local_review_only_not_runtime_replacement")
	holder.add_child(layer)
	layer.owner = holder

	var painted := _paint_review_cells(layer)
	await process_frame
	await process_frame

	var packed := PackedScene.new()
	var scene_saved := packed.pack(holder) == OK and ResourceSaver.save(packed, OUT_SCENE) == OK
	var image_saved := _try_save_viewport_image()
	var report := {
		"ok": scene_saved and painted >= 18,
		"image": OUT_IMAGE,
		"image_saved": image_saved,
		"scene": OUT_SCENE,
		"scene_saved": scene_saved,
		"tileset": TILESET_PATH,
		"tiles_painted": painted,
		"source_count": tile_set.get_source_count(),
		"boundary": "Local review board only; runtime rooms and collision remain unchanged. Screenshot is optional because headless dummy rendering may not expose a viewport texture.",
	}
	_write_text(OUT_REPORT, JSON.stringify(report, "\t"))
	print("Formal terrain kit review: %s" % OUT_REPORT)
	quit(0 if bool(report["ok"]) else 1)


func _paint_review_cells(layer: TileMapLayer) -> int:
	var painted := 0
	var placements := [
		# 平地 / 端头 / 内外角
		[Vector2i(0, 0), 0, Vector2i(2, 0)],
		[Vector2i(1, 0), 0, Vector2i(0, 0)],
		[Vector2i(2, 0), 0, Vector2i(1, 0)],
		[Vector2i(3, 0), 0, Vector2i(3, 0)],
		[Vector2i(0, 1), 0, Vector2i(0, 1)],
		[Vector2i(3, 1), 0, Vector2i(1, 1)],
		[Vector2i(6, 0), 0, Vector2i(0, 2)],
		[Vector2i(7, 0), 0, Vector2i(1, 2)],
		[Vector2i(8, 0), 0, Vector2i(2, 2)],
		# 台阶 / 断崖
		[Vector2i(0, 4), 1, Vector2i(0, 0)],
		[Vector2i(2, 4), 1, Vector2i(1, 0)],
		[Vector2i(4, 3), 1, Vector2i(0, 1)],
		[Vector2i(6, 3), 1, Vector2i(1, 1)],
		[Vector2i(8, 3), 1, Vector2i(2, 1)],
		[Vector2i(10, 3), 1, Vector2i(3, 1)],
		# 门口衔接
		[Vector2i(0, 7), 2, Vector2i(0, 0)],
		[Vector2i(2, 7), 2, Vector2i(1, 0)],
		[Vector2i(4, 7), 2, Vector2i(2, 0)],
		[Vector2i(6, 7), 2, Vector2i(3, 0)],
		[Vector2i(8, 7), 2, Vector2i(2, 2)],
		[Vector2i(10, 7), 2, Vector2i(3, 2)],
		# 装饰 / 瘴气
		[Vector2i(0, 10), 3, Vector2i(0, 0)],
		[Vector2i(2, 10), 3, Vector2i(2, 0)],
		[Vector2i(4, 10), 3, Vector2i(0, 1)],
		[Vector2i(6, 10), 3, Vector2i(3, 1)],
		[Vector2i(8, 10), 3, Vector2i(0, 2)],
		[Vector2i(10, 10), 3, Vector2i(3, 2)],
	]
	for item: Array in placements:
		layer.set_cell(item[0], int(item[1]), item[2])
		painted += 1
	return painted


func _try_save_viewport_image() -> bool:
	return false


func _write_text(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(value + "\n")
