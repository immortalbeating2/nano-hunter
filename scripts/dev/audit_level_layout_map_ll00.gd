extends SceneTree

# LL-00 关卡场景和地图布置审计。
# 本脚本只加载关键房间、截图并输出结构化问题表，不修改任何场景资源。

const OUT_DIR := "res://tests/artifacts/local/level-layout-map-polish/ll00_audit"
const SCREENSHOT_DIR := "%s/screenshots" % OUT_DIR
const OUT_JSON := "%s/ll00_level_layout_audit_report.json" % OUT_DIR
const OUT_MD := "%s/ll00_level_layout_audit_report.md" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(960, 540)
const SCREENSHOT_PADDING_RATIO := 0.9
const SAMPLE_STEP := 10

const ROOM_SPECS := [
	{
		"id": "tutorial_room",
		"stage": "Tutorial",
		"path": "res://scenes/rooms/tutorial_room.tscn",
		"intent": "移动、跳跃、冲刺和攻击教学四段清楚可通。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_entry",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn",
		"intent": "瘴泽妖域入口，低压读值和区域视觉建立。",
		"tileset_sample": true,
	},
	{
		"id": "stage13_miasma_marsh_caster",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn",
		"intent": "远程瘴气敌人首次压力。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_miasma",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn",
		"intent": "腐瘴危险识别与受击反馈。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_gate",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn",
		"intent": "封印门控与局部解锁。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_crossfire",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_crossfire_room.tscn",
		"intent": "交叉火力与平台压力。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_checkpoint",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn",
		"intent": "区域中段 checkpoint 与节奏缓冲。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_pressure",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn",
		"intent": "主线压力段，验证连续推进读值。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_branch_hub",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn",
		"intent": "资源支路和挑战支路分流。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_resource_branch",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn",
		"intent": "低风险资源收益支路。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_challenge_branch",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn",
		"intent": "高风险挑战收益支路。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_return",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_return_room.tscn",
		"intent": "支路回到主线后的重新汇合。",
		"tileset_sample": false,
	},
	{
		"id": "stage13_miasma_marsh_goal",
		"stage": "Stage13",
		"path": "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn",
		"intent": "第二小区域终点，进入 Stage14 神龛。",
		"tileset_sample": false,
	},
	{
		"id": "stage14_air_dash_shrine",
		"stage": "Stage14",
		"path": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn",
		"intent": "空中冲刺获得点和能力表达。",
		"tileset_sample": true,
	},
	{
		"id": "stage14_air_dash_gate",
		"stage": "Stage14",
		"path": "res://scenes/rooms/stage14_air_dash_gate_room.tscn",
		"intent": "空中冲刺能力门验证。",
		"tileset_sample": true,
	},
	{
		"id": "stage14_backtrack_hub",
		"stage": "Stage14",
		"path": "res://scenes/rooms/stage14_backtrack_hub_room.tscn",
		"intent": "回溯收益集合点。",
		"tileset_sample": false,
	},
	{
		"id": "stage14_loop_return",
		"stage": "Stage14",
		"path": "res://scenes/rooms/stage14_loop_return_room.tscn",
		"intent": "能力回环完成并进入 Stage15。",
		"tileset_sample": false,
	},
	{
		"id": "stage15_seal_pressure",
		"stage": "Stage15",
		"path": "res://scenes/rooms/stage15_seal_pressure_room.tscn",
		"intent": "Boss 前压力铺垫。",
		"tileset_sample": false,
	},
	{
		"id": "stage15_mixed_gauntlet",
		"stage": "Stage15",
		"path": "res://scenes/rooms/stage15_mixed_gauntlet_room.tscn",
		"intent": "混合敌人遭遇和全清门控。",
		"tileset_sample": false,
	},
	{
		"id": "stage15_challenge_branch",
		"stage": "Stage15",
		"path": "res://scenes/rooms/stage15_challenge_branch_room.tscn",
		"intent": "战斗挑战支路。",
		"tileset_sample": false,
	},
	{
		"id": "stage15_seal_guardian_boss",
		"stage": "Stage15",
		"path": "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn",
		"intent": "封印守卫 Boss 战空间、预警和胜利推进。",
		"tileset_sample": true,
	},
	{
		"id": "stage15_completion",
		"stage": "Stage15",
		"path": "res://scenes/rooms/stage15_completion_room.tscn",
		"intent": "Boss 后完成反馈并接入 Stage16。",
		"tileset_sample": false,
	},
	{
		"id": "stage16_seal_release_threshold",
		"stage": "Stage16",
		"path": "res://scenes/rooms/stage16_seal_release_threshold_room.tscn",
		"intent": "终局封印链起点。",
		"tileset_sample": true,
	},
	{
		"id": "stage16_talisman_relay",
		"stage": "Stage16",
		"path": "res://scenes/rooms/stage16_talisman_relay_room.tscn",
		"intent": "符印中继三点激活。",
		"tileset_sample": false,
	},
	{
		"id": "stage16_backtrack_confirmation",
		"stage": "Stage16",
		"path": "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn",
		"intent": "回溯收益确认。",
		"tileset_sample": false,
	},
	{
		"id": "stage16_corruption_purge",
		"stage": "Stage16",
		"path": "res://scenes/rooms/stage16_corruption_purge_room.tscn",
		"intent": "妖瘴净化和终局压力。",
		"tileset_sample": false,
	},
	{
		"id": "stage16_alpha_demo_end",
		"stage": "Stage16",
		"path": "res://scenes/rooms/stage16_alpha_demo_end_room.tscn",
		"intent": "Alpha Demo 终点反馈。",
		"tileset_sample": false,
	},
]


func _init() -> void:
	_run.call_deferred()


# 主入口：逐房审计并写出本地 JSON / Markdown 报告。
func _run() -> void:
	var result := await _audit_all_rooms()
	quit(result)


# 审计全部关键房间；发现 P0/P1/P2 只进入报告，不让审计脚本本身失败。
func _audit_all_rooms() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))
	root.size = VIEWPORT_SIZE

	var room_reports: Array = []
	for spec: Dictionary in ROOM_SPECS:
		room_reports.append(await _audit_room(spec))

	var report := _build_report(room_reports)
	var json_ok := _write_text(OUT_JSON, JSON.stringify(report, "\t"))
	var md_ok := _write_text(OUT_MD, _build_markdown_report(report))
	if not json_ok or not md_ok:
		return 1

	print("LL-00 level layout audit complete: %s" % OUT_MD)
	print("P0=%s P1=%s P2=%s" % [report.issue_counts.P0, report.issue_counts.P1, report.issue_counts.P2])
	return 0


# 加载一个房间，等待 ready 后截图，并提取地图 / 碰撞 / 出口 / 视觉层信息。
func _audit_room(spec: Dictionary) -> Dictionary:
	var scene_path := str(spec.get("path", ""))
	var packed_scene := ResourceLoader.load(scene_path) as PackedScene
	if packed_scene == null:
		return _failed_room_report(spec, "cannot_load_scene")

	var holder := Node2D.new()
	root.add_child(holder)
	var instance := packed_scene.instantiate()
	if instance == null:
		holder.free()
		return _failed_room_report(spec, "cannot_instantiate_scene")

	holder.add_child(instance)
	await process_frame
	await process_frame

	var camera_rect := _get_camera_rect(instance)
	var nodes := _collect_nodes(instance)
	var room_report := _inspect_room(spec, instance, nodes, camera_rect)

	_frame_holder(holder, camera_rect)
	await process_frame
	await process_frame

	var image_path := "%s/%s.png" % [SCREENSHOT_DIR, str(spec.get("id", "room"))]
	var image: Image = null
	if DisplayServer.get_name() != "headless":
		var viewport_texture := root.get_texture()
		image = viewport_texture.get_image() if viewport_texture != null else null
	room_report["screenshot"] = image_path
	room_report["screenshot_saved"] = image != null and not image.is_empty() and image.save_png(image_path) == OK
	room_report["screenshot_stats"] = _analyze_image(image)

	holder.free()
	return room_report


