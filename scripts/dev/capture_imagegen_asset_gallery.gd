extends SceneTree

# 渲染 image gen 资产 Gallery，并输出本地截图与非空画面分析报告。
# 截图属于一次性验证证据，默认写入 tests/artifacts/local/，不进入普通提交。

const SCENE_PATH := "res://scenes/dev/imagegen_asset_gallery.tscn"
const OUT_DIR := "res://tests/artifacts/local/imagegen_asset_gallery"
const OUT_IMAGE := "%s/gallery_viewport.png" % OUT_DIR
const OUT_REPORT := "%s/gallery_viewport_report.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(1600, 1000)
const SAMPLE_STEP := 8
const MIN_NON_TRANSPARENT_RATIO := 0.20
const MIN_VARIED_COLOR_BUCKETS := 32


func _init() -> void:
	_run.call_deferred()


# 主入口：实例化 Gallery，等待渲染后保存截图并写出采样报告。
func _run() -> void:
	var result := await _capture()
	quit(result)


# 执行截图和报告输出。
func _capture() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	root.size = VIEWPORT_SIZE

	var scene := ResourceLoader.load(SCENE_PATH)
	if scene == null or not scene is PackedScene:
		push_error("Cannot load Gallery scene: %s" % SCENE_PATH)
		return 1

	var instance := (scene as PackedScene).instantiate()
	if instance == null:
		push_error("Cannot instantiate Gallery scene: %s" % SCENE_PATH)
		return 1
	if instance is Control:
		var control := instance as Control
		control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(instance)

	await process_frame
	await process_frame
	await process_frame

	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Captured image is empty.")
		instance.free()
		return 1
	var save_error := image.save_png(OUT_IMAGE)
	if save_error != OK:
		push_error("Failed to save Gallery screenshot: %s" % save_error)
		instance.free()
		return 1

	var report := _analyze_image(image)
	report["scene"] = SCENE_PATH
	report["image"] = OUT_IMAGE
	report["viewport_size"] = [VIEWPORT_SIZE.x, VIEWPORT_SIZE.y]
	report["sample_step"] = SAMPLE_STEP
	report["status"] = "render_smoke_pass"
	report["boundary"] = "Nonblank viewport smoke only; does not prove final art polish or runtime integration."
	if not bool(report["ok"]):
		_write_json(OUT_REPORT, report)
		push_error("Gallery screenshot analysis failed: %s" % report)
		instance.free()
		return 1

	if not _write_json(OUT_REPORT, report):
		instance.free()
		return 1

	print("Imagegen asset gallery capture OK: %s" % OUT_IMAGE)
	print("Imagegen asset gallery capture report: %s" % OUT_REPORT)
	instance.free()
	return 0


# 采样截图像素，确认画面有可见内容、颜色变化和足够的非透明区域。
func _analyze_image(image: Image) -> Dictionary:
	var width := image.get_width()
	var height := image.get_height()
	var samples := 0
	var non_transparent := 0
	var color_buckets := {}
	var luma_sum := 0.0
	var luma_min := 1.0
	var luma_max := 0.0

	for y in range(0, height, SAMPLE_STEP):
		for x in range(0, width, SAMPLE_STEP):
			var color := image.get_pixel(x, y)
			samples += 1
			if color.a > 0.05:
				non_transparent += 1
			var bucket := "%02d_%02d_%02d" % [
				int(clampf(color.r, 0.0, 1.0) * 15.0),
				int(clampf(color.g, 0.0, 1.0) * 15.0),
				int(clampf(color.b, 0.0, 1.0) * 15.0),
			]
			color_buckets[bucket] = true
			var luma := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			luma_sum += luma
			luma_min = minf(luma_min, luma)
			luma_max = maxf(luma_max, luma)

	var non_transparent_ratio := 0.0
	var average_luma := 0.0
	if samples > 0:
		non_transparent_ratio = float(non_transparent) / float(samples)
		average_luma = luma_sum / float(samples)
	var varied_color_buckets := color_buckets.size()
	var ok := (
		samples > 0
		and non_transparent_ratio >= MIN_NON_TRANSPARENT_RATIO
		and varied_color_buckets >= MIN_VARIED_COLOR_BUCKETS
		and luma_max > luma_min
	)
	return {
		"ok": ok,
		"samples": samples,
		"non_transparent_samples": non_transparent,
		"non_transparent_ratio": non_transparent_ratio,
		"varied_color_buckets": varied_color_buckets,
		"average_luma": average_luma,
		"luma_min": luma_min,
		"luma_max": luma_max,
		"requirements": {
			"min_non_transparent_ratio": MIN_NON_TRANSPARENT_RATIO,
			"min_varied_color_buckets": MIN_VARIED_COLOR_BUCKETS,
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
