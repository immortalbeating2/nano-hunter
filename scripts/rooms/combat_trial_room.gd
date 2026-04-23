extends Node2D


signal room_transition_requested(target_room_path: String, spawn_id: StringName)
signal hud_context_changed(step_title: String, prompt_text: String)

const STEP_COMBAT: StringName = &"combat"
const STEP_CLEAR: StringName = &"clear"
const GOAL_TRIAL_ROOM_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const CAMERA_LIMITS := Rect2i(-320, -192, 960, 384)

const STEP_TITLES := {
	STEP_COMBAT: "实战 1/1 · 击败敌人",
	STEP_CLEAR: "实战完成 · 前往目标房",
}

const STEP_PROMPTS := {
	STEP_COMBAT: "前方出现了第一只近战敌人。观察接敌压力，利用冲刺与攻击击败它。",
	STEP_CLEAR: "敌人已被击败，出口打开了。继续向右前进，进入目标房完成这条短链路。",
}

const SPAWN_POSITIONS := {
	&"combat_entry": Vector2(-64, 120),
	&"combat_retry": Vector2(-64, 120),
}

@onready var basic_melee_enemy: StaticBody2D = $BasicMeleeEnemy
@onready var exit_barrier_shape: CollisionShape2D = $ExitBarrier/CollisionShape2D
@onready var exit_barrier_visual: Polygon2D = $ExitBarrier/BarrierVisual

var _player: CharacterBody2D
var _current_step: StringName = STEP_COMBAT
var _exit_unlocked := false
var _transition_requested := false


func _ready() -> void:
	if basic_melee_enemy != null and basic_melee_enemy.has_signal("defeated"):
		basic_melee_enemy.connect("defeated", Callable(self, "_on_basic_melee_enemy_defeated"))

	_apply_exit_lock_state()
	_emit_hud_context()


func bind_player(player: CharacterBody2D) -> void:
	_player = player


func _process(_delta: float) -> void:
	if _player == null or not _exit_unlocked or _transition_requested:
		return

	if _player.global_position.x >= $ExitZone.global_position.x - 36.0:
		_transition_requested = true
		room_transition_requested.emit(GOAL_TRIAL_ROOM_PATH, &"goal_entry")


func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS


func get_current_step_id() -> StringName:
	return _current_step


func get_current_step_title() -> String:
	return STEP_TITLES.get(_current_step, "实战进行中")


func get_current_prompt_text() -> String:
	return STEP_PROMPTS.get(_current_step, "")


func is_exit_unlocked() -> bool:
	return _exit_unlocked


func is_dash_available_in_hud() -> bool:
	return true


func get_spawn_position(spawn_id: StringName = &"combat_entry") -> Vector2:
	return SPAWN_POSITIONS.get(spawn_id, SPAWN_POSITIONS[&"combat_entry"])


func should_reset_on_player_defeat() -> bool:
	return true


func _on_basic_melee_enemy_defeated() -> void:
	_exit_unlocked = true
	_current_step = STEP_CLEAR
	_apply_exit_lock_state()
	_emit_hud_context()


func _emit_hud_context() -> void:
	hud_context_changed.emit(get_current_step_title(), get_current_prompt_text())


func _apply_exit_lock_state() -> void:
	if exit_barrier_shape != null:
		exit_barrier_shape.disabled = _exit_unlocked

	if exit_barrier_visual != null:
		exit_barrier_visual.color = Color(0.258824, 0.694118, 0.478431, 1.0) if _exit_unlocked else Color(0.776471, 0.321569, 0.262745, 1.0)
