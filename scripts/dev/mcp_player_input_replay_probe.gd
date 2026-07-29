extends Node

# MCP 输入式 replay 探针：只通过 Input action 驱动玩家，不调用房间切换或改玩家坐标。
# ponytail: 简单节拍器足够暴露阻塞点；真导航 AI 等它证明需要再说。

const OUT_DIR := "res://tests/artifacts/local/full-content-demo-qa/mcp_2026_07_01/player_input_replay"
const SCREENSHOT_DIR := "%s/screenshots" % OUT_DIR
const OUT_JSON := "%s/player_input_replay_probe.json" % OUT_DIR
const OUT_MD := "%s/player_input_replay_probe.md" % OUT_DIR

const ROOM_TIMEOUT := 48.0
const TOTAL_TIMEOUT := 480.0
const MID_CAPTURE_DELAY := 4.0
const ELEVATED_ATTACK_PREP_DISTANCE := 72.0

var _main: Node2D
var _running := false
var _finished := false
var _elapsed := 0.0
var _room_elapsed := 0.0
var _current_room_path := ""
var _current_room_id := ""
var _room_index := 0
var _last_player_x := 0.0
var _stuck_elapsed := 0.0
var _mid_captured := false
var _rows: Array[Dictionary] = []
var _issues: Array[Dictionary] = []
var _tap_timers := {"jump": 0.0, "attack": 0.0, "dash": 0.0, "recover": 0.0}
var _tap_active := {"jump": false, "attack": false, "dash": false, "recover": false}
var _objective_jump_hold_remaining := 0.0
var _objective_jump_cooldown_remaining := 0.0
var _start_room_override := ""
var _combat_target: Node2D
var _debug_sample_elapsed := 0.0
var _debug_samples: Array[Dictionary] = []
var _room_objective_phase := 0
var _objective_action_elapsed := 0.0


func start(main: Node2D, start_room_override: String = "") -> void:
	_main = main
	_start_room_override = start_room_override
	_running = true
	_finished = false
	_elapsed = 0.0
	_room_elapsed = 0.0
	_room_index = 0
	_rows.clear()
	_issues.clear()
	_debug_samples.clear()
	_debug_sample_elapsed = 0.0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))
	set_physics_process(true)
	_release_all()
	_enter_current_room("entry")


func is_finished() -> bool:
	return _finished


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not _running or _finished:
		return

	_elapsed += delta
	_room_elapsed += delta
	_drive_input(delta)
	_capture_debug_sample(delta)
	_check_room_change()
	_capture_midpoint()
	_check_completion()
	_check_timeout()


func _drive_input(delta: float) -> void:
	_focus_failure_continue(delta)
	if _drive_room_objective(delta):
		_update_stuck_timer(delta)
		_tick_tap("recover", delta, 2.0)
		return
	if _drive_seal_guardian_boss_combat(delta):
		_update_stuck_timer(delta)
		return
	var enemy := _nearest_active_enemy() if _should_use_combat_steering() else null
	var attack_period := 0.32
	var needs_full_jump := false
	var can_attack_elevated_target := false
	if enemy != null:
		attack_period = _drive_toward_enemy(enemy)
		var player := _player()
		if player != null:
			var vertical_gap := player.global_position.y - _enemy_combat_position(enemy).y
			needs_full_jump = vertical_gap > 40.0
			can_attack_elevated_target = vertical_gap <= ELEVATED_ATTACK_PREP_DISTANCE
	else:
		_set_horizontal_input(1.0)
	_update_stuck_timer(delta)
	if needs_full_jump:
		Input.action_release("dash")
		_tap_active["dash"] = false
		if can_attack_elevated_target:
			_tick_tap("attack", delta, attack_period)
		else:
			Input.action_release("attack")
			_tap_active["attack"] = false
	else:
		_tick_tap("attack", delta, attack_period)
		_tick_tap("dash", delta, 0.58)
	_tick_tap("recover", delta, 2.0)
	if needs_full_jump:
		_tick_objective_jump(delta)
	else:
		_release_objective_jump()
		var jump_period := 0.74 if _stuck_elapsed < 1.2 else 0.36
		_tick_tap("jump", delta, jump_period)


