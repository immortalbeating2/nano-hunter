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
git commit -m "閰嶇疆闃舵 1 鏄剧ず缂╂斁绛栫暐 / Configure stage 1 display scaling"
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
git commit -m "鏂板娴嬭瘯鎴块棿鐩告満杈圭晫 / Add test room camera bounds"
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

- `godot --path .` 鍙洿鎺ヨ繘鍏?`Main.tscn`
- 褰撳墠鍩哄噯鍒嗚鲸鐜囦负 `640x360`锛屽垵濮嬬獥鍙ｄ负 `1280x720`
- 褰撳墠绐楀彛鏀惧ぇ鏃朵細鎸夋暣鏁板€嶇瓑姣旂缉鏀撅紝闈?`16:9` 鏃舵樉绀虹暀杈?- 褰撳墠娴嬭瘯鎴块棿宸茬粡绾︽潫鐩告満杈圭晫锛岃瘯鐜╂椂涓嶅啀闇插嚭榛樿鐏拌壊绌哄尯
```

Replace `## Adjustable Now` with:

```markdown
## Adjustable Now

- 娴嬭瘯鎴块棿灏哄銆佸湴闈㈤珮搴︿笌杈圭晫瀹藉害
- 鐜╁鍑虹敓浣嶇疆涓庡綋鍓嶆瀯鍥剧殑鍏崇郴
- 鐩告満杈圭晫銆佹埧闂寸暀鐧藉拰鐜╁鍗犵敾闈㈡瘮渚?- 闃舵 2 鍓嶆槸鍚﹁璋冩暣 `PlayerSpawn` 涓?`TestRoom` 鐨勫満鏅綊灞?```

Append under `## Recently Completed`:

```markdown
- 缂栧啓骞舵彁浜?`spec-design/2026-04-01-stage-1-display-and-camera-tuning-design.md`
- 缂栧啓骞舵墽琛?`docs/implementation-plans/2026-04-01-stage-1-display-and-camera-tuning.md`
- 涓洪樁娈?1 閰嶇疆 `640x360` 鍩哄噯鍒嗚鲸鐜囥€乣viewport/keep/integer` 缂╂斁绛栫暐涓庢洿绋冲畾鐨勬竻灞忚儗鏅?- 涓烘祴璇曟埧闂磋ˉ鍏呯浉鏈鸿竟鐣岋紝骞惰鍗犱綅鐜╁鐨?`Camera2D` 鍙楁埧闂磋竟鐣岄檺鍒?```

Replace `## Next Recommended Steps` with:

```markdown
## Next Recommended Steps

1. 璇曠帺褰撳墠鐢婚潰涓庣浉鏈烘瀯鍥撅紝璁板綍鎴块棿灏哄銆佺帺瀹跺崰姣斾笌杈圭晫鏋勫浘鍙嶉
2. 涓?`闃舵 2锛氬熀纭€绉诲姩鎵嬫劅` 缂栧啓瀹炵幇璁″垝
3. 鍦ㄩ樁娈?2 涓姞鍏ユ渶灏忕Щ鍔ㄣ€佽烦璺冧笌钀藉湴鍙嶉
```
```

- [ ] **Step 2: Update timeline and add the new daily log**

Append to `docs/progress/timeline.md`:

```markdown
## 2026-04-01

- 缂栧啓骞舵彁浜ら樁娈?1 鐢婚潰涓庣浉鏈鸿皟浼樿璁?`spec-design/2026-04-01-stage-1-display-and-camera-tuning-design.md`锛屾彁浜?`3a5f4da`銆?- 缂栧啓骞舵墽琛?`闃舵 1` 鐢婚潰涓庣浉鏈鸿皟浼樿鍒?`docs/implementation-plans/2026-04-01-stage-1-display-and-camera-tuning.md`銆?- 涓洪」鐩厤缃?`640x360` 鍩哄噯鍒嗚鲸鐜囥€乣viewport/keep/integer` 缂╂斁绛栫暐涓庢洿绋冲畾鐨勬竻灞忚儗鏅€?- 涓烘祴璇曟埧闂磋ˉ鍏呯浉鏈鸿竟鐣岋紝骞跺皢杈圭晫搴旂敤鍒板崰浣嶇帺瀹剁殑 `Camera2D`銆?- 褰撳墠 worktree 璇曠帺绐楀彛宸插叿澶囧浐瀹氭瀯鍥俱€佺暀杈圭瓥鐣ヤ笌鎴块棿杈圭晫闄愬埗锛涢樁娈?2 浠嶉渶缁х画鏀堕泦鎴块棿灏哄銆佺帺瀹跺崰姣斾笌鍑虹敓鐐瑰弽棣堛€?```

Create `docs/progress/2026-04-01.md` with:

