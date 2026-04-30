extends GutTest

# Stage16 专项 GUT 保护 Alpha Demo 打包候选的退出条件：
# 五房终局封印链、Stage15 接入、Main 进度快照、完整重开、Demo shell、HUD 完成态、
# 灰盒主线 driver，以及资产 / QA / release notes 文档门禁。

const Stage16AlphaDemoGrayboxDriver := preload("res://tests/stage16/support/stage16_alpha_demo_graybox_driver.gd")

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const STAGE15_COMPLETION_ROOM_PATH := "res://scenes/rooms/stage15_completion_room.tscn"
const STAGE16_SEAL_RELEASE_THRESHOLD_ROOM_PATH := "res://scenes/rooms/stage16_seal_release_threshold_room.tscn"
const STAGE16_TALISMAN_RELAY_ROOM_PATH := "res://scenes/rooms/stage16_talisman_relay_room.tscn"
const STAGE16_BACKTRACK_CONFIRMATION_ROOM_PATH := "res://scenes/rooms/stage16_backtrack_confirmation_room.tscn"
const STAGE16_CORRUPTION_PURGE_ROOM_PATH := "res://scenes/rooms/stage16_corruption_purge_room.tscn"
const STAGE16_ALPHA_DEMO_END_ROOM_PATH := "res://scenes/rooms/stage16_alpha_demo_end_room.tscn"
const ASSET_MANIFEST_PATH := "res://docs/assets/asset-manifest.md"
const QA_CHECKLIST_PATH := "res://docs/deliverables/stage16-alpha-demo-candidate/qa-checklist.md"
const RELEASE_NOTES_PATH := "res://docs/deliverables/stage16-alpha-demo-candidate/release-notes.md"

const STAGE16_ROOM_PATHS := [
	STAGE16_SEAL_RELEASE_THRESHOLD_ROOM_PATH,
	STAGE16_TALISMAN_RELAY_ROOM_PATH,
	STAGE16_BACKTRACK_CONFIRMATION_ROOM_PATH,
	STAGE16_CORRUPTION_PURGE_ROOM_PATH,
	STAGE16_ALPHA_DEMO_END_ROOM_PATH,
]


# 输入清理保护 Demo shell 暂停 / 继续和重开测试不会被上一条残留动作污染。
func before_each() -> void:
	for action_name in ["move_left", "move_right", "jump", "attack", "dash", "recover", "ui_cancel", "ui_accept"]:
		_release_action_if_present(action_name)


# 每条 Stage16 测试结束后释放输入，保证灰盒 driver 和 HUD 断言相互独立。
func after_each() -> void:
	before_each()


# 保护 Stage16 房间集合：五个终局封印链房间必须存在，并可作为资源加载。
func test_stage16_five_room_resources_exist() -> void:
	for room_path in STAGE16_ROOM_PATHS:
		assert_true(ResourceLoader.exists(room_path), "缺少 Stage16 房间资源：%s" % room_path)


# 保护 Stage15 到 Stage16 的接入：completion room 的出口必须进入 Stage16 第一房。
func test_stage15_completion_room_links_to_stage16_entry() -> void:
	var room := await _spawn_room(STAGE15_COMPLETION_ROOM_PATH)
	var player := await _spawn_player_with_floor(Vector2.ZERO)
	var transitions: Array = []

	room.call("bind_player", player)
	room.connect("room_transition_requested", func(target_room_path: String, spawn_id: StringName) -> void:
		transitions.append({"target": target_room_path, "spawn": spawn_id})
	)

	player.global_position = room.get_node("ExitZone").global_position
	await _advance_process_frames(4)

	assert_eq(transitions.size(), 1)
	if transitions.is_empty():
		return
	assert_eq(transitions[0].get("target"), STAGE16_SEAL_RELEASE_THRESHOLD_ROOM_PATH)
	assert_eq(transitions[0].get("spawn"), &"stage16_seal_release_threshold_start")


# 保护 Main 快照契约：Stage16 完成态、release notes 和 QA checklist 必须是稳定读值。
func test_main_snapshot_exposes_stage16_release_notes_and_qa_flags() -> void:
	var main_scene := await _spawn_main_scene()
	assert_true(main_scene.has_method("get_demo_progress_snapshot"))

	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")
	assert_true(snapshot.has("stage16_alpha_demo_completed"))
	assert_true(snapshot.has("stage16_release_notes_ready"))
	assert_true(snapshot.has("stage16_qa_checklist_ready"))
	assert_false(bool(snapshot.get("stage16_alpha_demo_completed", true)))
	assert_false(bool(snapshot.get("stage16_release_notes_ready", true)))
	assert_false(bool(snapshot.get("stage16_qa_checklist_ready", true)))


# 保护完整重开语义：restart_demo 必须清理 Stage14 / Stage15 / Stage16 运行期进度。
func test_restart_demo_clears_stage14_stage15_and_stage16_runtime_state() -> void:
	var main_scene := await _spawn_main_scene()

	if main_scene.has_method("unlock_air_dash"):
		main_scene.call("unlock_air_dash")
	if main_scene.has_method("collect_stage14_backtrack_reward"):
		main_scene.call("collect_stage14_backtrack_reward", &"stage16_restart_probe_one")
		main_scene.call("collect_stage14_backtrack_reward", &"stage16_restart_probe_two")
	if main_scene.has_method("mark_stage15_boss_defeated"):
		main_scene.call("mark_stage15_boss_defeated")
	if main_scene.has_method("mark_stage16_alpha_demo_completed"):
		main_scene.call("mark_stage16_alpha_demo_completed")

	assert_true(main_scene.has_method("restart_demo"))
	main_scene.call("restart_demo")
	await _advance_process_frames(4)

	var snapshot: Dictionary = main_scene.call("get_demo_progress_snapshot")
	assert_false(bool(snapshot.get("air_dash_unlocked", true)))
	assert_eq(int(snapshot.get("stage14_backtrack_reward_count", -1)), 0)
	assert_false(bool(snapshot.get("stage15_boss_defeated", true)))
	assert_false(bool(snapshot.get("stage16_alpha_demo_completed", true)))
	assert_eq(_get_room_path(main_scene), "res://scenes/rooms/tutorial_room.tscn")


# 保护 Demo shell 最小契约：主菜单入口、暂停、继续和重开应由 Main 提供稳定接口。
func test_demo_shell_exposes_start_pause_resume_and_restart_contract() -> void:
	var main_scene := await _spawn_main_scene()

	assert_true(main_scene.has_method("start_demo"))
	assert_true(main_scene.has_method("pause_demo"))
	assert_true(main_scene.has_method("resume_demo"))
	assert_true(main_scene.has_method("is_demo_paused"))
	assert_true(main_scene.has_method("restart_demo"))
	if not (
		main_scene.has_method("start_demo")
		and main_scene.has_method("pause_demo")
		and main_scene.has_method("resume_demo")
		and main_scene.has_method("is_demo_paused")
	):
		return

	main_scene.call("start_demo")
	await _advance_process_frames(2)
	main_scene.call("pause_demo")
	await _advance_process_frames(2)
	assert_true(bool(main_scene.call("is_demo_paused")))

	main_scene.call("resume_demo")
	await _advance_process_frames(2)
	assert_false(bool(main_scene.call("is_demo_paused")))

	main_scene.call("restart_demo")
	await _advance_process_frames(2)
	assert_eq(_get_room_path(main_scene), "res://scenes/rooms/tutorial_room.tscn")


# 保护 HUD 完成态优先级：Alpha Demo 完成后不应继续显示旧 Boss 目标、旧收集行或旧恢复充能行。
func test_stage16_completion_hud_hides_old_boss_collectible_and_recovery_lines() -> void:
	assert_true(ResourceLoader.exists(STAGE16_ALPHA_DEMO_END_ROOM_PATH), "缺少 Stage16 终点房，无法验证 HUD 完成态")
	if not ResourceLoader.exists(STAGE16_ALPHA_DEMO_END_ROOM_PATH):
		return

	var main_scene := await _spawn_main_scene()
	main_scene.call("transition_to_room", STAGE16_ALPHA_DEMO_END_ROOM_PATH, &"stage16_alpha_demo_end_start")
	await _advance_process_frames(4)

	if main_scene.has_method("mark_stage16_alpha_demo_completed"):
		main_scene.call("mark_stage16_alpha_demo_completed")
	await _advance_process_frames(4)

	var progress_label := main_scene.get_node("HUD/TutorialHUD/BattlePanel/ProgressLabel") as Label
	assert_not_null(progress_label)
	assert_string_contains(progress_label.text, "Alpha Demo")
	assert_string_contains(progress_label.text, "已完成")
	assert_eq(progress_label.text.find("主目标：击败封印守卫"), -1)
	assert_eq(progress_label.text.find("收集："), -1)
	assert_eq(progress_label.text.find("恢复充能"), -1)
	assert_eq(progress_label.text.find("恢复：未激活"), -1)


