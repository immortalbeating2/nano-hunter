extends "res://scripts/rooms/stage10_room_base.gd"

# Stage10 可选支路房不新增逻辑，依靠 Stage10RoomBase 的 collectible / recovery / branch 契约工作。
# Stage20 将原收集物升级为风印能力；房间仍复用父类位置触发，不建立独立拾取系统。

const WIND_SEAL_PICKUP_ID: StringName = &"branch_reward"


# 支路收集物继续由父类去重，并在首次触发时把风印写入 Main 跨房状态。
func collect_stage10_pickup(pickup_id: StringName) -> void:
	super.collect_stage10_pickup(pickup_id)
	if pickup_id == WIND_SEAL_PICKUP_ID and _main != null and _main.has_method("unlock_wind_seal"):
		_main.call("unlock_wind_seal")
