extends GutTest

# 阶段 13 回归测试保护第二小区域内容生产的完整边界。
# 本 suite 先锁定“生物废液区 + 10 主线房 + 2 支路”的生产契约，
# 再覆盖孢子投射敌、废液危险、净化门控、checkpoint、资产清单和灰盒主路径。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const STAGE11_DEMO_END_ROOM_SCENE_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const SPORE_SHOOTER_SCENE_PATH := "res://scenes/combat/spore_shooter_enemy.tscn"
const SPORE_SHOOTER_CONFIG_SCRIPT_PATH := "res://scripts/configs/spore_shooter_enemy_config.gd"
const ASSET_MANIFEST_PATH := "res://docs/assets/asset-manifest.md"

const STAGE13_MAIN_ROOM_PATHS := [
	"res://scenes/rooms/stage13_bio_waste_entry_room.tscn",
	"res://scenes/rooms/stage13_bio_waste_spore_room.tscn",
	"res://scenes/rooms/stage13_bio_waste_acid_room.tscn",
	"res://scenes/rooms/stage13_bio_waste_gate_room.tscn",
	"res://scenes/rooms/stage13_bio_waste_crossfire_room.tscn",
	"res://scenes/rooms/stage13_bio_waste_checkpoint_room.tscn",
	"res://scenes/rooms/stage13_bio_waste_pressure_room.tscn",
	"res://scenes/rooms/stage13_bio_waste_branch_hub_room.tscn",
	"res://scenes/rooms/stage13_bio_waste_return_room.tscn",
	"res://scenes/rooms/stage13_bio_waste_goal_room.tscn",
]

const STAGE13_RESOURCE_BRANCH_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_resource_branch_room.tscn"
const STAGE13_CHALLENGE_BRANCH_ROOM_PATH := "res://scenes/rooms/stage13_bio_waste_challenge_branch_room.tscn"


func test_stage13_area_declares_ten_main_rooms_and_two_branches() -> void:
	for room_path in STAGE13_MAIN_ROOM_PATHS:
		assert_not_null(load(room_path), "缺少 Stage 13 主线房间：%s" % room_path)

	assert_not_null(load(STAGE13_RESOURCE_BRANCH_ROOM_PATH))
	assert_not_null(load(STAGE13_CHALLENGE_BRANCH_ROOM_PATH))

	var entry_room := await _spawn_room(STAGE13_MAIN_ROOM_PATHS[0])
	var hub_room := await _spawn_room(STAGE13_MAIN_ROOM_PATHS[7])

	assert_eq(entry_room.get("next_room_path"), STAGE13_MAIN_ROOM_PATHS[1])
	assert_eq(hub_room.call("get_resource_branch_room_path"), STAGE13_RESOURCE_BRANCH_ROOM_PATH)
	assert_eq(hub_room.call("get_challenge_branch_room_path"), STAGE13_CHALLENGE_BRANCH_ROOM_PATH)


func test_stage11_demo_end_continue_zone_links_into_stage13_entry_room_after_demo_completion() -> void:
	var room := await _spawn_room(STAGE11_DEMO_END_ROOM_SCENE_PATH)
	var player := await _spawn_player(Vector2.ZERO)
	var transitions: Array = []

	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target_room_path: String, spawn_id: StringName) -> void:
		transitions.append({"target": target_room_path, "spawn": spawn_id})
	)

	player.global_position = room.get_node("GoalZone").global_position
	await _advance_process_frames(4)

	assert_true(room.call("is_demo_goal_finished"))

	player.global_position = room.get_node("ContinueZone").global_position
	await _advance_process_frames(4)

	assert_eq(transitions.size(), 1)
	assert_eq(transitions[0].get("target"), STAGE13_MAIN_ROOM_PATHS[0])
	assert_eq(transitions[0].get("spawn"), &"stage13_entry_start")


func test_spore_shooter_enemy_uses_config_and_exposes_ranged_pressure_contract() -> void:
	var packed_scene: PackedScene = load(SPORE_SHOOTER_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var enemy: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(enemy)
	await get_tree().process_frame

	var config: Resource = enemy.get("config") as Resource

	assert_not_null(config)
	assert_eq(config.get_script().resource_path, SPORE_SHOOTER_CONFIG_SCRIPT_PATH)
	assert_true(enemy.has_method("get_projectile_range"))
	assert_gt(enemy.call("get_projectile_range"), 120.0)
	assert_gt(enemy.call("get_spore_pressure_radius"), 32.0)
	assert_eq(enemy.call("get_touch_damage"), config.get("touch_damage"))


func test_acid_hazard_damages_player_without_breaking_checkpoint_recovery() -> void:
	var room := await _spawn_room(STAGE13_MAIN_ROOM_PATHS[2])
	var player := await _spawn_player(Vector2.ZERO)

	room.call("bind_player", player)
	player.global_position = room.get_node("AcidHazard").global_position
	await _advance_process_frames(2)

	assert_lt(player.call("get_current_health"), player.call("get_max_health"))
	assert_true(room.call("has_acid_hazard"))
	assert_true(room.call("should_reset_on_player_defeat"))


func test_purification_gate_starts_locked_and_unlocks_after_node_activation() -> void:
	var room := await _spawn_room(STAGE13_MAIN_ROOM_PATHS[3])
	var player := await _spawn_player(Vector2.ZERO)

	room.call("bind_player", player)

	assert_false(room.call("is_gate_unlocked"))
	assert_true(room.call("has_purification_gate"))

	player.global_position = room.get_node("PurificationNode").global_position
	await _advance_process_frames(3)

	assert_true(room.call("is_gate_unlocked"))
	assert_true(room.call("is_purification_node_activated"))


func test_stage13_branches_provide_distinct_reward_roles_and_return_to_mainline() -> void:
	var resource_room := await _spawn_room(STAGE13_RESOURCE_BRANCH_ROOM_PATH)
	var challenge_room := await _spawn_room(STAGE13_CHALLENGE_BRANCH_ROOM_PATH)
	var player := await _spawn_player(Vector2.ZERO)

	resource_room.call("bind_player", player)
	challenge_room.call("bind_player", player)

	assert_true(resource_room.call("is_resource_reward_branch"))
	assert_true(challenge_room.call("is_challenge_reward_branch"))

	resource_room.call("collect_stage13_reward", &"resource_branch_reward")
	challenge_room.call("collect_stage13_reward", &"challenge_branch_reward")

	assert_eq(resource_room.call("get_stage13_progress_snapshot").get("branch_reward_count"), 1)
	assert_eq(challenge_room.call("get_stage13_progress_snapshot").get("branch_reward_count"), 1)
	assert_eq(resource_room.get("next_room_path"), STAGE13_MAIN_ROOM_PATHS[8])
	assert_eq(challenge_room.get("next_room_path"), STAGE13_MAIN_ROOM_PATHS[8])


func test_stage13_asset_manifest_contains_bio_waste_requirements() -> void:
	var manifest := _read_text_file(ASSET_MANIFEST_PATH)
	var required_terms := [
		"stage13_bio_waste_biome_reference",
		"stage13_bio_waste_tiles",
		"stage13_purification_gate",
		"stage13_purification_node",
		"stage13_spore_shooter_silhouette",
		"stage13_acid_hazard_warning",
		"stage13_bio_waste_goal_device",
	]

	for term in required_terms:
		assert_string_contains(manifest, term)


func test_stage13_graybox_driver_can_reach_second_zone_goal_from_main_scene() -> void:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await _advance_process_frames(2)
	main_scene.call("transition_to_room", STAGE11_DEMO_END_ROOM_SCENE_PATH, &"stage11_demo_end_start")
	await _advance_process_frames(2)

	var reached_goal := await _drive_to_stage13_goal(main_scene)

	assert_true(reached_goal)
	assert_eq((main_scene.get_node("Room") as Node2D).scene_file_path, STAGE13_MAIN_ROOM_PATHS[9])


func _drive_to_stage13_goal(main_scene: Node2D) -> bool:
	var safety := 0
	while safety < 40:
		safety += 1
		var room: Node2D = main_scene.get_node_or_null("Room") as Node2D
		var player: CharacterBody2D = main_scene.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
		if room == null or player == null:
			return false

		if room.scene_file_path == STAGE13_MAIN_ROOM_PATHS[9]:
			return true

		if room.scene_file_path == STAGE11_DEMO_END_ROOM_SCENE_PATH:
			var goal_zone: Node2D = room.get_node_or_null("GoalZone") as Node2D
			var continue_zone: Node2D = room.get_node_or_null("ContinueZone") as Node2D
			if goal_zone == null or continue_zone == null:
				return false
			player.global_position = goal_zone.global_position
			await _advance_process_frames(4)
			player.global_position = continue_zone.global_position
			await _advance_process_frames(4)
			continue

		for child in room.get_children():
			if child.has_method("receive_attack"):
				child.call("receive_attack", Vector2.RIGHT, 120.0)

		if room.has_method("unlock_gate"):
			room.call("unlock_gate", &"clear")

		if room.has_method("activate_purification_node"):
			room.call("activate_purification_node")

		var goal_zone: Node2D = room.get_node_or_null("GoalZone") as Node2D
		var exit_zone: Node2D = room.get_node_or_null("ExitZone") as Node2D
		var target_zone := goal_zone if goal_zone != null else exit_zone
		if target_zone == null:
			return false

		player.global_position = target_zone.global_position
		await _advance_process_frames(4)

	return false


func _spawn_room(scene_path: String) -> Node2D:
	var packed_scene: PackedScene = load(scene_path) as PackedScene

	assert_not_null(packed_scene)

	var room: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


func _spawn_player(spawn_position: Vector2) -> CharacterBody2D:
	var player_scene: PackedScene = load("res://scenes/player/player_placeholder.tscn") as PackedScene

	assert_not_null(player_scene)

	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	add_child_autofree(player)
	player.global_position = spawn_position
	await get_tree().process_frame
	return player


func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


func _read_text_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "无法读取文件：%s" % path)
	return file.get_as_text() if file != null else ""