# Boss 输入策略只读取公开状态：预警/出招时后撤，恢复/硬直时靠近跳攻，资源满时发送恢复输入。
func _drive_seal_guardian_boss_combat(delta: float) -> bool:
	var room := _room()
	var player := _player()
	if room == null or player == null or not room.scene_file_path.ends_with("stage15_seal_guardian_boss_room.tscn"):
		return false
	var boss := room.get_node_or_null("SealGuardianBoss") as Node2D
	if boss == null or boss.has_method("is_defeated") and bool(boss.call("is_defeated")):
		return false
	_combat_target = boss
	var state := str(boss.call("get_current_state_id")) if boss.has_method("get_current_state_id") else "idle"
	var dangerous := state in ["close_pressure", "ground_impact", "air_punish"]
	if dangerous:
		var retreat_axis := signf(player.global_position.x - boss.global_position.x)
		var horizontal_distance := absf(player.global_position.x - boss.global_position.x)
		if horizontal_distance < 104.0:
			_set_horizontal_input(retreat_axis if absf(retreat_axis) > 0.1 else -1.0)
		else:
			_set_horizontal_input(0.0)
		Input.action_release("dash")
		_tap_active["dash"] = false
		Input.action_release("attack")
		_tap_active["attack"] = false
		_release_objective_jump()
	else:
		var combat_position := _enemy_combat_position(boss)
		var delta_to_boss := combat_position - player.global_position
		var can_pressure := state in ["recovery", "staggered"]
		var approach_limit := 96.0 if can_pressure else 176.0
		_set_horizontal_input(signf(delta_to_boss.x) if absf(delta_to_boss.x) > approach_limit else 0.0)
		if can_pressure and absf(delta_to_boss.x) > 96.0:
			_tick_tap("dash", delta, 0.08)
		else:
			Input.action_release("dash")
			_tap_active["dash"] = false
		if can_pressure and absf(delta_to_boss.x) <= 96.0:
			var player_state := str(player.call("get_current_state_id")) if player.has_method("get_current_state_id") else ""
			if player_state == "dash":
				_release_objective_jump()
				Input.action_release("attack")
				_tap_active["attack"] = false
			else:
				_tick_objective_jump(delta)
				if player.is_on_floor():
					Input.action_release("attack")
					_tap_active["attack"] = false
				else:
					_tick_tap("attack", delta, 0.12)
		else:
			Input.action_release("attack")
			_tap_active["attack"] = false

	if player.has_method("can_spend_recovery_charge") and player.has_method("get_current_health") and player.has_method("get_max_health"):
		var should_recover := (
			bool(player.call("can_spend_recovery_charge"))
			and int(player.call("get_current_health")) < int(player.call("get_max_health"))
		)
		if should_recover:
			_tick_tap("recover", delta, 0.05)
		else:
			Input.action_release("recover")
			_tap_active["recover"] = false
	return true


# 当前权威关卡存在必须先靠近的上层机关；驱动只在门未开时临时朝真实目标节点导航。
func _drive_room_objective(delta: float) -> bool:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		return false
	if _drive_tutorial_step_route(delta, room):
		return true
	if _drive_goal_trial_route(delta, room, player):
		return true
	if _drive_stage13_goal_route(delta, room, player):
		return true
	if _drive_stage14_air_dash_shrine_route(delta, room, player):
		return true
	if _drive_stage14_air_dash_gate_route(delta, room, player):
		return true
	if _drive_stage14_backtrack_hub_route(delta, room, player):
		return true
	if _drive_stage14_loop_goal_route(delta, room, player):
		return true
	if _drive_stage16_seal_release_route(delta, room, player):
		return true
	if _drive_stage16_talisman_relay_route(delta, room, player):
		return true
	if _drive_stage16_backtrack_confirmation_route(delta, room, player):
		return true
	if _drive_stage16_corruption_purge_route(delta, room, player):
		return true
	if _drive_stage15_pressure_caster_route(delta, room, player):
		return true
	if _drive_stage13_caster_platform_route(delta, room, player):
		return true
	if _drive_stage13_gate_seal_route(delta, room, player):
		return true
	if not room.scene_file_path.ends_with("stage9_zone_switch_room.tscn"):
		return false
	if room.has_method("is_gate_unlocked") and bool(room.call("is_gate_unlocked")):
		return false

	var switch_node := room.get_node_or_null("GateSwitch") as Node2D
	if switch_node == null:
		return false

	# 先在低台右缘站稳并清空上一跳冷却，再从平台间隙完整起跳；避免连续向右输入让角色先跌回下层。
	return _drive_two_level_trigger_ascent(delta, room, player, switch_node, 96.0, 176.0, 1.0, false)


# 教程按公开 step_id 一次只发送一种目标动作，避免 Dash/Attack 抢占必须发生的跳跃输入。
func _drive_tutorial_step_route(delta: float, room: Node2D) -> bool:
	if not room.scene_file_path.ends_with("tutorial_room.tscn") or not room.has_method("get_current_step_id"):
		return false
	var step := str(room.call("get_current_step_id"))
	_set_horizontal_input(1.0)
	match step:
		"move_jump":
			Input.action_release("attack")
			Input.action_release("dash")
			_tap_active["attack"] = false
			_tap_active["dash"] = false
			_tick_objective_jump(delta)
		"dash":
			_release_objective_jump()
			Input.action_release("attack")
			_tap_active["attack"] = false
			_tick_tap("dash", delta, 0.10)
		"attack":
			_release_objective_jump()
			Input.action_release("dash")
			_tap_active["dash"] = false
			_tick_tap("attack", delta, 0.12)
		_:
			Input.action_release("attack")
			Input.action_release("dash")
			_tap_active["attack"] = false
			_tap_active["dash"] = false
			_tick_objective_jump(delta)
	return true


# 目标房清敌后必须完整跳上右侧平台；下层跑到相同 x 坐标不会触发完成判定。
func _drive_goal_trial_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("goal_trial_room.tscn"):
		return false
	if not room.has_method("is_goal_unlocked") or not bool(room.call("is_goal_unlocked")):
		return false
	var goal := room.get_node_or_null("GoalZone") as Node2D
	if goal == null:
		return false
	return _drive_upper_goal_platform(delta, room, player, goal, 568.0, 720.0)


# Stage13 区域终点同样位于上层祭坛，必须登台接近 GoalZone 后才能进入 Stage14。
func _drive_stage13_goal_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage13_miasma_marsh_goal_room.tscn"):
		return false
	var goal := room.get_node_or_null("GoalZone") as Node2D
	if goal == null:
		return false
	return _drive_upper_goal_platform(delta, room, player, goal, 504.0, 672.0)


