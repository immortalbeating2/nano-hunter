extends GutTest

# 正式 Demo 蓝图 V2 契约回归：保护 18 房、48 屏段与双视图产物，
# 防止后续施工重新退化成只有平台轮廓的 schema v1。

const BLUEPRINT_PATH := "res://spec-design/formal-demo-room-blueprints/formal-demo-room-blueprints.json"
const EXPECTED_ROOM_IDS := [
	"F01", "F02", "F03", "F04", "F05", "F06", "F07", "F08", "F09",
	"F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18",
]
const REQUIRED_TOP_LEVEL_FIELDS := [
	"blueprint_contract",
	"connection_vocabulary",
	"progression_state_matrix",
	"encounter_curve",
	"presentation_contract",
	"acceptance_contract",
]
const REQUIRED_ROOM_FIELDS := [
	"blueprint_status",
	"player_knowledge",
	"timing_and_rhythm",
	"connections",
	"interactions",
	"encounters",
	"hazards_and_recovery",
	"rewards",
	"state_variants",
	"camera",
	"presentation",
	"map_semantics",
	"qa",
	"views",
]
const REQUIRED_CONNECTION_FIELDS := [
	"connection_id",
	"type",
	"target_room",
	"source_anchor_id",
	"source_anchor_position",
	"target_spawn_id",
	"target_spawn_position",
	"target_facing",
	"directionality",
	"interaction_verb",
	"requirements",
	"blocked_feedback",
	"transition_feedback",
	"safe_arrival_contract",
	"anti_retrigger_contract",
	"map_representation",
]


func test_blueprint_v2_is_complete_for_all_rooms_and_segments() -> void:
	var manifest := _load_manifest()
	assert_eq(int(manifest.get("schema_version", 0)), 2)
	assert_eq(str(manifest.get("design_status", "")), "gameplay_blueprint_complete_runtime_scene_pending")
	for field: String in REQUIRED_TOP_LEVEL_FIELDS:
		assert_true(manifest.has(field), "蓝图缺少顶层合同：%s" % field)

	var rooms: Array = manifest.get("rooms", [])
	assert_eq(rooms.size(), 18)
	var actual_ids: Array = []
	var segment_count := 0
	for room: Dictionary in rooms:
		var room_id := str(room.get("id", ""))
		actual_ids.append(room_id)
		for field: String in REQUIRED_ROOM_FIELDS:
			assert_true(room.has(field), "%s 缺少字段：%s" % [room_id, field])
		assert_eq(str(room.get("blueprint_status", "")), "gameplay_blueprint_complete", "%s 尚未达到完整蓝图状态。" % room_id)

		var segments: Array = room.get("segments", [])
		segment_count += segments.size()
		for segment: Dictionary in segments:
			assert_true(segment.has("camera"), "%s/%s 缺少相机合同。" % [room_id, segment.get("id", "?")])
			assert_true(segment.has("presentation"), "%s/%s 缺少表现合同。" % [room_id, segment.get("id", "?")])

		var connections: Array = room.get("connections", [])
		assert_gt(connections.size(), 0, "%s 必须至少声明一个连接。" % room_id)
		for connection: Dictionary in connections:
			for field: String in REQUIRED_CONNECTION_FIELDS:
				assert_true(connection.has(field), "%s 连接缺少字段：%s" % [room_id, field])
			assert_true(EXPECTED_ROOM_IDS.has(str(connection.get("target_room", ""))), "%s 连接指向未知房间。" % room_id)

		var recovery: Dictionary = room.get("hazards_and_recovery", {})
		assert_ne(str(recovery.get("failure_reset", "")), "", "%s 必须声明失败重置。" % room_id)
		var encounters: Array = room.get("encounters", [])
		if encounters.is_empty():
			assert_eq(str(room.get("encounter_policy", "")), "safe_no_encounter", "%s 无遭遇时必须说明安全房策略。" % room_id)
			assert_ne(str(room.get("safe_room_reason", "")), "", "%s 无遭遇时必须说明原因。" % room_id)
		else:
			for encounter: Dictionary in encounters:
				assert_ne(str(encounter.get("failure_reset", "")), "", "%s 遭遇缺少失败重置。" % room_id)

	assert_eq(actual_ids, EXPECTED_ROOM_IDS)
	assert_eq(segment_count, 48)


func test_blueprint_v2_has_18_topology_and_18_gameplay_views() -> void:
	var manifest := _load_manifest()
	var topology_paths: Dictionary = {}
	var gameplay_paths: Dictionary = {}
	for room: Dictionary in manifest.get("rooms", []):
		var views: Dictionary = room.get("views", {})
		var topology_path := str(views.get("topology", ""))
		var gameplay_path := str(views.get("side_view_gameplay", ""))
		topology_paths[topology_path] = true
		gameplay_paths[gameplay_path] = true
		assert_true(FileAccess.file_exists(topology_path), "缺少 topology 图：%s" % topology_path)
		assert_true(FileAccess.file_exists(gameplay_path), "缺少 side_view_gameplay 图：%s" % gameplay_path)
	assert_eq(topology_paths.size(), 18)
	assert_eq(gameplay_paths.size(), 18)


func _load_manifest() -> Dictionary:
	assert_true(FileAccess.file_exists(BLUEPRINT_PATH), "蓝图 JSON 必须存在。")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(BLUEPRINT_PATH))
	assert_typeof(parsed, TYPE_DICTIONARY, "蓝图 JSON 必须解析为 Dictionary。")
	return parsed as Dictionary
