extends "res://scripts/combat/seal_guardian_boss.gd"
class_name KuiThunderBoss

# 夔影雷骸复用 SealGuardianBoss 的生命、护印、两阶段与攻击窗口，只替换招式读值和正式表现。

const PHASE1_PRESENCE_FRAMES: SpriteFrames = preload(
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_kui_boss_phase1_presence_runtime_ai01.spriteframes.tres"
)
const PHASE1_ATTACK_FRAMES: SpriteFrames = preload(
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_kui_boss_phase1_attacks_runtime_ai01.spriteframes.tres"
)
const TRANSITION_REACTION_FRAMES: SpriteFrames = preload(
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_kui_boss_transition_reaction_runtime_ai01.spriteframes.tres"
)
const PHASE2_PRESENCE_FRAMES: SpriteFrames = preload(
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_kui_boss_phase2_presence_runtime_ai01.spriteframes.tres"
)
const PHASE2_RESOLUTION_FRAMES: SpriteFrames = preload(
	"res://assets/art/characters/enemies/sprite_sheets/runtime_replacement/stage30_kui_boss_phase2_resolution_runtime_ai01.spriteframes.tres"
)
const COMBAT_VFX_FRAMES: SpriteFrames = preload(
	"res://assets/art/vfx/atlases/stage30_kui_boss_combat_vfx_runtime_ai01.spriteframes.tres"
)
const STATE_VFX_FRAMES: SpriteFrames = preload(
	"res://assets/art/vfx/atlases/stage30_kui_boss_state_vfx_runtime_ai01.spriteframes.tres"
)

@export var lightning_attack_range := 172.0
@export var scatter_stagger_bonus_duration := 0.35

var _scatter_stagger_bonus := false


# 雷风只延长已经形成的破势窗口；生命和护印仍由父类一次结算。
func receive_elemental_attack(
	hit_direction: Vector2,
	knockback_force: float,
	attack_context: Dictionary
) -> void:
	var scatter: bool = attack_context.get("reaction_id", StringName()) == &"thunder_wind_scatter"
	super.receive_elemental_attack(hit_direction, knockback_force, attack_context)
	if current_state == STATE_DEFEATED:
		return
	if scatter and current_state == STATE_STAGGERED:
		_scatter_stagger_bonus = true
		_state_elapsed = 0.0
		_sync_runtime_animation_visual()
		_sync_attack_vfx_visual()


func get_status_snapshot() -> Dictionary:
	var snapshot := super.get_status_snapshot()
	snapshot.merge({
		"boss_id": &"kui_thunder_boss",
		"boss_name": "夔影雷骸",
		"planned_attack_id": get_planned_attack_id(),
		"scatter_stagger_bonus": _scatter_stagger_bonus,
	}, true)
	return snapshot


func get_planned_attack_id() -> StringName:
	return &"lightning_call" if _planned_strike_state == STATE_AIR_PUNISH else &"close_pressure"


# 已击败回访不重新发奖：房间绑定 Main 后静默恢复休眠态。
func disable_after_prior_defeat() -> void:
	current_health = 0
	current_guard = 0
	current_state = STATE_DEFEATED
	if _collision_shape != null:
		_collision_shape.disabled = true
	set_physics_process(false)
	_sync_runtime_animation_visual()
	_sync_attack_vfx_visual()


func _get_stagger_duration() -> float:
	return stagger_duration + (scatter_stagger_bonus_duration if _scatter_stagger_bonus else 0.0)


func _restore_guard_and_idle() -> void:
	super._restore_guard_and_idle()
	_scatter_stagger_bonus = false


func _get_phase_adjusted_recovery_duration() -> float:
	return recovery_duration * 0.65 if _phase_index >= 2 else recovery_duration


func _find_damage_receiver() -> Node:
	if (
		current_state == STATE_AIR_PUNISH
		and _player != null
		and global_position.distance_to(_player.global_position) <= lightning_attack_range
	):
		return _resolve_damage_receiver(_player)
	return super._find_damage_receiver()


