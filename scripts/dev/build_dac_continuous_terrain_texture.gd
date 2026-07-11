extends SceneTree

# 生成一张可重复铺设的连续地面 underlay。
# ponytail: 先用单张连续材质清掉散片感；正式 tile kit 通过 image_gen 后再替换。

const OUTPUT_TEXTURE_PATH := "res://assets/art/textures/dac_continuous_stone_underlay.png"
const OUTPUT_SIZE := Vector2i(256, 128)


func _init() -> void:
	var output := Image.create(OUTPUT_SIZE.x, OUTPUT_SIZE.y, false, Image.FORMAT_RGBA8)
	_fill_continuous_stone_base(output)

	var save_result := output.save_png(OUTPUT_TEXTURE_PATH)
	if save_result != OK:
		push_error("Failed to save terrain texture %s: %s" % [OUTPUT_TEXTURE_PATH, save_result])
		quit(1)
		return

	print("DAC continuous terrain texture saved: %s" % OUTPUT_TEXTURE_PATH)
	quit(0)


func _fill_continuous_stone_base(output: Image) -> void:
	for y in range(OUTPUT_SIZE.y):
		for x in range(OUTPUT_SIZE.x):
			var grain := float((x * 19 + y * 31 + (x / 7) * 11 + (y / 5) * 13) % 37) / 420.0
			var cyan := float((x * 7 + y * 3) % 41) / 900.0
			output.set_pixel(x, y, Color(0.22 + grain, 0.255 + grain + cyan, 0.245 + grain + cyan * 2.0, 1.0))
	for y in range(18, OUTPUT_SIZE.y, 30):
		_draw_crack(output, Vector2i(0, y), Vector2i(OUTPUT_SIZE.x - 1, y + 2), Color(0.10, 0.12, 0.115, 1.0))
	for x in range(28, OUTPUT_SIZE.x, 46):
		_draw_crack(output, Vector2i(x, 0), Vector2i(x + 3, OUTPUT_SIZE.y - 1), Color(0.11, 0.13, 0.125, 1.0))
	for i in range(32):
		var x := (i * 47) % OUTPUT_SIZE.x
		var y := (i * 29) % OUTPUT_SIZE.y
		output.set_pixel(x, y, Color(0.16, 0.34, 0.32, 1.0))


func _draw_crack(output: Image, from: Vector2i, to: Vector2i, color: Color) -> void:
	var steps := maxi(abs(to.x - from.x), abs(to.y - from.y))
	for i in range(steps + 1):
		var t := float(i) / float(maxi(1, steps))
		var x := int(round(lerpf(from.x, to.x, t)))
		var y := int(round(lerpf(from.y, to.y, t)))
		if x >= 0 and y >= 0 and x < OUTPUT_SIZE.x and y < OUTPUT_SIZE.y:
			output.set_pixel(x, y, color)
