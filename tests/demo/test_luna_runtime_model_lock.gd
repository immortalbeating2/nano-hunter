extends GutTest

# 本门禁从正式资产验收表反查玩家生产绑定，并验证 Luna 实际运行态始终留在同一 Model Lock 家族。

const PLAYER_SCENE := preload("res://scenes/player/player_placeholder.tscn")
const LUNA_IDLE_FRAMES := preload("res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_idle_runtime_sheet_ai03.spriteframes.tres")
const LUNA_JUMP_STATE_FRAMES := preload("res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_state_runtime_sheet_ai04.spriteframes.tres")
const LUNA_ATTACK_BODY_FRAMES := preload("res://assets/art/characters/player/sprite_sheets/runtime_replacement/luna_attack_body_runtime_sheet_ai03.spriteframes.tres")
const STAGE27_CORE_VFX_FRAMES := preload("res://assets/art/vfx/atlases/stage27_core_combat_vfx_runtime_ai01.spriteframes.tres")

const FINAL_ART_GATES_PATH := "res://docs/assets/final-art-acceptance-gates.json"
const RUNTIME_EVIDENCE_DIR := "res://tests/artifacts/local/runtime-visual-integrity/luna-model-lock/runtime"
const RUNTIME_EVIDENCE_REPORT := "%s/luna_model_lock_runtime_report.json" % RUNTIME_EVIDENCE_DIR
const RUNTIME_EVIDENCE_STRIP := "%s/luna_jump_phase_strip.png" % RUNTIME_EVIDENCE_DIR
const LIVE_PLAYER_ROOTS := ["res://scripts/player", "res://scenes/player"]
const LIVE_PLAYER_EXTENSIONS := ["gd", "tscn", "tres"]
const MODEL_LOCK_ID := "luna_model_v1"
const CANONICAL_REFERENCE := "luna_idle_runtime_sheet_ai03"
const LIVE_BODY_ASSET_IDS := [
	"luna_idle_runtime_sheet_ai03",
	"luna_run_runtime_sheet_ai03",
	"luna_jump_state_runtime_sheet_ai04",
	"luna_attack_body_runtime_sheet_ai03",
	"luna_air_dash_body_runtime_sheet_ai03",
	"luna_hit_react_runtime_sheet_ai03",
	"luna_death_idle_runtime_sheet_ai03",
]


# final_ready=false 的 player_animation 不得再从脚本、玩家场景或玩家资源进入生产运行态。
func test_false_final_player_animation_assets_are_not_live_bound() -> void:
	var gates := _read_json(FINAL_ART_GATES_PATH)
	var blocked_stems: Array[String] = []
	for entry: Dictionary in gates.get("entries", []):
		if str(entry.get("target_kind", "")) != "player_animation":
			continue
		if bool(entry.get("final_ready", false)):
			continue
		var output_path := str(entry.get("output_path", ""))
		if output_path.is_empty():
			continue
		blocked_stems.append(output_path.get_file().get_basename())

	assert_gt(blocked_stems.size(), 0, "验收表必须至少包含一个被阻断的玩家动作资产，避免门禁空跑。")
	var violations: Array[String] = []
	for root: String in LIVE_PLAYER_ROOTS:
		for path: String in _collect_runtime_files(root):
			var source := FileAccess.get_file_as_string(path)
			for stem: String in blocked_stems:
				if source.contains(stem):
					violations.append("%s -> %s" % [path, stem])

	assert_eq(violations, [], "发现 final_ready=false 玩家动作生产绑定：%s" % [str(violations)])


