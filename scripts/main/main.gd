extends Node2D

# Main 负责房间链路、跨房进度、单档持久化，以及 Room / Player / HUD 的绑定。
# 单个房间内部的教学、战斗和门控细节仍由房间脚本负责。

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
const STAGE25_ENTRY_ROOM_PATH := "res://scenes/rooms/stage25_thunder_waste_entry_room.tscn"
const FORMAL_DEMO_ROOM_PROGRAM_PATH := "res://assets/configs/world_map/formal_demo_room_program.json"
const FALL_RESET_MARGIN := 96.0
const ROOM_ENTRY_FALL_GUARD_DURATION := 0.2
const SAVE_VERSION := 1
const SAVE_FILE_PATH := "user://north_star_save.json"
const BACKUP_SAVE_FILE_PATH := "user://north_star_save.backup.json"
const TRAVEL_WAYSTATION_MAIN: StringName = &"waystation_main"
const TRAVEL_THUNDER_OUTPOST: StringName = &"thunder_outpost"
const WIND_SEAL_REWARD_ID: StringName = &"wind_seal"
const ELEMENT_WIND: StringName = &"wind"
const ELEMENT_THUNDER: StringName = &"thunder"
const STANCE_SWIFT: StringName = &"swift"
const STANCE_WARD: StringName = &"ward"
const BUILD_MARSH_RELIC: StringName = &"marsh_relic"
const BUILD_WARDEN_SIGIL: StringName = &"warden_sigil"
const BUILD_CASTER_CORE: StringName = &"caster_core"
const BUILD_GUARDIAN_CORE: StringName = &"guardian_core"
const BUILD_THUNDER_BEAST_CORE: StringName = &"thunder_beast_core"
const BUILD_SLOT_LIMIT := 2
const BUILD_REWARD_IDS: Array[StringName] = [
	BUILD_MARSH_RELIC,
	BUILD_WARDEN_SIGIL,
	BUILD_CASTER_CORE,
	BUILD_GUARDIAN_CORE,
	BUILD_THUNDER_BEAST_CORE,
]
const BUILD_DEFINITIONS := {
	BUILD_MARSH_RELIC: {
		"label": "瘴泽遗物",
		"effect": "恢复充能获取 x1.5",
		"source": "瘴泽资源支路",
		"icon_id": &"build_marsh_relic",
	},
	BUILD_WARDEN_SIGIL: {
		"label": "镇妖挑战符",
		"effect": "横向攻击距离 +16px",
		"source": "瘴泽挑战支路",
		"icon_id": &"build_warden_sigil",
	},
	BUILD_CASTER_CORE: {
		"label": "腐瘴法珠",
		"effect": "元素序列窗口 +0.75s",
		"source": "断瘴缉术回交",
		"icon_id": &"build_caster_core",
	},
	BUILD_GUARDIAN_CORE: {
		"label": "守印金刚心",
		"effect": "姿态切换冷却 -0.15s",
		"source": "封印守卫",
		"icon_id": &"build_guardian_core",
	},
	BUILD_THUNDER_BEAST_CORE: {
		"label": "雷兽妖核",
		"effect": "雷风散射击退 x1.2",
		"source": "夔影雷骸",
		"icon_id": &"build_thunder_beast_core",
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
		"icon_id": &"bounty_caster_hunt",
	},
	BOUNTY_DEMON_BONE_EVIDENCE: {
		"title": "妖骨取证",
		"objective": "回收瘴泽妖骨证物",
		"reward": "妖骨案卷",
		"icon_id": &"bounty_demon_bone_evidence",
	},
	BOUNTY_SEAL_PULSE_CLEANUP: {
		"title": "封脉清障",
		"objective": "用雷风序列散去封印脉冲",
		"reward": "雷泽荒原路引",
		"icon_id": &"bounty_seal_pulse_cleanup",
	},
}
const STAGE11_STORY_EVENT_ID: StringName = &"stage11_hidden_dispatch"
const STAGE11_STORY_EVENT_TITLE := "镇妖驿厅 · 密令残页"
const STAGE11_STORY_EVENT_BODY := "镇妖卫驿卒：瘴泽封印并非天灾，是郡守私运妖骨后崩裂。\n\nLuna：悬赏只写“清除妖患”，没有百姓名册。\n\n陌生妖声：你闻得到他们留下的血。因为你与我同源。"
const STAGE28_ALL_BOUNTIES_EVENT_ID: StringName = &"stage28_all_bounties_turned_in"
const STAGE28_ALL_BOUNTIES_EVENT_TITLE := "镇妖驿站 · 三榜归档"
const STAGE28_ALL_BOUNTIES_EVENT_BODY := "镇妖卫驿卒：三道悬赏都已盖印，雷泽路引归你。\n\nLuna：把妖骨案卷另存一份。郡守若要抹去失踪者，我便把名字带回来。\n\n陌生妖声：雷声会记得那些血。"
const STAGE28_THUNDER_RETURN_EVENT_ID: StringName = &"stage28_thunder_waste_return"
const STAGE28_THUNDER_RETURN_EVENT_TITLE := "镇妖驿站 · 雷泽归来"
const STAGE28_THUNDER_RETURN_EVENT_BODY := "镇妖卫驿卒：雷印随你归站，荒原里的东西已认得镇妖卫。\n\nLuna：它认得的不是官印，是我体内的妖血。证物照旧封存，案卷照旧送审。\n\n陌生妖声：你还在替他们守门。"
const STAGE30_DEMON_RESONANCE_EVENT_ID: StringName = &"stage30_demon_resonance"
const STAGE30_DEMON_RESONANCE_EVENT_TITLE := "雷泽荒原 · 妖雷共鸣"
const STAGE30_DEMON_RESONANCE_EVENT_BODY := "夔影雷骸的鼓腔归于寂静，残雷却没有散去，而是沿 Luna 的镇妖印没入血脉。\n\nLuna：官府把妖骨制成封印，又命我来斩妖。究竟是谁借谁的血守门？\n\n陌生妖声：你终于肯收回本就属于你的雷。"
const STAGE14_REWARD_IDS: Array[StringName] = [
	&"stage14_reward_one",
	&"stage14_reward_two",
	&"stage14_reward_three",
]
const STORY_EVENT_IDS: Array[StringName] = [
	STAGE11_STORY_EVENT_ID,
	STAGE28_ALL_BOUNTIES_EVENT_ID,
	STAGE28_THUNDER_RETURN_EVENT_ID,
	STAGE30_DEMON_RESONANCE_EVENT_ID,
]
const SAVE_EXPLORATION_REWARD_IDS: Array[StringName] = [
	WIND_SEAL_REWARD_ID,
	BUILD_MARSH_RELIC,
	BUILD_WARDEN_SIGIL,
	BUILD_CASTER_CORE,
	BUILD_GUARDIAN_CORE,
	BUILD_THUNDER_BEAST_CORE,
]
const SAVE_BOOLEAN_FIELDS: Array[String] = [
	"short_chain_completed",
	"demo_completed",
	"air_dash_unlocked",
	"wind_seal_unlocked",
	"thunder_absorption_unlocked",
	"stage15_boss_defeated",
	"stage30_boss_defeated",
	"stage16_alpha_demo_completed",
]
const TRAVEL_POINT_IDS: Array[StringName] = [
	TRAVEL_WAYSTATION_MAIN,
	TRAVEL_THUNDER_OUTPOST,
]
const TRAVEL_POINT_DEFINITIONS := {
	TRAVEL_WAYSTATION_MAIN: {
		"label": "镇妖驿站",
		"room_path": STAGE11_DEMO_END_ROOM_PATH,
		"spawn_id": &"stage11_demo_end_start",
		"icon_id": &"waystation_main",
	},
	TRAVEL_THUNDER_OUTPOST: {
		"label": "雷泽前哨",
		"room_path": STAGE25_ENTRY_ROOM_PATH,
		"spawn_id": &"stage25_entry_start",
		"icon_id": &"thunder_outpost",
	},
}

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
var _room_entry_fall_guard_remaining := 0.0
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
var _completed_forward_room_paths: Dictionary = {}
var _discovered_travel_point_ids: Dictionary = {}
var _stage15_boss_defeated := false
var _stage30_boss_defeated := false
var _thunder_absorption_unlocked := false
var _stage16_alpha_demo_completed := false
var _stage16_release_notes_ready := true
var _stage16_qa_checklist_ready := true
var _persistence_session_active := false
var _save_file_path := SAVE_FILE_PATH
var _backup_save_file_path := BACKUP_SAVE_FILE_PATH
var _save_paths_overridden := false
var _last_save_result := {
	"ok": false,
	"code": &"not_saved",
	"message": "尚未写入存档。",
}
var _formal_demo_room_program: Dictionary = {}


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
func _process(delta: float) -> void:
	if _room_entry_fall_guard_remaining > 0.0:
		_room_entry_fall_guard_remaining = maxf(_room_entry_fall_guard_remaining - maxf(delta, 0.0), 0.0)
		return
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
	if player.has_method("set_thunder_absorption_unlocked"):
		player.call("set_thunder_absorption_unlocked", _thunder_absorption_unlocked)
	var element_callback := Callable(self, "_on_player_element_changed")
	if player.has_signal("element_changed") and not player.is_connected("element_changed", element_callback):
		player.connect("element_changed", element_callback)
	var stance_callback := Callable(self, "_on_player_stance_changed")
	if player.has_signal("stance_changed") and not player.is_connected("stance_changed", stance_callback):
		player.connect("stance_changed", stance_callback)

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


