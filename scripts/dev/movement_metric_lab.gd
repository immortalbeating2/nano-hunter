extends Node2D

# 生产移动标尺实验室只读取真实 Player 的当前参数与碰撞形状。
# 它把极限换算成保留落点余量的设计带，但不参与正式关卡运行，也不新增玩家能力。


const PLAYER_SCENE_PATH := "res://scenes/player/player_placeholder.tscn"
const PLAYER_SCENE := preload(PLAYER_SCENE_PATH)
const PLAYER_SPAWN := Vector2(-640.0, 96.0)


func _ready() -> void:
	if get_metric_player() == null:
		reset_metric_player()


# 返回当前实验室中的生产 Player，供自动采样和人工调试共用。
func get_metric_player() -> CharacterBody2D:
	return get_node_or_null("MetricPlayer") as CharacterBody2D


# 测试重置只替换 Player 实例；地板、相机和标尺节点保持不变。
func reset_metric_player() -> CharacterBody2D:
	var current := get_metric_player()
	if current != null:
		current.queue_free()

	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	player.name = "MetricPlayer"
	player.position = PLAYER_SPAWN
	add_child(player)
	return player


# 统一输出生产参数、理论上限和房间可采用的比例带。
# 理论值只作为归一化分母，正式房间必须使用下方设计带并保留落点宽度。
func get_metric_contract() -> Dictionary:
	var player := get_metric_player()
	if player == null:
		return {}

	var body_size := _read_body_size(player)
	var jump_velocity: float = absf(float(player.get("jump_velocity")))
	var rise_gravity: float = float(player.get("rise_gravity"))
	var fall_gravity: float = float(player.get("fall_gravity"))
	var max_run_speed: float = float(player.get("max_run_speed"))
	var jump_height := pow(jump_velocity, 2.0) / (2.0 * rise_gravity)
	var rise_time := jump_velocity / rise_gravity
	var fall_time := sqrt(2.0 * jump_height / fall_gravity)
	var airborne_time := rise_time + fall_time
	var max_horizontal_jump := max_run_speed * airborne_time
	var dash_distance: float = float(player.get("dash_speed")) * float(player.get("dash_duration"))
	var attack_size: Vector2 = player.get("attack_hitbox_size") as Vector2
	var attack_offset: Vector2 = player.get("attack_hitbox_offset") as Vector2
	var viewport_size := get_viewport_rect().size
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	var camera_zoom := camera.zoom if camera != null else Vector2.ONE

	return {
		"schema_version": 1,
		"source_scene": PLAYER_SCENE_PATH,
		"body_size": body_size,
		"max_run_speed": max_run_speed,
		"jump": {
			"theoretical_height": jump_height,
			"rise_time": rise_time,
			"airborne_time": airborne_time,
			"max_horizontal_distance": max_horizontal_jump,
			"coyote_time": float(player.get("coyote_time_window")),
			"input_buffer": float(player.get("jump_buffer_window")),
		},
		"dash": {
			"speed": float(player.get("dash_speed")),
			"duration": float(player.get("dash_duration")),
			"nominal_distance": dash_distance,
			"end_speed_upper_bound": float(player.get("dash_speed")),
		},
		"air_dash": {
			"speed": float(player.get("dash_speed")),
			"duration": float(player.get("dash_duration")),
			"nominal_distance": dash_distance,
			"uses_one_charge_per_airborne_cycle": true,
		},
		"attack": {
			"hitbox_size": attack_size,
			"hitbox_offset": attack_offset,
			"forward_reach": absf(attack_offset.x) + attack_size.x * 0.5,
			"movement_rule": "decelerate_during_attack",
		},
		"damage_knockback": {
			"initial_velocity": Vector2(
				float(player.get("damage_knockback_speed")),
				float(player.get("damage_knockback_lift"))
			),
		},
		"camera": {
			"zoom": camera_zoom,
			"visible_width": viewport_size.x / maxf(camera_zoom.x, 0.001),
			"visible_height": viewport_size.y / maxf(camera_zoom.y, 0.001),
			"look_ahead": 0.0,
		},
		"design_bands": _build_design_bands(max_horizontal_jump, jump_height, body_size.x),
	}


func _read_body_size(player: CharacterBody2D) -> Vector2:
	var collision := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null:
		return Vector2.ZERO
	var rectangle := collision.shape as RectangleShape2D
	return rectangle.size if rectangle != null else Vector2.ZERO


# 比例来自已批准规格；数值直接由当前生产 Player 极限计算，避免双份手工常量漂移。
func _build_design_bands(max_horizontal_jump: float, max_vertical_jump: float, body_width: float) -> Dictionary:
	return {
		"safe_teaching": _make_band(Vector2(0.4, 0.6), max_horizontal_jump, max_vertical_jump, body_width * 2.0),
		"normal_mainline": _make_band(Vector2(0.55, 0.75), max_horizontal_jump, max_vertical_jump, body_width * 1.5),
		"regular_challenge": _make_band(Vector2(0.7, 0.85), max_horizontal_jump, max_vertical_jump, body_width * 1.5),
		"optional_high": _make_band(Vector2(0.85, 0.95), max_horizontal_jump, max_vertical_jump, body_width * 1.5),
	}


func _make_band(ratio: Vector2, max_horizontal_jump: float, max_vertical_jump: float, landing_width: float) -> Dictionary:
	return {
		"ratio": ratio,
		"horizontal_gap": Vector2(max_horizontal_jump * ratio.x, max_horizontal_jump * ratio.y),
		"vertical_rise": Vector2(max_vertical_jump * ratio.x, max_vertical_jump * ratio.y),
		"landing_width": landing_width,
	}
