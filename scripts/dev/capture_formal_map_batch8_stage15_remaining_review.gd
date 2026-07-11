extends SceneTree

# Batch 8 Stage15 剩余四房运行态复核。

const MAIN := "res://scenes/main/main.tscn"
const PRESSURE := "res://scenes/rooms/stage15_seal_pressure_room.tscn"
const CHALLENGE := "res://scenes/rooms/stage15_challenge_branch_room.tscn"
const BOSS := "res://scenes/rooms/stage15_seal_guardian_boss_room.tscn"
const COMPLETION := "res://scenes/rooms/stage15_completion_room.tscn"
const STAGE16 := "res://scenes/rooms/stage16_seal_release_threshold_room.tscn"
const OUT := "res://tests/artifacts/local/formal-map-batch8-stage15-review"


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

	var pressure_ok := await _start(main, PRESSURE, &"stage15_seal_pressure_start")
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	pressure_ok = pressure_ok and _foot(player, 224) and not bool(room.call("is_gate_unlocked"))
	var pressure_image := _shot("01_pressure_two_enemy_clear.png")
	room.get_node("GroundChargerEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	room.get_node("MiasmaCasterEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	await _process_frames(5)
	var pressure_clear_ok := bool(room.call("is_gate_unlocked"))
	var pressure_clear_image := _shot("02_pressure_gate_open.png")

	var challenge_ok := await _start(main, CHALLENGE, &"stage15_challenge_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = Vector2(448, 124)
	player.velocity = Vector2.ZERO
	await _physics_frames(18)
	challenge_ok = challenge_ok and _foot(player, 144) and bool(room.call("has_miasma_hazard")) and not bool(room.call("is_gate_unlocked"))
	var challenge_image := _shot("03_challenge_hazard_bypass.png")
	room.get_node("MiasmaCasterEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	room.get_node("AerialSentinelEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	await _process_frames(5)
	player.global_position = Vector2(1088, 268)
	player.velocity = Vector2.ZERO
	await _physics_frames(16)
	var challenge_clear_ok := bool(room.call("is_gate_unlocked")) and int(room.call("get_stage13_progress_snapshot").branch_reward_count) == 1
	var challenge_clear_image := _shot("04_challenge_clear_reward.png")

	var boss_ok := await _start(main, BOSS, &"stage15_boss_start")
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	boss_ok = boss_ok and _foot(player, 288) and room.has_node("SealGuardianBoss")
	var boss_image := _shot("05_boss_wide_arena.png")
	var boss := room.get_node("SealGuardianBoss")
	for _i: int in range(int(boss.call("get_max_health"))):
		boss.call("receive_attack", Vector2.RIGHT, 120.0)
	await _process_frames(10)
	var boss_transition_ok := (main.get_node("Room") as Node2D).scene_file_path == COMPLETION

	var completion_ok := boss_transition_ok
	room = main.get_node("Room") as Node2D
	player = main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	await _physics_frames(40)
	completion_ok = completion_ok and _foot(player, 224) and room.has_node("CompletionSeal/SealCompletionArt")
	var completion_image := _shot("06_completion_ceremonial_hall.png")
	player.global_position = Vector2(736, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(20)
	await _process_frames(8)
	var completion_transition_ok := (main.get_node("Room") as Node2D).scene_file_path == STAGE16

	var ok := pressure_ok and pressure_clear_ok and challenge_ok and challenge_clear_ok and boss_ok and boss_transition_ok and completion_ok and completion_transition_ok
	ok = ok and pressure_image and pressure_clear_image and challenge_image and challenge_clear_image and boss_image and completion_image
	var file := FileAccess.open(ProjectSettings.globalize_path("%s/formal_map_batch8_stage15_review.json" % OUT), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"ok": ok,
			"pressure_clear_gate_ok": pressure_ok and pressure_clear_ok,
			"challenge_hazard_reward_ok": challenge_ok and challenge_clear_ok,
			"boss_arena_and_completion_transition_ok": boss_ok and boss_transition_ok,
			"completion_and_stage16_transition_ok": completion_ok and completion_transition_ok,
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
