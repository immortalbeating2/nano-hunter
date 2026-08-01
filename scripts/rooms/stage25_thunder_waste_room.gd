extends "res://scripts/rooms/stage10_room_base.gd"

# Stage25 雷泽房间复用既有出口、checkpoint 与 HUD 契约，只追加雷暴、接地祭柱和单一支路入口。

@export var stage25_title := "雷泽荒原"
@export_multiline var stage25_prompt := ""
@export var storm_hazard_present := false
@export var relay_gate_present := false
@export var storm_damage := 1
@export var branch_room_path := ""
@export var branch_spawn_id: StringName = &""
@export_range(4, 9, 1) var stage29_landmark_index := 4
@export var stage29_landmark_position := Vector2(128, 132)
@export var travel_point_id: StringName = &""
@export var shortcut_requires_thunder_absorption := false

const STAGE29_ENVIRONMENT_ATLAS: Texture2D = preload(
	"res://assets/art/environment/thunder_waste/stage29_thunder_waste_environment_runtime_ai01.png"
)

var _storm_damage_dealt := false
var _relay_grounded := false
var _stage25_branch_requested := false


# 初始化时按导出字段显示主题节点；非机关房立即复用父类开门状态。
func _ready() -> void:
	super._ready()
	_apply_stage29_presentation()
	var storm_field := get_node_or_null("StormField") as CanvasItem
	if storm_field != null:
		storm_field.visible = storm_hazard_present

	var relay := get_node_or_null("StormRelay") as StaticBody2D
	if relay != null:
		relay.visible = relay_gate_present
		relay.collision_layer = 4 if relay_gate_present else 0
		var callback := Callable(self, "_on_storm_relay_grounded")
		if relay_gate_present and relay.has_signal("grounded") and not relay.is_connected("grounded", callback):
			relay.connect("grounded", callback)

	var gate := get_node_or_null("GateBarrier") as CanvasItem
	if relay_gate_present:
		_gate_unlocked = false
		_apply_gate_lock_state()
	elif gate != null:
		unlock_gate()
		gate.visible = false

	var branch_zone := get_node_or_null("BranchZone") as CanvasItem
	if branch_zone != null:
		branch_zone.visible = not branch_room_path.is_empty()


# 雷泽房间先处理危险与支路，再交回父类处理左右出口和 checkpoint。
func _process(delta: float) -> void:
	_update_stage25_triggers()
	super._process(delta)


# 房间标题直接来自场景配置，避免为 6 个灰盒房创建 6 份流程资源。
func get_current_step_title() -> String:
	return stage25_title


func get_current_prompt_text() -> String:
	return stage25_prompt


# 主题快照供 HUD、GUT 与运行态复核读取，不保存跨房状态。
func get_stage25_progress_snapshot() -> Dictionary:
	return {
		"region_id": &"waste",
		"storm_hazard_present": storm_hazard_present,
		"storm_damage_dealt": _storm_damage_dealt,
		"relay_gate_present": relay_gate_present,
		"relay_grounded": _relay_grounded,
		"branch_room_path": branch_room_path,
		"stage29_landmark_index": stage29_landmark_index,
		"travel_point_id": travel_point_id,
		"absorption_shortcut_available": is_shortcut_available(),
	}


# Stage30 只给现有 ShortcutZone 增加一个能力条件，不建立第二套路由系统。
func is_shortcut_available() -> bool:
	if (
		shortcut_requires_thunder_absorption
		and (
			_main == null
			or not _main.has_method("is_thunder_absorption_unlocked")
			or not bool(_main.call("is_thunder_absorption_unlocked"))
		)
	):
		return false
	return super.is_shortcut_available()


func bind_main(main: Node) -> void:
	super.bind_main(main)
	_sync_absorption_shortcut_visual()


func get_hud_context() -> Dictionary:
	var context := super.get_hud_context()
	context.merge(get_stage25_progress_snapshot(), true)
	return context


func _update_stage25_triggers() -> void:
	if _player == null:
		return
	_try_apply_storm_hazard()
	_try_request_stage25_branch()


# 雷暴只在当前房间首次触碰时结算一次，提供危险反馈而不引入天气状态机。
func _try_apply_storm_hazard() -> void:
	if not storm_hazard_present or _storm_damage_dealt or _relay_grounded:
		return
	var storm_field := get_node_or_null("StormField") as Node2D
	if storm_field == null or _player.global_position.distance_to(storm_field.global_position) > 48.0:
		return

	_storm_damage_dealt = true
	if _player.has_method("receive_damage"):
		_player.call("receive_damage", storm_damage, Vector2.UP)
	_emit_hud_context()


# 风蚀岔口的上层入口继续使用标准房间切换信号。
func _try_request_stage25_branch() -> void:
	if _stage25_branch_requested or branch_room_path.is_empty():
		return
	var branch_zone := get_node_or_null("BranchZone") as Node2D
	if branch_zone == null or _player.global_position.distance_to(branch_zone.global_position) > 48.0:
		return

	_stage25_branch_requested = true
	room_transition_requested.emit(branch_room_path, branch_spawn_id)


# 正确序列接地后同时关闭当前雷暴和出口门，保持机关结果单一可读。
func _on_storm_relay_grounded() -> void:
	if _relay_grounded:
		return
	_relay_grounded = true
	var storm_field := get_node_or_null("StormField") as CanvasItem
	if storm_field != null:
		storm_field.visible = false
	unlock_gate(&"stage25_relay_grounded")
	_set_stage29_animation(^"StormRelay/RelayStateArt", &"relay_grounded")
	_set_stage29_animation(^"GateBarrier/Stage29BarrierArt", &"barrier_open")


# Stage29 仅建立显示层：地形格、逐房地标和前哨 ID 不参与路线或碰撞判定。
func _apply_stage29_presentation() -> void:
	var landmark := get_node_or_null("RoomLandmarkArt") as Sprite2D
	if landmark != null:
		landmark.position = stage29_landmark_position
		landmark.texture = _stage29_atlas_texture(stage29_landmark_index)
		landmark.set_meta(
			"runtime_source",
			"stage29_thunder_waste_environment_runtime_ai01.landmark_%d" % (stage29_landmark_index - 4)
		)

	var outpost := get_node_or_null("OutpostCheckpointArt") as CanvasItem
	if outpost != null:
		outpost.visible = travel_point_id == &"thunder_outpost"

	var ground := get_node_or_null("FormalGroundVisual") as TileMapLayer
	if ground != null:
		ground.clear()
		for cell_x: int in range(18):
			ground.set_cell(Vector2i(cell_x, 0), 0, Vector2i(0, 0))

	var hazard_ground := get_node_or_null("HazardGroundVisual") as TileMapLayer
	if hazard_ground != null:
		hazard_ground.clear()
		if storm_hazard_present:
			for cell_x: int in range(7, 10):
				hazard_ground.set_cell(Vector2i(cell_x, 0), 0, Vector2i(1, 0))
	_sync_absorption_shortcut_visual()


func _sync_absorption_shortcut_visual() -> void:
	var art := get_node_or_null("AbsorptionStormCurtainArt") as AnimatedSprite2D
	if art == null:
		return
	art.visible = shortcut_requires_thunder_absorption
	if not art.visible:
		return
	art.play(&"shortcut_curtain")
	art.pause()
	art.frame = 2 if is_shortcut_available() else 0
	art.set_meta("gameplay_collision", false)
	art.set_meta("damage_source", false)


func _stage29_atlas_texture(index: int) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = STAGE29_ENVIRONMENT_ATLAS
	texture.region = Rect2((index % 4) * 256, floori(index / 4.0) * 256, 256, 256)
	return texture


func _set_stage29_animation(path: NodePath, animation_name: StringName) -> void:
	var art := get_node_or_null(path) as AnimatedSprite2D
	if art == null:
		return
	art.play(animation_name)
	art.set_meta(
		"runtime_source",
		"stage29_thunder_waste_state_vfx_runtime_ai01.%s" % animation_name
	)
