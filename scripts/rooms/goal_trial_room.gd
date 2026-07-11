extends Node2D

# GoalTrialRoom 是阶段 7 的第三段短链路目标房。
# 它负责“解除门控 -> 抵达目标点 -> 发出完成信号”的最小终点闭环，
# 不再把失败后重置权交给自己，而是交回 Main 与上游房间链路决定。


signal hud_context_changed(step_title: String, prompt_text: String)
signal goal_completed
signal room_transition_requested(target_room_path: String, spawn_id: StringName)

const STEP_GOAL_GATE: StringName = &"goal_gate"
const STEP_GOAL_REACH: StringName = &"goal_reach"
const STEP_COMPLETE: StringName = &"complete"
const CAMERA_LIMITS := Rect2i(-384, -256, 1280, 512)
const RoomFlowConfig := preload("res://scripts/configs/room_flow_config.gd")
const GateStateVfx := preload("res://scripts/rooms/gate_state_vfx.gd")
const COMBAT_TRIAL_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const STAGE9_ENTRY_ROOM_PATH := "res://scenes/rooms/stage9_zone_entry_room.tscn"
const STAGE9_ENTRY_SPAWN_ID: StringName = &"zone_entry_start"
const SEAL_GATE_LOCKED_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres")
const SEAL_GATE_OPEN_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/003_shrine_gate_prop_atlas_ai01_auto_004_c01.atlas_texture.tres")

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
	&"goal_entry": Vector2(-256, 204),
	&"goal_retry": Vector2(-256, 204),
	&"goal_return": Vector2(704, 124),
}

@onready var basic_melee_enemy: StaticBody2D = $BasicMeleeEnemy
@onready var goal_barrier_shape: CollisionShape2D = $GoalBarrier/CollisionShape2D
@onready var goal_barrier_visual: Polygon2D = $GoalBarrier/BarrierVisual
@onready var goal_barrier_art: Sprite2D = $GoalBarrier/BarrierArt
@onready var goal_zone: Area2D = $GoalZone

var _player: CharacterBody2D
var _current_step: StringName = STEP_GOAL_GATE
var _goal_unlocked := false
var _goal_finished := false
var _transition_requested := false

@export var flow_config: RoomFlowConfig
@export var previous_room_path := COMBAT_TRIAL_ROOM_PATH
@export var previous_spawn_id: StringName = &"combat_return"


# 初始化先接守门敌人的 defeated 信号，再把当前门控状态同步给 HUD。
func _ready() -> void:
	if basic_melee_enemy != null and basic_melee_enemy.has_signal("defeated"):
		basic_melee_enemy.connect("defeated", Callable(self, "_on_basic_melee_enemy_defeated"))

	_apply_goal_lock_state()
	_emit_hud_context()


# 目标房只关心“门是否已开”和“玩家是否真正到达终点区”。
func _process(_delta: float) -> void:
	if _player == null or _transition_requested:
		return

	if _try_request_previous_room():
		return

	if not _goal_unlocked or _goal_finished:
		return

	if _player.global_position.distance_to(goal_zone.global_position) <= 48.0:
		_complete_goal()


# 接收 Main 注入的玩家实例，目标完成判定只读取其位置。
func bind_player(player: CharacterBody2D) -> void:
	_player = player


# 返回目标房相机边界，保护短链路终点构图。
func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS


# 公开当前目标步骤，供自动化确认门控与终点推进。
func get_current_step_id() -> StringName:
	return _current_step


# 返回目标房 HUD 标题，优先读取配置资源。
func get_current_step_title() -> String:
	if flow_config != null:
		return flow_config.get_step_title(_current_step, STEP_TITLES.get(_current_step, "目标推进中"))

	return STEP_TITLES.get(_current_step, "目标推进中")


# 返回目标房 HUD 提示，优先读取配置资源。
func get_current_prompt_text() -> String:
	if flow_config != null:
		return flow_config.get_step_prompt(_current_step, STEP_PROMPTS.get(_current_step, ""))

	return STEP_PROMPTS.get(_current_step, "")


