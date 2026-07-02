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