# 保护灰盒主线：测试侧 driver 必须能从生产 Main.tscn 推进到 Stage16 终点。
func test_stage16_graybox_driver_reaches_alpha_demo_end() -> void:
	var result: Dictionary = await Stage16AlphaDemoGrayboxDriver.drive_to_stage16_alpha_demo_end(self)

	assert_true(
		bool(result.get("success", false)),
		"Stage16 driver 失败：%s；最后房间：%s；策略：%s；HUD：%s" % [
			result.get("failure_reason", ""),
			result.get("last_room_path", ""),
			result.get("last_strategy_step", ""),
			result.get("last_progress_label", ""),
		]
	)
	assert_eq(result.get("last_room_path", ""), STAGE16_ALPHA_DEMO_END_ROOM_PATH)


# 保护文档门禁：manifest、QA checklist 和 release notes 必须包含 Stage16 Alpha Demo 关键条目。
func test_stage16_manifest_qa_checklist_and_release_notes_contain_required_entries() -> void:
	var manifest := _read_text_file(ASSET_MANIFEST_PATH)
	var qa_checklist := _read_text_file(QA_CHECKLIST_PATH)
	var release_notes := _read_text_file(RELEASE_NOTES_PATH)

	for term in [
		"stage16_seal_release_threshold",
		"stage16_talisman_relay",
		"stage16_backtrack_confirmation",
		"stage16_corruption_purge",
		"stage16_alpha_demo_completion",
		"stage16_minimal_bgm",
	]:
		assert_string_contains(manifest, term)

	for term in [
		"Main.tscn",
		"Stage16 五房链路",
		"暂停",
		"重开",
		"Godot MCP",
		"release notes",
	]:
		if not qa_checklist.is_empty():
			assert_string_contains(qa_checklist, term)

	for term in [
		"Alpha Demo",
		"Stage16",
		"20-28",
		"验证命令",
		"已知问题",
		"试玩入口",
	]:
		if not release_notes.is_empty():
			assert_string_contains(release_notes, term)


# Main fixture 固定加载生产入口，覆盖真实切房、玩家注入和 HUD 绑定。
func _spawn_main_scene() -> Node2D:
	var packed_scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	assert_not_null(packed_scene)

	var main_scene := packed_scene.instantiate() as Node2D
	add_child_autofree(main_scene)
	await _advance_process_frames(2)
	return main_scene


# 单房间 fixture 用于观察房间自己的 transition payload，不经过 Main 转译。
func _spawn_room(scene_path: String) -> Node2D:
	var packed_scene: PackedScene = load(scene_path) as PackedScene
	assert_not_null(packed_scene, "Missing room scene: %s" % scene_path)

	if packed_scene == null:
		return null

	var room := packed_scene.instantiate() as Node2D
	add_child_autofree(room)
	await get_tree().process_frame
	return room


# 玩家 fixture 提供最小地板，让出口触发和 HUD 绑定从稳定落地状态开始。
func _spawn_player_with_floor(spawn_position: Vector2) -> CharacterBody2D:
	var world := Node2D.new()
	add_child_autofree(world)

	var floor := StaticBody2D.new()
	floor.position = Vector2(0, 160)
	world.add_child(floor)

	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(1024, 32)
	floor_shape.shape = rectangle
	floor.add_child(floor_shape)

	var player_scene: PackedScene = load("res://scenes/player/player_placeholder.tscn") as PackedScene
	assert_not_null(player_scene)

	var player := player_scene.instantiate() as CharacterBody2D
	player.position = spawn_position
	world.add_child(player)
	await _advance_physics_frames(16)
	return player


# 物理帧推进用于玩家 fixture 落地。
func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame


# process 帧推进用于等待房间触发、HUD 更新和 Main 切房。
func _advance_process_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


# 释放输入前先确认动作存在，避免新机器或单测入口还未由 Main 创建默认输入时报引擎错误。
func _release_action_if_present(action_name: StringName) -> void:
	if InputMap.has_action(action_name):
		Input.action_release(action_name)


# 读取当前 Main 房间路径，用于重开和 driver 断言。
func _get_room_path(main_scene: Node2D) -> String:
	var room := main_scene.get_node_or_null("Room") as Node2D
	return room.scene_file_path if room != null else ""


# 读取文档文本；缺失文件时让测试以明确路径失败。
func _read_text_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "无法读取文件：%s" % path)
	return file.get_as_text() if file != null else ""
