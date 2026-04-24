extends Node2D

# Stage11DemoEndRoom 负责把前面已验证成立的主线收成“可完成、可反馈、可重开”的最小 demo 终点。
# 它只处理终点触发、终点房 checkpoint 与完成后重开入口，不扩展成剧情系统或正式结算界面。

signal room_transition_requested(target_room_path: String, spawn_id: StringName)
signal hud_context_changed(step_title: String, prompt_text: String)
signal checkpoint_requested(room_path: String, spawn_id: StringName)
signal goal_completed

const CAMERA_LIMITS := Rect2i(-320, -192, 960, 384)
const STEP_FINISH: StringName = &"finish"
const STEP_COMPLETE: StringName = &"complete"
const TUTORIAL_ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const DEMO_END_SPAWN_ID: StringName = &"stage11_demo_end_start"

const STEP_TITLES := {
	STEP_FINISH: "Demo 终点 · 抵达右侧终点",
	STEP_COMPLETE: "Demo 终点 · 已完成",
}

const STEP_PROMPTS := {
	STEP_FINISH: "穿出挑战房后，向右抵达终点光标。完成后可向左走回试玩入口，重新开始一遍。",
	STEP_COMPLETE: "Demo 已完成。向左走回试玩入口，可以从教程房间重新开始。",
}

@onready var replay_zone: Area2D = $ReplayZone
@onready var goal_zone: Area2D = $GoalZone

var _player: CharacterBody2D
var _current_step: StringName = STEP_FINISH
var _goal_finished := false
var _replay_requested := false
var _checkpoint_activated := false


# 终点房一进入就应注册最近的回到点，确保失败后仍在同一个 demo 终点节点内重来。
func _ready() -> void:
	_activate_checkpoint()
	_emit_hud_context()


# 这个房间只有两条运行时逻辑：没完成时向右触发终点，完成后向左触发重开。
func _process(_delta: float) -> void:
	if _player == null:
		return

	if not _goal_finished:
		if _player.global_position.x >= goal_zone.global_position.x - 24.0:
			_complete_demo()
		return

	if _replay_requested:
		return

	if _player.global_position.x <= replay_zone.global_position.x + 24.0:
		_replay_requested = true
		room_transition_requested.emit(TUTORIAL_ROOM_PATH, &"tutorial_start")


func bind_player(player: CharacterBody2D) -> void:
	_player = player


func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS


func get_spawn_position(spawn_id: StringName = DEMO_END_SPAWN_ID) -> Vector2:
	if spawn_id == DEMO_END_SPAWN_ID:
		return Vector2(-128, 96)

	return Vector2(-128, 96)


func get_hud_context() -> Dictionary:
	return {
		"step_id": _current_step,
		"step_title": STEP_TITLES.get(_current_step, "Demo 终点"),
		"prompt_text": STEP_PROMPTS.get(_current_step, ""),
		"dash_available": true,
	}


func should_reset_on_player_defeat() -> bool:
	return true


func _activate_checkpoint() -> void:
	if _checkpoint_activated:
		return

	_checkpoint_activated = true
	checkpoint_requested.emit(scene_file_path, DEMO_END_SPAWN_ID)


func _complete_demo() -> void:
	if _goal_finished:
		return

	_goal_finished = true
	_current_step = STEP_COMPLETE
	_emit_hud_context()
	goal_completed.emit()


func _emit_hud_context() -> void:
	hud_context_changed.emit(
		STEP_TITLES.get(_current_step, "Demo 终点"),
		STEP_PROMPTS.get(_current_step, "")
	)
