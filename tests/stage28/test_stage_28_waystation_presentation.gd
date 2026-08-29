extends GutTest

# Stage28 回归保护正式驿站显示层、稳定图标状态、两槽视图与三段事件去重。

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const STAGE11_SCENE := preload("res://scenes/rooms/stage11_demo_end_room.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player_placeholder.tscn")
const STAGE11_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const BOUNTY_FRAME_PATH := "res://assets/art/ui/stage28_bounty_archive_frame_warden_ai01.png"
const BOUNTY_IDS: Array[StringName] = [
	&"caster_hunt",
	&"demon_bone_evidence",
	&"seal_pulse_cleanup",
]
const BUILD_IDS: Array[StringName] = [
	&"marsh_relic",
	&"warden_sigil",
	&"caster_core",
	&"guardian_core",
]


func after_each() -> void:
	get_tree().paused = false


func test_stage11_uses_formal_waystation_art_without_replacing_room_contracts() -> void:
	var room := STAGE11_SCENE.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	var background := room.get_node("DemoBackgroundArt") as Sprite2D
	var board := room.get_node("BountyBoardZone/BountyBoardMarkerArt") as Sprite2D
	var clerk := room.get_node("WaystationClerk") as AnimatedSprite2D
	var route := room.get_node("ThunderRouteZone/ThunderRouteMarkerArt") as Sprite2D

	assert_true(background.texture.resource_path.ends_with("stage28_waystation_background_runtime_ai01.png"))
	assert_true((board.texture as AtlasTexture).atlas.resource_path.ends_with("stage28_waystation_world_runtime_ai01.png"))
	assert_eq(clerk.sprite_frames.get_frame_count(&"clerk_idle"), 4)
	assert_true(clerk.is_playing())
	assert_true((route.texture as AtlasTexture).atlas.resource_path.ends_with("stage28_waystation_world_runtime_ai01.png"))
	assert_not_null(room.get_node("ReplayZone/CollisionShape2D").shape)
	assert_not_null(room.get_node("BountyBoardZone/CollisionShape2D").shape)
	assert_true(room.has_signal("room_transition_requested"))
	assert_true(room.has_signal("checkpoint_requested"))


# F03 的整张驿站背景已经包含道路；生产碰撞必须与该道路共用一条可读基线，不能再显示第二层施工地板。
func test_stage11_uses_one_waystation_street_baseline_without_duplicate_solid_visual() -> void:
	var room := STAGE11_SCENE.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	var layout := room.get_node("Phase2GrayboxLayout") as Node2D
	var solid_rects: Array[Rect2] = layout.get("solid_rects")
	var start_position: Vector2 = room.call("get_spawn_position", &"stage11_demo_end_start")
	var camera_limits: Rect2i = room.call("get_camera_limits")

	assert_eq(solid_rects.size(), 1)
	assert_almost_eq(solid_rects[0].position.y, 192.0, 0.01)
	assert_almost_eq(start_position.y + 20.0, solid_rects[0].position.y, 0.01)
	assert_eq(camera_limits.end.y, 224)
	assert_eq(layout.get("show_solid_visuals"), false)
	var solid := layout.get_node("Solid01") as StaticBody2D
	assert_false((solid.get_node("TerrainBodyVisual") as CanvasItem).is_visible_in_tree())
	assert_false((solid.get_node("GroundSurfaceVisual") as CanvasItem).is_visible_in_tree())
	assert_false((room.get_node("GroundSurfaceVisual") as CanvasItem).is_visible_in_tree())
	assert_true((room.get_node("DemoBackgroundArt") as Sprite2D).is_visible_in_tree())


# 同一景深的成人 NPC 与 Luna 应使用接近的运行时体量；当前只锁单元格显示高度，正式人物资产仍另行替换。
func test_waystation_clerk_provisional_scale_matches_luna_runtime_cell_height() -> void:
	var room := STAGE11_SCENE.instantiate() as Node2D
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	add_child_autofree(room)
	add_child_autofree(player)
	await get_tree().process_frame
	var clerk := room.get_node("WaystationClerk") as AnimatedSprite2D
	var luna := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var clerk_frame := clerk.sprite_frames.get_frame_texture(&"clerk_idle", 0)
	var luna_frame := luna.sprite_frames.get_frame_texture(&"idle", 0)
	var display_height_ratio := (
		float(clerk_frame.get_height()) * clerk.scale.y
		/ (float(luna_frame.get_height()) * luna.scale.y)
	)

	assert_between(display_height_ratio, 0.9, 1.12)