# 顶点两侧都必须延续 ai04 物理相位表，不能在低速区间换成另一套人物模型。
func test_jump_apex_keeps_ai04_model_lock_on_both_sides() -> void:
	var player := await _spawn_player()
	var body := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	player.set("_jump_visual_elapsed", 0.4)

	player.current_state = &"jump_rise"
	player.velocity.y = -40.0
	player.call("_update_runtime_animation_visual")
	assert_eq(body.sprite_frames, LUNA_JUMP_STATE_FRAMES)
	assert_eq(body.animation, &"rise_hold")
	assert_eq(body.get_meta("asset_id", ""), "luna_jump_state_runtime_sheet_ai04")

	player.current_state = &"jump_fall"
	player.velocity.y = 40.0
	player.call("_update_runtime_animation_visual")
	assert_eq(body.sprite_frames, LUNA_JUMP_STATE_FRAMES)
	assert_eq(body.animation, &"fall_hold")
	assert_eq(body.get_meta("asset_id", ""), "luna_jump_state_runtime_sheet_ai04")


# 姿态、空中攻击和序列反应只改变语义 VFX；人物 body 保持已验证的 ai03 攻击母版。
func test_all_attack_variants_keep_canonical_body_and_semantic_vfx() -> void:
	var player := await _spawn_player()
	var body := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var vfx := player.get_node("AttackSlashVfxVisual") as AnimatedSprite2D
	var cases := [
		{"state": &"attack", "stance": &"ward", "reaction": &"", "vfx": &"thunder_attack"},
		{"state": &"air_attack", "stance": &"swift", "reaction": &"", "vfx": &"thunder_attack"},
		{"state": &"attack", "stance": &"swift", "reaction": &"wind_thunder_pierce", "vfx": &"wind_thunder_pierce"},
		{"state": &"attack", "stance": &"swift", "reaction": &"thunder_wind_scatter", "vfx": &"thunder_wind_scatter"},
	]

	for runtime_case: Dictionary in cases:
		player.current_state = runtime_case.get("state")
		player.set("_current_stance_id", runtime_case.get("stance"))
		player.set("_current_element_id", &"thunder")
		player.set("_active_attack_reaction_id", runtime_case.get("reaction"))
		player.set("_attack_elapsed", 0.1)
		player.call("_update_runtime_animation_visual")
		assert_eq(body.sprite_frames, LUNA_ATTACK_BODY_FRAMES, "动作分支 %s 使用了另一套人物 body。" % runtime_case)
		assert_eq(body.animation, &"attack_body")
		assert_eq(body.get_meta("asset_id", ""), "luna_attack_body_runtime_sheet_ai03")
		assert_eq(vfx.sprite_frames, STAGE27_CORE_VFX_FRAMES)
		assert_eq(vfx.animation, runtime_case.get("vfx"), "动作分支 %s 丢失了语义 VFX。" % runtime_case)


# 元素 / 姿态切换仍可保留短反馈计时，但不能借此换入未通过验收的第二人物模型。
func test_presentation_actions_keep_canonical_idle_body() -> void:
	var player := await _spawn_player()
	var body := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	for action_id: StringName in [&"element_switch", &"stance_switch", &"recover"]:
		player.current_state = &"idle"
		player.set("_presentation_action_id", action_id)
		player.set("_presentation_action_remaining", 0.2)
		player.call("_update_runtime_animation_visual")
		assert_eq(body.sprite_frames, LUNA_IDLE_FRAMES, "%s 换入了另一套人物 body。" % action_id)
		assert_eq(body.animation, &"idle")
		assert_eq(body.get_meta("asset_id", ""), "luna_idle_runtime_sheet_ai03")


# 所有 live body metadata 都必须声明同一个模型、画布、中心轴和 canonical reference。
func test_live_body_metadata_declares_one_model_lock_contract() -> void:
	for asset_id: String in LIVE_BODY_ASSET_IDS:
		var path := "res://assets/art/characters/player/sprite_sheets/runtime_replacement/%s.frames.json" % asset_id
		var metadata := _read_json(path)
		var lock: Dictionary = metadata.get("model_lock", {})
		assert_eq(str(lock.get("model_id", "")), MODEL_LOCK_ID, "%s 缺少统一 model_id。" % asset_id)
		assert_eq(str(lock.get("canonical_reference", "")), CANONICAL_REFERENCE, "%s canonical reference 不一致。" % asset_id)
		var cell: Array = metadata.get("cell", [])
		assert_eq(cell.size(), 2, "%s cell 元数据不完整。" % asset_id)
		if cell.size() == 2:
			assert_eq(Vector2i(int(cell[0]), int(cell[1])), Vector2i(192, 192), "%s 画布不是 192x192。" % asset_id)
		assert_eq(int(lock.get("center_x", -1)), 96, "%s 中心轴不是 x=96。" % asset_id)
		assert_lte(float(lock.get("center_tolerance_px", 999.0)), 2.0, "%s 中心轴容差过宽。" % asset_id)


