extends GutTest

# 阶段 18 宏观银河城回归：保护三区域环路、远端捷径、持久探索收益和锚点房职责。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"

const STAGE9_SWITCH := "res://scenes/rooms/stage9_zone_switch_room.tscn"
const STAGE9_FINAL := "res://scenes/rooms/stage9_zone_final_room.tscn"
const STAGE10_AERIAL := "res://scenes/rooms/stage10_zone_aerial_room.tscn"
const STAGE10_BRANCH := "res://scenes/rooms/stage10_zone_branch_room.tscn"
const STAGE13_ENTRY := "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"
const STAGE13_CHECKPOINT := "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"
const STAGE13_RESOURCE := "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"
const STAGE13_CHALLENGE := "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn"
const STAGE13_GOAL := "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"
const STAGE13_GATE := "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"
const STAGE14_GATE := "res://scenes/rooms/stage14_air_dash_gate_room.tscn"
const STAGE14_HUB := "res://scenes/rooms/stage14_backtrack_hub_room.tscn"
const STAGE14_LOOP_RETURN := "res://scenes/rooms/stage14_loop_return_room.tscn"
const STAGE15_PRESSURE := "res://scenes/rooms/stage15_seal_pressure_room.tscn"
const STAGE15_GAUNTLET := "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn"
const STAGE15_CHALLENGE := "res://scenes/rooms/stage15_challenge_branch_room.tscn"

const SHORTCUT_LINKS := [
	{
		"from": STAGE9_SWITCH,
		"target": STAGE10_BRANCH,
		"spawn": &"stage10_branch_from_stage9_shortcut",
		"air_dash": false,
		"reward": StringName(),
	},
	{
		"from": STAGE10_AERIAL,
		"target": STAGE13_ENTRY,
		"spawn": &"stage13_entry_from_stage10_shortcut",
		"air_dash": true,
		"reward": StringName(),
	},
	{
		"from": STAGE13_ENTRY,
		"target": STAGE10_AERIAL,
		"spawn": &"stage10_aerial_from_stage13_shortcut",
		"air_dash": true,
		"reward": StringName(),
	},
	{
		"from": STAGE14_HUB,
		"target": STAGE15_CHALLENGE,
		"spawn": &"stage15_challenge_from_stage14_shortcut",
		"air_dash": false,
		"reward": &"warden_sigil",
	},
	{
		"from": STAGE13_GATE,
		"target": STAGE14_GATE,
		"spawn": &"stage14_gate_from_wind_cross",
		"air_dash": true,
		"reward": &"wind_seal",
	},
	{
		"from": STAGE14_GATE,
		"target": STAGE13_GATE,
		"spawn": &"stage13_gate_from_wind_cross",
		"air_dash": true,
		"reward": &"wind_seal",
	},
]