# 主菜单新开明确启用正式持久化；测试选关继续保持无存档副作用。
func start_new_game() -> Dictionary:
	_persistence_session_active = true
	restart_demo()
	return _last_save_result


# Demo 重开只清理本轮推进状态，保留全局输入和场景结构，方便终点房反复试玩。
func restart_demo() -> void:
	_reset_demo_runtime_state()
	_change_room(TUTORIAL_ROOM_PATH, &"tutorial_start")
	_persist_if_session_active()


# 测试选关入口：仍走生产 Main 的房间、玩家、HUD 和相机装配，只跳过手动主线推进。
func start_demo_at_room(room_path: String, spawn_id: StringName, debug_progress: Dictionary = {}) -> bool:
	if room_path.is_empty() or not ResourceLoader.exists(room_path):
		return false

	_persistence_session_active = false
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
	_stage30_boss_defeated = bool(debug_progress.get("stage30_boss_defeated", false))
	_thunder_absorption_unlocked = bool(
		debug_progress.get("thunder_absorption_unlocked", _stage30_boss_defeated)
	)
	if _stage30_boss_defeated:
		collect_exploration_reward(BUILD_THUNDER_BEAST_CORE)
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
	_completed_forward_room_paths.clear()
	_discovered_travel_point_ids.clear()
	_stage15_boss_defeated = false
	_stage30_boss_defeated = false
	_thunder_absorption_unlocked = false
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

	start_new_game()
	get_tree().paused = false


# DemoShell 用这一公开入口声明标题流程与游戏流程的边界；完整 HUD 必须连同共享注意层一起切换。
func set_gameplay_hud_visible(is_visible: bool) -> void:
	if tutorial_hud != null:
		tutorial_hud.visible = is_visible


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
		"thunder_beast_core_collected": has_exploration_reward(BUILD_THUNDER_BEAST_CORE),
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
		"stage28_all_bounties_story_completed": has_completed_story_event(STAGE28_ALL_BOUNTIES_EVENT_ID),
		"stage28_thunder_return_story_completed": has_completed_story_event(STAGE28_THUNDER_RETURN_EVENT_ID),
		"stage30_demon_resonance_story_completed": has_completed_story_event(STAGE30_DEMON_RESONANCE_EVENT_ID),
		"visited_room_count": _visited_room_paths.size(),
		"stage15_boss_defeated": _stage15_boss_defeated,
		"stage30_boss_defeated": _stage30_boss_defeated,
		"thunder_absorption_unlocked": _thunder_absorption_unlocked,
		"stage15_recovery_charge_ready": _is_stage15_recovery_charge_ready(),
		"stage16_alpha_demo_completed": _stage16_alpha_demo_completed,
		"stage16_release_notes_ready": _stage16_release_notes_ready,
		"stage16_qa_checklist_ready": _stage16_qa_checklist_ready,
		"current_travel_point_id": _get_current_travel_point_id(),
		"discovered_travel_point_count": _discovered_travel_point_ids.size(),
		"persistence_session_active": _persistence_session_active,
		"last_save_code": _last_save_result.get("code", &"not_saved"),
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
		"stage30_boss_defeated": _stage30_boss_defeated,
		"thunder_absorption_unlocked": _thunder_absorption_unlocked,
		"bounty_accepted_count": bounty_snapshot.get("accepted_count", 0),
		"bounty_completed_count": bounty_snapshot.get("completed_count", 0),
		"bounty_turned_in_count": bounty_snapshot.get("turned_in_count", 0),
		"waystation_intel_unlocked": bounty_snapshot.get("waystation_intel_unlocked", false),
		"discovered_travel_point_ids": _sorted_string_ids(_discovered_travel_point_ids),
	}


# 正式 Demo program 只读快照供地图、兼容迁移和测试使用；实际切房仍由房间 signal 决定。
func get_formal_demo_room_program_snapshot() -> Dictionary:
	var program := _get_formal_demo_room_program()
	var formal_ids: Array[String] = []
	var formal_paths: Array[String] = []
	var formal_rooms: Variant = program.get("formal_rooms", [])
	if formal_rooms is Array:
		for room_definition: Variant in formal_rooms:
			if not (room_definition is Dictionary):
				continue
			formal_ids.append(str(room_definition.get("id", "")))
			formal_paths.append(str(room_definition.get("path", "")))
	var merged_rooms: Variant = program.get("merged_rooms", [])
	var reserve_rooms: Variant = program.get("reserve_room_paths", [])
	return {
		"program_id": str(program.get("program_id", "")),
		"formal_room_count": formal_paths.size(),
		"reserve_room_count": (merged_rooms.size() if merged_rooms is Array else 0) + (reserve_rooms.size() if reserve_rooms is Array else 0),
		"formal_room_ids": formal_ids,
		"formal_room_paths": formal_paths,
		"formal_main_route": (program.get("formal_main_route", []) as Array).duplicate(),
		"formal_branch_connections": (program.get("formal_branch_connections", []) as Array).duplicate(true),
	}


# 旧房间仍可加载；正式 Continue 遇到 merged / reserve 房间时统一迁移到安全入口。
func resolve_formal_demo_room_entry(room_path: String, spawn_id: StringName) -> Dictionary:
	var program := _get_formal_demo_room_program()
	var formal_rooms: Variant = program.get("formal_rooms", [])
	if formal_rooms is Array:
		for room_definition: Variant in formal_rooms:
			if room_definition is Dictionary and str(room_definition.get("path", "")) == room_path:
				return {
					"status": &"formal",
					"source_path": room_path,
					"room_path": room_path,
					"spawn_id": spawn_id,
				}
	var merged_rooms: Variant = program.get("merged_rooms", [])
	if merged_rooms is Array:
		for merged: Variant in merged_rooms:
			if merged is Dictionary and str(merged.get("source_path", "")) == room_path:
				return {
					"status": &"merged",
					"source_path": room_path,
					"room_path": str(merged.get("target_path", TUTORIAL_ROOM_PATH)),
					"spawn_id": StringName(str(merged.get("target_spawn_id", "tutorial_start"))),
				}
	var reserve_rooms: Variant = program.get("reserve_room_paths", [])
	if reserve_rooms is Array and room_path in reserve_rooms:
		var fallback: Dictionary = program.get("default_fallback", {})
		return {
			"status": &"reserve",
			"source_path": room_path,
			"room_path": str(fallback.get("room_path", TUTORIAL_ROOM_PATH)),
			"spawn_id": StringName(str(fallback.get("spawn_id", "tutorial_start"))),
		}
	return {
		"status": &"unknown",
		"source_path": room_path,
		"room_path": room_path,
		"spawn_id": spawn_id,
	}


# 房间只读查询自身是否确实完成过向前切换；不能用“目标房已访问”替代，否则环路会误开门。
func is_room_forward_route_completed(room_path: String) -> bool:
	return not room_path.is_empty() and _completed_forward_room_paths.has(room_path)


# 解锁 Stage14 空中冲刺，并立即同步到当前房间里已经生成的玩家实例。
func unlock_air_dash() -> void:
	_air_dash_unlocked = true
	var player := _get_runtime_player()
	if player != null and player.has_method("set_air_dash_unlocked"):
		player.call("set_air_dash_unlocked", true)
	_persist_if_session_active()


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
	_persist_if_session_active()


# 查询风印是否已成为本轮可用的第二能力。
func is_wind_seal_unlocked() -> bool:
	return _wind_seal_unlocked


# 玩家只上报跨房选择；两步序列仍由当前玩家实例自己持有。
func _on_player_element_changed(element_id: StringName) -> void:
	_current_element_id = element_id
	_refresh_hud_progress()
	_persist_if_session_active()


func _on_player_stance_changed(stance_id: StringName) -> void:
	_current_stance_id = stance_id
	_refresh_hud_progress()
	_persist_if_session_active()


# 记录 Stage14 回溯收益，使用 reward_id 去重，防止换房或重复触发刷计数。
func collect_stage14_backtrack_reward(reward_id: StringName) -> void:
	if reward_id == StringName() or _stage14_backtrack_reward_ids.has(reward_id):
		return

	_stage14_backtrack_reward_ids[reward_id] = true
	_persist_if_session_active()


# 返回已确认的 Stage14 回溯收益数量，HUD 和主线测试都依赖这个读值。
func get_stage14_backtrack_reward_count() -> int:
	return _stage14_backtrack_reward_ids.size()


# 精确查询单个回访事实，供分散在旧房间的奖励恢复与 F15 主路线门禁使用。
func has_stage14_backtrack_reward(reward_id: StringName) -> bool:
	return reward_id != StringName() and _stage14_backtrack_reward_ids.has(reward_id)


# 记录跨房间探索 / 战斗收益；固定 Build 共用该去重入口，不扩展成物品栏或经济系统。
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
	_persist_if_session_active()


# 驿站悬赏只保留三条固定条目；状态快照同时供榜单、HUD、地图与测试读取。
func get_bounty_board_snapshot() -> Dictionary:
	var entries: Array[Dictionary] = []
	for bounty_id: StringName in BOUNTY_IDS:
		var definition: Dictionary = BOUNTY_DEFINITIONS[bounty_id]
		var state := _get_bounty_state(bounty_id)
		entries.append({
			"id": bounty_id,
			"title": definition.get("title", ""),
			"objective": definition.get("objective", ""),
			"reward": definition.get("reward", ""),
			"icon_id": definition.get("icon_id", StringName()),
			"state": state,
			"state_id": state,
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
		if _turned_in_bounty_ids.size() == BOUNTY_IDS.size():
			call_deferred("_trigger_stage28_all_bounties_story")
	_persist_if_session_active()
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
	_persist_if_session_active()


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
	_persist_if_session_active()
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
		var equipped := _equipped_build_ids.has(build_id)
		entries.append({
			"id": build_id,
			"label": definition.get("label", ""),
			"effect": definition.get("effect", ""),
			"source": definition.get("source", ""),
			"icon_id": definition.get("icon_id", StringName()),
			"state_id": &"equipped" if equipped else &"available",
			"equipped": equipped,
			"slot": _equipped_build_ids.find(build_id) + 1,
		})
	var slots: Array[Dictionary] = []
	for slot_index in range(BUILD_SLOT_LIMIT):
		var equipped_id := _equipped_build_ids[slot_index] if slot_index < _equipped_build_ids.size() else StringName()
		var equipped_definition: Dictionary = BUILD_DEFINITIONS.get(equipped_id, {})
		slots.append({
			"slot": slot_index + 1,
			"state_id": &"equipped" if equipped_id != StringName() else &"empty",
			"build_id": equipped_id,
			"icon_id": equipped_definition.get("icon_id", &"slot_empty"),
		})
	return {
		"entries": entries,
		"slots": slots,
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
	_persist_if_session_active()
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
	_persist_if_session_active()
	return true


# 查询剧情事件是否已在本轮完成。
func has_completed_story_event(event_id: StringName) -> bool:
	return event_id != StringName() and _completed_story_event_ids.has(event_id)


# 标记 Stage15 Boss 已击败；实际胜利房间跳转仍由房间脚本发起。
func mark_stage15_boss_defeated() -> void:
	# Boss 房只报告胜利事件；Main 把它转成 demo 进度快照，供完成房和 HUD 继续读取。
	if _stage15_boss_defeated:
		return
	_stage15_boss_defeated = true
	collect_exploration_reward(BUILD_GUARDIAN_CORE)
	_persist_if_session_active()


# 公开查询 Stage15 Boss 结果，避免完成房直接读取 Main 私有变量。
func is_stage15_boss_defeated() -> bool:
	return _stage15_boss_defeated


# 雷泽首领胜利只通过此入口授予能力、组件和一次性共鸣事件，重复信号不重复发奖。
func mark_stage30_boss_defeated() -> void:
	if _stage30_boss_defeated:
		return

	_stage30_boss_defeated = true
	unlock_thunder_absorption()
	collect_exploration_reward(BUILD_THUNDER_BEAST_CORE)
	trigger_story_event(
		STAGE30_DEMON_RESONANCE_EVENT_ID,
		STAGE30_DEMON_RESONANCE_EVENT_TITLE,
		STAGE30_DEMON_RESONANCE_EVENT_BODY
	)
	_persist_if_session_active()


func is_stage30_boss_defeated() -> bool:
	return _stage30_boss_defeated


# 妖雷吸收是独立能力读值；Main 负责跨房保存并注入当前玩家。
func unlock_thunder_absorption() -> void:
	if _thunder_absorption_unlocked:
		return
	_thunder_absorption_unlocked = true
	var player := _get_runtime_player()
	if player != null and player.has_method("set_thunder_absorption_unlocked"):
		player.call("set_thunder_absorption_unlocked", true)
	_refresh_hud_progress()
	_persist_if_session_active()


func is_thunder_absorption_unlocked() -> bool:
	return _thunder_absorption_unlocked


# 标记 Stage16 Alpha Demo 已完成；终点房或专项测试通过这个接口写入 Main 快照。
func mark_stage16_alpha_demo_completed() -> void:
	_stage16_alpha_demo_completed = true
	_is_demo_completed = true
	_refresh_hud_progress()
	_persist_if_session_active()


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


# Stage31 固定一个 version 1 单档；测试只能覆写到 user:// 内的独立 JSON，避免污染真人档。
func set_save_paths_for_testing(save_path: String, backup_path: String) -> bool:
	if (
		not _is_safe_user_json_path(save_path)
		or not _is_safe_user_json_path(backup_path)
		or save_path == backup_path
	):
		return false
	_save_file_path = save_path
	_backup_save_file_path = backup_path
	_save_paths_overridden = true
	_persistence_session_active = true
	return true


# 直接序列化 Main 已持有的权威字段，不创建第二份 SaveGame 领域对象。
func build_save_snapshot() -> Dictionary:
	var checkpoint_room_path := _checkpoint_room_path if not _checkpoint_room_path.is_empty() else _current_room_path
	var checkpoint_spawn_id := _checkpoint_spawn_id if _checkpoint_spawn_id != StringName() else _current_spawn_id
	return {
		"version": SAVE_VERSION,
		"checkpoint": {
			"room_path": checkpoint_room_path,
			"spawn_id": String(checkpoint_spawn_id),
		},
		"progress": {
			"short_chain_completed": _is_short_chain_completed,
			"demo_completed": _is_demo_completed,
			"air_dash_unlocked": _air_dash_unlocked,
			"wind_seal_unlocked": _wind_seal_unlocked,
			"thunder_absorption_unlocked": _thunder_absorption_unlocked,
			"current_element_id": String(_current_element_id),
			"current_stance_id": String(_current_stance_id),
			"stage14_backtrack_reward_ids": _sorted_string_ids(_stage14_backtrack_reward_ids),
			"exploration_reward_ids": _sorted_string_ids(_exploration_reward_ids),
			"accepted_bounty_ids": _sorted_string_ids(_accepted_bounty_ids),
			"completed_bounty_ids": _sorted_string_ids(_completed_bounty_ids),
			"turned_in_bounty_ids": _sorted_string_ids(_turned_in_bounty_ids),
			"active_build_id": String(_active_build_id),
			"equipped_build_ids": _string_name_array_to_strings(_equipped_build_ids),
			"completed_story_event_ids": _sorted_string_ids(_completed_story_event_ids),
			"visited_room_paths": _sorted_string_ids(_visited_room_paths),
			"completed_forward_room_paths": _sorted_string_ids(_completed_forward_room_paths),
			"stage15_boss_defeated": _stage15_boss_defeated,
			"stage30_boss_defeated": _stage30_boss_defeated,
			"stage16_alpha_demo_completed": _stage16_alpha_demo_completed,
		},
		"travel_point_ids": _sorted_string_ids(_discovered_travel_point_ids),
	}


# 应用前先把整份输入校验并规范化；失败时不会清理或覆盖当前进度。
func apply_save_snapshot(candidate: Variant) -> Dictionary:
	var validation := _validate_save_snapshot(candidate)
	if not bool(validation.get("ok", false)):
		return validation

	var snapshot: Dictionary = validation.get("snapshot", {})
	var checkpoint: Dictionary = snapshot.get("checkpoint", {})
	var progress: Dictionary = snapshot.get("progress", {})
	_reset_demo_runtime_state()
	_is_short_chain_completed = bool(progress.get("short_chain_completed", false))
	_is_demo_completed = bool(progress.get("demo_completed", false))
	_air_dash_unlocked = bool(progress.get("air_dash_unlocked", false))
	_wind_seal_unlocked = bool(progress.get("wind_seal_unlocked", false))
	_thunder_absorption_unlocked = bool(progress.get("thunder_absorption_unlocked", false))
	_current_element_id = StringName(str(progress.get("current_element_id", ELEMENT_THUNDER)))
	_current_stance_id = StringName(str(progress.get("current_stance_id", STANCE_SWIFT)))
	_stage14_backtrack_reward_ids = _dictionary_from_string_ids(progress.get("stage14_backtrack_reward_ids", []))
	_exploration_reward_ids = _dictionary_from_string_ids(progress.get("exploration_reward_ids", []))
	_accepted_bounty_ids = _dictionary_from_string_ids(progress.get("accepted_bounty_ids", []))
	_completed_bounty_ids = _dictionary_from_string_ids(progress.get("completed_bounty_ids", []))
	_turned_in_bounty_ids = _dictionary_from_string_ids(progress.get("turned_in_bounty_ids", []))
	_completed_story_event_ids = _dictionary_from_string_ids(progress.get("completed_story_event_ids", []))
	_visited_room_paths = _dictionary_from_string_ids(progress.get("visited_room_paths", []))
	_completed_forward_room_paths = _dictionary_from_string_ids(progress.get("completed_forward_room_paths", []))
	_discovered_travel_point_ids = _dictionary_from_string_ids(snapshot.get("travel_point_ids", []))
	_equipped_build_ids.clear()
	for build_id: Variant in progress.get("equipped_build_ids", []):
		_equipped_build_ids.append(StringName(str(build_id)))
	_active_build_id = StringName(str(progress.get("active_build_id", "")))
	_stage15_boss_defeated = bool(progress.get("stage15_boss_defeated", false))
	_stage30_boss_defeated = bool(progress.get("stage30_boss_defeated", false))
	_stage16_alpha_demo_completed = bool(progress.get("stage16_alpha_demo_completed", false))
	var resolved_checkpoint := resolve_formal_demo_room_entry(
		str(checkpoint.get("room_path", TUTORIAL_ROOM_PATH)),
		StringName(str(checkpoint.get("spawn_id", "tutorial_start")))
	)
	_checkpoint_room_path = str(resolved_checkpoint.get("room_path", TUTORIAL_ROOM_PATH))
	_checkpoint_spawn_id = StringName(resolved_checkpoint.get("spawn_id", &"tutorial_start"))

	var player := _get_runtime_player()
	if player != null:
		_bind_runtime_dependencies(player)
	_refresh_hud_progress()
	return {
		"ok": true,
		"code": &"applied",
		"message": "存档状态已应用。",
		"snapshot": build_save_snapshot(),
	}


# 写入顺序：新档 temp 校验 -> 旧主档备份 -> 替换主档；任一步失败都不覆盖未轮换的有效档。
func save_game() -> Dictionary:
	if not _persistence_session_active:
		return _save_result(false, &"inactive", "当前会话未启用正式存档。")
	if not _can_write_persistence():
		return _save_result(true, &"test_write_skipped", "GUT 默认路径写入已跳过。", {"skipped": true})

	var snapshot := build_save_snapshot()
	var temp_path := _save_file_path + ".tmp"
	_remove_file_if_present(temp_path)
	var write_error := _write_text_file(temp_path, JSON.stringify(snapshot, "\t"))
	if write_error != OK:
		return _record_save_result(_save_result(false, &"write_failed", "无法写入临时存档。", {"error": write_error}))
	var temp_validation := _read_save_file(temp_path)
	if not bool(temp_validation.get("ok", false)):
		_remove_file_if_present(temp_path)
		return _record_save_result(_save_result(false, &"temp_invalid", "临时存档回读校验失败。"))

	var current := _read_save_file(_save_file_path)
	if bool(current.get("ok", false)):
		var backup_temp_path := _backup_save_file_path + ".tmp"
		_remove_file_if_present(backup_temp_path)
		var backup_text := JSON.stringify(current.get("snapshot", {}), "\t")
		var backup_write_error := _write_text_file(backup_temp_path, backup_text)
		if backup_write_error != OK or not bool(_read_save_file(backup_temp_path).get("ok", false)):
			_remove_file_if_present(backup_temp_path)
			_remove_file_if_present(temp_path)
			return _record_save_result(_save_result(false, &"backup_failed", "上一有效档无法安全轮换，已保留当前主档。"))
		var backup_remove_error := _remove_file_if_present(_backup_save_file_path)
		if backup_remove_error != OK:
			_remove_file_if_present(backup_temp_path)
			_remove_file_if_present(temp_path)
			return _record_save_result(_save_result(false, &"backup_replace_failed", "旧备份无法替换，已保留当前主档。"))
		var backup_rename_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(backup_temp_path),
			ProjectSettings.globalize_path(_backup_save_file_path)
		)
		if backup_rename_error != OK:
			_remove_file_if_present(temp_path)
			return _record_save_result(_save_result(false, &"backup_replace_failed", "新备份无法就位，已保留当前主档。"))

	var main_remove_error := _remove_file_if_present(_save_file_path)
	if main_remove_error != OK:
		_remove_file_if_present(temp_path)
		return _record_save_result(_save_result(false, &"replace_failed", "主存档无法替换。"))
	var rename_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temp_path),
		ProjectSettings.globalize_path(_save_file_path)
	)
	if rename_error != OK:
		return _record_save_result(_save_result(false, &"replace_failed", "临时存档无法切换为主档；备份仍保留。"))
	var final_validation := _read_save_file(_save_file_path)
	if not bool(final_validation.get("ok", false)):
		return _record_save_result(_save_result(false, &"final_invalid", "主存档写入后校验失败；可继续使用备份。"))
	return _record_save_result(_save_result(true, &"saved", "进度已保存。"))