# 单层上方终点统一采用“下层整备 -> 完整跳跃 -> 上层对准目标”，避免短跳在同一 x 下方误判完成。
func _drive_upper_goal_platform(
	delta: float,
	room: Node2D,
	player: CharacterBody2D,
	goal: Node2D,
	launch_x: float,
	platform_center_x: float
) -> bool:

	Input.action_release("attack")
	Input.action_release("dash")
	_tap_active["attack"] = false
	_tap_active["dash"] = false
	var player_local := room.to_local(player.global_position)
	if player.is_on_floor() and player_local.y <= 150.0:
		_drive_objective_x(player_local.x, goal.position.x, 10.0)
		_release_objective_jump()
		return true

	# 先回到稳定起跳带，再长按跳跃向平台中央推进；失败落地后会自动重整位置。
	if player.is_on_floor() and player_local.y > 150.0:
		if player_local.x < launch_x - 40.0 or player_local.x > launch_x + 40.0:
			_drive_objective_x(player_local.x, launch_x, 12.0)
			_release_objective_jump()
			return true
	_drive_objective_x(player_local.x, platform_center_x, 16.0)
	_tick_objective_jump(delta)
	return true


# Stage14 神龛必须真实授予能力后才能离房，避免输入探针越过平台却把能力门误判为阻塞。
func _drive_stage14_air_dash_shrine_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage14_air_dash_shrine_room.tscn"):
		return false
	if bool(_snapshot().get("air_dash_unlocked", false)):
		return false
	var shrine := room.get_node_or_null("AirDashShrine") as Node2D
	if shrine == null:
		return false
	Input.action_release("attack")
	Input.action_release("dash")
	_tap_active["attack"] = false
	_tap_active["dash"] = false
	var player_local := room.to_local(player.global_position)
	var delta_x := shrine.position.x - player_local.x
	_set_horizontal_input(signf(delta_x) if absf(delta_x) > 18.0 else 0.0)
	_tick_objective_jump(delta)
	return true


# Stage14 能力门复用正式 GUT 的真实输入节奏：两级上行后长按跳跃，再在空中触发一次 Dash。
func _drive_stage14_air_dash_gate_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage14_air_dash_gate_room.tscn"):
		return false
	if not bool(_snapshot().get("air_dash_unlocked", false)):
		return false
	var player_local := room.to_local(player.global_position)
	if player.is_on_floor() and player_local.y > 150.0 and _room_objective_phase >= 1:
		_room_objective_phase = 0
		_objective_action_elapsed = 0.0
		_release_objective_jump()
	if player.is_on_floor() and player_local.y <= 150.0 and player_local.y > 96.0 and _room_objective_phase == 0:
		_room_objective_phase = 1
		_release_objective_jump()
		_objective_jump_cooldown_remaining = 0.08
	if player.is_on_floor() and player_local.y < 96.0 and player_local.x >= 120.0 and player_local.x < 224.0 and _room_objective_phase <= 1:
		_room_objective_phase = 2
		_objective_action_elapsed = -0.08
		_release_objective_jump()
	if player.is_on_floor() and player_local.x > 428.0 and player_local.y < 96.0:
		_room_objective_phase = 5
	if _room_objective_phase >= 5:
		return false

	Input.action_release("attack")
	_tap_active["attack"] = false
	if _room_objective_phase < 2:
		Input.action_release("dash")
		_tap_active["dash"] = false
		if _room_objective_phase == 1:
			_set_horizontal_input(1.0)
			if player.is_on_floor() and player_local.y < 96.0:
				_release_objective_jump()
				return true
			if player_local.x < -160.0:
				_release_objective_jump()
				return true
		else:
			var delta_x := -224.0 - player_local.x
			_set_horizontal_input(signf(delta_x) if absf(delta_x) > 18.0 else 0.0)
		_tick_objective_jump(delta)
		return true

	_set_horizontal_input(1.0)
	_objective_action_elapsed += delta
	if _room_objective_phase == 2:
		if _objective_action_elapsed < 0.0:
			Input.action_release("jump")
			Input.action_release("dash")
			return true
		Input.action_press("jump")
		Input.action_release("dash")
		if _objective_action_elapsed >= 44.0 / 60.0:
			_room_objective_phase = 3
			_objective_action_elapsed = 0.0
	elif _room_objective_phase == 3:
		Input.action_release("jump")
		Input.action_press("dash")
		if _objective_action_elapsed >= 2.0 / 60.0:
			_room_objective_phase = 4
			_objective_action_elapsed = 0.0
	else:
		Input.action_release("jump")
		Input.action_release("dash")
	return true


# Stage14 Hub 与 Stage16 符印中继共享同一套三层正式网格，按真实节点计数顺序完成攀爬。
func _drive_stage14_backtrack_hub_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage14_backtrack_hub_room.tscn"):
		return false
	var count := int(_snapshot().get("stage14_backtrack_reward_count", 0))
	return _drive_three_level_marker_ascent(
		delta,
		room,
		player,
		["BacktrackRewardOne", "BacktrackRewardTwo", "BacktrackRewardThree"],
		count
	)


# Stage16 三符印房复用同一几何路线，激活数量仍从房间公开快照读取。
func _drive_stage16_talisman_relay_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage16_talisman_relay_room.tscn"):
		return false
	var snapshot: Dictionary = room.call("get_stage16_progress_snapshot") if room.has_method("get_stage16_progress_snapshot") else {}
	var count := int(snapshot.get("stage16_talisman_relay_count", 0))
	return _drive_three_level_marker_ascent(
		delta,
		room,
		player,
		["TalismanRelayA", "TalismanRelayB", "TalismanRelayC"],
		count
	)