# 加载失败也保持同一份报告结构，便于后续 LL-01 直接消费 P0。
func _failed_room_report(spec: Dictionary, reason: String) -> Dictionary:
	return {
		"id": str(spec.get("id", "")),
		"stage": str(spec.get("stage", "")),
		"path": str(spec.get("path", "")),
		"intent": str(spec.get("intent", "")),
		"load_ok": false,
		"issues": [_make_issue("P0", reason, "房间无法加载或实例化，主链路必须优先修复。")],
	}


# 根据相机矩形把房间缩放居中到审计视口，截图能看到完整布置。
func _frame_holder(holder: Node2D, camera_rect: Rect2) -> void:
	var room_size := camera_rect.size
	var scale_x := float(VIEWPORT_SIZE.x) / maxf(room_size.x, 1.0)
	var scale_y := float(VIEWPORT_SIZE.y) / maxf(room_size.y, 1.0)
	var scale_value := minf(scale_x, scale_y) * SCREENSHOT_PADDING_RATIO
	holder.scale = Vector2(scale_value, scale_value)
	holder.position = Vector2(VIEWPORT_SIZE) * 0.5 - camera_rect.get_center() * scale_value


# 优先读取房间公开相机接口，缺失时保守使用默认可视范围。
func _get_camera_rect(room: Node) -> Rect2:
	if room.has_method("get_camera_limits"):
		var limits: Variant = room.call("get_camera_limits")
		if typeof(limits) == TYPE_RECT2I:
			var rect_i := limits as Rect2i
			return Rect2(Vector2(rect_i.position), Vector2(rect_i.size))
		if typeof(limits) == TYPE_RECT2:
			return limits as Rect2

	return Rect2(Vector2(-480, -270), Vector2(960, 540))


# 收集房间内全部节点，后续统计统一从这个数组读，避免多次递归。
func _collect_nodes(root_node: Node) -> Array:
	var nodes: Array = []
	_collect_nodes_recursive(root_node, nodes)
	return nodes


# 递归遍历节点树。
func _collect_nodes_recursive(node: Node, nodes: Array) -> void:
	nodes.append(node)
	for child: Node in node.get_children():
		_collect_nodes_recursive(child, nodes)


# 汇总单房间地图结构，并按保守规则生成 P0/P1/P2 问题。
func _inspect_room(spec: Dictionary, room: Node, nodes: Array, camera_rect: Rect2) -> Dictionary:
	var spawn_position := _get_spawn_position(room)
	var exit_nodes := _find_named_nodes(nodes, ["ExitZone", "GoalZone", "ContinueZone"])
	var gate_nodes := _find_named_nodes(nodes, ["GateBarrier", "ExitBarrier"])
	var hazard_nodes := _find_keyword_nodes(nodes, ["Hazard", "CorruptionMiasma"])
	var tilemap_reports := _inspect_tilemaps(nodes)
	var visual_reports := _inspect_visuals(nodes)
	var collision_summary := _inspect_collision(nodes)
	var issue_list := _build_issues(spec, room, nodes, camera_rect, spawn_position, exit_nodes, gate_nodes, hazard_nodes, tilemap_reports, visual_reports, collision_summary)

	return {
		"id": str(spec.get("id", "")),
		"stage": str(spec.get("stage", "")),
		"path": str(spec.get("path", "")),
		"intent": str(spec.get("intent", "")),
		"load_ok": true,
		"camera_limits": _rect_to_array(camera_rect),
		"spawn_position": _vector_to_array(spawn_position),
		"exit_nodes": _nodes_to_reports(room, exit_nodes),
		"gate_nodes": _nodes_to_reports(room, gate_nodes),
		"hazard_nodes": _nodes_to_reports(room, hazard_nodes),
		"tilemaps": tilemap_reports,
		"visual_assets": visual_reports,
		"collision": collision_summary,
		"node_counts": _count_node_types(nodes),
		"issues": issue_list,
	}