# 主菜单只检查有效性；真正应用状态只发生在 Continue 点击之后。
func get_save_status_snapshot() -> Dictionary:
	var selected := _select_valid_save()
	if bool(selected.get("ok", false)):
		var from_backup := StringName(selected.get("source", &"primary")) == &"backup"
		return {
			"valid": true,
			"source": selected.get("source", &"primary"),
			"from_backup": from_backup,
			"corrupted_primary": bool(selected.get("corrupted_primary", false)),
			"message": "主档损坏，可从上一有效备份继续。" if from_backup else "检测到有效本地存档。",
		}
	var corrupted := FileAccess.file_exists(_save_file_path) or FileAccess.file_exists(_backup_save_file_path)
	return {
		"valid": false,
		"source": &"none",
		"from_backup": false,
		"corrupted_primary": corrupted,
		"code": selected.get("code", &"missing"),
		"message": "存档损坏或版本不受支持，可安全开始新游戏。" if corrupted else "尚无本地存档。",
	}


func continue_saved_game() -> Dictionary:
	var selected := _select_valid_save()
	if not bool(selected.get("ok", false)):
		return _save_result(false, selected.get("code", &"invalid_save"), "没有可继续的有效存档。")
	var previous_session_active := _persistence_session_active
	_persistence_session_active = false
	var applied := apply_save_snapshot(selected.get("snapshot", {}))
	if not bool(applied.get("ok", false)):
		_persistence_session_active = previous_session_active
		return applied
	var checkpoint: Dictionary = (selected.get("snapshot", {}) as Dictionary).get("checkpoint", {})
	_change_room(
		str(checkpoint.get("room_path", TUTORIAL_ROOM_PATH)),
		StringName(str(checkpoint.get("spawn_id", "tutorial_start"))),
		true
	)
	_persistence_session_active = true
	get_tree().paused = false
	_last_save_result = _save_result(
		true,
		&"continued_from_backup" if StringName(selected.get("source", &"primary")) == &"backup" else &"continued",
		"已从上一有效备份继续。" if StringName(selected.get("source", &"primary")) == &"backup" else "已继续本地进度。"
	)
	return _last_save_result.duplicate(true)


# 传送只开放固定两点；目标发现、起点位置和传送前保存缺一不可。
func get_waystation_travel_snapshot(status_message := "") -> Dictionary:
	var current_id := _get_current_travel_point_id()
	var entries: Array[Dictionary] = []
	var can_travel := false
	for travel_id: StringName in TRAVEL_POINT_IDS:
		var definition: Dictionary = TRAVEL_POINT_DEFINITIONS[travel_id]
		var discovered := _discovered_travel_point_ids.has(travel_id)
		var is_current := travel_id == current_id
		if current_id != StringName() and discovered and not is_current:
			can_travel = true
		entries.append({
			"id": travel_id,
			"label": definition.get("label", "未知驿站"),
			"room_path": definition.get("room_path", ""),
			"spawn_id": definition.get("spawn_id", StringName()),
			"icon_id": definition.get("icon_id", &"travel_locked"),
			"discovered": discovered,
			"current": is_current,
			"state_id": &"current" if is_current else (&"available" if discovered else &"locked"),
		})
	return {
		"entries": entries,
		"current_travel_point_id": current_id,
		"discovered_count": _discovered_travel_point_ids.size(),
		"can_travel": can_travel,
		"status_message": status_message,
	}


