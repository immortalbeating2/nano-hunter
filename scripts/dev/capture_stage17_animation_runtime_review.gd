extends SceneTree

# Stage17 动作运行态统一复核脚本。
# 它只实例化生产玩家、普通敌人和 Boss 场景，记录时间序列并把截图写入本地忽略目录。

const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const BOSS_SCENE_PATH := "res://scenes/enemies/seal_guardian_boss.tscn"
const OUT_DIR := "res://tests/artifacts/local/stage17-animation-runtime"
const OUT_REPORT := "%s/runtime_report.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(960, 540)
const CANVAS_SIZE := Vector2(2560.0, 1440.0)
const EXPECTED_ATTACK_FRAMES := [4, 6, 7, 8, 10, 12]
const EXPECTED_DASH_FRAMES := [0, 2, 4, 6, 7, 8]
const EXPECTED_JUMP_PHASES := ["jump_start", "rise_hold", "fall_hold", "land"]
const ENEMY_CASES := [
	{
		"id": "basic_melee",
		"scene": "res://scenes/combat/basic_melee_enemy.tscn",
		"cycle": "basic_melee_cycle",
		"defeat": "basic_melee_defeat",
	},
	{
		"id": "ground_charger",
		"scene": "res://scenes/combat/ground_charger_enemy.tscn",
		"cycle": "ground_charger_cycle",
		"defeat": "ground_charger_defeat",
	},
	{
		"id": "aerial_sentinel",
		"scene": "res://scenes/combat/aerial_sentinel_enemy.tscn",
		"cycle": "aerial_sentinel_cycle",
		"defeat": "aerial_sentinel_defeat",
	},
	{
		"id": "miasma_caster",
		"scene": "res://scenes/combat/miasma_caster_enemy.tscn",
		"cycle": "miasma_caster_cycle",
		"defeat": "miasma_caster_defeat",
	},
]


func _init() -> void:
	_run.call_deferred()


# 主入口依次复核 Luna、普通敌人和 Boss；任一自检失败都以非零码退出。
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	root.size = VIEWPORT_SIZE
	_add_background()

	var luna_report := await _probe_luna()
	var enemy_report := await _probe_enemies()
	var boss_report := await _probe_boss()
	var checks := {
		"luna_attack_keyframes": bool(luna_report.get("attack_ok", false)),
		"luna_dash_keyframes": bool(luna_report.get("dash_ok", false)),
		"luna_jump_phase_order": bool(luna_report.get("jump_ok", false)),
		"luna_hit_react_visible": bool(luna_report.get("hit_ok", false)),
		"regular_enemy_cycles_advance": bool(enemy_report.get("cycles_ok", false)),
		"regular_enemy_defeats_visible": bool(enemy_report.get("defeats_ok", false)),
		"ground_charger_state_order": bool(enemy_report.get("charger_ok", false)),
		"boss_recovery_visible": bool(boss_report.get("recovery_ok", false)),
		"boss_stagger_visible": bool(boss_report.get("stagger_ok", false)),
		"boss_body_vfx_reach_late_frames": bool(boss_report.get("late_frames_ok", false)),
		"boss_damage_once": bool(boss_report.get("damage_once_ok", false)),
	}
	var ok := _all_checks_pass(checks)
	var report := {
		"ok": ok,
		"review_id": "stage17_animation_runtime",
		"viewport_size": [VIEWPORT_SIZE.x, VIEWPORT_SIZE.y],
		"checks": checks,
		"luna": luna_report,
		"regular_enemies": enemy_report,
		"boss": boss_report,
		"boundary": "Runtime presentation and state timing probe only; gameplay tests remain authoritative for collision, damage, room gates and completion flow.",
	}
	if not _write_json(OUT_REPORT, report):
		quit(1)
		return

	print("Stage17 animation runtime review: ok=%s" % ok)
	print("Stage17 animation runtime report: %s" % OUT_REPORT)
	quit(0 if ok else 1)


# 深色背景让透明角色与 VFX 在截图中保持可读。
func _add_background() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -10
	root.add_child(layer)
	var background := ColorRect.new()
	background.color = Color(0.035, 0.055, 0.07, 1.0)
	background.size = CANVAS_SIZE
	layer.add_child(background)


