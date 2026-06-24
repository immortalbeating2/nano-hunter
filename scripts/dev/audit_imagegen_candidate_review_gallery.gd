extends SceneTree

# 验证 image_gen raw candidate 审图场景与 manifest 可用。

const MANIFEST_PATH := "res://docs/assets/imagegen-candidate-review-gallery-manifest.json"


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：加载 manifest、实例化场景、确认候选卡和纹理资源都可用。
func _run() -> int:
	var manifest := _read_json(MANIFEST_PATH)
	if manifest.is_empty():
		return 1

	var counts: Dictionary = manifest.get("counts", {})
	var expected_candidates := int(counts.get("unselected_candidates", -1))
	var expected_assets := int(counts.get("review_required_assets", -1))
	if expected_candidates <= 0 or expected_assets <= 0:
		push_error("Candidate review manifest has invalid counts: %s" % counts)
		return 1

	var scene_path := String(manifest.get("scene", ""))
	var scene := ResourceLoader.load(scene_path)
	if scene == null or not scene is PackedScene:
		push_error("Cannot load candidate review gallery scene: %s" % scene_path)
		return 1
	var instance := (scene as PackedScene).instantiate()
	if instance == null:
		push_error("Cannot instantiate candidate review gallery scene: %s" % scene_path)
		return 1
	if not instance.has_meta("candidate_review_gallery_scene"):
		push_error("Candidate review gallery root missing metadata.")
		instance.free()
		return 1

	var preview_count := _count_candidate_nodes(instance)
	if preview_count != expected_candidates:
		push_error("Candidate card count mismatch: expected %s got %s" % [expected_candidates, preview_count])
		instance.free()
		return 1

	var resource_count := {"textures": 0}
	if not _audit_candidate_resources(instance, resource_count):
		instance.free()
		return 1
	if int(resource_count["textures"]) != expected_candidates:
		push_error("Candidate texture load count mismatch: expected %s got %s" % [expected_candidates, resource_count["textures"]])
		instance.free()
		return 1

	print("Imagegen candidate review gallery OK: %s candidates, %s assets" % [expected_candidates, expected_assets])
	instance.free()
	return 0


# 统计候选卡节点数量。
func _count_candidate_nodes(root: Node) -> int:
	var count := 0
	if root.has_meta("candidate_review_kind"):
		count += 1
	for child: Node in root.get_children():
		count += _count_candidate_nodes(child)
	return count


# 递归验证候选卡绑定的纹理资源。
func _audit_candidate_resources(root: Node, counts: Dictionary) -> bool:
	if root.has_meta("candidate_review_kind"):
		var resource_path := String(root.get_meta("candidate_review_resource", ""))
		if resource_path.is_empty():
			push_error("Candidate card missing resource path: %s" % root.name)
			return false
		var resource := ResourceLoader.load(resource_path)
		if resource == null or not resource is Texture2D:
			push_error("Candidate resource is not Texture2D: %s" % resource_path)
			return false
		var texture := resource as Texture2D
		if texture.get_width() <= 0 or texture.get_height() <= 0:
			push_error("Candidate texture has invalid size: %s" % resource_path)
			return false
		var texture_rect := _find_first_texture_rect(root)
		if texture_rect == null or texture_rect.texture == null:
			push_error("Candidate card has no TextureRect texture: %s" % resource_path)
			return false
		counts["textures"] = int(counts.get("textures", 0)) + 1
	for child: Node in root.get_children():
		if not _audit_candidate_resources(child, counts):
			return false
	return true


# 查找候选卡下的第一个 TextureRect。
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