func request_waystation_travel(target_id: StringName) -> Dictionary:
	var current_id := _get_current_travel_point_id()
	if current_id == StringName():
		return _travel_result(false, &"invalid_origin", "只能在镇妖驿站或雷泽前哨传送。")
	if target_id not in TRAVEL_POINT_IDS or target_id == current_id:
		return _travel_result(false, &"invalid_target", "请选择另一处固定驿站。")
	if not _discovered_travel_point_ids.has(target_id):
		return _travel_result(false, &"undiscovered", "目标驿站尚未发现。")
	var pre_save := save_game()
	if not bool(pre_save.get("ok", false)):
		return _travel_result(false, &"save_failed", "传送前保存失败，位置保持不变。")

	var definition: Dictionary = TRAVEL_POINT_DEFINITIONS[target_id]
	_change_room(
		str(definition.get("room_path", "")),
		StringName(definition.get("spawn_id", StringName())),
		true
	)
	_refresh_hud_progress()
	return _travel_result(true, &"traveled", "已抵达%s。" % definition.get("label", "目标驿站"))


func _validate_save_snapshot(candidate: Variant) -> Dictionary:
	if not (candidate is Dictionary):
		return _invalid_save(&"invalid_root", "存档根节点必须是字典。")
	var root: Dictionary = candidate
	var version_value: Variant = root.get("version", null)
	if typeof(version_value) not in [TYPE_INT, TYPE_FLOAT]:
		return _invalid_save(&"invalid_version", "存档版本字段类型错误。")
	if float(version_value) != float(int(version_value)) or int(version_value) != SAVE_VERSION:
		return _invalid_save(&"unsupported_version", "存档版本不受支持。")
	if not (root.get("checkpoint", null) is Dictionary) or not (root.get("progress", null) is Dictionary):
		return _invalid_save(&"invalid_sections", "存档缺少 checkpoint 或 progress。")
	if not (root.get("travel_point_ids", null) is Array):
		return _invalid_save(&"invalid_travel_points", "传送点字段类型错误。")

	var checkpoint: Dictionary = root.get("checkpoint", {})
	var progress: Dictionary = root.get("progress", {})
	for key: String in ["room_path", "spawn_id"]:
		if not checkpoint.has(key) or typeof(checkpoint[key]) not in [TYPE_STRING, TYPE_STRING_NAME]:
			return _invalid_save(&"invalid_checkpoint", "checkpoint 字段类型错误。")
	var checkpoint_room_path := str(checkpoint.get("room_path", ""))
	var checkpoint_spawn_id := str(checkpoint.get("spawn_id", ""))
	if not _is_safe_room_path(checkpoint_room_path) or checkpoint_spawn_id.is_empty():
		return _invalid_save(&"unsafe_checkpoint", "checkpoint 路径或出生点无效。")
	var resolved_checkpoint := resolve_formal_demo_room_entry(checkpoint_room_path, StringName(checkpoint_spawn_id))
	checkpoint_room_path = str(resolved_checkpoint.get("room_path", checkpoint_room_path))
	checkpoint_spawn_id = str(resolved_checkpoint.get("spawn_id", checkpoint_spawn_id))

	for field: String in SAVE_BOOLEAN_FIELDS:
		if not progress.has(field) or typeof(progress[field]) != TYPE_BOOL:
			return _invalid_save(&"invalid_field_type", "%s 字段类型错误。" % field)
	for field: String in ["current_element_id", "current_stance_id", "active_build_id"]:
		if not progress.has(field) or typeof(progress[field]) not in [TYPE_STRING, TYPE_STRING_NAME]:
			return _invalid_save(&"invalid_field_type", "%s 字段类型错误。" % field)

	var stage14 := _sanitize_id_array(progress.get("stage14_backtrack_reward_ids", null), STAGE14_REWARD_IDS)
	var exploration := _sanitize_id_array(progress.get("exploration_reward_ids", null), SAVE_EXPLORATION_REWARD_IDS)
	var accepted := _sanitize_id_array(progress.get("accepted_bounty_ids", null), BOUNTY_IDS)
	var completed := _sanitize_id_array(progress.get("completed_bounty_ids", null), BOUNTY_IDS)
	var turned_in := _sanitize_id_array(progress.get("turned_in_bounty_ids", null), BOUNTY_IDS)
	var equipped := _sanitize_id_array(progress.get("equipped_build_ids", null), BUILD_REWARD_IDS)
	var story := _sanitize_id_array(progress.get("completed_story_event_ids", null), STORY_EVENT_IDS)
	var travel := _sanitize_id_array(root.get("travel_point_ids", null), TRAVEL_POINT_IDS)
	for result: Dictionary in [stage14, exploration, accepted, completed, turned_in, equipped, story, travel]:
		if not bool(result.get("ok", false)):
			return result
	var visited := _sanitize_room_path_array(progress.get("visited_room_paths", null))
	if not bool(visited.get("ok", false)):
		return visited
	# 旧版 v1 存档没有该字段时按空集合加载，保持现有存档向后兼容。
	var completed_forward := _sanitize_room_path_array(progress.get("completed_forward_room_paths", []))
	if not bool(completed_forward.get("ok", false)):
		return completed_forward

	var accepted_ids: Array = accepted.get("values", [])
	var completed_ids: Array = completed.get("values", [])
	var turned_in_ids: Array = turned_in.get("values", [])
	for bounty_id: Variant in completed_ids:
		if bounty_id not in accepted_ids:
			return _invalid_save(&"invalid_bounty_state", "完成悬赏必须先处于已接取状态。")
	for bounty_id: Variant in turned_in_ids:
		if bounty_id not in completed_ids:
			return _invalid_save(&"invalid_bounty_state", "回交悬赏必须先处于已完成状态。")

	var exploration_ids: Array = exploration.get("values", [])
	var wind_seal_unlocked := bool(progress.get("wind_seal_unlocked", false))
	if wind_seal_unlocked and String(WIND_SEAL_REWARD_ID) not in exploration_ids:
		exploration_ids.append(String(WIND_SEAL_REWARD_ID))
	if String(WIND_SEAL_REWARD_ID) in exploration_ids:
		wind_seal_unlocked = true
	var stage15_defeated := bool(progress.get("stage15_boss_defeated", false))
	var stage30_defeated := bool(progress.get("stage30_boss_defeated", false))
	var thunder_absorption_unlocked := bool(progress.get("thunder_absorption_unlocked", false)) or stage30_defeated
	if stage15_defeated and String(BUILD_GUARDIAN_CORE) not in exploration_ids:
		exploration_ids.append(String(BUILD_GUARDIAN_CORE))
	if String(BOUNTY_CASTER_HUNT) in turned_in_ids and String(BUILD_CASTER_CORE) not in exploration_ids:
		exploration_ids.append(String(BUILD_CASTER_CORE))
	if stage30_defeated and String(BUILD_THUNDER_BEAST_CORE) not in exploration_ids:
		exploration_ids.append(String(BUILD_THUNDER_BEAST_CORE))
	exploration_ids.sort()

	var equipped_ids: Array = []
	for build_id: Variant in equipped.get("values", []):
		if build_id in exploration_ids and equipped_ids.size() < BUILD_SLOT_LIMIT:
			equipped_ids.append(build_id)
	var active_build_id := str(progress.get("active_build_id", ""))
	if active_build_id not in equipped_ids:
		active_build_id = str(equipped_ids[0]) if not equipped_ids.is_empty() else ""
	var current_element_id := str(progress.get("current_element_id", String(ELEMENT_THUNDER)))
	if current_element_id not in [String(ELEMENT_THUNDER), String(ELEMENT_WIND)] or (current_element_id == String(ELEMENT_WIND) and not wind_seal_unlocked):
		current_element_id = String(ELEMENT_THUNDER)
	var current_stance_id := str(progress.get("current_stance_id", String(STANCE_SWIFT)))
	if current_stance_id not in [String(STANCE_SWIFT), String(STANCE_WARD)]:
		current_stance_id = String(STANCE_SWIFT)

	var visited_paths: Array = visited.get("values", [])
	if checkpoint_room_path not in visited_paths:
		visited_paths.append(checkpoint_room_path)
	visited_paths.sort()
	var travel_ids: Array = travel.get("values", [])
	for travel_id: StringName in TRAVEL_POINT_IDS:
		var definition: Dictionary = TRAVEL_POINT_DEFINITIONS[travel_id]
		if str(definition.get("room_path", "")) in visited_paths and String(travel_id) not in travel_ids:
			travel_ids.append(String(travel_id))
	travel_ids.sort()

	var stage16_completed := bool(progress.get("stage16_alpha_demo_completed", false))
	return {
		"ok": true,
		"snapshot": {
			"version": SAVE_VERSION,
			"checkpoint": {
				"room_path": checkpoint_room_path,
				"spawn_id": checkpoint_spawn_id,
			},
			"progress": {
				"short_chain_completed": bool(progress.get("short_chain_completed", false)),
				"demo_completed": bool(progress.get("demo_completed", false)) or stage16_completed,
				"air_dash_unlocked": bool(progress.get("air_dash_unlocked", false)),
				"wind_seal_unlocked": wind_seal_unlocked,
				"thunder_absorption_unlocked": thunder_absorption_unlocked,
				"current_element_id": current_element_id,
				"current_stance_id": current_stance_id,
				"stage14_backtrack_reward_ids": stage14.get("values", []),
				"exploration_reward_ids": exploration_ids,
				"accepted_bounty_ids": accepted_ids,
				"completed_bounty_ids": completed_ids,
				"turned_in_bounty_ids": turned_in_ids,
				"active_build_id": active_build_id,
				"equipped_build_ids": equipped_ids,
				"completed_story_event_ids": story.get("values", []),
				"visited_room_paths": visited_paths,
				"completed_forward_room_paths": completed_forward.get("values", []),
				"stage15_boss_defeated": stage15_defeated,
				"stage30_boss_defeated": stage30_defeated,
				"stage16_alpha_demo_completed": stage16_completed,
			},
			"travel_point_ids": travel_ids,
		},
	}


