extends SceneTree

# Batch 7 Stage14 Shrine、Hub、Loop Return 运行态复核。

const MAIN := "res://scenes/main/main.tscn"
const SHRINE := "res://scenes/rooms/stage14_air_dash_shrine_room.tscn"
const HUB := "res://scenes/rooms/stage14_backtrack_hub_room.tscn"
const LOOP := "res://scenes/rooms/stage14_loop_return_room.tscn"
const STAGE15 := "res://scenes/rooms/stage15_seal_pressure_room.tscn"
const OUT := "res://tests/artifacts/local/formal-map-batch7-stage14-review"


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

	var shrine_ok := await _start(main, SHRINE, &"stage14_air_dash_shrine_start")
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	shrine_ok = shrine_ok and _foot(player, 224) and not bool(main.call("is_air_dash_unlocked"))
	var shrine_image := _shot("01_shrine_single_focus.png")
	player.global_position = Vector2(320, 124)
	player.velocity = Vector2.ZERO
	await _physics_frames(16)
	var shrine_grant_ok := _foot(player, 144) and bool(main.call("is_air_dash_unlocked")) and bool(room.call("has_air_dash_been_granted"))
	var shrine_grant_image := _shot("02_shrine_air_dash_granted.png")

	var hub_ok := await _start(main, HUB, &"stage14_backtrack_hub_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	hub_ok = hub_ok and _foot(player, 288)
	var hub_image := _shot("03_hub_three_reward_ascent.png")
	for target: Vector2 in [Vector2(128, 188), Vector2(512, 124), Vector2(896, 60)]:
		player.global_position = target
		player.velocity = Vector2.ZERO
		await _physics_frames(12)
	var hub_collect_ok := int(main.call("get_stage14_backtrack_reward_count")) == 3
	var hub_collect_image := _shot("04_hub_rewards_collected.png")

	var loop_ok := await _start(main, LOOP, &"stage14_loop_return_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	loop_ok = loop_ok and _foot(player, 224) and room.has_node("GoalZone/GoalMarkerArt")
	var loop_image := _shot("05_loop_return_upper_goal.png")
	player.global_position = Vector2(704, 60)
	player.velocity = Vector2.ZERO
	await _physics_frames(20)
	await _process_frames(8)
	var loop_transition_ok := (main.get_node("Room") as Node2D).scene_file_path == STAGE15

	var ok := shrine_ok and shrine_grant_ok and hub_ok and hub_collect_ok and loop_ok and loop_transition_ok
	ok = ok and shrine_image and shrine_grant_image and hub_image and hub_collect_image and loop_image
	var file := FileAccess.open(ProjectSettings.globalize_path("%s/formal_map_batch7_stage14_review.json" % OUT), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"ok": ok,
			"shrine_focus_and_grant_ok": shrine_ok and shrine_grant_ok,
			"hub_three_rewards_ok": hub_ok and hub_collect_ok,
			"loop_goal_and_stage15_transition_ok": loop_ok and loop_transition_ok,
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