const ANCHOR_REQUIREMENTS := [
	{"path": "res://scenes/rooms/tutorial_room.tscn", "node": "NarrativeStele"},
	{"path": "res://scenes/rooms/stage9_zone_entry_room.tscn", "node": "RegionCheckpoint"},
	{"path": STAGE9_SWITCH, "node": "ShortcutZone"},
	{"path": STAGE10_AERIAL, "node": "ShortcutZone"},
	{"path": STAGE10_BRANCH, "node": "SecretWall"},
	{"path": STAGE13_ENTRY, "node": "NarrativeStele"},
	{"path": "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn", "node": "SealNode"},
	{"path": "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn", "node": "ResourceBranchZone"},
	{"path": STAGE13_RESOURCE, "node": "SecretWall"},
	{"path": STAGE13_CHALLENGE, "node": "MiasmaHazard"},
	{"path": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn", "node": "NarrativeStele"},
	{"path": STAGE14_HUB, "node": "ShortcutZone"},
	{"path": STAGE15_CHALLENGE, "node": "ChallengeBackgroundArt"},
]


func test_world_graph_declares_three_region_loops_and_six_remote_connections() -> void:
	for link: Dictionary in SHORTCUT_LINKS:
		var room := await _spawn_room(str(link.from))
		_assert_shortcut_contract(room, link)

	var stage10_branch := await _spawn_room(STAGE10_BRANCH)
	assert_eq(stage10_branch.get("previous_room_path"), STAGE9_SWITCH, "环路 A 返回 Stage9 Switch")

	var resource_branch := await _spawn_room(STAGE13_RESOURCE)
	assert_eq(resource_branch.get("next_room_path"), STAGE13_CHECKPOINT, "资源支路回到旧 checkpoint")

	var challenge_branch := await _spawn_room(STAGE13_CHALLENGE)
	assert_eq(challenge_branch.get("next_room_path"), STAGE13_GOAL, "挑战支路前送到区域目标")

	var stage15_challenge := await _spawn_room(STAGE15_CHALLENGE)
	assert_eq(stage15_challenge.get("previous_room_path"), STAGE14_HUB, "环路 C 返回 Stage14 Hub")


func test_world_graph_contains_three_closed_region_cycles() -> void:
	var loops := [
		[STAGE9_SWITCH, STAGE9_FINAL, STAGE10_AERIAL, STAGE10_BRANCH, STAGE9_SWITCH],
		[STAGE13_CHECKPOINT, "res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn", "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn", STAGE13_RESOURCE, STAGE13_CHECKPOINT],
		[STAGE14_HUB, STAGE14_LOOP_RETURN, STAGE15_PRESSURE, STAGE15_GAUNTLET, STAGE15_CHALLENGE, STAGE14_HUB],
	]

	for loop: Array in loops:
		for index in range(loop.size() - 1):
			var source := str(loop[index])
			var target := str(loop[index + 1])
			assert_true(await _room_links_to(source, target), "环路缺边：%s -> %s" % [source, target])


func test_stage13_branches_have_distinct_risk_exit_and_persistent_reward() -> void:
	var resource_branch := await _spawn_room(STAGE13_RESOURCE)
	var challenge_branch := await _spawn_room(STAGE13_CHALLENGE)

	assert_eq(resource_branch.get("next_room_path"), STAGE13_CHECKPOINT)
	assert_eq(challenge_branch.get("next_room_path"), STAGE13_GOAL)
	assert_eq(resource_branch.get("persistent_reward_id"), &"marsh_relic")
	assert_eq(challenge_branch.get("persistent_reward_id"), &"warden_sigil")
	assert_null(resource_branch.get_node_or_null("MiasmaHazard"), "资源支路保持低压探索")
	assert_not_null(challenge_branch.get_node_or_null("MiasmaHazard"), "挑战支路保留危险区")
	assert_true(bool(challenge_branch.get("require_all_enemies_defeated")), "挑战支路必须清场")


func test_main_persists_exploration_rewards_across_room_changes_and_resets_on_restart() -> void:
	var main := await _spawn_main()
	assert_true(main.has_method("collect_exploration_reward"))
	assert_true(main.has_method("has_exploration_reward"))
	assert_true(main.has_method("get_exploration_reward_count"))
	if not main.has_method("collect_exploration_reward"):
		return

	main.call("collect_exploration_reward", &"marsh_relic")
	main.call("transition_to_room", STAGE13_ENTRY, &"stage13_entry_start")
	assert_true(bool(main.call("has_exploration_reward", &"marsh_relic")))
	assert_eq(int(main.call("get_exploration_reward_count")), 1)

	main.call("restart_demo")
	assert_false(bool(main.call("has_exploration_reward", &"marsh_relic")))
	assert_eq(int(main.call("get_exploration_reward_count")), 0)


func test_stage9_shortcut_is_available_as_early_second_route() -> void:
	var room := await _spawn_room(STAGE9_SWITCH)
	var player := await _spawn_player()
	var transitions: Array[Dictionary] = []

	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	player.global_position = (room.get_node("ShortcutZone") as Node2D).global_position

	await _advance_process_frames(3)
	assert_eq(transitions.size(), 1)
	if not transitions.is_empty():
		assert_eq(transitions[0].target, STAGE10_BRANCH)
		assert_eq(transitions[0].spawn, &"stage10_branch_from_stage9_shortcut")


func test_stage10_air_dash_shortcut_reopens_seen_cross_region_route() -> void:
	var room := await _spawn_room(STAGE10_AERIAL)
	var player := await _spawn_player()
	var transitions: Array[Dictionary] = []

	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	player.global_position = (room.get_node("ShortcutZone") as Node2D).global_position

	await _advance_process_frames(3)
	assert_true(transitions.is_empty(), "Stage10 旧上层路线在 Air Dash 前保持关闭")

	player.call("set_air_dash_unlocked", true)
	await _advance_process_frames(3)
	assert_eq(transitions.size(), 1)
	if not transitions.is_empty():
		assert_eq(transitions[0].target, STAGE13_ENTRY)
		assert_eq(transitions[0].spawn, &"stage13_entry_from_stage10_shortcut")


func test_stage13_rewards_write_distinct_long_term_state() -> void:
	var main := await _spawn_main()
	var player := await _spawn_player()
	var resource_branch := await _spawn_room(STAGE13_RESOURCE)
	resource_branch.call("bind_main", main)
	resource_branch.call("bind_player", player)
	player.global_position = (resource_branch.get_node("Stage13Reward") as Node2D).global_position
	await _advance_process_frames(3)
	assert_true(bool(main.call("has_exploration_reward", &"marsh_relic")))

	resource_branch.queue_free()
	await get_tree().process_frame
	var challenge_branch := await _spawn_room(STAGE13_CHALLENGE)
	challenge_branch.call("bind_main", main)
	challenge_branch.call("bind_player", player)
	player.global_position = (challenge_branch.get_node("Stage13Reward") as Node2D).global_position
	await _advance_process_frames(3)
	assert_true(bool(main.call("has_exploration_reward", &"warden_sigil")))
	assert_eq(int(main.call("get_exploration_reward_count")), 2)


func test_stage14_high_risk_shortcut_requires_warden_sigil() -> void:
	var main := await _spawn_main()
	var room := await _spawn_room(STAGE14_HUB)
	var player := await _spawn_player()
	var transitions: Array[Dictionary] = []

	room.call("bind_main", main)
	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	player.global_position = (room.get_node("ShortcutZone") as Node2D).global_position

	await _advance_process_frames(3)
	assert_true(transitions.is_empty(), "未取得挑战符时高风险捷径关闭")

	main.call("collect_exploration_reward", &"warden_sigil")
	await _advance_process_frames(3)
	assert_eq(transitions.size(), 1)
	if not transitions.is_empty():
		assert_eq(transitions[0].target, STAGE15_CHALLENGE)
		assert_eq(transitions[0].spawn, &"stage15_challenge_from_stage14_shortcut")


func test_narrative_stele_temporarily_replaces_room_prompt() -> void:
	var room := await _spawn_room(STAGE13_ENTRY)
	var player := await _spawn_player()
	room.call("bind_player", player)
	var default_title := str(room.call("get_current_step_title"))

	player.global_position = (room.get_node("NarrativeStele") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq(str(room.call("get_current_step_title")), "瘴泽镇界碑")
	assert_true(str(room.call("get_current_prompt_text")).contains("镇妖卫旧记"))

	player.global_position = Vector2(-256, 204)
	await _advance_process_frames(2)
	assert_eq(str(room.call("get_current_step_title")), default_title)


func test_anchor_rooms_expose_secret_mechanism_narrative_or_landmark_nodes() -> void:
	for requirement: Dictionary in ANCHOR_REQUIREMENTS:
		var room := await _spawn_room(str(requirement.path))
		assert_not_null(
			room.get_node_or_null(str(requirement.node)),
			"锚点房缺少职责节点：%s/%s" % [str(requirement.path), str(requirement.node)]
		)


func test_all_formal_room_platforms_use_thin_one_way_collision_matching_visible_cells() -> void:
	var directory := DirAccess.open("res://scenes/rooms")
	assert_not_null(directory)
	if directory == null:
		return

	var checked_rooms := 0
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		if not directory.current_is_dir() and file_name.ends_with(".tscn"):
			var path := "res://scenes/rooms/%s" % file_name
			var packed := load(path) as PackedScene
			var room := packed.instantiate() as Node2D if packed != null else null
			assert_not_null(room, "房间场景可实例化：%s" % path)
			if room != null:
				var platform := room.get_node_or_null("PlatformCollisionVisual") as TileMapLayer
				var thin_surface := room.get_node_or_null("ThinPlatformSurfaceVisual") as TileMapLayer
				if platform != null:
					checked_rooms += 1
					assert_not_null(thin_surface, "薄平台碰撞必须有对应可见表面：%s" % path)
					var visible_cells := thin_surface.get_used_cells() if thin_surface != null else []
					for cell: Vector2i in platform.get_used_cells():
						assert_true(cell in visible_cells, "薄平台视觉与碰撞格坐标一致：%s %s" % [path, cell])
						var tile_data := _tile_data(platform, cell)
						assert_not_null(tile_data, "薄平台格必须有 TileData：%s %s" % [path, cell])
						if tile_data != null:
							assert_eq(tile_data.get_collision_polygons_count(0), 1)
							assert_true(tile_data.is_collision_polygon_one_way(0, 0), "上层薄台必须允许从下方穿过：%s %s" % [path, cell])
							var points := tile_data.get_collision_polygon_points(0, 0)
							var min_y := INF
							var max_y := -INF
							for point: Vector2 in points:
								min_y = minf(min_y, point.y)
								max_y = maxf(max_y, point.y)
							assert_lte((max_y - min_y) * absf(platform.scale.y), 4.0, "薄平台碰撞厚度不得退化成整块实心砖：%s %s" % [path, cell])
				room.free()
		file_name = directory.get_next()
	directory.list_dir_end()
	assert_gte(checked_rooms, 34, "至少覆盖当前 34 房正式关卡")


func test_secret_walls_reuse_receive_attack_contract() -> void:
	for room_path: String in [STAGE10_BRANCH, STAGE13_RESOURCE]:
		var room := await _spawn_room(room_path)
		var secret_wall := room.get_node_or_null("SecretWall") as StaticBody2D
		assert_not_null(secret_wall)
		if secret_wall == null:
			continue

		assert_true(secret_wall.has_method("receive_attack"))
		var shape := secret_wall.get_node_or_null("CollisionShape2D") as CollisionShape2D
		var wall_mass_art := secret_wall.get_node_or_null("WallMassArt") as Sprite2D
		assert_not_null(shape)
		assert_not_null(wall_mass_art)
		if shape != null and shape.shape is RectangleShape2D and wall_mass_art != null:
			var wall_shape := shape.shape as RectangleShape2D
			assert_eq(
				wall_mass_art.region_rect.size * wall_mass_art.scale,
				wall_shape.size,
				"秘密墙的可见实体必须与碰撞边界一致"
			)

		secret_wall.call("receive_attack", Vector2.RIGHT, 120.0)
		await get_tree().process_frame
		assert_false(secret_wall.visible)
		if shape != null:
			assert_true(shape.disabled)


func _assert_shortcut_contract(room: Node2D, expected: Dictionary) -> void:
	assert_not_null(room.get_node_or_null("ShortcutZone"), "捷径入口必须可见且可触发")
	for property_name: String in ["shortcut_room_path", "shortcut_spawn_id", "shortcut_requires_air_dash", "shortcut_required_reward_id"]:
		assert_true(_has_property(room, property_name), "缺少捷径导出字段：%s" % property_name)
	if not _has_property(room, "shortcut_room_path"):
		return

	assert_eq(room.get("shortcut_room_path"), expected.target)
	assert_eq(room.get("shortcut_spawn_id"), expected.spawn)
	assert_eq(room.get("shortcut_requires_air_dash"), expected.air_dash)
	assert_eq(room.get("shortcut_required_reward_id"), expected.reward)


func _has_property(target: Object, property_name: String) -> bool:
	for property: Dictionary in target.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false


func _tile_data(layer: TileMapLayer, cell: Vector2i) -> TileData:
	var source := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
	if source == null:
		return null
	return source.get_tile_data(layer.get_cell_atlas_coords(cell), 0)


func _room_links_to(source_path: String, target_path: String) -> bool:
	var room := await _spawn_room(source_path)
	for property_name: String in ["next_room_path", "previous_room_path", "shortcut_room_path", "optional_branch_room_path", "resource_branch_room_path", "challenge_branch_room_path"]:
		if _has_property(room, property_name) and str(room.get(property_name)) == target_path:
			return true
	return false


func _spawn_room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed, "房间场景存在：%s" % path)
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


func _spawn_main() -> Node2D:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	return main


func _spawn_player() -> CharacterBody2D:
	var packed := load(PLAYER_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var player := packed.instantiate() as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	return player


func _advance_process_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame
