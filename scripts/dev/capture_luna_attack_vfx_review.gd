extends SceneTree

# 捕获 Luna 攻击正式替换批次的运行态 VFX 复核截图。
# 输出默认进入 tests/artifacts/local/，作为本地证据，不进入普通提交。

const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const OUT_DIR := "res://tests/artifacts/local/animation-runtime-replacement/arp_18_luna_attack_vfx_runtime"
const OUT_IMAGE := "%s/luna_attack_vfx_runtime.png" % OUT_DIR
const OUT_REPORT := "%s/luna_attack_vfx_runtime_report.json" % OUT_DIR
const VIEWPORT_SIZE := Vector2i(960, 540)
const TARGET_BODY_ASSET_ID := "luna_attack_body_runtime_sheet_ai02"
const TARGET_BODY_SPRITEFRAMES := "res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_attack_body_runtime_sheet_ai02.spriteframes.tres"
const TARGET_SLASH_ASSET_ID := "luna_attack_slash_vfx_runtime_ai01"
const TARGET_SLASH_SPRITEFRAMES := "res://assets/art/vfx/atlases/luna_attack_slash_vfx_runtime_ai01.spriteframes.tres"
const TARGET_SEAL_ARC_ASSET_ID := "luna_attack_seal_arc_vfx_runtime_ai01"
const TARGET_SEAL_ARC_SPRITEFRAMES := "res://assets/art/vfx/atlases/luna_attack_seal_arc_vfx_runtime_ai01.spriteframes.tres"
const SAMPLE_STEP := 6
const MIN_VISIBLE_PIXEL_RATIO := 0.01


func _init() -> void:
	_run.call_deferred()


# 主入口：构造玩家攻击状态，保存截图和结构化报告。
func _run() -> void:
	var result := await _capture_attack_vfx()
	quit(result)


# 实例化玩家、触发地面攻击，并截取运行态画面。
func _capture_attack_vfx() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	root.size = VIEWPORT_SIZE

	var packed_scene := ResourceLoader.load(PLAYER_SCENE_PATH) as PackedScene
	if packed_scene == null:
		push_error("Cannot load Player scene: %s" % PLAYER_SCENE_PATH)
		return 1

	var world := Node2D.new()
	root.add_child(world)

	var floor := StaticBody2D.new()
	floor.position = Vector2(480, 380)
	world.add_child(floor)
	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(1024, 32)
	floor_shape.shape = rectangle
	floor.add_child(floor_shape)

	var player := packed_scene.instantiate() as CharacterBody2D
	if player == null:
		push_error("Cannot instantiate Player scene: %s" % PLAYER_SCENE_PATH)
		world.free()
		return 1
	player.position = Vector2(480, 320)
	world.add_child(player)

	await _settle_player(player, 60)
	Input.action_press("attack")
	await physics_frame
	await physics_frame
	Input.action_release("attack")
	await process_frame
	await process_frame

	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Captured image is empty.")
		world.free()
		return 1

	var save_error := image.save_png(OUT_IMAGE)
	if save_error != OK:
		push_error("Failed to save Luna attack runtime screenshot: %s" % save_error)
		world.free()
		return 1

	var report := _build_report(image, player)
	if not _write_json(OUT_REPORT, report):
		world.free()
		return 1

	if not bool(report.get("ok", false)):
		push_error("Luna attack runtime review failed: %s" % report)
		world.free()
		return 1

	print("Luna attack runtime review capture OK: %s" % OUT_IMAGE)
	print("Luna attack runtime review report: %s" % OUT_REPORT)
	world.free()
	return 0


# 等待玩家稳定落地，保证攻击从地面状态起手。
func _settle_player(player: CharacterBody2D, max_frames: int) -> void:
	for _i in range(max_frames):
		if player.is_on_floor() and absf(player.velocity.x) <= 0.1 and absf(player.velocity.y) <= 0.1:
			await physics_frame
			await physics_frame
			return
		await physics_frame


