extends SceneTree

# 捕获普通敌人正式替换批次的受击 VFX 复核截图。
# 输出默认进入 tests/artifacts/local/，作为本地证据，不进入普通提交。

const ENEMY_SCENE_PATH := "res://scenes/combat/basic_melee_enemy.tscn"
const OUT_DIR := "res://tests/artifacts/local/animation-runtime-replacement/arp_19_enemy_hit_spark_vfx_runtime"
const OUT_IMAGE := "%s/enemy_hit_spark_vfx_runtime.png" % OUT_DIR
const OUT_REPORT := "%s/enemy_hit_spark_vfx_runtime_report.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(960, 540)
const TARGET_ASSET_ID := "enemy_hit_spark_vfx_runtime_ai01"
const TARGET_SPRITEFRAMES := "res://assets/art/vfx/atlases/enemy_hit_spark_vfx_runtime_ai01.spriteframes.tres"
const TARGET_ANIMATION := &"enemy_hit_spark"
const SAMPLE_STEP := 6
const MIN_VISIBLE_PIXEL_RATIO := 0.01


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var result := await _capture_enemy_hit_spark_vfx()
	quit(result)


func _capture_enemy_hit_spark_vfx() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	root.size = VIEWPORT_SIZE

	var packed_scene := ResourceLoader.load(ENEMY_SCENE_PATH) as PackedScene
	if packed_scene == null:
		push_error("Cannot load enemy scene: %s" % ENEMY_SCENE_PATH)
		return 1

	var world := Node2D.new()
	root.add_child(world)

	var enemy := packed_scene.instantiate() as Node2D
	if enemy == null:
		push_error("Cannot instantiate enemy scene: %s" % ENEMY_SCENE_PATH)
		world.free()
		return 1
	enemy.position = Vector2(480, 320)
	world.add_child(enemy)

	await process_frame
	enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await process_frame
	await process_frame

	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Captured image is empty.")
		world.free()
		return 1

	var save_error := image.save_png(OUT_IMAGE)
	if save_error != OK:
		push_error("Failed to save enemy hit spark screenshot: %s" % save_error)
		world.free()
		return 1

	var report := _build_report(image, enemy)
	if not _write_json(OUT_REPORT, report):
		world.free()
		return 1

	if not bool(report.get("ok", false)):
		push_error("Enemy hit spark runtime review failed: %s" % report)
		world.free()
		return 1

	print("Enemy hit spark runtime review capture OK: %s" % OUT_IMAGE)
	print("Enemy hit spark runtime review report: %s" % OUT_REPORT)
	world.free()
	return 0


func _build_report(image: Image, enemy: Node2D) -> Dictionary:
	var visual := enemy.get_node_or_null("EnemyHitSparkVfxVisual") as AnimatedSprite2D
	var image_stats := _analyze_image(image)
	var report := _inspect_visual(visual)
	var ok := (
		bool(report.get("visible", false))
		and bool(report.get("resource_ok", false))
		and bool(report.get("metadata_ok", false))
		and bool(image_stats.get("ok", false))
	)

	return {
		"ok": ok,
		"review_id": "arp_19_enemy_hit_spark_vfx_runtime",
		"scene": ENEMY_SCENE_PATH,
		"image": OUT_IMAGE,
		"viewport_size": [VIEWPORT_SIZE.x, VIEWPORT_SIZE.y],
		"visual": report,
		"image_stats": image_stats,
		"manual_review_guidance": "Open the screenshot and confirm the hit spark is visible behind or beside the enemy and does not read as gameplay collision.",
		"boundary": "Runtime screenshot and metadata review only; enemy defeat and hurtbox disable remain authored by gameplay code.",
	}


func _inspect_visual(visual: AnimatedSprite2D) -> Dictionary:
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


func _write_json(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write JSON file: %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
	return true
