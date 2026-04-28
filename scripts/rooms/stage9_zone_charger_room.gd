extends "res://scripts/rooms/stage9_room_base.gd"

# Stage9 冲锋敌教学房沿用基类，只在敌人击败后同时设置 checkpoint 和开门。
# 这样玩家失败后能从已学会处理冲锋敌的位置恢复，而不是退回前一房间。

func _handle_enemy_defeated() -> void:
	# 这里保留为独立 override，是为了把“击败冲锋敌”明确记录为阶段检查点。
	activate_checkpoint()
	unlock_gate(cleared_step_id)
