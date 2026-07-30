extends SceneTree

# Stage17-26 键鼠 / 手柄输入通路 smoke。
# 事件通过生产 InputMap 注入生产玩家，不直接调用玩家的动作启动函数。

const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const OUT_DIR := "res://tests/artifacts/local/stage17-animation-runtime"
const OUT_REPORT := "%s/input_smoke_report.json" % OUT_DIR
const ACTION_CASES := [
	"move_right",
	"jump",
	"attack",
	"dash",
	"recover",
	"element_switch",
	"stance_switch",
]


func _init() -> void:
	_run.call_deferred()


# 分别以键盘事件和 Joypad 事件驱动四个基础动作，任一事件未映射或未触发状态都失败。
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var rows: Array[Dictionary] = []
	for device in ["keyboard", "joypad"]:
		for action in ACTION_CASES:
			rows.append(await _probe_action(device, action))
	var ok := true
	for row in rows:
		if not bool(row.get("ok", false)):
			ok = false
	var report := {
		"ok": ok,
		"review_id": "stage17_input_smoke",
		"rows": rows,
		"boundary": "Automated InputMap smoke: keyboard and synthetic Joypad events enter the production player through Input.parse_input_event. This is not a claim of physical-controller hardware certification.",
	}
	if not _write_json(OUT_REPORT, report):
		quit(1)
		return
	print("Stage17 input smoke: ok=%s" % ok)
	print("Stage17 input smoke report: %s" % OUT_REPORT)
	quit(0 if ok else 1)


# 每个动作使用独立生产玩家夹具，避免 Dash 冷却或跳跃状态污染下一项。
func _probe_action(device: String, action: String) -> Dictionary:
	_release_actions()
	var world := Node2D.new()
	root.add_child(world)
	_add_floor(world)
	var player := await _spawn_player(world)
	if player == null:
		world.free()
		return {"ok": false, "device": device, "action": action, "error": "player_spawn_failed"}
	_prepare_action(player, action)

	var event := _input_event(device, action, true)
	var release_event := _input_event(device, action, false)
	if event == null or release_event == null:
		world.free()
		return {"ok": false, "device": device, "action": action, "error": "event_build_failed"}

	var mapped := InputMap.event_is_action(event, StringName(action), false)
	var start_x := player.global_position.x
	Input.parse_input_event(event)
	var observed := false
	for _i in range(12 if action == "move_right" else 3):
		await physics_frame
		if _action_observed(player, action, start_x):
			observed = true
	Input.parse_input_event(release_event)
	await physics_frame

	var visual := player.get_node_or_null("LunaRuntimeAnimationVisual") as AnimatedSprite2D
	var row := {
		"ok": mapped and observed,
		"device": device,
		"action": action,
		"mapped_by_input_map": mapped,
		"observed_in_player": observed,
		"state": String(player.call("get_current_state_id")),
		"animation": String(visual.animation) if visual != null else "",
		"asset_id": String(visual.get_meta("asset_id", "")) if visual != null else "",
		"x_delta": player.global_position.x - start_x,
		"element": String(player.call("get_current_element_id")),
		"stance": String(player.call("get_current_stance_id")),
		"health": int(player.call("get_current_health")),
	}
	world.free()
	_release_actions()
	return row


# 生产玩家动作以公开状态和真实位移判定，不读取测试专用字段。
func _action_observed(player: CharacterBody2D, action: String, start_x: float) -> bool:
	var state := String(player.call("get_current_state_id"))
	match action:
		"move_right":
			return player.global_position.x - start_x > 2.0
		"jump":
			return state == "jump_rise" or state == "jump_fall"
		"attack":
			return state == "attack"
		"dash":
			return state == "dash"
		"recover":
			return (
				int(player.call("get_current_health")) == int(player.call("get_max_health"))
				and not bool(player.call("can_spend_recovery_charge"))
			)
		"element_switch":
			return StringName(player.call("get_current_element_id")) == &"thunder"
		"stance_switch":
			return StringName(player.call("get_current_stance_id")) == &"ward"
	return false


# 根据项目当前默认绑定创建真实键盘或 Joypad 事件。
func _input_event(device: String, action: String, pressed: bool) -> InputEvent:
	if device == "keyboard":
		var key_event := InputEventKey.new()
		key_event.pressed = pressed
		var keycode: int = int({
			"move_right": KEY_D,
			"jump": KEY_SPACE,
			"attack": KEY_J,
			"dash": KEY_K,
			"recover": KEY_L,
			"element_switch": KEY_Q,
			"stance_switch": KEY_E,
		}.get(action, KEY_NONE))
		key_event.keycode = keycode
		key_event.physical_keycode = keycode
		return key_event

	if action == "move_right":
		var motion_event := InputEventJoypadMotion.new()
		motion_event.device = 0
		motion_event.axis = JOY_AXIS_LEFT_X
		motion_event.axis_value = 1.0 if pressed else 0.0
		return motion_event

	var button_event := InputEventJoypadButton.new()
	button_event.device = 0
	button_event.pressed = pressed
	button_event.button_index = int({
		"jump": JOY_BUTTON_A,
		"attack": JOY_BUTTON_X,
		"dash": JOY_BUTTON_B,
		"recover": JOY_BUTTON_Y,
		"element_switch": JOY_BUTTON_LEFT_SHOULDER,
		"stance_switch": JOY_BUTTON_RIGHT_SHOULDER,
	}.get(action, JOY_BUTTON_INVALID))
	return button_event


# 恢复与元素输入需要最小生产前置；每项仍由真实输入事件触发最终状态变化。
func _prepare_action(player: CharacterBody2D, action: String) -> void:
	if action == "recover":
		player.call("receive_damage", 1, Vector2.ZERO)
		player.call("add_recovery_charge", 1.0)
	elif action == "element_switch":
		player.call("set_wind_seal_unlocked", true)


# 玩家夹具沿用真实 CharacterBody2D、碰撞与地板，只关闭无关相机。
func _spawn_player(world: Node2D) -> CharacterBody2D:
	var packed_scene := ResourceLoader.load(PLAYER_SCENE_PATH) as PackedScene
	if packed_scene == null:
		return null
	var player := packed_scene.instantiate() as CharacterBody2D
	if player == null:
		return null
	player.position = Vector2.ZERO
	world.add_child(player)
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.enabled = false
	for _i in range(90):
		if player.is_on_floor() and absf(player.velocity.y) <= 0.1:
			await physics_frame
			return player
		await physics_frame
	return null


# 地板仅提供真实落地条件，不参与动作或输入判定。
func _add_floor(world: Node2D) -> void:
	var floor := StaticBody2D.new()
	floor.position = Vector2(0.0, 160.0)
	world.add_child(floor)
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(1024.0, 32.0)
	shape_node.shape = shape
	floor.add_child(shape_node)


# 每项前后都释放 action，避免 Input 单例把状态泄漏到下一夹具。
func _release_actions() -> void:
	for action in ["move_left", "move_right", "jump", "attack", "dash", "recover", "element_switch", "stance_switch"]:
		if InputMap.has_action(action):
			Input.action_release(action)


# 报告写入本地忽略目录，供最终收口引用而不提交硬件相关证据。
func _write_json(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write Stage17 input smoke JSON: %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t", false) + "\n")
	return true
