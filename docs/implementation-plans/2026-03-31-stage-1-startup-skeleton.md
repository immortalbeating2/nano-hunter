# Stage 1 Startup Skeleton Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first playable checkpoint for `nano-hunter` by adding a loadable main scene, a placeholder player spawn, a simple test room, and the project startup configuration needed to enter the scene directly.

**Architecture:** Keep Stage 1 intentionally small and stable. Use one root startup scene (`Main.tscn`) that owns a runtime container and a fixed spawn marker, instantiate a dedicated placeholder player scene, and reference a separate test-room scene so Stage 2 can extend movement without rebuilding the bootstrap. Validation should combine GUT checks for scene wiring with headless Godot import plus one manual launch check.

**Tech Stack:** Godot 4.6, GDScript, `.tscn` text scenes, GUT, PowerShell validation commands

---

## File Structure

- Create: `scenes/main/main.tscn`
  - Root startup scene for Stage 1. Owns the runtime container, the room instance, and the player spawn marker.
- Create: `scripts/main/main.gd`
  - Spawns the placeholder player into the runtime container at startup.
- Create: `scenes/player/player_placeholder.tscn`
  - Temporary player scene used for Stage 1 visual and collision validation.
- Create: `scripts/player/player_placeholder.gd`
  - Minimal placeholder-player script with stable defaults and no movement logic yet.
- Create: `scenes/rooms/test_room.tscn`
  - First test room shell with visible background, floor, and side walls.
- Create: `tests/stage1/test_stage_1_startup_skeleton.gd`
  - GUT coverage for startup configuration, room wiring, and placeholder-player spawn.
- Modify: `project.godot`
  - Add `run/main_scene` pointing to `res://scenes/main/main.tscn`.
- Modify: `docs/progress/status.md`
  - Move the project from “Stage 1 planned” to “Stage 1 playable”.
- Modify: `docs/progress/timeline.md`
  - Record completion of the first playable checkpoint.
- Modify: `docs/progress/2026-03-31.md`
  - Record implementation, validation commands, and Stage 1 outcomes.

## Notes Before Execution

- Keep Stage 1 focused on the startup skeleton only. Do not add movement input, attacks, HUD, or ability systems in this plan.
- Use placeholder visuals only. Do not block Stage 1 on final art production.
- Keep the scene tree and scripts small so Stage 2 can layer movement logic onto the same bootstrap with minimal churn.
- Use the worktree branch already prepared for this feature work.

### Task 1: Bootstrap A Loadable Main Scene Entry

**Files:**
- Create: `scenes/main/main.tscn`
- Modify: `project.godot`
- Create: `tests/stage1/test_stage_1_startup_skeleton.gd`
- Test: `tests/stage1/test_stage_1_startup_skeleton.gd`

- [ ] **Step 1: Write the failing startup-entry test**

```gdscript
extends GutTest


func test_project_points_to_a_loadable_stage_1_main_scene() -> void:
    assert_eq(
        ProjectSettings.get_setting("application/run/main_scene", ""),
        "res://scenes/main/main.tscn"
    )

    var packed_scene := load("res://scenes/main/main.tscn") as PackedScene

    assert_not_null(packed_scene)
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
```

Expected:

- FAIL because `application/run/main_scene` is still unset
- FAIL because `res://scenes/main/main.tscn` does not exist yet

- [ ] **Step 3: Create the minimal startup scene and project setting**

`scenes/main/main.tscn`

```tscn
[gd_scene format=3]

[node name="Main" type="Node2D"]

[node name="Runtime" type="Node2D" parent="."]

[node name="PlayerSpawn" type="Marker2D" parent="."]
position = Vector2(-320, 96)
```

`project.godot`

```ini
[application]

config/name="nano-hunter"
config/features=PackedStringArray("4.6", "Forward Plus")
config/icon="res://icon.svg"
run/main_scene="res://scenes/main/main.tscn"
```

- [ ] **Step 4: Run the startup-entry test again**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
```

Expected:

- PASS for `test_project_points_to_a_loadable_stage_1_main_scene`

- [ ] **Step 5: Commit the bootstrap entry point**

```bash
git add project.godot scenes/main/main.tscn tests/stage1/test_stage_1_startup_skeleton.gd
git commit -m "配置阶段 1 启动入口 / Configure stage 1 startup entry"
```

### Task 2: Spawn A Placeholder Player With Camera And Collision

**Files:**
- Create: `scripts/main/main.gd`
- Create: `scenes/player/player_placeholder.tscn`
- Create: `scripts/player/player_placeholder.gd`
- Modify: `scenes/main/main.tscn`
- Modify: `tests/stage1/test_stage_1_startup_skeleton.gd`
- Test: `tests/stage1/test_stage_1_startup_skeleton.gd`

- [ ] **Step 1: Add the failing player-spawn tests**

Append to `tests/stage1/test_stage_1_startup_skeleton.gd`:

```gdscript
func test_main_scene_spawns_one_placeholder_player_at_the_spawn_marker() -> void:
    var packed_scene := load("res://scenes/main/main.tscn") as PackedScene
    var main := packed_scene.instantiate() as Node2D

    add_child_autofree(main)
    await get_tree().process_frame

    var runtime := main.get_node_or_null("Runtime") as Node2D
    var spawn_marker := main.get_node_or_null("PlayerSpawn") as Marker2D

    assert_not_null(runtime)
    assert_not_null(spawn_marker)
    assert_eq(runtime.get_child_count(), 1)

    var player := runtime.get_child(0) as CharacterBody2D

    assert_not_null(player)
    assert_eq(player.position, spawn_marker.position)


func test_placeholder_player_has_camera_and_collision_shell() -> void:
    var packed_scene := load("res://scenes/player/player_placeholder.tscn") as PackedScene
    var player := packed_scene.instantiate()

    add_child_autofree(player)

    assert_not_null(player.get_node_or_null("Camera2D"))
    assert_not_null(player.get_node_or_null("CollisionShape2D"))
    assert_not_null(player.get_node_or_null("Body"))
```

- [ ] **Step 2: Run the expanded test file to verify it fails**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
```

Expected:

- FAIL because `res://scenes/player/player_placeholder.tscn` does not exist
- FAIL because `Main.tscn` does not yet spawn anything into `Runtime`

- [ ] **Step 3: Implement the placeholder player scene and startup spawn script**

`scripts/player/player_placeholder.gd`

```gdscript
extends CharacterBody2D

@export var placeholder_label: String = "stage_1_player"


func _ready() -> void:
    velocity = Vector2.ZERO
```

`scenes/player/player_placeholder.tscn`

```tscn
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/player/player_placeholder.gd" id="1"]

[sub_resource type="RectangleShape2D" id="1"]
size = Vector2(24, 40)

[node name="PlayerPlaceholder" type="CharacterBody2D"]
script = ExtResource("1")

[node name="Body" type="Polygon2D" parent="."]
color = Color(0.321569, 0.843137, 0.937255, 1)
polygon = PackedVector2Array(-12, 20, 12, 20, 12, -20, -12, -20)

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("1")

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(0, -40)
enabled = true
```

`scripts/main/main.gd`

```gdscript
extends Node2D

const PLAYER_PLACEHOLDER_SCENE: PackedScene = preload("res://scenes/player/player_placeholder.tscn")

@onready var _runtime: Node2D = $Runtime
@onready var _player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
    _spawn_player_placeholder()


func _spawn_player_placeholder() -> void:
    if _runtime.get_child_count() > 0:
        return

    var player := PLAYER_PLACEHOLDER_SCENE.instantiate() as Node2D

    player.position = _player_spawn.position
    _runtime.add_child(player)
```

Replace `scenes/main/main.tscn` with:

```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/main/main.gd" id="1"]

[node name="Main" type="Node2D"]
script = ExtResource("1")

[node name="Runtime" type="Node2D" parent="."]

[node name="PlayerSpawn" type="Marker2D" parent="."]
position = Vector2(-320, 96)
```

