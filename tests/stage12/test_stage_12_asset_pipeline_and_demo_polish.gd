extends GutTest
const Stage11GrayboxMainlineDriver := preload("res://tests/stage11/support/stage11_graybox_mainline_driver.gd")

# 阶段 12 回归测试保护“资产管线 + 第一轮 Demo 表现升级”的最小闭环。
# 它验证资产目录与清单已经落地，轻量可读性节点已经接入，
# 同时确认 Stage 11 灰盒主线仍能作为后续内容生产的稳定基线。

const ASSET_MANIFEST_PATH := "res://docs/assets/asset-manifest.md"
const ASSET_INGESTION_CHECKLIST_PATH := "res://docs/assets/asset-ingestion-checklist.md"
const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const BASIC_ENEMY_SCENE_PATH := "res://scenes/combat/basic_melee_enemy.tscn"
const GROUND_CHARGER_SCENE_PATH := "res://scenes/combat/ground_charger_enemy.tscn"
const AERIAL_SENTINEL_SCENE_PATH := "res://scenes/combat/aerial_sentinel_enemy.tscn"
const HUD_SCENE_PATH := "res://scenes/ui/tutorial_hud.tscn"
const STAGE9_SWITCH_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_switch_room.tscn"

const PLAYER_SILHOUETTE_ASSET_PATH := "res://assets/art/characters/player/stage12_player_silhouette.svg"
const BASIC_MELEE_SILHOUETTE_ASSET_PATH := "res://assets/art/characters/enemies/stage12_basic_melee_silhouette.svg"
const GROUND_CHARGER_SILHOUETTE_ASSET_PATH := "res://assets/art/characters/enemies/stage12_ground_charger_silhouette.svg"
const AERIAL_SENTINEL_SILHOUETTE_ASSET_PATH := "res://assets/art/characters/enemies/stage12_aerial_sentinel_silhouette.svg"
const CHECKPOINT_GATE_GOAL_ASSET_PATH := "res://assets/art/ui/stage12_checkpoint_gate_goal_icons.svg"
const SLASH_VFX_ASSET_PATH := "res://assets/art/vfx/stage12_slash_vfx.svg"
const HIT_SPARK_VFX_ASSET_PATH := "res://assets/art/vfx/stage12_hit_spark_vfx.svg"


func test_stage12_asset_pipeline_docs_and_directories_exist() -> void:
	var required_directories := [
		"res://assets/art/characters/player",
		"res://assets/art/characters/enemies",
		"res://assets/art/environment/biome_01_lab",
		"res://assets/art/vfx",
		"res://assets/art/ui",
		"res://assets/audio/sfx",
		"res://assets/audio/music",
		"res://assets/source/references",
		"res://assets/source/ai_generated",
		"res://assets/source/editable",
	]

	for directory_path in required_directories:
		assert_true(DirAccess.dir_exists_absolute(directory_path), "缺少资产目录：%s" % directory_path)

	assert_true(FileAccess.file_exists(ASSET_MANIFEST_PATH))
	assert_true(FileAccess.file_exists(ASSET_INGESTION_CHECKLIST_PATH))


func test_stage12_manifest_contains_required_fields_and_first_batch_entries() -> void:
	var manifest := _read_text_file(ASSET_MANIFEST_PATH)
	var required_terms := [
		"资产 ID",
		"用途",
		"目标路径",
		"尺寸 / 规格",
		"来源",
		"授权状态",
		"当前状态",
		"接入阶段",
		"替换优先级",
		"placeholder_ready",
		"integrated",
		"stage12_player_silhouette",
		"stage12_basic_melee_silhouette",
		"stage12_ground_charger_silhouette",
		"stage12_aerial_sentinel_silhouette",
		"stage12_slash_vfx",
		"stage12_checkpoint_gate_goal_icons",
	]

	for term in required_terms:
		assert_string_contains(manifest, term)


func test_stage12_ingestion_checklist_covers_required_review_points() -> void:
	var checklist := _read_text_file(ASSET_INGESTION_CHECKLIST_PATH)
	var required_terms := [
		"导入",
		"路径",
		"显示",
		"碰撞",
		"HUD",
		"自动化",
		"授权",
		"人工复核",
	]

	for term in required_terms:
		assert_string_contains(checklist, term)


func test_stage12_player_and_enemy_scenes_keep_collision_contract_and_gain_visual_markers() -> void:
	await _assert_scene_has_nodes(PLAYER_SCENE_PATH, [
		"CollisionShape2D",
		"Body",
		"Stage12Silhouette",
		"Stage12HelmetMark",
		"Stage12AssetSprite",
		"Stage12SlashPreview",
	])
	await _assert_scene_has_nodes(BASIC_ENEMY_SCENE_PATH, [
		"CollisionShape2D",
		"Hurtbox",
		"Stage12Silhouette",
		"Stage12ThreatMark",
		"Stage12AssetSprite",
		"Stage12HitSpark",
	])
	await _assert_scene_has_nodes(GROUND_CHARGER_SCENE_PATH, [
		"CollisionShape2D",
		"Hurtbox",
		"Stage12Silhouette",
		"Stage12ChargeMark",
		"Stage12AssetSprite",
		"Stage12HitSpark",
	])
	await _assert_scene_has_nodes(AERIAL_SENTINEL_SCENE_PATH, [
		"CollisionShape2D",
		"Hurtbox",
		"Stage12Silhouette",
		"Stage12AirMark",
		"Stage12AssetSprite",
		"Stage12HitSpark",
	])