# Stage16 首房只有一层封印阈值，登台靠近节点后由生产脚本解门。
func _drive_stage16_seal_release_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage16_seal_release_threshold_room.tscn"):
		return false
	if room.has_method("is_gate_unlocked") and bool(room.call("is_gate_unlocked")):
		return false
	var node := room.get_node_or_null("SealReleaseNode") as Node2D
	if node == null:
		return false
	_drive_trigger_node_on_platform(delta, room, player, node, 320.0)
	return true


# 回溯确认房从低台登上高台，节点会自行检查 Main 中的三收益计数。
func _drive_stage16_backtrack_confirmation_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage16_backtrack_confirmation_room.tscn"):
		return false
	if room.has_method("is_gate_unlocked") and bool(room.call("is_gate_unlocked")):
		return false
	var node := room.get_node_or_null("BacktrackConfirmationNode") as Node2D
	if node == null:
		return false
	return _drive_two_level_trigger_ascent(delta, room, player, node, 352.0, 416.0, 1.0, false)


# 净化房从右侧低台反向登上中央高台，避开 192px 左侧大缺口。
func _drive_stage16_corruption_purge_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage16_corruption_purge_room.tscn"):
		return false
	if room.has_method("is_gate_unlocked") and bool(room.call("is_gate_unlocked")):
		return false
	var node := room.get_node_or_null("CorruptionPurgeNode") as Node2D
	if node == null:
		return false
	return _drive_two_level_trigger_ascent(delta, room, player, node, 928.0, 920.0, -1.0, true)


# 单层节点路线统一清理战斗输入，并持续完整跳跃直到玩家真正落在节点平台附近。
func _drive_trigger_node_on_platform(
	delta: float,
	room: Node2D,
	player: CharacterBody2D,
	node: Node2D,
	stage_x: float
) -> void:
	Input.action_release("attack")
	Input.action_release("dash")
	_tap_active["attack"] = false
	_tap_active["dash"] = false
	var player_local := room.to_local(player.global_position)
	_drive_objective_x(player_local.x, stage_x)
	if player.global_position.distance_to(node.global_position) <= 48.0:
		_release_objective_jump()
	else:
		_tick_objective_jump(delta)


# 两层节点路线支持向右或向左起跳；失败落地后会重新登低台，而不会沿旧输入冲向出口。
func _drive_two_level_trigger_ascent(
	delta: float,
	room: Node2D,
	player: CharacterBody2D,
	node: Node2D,
	low_platform_x: float,
	launch_x: float,
	direction: float,
	use_air_dash: bool
) -> bool:
	Input.action_release("attack")
	Input.action_release("dash")
	_tap_active["attack"] = false
	_tap_active["dash"] = false
	var player_local := room.to_local(player.global_position)
	if player.is_on_floor():
		if player_local.y > 150.0:
			_room_objective_phase = 0
		elif player_local.y > 90.0:
			if _room_objective_phase != 3:
				_room_objective_phase = 1 if absf(player_local.x - low_platform_x) <= 192.0 else 0
		else:
			_room_objective_phase = 2
	match _room_objective_phase:
		0:
			_drive_objective_x(player_local.x, low_platform_x)
			_tick_objective_jump(delta)
		1:
			_drive_objective_x(player_local.x, launch_x, 4.0)
			_release_objective_jump()
			var staged := player_local.x >= launch_x - 4.0 if direction > 0.0 else player_local.x <= launch_x + 4.0
			if staged and player.is_on_floor():
				_room_objective_phase = 3
				_objective_action_elapsed = -0.08
				_release_objective_jump()
		3:
			_set_horizontal_input(direction)
			if use_air_dash:
				_objective_action_elapsed += delta
				if _objective_action_elapsed < 0.0:
					Input.action_release("jump")
					Input.action_release("dash")
				elif _objective_action_elapsed < 0.55:
					Input.action_press("jump")
					Input.action_release("dash")
				elif _objective_action_elapsed < 0.60:
					Input.action_release("jump")
					Input.action_press("dash")
				else:
					Input.action_release("jump")
					Input.action_release("dash")
			else:
				_tick_objective_jump(delta)
			if player.is_on_floor() and player_local.y <= 90.0:
				_room_objective_phase = 2
		2:
			_drive_objective_x(player_local.x, node.position.x)
			_release_objective_jump()
	return true


# 三层标记路线只发送移动和跳跃；节点触发、隐藏、计数与开门全部保留给生产房间脚本。
func _drive_three_level_marker_ascent(
	delta: float,
	room: Node2D,
	player: CharacterBody2D,
	marker_names: Array[String],
	collected_count: int
) -> bool:
	if collected_count >= marker_names.size():
		return false
	if collected_count == 0:
		_room_objective_phase = 0
	elif collected_count == 1 and _room_objective_phase < 1:
		_room_objective_phase = 1
	elif collected_count == 2 and _room_objective_phase < 3:
		_room_objective_phase = 3

	Input.action_release("attack")
	Input.action_release("dash")
	_tap_active["attack"] = false
	_tap_active["dash"] = false
	var player_local := room.to_local(player.global_position)
	match _room_objective_phase:
		0:
			_drive_objective_x(player_local.x, 128.0)
			_tick_objective_jump(delta)
		1:
			if player.is_on_floor() and player_local.y > 220.0:
				_drive_objective_x(player_local.x, 128.0)
				_tick_objective_jump(delta)
			elif player.is_on_floor() and player_local.y > 150.0:
				_drive_objective_x(player_local.x, 276.0, 4.0)
				_release_objective_jump()
				if player_local.x >= 272.0:
					_room_objective_phase = 2
					_objective_jump_cooldown_remaining = 0.08
			else:
				_drive_objective_x(player_local.x, 276.0)
				_tick_objective_jump(delta)
		2:
			if player.is_on_floor() and player_local.y > 220.0:
				_room_objective_phase = 1
				_drive_objective_x(player_local.x, 128.0)
				_tick_objective_jump(delta)
				return true
			_drive_objective_x(player_local.x, 512.0)
			if player.is_on_floor() and player_local.y <= 150.0:
				_release_objective_jump()
			else:
				_tick_objective_jump(delta)
		3:
			if player.is_on_floor() and player_local.y > 150.0:
				_room_objective_phase = 5
				_drive_objective_x(player_local.x, 128.0)
				_tick_objective_jump(delta)
				return true
			if player.is_on_floor() and player_local.y > 90.0:
				_drive_objective_x(player_local.x, 656.0, 4.0)
				_release_objective_jump()
				if player_local.x >= 652.0:
					_room_objective_phase = 4
					_objective_jump_cooldown_remaining = 0.08
			else:
				_drive_objective_x(player_local.x, 656.0)
				_tick_objective_jump(delta)
		4:
			if player.is_on_floor() and player_local.y > 150.0:
				_room_objective_phase = 5
				_drive_objective_x(player_local.x, 128.0)
				_tick_objective_jump(delta)
				return true
			_drive_objective_x(player_local.x, 896.0)
			if player.is_on_floor() and player_local.y <= 90.0:
				_release_objective_jump()
			else:
				_tick_objective_jump(delta)
		5:
			if player.is_on_floor() and player_local.y > 220.0:
				_drive_objective_x(player_local.x, 128.0)
				_tick_objective_jump(delta)
			elif player.is_on_floor() and player_local.y > 150.0:
				_drive_objective_x(player_local.x, 276.0, 4.0)
				_release_objective_jump()
				if player_local.x >= 272.0:
					_room_objective_phase = 6
					_objective_jump_cooldown_remaining = 0.08
			elif player.is_on_floor():
				_room_objective_phase = 3
			else:
				_drive_objective_x(player_local.x, 128.0)
				_tick_objective_jump(delta)
		6:
			if player.is_on_floor() and player_local.y > 220.0:
				_room_objective_phase = 5
				_drive_objective_x(player_local.x, 128.0)
				_tick_objective_jump(delta)
				return true
			_drive_objective_x(player_local.x, 512.0)
			if player.is_on_floor() and player_local.y <= 150.0:
				_room_objective_phase = 3
				_release_objective_jump()
			else:
				_tick_objective_jump(delta)
	return true


# 把重复的单轴路标移动收束为一处，误差带内停止以免从窄平台边缘来回摆动。
func _drive_objective_x(current_x: float, target_x: float, tolerance: float = 18.0) -> void:
	var delta_x := target_x - current_x
	_set_horizontal_input(signf(delta_x) if absf(delta_x) > tolerance else 0.0)


# Stage14 回环终点位于第二层平台；输入探针只负责登台并触达 GoalZone。
func _drive_stage14_loop_goal_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage14_loop_return_room.tscn"):
		return false
	var goal := room.get_node_or_null("GoalZone") as Node2D
	if goal == null:
		return false
	var player_local := room.to_local(player.global_position)
	if player.is_on_floor():
		if player_local.y > 150.0:
			_room_objective_phase = 0
		elif player_local.y > 90.0:
			_room_objective_phase = 1
		else:
			_room_objective_phase = 2

	Input.action_release("attack")
	Input.action_release("dash")
	_tap_active["attack"] = false
	_tap_active["dash"] = false
	var target_x := 416.0 if _room_objective_phase == 0 else goal.position.x
	var delta_x := target_x - player_local.x
	_set_horizontal_input(signf(delta_x) if absf(delta_x) > 18.0 else 0.0)
	if _room_objective_phase < 2:
		_tick_objective_jump(delta)
	else:
		_release_objective_jump()
	return true


# Stage15 压力房先处理地面冲锋敌，再登右侧低台与施法者交战，仍由真实攻击完成全清。
func _drive_stage15_pressure_caster_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage15_seal_pressure_room.tscn"):
		return false
	var caster := room.get_node_or_null("MiasmaCasterEnemy") as Node2D
	var charger := room.get_node_or_null("GroundChargerEnemy") as Node2D
	if caster == null or caster.has_method("is_defeated") and bool(caster.call("is_defeated")):
		return false
	if charger != null and charger.has_method("is_defeated") and not bool(charger.call("is_defeated")):
		return false
	var player_local := room.to_local(player.global_position)
	if player.is_on_floor() and player_local.y > 150.0:
		_room_objective_phase = 0
	elif player.is_on_floor() and player_local.y <= 150.0 and player_local.x >= 880.0:
		_room_objective_phase = 1
	if _room_objective_phase >= 2:
		return false

	Input.action_release("attack")
	Input.action_release("dash")
	_tap_active["attack"] = false
	_tap_active["dash"] = false
	if _room_objective_phase == 1:
		var stage_delta_x := 916.0 - player_local.x
		_set_horizontal_input(signf(stage_delta_x) if absf(stage_delta_x) > 4.0 else 0.0)
		_release_objective_jump()
		if player.is_on_floor() and player_local.x <= 920.0:
			_room_objective_phase = 2
			_objective_jump_cooldown_remaining = 0.08
			return false
		return true
	var delta_x := 928.0 - player_local.x
	_set_horizontal_input(signf(delta_x) if absf(delta_x) > 18.0 else 0.0)
	_tick_objective_jump(delta)
	return true


