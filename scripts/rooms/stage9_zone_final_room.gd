extends "res://scripts/rooms/stage9_room_base.gd"

# Stage9 终点房负责把多敌人清场要求转成门控解锁。
# 它不创建敌人，只统计场景中带 defeated 信号的节点并等待全部击败。

# 剩余敌人数是本房间唯一的运行期门控状态，避免基类误把单个敌人死亡当作清场。
var _remaining_enemy_count := 0


# 初始化终点房清场计数，并在仍有敌人时强制锁门。
func _ready() -> void:
	# 先统计敌人再调用基类 ready，保证基类绑定信号后仍能使用正确的初始锁门状态。
	_remaining_enemy_count = _count_active_enemies()
	super._ready()
	if _remaining_enemy_count > 0:
		_gate_unlocked = false
		_apply_gate_lock_state()
		_emit_hud_context()


# 处理单个敌人击败事件，只有全部敌人清空后才解锁终点门。
func _handle_enemy_defeated() -> void:
	# 基类会把每个敌人的 defeated 信号汇聚到这里，终点房必须等全部敌人清空。
	_remaining_enemy_count = max(_remaining_enemy_count - 1, 0)
	if _remaining_enemy_count == 0:
		unlock_gate(cleared_step_id)


# 统计当前房间内带 defeated 信号的敌人数量，作为终点房清场目标。
func _count_active_enemies() -> int:
	# 使用 defeated 信号识别敌人，保持房间脚本不绑定具体敌人类型。
	var count := 0
	for child in get_children():
		if child.has_signal("defeated"):
			count += 1
	return count