- [ ] **Step 4: Run the player-spawn tests again**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
```

Expected:

- PASS for the startup-entry test
- PASS for the placeholder-player spawn test
- PASS for the placeholder-player camera and collision test

- [ ] **Step 5: Commit the placeholder player bootstrap**

```bash
git add scenes/main/main.tscn scenes/player/player_placeholder.tscn scripts/main/main.gd scripts/player/player_placeholder.gd tests/stage1/test_stage_1_startup_skeleton.gd
git commit -m "新增占位玩家与启动脚本 / Add placeholder player and startup script"
```

### Task 3: Add A Visible Test Room Shell

**Files:**
- Create: `scenes/rooms/test_room.tscn`
- Modify: `scenes/main/main.tscn`
- Modify: `tests/stage1/test_stage_1_startup_skeleton.gd`
- Test: `tests/stage1/test_stage_1_startup_skeleton.gd`

- [ ] **Step 1: Add the failing room-shell tests**

Append to `tests/stage1/test_stage_1_startup_skeleton.gd`:

```gdscript
func test_test_room_contains_floor_and_side_walls() -> void:
    var packed_scene := load("res://scenes/rooms/test_room.tscn") as PackedScene
    var room := packed_scene.instantiate()

    add_child_autofree(room)

    assert_not_null(room.get_node_or_null("Backdrop"))
    assert_not_null(room.get_node_or_null("Floor"))
    assert_not_null(room.get_node_or_null("LeftWall"))
    assert_not_null(room.get_node_or_null("RightWall"))


func test_main_scene_instances_the_test_room() -> void:
    var packed_scene := load("res://scenes/main/main.tscn") as PackedScene
    var main := packed_scene.instantiate()

    add_child_autofree(main)

    assert_not_null(main.get_node_or_null("TestRoom"))
```

- [ ] **Step 2: Run the test file to verify the room tests fail**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
```

Expected:

- FAIL because `res://scenes/rooms/test_room.tscn` does not exist
- FAIL because `Main.tscn` does not yet contain a `TestRoom` child

- [ ] **Step 3: Implement the test room shell and wire it into Main**

`scenes/rooms/test_room.tscn`

```tscn
[gd_scene load_steps=4 format=3]

[sub_resource type="RectangleShape2D" id="1"]
size = Vector2(1152, 64)

[sub_resource type="RectangleShape2D" id="2"]
size = Vector2(64, 640)

[node name="TestRoom" type="Node2D"]

[node name="Backdrop" type="Polygon2D" parent="."]
color = Color(0.0901961, 0.117647, 0.180392, 1)
polygon = PackedVector2Array(-640, -360, 640, -360, 640, 360, -640, 360)

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(0, 176)

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("1")

[node name="Visual" type="Polygon2D" parent="Floor"]
color = Color(0.223529, 0.247059, 0.309804, 1)
polygon = PackedVector2Array(-576, -32, 576, -32, 576, 32, -576, 32)

[node name="LeftWall" type="StaticBody2D" parent="."]
position = Vector2(-608, -80)

[node name="CollisionShape2D" type="CollisionShape2D" parent="LeftWall"]
shape = SubResource("2")

[node name="Visual" type="Polygon2D" parent="LeftWall"]
color = Color(0.172549, 0.192157, 0.25098, 1)
polygon = PackedVector2Array(-32, -320, 32, -320, 32, 320, -32, 320)

[node name="RightWall" type="StaticBody2D" parent="."]
position = Vector2(608, -80)

[node name="CollisionShape2D" type="CollisionShape2D" parent="RightWall"]
shape = SubResource("2")

[node name="Visual" type="Polygon2D" parent="RightWall"]
color = Color(0.172549, 0.192157, 0.25098, 1)
polygon = PackedVector2Array(-32, -320, 32, -320, 32, 320, -32, 320)
```

Replace `scenes/main/main.tscn` with:

```tscn
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/main/main.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/rooms/test_room.tscn" id="2"]

[node name="Main" type="Node2D"]
script = ExtResource("1")

[node name="TestRoom" parent="." instance=ExtResource("2")]

[node name="Runtime" type="Node2D" parent="."]

[node name="PlayerSpawn" type="Marker2D" parent="."]
position = Vector2(-320, 96)
```

