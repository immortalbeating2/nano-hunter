extends Node2D

# Main 负责把当前阶段的房间链路串成真正可玩的主入口。
# 它只管理房间切换、出生点解析、checkpoint 恢复，以及 Room / Player / HUD 的绑定，
# 不负责单个房间内部的教学、战斗或门控细节。

const BASE_VIEWPORT_SIZE := Vector2i(640, 360)
const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")
const TUTORIAL_ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
const COMBAT_TRIAL_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
const GOAL_TRIAL_ROOM_PATH := "res://scenes/rooms/goal_trial_room.tscn"
const STAGE10_BRANCH_ROOM_PATH := "res://scenes/rooms/stage10_zone_branch_room.tscn"
const STAGE10_CHALLENGE_ROOM_PATH := "res://scenes/rooms/stage10_zone_challenge_room.tscn"
const STAGE11_DEMO_END_ROOM_PATH := "res://scenes/rooms/stage11_demo_end_room.tscn"
const STAGE13_ROOM_PREFIX := "res://scenes/rooms/stage13_"
const STAGE14_ROOM_PREFIX := "res://scenes/rooms/stage14_"
const STAGE15_ROOM_PREFIX := "res://scenes/rooms/stage15_"
const STAGE15_COMPLETION_ROOM_PATH := "res://scenes/rooms/stage15_completion_room.tscn"
const STAGE16_ROOM_PREFIX := "res://scenes/rooms/stage16_"
const STAGE16_ALPHA_DEMO_END_ROOM_PATH := "res://scenes/rooms/stage16_alpha_demo_end_room.tscn"
const STAGE25_ROOM_PREFIX := "res://scenes/rooms/stage25_"
const FALL_RESET_MARGIN := 96.0
const WIND_SEAL_REWARD_ID: StringName = &"wind_seal"
const ELEMENT_WIND: StringName = &"wind"
const ELEMENT_THUNDER: StringName = &"thunder"
const STANCE_SWIFT: StringName = &"swift"
const STANCE_WARD: StringName = &"ward"
const BUILD_MARSH_RELIC: StringName = &"marsh_relic"
const BUILD_WARDEN_SIGIL: StringName = &"warden_sigil"
const BUILD_CASTER_CORE: StringName = &"caster_core"
const BUILD_GUARDIAN_CORE: StringName = &"guardian_core"
const BUILD_SLOT_LIMIT := 2
const BUILD_REWARD_IDS: Array[StringName] = [
	BUILD_MARSH_RELIC,
	BUILD_WARDEN_SIGIL,
	BUILD_CASTER_CORE,
	BUILD_GUARDIAN_CORE,
]
const BUILD_DEFINITIONS := {
	BUILD_MARSH_RELIC: {
		"label": "瘴泽遗物",
		"effect": "恢复充能获取 x1.5",
		"source": "瘴泽资源支路",
	},
	BUILD_WARDEN_SIGIL: {
		"label": "镇妖挑战符",
		"effect": "横向攻击距离 +16px",
		"source": "瘴泽挑战支路",
	},
	BUILD_CASTER_CORE: {
		"label": "腐瘴法珠",
		"effect": "元素序列窗口 +0.75s",
		"source": "断瘴缉术回交",
	},
	BUILD_GUARDIAN_CORE: {
		"label": "守印金刚心",
		"effect": "姿态切换冷却 -0.15s",
		"source": "封印守卫",
	},
}
const MIASMA_CASTER_SCRIPT_PATH := "res://scripts/combat/miasma_caster_enemy.gd"
const BOUNTY_CASTER_HUNT: StringName = &"caster_hunt"
const BOUNTY_DEMON_BONE_EVIDENCE: StringName = &"demon_bone_evidence"
const BOUNTY_SEAL_PULSE_CLEANUP: StringName = &"seal_pulse_cleanup"
const BOUNTY_IDS: Array[StringName] = [
	BOUNTY_CASTER_HUNT,
	BOUNTY_DEMON_BONE_EVIDENCE,
	BOUNTY_SEAL_PULSE_CLEANUP,
]
const BOUNTY_DEFINITIONS := {
	BOUNTY_CASTER_HUNT: {
		"title": "断瘴缉术",
		"objective": "击败一名腐瘴法师",
		"reward": "瘴泽术式记录",
	},
	BOUNTY_DEMON_BONE_EVIDENCE: {
		"title": "妖骨取证",
		"objective": "回收瘴泽妖骨证物",
		"reward": "妖骨案卷",
	},
	BOUNTY_SEAL_PULSE_CLEANUP: {
		"title": "封脉清障",
		"objective": "用雷风序列散去封印脉冲",
		"reward": "雷泽荒原路引",
	},
}
const STAGE11_STORY_EVENT_ID: StringName = &"stage11_hidden_dispatch"
const STAGE11_STORY_EVENT_TITLE := "镇妖驿厅 · 密令残页"
const STAGE11_STORY_EVENT_BODY := "镇妖卫驿卒：瘴泽封印并非天灾，是郡守私运妖骨后崩裂。\n\nLuna：悬赏只写“清除妖患”，没有百姓名册。\n\n陌生妖声：你闻得到他们留下的血。因为你与我同源。"

# 默认输入绑定由 Main 兜底创建，保证独立运行测试或新机器启动时输入契约完整。
const INPUT_BINDINGS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_SPACE, KEY_W, KEY_UP],
	"attack": [KEY_J],
	"dash": [KEY_K],
	"recover": [KEY_L],
	"element_switch": [KEY_Q],
	"stance_switch": [KEY_E],
	"pause": [KEY_ESCAPE],
}

# 主场景固定节点缓存：Runtime 承载当前玩家，Room 承载当前房间，HUD 只消费快照。
@onready var runtime: Node2D = $Runtime
@onready var fallback_player_spawn: Marker2D = $PlayerSpawn
@onready var tutorial_hud: Control = $HUD/TutorialHUD
@onready var demo_shell: Control = $HUD/DemoShell

# Main 持有跨房间运行期状态；单房间内部状态仍由各房间脚本自己维护。
var room: Node2D
var _current_room_path := TUTORIAL_ROOM_PATH
var _current_spawn_id: StringName = &"tutorial_start"
var _checkpoint_room_path := ""
var _checkpoint_spawn_id: StringName = &""
var _is_short_chain_completed := false
var _is_demo_completed := false
var _air_dash_unlocked := false
var _wind_seal_unlocked := false
var _current_element_id: StringName = ELEMENT_THUNDER
var _current_stance_id: StringName = STANCE_SWIFT
var _stage14_backtrack_reward_ids: Dictionary = {}
var _exploration_reward_ids: Dictionary = {}
var _accepted_bounty_ids: Dictionary = {}
var _completed_bounty_ids: Dictionary = {}
var _turned_in_bounty_ids: Dictionary = {}
var _active_build_id: StringName = &""
var _equipped_build_ids: Array[StringName] = []
var _completed_story_event_ids: Dictionary = {}
var _visited_room_paths: Dictionary = {}
var _stage15_boss_defeated := false
var _stage16_alpha_demo_completed := false
var _stage16_release_notes_ready := true
var _stage16_qa_checklist_ready := true


# 主入口初始化只做一次：窗口基线、默认输入契约和首房间加载。
func _ready() -> void:
	_configure_window_defaults()
	if not get_viewport().size_changed.is_connected(_update_runtime_camera_zoom):
		get_viewport().size_changed.connect(_update_runtime_camera_zoom)
	_ensure_default_input_bindings()
	room = get_node_or_null("Room") as Node2D
	if demo_shell != null and demo_shell.has_method("bind_main"):
		demo_shell.call("bind_main", self)
	_change_room(TUTORIAL_ROOM_PATH, &"tutorial_start")


# 主流程每帧只做跨房间安全检查；房间内教学、战斗和门控仍由房间脚本负责。
func _process(_delta: float) -> void:
	_check_player_fall_out_of_bounds()


# 固定窗口最小尺寸，保证灰盒 HUD 与房间构图在桌面运行时不被压得不可读。
func _configure_window_defaults() -> void:
	get_window().min_size = BASE_VIEWPORT_SIZE


# 创建缺失的默认输入动作，保护新机器、测试入口和导入缓存清理后的启动体验。
func _ensure_default_input_bindings() -> void:
	for action_name in INPUT_BINDINGS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		if not InputMap.action_get_events(action_name).is_empty():
			continue

		for keycode: Key in INPUT_BINDINGS[action_name]:
			var event := InputEventKey.new()
			event.keycode = keycode
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name, event)


# 运行时实例装配：每次换房后都重新生成玩家，并把房间和 HUD 绑定到同一份运行时对象上。
func _spawn_placeholder_player(spawn_id: StringName) -> void:
	_clear_runtime()

	var player: CharacterBody2D = PLAYER_PLACEHOLDER_SCENE.instantiate() as CharacterBody2D
	if player == null:
		return

	player.position = _resolve_spawn_position(spawn_id)
	runtime.add_child(player)
	if player.has_signal("defeated"):
		player.defeated.connect(_on_player_defeated)
	_apply_room_camera_limits(player)
	_bind_runtime_dependencies(player)


# 根据当前房间声明的相机边界限制玩家相机，避免换房后看见灰盒外部空间。
func _apply_room_camera_limits(player: CharacterBody2D) -> void:
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return

	if room == null or not room.has_method("get_camera_limits"):
		return

	var camera_limits: Rect2i = room.call("get_camera_limits")
	var room_world_offset := Vector2i(room.global_position.round())
	var world_camera_limits := Rect2i(camera_limits.position + room_world_offset, camera_limits.size)

	camera.limit_enabled = true
	camera.limit_left = world_camera_limits.position.x
	camera.limit_top = world_camera_limits.position.y
	camera.limit_right = world_camera_limits.end.x
	camera.limit_bottom = world_camera_limits.end.y
	_apply_camera_zoom(camera)


# 正式 Demo 仍按 640x360 设计房间构图；高分屏只放大相机，不额外暴露未清稿背景。
func _apply_camera_zoom(camera: Camera2D) -> void:
	var viewport_size := Vector2(get_tree().root.size)
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = get_viewport_rect().size
	var scale_x := viewport_size.x / float(BASE_VIEWPORT_SIZE.x)
	var scale_y := viewport_size.y / float(BASE_VIEWPORT_SIZE.y)
	var scale_value: float = maxf(1.0, minf(scale_x, scale_y))
	camera.zoom = Vector2(scale_value, scale_value)


# ponytail: 单玩家主入口直接更新当前 Camera2D；多玩家或分屏时再抽专门相机管理。
func _update_runtime_camera_zoom() -> void:
	var player := _get_runtime_player()
	if player == null:
		return

	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return

	_apply_camera_zoom(camera)


# 把跨房间状态注入新玩家，并把当前 Room / Player / Main 三方重新挂到 HUD。
func _bind_runtime_dependencies(player: CharacterBody2D) -> void:
	if player.has_method("set_air_dash_unlocked"):
		player.call("set_air_dash_unlocked", _air_dash_unlocked)
	if player.has_method("set_wind_seal_unlocked"):
		player.call("set_wind_seal_unlocked", _wind_seal_unlocked)
	if player.has_method("set_current_element_id"):
		player.call("set_current_element_id", _current_element_id)
	if player.has_method("set_current_stance_id"):
		player.call("set_current_stance_id", _current_stance_id)
	if player.has_method("set_equipped_build_ids"):
		player.call("set_equipped_build_ids", _equipped_build_ids, _active_build_id)
	elif player.has_method("set_active_build_id"):
		player.call("set_active_build_id", _active_build_id)
	if player.has_signal("element_changed"):
		player.connect("element_changed", Callable(self, "_on_player_element_changed"))
	if player.has_signal("stance_changed"):
		player.connect("stance_changed", Callable(self, "_on_player_stance_changed"))

	if room != null and room.has_method("bind_player"):
		room.call("bind_player", player)

	if room != null and room.has_method("bind_main"):
		room.call("bind_main", self)

	if tutorial_hud == null:
		return

	if tutorial_hud.has_method("bind_room"):
		tutorial_hud.call("bind_room", room)

	if tutorial_hud.has_method("bind_player"):
		tutorial_hud.call("bind_player", player)

	if tutorial_hud.has_method("bind_main"):
		tutorial_hud.call("bind_main", self)


# 公开给测试与房间脚本使用的最小切房入口。
func transition_to_room(room_path: String, spawn_id: StringName) -> void:
	_change_room(room_path, spawn_id)


# Demo 重开只清理本轮推进状态，保留全局输入和场景结构，方便终点房反复试玩。
func restart_demo() -> void:
	_reset_demo_runtime_state()
	_change_room(TUTORIAL_ROOM_PATH, &"tutorial_start")


# 测试选关入口：仍走生产 Main 的房间、玩家、HUD 和相机装配，只跳过手动主线推进。
func start_demo_at_room(room_path: String, spawn_id: StringName, debug_progress: Dictionary = {}) -> bool:
	if room_path.is_empty() or not ResourceLoader.exists(room_path):
		return false

	_reset_demo_runtime_state()
	if bool(debug_progress.get("air_dash_unlocked", false)):
		_air_dash_unlocked = true
	if bool(debug_progress.get("wind_seal_unlocked", false)):
		_wind_seal_unlocked = true
		_exploration_reward_ids[WIND_SEAL_REWARD_ID] = true
		_current_element_id = ELEMENT_WIND
	var debug_element_id := StringName(str(debug_progress.get("current_element_id", "")))
	if debug_element_id == ELEMENT_THUNDER or (debug_element_id == ELEMENT_WIND and _wind_seal_unlocked):
		_current_element_id = debug_element_id
	var debug_stance_id := StringName(str(debug_progress.get("current_stance_id", "")))
	if debug_stance_id == STANCE_SWIFT or debug_stance_id == STANCE_WARD:
		_current_stance_id = debug_stance_id
	var debug_rewards: Variant = debug_progress.get("exploration_rewards", [])
	if debug_rewards is Array:
		for reward_id: Variant in debug_rewards:
			var resolved_reward_id := StringName(str(reward_id))
			if resolved_reward_id != StringName():
				_exploration_reward_ids[resolved_reward_id] = true
	var debug_equipped_builds: Variant = debug_progress.get("equipped_build_ids", [])
	if debug_equipped_builds is Array:
		for build_id: Variant in debug_equipped_builds:
			var resolved_build_id := StringName(str(build_id))
			if (
				resolved_build_id in BUILD_REWARD_IDS
				and _exploration_reward_ids.has(resolved_build_id)
				and not _equipped_build_ids.has(resolved_build_id)
				and _equipped_build_ids.size() < BUILD_SLOT_LIMIT
			):
				_equipped_build_ids.append(resolved_build_id)
	var debug_build_id := StringName(str(debug_progress.get("active_build_id", "")))
	if (
		debug_build_id in BUILD_REWARD_IDS
		and _exploration_reward_ids.has(debug_build_id)
		and not _equipped_build_ids.has(debug_build_id)
		and _equipped_build_ids.size() < BUILD_SLOT_LIMIT
	):
		_equipped_build_ids.append(debug_build_id)
	if _equipped_build_ids.has(debug_build_id):
		_active_build_id = debug_build_id
	elif _equipped_build_ids.is_empty():
		_equip_available_builds()
	else:
		_active_build_id = _equipped_build_ids[0]
	var reward_count := int(debug_progress.get("stage14_backtrack_reward_count", 0))
	for reward_index in range(reward_count):
		_stage14_backtrack_reward_ids[StringName("debug_stage14_reward_%d" % reward_index)] = true
	_stage15_boss_defeated = bool(debug_progress.get("stage15_boss_defeated", false))
	_change_room(room_path, spawn_id)
	get_tree().paused = false
	return true


# 重置一轮试玩的跨房间状态；正式重开和测试选关复用同一份清理语义。
func _reset_demo_runtime_state() -> void:
	_is_short_chain_completed = false
	_is_demo_completed = false
	_air_dash_unlocked = false
	_wind_seal_unlocked = false
	_current_element_id = ELEMENT_THUNDER
	_current_stance_id = STANCE_SWIFT
	_stage14_backtrack_reward_ids.clear()
	_exploration_reward_ids.clear()
	_accepted_bounty_ids.clear()
	_completed_bounty_ids.clear()
	_turned_in_bounty_ids.clear()
	_active_build_id = &""
	_equipped_build_ids.clear()
	_completed_story_event_ids.clear()
	_visited_room_paths.clear()
	_stage15_boss_defeated = false
	_stage16_alpha_demo_completed = false
	# 候选文档是随构建发布的静态交付物，不随单次 Demo 会话重开而消失。
	_stage16_release_notes_ready = true
	_stage16_qa_checklist_ready = true
	_checkpoint_room_path = ""
	_checkpoint_spawn_id = &""


# 从 Demo 壳或测试入口开始试玩；Main 只负责转发并保留无 UI 时的回退路径。
func start_demo() -> void:
	if demo_shell != null and demo_shell.has_method("start_demo"):
		demo_shell.call("start_demo")
		return

	restart_demo()
	get_tree().paused = false


# 暂停状态由 Demo 壳负责显示；Main 暴露统一入口给测试和后续外层 UI。
func pause_demo() -> void:
	if demo_shell != null and demo_shell.has_method("pause_demo"):
		demo_shell.call("pause_demo")
		return

	get_tree().paused = true


# 继续试玩只恢复暂停，不写入任何 Demo 进度。
func resume_demo() -> void:
	if demo_shell != null and demo_shell.has_method("resume_demo"):
		demo_shell.call("resume_demo")
		return

	get_tree().paused = false


# 查询当前 Demo 是否处于暂停态；正式进度仍通过 get_demo_progress_snapshot 读取。
func is_demo_paused() -> bool:
	if demo_shell != null and demo_shell.has_method("is_demo_paused"):
		return bool(demo_shell.call("is_demo_paused"))

	return get_tree().paused


# 输出主流程稳定快照，供 HUD、GUT 和 MCP 复核读取，不暴露 Main 私有字段。
func get_demo_progress_snapshot() -> Dictionary:
	# 快照是 HUD、测试和 MCP 复核的统一读值入口，不让外部直接依赖 Main 私有字段名。
	var sequence_snapshot := _get_current_element_sequence_snapshot()
	var bounty_snapshot := get_bounty_board_snapshot()
	return {
		"short_chain_completed": _is_short_chain_completed,
		"demo_completed": _is_demo_completed,
		"goal_text": _get_demo_goal_text(),
		"goal_hint_text": _get_demo_goal_hint_text(),
		"replay_available": _is_demo_completed,
		"air_dash_unlocked": _air_dash_unlocked,
		"wind_seal_unlocked": _wind_seal_unlocked,
		"current_element_id": _current_element_id,
		"current_element_label": "风" if _current_element_id == ELEMENT_WIND else "雷",
		"current_stance_id": _current_stance_id,
		"current_stance_label": "御印" if _current_stance_id == STANCE_WARD else "疾印",
		"element_sequence": sequence_snapshot.get("element_ids", []),
		"sequence_window_remaining": sequence_snapshot.get("window_remaining", 0.0),
		"sequence_window_duration": sequence_snapshot.get("window_duration", 0.0),
		"sequence_reaction_id": sequence_snapshot.get("reaction_id", StringName()),
		"sequence_reaction_label": sequence_snapshot.get("reaction_label", ""),
		"stage14_backtrack_reward_count": get_stage14_backtrack_reward_count(),
		"exploration_reward_count": get_exploration_reward_count(),
		"marsh_relic_collected": has_exploration_reward(&"marsh_relic"),
		"warden_sigil_collected": has_exploration_reward(&"warden_sigil"),
		"bounty_board": bounty_snapshot,
		"bounty_accepted_count": bounty_snapshot.get("accepted_count", 0),
		"bounty_completed_count": bounty_snapshot.get("completed_count", 0),
		"bounty_turned_in_count": bounty_snapshot.get("turned_in_count", 0),
		"bounty_reward_count": bounty_snapshot.get("reward_count", 0),
		"waystation_intel_unlocked": bounty_snapshot.get("waystation_intel_unlocked", false),
		"active_build_id": _active_build_id,
		"active_build_label": get_active_build_label(),
		"equipped_build_ids": get_equipped_build_ids(),
		"equipped_build_count": _equipped_build_ids.size(),
		"build_slot_limit": BUILD_SLOT_LIMIT,
		"build_loadout": get_build_loadout_snapshot(),
		"available_build_count": get_available_build_count(),
		"story_event_count": _completed_story_event_ids.size(),
		"stage11_story_event_completed": has_completed_story_event(STAGE11_STORY_EVENT_ID),
		"visited_room_count": _visited_room_paths.size(),
		"stage15_boss_defeated": _stage15_boss_defeated,
		"stage15_recovery_charge_ready": _is_stage15_recovery_charge_ready(),
		"stage16_alpha_demo_completed": _stage16_alpha_demo_completed,
		"stage16_release_notes_ready": _stage16_release_notes_ready,
		"stage16_qa_checklist_ready": _stage16_qa_checklist_ready,
	}


# 输出探索地图所需的只读状态；地图只消费该快照，不参与切房或门控判定。
func get_world_map_snapshot() -> Dictionary:
	var visited_room_paths: Array = _visited_room_paths.keys()
	var bounty_snapshot := get_bounty_board_snapshot()
	visited_room_paths.sort()
	return {
		"current_room_path": _current_room_path,
		"visited_room_paths": visited_room_paths,
		"air_dash_unlocked": _air_dash_unlocked,
		"wind_seal_unlocked": _wind_seal_unlocked,
		"marsh_relic_collected": has_exploration_reward(&"marsh_relic"),
		"warden_sigil_collected": has_exploration_reward(&"warden_sigil"),
		"bounty_accepted_count": bounty_snapshot.get("accepted_count", 0),
		"bounty_completed_count": bounty_snapshot.get("completed_count", 0),
		"bounty_turned_in_count": bounty_snapshot.get("turned_in_count", 0),
		"waystation_intel_unlocked": bounty_snapshot.get("waystation_intel_unlocked", false),
	}


# 解锁 Stage14 空中冲刺，并立即同步到当前房间里已经生成的玩家实例。
func unlock_air_dash() -> void:
	_air_dash_unlocked = true
	var player := _get_runtime_player()
	if player != null and player.has_method("set_air_dash_unlocked"):
		player.call("set_air_dash_unlocked", true)


# 公开查询空中冲刺是否已进入跨房间主流程状态。
func is_air_dash_unlocked() -> bool:
	return _air_dash_unlocked


# 解锁风印并同步当前玩家；探索奖励字典同时承担跨房门控查询。
func unlock_wind_seal() -> void:
	_wind_seal_unlocked = true
	_current_element_id = ELEMENT_WIND
	_exploration_reward_ids[WIND_SEAL_REWARD_ID] = true
	var player := _get_runtime_player()
	if player != null and player.has_method("set_wind_seal_unlocked"):
		player.call("set_wind_seal_unlocked", true)
	if player != null and player.has_method("set_current_element_id"):
		player.call("set_current_element_id", _current_element_id)
	_refresh_hud_progress()


# 查询风印是否已成为本轮可用的第二能力。
func is_wind_seal_unlocked() -> bool:
	return _wind_seal_unlocked


# 玩家只上报跨房选择；两步序列仍由当前玩家实例自己持有。
func _on_player_element_changed(element_id: StringName) -> void:
	_current_element_id = element_id
	_refresh_hud_progress()


func _on_player_stance_changed(stance_id: StringName) -> void:
	_current_stance_id = stance_id
	_refresh_hud_progress()


# 记录 Stage14 回溯收益，使用 reward_id 去重，防止换房或重复触发刷计数。
func collect_stage14_backtrack_reward(reward_id: StringName) -> void:
	if reward_id == StringName() or _stage14_backtrack_reward_ids.has(reward_id):
		return

	_stage14_backtrack_reward_ids[reward_id] = true


# 返回已确认的 Stage14 回溯收益数量，HUD 和主线测试都依赖这个读值。
func get_stage14_backtrack_reward_count() -> int:
	return _stage14_backtrack_reward_ids.size()


# 记录跨房间探索 / 战斗收益；四件固定 Build 共用该去重入口，不扩展成物品栏或经济系统。
func collect_exploration_reward(reward_id: StringName) -> void:
	if reward_id == StringName() or _exploration_reward_ids.has(reward_id):
		return

	_exploration_reward_ids[reward_id] = true
	if reward_id in BUILD_REWARD_IDS:
		if _equipped_build_ids.size() < BUILD_SLOT_LIMIT:
			_equipped_build_ids.append(reward_id)
		if _active_build_id == StringName() and _equipped_build_ids.has(reward_id):
			_active_build_id = reward_id
		_apply_build_loadout_to_current_player()
	if reward_id == &"marsh_relic":
		_complete_bounty(BOUNTY_DEMON_BONE_EVIDENCE)
	_refresh_hud_progress()


# 驿站悬赏只保留三条固定条目；状态快照同时供榜单、HUD、地图与测试读取。
func get_bounty_board_snapshot() -> Dictionary:
	var entries: Array[Dictionary] = []
	for bounty_id: StringName in BOUNTY_IDS:
		var definition: Dictionary = BOUNTY_DEFINITIONS[bounty_id]
		entries.append({
			"id": bounty_id,
			"title": definition.get("title", ""),
			"objective": definition.get("objective", ""),
			"reward": definition.get("reward", ""),
			"state": _get_bounty_state(bounty_id),
		})
	return {
		"entries": entries,
		"accepted_count": _accepted_bounty_ids.size(),
		"completed_count": _completed_bounty_ids.size(),
		"turned_in_count": _turned_in_bounty_ids.size(),
		"reward_count": _turned_in_bounty_ids.size(),
		"waystation_intel_unlocked": _turned_in_bounty_ids.size() == BOUNTY_IDS.size(),
	}


# 同一入口承担接取与回交；任务推进只允许在镇妖驿厅发生。
func advance_bounty(bounty_id: StringName) -> Dictionary:
	if room == null or room.scene_file_path != STAGE11_DEMO_END_ROOM_PATH:
		return get_bounty_board_snapshot()
	if not BOUNTY_DEFINITIONS.has(bounty_id):
		return get_bounty_board_snapshot()

	if not _accepted_bounty_ids.has(bounty_id):
		_accepted_bounty_ids[bounty_id] = true
		if bounty_id == BOUNTY_DEMON_BONE_EVIDENCE and has_exploration_reward(&"marsh_relic"):
			_complete_bounty(bounty_id)
	elif _completed_bounty_ids.has(bounty_id) and not _turned_in_bounty_ids.has(bounty_id):
		_turned_in_bounty_ids[bounty_id] = true
		if bounty_id == BOUNTY_CASTER_HUNT:
			collect_exploration_reward(BUILD_CASTER_CORE)
		_refresh_hud_progress()
	return get_bounty_board_snapshot()


# 房间信号和测试复用该入口，榜单只显示状态，不持有任务数据。
func open_bounty_board() -> void:
	if room == null or room.scene_file_path != STAGE11_DEMO_END_ROOM_PATH:
		return
	if demo_shell != null and demo_shell.has_method("show_bounty_board"):
		demo_shell.call("show_bounty_board", get_bounty_board_snapshot())


func _complete_bounty(bounty_id: StringName) -> void:
	if not _accepted_bounty_ids.has(bounty_id) or _completed_bounty_ids.has(bounty_id):
		return
	_completed_bounty_ids[bounty_id] = true
	_refresh_hud_progress()


func _get_bounty_state(bounty_id: StringName) -> StringName:
	if _turned_in_bounty_ids.has(bounty_id):
		return &"turned_in"
	if _completed_bounty_ids.has(bounty_id):
		return &"completed"
	if _accepted_bounty_ids.has(bounty_id):
		return &"accepted"
	return &"available"


func _get_bounty_progress_hint() -> String:
	return "悬赏：已接 %d/%d · 完成 %d · 回交 %d" % [
		_accepted_bounty_ids.size(),
		BOUNTY_IDS.size(),
		_completed_bounty_ids.size(),
		_turned_in_bounty_ids.size(),
	]


# 查询指定探索收益是否已经取得，供远端捷径恢复开关状态。
func has_exploration_reward(reward_id: StringName) -> bool:
	return reward_id != StringName() and _exploration_reward_ids.has(reward_id)


# 返回当前 Demo 内已取得的探索收益数量，供 HUD 与回归测试读取。
func get_exploration_reward_count() -> int:
	return _exploration_reward_ids.size()


# 在当前两槽装备间循环调谐焦点；实际效果始终由整份装备列表决定。
func cycle_active_build() -> StringName:
	if _equipped_build_ids.is_empty():
		_active_build_id = &""
		return _active_build_id

	var current_index := _equipped_build_ids.find(_active_build_id)
	_active_build_id = (
		_equipped_build_ids[(current_index + 1) % _equipped_build_ids.size()]
		if current_index >= 0
		else _equipped_build_ids[0]
	)
	_apply_build_loadout_to_current_player()
	_refresh_hud_progress()
	return _active_build_id


# 返回当前调谐 ID，暂停菜单和测试不直接读取 Main 私有状态。
func get_active_build_id() -> StringName:
	return _active_build_id


# 返回调谐焦点的短标签；效果仍由两槽共同决定。
func get_active_build_label() -> String:
	if not BUILD_DEFINITIONS.has(_active_build_id):
		return "尚未调谐"
	return str((BUILD_DEFINITIONS[_active_build_id] as Dictionary).get("label", "尚未调谐"))


# 返回本轮可切换的 Build 数量。
func get_available_build_count() -> int:
	return _get_available_build_ids().size()


# 返回两槽副本，暂停 UI、测试和玩家注入都不直接修改 Main 内部数组。
func get_equipped_build_ids() -> Array[StringName]:
	return _equipped_build_ids.duplicate()


# 输出轻量装备面板所需的全部状态，不建立通用物品栏模型。
func get_build_loadout_snapshot(status_message := "") -> Dictionary:
	var entries: Array[Dictionary] = []
	for build_id: StringName in _get_available_build_ids():
		var definition: Dictionary = BUILD_DEFINITIONS[build_id]
		entries.append({
			"id": build_id,
			"label": definition.get("label", ""),
			"effect": definition.get("effect", ""),
			"source": definition.get("source", ""),
			"equipped": _equipped_build_ids.has(build_id),
			"slot": _equipped_build_ids.find(build_id) + 1,
		})
	return {
		"entries": entries,
		"available_count": entries.size(),
		"equipped_count": _equipped_build_ids.size(),
		"equipped_ids": get_equipped_build_ids(),
		"active_build_id": _active_build_id,
		"slot_limit": BUILD_SLOT_LIMIT,
		"status_message": status_message,
	}


# 装备已取得物品或卸下已装备物品；槽满时保持原状态并给 UI 明确信息。
func toggle_build_equipped(build_id: StringName) -> Dictionary:
	if not _exploration_reward_ids.has(build_id) or not BUILD_DEFINITIONS.has(build_id):
		return get_build_loadout_snapshot("尚未取得该圣物。")

	if _equipped_build_ids.has(build_id):
		_equipped_build_ids.erase(build_id)
		if _active_build_id == build_id:
			_active_build_id = _equipped_build_ids[0] if not _equipped_build_ids.is_empty() else StringName()
	elif _equipped_build_ids.size() >= BUILD_SLOT_LIMIT:
		return get_build_loadout_snapshot("槽位已满，请先卸下一件。")
	else:
		_equipped_build_ids.append(build_id)
		_active_build_id = build_id

	_apply_build_loadout_to_current_player()
	_refresh_hud_progress()
	return get_build_loadout_snapshot()


func open_build_loadout() -> void:
	if demo_shell != null and demo_shell.has_method("show_build_loadout"):
		demo_shell.call("show_build_loadout", get_build_loadout_snapshot())


# 触发一次正式剧情事件；Main 只去重和转发，表现继续由 DemoShell 负责。
func trigger_story_event(event_id: StringName, title: String, body: String) -> bool:
	if event_id == StringName() or _completed_story_event_ids.has(event_id):
		return false

	_completed_story_event_ids[event_id] = true
	if demo_shell != null and demo_shell.has_method("show_story_event"):
		demo_shell.call("show_story_event", title, body)
	_refresh_hud_progress()
	return true


# 查询剧情事件是否已在本轮完成。
func has_completed_story_event(event_id: StringName) -> bool:
	return event_id != StringName() and _completed_story_event_ids.has(event_id)


# 标记 Stage15 Boss 已击败；实际胜利房间跳转仍由房间脚本发起。
func mark_stage15_boss_defeated() -> void:
	# Boss 房只报告胜利事件；Main 把它转成 demo 进度快照，供完成房和 HUD 继续读取。
	_stage15_boss_defeated = true
	collect_exploration_reward(BUILD_GUARDIAN_CORE)


# 公开查询 Stage15 Boss 结果，避免完成房直接读取 Main 私有变量。
func is_stage15_boss_defeated() -> bool:
	return _stage15_boss_defeated


# 标记 Stage16 Alpha Demo 已完成；终点房或专项测试通过这个接口写入 Main 快照。
func mark_stage16_alpha_demo_completed() -> void:
	_stage16_alpha_demo_completed = true
	_is_demo_completed = true
	_refresh_hud_progress()


# 查询 Stage16 Alpha Demo 完成态，避免 Demo 壳、房间或测试读取 Main 私有变量。
func is_stage16_alpha_demo_completed() -> bool:
	return _stage16_alpha_demo_completed


# 标记 Alpha Demo release notes 已准备好；运行时只保存可读状态，不负责文档生成。
func mark_stage16_release_notes_ready() -> void:
	_stage16_release_notes_ready = true
	_refresh_hud_progress()


# 查询 release notes 状态，供 HUD、Demo 壳和测试读取。
func is_stage16_release_notes_ready() -> bool:
	return _stage16_release_notes_ready


# 标记 Demo 级 QA checklist 已准备好；Main 只作为跨系统快照出口。
func mark_stage16_qa_checklist_ready() -> void:
	_stage16_qa_checklist_ready = true
	_refresh_hud_progress()


# 查询 QA checklist 状态，供 HUD、Demo 壳和测试读取。
func is_stage16_qa_checklist_ready() -> bool:
	return _stage16_qa_checklist_ready


# 房间切换逻辑必须同时覆盖：首次进入、同房间重生，以及真正的场景替换。
func _change_room(room_path: String, spawn_id: StringName, force_reload := false) -> void:
	var room_scene: PackedScene = load(room_path) as PackedScene
	if room_scene == null:
		return

	if room == null:
		room = get_node_or_null("Room") as Node2D

	_current_room_path = room_path
	_current_spawn_id = spawn_id
	_visited_room_paths[room_path] = true

	if not force_reload and room != null and room.scene_file_path == room_path:
		_bind_room_signals()
		_spawn_placeholder_player(spawn_id)
		return

	if room != null:
		remove_child(room)
		room.queue_free()
		room = null

	room = room_scene.instantiate() as Node2D
	if room == null:
		return

	room.name = "Room"
	add_child(room)
	move_child(room, 0)
	_bind_room_signals()
	_spawn_placeholder_player(spawn_id)


# Main 只消费房间约定好的统一信号，不在这里写分房间的硬编码推进逻辑。
func _bind_room_signals() -> void:
	_ensure_room_signal_binding()


# 按房间统一契约安全连接信号，支持同一房间重生时重复调用。
func _ensure_room_signal_binding() -> void:
	if room == null:
		return

	var transition_callback := Callable(self, "_on_room_transition_requested")
	if room.has_signal("room_transition_requested") and not room.is_connected("room_transition_requested", transition_callback):
		room.connect("room_transition_requested", transition_callback)

	var complete_callback := Callable(self, "_on_goal_completed")
	if room.has_signal("goal_completed") and not room.is_connected("goal_completed", complete_callback):
		room.connect("goal_completed", complete_callback)

	var checkpoint_callback := Callable(self, "_on_checkpoint_requested")
	if room.has_signal("checkpoint_requested") and not room.is_connected("checkpoint_requested", checkpoint_callback):
		room.connect("checkpoint_requested", checkpoint_callback)

	var bounty_board_callback := Callable(self, "_on_bounty_board_requested")
	if room.has_signal("bounty_board_requested") and not room.is_connected("bounty_board_requested", bounty_board_callback):
		room.connect("bounty_board_requested", bounty_board_callback)

	_bind_bounty_target_signals()


# 直接复用现有房间子节点的生产信号，不让任务系统接管敌人或机关生命周期。
func _bind_bounty_target_signals() -> void:
	for child: Node in room.get_children():
		var child_script := child.get_script() as Script
		var caster_callback := Callable(self, "_on_bounty_caster_defeated")
		if (
			child_script != null
			and child_script.resource_path == MIASMA_CASTER_SCRIPT_PATH
			and child.has_signal("defeated")
			and not child.is_connected("defeated", caster_callback)
		):
			child.connect("defeated", caster_callback)

		var pulse_callback := Callable(self, "_on_bounty_pulse_disrupted")
		if child.has_signal("sequence_disrupted") and not child.is_connected("sequence_disrupted", pulse_callback):
			child.connect("sequence_disrupted", pulse_callback)


func _on_bounty_board_requested() -> void:
	open_bounty_board()


func _on_bounty_caster_defeated() -> void:
	_complete_bounty(BOUNTY_CASTER_HUNT)


func _on_bounty_pulse_disrupted() -> void:
	_complete_bounty(BOUNTY_SEAL_PULSE_CLEANUP)


# 解析房间出生点；房间未实现契约时回落到主场景默认出生点。
func _resolve_spawn_position(spawn_id: StringName) -> Vector2:
	if room != null and room.has_method("get_spawn_position"):
		return room.call("get_spawn_position", spawn_id)

	if fallback_player_spawn != null:
		return fallback_player_spawn.position

	return Vector2.ZERO


# 清空当前运行时子节点，确保换房时不会留下旧玩家、旧 hitbox 或旧信号来源。
func _clear_runtime() -> void:
	for child in runtime.get_children():
		runtime.remove_child(child)
		child.queue_free()


# 失败与 checkpoint 恢复仍保持“最小原型规则”：优先回最近 checkpoint，否则按当前房间的重置策略处理。
func _on_room_transition_requested(target_room_path: String, spawn_id: StringName) -> void:
	if _is_demo_completed and target_room_path == TUTORIAL_ROOM_PATH:
		restart_demo()
		return

	transition_to_room(target_room_path, spawn_id)


# 玩家失败后优先回 checkpoint，没有 checkpoint 时按当前房间的失败规则决定是否重置。
func _on_player_defeated() -> void:
	_handle_player_failure("已战败，回到最近检查点。")


# 玩家跌出当前房间相机下边界时，按失败处理，防止落入空白区域后无法恢复。
func _check_player_fall_out_of_bounds() -> void:
	var player := _get_runtime_player()
	if player == null:
		return

	var camera_limits := _get_current_room_camera_limits()
	if player.global_position.y <= float(camera_limits.end.y) + FALL_RESET_MARGIN:
		return

	_handle_player_failure("已跌落，回到最近检查点。")


func _handle_player_failure(message: String) -> void:
	if not _checkpoint_room_path.is_empty():
		_change_room(_checkpoint_room_path, _checkpoint_spawn_id, true)
		_show_failure_notice(message)
		return

	if room == null:
		return

	if room.has_method("should_reset_on_player_defeat") and room.call("should_reset_on_player_defeat"):
		_change_room(_current_room_path, _current_spawn_id, true)
	else:
		_change_room(_current_room_path, _current_spawn_id)

	_show_failure_notice(message)


func _get_current_room_camera_limits() -> Rect2i:
	if room != null and room.has_method("get_camera_limits"):
		var camera_limits: Rect2i = room.call("get_camera_limits")
		var room_world_offset := Vector2i(room.global_position.round())
		return Rect2i(camera_limits.position + room_world_offset, camera_limits.size)

	return Rect2i(Vector2i(-BASE_VIEWPORT_SIZE.x / 2, -BASE_VIEWPORT_SIZE.y / 2), BASE_VIEWPORT_SIZE)


func _show_failure_notice(message: String) -> void:
	if demo_shell != null and demo_shell.has_method("show_failure_notice"):
		demo_shell.call("show_failure_notice", message)


# 从 Runtime 容器取当前玩家实例；每次换房都会生成新实例，因此不能长期缓存。
func _get_runtime_player() -> CharacterBody2D:
	return runtime.get_node_or_null("PlayerPlaceholder") as CharacterBody2D


# Main 在关键快照变化后主动刷新 HUD，保证暂停菜单或测试暂停状态下也能看到最新完成反馈。
func _refresh_hud_progress() -> void:
	if tutorial_hud != null and tutorial_hud.has_method("_update_progress_status"):
		tutorial_hud.call("_update_progress_status")


# Main 只转发当前玩家的局部序列快照；没有玩家或换房瞬间回落为空序列。
func _get_current_element_sequence_snapshot() -> Dictionary:
	var player := _get_runtime_player()
	if player == null or not player.has_method("get_element_sequence_snapshot"):
		return {
			"element_ids": [],
			"window_remaining": 0.0,
			"window_duration": 0.0,
			"reaction_id": StringName(),
			"reaction_label": "",
		}

	var snapshot: Variant = player.call("get_element_sequence_snapshot")
	return snapshot if snapshot is Dictionary else {}


