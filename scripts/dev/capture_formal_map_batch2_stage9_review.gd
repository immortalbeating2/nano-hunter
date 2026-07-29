extends SceneTree

# Stage9 五房正式地图运行态复核：验证脚底、层级、门控和 checkpoint 读值。

const MAIN := "res://scenes/main/main.tscn"
const ENTRY := "res://scenes/rooms/stage9_zone_entry_room.tscn"
const COMBAT := "res://scenes/rooms/stage9_zone_combat_room.tscn"
const CHARGER := "res://scenes/rooms/stage9_zone_charger_room.tscn"
const SWITCH := "res://scenes/rooms/stage9_zone_switch_room.tscn"
const FINAL := "res://scenes/rooms/stage9_zone_final_room.tscn"
const OUT := "res://tests/artifacts/local/formal-map-batch2-stage9-review"
const VIEWPORT := Vector2i(1280, 720)
const PLAYER_HALF_HEIGHT := 20.0


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	quit(await _capture())


func _capture() -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = VIEWPORT
	var packed := load(MAIN) as PackedScene
	if packed == null:
		return 1
	var main := packed.instantiate() as Node2D
	root.add_child(main)
	await _process_frames(4)
	_hide_shell(main)

	var entry_ok := await _start(main, ENTRY, &"zone_entry_start")
	var entry_room := main.get_node_or_null("Room") as Node2D
	var player := main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	entry_ok = entry_ok and _foot_matches(player, 160.0) and bool(entry_room.get_node("RegionCheckpoint/CheckpointArt").visible)
	var entry_image := _shot("01_entry_checkpoint.png")

	var combat_ok := await _start(main, COMBAT, &"zone_combat_start")
	var combat_room := main.get_node_or_null("Room") as Node2D
	player = main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	combat_ok = combat_ok and _foot_matches(player, 224.0) and not bool(combat_room.call("is_gate_unlocked"))
	player.global_position = Vector2(96, 124)
	player.velocity = Vector2.ZERO
	await _physics_frames(30)
	var combat_layer_ok := _foot_matches(player, 144.0)
	var combat_image := _shot("02_combat_two_layer.png")

	var charger_ok := await _start(main, CHARGER, &"zone_charger_start")
	var charger_room := main.get_node_or_null("Room") as Node2D
	player = main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var checkpoint_art := charger_room.get_node("CheckpointPoint/CheckpointArt") as Sprite2D
	charger_ok = charger_ok and _foot_matches(player, 224.0) and not checkpoint_art.visible
	player.global_position = Vector2(448, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(20)
	var charger_locked_image := _shot("03_charger_lane_locked.png")
	var charger_enemy := charger_room.get_node("GroundChargerEnemy")
	charger_enemy.call("receive_attack", Vector2.RIGHT, 120.0)
	await _process_frames(4)
	var charger_checkpoint_ok := checkpoint_art.visible and bool(charger_room.call("is_gate_unlocked"))
	var charger_open_image := _shot("04_charger_checkpoint_open.png")

	var switch_ok := await _start(main, SWITCH, &"zone_switch_start")
	var switch_room := main.get_node_or_null("Room") as Node2D
	player = main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = Vector2(352, 60)
	player.velocity = Vector2.ZERO
	await _physics_frames(24)
	await _process_frames(4)
	switch_ok = switch_ok and _foot_matches(player, 80.0) and bool(switch_room.call("is_gate_unlocked"))
	var switch_image := _shot("05_switch_upper_route_open.png")

	var final_ok := await _start(main, FINAL, &"zone_final_start")
	var final_room := main.get_node_or_null("Room") as Node2D
	player = main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	player.global_position = Vector2(128, 124)
	player.velocity = Vector2.ZERO
	await _physics_frames(24)
	var final_upper_ok := _foot_matches(player, 144.0) and not bool(final_room.call("is_gate_unlocked"))
	var final_left_image := _shot("06_final_layered_encounter.png")
	final_room.get_node("BasicMeleeEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	final_room.get_node("GroundChargerEnemy").call("receive_attack", Vector2.RIGHT, 120.0)
	await _process_frames(5)
	player.global_position = Vector2(960, 204)
	player.velocity = Vector2.ZERO
	await _physics_frames(20)
	var final_open_ok := bool(final_room.call("is_gate_unlocked")) and _foot_matches(player, 224.0)
	var final_gate_image := _shot("07_final_gate_open.png")

	var ok := entry_ok and combat_ok and combat_layer_ok and charger_ok and charger_checkpoint_ok and switch_ok and final_ok and final_upper_ok and final_open_ok
	ok = ok and entry_image and combat_image and charger_locked_image and charger_open_image and switch_image and final_left_image and final_gate_image
	_write_report({
		"ok": ok,
		"entry_checkpoint_ok": entry_ok,
		"combat_entry_ok": combat_ok,
		"combat_upper_layer_ok": combat_layer_ok,
		"charger_lane_ok": charger_ok,
		"charger_checkpoint_open_ok": charger_checkpoint_ok,
		"switch_upper_route_open_ok": switch_ok,
		"final_entry_ok": final_ok,
		"final_upper_layer_ok": final_upper_ok,
		"final_gate_open_ok": final_open_ok,
		"display_server": DisplayServer.get_name(),
	})
	main.queue_free()
	return 0 if ok else 1


func _start(main: Node, path: String, spawn: StringName) -> bool:
	var started := bool(main.call("start_demo_at_room", path, spawn, {}))
	await _process_frames(6)
	await _physics_frames(50)
	_hide_shell(main)
	return started and (main.get_node_or_null("Room") as Node2D).scene_file_path == path


func _foot_matches(player: CharacterBody2D, top: float) -> bool:
	return player != null and player.is_on_floor() and absf(player.global_position.y + PLAYER_HALF_HEIGHT - top) <= 0.6


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


func _write_report(data: Dictionary) -> void:
	var file := FileAccess.open(ProjectSettings.globalize_path("%s/formal_map_batch2_stage9_review.json" % OUT), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t", false) + "\n")


func _process_frames(count: int) -> void:
	for _i: int in range(count):
		await process_frame


func _physics_frames(count: int) -> void:
	for _i: int in range(count):
		await physics_frame