func _sanitize_id_array(value: Variant, allowed_ids: Array[StringName]) -> Dictionary:
	if not (value is Array):
		return _invalid_save(&"invalid_array", "存档 ID 列表类型错误。")
	var values: Array[String] = []
	for raw_id: Variant in value:
		if typeof(raw_id) not in [TYPE_STRING, TYPE_STRING_NAME]:
			return _invalid_save(&"invalid_id_type", "存档 ID 类型错误。")
		var resolved_id := StringName(str(raw_id))
		if resolved_id in allowed_ids and String(resolved_id) not in values:
			values.append(String(resolved_id))
	values.sort()
	return {"ok": true, "values": values}


func _sanitize_room_path_array(value: Variant) -> Dictionary:
	if not (value is Array):
		return _invalid_save(&"invalid_room_list", "已发现房间列表类型错误。")
	var paths: Array[String] = []
	for raw_path: Variant in value:
		if typeof(raw_path) not in [TYPE_STRING, TYPE_STRING_NAME]:
			return _invalid_save(&"invalid_room_path", "已发现房间路径类型错误。")
		var room_path := str(raw_path)
		if not _is_safe_room_path(room_path):
			return _invalid_save(&"unsafe_room_path", "存档包含越界或不存在的房间路径。")
		if room_path not in paths:
			paths.append(room_path)
	paths.sort()
	return {"ok": true, "values": paths}


func _read_save_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _invalid_save(&"missing", "存档文件不存在。")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _invalid_save(&"read_failed", "存档文件无法读取。")
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK:
		return _invalid_save(&"corrupted_json", "存档 JSON 损坏。")
	var validation := _validate_save_snapshot(json.data)
	if bool(validation.get("ok", false)):
		validation["path"] = path
	return validation


func _select_valid_save() -> Dictionary:
	var primary := _read_save_file(_save_file_path)
	if bool(primary.get("ok", false)):
		primary["source"] = &"primary"
		return primary
	var backup := _read_save_file(_backup_save_file_path)
	if bool(backup.get("ok", false)):
		backup["source"] = &"backup"
		backup["corrupted_primary"] = FileAccess.file_exists(_save_file_path)
		return backup
	return primary if FileAccess.file_exists(_save_file_path) else backup


