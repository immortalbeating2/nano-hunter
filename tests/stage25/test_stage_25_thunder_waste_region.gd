extends GutTest

# Stage25 雷泽荒原回归：保护路引门控、6 房拓扑、雷暴 / 接地机关和世界图同步。

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const WORLD_MAP_LAYOUT_PATH := "res://assets/configs/world_map/alpha_demo_world_map.json"
const STAGE11_ROOM_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const STAGE25_ENTRY_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_entry_room.tscn"
const STAGE25_STORM_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_stormfield_room.tscn"
const STAGE25_SLOPE_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_slope_room.tscn"
const STAGE25_FORK_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_fork_room.tscn"
const STAGE25_RELAY_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_relay_room.tscn"
const STAGE25_OUTLOOK_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_outlook_room.tscn"
const STAGE25_ROOM_PATHS := [
	STAGE25_ENTRY_ROOM_PATH,
	STAGE25_STORM_ROOM_PATH,
	STAGE25_SLOPE_ROOM_PATH,
	STAGE25_FORK_ROOM_PATH,
	STAGE25_RELAY_ROOM_PATH,
	STAGE25_OUTLOOK_ROOM_PATH,
]
const BOUNTY_IDS: Array[StringName] = [
	&"caster_hunt",
	&"demon_bone_evidence",
	&"seal_pulse_cleanup",
]


func before_each() -> void:
	Input.action_release("ui_down")


func after_each() -> void:
	get_tree().paused = false
	Input.action_release("ui_down")


func test_world_map_adds_six_waste_rooms_and_two_remote_connections() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WORLD_MAP_LAYOUT_PATH))
	assert_true(parsed is Dictionary)
	if not parsed is Dictionary:
		return

	var rooms: Array = parsed.get("rooms", [])
	assert_eq(rooms.size(), 44)
	var waste_rooms := rooms.filter(func(room: Dictionary) -> bool:
		return str(room.get("region", "")) == "waste"
	)
	assert_eq(waste_rooms.size(), 6)
	for room: Dictionary in waste_rooms:
		assert_true(ResourceLoader.exists(str(room.get("path", ""))))

	var regions: Array = parsed.get("regions", [])
	assert_eq(regions.filter(func(region: Dictionary) -> bool:
		return str(region.get("id", "")) == "waste"
	).size(), 1)

	var remote_connections: Array = parsed.get("remote_connections", [])
	var remote_by_id: Dictionary = {}
	for connection: Dictionary in remote_connections:
		remote_by_id[str(connection.get("id", ""))] = connection
	assert_eq(remote_connections.size(), 8)
	assert_eq(Array(remote_by_id["SC-07"].get("requirements", [])), ["waystation_intel_unlocked"])
	assert_eq(str(remote_by_id["SC-08"].get("from", "")), "40")
	assert_eq(str(remote_by_id["SC-08"].get("to", "")), "11")