# 读取房间出生点接口；缺失时回退零点并由 issue 规则标记。
func _get_spawn_position(room: Node) -> Vector2:
	if room.has_method("get_spawn_position"):
		var value: Variant = room.call("get_spawn_position", StringName())
		if typeof(value) == TYPE_VECTOR2:
			return value as Vector2

	return Vector2.ZERO


# 按精确节点名收集关键交互节点。
func _find_named_nodes(nodes: Array, names: Array) -> Array:
	var result: Array = []
	for node: Node in nodes:
		if names.has(str(node.name)):
			result.append(node)
	return result


# 按名称关键词收集危险、净化、腐化等地图语义节点。
func _find_keyword_nodes(nodes: Array, keywords: Array) -> Array:
	var result: Array = []
	for node: Node in nodes:
		var node_name := str(node.name).to_lower()
		if _is_visual_reference_name(node_name):
			continue
		for keyword: String in keywords:
			if node_name.find(keyword.to_lower()) >= 0:
				result.append(node)
				break
	return result


# 带危险词的纯美术参考图不等于可伤害区域，避免把背景图误分流到 LL-04。
func _is_visual_reference_name(node_name: String) -> bool:
	return node_name.ends_with("art") or node_name.find("preview") >= 0 or node_name.find("tileset") >= 0


# TileMapLayer 审计：只记录资源、格子数量和 visual-only 元信息。
func _inspect_tilemaps(nodes: Array) -> Array:
	var reports: Array = []
	for node: Node in nodes:
		if node is TileMapLayer:
			var tilemap := node as TileMapLayer
			reports.append({
				"name": str(node.name),
				"path": str(node.get_path()),
				"visible": tilemap.visible,
				"tile_set": tilemap.tile_set.resource_path if tilemap.tile_set != null else "",
				"used_cell_count": tilemap.get_used_cells().size(),
				"asset_id": str(node.get_meta("asset_id", "")),
				"binding_note": str(node.get_meta("asset_binding_note", "")),
			})
	return reports


# 视觉资产审计：记录带贴图或 asset_id 的可见节点。
func _inspect_visuals(nodes: Array) -> Array:
	var reports: Array = []
	for node: Node in nodes:
		var resource_path := _resource_path_for(node)
		var asset_id := str(node.get_meta("asset_id", ""))
		if resource_path.is_empty() and asset_id.is_empty():
			continue
		var visible := true
		if node is CanvasItem:
			visible = (node as CanvasItem).visible
		reports.append({
			"name": str(node.name),
			"path": str(node.get_path()),
			"type": node.get_class(),
			"visible": visible,
			"resource_path": resource_path,
			"asset_id": asset_id,
			"binding_note": str(node.get_meta("asset_binding_note", "")),
		})
	return reports


# 抽取常见视觉资源路径，帮助判断是否仍停留在无资源灰盒。
func _resource_path_for(node: Node) -> String:
	if node is Sprite2D:
		var sprite := node as Sprite2D
		return sprite.texture.resource_path if sprite.texture != null else ""
	if node is TextureRect:
		var rect := node as TextureRect
		return rect.texture.resource_path if rect.texture != null else ""
	if node is NinePatchRect:
		var patch := node as NinePatchRect
		return patch.texture.resource_path if patch.texture != null else ""
	if node is AnimatedSprite2D:
		var animated := node as AnimatedSprite2D
		return animated.sprite_frames.resource_path if animated.sprite_frames != null else ""
	if node is TileMapLayer:
		var tilemap := node as TileMapLayer
		return tilemap.tile_set.resource_path if tilemap.tile_set != null else ""
	return ""


