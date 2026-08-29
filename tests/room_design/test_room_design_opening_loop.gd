extends GutTest

# 方案 B 开场三房回归：教程、首次实战与镇妖驿站必须生产直连，
# 历史 goal_trial 仅保留兼容入口，不再占用正式主路线。


const TUTORIAL := "res://scenes/rooms/tutorial_room.tscn"
const COMBAT := "res://scenes/rooms/combat_trial_room.tscn"
const HUB := "res://scenes/rooms/stage11_demo_end_room.tscn"
const MARSH_ENTRY := "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"


func test_opening_rooms_publish_formal_roles_and_direct_links() -> void:
	var tutorial := await _spawn(TUTORIAL)
	var combat := await _spawn(COMBAT)
	var hub := await _spawn(HUB)

	assert_eq(str(tutorial.get_meta("formal_room_id", "")), "F01")
	assert_eq(str(combat.get_meta("formal_room_id", "")), "F02")
	assert_eq(str(hub.get_meta("formal_room_id", "")), "F03")
	assert_eq(tutorial.call("get_forward_room_path"), COMBAT)
	assert_eq(combat.call("get_forward_room_path"), HUB)
	assert_eq(hub.call("get_forward_room_path"), MARSH_ENTRY)
	assert_eq(str(hub.get_meta("route_role", "")), "reusable_waystation_hub")


func test_combat_clear_requires_bounty_confirmation_before_hub() -> void:
	var combat := await _spawn(COMBAT)
	var player := await _spawn_player()
	var transitions: Array[Dictionary] = []
	combat.call("bind_player", player)
	combat.connect("room_transition_requested", func(target: String, spawn: StringName) -> void:
		transitions.append({"target": target, "spawn": spawn})
	)

	combat.call("_on_basic_melee_enemy_defeated")
	player.global_position = (combat.get_node("BountyBoardZone") as Node2D).global_position
	await _frames(2)
	assert_true(transitions.is_empty(), "F02 清场后仍须在悬令台明确确认。")
	Input.action_press("ui_down")
	await _frames(2)
	Input.action_release("ui_down")
	assert_eq(transitions.size(), 1)
	if not transitions.is_empty():
		assert_eq(transitions[0].target, HUB)
		assert_eq(transitions[0].spawn, &"stage11_demo_end_start")


func _spawn(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed)
	var node := packed.instantiate() as Node2D
	add_child_autofree(node)
	await get_tree().process_frame
	return node


func _spawn_player() -> CharacterBody2D:
	var player := (load("res://scenes/player/player_placeholder.tscn") as PackedScene).instantiate() as CharacterBody2D
	add_child_autofree(player)
	await get_tree().process_frame
	return player


func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame
