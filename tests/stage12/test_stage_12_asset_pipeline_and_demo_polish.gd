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
const STAGE11_DEMO_END_ROOM_SCENE_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const STAGE9_SWITCH_ROOM_SCENE_PATH := "res://scenes/rooms/stage9_zone_switch_room.tscn"

const AIR_DASH_ICON_ASSET_PATH := "res://assets/art/editor_resources/icon_sheet_core_ai01/000_icon_sheet_core_ai01_auto_001_c01.atlas_texture.tres"
const RECOVERY_CHARGE_ICON_ASSET_PATH := "res://assets/art/editor_resources/icon_sheet_core_ai01/001_icon_sheet_core_ai01_auto_002_c01.atlas_texture.tres"
const HUD_CORE_METER_RAIL_RESOURCE_PATH := "res://assets/art/editor_resources/hud_core_ui_atlas_ai01/008_hud_core_ui_atlas_ai01_auto_009.atlas_texture.tres"
const HUD_GOAL_MARKER_RESOURCE_PATH := "res://assets/art/editor_resources/hud_core_ui_atlas_ai01/011_hud_core_ui_atlas_ai01_auto_012_c01.atlas_texture.tres"
const HUD_BATTLE_PANEL_ART_PATH := "res://assets/art/editor_resources/menu_ninepatch_ui_ai01/001_menu_ninepatch_ui_ai01_auto_002_c01.atlas_texture.tres"
const HUD_PROMPT_PANEL_ART_PATH := "res://assets/art/editor_resources/menu_ninepatch_ui_ai01/002_menu_ninepatch_ui_ai01_auto_003_c01.atlas_texture.tres"
const HEALTH_ICON_RESOURCE_PATH := "res://assets/art/editor_resources/icon_sheet_core_ai01/009_icon_sheet_core_ai01_auto_010_c02.atlas_texture.tres"
const STAGE11_REPLAY_MARKER_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/003_equipment_pickup_atlas_ai01_auto_004_c01.atlas_texture.tres"
const STAGE11_GOAL_MARKER_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/023_equipment_pickup_atlas_ai01_auto_024_c02.atlas_texture.tres"
const STAGE11_CONTINUE_MARKER_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/011_equipment_pickup_atlas_ai01_auto_012_c02.atlas_texture.tres"


