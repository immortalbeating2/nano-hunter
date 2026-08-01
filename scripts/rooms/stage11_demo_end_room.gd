extends Node2D

# Stage11DemoEndRoom 保留历史场景句柄，但运行职责已改为连接 Stage10、Stage13 与 Stage25 的镇妖驿厅。
# 它只处理封印回响确认、悬赏榜、路引入口、checkpoint 和区域出口，不再提前结束完整 Demo。

signal room_transition_requested(target_room_path: String, spawn_id: StringName)
signal hud_context_changed(step_title: String, prompt_text: String)
signal checkpoint_requested(room_path: String, spawn_id: StringName)
signal goal_completed
signal bounty_board_requested

const CAMERA_LIMITS := Rect2i(-384, -256, 1152, 512)
const STEP_FINISH: StringName = &"finish"
const STEP_COMPLETE: StringName = &"complete"
const STAGE10_CHALLENGE_ROOM_PATH := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const STAGE13_ENTRY_ROOM_PATH := "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn"
const STAGE25_ENTRY_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_entry_room.tscn"
const DEMO_END_SPAWN_ID: StringName = &"stage11_demo_end_start"
const WAYSTATION_WORLD_ATLAS: Texture2D = preload(
	"res://assets/art/environment/waystation/stage28_waystation_world_runtime_ai01.png"
)
const BOARD_VISUAL_INDEX := {
	&"available": 0,
	&"accepted": 1,
	&"completed": 2,
	&"turned_in": 3,
}

const STEP_TITLES := {
	STEP_FINISH: "镇妖驿厅 · 确认封印回响",
	STEP_COMPLETE: "镇妖驿厅 · 双向通路已确认",
}

const STEP_PROMPTS := {
	STEP_FINISH: "触碰中央封印标记，确认镇妖驿厅与瘴泽通路。",
	STEP_COMPLETE: "通路已确认：向左返回镇妖试炼，向右进入瘴泽妖域。",
}

@onready var replay_zone: Area2D = $ReplayZone
@onready var bounty_board_zone: Area2D = $BountyBoardZone
@onready var thunder_route_zone: Area2D = $ThunderRouteZone
@onready var goal_zone: Area2D = $GoalZone
@onready var continue_zone: Area2D = $ContinueZone

var _player: CharacterBody2D
var _main: Node
var _current_step: StringName = STEP_FINISH
var _goal_finished := false
var _replay_requested := false
var _continue_requested := false
var _checkpoint_activated := false
var _bounty_board_near := false
var _thunder_route_requested := false
var _displayed_board_state: StringName = &""
var _displayed_route_open := false
var _route_marker_initialized := false


# 驿厅一进入就注册最近恢复点，确保失败后仍从安全位置重来。
func _ready() -> void:
	_activate_checkpoint()
	_emit_hud_context()


# 未确认封印回响前锁住出口；确认后开放左返 Stage10、右进 Stage13。
func _process(_delta: float) -> void:
	if _player == null:
		return

	_update_bounty_board()
	_refresh_thunder_route_marker()

	if not _goal_finished:
		# 未完成前先确认中央封印标记，避免玩家绕过本房 checkpoint 与 HUD 状态。
		if _player.global_position.x >= goal_zone.global_position.x - 24.0:
			_complete_demo()
		return

	if _replay_requested:
		return

	if _try_request_thunder_waste():
		return

	if _player.global_position.x <= replay_zone.global_position.x + 24.0:
		# 左侧历史 ReplayZone 复用为 Stage10 返回口，节点名保持兼容但不再执行重开。
		_replay_requested = true
		room_transition_requested.emit(STAGE10_CHALLENGE_ROOM_PATH, &"stage10_challenge_return")
		return

	if _continue_requested:
		return

	if _player.global_position.x >= continue_zone.global_position.x - 24.0:
		# 右侧继续进入瘴泽主线；完整 Demo 完成态仍只属于 Stage16。
		_continue_requested = true
		room_transition_requested.emit(STAGE13_ENTRY_ROOM_PATH, &"stage13_entry_start")


# 接收 Main 注入的玩家实例，用于封印标记与左右出口的位置判定。
func bind_player(player: CharacterBody2D) -> void:
	_player = player


# Main 只提供悬赏快照；驿厅不保存或修改路引状态。
func bind_main(main: Node) -> void:
	_main = main
	_refresh_thunder_route_marker()
	_emit_hud_context()


# 返回驿厅相机边界，保证中央标记和左右出口都在可见范围。
func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS


# 返回终点房出生点；当前只有一个稳定起点。
func get_spawn_position(spawn_id: StringName = DEMO_END_SPAWN_ID) -> Vector2:
	if spawn_id == DEMO_END_SPAWN_ID:
		return Vector2(-128, 204)
	if spawn_id == &"stage11_demo_end_return":
		return Vector2(560, 204)
	if spawn_id == &"stage11_thunder_waste_return":
		return Vector2(240, 204)

	return Vector2(-128, 204)


