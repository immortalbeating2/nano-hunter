extends "res://scripts/rooms/stage14_backtracking_room_base.gd"

# Air Dash gate 是 Stage14 的移动挑战样板，单独扩大镜头边界，不影响其它 Stage14 房间。
const FORMAL_GATE_CAMERA_LIMITS := Rect2i(-512, -288, 1536, 576)


# Main 继续通过既有房间契约读取镜头边界。
func get_camera_limits() -> Rect2i:
	return FORMAL_GATE_CAMERA_LIMITS
