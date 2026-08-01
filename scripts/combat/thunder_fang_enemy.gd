extends "res://scripts/combat/base_enemy.gd"
class_name ThunderFangEnemy

# 雷蚀獠复用 BaseEnemy 的 defeated、碰撞关闭与受击入口，只补两点生命和可选蓄雷冲刺节奏。

signal health_changed(current_health: int, max_health: int)
signal state_changed(state_id: StringName)

const STATE_PATROL: StringName = &"patrol"
const STATE_WARNING: StringName = &"warning"
const STATE_ATTACK: StringName = &"attack"
const STATE_RECOVERY: StringName = &"recovery"
const STATE_HIT: StringName = &"hit"
const STATE_DEFEATED: StringName = &"defeated"

const LOCOMOTION_FRAMES: SpriteFrames = preload(
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_thunder_fang_locomotion_runtime_ai01.spriteframes.tres"
)
const ATTACK_FRAMES: SpriteFrames = preload(
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_thunder_fang_attack_runtime_ai01.spriteframes.tres"
)
const REACTION_FRAMES: SpriteFrames = preload(
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_thunder_fang_reaction_runtime_ai01.spriteframes.tres"
)
const VFX_FRAMES: SpriteFrames = preload(
	"res://assets/art/vfx/atlases/stage30_thunder_fang_vfx_runtime_ai01.spriteframes.tres"
)

@export var charged_variant := false
@export var max_health := 2
@export var touch_damage := 1
@export var patrol_distance := 42.0
@export var patrol_speed := 2.2
@export var trigger_distance := 150.0
@export var warning_duration := 0.5
@export var attack_duration := 0.28
@export var attack_speed := 210.0
@export var recovery_duration := 0.45
@export var hit_duration := 0.2

var current_health := 2
var current_state: StringName = STATE_PATROL
var _player: CharacterBody2D
var _spawn_position := Vector2.ZERO
var _patrol_elapsed := 0.0
var _state_elapsed := 0.0
var _attack_direction := 1.0
var _attack_armed := true

@onready var _state_vfx_visual: AnimatedSprite2D = get_node_or_null("ThunderFangVfxVisual") as AnimatedSprite2D


func _ready() -> void:
	super._ready()
	current_health = max_health
	_spawn_position = position
	_enter_state(STATE_PATROL)
	health_changed.emit(current_health, max_health)


func _physics_process(delta: float) -> void:
	if is_defeated():
		return

	_state_elapsed += delta
	match current_state:
		STATE_PATROL:
			_update_patrol(delta)
			_deal_touch_damage(touch_damage)
		STATE_WARNING:
			if _state_elapsed >= warning_duration:
				_enter_state(STATE_ATTACK)
		STATE_ATTACK:
			position.x += _attack_direction * attack_speed * delta
			_deal_touch_damage(touch_damage)
			if _state_elapsed >= attack_duration:
				_enter_state(STATE_RECOVERY)
		STATE_RECOVERY:
			if _state_elapsed >= recovery_duration:
				_enter_state(STATE_PATROL)
		STATE_HIT:
			if _state_elapsed >= hit_duration:
				_enter_state(STATE_PATROL)


func bind_player(player: CharacterBody2D) -> void:
	_player = player


func receive_attack(hit_direction: Vector2, knockback_force: float) -> void:
	_take_hit(hit_direction, knockback_force, &"hit", &"")


# 风雷只在蓄雷 warning 窗直接破甲；雷风只在普通扣血之外取消攻击并表现后退。
func receive_elemental_attack(
	hit_direction: Vector2,
	knockback_force: float,
	attack_context: Dictionary
) -> void:
	var reaction_id := StringName(attack_context.get("reaction_id", StringName()))
	if reaction_id == &"wind_thunder_pierce" and current_state == STATE_WARNING:
		current_health = 0
		health_changed.emit(current_health, max_health)
		_show_state_vfx(&"guard_break")
		super.receive_attack(hit_direction, knockback_force)
		return

	if reaction_id == &"thunder_wind_scatter":
		var direction := signf(hit_direction.x)
		if absf(direction) <= 0.01:
			direction = 1.0
		position.x += direction * minf(maxf(knockback_force, 0.0) * 0.25, 56.0)
		_take_hit(hit_direction, knockback_force, &"stagger", &"stagger")
		return

	receive_attack(hit_direction, knockback_force)


