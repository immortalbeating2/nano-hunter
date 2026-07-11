extends SceneTree

# 将归一化后的 image_gen terrain sheet 包装成 Godot TileSet。

const SOURCE_TEXTURE_PATH := "res://assets/art/tilesets/dac_formal_terrain_tileset_ai01_64.png"
const OUT_TILESET_PATH := "res://assets/art/tilesets/editor_tilesets/dac_formal_terrain_tileset_ai01_64.tileset.tres"
const CELL := Vector2i(64, 64)
const COLUMNS := 8
const ROWS := 6


func _init() -> void:
	var texture := load(SOURCE_TEXTURE_PATH) as Texture2D
	if texture == null:
		push_error("Missing texture: %s" % SOURCE_TEXTURE_PATH)
		quit(1)
		return

	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = CELL
	for y: int in range(ROWS):
		for x: int in range(COLUMNS):
			atlas.create_tile(Vector2i(x, y))

	var tile_set := TileSet.new()
	tile_set.tile_size = CELL
	tile_set.add_source(atlas, 0)
	var save_result := ResourceSaver.save(tile_set, OUT_TILESET_PATH)
	if save_result != OK:
		push_error("Failed to save %s: %s" % [OUT_TILESET_PATH, save_result])
		quit(1)
		return

	print("built=%s cells=%d" % [OUT_TILESET_PATH, COLUMNS * ROWS])
	quit(0)
