extends SceneTree

# 生成 image gen 资产接入演示场景。
# 该场景把当前资产包放入真实 Godot 节点，验证 SpriteFrames、TileSet、StyleBoxTexture、AtlasTexture 等可被节点消费。

const ATLAS_MANIFEST_PATH := "res://docs/assets/asset-atlas-build-manifest.json"
const ATLAS_TEXTURE_INDEX_PATH := "res://assets/art/editor_resources/editor_atlas_textures.index.json"
const STYLEBOX_INDEX_PATH := "res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json"
const OUT_SCENE := "res://scenes/dev/imagegen_asset_integration_showcase.tscn"
const OUT_MANIFEST := "res://docs/assets/imagegen-asset-integration-showcase-manifest.json"
const EXPECTED_COUNTS := {
	"animated_sprite_nodes": 10,
	"tilemap_layer_nodes": 2,
	"stylebox_nodes": 4,
	"atlas_sprite_nodes": 8,
}


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：构建演示节点树、保存场景和 manifest。
func _run() -> int:
	var atlas_manifest := _read_json(ATLAS_MANIFEST_PATH)
	var atlas_index := _read_json(ATLAS_TEXTURE_INDEX_PATH)
	var stylebox_index := _read_json(STYLEBOX_INDEX_PATH)
	if atlas_manifest.is_empty() or atlas_index.is_empty() or stylebox_index.is_empty():
		return 1

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/dev"))
	var root := Node2D.new()
	root.name = "ImagegenAssetIntegrationShowcase"
	root.set_meta("imagegen_asset_integration_showcase", true)

	var counts := {
		"animated_sprite_nodes": _add_animated_sprite_nodes(root, atlas_manifest),
		"tilemap_layer_nodes": _add_tileset_nodes(root, atlas_manifest),
		"stylebox_nodes": _add_stylebox_nodes(root, stylebox_index),
		"atlas_sprite_nodes": _add_atlas_sprite_nodes(root, atlas_index),
	}
	for key: String in EXPECTED_COUNTS.keys():
		var expected := int(EXPECTED_COUNTS[key])
		var actual := int(counts.get(key, -1))
		if actual != expected:
			push_error("Integration showcase count mismatch for %s: expected %s got %s" % [key, expected, actual])
			root.free()
			return 1

	var scene := PackedScene.new()
	var pack_error := scene.pack(root)
	if pack_error != OK:
		push_error("Failed to pack integration showcase: %s" % pack_error)
		root.free()
		return 1
	var save_error := ResourceSaver.save(scene, OUT_SCENE)
	if save_error != OK:
		push_error("Failed to save integration showcase: %s" % save_error)
		root.free()
		return 1

	var manifest := {
		"version": 1,
		"status": "placeholder_ready",
		"scene": OUT_SCENE,
		"purpose": "Godot node-level integration showcase for image-gen art package resources.",
		"boundary": "Node-consumption smoke only; not final runtime replacement, collision polish, animation tuning, or art cleanup.",
		"counts": counts,
		"sources": {
			"atlas_manifest": ATLAS_MANIFEST_PATH,
			"atlas_texture_index": ATLAS_TEXTURE_INDEX_PATH,
			"stylebox_index": STYLEBOX_INDEX_PATH,
		},
	}
	if not _write_json(OUT_MANIFEST, manifest):
		root.free()
		return 1

	print("Imagegen asset integration showcase built: %s" % OUT_SCENE)
	print("Imagegen asset integration showcase manifest written: %s" % OUT_MANIFEST)
	root.free()
	return 0


# 添加所有 SpriteFrames 候选到 AnimatedSprite2D，覆盖角色、敌人和 VFX 序列帧。
func _add_animated_sprite_nodes(root: Node2D, manifest: Dictionary) -> int:
	var count := 0
	var origin := Vector2(120, 120)
	for item: Dictionary in manifest.get("outputs", []):
		var sprite_frames_path := String(item.get("sprite_frames", ""))
		if sprite_frames_path.is_empty():
			continue
		var resource := ResourceLoader.load(_to_res_path(sprite_frames_path))
		if resource == null or not resource is SpriteFrames:
			push_error("Cannot load SpriteFrames: %s" % sprite_frames_path)
			continue
		var animated := AnimatedSprite2D.new()
		animated.name = "Animated_%s" % String(item.get("id", "sprite_frames"))
		animated.sprite_frames = resource
		var animation_name := String(item.get("animation", {}).get("name", ""))
		if animation_name.is_empty():
			var names := animated.sprite_frames.get_animation_names()
			if not names.is_empty():
				animation_name = String(names[0])
		if not animation_name.is_empty():
			animated.animation = animation_name
		animated.frame = 0
		animated.position = origin + Vector2((count % 5) * 220, int(count / 5) * 190)
		animated.scale = Vector2(0.65, 0.65)
		animated.set_meta("integration_kind", "animated_sprite")
		animated.set_meta("integration_resource", _to_res_path(sprite_frames_path))
		root.add_child(animated)
		animated.owner = root
		count += 1
	return count


# 添加 TileSet 到 TileMapLayer，并放置少量 tile，验证 TileSet 可被关卡节点消费。
func _add_tileset_nodes(root: Node2D, manifest: Dictionary) -> int:
	var count := 0
	for item: Dictionary in manifest.get("outputs", []):
		if String(item.get("kind", "")) != "tileset_sheet":
			continue
		var id := String(item.get("id", "tileset"))
		var path := "res://assets/art/tilesets/editor_tilesets/%s.tileset.tres" % id
		var resource := ResourceLoader.load(path)
		if resource == null or not resource is TileSet:
			push_error("Cannot load TileSet: %s" % path)
			continue
		var layer := TileMapLayer.new()
		layer.name = "TileLayer_%s" % id
		layer.tile_set = resource
		layer.position = Vector2(120 + count * 620, 540)
		layer.set_meta("integration_kind", "tilemap_layer")
		layer.set_meta("integration_resource", path)
		var columns: int = max(1, int(item.get("columns", 8)))
		for index in range(12):
			layer.set_cell(Vector2i(index % 6, int(index / 6)), 0, Vector2i(index % columns, int(index / columns)), 0)
		root.add_child(layer)
		layer.owner = root
		count += 1
	return count


# 添加九宫格 StyleBoxTexture 到 PanelContainer，验证 UI 样式资源可被 Control 节点消费。
func _add_stylebox_nodes(root: Node2D, stylebox_index: Dictionary) -> int:
	var count := 0
	for item: Dictionary in stylebox_index.get("items", []):
		if count >= 4:
			break
		var path := String(item.get("resource", ""))
		var resource := ResourceLoader.load(path)
		if resource == null or not resource is StyleBoxTexture:
			push_error("Cannot load StyleBoxTexture: %s" % path)
			continue
		var panel := PanelContainer.new()
		panel.name = "StyleBoxPanel_%s" % count
		panel.position = Vector2(1180, 100 + count * 150)
		panel.custom_minimum_size = Vector2(300, 100)
		panel.add_theme_stylebox_override("panel", resource)
		panel.set_meta("integration_kind", "stylebox_panel")
		panel.set_meta("integration_resource", path)
		root.add_child(panel)
		panel.owner = root
		var label := Label.new()
		label.text = "StyleBox %s" % count
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		panel.add_child(label)
		label.owner = root
		count += 1
	return count


# 添加若干 AtlasTexture 到 Sprite2D，覆盖 icon、prop、texture、promo、storyboard 和 Spine part region。
func _add_atlas_sprite_nodes(root: Node2D, atlas_index: Dictionary) -> int:
	var wanted := [
		"icon_sheet_core_ai01",
		"shrine_gate_prop_atlas_ai01",
		"equipment_pickup_atlas_ai01",
		"material_texture_atlas_ai01",
		"promo_key_art_sheet_ai01",
		"storyboard_intro_bounty_ai01",
		"luna_spine_parts_ai01",
		"seal_guardian_spine_parts_ai01",
	]
	var count := 0
	for asset_id: String in wanted:
		var resource_path := _first_atlas_resource_for_asset(atlas_index, asset_id)
		if resource_path.is_empty():
			push_error("Missing AtlasTexture resource for %s" % asset_id)
			continue
		var resource := ResourceLoader.load(resource_path)
		if resource == null or not resource is Texture2D:
			push_error("Cannot load AtlasTexture resource: %s" % resource_path)
			continue
		var sprite := Sprite2D.new()
		sprite.name = "AtlasSprite_%s" % asset_id
		sprite.texture = resource
		sprite.position = Vector2(140 + (count % 4) * 230, 780 + int(count / 4) * 150)
		sprite.scale = Vector2(0.8, 0.8)
		sprite.set_meta("integration_kind", "atlas_sprite")
		sprite.set_meta("integration_resource", resource_path)
		root.add_child(sprite)
		sprite.owner = root
		count += 1
	return count


# 取得指定 asset 的第一个 AtlasTexture 资源路径。
func _first_atlas_resource_for_asset(index: Dictionary, asset_id: String) -> String:
	for asset: Dictionary in index.get("assets", []):
		var current_id := String(asset.get("asset_id", asset.get("id", "")))
		if current_id != asset_id:
			continue
		var resources: Array = asset.get("resources", [])
		if resources.is_empty():
			return ""
		return String(resources[0].get("resource", ""))
	return ""


# 读取 JSON 并确保顶层是 Dictionary。
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


# 将项目相对路径转换为 res:// 路径。
func _to_res_path(value: String) -> String:
	if value.begins_with("res://"):
		return value
	return "res://" + value
