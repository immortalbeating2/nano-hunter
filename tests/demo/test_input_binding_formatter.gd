extends GutTest

# 输入短标签红测：读取真实 InputMap，并确保临时重绑不污染后续测试。

const FORMATTER_PATH := "res://scripts/ui/input_binding_formatter.gd"
const TEMP_ACTION: StringName = &"test_input_binding_formatter_button"

var _saved_stance_events: Array[InputEvent] = []
var _stance_binding_replaced := false


func after_each() -> void:
	if _stance_binding_replaced:
		InputMap.action_erase_events(&"stance_switch")
		for event: InputEvent in _saved_stance_events:
			InputMap.action_add_event(&"stance_switch", event)
		_stance_binding_replaced = false
		_saved_stance_events.clear()
	if InputMap.has_action(TEMP_ACTION):
		InputMap.erase_action(TEMP_ACTION)


func test_formatter_reports_default_keyboard_and_controller_bindings() -> void:
	var formatter := _load_formatter()
	if formatter == null:
		return
	assert_eq(_action_label(formatter, &"element_switch", "keyboard"), "Q")
	assert_eq(_action_label(formatter, &"stance_switch", "keyboard"), "E")
	assert_eq(_action_label(formatter, &"element_switch", "controller"), "LB / L1")
	assert_eq(_action_label(formatter, &"stance_switch", "controller"), "RB / R1")
	assert_eq(_action_label(formatter, &"not_a_bound_action", "keyboard"), "未绑定")


func test_formatter_reflects_a_temporary_real_inputmap_rebinding() -> void:
	var formatter := _load_formatter()
	if formatter == null:
		return
	_saved_stance_events.assign(InputMap.action_get_events(&"stance_switch"))
	_stance_binding_replaced = true
	InputMap.action_erase_events(&"stance_switch")
	var replacement := InputEventKey.new()
	replacement.keycode = KEY_R
	replacement.physical_keycode = KEY_R
	InputMap.action_add_event(&"stance_switch", replacement)
	assert_eq(_action_label(formatter, &"stance_switch", "keyboard"), "R")
	_restore_stance_binding()
	assert_eq(_action_label(formatter, &"stance_switch", "keyboard"), "E")
	assert_eq(_action_label(formatter, &"stance_switch", "controller"), "RB / R1")


# 手柄短标签必须覆盖当前生产布局；未知编号保留原始 index，不能伪装成已知键。
func test_formatter_maps_supported_controller_buttons_and_preserves_unknown_index() -> void:
	var formatter := _load_formatter()
	if formatter == null:
		return
	var cases := [
		[JOY_BUTTON_A, "A / Cross"],
		[JOY_BUTTON_B, "B / Circle"],
		[JOY_BUTTON_X, "X / Square"],
		[JOY_BUTTON_Y, "Y / Triangle"],
		[JOY_BUTTON_LEFT_SHOULDER, "LB / L1"],
		[JOY_BUTTON_RIGHT_SHOULDER, "RB / R1"],
		[JOY_BUTTON_START, "Menu"],
		[42, "按钮 42"],
	]
	for case: Array in cases:
		InputMap.add_action(TEMP_ACTION)
		var event := InputEventJoypadButton.new()
		event.button_index = int(case[0])
		InputMap.action_add_event(TEMP_ACTION, event)
		assert_eq(_action_label(formatter, TEMP_ACTION, "controller"), str(case[1]))
		InputMap.erase_action(TEMP_ACTION)
	assert_eq(_action_label(formatter, &"not_a_bound_action", "controller"), "未绑定")


func _load_formatter() -> GDScript:
	if not ResourceLoader.exists(FORMATTER_PATH):
		assert_true(false, "必须提供 InputBindingFormatter，并从真实 InputMap 构造短标签。")
		return null
	var formatter := load(FORMATTER_PATH) as GDScript
	assert_not_null(formatter, "必须提供 InputBindingFormatter，并从真实 InputMap 构造短标签。")
	return formatter


func _action_label(formatter: GDScript, action: StringName, device: String) -> String:
	return str(formatter.call("action_label", action, device))


# 临时重绑测试必须在断言后立即恢复，after_each 只作为失败路径兜底。
func _restore_stance_binding() -> void:
	InputMap.action_erase_events(&"stance_switch")
	for event: InputEvent in _saved_stance_events:
		InputMap.action_add_event(&"stance_switch", event)
	_stance_binding_replaced = false
	_saved_stance_events.clear()
