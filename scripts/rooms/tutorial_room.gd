extends Node2D


signal tutorial_step_changed(step_id: StringName, prompt_text: String)
signal hud_context_changed(step_title: String, prompt_text: String)
signal room_transition_requested(target_room_path: String, spawn_id: StringName)

const STEP_MOVE_JUMP: StringName = &"move_jump"
const STEP_DASH: StringName = &"dash"
const STEP_ATTACK: StringName = &"attack"
const STEP_EXIT: StringName = &"exit"
const STEP_COMPLETE: StringName = &"complete"
const COMBAT_TRIAL_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"

const CAMERA_LIMITS := Rect2i(-512, -192, 1536, 384)

const STEP_PROMPTS := {
	STEP_MOVE_JUMP: "按 A/D 或 ←/→ 移动，再按 Space、W 或 ↑ 跳到上方平台。",
	STEP_DASH: "前面是低顶短门槛，按 K 冲刺贴地穿过去。",
	STEP_ATTACK: "靠近训练目标后按 J 攻击，打通出口。",
	STEP_EXIT: "出口已经打开，继续向右前进离开教程区。",
	STEP_COMPLETE: "阶段 5 教程区已完成，可以继续扩展主流程。",
}

const STEP_TITLES := {
	STEP_MOVE_JUMP: "教程 1/4 · 移动与跳跃",
	STEP_DASH: "教程 2/4 · 冲刺穿门",
	STEP_ATTACK: "教程 3/4 · 基础攻击",
	STEP_EXIT: "教程 4/4 · 离开教程区",
	STEP_COMPLETE: "教程完成",
}

const STEP_ORDER := {
	STEP_MOVE_JUMP: 0,
	STEP_DASH: 1,
	STEP_ATTACK: 2,
	STEP_EXIT: 3,
	STEP_COMPLETE: 4,
}

@onready var tutorial_dummy: StaticBody2D = $TutorialDummy
@onready var exit_barrier_shape: CollisionShape2D = $ExitBarrier/CollisionShape2D
@onready var exit_barrier_visual: Polygon2D = $ExitBarrier/BarrierVisual
@onready var exit_zone: Area2D = $ExitZone

var _player: CharacterBody2D
var _current_step: StringName = STEP_MOVE_JUMP
var _exit_unlocked := false
var _transition_requested := false


func _ready() -> void:
	if tutorial_dummy != null and tutorial_dummy.has_signal("hit_registered"):
		tutorial_dummy.connect("hit_registered", Callable(self, "_on_tutorial_dummy_hit_registered"))

	_apply_exit_lock_state()
	_emit_step_changed()


func _process(_delta: float) -> void:
	if _player == null:
		return

	match _current_step:
		STEP_MOVE_JUMP:
			if _player.global_position.x >= -80.0 and _player.global_position.y <= 40.0:
				_set_current_step(STEP_DASH)
		STEP_DASH:
			# 这里改用空间位置判断，避免测试或瞬移校验时过度依赖单帧 floor 状态。
			if _player.global_position.x >= 252.0 and _player.global_position.y >= 80.0:
				_set_current_step(STEP_ATTACK)
		STEP_ATTACK:
			if tutorial_dummy != null and tutorial_dummy.get("hit_count") > 0:
				_unlock_exit_after_attack()
		STEP_EXIT:
			if _exit_unlocked and _player.global_position.x >= exit_zone.global_position.x - 36.0:
				_set_current_step(STEP_COMPLETE)
				_request_combat_trial_transition()


func bind_player(player: CharacterBody2D) -> void:
	_player = player


func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS


func get_current_step_id() -> StringName:
	return _current_step


func get_current_prompt_text() -> String:
	return STEP_PROMPTS.get(_current_step, "")


func get_current_step_title() -> String:
	return STEP_TITLES.get(_current_step, "教程进行中")


func is_exit_unlocked() -> bool:
	return _exit_unlocked


func is_dash_available_in_hud() -> bool:
	return STEP_ORDER.get(_current_step, 0) >= STEP_ORDER[STEP_DASH]


func get_spawn_position(spawn_id: StringName = &"tutorial_start") -> Vector2:
	if spawn_id == &"tutorial_start":
		return Vector2(-320, 96)

	return Vector2(-320, 96)


func _set_current_step(step_id: StringName) -> void:
	if _current_step == step_id:
		return

	_current_step = step_id
	_emit_step_changed()


func _emit_step_changed() -> void:
	tutorial_step_changed.emit(_current_step, get_current_prompt_text())
	hud_context_changed.emit(get_current_step_title(), get_current_prompt_text())


func _apply_exit_lock_state() -> void:
	if exit_barrier_shape != null:
		exit_barrier_shape.disabled = _exit_unlocked

	if exit_barrier_visual != null:
		exit_barrier_visual.color = Color(0.258824, 0.694118, 0.478431, 1.0) if _exit_unlocked else Color(0.776471, 0.321569, 0.262745, 1.0)


func _request_combat_trial_transition() -> void:
	if _transition_requested:
		return

	_transition_requested = true
	room_transition_requested.emit(COMBAT_TRIAL_ROOM_PATH, &"combat_entry")


func _on_tutorial_dummy_hit_registered(_hit_count: int) -> void:
	if _current_step != STEP_ATTACK:
		return

	_unlock_exit_after_attack()


func _unlock_exit_after_attack() -> void:
	_exit_unlocked = true
	_apply_exit_lock_state()
	_set_current_step(STEP_EXIT)
