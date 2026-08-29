extends GutTest

# 第二阶段 2.3 施工校准回归：保护 F04-F09 不只“有碰撞”，还要让生产锚点、
# 高度层、移动间距和回访入口真正对齐已批准蓝图。

const F04 := "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"
const F05 := "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"
const F06 := "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"
const F07 := "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"
const F08 := "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"
const F09 := "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"
const SOLID_TEXTURE := "res://assets/art/textures/dac_continuous_stone_underlay.png"
const GROUND_ATLAS_TEXTURE := "res://assets/art/tilesets/shrine_trial_tileset_ai01.png"
const GROUND_SURFACE_REGION := Rect2(0, 0, 192, 64)
const GROUND_ALPHA_TOP_INSET := 37.0
const PLATFORM_TEXTURE := "res://assets/art/tilesets/tutorial_jump_platform_visual_ai02.png"
const PLATFORM_ALPHA_TOP_INSET := 23.0


# 删除全景、下降或远景锚点，或把它们重新挤回同一屏，都会失去 F04 的区域揭示节奏。
func test_f04_landmarks_follow_three_segment_reveal_positions() -> void:
	var room := await _spawn_room(F04)
	var vista := room.get_node("RegionVistaMarker") as Node2D
	var descent := room.get_node("MarshDescentMarker") as Node2D
	var cross_gate := room.get_node("CrossGateVistaMarker") as Node2D
	assert_between(vista.position.x, 64.0, 192.0)
	assert_between(descent.position.x, 592.0, 704.0)
	assert_between(cross_gate.position.x, 1088.0, 1216.0)
	assert_lt(vista.position.y, descent.position.y)


# F05 必须先给安全观察点，再出现施法者、授印龛和移动应用点。
func test_f05_publishes_observe_caster_shrine_practice_order() -> void:
	var room := await _spawn_room(F05)
	var observe := room.get_node_or_null("ProjectileObservationMarker") as Node2D
	assert_not_null(observe)
	if observe == null:
		return
	var caster := room.get_node("MiasmaCasterEnemy") as Node2D
	var shrine := room.get_node("WindSealShrine") as Node2D
	var practice := room.get_node("ProjectilePracticeMarker") as Node2D
	assert_lt(observe.position.x, caster.position.x)
	assert_lt(caster.position.x, shrine.position.x)
	assert_lt(shrine.position.x, practice.position.x)
	assert_gte(caster.position.x - observe.position.x, 160.0)


# F06 奖励属于下层 Air Dash 回访线，不能再次漂到首次安全上层。
func test_f06_air_dash_reward_is_supported_on_lower_revisit_route() -> void:
	var room := await _spawn_room(F06)
	var layout := room.get_node("Phase2GrayboxLayout")
	var reward := room.get_node("AirDashRevisitReward") as Node2D
	var upper := float(layout.call("get_route_height", &"upper_main"))
	var lower := float(layout.call("get_route_height", &"lower_revisit"))
	assert_gt(reward.position.y, upper + 72.0)
	assert_between(lower - reward.position.y, 24.0, 56.0)
	assert_true(bool(layout.call("has_support_below", reward.position, 56.0)))


# F06 的下层实体必须完整进入相机范围，不能只在物理世界存在、画面却永远看不到。
func test_f06_camera_contains_the_lower_revisit_floor() -> void:
	var room := await _spawn_room(F06)
	var layout := room.get_node("Phase2GrayboxLayout")
	var limits: Rect2i = room.call("get_camera_limits")
	var lowest_bottom := -INF
	for rect: Rect2 in layout.get("solid_rects"):
		lowest_bottom = maxf(lowest_bottom, rect.end.y)
	assert_gte(float(limits.end.y), lowest_bottom)


