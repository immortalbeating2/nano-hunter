extends GutTest

# Stage29 雷泽清稿回归：保护六房拓扑 / 碰撞权威，同时确认专属背景、地形、地标和机关状态已接入。

const BASE_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_room_base.tscn"
const BACKGROUND_PATH := "res://assets/art/environment/thunder_waste/stage29_thunder_waste_background_runtime_ai01.png"
const ENVIRONMENT_PATH := "res://assets/art/environment/thunder_waste/stage29_thunder_waste_environment_runtime_ai01.png"
const VFX_PATH := "res://assets/art/environment/thunder_waste/stage29_thunder_waste_state_vfx_runtime_ai01.png"
const TILESET_PATH := "res://assets/art/environment/thunder_waste/stage29_thunder_waste_tiles_runtime_ai01.tileset.tres"
const ROOM_PATHS := [
	"res://scenes/rooms/stage25_thunder_waste_entry_room.tscn",
	"res://scenes/rooms/stage25_thunder_waste_stormfield_room.tscn",
	"res://scenes/rooms/stage25_thunder_waste_slope_room.tscn",
	"res://scenes/rooms/stage25_thunder_waste_fork_room.tscn",
	"res://scenes/rooms/stage25_thunder_waste_relay_room.tscn",
	"res://scenes/rooms/stage25_thunder_waste_outlook_room.tscn",
]


func after_each() -> void:
	get_tree().paused = false


func test_stage29_runtime_assets_and_tileset_are_loadable() -> void:
	for path: String in [BACKGROUND_PATH, ENVIRONMENT_PATH, VFX_PATH, TILESET_PATH]:
		assert_true(ResourceLoader.exists(path), "Stage29 资源可加载：%s" % path)

	var background := load(BACKGROUND_PATH) as Texture2D
	var environment := load(ENVIRONMENT_PATH) as Texture2D
	var vfx := load(VFX_PATH) as Texture2D
	var tileset := load(TILESET_PATH) as TileSet
	assert_eq(Vector2i(background.get_width(), background.get_height()), Vector2i(1280, 512))
	assert_eq(Vector2i(environment.get_width(), environment.get_height()), Vector2i(1024, 1024))
	assert_eq(Vector2i(vfx.get_width(), vfx.get_height()), Vector2i(1024, 1024))
	assert_eq(tileset.tile_size, Vector2i(64, 64))
	assert_eq(tileset.get_source_count(), 1)


func test_six_rooms_use_unique_landmarks_and_only_entry_declares_outpost() -> void:
	var landmark_indexes: Dictionary = {}
	for path: String in ROOM_PATHS:
		var room := await _spawn_room(path)
		assert_not_null(room, "雷泽房间可实例化：%s" % path)
		if room == null:
			continue

		var snapshot: Dictionary = room.call("get_stage25_progress_snapshot")
		var landmark_index := int(snapshot.get("stage29_landmark_index", -1))
		landmark_indexes[landmark_index] = true
		assert_between(landmark_index, 4, 9)
		var landmark_texture := (room.get_node("RoomLandmarkArt") as Sprite2D).texture as AtlasTexture
		assert_eq(landmark_texture.region.position, Vector2((landmark_index % 4) * 256, floori(landmark_index / 4.0) * 256))
		assert_eq((room.get_node("FormalGroundVisual") as TileMapLayer).get_used_cells().size(), 18)
		assert_false((room.get_node("Floor/FloorVisual") as CanvasItem).visible)
		assert_false((room.get_node("StormCloudBand") as CanvasItem).visible)
		assert_false((room.get_node("ExitZone/ExitMarker") as CanvasItem).visible)
		assert_eq(
			str((room.get_node("WasteBackgroundArt") as Sprite2D).get_meta("asset_id")),
			"stage29_thunder_waste_background_ai01"
		)

		var is_entry := path.ends_with("entry_room.tscn")
		assert_eq(StringName(snapshot.get("travel_point_id", StringName())), &"thunder_outpost" if is_entry else &"")
		assert_eq((room.get_node("OutpostCheckpointArt") as CanvasItem).visible, is_entry)

	assert_eq(landmark_indexes.size(), 6)


func test_storm_and_relay_use_formal_state_art_without_changing_collision() -> void:
	var room := await _spawn_room(ROOM_PATHS[4])
	assert_not_null(room)
	if room == null:
		return

	var floor_shape := room.get_node("Floor/CollisionShape2D") as CollisionShape2D
	assert_eq((floor_shape.shape as RectangleShape2D).size, Vector2(1152, 32))
	assert_eq((room.get_node("HazardGroundVisual") as TileMapLayer).get_used_cells().size(), 3)
	assert_false((room.get_node("StormField/FieldGlow") as CanvasItem).visible)
	assert_false((room.get_node("StormField/BoltLeft") as CanvasItem).visible)
	assert_false((room.get_node("StormField/BoltRight") as CanvasItem).visible)
	assert_false((room.get_node("StormRelay/RelayRing") as CanvasItem).visible)
	assert_false((room.get_node("StormRelay/RelayCore") as CanvasItem).visible)
	assert_false((room.get_node("GateBarrier/BarrierVisual") as CanvasItem).visible)

	var relay := room.get_node("StormRelay")
	relay.call("receive_elemental_attack", Vector2.RIGHT, 120.0, {
		"element_id": &"thunder",
		"reaction_id": &"wind_thunder_pierce",
	})
	assert_true(bool(relay.call("is_grounded")))
	assert_eq((relay.get_node("RelayStateArt") as AnimatedSprite2D).animation, &"relay_grounded")
	assert_eq((room.get_node("GateBarrier/Stage29BarrierArt") as AnimatedSprite2D).animation, &"barrier_open")
	assert_true((room.get_node("GateBarrier/CollisionShape2D") as CollisionShape2D).disabled)


func _spawn_room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return null
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room
