extends "res://scripts/rooms/stage25_thunder_waste_room.gd"

# 驿路远眺房复用 Stage25 拓扑，新增夔影雷骸胜利、奖励与 HUD 快照，不扩第七房。

var _stage30_boss_defeated := false


func _ready() -> void:
	super._ready()
	var boss := _get_stage30_boss()
	if boss != null and not bool(boss.call("is_defeated")):
		_gate_unlocked = false
		var gate := get_node_or_null("GateBarrier") as CanvasItem
		if gate != null:
			gate.visible = true
		_apply_gate_lock_state()
		_set_stage29_animation(^"GateBarrier/Stage29BarrierArt", &"barrier_locked")


func bind_main(main: Node) -> void:
	super.bind_main(main)
	if (
		_main != null
		and _main.has_method("is_stage30_boss_defeated")
		and bool(_main.call("is_stage30_boss_defeated"))
	):
		_stage30_boss_defeated = true
		var boss := _get_stage30_boss()
		if boss != null and boss.has_method("disable_after_prior_defeat"):
			boss.call("disable_after_prior_defeat")
		unlock_gate(&"stage30_kui_defeated")
		_set_stage29_animation(^"GateBarrier/Stage29BarrierArt", &"barrier_open")


func _on_enemy_defeated() -> void:
	var boss := _get_stage30_boss()
	if boss == null or not bool(boss.call("is_defeated")):
		super._on_enemy_defeated()
		return
	if _stage30_boss_defeated:
		return

	super._on_enemy_defeated()
	_stage30_boss_defeated = true
	if _main != null and _main.has_method("mark_stage30_boss_defeated"):
		_main.call("mark_stage30_boss_defeated")
	unlock_gate(&"stage30_kui_defeated")
	_set_stage29_animation(^"GateBarrier/Stage29BarrierArt", &"barrier_open")
	var reward_vfx := get_node_or_null("Stage30RewardVfx") as AnimatedSprite2D
	if reward_vfx != null:
		reward_vfx.visible = true
		reward_vfx.play(&"absorption_unlock")
	_emit_hud_context()


func get_hud_context() -> Dictionary:
	var context := super.get_hud_context()
	context.merge(get_stage30_boss_snapshot(), true)
	return context


func get_stage30_boss_snapshot() -> Dictionary:
	var boss := _get_stage30_boss()
	return {
		"stage30_boss_room": true,
		"stage30_boss_name": "夔影雷骸",
		"stage30_boss_defeated": _stage30_boss_defeated,
		"stage30_boss_health": int(boss.call("get_current_health")) if boss != null else 0,
		"stage30_boss_max_health": int(boss.call("get_max_health")) if boss != null else 0,
		"stage30_boss_guard": int(boss.call("get_current_guard")) if boss != null else 0,
		"stage30_boss_phase": int(boss.call("get_phase_index")) if boss != null else 0,
		"stage30_boss_state": StringName(boss.call("get_boss_state")) if boss != null else &"missing",
	}


func _get_stage30_boss() -> Node:
	return get_node_or_null("KuiThunderBoss")