# Luna 复核覆盖攻击、Dash、Jump 四相和受击视觉窗口。
func _probe_luna() -> Dictionary:
	var world := _new_world(3.2)
	_add_floor(world, 900.0)
	var player := await _spawn_player(world, Vector2(1280.0, 820.0))
	if player == null:
		world.free()
		return {"ok": false, "error": "player_spawn_failed"}

	var visual := player.get_node_or_null("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var attack_samples: Array[Dictionary] = []
	var attack_frames: Dictionary = {}
	var attack_image := "%s/luna_attack.png" % OUT_DIR
	var attack_image_saved := false
	player.call("_start_attack")
	for frame_index in range(30):
		await physics_frame
		var sample := _sample_visual(player, visual, float(frame_index) / 60.0)
		attack_samples.append(sample)
		attack_frames[int(sample.get("frame", -1))] = true
		if not attack_image_saved and int(sample.get("frame", -1)) in [6, 7]:
			attack_image_saved = await _save_screenshot(attack_image)
		if frame_index > 0 and String(sample.get("state", "")) != "attack":
			break

	await _settle_player(player, 30)
	var dash_samples: Array[Dictionary] = []
	var dash_frames: Dictionary = {}
	player.call("_start_dash")
	for frame_index in range(30):
		await physics_frame
		var sample := _sample_visual(player, visual, float(frame_index) / 60.0)
		dash_samples.append(sample)
		dash_frames[int(sample.get("frame", -1))] = true
		if frame_index > 0 and String(sample.get("state", "")) != "dash":
			break

	await _settle_player(player, 60)
	var jump_samples: Array[Dictionary] = []
	var jump_phases: Array[String] = []
	var jump_image := "%s/luna_jump_fall.png" % OUT_DIR
	var jump_image_saved := false
	player.call("_start_jump")
	for frame_index in range(150):
		await physics_frame
		var sample := _sample_visual(player, visual, float(frame_index) / 60.0)
		jump_samples.append(sample)
		var animation_name := String(sample.get("animation", ""))
		if animation_name in EXPECTED_JUMP_PHASES and (jump_phases.is_empty() or jump_phases[-1] != animation_name):
			jump_phases.append(animation_name)
		if not jump_image_saved and animation_name == "fall_hold":
			jump_image_saved = await _save_screenshot(jump_image)
		if jump_phases.has("land") and String(sample.get("state", "")) == "idle":
			break

	var hit_samples: Array[Dictionary] = []
	player.call("receive_damage", 1, Vector2.LEFT)
	for frame_index in range(18):
		await physics_frame
		hit_samples.append(_sample_visual(player, visual, float(frame_index) / 60.0))

	var attack_ok := attack_image_saved and _contains_all_frames(attack_frames, EXPECTED_ATTACK_FRAMES)
	var dash_ok := _contains_all_frames(dash_frames, EXPECTED_DASH_FRAMES)
	var jump_ok := jump_image_saved and _sequence_contains_in_order(jump_phases, EXPECTED_JUMP_PHASES)
	var hit_ok := false
	for sample in hit_samples:
		if String(sample.get("asset_id", "")) == "luna_hit_react_runtime_sheet_ai03" and bool(sample.get("visible", false)):
			hit_ok = true
			break

	world.free()
	return {
		"attack_ok": attack_ok,
		"dash_ok": dash_ok,
		"jump_ok": jump_ok,
		"hit_ok": hit_ok,
		"attack_distinct_frames": _sorted_int_keys(attack_frames),
		"dash_distinct_frames": _sorted_int_keys(dash_frames),
		"jump_phase_order": jump_phases,
		"screenshots": [attack_image, jump_image],
		"attack_samples": attack_samples,
		"dash_samples": dash_samples,
		"jump_samples": jump_samples,
		"hit_samples": hit_samples,
	}


# 普通敌人复核默认 cycle、四份 defeat 和 Ground Charger 的真实四段行为映射。
func _probe_enemies() -> Dictionary:
	var world := _new_world(2.8)
	var spawned: Array[Dictionary] = []
	var cycle_reports: Array[Dictionary] = []
	for index in range(ENEMY_CASES.size()):
		var enemy_case: Dictionary = ENEMY_CASES[index]
		var enemy := _instantiate_scene(String(enemy_case.get("scene", ""))) as Node2D
		if enemy == null:
			cycle_reports.append({"id": enemy_case.get("id"), "ok": false, "error": "spawn_failed"})
			continue
		enemy.position = Vector2(950.0 + index * 220.0, 900.0)
		world.add_child(enemy)
		await process_frame
		var visual := enemy.get_node_or_null("EnemyRuntimeAnimationVisual") as AnimatedSprite2D
		var samples: Array[Dictionary] = []
		var distinct_frames: Dictionary = {}
		for frame_index in range(36):
			await process_frame
			var sample := _sample_visual(enemy, visual, float(frame_index) / 120.0)
			samples.append(sample)
			distinct_frames[int(sample.get("frame", -1))] = true
		var cycle_ok := (
			visual != null
			and visual.is_playing()
			and String(visual.animation) == String(enemy_case.get("cycle", ""))
			and distinct_frames.size() >= 2
		)
		cycle_reports.append({
			"id": enemy_case.get("id"),
			"ok": cycle_ok,
			"distinct_frames": _sorted_int_keys(distinct_frames),
			"samples": samples,
		})
		spawned.append({"case": enemy_case, "enemy": enemy, "visual": visual})

	var charger_samples: Array[Dictionary] = []
	var charger_order: Array[String] = []
	for entry in spawned:
		var enemy_case: Dictionary = entry.get("case", {})
		if String(enemy_case.get("id", "")) != "ground_charger":
			continue
		var charger := entry.get("enemy") as Node2D
		var charger_visual := entry.get("visual") as AnimatedSprite2D
		var target := CharacterBody2D.new()
		target.global_position = charger.global_position + Vector2(32.0, 0.0)
		world.add_child(target)
		charger.call("bind_player", target)
		for frame_index in range(80):
			await physics_frame
			var sample := _sample_visual(charger, charger_visual, float(frame_index) / 60.0)
			charger_samples.append(sample)
			var animation_name := String(sample.get("animation", ""))
			if charger_order.is_empty() or charger_order[-1] != animation_name:
				charger_order.append(animation_name)
			if _sequence_contains_in_order(
				charger_order,
				["ground_charger_telegraph", "ground_charger_charge", "ground_charger_recover", "ground_charger_cycle"]
			):
				break
		break

	var defeat_reports: Array[Dictionary] = []
	for entry in spawned:
		var enemy_case: Dictionary = entry.get("case", {})
		var enemy := entry.get("enemy") as Node2D
		var visual := entry.get("visual") as AnimatedSprite2D
		enemy.call("receive_attack", Vector2.RIGHT, 120.0)
		await process_frame
		var sample := _sample_visual(enemy, visual, 0.0)
		var defeat_ok: bool = (
			bool(enemy.call("is_defeated"))
			and bool(sample.get("visible", false))
			and String(sample.get("animation", "")) == String(enemy_case.get("defeat", ""))
		)
		defeat_reports.append({"id": enemy_case.get("id"), "ok": defeat_ok, "sample": sample})

	for _i in range(70):
		await process_frame
	var enemy_image := "%s/regular_enemy_defeats.png" % OUT_DIR
	var enemy_image_saved := await _save_screenshot(enemy_image)
	var cycles_ok := enemy_image_saved and _all_report_rows_pass(cycle_reports)
	var defeats_ok := _all_report_rows_pass(defeat_reports)
	var charger_ok := _sequence_contains_in_order(
		charger_order,
		["ground_charger_telegraph", "ground_charger_charge", "ground_charger_recover", "ground_charger_cycle"]
	)

	world.free()
	return {
		"cycles_ok": cycles_ok,
		"defeats_ok": defeats_ok,
		"charger_ok": charger_ok,
		"charger_state_order": charger_order,
		"charger_samples": charger_samples,
		"cycle_reports": cycle_reports,
		"defeat_reports": defeat_reports,
		"screenshots": [enemy_image],
	}


# Boss 复核正常 strike/recovery、guard-break staggered、VFX 后半帧和单次伤害。
func _probe_boss() -> Dictionary:
	var world := _new_world(2.8)
	_add_floor(world, 900.0)
	var player := await _spawn_player(world, Vector2(1260.0, 820.0))
	var boss := _instantiate_scene(BOSS_SCENE_PATH) as Node2D
	if player == null or boss == null:
		world.free()
		return {"ok": false, "error": "boss_fixture_failed"}
	boss.position = Vector2(1320.0, 884.0)
	world.add_child(boss)
	await process_frame
	boss.call("bind_player", player)

	var body := boss.get_node_or_null("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var vfx := boss.get_node_or_null("SealGuardianAttackVfxVisual") as AnimatedSprite2D
	var attack_samples: Array[Dictionary] = []
	var recovery_seen := false
	var recovery_visible := false
	var max_body_frame := -1
	var max_vfx_frame := -1
	var recovery_image := "%s/boss_recovery.png" % OUT_DIR
	var recovery_image_saved := false
	var starting_health := int(player.call("get_current_health"))
	for frame_index in range(120):
		await physics_frame
		var sample := _sample_visual(boss, body, float(frame_index) / 60.0)
		sample["vfx"] = _sample_visual(boss, vfx, float(frame_index) / 60.0)
		attack_samples.append(sample)
		var state := String(sample.get("state", ""))
		if state in ["ground_impact", "air_punish", "recovery"]:
			max_body_frame = maxi(max_body_frame, int(sample.get("frame", -1)))
		var vfx_sample: Dictionary = sample.get("vfx", {})
		if bool(vfx_sample.get("visible", false)):
			max_vfx_frame = maxi(max_vfx_frame, int(vfx_sample.get("frame", -1)))
		if state == "recovery":
			recovery_seen = true
			recovery_visible = recovery_visible or bool(sample.get("visible", false))
			if not recovery_image_saved and int(sample.get("frame", -1)) >= 5:
				recovery_image_saved = await _save_screenshot(recovery_image)
		if recovery_seen and state == "idle":
			break

	for _i in range(int(boss.call("get_max_guard"))):
		boss.call("receive_attack", Vector2.RIGHT, 120.0)
	var stagger_samples: Array[Dictionary] = []
	var stagger_visible := false
	var stagger_asset_ok := false
	var stagger_image := "%s/boss_staggered.png" % OUT_DIR
	var stagger_image_saved := false
	for frame_index in range(24):
		await physics_frame
		var sample := _sample_visual(boss, body, float(frame_index) / 60.0)
		stagger_samples.append(sample)
		if String(sample.get("state", "")) == "staggered":
			stagger_visible = stagger_visible or bool(sample.get("visible", false))
			stagger_asset_ok = stagger_asset_ok or String(sample.get("asset_id", "")) == "seal_guardian_stagger_runtime_sheet_ai01"
			if not stagger_image_saved and int(sample.get("frame", -1)) >= 1:
				stagger_image_saved = await _save_screenshot(stagger_image)

	var ending_health := int(player.call("get_current_health"))
	var recovery_ok := recovery_seen and recovery_visible and recovery_image_saved
	var stagger_ok := stagger_visible and stagger_asset_ok and stagger_image_saved
	var late_frames_ok := max_body_frame >= 4 and max_vfx_frame >= 4
	var damage_once_ok := ending_health == starting_health - 1

	world.free()
	return {
		"recovery_ok": recovery_ok,
		"stagger_ok": stagger_ok,
		"late_frames_ok": late_frames_ok,
		"damage_once_ok": damage_once_ok,
		"starting_player_health": starting_health,
		"ending_player_health": ending_health,
		"max_body_frame": max_body_frame,
		"max_vfx_frame": max_vfx_frame,
		"screenshots": [recovery_image, stagger_image],
		"attack_samples": attack_samples,
		"stagger_samples": stagger_samples,
	}


# 创建不带测试替身的运行世界；复核相机只负责把生产角色放大到可人工检查的尺寸。
func _new_world(camera_zoom: float) -> Node2D:
	var world := Node2D.new()
	root.add_child(world)
	var camera := Camera2D.new()
	camera.name = "ReviewCamera"
	camera.position = CANVAS_SIZE / 2.0
	camera.zoom = Vector2(camera_zoom, camera_zoom)
	camera.enabled = true
	world.add_child(camera)
	return world


# 地板只为生产玩家提供真实 CharacterBody2D 落地条件。
func _add_floor(world: Node2D, y_position: float) -> void:
	var floor := StaticBody2D.new()
	floor.position = Vector2(CANVAS_SIZE.x / 2.0, y_position)
	world.add_child(floor)
	var floor_visual := Polygon2D.new()
	floor_visual.color = Color(0.14, 0.20, 0.22, 1.0)
	floor_visual.polygon = PackedVector2Array([
		Vector2(-CANVAS_SIZE.x / 2.0, -16.0),
		Vector2(CANVAS_SIZE.x / 2.0, -16.0),
		Vector2(CANVAS_SIZE.x / 2.0, 16.0),
		Vector2(-CANVAS_SIZE.x / 2.0, 16.0),
	])
	floor.add_child(floor_visual)
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(CANVAS_SIZE.x, 32.0)
	shape_node.shape = shape
	floor.add_child(shape_node)


# 实例化生产玩家并关闭其跟随相机，避免复核画布被单个角色重定位。
func _spawn_player(world: Node2D, spawn_position: Vector2) -> CharacterBody2D:
	var player := _instantiate_scene(PLAYER_SCENE_PATH) as CharacterBody2D
	if player == null:
		return null
	player.position = spawn_position
	world.add_child(player)
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.enabled = false
	var review_camera := world.get_node_or_null("ReviewCamera") as Camera2D
	if review_camera != null:
		review_camera.enabled = true
	if not await _settle_player(player, 90):
		return null
	return player


# 等待玩家真实落地，避免动作从出生下落状态起手。
func _settle_player(player: CharacterBody2D, max_frames: int) -> bool:
	for _i in range(max_frames):
		if player.is_on_floor() and absf(player.velocity.y) <= 0.1:
			await physics_frame
			return true
		await physics_frame
	return false


# 统一加载生产 PackedScene；失败时保留明确错误供报告定位。
func _instantiate_scene(scene_path: String) -> Node:
	var packed_scene := ResourceLoader.load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("Cannot load Stage17 runtime review scene: %s" % scene_path)
		return null
	return packed_scene.instantiate()


# 记录计划要求的 state / animation / frame / is_playing / visible 和资产标识。
func _sample_visual(owner: Node, visual: AnimatedSprite2D, elapsed: float) -> Dictionary:
	var state := ""
	if owner != null and owner.has_method("get_boss_state"):
		state = String(owner.call("get_boss_state"))
	elif owner != null and owner.has_method("get_current_state_id"):
		state = String(owner.call("get_current_state_id"))
	elif visual != null:
		state = String(visual.animation)
	if visual == null:
		return {
			"time": elapsed,
			"state": state,
			"animation": "",
			"frame": -1,
			"is_playing": false,
			"visible": false,
			"asset_id": "",
		}
	return {
		"time": elapsed,
		"state": state,
		"animation": String(visual.animation),
		"frame": visual.frame,
		"is_playing": visual.is_playing(),
		"visible": visual.visible,
		"asset_id": String(visual.get_meta("asset_id", "")),
	}


# 截图等待渲染完成后再读取 viewport，防止保存上一帧或空图。
func _save_screenshot(path: String) -> bool:
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		return false
	return image.save_png(path) == OK


# 预期关键帧必须全部出现，多余中间帧不影响契约。
func _contains_all_frames(observed: Dictionary, expected: Array) -> bool:
	for frame in expected:
		if not observed.has(int(frame)):
			return false
	return true


# 验证状态序列按顺序出现，允许中间重复帧或其它非关键状态。
func _sequence_contains_in_order(observed: Array, expected: Array) -> bool:
	var expected_index := 0
	for value in observed:
		if expected_index < expected.size() and String(value) == String(expected[expected_index]):
			expected_index += 1
	return expected_index == expected.size()


# JSON 报告使用排序后的帧号，便于人工 diff 和后续 session 对比。
func _sorted_int_keys(values: Dictionary) -> Array[int]:
	var result: Array[int] = []
	for value in values.keys():
		result.append(int(value))
	result.sort()
	return result


# 汇总布尔检查，任何一项失败都阻止探针以成功码退出。
func _all_checks_pass(checks: Dictionary) -> bool:
	for value in checks.values():
		if not bool(value):
			return false
	return true


# 普通敌人各行都必须通过，缺失实例也会作为失败行保留在报告中。
func _all_report_rows_pass(rows: Array[Dictionary]) -> bool:
	if rows.size() != ENEMY_CASES.size():
		return false
	for row in rows:
		if not bool(row.get("ok", false)):
			return false
	return true


# 把完整时间序列写入 ignored 本地证据目录。
func _write_json(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write Stage17 runtime review JSON: %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
	return true