# Stage13 首个施法者房要求先踩低台再登高台；路标只负责抵达战斗层，不替代攻击或门控。
func _drive_stage13_caster_platform_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage13_miasma_marsh_caster_room.tscn"):
		return false
	var caster := room.get_node_or_null("MiasmaCasterEnemy") as Node2D
	if caster == null or caster.has_method("is_defeated") and bool(caster.call("is_defeated")):
		return false
	var player_local := room.to_local(player.global_position)
	var combat_delta := _enemy_combat_position(caster) - player.global_position
	if absf(combat_delta.x) <= 96.0 and absf(combat_delta.y) <= 72.0:
		_room_objective_phase = 2
		_release_objective_jump()
		return false
	return _drive_two_level_trigger_ascent(delta, room, player, caster, 224.0, 288.0, 1.0, false)


# Stage13 封印门同样要求两级上行；到达高台后靠近真实 SealNode，让房间脚本自行解门。
func _drive_stage13_gate_seal_route(delta: float, room: Node2D, player: CharacterBody2D) -> bool:
	if not room.scene_file_path.ends_with("stage13_miasma_marsh_gate_room.tscn"):
		return false
	if room.has_method("is_gate_unlocked") and bool(room.call("is_gate_unlocked")):
		return false
	var seal_node := room.get_node_or_null("SealNode") as Node2D
	if seal_node == null:
		return false
	var player_local := room.to_local(player.global_position)
	if player.is_on_floor():
		if player_local.y > 150.0:
			_room_objective_phase = 0
		elif player_local.y > 90.0:
			_room_objective_phase = 1
		else:
			_room_objective_phase = 2

	Input.action_release("attack")
	Input.action_release("dash")
	_tap_active["attack"] = false
	_tap_active["dash"] = false
	var target_x := 224.0 if _room_objective_phase == 0 else seal_node.position.x
	var delta_x := target_x - player_local.x
	_set_horizontal_input(signf(delta_x) if absf(delta_x) > 18.0 else 0.0)
	if _room_objective_phase < 2:
		_tick_objective_jump(delta)
	else:
		_release_objective_jump()
	return true


# 上层机关需要完整跳跃；保持按键一小段时间，避免生产玩家的提前松开逻辑把高度裁掉。
func _tick_objective_jump(delta: float) -> void:
	if _objective_jump_hold_remaining > 0.0:
		_objective_jump_hold_remaining = maxf(_objective_jump_hold_remaining - delta, 0.0)
		if _objective_jump_hold_remaining <= 0.0:
			Input.action_release("jump")
		return

	_objective_jump_cooldown_remaining = maxf(_objective_jump_cooldown_remaining - delta, 0.0)
	if _objective_jump_cooldown_remaining > 0.0:
		return
	Input.action_press("jump")
	_objective_jump_hold_remaining = 0.50
	_objective_jump_cooldown_remaining = 0.78


# 离开目标导航后清理专用按住状态，避免它污染通用 jump tap。
func _release_objective_jump() -> void:
	Input.action_release("jump")
	_objective_jump_hold_remaining = 0.0
	_objective_jump_cooldown_remaining = 0.0


func _drive_toward_enemy(enemy: Node2D) -> float:
	var player := _player()
	if player == null:
		_set_horizontal_input(1.0)
		return 0.32

	var delta_to_enemy := _enemy_combat_position(enemy) - player.global_position
	if absf(delta_to_enemy.x) <= 58.0 and absf(delta_to_enemy.y) <= 64.0:
		_set_horizontal_input(0.0)
		return 0.16

	_set_horizontal_input(signf(delta_to_enemy.x))
	return 0.22


func _set_horizontal_input(axis: float) -> void:
	if axis > 0.1:
		Input.action_release("move_left")
		Input.action_press("move_right")
	elif axis < -0.1:
		Input.action_release("move_right")
		Input.action_press("move_left")
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")


func _nearest_active_enemy() -> Node2D:
	var room := _room()
	var player := _player()
	if room == null or player == null:
		return null
	if is_instance_valid(_combat_target) and _combat_target.get_parent() == room:
		if not _combat_target.has_method("is_defeated") or not bool(_combat_target.call("is_defeated")):
			return _combat_target

	var best_enemy: Node2D = null
	var best_distance := INF
	for child: Node in room.get_children():
		if not child is Node2D or not child.has_method("receive_attack"):
			continue
		if child.has_method("is_defeated") and bool(child.call("is_defeated")):
			continue

		var enemy := child as Node2D
		var distance := player.global_position.distance_to(_enemy_combat_position(enemy))
		if distance < best_distance:
			best_distance = distance
			best_enemy = enemy
	_combat_target = best_enemy
	return best_enemy


# 空中敌的场景根节点是悬浮锚点，真实可命中位置位于 Hurtbox；导航必须追踪战斗几何而不是节点原点。
func _enemy_combat_position(enemy: Node2D) -> Vector2:
	var hurtbox := enemy.get_node_or_null("Hurtbox") as Node2D
	if hurtbox != null:
		return hurtbox.global_position
	var collision := enemy.get_node_or_null("CollisionShape2D") as Node2D
	if collision != null:
		return collision.global_position
	return enemy.global_position


func _should_use_combat_steering() -> bool:
	var room := _room()
	if room == null:
		return false

	if room.scene_file_path.ends_with("stage15_seal_guardian_boss_room.tscn"):
		return true

	if not room.has_method("get_remaining_required_enemy_count"):
		return room.has_method("is_gate_unlocked") and not bool(room.call("is_gate_unlocked")) and _nearest_active_enemy() != null

	if int(room.call("get_remaining_required_enemy_count")) > 0:
		return true
	return room.has_method("is_gate_unlocked") and not bool(room.call("is_gate_unlocked")) and _nearest_active_enemy() != null


