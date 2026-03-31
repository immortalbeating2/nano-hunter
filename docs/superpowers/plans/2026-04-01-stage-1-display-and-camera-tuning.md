# Stage 1 Display And Camera Tuning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tune the current Stage 1 prototype so it uses a fixed 640x360 base viewport, integer scaling with keep-aspect letterboxing, and room-bounded camera framing that no longer reveals the gray area outside the test room.

**Architecture:** Keep the change small and Stage-1-scoped. Put stable display defaults in `project.godot`, expose room camera bounds through a tiny room-local script, and let `main.gd` apply those bounds to the placeholder player's camera without introducing a general room-management system.

**Tech Stack:** Godot 4.6, GDScript, `.tscn` text scenes, `project.godot`, GUT

---

## File Structure

- Modify: `project.godot`
  - Add the Stage 1 display defaults: base viewport, stretch mode, aspect policy, integer scaling, and non-gray clear color.
- Modify: `scripts/main/main.gd`
  - Apply the room's camera limits to the placeholder player's `Camera2D` and set the minimum runtime window size to the base viewport.
- Create: `scripts/rooms/test_room.gd`
  - Expose a small room-local `Rect2i` camera-bounds contract for Stage 1 only.
- Modify: `scenes/rooms/test_room.tscn`
  - Attach the room script while keeping the room shell itself simple.
- Modify: `tests/stage1/test_stage_1_startup_skeleton.gd`
  - Extend Stage 1 coverage to include display settings, runtime minimum window size, room camera bounds, and camera-limit application.
- Modify: `docs/progress/status.md`
  - Reflect that Stage 1 display/camera tuning is complete and explain what is now visible/playable/tunable.
- Modify: `docs/progress/timeline.md`
  - Record the display/camera tuning design, implementation, validation, and the remaining follow-up note for Stage 2.
- Create: `docs/progress/2026-04-01.md`
  - Record the design decisions, validation outputs, and the remaining feedback still needed from the user after the tuning is playable.

## Notes Before Execution

- Keep this as a Stage 1 tuning pass. Do not add movement, attacks, camera smoothing, room transitions, TileMap content, or a general room manager.
- `PlayerSpawn` and `TestRoom` remain siblings in `Main.tscn` for now. Do not restructure their ownership during this pass.
- The goal is stable framing and scaling, not final art polish.
- Use the existing Stage 1 GUT file so one command still validates the whole Stage 1 skeleton.

### Task 1: Configure Stage 1 Display Defaults

**Files:**
- Modify: `project.godot`
- Modify: `scripts/main/main.gd`
- Modify: `tests/stage1/test_stage_1_startup_skeleton.gd`
- Test: `tests/stage1/test_stage_1_startup_skeleton.gd`

- [ ] **Step 1: Add the failing display-default tests**

Append to `tests/stage1/test_stage_1_startup_skeleton.gd`:

```gdscript
func test_project_uses_stage_1_display_scaling_defaults() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width", 0), 640)
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_height", 0), 360)
	assert_eq(ProjectSettings.get_setting("display/window/size/window_width_override", 0), 1280)
	assert_eq(ProjectSettings.get_setting("display/window/size/window_height_override", 0), 720)
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode", ""), "viewport")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/aspect", ""), "keep")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/scale_mode", ""), "integer")
	assert_eq(
		ProjectSettings.get_setting(
			"rendering/environment/defaults/default_clear_color",
			Color(0.3, 0.3, 0.3, 1)
		),
		Color(0.0745098, 0.129412, 0.219608, 1)
	)


func test_main_scene_sets_window_minimum_size_to_base_viewport() -> void:
	var previous_min_size: Vector2i = get_window().min_size
	var packed_scene: PackedScene = load("res://scenes/main/main.tscn") as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node = packed_scene.instantiate()
	add_child_autofree(main_scene)
	await get_tree().process_frame

	assert_eq(get_window().min_size, Vector2i(640, 360))

	get_window().min_size = previous_min_size
```

- [ ] **Step 2: Run the Stage 1 test file to confirm the new tests fail**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
```

Expected:

- FAIL because the project still uses Godot's default window and stretch settings
- FAIL because `main.gd` does not yet set `get_window().min_size`

- [ ] **Step 3: Implement the display defaults**

Update `project.godot` to include these sections and values:

```ini
[application]

config/name="nano-hunter"
run/main_scene="res://scenes/main/main.tscn"
config/features=PackedStringArray("4.6", "Forward Plus")
config/icon="res://icon.svg"

[display]

window/size/viewport_width=640
window/size/viewport_height=360
window/size/window_width_override=1280
window/size/window_height_override=720
window/stretch/mode="viewport"
window/stretch/aspect="keep"
window/stretch/scale_mode="integer"
```

Update `scripts/main/main.gd` to:

```gdscript
extends Node2D

const BASE_VIEWPORT_SIZE := Vector2i(640, 360)
const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")

@onready var runtime: Node2D = $Runtime
@onready var player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
	_configure_window_defaults()
	_spawn_placeholder_player()


func _configure_window_defaults() -> void:
	get_window().min_size = BASE_VIEWPORT_SIZE


func _spawn_placeholder_player() -> void:
	if runtime.get_child_count() > 0:
		return

	var player: CharacterBody2D = PLAYER_PLACEHOLDER_SCENE.instantiate() as CharacterBody2D

	if player == null:
		return

	player.position = player_spawn.position
	runtime.add_child(player)
```

Append this rendering setting under `[rendering]` in `project.godot`:

```ini
rendering/environment/defaults/default_clear_color=Color(0.0745098, 0.129412, 0.219608, 1)
```

- [ ] **Step 4: Run the Stage 1 test file again**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
```

Expected:

- PASS, with the full file now reporting `7/7 passed`

- [ ] **Step 5: Commit the display-default configuration**

```bash
git add project.godot scripts/main/main.gd tests/stage1/test_stage_1_startup_skeleton.gd
git commit -m "配置阶段 1 显示缩放策略 / Configure stage 1 display scaling"
```

### Task 2: Add Room Camera Bounds And Apply Them To The Placeholder Camera

**Files:**
- Create: `scripts/rooms/test_room.gd`
- Modify: `scenes/rooms/test_room.tscn`
- Modify: `scripts/main/main.gd`
- Modify: `tests/stage1/test_stage_1_startup_skeleton.gd`
- Test: `tests/stage1/test_stage_1_startup_skeleton.gd`

- [ ] **Step 1: Add the failing camera-bounds tests**

Append to `tests/stage1/test_stage_1_startup_skeleton.gd`:

```gdscript
func test_test_room_exposes_stage_1_camera_limits() -> void:
	var packed_scene: PackedScene = load("res://scenes/rooms/test_room.tscn") as PackedScene

	assert_not_null(packed_scene)

	var test_room: Node = packed_scene.instantiate()
	add_child_autofree(test_room)

	assert_true(test_room.has_method("get_camera_limits"))

	var camera_limits: Rect2i = test_room.call("get_camera_limits")

	assert_eq(camera_limits, Rect2i(-512, -192, 1024, 384))


func test_main_scene_applies_test_room_camera_limits_to_placeholder_camera() -> void:
	var packed_scene: PackedScene = load("res://scenes/main/main.tscn") as PackedScene

	assert_not_null(packed_scene)

	var main_scene: Node = packed_scene.instantiate()
	add_child_autofree(main_scene)
	await get_tree().process_frame

	var runtime: Node2D = main_scene.get_node_or_null("Runtime") as Node2D

	assert_not_null(runtime)
	assert_eq(runtime.get_child_count(), 1)

	var player: CharacterBody2D = runtime.get_child(0) as CharacterBody2D

	assert_not_null(player)

	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D

	assert_not_null(camera)
	assert_true(camera.limit_enabled)
	assert_eq(camera.limit_left, -512)
	assert_eq(camera.limit_top, -192)
	assert_eq(camera.limit_right, 512)
	assert_eq(camera.limit_bottom, 192)
```

- [ ] **Step 2: Run the Stage 1 test file to confirm the new tests fail**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
```

Expected:

- FAIL because `test_room.tscn` has no room-local camera-bounds contract yet
- FAIL because `main.gd` does not yet push room limits into the placeholder player's `Camera2D`

- [ ] **Step 3: Implement the room bounds contract and camera limit application**

Create `scripts/rooms/test_room.gd`:

```gdscript
extends Node2D

const CAMERA_LIMITS := Rect2i(-512, -192, 1024, 384)


func get_camera_limits() -> Rect2i:
	return CAMERA_LIMITS
```

Replace the start of `scenes/rooms/test_room.tscn` with:

```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/rooms/test_room.gd" id="1"]

[sub_resource type="RectangleShape2D" id="1"]
size = Vector2(1024, 32)

[sub_resource type="RectangleShape2D" id="2"]
size = Vector2(32, 384)

[node name="TestRoom" type="Node2D"]
script = ExtResource("1")
```

Replace `scripts/main/main.gd` with:

```gdscript
extends Node2D

const BASE_VIEWPORT_SIZE := Vector2i(640, 360)
const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")

@onready var test_room: Node2D = $TestRoom
@onready var runtime: Node2D = $Runtime
@onready var player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
	_configure_window_defaults()
	_spawn_placeholder_player()


func _configure_window_defaults() -> void:
	get_window().min_size = BASE_VIEWPORT_SIZE


func _spawn_placeholder_player() -> void:
	if runtime.get_child_count() > 0:
		return

	var player: CharacterBody2D = PLAYER_PLACEHOLDER_SCENE.instantiate() as CharacterBody2D

	if player == null:
		return

	player.position = player_spawn.position
	_apply_test_room_camera_limits(player)
	runtime.add_child(player)


func _apply_test_room_camera_limits(player: CharacterBody2D) -> void:
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D

	if camera == null:
		return

	if test_room == null or not test_room.has_method("get_camera_limits"):
		return

	var camera_limits: Rect2i = test_room.call("get_camera_limits")

	camera.limit_enabled = true
	camera.limit_left = camera_limits.position.x
	camera.limit_top = camera_limits.position.y
	camera.limit_right = camera_limits.end.x
	camera.limit_bottom = camera_limits.end.y
```

- [ ] **Step 4: Run the Stage 1 test file again**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
```

Expected:

- PASS, with the full file now reporting `9/9 passed`

- [ ] **Step 5: Commit the room-bounds tuning**

```bash
git add scripts/rooms/test_room.gd scenes/rooms/test_room.tscn scripts/main/main.gd tests/stage1/test_stage_1_startup_skeleton.gd
git commit -m "新增测试房间相机边界 / Add test room camera bounds"
```

### Task 3: Verify The Tuned Stage 1 Checkpoint And Update Progress Docs

**Files:**
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Create: `docs/progress/2026-04-01.md`
- Test: `docs/progress/status.md`
- Test: `docs/progress/timeline.md`
- Test: `docs/progress/2026-04-01.md`

- [ ] **Step 1: Update the status snapshot**

Update `docs/progress/status.md` with these changes:

```markdown
Last Updated: 2026-04-01
```

Replace `## Playable Now` with:

```markdown
## Playable Now

- `godot --path .` 可直接进入 `Main.tscn`
- 当前基准分辨率为 `640x360`，初始窗口为 `1280x720`
- 当前窗口放大时会按整数倍等比缩放，非 `16:9` 时显示留边
- 当前测试房间已经约束相机边界，试玩时不再露出默认灰色空区
```

Replace `## Adjustable Now` with:

```markdown
## Adjustable Now

- 测试房间尺寸、地面高度与边界宽度
- 玩家出生位置与当前构图的关系
- 相机边界、房间留白和玩家占画面比例
- 阶段 2 前是否要调整 `PlayerSpawn` 与 `TestRoom` 的场景归属
```

Append under `## Recently Completed`:

```markdown
- 编写并提交 `spec-design/2026-04-01-stage-1-display-and-camera-tuning-design.md`
- 编写并执行 `docs/superpowers/plans/2026-04-01-stage-1-display-and-camera-tuning.md`
- 为阶段 1 配置 `640x360` 基准分辨率、`viewport/keep/integer` 缩放策略与更稳定的清屏背景
- 为测试房间补充相机边界，并让占位玩家的 `Camera2D` 受房间边界限制
```

Replace `## Next Recommended Steps` with:

```markdown
## Next Recommended Steps

1. 试玩当前画面与相机构图，记录房间尺寸、玩家占比与边界构图反馈
2. 为 `阶段 2：基础移动手感` 编写实现计划
3. 在阶段 2 中加入最小移动、跳跃与落地反馈
```
```

- [ ] **Step 2: Update timeline and add the new daily log**

Append to `docs/progress/timeline.md`:

```markdown
## 2026-04-01

