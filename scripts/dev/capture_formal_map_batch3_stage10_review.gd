extends SceneTree

# Stage10 三房正式地图运行态复核。

const MAIN := "res://scenes/main/main.tscn"
const AERIAL := "res://scenes/rooms/stage10_zone_aerial_room.tscn"
const BRANCH := "res://scenes/rooms/stage10_zone_branch_room.tscn"
const CHALLENGE := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const OUT := "res://tests/artifacts/local/formal-map-batch3-stage10-review"
const HALF_HEIGHT := 20.0


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	quit(await _capture())


func _capture() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1280, 720)
	var main := (load(MAIN) as PackedScene).instantiate() as Node2D
	root.add_child(main)
	await _process_frames(4)
	_hide_shell(main)

	var aerial_ok := await _start(main, AERIAL, &"stage10_aerial_start")
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	aerial_ok = aerial_ok and _foot(player, 224) and not bool(room.call("is_gate_unlocked"))
	var aerial_entry_image := _shot("01_aerial_branch_entry.png")
	player.global_position = Vector2(384, 60)
	player.velocity = Vector2.ZERO
	await _physics_frames(28)
	var aerial_layer_ok := _foot(player, 80)
	var aerial_layer_image := _shot("02_aerial_upper_combat.png")

	var branch_ok := await _start(main, BRANCH, &"stage10_branch_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	var branch_enemy := room.get_node("AerialSentinelEnemy")
	branch_enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _process_frames(4)
	player.global_position = Vector2(416, 60)
	player.velocity = Vector2.ZERO
	await _physics_frames(24)
	branch_ok = branch_ok and _foot(player, 80) and bool(room.call("is_gate_unlocked"))
	var branch_image := _shot("03_branch_reward_climb.png")

	var challenge_ok := await _start(main, CHALLENGE, &"stage10_challenge_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = Vector2(-64, 188)
	player.velocity = Vector2.ZERO
	await _physics_frames(24)
	var challenge_layer_ok := _foot(player, 208) and not bool(room.call("is_gate_unlocked"))
	var challenge_image := _shot("04_challenge_three_layers.png")
	for enemy_name: String in ["BasicMeleeEnemy", "GroundChargerEnemy", "AerialSentinelEnemy"]:
		room.get_node(enemy_name).call("receive_attack", Vector2.RIGHT, 120.0)
	await _process_frames(5)
	player.global_position = Vector2(1088, 268)
	player.velocity = Vector2.ZERO
	await _physics_frames(24)
	var challenge_open_ok := bool(room.call("is_gate_unlocked")) and _foot(player, 288)
	var challenge_open_image := _shot("05_challenge_gate_open.png")

	var ok := aerial_ok and aerial_layer_ok and branch_ok and challenge_ok and challenge_layer_ok and challenge_open_ok
	ok = ok and aerial_entry_image and aerial_layer_image and branch_image and challenge_image and challenge_open_image
	var file := FileAccess.open(ProjectSettings.globalize_path("%s/formal_map_batch3_stage10_review.json" % OUT), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"ok": ok,
			"aerial_entry_ok": aerial_ok,
			"aerial_upper_layer_ok": aerial_layer_ok,
			"branch_reward_route_ok": branch_ok,
			"challenge_entry_ok": challenge_ok,
			"challenge_layer_ok": challenge_layer_ok,
			"challenge_gate_open_ok": challenge_open_ok,
			"display_server": DisplayServer.get_name(),
		}, "\t", false) + "\n")
	main.queue_free()
	return 0 if ok else 1


func _start(main: Node, path: String, spawn: StringName) -> bool:
	var ok := bool(main.call("start_demo_at_room", path, spawn, {}))
	await _process_frames(6)
	await _physics_frames(50)
	_hide_shell(main)
	return ok and (main.get_node("Room") as Node2D).scene_file_path == path


func _foot(player: CharacterBody2D, top: float) -> bool:
	return player != null and player.is_on_floor() and absf(player.global_position.y + HALF_HEIGHT - top) <= 0.6


func _hide_shell(main: Node) -> void:
	var shell := main.get_node_or_null("HUD/DemoShell")
	if shell == null:
		return
	for path: String in ["MainMenu", "TitleBackground"]:
		var item := shell.get_node_or_null(path) as CanvasItem
		if item != null:
			item.visible = false


func _shot(name: String) -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	var image := root.get_texture().get_image()
	return image != null and not image.is_empty() and image.save_png("%s/%s" % [OUT, name]) == OK


func _process_frames(count: int) -> void:
	for _i: int in range(count):
		await process_frame


func _physics_frames(count: int) -> void:
	for _i: int in range(count):
		await physics_frame
