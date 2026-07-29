extends StaticBody2D

# TutorialExitBarrier 让教程出口封印柱本身也遵守玩家攻击契约。
# 玩家在攻击教学中很容易把红色柱子理解为目标，因此它必须能直接反馈命中并通知房间开门。

signal hit_registered(hit_count: int)

# 命中次数只用于教程房解锁和测试断言，不在封印柱脚本内决定房间流程。
var hit_count: int = 0


# 接收 PlayerPlaceholder 的攻击命中；具体是否解锁出口由 TutorialRoom 当前步骤决定。
func receive_attack(_hit_direction: Vector2, _knockback_force: float) -> void:
	hit_count += 1
	hit_registered.emit(hit_count)
