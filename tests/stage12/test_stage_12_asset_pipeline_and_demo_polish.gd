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

const HUD_V4_ROOT := "res://assets/art/ui/hud_warden_official_v4/"
const HUD_V4_STYLEBOX_ROOT := "res://assets/art/ui/styleboxes/hud_warden_official_v4/"
const HUD_V5_ROOT := "res://assets/art/ui/hud_warden_integrated_v5/"
const HUD_V5_STYLEBOX_ROOT := "res://assets/art/ui/styleboxes/hud_warden_integrated_v5/"
const AIR_DASH_ICON_ASSET_PATH := HUD_V4_ROOT + "hud_icon_dash_warden_official_ai01.png"
const RECOVERY_CHARGE_ICON_ASSET_PATH := HUD_V4_ROOT + "hud_icon_recovery_warden_official_ai01.png"
const HUD_CORE_METER_RAIL_RESOURCE_PATH := HUD_V4_ROOT + "hud_meter_rail_warden_official_ai01.png"
const HUD_GOAL_MARKER_RESOURCE_PATH := HUD_V4_ROOT + "hud_icon_objective_warden_official_ai01.png"
const HUD_BATTLE_PANEL_STYLEBOX_PATH := HUD_V5_STYLEBOX_ROOT + "battle_content_safe.stylebox_empty.tres"
const HUD_PROMPT_PANEL_STYLEBOX_PATH := HUD_V5_STYLEBOX_ROOT + "tutorial_content_safe.stylebox_empty.tres"
const HUD_ELEMENT_PANEL_STYLEBOX_PATH := "res://assets/art/ui/styleboxes/hud_seal_resonance_v2/seal_resonance_idle_content_safe.stylebox_empty.tres"
const HEALTH_ICON_RESOURCE_PATH := HUD_V4_ROOT + "hud_icon_health_warden_official_ai01.png"
const STAGE28_WAYSTATION_WORLD_ATLAS_PATH := "res://assets/art/environment/waystation/stage28_waystation_world_runtime_ai01.png"
const HUD_V4_ASSET_IDS := [
	"battle_frame_base_warden_official_ai01",
	"tutorial_frame_base_warden_official_ai01",
	"element_frame_base_warden_official_ai01",
	"pause_frame_base_warden_official_ai01",
	"warden_seal_medallion_ai01",
	"warden_chain_hook_ai01",
	"warden_chain_talisman_tassel_ai01",
	"warden_cinnabar_stamp_ai01",
	"hud_icon_health_warden_official_ai01",
	"hud_icon_dash_warden_official_ai01",
	"hud_icon_objective_warden_official_ai01",
	"hud_icon_recovery_warden_official_ai01",
	"hud_meter_rail_warden_official_ai01",
]
const HUD_V5_ASSET_IDS := [
	"battle_frame_integrated_warden_ai01",
	"battle_frame_integrated_warden_expanded_ai01",
	"tutorial_frame_integrated_warden_ai01",
	"element_frame_integrated_warden_ai01",
]


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