func get_status_snapshot() -> Dictionary:
	return {
		"enemy_id": &"thunder_fang",
		"charged_variant": charged_variant,
		"current_health": current_health,
		"max_health": max_health,
		"current_state": current_state,
		"is_defeated": is_defeated(),
	}


func _take_hit(
	hit_direction: Vector2,
	knockback_force: float,
	reaction_animation: StringName,
	vfx_animation: StringName
) -> void:
	if is_defeated():
		return

	current_health = maxi(current_health - 1, 0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		super.receive_attack(hit_direction, knockback_force)
		return

	_enter_state(STATE_HIT)
	_play_runtime_animation(
		REACTION_FRAMES,
		reaction_animation,
		"stage30_thunder_fang_reaction_runtime_ai01",
		true
	)
	_show_enemy_hit_spark_vfx()
	if vfx_animation != StringName():
		_show_state_vfx(vfx_animation)


func _update_patrol(delta: float) -> void:
	_patrol_elapsed += delta
	position.x = _spawn_position.x + sin(_patrol_elapsed * patrol_speed) * patrol_distance
	if _runtime_animation_visual != null:
		_runtime_animation_visual.flip_h = cos(_patrol_elapsed * patrol_speed) < 0.0
	if not charged_variant or _player == null:
		return

	var offset := _player.global_position - global_position
	if absf(offset.y) > 48.0 or absf(offset.x) > trigger_distance:
		_attack_armed = true
		return
	if not _attack_armed:
		return

	_attack_armed = false
	_attack_direction = signf(offset.x)
	if absf(_attack_direction) <= 0.01:
		_attack_direction = 1.0
	_enter_state(STATE_WARNING)


func _enter_state(next_state: StringName) -> void:
	current_state = next_state
	_state_elapsed = 0.0
	state_changed.emit(current_state)
	match current_state:
		STATE_PATROL:
			_play_runtime_animation(
				LOCOMOTION_FRAMES,
				&"move" if charged_variant else &"patrol",
				"stage30_thunder_fang_locomotion_runtime_ai01",
				true
			)
			_hide_state_vfx()
		STATE_WARNING:
			_play_runtime_animation(ATTACK_FRAMES, &"warning", "stage30_thunder_fang_attack_runtime_ai01", true)
			_show_state_vfx(&"warning")
		STATE_ATTACK:
			_play_runtime_animation(ATTACK_FRAMES, &"attack", "stage30_thunder_fang_attack_runtime_ai01", true)
			_show_state_vfx(&"attack")
		STATE_RECOVERY:
			_play_runtime_animation(ATTACK_FRAMES, &"recovery", "stage30_thunder_fang_attack_runtime_ai01", true)
			_hide_state_vfx()
		STATE_HIT:
			_play_runtime_animation(REACTION_FRAMES, &"hit", "stage30_thunder_fang_reaction_runtime_ai01", true)
			_hide_state_vfx()


func _play_defeat_animation() -> void:
	current_state = STATE_DEFEATED
	state_changed.emit(current_state)
	_play_runtime_animation(
		REACTION_FRAMES,
		&"defeat",
		"stage30_thunder_fang_reaction_runtime_ai01",
		true
	)
	_hide_state_vfx()


func _show_state_vfx(animation_name: StringName) -> void:
	if _state_vfx_visual == null:
		return
	_state_vfx_visual.visible = true
	_state_vfx_visual.sprite_frames = VFX_FRAMES
	_state_vfx_visual.set_meta("asset_id", "stage30_thunder_fang_vfx_runtime_ai01")
	_state_vfx_visual.set_meta("gameplay_collision", false)
	_state_vfx_visual.set_meta("damage_source", false)
	_state_vfx_visual.play(animation_name)


func _hide_state_vfx() -> void:
	if _state_vfx_visual != null:
		_state_vfx_visual.visible = false
		_state_vfx_visual.stop()