# 生产 Player 必须通过真实物理顶点；四个相位同时产出可视帧与逐帧 JSON，供非交互复核。
func test_real_jump_crosses_apex_without_leaving_model_lock_and_writes_evidence() -> void:
	var player := await _spawn_player_with_floor()
	var body := player.get_node("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var samples: Array[Dictionary] = []
	var captured_samples: Dictionary = {}
	var captured_images: Dictionary = {}

	player.call("_start_jump")
	for frame_index in range(180):
		await get_tree().physics_frame
		var sample := _sample_jump_state(player, body, frame_index)
		samples.append(sample)
		var state := String(sample.get("state", ""))
		var velocity_y := float(sample.get("velocity_y", 999.0))
		if state == "jump_rise" and velocity_y < -80.0 and not captured_samples.has("rise"):
			_capture_runtime_frame("rise", sample, body, captured_samples, captured_images)
		if state in ["jump_rise", "jump_fall"] and absf(velocity_y) < 80.0 and not captured_samples.has("apex"):
			_capture_runtime_frame("apex", sample, body, captured_samples, captured_images)
		if state == "jump_fall" and velocity_y > 80.0 and not captured_samples.has("fall"):
			_capture_runtime_frame("fall", sample, body, captured_samples, captured_images)
		if state == "land" and not captured_samples.has("land"):
			_capture_runtime_frame("land", sample, body, captured_samples, captured_images)
		if captured_samples.has("land") and state == "idle":
			break

	var jump_samples: Array = samples.filter(func(sample: Dictionary) -> bool:
		return String(sample.get("state", "")) in ["jump_rise", "jump_fall", "land"]
	)
	var wrong_assets: Array = jump_samples.filter(func(sample: Dictionary) -> bool:
		return String(sample.get("asset_id", "")) != "luna_jump_state_runtime_sheet_ai04"
	)
	var required_phases := ["rise", "apex", "fall", "land"]
	for phase: String in required_phases:
		assert_true(captured_samples.has(phase), "真实跳跃没有捕获 %s 相位。" % phase)
	assert_gt(jump_samples.size(), 0, "真实跳跃没有产生任何受检物理样本。")
	assert_eq(wrong_assets, [], "真实跳跃中出现跨模型 live body：%s" % str(wrong_assets))

	var strip_ok := _write_jump_phase_strip(captured_images, required_phases)
	var report := {
		"ok": strip_ok and wrong_assets.is_empty() and captured_samples.size() == required_phases.size(),
		"review_id": "luna_model_lock_real_physics_transition",
		"production_scene": "res://scenes/player/player_placeholder.tscn",
		"expected_asset_id": "luna_jump_state_runtime_sheet_ai04",
		"required_phases": required_phases,
		"captured_phases": captured_samples,
		"sample_count": samples.size(),
		"jump_state_sample_count": jump_samples.size(),
		"wrong_asset_samples": wrong_assets,
		"strip": RUNTIME_EVIDENCE_STRIP,
		"boundary": "生产 Player 的真实 physics_frame、状态和 SpriteFrames 绑定证据；不替代真人身份、轮廓或动作节奏美术签核。",
	}
	var report_ok := _write_json(RUNTIME_EVIDENCE_REPORT, report)
	assert_true(strip_ok, "无法写入 Luna 真实跳跃相位图。")
	assert_true(report_ok, "无法写入 Luna 真实跳跃 JSON 证据。")
	assert_true(bool(report.get("ok", false)), "Luna 真实跳跃 Model Lock 证据未达到门禁。")


func _spawn_player() -> CharacterBody2D:
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	return player


func _spawn_player_with_floor() -> CharacterBody2D:
	var world := Node2D.new()
	add_child_autofree(world)
	var floor := StaticBody2D.new()
	floor.position = Vector2(0.0, 160.0)
	world.add_child(floor)
	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(1024.0, 32.0)
	floor_shape.shape = rectangle
	floor.add_child(floor_shape)
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	world.add_child(player)
	for _index in range(64):
		if player.is_on_floor() and absf(player.velocity.y) <= 0.1:
			await get_tree().physics_frame
			return player
		await get_tree().physics_frame
	fail_test("Luna 未在预期帧数内稳定落地。")
	return player


func _sample_jump_state(player: CharacterBody2D, body: AnimatedSprite2D, physics_frame_index: int) -> Dictionary:
	return {
		"physics_frame": physics_frame_index,
		"state": String(player.call("get_current_state_id")),
		"velocity_y": player.velocity.y,
		"position": [player.position.x, player.position.y],
		"asset_id": String(body.get_meta("asset_id", "")),
		"animation": String(body.animation),
		"animation_frame": body.frame,
		"visual_position": [body.position.x, body.position.y],
		"visual_scale": [body.scale.x, body.scale.y],
	}


func _capture_runtime_frame(
	phase: String,
	sample: Dictionary,
	body: AnimatedSprite2D,
	captured_samples: Dictionary,
	captured_images: Dictionary
) -> void:
	captured_samples[phase] = sample.duplicate(true)
	var frame_texture := body.sprite_frames.get_frame_texture(body.animation, body.frame)
	if frame_texture == null:
		return
	var frame_image := frame_texture.get_image()
	if frame_image == null or frame_image.is_empty():
		return
	frame_image.convert(Image.FORMAT_RGBA8)
	captured_images[phase] = frame_image


func _write_jump_phase_strip(captured_images: Dictionary, phases: Array) -> bool:
	for phase: String in phases:
		if not captured_images.has(phase):
			return false
	var cell_size := Vector2i(220, 220)
	var strip := Image.create(cell_size.x * phases.size(), cell_size.y, false, Image.FORMAT_RGBA8)
	strip.fill(Color("081923"))
	for phase_index in range(phases.size()):
		var phase := String(phases[phase_index])
		var frame_image := captured_images.get(phase) as Image
		var origin := Vector2i(phase_index * cell_size.x + 14, 14)
		strip.fill_rect(
			Rect2i(phase_index * cell_size.x, 0, cell_size.x, 5),
			Color("d5a94f") if phase in ["apex", "land"] else Color("43dbe6")
		)
		strip.blit_rect(frame_image, Rect2i(Vector2i.ZERO, frame_image.get_size()), origin)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RUNTIME_EVIDENCE_DIR))
	return strip.save_png(RUNTIME_EVIDENCE_STRIP) == OK


func _write_json(path: String, data: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
	return true


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "无法读取 JSON：%s" % path)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert_true(parsed is Dictionary, "JSON 根节点必须是 Dictionary：%s" % path)
	return parsed as Dictionary if parsed is Dictionary else {}


func _collect_runtime_files(root: String) -> Array[String]:
	var result: Array[String] = []
	_walk_runtime_files(root, result)
	return result


func _walk_runtime_files(path: String, result: Array[String]) -> void:
	var directory := DirAccess.open(path)
	assert_not_null(directory, "无法扫描生产目录：%s" % path)
	if directory == null:
		return
	directory.list_dir_begin()
	var name := directory.get_next()
	while not name.is_empty():
		if not name.begins_with("."):
			var child_path := path.path_join(name)
			if directory.current_is_dir():
				_walk_runtime_files(child_path, result)
			elif name.get_extension() in LIVE_PLAYER_EXTENSIONS:
				result.append(child_path)
		name = directory.get_next()
	directory.list_dir_end()
