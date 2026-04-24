extends GutTest

# 阶段 8 回归测试保护系统收口层。
# 它验证玩家配置、房间 HUD 上下文与基础敌人模板契约已经稳定可复用。


const BASIC_ENEMY_CONFIG_SCRIPT_PATH := "res://scripts/configs/basic_enemy_config.gd"
const BASE_ENEMY_SCRIPT_PATH := "res://scripts/combat/base_enemy.gd"
const BASIC_ENEMY_SCENE_PATH := "res://scenes/combat/basic_melee_enemy.tscn"
const PLAYER_CONFIG_SCRIPT_PATH := "res://scripts/configs/player_config.gd"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const TUTORIAL_ROOM_SCENE_PATH := "res://scenes/rooms/tutorial_room.tscn"


func test_player_placeholder_applies_config_resource_and_exposes_hud_snapshot() -> void:
	var packed_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var player: CharacterBody2D = packed_scene.instantiate() as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame

	var config: Resource = player.get("player_config") as Resource
	var hud_snapshot: Dictionary = player.call("get_hud_status_snapshot")

	assert_not_null(config)
	assert_eq(config.get_script().resource_path, PLAYER_CONFIG_SCRIPT_PATH)
	assert_eq(player.call("get_max_health"), config.get("max_health"))
	assert_eq(player.call("get_current_health"), config.get("max_health"))
	assert_true(hud_snapshot.has("current_health"))
	assert_true(hud_snapshot.has("max_health"))
	assert_true(hud_snapshot.has("dash_ready"))
	assert_true(hud_snapshot.has("dash_cooldown_remaining"))


func test_tutorial_room_exposes_hud_context_from_flow_config() -> void:
	var packed_scene: PackedScene = load(TUTORIAL_ROOM_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var room: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame

	var hud_context: Dictionary = room.call("get_hud_context")
	var flow_config: Resource = room.get("flow_config") as Resource

	assert_not_null(flow_config)
	assert_eq(hud_context.get("step_title"), room.call("get_current_step_title"))
	assert_eq(hud_context.get("prompt_text"), room.call("get_current_prompt_text"))
	assert_eq(hud_context.get("dash_available"), room.call("is_dash_available_in_hud"))
	assert_eq(room.call("get_spawn_position", &"tutorial_start"), flow_config.call("get_spawn_position", &"tutorial_start", Vector2.ZERO))


func test_basic_melee_enemy_applies_config_resource_values() -> void:
	var packed_scene: PackedScene = load(BASIC_ENEMY_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var enemy: Node = packed_scene.instantiate()
	add_child_autofree(enemy)
	await get_tree().process_frame

	var config: Resource = enemy.get("config") as Resource

	assert_not_null(config)
	assert_eq(config.get_script().resource_path, BASIC_ENEMY_CONFIG_SCRIPT_PATH)
	assert_eq(enemy.call("get_patrol_distance"), config.get("patrol_distance"))
	assert_eq(enemy.call("get_patrol_speed"), config.get("patrol_speed"))
	assert_eq(enemy.call("get_touch_damage"), config.get("touch_damage"))


func test_basic_melee_enemy_exposes_single_config_entry_in_editor() -> void:
	var file := FileAccess.open("res://scripts/combat/basic_melee_enemy.gd", FileAccess.READ)

	assert_not_null(file)

	var source := file.get_as_text()

	assert_string_contains(source, "@export var config: BasicEnemyConfig")
	assert_false(source.contains("@export var patrol_distance"))
	assert_false(source.contains("@export var patrol_speed"))
	assert_false(source.contains("@export var touch_damage"))


func test_basic_melee_enemy_keeps_base_enemy_contract() -> void:
	var packed_scene: PackedScene = load(BASIC_ENEMY_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var enemy: Node = packed_scene.instantiate()
	add_child_autofree(enemy)
	await get_tree().process_frame

	assert_eq(enemy.get_script().get_base_script().resource_path, BASE_ENEMY_SCRIPT_PATH)
	assert_true(enemy.has_signal("defeated"))
	assert_true(enemy.has_method("receive_attack"))

	enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await get_tree().process_frame

	assert_true(enemy.call("is_defeated"))