- 编写并提交阶段 1 画面与相机调优设计 `spec-design/2026-04-01-stage-1-display-and-camera-tuning-design.md`，提交 `3a5f4da`。
- 编写并执行 `阶段 1` 画面与相机调优计划 `docs/superpowers/plans/2026-04-01-stage-1-display-and-camera-tuning.md`。
- 为项目配置 `640x360` 基准分辨率、`viewport/keep/integer` 缩放策略与更稳定的清屏背景。
- 为测试房间补充相机边界，并将边界应用到占位玩家的 `Camera2D`。
- 当前 worktree 试玩窗口已具备固定构图、留边策略与房间边界限制；阶段 2 仍需继续收集房间尺寸、玩家占比与出生点反馈。
```

Create `docs/progress/2026-04-01.md` with:

```markdown
# Nano Hunter Development Log - 2026-04-01

## Background

今天的目标是对 `阶段 1：可启动骨架` 做一次小型画面与相机调优，让当前试玩版本具备固定基准分辨率、整数倍缩放和房间边界限制，再把这些变化记录进进度文档，为阶段 2 的移动手感开发做准备。

## Work Completed

- 根据试玩反馈，确认当前主要问题是默认灰色空区、窗口放大后构图不稳定以及缺少房间边界相机限制。
- 编写并提交 `spec-design/2026-04-01-stage-1-display-and-camera-tuning-design.md`，明确本次只做阶段 1 试玩优化，不扩展到正式关卡系统。
- 编写并执行 `docs/superpowers/plans/2026-04-01-stage-1-display-and-camera-tuning.md`。
- 为项目配置 `640x360` 基准分辨率、`viewport` 拉伸模式、`keep` 比例策略与 `integer` 缩放策略。
- 将初始窗口调整为 `1280x720`，并在运行时将最小窗口尺寸限制为 `640x360`。
- 为测试房间补充 `Rect2i` 相机边界契约，并把边界应用到占位玩家的 `Camera2D`。
- 保留 `PlayerSpawn` 与 `TestRoom` 的当前兄弟节点结构，把归属讨论明确延后到阶段 2。

## Validation Already Observed

- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
  结果：当前 `9/9 passed`，阶段 1 的启动入口、占位玩家、测试房间、显示设置与房间边界测试全部为绿色
- `godot --headless --path . --import`
  结果：导入通过；退出时仍有 `ObjectDB instances leaked at exit` 警告
- `godot --path .`
  结果：当前试玩窗口可直接启动，窗口放大时整体按比例缩放，测试房间边界不再露出默认灰色空区

## Open Items

- `ObjectDB instances leaked at exit` 仍需后续单独追踪
- 当前调优还没有新的用户试玩反馈结论，后续仍需记录房间尺寸、玩家占比、出生点与相机观感
- `PlayerSpawn` 与 `TestRoom` 的归属关系保留为阶段 2 注意项

## Next Step

试玩当前画面与相机构图，收集房间尺寸、玩家占比、出生点与边界构图反馈，然后为 `阶段 2：基础移动手感` 编写实现计划。
```

- [ ] **Step 3: Run the final verification commands**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
godot --headless --path . --import
godot --path .
```

Expected:

- GUT reports `9/9 passed`
- `--import` completes without project-side parse errors
- The launched game window shows a 640x360-framed Stage 1 scene that scales up cleanly, uses black bars for non-16:9 windows, and no longer reveals the old gray outside area while staying within room bounds

- [ ] **Step 4: Commit the tuned Stage 1 checkpoint**

```bash
git add project.godot scripts/main/main.gd scripts/rooms/test_room.gd scenes/rooms/test_room.tscn tests/stage1/test_stage_1_startup_skeleton.gd docs/progress/status.md docs/progress/timeline.md docs/progress/2026-04-01.md
git commit -m "完成阶段 1 画面与相机调优 / Complete stage 1 display and camera tuning"
```

## Self-Review

- Spec coverage: The plan implements the approved design's four required outcomes: `640x360` base viewport, keep-aspect scaling, integer scaling, and room-bounded player camera framing. It also keeps `PlayerSpawn`/`TestRoom` ownership unchanged per the design's out-of-scope rule.
- Placeholder scan: No `TODO`, `TBD`, or “implement later” placeholders remain. Every task contains concrete code or exact markdown content.
- Type consistency: The plan consistently uses `Rect2i` for room camera bounds, `Camera2D.limit_*` for camera limits, and the existing Stage 1 test file for verification.
