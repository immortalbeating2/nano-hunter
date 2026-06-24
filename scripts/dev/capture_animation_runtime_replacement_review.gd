extends SceneTree

# 捕获动作正式替换批次的运行态复核截图。
# 输出默认进入 tests/artifacts/local/，作为本地证据，不进入普通提交。

const BOSS_SCENE_PATH := "res://scenes/enemies/seal_guardian_boss.tscn"
const OUT_DIR := "res://tests/artifacts/local/animation-runtime-replacement/arp_15_seal_guardian_attack_vfx"
const OUT_IMAGE := "%s/seal_guardian_attack_vfx_runtime.png" % OUT_DIR
const OUT_REPORT := "%s/seal_guardian_attack_vfx_runtime_report.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(960, 540)
const TARGET_STATE := &"ground_impact"
const TARGET_ASSET_ID := "seal_guardian_attack_vfx_atlas_ai01"
const TARGET_SPRITEFRAMES := "res://assets/art/vfx/atlases/seal_guardian_attack_vfx_atlas_ai01.spriteframes.tres"
const TARGET_ANIMATION := &"boss_attack_vfx"
const SAMPLE_STEP := 6
const MIN_VISIBLE_PIXEL_RATIO := 0.01


func _init() -> void:
	_run.call_deferred()


# 主入口：构造运行态 Boss 攻击状态，保存截图和结构化报告。
func _run() -> void:
	var result := await _capture_boss_attack_vfx()
	quit(result)


# 实例化 Boss 并推进到攻击状态。
func _capture_boss_attack_vfx() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	root.size = VIEWPORT_SIZE

	var packed_scene := ResourceLoader.load(BOSS_SCENE_PATH) as PackedScene
	if packed_scene == null:
		push_error("Cannot load Boss scene: %s" % BOSS_SCENE_PATH)
		return 1

	var world := Node2D.new()
	root.add_child(world)

	var boss := packed_scene.instantiate() as Node2D
	if boss == null:
		push_error("Cannot instantiate Boss scene: %s" % BOSS_SCENE_PATH)
		world.free()
		return 1
	boss.position = Vector2(480, 340)
	world.add_child(boss)

	var dummy_player := Node2D.new()
	dummy_player.name = "RuntimeReviewDummyPlayer"
	dummy_player.global_position = boss.global_position
	world.add_child(dummy_player)
	if boss.has_method("bind_player"):
		boss.call("bind_player", dummy_player)

	var reached_attack := await _advance_until_attack(boss, 72)
	await process_frame
	await process_frame

	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Captured image is empty.")
		world.free()
		return 1

	var save_error := image.save_png(OUT_IMAGE)
	if save_error != OK:
		push_error("Failed to save runtime review screenshot: %s" % save_error)
		world.free()
		return 1

	var report := _build_report(image, boss, reached_attack)
	if not _write_json(OUT_REPORT, report):
		world.free()
		return 1

	if not bool(report.get("ok", false)):
		push_error("Animation runtime review failed: %s" % report)
		world.free()
		return 1

	print("Animation runtime review capture OK: %s" % OUT_IMAGE)
	print("Animation runtime review report: %s" % OUT_REPORT)
	world.free()
	return 0


# 推进物理帧直到 Boss 进入攻击状态。
func _advance_until_attack(boss: Node, max_frames: int) -> bool:
	for _i in range(max_frames):
		await physics_frame
		var state := StringName(boss.call("get_boss_state")) if boss.has_method("get_boss_state") else &""
		if state == TARGET_STATE or state == &"air_punish":
			return true
	return false


