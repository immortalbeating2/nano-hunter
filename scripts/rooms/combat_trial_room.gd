extends Node2D

# CombatTrialRoom 是阶段 6 的最小真实战斗房。
# 它负责“敌人未清 -> 门锁住；敌人清掉 -> 门打开并推进到目标房”的局部闭环，
# 不负责主线总进度或 checkpoint 记录。


signal room_transition_requested(target_room_path: String, spawn_id: StringName)
signal hud_context_changed(step_title: String, prompt_text: String)

const STEP_COMBAT: StringName = &"combat"
const STEP_CLEAR: StringName = &"clear"
const GOAL_TRIAL_ROOM_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const CAMERA_LIMITS := Rect2i(-320, -192, 960, 384)
const RoomFlowConfig := preload("res://scripts/configs/room_flow_config.gd")

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

@export var flow_config: RoomFlowConfig


# 初始化时先把唯一敌人与出口门控接起来，再同步第一条 HUD 提示。
func _ready() -> void:
	if basic_melee_enemy != null and basic_melee_enemy.has_signal("defeated"):
		basic_melee_enemy.connect("defeated", Callable(self, "_on_basic_melee_enemy_defeated"))

	_apply_exit_lock_state()
	_emit_hud_context()


# 接收 Main 注入的玩家实例，清房后用其位置判断是否进入出口区。
func bind_player(player: CharacterBody2D) -> void:
	_player = player


# 战斗房的运行态逻辑非常单一：只有清房后才允许进入下一个房间。
func _process(_delta: float) -> void:
	if _player == null or not _exit_unlocked or _transition_requested:
		return

	if _player.global_position.x >= $ExitZone.global_position.x - 36.0:
		_transition_requested = true
		room_transition_requested.emit(GOAL_TRIAL_ROOM_PATH, &"goal_entry")


# 返回战斗房相机边界，保证实战区不会暴露灰盒外部。
func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS


# 公开当前步骤，供测试确认战斗房从清敌切换到通行。
func get_current_step_id() -> StringName:
	return _current_step


# 返回当前 HUD 标题，优先读取流程配置。
func get_current_step_title() -> String:
	if flow_config != null:
		return flow_config.get_step_title(_current_step, STEP_TITLES.get(_current_step, "实战进行中"))

	return STEP_TITLES.get(_current_step, "实战进行中")


# 返回当前 HUD 提示，优先读取流程配置。
func get_current_prompt_text() -> String:
	if flow_config != null:
		return flow_config.get_step_prompt(_current_step, STEP_PROMPTS.get(_current_step, ""))

	return STEP_PROMPTS.get(_current_step, "")


# 公开出口门控状态，供测试验证击败敌人后门打开。
func is_exit_unlocked() -> bool:
	return _exit_unlocked


# 战斗房默认始终显示 dash；配置可覆盖该 HUD 可见性。
func is_dash_available_in_hud() -> bool:
	if flow_config != null:
		return flow_config.is_dash_visible(_current_step, true)

	return true


# 返回战斗房出生点，支持首次进入和失败重试复用同一默认点。
func get_spawn_position(spawn_id: StringName = &"combat_entry") -> Vector2:
	if flow_config != null:
		return flow_config.get_spawn_position(spawn_id, SPAWN_POSITIONS[&"combat_entry"])

	return SPAWN_POSITIONS.get(spawn_id, SPAWN_POSITIONS[&"combat_entry"])


# 汇总战斗房 HUD 上下文，供 TutorialHUD 统一翻译显示。
func get_hud_context() -> Dictionary:
	return {
		"step_id": _current_step,
		"step_title": get_current_step_title(),
		"prompt_text": get_current_prompt_text(),
		"dash_available": is_dash_available_in_hud(),
	}


# 战斗房失败后允许 Main 重载当前房间，形成最小重试闭环。
func should_reset_on_player_defeat() -> bool:
	return true


# 清房事件是这个房间唯一的门控解锁来源。
func _on_basic_melee_enemy_defeated() -> void:
	_exit_unlocked = true
	_current_step = STEP_CLEAR
	_apply_exit_lock_state()
	_emit_hud_context()


# 广播当前标题和提示，驱动 HUD 在清房时立即刷新。
func _emit_hud_context() -> void:
	hud_context_changed.emit(get_current_step_title(), get_current_prompt_text())


# 按出口解锁状态同步碰撞和占位颜色。
func _apply_exit_lock_state() -> void:
	if exit_barrier_shape != null:
		exit_barrier_shape.disabled = _exit_unlocked

	if exit_barrier_visual != null:
		exit_barrier_visual.color = Color(0.258824, 0.694118, 0.478431, 1.0) if _exit_unlocked else Color(0.776471, 0.321569, 0.262745, 1.0)
