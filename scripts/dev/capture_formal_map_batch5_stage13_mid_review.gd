extends SceneTree

# Batch 5 Stage13 中段四房运行态复核。

const MAIN := "res://scenes/main/main.tscn"
const GATE := "res://scenes/rooms/stage13_miasma_marsh_gate_room.tscn"
const CROSSFIRE := "res://scenes/rooms/stage13_miasma_marsh_crossfire_room.tscn"
const CHECKPOINT := "res://scenes/rooms/stage13_miasma_marsh_checkpoint_room.tscn"
const PRESSURE := "res://scenes/rooms/stage13_miasma_marsh_pressure_room.tscn"
const OUT := "res://tests/artifacts/local/formal-map-batch5-stage13-mid-review"


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

	var gate_locked_ok := await _start(main, GATE, &"stage13_gate_start")
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	gate_locked_ok = gate_locked_ok and _foot(player, 224) and not bool(room.call("is_gate_unlocked")) and room.has_node("SealNode/SealArt")
	var gate_locked_image := _shot("01_gate_locked_and_seal_route.png")
	player.global_position = Vector2(384, 60)
	player.velocity = Vector2.ZERO
	await _physics_frames(20)
	var seal_ok := _foot(player, 80) and bool(room.call("is_seal_node_activated")) and bool(room.call("is_gate_unlocked"))
	var seal_image := _shot("02_gate_seal_activated.png")
	player.global_position = Vector2(768, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(16)
	var gate_approach_ok := _foot(player, 224) and bool(room.call("is_gate_unlocked"))
	var gate_open_image := _shot("03_gate_open_safe_approach.png")

	var crossfire_ok := await _start(main, CROSSFIRE, &"stage13_crossfire_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = Vector2(448, 124)
	player.velocity = Vector2.ZERO
	await _physics_frames(20)
	crossfire_ok = crossfire_ok and _foot(player, 144) and room.has_node("MiasmaCasterEnemyA") and room.has_node("MiasmaCasterEnemyB")
	var crossfire_image := _shot("04_crossfire_three_layer_arena.png")

	var checkpoint_ok := await _start(main, CHECKPOINT, &"stage13_checkpoint_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	checkpoint_ok = checkpoint_ok and _foot(player, 224) and bool(room.get_node("RecoveryPoint/CheckpointArt").visible)
	var checkpoint_image := _shot("05_checkpoint_recovery_hall.png")

	var pressure_ok := await _start(main, PRESSURE, &"stage13_pressure_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = Vector2(256, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(18)
	var hazard_lane_ok := _foot(player, 224) and bool(room.call("has_miasma_hazard"))
	var hazard_image := _shot("06_pressure_hazard_lane.png")
	player.global_position = Vector2(384, 124)
	player.velocity = Vector2.ZERO
	await _physics_frames(20)
	var bypass_ok := _foot(player, 144)
	var bypass_image := _shot("07_pressure_hazard_bypass.png")

	var ok := gate_locked_ok and seal_ok and gate_approach_ok and crossfire_ok and checkpoint_ok and pressure_ok and hazard_lane_ok and bypass_ok
	ok = ok and gate_locked_image and seal_image and gate_open_image and crossfire_image and checkpoint_image and hazard_image and bypass_image
	var file := FileAccess.open(ProjectSettings.globalize_path("%s/formal_map_batch5_stage13_mid_review.json" % OUT), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"ok": ok,
			"gate_locked_ok": gate_locked_ok,
			"gate_seal_activation_ok": seal_ok,
			"gate_safe_approach_ok": gate_approach_ok,
			"crossfire_three_layer_ok": crossfire_ok,
			"checkpoint_recovery_ok": checkpoint_ok,
			"pressure_hazard_lane_ok": pressure_ok and hazard_lane_ok,
			"pressure_bypass_ok": bypass_ok,
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
	return player != null and player.is_on_floor() and absf(player.global_position.y + 20.0 - top) <= 0.6


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