# 返回目标房出生点，支持首次进入和失败后回到上游时的稳定读值。
func get_spawn_position(spawn_id: StringName = &"goal_entry") -> Vector2:
	var fallback: Vector2 = SPAWN_POSITIONS[&"goal_entry"]
	var configured: Variant = SPAWN_POSITIONS.get(spawn_id, fallback)
	if configured is Vector2:
		fallback = configured

	if flow_config != null:
		return flow_config.get_spawn_position(spawn_id, fallback)

	return fallback


# 目标房失败不自重置，交由 Main 和上游 checkpoint 策略处理。
func should_reset_on_player_defeat() -> bool:
	return false


# 目标房默认显示 dash，配置资源可按步骤覆盖。
func is_dash_available_in_hud() -> bool:
	if flow_config != null:
		return flow_config.is_dash_visible(_current_step, true)

	return true


# 公开目标门控是否已解除，供测试保护守门敌清除逻辑。
func is_goal_unlocked() -> bool:
	return _goal_unlocked


# 汇总目标房 HUD 上下文，统一暴露步骤、标题、提示和 dash 状态。
func get_hud_context() -> Dictionary:
	return {
		"step_id": _current_step,
		"step_title": get_current_step_title(),
		"prompt_text": get_current_prompt_text(),
		"dash_available": is_dash_available_in_hud(),
	}


# 清掉守门敌人后，目标房从“解除门控”切到“抵达终点”。
func _on_basic_melee_enemy_defeated() -> void:
	_goal_unlocked = true
	_current_step = STEP_GOAL_REACH
	_apply_goal_lock_state()
	_emit_hud_context()


# 完成短链路目标，并把主线推进到 Stage9 入口房。
func _complete_goal() -> void:
	if _goal_finished or _transition_requested:
		return

	_goal_finished = true
	_transition_requested = true
	_current_step = STEP_COMPLETE
	_emit_hud_context()
	goal_completed.emit()
	room_transition_requested.emit(STAGE9_ENTRY_ROOM_PATH, STAGE9_ENTRY_SPAWN_ID)


# 目标房不是 Boss 锁门房，玩家应能从左侧回到战斗房复查路线。
func _try_request_previous_room() -> bool:
	if previous_room_path.is_empty():
		return false

	var left_exit_zone := get_node_or_null("LeftExitZone") as Node2D
	if left_exit_zone == null:
		return false

	if _player.global_position.x > left_exit_zone.global_position.x + 36.0:
		return false

	_transition_requested = true
	room_transition_requested.emit(previous_room_path, previous_spawn_id)
	return true


# 广播当前目标房 HUD 文案，供 TutorialHUD 立即刷新。
func _emit_hud_context() -> void:
	hud_context_changed.emit(get_current_step_title(), get_current_prompt_text())


# 按当前目标解锁状态同步终点门控碰撞、旧占位颜色和正式门贴图。
func _apply_goal_lock_state() -> void:
	if goal_barrier_shape != null:
		goal_barrier_shape.disabled = _goal_unlocked

	if goal_barrier_visual != null:
		goal_barrier_visual.color = Color(0.258824, 0.694118, 0.478431, 1.0) if _goal_unlocked else Color(0.776471, 0.321569, 0.262745, 1.0)

	if goal_barrier_art != null:
		goal_barrier_art.texture = SEAL_GATE_OPEN_TEXTURE if _goal_unlocked else SEAL_GATE_LOCKED_TEXTURE
		goal_barrier_art.set_meta("asset_id", "shrine_gate_prop_atlas_ai01")
		goal_barrier_art.set_meta("runtime_source", "shrine_gate_prop_atlas_ai01.seal_gate_open" if _goal_unlocked else "shrine_gate_prop_atlas_ai01.seal_gate_locked")

	GateStateVfx.sync_unlock_feedback(get_node_or_null("GoalBarrier"), _goal_unlocked)
