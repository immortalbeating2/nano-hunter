extends SceneTree

# 捕获 P1/P2/P3 样板房运行态截图；只用于本地 QA 证据。

const OUT_DIR := "res://tests/artifacts/local/p1-p3-sample-polish-2026-06-30/current_tree"
const MAIN_SCENE := "res://scenes/main/main.tscn"

var _main: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(640, 360)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	_main = load(MAIN_SCENE).instantiate()
	root.add_child(_main)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	_save_viewport("00_main_menu")

	_main.get_node("HUD/DemoShell").call("start_demo")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	_save_viewport("01_tutorial_after_start")

	await _transition_and_capture("res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn", "02_stage13_entry")
	await _transition_and_capture("res://scenes/rooms/stage14_air_dash_gate_room.tscn", "03_stage14_air_dash_gate")
	await _transition_and_capture("res://scenes/rooms/stage15_seal_guardian_boss_room.tscn", "04_stage15_boss")
	await _transition_and_capture("res://scenes/rooms/stage16_alpha_demo_end_room.tscn", "05_stage16_end")
	await process_frame
	quit()


func _transition_and_capture(room_path: String, file_stem: String) -> void:
	_main.call("transition_to_room", room_path, &"")
	_main.get_node("HUD/DemoShell/MainMenu").visible = false
	_main.get_node("HUD/DemoShell/TitleBackground").visible = false
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	_save_viewport(file_stem)


func _save_viewport(file_stem: String) -> void:
	var image := root.get_texture().get_image()
	image.save_png("%s/%s.png" % [OUT_DIR, file_stem])
	var progress_label := _main.get_node("HUD/TutorialHUD/BattlePanel/ProgressLabel") as Label
	print("%s | %s" % [file_stem, progress_label.text.replace("\n", " / ")])
