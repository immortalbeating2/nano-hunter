extends StaticBody2D

# 雷泽接地祭柱只识别 Stage21 已存在的风→雷反应，并把成功结果交给房间开门。

signal grounded

const REQUIRED_REACTION: StringName = &"wind_thunder_pierce"

var _grounded := false


# 元素上下文由玩家统一攻击入口注入；错误顺序与单元素攻击不会改变机关状态。
func receive_elemental_attack(_direction: Vector2, _knockback_force: float, context: Dictionary) -> void:
	if _grounded or StringName(context.get("reaction_id", StringName())) != REQUIRED_REACTION:
		return

	_grounded = true
	var core := get_node_or_null("RelayCore") as Polygon2D
	if core != null:
		core.color = Color(0.42, 0.91, 0.88, 0.96)
	var ring := get_node_or_null("RelayRing") as Polygon2D
	if ring != null:
		ring.color = Color(0.74, 0.92, 1.0, 0.72)
	grounded.emit()


# HUD、房间和测试共用这一只读入口确认祭柱是否已接地。
func is_grounded() -> bool:
	return _grounded
