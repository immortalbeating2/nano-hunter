extends GutTest

# 阶段 13 回归测试保护第二小区域内容生产的完整边界。
# 本 suite 先锁定“瘴泽妖域 + 10 主线房 + 2 支路”的生产契约，
# 再覆盖瘴气妖术投射者、腐瘴危险、封印门控、checkpoint、资产清单和灰盒主路径。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const STAGE11_DEMO_END_ROOM_SCENE_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const MIASMA_CASTER_SCENE_PATH := "res://scenes/combat/miasma_caster_enemy.tscn"
const MIASMA_CASTER_CONFIG_SCRIPT_PATH := "res://scripts/configs/miasma_caster_enemy_config.gd"
const ASSET_MANIFEST_PATH := "res://docs/assets/asset-manifest.md"
const MIASMA_TILESET_RESOURCE_PATH := "res://assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres"
const VFX_COMBAT_SPRITEFRAMES_PATH := "res://assets/art/vfx/atlases/vfx_combat_atlas_ai01.spriteframes.tres"
const MIASMA_PURGE_WARNING_SPRITEFRAMES_PATH := "res://assets/art/vfx/atlases/miasma_purge_warning_vfx_runtime_ai01.spriteframes.tres"
const SHRINE_GATE_LOCKED_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres"
const SHRINE_GATE_OPEN_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/003_shrine_gate_prop_atlas_ai01_auto_004_c01.atlas_texture.tres"
const STAGE13_GOAL_DEVICE_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/016_shrine_gate_prop_atlas_ai01_auto_017_c02.atlas_texture.tres"
const STAGE13_CHECKPOINT_ACTIVE_TEXTURE_PATH := "res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/015_shrine_gate_prop_atlas_ai01_auto_016_c02.atlas_texture.tres"
const BRANCH_RESOURCE_MARKER_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/008_equipment_pickup_atlas_ai01_auto_009_c01.atlas_texture.tres"
const BRANCH_CHALLENGE_MARKER_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/019_equipment_pickup_atlas_ai01_auto_020_c02.atlas_texture.tres"
const BRANCH_EXIT_MARKER_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/022_equipment_pickup_atlas_ai01_auto_023_c02.atlas_texture.tres"
const STAGE13_RESOURCE_BRANCH_REWARD_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/005_equipment_pickup_atlas_ai01_auto_006_c01.atlas_texture.tres"
const STAGE13_CHALLENGE_BRANCH_REWARD_TEXTURE_PATH := "res://assets/art/editor_resources/equipment_pickup_atlas_ai01/009_equipment_pickup_atlas_ai01_auto_010_c01.atlas_texture.tres"

const STAGE13_MAIN_ROOM_PATHS := [
	"res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_crossfire_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_return_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn",
]

const STAGE13_RESOURCE_BRANCH_ROOM_PATH := "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"
const STAGE13_CHALLENGE_BRANCH_ROOM_PATH := "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn"
const MIASMA_BACKGROUND_RESOURCE_PATH := "res://assets/art/environment/biome_02_miasma_marsh/biome02_miasma_marsh_background_ai01.png"
const MIASMA_TILE_SHEET_RESOURCE_PATH := "res://assets/art/environment/biome_02_miasma_marsh/biome02_miasma_marsh_tiles_ai01.png"
const STAGE13_MIASMA_VISUAL_PASS_ROOM_PATHS := [
	"res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_return_room.tscn",
	"res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn",
]


# 保护 Stage13 内容范围：10 个主线房和 2 条支路必须全部存在并完成入口配置。
func test_stage13_area_declares_ten_main_rooms_and_two_branches() -> void:
	# 先锁资产和场景数量边界，避免后续改房间时悄悄丢掉主线或支路。
	for room_path in STAGE13_MAIN_ROOM_PATHS:
		assert_not_null(load(room_path), "缺少 Stage 13 主线房间：%s" % room_path)

	assert_not_null(load(STAGE13_RESOURCE_BRANCH_ROOM_PATH))
	assert_not_null(load(STAGE13_CHALLENGE_BRANCH_ROOM_PATH))

	var entry_room := await _spawn_room(STAGE13_MAIN_ROOM_PATHS[0])
	var hub_room := await _spawn_room(STAGE13_MAIN_ROOM_PATHS[7])

	assert_eq(entry_room.get("next_room_path"), STAGE13_MAIN_ROOM_PATHS[1])
	assert_eq(hub_room.call("get_resource_branch_room_path"), STAGE13_RESOURCE_BRANCH_ROOM_PATH)
	assert_eq(hub_room.call("get_challenge_branch_room_path"), STAGE13_CHALLENGE_BRANCH_ROOM_PATH)


