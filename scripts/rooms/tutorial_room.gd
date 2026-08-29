extends Node2D

# TutorialRoom 负责阶段 5 的单场景教学链路。
# 它只管理教程步骤、提示更新、dash 门槛和离开教程区的最小门控，
# 不负责真实战斗循环或 checkpoint。


signal tutorial_step_changed(step_id: StringName, prompt_text: String)
signal hud_context_changed(step_title: String, prompt_text: String)
signal room_transition_requested(target_room_path: String, spawn_id: StringName)

const STEP_MOVE_JUMP: StringName = &"move_jump"
const STEP_DASH: StringName = &"dash"
const STEP_ATTACK: StringName = &"attack"
const STEP_STANCE: StringName = &"stance"
const STEP_EXIT: StringName = &"exit"
const STEP_COMPLETE: StringName = &"complete"
const COMBAT_TRIAL_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const RoomFlowConfig := preload("res://scripts/configs/room_flow_config.gd")
const GateStateVfx := preload("res://scripts/rooms/gate_state_vfx.gd")
const SEAL_GATE_LOCKED_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/002_shrine_gate_prop_atlas_ai01_auto_003_c01.atlas_texture.tres")
const SEAL_GATE_OPEN_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/003_shrine_gate_prop_atlas_ai01_auto_004_c01.atlas_texture.tres")

const CAMERA_LIMITS := Rect2i(-512, -192, 1536, 384)

const STEP_PROMPTS := {
	STEP_MOVE_JUMP: "A/D 或 ←/→ 移动，Space/W/↑ 跳上平台。",
	STEP_DASH: "按 K 冲刺穿过低顶门槛。",
	STEP_ATTACK: "J 攻击训练目标或红色封印柱，完成攻击训练。",
	STEP_STANCE: "切换一次疾印 / 御印，观察攻守差异。",
	STEP_EXIT: "出口已打开，继续向右离开教程区。",
	STEP_COMPLETE: "阶段 5 教程区已完成，可以继续扩展主流程。",
}

const STEP_TITLES := {
	STEP_MOVE_JUMP: "教程 1/5 · 移动与跳跃",
	STEP_DASH: "教程 2/5 · 冲刺穿门",
	STEP_ATTACK: "教程 3/5 · 基础攻击",
	STEP_STANCE: "教程 4/5 · 疾御换印",
	STEP_EXIT: "教程 5/5 · 离开教程区",
	STEP_COMPLETE: "教程完成",
}

const STEP_ORDER := {
	STEP_MOVE_JUMP: 0,
	STEP_DASH: 1,
	STEP_ATTACK: 2,
	STEP_STANCE: 3,
	STEP_EXIT: 4,
	STEP_COMPLETE: 5,
}

@onready var tutorial_dummy: StaticBody2D = $TutorialDummy
@onready var exit_barrier: StaticBody2D = $ExitBarrier
@onready var exit_barrier_shape: CollisionShape2D = $ExitBarrier/CollisionShape2D
@onready var exit_barrier_visual: Polygon2D = $ExitBarrier/BarrierVisual
@onready var exit_barrier_art: Sprite2D = $ExitBarrier/BarrierArt
@onready var exit_zone: Area2D = $ExitZone

var _player: CharacterBody2D
var _current_step: StringName = STEP_MOVE_JUMP
var _exit_unlocked := false
var _transition_requested := false

@export var flow_config: RoomFlowConfig


# 房间初始化会先把训练目标和出口锁状态接好，再把当前步骤广播给 HUD。
func _ready() -> void:
	if tutorial_dummy != null and tutorial_dummy.has_signal("hit_registered"):
		tutorial_dummy.connect("hit_registered", Callable(self, "_on_tutorial_dummy_hit_registered"))
	if exit_barrier != null and exit_barrier.has_signal("hit_registered"):
		exit_barrier.connect("hit_registered", Callable(self, "_on_exit_barrier_hit_registered"))

	_apply_exit_lock_state()
	_emit_step_changed()


