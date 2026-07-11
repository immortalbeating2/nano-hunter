extends SceneTree

# Batch 4 四房运行态复核。

const MAIN := "res://scenes/main/main.tscn"
const END := "res://scenes/rooms/stage11_demo_end_room.tscn"
const ENTRY := "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"
const CASTER := "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn"
const MIASMA := "res://scenes/rooms/stage13_miasma_marsh_miasma_room.tscn"
const OUT := "res://tests/artifacts/local/formal-map-batch4-stage11-stage13-review"


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

	var end_ok := await _start(main, END, &"stage11_demo_end_start")
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	end_ok = end_ok and _foot(player, 224) and room.has_node("ReplayZone/ReplayMarkerArt") and room.has_node("GoalZone/GoalMarkerArt") and room.has_node("ContinueZone/ContinueMarkerArt")
	var end_image := _shot("01_stage11_three_choice_hall.png")

	var entry_ok := await _start(main, ENTRY, &"stage13_entry_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	entry_ok = entry_ok and _foot(player, 224) and bool(room.get_node("RegionCheckpoint/CheckpointArt").visible)
	var entry_image := _shot("02_stage13_entry_checkpoint.png")

	var caster_ok := await _start(main, CASTER, &"stage13_miasma_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = Vector2(576, 60)
	player.velocity = Vector2.ZERO
	await _physics_frames(24)
	caster_ok = caster_ok and _foot(player, 80) and not bool(room.call("is_gate_unlocked"))
	var caster_image := _shot("03_stage13_caster_high_layer.png")
	room.get_node("MiasmaCasterEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	await _process_frames(4)
	player.global_position = Vector2(960, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(20)
	var caster_open_ok := bool(room.call("is_gate_unlocked")) and _foot(player, 224)
	var caster_open_image := _shot("04_stage13_caster_gate_open.png")

	var miasma_ok := await _start(main, MIASMA, &"stage13_miasma_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = Vector2(240, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(18)
	var hazard_floor_ok := _foot(player, 224) and bool(room.call("has_miasma_hazard"))
	var hazard_image := _shot("05_stage13_miasma_hazard_lane.png")
	player.global_position = Vector2(224, 124)
	player.velocity = Vector2.ZERO
	await _physics_frames(24)
	var bypass_ok := _foot(player, 144)
	var bypass_image := _shot("06_stage13_miasma_bypass.png")

	var ok := end_ok and entry_ok and caster_ok and caster_open_ok and miasma_ok and hazard_floor_ok and bypass_ok
	ok = ok and end_image and entry_image and caster_image and caster_open_image and hazard_image and bypass_image
	var file := FileAccess.open(ProjectSettings.globalize_path("%s/formal_map_batch4_stage11_stage13_review.json" % OUT), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"ok": ok, "stage11_end_ok": end_ok, "stage13_entry_ok": entry_ok,
			"caster_high_layer_ok": caster_ok, "caster_gate_open_ok": caster_open_ok,
			"miasma_hazard_lane_ok": miasma_ok and hazard_floor_ok, "miasma_bypass_ok": bypass_ok,
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