# 保护 v4 生图来源：每个 live PNG 必须能反查隔离源图，且旁置散列与磁盘内容一致。
func test_hud_warden_official_v4_keeps_complete_provenance_sidecars() -> void:
	for asset_id: String in HUD_V4_ASSET_IDS:
		var record_path := HUD_V4_ROOT + asset_id + ".source.json"
		assert_true(FileAccess.file_exists(record_path), "%s 缺少来源记录。" % asset_id)
		if not FileAccess.file_exists(record_path):
			continue
		var parsed: Variant = JSON.parse_string(_read_text_file(record_path))
		assert_true(parsed is Dictionary, "%s 来源记录不是合法 JSON object。" % asset_id)
		if not parsed is Dictionary:
			continue
		var record := parsed as Dictionary
		var output_path := "res://" + String(record.get("output_path", ""))
		var candidate_path := "res://" + String(record.get("candidate_path", ""))
		assert_eq(String(record.get("asset_id", "")), asset_id)
		assert_eq(String(record.get("provider", "")), "official OpenAI built-in image_gen")
		assert_eq(String(record.get("visual_anchor_contract", "")), "02_warden_seal_chains_tassel")
		assert_eq(output_path, HUD_V4_ROOT + asset_id + ".png")
		assert_true(FileAccess.file_exists(output_path), "%s 运行 PNG 缺失。" % asset_id)
		assert_true(FileAccess.file_exists(candidate_path), "%s 隔离源图缺失。" % asset_id)
		if FileAccess.file_exists(output_path):
			assert_eq(FileAccess.get_sha256(output_path), String(record.get("output_sha256", "")), "%s 输出散列漂移。" % asset_id)
		if FileAccess.file_exists(candidate_path):
			assert_eq(FileAccess.get_sha256(candidate_path), String(record.get("candidate_sha256", "")), "%s 候选散列漂移。" % asset_id)


