extends "res://scripts/rooms/stage13_miasma_marsh_room_base.gd"

# mixed gauntlet 是三类敌人混合战斗样板，单独扩大房间边界。
const FORMAL_GAUNTLET_CAMERA_LIMITS := Rect2i(-512, -288, 1664, 576)


func get_camera_limits() -> Rect2i:
	return FORMAL_GAUNTLET_CAMERA_LIMITS
