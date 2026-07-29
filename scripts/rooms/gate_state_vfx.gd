extends RefCounted

# GateStateVfx 只负责给门禁和机关状态变化补一层可读的运行态反馈。
# 它复用现有封印 VFX 资产，不改变门控碰撞、房间推进或存档语义。

const SEAL_MAGIC_FRAMES := preload("res://assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.spriteframes.tres")
const SEAL_MAGIC_ANIMATION: StringName = &"seal_magic"
const ASSET_ID := "vfx_seal_magic_atlas_ai01"


# 在 anchor 下创建或更新一个短暂的解锁反馈动画；只有经历过锁定状态后才播放。
static func sync_unlock_feedback(
	anchor: Node,
	unlocked: bool,
	node_name: StringName = &"GateUnlockVfxArt",
	local_position: Vector2 = Vector2.ZERO,
	local_scale: Vector2 = Vector2(0.36, 0.36),
	runtime_source := "vfx_seal_magic_atlas_ai01.gate_unlock_feedback"
) -> AnimatedSprite2D:
	if anchor == null:
		return null

	var vfx := anchor.get_node_or_null(NodePath(String(node_name))) as AnimatedSprite2D
	if vfx == null:
		vfx = AnimatedSprite2D.new()
		vfx.name = String(node_name)
		anchor.add_child(vfx)
		var hide_callback := Callable(vfx, "hide")
		if not vfx.animation_finished.is_connected(hide_callback):
			vfx.animation_finished.connect(hide_callback)

	vfx.sprite_frames = SEAL_MAGIC_FRAMES
	vfx.animation = SEAL_MAGIC_ANIMATION
	vfx.centered = true
	vfx.position = local_position
	vfx.scale = local_scale
	vfx.z_index = 20
	vfx.modulate = Color(0.62, 1.0, 0.76, 0.68)
	vfx.set_meta("asset_id", ASSET_ID)
	vfx.set_meta("runtime_source", runtime_source)

	var seen_locked_key := "%s_seen_locked" % String(node_name)
	var played_unlock_key := "%s_played_unlock" % String(node_name)
	if not unlocked:
		anchor.set_meta(seen_locked_key, true)
		anchor.set_meta(played_unlock_key, false)
		vfx.stop()
		vfx.visible = false
		return vfx

	if not bool(anchor.get_meta(seen_locked_key, false)):
		vfx.visible = false
		return vfx

	if bool(anchor.get_meta(played_unlock_key, false)):
		return vfx

	anchor.set_meta(played_unlock_key, true)
	vfx.visible = true
	vfx.play(SEAL_MAGIC_ANIMATION)
	vfx.frame = 0
	return vfx
