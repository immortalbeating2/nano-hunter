extends Node2D

const CAMERA_LIMITS := Rect2i(-512, -192, 1024, 384)


func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS
