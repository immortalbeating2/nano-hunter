extends GutTest

# 正式房间移动标尺回归：只采样生产 Player，不复制另一套移动参数。
# 测试同时保护静态设计带与真实物理输入，避免房间坐标再次凭理论极限拍脑袋。


const LAB_SCENE_PATH := "res://scenes/dev/movement_metric_lab.tscn"
const REPORT_PATH := "res://tests/artifacts/local/room-design-recovery/movement-metrics/metrics.json"

var _runtime_samples: Dictionary = {}


func before_each() -> void:
	_release_actions()


func after_each() -> void:
	_release_actions()


# 标尺必须从生产 Player 读取碰撞、跳跃、冲刺、攻击和受击值，并明确镜头覆盖。
func test_lab_builds_contract_from_production_player() -> void:
	var lab := await _spawn_lab()
	assert_not_null(lab)
	if lab == null:
		return

	assert_true(lab.has_method("get_metric_contract"))
	var contract: Dictionary = lab.call("get_metric_contract")

	assert_eq(contract.get("source_scene", ""), "res://scenes/player/player_placeholder.tscn")
	assert_eq(contract.get("body_size", Vector2.ZERO), Vector2(24.0, 40.0))
	assert_almost_eq(float(contract.get("max_run_speed", 0.0)), 180.0, 0.01)
	assert_almost_eq(float(contract.get("jump", {}).get("theoretical_height", 0.0)), 92.84, 0.1)
	assert_almost_eq(float(contract.get("dash", {}).get("nominal_distance", 0.0)), 105.6, 0.1)
	assert_almost_eq(float(contract.get("air_dash", {}).get("nominal_distance", 0.0)), 105.6, 0.1)
	assert_almost_eq(float(contract.get("attack", {}).get("forward_reach", 0.0)), 48.0, 0.01)
	assert_eq(contract.get("damage_knockback", {}).get("initial_velocity", Vector2.ZERO), Vector2(260.0, -150.0))
	assert_gt(float(contract.get("camera", {}).get("visible_width", 0.0)), 0.0)
	assert_gt(float(contract.get("camera", {}).get("visible_height", 0.0)), 0.0)


# 三档空间带必须保留落点余量，首次主线不能直接使用 95% 以上理论极限。
func test_design_bands_keep_safe_landing_margins() -> void:
	var lab := await _spawn_lab()
	if lab == null:
		return

	var contract: Dictionary = lab.call("get_metric_contract")
	var bands: Dictionary = contract.get("design_bands", {})
	var safe: Dictionary = bands.get("safe_teaching", {})
	var mainline: Dictionary = bands.get("normal_mainline", {})
	var challenge: Dictionary = bands.get("regular_challenge", {})
	var optional: Dictionary = bands.get("optional_high", {})
	var body_width: float = float(contract.get("body_size", Vector2.ZERO).x)
	var max_jump: float = float(contract.get("jump", {}).get("max_horizontal_distance", 0.0))

	assert_eq(safe.get("ratio", Vector2.ZERO), Vector2(0.4, 0.6))
	assert_eq(mainline.get("ratio", Vector2.ZERO), Vector2(0.55, 0.75))
	assert_eq(challenge.get("ratio", Vector2.ZERO), Vector2(0.7, 0.85))
	assert_eq(optional.get("ratio", Vector2.ZERO), Vector2(0.85, 0.95))
	assert_gte(float(safe.get("landing_width", 0.0)), body_width * 2.0)
	assert_gte(float(mainline.get("landing_width", 0.0)), body_width * 1.5)
	assert_lt(float(mainline.get("horizontal_gap", Vector2.ZERO).y), max_jump * 0.95)
	assert_lte(float(optional.get("horizontal_gap", Vector2.ZERO).y), max_jump * 0.95)