# 六房的正式表面必须由 Phase2 矩形直接生成；旧 TileMap 只能退出显示，不能继续与新碰撞错位叠加。
func test_f04_to_f09_runtime_visuals_share_the_phase2_collision_rects() -> void:
	for path: String in [F04, F05, F06, F07, F08, F09]:
		var room := await _spawn_room(path)
		assert_false((room.get_node("GroundSurfaceVisual") as CanvasItem).visible, "%s 旧地面表面必须退役" % path)
		assert_false((room.get_node("ThinPlatformSurfaceVisual") as CanvasItem).visible, "%s 旧跳台表面必须退役" % path)
		var layout := room.get_node("Phase2GrayboxLayout")
		var platform_count := 0
		for child: Node in layout.get_children():
			if not child is StaticBody2D:
				continue
			platform_count += 1
			var collision := child.get_node("CollisionShape2D") as CollisionShape2D
			var shape := collision.shape as RectangleShape2D
			var surface_name := "OneWaySurfaceVisual" if collision.one_way_collision else "GroundSurfaceVisual"
			var surface := child.get_node_or_null(surface_name) as NinePatchRect
			assert_not_null(surface, "%s/%s 缺少同源地形表面" % [path, child.name])
			if surface == null:
				continue
			assert_almost_eq(surface.size.x, shape.size.x, 0.01)
			var alpha_top_inset := PLATFORM_ALPHA_TOP_INSET if collision.one_way_collision else GROUND_ALPHA_TOP_INSET
			assert_almost_eq(surface.position.y + alpha_top_inset, -shape.size.y * 0.5, 0.01)
			var body_visual := child.get_node_or_null("TerrainBodyVisual") as Polygon2D
			if collision.one_way_collision:
				assert_eq(surface.texture.resource_path, PLATFORM_TEXTURE)
				assert_null(body_visual)
			else:
				assert_true(surface.texture is AtlasTexture, "%s/%s 实体地面必须使用专用地面条" % [path, child.name])
				var ground_surface := surface.texture as AtlasTexture
				if ground_surface != null:
					assert_eq(ground_surface.atlas.resource_path, GROUND_ATLAS_TEXTURE)
					assert_eq(ground_surface.region, GROUND_SURFACE_REGION)
				assert_not_null(body_visual)
				if body_visual != null:
					assert_eq(body_visual.texture.resource_path, SOLID_TEXTURE)
		assert_eq(platform_count, int(layout.call("get_runtime_platform_count")))


# 六房扩宽后，旧背景尺寸不能在中段和出口露出纯色空洞。
func test_f04_to_f09_background_covers_every_camera_limit() -> void:
	for path: String in [F04, F05, F06, F07, F08, F09]:
		var room := await _spawn_room(path)
		var limits: Rect2i = room.call("get_camera_limits")
		var background := room.get_node("MiasmaBackgroundArt") as Sprite2D
		var visual_size := background.texture.get_size() * background.scale.abs()
		var visual_bounds := Rect2(background.position - visual_size * 0.5, visual_size)
		assert_lte(visual_bounds.position.x, float(limits.position.x), "%s 背景左侧未覆盖相机" % path)
		assert_lte(visual_bounds.position.y, float(limits.position.y), "%s 背景上方未覆盖相机" % path)
		assert_gte(visual_bounds.end.x, float(limits.end.x), "%s 背景右侧未覆盖相机" % path)
		assert_gte(visual_bounds.end.y, float(limits.end.y), "%s 背景下方未覆盖相机" % path)
		var backdrop := room.get_node("Backdrop") as Polygon2D
		var backdrop_bounds := Rect2(backdrop.polygon[0], backdrop.polygon[2] - backdrop.polygon[0])
		assert_lte(backdrop_bounds.position.x, float(limits.position.x), "%s 半透明背景底色左侧未覆盖相机" % path)
		assert_lte(backdrop_bounds.position.y, float(limits.position.y), "%s 半透明背景底色上方未覆盖相机" % path)
		assert_gte(backdrop_bounds.end.x, float(limits.end.x), "%s 半透明背景底色右侧未覆盖相机" % path)
		assert_gte(backdrop_bounds.end.y, float(limits.end.y), "%s 半透明背景底色下方未覆盖相机" % path)
		assert_lte(backdrop_bounds.position.x, visual_bounds.position.x, "%s 背景底色未覆盖半透明画面左侧" % path)
		assert_lte(backdrop_bounds.position.y, visual_bounds.position.y, "%s 背景底色未覆盖半透明画面上方" % path)
		assert_gte(backdrop_bounds.end.x, visual_bounds.end.x, "%s 背景底色未覆盖半透明画面右侧" % path)
		assert_gte(backdrop_bounds.end.y, visual_bounds.end.y, "%s 背景底色未覆盖半透明画面下方" % path)