func test_stage12_hud_contains_polish_icons_and_keeps_demo_completion_feedback() -> void:
	var packed_scene: PackedScene = load(HUD_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)

	var hud: Control = packed_scene.instantiate() as Control
	add_child_autofree(hud)
	await get_tree().process_frame

	assert_not_null(hud.get_node_or_null("BattlePanel/HealthIcon"))
	assert_not_null(hud.get_node_or_null("BattlePanel/DashIcon"))
	assert_not_null(hud.get_node_or_null("BattlePanel/ObjectiveIcon"))
	assert_string_contains((hud.get_node("BattlePanel/StatusLabel") as Label).text, "生命")
	assert_string_contains((hud.get_node("BattlePanel/DashLabel") as Label).text, "冲刺")


func test_stage12_registered_svg_assets_are_loadable_and_referenced_by_scenes() -> void:
	var asset_paths := [
		PLAYER_SILHOUETTE_ASSET_PATH,
		BASIC_MELEE_SILHOUETTE_ASSET_PATH,
		GROUND_CHARGER_SILHOUETTE_ASSET_PATH,
		AERIAL_SENTINEL_SILHOUETTE_ASSET_PATH,
		CHECKPOINT_GATE_GOAL_ASSET_PATH,
		SLASH_VFX_ASSET_PATH,
		HIT_SPARK_VFX_ASSET_PATH,
	]

	for asset_path in asset_paths:
		assert_not_null(load(asset_path), "无法加载资产：%s" % asset_path)

	_assert_file_contains(PLAYER_SCENE_PATH, PLAYER_SILHOUETTE_ASSET_PATH)
	_assert_file_contains(BASIC_ENEMY_SCENE_PATH, BASIC_MELEE_SILHOUETTE_ASSET_PATH)
	_assert_file_contains(GROUND_CHARGER_SCENE_PATH, GROUND_CHARGER_SILHOUETTE_ASSET_PATH)
	_assert_file_contains(AERIAL_SENTINEL_SCENE_PATH, AERIAL_SENTINEL_SILHOUETTE_ASSET_PATH)
	_assert_file_contains(PLAYER_SCENE_PATH, SLASH_VFX_ASSET_PATH)
	_assert_file_contains(BASIC_ENEMY_SCENE_PATH, HIT_SPARK_VFX_ASSET_PATH)
	_assert_file_contains(GROUND_CHARGER_SCENE_PATH, HIT_SPARK_VFX_ASSET_PATH)
	_assert_file_contains(AERIAL_SENTINEL_SCENE_PATH, HIT_SPARK_VFX_ASSET_PATH)
	_assert_file_contains(HUD_SCENE_PATH, CHECKPOINT_GATE_GOAL_ASSET_PATH)
	_assert_file_contains(STAGE9_SWITCH_ROOM_SCENE_PATH, CHECKPOINT_GATE_GOAL_ASSET_PATH)


func test_stage12_lightweight_vfx_toggle_without_changing_combat_contract() -> void:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	var player := player_scene.instantiate()
	add_child_autofree(player)
	await get_tree().process_frame

	var slash := player.get_node("Stage12SlashPreview") as Sprite2D
	assert_false(slash.visible)
	player.call("_start_attack")
	assert_true(slash.visible)
	player.call("_finish_attack")
	assert_false(slash.visible)

	var enemy_scene: PackedScene = load(BASIC_ENEMY_SCENE_PATH) as PackedScene
	var enemy := enemy_scene.instantiate()
	add_child_autofree(enemy)
	await get_tree().process_frame

	var hit_spark := enemy.get_node("Stage12HitSpark") as Sprite2D
	assert_false(hit_spark.visible)
	enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	assert_true(enemy.call("is_defeated"))
	assert_true(hit_spark.visible)


func test_stage12_gate_and_checkpoint_polish_nodes_exist_without_changing_gate_collision() -> void:
	await _assert_scene_has_nodes(STAGE9_SWITCH_ROOM_SCENE_PATH, [
		"GateBarrier",
		"GateBarrier/CollisionShape2D",
		"GateBarrier/Stage12GateHint",
		"GateSwitch",
		"GateSwitch/CollisionShape2D",
		"GateSwitch/Stage12CheckpointMarker",
	])


func test_stage12_keeps_stage11_graybox_mainline_finishable() -> void:
	var result: Dictionary = await Stage11GrayboxMainlineDriver.drive_mainline(self)

	assert_true(
		result.get("success", false),
		"Stage 12 表现升级不应破坏 Stage 11 主线：failure_reason=%s last_room=%s strategy=%s" % [
			result.get("failure_reason", ""),
			result.get("last_room_path", ""),
			result.get("last_strategy_step", ""),
		]
	)


# 测试辅助：集中处理文件读取和场景节点断言，让每个测试只表达 Stage 12 的行为目标。
func _read_text_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "无法读取文件：%s" % path)
	return file.get_as_text() if file != null else ""


func _assert_scene_has_nodes(scene_path: String, node_paths: Array[String]) -> void:
	var packed_scene: PackedScene = load(scene_path) as PackedScene
	assert_not_null(packed_scene, "无法加载场景：%s" % scene_path)

	var scene: Node = packed_scene.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	for node_path in node_paths:
		assert_not_null(scene.get_node_or_null(node_path), "%s 缺少节点：%s" % [scene_path, node_path])


func _assert_file_contains(file_path: String, expected_text: String) -> void:
	var text := _read_text_file(file_path)
	assert_string_contains(text, expected_text)
