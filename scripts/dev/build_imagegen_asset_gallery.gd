extends SceneTree

# 生成 image gen 资产包的 Godot 编辑器预览场景。
# 该场景用于人工扫图、分类验收和后续替换接入前的编辑器侧检查。

const QUEUE_PATH := "res://docs/assets/image-gen-prompt-queue.json"
const ATLAS_INDEX_PATH := "res://assets/art/editor_resources/editor_atlas_textures.index.json"
const STYLEBOX_INDEX_PATH := "res://assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/menu_ninepatch_ui_ai01.styleboxes.index.json"
const SPINE_INDEX_PATH := "res://assets/art/spine_parts/spine_exports/spine_cutout_exports.index.json"
const AUDIT_REPORT_PATH := "res://docs/assets/asset-package-audit-report.json"
const OUT_SCENE := "res://scenes/dev/imagegen_asset_gallery.tscn"
const OUT_MANIFEST := "res://docs/assets/imagegen-asset-gallery-manifest.json"

const CATEGORY_LABELS := {
	"style_board": "风格板",
	"character_direction": "角色方向稿",
	"sprite_sheet": "角色 / 敌人序列帧",
	"boss_direction": "Boss 方向稿",
	"spine_cutout_parts": "Spine 拆件图集",
	"tileset_sheet": "TileSet",
	"terrain_tile_strip": "语义地形条带",
	"environment_tiles": "关卡地块",
	"environment_background": "区域背景",
	"environment_room_background": "房间背景",
	"environment_boss_room_background": "Boss 房背景",
	"ui_atlas": "UI 图集",
	"ui_panel": "UI 面板",
	"ui_map_foundation": "探索地图底板",
	"hud_frame": "HUD 框架",
	"completion_ui": "完成反馈",
	"title_background": "标题背景",
	"ninepatch_sheet": "九宫格",
	"icon": "图标",
	"icon_sheet": "图标图集",
	"prop": "道具",
	"prop_atlas": "道具图集",
	"prop_sheet": "道具 sheet",
	"equipment_atlas": "装备图集",
	"vfx_direction": "特效方向稿",
	"vfx_warning": "特效预警",
	"vfx_sheet": "特效序列帧",
	"vfx_atlas": "特效图集",
	"texture_atlas": "材质贴图",
	"promo_key_art": "宣传主视觉",
	"promo_capsule": "商店胶囊图",
	"logo_direction": "LOGO 方向",
	"cg_illustration": "CG 图",
	"storyboard_sheet": "剧情分镜",
}


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：收集资产索引，生成可在编辑器中打开的预览场景和独立 manifest。
func _run() -> int:
	var queue := _read_json(QUEUE_PATH)
	var atlas_index := _read_json(ATLAS_INDEX_PATH)
	var stylebox_index := _read_json(STYLEBOX_INDEX_PATH)
	var spine_index := _read_json(SPINE_INDEX_PATH)
	var audit_report := _read_json(AUDIT_REPORT_PATH)
	if queue.is_empty() or atlas_index.is_empty() or stylebox_index.is_empty() or spine_index.is_empty() or audit_report.is_empty():
		return 1

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/dev"))

	var root := _make_root()
	var content := root.get_node("Scroll/Content") as VBoxContainer
	_add_header(content, audit_report)

	var queue_counts := _add_queue_outputs(content, queue)
	var atlas_count := _add_atlas_texture_outputs(content, atlas_index)
	var tileset_count := _add_tileset_outputs(content, queue)
	var stylebox_count := _add_stylebox_outputs(content, stylebox_index)
	var spine_part_count := _add_spine_outputs(content, spine_index)

	var scene := PackedScene.new()
	var pack_error := scene.pack(root)
	if pack_error != OK:
		push_error("Failed to pack gallery scene: %s" % pack_error)
		return 1
	var save_error := ResourceSaver.save(scene, OUT_SCENE)
	if save_error != OK:
		push_error("Failed to save gallery scene: %s" % save_error)
		root.free()
		return 1

	var manifest := {
		"version": 1,
		"status": "placeholder_ready",
		"scene": OUT_SCENE,
		"purpose": "Godot editor-facing preview scene for image-gen art package review.",
		"boundary": "Preview and structural review only; not final art polish or runtime integration.",
		"counts": {
			"queue_outputs": queue_counts.get("total", 0),
			"queue_categories": queue_counts.get("categories", {}),
			"atlas_textures": atlas_count,
			"tilesets": tileset_count,
			"styleboxes": stylebox_count,
			"spine_parts": spine_part_count,
		},
		"sources": {
			"queue": QUEUE_PATH,
			"atlas_index": ATLAS_INDEX_PATH,
			"stylebox_index": STYLEBOX_INDEX_PATH,
			"spine_index": SPINE_INDEX_PATH,
			"audit_report": AUDIT_REPORT_PATH,
		},
	}
	if not _write_json(OUT_MANIFEST, manifest):
		root.free()
		return 1

	root.free()
	print("Imagegen asset gallery built: %s" % OUT_SCENE)
	print("Imagegen asset gallery manifest written: %s" % OUT_MANIFEST)
	return 0


