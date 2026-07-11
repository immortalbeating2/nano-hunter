extends SceneTree

# Batch 6 Stage13 支路、回环与终点五房运行态复核。

const MAIN := "res://scenes/main/main.tscn"
const HUB := "res://scenes/rooms/stage13_miasma_marsh_branch_hub_room.tscn"
const RESOURCE := "res://scenes/rooms/stage13_miasma_marsh_resource_branch_room.tscn"
const CHALLENGE := "res://scenes/rooms/stage13_miasma_marsh_challenge_branch_room.tscn"
const RETURN := "res://scenes/rooms/stage13_miasma_marsh_return_room.tscn"
const GOAL := "res://scenes/rooms/stage13_miasma_marsh_goal_room.tscn"
const STAGE14 := "res://scenes/rooms/stage14_air_dash_shrine_room.tscn"
const OUT := "res://tests/artifacts/local/formal-map-batch6-stage13-branches-goal-review"


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

	var hub_ok := await _start(main, HUB, &"stage13_branch_hub_start")
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	hub_ok = hub_ok and _foot(player, 224) and room.has_node("ResourceBranchZone/ResourceMarkerArt") and room.has_node("ChallengeBranchZone/ChallengeMarkerArt") and room.has_node("ExitZone/ExitMarkerArt")
	var hub_image := _shot("01_branch_hub_three_routes.png")

	var resource_ok := await _start(main, RESOURCE, &"stage13_resource_branch_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	resource_ok = resource_ok and _foot(player, 224) and bool(room.get_node("Stage13Reward/RewardArt").visible)
	var resource_image := _shot("02_resource_branch_ascent.png")
	player.global_position = Vector2(512, 60)
	player.velocity = Vector2.ZERO
	await _physics_frames(16)
	var resource_collect_ok := _foot(player, 80) and int(room.call("get_stage13_progress_snapshot").branch_reward_count) == 1

	var challenge_ok := await _start(main, CHALLENGE, &"stage13_challenge_branch_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	challenge_ok = challenge_ok and _foot(player, 224) and not bool(room.call("is_gate_unlocked"))
	var challenge_locked_image := _shot("03_challenge_enemy_gate_reward.png")
	room.get_node("MiasmaCasterEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	await _process_frames(4)
	player.global_position = Vector2(1040, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(16)
	var challenge_clear_ok := _foot(player, 224) and bool(room.call("is_gate_unlocked")) and int(room.call("get_stage13_progress_snapshot").branch_reward_count) == 1
	var challenge_open_image := _shot("04_challenge_cleared_reward.png")

	var return_ok := await _start(main, RETURN, &"stage13_return_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	return_ok = return_ok and _foot(player, 224)
	var return_image := _shot("05_return_convergence.png")

	var goal_ok := await _start(main, GOAL, &"stage13_goal_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = Vector2(448, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(12)
	goal_ok = goal_ok and _foot(player, 224) and room.has_node("GoalDevice")
	var goal_image := _shot("06_goal_upper_ritual.png")
	player.global_position = Vector2(704, 124)
	player.velocity = Vector2.ZERO
	await _physics_frames(20)
	await _process_frames(8)
	var goal_transition_ok := (main.get_node("Room") as Node2D).scene_file_path == STAGE14

	var ok := hub_ok and resource_ok and resource_collect_ok and challenge_ok and challenge_clear_ok and return_ok and goal_ok and goal_transition_ok
	ok = ok and hub_image and resource_image and challenge_locked_image and challenge_open_image and return_image and goal_image
	var file := FileAccess.open(ProjectSettings.globalize_path("%s/formal_map_batch6_stage13_branches_goal_review.json" % OUT), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"ok": ok,
			"hub_three_routes_ok": hub_ok,
			"resource_ascent_ok": resource_ok and resource_collect_ok,
			"challenge_gate_reward_ok": challenge_ok and challenge_clear_ok,
			"return_convergence_ok": return_ok,
			"goal_ritual_and_stage14_transition_ok": goal_ok and goal_transition_ok,
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
