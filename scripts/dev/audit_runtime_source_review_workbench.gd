extends SceneTree

# 验证运行时来源复核 Workbench 场景与 manifest 可用。

const MANIFEST_PATH := "res://docs/assets/runtime-source-review-workbench-manifest.json"


func _init() -> void:
	var result := _run()
	quit(result)


# 主入口：加载 manifest、实例化场景并确认全部预览纹理可用。
func _run() -> int:
	var manifest := _read_json(MANIFEST_PATH)
	if manifest.is_empty():
		return 1

	var counts: Dictionary = manifest.get("counts", {})
	var expected_entries := int(counts.get("entry_count", -1))
	var expected_outputs := int(counts.get("current_output_count", -1))
	var expected_candidates := int(counts.get("candidate_count", -1))
	if expected_entries <= 0 or expected_outputs <= 0 or expected_candidates <= 0:
		push_error("Runtime source workbench has invalid counts: %s" % counts)
		return 1

	var scene_path := String(manifest.get("scene", ""))
	var scene := ResourceLoader.load(scene_path)
	if scene == null or not scene is PackedScene:
		push_error("Cannot load runtime source review workbench scene: %s" % scene_path)
		return 1
	var instance := (scene as PackedScene).instantiate()
	if instance == null:
		push_error("Cannot instantiate runtime source review workbench scene: %s" % scene_path)
		return 1
	if not instance.has_meta("runtime_source_review_workbench_scene"):
		push_error("Runtime source review workbench root missing metadata.")
		instance.free()
		return 1

	var node_counts := {"current_output": 0, "candidate": 0, "textures": 0}
	if not _audit_runtime_source_cards(instance, node_counts):
		instance.free()
		return 1
	if int(node_counts["current_output"]) != expected_outputs:
		push_error("Current output card count mismatch: expected %s got %s" % [expected_outputs, node_counts["current_output"]])
		instance.free()
		return 1
	if int(node_counts["candidate"]) != expected_candidates:
		push_error("Candidate card count mismatch: expected %s got %s" % [expected_candidates, node_counts["candidate"]])
		instance.free()
		return 1
	var expected_textures := expected_outputs + expected_candidates
	if int(node_counts["textures"]) != expected_textures:
		push_error("Texture load count mismatch: expected %s got %s" % [expected_textures, node_counts["textures"]])
		instance.free()
		return 1

	print("Runtime source review workbench OK: %s assets, %s current outputs, %s candidates" % [
		expected_entries,
		expected_outputs,
		expected_candidates,
	])
	instance.free()
	return 0


# 递归验证当前输出和候选卡片绑定的纹理资源。
func _audit_runtime_source_cards(root: Node, counts: Dictionary) -> bool:
	if root.has_meta("runtime_source_review_kind"):
		var kind := String(root.get_meta("runtime_source_review_kind", ""))
		var resource_path := String(root.get_meta("runtime_source_review_resource", ""))
		if resource_path.is_empty():
			push_error("Runtime source card missing resource path: %s" % root.name)
			return false
		var resource := ResourceLoader.load(resource_path)
		if resource == null or not resource is Texture2D:
			push_error("Runtime source resource is not Texture2D: %s" % resource_path)
			return false
		var texture := resource as Texture2D
		if texture.get_width() <= 0 or texture.get_height() <= 0:
			push_error("Runtime source texture has invalid size: %s" % resource_path)
			return false
		var texture_rect := _find_first_texture_rect(root)
		if texture_rect == null or texture_rect.texture == null:
			push_error("Runtime source card has no TextureRect texture: %s" % resource_path)
			return false
		counts["textures"] = int(counts.get("textures", 0)) + 1
		if kind == "current_output":
			counts["current_output"] = int(counts.get("current_output", 0)) + 1
		elif kind == "candidate":
			counts["candidate"] = int(counts.get("candidate", 0)) + 1
		else:
			push_error("Unknown runtime source review kind: %s" % kind)
			return false
	for child: Node in root.get_children():
		if not _audit_runtime_source_cards(child, counts):
			return false
	return true


# 查找卡片下的第一个 TextureRect。
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