# 碰撞审计聚合物理体、Area、碰撞形状、禁用碰撞和明显灰盒视觉数量。
func _inspect_collision(nodes: Array) -> Dictionary:
	var bodies := 0
	var areas := 0
	var shapes := 0
	var disabled_shapes := 0
	var polygons := 0
	var graybox_polygons := 0
	for node: Node in nodes:
		if node is StaticBody2D or node is CharacterBody2D or node is RigidBody2D:
			bodies += 1
		if node is Area2D:
			areas += 1
		if node is CollisionShape2D:
			shapes += 1
			if (node as CollisionShape2D).disabled:
				disabled_shapes += 1
		if node is CollisionPolygon2D:
			polygons += 1
		if node is Polygon2D and str(node.get_meta("asset_id", "")).is_empty():
			graybox_polygons += 1
	return {
		"physics_body_count": bodies,
		"area_count": areas,
		"collision_shape_count": shapes,
		"disabled_collision_shape_count": disabled_shapes,
		"collision_polygon_count": polygons,
		"graybox_polygon_count": graybox_polygons,
	}


# 生成保守问题表：P0 只标记加载 / 主链路契约断裂，P1/P2 记录布局和美术后续项。
func _build_issues(
	spec: Dictionary,
	room: Node,
	nodes: Array,
	camera_rect: Rect2,
	spawn_position: Vector2,
	exit_nodes: Array,
	gate_nodes: Array,
	hazard_nodes: Array,
	tilemaps: Array,
	visuals: Array,
	collision_summary: Dictionary
) -> Array:
	var issues: Array = []
	var room_id := str(spec.get("id", ""))

	if not room.has_method("get_spawn_position"):
		issues.append(_make_issue("P0", "missing_spawn_interface", "房间缺少 get_spawn_position，Main 切房后无法稳定出生。"))
	if not room.has_method("get_camera_limits"):
		issues.append(_make_issue("P0", "missing_camera_interface", "房间缺少 get_camera_limits，分辨率变化后构图风险很高。"))

	var has_boss_or_auto_transition := _has_node_named(nodes, "SealGuardianBoss")
	if exit_nodes.is_empty() and not has_boss_or_auto_transition:
		issues.append(_make_issue("P0", "missing_progression_zone", "房间没有 ExitZone / GoalZone / ContinueZone，也不是 Boss 自动推进房。"))

	if not camera_rect.has_point(spawn_position):
		issues.append(_make_issue("P1", "spawn_outside_camera_limits", "出生点不在 camera limits 内，运行时可能看不到玩家或起点。"))

	for exit_node: Node in exit_nodes:
		if exit_node is Node2D and not camera_rect.has_point((exit_node as Node2D).global_position):
			issues.append(_make_issue("P1", "progression_zone_outside_camera_limits", "%s 不在 camera limits 内，可能造成出口读值差。" % str(exit_node.name)))

	if not gate_nodes.is_empty() and not _has_unlock_evidence(room, nodes):
		issues.append(_make_issue("P1", "gate_without_clear_unlock_evidence", "存在门或封印柱，但未找到明显解锁节点 / 敌人 / 可攻击目标证据，需要人工复核。"))

	if not hazard_nodes.is_empty() and _hazard_area_count(hazard_nodes) <= 0:
		issues.append(_make_issue("P1", "hazard_without_area_authoring", "危险节点目前更像位置触发或视觉标记，LL-04 需要补 Area2D / collision author。"))

	if bool(spec.get("tileset_sample", false)) and tilemaps.is_empty():
		issues.append(_make_issue("P2", "sample_room_missing_runtime_tilemap", "样板房未发现 runtime TileMapLayer，LL-03 应优先接入现有 TileSet。"))

	for tilemap: Dictionary in tilemaps:
		if int(tilemap.get("used_cell_count", 0)) <= 0:
			issues.append(_make_issue("P2", "empty_tilemap_layer", "%s 已挂 TileMapLayer 但没有已用格子。" % str(tilemap.get("name", ""))))

	if visuals.is_empty() and room_id != "tutorial_room":
		issues.append(_make_issue("P2", "no_asset_bound_visuals", "房间没有发现带贴图或 asset_id 的美术节点，灰盒感会很强。"))

	var graybox_count := int(collision_summary.get("graybox_polygon_count", 0))
	if graybox_count >= 4 and visuals.size() <= 2:
		issues.append(_make_issue("P2", "graybox_visual_dominant", "无 asset_id 的 Polygon2D 较多，当前视觉仍以灰盒块为主。"))

	return issues