# 保护 Stage11 到 Stage13 的接入：Demo 完成后 ContinueZone 必须进入第二小区域入口。
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


# 保护瘴气妖术投射者契约：敌人必须读取配置并暴露远程压制相关读值。
func test_miasma_caster_enemy_uses_config_and_exposes_ranged_pressure_contract() -> void:
	var packed_scene: PackedScene = load(MIASMA_CASTER_SCENE_PATH) as PackedScene

	assert_not_null(packed_scene)

	var enemy: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(enemy)
	await get_tree().process_frame

	var config: Resource = enemy.get("config") as Resource

	assert_not_null(config)
	assert_eq(config.get_script().resource_path, MIASMA_CASTER_CONFIG_SCRIPT_PATH)
	assert_true(enemy.has_method("get_projectile_range"))
	assert_gt(enemy.call("get_projectile_range"), 120.0)
	assert_gt(enemy.call("get_miasma_pressure_radius"), 32.0)
	assert_eq(enemy.call("get_touch_damage"), config.get("touch_damage"))
	var pressure_polygon := enemy.get_node_or_null("MiasmaPressureVisual") as Polygon2D
	assert_not_null(pressure_polygon)
	if pressure_polygon != null:
		assert_false(pressure_polygon.visible)
	_assert_animated_sprite_references_asset(
		enemy,
		"MiasmaPressureVfxVisual",
		"miasma_purge_warning_vfx_runtime_ai01",
		MIASMA_PURGE_WARNING_SPRITEFRAMES_PATH,
		&"miasma_purge_warning"
	)
	var pressure_vfx := enemy.get_node_or_null("MiasmaPressureVfxVisual") as AnimatedSprite2D
	assert_not_null(pressure_vfx)
	if pressure_vfx != null:
		assert_lt(pressure_vfx.modulate.a, 0.22)
		assert_lt(pressure_vfx.scale.x, 0.37)
		assert_lt(pressure_vfx.scale.y, 0.24)


# 保护瘴气危险：触发瘴气应造成伤害，同时房间仍保留失败重试契约。
func test_miasma_hazard_damages_player_without_breaking_checkpoint_recovery() -> void:
	var room := await _spawn_room(STAGE13_MAIN_ROOM_PATHS[2])
	var player := await _spawn_player(Vector2.ZERO)

	room.call("bind_player", player)
	player.global_position = room.get_node("MiasmaHazard").global_position
	await _advance_process_frames(2)

	assert_lt(player.call("get_current_health"), player.call("get_max_health"))
	assert_true(room.call("has_miasma_hazard"))
	assert_true(room.call("should_reset_on_player_defeat"))


# 保护腐瘴危险的正式运行态读值：hazard 不应继续显示绿色几何 SVG / Polygon 占位。
func test_miasma_hazard_warning_uses_miasma_purge_vfx_asset() -> void:
	for room_path: String in [STAGE13_MAIN_ROOM_PATHS[2], STAGE13_MAIN_ROOM_PATHS[6]]:
		var room := await _spawn_room(room_path)
		var warning_polygon := room.get_node_or_null("MiasmaHazard/WarningVisual") as Polygon2D
		var warning_svg := room.get_node_or_null("MiasmaHazard/MiasmaWarningArt") as Sprite2D

		assert_not_null(warning_polygon)
		assert_not_null(warning_svg)
		if warning_polygon != null:
			assert_false(warning_polygon.visible)
		if warning_svg != null:
			assert_false(warning_svg.visible)
		_assert_animated_sprite_references_asset(
			room,
			"MiasmaHazard/MiasmaWarningVfxArt",
			"miasma_purge_warning_vfx_runtime_ai01",
			MIASMA_PURGE_WARNING_SPRITEFRAMES_PATH,
			&"miasma_purge_warning"
		)
		var warning_vfx := room.get_node_or_null("MiasmaHazard/MiasmaWarningVfxArt") as AnimatedSprite2D
		assert_not_null(warning_vfx)
		if warning_vfx != null:
			assert_between(warning_vfx.modulate.a, 0.25, 0.8)
			assert_between(warning_vfx.scale.x, 0.35, 0.85)
			assert_between(warning_vfx.scale.y, 0.2, 0.45)