# F07 的能力门与捷径必须是两个空间事件；F14 返回出生点落在捷径前庭。
func test_f07_gate_and_shortcut_are_separated_on_supported_lower_route() -> void:
	var room := await _spawn_room(F07)
	var layout := room.get_node("Phase2GrayboxLayout")
	var gate := room.get_node("GateBarrier") as Node2D
	var shortcut := room.get_node("ShortcutZone") as Node2D
	assert_gte(shortcut.position.x - gate.position.x, 192.0)
	assert_gt(shortcut.position.y, float(layout.call("get_route_height", &"first_visit_bypass")))
	assert_true(bool(layout.call("has_support_below", shortcut.position, 56.0)))
	var return_spawn: Vector2 = room.call("get_spawn_position", &"stage13_gate_from_wind_cross")
	assert_gt(return_spawn.distance_to(shortcut.position), 48.0)
	assert_lte(return_spawn.distance_to(shortcut.position), 72.0)


# F10 回环必须落在蓝图的上层落点，再安全下降到 F08，而不是落到出口旁。
func test_f08_resource_loop_landing_matches_upper_reset_point() -> void:
	var room := await _spawn_room(F08)
	var marker := room.get_node_or_null("ResourceLoopLandingMarker") as Node2D
	assert_not_null(marker)
	if marker == null:
		return
	var spawn: Vector2 = room.call("get_spawn_position", &"stage13_checkpoint_from_resource_branch")
	assert_lte(spawn.distance_to(marker.position), 1.0)
	assert_between(marker.position.x, 368.0, 464.0)
	assert_true(bool(room.get_node("Phase2GrayboxLayout").call("has_support_below", marker.position, 32.0)))
	assert_gte((room.get_node("ExitZone") as Node2D).position.x - marker.position.x, 384.0)


# F09 必须在 S1 预读高速入口、S2 判读三路、S3 才触发上层高速出口；
# 下层资源线还必须有足够头部空间，不能只是画在中层实心地板下面。
func test_f09_three_routes_are_physically_distinct_and_traversable() -> void:
	var room := await _spawn_room(F09)
	var layout := room.get_node("Phase2GrayboxLayout")
	var fast_entry := room.get_node_or_null("AirDashFastRouteEntryMarker") as Node2D
	var landmark := room.get_node_or_null("ThreeRouteLandmark") as Node2D
	assert_not_null(fast_entry)
	assert_not_null(landmark)
	if fast_entry == null or landmark == null:
		return
	var resource := room.get_node("ResourceBranchZone") as Node2D
	var challenge := room.get_node("ChallengeBranchZone") as Node2D
	var fast_exit := room.get_node("AirDashFastRouteExitMarker") as Node2D
	var fast_trigger := room.get_node("AirDashFastRouteZone") as Node2D
	var main_exit := room.get_node("ExitZone") as Node2D
	assert_lte(fast_entry.position.x, 192.0)
	assert_between(landmark.position.x, 544.0, 672.0)
	assert_between(resource.position.x, 1024.0, 1152.0)
	assert_between(challenge.position.x, 1152.0, 1248.0)
	assert_gte(fast_exit.position.x, 1480.0)
	assert_lt(fast_trigger.position.x, challenge.position.x)
	assert_lt(challenge.position.y, main_exit.position.y)
	assert_lt(main_exit.position.y, resource.position.y)
	assert_gte(float(layout.call("get_vertical_clearance_above", resource.position)), 48.0)
	assert_lte(float(layout.call("get_max_surface_gap", &"main")), 110.0)


func _spawn_room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed)
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room
