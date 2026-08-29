extends Node2D

# FormalRoomGrayboxLayout 把房间蓝图中的矩形块转为同源的实体碰撞与地形表面。
# 房间场景只保存本房的块面数据；玩家出生安全检查、路线高度和可见地形统一读取本组件。

@export_range(1, 8, 1) var segment_count := 1
@export var layout_profile: StringName = &""
@export var solid_rects: Array[Rect2] = []
@export var one_way_rects: Array[Rect2] = []
@export var route_heights: Dictionary = {}
# 整房背景已经带有精确道路视觉时，可只保留本组件的碰撞真源，避免重复画第二层实体地板。
@export var show_solid_visuals := true

const SOLID_TEXTURE := preload("res://assets/art/textures/dac_continuous_stone_underlay.png")
const GROUND_ATLAS_TEXTURE := preload("res://assets/art/tilesets/shrine_trial_tileset_ai01.png")
const GROUND_SURFACE_REGION := Rect2(0, 0, 192, 64)
const GROUND_ALPHA_TOP_INSET := 37.0
const PLATFORM_TEXTURE := preload("res://assets/art/tilesets/tutorial_jump_platform_visual_ai02.png")
const PLATFORM_ALPHA_TOP_INSET := 23.0
const PLATFORM_HEIGHT := 64.0
const PLATFORM_CAP_WIDTH := 64
const ONE_WAY_PLATFORM_GROUP: StringName = &"one_way_platform"

var _ground_surface_texture: AtlasTexture


func _ready() -> void:
	_ground_surface_texture = AtlasTexture.new()
	_ground_surface_texture.atlas = GROUND_ATLAS_TEXTURE
	_ground_surface_texture.region = GROUND_SURFACE_REGION
	_fit_background_to_camera()
	_retire_stale_surface_layers()
	_build_runtime_geometry()


# 返回蓝图定义的镜头分段数，供房间规模回归使用。
func get_segment_count() -> int:
	return segment_count


# 返回房间的空间职责，不让 F04–F09 再退回同构连续走廊。
func get_layout_profile() -> StringName:
	return layout_profile


# 返回本组件实际生成的可踩块数量，避免只写元数据却没有实体碰撞。
func get_runtime_platform_count() -> int:
	return solid_rects.size() + one_way_rects.size()


# 判断指定点正下方是否存在近距离支撑，用于防止切房出生后直接触发跌落恢复。
func has_support_below(point: Vector2, max_drop: float) -> bool:
	for rect: Rect2 in solid_rects + one_way_rects:
		if point.x < rect.position.x or point.x > rect.end.x:
			continue
		var drop := rect.position.y - point.y
		if drop >= 0.0 and drop <= max_drop:
			return true
	return false


# 返回蓝图路线的表面高度；缺少声明时使用 INF，让测试明确失败而非误判为地面高度。
func get_route_height(route_id: StringName) -> float:
	return float(route_heights.get(route_id, INF))


# 返回指定落脚点所在表面与头顶最近实体底边之间的净空；单向平台也视为上方障碍，
# 因为下层回访路线若被它压到角色高度以内，蓝图上虽有分层，运行时仍无法通过。
func get_vertical_clearance_above(point: Vector2) -> float:
	var support_y := INF
	for rect: Rect2 in solid_rects + one_way_rects:
		if point.x < rect.position.x or point.x > rect.end.x:
			continue
		if rect.position.y >= point.y:
			support_y = minf(support_y, rect.position.y)
	if is_inf(support_y):
		return 0.0

	var obstruction_bottom := -INF
	for rect: Rect2 in solid_rects + one_way_rects:
		if point.x < rect.position.x or point.x > rect.end.x:
			continue
		if rect.end.y <= support_y:
			obstruction_bottom = maxf(obstruction_bottom, rect.end.y)
	if is_inf(obstruction_bottom):
		return INF
	return support_y - obstruction_bottom


# 计算同一声明高度上相邻可踩面的最大水平断口，用移动标尺守住普通主线 110u 上限。
# 这里只比较与路线高度严格对齐的表面，避免把上下层投影重叠误当成连续地面。
func get_max_surface_gap(route_id: StringName) -> float:
	var route_y := get_route_height(route_id)
	if is_inf(route_y):
		return INF
	var surfaces: Array[Rect2] = []
	for rect: Rect2 in solid_rects + one_way_rects:
		if is_equal_approx(rect.position.y, route_y):
			surfaces.append(rect)
	if surfaces.size() < 2:
		return 0.0
	surfaces.sort_custom(func(left: Rect2, right: Rect2) -> bool: return left.position.x < right.position.x)
	var furthest_end := surfaces[0].end.x
	var max_gap := 0.0
	for index in range(1, surfaces.size()):
		max_gap = maxf(max_gap, surfaces[index].position.x - furthest_end)
		furthest_end = maxf(furthest_end, surfaces[index].end.x)
	return max_gap


