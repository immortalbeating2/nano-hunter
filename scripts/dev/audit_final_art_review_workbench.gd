extends SceneTree

# 验证最终美术复核 Workbench 场景与 manifest 可用。

const MANIFEST_PATH := "res://docs/assets/final-art-review-workbench-manifest.json"
const REVIEW_QUEUE_PATH := "res://docs/assets/final-art-review-queue.json"


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：加载 manifest、实例化场景、确认当前队列的全部复核卡和预览纹理都可用。
func _run() -> int:
	var manifest := _read_json(MANIFEST_PATH)
	if manifest.is_empty():
		return 1
	var queue := _read_json(REVIEW_QUEUE_PATH)
	if queue.is_empty():
		return 1

	var queue_summary: Dictionary = queue.get("summary", {})
	var counts: Dictionary = manifest.get("counts", {})
	var expected_entries := int(queue_summary.get("asset_count", -1))
	var expected_manual_review := int(queue_summary.get("manual_review_required_count", -1))
	var expected_final_ready := int(queue_summary.get("final_ready_count", -1))

	if int(counts.get("entry_count", -1)) != expected_entries:
		push_error("Workbench entry count mismatch: expected %s got %s" % [expected_entries, counts.get("entry_count", -1)])
		return 1
	if int(counts.get("manual_review_required_count", -1)) != expected_manual_review:
		push_error("Workbench manual review count mismatch: expected %s got %s" % [expected_manual_review, counts.get("manual_review_required_count", -1)])
		return 1
	if int(counts.get("final_ready_count", -1)) != expected_final_ready:
		push_error("Workbench final ready count mismatch: expected %s got %s" % [expected_final_ready, counts.get("final_ready_count", -1)])
		return 1

	var scene_path := String(manifest.get("scene", ""))
	var scene := ResourceLoader.load(scene_path)
	if scene == null or not scene is PackedScene:
		push_error("Cannot load final art review workbench scene: %s" % scene_path)
		return 1
	var instance := (scene as PackedScene).instantiate()
	if instance == null:
		push_error("Cannot instantiate final art review workbench scene: %s" % scene_path)
		return 1
	if not instance.has_meta("final_art_review_workbench_scene"):
		push_error("Final art review workbench root missing metadata.")
		instance.free()
		return 1

	var card_counts := {"cards": 0, "textures": 0, "blockers": 0, "priorities": {}, "families": {}}
	if not _audit_review_cards(instance, card_counts):
		instance.free()
		return 1

	if int(card_counts["cards"]) != expected_entries:
		push_error("Workbench card count mismatch: expected %s got %s" % [expected_entries, card_counts["cards"]])
		instance.free()
		return 1
	if int(card_counts["textures"]) != expected_entries:
		push_error("Workbench texture count mismatch: expected %s got %s" % [expected_entries, card_counts["textures"]])
		instance.free()
		return 1
	if int(card_counts["blockers"]) != int(counts.get("blocker_total", -1)):
		push_error("Workbench blocker total mismatch: expected %s got %s" % [counts.get("blocker_total", -1), card_counts["blockers"]])
		instance.free()
		return 1

	print("Final art review workbench OK: %s cards, %s manual-review assets, %s final-ready assets" % [
		card_counts["cards"],
		expected_manual_review,
		expected_final_ready,
	])
	instance.free()
	return 0


# 递归验证每张复核卡的纹理、priority、family 和 blocker 元数据。
func _audit_review_cards(root: Node, counts: Dictionary) -> bool:
	if root.has_meta("final_art_review_kind"):
		var resource_path := String(root.get_meta("final_art_review_resource", ""))
		if resource_path.is_empty():
			push_error("Review card missing resource path: %s" % root.name)
			return false
		var resource := ResourceLoader.load(resource_path)
		if resource == null or not resource is Texture2D:
			push_error("Review card resource is not Texture2D: %s" % resource_path)
			return false
		var texture := resource as Texture2D
		if texture.get_width() <= 0 or texture.get_height() <= 0:
			push_error("Review card texture has invalid size: %s" % resource_path)
			return false
		var texture_rect := _find_first_texture_rect(root)
		if texture_rect == null or texture_rect.texture == null:
			push_error("Review card has no TextureRect texture: %s" % resource_path)
			return false

		counts["cards"] = int(counts.get("cards", 0)) + 1
		counts["textures"] = int(counts.get("textures", 0)) + 1
		counts["blockers"] = int(counts.get("blockers", 0)) + int(root.get_meta("final_art_review_blocker_count", 0))
		var priorities: Dictionary = counts.get("priorities", {})
		var priority := String(root.get_meta("final_art_review_priority", "unknown"))
		priorities[priority] = int(priorities.get(priority, 0)) + 1
		counts["priorities"] = priorities
		var families: Dictionary = counts.get("families", {})
		var family := String(root.get_meta("final_art_review_family", "unknown"))
		families[family] = int(families.get(family, 0)) + 1
		counts["families"] = families

	for child: Node in root.get_children():
		if not _audit_review_cards(child, counts):
			return false
	return true


# 查找复核卡下的第一个 TextureRect。
func _find_first_texture_rect(node: Node) -> TextureRect:
	if node is TextureRect:
		return node as TextureRect
	for child: Node in node.get_children():
		var found := _find_first_texture_rect(child)
		if found != null:
			return found
	return null


# 读取 JSON 并确保顶层为 Dictionary。
func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing JSON file: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open JSON file: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("JSON is not a dictionary: %s" % path)
		return {}
	return parsed