func test_stage11_route_requires_all_bounties_turned_in() -> void:
	var main := await _spawn_main()
	main.call("transition_to_room", STAGE11_ROOM_PATH, &"stage11_demo_end_start")
	await get_tree().process_frame
	var room := main.get_node("Room") as Node2D
	var player := main.get_node("Runtime/PlayerPlaceholder") as CharacterBody2D
	assert_not_null(room)
	assert_not_null(player)
	if room == null or player == null:
		return

	player.global_position = (room.get_node("GoalZone") as Node2D).global_position
	await _advance_process_frames(2)
	Input.action_press("ui_down")
	await _advance_process_frames(2)
	Input.action_release("ui_down")
	_close_detail_panel(main)
	player.global_position = (room.get_node("ThunderRouteZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq(main.get_node("Room").scene_file_path, STAGE11_ROOM_PATH)
	assert_false(bool(room.call("is_thunder_waste_route_unlocked")))

	for bounty_id: StringName in BOUNTY_IDS:
		main.call("advance_bounty", bounty_id)
		main.call("_complete_bounty", bounty_id)
		main.call("advance_bounty", bounty_id)
	assert_true(bool(room.call("is_thunder_waste_route_unlocked")))

	# Stage28 在第三榜回交后复用 DetailPanel 显示一次性驿卒事件；确认后才恢复房间处理。
	await get_tree().process_frame
	_close_detail_panel(main)
	await _advance_process_frames(2)
	assert_eq(main.get_node("Room").scene_file_path, STAGE25_ENTRY_ROOM_PATH)

	main.call("restart_demo")
	await get_tree().process_frame
	assert_false(bool(main.call("get_bounty_board_snapshot").get("waystation_intel_unlocked", true)))


func test_six_rooms_form_main_route_internal_loop_and_waystation_return() -> void:
	var loaded_rooms: Dictionary = {}
	for room_path: String in STAGE25_ROOM_PATHS:
		var room := await _spawn_room(room_path)
		assert_not_null(room, "雷泽房间可加载：%s" % room_path)
		if room != null:
			loaded_rooms[room_path] = room
	assert_eq(loaded_rooms.size(), 6)
	if loaded_rooms.size() != 6:
		return

	assert_eq(str(loaded_rooms[STAGE25_ENTRY_ROOM_PATH].next_room_path), STAGE25_STORM_ROOM_PATH)
	assert_eq(str(loaded_rooms[STAGE25_STORM_ROOM_PATH].next_room_path), STAGE25_SLOPE_ROOM_PATH)
	assert_eq(str(loaded_rooms[STAGE25_SLOPE_ROOM_PATH].next_room_path), STAGE25_FORK_ROOM_PATH)
	assert_eq(str(loaded_rooms[STAGE25_FORK_ROOM_PATH].next_room_path), STAGE25_OUTLOOK_ROOM_PATH)
	assert_eq(str(loaded_rooms[STAGE25_FORK_ROOM_PATH].branch_room_path), STAGE25_RELAY_ROOM_PATH)
	assert_eq(str(loaded_rooms[STAGE25_RELAY_ROOM_PATH].next_room_path), STAGE25_SLOPE_ROOM_PATH)
	assert_eq(str(loaded_rooms[STAGE25_OUTLOOK_ROOM_PATH].next_room_path), STAGE11_ROOM_PATH)
	assert_true(bool(loaded_rooms[STAGE25_ENTRY_ROOM_PATH].checkpoint_on_ready))


func test_storm_hits_once_and_wind_thunder_sequence_grounds_relay() -> void:
	var room := await _spawn_room(STAGE25_RELAY_ROOM_PATH)
	var player := await _spawn_player()
	assert_not_null(room)
	assert_not_null(player)
	if room == null or player == null:
		return

	room.call("bind_player", player)
	var health_before := int(player.call("get_current_health"))
	player.global_position = (room.get_node("StormField") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq(int(player.call("get_current_health")), health_before - 1)
	await _advance_process_frames(2)
	assert_eq(int(player.call("get_current_health")), health_before - 1)
	assert_false(bool(room.call("is_gate_unlocked")))

	var relay := room.get_node("StormRelay")
	relay.call("receive_elemental_attack", Vector2.RIGHT, 120.0, {
		"element_id": &"wind",
		"reaction_id": &"thunder_wind_scatter",
	})
	assert_false(bool(relay.call("is_grounded")))
	assert_false(bool(room.call("is_gate_unlocked")))

	relay.call("receive_elemental_attack", Vector2.RIGHT, 120.0, {
		"element_id": &"thunder",
		"reaction_id": &"wind_thunder_pierce",
	})
	assert_true(bool(relay.call("is_grounded")))
	assert_true(bool(room.call("is_gate_unlocked")))
	assert_false((room.get_node("StormField") as CanvasItem).visible)


func test_fork_zone_requests_relay_branch() -> void:
	var room := await _spawn_room(STAGE25_FORK_ROOM_PATH)
	var player := await _spawn_player()
	var transitions: Array[Dictionary] = []
	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)
	player.global_position = (room.get_node("BranchZone") as Node2D).global_position
	await _advance_process_frames(2)
	assert_eq(transitions.size(), 1)
	if not transitions.is_empty():
		assert_eq(str(transitions[0].target), STAGE25_RELAY_ROOM_PATH)
		assert_eq(transitions[0].spawn, &"stage25_relay_start")


func _spawn_main() -> Node2D:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed)
	var main := packed.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	return main


func _spawn_room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return null
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


func _spawn_player() -> CharacterBody2D:
	var packed := load("res://scenes/player/player_placeholder.tscn") as PackedScene
	assert_not_null(packed)
	var player := packed.instantiate() as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	return player


func _advance_process_frames(count: int) -> void:
	for _index: int in range(count):
		await get_tree().process_frame


func _close_detail_panel(main: Node) -> void:
	var shell := main.get_node("HUD/DemoShell") as Control
	var detail_panel := shell.get_node("DetailPanel") as Control
	if not detail_panel.visible:
		return
	var back_button := shell.get_node(
		"DetailPanel/MarginContainer/VBoxContainer/DetailBackButton"
	) as Button
	back_button.pressed.emit()