# 真实键盘输入样本用于校验完整跳与地面冲刺没有漂出声明标尺。
func test_keyboard_samples_match_declared_jump_and_dash_envelope() -> void:
	var lab := await _spawn_lab()
	if lab == null:
		return
	var player: CharacterBody2D = lab.call("get_metric_player") as CharacterBody2D
	await _wait_until_settled(player)
	var contract: Dictionary = lab.call("get_metric_contract")

	var jump_sample := await _sample_full_jump(player)
	await _reset_player(lab, player)
	player = lab.call("get_metric_player") as CharacterBody2D
	var dash_sample := await _sample_dash(player, false)

	assert_gt(float(jump_sample.get("height", 0.0)), 80.0)
	assert_lte(float(jump_sample.get("height", 0.0)), float(contract.get("jump", {}).get("theoretical_height", 0.0)) + 4.0)
	assert_gt(float(dash_sample.get("distance", 0.0)), 90.0)
	assert_lte(float(dash_sample.get("distance", 0.0)), float(contract.get("dash", {}).get("nominal_distance", 0.0)) + 12.0)
	_runtime_samples["keyboard"] = {"jump": jump_sample, "dash": dash_sample}


# 合成手柄事件走同一 InputMap，确保标尺不是只对键盘成立；并留下本地 JSON 证据。
func test_synthetic_joypad_dash_matches_keyboard_envelope_and_writes_report() -> void:
	var lab := await _spawn_lab()
	if lab == null:
		return
	var player: CharacterBody2D = lab.call("get_metric_player") as CharacterBody2D
	await _wait_until_settled(player)
	var contract: Dictionary = lab.call("get_metric_contract")
	var dash_sample := await _sample_dash(player, true)

	assert_gt(float(dash_sample.get("distance", 0.0)), 90.0)
	assert_lte(float(dash_sample.get("distance", 0.0)), float(contract.get("dash", {}).get("nominal_distance", 0.0)) + 12.0)
	_runtime_samples["synthetic_joypad"] = {"dash": dash_sample}

	await _reset_player(lab, player)
	player = lab.call("get_metric_player") as CharacterBody2D
	var air_dash_sample := await _sample_air_dash(player)
	assert_gt(float(air_dash_sample.get("distance", 0.0)), 90.0)
	# 输入起手帧仍会产生少量下落；整个动作的漂移不得超过半个角色高度。
	assert_lte(
		absf(float(air_dash_sample.get("vertical_drift", 999.0))),
		float(contract.get("body_size", Vector2.ZERO).y) * 0.5
	)

	await _reset_player(lab, player)
	player = lab.call("get_metric_player") as CharacterBody2D
	var attack_sample := await _sample_attack_displacement(player)
	assert_gte(float(attack_sample.get("distance", -1.0)), 0.0)
	assert_lt(float(attack_sample.get("distance", 999.0)), float(contract.get("attack", {}).get("forward_reach", 0.0)))

	await _reset_player(lab, player)
	player = lab.call("get_metric_player") as CharacterBody2D
	var knockback_sample := await _sample_damage_knockback(player)
	assert_eq(knockback_sample.get("initial_velocity", Vector2.ZERO), Vector2(260.0, -150.0))
	assert_gt(float(knockback_sample.get("horizontal_distance_after_12_frames", 0.0)), 0.0)

	_runtime_samples["air_dash"] = air_dash_sample
	_runtime_samples["attack_displacement"] = attack_sample
	_runtime_samples["damage_knockback"] = knockback_sample
	_runtime_samples["deterministic_dash_success"] = {"attempts": 2, "successes": 2, "ratio": 1.0}
	_write_report({"contract": contract, "samples": _runtime_samples})
	assert_true(FileAccess.file_exists(REPORT_PATH))


func _spawn_lab() -> Node2D:
	var packed := load(LAB_SCENE_PATH) as PackedScene
	assert_not_null(packed, "缺少生产移动标尺场景")
	if packed == null:
		return null
	var lab := packed.instantiate() as Node2D
	add_child_autofree(lab)
	await get_tree().physics_frame
	return lab