# 汇总驿厅 HUD 上下文，展示封印确认前后的路线提示。
func get_hud_context() -> Dictionary:
	return {
		"step_id": _current_step,
		"step_title": STEP_TITLES.get(_current_step, "镇妖驿厅"),
		"prompt_text": _get_prompt_text(),
		"dash_available": true,
		"bounty_board_present": true,
		"thunder_waste_route_unlocked": is_thunder_waste_route_unlocked(),
	}


# 驿厅失败允许 Main 回到本房 checkpoint。
func should_reset_on_player_defeat() -> bool:
	return true


# 保留历史读值接口，表示本房封印回响是否已确认。
func is_demo_goal_finished() -> bool:
	return _goal_finished


# 三条悬赏全部回交后，Stage23 的路引奖励才真正开放 Stage25 入口。
func is_thunder_waste_route_unlocked() -> bool:
	if _main == null or not _main.has_method("get_bounty_board_snapshot"):
		return false
	var snapshot: Dictionary = _main.call("get_bounty_board_snapshot")
	return bool(snapshot.get("waystation_intel_unlocked", false))


# 激活驿厅 checkpoint，只触发一次，避免重复覆盖 Main 恢复点。
func _activate_checkpoint() -> void:
	if _checkpoint_activated:
		return

	_checkpoint_activated = true
	checkpoint_requested.emit(scene_file_path, DEMO_END_SPAWN_ID)


# 玩家首次靠近榜牌时打开榜单，离开后才允许再次触发。
func _update_bounty_board() -> void:
	var is_near := _player.global_position.distance_to(bounty_board_zone.global_position) <= 56.0
	if is_near and not _bounty_board_near:
		_bounty_board_near = true
		bounty_board_requested.emit()
	elif not is_near:
		_bounty_board_near = false


# 雷泽入口只在封印回响已确认且路引齐备时响应，并继续走标准切房信号。
func _try_request_thunder_waste() -> bool:
	if _thunder_route_requested or not is_thunder_waste_route_unlocked():
		return false
	if _player.global_position.distance_to(thunder_route_zone.global_position) > 56.0:
		return false

	_thunder_route_requested = true
	room_transition_requested.emit(STAGE25_ENTRY_ROOM_PATH, &"stage25_entry_start")
	return true


# 榜牌与雷泽入口只读取 Main 快照并替换图集区域，不参与任务或门控写入。
func _refresh_thunder_route_marker() -> void:
	var snapshot: Dictionary = {}
	if _main != null and _main.has_method("get_bounty_board_snapshot"):
		snapshot = _main.call("get_bounty_board_snapshot")

	var board_state := _get_board_visual_state(snapshot)
	var board_marker := bounty_board_zone.get_node_or_null("BountyBoardMarkerArt") as Sprite2D
	if board_marker != null and board_state != _displayed_board_state:
		_displayed_board_state = board_state
		board_marker.texture = _atlas_texture(int(BOARD_VISUAL_INDEX.get(board_state, 0)))
		board_marker.set_meta("runtime_source", "stage28_waystation_world_runtime_ai01.bounty_%s" % board_state)

	var route_open := bool(snapshot.get("waystation_intel_unlocked", false))
	var route_marker := thunder_route_zone.get_node_or_null("ThunderRouteMarkerArt") as Sprite2D
	if route_marker != null and (not _route_marker_initialized or route_open != _displayed_route_open):
		_route_marker_initialized = true
		_displayed_route_open = route_open
		route_marker.texture = _atlas_texture(11 if route_open else 10)
		route_marker.modulate = Color.WHITE
		route_marker.set_meta(
			"runtime_source",
			"stage28_waystation_world_runtime_ai01.route_open" if route_open else "stage28_waystation_world_runtime_ai01.route_locked"
		)


func _get_board_visual_state(snapshot: Dictionary) -> StringName:
	if int(snapshot.get("turned_in_count", 0)) >= 3:
		return &"turned_in"
	if int(snapshot.get("completed_count", 0)) > int(snapshot.get("turned_in_count", 0)):
		return &"completed"
	if int(snapshot.get("accepted_count", 0)) > 0:
		return &"accepted"
	return &"available"


func _atlas_texture(index: int) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = WAYSTATION_WORLD_ATLAS
	texture.region = Rect2((index % 4) * 256, (index / 4) * 256, 256, 256)
	return texture


func _get_prompt_text() -> String:
	if _goal_finished and is_thunder_waste_route_unlocked():
		return "路引已齐：蓝色雷印通往雷泽荒原；左右旧路仍可往返。"
	return STEP_PROMPTS.get(_current_step, "")


# 确认驿厅封印回响，只触发一次 HUD 更新和 goal_completed 信号。
func _complete_demo() -> void:
	# 确认态只发一次，避免玩家停在 GoalZone 内时重复改 HUD 和重复发信号。
	if _goal_finished:
		return

	_goal_finished = true
	_current_step = STEP_COMPLETE
	_emit_hud_context()
	goal_completed.emit()


# 广播驿厅当前 HUD 文案，供确认状态切换后立即刷新。
func _emit_hud_context() -> void:
	hud_context_changed.emit(
		STEP_TITLES.get(_current_step, "镇妖驿厅"),
		_get_prompt_text()
	)