func _write_text_file(path: String, text: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.flush()
	return file.get_error()


func _remove_file_if_present(path: String) -> Error:
	if not FileAccess.file_exists(path):
		return OK
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _persist_if_session_active() -> void:
	if _persistence_session_active and _can_write_persistence():
		save_game()


func _can_write_persistence() -> bool:
	if _save_paths_overridden:
		return true
	return get_tree() == null or get_tree().root.find_child("GutRunner", true, false) == null


func _record_save_result(result: Dictionary) -> Dictionary:
	_last_save_result = result.duplicate(true)
	if demo_shell != null and demo_shell.has_method("refresh_save_state"):
		demo_shell.call("refresh_save_state")
	return result


func _save_result(ok: bool, code: StringName, message: String, extra: Dictionary = {}) -> Dictionary:
	var result := {"ok": ok, "code": code, "message": message}
	result.merge(extra, true)
	return result


func _travel_result(ok: bool, code: StringName, message: String) -> Dictionary:
	var result := get_waystation_travel_snapshot(message)
	result.merge({"ok": ok, "code": code, "message": message}, true)
	return result


func _invalid_save(code: StringName, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message}


func _is_safe_room_path(path: String) -> bool:
	return (
		not path.is_empty()
		and not path.contains("..")
		and not path.contains("\\")
		and path.begins_with("res://scenes/rooms/")
		and path.ends_with(".tscn")
		and ResourceLoader.exists(path)
	)


func _is_safe_user_json_path(path: String) -> bool:
	return (
		path.begins_with("user://")
		and path.ends_with(".json")
		and not path.contains("..")
		and not path.contains("\\")
	)


func _sorted_string_ids(values: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for raw_id: Variant in values.keys():
		result.append(str(raw_id))
	result.sort()
	return result


func _string_name_array_to_strings(values: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for value: StringName in values:
		result.append(String(value))
	return result


func _dictionary_from_string_ids(values: Array) -> Dictionary:
	var result := {}
	for value: Variant in values:
		result[StringName(str(value))] = true
	return result


func _get_current_travel_point_id() -> StringName:
	for travel_id: StringName in TRAVEL_POINT_IDS:
		var definition: Dictionary = TRAVEL_POINT_DEFINITIONS[travel_id]
		if str(definition.get("room_path", "")) == _current_room_path:
			return travel_id
	return StringName()


# 首次进入固定驿站即登记发现并把恢复点收敛到该站的稳定 spawn。
func _register_travel_point_for_room(room_path: String) -> bool:
	for travel_id: StringName in TRAVEL_POINT_IDS:
		var definition: Dictionary = TRAVEL_POINT_DEFINITIONS[travel_id]
		if str(definition.get("room_path", "")) != room_path:
			continue
		var changed := not _discovered_travel_point_ids.has(travel_id)
		_discovered_travel_point_ids[travel_id] = true
		var spawn_id := StringName(definition.get("spawn_id", StringName()))
		if _checkpoint_room_path != room_path or _checkpoint_spawn_id != spawn_id:
			changed = true
		_checkpoint_room_path = room_path
		_checkpoint_spawn_id = spawn_id
		return changed
	return false


# 房间切换逻辑必须同时覆盖：首次进入、同房间重生，以及真正的场景替换。
func _change_room(room_path: String, spawn_id: StringName, force_reload := false) -> void:
	var room_scene: PackedScene = load(room_path) as PackedScene
	if room_scene == null:
		return

	# 新玩家生成后的极短窗口可能仍处在接触重建/画面切换帧；只跳过该瞬态，随后恢复正常跌落判定。
	_room_entry_fall_guard_remaining = ROOM_ENTRY_FALL_GUARD_DURATION

	if room == null:
		room = get_node_or_null("Room") as Node2D

	_current_room_path = room_path
	_current_spawn_id = spawn_id
	_visited_room_paths[room_path] = true
	var travel_progress_changed := _register_travel_point_for_room(room_path)

	if not force_reload and room != null and room.scene_file_path == room_path:
		_bind_room_signals()
		_spawn_placeholder_player(spawn_id)
		_queue_room_entry_story(room_path, spawn_id)
		if travel_progress_changed:
			_persist_if_session_active()
		return

	if room != null:
		_disconnect_room_signals(room)
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
	_queue_room_entry_story(room_path, spawn_id)
	if travel_progress_changed:
		_persist_if_session_active()


func _queue_room_entry_story(room_path: String, spawn_id: StringName) -> void:
	if room_path == STAGE11_DEMO_END_ROOM_PATH and spawn_id == &"stage11_thunder_waste_return":
		call_deferred("_trigger_stage28_thunder_return_story")


func _trigger_stage28_all_bounties_story() -> void:
	trigger_story_event(
		STAGE28_ALL_BOUNTIES_EVENT_ID,
		STAGE28_ALL_BOUNTIES_EVENT_TITLE,
		STAGE28_ALL_BOUNTIES_EVENT_BODY
	)


func _trigger_stage28_thunder_return_story() -> void:
	trigger_story_event(
		STAGE28_THUNDER_RETURN_EVENT_ID,
		STAGE28_THUNDER_RETURN_EVENT_TITLE,
		STAGE28_THUNDER_RETURN_EVENT_BODY
	)


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


# 旧房间 queue_free 前先断开指向 Main 的回调，避免延迟 checkpoint / 出口信号覆盖新房间状态。
func _disconnect_room_signals(source_room: Node) -> void:
	_disconnect_signal_if_connected(source_room, &"room_transition_requested", &"_on_room_transition_requested")
	_disconnect_signal_if_connected(source_room, &"goal_completed", &"_on_goal_completed")
	_disconnect_signal_if_connected(source_room, &"checkpoint_requested", &"_on_checkpoint_requested")
	_disconnect_signal_if_connected(source_room, &"bounty_board_requested", &"_on_bounty_board_requested")
	for child: Node in source_room.get_children():
		_disconnect_signal_if_connected(child, &"defeated", &"_on_bounty_caster_defeated")
		_disconnect_signal_if_connected(child, &"sequence_disrupted", &"_on_bounty_pulse_disrupted")


func _disconnect_signal_if_connected(source: Node, signal_name: StringName, method_name: StringName) -> void:
	var callback := Callable(self, method_name)
	if source.has_signal(signal_name) and source.is_connected(signal_name, callback):
		source.disconnect(signal_name, callback)


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

	_register_completed_forward_route(target_room_path)
	transition_to_room(target_room_path, spawn_id)


# 只有房间真实请求了它声明的向前目标时才记录完成，避免支路/回程或已访问枢纽造成误判。
func _register_completed_forward_route(target_room_path: String) -> void:
	if room == null or not room.has_method("get_forward_room_path"):
		return
	if str(room.call("get_forward_room_path")) != target_room_path:
		return
	var source_room_path := room.scene_file_path
	if source_room_path.is_empty() or _completed_forward_room_paths.has(source_room_path):
		return

	_completed_forward_room_paths[source_room_path] = true
	_persist_if_session_active()


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


func _get_formal_demo_room_program() -> Dictionary:
	if not _formal_demo_room_program.is_empty():
		return _formal_demo_room_program
	if not FileAccess.file_exists(FORMAL_DEMO_ROOM_PROGRAM_PATH):
		push_error("正式 Demo 房间 program 不存在：%s" % FORMAL_DEMO_ROOM_PROGRAM_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(FORMAL_DEMO_ROOM_PROGRAM_PATH))
	if not (parsed is Dictionary):
		push_error("正式 Demo 房间 program 不是有效 Dictionary：%s" % FORMAL_DEMO_ROOM_PROGRAM_PATH)
		return {}
	_formal_demo_room_program = (parsed as Dictionary).duplicate(true)
	return _formal_demo_room_program


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


# 房间请求 checkpoint 时更新最近恢复点；正式会话再通过统一存档入口落盘。
func _on_checkpoint_requested(room_path: String, spawn_id: StringName) -> void:
	_checkpoint_room_path = room_path
	_checkpoint_spawn_id = spawn_id
	_persist_if_session_active()


# 按固定顺序返回已取得 Build，保证两槽 UI 与测试顺序稳定。
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
			return "目标：确认驿厅通路"
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
			return "提示：左返 / 右进"
		_:
			return ""