# 保护封印门控：带镇妖印节点的房间默认锁门，触发节点后解锁。
func test_seal_gate_starts_locked_and_unlocks_after_node_activation() -> void:
	var room := await _spawn_room(STAGE13_MAIN_ROOM_PATHS[3])
	var player := await _spawn_player(Vector2.ZERO)

	room.call("bind_player", player)

	assert_false(room.call("is_gate_unlocked"))
	assert_true(room.call("has_seal_gate"))
	_assert_sprite_references_asset(
		room,
		"GateBarrier/GateArt",
		"shrine_gate_prop_atlas_ai01",
		SHRINE_GATE_LOCKED_TEXTURE_PATH
	)
	var gate_art := room.get_node_or_null("GateBarrier/GateArt") as Sprite2D
	if gate_art != null:
		assert_eq(gate_art.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.seal_gate_locked")

	player.global_position = room.get_node("SealNode").global_position
	await _advance_process_frames(3)

	assert_true(room.call("is_gate_unlocked"))
	assert_true(room.call("is_seal_node_activated"))
	_assert_sprite_references_asset(
		room,
		"GateBarrier/GateArt",
		"shrine_gate_prop_atlas_ai01",
		SHRINE_GATE_OPEN_TEXTURE_PATH
	)
	if gate_art != null:
		assert_eq(gate_art.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.seal_gate_open")


# 保护两条支路的收益角色：资源支路与挑战支路都能计数奖励并回到主线。
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

	var branch_reward_specs := [
		{
			"room": resource_room,
			"texture": STAGE13_RESOURCE_BRANCH_REWARD_TEXTURE_PATH,
			"source": "equipment_pickup_atlas_ai01.seal_fragment",
		},
		{
			"room": challenge_room,
			"texture": STAGE13_CHALLENGE_BRANCH_REWARD_TEXTURE_PATH,
			"source": "equipment_pickup_atlas_ai01.reward_orb_large",
		},
	]

	for spec: Dictionary in branch_reward_specs:
		var branch_room := spec.room as Node2D
		_assert_sprite_references_asset(
			branch_room,
			"Stage13Reward/RewardArt",
			"equipment_pickup_atlas_ai01",
			str(spec.texture)
		)
		var reward_art := branch_room.get_node_or_null("Stage13Reward/RewardArt") as Sprite2D
		if reward_art != null:
			assert_eq(reward_art.get_meta("runtime_source", ""), spec.source)
			assert_gte(reward_art.z_index, 2)
			assert_lte(reward_art.scale.x, 0.35)
			assert_lte(reward_art.scale.y, 0.35)


# 保护支路枢纽读值：三条路线不能只依赖低透明触发区色块。
func test_stage13_branch_hub_uses_formal_route_marker_art() -> void:
	var hub_room := await _spawn_room(STAGE13_MAIN_ROOM_PATHS[7])
	var marker_specs := [
		{
			"path": "ResourceBranchZone/ResourceMarkerArt",
			"visual": "ResourceBranchZone/ResourceVisual",
			"texture": BRANCH_RESOURCE_MARKER_TEXTURE_PATH,
			"source": "equipment_pickup_atlas_ai01.reward_orb_small",
		},
		{
			"path": "ChallengeBranchZone/ChallengeMarkerArt",
			"visual": "ChallengeBranchZone/ChallengeVisual",
			"texture": BRANCH_CHALLENGE_MARKER_TEXTURE_PATH,
			"source": "equipment_pickup_atlas_ai01.boss_core_shard",
		},
		{
			"path": "ExitZone/ExitMarkerArt",
			"visual": "ExitZone/ZoneVisual",
			"texture": BRANCH_EXIT_MARKER_TEXTURE_PATH,
			"source": "equipment_pickup_atlas_ai01.map_scrap",
		},
	]

	for spec: Dictionary in marker_specs:
		_assert_sprite_references_asset(
			hub_room,
			str(spec.path),
			"equipment_pickup_atlas_ai01",
			str(spec.texture)
		)
		var marker := hub_room.get_node_or_null(NodePath(str(spec.path))) as Sprite2D
		if marker != null:
			assert_eq(marker.get_meta("runtime_source", ""), spec.source)
			assert_gte(marker.z_index, 2)
			assert_lte(marker.scale.x, 0.34)
			assert_lte(marker.scale.y, 0.34)
		var legacy_visual := hub_room.get_node_or_null(NodePath(str(spec.visual))) as Polygon2D
		assert_not_null(legacy_visual, "支路枢纽旧触发区底板必须保留为隐藏编辑参考：%s" % str(spec.visual))
		if legacy_visual != null:
			assert_false(legacy_visual.visible)


# 保护资产规划：Stage13 瘴泽妖域关键视觉需求必须写入 manifest。
func test_stage13_asset_manifest_contains_miasma_marsh_requirements() -> void:
	var manifest := _read_text_file(ASSET_MANIFEST_PATH)
	var required_terms := [
		"stage13_miasma_marsh_biome_reference",
		"stage13_miasma_marsh_tiles",
		"stage13_seal_gate",
		"stage13_seal_node",
		"stage13_miasma_caster_silhouette",
		"stage13_miasma_hazard_warning",
		"stage13_miasma_marsh_goal_device",
	]

	for term in required_terms:
		assert_string_contains(manifest, term)


# 保护瘴泽 TileSet 预览接入：入口房先引用 Godot TileSet，但碰撞仍由灰盒 StaticBody 负责。
func test_stage13_entry_room_references_miasma_marsh_tileset_preview() -> void:
	var room := await _spawn_room(STAGE13_MAIN_ROOM_PATHS[0])
	_assert_tileset_preview_references_asset(room, "MiasmaTilesetPreview")


# 保护 Stage13 可达性：每个正式可达房间的地面必须覆盖到出口或目标点前。
func test_stage13_reachable_room_floors_reach_exit_or_goal_trigger() -> void:
	for room_path: String in STAGE13_MAIN_ROOM_PATHS + [STAGE13_RESOURCE_BRANCH_ROOM_PATH, STAGE13_CHALLENGE_BRANCH_ROOM_PATH]:
		var room := await _spawn_room(room_path)
		_assert_floor_reaches_exit_or_goal(room)


# 地面覆盖 helper 防止只修入口、漏掉后续主线或支线房间。
func _assert_floor_reaches_exit_or_goal(room: Node2D) -> void:
	var exit_zone := room.get_node_or_null("ExitZone") as Area2D
	var goal_zone := room.get_node_or_null("GoalZone") as Area2D
	var target_zone := goal_zone if goal_zone != null else exit_zone
	assert_not_null(target_zone)
	if target_zone == null:
		return

	var terrain := room.get_node_or_null("TerrainCollisionVisual") as TileMapLayer
	if terrain != null and bool(terrain.get("collision_enabled")) and not terrain.get_used_cells().is_empty():
		var used := terrain.get_used_rect()
		var last_cell := Vector2i(used.end.x - 1, used.position.y)
		var floor_right_edge := terrain.to_global(terrain.map_to_local(last_cell)).x + 32.0
		assert_gte(floor_right_edge, target_zone.position.x - 36.0)
		return

	var floor := room.get_node_or_null("Floor") as StaticBody2D
	var floor_shape := room.get_node_or_null("Floor/CollisionShape2D") as CollisionShape2D
	assert_not_null(floor)
	assert_not_null(floor_shape)
	if floor == null or floor_shape == null:
		return
	var rectangle := floor_shape.shape as RectangleShape2D
	assert_not_null(rectangle)
	if rectangle == null:
		return

	var floor_right_edge := floor.position.x + rectangle.size.x * 0.5
	var exit_trigger_x := target_zone.position.x - 36.0
	assert_gte(floor_right_edge, exit_trigger_x)


# 保护 Stage13 visual replacement：P2 房间统一接入瘴泽背景、tile sheet 和 TileSet 预览。
func test_stage13_p2_visual_replacement_rooms_reference_miasma_visual_stack() -> void:
	for room_path: String in STAGE13_MIASMA_VISUAL_PASS_ROOM_PATHS:
		var room: Node2D = await _spawn_room(room_path)
		_assert_sprite_references_asset(
			room,
			"MiasmaBackgroundArt",
			"biome02_miasma_marsh_background_ai01",
			MIASMA_BACKGROUND_RESOURCE_PATH
		)
		_assert_sprite_references_asset(
			room,
			"MiasmaTileSheetArt",
			"biome02_miasma_marsh_tiles_ai01",
			MIASMA_TILE_SHEET_RESOURCE_PATH
		)
		_assert_tileset_preview_references_asset(room, "MiasmaTilesetPreview")

	var goal_room: Node2D = await _spawn_room(STAGE13_MAIN_ROOM_PATHS[9])
	assert_null(goal_room.get_node_or_null("GoalDevice") as Polygon2D, "Stage13 目标装置不能退回亮色 Polygon2D 占位。")
	_assert_sprite_references_asset(
		goal_room,
		"GoalDevice",
		"shrine_gate_prop_atlas_ai01",
		STAGE13_GOAL_DEVICE_TEXTURE_PATH
	)
	var goal_device := goal_room.get_node_or_null("GoalDevice") as Sprite2D
	if goal_device != null:
		assert_eq(goal_device.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.miasma_ward_idle")
		assert_gte(goal_device.z_index, 1, "目标装置必须压在地形装饰上方，避免被 TileMap 前景盖住。")
		assert_lte(goal_device.scale.x, 0.36)
		assert_lte(goal_device.scale.y, 0.36)
	var goal_visual := goal_room.get_node_or_null("GoalZone/GoalVisual") as Polygon2D
	assert_not_null(goal_visual, "Stage13 目标触发区只保留隐藏编辑参考，运行态读值交给 GoalDevice。")
	if goal_visual != null:
		assert_false(goal_visual.visible)

	var checkpoint_room: Node2D = await _spawn_room(STAGE13_MAIN_ROOM_PATHS[5])
	_assert_sprite_references_asset(
		checkpoint_room,
		"RecoveryPoint/CheckpointArt",
		"shrine_gate_prop_atlas_ai01",
		STAGE13_CHECKPOINT_ACTIVE_TEXTURE_PATH
	)
	var checkpoint_art := checkpoint_room.get_node_or_null("RecoveryPoint/CheckpointArt") as Sprite2D
	if checkpoint_art != null:
		assert_eq(checkpoint_art.get_meta("runtime_source", ""), "shrine_gate_prop_atlas_ai01.checkpoint_active")
		assert_gte(checkpoint_art.z_index, 3)
		assert_lte(checkpoint_art.scale.x, 0.32)
		assert_lte(checkpoint_art.scale.y, 0.32)


# 保护灰盒主路径：从 Main 进入 Stage11 终点后应能自动推进到 Stage13 目标房。
func test_stage13_graybox_driver_can_reach_second_zone_goal_from_main_scene() -> void:
	# 这条测试从 Main.tscn 出发，保护 Stage11 终点继续进入 Stage13 的真实主线契约。
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


# 灰盒 driver 按当前房间状态选择最小推进动作，保护 Stage13 主线不会断链。
func _drive_to_stage13_goal(main_scene: Node2D) -> bool:
	# Stage13 driver 按当前房间状态选择最小推进动作：清敌、解门、走出口。
	# 它不评估真人手感，只保护灰盒链路不会断。
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

		if room.has_method("activate_seal_node"):
			room.call("activate_seal_node")

		var goal_zone: Node2D = room.get_node_or_null("GoalZone") as Node2D
		var exit_zone: Node2D = room.get_node_or_null("ExitZone") as Node2D
		var target_zone := goal_zone if goal_zone != null else exit_zone
		if target_zone == null:
			return false

		player.global_position = target_zone.global_position
		await _advance_process_frames(4)

	return false


# 统一房间实例化入口，保证每个房间都至少跑过一帧 _ready 初始化。
func _spawn_room(scene_path: String) -> Node2D:
	var packed_scene: PackedScene = load(scene_path) as PackedScene

	assert_not_null(packed_scene)

	var room: Node2D = packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


# 玩家 helper 用真实 PlayerPlaceholder，避免测试绕过生命、伤害和 HUD 快照契约。
func _spawn_player(spawn_position: Vector2) -> CharacterBody2D:
	var player_scene: PackedScene = load("res://scenes/player/player_placeholder.tscn") as PackedScene

	assert_not_null(player_scene)

	var player: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	add_child_autofree(player)
	player.global_position = spawn_position
	await get_tree().process_frame
	return player


# process 帧推进 helper 用于等待房间位置触发、信号切房和 HUD 更新。
func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


# 读取文本文件用于 manifest 断言，失败时给出明确路径。
func _read_text_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "无法读取文件：%s" % path)
	return file.get_as_text() if file != null else ""


# 资产接入断言 helper：保护 Sprite2D 节点、asset_id metadata 和实际资源路径三者一致。
func _assert_sprite_references_asset(parent: Node, node_path: String, asset_id: String, resource_path: String) -> void:
	var sprite := parent.get_node_or_null(NodePath(node_path)) as Sprite2D
	assert_not_null(sprite, "缺少 Sprite2D 资产节点：%s" % node_path)
	if sprite == null:
		return

	assert_eq(sprite.get_meta("asset_id", ""), asset_id)
	assert_not_null(sprite.texture, "Sprite2D 没有纹理：%s" % node_path)
	if sprite.texture != null:
		assert_eq(sprite.texture.resource_path, resource_path)


# 资产接入断言 helper：保护 AnimatedSprite2D 节点、asset_id metadata 和 SpriteFrames 路径。
func _assert_animated_sprite_references_asset(parent: Node, node_path: String, asset_id: String, resource_path: String, animation_name: StringName) -> void:
	var animated_sprite := parent.get_node_or_null(NodePath(node_path)) as AnimatedSprite2D
	assert_not_null(animated_sprite, "缺少 AnimatedSprite2D 资产节点：%s" % node_path)
	if animated_sprite == null:
		return

	assert_eq(animated_sprite.get_meta("asset_id", ""), asset_id)
	assert_not_null(animated_sprite.sprite_frames, "AnimatedSprite2D 没有 SpriteFrames：%s" % node_path)
	if animated_sprite.sprite_frames != null:
		assert_eq(animated_sprite.sprite_frames.resource_path, resource_path)
		assert_true(animated_sprite.sprite_frames.has_animation(animation_name))
		assert_gt(animated_sprite.sprite_frames.get_frame_count(animation_name), 0)
	assert_eq(animated_sprite.animation, animation_name)


# TileSet 预览断言 helper：只证明场景可加载项目内 TileSet 并放置可见 tile，不代表最终碰撞清稿。
func _assert_tileset_preview_references_asset(parent: Node, node_path: String) -> void:
	var layer := parent.get_node_or_null(NodePath(node_path)) as TileMapLayer
	assert_not_null(layer, "缺少 TileMapLayer 资产节点：%s" % node_path)
	if layer == null:
		return

	assert_eq(layer.get_meta("asset_id", ""), "miasma_marsh_tileset_ai01")
	assert_not_null(layer.tile_set, "TileMapLayer 没有 TileSet：%s" % node_path)
	if layer.tile_set != null:
		assert_eq(layer.tile_set.resource_path, MIASMA_TILESET_RESOURCE_PATH)
		assert_gt(layer.tile_set.get_source_count(), 0)
	assert_gt(layer.get_used_cells().size(), 0)
	assert_false(layer.visible, "TileSet 预览层只能保留资源引用，不能作为正式道路上屏：%s" % node_path)