func _sync_runtime_animation_visual() -> void:
	if _runtime_animation_visual == null:
		return

	var frames: SpriteFrames
	var animation: StringName
	var asset_id := ""
	var manual_frame := -1
	if current_state == STATE_DEFEATED:
		frames = PHASE2_RESOLUTION_FRAMES
		animation = &"defeat"
		asset_id = "stage30_kui_boss_phase2_resolution_runtime_ai01"
	elif _phase_transition_visual_remaining > 0.0:
		frames = TRANSITION_REACTION_FRAMES
		animation = &"phase_transition"
		asset_id = "stage30_kui_boss_transition_reaction_runtime_ai01"
	elif _hit_flash_remaining > 0.0 and current_state != STATE_STAGGERED:
		frames = TRANSITION_REACTION_FRAMES
		animation = &"hit"
		asset_id = "stage30_kui_boss_transition_reaction_runtime_ai01"
		manual_frame = 0
	else:
		match current_state:
			STATE_IDLE:
				frames = PHASE2_PRESENCE_FRAMES if _phase_index >= 2 else PHASE1_PRESENCE_FRAMES
				animation = &"phase2_idle" if _phase_index >= 2 else &"phase1_idle"
				asset_id = "stage30_kui_boss_phase2_presence_runtime_ai01" if _phase_index >= 2 else "stage30_kui_boss_phase1_presence_runtime_ai01"
			STATE_CLOSE_PRESSURE:
				frames = PHASE2_PRESENCE_FRAMES if _phase_index >= 2 else PHASE1_PRESENCE_FRAMES
				animation = &"lightning_warning" if _planned_strike_state == STATE_AIR_PUNISH else &"close_warning"
				asset_id = "stage30_kui_boss_phase2_presence_runtime_ai01" if _phase_index >= 2 else "stage30_kui_boss_phase1_presence_runtime_ai01"
				manual_frame = _map_attack_contract_frame(0, 3, windup_duration)
			STATE_GROUND_IMPACT:
				frames = PHASE2_RESOLUTION_FRAMES if _phase_index >= 2 else PHASE1_ATTACK_FRAMES
				animation = &"phase2_close_attack" if _phase_index >= 2 else &"close_attack"
				asset_id = "stage30_kui_boss_phase2_resolution_runtime_ai01" if _phase_index >= 2 else "stage30_kui_boss_phase1_attacks_runtime_ai01"
				manual_frame = _map_attack_contract_frame(0, 3, strike_duration)
			STATE_AIR_PUNISH:
				frames = PHASE2_RESOLUTION_FRAMES if _phase_index >= 2 else PHASE1_ATTACK_FRAMES
				animation = &"phase2_lightning_attack" if _phase_index >= 2 else &"lightning_attack"
				asset_id = "stage30_kui_boss_phase2_resolution_runtime_ai01" if _phase_index >= 2 else "stage30_kui_boss_phase1_attacks_runtime_ai01"
				manual_frame = _map_attack_contract_frame(0, 3, strike_duration)
			STATE_RECOVERY:
				frames = PHASE2_RESOLUTION_FRAMES if _phase_index >= 2 else PHASE1_PRESENCE_FRAMES
				animation = &"phase2_recovery" if _phase_index >= 2 else &"phase1_recovery"
				asset_id = "stage30_kui_boss_phase2_resolution_runtime_ai01" if _phase_index >= 2 else "stage30_kui_boss_phase1_presence_runtime_ai01"
				manual_frame = _map_attack_contract_frame(0, 3, _get_phase_adjusted_recovery_duration())
			STATE_STAGGERED:
				frames = TRANSITION_REACTION_FRAMES
				animation = &"stagger" if _scatter_stagger_bonus else &"guard_break"
				asset_id = "stage30_kui_boss_transition_reaction_runtime_ai01"
				manual_frame = _map_attack_contract_frame(0, 3, _get_stagger_duration())
			_:
				frames = PHASE1_PRESENCE_FRAMES
				animation = &"phase1_idle"
				asset_id = "stage30_kui_boss_phase1_presence_runtime_ai01"

	_runtime_animation_visual.visible = true
	var changed := _runtime_animation_visual.sprite_frames != frames or _runtime_animation_visual.animation != animation
	_runtime_animation_visual.sprite_frames = frames
	_runtime_animation_visual.animation = animation
	_runtime_animation_visual.set_meta("asset_id", asset_id)
	if manual_frame >= 0:
		_runtime_animation_visual.pause()
		_runtime_animation_visual.frame = manual_frame
	elif changed or not _runtime_animation_visual.is_playing():
		_runtime_animation_visual.play(animation)


func _sync_attack_vfx_visual() -> void:
	if _attack_vfx_visual == null:
		return

	var frames: SpriteFrames
	var animation: StringName = &""
	var asset_id := ""
	var manual_frame := -1
	if current_state == STATE_DEFEATED:
		frames = STATE_VFX_FRAMES
		animation = &"defeat"
		asset_id = "stage30_kui_boss_state_vfx_runtime_ai01"
	elif _phase_transition_visual_remaining > 0.0:
		frames = STATE_VFX_FRAMES
		animation = &"phase_transition"
		asset_id = "stage30_kui_boss_state_vfx_runtime_ai01"
	elif current_state == STATE_CLOSE_PRESSURE:
		frames = COMBAT_VFX_FRAMES
		animation = &"lightning_warning" if _planned_strike_state == STATE_AIR_PUNISH else &"close_warning"
		asset_id = "stage30_kui_boss_combat_vfx_runtime_ai01"
		manual_frame = _map_attack_contract_frame(0, 3, windup_duration)
	elif current_state == STATE_GROUND_IMPACT or current_state == STATE_AIR_PUNISH:
		frames = COMBAT_VFX_FRAMES
		animation = &"lightning_impact" if current_state == STATE_AIR_PUNISH else &"close_impact"
		asset_id = "stage30_kui_boss_combat_vfx_runtime_ai01"
		manual_frame = _map_attack_contract_frame(0, 3, strike_duration)
	elif current_state == STATE_STAGGERED:
		frames = STATE_VFX_FRAMES
		animation = &"stagger" if _scatter_stagger_bonus else &"guard_break"
		asset_id = "stage30_kui_boss_state_vfx_runtime_ai01"
		manual_frame = _map_attack_contract_frame(0, 3, _get_stagger_duration())

	if animation == StringName():
		_attack_vfx_visual.visible = false
		_attack_vfx_visual.stop()
		return

	_attack_vfx_visual.visible = true
	var changed := _attack_vfx_visual.sprite_frames != frames or _attack_vfx_visual.animation != animation
	_attack_vfx_visual.sprite_frames = frames
	_attack_vfx_visual.animation = animation
	_attack_vfx_visual.set_meta("asset_id", asset_id)
	_attack_vfx_visual.set_meta("gameplay_collision", false)
	_attack_vfx_visual.set_meta("damage_source", false)
	if manual_frame >= 0:
		_attack_vfx_visual.pause()
		_attack_vfx_visual.frame = manual_frame
	elif changed or not _attack_vfx_visual.is_playing():
		_attack_vfx_visual.play(animation)
