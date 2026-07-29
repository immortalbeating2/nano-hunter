extends StaticBody2D

# 可破坏秘密墙复用玩家现有 receive_attack 调用；首次命中后只关闭自身碰撞和视觉。

var _revealed := false


func receive_attack(_hit_direction: Vector2, _knockback_force: float) -> void:
	if _revealed:
		return

	_revealed = true
	visible = false
	var shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape != null:
		shape.set_deferred("disabled", true)


func is_revealed() -> bool:
	return _revealed