func _build_runtime_geometry() -> void:
	for index in solid_rects.size():
		_create_platform(solid_rects[index], false, "Solid%02d" % (index + 1))
	for index in one_way_rects.size():
		_create_platform(one_way_rects[index], true, "OneWay%02d" % (index + 1))


# 每个蓝图矩形生成独立 StaticBody2D；碰撞、实体填充和表面宽度共用同一尺寸。
func _create_platform(rect: Rect2, one_way: bool, platform_name: String) -> void:
	var body := StaticBody2D.new()
	body.name = platform_name
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 0
	if one_way:
		body.add_to_group(ONE_WAY_PLATFORM_GROUP)
	add_child(body)

	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.shape = shape
	collision.one_way_collision = one_way
	collision.one_way_collision_margin = 8.0
	body.add_child(collision)

	var half_size := rect.size * 0.5
	if not one_way:
		var body_visual := Polygon2D.new()
		body_visual.name = "TerrainBodyVisual"
		body_visual.z_index = 1
		body_visual.texture = SOLID_TEXTURE
		body_visual.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		body_visual.polygon = PackedVector2Array([
			Vector2(-half_size.x, -half_size.y),
			Vector2(half_size.x, -half_size.y),
			Vector2(half_size.x, half_size.y),
			Vector2(-half_size.x, half_size.y),
		])
		body_visual.visible = show_solid_visuals
		body.add_child(body_visual)

	var surface := NinePatchRect.new()
	surface.name = "OneWaySurfaceVisual" if one_way else "GroundSurfaceVisual"
	surface.z_index = 2
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surface.texture = PLATFORM_TEXTURE if one_way else _ground_surface_texture
	surface.visible = true if one_way else show_solid_visuals
	var alpha_top_inset := PLATFORM_ALPHA_TOP_INSET if one_way else GROUND_ALPHA_TOP_INSET
	surface.position = Vector2(-half_size.x, -half_size.y - alpha_top_inset)
	surface.size = Vector2(rect.size.x, PLATFORM_HEIGHT)
	surface.patch_margin_left = PLATFORM_CAP_WIDTH
	surface.patch_margin_right = PLATFORM_CAP_WIDTH
	surface.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
	body.add_child(surface)


# Phase2 几何已取代旧 Batch TileMap；旧表面若继续显示，会把旧地形错误叠到新碰撞上。
func _retire_stale_surface_layers() -> void:
	var room := get_parent()
	for node_name: String in ["GroundSurfaceVisual", "ThinPlatformSurfaceVisual"]:
		var stale_surface := room.get_node_or_null(node_name) as CanvasItem
		if stale_surface != null:
			stale_surface.visible = false


# 六房沿 X 扩成多屏后，沿用旧单屏背景变换会在中段和出口露出纯色底。
func _fit_background_to_camera() -> void:
	var room := get_parent()
	var background: Sprite2D
	for node_name: String in [
		"MiasmaBackgroundArt",
		"DemoBackgroundArt",
		"TutorialShrineBackgroundArt",
		"ShrineTrialBackgroundArt",
		"ShrineGateBackgroundArt",
		"GauntletBackgroundArt",
		"SealGuardianBossRoomBackgroundArt",
		"CompletionBackgroundArt",
	]:
		background = room.get_node_or_null(node_name) as Sprite2D
		if background != null:
			break
	if background == null or background.texture == null or not room.has_method("get_camera_limits"):
		return
	var limits: Rect2i = room.call("get_camera_limits")
	var texture_size := background.texture.get_size()
	var cover_scale := maxf(float(limits.size.x) / texture_size.x, float(limits.size.y) / texture_size.y)
	background.position = Vector2(limits.position) + Vector2(limits.size) * 0.5
	background.scale = Vector2.ONE * cover_scale
	var backdrop := room.get_node_or_null("Backdrop") as Polygon2D
	if backdrop != null:
		var half_background_size := texture_size * cover_scale * 0.5
		var top_left := background.position - half_background_size
		var bottom_right := background.position + half_background_size
		backdrop.polygon = PackedVector2Array([
			top_left,
			Vector2(bottom_right.x, top_left.y),
			bottom_right,
			Vector2(top_left.x, bottom_right.y),
		])