# 保护资产管线目录：Stage12 必须建立角色、敌人、环境、VFX、UI、音频和源文件目录。
func test_stage12_asset_pipeline_docs_and_directories_exist() -> void:
	var required_directories := [
		"res://assets/art/characters/player",
		"res://assets/art/characters/enemies",
		"res://assets/art/environment/biome_01_shrine_trial",
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


# 保护资产 manifest 结构：清单字段和第一批关键占位资产 ID 必须可追踪。
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


# 保护资产接入 checklist：导入、碰撞、HUD、授权和人工复核等检查项必须保留。
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


# 保护表现升级不破坏碰撞契约：玩家和三类敌人必须保留碰撞节点与正式运行视觉。
func test_stage12_player_and_enemy_scenes_keep_collision_contract_and_gain_visual_markers() -> void:
	await _assert_scene_has_nodes(PLAYER_SCENE_PATH, [
		"CollisionShape2D",
		"Body",
		"LunaRuntimeAnimationVisual",
		"AttackSlashVfxVisual",
		"AttackSealArcVfxVisual",
	])
	await _assert_scene_has_nodes(BASIC_ENEMY_SCENE_PATH, [
		"CollisionShape2D",
		"Hurtbox",
		"EnemyRuntimeAnimationVisual",
		"EnemyHitSparkVfxVisual",
	])
	await _assert_scene_has_nodes(GROUND_CHARGER_SCENE_PATH, [
		"CollisionShape2D",
		"Hurtbox",
		"EnemyRuntimeAnimationVisual",
		"EnemyHitSparkVfxVisual",
	])
	await _assert_scene_has_nodes(AERIAL_SENTINEL_SCENE_PATH, [
		"CollisionShape2D",
		"Hurtbox",
		"EnemyRuntimeAnimationVisual",
		"EnemyHitSparkVfxVisual",
	])


# 保护 HUD polish：生命、dash、目标图标存在，同时基础状态文本仍可读。
func test_stage12_hud_contains_polish_icons_and_keeps_demo_completion_feedback() -> void:
	var packed_scene: PackedScene = load(HUD_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)

	var hud: Control = packed_scene.instantiate() as Control
	add_child_autofree(hud)
	await get_tree().process_frame

	assert_eq(float(hud.call("_runtime_hud_scale", Vector2(640.0, 360.0))), 1.0)
	assert_eq(float(hud.call("_runtime_hud_scale", Vector2(1280.0, 720.0))), 1.0)
	assert_eq(float(hud.call("_runtime_hud_scale", Vector2(2560.0, 1440.0))), 2.0)
	assert_gte((hud.get_node("BattlePanel") as Panel).scale.x, 1.0)
	assert_gte((hud.get_node("PromptPanel") as Panel).scale.x, 1.0)
	assert_not_null(hud.get_node_or_null("BattlePanel/HealthIcon"))
	assert_not_null(hud.get_node_or_null("BattlePanel/BattlePanelArt"))
	assert_not_null(hud.get_node_or_null("PromptPanel/PromptPanelArt"))
	assert_not_null(hud.get_node_or_null("BattlePanel/DashIcon"))
	assert_not_null(hud.get_node_or_null("BattlePanel/RecoveryChargeIcon"))
	assert_null(hud.get_node_or_null("BattlePanel/AbilityStatusFrameArt"))
	assert_null(hud.get_node_or_null("BattlePanel/BossHudFrameArt"))
	assert_not_null(hud.get_node_or_null("BattlePanel/ObjectiveIcon"))
	assert_not_null(hud.get_node_or_null("BattlePanel/HealthBarBack"))
	assert_not_null(hud.get_node_or_null("BattlePanel/HealthBarFill"))
	assert_not_null(hud.get_node_or_null("BattlePanel/HealthMeterFrameArt"))
	assert_not_null(hud.get_node_or_null("BattlePanel/DashBarBack"))
	assert_not_null(hud.get_node_or_null("BattlePanel/DashBarFill"))
	assert_not_null(hud.get_node_or_null("BattlePanel/DashMeterFrameArt"))
	assert_not_null(hud.get_node_or_null("BattlePanel/RecoveryBarBack"))
	assert_not_null(hud.get_node_or_null("BattlePanel/RecoveryBarFill"))
	assert_not_null(hud.get_node_or_null("BattlePanel/RecoveryMeterFrameArt"))
	assert_not_null(hud.get_node_or_null("BattlePanel/BossBarBack"))
	assert_not_null(hud.get_node_or_null("BattlePanel/BossBarFill"))
	assert_not_null(hud.get_node_or_null("BattlePanel/BossMeterFrameArt"))
	assert_string_contains((hud.get_node("BattlePanel/StatusLabel") as Label).text, "生命")
	assert_string_contains((hud.get_node("BattlePanel/DashLabel") as Label).text, "冲刺")

	var prompt_panel := hud.get_node("PromptPanel") as Panel
	var prompt_label := hud.get_node("PromptPanel/PromptLabel") as Label
	var prompt_panel_art := hud.get_node("PromptPanel/PromptPanelArt") as TextureRect
	var battle_panel_art := hud.get_node("BattlePanel/BattlePanelArt") as TextureRect
	assert_gte(prompt_panel.size.y, 44.0)
	assert_gte(prompt_panel.size.x, 300.0)
	assert_eq(prompt_panel_art.texture.resource_path, HUD_PROMPT_PANEL_ART_PATH)
	assert_eq(prompt_panel_art.get_meta("asset_id", ""), "menu_ninepatch_ui_ai01.hud_prompt_panel_art")
	assert_eq(battle_panel_art.texture.resource_path, HUD_BATTLE_PANEL_ART_PATH)
	assert_eq(battle_panel_art.get_meta("asset_id", ""), "menu_ninepatch_ui_ai01.hud_battle_panel_art")
	assert_lte(battle_panel_art.size.x, 200.0, "HUD 面板贴图层必须跟随固定面板尺寸，不能按源图尺寸撑开。")
	assert_lte(battle_panel_art.size.y, 110.0, "HUD 面板贴图层必须跟随固定面板尺寸，不能压住运行画面。")
	hud.call("_on_hud_context_changed", "区域推进中", "")
	assert_false(prompt_label.visible)
	assert_lte(prompt_panel.size.y, 28.0)
	assert_lte(prompt_panel.size.x, 180.0)
	assert_lte(prompt_panel_art.size.x, 180.0)
	assert_lte(prompt_panel_art.size.y, 28.0)
	hud.call("_on_hud_context_changed", "教程", "A/D 移动。")
	assert_true(prompt_label.visible)
	assert_gte(prompt_panel.size.y, 44.0)
	assert_gte(prompt_panel.size.x, 300.0)

	var health_icon := hud.get_node("BattlePanel/HealthIcon") as TextureRect
	var dash_icon := hud.get_node("BattlePanel/DashIcon") as TextureRect
	var objective_icon := hud.get_node("BattlePanel/ObjectiveIcon") as TextureRect
	var recovery_icon := hud.get_node("BattlePanel/RecoveryChargeIcon") as TextureRect
	var health_meter_frame := hud.get_node("BattlePanel/HealthMeterFrameArt") as TextureRect
	var dash_meter_frame := hud.get_node("BattlePanel/DashMeterFrameArt") as TextureRect
	var recovery_meter_frame := hud.get_node("BattlePanel/RecoveryMeterFrameArt") as TextureRect
	var boss_meter_frame := hud.get_node("BattlePanel/BossMeterFrameArt") as TextureRect
	assert_not_null(health_icon, "生命图标必须使用正式 TextureRect 资产，不能退回运行态红色色块。")
	assert_eq(health_icon.texture.resource_path, HEALTH_ICON_RESOURCE_PATH)
	assert_eq(health_icon.get_meta("asset_id", ""), "icon_sheet_core_ai01.health")
	assert_lte(health_icon.size.x, 16.0, "生命图标必须按 HUD 小控件尺寸缩放，不能被原始大图尺寸撑开。")
	assert_lte(health_icon.size.y, 16.0, "生命图标必须按 HUD 小控件尺寸缩放，不能遮挡运行画面。")
	assert_eq(dash_icon.texture.resource_path, AIR_DASH_ICON_ASSET_PATH)
	assert_eq(dash_icon.get_meta("asset_id", ""), "icon_sheet_core_ai01.air_dash")
	assert_lte(dash_icon.size.x, 16.0, "Dash 图标必须按 HUD 小控件尺寸缩放，不能被原始大图尺寸撑开。")
	assert_lte(dash_icon.size.y, 16.0, "Dash 图标必须按 HUD 小控件尺寸缩放，不能遮挡运行画面。")
	assert_eq(recovery_icon.texture.resource_path, RECOVERY_CHARGE_ICON_ASSET_PATH)
	assert_eq(recovery_icon.get_meta("asset_id", ""), "icon_sheet_core_ai01.recovery_charge")
	assert_lte(recovery_icon.size.x, 16.0, "Recovery 图标必须按 HUD 小控件尺寸缩放，不能被原始大图尺寸撑开。")
	assert_lte(recovery_icon.size.y, 16.0, "Recovery 图标必须按 HUD 小控件尺寸缩放，不能遮挡运行画面。")
	assert_eq(objective_icon.texture.resource_path, HUD_GOAL_MARKER_RESOURCE_PATH)
	assert_eq(objective_icon.get_meta("asset_id", ""), "hud_core_ui_atlas_ai01.room_goal_marker")
	assert_true(objective_icon.visible, "普通目标行必须显示同源 HUD atlas 目标徽标。")
	assert_lte(objective_icon.size.x, 16.0, "目标徽标必须锁在 HUD 小控件尺寸内，不能遮挡目标文本。")
	assert_lte(objective_icon.size.y, 16.0, "目标徽标必须锁在 HUD 小控件尺寸内，不能遮挡目标文本。")
	assert_gte((hud.get_node("BattlePanel/ProgressLabel") as Label).position.x, 26.0)
	for meter_frame: TextureRect in [health_meter_frame, dash_meter_frame, recovery_meter_frame, boss_meter_frame]:
		assert_eq(meter_frame.texture.resource_path, HUD_CORE_METER_RAIL_RESOURCE_PATH)
		assert_eq(meter_frame.get_meta("asset_id", ""), "hud_core_ui_atlas_ai01.meter_rail")
		assert_lte(meter_frame.size.x, 132.0, "HUD 条形资产必须锁在战斗面板内，不能按原图尺寸撑开。")
		assert_lte(meter_frame.size.y, 20.0, "HUD 条形资产必须是细条装饰，不能遮挡目标文本。")
	assert_true(health_meter_frame.visible, "生命条必须在运行态显示核心 HUD atlas 的条形装饰。")
	assert_true(dash_meter_frame.visible, "冲刺条必须在运行态显示核心 HUD atlas 的条形装饰。")
	assert_false(recovery_meter_frame.visible, "恢复条装饰只在 Stage15 恢复机制相关房间显示。")
	assert_false(boss_meter_frame.visible, "Boss 条装饰只在 Boss 房显示。")
	_assert_file_contains(HUD_SCENE_PATH, HUD_GOAL_MARKER_RESOURCE_PATH)


# 保护轻量 VFX：攻击和受击视觉可切换，但不改变玩家攻击或敌人 defeated 契约。
func test_stage12_lightweight_vfx_toggle_without_changing_combat_contract() -> void:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	var player := player_scene.instantiate()
	add_child_autofree(player)
	await get_tree().process_frame

	var attack_slash_vfx := player.get_node("AttackSlashVfxVisual") as AnimatedSprite2D
	var attack_seal_arc_vfx := player.get_node("AttackSealArcVfxVisual") as AnimatedSprite2D
	assert_false(attack_slash_vfx.visible)
	assert_false(attack_seal_arc_vfx.visible)
	player.call("_start_attack")
	assert_false(attack_slash_vfx.visible, "Stage17 startup 关键帧期间不应提前显示攻击 VFX。")
	assert_false(attack_seal_arc_vfx.visible, "Stage17 startup 关键帧期间不应提前显示符印 VFX。")
	var active_vfx_seen := false
	for _i in range(12):
		await get_tree().physics_frame
		if attack_slash_vfx.visible and attack_seal_arc_vfx.visible:
			active_vfx_seen = true
			break
	assert_true(active_vfx_seen, "Stage17 attack active 窗口必须显示两层攻击 VFX。")
	assert_false(attack_slash_vfx.get_meta("gameplay_collision", true))
	assert_false(attack_slash_vfx.get_meta("damage_source", true))
	assert_false(attack_seal_arc_vfx.get_meta("gameplay_collision", true))
	assert_false(attack_seal_arc_vfx.get_meta("damage_source", true))
	player.call("_finish_attack")
	assert_false(attack_slash_vfx.visible)
	assert_false(attack_seal_arc_vfx.visible)

	var enemy_scene: PackedScene = load(BASIC_ENEMY_SCENE_PATH) as PackedScene
	var enemy := enemy_scene.instantiate()
	add_child_autofree(enemy)
	await get_tree().process_frame

	var hit_spark := enemy.get_node("EnemyHitSparkVfxVisual") as AnimatedSprite2D
	var enemy_body := enemy.get_node("Body") as CanvasItem
	var enemy_silhouette := enemy.get_node("Stage12Silhouette") as CanvasItem
	assert_false(hit_spark.visible)
	assert_false(enemy_body.visible)
	assert_false(enemy_silhouette.visible)
	enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	assert_true(enemy.call("is_defeated"))
	assert_true(hit_spark.visible)
	assert_false(hit_spark.get_meta("gameplay_collision", true))
	assert_false(hit_spark.get_meta("damage_source", true))
	await get_tree().create_timer(0.6).timeout
	assert_false(hit_spark.visible)


# 保护门控 / checkpoint polish：正式道具不能移除原有 GateBarrier 和 GateSwitch 碰撞。
func test_stage12_gate_and_checkpoint_polish_nodes_exist_without_changing_gate_collision() -> void:
	await _assert_scene_has_nodes(STAGE9_SWITCH_ROOM_SCENE_PATH, [
		"GateBarrier",
		"GateBarrier/CollisionShape2D",
		"GateBarrier/BarrierArt",
		"GateSwitch",
		"GateSwitch/CollisionShape2D",
		"GateSwitch/SwitchArt",
	])


# 保护 Stage11 终点房视觉：旧高亮箭头不能继续作为正式 Demo 入口提示。
func test_stage12_stage11_end_room_hides_legacy_arrows_and_uses_formal_marker_art() -> void:
	var packed_scene: PackedScene = load(STAGE11_DEMO_END_ROOM_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)

	var room: Node = packed_scene.instantiate()
	add_child_autofree(room)

	var replay_arrow := room.get_node_or_null("ReplayZone/Stage12ReplayArrow") as Polygon2D
	var goal_arrow := room.get_node_or_null("GoalZone/Stage12GoalArrow") as Polygon2D
	var continue_arrow := room.get_node_or_null("ContinueZone/Stage13ContinueArrow") as Polygon2D
	var replay_visual := room.get_node_or_null("ReplayZone/ReplayVisual") as Polygon2D
	var goal_visual := room.get_node_or_null("GoalZone/GoalVisual") as Polygon2D
	var continue_visual := room.get_node_or_null("ContinueZone/ContinueVisual") as Polygon2D
	var replay_art := room.get_node_or_null("ReplayZone/ReplayMarkerArt") as Sprite2D
	var goal_art := room.get_node_or_null("GoalZone/GoalMarkerArt") as Sprite2D
	var continue_art := room.get_node_or_null("ContinueZone/ContinueMarkerArt") as Sprite2D

	assert_not_null(replay_arrow)
	assert_not_null(goal_arrow)
	assert_not_null(continue_arrow)
	assert_not_null(replay_visual)
	assert_not_null(goal_visual)
	assert_not_null(continue_visual)
	assert_false(replay_arrow.visible)
	assert_false(goal_arrow.visible)
	assert_false(continue_arrow.visible)
	if replay_visual != null:
		assert_false(replay_visual.visible)
	if goal_visual != null:
		assert_false(goal_visual.visible)
	if continue_visual != null:
		assert_false(continue_visual.visible)

	assert_not_null(replay_art)
	assert_not_null(goal_art)
	assert_not_null(continue_art)
	assert_eq(replay_art.texture.resource_path, STAGE11_REPLAY_MARKER_TEXTURE_PATH)
	assert_eq(goal_art.texture.resource_path, STAGE11_GOAL_MARKER_TEXTURE_PATH)
	assert_eq(continue_art.texture.resource_path, STAGE11_CONTINUE_MARKER_TEXTURE_PATH)
	assert_eq(replay_art.get_meta("runtime_source", ""), "equipment_pickup_atlas_ai01.bronze_bell")
	assert_eq(goal_art.get_meta("runtime_source", ""), "equipment_pickup_atlas_ai01.demo_completion_token")
	assert_eq(continue_art.get_meta("runtime_source", ""), "equipment_pickup_atlas_ai01.shrine_key_token")


# 保护回归基线：Stage12 表现升级后，Stage11 灰盒主线仍必须可完成。
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
# 读取项目文本文件，用于 manifest、checklist 和场景引用断言。
func _read_text_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "无法读取文件：%s" % path)
	return file.get_as_text() if file != null else ""


# 加载场景并断言一组节点存在，集中处理场景实例化和错误信息。
func _assert_scene_has_nodes(scene_path: String, node_paths: Array[String]) -> void:
	var packed_scene: PackedScene = load(scene_path) as PackedScene
	assert_not_null(packed_scene, "无法加载场景：%s" % scene_path)

	var scene: Node = packed_scene.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	for node_path in node_paths:
		assert_not_null(scene.get_node_or_null(node_path), "%s 缺少节点：%s" % [scene_path, node_path])


# 断言指定文件包含某段文本，用于确认资源路径已经写入场景或文档。
func _assert_file_contains(file_path: String, expected_text: String) -> void:
	var text := _read_text_file(file_path)
	assert_string_contains(text, expected_text)