# 把玩家恢复充能 ready 状态转成 Main 快照字段，供 HUD 展示 stage15 战斗容错。
func _is_stage15_recovery_charge_ready() -> bool:
	# Recovery Charge 不由 Main 持久化；快照只转述当前玩家是否已经满充能。
	var player := _get_runtime_player()
	if player == null or not player.has_method("can_spend_recovery_charge"):
		return false

	return bool(player.call("can_spend_recovery_charge"))


# Stage11 只确认早期短链路；完整 Demo 完成态只允许 Stage16 终点写入。
func _on_goal_completed() -> void:
	if room != null and room.scene_file_path == STAGE16_ALPHA_DEMO_END_ROOM_PATH:
		mark_stage16_alpha_demo_completed()
		return

	if room != null and room.scene_file_path == STAGE11_DEMO_END_ROOM_PATH:
		_is_short_chain_completed = true
		trigger_story_event(
			STAGE11_STORY_EVENT_ID,
			STAGE11_STORY_EVENT_TITLE,
			STAGE11_STORY_EVENT_BODY
		)
		_refresh_hud_progress()


# 房间请求 checkpoint 时只记录房间路径与出生点，不在 Main 内保存更多房间状态。
func _on_checkpoint_requested(room_path: String, spawn_id: StringName) -> void:
	# checkpoint 仍然只记录运行期最近的恢复点，不扩展成正式存档系统。
	_checkpoint_room_path = room_path
	_checkpoint_spawn_id = spawn_id


# 按固定四件顺序返回已取得 Build，保证两槽 UI 与测试顺序稳定。
func _get_available_build_ids() -> Array[StringName]:
	var available_builds: Array[StringName] = []
	for reward_id: StringName in BUILD_REWARD_IDS:
		if has_exploration_reward(reward_id):
			available_builds.append(reward_id)
	return available_builds


func _equip_available_builds() -> void:
	var available_builds := _get_available_build_ids()
	for build_id: StringName in available_builds:
		if _equipped_build_ids.size() >= BUILD_SLOT_LIMIT:
			break
		_equipped_build_ids.append(build_id)
	if not _equipped_build_ids.is_empty():
		_active_build_id = _equipped_build_ids[0]


func _apply_build_loadout_to_current_player() -> void:
	var player := _get_runtime_player()
	if player != null and player.has_method("set_equipped_build_ids"):
		player.call("set_equipped_build_ids", _equipped_build_ids, _active_build_id)
	elif player != null and player.has_method("set_active_build_id"):
		player.call("set_active_build_id", _active_build_id)


# Demo 主链路的目标文案只做“当前处于哪个关键节点”的最小收束，
# 不把它扩成另一层配置系统。
func _get_demo_goal_text() -> String:
	# Stage 13 已回收到瘴泽妖域语境；这里保持玩家目标可读，不额外引入剧情系统。
	if _stage16_alpha_demo_completed:
		return "Alpha Demo 已完成"

	if room != null and room.scene_file_path.begins_with(STAGE25_ROOM_PREFIX):
		return "目标：勘明雷泽荒原并返回驿厅"

	if room != null and room.scene_file_path.begins_with(STAGE16_ROOM_PREFIX):
		return "目标：完成封印链"

	if room != null and room.scene_file_path == STAGE15_COMPLETION_ROOM_PATH and _stage15_boss_defeated:
		return "Stage15 已完成：封印守卫已击败，战斗高潮闭环成立"

	if room != null and room.scene_file_path.begins_with(STAGE15_ROOM_PREFIX):
		return "目标：击败封印守卫"

	if room != null and room.scene_file_path.begins_with(STAGE14_ROOM_PREFIX):
		return "目标：取得空中冲刺"

	if room != null and room.scene_file_path.begins_with(STAGE13_ROOM_PREFIX):
		return "目标：抵达二区终点"

	if _is_demo_completed:
		return "Demo 已完成：可向左返回并重开试玩"

	if room == null:
		return "目标：加载 Demo"

	match room.scene_file_path:
		STAGE10_BRANCH_ROOM_PATH:
			return "目标：返回主线"
		STAGE10_CHALLENGE_ROOM_PATH:
			return "目标：完成挑战"
		STAGE11_DEMO_END_ROOM_PATH:
			return "目标：确认镇妖驿厅通路"
		_:
			return "目标：推进 Demo"


# 按当前阶段和房间给 HUD 生成一条短提示，帮助玩家理解当下最关键的操作。
func _get_demo_goal_hint_text() -> String:
	# 提示文案只标注当前房间最可能卡住玩家的点，不在 HUD 里写完整教程。
	if _stage16_alpha_demo_completed:
		return "提示：可重开或查看发布项"

	if room != null and room.scene_file_path.begins_with(STAGE25_ROOM_PREFIX):
		return "提示：避开雷暴 / 风后接雷使祭柱接地"

	if room != null and room.scene_file_path.begins_with(STAGE16_ROOM_PREFIX):
		return "提示：符印/回溯/净化"

	if not _accepted_bounty_ids.is_empty():
		return _get_bounty_progress_hint()

	if room != null and room.scene_file_path == STAGE15_COMPLETION_ROOM_PATH and _stage15_boss_defeated:
		return "提示：可进入打包复核"

	if room != null and room.scene_file_path.begins_with(STAGE15_ROOM_PREFIX):
		return "提示：攻击充能，L 恢复"

	if room != null and room.scene_file_path.begins_with(STAGE14_ROOM_PREFIX):
		return "提示：空中冲刺过门"

	if room != null and room.scene_file_path.begins_with(STAGE13_ROOM_PREFIX):
		return "提示：瘴气/投射/门控"

	if _is_demo_completed:
		return "提示：向左回到重开入口后，可从教程重新开始"

	if room == null:
		return ""

	match room.scene_file_path:
		STAGE10_BRANCH_ROOM_PATH:
			return "提示：支路会给出恢复点与收集收益"
		STAGE10_CHALLENGE_ROOM_PATH:
			return "提示：通过挑战房后，右侧出口会接入镇妖驿厅"
		STAGE11_DEMO_END_ROOM_PATH:
			return "提示：左返试炼 / 右入瘴泽"
		_:
			return ""
