extends StaticBody2D
class_name BaseEnemy

# BaseEnemy 定义当前原型期敌人的最小公共契约。
# 它只负责“受击后失效”和“碰撞到玩家时转发 receive_damage”，
# 更具体的移动、冲锋、悬浮节奏交给子类。

# defeated 是房间门控和 Main 流程唯一依赖的敌人清除信号。
signal defeated

const HIT_SPARK_VFX_TIMEOUT := 0.45

# 节点缓存只用于关闭碰撞、隐藏 hurtbox 和显示轻量受击反馈，不作为外部读取入口。
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var _body_polygon: Polygon2D = $Body
@onready var _runtime_animation_visual: AnimatedSprite2D = get_node_or_null("EnemyRuntimeAnimationVisual") as AnimatedSprite2D
@onready var _hit_spark_vfx_visual: AnimatedSprite2D = get_node_or_null("EnemyHitSparkVfxVisual") as AnimatedSprite2D

# 基类只记录是否已经失效；生命、护印和复杂状态由更高阶敌人自行实现。
var _is_defeated := false


# 初始化正式运行时视觉层：有 runtime 动画时，旧灰盒轮廓只保留为隐藏调试层。
func _ready() -> void:
	_prepare_runtime_visual_stack()
	_hide_enemy_hit_spark_vfx()


# 玩家攻击统一通过 receive_attack 进入敌人契约，敌人被击败后同时关闭实体碰撞与 hurtbox。
func receive_attack(_hit_direction: Vector2, _knockback_force: float) -> void:
	if _is_defeated:
		return

	_is_defeated = true
	if _collision_shape != null:
		_collision_shape.disabled = true
	if _hurtbox_shape != null:
		_hurtbox_shape.disabled = true
	if _body_polygon != null:
		_body_polygon.color = Color(0.572549, 0.294118, 0.294118, 0.45)
	if _runtime_animation_visual != null:
		_runtime_animation_visual.visible = false
	_show_enemy_hit_spark_vfx()
	defeated.emit()


# 普通敌人正式动画已接入时，隐藏旧 Stage12/13 轮廓、灰盒 body 和低透明 source sprite，避免运行画面混合读值。
func _prepare_runtime_visual_stack() -> void:
	if _runtime_animation_visual == null:
		return

	for node_name: String in [
		"Body",
		"Stage12Silhouette",
		"Stage12ThreatMark",
		"Stage12ChargeMark",
		"Stage12AirMark",
		"Stage12AssetSprite",
		"Stage13Silhouette",
		"Stage13AssetSprite",
	]:
		var legacy_visual := get_node_or_null(node_name) as CanvasItem
		if legacy_visual != null:
			legacy_visual.visible = false

	var callback := Callable(self, "_on_enemy_hit_spark_animation_finished")
	if _hit_spark_vfx_visual != null and not _hit_spark_vfx_visual.is_connected("animation_finished", callback):
		_hit_spark_vfx_visual.connect("animation_finished", callback)


# 公开敌人是否已经失效，供房间门控和测试读取。
func is_defeated() -> bool:
	# 房间和测试通过该读值判断敌人是否已被清除，避免直接读取私有状态。
	return _is_defeated


# 敌人受击命中特效通过可选节点接入，缺节点时不影响早期敌人场景。
func _show_enemy_hit_spark_vfx() -> void:
	if _hit_spark_vfx_visual == null:
		var legacy_hit_spark := get_node_or_null("Stage12HitSpark") as CanvasItem
		if legacy_hit_spark != null:
			legacy_hit_spark.visible = true
		return

	_hit_spark_vfx_visual.visible = true
	_hit_spark_vfx_visual.set_meta("gameplay_collision", false)
	_hit_spark_vfx_visual.set_meta("damage_source", false)
	_hit_spark_vfx_visual.play(&"enemy_hit_spark")
	_hide_enemy_hit_spark_vfx_after_timeout()


# 命中特效是一次性反馈；播放完必须退场，避免敌人已清除后画面仍残留火花。
func _on_enemy_hit_spark_animation_finished() -> void:
	_hide_enemy_hit_spark_vfx()


func _hide_enemy_hit_spark_vfx() -> void:
	if _hit_spark_vfx_visual != null:
		_hit_spark_vfx_visual.visible = false
		_hit_spark_vfx_visual.stop()

	var legacy_hit_spark := get_node_or_null("Stage12HitSpark") as CanvasItem
	if legacy_hit_spark != null:
		legacy_hit_spark.visible = false


func _hide_enemy_hit_spark_vfx_after_timeout() -> void:
	await get_tree().create_timer(HIT_SPARK_VFX_TIMEOUT).timeout
	_hide_enemy_hit_spark_vfx()


# 触碰伤害统一由基类发起，这样子类只需要决定“何时应当能碰到玩家”。
func _deal_touch_damage(touch_damage: int) -> void:
	if _is_defeated or _hurtbox == null:
		return

	# 每个物理帧扫描 hurtbox 重叠体，当前原型依赖玩家无敌帧限制重复受击。
	for body in _hurtbox.get_overlapping_bodies():
		var receiver := _resolve_damage_receiver(body)
		if receiver == null:
			continue

		var receiver_node := receiver as Node2D
		if receiver_node == null:
			continue

		var hit_direction: Vector2 = receiver_node.global_position - global_position
		receiver.call("receive_damage", touch_damage, hit_direction)


# 将碰撞节点、玩家本体和玩家子节点统一解析为 receive_damage 持有者。
func _resolve_damage_receiver(candidate: Object) -> Node:
	# Hurtbox 命中的节点可能是玩家本体，也可能是玩家碰撞子节点；
	# 统一解析为 receive_damage 持有者，避免每个敌人重复写父节点判断。
	if candidate == null:
		return null

	if candidate.has_method("receive_damage"):
		return candidate as Node

	if candidate is Node:
		var parent := (candidate as Node).get_parent()
		if parent != null and parent.has_method("receive_damage"):
			return parent

	return null
