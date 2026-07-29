extends Control

# WorldMapView 只把独立布局配置绘制成发现式地图。
# 图片只负责宣纸和外框；房间、路线、门控与探索状态始终由 Godot 动态叠加。

const DEFAULT_LAYOUT_PATH := "res://assets/configs/world_map/alpha_demo_world_map.json"
const MAP_PADDING := Vector2(10.0, 8.0)

const REGION_COLORS := {
	"trial": Color(0.20, 0.48, 0.49, 0.94),
	"ward": Color(0.38, 0.48, 0.23, 0.94),
	"marsh": Color(0.20, 0.43, 0.33, 0.94),
	"sanctum": Color(0.54, 0.36, 0.18, 0.94),
	"seal": Color(0.45, 0.24, 0.29, 0.94),
	"waste": Color(0.27, 0.40, 0.62, 0.94),
}

@export_file("*.json") var layout_path := DEFAULT_LAYOUT_PATH

var _layout: Dictionary = {}
var _room_definitions: Array = []
var _room_by_id: Dictionary = {}
var _room_by_path: Dictionary = {}
var _visited_room_paths: Dictionary = {}
var _current_room_path := ""
var _map_snapshot: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_layout()
	resized.connect(queue_redraw)


# Main 每次打开地图时注入只读快照；视图不持有 Main，也不反向修改进度。
func set_map_snapshot(snapshot: Dictionary) -> void:
	_map_snapshot = snapshot.duplicate(true)
	_current_room_path = str(snapshot.get("current_room_path", ""))
	_visited_room_paths.clear()
	var visited: Variant = snapshot.get("visited_room_paths", [])
	if visited is Array:
		for room_path: Variant in visited:
			_visited_room_paths[str(room_path)] = true
	elif visited is Dictionary:
		for room_path: Variant in visited.keys():
			_visited_room_paths[str(room_path)] = true

	queue_redraw()


func get_layout_source_path() -> String:
	return layout_path


func get_visual_style_id() -> String:
	return "ink_shrine_v1"


func get_room_count() -> int:
	_ensure_layout()
	return _room_definitions.size()


func get_room_paths() -> Array:
	_ensure_layout()
	var room_paths: Array = []
	for room_definition: Dictionary in _room_definitions:
		room_paths.append(str(room_definition.get("path", "")))
	return room_paths


func get_remote_connection_ids() -> Array:
	_ensure_layout()
	var connection_ids: Array = []
	var connections: Variant = _layout.get("remote_connections", [])
	if connections is Array:
		for connection: Dictionary in connections:
			connection_ids.append(str(connection.get("id", "")))
	return connection_ids


func get_current_room_label() -> String:
	_ensure_layout()
	var room_definition: Dictionary = _room_by_path.get(_current_room_path, {})
	if room_definition.is_empty():
		return "未知房间"
	return "%s  %s" % [str(room_definition.get("id", "?")), str(room_definition.get("title", "未知房间"))]


func _ensure_layout() -> void:
	if _layout.is_empty():
		_load_layout()


func _load_layout() -> void:
	_layout.clear()
	_room_definitions.clear()
	_room_by_id.clear()
	_room_by_path.clear()
	if not FileAccess.file_exists(layout_path):
		push_error("世界地图布局不存在：%s" % layout_path)
		return

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(layout_path))
	if not parsed is Dictionary:
		push_error("世界地图布局不是有效 Dictionary：%s" % layout_path)
		return
	_layout = parsed

	var rooms: Variant = _layout.get("rooms", [])
	if not rooms is Array:
		push_error("世界地图布局缺少 rooms 数组：%s" % layout_path)
		_layout.clear()
		return
	for room_definition: Dictionary in rooms:
		_room_definitions.append(room_definition)
		_room_by_id[str(room_definition.get("id", ""))] = room_definition
		_room_by_path[str(room_definition.get("path", ""))] = room_definition
	queue_redraw()


func _get_connections() -> Array[Dictionary]:
	var connections: Array[Dictionary] = []
	var main_route: Variant = _layout.get("main_route", [])
	if main_route is Array:
		for index: int in range(main_route.size() - 1):
			connections.append({"kind": "main", "from": main_route[index], "to": main_route[index + 1]})

	var branches: Variant = _layout.get("branch_connections", [])
	if branches is Array:
		for branch: Dictionary in branches:
			connections.append({"kind": "branch", "from": branch.get("from", ""), "to": branch.get("to", "")})

	var shortcuts: Variant = _layout.get("remote_connections", [])
	if shortcuts is Array:
		for shortcut: Dictionary in shortcuts:
			connections.append({
				"kind": "shortcut",
				"id": shortcut.get("id", ""),
				"from": shortcut.get("from", ""),
				"to": shortcut.get("to", ""),
				"requirements": shortcut.get("requirements", []),
			})
	return connections


func _draw() -> void:
	_ensure_layout()
	if _layout.is_empty() or size.x <= MAP_PADDING.x * 2.0 or size.y <= MAP_PADDING.y * 2.0:
		return

	var connections := _get_connections()
	_draw_region_labels()
	for connection: Dictionary in connections:
		_draw_connection(connection)
	for room_definition: Dictionary in _room_definitions:
		_draw_room(room_definition, connections)


func _draw_region_labels() -> void:
	var regions: Variant = _layout.get("regions", [])
	if not regions is Array:
		return
	for region: Dictionary in regions:
		var region_id := str(region.get("id", ""))
		if not _is_region_discovered(region_id):
			continue
		var center := _normalized_to_point(_position_from_variant(region.get("label_position", [])))
		var color: Color = REGION_COLORS.get(region_id, Color(0.24, 0.31, 0.29, 0.9))
		color = color.darkened(0.18)
		color.a = 0.90
		var visual_scale := _get_visual_scale()
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-52.0, 5.0) * visual_scale,
			str(region.get("title", "")),
			HORIZONTAL_ALIGNMENT_CENTER,
			104.0 * visual_scale,
			maxi(10, int(roundf(11.0 * visual_scale))),
			color
		)


func _draw_connection(connection: Dictionary) -> void:
	var from_id := str(connection.get("from", ""))
	var to_id := str(connection.get("to", ""))
	if not _room_by_id.has(from_id) or not _room_by_id.has(to_id):
		return

	var from_visited := _is_room_visited(from_id)
	var to_visited := _is_room_visited(to_id)
	if not from_visited and not to_visited:
		return

	var kind := str(connection.get("kind", "main"))
	if kind == "shortcut" and not (from_visited and to_visited):
		return

	var points := _build_curve_points(_get_room_center(from_id), _get_room_center(to_id), kind, from_id, to_id)
	var fully_discovered := from_visited and to_visited
	var visual_scale := _get_visual_scale()
	if kind == "shortcut":
		var available := _is_shortcut_available(connection)
		var shortcut_color := Color(0.76, 0.52, 0.20, 0.88) if available else Color(0.34, 0.30, 0.23, 0.48)
		_draw_dashed_curve(points, shortcut_color, 1.7 * visual_scale)
		var midpoint := points[points.size() / 2]
		draw_circle(midpoint, 3.0 * visual_scale, shortcut_color, false, 1.2 * visual_scale, true)
		return

	var route_color := Color(0.17, 0.24, 0.22, 0.80)
	if kind == "branch":
		route_color = Color(0.16, 0.42, 0.34, 0.86)
	if not fully_discovered:
		route_color.a = 0.30
	draw_polyline(points, route_color, (1.8 if fully_discovered else 1.2) * visual_scale, true)


func _draw_room(room_definition: Dictionary, connections: Array[Dictionary]) -> void:
	var room_id := str(room_definition.get("id", ""))
	var room_path := str(room_definition.get("path", ""))
	var visited := _visited_room_paths.has(room_path)
	var adjacent := not visited and _is_adjacent_to_visited(room_id, connections)
	if not visited and not adjacent:
		return

	var center := _get_room_center(room_id)
	var current := room_path == _current_room_path
	var region_color: Color = REGION_COLORS.get(str(room_definition.get("region", "trial")), Color(0.28, 0.42, 0.39, 0.94))
	var visual_scale := _get_visual_scale()
	if adjacent:
		_draw_unknown_mist(center, visual_scale)

	var scale := (1.25 if current else 1.0) * visual_scale
	var shrine_shape := _make_shrine_shape(center, scale)
	var outline := shrine_shape.duplicate()
	outline.append(shrine_shape[0])
	if visited:
		var fill_color := Color(0.83, 0.61, 0.23, 0.98) if current else region_color
		draw_colored_polygon(shrine_shape, fill_color)
		draw_polyline(outline, Color(0.08, 0.11, 0.10, 0.96), 1.25, true)
		draw_line(center + Vector2(-2.0, 1.0) * scale, center + Vector2(-2.0, 5.0) * scale, Color(0.07, 0.10, 0.09, 0.74), 1.0, true)
		draw_line(center + Vector2(2.0, 1.0) * scale, center + Vector2(2.0, 5.0) * scale, Color(0.07, 0.10, 0.09, 0.74), 1.0, true)
	else:
		draw_colored_polygon(shrine_shape, Color(0.08, 0.11, 0.10, 0.20))
		draw_polyline(outline, Color(0.30, 0.36, 0.33, 0.58), 1.0, true)

	if current:
		draw_arc(center, 12.0 * visual_scale, 0.0, TAU, 28, Color(0.88, 0.66, 0.25, 0.96), 1.6 * visual_scale, true)
		draw_arc(center, 16.0 * visual_scale, 0.0, TAU, 32, Color(0.17, 0.68, 0.67, 0.42), 1.2 * visual_scale, true)
		draw_circle(center, 2.0 * visual_scale, Color(0.42, 0.91, 0.88, 0.96), true, -1.0, true)

	if visited:
		var label_color := Color(0.10, 0.13, 0.12, 0.88)
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-11.0, 18.0) * visual_scale,
			room_id,
			HORIZONTAL_ALIGNMENT_CENTER,
			22.0 * visual_scale,
			maxi(8, int(roundf(8.0 * visual_scale))),
			label_color
		)


func _make_shrine_shape(center: Vector2, scale: float) -> PackedVector2Array:
	var offsets := [
		Vector2(-7.0, -1.0),
		Vector2(-4.0, -2.5),
		Vector2(0.0, -7.0),
		Vector2(4.0, -2.5),
		Vector2(7.0, -1.0),
		Vector2(5.0, 1.0),
		Vector2(5.0, 6.0),
		Vector2(-5.0, 6.0),
		Vector2(-5.0, 1.0),
	]
	var points := PackedVector2Array()
	for offset: Vector2 in offsets:
		points.append(center + offset * scale)
	return points


func _draw_unknown_mist(center: Vector2, visual_scale: float) -> void:
	draw_circle(center + Vector2(-5.0, 1.0) * visual_scale, 16.0 * visual_scale, Color(0.04, 0.06, 0.06, 0.10))
	draw_circle(center + Vector2(7.0, -2.0) * visual_scale, 13.0 * visual_scale, Color(0.04, 0.06, 0.06, 0.08))


func _build_curve_points(from_point: Vector2, to_point: Vector2, kind: String, from_id: String, to_id: String) -> PackedVector2Array:
	var delta := to_point - from_point
	var normal := Vector2(-delta.y, delta.x).normalized()
	var bend_ratio := 0.10
	if kind == "branch":
		bend_ratio = 0.16
	elif kind == "shortcut":
		bend_ratio = 0.24
	var bend_sign := -1.0 if ("%s:%s" % [from_id, to_id]).hash() % 2 == 0 else 1.0
	var control := from_point.lerp(to_point, 0.5) + normal * minf(delta.length() * bend_ratio, 34.0) * bend_sign

	var points := PackedVector2Array()
	for index: int in range(17):
		var t := float(index) / 16.0
		var inverse := 1.0 - t
		points.append(inverse * inverse * from_point + 2.0 * inverse * t * control + t * t * to_point)
	return points


func _draw_dashed_curve(points: PackedVector2Array, color: Color, width: float) -> void:
	for index: int in range(points.size() - 1):
		if index % 2 == 0:
			draw_line(points[index], points[index + 1], color, width, true)


func _get_room_center(room_id: String) -> Vector2:
	var room_definition: Dictionary = _room_by_id.get(room_id, {})
	return _normalized_to_point(_position_from_variant(room_definition.get("position", [])))


func _normalized_to_point(normalized_position: Vector2) -> Vector2:
	var usable_size := size - MAP_PADDING * 2.0
	return MAP_PADDING + normalized_position * usable_size


func _get_visual_scale() -> float:
	return clampf(minf(size.x / 900.0, size.y / 520.0), 0.82, 1.45)


func _position_from_variant(value: Variant) -> Vector2:
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO


func _is_room_visited(room_id: String) -> bool:
	var room_definition: Dictionary = _room_by_id.get(room_id, {})
	return _visited_room_paths.has(str(room_definition.get("path", "")))


func _is_region_discovered(region_id: String) -> bool:
	for room_definition: Dictionary in _room_definitions:
		if str(room_definition.get("region", "")) == region_id and _visited_room_paths.has(str(room_definition.get("path", ""))):
			return true
	return false


func _is_adjacent_to_visited(room_id: String, connections: Array[Dictionary]) -> bool:
	for connection: Dictionary in connections:
		var from_id := str(connection.get("from", ""))
		var to_id := str(connection.get("to", ""))
		if from_id == room_id and _is_room_visited(to_id):
			return true
		if to_id == room_id and _is_room_visited(from_id):
			return true
	return false


func _is_shortcut_available(connection: Dictionary) -> bool:
	var requirements: Variant = connection.get("requirements", [])
	if not requirements is Array:
		return true
	for requirement: Variant in requirements:
		if not bool(_map_snapshot.get(str(requirement), false)):
			return false
	return true
