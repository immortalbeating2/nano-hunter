extends GutTest

# 方案 B 灰盒遥测契约：数据用于定位房间节奏与误触，不得自动生成真人体验结论。

const TELEMETRY_SCRIPT := preload("res://scripts/dev/room_playtest_telemetry.gd")
const CAPTURE_SCRIPT_PATH := "res://scripts/dev/capture_formal_demo_room_recovery.gd"


func test_session_records_room_timing_directions_and_reversal() -> void:
	var telemetry = TELEMETRY_SCRIPT.new()
	telemetry.start_session({"tester": "automation"}, 1000)
	telemetry.enter_room("F03", "res://scenes/rooms/stage11_demo_end_room.tscn", &"stage11_demo_end_start", &"right", Vector2.ZERO, 1200)
	telemetry.record_direction_sample(&"right", 1300)
	telemetry.record_direction_sample(&"left", 1500)
	telemetry.leave_room(&"left", "F02", Vector2(-120, 160), 2200)

	var snapshot: Dictionary = telemetry.get_snapshot(2500)
	assert_eq(snapshot.get("schema"), "nano_hunter_room_playtest_v1")
	assert_eq(snapshot.get("human_acceptance"), "pending_external_playtest")
	assert_eq(snapshot.get("room_visits", []).size(), 1)
	var visit: Dictionary = snapshot.get("room_visits", [])[0]
	assert_eq(visit.get("duration_msec"), 1000)
	assert_eq(visit.get("entry_direction"), "right")
	assert_eq(visit.get("exit_direction"), "left")
	assert_eq(visit.get("direction_reversal_count"), 1)


func test_session_records_failures_map_opens_exit_misfires_and_shortcut_discovery() -> void:
	var telemetry = TELEMETRY_SCRIPT.new()
	telemetry.start_session({}, 0)
	telemetry.enter_room("F14", "res://scenes/rooms/stage14_air_dash_gate_room.tscn", &"stage14_air_dash_gate_start", &"right", Vector2(-384, 160), 100)
	telemetry.record_death(Vector2(420, 260), &"hazard", 400)
	telemetry.record_failure(&"air_dash_proof_missed", Vector2(540, 64), 500)
	telemetry.record_map_open(600)
	telemetry.record_exit_contact(&"right_exit", false, Vector2(928, 32), 700)
	telemetry.record_ability_route(&"air_dash", "F14", "F15", &"stage14_gate_shortcut", 900)
	telemetry.leave_room(&"right", "F15", Vector2(928, 32), 1100)

	var snapshot: Dictionary = telemetry.get_snapshot(1200)
	assert_eq(snapshot.get("death_count"), 1)
	assert_eq(snapshot.get("failure_count"), 1)
	assert_eq(snapshot.get("map_open_count"), 1)
	assert_eq(snapshot.get("exit_misfire_count"), 1)
	assert_eq(snapshot.get("ability_routes", []).size(), 1)
	assert_eq(snapshot.get("ability_routes", [])[0].get("discovery_msec"), 900)
	assert_eq(snapshot.get("events", []).size(), 8)


func test_snapshot_closes_open_visit_without_claiming_human_approval() -> void:
	var telemetry = TELEMETRY_SCRIPT.new()
	telemetry.start_session({"tester": "human_candidate"}, 200)
	telemetry.enter_room("F01", "res://scenes/rooms/tutorial_room.tscn", &"tutorial_start", &"right", Vector2(-480, 160), 300)

	var snapshot: Dictionary = telemetry.get_snapshot(800)
	assert_eq(snapshot.get("session_duration_msec"), 600)
	assert_eq(snapshot.get("active_room_visit", {}).get("elapsed_msec"), 500)
	assert_false(bool(snapshot.get("human_approved", true)))
	assert_eq(snapshot.get("boundary"), "telemetry_and_screenshots_are_diagnostic_evidence_not_human_acceptance")


func test_capture_runner_reserves_three_views_per_room_without_human_claim() -> void:
	var source := FileAccess.get_file_as_string(CAPTURE_SCRIPT_PATH)
	assert_string_contains(source, 'const CAPTURE_PHASES := ["entry", "core", "exit"]')
	assert_string_contains(source, '"human_acceptance": "pending_external_playtest"')
	assert_string_contains(source, "automated_capture_is_diagnostic_evidence_not_human_playtest_acceptance")