func _focus_failure_continue(delta: float) -> void:
	var button := _failure_continue_button()
	if button == null or not button.visible:
		return

	button.grab_focus()
	_tick_tap("ui_accept", delta, 0.36)


func _tick_tap(action: String, delta: float, period: float) -> void:
	_tap_timers[action] = float(_tap_timers.get(action, 0.0)) + delta
	if bool(_tap_active.get(action, false)):
		Input.action_release(action)
		_tap_active[action] = false
		return
	if float(_tap_timers.get(action, 0.0)) < period:
		return
	_tap_timers[action] = 0.0
	Input.action_press(action)
	_tap_active[action] = true


func _update_stuck_timer(delta: float) -> void:
	var player := _player()
	if player == null:
		_stuck_elapsed += delta
		return
	var dx := player.global_position.x - _last_player_x
	if dx > 2.0:
		_stuck_elapsed = 0.0
	else:
		_stuck_elapsed += delta
	_last_player_x = player.global_position.x


func _check_room_change() -> void:
	var path := _room_path()
	if path.is_empty() or path == _current_room_path:
		return
	_capture(_current_room_id, "exit")
	_enter_current_room("entry")


func _enter_current_room(phase: String) -> void:
	_current_room_path = _room_path()
	_current_room_id = _room_id(_current_room_path)
	_combat_target = null
	_room_objective_phase = 0
	_objective_action_elapsed = 0.0
	_room_elapsed = 0.0
	_stuck_elapsed = 0.0
	_mid_captured = false
	var player := _player()
	_last_player_x = player.global_position.x if player != null else 0.0
	_rows.append({
		"index": _room_index,
		"id": _current_room_id,
		"path": _current_room_path,
		"entered_at": _elapsed,
		"screenshots": {phase: _capture(_current_room_id, phase)},
	})
	_room_index += 1
	_write_report(false)


func _capture_midpoint() -> void:
	if _mid_captured or _room_elapsed < MID_CAPTURE_DELAY:
		return
	_mid_captured = true
	_append_screenshot("mid", _capture(_current_room_id, "mid"))
	_write_report(false)


func _append_screenshot(phase: String, path: String) -> void:
	if _rows.is_empty():
		return
	var row: Dictionary = _rows[_rows.size() - 1]
	var shots: Dictionary = row.get("screenshots", {})
	shots[phase] = path
	row["screenshots"] = shots
	_rows[_rows.size() - 1] = row


func _check_completion() -> void:
	var snapshot := _snapshot()
	if bool(snapshot.get("stage16_alpha_demo_completed", false)):
		_append_screenshot("complete", _capture(_current_room_id, "complete"))
		_finish()


func _check_timeout() -> void:
	if _elapsed >= TOTAL_TIMEOUT:
		_add_issue("P0", _current_room_id, "total_timeout", "input replay exceeded total timeout")
		_finish()
		return
	if _room_elapsed < ROOM_TIMEOUT:
		return
	_add_issue("P0", _current_room_id, "room_timeout", "input replay did not naturally leave room in %.1fs" % ROOM_TIMEOUT)
	_append_screenshot("timeout", _capture(_current_room_id, "timeout"))
	_finish()


func _finish() -> void:
	_release_all()
	_running = false
	_finished = true
	set_physics_process(false)
	_write_report(true)


func _capture(room_id: String, phase: String) -> String:
	if DisplayServer.get_name() == "headless":
		return ""
	var safe_id := room_id if not room_id.is_empty() else "unknown"
	var path := "%s/%03d_%s_%s.png" % [SCREENSHOT_DIR, _room_index, safe_id, phase]
	var image := get_viewport().get_texture().get_image()
	if image == null:
		return ""
	image.save_png(path)
	return path


