extends SceneTree

# Room3 ↔ Room4 回访复核：使用真实左移输入返回，记录两次进入 Room4 是否误触跌落失败。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const GOAL_ROOM_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const ENTRY_ROOM_PATH := "res://scenes/rooms/stage9_zone_entry_room.tscn"
const OUT_DIR := "res://tests/artifacts/local/room3-room4-roundtrip-review"
const OUT_REPORT := "%s/room3_room4_roundtrip_review.json" % OUT_DIR


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	await _wait_process_frames(6)

	var packed := load(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		quit(1)
		return
	var main := packed.instantiate() as Node2D
	root.add_child(main)
	await _wait_process_frames(8)
	main.call("start_demo")
	await _wait_process_frames(4)
	var started := bool(main.call("start_demo_at_room", GOAL_ROOM_PATH, &"goal_entry"))
	await _wait_process_frames(4)

	var completed_first := await _complete_goal_room(main)
	await _wait_physics_frames(30)
	var first_entry := _snapshot(main, "first_room4")
	first_entry["screenshot"] = _capture("%s/01_first_room4.png" % OUT_DIR)

	Input.action_press("move_left")
	var returned := await _wait_until_room(main, GOAL_ROOM_PATH, 180)
	await _wait_physics_frames(12)
	Input.action_release("move_left")
	await _wait_physics_frames(120)
	var return_stable := _snapshot(main, "room3_return_stable")
	return_stable["screenshot"] = _capture("%s/02_room3_return_stable.png" % OUT_DIR)

	Input.action_press("move_right")
	var completed_second := await _complete_goal_room(main)
	await _wait_physics_frames(24)
	Input.action_release("move_right")
	await _wait_physics_frames(96)
	var second_entry := _snapshot(main, "second_room4")
	second_entry["screenshot"] = _capture("%s/03_second_room4_no_failure.png" % OUT_DIR)

	var ok := (
		started
		and completed_first
		and returned
		and completed_second
		and str(first_entry.get("room_path", "")) == ENTRY_ROOM_PATH
		and not bool(first_entry.get("failure_visible", true))
		and str(return_stable.get("room_path", "")) == GOAL_ROOM_PATH
		and bool(return_stable.get("player_on_floor", false))
		and not bool(return_stable.get("failure_visible", true))
		and str(second_entry.get("room_path", "")) == ENTRY_ROOM_PATH
		and not bool(second_entry.get("failure_visible", true))
	)
	_write_json({
		"review_id": "room3_room4_roundtrip_review",
		"ok": ok,
		"uses_real_return_input": true,
		"first_entry": first_entry,
		"return_stable": return_stable,
		"second_entry": second_entry,
		"boundary": "Goal 完成使用敌人公开 receive_attack 与 GoalZone 触发；Room4 返回 Room3 使用真实 move_left 输入。",
	})
	print("room3_room4_roundtrip_review ok=%s" % str(ok).to_lower())
	Input.action_release("move_left")
	Input.action_release("move_right")
	main.queue_free()
	await _wait_process_frames(2)
	quit(0 if ok else 1)


func _complete_goal_room(main: Node2D) -> bool:
	var room := main.get_node_or_null("Room") as Node2D
	var player := main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	if room == null or player == null or room.scene_file_path != GOAL_ROOM_PATH:
		return false
	var enemy := room.get_node_or_null("BasicMeleeEnemy")
	var goal_zone := room.get_node_or_null("GoalZone") as Area2D
	if enemy == null or goal_zone == null or not enemy.has_method("receive_attack"):
		return false
	enemy.call("receive_attack", Vector2.RIGHT, 0.0)
	await _wait_process_frames(2)
	player.global_position = goal_zone.global_position
	await _wait_process_frames(4)
	var next_room := main.get_node_or_null("Room") as Node2D
	return next_room != null and next_room.scene_file_path == ENTRY_ROOM_PATH


func _wait_until_room(main: Node2D, expected_path: String, max_frames: int) -> bool:
	for _index: int in range(max_frames):
		await physics_frame
		var room := main.get_node_or_null("Room") as Node2D
		if room != null and room.scene_file_path == expected_path:
			return true
	return false


func _snapshot(main: Node2D, label: String) -> Dictionary:
	var room := main.get_node_or_null("Room") as Node2D
	var player := main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D
	var failure := main.get_node_or_null("HUD/DemoShell/FailurePanel") as Panel
	return {
		"label": label,
		"room_path": room.scene_file_path if room != null else "",
		"player_position": [player.global_position.x, player.global_position.y] if player != null else [],
		"player_on_floor": player.is_on_floor() if player != null else false,
		"failure_visible": failure.visible if failure != null else true,
	}


func _capture(path: String) -> Dictionary:
	var image := root.get_texture().get_image()
	var error := ERR_INVALID_DATA if image == null or image.is_empty() else image.save_png(path)
	return {"ok": error == OK, "path": path}


func _write_json(data: Dictionary) -> void:
	var file := FileAccess.open(ProjectSettings.globalize_path(OUT_REPORT), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t", false) + "\n")


func _wait_process_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame


func _wait_physics_frames(count: int) -> void:
	for _index: int in range(count):
		await physics_frame