# 判断门控是否有可解释的解锁来源，避免把所有门控都判成阻塞。
func _has_unlock_evidence(room: Node, nodes: Array) -> bool:
	var air_dash_gate_value: Variant = room.get("air_dash_gate_room")
	if typeof(air_dash_gate_value) == TYPE_BOOL and air_dash_gate_value:
		return true
	var require_all_enemies_value: Variant = room.get("require_all_enemies_defeated")
	if typeof(require_all_enemies_value) == TYPE_BOOL and require_all_enemies_value:
		return true
	for node: Node in nodes:
		var node_name := str(node.name)
		if node.has_method("receive_attack") or node.has_signal("defeated") or node.has_signal("hit_registered"):
			return true
		if ["SealNode", "AirDashShrine", "SealReleaseNode", "BacktrackConfirmationNode", "CorruptionPurgeNode"].has(node_name):
			return true
		if node_name.begins_with("TalismanRelay"):
			return true
	return false


# 危险 Area 数量用于区分“正式 author”与“仅位置触发或视觉标记”。
func _hazard_area_count(hazard_nodes: Array) -> int:
	var count := 0
	for node: Node in hazard_nodes:
		if node is Area2D:
			count += 1
	return count


# 节点名检查。
func _has_node_named(nodes: Array, target_name: String) -> bool:
	for node: Node in nodes:
		if str(node.name) == target_name:
			return true
	return false


# 节点列表转为报告路径和位置。
func _nodes_to_reports(room: Node, nodes: Array) -> Array:
	var reports: Array = []
	for node: Node in nodes:
		var item := {
			"name": str(node.name),
			"type": node.get_class(),
			"path": str(room.get_path_to(node)),
		}
		if node is Node2D:
			item["position"] = _vector_to_array((node as Node2D).global_position)
		reports.append(item)
	return reports


# 统计节点类型数量，给人工复核快速判断灰盒 / 资产 / 碰撞比例。
func _count_node_types(nodes: Array) -> Dictionary:
	var counts := {}
	for node: Node in nodes:
		var type_name := node.get_class()
		counts[type_name] = int(counts.get(type_name, 0)) + 1
	return counts


# 截图采样，避免空白截图被误当成证据。
func _analyze_image(image: Image) -> Dictionary:
	if image == null or image.is_empty():
		return {"ok": false, "error": "empty_image"}
	var samples := 0
	var visible_samples := 0
	var buckets := {}
	for y in range(0, image.get_height(), SAMPLE_STEP):
		for x in range(0, image.get_width(), SAMPLE_STEP):
			var color := image.get_pixel(x, y)
			samples += 1
			if color.a > 0.05 and (color.r + color.g + color.b) > 0.08:
				visible_samples += 1
			var bucket := "%02d_%02d_%02d" % [
				int(clampf(color.r, 0.0, 1.0) * 15.0),
				int(clampf(color.g, 0.0, 1.0) * 15.0),
				int(clampf(color.b, 0.0, 1.0) * 15.0),
			]
			buckets[bucket] = true
	return {
		"ok": visible_samples > 0 and buckets.size() > 1,
		"samples": samples,
		"visible_samples": visible_samples,
		"visible_ratio": float(visible_samples) / float(maxi(samples, 1)),
		"varied_color_buckets": buckets.size(),
	}