# 创建根 Control、滚动容器和基础版式。
func _make_root() -> Control:
	var root := Control.new()
	root.name = "ImagegenAssetGallery"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.custom_minimum_size = Vector2(1600, 1000)
	root.set_meta("asset_gallery_scene", true)

	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(scroll)
	scroll.owner = root

	var content := VBoxContainer.new()
	content.name = "Content"
	content.custom_minimum_size = Vector2(1500, 0)
	content.add_theme_constant_override("separation", 20)
	scroll.add_child(content)
	content.owner = root
	return root


# 写入总览标题和审计边界。
func _add_header(parent: VBoxContainer, audit_report: Dictionary) -> void:
	_add_label(parent, "Nano Hunter Image Gen Asset Gallery", 28)
	_add_label(parent, "用途：集中预览角色、关卡、UI、图标、道具、VFX、动画帧、贴图、宣传图、CG 与分镜资产。", 16)
	_add_label(parent, "边界：该场景证明资源可打开和可预览，不代表最终清稿、授权、运行时替换或玩法读值完成。", 14)
	var counts: Dictionary = audit_report.get("file_counts", {})
	_add_label(parent, "当前结构审计：art_png=%s, spriteframes=%s, atlas_textures=%s, tilesets=%s, styleboxes=%s" % [
		counts.get("art_png", 0),
		counts.get("spriteframes_tres", 0),
		counts.get("atlas_texture_tres", 0),
		counts.get("tileset_tres", 0),
		counts.get("stylebox_texture_tres", 0),
	], 14)


# 按 target_kind 分组展示 prompt queue 中的全部最终输出 PNG。
func _add_queue_outputs(parent: VBoxContainer, queue: Dictionary) -> Dictionary:
	_add_section_title(parent, "01 最终输出 PNG / Queue Outputs")
	var groups: Dictionary = {}
	for item: Dictionary in queue.get("items", []):
		var target_kind := String(item.get("target_kind", "unknown"))
		if not groups.has(target_kind):
			groups[target_kind] = []
		groups[target_kind].append(item)

	var total := 0
	var categories := {}
	var sorted_kinds := groups.keys()
	sorted_kinds.sort()
	for target_kind: String in sorted_kinds:
		var items: Array = groups[target_kind]
		total += items.size()
		categories[target_kind] = items.size()
		_add_label(parent, "%s / %s：%s" % [target_kind, CATEGORY_LABELS.get(target_kind, "未分类"), items.size()], 18)
		var grid := _make_grid(parent, 4)
		for item: Dictionary in items:
			var asset_id := String(item.get("asset_id", "unknown"))
			var path := _to_res_path(String(item.get("output_path", "")))
			_add_texture_card(grid, asset_id, path, "queue_output", Vector2(260, 150))
	return {"total": total, "categories": categories}


# 展示从图集中拆出的 AtlasTexture region，便于检查小图、道具、VFX、分镜和拆件。
func _add_atlas_texture_outputs(parent: VBoxContainer, atlas_index: Dictionary) -> int:
	_add_section_title(parent, "02 Godot AtlasTexture / 图集拆分资源")
	var total := 0
	for asset: Dictionary in atlas_index.get("assets", []):
		var resources: Array = asset.get("resources", [])
		total += resources.size()
		_add_label(parent, "%s：%s regions" % [String(asset.get("asset_id", "unknown")), resources.size()], 18)
		var grid := _make_grid(parent, 6)
		for entry: Dictionary in resources:
			var title := String(entry.get("name", "region"))
			var path := String(entry.get("resource", ""))
			_add_texture_card(grid, title, path, "atlas_texture", Vector2(150, 120))
	return total


# 展示 TileSet 资源对应的源 sheet，并记录 Godot TileSet 候选数量。
func _add_tileset_outputs(parent: VBoxContainer, queue: Dictionary) -> int:
	_add_section_title(parent, "03 Godot TileSet / 关卡地块候选")
	var grid := _make_grid(parent, 2)
	var count := 0
	for item: Dictionary in queue.get("items", []):
		if String(item.get("target_kind", "")) != "tileset_sheet":
			continue
		var asset_id := String(item.get("asset_id", "unknown"))
		_add_texture_card(
			grid,
			asset_id,
			_to_res_path(String(item.get("output_path", ""))),
			"tileset_sheet",
			Vector2(360, 220)
		)
		count += 1
	return count


