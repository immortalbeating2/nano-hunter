extends Node2D

# CombatTrialRoom 是阶段 6 的最小真实战斗房。
# 它负责“敌人未清 -> 妖气结界锁住；敌人清掉 -> 结界消散并直达驿站”的局部闭环，
# 不负责主线总进度或 checkpoint 记录。


signal room_transition_requested(target_room_path: String, spawn_id: StringName)
signal hud_context_changed(step_title: String, prompt_text: String)

const STEP_COMBAT: StringName = &"combat"
const STEP_CLEAR: StringName = &"clear"
const TUTORIAL_ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const WAYSTATION_HUB_ROOM_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const CAMERA_LIMITS := Rect2i(-384, -256, 1920, 512)
const RoomFlowConfig := preload("res://scripts/configs/room_flow_config.gd")
const GateStateVfx := preload("res://scripts/rooms/gate_state_vfx.gd")
const SEAL_GATE_LOCKED_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres")
const SEAL_GATE_OPEN_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/003_shrine_gate_prop_atlas_ai01_auto_004_c01.atlas_texture.tres")

const STEP_TITLES := {
	STEP_COMBAT: "实战 1/1 · 击败敌人",
	STEP_CLEAR: "首次镇妖完成 · 确认悬令",
}

const STEP_PROMPTS := {
	STEP_COMBAT: "前方出现了第一只近战敌人。观察接敌压力，利用冲刺与攻击击败它。",
	STEP_CLEAR: "妖气结界已消散。前往悬令台按 ↓ 确认首赏，再返回镇妖驿站。",
}

const SPAWN_POSITIONS := {
	&"combat_entry": Vector2(-256, 140),
	&"combat_retry": Vector2(-256, 140),
	&"combat_return": Vector2(1408, 108),
}

@onready var basic_melee_enemy: StaticBody2D = $BasicMeleeEnemy
@onready var exit_barrier_shape: CollisionShape2D = $ExitBarrier/CollisionShape2D
@onready var exit_barrier_visual: Polygon2D = $ExitBarrier/BarrierVisual
@onready var exit_barrier_art: Sprite2D = $ExitBarrier/BarrierArt

var _player: CharacterBody2D
var _current_step: StringName = STEP_COMBAT
var _exit_unlocked := false
var _transition_requested := false
var _main: Node

@export var flow_config: RoomFlowConfig
@export var previous_room_path := TUTORIAL_ROOM_PATH
@export var previous_spawn_id: StringName = &"tutorial_return"


# 初始化时先把唯一敌人与出口门控接起来，再同步第一条 HUD 提示。
func _ready() -> void:
	if basic_melee_enemy != null and basic_melee_enemy.has_signal("defeated"):
		basic_melee_enemy.connect("defeated", Callable(self, "_on_basic_melee_enemy_defeated"))

	_apply_exit_lock_state()
	_emit_hud_context()


# 接收 Main 注入的玩家实例，清房后用其位置判断是否进入出口区。
func bind_player(player: CharacterBody2D) -> void:
	_player = player


# 回访实战房时恢复已经完成过的出口，不强迫玩家重复清敌后才能离开旧房间。
func bind_main(main: Node) -> void:
	_main = main
	if main != null and main.has_method("is_room_forward_route_completed") and bool(main.call("is_room_forward_route_completed", scene_file_path)):
		_exit_unlocked = true
		_current_step = STEP_CLEAR
		_apply_exit_lock_state()
		_emit_hud_context()


# 声明实战房唯一向前目标，供 Main 只在真实推进时记录房间完成态。
func get_forward_room_path() -> String:
	return WAYSTATION_HUB_ROOM_PATH


# 战斗房的运行态逻辑非常单一：只有清房后才允许进入下一个房间。
func _process(_delta: float) -> void:
	if _player == null or _transition_requested:
		return

	if _try_request_previous_room():
		return

	if not _exit_unlocked:
		return

	var bounty_board := get_node_or_null("BountyBoardZone") as Node2D
	if bounty_board == null or _player.global_position.distance_to(bounty_board.global_position) > 56.0:
		return
	if not Input.is_action_just_pressed("ui_down"):
		return

	if _main != null and _main.has_method("collect_exploration_reward"):
		_main.call("collect_exploration_reward", &"first_bounty")
	_transition_requested = true
	room_transition_requested.emit(WAYSTATION_HUB_ROOM_PATH, &"stage11_demo_end_start")


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
	var fallback: Vector2 = SPAWN_POSITIONS[&"combat_entry"]
	var configured: Variant = SPAWN_POSITIONS.get(spawn_id, fallback)
	if configured is Vector2:
		fallback = configured

	if flow_config != null:
		return flow_config.get_spawn_position(spawn_id, fallback)

	return fallback


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


# 战斗房是普通房间，允许从左侧回教程房；Boss 锁门不使用这套逻辑。
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


# 广播当前标题和提示，驱动 HUD 在清房时立即刷新。
func _emit_hud_context() -> void:
	hud_context_changed.emit(get_current_step_title(), get_current_prompt_text())


# 按出口解锁状态同步碰撞、旧占位颜色和正式门贴图。
func _apply_exit_lock_state() -> void:
	if exit_barrier_shape != null:
		exit_barrier_shape.disabled = _exit_unlocked

	if exit_barrier_visual != null:
		exit_barrier_visual.color = Color(0.258824, 0.694118, 0.478431, 1.0) if _exit_unlocked else Color(0.776471, 0.321569, 0.262745, 1.0)

	if exit_barrier_art != null:
		exit_barrier_art.texture = SEAL_GATE_OPEN_TEXTURE if _exit_unlocked else SEAL_GATE_LOCKED_TEXTURE
		exit_barrier_art.set_meta("asset_id", "shrine_gate_prop_atlas_ai01")
		exit_barrier_art.set_meta("runtime_source", "shrine_gate_prop_atlas_ai01.seal_gate_open" if _exit_unlocked else "shrine_gate_prop_atlas_ai01.seal_gate_locked")

	GateStateVfx.sync_unlock_feedback(get_node_or_null("ExitBarrier"), _exit_unlocked)
