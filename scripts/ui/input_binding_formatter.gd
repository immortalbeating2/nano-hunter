extends RefCounted
class_name InputBindingFormatter

# InputBindingFormatter 把生产 InputMap 中的首个匹配事件转换为短标签。
# 调用方只负责选择设备类型；缺失 action 或未知设备一律返回“未绑定”。

const DEVICE_KEYBOARD := "keyboard"
const DEVICE_CONTROLLER := "controller"


# 从真实 InputMap 读取绑定，避免 HUD / Controls 在重绑定后继续展示硬编码按键。
static func action_label(action: StringName, device: String) -> String:
	for event: InputEvent in InputMap.action_get_events(action):
		if device == DEVICE_KEYBOARD and event is InputEventKey:
			var key_event := event as InputEventKey
			var keycode := key_event.physical_keycode
			if keycode == 0:
				keycode = key_event.keycode
			return OS.get_keycode_string(keycode) if keycode != 0 else "未绑定"
		if device == DEVICE_CONTROLLER and event is InputEventJoypadButton:
			return _joy_button_label((event as InputEventJoypadButton).button_index)
	return "未绑定"


# 同时给出 Xbox / PlayStation 常用名称；未知编号保留 index，禁止伪造默认绑定。
static func _joy_button_label(button_index: int) -> String:
	match button_index:
		JOY_BUTTON_A:
			return "A / Cross"
		JOY_BUTTON_B:
			return "B / Circle"
		JOY_BUTTON_X:
			return "X / Square"
		JOY_BUTTON_Y:
			return "Y / Triangle"
		JOY_BUTTON_LEFT_SHOULDER:
			return "LB / L1"
		JOY_BUTTON_RIGHT_SHOULDER:
			return "RB / R1"
		JOY_BUTTON_START:
			return "Menu"
		_:
			return "按钮 %d" % button_index