# 教程推进统一走运行时位置和事件判断，这样自动化测试与手动试玩都能读到同一条规则。
func _process(_delta: float) -> void:
	if _player == null:
		return

	match _current_step:
		STEP_MOVE_JUMP:
			if _player.global_position.x >= _get_threshold_float(&"move_jump_goal_x", -80.0) and _player.global_position.y <= _get_threshold_float(&"move_jump_goal_y", 40.0):
				_set_current_step(STEP_DASH)
		STEP_DASH:
			# 这里改用空间位置判断，避免测试或瞬移校验时过度依赖单帧 floor 状态。
			if _player.global_position.x >= _get_threshold_float(&"dash_gate_x", 252.0) and _player.global_position.y >= _get_threshold_float(&"dash_gate_y", 80.0):
				_set_current_step(STEP_ATTACK)
		STEP_ATTACK:
			if tutorial_dummy != null and tutorial_dummy.get("hit_count") > 0:
				_unlock_exit_after_attack()
		STEP_EXIT:
			if _exit_unlocked and _player.global_position.x >= exit_zone.global_position.x - 36.0:
				_set_current_step(STEP_COMPLETE)
				_request_combat_trial_transition()


# 接收 Main 注入的当前玩家实例；重绑定必须先断开旧信号，避免旧玩家延迟事件开门。
func bind_player(player: CharacterBody2D) -> void:
	var stance_callback := Callable(self, "_on_player_stance_changed")
	if _player != null and _player.has_signal("stance_changed") and _player.is_connected("stance_changed", stance_callback):
		_player.disconnect("stance_changed", stance_callback)
	_player = player
	if _player != null and _player.has_signal("stance_changed") and not _player.is_connected("stance_changed", stance_callback):
		_player.connect("stance_changed", stance_callback)


# 回访教程房时读取 Main 已记录的真实向前完成态，避免整套教学被新实例重置后堵住出口。
func bind_main(main: Node) -> void:
	if main != null and main.has_method("is_room_forward_route_completed") and bool(main.call("is_room_forward_route_completed", scene_file_path)):
		_exit_unlocked = true
		_current_step = STEP_EXIT
		_apply_exit_lock_state()
		_emit_step_changed()


# 声明教程房唯一向前目标，供 Main 区分完成推进与其他切房来源。
func get_forward_room_path() -> String:
	return COMBAT_TRIAL_ROOM_PATH


# 返回教程房相机边界，保护首段教学构图。
func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS


# 公开当前教程步骤，供测试和 HUD 快照确认教学推进。
func get_current_step_id() -> StringName:
	return _current_step


# 返回当前步骤提示文本，优先读取配置资源，缺失时使用脚本内默认文案。
func get_current_prompt_text() -> String:
	if flow_config != null:
		return flow_config.get_step_prompt(_current_step, STEP_PROMPTS.get(_current_step, ""))

	return STEP_PROMPTS.get(_current_step, "")


# 返回当前步骤标题，配置缺失时回退到内置标题。
func get_current_step_title() -> String:
	if flow_config != null:
		return flow_config.get_step_title(_current_step, STEP_TITLES.get(_current_step, "教程进行中"))

	return STEP_TITLES.get(_current_step, "教程进行中")


# 公开教程出口是否已解锁，测试用它确认攻击教学门控。
func is_exit_unlocked() -> bool:
	return _exit_unlocked


# 查询 HUD 是否应显示 dash；教程前段会隐藏冲刺能力避免过早提示。
func is_dash_available_in_hud() -> bool:
	if flow_config != null:
		return flow_config.is_dash_visible(_current_step, STEP_ORDER.get(_current_step, 0) >= STEP_ORDER[STEP_DASH])

	return STEP_ORDER.get(_current_step, 0) >= STEP_ORDER[STEP_DASH]