# 聚合房间报告和问题计数。
func _build_report(room_reports: Array) -> Dictionary:
	var issues: Array = []
	var issue_counts := {"P0": 0, "P1": 0, "P2": 0}
	var stage_counts := {}
	var tilemap_room_count := 0
	var visual_room_count := 0
	for room_report: Dictionary in room_reports:
		var stage := str(room_report.get("stage", "Unknown"))
		stage_counts[stage] = int(stage_counts.get(stage, 0)) + 1
		if not room_report.get("tilemaps", []).is_empty():
			tilemap_room_count += 1
		if not room_report.get("visual_assets", []).is_empty():
			visual_room_count += 1
		for issue: Dictionary in room_report.get("issues", []):
			var severity := str(issue.get("severity", "P2"))
			issue_counts[severity] = int(issue_counts.get(severity, 0)) + 1
			var issue_copy := issue.duplicate(true)
			issue_copy["room_id"] = room_report.get("id", "")
			issue_copy["room_path"] = room_report.get("path", "")
			issues.append(issue_copy)

	return {
		"review_id": "ll00_level_layout_map_audit",
		"generated_at": Time.get_datetime_string_from_system(),
		"room_count": room_reports.size(),
		"stage_counts": stage_counts,
		"tilemap_room_count": tilemap_room_count,
		"visual_room_count": visual_room_count,
		"issue_counts": issue_counts,
		"issues": issues,
		"rooms": room_reports,
		"evidence_dir": OUT_DIR,
		"boundary": "LL-00 audit only. P0/P1/P2 findings feed LL-01 to LL-06; screenshots are evidence, not final art approval.",
	}


# 构建人读版 Markdown 报告，方便后续计划引用。
func _build_markdown_report(report: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("# LL-00 Level Layout Audit Report")
	lines.append("")
	lines.append("- 生成时间：%s" % str(report.get("generated_at", "")))
	lines.append("- 房间数量：%s" % int(report.get("room_count", 0)))
	lines.append("- P0 / P1 / P2：%s / %s / %s" % [
		report.issue_counts.P0,
		report.issue_counts.P1,
		report.issue_counts.P2,
	])
	lines.append("- 证据目录：`%s`" % OUT_DIR)
	lines.append("")
	lines.append("## 问题表")
	lines.append("")
	lines.append("| Severity | Room | Code | Note |")
	lines.append("| --- | --- | --- | --- |")
	for issue: Dictionary in report.get("issues", []):
		lines.append("| %s | `%s` | `%s` | %s |" % [
			str(issue.get("severity", "")),
			str(issue.get("room_id", "")),
			str(issue.get("code", "")),
			str(issue.get("note", "")).replace("|", "/"),
		])
	if report.get("issues", []).is_empty():
		lines.append("| - | - | - | 未发现自动审计问题，仍需人工视觉复核。 |")

	lines.append("")
	lines.append("## 房间概览")
	lines.append("")
	lines.append("| Room | Stage | Exits | Gates | Hazards | TileMaps | Visuals | Screenshot |")
	lines.append("| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |")
	for room_report: Dictionary in report.get("rooms", []):
		lines.append("| `%s` | %s | %s | %s | %s | %s | %s | `%s` |" % [
			str(room_report.get("id", "")),
			str(room_report.get("stage", "")),
			room_report.get("exit_nodes", []).size(),
			room_report.get("gate_nodes", []).size(),
			room_report.get("hazard_nodes", []).size(),
			room_report.get("tilemaps", []).size(),
			room_report.get("visual_assets", []).size(),
			str(room_report.get("screenshot", "")),
		])

	lines.append("")
	lines.append("## 后续分流")
	lines.append("")
	lines.append("- P0 进入 LL-01：只修通关阻塞和主链路契约。")
	lines.append("- P1 进入 LL-02 / LL-04：地图语义、camera、hazard author 和碰撞读值。")
	lines.append("- P2 进入 LL-03 / LL-05：TileSet 样板、美术替换、image_gen 或外部资产评估。")
	lines.append("")
	return "\n".join(lines)


# 创建统一问题项。
func _make_issue(severity: String, code: String, note: String) -> Dictionary:
	return {"severity": severity, "code": code, "note": note}


# 写文本文件，目录已在入口创建。
func _write_text(path: String, content: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write file: %s" % path)
		return false
	file.store_string(content)
	return true


# Vector2 转 JSON 友好数组。
func _vector_to_array(value: Vector2) -> Array:
	return [value.x, value.y]


# Rect2 转 JSON 友好数组。
func _rect_to_array(value: Rect2) -> Array:
	return [value.position.x, value.position.y, value.size.x, value.size.y]
