extends GutTest

# 正式 Demo remap 契约测试：保护普通房间双向连接、出入口安全和强视觉读值。

const ORDINARY_BIDIRECTIONAL_LINKS := [
	{
		"from": "res://scenes/rooms/combat_trial_room.tscn",
		"from_previous": "res://scenes/rooms/tutorial_room.tscn",
		"from_previous_spawn": &"tutorial_return",
		"left_exit": "LeftExitZone",
	},
	{
		"from": "res://scenes/rooms/goal_trial_room.tscn",
		"from_previous": "res://scenes/rooms/combat_trial_room.tscn",
		"from_previous_spawn": &"combat_return",
		"left_exit": "LeftExitZone",
	},
	{
		"from": "res://scenes/rooms/stage9_zone_entry_room.tscn",
		"from_previous": "res://scenes/rooms/goal_trial_room.tscn",
		"from_previous_spawn": &"goal_return",
		"left_exit": "LeftExitZone",
	},
	{
		"from": "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn",
		"from_previous": "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn",
		"from_previous_spawn": &"stage13_entry_return",
		"left_exit": "LeftExitZone",
	},
	{
		"from": "res://scenes/rooms/stage14_air_dash_gate_room.tscn",
		"from_previous": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn",
		"from_previous_spawn": &"stage14_shrine_return",
		"left_exit": "LeftExitZone",
	},
	{
		"from": "res://scenes/rooms/stage16_talisman_relay_room.tscn",
		"from_previous": "res://scenes/rooms/stage16_seal_release_threshold_room.tscn",
		"from_previous_spawn": &"stage16_seal_release_return",
		"left_exit": "LeftExitZone",
	},
]

const READABILITY_SCENES := [
	"res://scenes/rooms/tutorial_room.tscn",
	"res://scenes/rooms/goal_trial_room.tscn",
	"res://scenes/rooms/stage16_seal_release_threshold_room.tscn",
]

const GOAL_TRIAL_ROUTE_MARKER_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/023_equipment_pickup_atlas_ai01_auto_024_c02.atlas_texture.tres"


func test_project_uses_formal_demo_resolution_adaptation_settings() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode"), "canvas_items")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/aspect"), "expand")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/scale_mode"), "fractional")


func test_ordinary_rooms_expose_previous_room_contract() -> void:
	for link: Dictionary in ORDINARY_BIDIRECTIONAL_LINKS:
		var room := _instantiate_room(str(link.from))
		assert_not_null(room, "room loads: %s" % str(link.from))
		if room == null:
			continue

		assert_true(room.has_method("get_spawn_position"), "room has spawn contract")
		assert_not_null(room.get_node_or_null(str(link.left_exit)), "room has LeftExitZone")
		if room.get("previous_room_path") != null:
			assert_eq(str(room.get("previous_room_path")), str(link.from_previous))
			assert_eq(room.get("previous_spawn_id"), link.from_previous_spawn)
		room.queue_free()


func test_left_exit_zones_have_safe_return_spawn() -> void:
	for link: Dictionary in ORDINARY_BIDIRECTIONAL_LINKS:
		var room := _instantiate_room(str(link.from))
		if room == null:
			continue

		var left_exit := room.get_node_or_null(str(link.left_exit)) as Node2D
		assert_not_null(left_exit)
		if left_exit != null:
			var spawn: Vector2 = room.call("get_spawn_position", link.from_previous_spawn) if room.has_method("get_spawn_position") else Vector2.ZERO
			assert_lt(absf(spawn.y - left_exit.position.y), 160.0, "return spawn is vertically near left exit")
		room.queue_free()


func test_no_visible_solid_green_goal_ledge_or_gate_placeholder() -> void:
	for path: String in READABILITY_SCENES:
		var room := _instantiate_room(path)
		if room == null:
			continue

		for polygon: Polygon2D in _find_polygons(room):
			if not polygon.visible:
				continue

			var node_name := polygon.name.to_lower()
			var is_goal_or_gate := node_name.find("goal") >= 0 or node_name.find("barrier") >= 0 or node_name.find("ledge") >= 0
			var is_solid_green := polygon.color.g > 0.55 and polygon.color.r < 0.35 and polygon.color.a >= 0.5
			assert_false(is_goal_or_gate and is_solid_green, "%s has solid green placeholder polygon: %s" % [path, polygon.get_path()])
		room.queue_free()


func test_ordinary_room_floor_covers_transition_edges() -> void:
	for link: Dictionary in ORDINARY_BIDIRECTIONAL_LINKS:
		var room := _instantiate_room(str(link.from))
		if room == null:
			continue

		var left_exit := room.get_node_or_null(str(link.left_exit)) as Node2D
		var right_target := _get_right_transition_zone(room)
		var floor_edges := _get_walkable_floor_edges(room)

		assert_not_null(left_exit, "room has left return edge: %s" % str(link.from))
		assert_not_null(right_target, "room has right transition edge: %s" % str(link.from))
		assert_lt(floor_edges.x, floor_edges.y, "room has walkable floor coverage: %s" % str(link.from))
		if left_exit == null or right_target == null or floor_edges.x >= floor_edges.y:
			room.queue_free()
			continue

		assert_lte(floor_edges.x, left_exit.position.x + 36.0, "floor covers left return edge")
		assert_gte(floor_edges.y, right_target.position.x - 36.0, "floor covers right transition edge")
		room.queue_free()


