extends "res://scripts/rooms/stage9_room_base.gd"

# Stage9 开关房验证“靠近机关解锁门”的轻量门控。
# 机关本身仍是灰盒 Area2D，后续正式机关只要保留 GateSwitch 节点名即可复用逻辑。

# 记录开关是否已触发，防止玩家停留在触发区时重复发出解锁和 HUD 更新。
var _switch_activated := false


# 每帧检查玩家是否靠近灰盒开关，触发后再交回父类出口推进。
func _process(delta: float) -> void:
	# 用距离检测替代正式交互按钮，降低当前原型对输入提示和机关资源的依赖。
	if not _switch_activated and _player != null:
		var switch_zone: Area2D = get_node_or_null("GateSwitch") as Area2D
		if switch_zone != null and _player.global_position.distance_to(switch_zone.global_position) <= 56.0:
			activate_gate_switch()

	super._process(delta)


# 激活灰盒开关并解锁门控，供测试直接调用和玩家位置触发共用。
func activate_gate_switch() -> void:
	# 测试可以直接调用该函数，从而只验证门控结果，不依赖物理步进。
	if _switch_activated:
		return

	_switch_activated = true
	unlock_gate(cleared_step_id)