# 汇总截图采样、节点状态和 no-collision / no-damage 约束。
func _build_report(image: Image, boss: Node2D, reached_attack: bool) -> Dictionary:
	var runtime_visual := boss.get_node_or_null("SealGuardianRuntimeAnimationVisual") as AnimatedSprite2D
	var attack_vfx := boss.get_node_or_null("SealGuardianAttackVfxVisual") as AnimatedSprite2D
	var state := String(boss.call("get_boss_state")) if boss.has_method("get_boss_state") else ""
	var image_stats := _analyze_image(image)
	var attack_vfx_report := _inspect_attack_vfx(attack_vfx)
	var runtime_visual_report := _inspect_runtime_visual(runtime_visual)
	var has_collision_child := _has_collision_or_area_child(attack_vfx)
	var ok := (
		reached_attack
		and state in ["ground_impact", "air_punish"]
		and bool(attack_vfx_report.get("visible", false))
		and bool(runtime_visual_report.get("visible", false))
		and bool(attack_vfx_report.get("resource_ok", false))
		and bool(attack_vfx_report.get("metadata_ok", false))
		and not has_collision_child
		and bool(image_stats.get("ok", false))
	)

	return {
		"ok": ok,
		"review_id": "arp_15_seal_guardian_attack_vfx_runtime",
		"scene": BOSS_SCENE_PATH,
		"image": OUT_IMAGE,
		"viewport_size": [VIEWPORT_SIZE.x, VIEWPORT_SIZE.y],
		"boss_state": state,
		"reached_attack_state": reached_attack,
		"runtime_visual": runtime_visual_report,
		"attack_vfx_visual": attack_vfx_report,
		"attack_vfx_has_collision_or_area_child": has_collision_child,
		"image_stats": image_stats,
		"manual_review_guidance": "Open the screenshot and confirm VFX anchor, alpha, overlap with attack body, and readability.",
		"boundary": "Runtime screenshot and metadata review only; gameplay collision and damage remain authored by gameplay code / AttackArea, not by this VFX node.",
	}


# 检查 Boss body runtime visual 是否处于攻击身体层。
func _inspect_runtime_visual(visual: AnimatedSprite2D) -> Dictionary:
	if visual == null:
		return {"exists": false}
	var resource_path := visual.sprite_frames.resource_path if visual.sprite_frames != null else ""
	return {
		"exists": true,
		"visible": visual.visible,
		"asset_id": str(visual.get_meta("asset_id", "")),
		"resource_path": resource_path,
		"animation": String(visual.animation),
	}


# 检查 Boss attack VFX visual 的资源、动画和 metadata。
func _inspect_attack_vfx(visual: AnimatedSprite2D) -> Dictionary:
	if visual == null:
		return {"exists": false, "resource_ok": false, "metadata_ok": false}
	var resource_path := visual.sprite_frames.resource_path if visual.sprite_frames != null else ""
	var gameplay_collision := bool(visual.get_meta("gameplay_collision", true))
	var damage_source := bool(visual.get_meta("damage_source", true))
	var resource_ok := (
		str(visual.get_meta("asset_id", "")) == TARGET_ASSET_ID
		and resource_path == TARGET_SPRITEFRAMES
		and visual.animation == TARGET_ANIMATION
	)
	var metadata_ok := not gameplay_collision and not damage_source
	return {
		"exists": true,
		"visible": visual.visible,
		"asset_id": str(visual.get_meta("asset_id", "")),
		"resource_path": resource_path,
		"animation": String(visual.animation),
		"gameplay_collision": gameplay_collision,
		"damage_source": damage_source,
		"resource_ok": resource_ok,
		"metadata_ok": metadata_ok,
	}


# 防止 VFX 节点被误挂 Area2D、CollisionShape2D 或其它物理子节点。
func _has_collision_or_area_child(node: Node) -> bool:
	if node == null:
		return true
	for child in node.get_children():
		if child is Area2D or child is CollisionShape2D or child is CollisionPolygon2D:
			return true
		if _has_collision_or_area_child(child):
			return true
	return false


# 采样截图，避免空画面或纯色画面误判为完成。
func _analyze_image(image: Image) -> Dictionary:
	var width := image.get_width()
	var height := image.get_height()
	var samples := 0
	var visible_pixels := 0
	var varied_buckets := {}
	for y in range(0, height, SAMPLE_STEP):
		for x in range(0, width, SAMPLE_STEP):
			var color := image.get_pixel(x, y)
			samples += 1
			if color.a > 0.05 and (color.r + color.g + color.b) > 0.08:
				visible_pixels += 1
			var bucket := "%02d_%02d_%02d" % [
				int(clampf(color.r, 0.0, 1.0) * 15.0),
				int(clampf(color.g, 0.0, 1.0) * 15.0),
				int(clampf(color.b, 0.0, 1.0) * 15.0),
			]
			varied_buckets[bucket] = true

	var visible_ratio := 0.0
	if samples > 0:
		visible_ratio = float(visible_pixels) / float(samples)
	return {
		"ok": samples > 0 and visible_ratio >= MIN_VISIBLE_PIXEL_RATIO and varied_buckets.size() >= 8,
		"samples": samples,
		"visible_pixels": visible_pixels,
		"visible_ratio": visible_ratio,
		"varied_color_buckets": varied_buckets.size(),
		"requirements": {
			"min_visible_pixel_ratio": MIN_VISIBLE_PIXEL_RATIO,
			"min_varied_color_buckets": 8,
		},
	}


# 写出 JSON 报告。
func _write_json(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write JSON file: %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
	return true