func test_goal_trial_target_uses_formal_route_marker_art() -> void:
	var room := _instantiate_room("res://scenes/rooms/goal_trial_room.tscn")
	assert_not_null(room)
	if room == null:
		return

	var marker := room.get_node_or_null("GoalZone/GoalMarkerArt") as Sprite2D
	assert_not_null(marker, "GoalTrial target has visible route marker art")
	if marker == null:
		room.queue_free()
		return

	var trigger_visual := room.get_node_or_null("GoalZone/ZoneVisual") as Polygon2D
	assert_not_null(trigger_visual, "GoalTrial keeps trigger polygon only as hidden editor reference")
	if trigger_visual != null:
		assert_false(trigger_visual.visible)

	assert_eq(marker.get_meta("asset_id", ""), "equipment_pickup_atlas_ai01")
	assert_eq(marker.get_meta("runtime_source", ""), "equipment_pickup_atlas_ai01.demo_completion_token")
	assert_not_null(marker.texture)
	if marker.texture != null:
		assert_eq(marker.texture.resource_path, GOAL_TRIAL_ROUTE_MARKER_TEXTURE_PATH)
	assert_gte(marker.z_index, 2)
	assert_gte(marker.position.y, 24.0)
	assert_gte(marker.scale.x, 0.38)
	assert_gte(marker.scale.y, 0.38)
	assert_lte(marker.scale.x, 0.46)
	assert_lte(marker.scale.y, 0.46)
	room.queue_free()


func test_formal_terrain_visual_layers_align_to_static_floor_top() -> void:
	for link: Dictionary in ORDINARY_BIDIRECTIONAL_LINKS:
		var room := _instantiate_room(str(link.from))
		if room == null:
			continue

		for layer_name: String in ["FormalTerrainTilemapDecor", "FormalForegroundEdgeDecor"]:
			var layer := room.get_node_or_null(layer_name) as TileMapLayer
			assert_not_null(layer, "%s has %s" % [str(link.from), layer_name])
			if layer != null:
				assert_eq(layer.position, Vector2(0, 16), "%s visual terrain layer is collision-top aligned" % layer_name)
				assert_false(bool(layer.get("collision_enabled")), "%s remains visual-only" % layer_name)
		room.queue_free()


func test_tutorial_formal_terrain_does_not_turn_thin_platforms_into_solid_blocks() -> void:
	var room := _instantiate_room("res://scenes/rooms/tutorial_room.tscn")
	assert_not_null(room)
	if room == null:
		return

	var layer := room.get_node_or_null("FormalTerrainTilemapDecor") as TileMapLayer
	assert_not_null(layer, "tutorial room has formal terrain visual layer")
	if layer == null:
		room.queue_free()
		return

	assert_false(bool(layer.get("collision_enabled")), "formal terrain stays visual-only")
	for cell: Vector2i in layer.get_used_cells():
		assert_gte(cell.y, 2, "formal terrain must not paint tutorial thin platform / ceiling cells as full stone blocks")
	room.queue_free()


func _instantiate_room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed, "packed scene exists: %s" % path)
	if packed == null:
		return null

	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room


func _find_polygons(root: Node) -> Array[Polygon2D]:
	var result: Array[Polygon2D] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is Polygon2D:
			result.append(node as Polygon2D)
		for child: Node in node.get_children():
			stack.append(child)
	return result


func _get_right_transition_zone(room: Node) -> Node2D:
	var exit_zone := room.get_node_or_null("ExitZone") as Node2D
	if exit_zone != null:
		return exit_zone

	return room.get_node_or_null("GoalZone") as Node2D


# 正式房间读取 TileMap 实体覆盖，尚未重做的房间继续读取旧 Floor rectangle。
func _get_walkable_floor_edges(room: Node2D) -> Vector2:
	var terrain := room.get_node_or_null("TerrainCollisionVisual") as TileMapLayer
	if terrain != null and bool(terrain.get("collision_enabled")) and not terrain.get_used_cells().is_empty():
		var left := INF
		var right := -INF
		var tile_width := float(terrain.tile_set.tile_size.x) * absf(terrain.global_scale.x)
		for cell: Vector2i in terrain.get_used_cells():
			var cell_left := terrain.to_global(terrain.map_to_local(cell)).x
			left = minf(left, cell_left)
			right = maxf(right, cell_left + tile_width)
		return Vector2(left, right)

	var floor := room.get_node_or_null("Floor") as StaticBody2D
	var floor_shape := room.get_node_or_null("Floor/CollisionShape2D") as CollisionShape2D
	var rectangle := floor_shape.shape as RectangleShape2D if floor_shape != null else null
	if floor == null or rectangle == null:
		return Vector2.ZERO
	return Vector2(
		floor.position.x - rectangle.size.x * 0.5,
		floor.position.x + rectangle.size.x * 0.5
	)