- [ ] **Step 4: Run the full Stage 1 test file again**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
```

Expected:

- PASS for all startup skeleton tests

- [ ] **Step 5: Commit the test room shell**

```bash
git add scenes/main/main.tscn scenes/rooms/test_room.tscn tests/stage1/test_stage_1_startup_skeleton.gd
git commit -m "新增测试房间壳体 / Add startup test room shell"
```

### Task 4: Verify The Playable Checkpoint And Update Progress Docs

**Files:**
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-03-31.md`
- Test: `docs/progress/status.md`
- Test: `docs/progress/timeline.md`
- Test: `docs/progress/2026-03-31.md`

- [ ] **Step 1: Update the status snapshot to show Stage 1 is playable**

Replace the stage summary in `docs/progress/status.md` with:

```markdown
## Current Stage

`阶段 1：可启动骨架（已完成，可试玩）`

## Stage Goal

保持阶段 1 的启动骨架可试玩，并收集主场景比例、测试房间尺寸和基础视觉可读性的反馈，为阶段 2 做准备。

## Playable Now

- `godot --path .` 可直接进入 `Main.tscn`
- 可在测试房间中看到占位玩家、基础相机与碰撞壳体
- 可以验证主场景入口、玩家出生点和房间尺度是否合适

## Adjustable Now

- 玩家出生位置
- 相机基础位置与房间显示比例
- 测试房间尺寸、地面高度与边界宽度
- 占位资产、免费替代资产和 AI 临时视觉样本的取舍

## Exit Criteria

- `run/main_scene` 已配置且可启动
- `Main.tscn`、测试房间、玩家出生点、相机和基础碰撞已全部落地
- 已经形成第一个可启动、可看、可调的试玩检查点

## Asset Status

- 当前以占位资产与简单几何可视化为主
- 允许在阶段 2 前继续补充免费替代资产和少量 AI 临时视觉探索

## Next Stage

`阶段 2：基础移动手感`
```

- [ ] **Step 2: Record the checkpoint in timeline and daily log**

Append to `docs/progress/timeline.md`:

```markdown
- 完成 `阶段 1：可启动骨架`，新增 `Main.tscn`、`test_room.tscn`、`player_placeholder.tscn` 与项目启动入口，形成第一个可启动、可看、可调的试玩检查点。
```

Append under `## Work Completed` in `docs/progress/2026-03-31.md`:

```markdown
- 为 `阶段 1：可启动骨架` 编写并执行实现计划，新增启动主场景、测试房间、占位玩家和项目运行入口。
```

Append under `## Validation Already Observed` in `docs/progress/2026-03-31.md`:

```markdown
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . --import`
- `godot --path .`
```

Replace `## Next Step` in `docs/progress/2026-03-31.md` with:

```markdown
## Next Step

试玩 `阶段 1：可启动骨架`，收集主场景比例、测试房间尺度与占位可读性的反馈，再为 `阶段 2：基础移动手感` 编写实现计划。
```

- [ ] **Step 3: Run the final validation commands**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit
godot --headless --path . --import
```

Then launch manually:

```powershell
godot --path .
```

Expected:

- GUT reports all Stage 1 tests passing
- `godot --headless --path . --import` completes without project-side parse errors
- A game window opens directly into the startup scene with the placeholder player visible in the test room

- [ ] **Step 4: Commit the playable checkpoint and doc updates**

```bash
git add docs/progress/status.md docs/progress/timeline.md docs/progress/2026-03-31.md scenes/main/main.tscn scenes/rooms/test_room.tscn scenes/player/player_placeholder.tscn scripts/main/main.gd scripts/player/player_placeholder.gd tests/stage1/test_stage_1_startup_skeleton.gd project.godot
git commit -m "完成阶段 1 可启动骨架 / Complete stage 1 startup skeleton"
```

## Self-Review

- Spec coverage: The plan covers Stage 1 startup configuration, placeholder player spawn, test-room shell, current-stage documentation, and validation expectations. It intentionally excludes movement, attack, HUD, and ability work so Stage 1 stays within the approved checkpoint scope.
- Placeholder scan: No `TODO`, `TBD`, or “implement later” placeholders remain. Every code-changing step includes concrete file contents or exact appended snippets.
- Type consistency: `Main.tscn`, `main.gd`, and the GUT tests all use the same node names: `Main`, `TestRoom`, `Runtime`, `PlayerSpawn`, and `PlayerPlaceholder`.