func _release_all() -> void:
	_release_objective_jump()
	for action: String in ["move_left", "move_right", "jump", "attack", "dash", "recover", "ui_accept"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _room_path() -> String:
	var room := _room()
	if room == null:
		return ""
	return room.scene_file_path


func _room_id(path: String) -> String:
	if path.is_empty():
		return "missing_room"
	var file := path.get_file().replace(".tscn", "")
	for prefix: String in ["stage13_miasma_marsh_", "stage14_air_dash_", "stage15_seal_guardian_", "stage15_mixed_", "stage16_alpha_demo_", "stage16_"]:
		file = file.replace(prefix, "")
	return file


func _room() -> Node2D:
	if _main == null:
		return null
	return _main.get_node_or_null("Room") as Node2D


func _player() -> CharacterBody2D:
	if _main == null:
		return null
	return _main.get_node_or_null("Runtime/PlayerPlaceholder") as CharacterBody2D


func _failure_continue_button() -> Button:
	if _main == null:
		return null
	return _main.get_node_or_null("HUD/DemoShell/FailurePanel/MarginContainer/VBoxContainer/FailureContinueButton") as Button


func _snapshot() -> Dictionary:
	if _main != null and _main.has_method("get_demo_progress_snapshot"):
		return _main.call("get_demo_progress_snapshot")
	return {}


func _add_issue(severity: String, room: String, code: String, note: String) -> void:
	_issues.append({"severity": severity, "room": room, "code": code, "note": note})


func _count_issues() -> Dictionary:
	var counts := {"P0": 0, "P1": 0, "P2": 0}
	for issue: Dictionary in _issues:
		var severity := str(issue.get("severity", ""))
		counts[severity] = int(counts.get(severity, 0)) + 1
	return counts


func _write_report(done: bool) -> void:
	var report := {
		"review_id": "mcp_player_input_replay_probe",
		"generated_at": Time.get_datetime_string_from_system(),
		"done": done,
		"elapsed": _elapsed,
		"rooms_seen": _rows.size(),
		"current_room": _current_room_path,
		"issue_counts": _count_issues(),
		"issues": _issues,
		"rows": _rows,
		"final_snapshot": _snapshot(),
		"runtime_debug": _runtime_debug_snapshot(),
		"debug_samples": _debug_samples,
		"start_room_override": _start_room_override,
		"boundary": "Measured replay uses Input.action_press/release plus UI focus for visible failure continue; it never calls transition_to_room or moves the player. An optional runner-only start room may shorten diagnostics before the probe begins.",
	}
	_write_text(OUT_JSON, JSON.stringify(report, "\t"))
	_write_text(OUT_MD, _markdown(report))


# 仅保留最近十二秒的低频输入样本，超时时可以看出跳跃与攻击是否真正送达生产玩家。
func _capture_debug_sample(delta: float) -> void:
	_debug_sample_elapsed += delta
	if _debug_sample_elapsed < 0.10:
		return
	_debug_sample_elapsed = 0.0
	var player := _player()
	var target := _combat_target if is_instance_valid(_combat_target) else null
	_debug_samples.append({
		"elapsed": _elapsed,
		"room_elapsed": _room_elapsed,
		"player_position": [player.global_position.x, player.global_position.y] if player != null else [],
		"player_state": str(player.call("get_current_state_id")) if player != null and player.has_method("get_current_state_id") else "",
		"player_health": int(player.call("get_current_health")) if player != null and player.has_method("get_current_health") else -1,
		"target": target.name if target != null else "",
		"target_combat_position": [_enemy_combat_position(target).x, _enemy_combat_position(target).y] if target != null else [],
		"target_health": int(target.call("get_current_health")) if target != null and target.has_method("get_current_health") else -1,
		"target_state": str(target.call("get_current_state_id")) if target != null and target.has_method("get_current_state_id") else "",
		"objective_phase": _room_objective_phase,
		"backtrack_reward_count": int(_snapshot().get("stage14_backtrack_reward_count", 0)),
		"jump_pressed": Input.is_action_pressed("jump"),
		"attack_pressed": Input.is_action_pressed("attack"),
	})
	if _debug_samples.size() > 120:
		_debug_samples.pop_front()


# 超时报告附带当前玩家、门控和敌人只读快照，便于区分玩法阻塞与探针导航不足。
func _runtime_debug_snapshot() -> Dictionary:
	var room := _room()
	var player := _player()
	var enemies: Array[Dictionary] = []
	if room != null:
		for child: Node in room.get_children():
			if not child is Node2D or not child.has_method("receive_attack"):
				continue
			var enemy := child as Node2D
			var combat_position := _enemy_combat_position(enemy)
			enemies.append({
				"name": enemy.name,
				"position": [enemy.global_position.x, enemy.global_position.y],
				"combat_position": [combat_position.x, combat_position.y],
				"defeated": bool(enemy.call("is_defeated")) if enemy.has_method("is_defeated") else false,
				"health": int(enemy.call("get_current_health")) if enemy.has_method("get_current_health") else -1,
				"guard": int(enemy.call("get_current_guard")) if enemy.has_method("get_current_guard") else -1,
				"state": str(enemy.call("get_current_state_id")) if enemy.has_method("get_current_state_id") else "",
			})
	var player_state := ""
	if player != null and player.has_method("get_current_state_id"):
		player_state = str(player.call("get_current_state_id"))
	return {
		"room": room.scene_file_path if room != null else "",
		"room_elapsed": _room_elapsed,
		"gate_unlocked": bool(room.call("is_gate_unlocked")) if room != null and room.has_method("is_gate_unlocked") else null,
		"player_position": [player.global_position.x, player.global_position.y] if player != null else [],
		"player_state": player_state,
		"enemies": enemies,
	}


func _markdown(report: Dictionary) -> String:
	var counts: Dictionary = report.get("issue_counts", {})
	var lines: Array[String] = []
	lines.append("# MCP Player Input Replay Probe")
	lines.append("")
	lines.append("- 生成时间：%s" % str(report.get("generated_at", "")))
	lines.append("- 完成：%s" % str(report.get("done", false)))
	lines.append("- 用时：%.2fs" % float(report.get("elapsed", 0.0)))
	lines.append("- 房间数：%d" % int(report.get("rooms_seen", 0)))
	lines.append("- P0 / P1 / P2：%s / %s / %s" % [counts.get("P0", 0), counts.get("P1", 0), counts.get("P2", 0)])
	lines.append("- 边界：%s" % str(report.get("boundary", "")))
	lines.append("")
	lines.append("| # | Room | Path | Screenshots |")
	lines.append("| --- | --- | --- | --- |")
	for row: Dictionary in report.get("rows", []):
		lines.append("| %d | `%s` | `%s` | `%s` |" % [
			int(row.get("index", 0)),
			str(row.get("id", "")),
			str(row.get("path", "")),
			JSON.stringify(row.get("screenshots", {})),
		])
	lines.append("")
	lines.append("## Issues")
	lines.append("")
	if _issues.is_empty():
		lines.append("- 无。")
	else:
		for issue: Dictionary in _issues:
			lines.append("- %s `%s` `%s`：%s" % [
				issue.get("severity", ""),
				issue.get("room", ""),
				issue.get("code", ""),
				issue.get("note", ""),
			])
	return "\n".join(lines) + "\n"


func _write_text(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(content)
