extends "res://scripts/rooms/stage9_room_base.gd"

# Stage9 开关房验证“靠近机关解锁门”的轻量门控。
# GateSwitch 仍保留 Area2D 触发契约，运行态视觉已由场景内正式 prop 承担。

const SWITCH_IDLE_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/006_shrine_gate_prop_atlas_ai01_auto_007_c01.atlas_texture.tres")
const SWITCH_LIT_TEXTURE := preload("res://assets/art/editor_resources/shrine_gate_prop_atlas_ai01/007_shrine_gate_prop_atlas_ai01_auto_008_c01.atlas_texture.tres")

# 记录开关是否已触发，防止玩家停留在触发区时重复发出解锁和 HUD 更新。
var _switch_activated := false


# 初始化开关自身的状态反馈，再交回父类同步房间门控。
func _ready() -> void:
	_apply_switch_art_state()
	super._ready()


# 每帧检查玩家是否靠近机关，触发后再交回父类出口推进。
func _process(delta: float) -> void:
	# 用距离检测替代正式交互按钮，降低当前原型对输入提示和机关资源的依赖。
	if not _switch_activated and _player != null:
		var switch_zone: Area2D = get_node_or_null("GateSwitch") as Area2D
		if switch_zone != null and _player.global_position.distance_to(switch_zone.global_position) <= 56.0:
			activate_gate_switch()

	super._process(delta)


# 激活机关并解锁门控，供测试直接调用和玩家位置触发共用。
func activate_gate_switch() -> void:
	# 测试可以直接调用该函数，从而只验证门控结果，不依赖物理步进。
	if _switch_activated:
		return

	_switch_activated = true
	_apply_switch_art_state()
	unlock_gate(cleared_step_id)


# 根据开关触发状态同步正式机关贴图，避免控制器始终显示已点亮。
func _apply_switch_art_state() -> void:
	var switch_art := get_node_or_null("GateSwitch/SwitchArt") as Sprite2D
	if switch_art == null:
		return

	switch_art.texture = SWITCH_LIT_TEXTURE if _switch_activated else SWITCH_IDLE_TEXTURE
	switch_art.set_meta("asset_id", "shrine_gate_prop_atlas_ai01")
	switch_art.set_meta("runtime_source", "shrine_gate_prop_atlas_ai01.talisman_stake_lit" if _switch_activated else "shrine_gate_prop_atlas_ai01.talisman_stake_idle")
	GateStateVfx.sync_unlock_feedback(
		get_node_or_null("GateSwitch"),
		_switch_activated,
		&"SwitchActivateVfxArt",
		Vector2.ZERO,
		Vector2(0.28, 0.28),
		"vfx_seal_magic_atlas_ai01.switch_activate_feedback"
	)