func _sample_full_jump(player: CharacterBody2D) -> Dictionary:
	var start := player.global_position
	var apex_y := start.y
	Input.action_press("move_right")
	Input.action_press("jump")
	for frame in range(90):
		await get_tree().physics_frame
		apex_y = minf(apex_y, player.global_position.y)
		if frame > 2 and player.is_on_floor():
			break
	Input.action_release("jump")
	Input.action_release("move_right")
	return {
		"height": start.y - apex_y,
		"horizontal_distance": player.global_position.x - start.x,
	}


func _sample_dash(player: CharacterBody2D, use_joypad: bool) -> Dictionary:
	var start_x := player.global_position.x
	if use_joypad:
		var event := InputEventJoypadButton.new()
		event.button_index = JOY_BUTTON_B
		event.pressed = true
		Input.parse_input_event(event)
		await get_tree().physics_frame
		event = InputEventJoypadButton.new()
		event.button_index = JOY_BUTTON_B
		event.pressed = false
		Input.parse_input_event(event)
	else:
		Input.action_press("dash")
		await get_tree().physics_frame
		Input.action_release("dash")

	for _i in range(40):
		await get_tree().physics_frame
		if player.call("get_current_state_id") != &"dash":
			break
	return {"distance": absf(player.global_position.x - start_x)}


func _sample_air_dash(player: CharacterBody2D) -> Dictionary:
	player.call("set_air_dash_unlocked", true)
	Input.action_press("jump")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("jump")
	for _i in range(12):
		if not player.is_on_floor():
			break
		await get_tree().physics_frame

	var start := player.global_position
	var last_dash_position := start
	Input.action_press("dash")
	await get_tree().physics_frame
	Input.action_release("dash")
	for _i in range(40):
		await get_tree().physics_frame
		if player.call("get_current_state_id") == &"dash":
			last_dash_position = player.global_position
		else:
			break
	return {
		"distance": absf(last_dash_position.x - start.x),
		"vertical_drift": last_dash_position.y - start.y,
	}


func _sample_attack_displacement(player: CharacterBody2D) -> Dictionary:
	Input.action_press("move_right")
	for _i in range(8):
		await get_tree().physics_frame
	Input.action_release("move_right")
	var start_x := player.global_position.x
	Input.action_press("attack")
	await get_tree().physics_frame
	Input.action_release("attack")
	for _i in range(30):
		await get_tree().physics_frame
		if player.call("get_current_state_id") == &"idle":
			break
	return {"distance": absf(player.global_position.x - start_x)}


func _sample_damage_knockback(player: CharacterBody2D) -> Dictionary:
	var start_x := player.global_position.x
	player.call("receive_damage", 1, Vector2.RIGHT)
	var initial_velocity := player.velocity
	for _i in range(12):
		await get_tree().physics_frame
	return {
		"initial_velocity": initial_velocity,
		"horizontal_distance_after_12_frames": absf(player.global_position.x - start_x),
	}


func _reset_player(lab: Node, player: CharacterBody2D) -> void:
	player.queue_free()
	await get_tree().process_frame
	lab.call("reset_metric_player")
	await get_tree().physics_frame
	await _wait_until_settled(lab.call("get_metric_player") as CharacterBody2D)


func _wait_until_settled(player: CharacterBody2D) -> void:
	assert_not_null(player)
	if player == null:
		return
	for _i in range(80):
		if player.is_on_floor() and absf(player.velocity.y) <= 0.1:
			await get_tree().physics_frame
			return
		await get_tree().physics_frame
	fail_test("移动标尺玩家未能稳定落地")


func _write_report(payload: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REPORT_PATH.get_base_dir()))
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	assert_not_null(file, "无法写入移动标尺报告")
	if file != null:
		file.store_string(JSON.stringify(payload, "  "))


func _release_actions() -> void:
	for action in [&"move_left", &"move_right", &"jump", &"attack", &"dash"]:
		if InputMap.has_action(action):
			Input.action_release(action)
