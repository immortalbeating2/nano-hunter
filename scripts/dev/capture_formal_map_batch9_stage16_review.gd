extends SceneTree

# Batch 9 Stage16 五房终局封印链运行态复核。

const MAIN := "res://scenes/main/main.tscn"
const THRESHOLD := "res://scenes/rooms/stage16_seal_release_threshold_room.tscn"
const RELAY := "res://scenes/rooms/stage16_talisman_relay_room.tscn"
const BACKTRACK := "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn"
const PURGE := "res://scenes/rooms/stage16_corruption_purge_room.tscn"
const END := "res://scenes/rooms/stage16_alpha_demo_end_room.tscn"
const OUT := "res://tests/artifacts/local/formal-map-batch9-stage16-review"


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

	var threshold_ok := await _start(main, THRESHOLD, &"stage16_seal_release_start")
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	threshold_ok = threshold_ok and _foot(player, 224) and not bool(room.call("is_gate_unlocked"))
	var threshold_image := _shot("01_threshold_upper_release.png")
	player.global_position = Vector2(320, 124)
	player.velocity = Vector2.ZERO
	await _physics_frames(16)
	var threshold_release_ok := _foot(player, 144) and bool(room.call("is_gate_unlocked"))
	var threshold_release_image := _shot("02_threshold_released.png")

	var relay_ok := await _start(main, RELAY, &"stage16_talisman_relay_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	relay_ok = relay_ok and _foot(player, 288) and not bool(room.call("is_gate_unlocked"))
	var relay_image := _shot("03_relay_three_level_chain.png")
	for target: Vector2 in [Vector2(128, 188), Vector2(512, 124), Vector2(896, 60)]:
		player.global_position = target
		player.velocity = Vector2.ZERO
		await _physics_frames(12)
	var relay_complete_ok := int(room.call("get_stage16_progress_snapshot").stage16_talisman_relay_count) == 3 and bool(room.call("is_gate_unlocked"))
	var relay_complete_image := _shot("04_relay_chain_complete.png")

	var backtrack_ok := await _start(main, BACKTRACK, &"stage16_backtrack_confirmation_start", {"stage14_backtrack_reward_count": 3})
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	backtrack_ok = backtrack_ok and _foot(player, 224) and not bool(room.call("is_gate_unlocked"))
	var backtrack_image := _shot("05_backtrack_upper_confirmation.png")
	player.global_position = Vector2(640, 60)
	player.velocity = Vector2.ZERO
	await _physics_frames(16)
	var backtrack_confirm_ok := _foot(player, 80) and bool(room.call("is_gate_unlocked"))

	var purge_ok := await _start(main, PURGE, &"stage16_corruption_purge_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = Vector2(448, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(16)
	purge_ok = purge_ok and _foot(player, 224) and not bool(room.call("is_gate_unlocked"))
	var purge_image := _shot("06_purge_hazard_and_upper_node.png")
	player.global_position = Vector2(640, 60)
	player.velocity = Vector2.ZERO
	await _physics_frames(16)
	var purge_complete_ok := _foot(player, 80) and bool(room.call("is_gate_unlocked"))
	var purge_complete_image := _shot("07_purge_complete.png")

	var end_ok := await _start(main, END, &"stage16_alpha_demo_end_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	end_ok = end_ok and _foot(player, 224) and room.has_node("AlphaDemoCompletionArt") and room.has_node("CompletionMessageLabel")
	var end_image := _shot("08_alpha_demo_end_hall.png")
	player.global_position = Vector2(736, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(20)
	await _process_frames(8)
	var end_complete_ok := bool(main.call("get_demo_progress_snapshot").stage16_alpha_demo_completed)

	var ok := threshold_ok and threshold_release_ok and relay_ok and relay_complete_ok and backtrack_ok and backtrack_confirm_ok and purge_ok and purge_complete_ok and end_ok and end_complete_ok
	ok = ok and threshold_image and threshold_release_image and relay_image and relay_complete_image and backtrack_image and purge_image and purge_complete_image and end_image
	var file := FileAccess.open(ProjectSettings.globalize_path("%s/formal_map_batch9_stage16_review.json" % OUT), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"ok": ok,
			"threshold_release_ok": threshold_ok and threshold_release_ok,
			"relay_three_level_ok": relay_ok and relay_complete_ok,
			"backtrack_confirmation_ok": backtrack_ok and backtrack_confirm_ok,
			"purge_hazard_and_node_ok": purge_ok and purge_complete_ok,
			"alpha_demo_end_ok": end_ok and end_complete_ok,
			"display_server": DisplayServer.get_name(),
		}, "\t", false) + "\n")
	main.queue_free()
	return 0 if ok else 1


func _start(main: Node, path: String, spawn: StringName, debug_progress: Dictionary = {}) -> bool:
	var ok := bool(main.call("start_demo_at_room", path, spawn, debug_progress))
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