# 汇总截图采样、玩家状态、body runtime 和两个攻击 VFX 约束。
func _build_report(image: Image, player: CharacterBody2D) -> Dictionary:
	var runtime_visual := player.get_node_or_null("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var slash_vfx := player.get_node_or_null("AttackSlashVfxVisual") as AnimatedSprite2D
	var seal_arc_vfx := player.get_node_or_null("AttackSealArcVfxVisual") as AnimatedSprite2D
	var legacy_slash := player.get_node_or_null("Stage12SlashPreview") as Sprite2D
	var state := String(player.call("get_current_state_id")) if player.has_method("get_current_state_id") else ""
	var runtime_report := _inspect_runtime_visual(runtime_visual)
	var slash_report := _inspect_attack_vfx(slash_vfx, TARGET_SLASH_ASSET_ID, TARGET_SLASH_SPRITEFRAMES, &"attack_slash")
	var seal_arc_report := _inspect_attack_vfx(seal_arc_vfx, TARGET_SEAL_ARC_ASSET_ID, TARGET_SEAL_ARC_SPRITEFRAMES, &"attack_seal_arc")
	var legacy_report := _inspect_legacy_slash(legacy_slash)
	var slash_has_collision_child := _has_collision_or_area_child(slash_vfx)
	var seal_arc_has_collision_child := _has_collision_or_area_child(seal_arc_vfx)
	var image_stats := _analyze_image(image)
	var ok := (
		state in ["attack", "air_attack"]
		and bool(runtime_report.get("visible", false))
		and bool(runtime_report.get("resource_ok", false))
		and bool(slash_report.get("visible", false))
		and bool(slash_report.get("resource_ok", false))
		and bool(slash_report.get("metadata_ok", false))
		and bool(seal_arc_report.get("visible", false))
		and bool(seal_arc_report.get("resource_ok", false))
		and bool(seal_arc_report.get("metadata_ok", false))
		and not bool(legacy_report.get("visible", true))
		and not slash_has_collision_child
		and not seal_arc_has_collision_child
		and bool(image_stats.get("ok", false))
	)

	return {
		"ok": ok,
		"review_id": "arp_18_luna_attack_vfx_runtime",
		"scene": PLAYER_SCENE_PATH,
		"image": OUT_IMAGE,
		"viewport_size": [VIEWPORT_SIZE.x, VIEWPORT_SIZE.y],
		"player_state": state,
		"runtime_visual": runtime_report,
		"attack_slash_vfx_visual": slash_report,
		"attack_seal_arc_vfx_visual": seal_arc_report,
		"legacy_stage12_slash_visual": legacy_report,
		"attack_slash_has_collision_or_area_child": slash_has_collision_child,
		"attack_seal_arc_has_collision_or_area_child": seal_arc_has_collision_child,
		"image_stats": image_stats,
		"manual_review_guidance": "Open the screenshot and confirm slash / seal arc position, alpha, overlap with Luna body, and readability.",
		"boundary": "Runtime screenshot and metadata review only; attack hitbox, damage timing and recovery remain authored by player gameplay code.",
	}


# 检查 Luna runtime visual 是否处于 clean attack body。
func _inspect_runtime_visual(visual: AnimatedSprite2D) -> Dictionary:
	if visual == null:
		return {"exists": false, "resource_ok": false}
	var resource_path := visual.sprite_frames.resource_path if visual.sprite_frames != null else ""
	var resource_ok := (
		str(visual.get_meta("asset_id", "")) == TARGET_BODY_ASSET_ID
		and resource_path == TARGET_BODY_SPRITEFRAMES
		and visual.animation == &"attack_body"
	)
	return {
		"exists": true,
		"visible": visual.visible,
		"asset_id": str(visual.get_meta("asset_id", "")),
		"resource_path": resource_path,
		"animation": String(visual.animation),
		"resource_ok": resource_ok,
	}


# 检查单个攻击 VFX 的资源、动画和 no-collision / no-damage metadata。
func _inspect_attack_vfx(visual: AnimatedSprite2D, asset_id: String, spriteframes_path: String, animation_name: StringName) -> Dictionary:
	if visual == null:
		return {"exists": false, "resource_ok": false, "metadata_ok": false}
	var resource_path := visual.sprite_frames.resource_path if visual.sprite_frames != null else ""
	var gameplay_collision := bool(visual.get_meta("gameplay_collision", true))
	var damage_source := bool(visual.get_meta("damage_source", true))
	var resource_ok := (
		str(visual.get_meta("asset_id", "")) == asset_id
		and resource_path == spriteframes_path
		and visual.animation == animation_name
	)
	var metadata_ok := not gameplay_collision and not damage_source
	return {
		"exists": true,
		"visible": visual.visible,
		"asset_id": str(visual.get_meta("asset_id", "")),
		"resource_path": resource_path,
		"animation": String(visual.animation),
		"position": [visual.position.x, visual.position.y],
		"flip_h": visual.flip_h,
		"gameplay_collision": gameplay_collision,
		"damage_source": damage_source,
		"resource_ok": resource_ok,
		"metadata_ok": metadata_ok,
	}


# 旧 Stage12 SVG 只允许作为隐藏历史预览资源存在。
func _inspect_legacy_slash(visual: Sprite2D) -> Dictionary:
	if visual == null:
		return {"exists": false, "visible": true}
	return {
		"exists": true,
		"visible": visual.visible,
		"asset_id": str(visual.get_meta("asset_id", "")),
		"gameplay_collision": bool(visual.get_meta("gameplay_collision", true)),
		"damage_source": bool(visual.get_meta("damage_source", true)),
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
