extends StaticBody2D

# TrainingDummy 是阶段 3-5 用来验证攻击命中反馈的静态目标。
# 它记录最近一次命中方向和力度，并用短暂位移 / 变色让玩家和测试都能确认攻击生效。

# 命中信号供教程房推进攻击教学，也供早期测试确认攻击确实发生。
signal hit_registered(hit_count: int)

# 视觉反馈参数只影响假人读招，不参与玩家攻击数值计算。
@export var hit_flash_duration: float = 0.14
@export var hit_offset_distance: float = 12.0
@export var hit_scale := Vector2(1.08, 0.92)

# 公开读值保留最近一次命中的方向、力度和累计次数，作为攻击契约的测试入口。
var last_hit_direction := Vector2.ZERO
var last_knockback_force := 0.0
var hit_count: int = 0

# 反馈计时器只控制假人自身视觉恢复。
var _hit_feedback_timer := 0.0


# 初始化训练假人视觉基线，保证首帧没有残留命中反馈。
func _ready() -> void:
	# 初始状态和反馈结束共用复位逻辑，避免初始颜色与恢复颜色漂移。
	_reset_feedback_visuals()


# 每帧递减命中反馈计时，到期后恢复默认位置、颜色和缩放。
func _process(delta: float) -> void:
	# 命中反馈只持续极短时间，结束后必须回到原位，避免后续测试读到残留视觉状态。
	if _hit_feedback_timer <= 0.0:
		return

	_hit_feedback_timer = maxf(_hit_feedback_timer - delta, 0.0)
	if _hit_feedback_timer <= 0.0:
		_reset_feedback_visuals()


# 玩家攻击和测试都通过 receive_attack 进入假人契约。
func receive_attack(hit_direction: Vector2, knockback_force: float) -> void:
	# 训练目标不参与生命系统，只记录命中次数和最近一次攻击参数。
	hit_count += 1
	last_hit_direction = hit_direction
	last_knockback_force = knockback_force
	_hit_feedback_timer = hit_flash_duration
	hit_registered.emit(hit_count)

	var direction := hit_direction.normalized()
	$Body.position = direction * hit_offset_distance
	$Body.color = Color(1.0, 0.92, 0.68, 1.0)
	$Body.scale = hit_scale


# 复位训练假人的占位视觉，供初始化和命中反馈结束共同调用。
func _reset_feedback_visuals() -> void:
	# 复位逻辑集中在这里，确保 ready 和命中反馈结束走同一套视觉基线。
	$Body.position = Vector2.ZERO
	$Body.color = Color(0.654902, 0.498039, 0.298039, 1.0)
	$Body.scale = Vector2.ONE
