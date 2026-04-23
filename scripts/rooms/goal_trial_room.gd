extends Node2D


signal hud_context_changed(step_title: String, prompt_text: String)
signal goal_completed

const STEP_GOAL_GATE: StringName = &"goal_gate"
const STEP_GOAL_REACH: StringName = &"goal_reach"
const STEP_COMPLETE: StringName = &"complete"
const CAMERA_LIMITS := Rect2i(-320, -192, 960, 384)

const STEP_TITLES := {
	STEP_GOAL_GATE: "目标 1/2 · 解除门控",
	STEP_GOAL_REACH: "目标 2/2 · 抵达目标点",
	STEP_COMPLETE: "短链路完成",
}

const STEP_PROMPTS := {
	STEP_GOAL_GATE: "击败守在前方的敌人，解除目标门控，再继续向右推进。",
	STEP_GOAL_REACH: "门控已解除，利用跳跃与冲刺抵达右侧目标点，完成这条短链路。",
	STEP_COMPLETE: "目标已达成，阶段 7 的三段短链路已经成立。",
}

const SPAWN_POSITIONS := {
	&"goal_entry": Vector2(-96, 120),
	&"goal_retry": Vector2(-96, 120),
}

@onready var basic_melee_enemy: StaticBody2D = $BasicMeleeEnemy
@onready var goal_barrier_shape: CollisionShape2D = $GoalBarrier/CollisionShape2D
@onready var goal_barrier_visual: Polygon2D = $GoalBarrier/BarrierVisual
@onready var goal_zone: Area2D = $GoalZone

var _player: CharacterBody2D
var _current_step: StringName = STEP_GOAL_GATE
var _goal_unlocked := false
var _goal_finished := false


func _ready() -> void:
	if basic_melee_enemy != null and basic_melee_enemy.has_signal("defeated"):
		basic_melee_enemy.connect("defeated", Callable(self, "_on_basic_melee_enemy_defeated"))

	_apply_goal_lock_state()
	_emit_hud_context()


func _process(_delta: float) -> void:
	if _player == null or not _goal_unlocked or _goal_finished:
		return

	if _player.global_position.x >= goal_zone.global_position.x - 24.0:
		_complete_goal()


func bind_player(player: CharacterBody2D) -> void:
	_player = player


func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS


func get_current_step_id() -> StringName:
	return _current_step


func get_current_step_title() -> String:
	return STEP_TITLES.get(_current_step, "目标推进中")


func get_current_prompt_text() -> String:
	return STEP_PROMPTS.get(_current_step, "")


func get_spawn_position(spawn_id: StringName = &"goal_entry") -> Vector2:
	return SPAWN_POSITIONS.get(spawn_id, SPAWN_POSITIONS[&"goal_entry"])


func should_reset_on_player_defeat() -> bool:
	return false


func is_dash_available_in_hud() -> bool:
	return true


func is_goal_unlocked() -> bool:
	return _goal_unlocked


func _on_basic_melee_enemy_defeated() -> void:
	_goal_unlocked = true
	_current_step = STEP_GOAL_REACH
	_apply_goal_lock_state()
	_emit_hud_context()


func _complete_goal() -> void:
	if _goal_finished:
		return

	_goal_finished = true
	_current_step = STEP_COMPLETE
	_emit_hud_context()
	goal_completed.emit()


func _emit_hud_context() -> void:
	hud_context_changed.emit(get_current_step_title(), get_current_prompt_text())


func _apply_goal_lock_state() -> void:
	if goal_barrier_shape != null:
		goal_barrier_shape.disabled = _goal_unlocked

	if goal_barrier_visual != null:
		goal_barrier_visual.color = Color(0.258824, 0.694118, 0.478431, 1.0) if _goal_unlocked else Color(0.776471, 0.321569, 0.262745, 1.0)