# gameplay HUD v5 必须由三张一体化 Image Gen 框体组成；来源记录要能反查源图并锁定输出散列。
func test_hud_warden_integrated_v5_keeps_complete_provenance_sidecars() -> void:
	for asset_id: String in HUD_V5_ASSET_IDS:
		var record_path := HUD_V5_ROOT + asset_id + ".source.json"
		assert_true(FileAccess.file_exists(record_path), "%s 缺少 v5 来源记录。" % asset_id)
		if not FileAccess.file_exists(record_path):
			continue
		var parsed: Variant = JSON.parse_string(_read_text_file(record_path))
		assert_true(parsed is Dictionary, "%s v5 来源记录不是合法 JSON object。" % asset_id)
		if not parsed is Dictionary:
			continue
		var record := parsed as Dictionary
		var output_path := "res://" + String(record.get("output_path", ""))
		var candidate_path := "res://" + String(record.get("candidate_path", ""))
		assert_eq(String(record.get("asset_id", "")), asset_id)
		assert_eq(String(record.get("provider", "")), "official OpenAI built-in image_gen")
		assert_eq(String(record.get("visual_assembly_contract", "")), "02_warden_integrated_frame_assembly")
		assert_eq(output_path, HUD_V5_ROOT + asset_id + ".png")
		assert_true(FileAccess.file_exists(output_path), "%s v5 运行 PNG 缺失。" % asset_id)
		assert_true(FileAccess.file_exists(candidate_path), "%s v5 隔离源图缺失。" % asset_id)
		if FileAccess.file_exists(output_path):
			assert_eq(FileAccess.get_sha256(output_path), String(record.get("output_sha256", "")), "%s v5 输出散列漂移。" % asset_id)
		if FileAccess.file_exists(candidate_path):
			assert_eq(FileAccess.get_sha256(candidate_path), String(record.get("candidate_sha256", "")), "%s v5 候选散列漂移。" % asset_id)


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

	assert_almost_eq(float(hud.call("_runtime_hud_scale", Vector2(640.0, 360.0))), 3.2, 0.001)
	assert_eq(float(hud.call("_runtime_hud_scale", Vector2(1280.0, 720.0))), 2.0)
	assert_eq(float(hud.call("_runtime_hud_scale", Vector2(2560.0, 1440.0))), 2.0)
	assert_gte((hud.get_node("BattlePanel") as Panel).scale.x, 1.0)
	assert_gte((hud.get_node("PromptPanel") as Panel).scale.x, 1.0)
	assert_not_null(hud.get_node_or_null("BattlePanel/HealthIcon"))
	assert_not_null(hud.get_node_or_null("BattlePanel/FrameArt"))
	assert_not_null(hud.get_node_or_null("BattlePanel/FrameArtExpanded"))
	assert_not_null(hud.get_node_or_null("PromptPanel/FrameArt"))
	assert_not_null(hud.get_node_or_null("ElementPanel/FrameArt"))
	assert_not_null(hud.get_node_or_null("TutorialAttention"))
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
	var battle_panel := hud.get_node("BattlePanel") as Panel
	var prompt_label := hud.get_node("PromptPanel/PromptLabel") as Label
	var prompt_panel_style := prompt_panel.get_theme_stylebox("panel")
	var battle_panel_style := battle_panel.get_theme_stylebox("panel")
	var element_panel := hud.get_node("ElementPanel") as Panel
	var element_panel_style := element_panel.get_theme_stylebox("panel")
	assert_gte(prompt_panel.size.y, 44.0)
	assert_gte(prompt_panel.size.x, 300.0)
	assert_true(prompt_panel_style is StyleBoxEmpty, "PromptPanel 的 StyleBox 只负责内容安全区，不得再承载可拉伸纹理。")
	assert_true(battle_panel_style is StyleBoxEmpty, "BattlePanel 的完整框体由 FrameArt 等比显示。")
	assert_true(element_panel_style is StyleBoxEmpty, "ElementPanel 的完整框体由 FrameArt 等比显示。")
	assert_eq(prompt_panel_style.resource_path, HUD_PROMPT_PANEL_STYLEBOX_PATH)
	assert_eq(battle_panel_style.resource_path, HUD_BATTLE_PANEL_STYLEBOX_PATH)
	assert_eq(element_panel_style.resource_path, HUD_ELEMENT_PANEL_STYLEBOX_PATH)
	assert_eq(prompt_panel.get_meta("asset_id", ""), "tutorial_frame_integrated_warden_ai01")
	assert_eq(battle_panel.get_meta("asset_id", ""), "battle_frame_integrated_warden_ai01")
	assert_eq(element_panel.get_meta("asset_id_idle", ""), "seal_resonance_idle_frame_warden_ai02")
	assert_eq(element_panel.get_meta("asset_id_active", ""), "seal_resonance_active_frame_warden_ai02")
	for panel: Panel in [prompt_panel, battle_panel]:
		assert_null(panel.get_node_or_null("OrnamentLayer"), "%s 不得继续叠加独立官印装饰套件。" % panel.name)
		assert_eq(String(panel.get_meta("visual_assembly_contract", "")), "02_warden_integrated_frame_assembly")
		var frame_art := panel.get_node_or_null("FrameArt") as TextureRect
		assert_not_null(frame_art, "%s 缺少 v5 一体化框体。" % panel.name)
		if frame_art != null:
			assert_eq(frame_art.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	assert_null(element_panel.get_node_or_null("OrnamentLayer"), "ElementPanel 不得叠加独立装饰套件。")
	assert_eq(String(element_panel.get_meta("visual_assembly_contract", "")), "seal_resonance_v2_command_seal")
	var element_frame_art := element_panel.get_node_or_null("FrameArt") as TextureRect
	var element_frame_art_active := element_panel.get_node_or_null("FrameArtActive") as TextureRect
	assert_not_null(element_frame_art, "ElementPanel 缺少 idle 完整框体。")
	assert_not_null(element_frame_art_active, "ElementPanel 缺少 active 完整框体。")
	for frame_art: TextureRect in [element_frame_art, element_frame_art_active]:
		if frame_art != null:
			assert_eq(frame_art.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	assert_true(hud.has_method("get_hud_content_safe_rects"))
	hud.call("_on_hud_context_changed", "区域推进中", "")
	assert_false(prompt_label.visible)
	assert_lte(prompt_panel.size.y, 118.0)
	assert_lte(prompt_panel.size.x, 400.0)
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
	assert_eq(health_icon.get_meta("asset_id", ""), "hud_icon_health_warden_official_ai01")
	assert_lte(health_icon.size.x, 24.0, "生命图标必须按正式 HUD 小控件尺寸缩放，不能被原始大图尺寸撑开。")
	assert_lte(health_icon.size.y, 24.0, "生命图标必须按正式 HUD 小控件尺寸缩放，不能遮挡运行画面。")
	assert_eq(dash_icon.texture.resource_path, AIR_DASH_ICON_ASSET_PATH)
	assert_eq(dash_icon.get_meta("asset_id", ""), "hud_icon_dash_warden_official_ai01")
	assert_lte(dash_icon.size.x, 24.0, "Dash 图标必须按正式 HUD 小控件尺寸缩放，不能被原始大图尺寸撑开。")
	assert_lte(dash_icon.size.y, 24.0, "Dash 图标必须按正式 HUD 小控件尺寸缩放，不能遮挡运行画面。")
	assert_eq(recovery_icon.texture.resource_path, RECOVERY_CHARGE_ICON_ASSET_PATH)
	assert_eq(recovery_icon.get_meta("asset_id", ""), "hud_icon_recovery_warden_official_ai01")
	assert_lte(recovery_icon.size.x, 24.0, "Recovery 图标必须按正式 HUD 小控件尺寸缩放，不能被原始大图尺寸撑开。")
	assert_lte(recovery_icon.size.y, 24.0, "Recovery 图标必须按正式 HUD 小控件尺寸缩放，不能遮挡运行画面。")
	assert_eq(objective_icon.texture.resource_path, HUD_GOAL_MARKER_RESOURCE_PATH)
	assert_eq(objective_icon.get_meta("asset_id", ""), "hud_icon_objective_warden_official_ai01")
	assert_true(objective_icon.visible, "普通目标行必须显示同源 HUD atlas 目标徽标。")
	assert_lte(objective_icon.size.x, 24.0, "目标徽标必须锁在正式 HUD 小控件尺寸内，不能遮挡目标文本。")
	assert_lte(objective_icon.size.y, 24.0, "目标徽标必须锁在正式 HUD 小控件尺寸内，不能遮挡目标文本。")
	assert_gte((hud.get_node("BattlePanel/ProgressLabel") as Label).position.x, 26.0)
	for meter_frame: TextureRect in [health_meter_frame, dash_meter_frame, recovery_meter_frame, boss_meter_frame]:
		assert_eq(meter_frame.texture.resource_path, HUD_CORE_METER_RAIL_RESOURCE_PATH)
		assert_eq(meter_frame.get_meta("asset_id", ""), "hud_meter_rail_warden_official_ai01")
		assert_gte(meter_frame.position.x, battle_panel_style.get_content_margin(SIDE_LEFT), "HUD 条形资产不能压住左侧纹样。")
		assert_lte(
			meter_frame.position.x + meter_frame.size.x,
			battle_panel.size.x - battle_panel_style.get_content_margin(SIDE_RIGHT),
			"HUD 条形资产必须锁在 NinePatch 内容安全区内。",
		)
		assert_lte(meter_frame.size.y, 30.0, "HUD 条形资产必须是细条装饰，不能遮挡目标文本。")
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
		if attack_slash_vfx.visible:
			active_vfx_seen = true
			break
	assert_true(active_vfx_seen, "attack active 窗口必须显示元素主 VFX。")
	assert_false(attack_seal_arc_vfx.visible, "迅捷姿态不叠加护印副 VFX。")
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
	assert_eq((replay_art.texture as AtlasTexture).atlas.resource_path, STAGE28_WAYSTATION_WORLD_ATLAS_PATH)
	assert_eq((goal_art.texture as AtlasTexture).atlas.resource_path, STAGE28_WAYSTATION_WORLD_ATLAS_PATH)
	assert_eq((continue_art.texture as AtlasTexture).atlas.resource_path, STAGE28_WAYSTATION_WORLD_ATLAS_PATH)
	assert_eq(replay_art.get_meta("runtime_source", ""), "stage28_waystation_world_runtime_ai01.travel_left")
	assert_eq(goal_art.get_meta("runtime_source", ""), "stage28_waystation_world_runtime_ai01.checkpoint")
	assert_eq(continue_art.get_meta("runtime_source", ""), "stage28_waystation_world_runtime_ai01.travel_right")


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
