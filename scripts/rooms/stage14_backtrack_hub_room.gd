extends "res://scripts/rooms/stage14_backtracking_room_base.gd"

# F15 只汇总三处旧地点回访进度，并以 F07 主捷径事实开放 Boss 前路线；
# F06 与 F09 奖励保持可选，缺失时不会造成软锁。


@export var required_revisit_reward_id: StringName = &"stage14_reward_two"


func _ready() -> void:
	super._ready()
	_sync_revisit_hub_state()


func bind_main(main: Node) -> void:
	super.bind_main(main)
	_sync_revisit_hub_state()


func _process(delta: float) -> void:
	_sync_revisit_hub_state()
	super._process(delta)


func is_boss_route_ready() -> bool:
	return (
		required_revisit_reward_id == StringName()
		or (
			_main != null
			and _main.has_method("has_stage14_backtrack_reward")
			and bool(_main.call("has_stage14_backtrack_reward", required_revisit_reward_id))
		)
	)


func get_hud_context() -> Dictionary:
	var context := super.get_hud_context()
	context.merge({
		"boss_route_ready": is_boss_route_ready(),
		"required_revisit_reward_id": required_revisit_reward_id,
	}, true)
	return context


# 主回访未完成时仍允许从左侧返回；只阻止右侧普通出口进入 F16。
func _sync_revisit_hub_state() -> void:
	_gate_unlocked = is_boss_route_ready()
	_apply_gate_lock_state()
	var seal := get_node_or_null("BossRouteSeal") as CanvasItem
	if seal != null:
		seal.visible = not _gate_unlocked
	var progress_root := get_node_or_null("RevisitProgress")
	if progress_root == null:
		return
	var collected_count := get_stage14_backtrack_reward_count()
	for index in range(3):
		var marker := progress_root.get_node_or_null("Marker%d" % (index + 1)) as CanvasItem
		if marker != null:
			marker.modulate = Color.WHITE if index < collected_count else Color(0.28, 0.34, 0.4, 0.45)
