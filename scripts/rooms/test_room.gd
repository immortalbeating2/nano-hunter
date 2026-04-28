extends Node2D

# Stage1-4 测试房只提供基础相机边界和早期移动 / 战斗灰盒场景。
# 它不参与正式主线房间链路，因此保持脚本极薄，避免早期测试入口承担生产逻辑。

# 早期测试依赖固定相机矩形，保证玩家、假人和门控区域在自动化中稳定可见。
const CAMERA_LIMITS := Rect2i(-512, -192, 1024, 384)


# 返回测试房固定相机边界，让 Main 的相机限制逻辑可稳定验证。
func get_camera_limits() -> Rect2i:
	# Main 会优先读取房间相机边界；测试房通过这个稳定接口参与相机验证。
	return CAMERA_LIMITS
