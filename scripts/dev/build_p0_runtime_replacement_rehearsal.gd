extends SceneTree

# 生成 P0 runtime replacement rehearsal 场景。
# 该场景把 P0 替换计划中的资源绑定到 Godot 节点，作为正式替换前的编辑器排练。

const PLAN_PATH := "res://docs/assets/p0-runtime-replacement-plan.json"
const OUT_SCENE := "res://scenes/dev/p0_runtime_replacement_rehearsal.tscn"
const OUT_MANIFEST := "res://docs/assets/p0-runtime-replacement-rehearsal-manifest.json"


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：读取 P0 replacement plan，生成节点排练场景和 manifest。
func _run() -> int:
	var plan := _read_json(PLAN_PATH)
	if plan.is_empty():
		return 1

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/dev"))

	var root := Node2D.new()
	root.name = "P0RuntimeReplacementRehearsal"
	root.set_meta("p0_runtime_replacement_rehearsal_scene", true)

	var counts := {
		"entry_count": 0,
		"texture2d_nodes": 0,
		"spriteframes_nodes": 0,
		"tileset_nodes": 0,
		"stylebox_nodes": 0,
		"atlastexture_nodes": 0,
	}
	var index := 0
	for entry: Dictionary in plan.get("entries", []):
		if not _add_rehearsal_node(root, entry, index, counts):
			root.free()
			return 1
		index += 1
	counts["entry_count"] = index

	var scene := PackedScene.new()
	var pack_error := scene.pack(root)
	if pack_error != OK:
		push_error("Failed to pack P0 runtime replacement rehearsal: %s" % pack_error)
		root.free()
		return 1
	var save_error := ResourceSaver.save(scene, OUT_SCENE)
	if save_error != OK:
		push_error("Failed to save P0 runtime replacement rehearsal: %s" % save_error)
		root.free()
		return 1

	var manifest := {
		"version": 1,
		"status": "rehearsal_ready",
		"scene": OUT_SCENE,
		"purpose": "Godot editor rehearsal scene for P0 runtime replacement resources.",
		"boundary": "Rehearsal only. It binds resources to compatible Godot nodes but does not modify formal gameplay scenes, close runtime_replacement gates, or approve final art.",
		"counts": counts,
		"sources": {
			"p0_runtime_replacement_plan": PLAN_PATH,
		},
	}
	if not _write_json(OUT_MANIFEST, manifest):
		root.free()
		return 1

	print("P0 runtime replacement rehearsal built: %s" % OUT_SCENE)
	print("P0 runtime replacement rehearsal manifest written: %s" % OUT_MANIFEST)
	root.free()
	return 0


# 根据资源类型创建对应 Godot 节点并绑定资源。
func _add_rehearsal_node(root: Node2D, entry: Dictionary, index: int, counts: Dictionary) -> bool:
	var resource_path := String(entry.get("resource_path", ""))
	var asset_id := String(entry.get("asset_id", "unknown"))
	var resource := ResourceLoader.load(resource_path)
	if resource == null:
		push_error("Cannot load rehearsal resource for %s: %s" % [asset_id, resource_path])
		return false
	var resource_type := String(entry.get("catalog_resource_type", "unknown"))
	var position := Vector2(120 + (index % 7) * 230, 120 + int(index / 7) * 190)
	match resource_type:
		"SpriteFrames":
			_add_spriteframes_node(root, entry, resource as SpriteFrames, position)
			counts["spriteframes_nodes"] = int(counts["spriteframes_nodes"]) + 1
		"TileSet":
			_add_tileset_node(root, entry, resource as TileSet, position)
			counts["tileset_nodes"] = int(counts["tileset_nodes"]) + 1
		"StyleBoxTexture":
			_add_stylebox_node(root, entry, resource as StyleBoxTexture, position)
			counts["stylebox_nodes"] = int(counts["stylebox_nodes"]) + 1
		"AtlasTexture":
			_add_texture_node(root, entry, resource as Texture2D, position, "atlastexture")
			counts["atlastexture_nodes"] = int(counts["atlastexture_nodes"]) + 1
		"CompressedTexture2D", "Texture2D":
			_add_texture_node(root, entry, resource as Texture2D, position, "texture2d")
			counts["texture2d_nodes"] = int(counts["texture2d_nodes"]) + 1
		_:
			if resource is Texture2D:
				_add_texture_node(root, entry, resource as Texture2D, position, "texture2d")
				counts["texture2d_nodes"] = int(counts["texture2d_nodes"]) + 1
			else:
				push_error("Unsupported rehearsal resource type for %s: %s" % [asset_id, resource_type])
				return false
	return true


# 添加 Texture2D / CompressedTexture2D / AtlasTexture 预演节点。
func _add_texture_node(root: Node2D, entry: Dictionary, texture: Texture2D, position: Vector2, kind: String) -> void:
	var sprite := Sprite2D.new()
	sprite.name = "Rehearsal_%s_%s" % [kind, _safe_node_name(String(entry.get("asset_id", "unknown")))]
	sprite.texture = texture
	sprite.position = position
	sprite.scale = Vector2(0.32, 0.32)
	_apply_meta(sprite, entry, kind)
	root.add_child(sprite)
	sprite.owner = root


# 添加 SpriteFrames 预演节点。
func _add_spriteframes_node(root: Node2D, entry: Dictionary, sprite_frames: SpriteFrames, position: Vector2) -> void:
	var animated := AnimatedSprite2D.new()
	animated.name = "Rehearsal_spriteframes_%s" % _safe_node_name(String(entry.get("asset_id", "unknown")))
	animated.sprite_frames = sprite_frames
	var names := sprite_frames.get_animation_names()
	if not names.is_empty():
		animated.animation = String(names[0])
	animated.frame = 0
	animated.position = position
	animated.scale = Vector2(0.45, 0.45)
	_apply_meta(animated, entry, "spriteframes")
	root.add_child(animated)
	animated.owner = root


# 添加 TileSet 预演节点。
func _add_tileset_node(root: Node2D, entry: Dictionary, tile_set: TileSet, position: Vector2) -> void:
	var layer := TileMapLayer.new()
	layer.name = "Rehearsal_tileset_%s" % _safe_node_name(String(entry.get("asset_id", "unknown")))
	layer.tile_set = tile_set
	layer.position = position
	_apply_meta(layer, entry, "tileset")
	for index: int in range(8):
		layer.set_cell(Vector2i(index % 4, int(index / 4)), 0, Vector2i(index % 8, int(index / 8)), 0)
	root.add_child(layer)
	layer.owner = root


# 添加 StyleBoxTexture 预演节点。
func _add_stylebox_node(root: Node2D, entry: Dictionary, stylebox: StyleBoxTexture, position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.name = "Rehearsal_stylebox_%s" % _safe_node_name(String(entry.get("asset_id", "unknown")))
	panel.position = position
	panel.custom_minimum_size = Vector2(180, 90)
	panel.add_theme_stylebox_override("panel", stylebox)
	_apply_meta(panel, entry, "stylebox")
	root.add_child(panel)
	panel.owner = root

	var label := Label.new()
	label.text = String(entry.get("asset_id", "stylebox"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label)
	label.owner = root


# 添加审计所需元数据。
func _apply_meta(node: Node, entry: Dictionary, kind: String) -> void:
	node.set_meta("p0_rehearsal_kind", kind)
	node.set_meta("p0_rehearsal_asset_id", String(entry.get("asset_id", "unknown")))
	node.set_meta("p0_rehearsal_resource", String(entry.get("resource_path", "")))
	node.set_meta("p0_rehearsal_track", String(entry.get("track", "unknown")))
	node.set_meta("p0_rehearsal_status", String(entry.get("runtime_replacement_status", "unknown")))


# 读取 JSON 并确保顶层为 Dictionary。
func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing JSON file: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open JSON file: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("JSON is not a dictionary: %s" % path)
		return {}
	return parsed


# 写出 JSON manifest。
func _write_json(path: String, data: Dictionary) -> bool:
	var absolute_path := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write JSON file: %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
	return true


# 生成稳定节点名片段。
func _safe_node_name(value: String) -> String:
	var safe := value.to_lower()
	for token: String in [" ", "/", "\\", ".", ":", "-", "__"]:
		safe = safe.replace(token, "_")
	return safe.strip_edges().left(72)