```markdown
# Nano Hunter Development Log - 2026-04-01

## Background

浠婂ぉ鐨勭洰鏍囨槸瀵?`闃舵 1锛氬彲鍚姩楠ㄦ灦` 鍋氫竴娆″皬鍨嬬敾闈笌鐩告満璋冧紭锛岃褰撳墠璇曠帺鐗堟湰鍏峰鍥哄畾鍩哄噯鍒嗚鲸鐜囥€佹暣鏁板€嶇缉鏀惧拰鎴块棿杈圭晫闄愬埗锛屽啀鎶婅繖浜涘彉鍖栬褰曡繘杩涘害鏂囨。锛屼负闃舵 2 鐨勭Щ鍔ㄦ墜鎰熷紑鍙戝仛鍑嗗銆?
## Work Completed

- 鏍规嵁璇曠帺鍙嶉锛岀‘璁ゅ綋鍓嶄富瑕侀棶棰樻槸榛樿鐏拌壊绌哄尯銆佺獥鍙ｆ斁澶у悗鏋勫浘涓嶇ǔ瀹氫互鍙婄己灏戞埧闂磋竟鐣岀浉鏈洪檺鍒躲€?- 缂栧啓骞舵彁浜?`spec-design/2026-04-01-stage-1-display-and-camera-tuning-design.md`锛屾槑纭湰娆″彧鍋氶樁娈?1 璇曠帺浼樺寲锛屼笉鎵╁睍鍒版寮忓叧鍗＄郴缁熴€?- 缂栧啓骞舵墽琛?`docs/implementation-plans/2026-04-01-stage-1-display-and-camera-tuning.md`銆?- 涓洪」鐩厤缃?`640x360` 鍩哄噯鍒嗚鲸鐜囥€乣viewport` 鎷変几妯″紡銆乣keep` 姣斾緥绛栫暐涓?`integer` 缂╂斁绛栫暐銆?- 灏嗗垵濮嬬獥鍙ｈ皟鏁翠负 `1280x720`锛屽苟鍦ㄨ繍琛屾椂灏嗘渶灏忕獥鍙ｅ昂瀵搁檺鍒朵负 `640x360`銆?- 涓烘祴璇曟埧闂磋ˉ鍏?`Rect2i` 鐩告満杈圭晫濂戠害锛屽苟鎶婅竟鐣屽簲鐢ㄥ埌鍗犱綅鐜╁鐨?`Camera2D`銆?- 淇濈暀 `PlayerSpawn` 涓?`TestRoom` 鐨勫綋鍓嶅厔寮熻妭鐐圭粨鏋勶紝鎶婂綊灞炶璁烘槑纭欢鍚庡埌闃舵 2銆?
## Validation Already Observed

- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
  缁撴灉锛氬綋鍓?`9/9 passed`锛岄樁娈?1 鐨勫惎鍔ㄥ叆鍙ｃ€佸崰浣嶇帺瀹躲€佹祴璇曟埧闂淬€佹樉绀鸿缃笌鎴块棿杈圭晫娴嬭瘯鍏ㄩ儴涓虹豢鑹?- `godot --headless --path . --import`
  缁撴灉锛氬鍏ラ€氳繃锛涢€€鍑烘椂浠嶆湁 `ObjectDB instances leaked at exit` 璀﹀憡
- `godot --path .`
  缁撴灉锛氬綋鍓嶈瘯鐜╃獥鍙ｅ彲鐩存帴鍚姩锛岀獥鍙ｆ斁澶ф椂鏁翠綋鎸夋瘮渚嬬缉鏀撅紝娴嬭瘯鎴块棿杈圭晫涓嶅啀闇插嚭榛樿鐏拌壊绌哄尯

## Open Items

- `ObjectDB instances leaked at exit` 浠嶉渶鍚庣画鍗曠嫭杩借釜
- 褰撳墠璋冧紭杩樻病鏈夋柊鐨勭敤鎴疯瘯鐜╁弽棣堢粨璁猴紝鍚庣画浠嶉渶璁板綍鎴块棿灏哄銆佺帺瀹跺崰姣斻€佸嚭鐢熺偣涓庣浉鏈鸿鎰?- `PlayerSpawn` 涓?`TestRoom` 鐨勫綊灞炲叧绯讳繚鐣欎负闃舵 2 娉ㄦ剰椤?
## Next Step

璇曠帺褰撳墠鐢婚潰涓庣浉鏈烘瀯鍥撅紝鏀堕泦鎴块棿灏哄銆佺帺瀹跺崰姣斻€佸嚭鐢熺偣涓庤竟鐣屾瀯鍥惧弽棣堬紝鐒跺悗涓?`闃舵 2锛氬熀纭€绉诲姩鎵嬫劅` 缂栧啓瀹炵幇璁″垝銆?```

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
git commit -m "瀹屾垚闃舵 1 鐢婚潰涓庣浉鏈鸿皟浼?/ Complete stage 1 display and camera tuning"
```

## Self-Review

- Spec coverage: The plan implements the approved design's four required outcomes: `640x360` base viewport, keep-aspect scaling, integer scaling, and room-bounded player camera framing. It also keeps `PlayerSpawn`/`TestRoom` ownership unchanged per the design's out-of-scope rule.
- Placeholder scan: No `TODO`, `TBD`, or 鈥渋mplement later鈥?placeholders remain. Every task contains concrete code or exact markdown content.
- Type consistency: The plan consistently uses `Rect2i` for room camera bounds, `Camera2D.limit_*` for camera limits, and the existing Stage 1 test file for verification.