func test_bounty_and_build_snapshots_expose_stable_icons_states_and_two_slots() -> void:
	var main := await _spawn_main()
	var bounty_snapshot: Dictionary = main.call("get_bounty_board_snapshot")
	assert_eq((bounty_snapshot.get("entries", []) as Array).size(), 3)
	for entry: Dictionary in bounty_snapshot.get("entries", []):
		assert_ne(StringName(entry.get("icon_id", &"")), StringName())
		assert_eq(entry.get("state_id"), entry.get("state"))

	for build_id: StringName in BUILD_IDS:
		main.call("collect_exploration_reward", build_id)
	var build_snapshot: Dictionary = main.call("get_build_loadout_snapshot")
	assert_eq((build_snapshot.get("entries", []) as Array).size(), 4)
	assert_eq((build_snapshot.get("slots", []) as Array).size(), 2)
	for entry: Dictionary in build_snapshot.get("entries", []):
		assert_ne(StringName(entry.get("icon_id", &"")), StringName())
		assert_true(StringName(entry.get("state_id", &"")) in [&"available", &"equipped"])
	main.call("toggle_build_equipped", &"marsh_relic")
	build_snapshot = main.call("get_build_loadout_snapshot")
	var slots := build_snapshot.get("slots", []) as Array
	assert_eq((slots[1] as Dictionary).get("state_id"), &"empty")


func test_detail_panel_reuses_one_focus_path_with_icons_and_slot_state() -> void:
	var main := await _spawn_main()
	main.call("transition_to_room", STAGE11_PATH, &"stage11_demo_end_start")
	await get_tree().process_frame
	main.call("open_bounty_board")
	var shell := main.get_node("HUD/DemoShell") as Control
	var bounty_list := shell.get_node("DetailPanel/MarginContainer/VBoxContainer/BountyScroll/BountyList") as VBoxContainer
	var context_icon := shell.get_node("DetailPanel/MarginContainer/VBoxContainer/WaystationContextIcon") as TextureRect
	var bounty_frame := shell.get_node("DetailPanel/BountyFrameArt") as TextureRect
	assert_true(context_icon.visible)
	assert_true(bounty_frame.visible)
	assert_eq(bounty_list.get_child_count(), 3)
	for node: Node in bounty_list.get_children():
		var child := node as Button
		assert_not_null(child.icon)
		assert_ne(StringName(child.get_meta("icon_id", &"")), StringName())
	var first_bounty := bounty_list.get_child(0) as Button
	var second_bounty := bounty_list.get_child(1) as Button
	assert_eq(first_bounty.focus_neighbor_bottom, first_bounty.get_path_to(second_bounty))
	(shell.get_node("DetailPanel/MarginContainer/VBoxContainer/DetailBackButton") as Button).pressed.emit()

	for build_id: StringName in BUILD_IDS:
		main.call("collect_exploration_reward", build_id)
	main.call("open_build_loadout")
	await get_tree().process_frame
	assert_false(bounty_frame.visible)
	var slot_row := shell.get_node("DetailPanel/MarginContainer/VBoxContainer/BuildSlotRow") as HBoxContainer
	assert_true(slot_row.visible)
	assert_eq(slot_row.get_child_count(), 2)
	assert_eq(bounty_list.get_child_count(), 4)
	for node: Node in bounty_list.get_children():
		var child := node as Button
		assert_not_null(child.icon)
		assert_ne(StringName(child.get_meta("state_id", &"")), StringName())
	var first_build := bounty_list.get_child(0) as Button
	var second_build := bounty_list.get_child(1) as Button
	assert_eq(first_build.focus_neighbor_bottom, first_build.get_path_to(second_build))
	(shell.get_node("DetailPanel/MarginContainer/VBoxContainer/DetailBackButton") as Button).pressed.emit()
	await get_tree().process_frame


# 2K 运行态的悬赏榜不能继续沿用 460x300 小卡片；三条任务、头像和返回操作都要留在面板安全区。
func test_bounty_panel_is_readable_and_contained_at_large_viewport() -> void:
	var main := await _spawn_main()
	main.call("transition_to_room", STAGE11_PATH, &"stage11_demo_end_start")
	await get_tree().process_frame
	main.call("open_bounty_board")
	await get_tree().process_frame
	await get_tree().process_frame
	var shell := main.get_node("HUD/DemoShell") as Control
	var panel := shell.get_node("DetailPanel") as Panel
	var frame := panel.get_node("BountyFrameArt") as TextureRect
	var scrim := shell.get_node_or_null("DetailScrim") as ColorRect
	var title := panel.get_node("MarginContainer/VBoxContainer/DetailTitleLabel") as Label
	var body := panel.get_node("MarginContainer/VBoxContainer/DetailBodyLabel") as Label
	var scroll := panel.get_node("MarginContainer/VBoxContainer/BountyScroll") as ScrollContainer
	var list := scroll.get_node("BountyList") as VBoxContainer
	var back := panel.get_node("MarginContainer/VBoxContainer/DetailBackButton") as Button
	var viewport_size := shell.get_viewport_rect().size

	assert_not_null(scrim)
	assert_true(frame.visible)
	assert_eq(frame.texture.resource_path, BOUNTY_FRAME_PATH)
	assert_eq(frame.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(frame.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var frame_image := frame.texture.get_image()
	assert_almost_eq(frame_image.get_pixel(0, 0).a, 0.0, 0.01)
	assert_gte(frame_image.get_pixel(frame_image.get_width() / 2, frame_image.get_height() / 2).a, 0.9)
	if scrim != null:
		assert_true(scrim.visible)
		assert_gte(scrim.color.a, 0.45)
	if viewport_size.x >= 1280.0 and viewport_size.y >= 720.0:
		assert_gte(panel.size.x / viewport_size.x, 0.32)
		assert_gte(panel.size.y / viewport_size.y, 0.42)
		assert_between(panel.size.x / panel.size.y, 1.02, 1.16)
		assert_gte(title.get_theme_font_size("font_size"), 24)
		assert_gte(body.get_theme_font_size("font_size"), 18)
		assert_gte(title.get_theme_color("font_color").get_luminance(), 0.55)
		assert_gte(body.get_theme_color("font_color").get_luminance(), 0.55)
		assert_gte(scroll.size.y, 190.0)
	assert_true(panel.get_global_rect().encloses(title.get_global_rect()))
	assert_true(panel.get_global_rect().encloses(body.get_global_rect()))
	assert_true(panel.get_global_rect().encloses(scroll.get_global_rect()))
	assert_true(panel.get_global_rect().encloses(back.get_global_rect()))
	assert_eq(list.get_child_count(), 3)
	for node: Node in list.get_children():
		var button := node as Button
		assert_string_contains(button.text, "\n")
		assert_gte(button.get_theme_font_size("font_size"), 14)
		assert_true(scroll.get_global_rect().encloses(button.get_global_rect()))


# F03 同时显示目标、提示、风印和 Build 时，左上状态文字仍必须留在正式框体内容区。
func test_f03_progress_text_stays_inside_battle_panel_capacity() -> void:
	var main := await _spawn_main()
	assert_true(bool(main.call("start_demo_at_room", STAGE11_PATH, &"stage11_demo_end_start", {
		"wind_seal_unlocked": true,
		"exploration_rewards": ["marsh_relic"],
		"equipped_build_ids": ["marsh_relic"],
		"active_build_id": "marsh_relic",
	})))
	await get_tree().process_frame
	await get_tree().process_frame
	var battle_panel := main.get_node("HUD/TutorialHUD/BattlePanel") as Panel
	var progress := battle_panel.get_node("ProgressLabel") as Label

	assert_lte(progress.text.split("\n").size(), 2)
	assert_lte(progress.get_line_count(), 2)
	assert_lte(progress.get_combined_minimum_size().y, progress.size.y + 1.0)


func test_all_bounties_and_thunder_return_events_are_deferred_and_deduplicated() -> void:
	var main := await _spawn_main()
	main.call("transition_to_room", STAGE11_PATH, &"stage11_demo_end_start")
	await get_tree().process_frame
	for bounty_id: StringName in BOUNTY_IDS:
		main.call("advance_bounty", bounty_id)
		main.call("_complete_bounty", bounty_id)
		main.call("advance_bounty", bounty_id)
	await get_tree().process_frame
	var snapshot: Dictionary = main.call("get_demo_progress_snapshot")
	assert_true(bool(snapshot.get("stage28_all_bounties_story_completed", false)))
	assert_eq(int(snapshot.get("story_event_count", 0)), 1)

	var back := main.get_node("HUD/DemoShell/DetailPanel/MarginContainer/VBoxContainer/DetailBackButton") as Button
	back.pressed.emit()
	main.call("transition_to_room", STAGE11_PATH, &"stage11_thunder_waste_return")
	await get_tree().process_frame
	snapshot = main.call("get_demo_progress_snapshot")
	assert_true(bool(snapshot.get("stage28_thunder_return_story_completed", false)))
	assert_eq(int(snapshot.get("story_event_count", 0)), 2)
	back.pressed.emit()
	main.call("transition_to_room", STAGE11_PATH, &"stage11_thunder_waste_return")
	await get_tree().process_frame
	assert_eq(int((main.call("get_demo_progress_snapshot") as Dictionary).get("story_event_count", 0)), 2)


func _spawn_main() -> Node2D:
	var main := MAIN_SCENE.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	return main