# 展示九宫格 StyleBoxTexture 候选，便于检查 UI 面板拉伸资源。
func _add_stylebox_outputs(parent: VBoxContainer, stylebox_index: Dictionary) -> int:
	_add_section_title(parent, "04 Godot StyleBoxTexture / 九宫格 UI 候选")
	var grid := _make_grid(parent, 4)
	var count := 0
	for item: Dictionary in stylebox_index.get("items", []):
		var title := String(item.get("name", "stylebox"))
		var path := String(item.get("resource", ""))
		_add_stylebox_card(grid, title, path)
		count += 1
	return count


# 展示 Spine-style cutout 导出统计，并用拆件图集源图做人工预览入口。
func _add_spine_outputs(parent: VBoxContainer, spine_index: Dictionary) -> int:
	_add_section_title(parent, "05 Spine-style Cutout / 拆件图集")
	var grid := _make_grid(parent, 2)
	var part_count := 0
	for asset: Dictionary in spine_index.get("assets", []):
		part_count += int(asset.get("part_count", 0))
		var asset_id := String(asset.get("asset_id", "unknown"))
		var texture_path := "res://assets/art/spine_parts/%s.png" % asset_id
		_add_texture_card(grid, "%s / %s parts" % [asset_id, asset.get("part_count", 0)], texture_path, "spine_cutout", Vector2(420, 280))
	return part_count


# 创建一个固定列数的 GridContainer。
func _make_grid(parent: VBoxContainer, columns: int) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	parent.add_child(grid)
	grid.owner = parent.owner
	return grid


# 添加一张纹理预览卡片，加载失败时也保留路径标签帮助排查。
func _add_texture_card(parent: GridContainer, title: String, texture_path: String, kind: String, size: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.name = "Preview_%s_%s" % [kind, _safe_node_name(title)]
	panel.custom_minimum_size = Vector2(size.x + 24.0, size.y + 70.0)
	panel.set_meta("asset_gallery_kind", kind)
	panel.set_meta("asset_gallery_resource", texture_path)
	parent.add_child(panel)
	panel.owner = parent.owner

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.owner = parent.owner

	var label := Label.new()
	label.text = title
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(label)
	label.owner = parent.owner

	var texture_rect := TextureRect.new()
	texture_rect.custom_minimum_size = size
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture := ResourceLoader.load(texture_path)
	if texture != null and texture is Texture2D:
		texture_rect.texture = texture
	else:
		label.text = "%s / missing texture" % title
	box.add_child(texture_rect)
	texture_rect.owner = parent.owner

	var path_label := Label.new()
	path_label.text = texture_path
	path_label.clip_text = true
	path_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(path_label)
	path_label.owner = parent.owner


# 添加一张 StyleBoxTexture 预览卡片，用 PanelContainer 直接应用九宫格候选资源。
func _add_stylebox_card(parent: GridContainer, title: String, stylebox_path: String) -> void:
	var panel := PanelContainer.new()
	panel.name = "Preview_stylebox_%s" % _safe_node_name(title)
	panel.custom_minimum_size = Vector2(280, 150)
	panel.set_meta("asset_gallery_kind", "stylebox")
	panel.set_meta("asset_gallery_resource", stylebox_path)
	var resource := ResourceLoader.load(stylebox_path)
	if resource != null and resource is StyleBoxTexture:
		panel.add_theme_stylebox_override("panel", resource)
	parent.add_child(panel)
	panel.owner = parent.owner

	var label := Label.new()
	label.text = "%s\n%s" % [title, stylebox_path]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label)
	label.owner = parent.owner


# 添加分节标题。
func _add_section_title(parent: VBoxContainer, text: String) -> void:
	var label := _add_label(parent, text, 22)
	label.add_theme_color_override("font_color", Color(0.95, 0.86, 0.58, 1.0))


# 添加普通标签。
func _add_label(parent: VBoxContainer, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	label.owner = parent.owner
	return label


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


# 将项目相对路径或绝对路径转换为 res:// 路径。
func _to_res_path(value: String) -> String:
	if value.begins_with("res://"):
		return value
	if value.is_absolute_path():
		var project_root := ProjectSettings.globalize_path("res://")
		var normalized_root := project_root.replace("\\", "/").trim_suffix("/")
		var normalized_value := value.replace("\\", "/")
		if normalized_value.begins_with(normalized_root):
			return "res://" + normalized_value.substr(normalized_root.length()).trim_prefix("/")
		return value
	return "res://" + value


# 生成稳定节点名片段，避免文件名中的符号污染场景树。
func _safe_node_name(value: String) -> String:
	var safe := value.to_lower()
	for token: String in [" ", "/", "\\", ".", ":", "-", "__"]:
		safe = safe.replace(token, "_")
	return safe.strip_edges().left(72)