# 对外只暴露房间契约：出生点、步骤标题 / 提示和 HUD 上下文。
func get_spawn_position(spawn_id: StringName = &"tutorial_start") -> Vector2:
	if flow_config != null:
		return flow_config.get_spawn_position(spawn_id, Vector2(-320, 96))

	if spawn_id == &"tutorial_start":
		return Vector2(-320, 96)

	return Vector2(-320, 96)


# 汇总教程房 HUD 上下文，统一提供步骤、标题、提示和 dash 可见性。
func get_hud_context() -> Dictionary:
	return {
		"step_id": _current_step,
		"step_title": get_current_step_title(),
		"prompt_text": get_current_prompt_text(),
		"dash_available": is_dash_available_in_hud(),
	}


# 内部状态切换层：任何步骤推进都必须先改 step，再统一广播给 HUD。
func _set_current_step(step_id: StringName) -> void:
	if _current_step == step_id:
		return

	_current_step = step_id
	_emit_step_changed()


# 广播教程步骤变化，同时兼容旧教程信号和通用 HUD 上下文信号。
func _emit_step_changed() -> void:
	tutorial_step_changed.emit(_current_step, get_current_prompt_text())
	hud_context_changed.emit(get_current_step_title(), get_current_prompt_text())


# 按当前解锁状态同步出口碰撞、旧占位颜色和正式门贴图。
func _apply_exit_lock_state() -> void:
	if exit_barrier_shape != null:
		exit_barrier_shape.disabled = _exit_unlocked

	if exit_barrier_visual != null:
		exit_barrier_visual.color = Color(0.258824, 0.694118, 0.478431, 1.0) if _exit_unlocked else Color(0.776471, 0.321569, 0.262745, 1.0)

	if exit_barrier_art != null:
		exit_barrier_art.texture = SEAL_GATE_OPEN_TEXTURE if _exit_unlocked else SEAL_GATE_LOCKED_TEXTURE
		exit_barrier_art.set_meta("asset_id", "shrine_gate_prop_atlas_ai01")
		exit_barrier_art.set_meta("runtime_source", "shrine_gate_prop_atlas_ai01.seal_gate_open" if _exit_unlocked else "shrine_gate_prop_atlas_ai01.seal_gate_locked")

	GateStateVfx.sync_unlock_feedback(exit_barrier, _exit_unlocked)


# 请求离开教程房进入实战房，使用标记防止同一区域重复触发。
func _request_combat_trial_transition() -> void:
	if _transition_requested:
		return

	_transition_requested = true
	room_transition_requested.emit(COMBAT_TRIAL_ROOM_PATH, &"combat_entry")


# 训练假人命中信号只在攻击教学步骤内解锁出口。
func _on_tutorial_dummy_hit_registered(_hit_count: int) -> void:
	if _current_step != STEP_ATTACK:
		return

	_unlock_exit_after_attack()


# 红色封印柱是玩家眼中的出口目标；攻击教学阶段命中它也必须开门。
func _on_exit_barrier_hit_registered(_hit_count: int) -> void:
	if _current_step != STEP_ATTACK:
		return

	_unlock_exit_after_attack()


# 攻击教学完成后只进入换印步骤；出口继续锁定，等待玩家主动姿态变化。
func _unlock_exit_after_attack() -> void:
	_set_current_step(STEP_STANCE)


# 初始化注入和其他阶段的 stance_changed 都不能跳步，只有姿态教学中的真实变化有效。
func _on_player_stance_changed(_stance_id: StringName) -> void:
	if _current_step != STEP_STANCE:
		return
	_unlock_exit_after_stance_switch()


# 姿态教学完成后由房间统一开门，并推进到最后的离开步骤。
func _unlock_exit_after_stance_switch() -> void:
	_exit_unlocked = true
	_apply_exit_lock_state()
	_set_current_step(STEP_EXIT)


# 从房间流程配置读取阈值；缺失时使用脚本默认值保持旧测试稳定。
func _get_threshold_float(key: StringName, fallback: float) -> float:
	if flow_config == null:
		return fallback

	return float(flow_config.get_threshold(key, fallback))
