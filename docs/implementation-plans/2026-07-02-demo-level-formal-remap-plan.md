# Alpha Demo Formal Level Remap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将当前 Alpha Demo 关卡修正为正式 Demo 级横版类银河恶魔城区域：普通房间双向通行、出入口安全、强视觉元素不误导、关键房间尺度和背景延展合理，并用 Godot MCP Pro 完成阶段六运行态复核。

**Architecture:** 不新增大型地图系统。复用现有 `room_transition_requested(target_room_path, spawn_id)`、`get_spawn_position()`、`get_camera_limits()` 和房间导出字段模式，在共享房间基类补反向出口契约，独立早期房间按同一契约补最小逻辑。图形资产优先复用现有 shrine / miasma / seal / terrain kit；现有资源无法满足读值时才用 image_gen 生成正式门、台阶、出口和 parallax 层。

**Tech Stack:** Godot 4.6.x, GDScript, GUT, Godot MCP Pro, existing image_gen workflow, existing `scripts/dev/*` QA scripts.

---

## File Structure

- Modify: `scripts/rooms/stage9_room_base.gd`
  - Add `previous_room_path` / `previous_spawn_id` exports and `LeftExitZone` handling for Stage9+ shared room flow.
- Modify: `scripts/rooms/combat_trial_room.gd`
  - Add previous-room return to tutorial.
- Modify: `scripts/rooms/goal_trial_room.gd`
  - Add previous-room return to combat trial.
- Modify: selected `scenes/rooms/*.tscn`
  - Add `LeftExitZone`, reverse spawn IDs, safe landing floors, proper exit markers, and asset replacements.
- Create: `tests/demo/test_alpha_demo_formal_level_remap.gd`
  - Protect bidirectional links, safe exits, misleading color blocks, and background coverage contracts.
- Create or modify as needed: `scripts/dev/capture_demo_formal_remap_review.gd`
  - Produce Phase 6 review report if existing DAC/full-flow reports do not expose bidirectional return screenshots.
- Modify if image_gen is used: `docs/assets/asset-manifest.md`
  - Add generated formal gate / ledge / parallax asset records.
- Modify: `docs/progress/status.md`, `docs/progress/timeline.md`, `docs/progress/logs/YYYY-MM-DD.md`
  - Record plan execution, validation, risks, and commit hashes.

## Phase 0: Preflight and Branch

**Files:**
- Read: `AGENTS.md`
- Read: `docs/progress/status.md`
- Read: `docs/implementation-plans/2026-06-30-demo-art-composition-asset-configuration-plan.md`
- Read: `docs/assets/environment-art-kit-spec.md`

- [ ] **Step 1: Confirm worktree and dirty state**

Run:

```powershell
git status --short --branch
git rev-parse --show-toplevel
```

Expected:

```text
## codex/art-asset-remaining-plan
C:/Users/peng8/.codex/worktrees/d7ef/nano-hunter
```

If the branch differs, record the actual branch in `docs/progress/logs/YYYY-MM-DD.md` before editing.

- [ ] **Step 2: Create or switch to a stage branch if execution has not already isolated one**

Run:

```powershell
git branch --show-current
```

If the current branch is not a dedicated remap branch, create one:

```powershell
git switch -c codex/demo-level-formal-remap
```

Expected: branch is `codex/demo-level-formal-remap`.

- [ ] **Step 3: Baseline import before touching scenes**

Run:

```powershell
godot --headless --path . --import
```

Expected: command exits `0`. Any import error must be fixed or recorded before scene edits.

## Phase 1: Topology Contract Tests First

**Files:**
- Create: `tests/demo/test_alpha_demo_formal_level_remap.gd`
- Test command: `godot --headless --path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_alpha_demo_formal_level_remap.gd -gexit`

- [ ] **Step 1: Create failing topology and readability tests**

Create `tests/demo/test_alpha_demo_formal_level_remap.gd`:

```gdscript
extends GutTest

# 正式 Demo remap 契约测试：保护普通房间双向连接、出入口安全和强视觉读值。

const ORDINARY_BIDIRECTIONAL_LINKS := [
	{
		"from": "res://scenes/rooms/combat_trial_room.tscn",
		"from_previous": "res://scenes/rooms/tutorial_room.tscn",
		"from_previous_spawn": &"tutorial_return",
		"left_exit": "LeftExitZone",
	},
	{
		"from": "res://scenes/rooms/goal_trial_room.tscn",
		"from_previous": "res://scenes/rooms/combat_trial_room.tscn",
		"from_previous_spawn": &"combat_return",
		"left_exit": "LeftExitZone",
	},
	{
		"from": "res://scenes/rooms/stage9_zone_entry_room.tscn",
		"from_previous": "res://scenes/rooms/goal_trial_room.tscn",
		"from_previous_spawn": &"goal_return",
		"left_exit": "LeftExitZone",
	},
	{
		"from": "res://scenes/rooms/stage13_miasma_marsh_caster_room.tscn",
		"from_previous": "res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn",
		"from_previous_spawn": &"stage13_entry_return",
		"left_exit": "LeftExitZone",
	},
	{
		"from": "res://scenes/rooms/stage14_air_dash_gate_room.tscn",
		"from_previous": "res://scenes/rooms/stage14_air_dash_shrine_room.tscn",
		"from_previous_spawn": &"stage14_shrine_return",
		"left_exit": "LeftExitZone",
	},
	{
		"from": "res://scenes/rooms/stage16_talisman_relay_room.tscn",
		"from_previous": "res://scenes/rooms/stage16_seal_release_threshold_room.tscn",
		"from_previous_spawn": &"stage16_seal_release_return",
		"left_exit": "LeftExitZone",
	},
]

const READABILITY_SCENES := [
	"res://scenes/rooms/tutorial_room.tscn",
	"res://scenes/rooms/goal_trial_room.tscn",
	"res://scenes/rooms/stage16_seal_release_threshold_room.tscn",
]

func test_ordinary_rooms_expose_previous_room_contract() -> void:
	for link: Dictionary in ORDINARY_BIDIRECTIONAL_LINKS:
		var room := _instantiate_room(str(link.from))
		assert_not_null(room, "room loads: %s" % str(link.from))
		if room == null:
			continue
		assert_true(room.has_method("get_spawn_position"), "room has spawn contract")
		assert_not_null(room.get_node_or_null(str(link.left_exit)), "room has LeftExitZone")
		if room.get("previous_room_path") != null:
			assert_eq(str(room.get("previous_room_path")), str(link.from_previous))
			assert_eq(room.get("previous_spawn_id"), link.from_previous_spawn)
		room.queue_free()

func test_left_exit_zones_have_safe_return_spawn() -> void:
	for link: Dictionary in ORDINARY_BIDIRECTIONAL_LINKS:
		var room := _instantiate_room(str(link.from))
		if room == null:
			continue
		var left_exit := room.get_node_or_null(str(link.left_exit)) as Node2D
		assert_not_null(left_exit)
		if left_exit != null:
			var spawn := room.call("get_spawn_position", link.from_previous_spawn) if room.has_method("get_spawn_position") else Vector2.ZERO
			assert_lt(absf(spawn.y - left_exit.position.y), 160.0, "return spawn is vertically near left exit")
		room.queue_free()

func test_no_visible_solid_green_goal_ledge_or_gate_placeholder() -> void:
	for path: String in READABILITY_SCENES:
		var room := _instantiate_room(path)
		if room == null:
			continue
		for polygon: Polygon2D in _find_polygons(room):
			if not polygon.visible:
				continue
			var name := polygon.name.to_lower()
			var is_goal_or_gate := name.find("goal") >= 0 or name.find("barrier") >= 0 or name.find("ledge") >= 0
			var is_solid_green := polygon.color.g > 0.55 and polygon.color.r < 0.35 and polygon.color.a >= 0.5
			assert_false(is_goal_or_gate and is_solid_green, "%s has solid green placeholder polygon: %s" % [path, polygon.get_path()])
		room.queue_free()

func _instantiate_room(path: String) -> Node2D:
	var packed := load(path) as PackedScene
	assert_not_null(packed, "packed scene exists: %s" % path)
	if packed == null:
		return null
	var room := packed.instantiate() as Node2D
	add_child_autofree(room)
	return room

func _find_polygons(root: Node) -> Array[Polygon2D]:
	var result: Array[Polygon2D] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node := stack.pop_back()
		if node is Polygon2D:
			result.append(node as Polygon2D)
		for child: Node in node.get_children():
			stack.append(child)
	return result
```

- [ ] **Step 2: Run the new test and confirm it fails**

Run:

```powershell
godot --headless --path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_alpha_demo_formal_level_remap.gd -gexit
```

Expected before implementation: FAIL because `LeftExitZone`, `previous_room_path`, or solid green `GoalLedge` remediation is missing.

- [ ] **Step 3: Commit the failing test**

Run:

```powershell
git add tests/demo/test_alpha_demo_formal_level_remap.gd
git commit -m "test: add formal demo remap contracts / 添加正式Demo关卡重排契约测试"
```

Expected: one commit containing only the new test file.

## Phase 2: Shared Bidirectional Room Contract

**Files:**
- Modify: `scripts/rooms/stage9_room_base.gd`
- Test: `tests/demo/test_alpha_demo_formal_level_remap.gd`

- [ ] **Step 1: Add previous-room exports and left-exit handling to Stage9 base**

Modify `scripts/rooms/stage9_room_base.gd`:

```gdscript
@export var previous_room_path := ""
@export var previous_spawn_id: StringName = &""
```

In `_process(_delta: float)`, check the left exit before the forward gate:

```gdscript
func _process(_delta: float) -> void:
	if _player == null or _transition_requested:
		return

	if _try_request_previous_room():
		return

	if not _gate_unlocked:
		return

	var exit_zone: Area2D = get_node_or_null("ExitZone") as Area2D
	if exit_zone == null:
		return

	if _player.global_position.x >= exit_zone.global_position.x - 36.0:
		_transition_requested = true
		_handle_exit_reached()
```

Add this helper near `_handle_exit_reached()`:

```gdscript
# 普通房间允许玩家从左侧返回上一房；Boss 锁门等例外不放 LeftExitZone 或不配置 previous_room_path。
func _try_request_previous_room() -> bool:
	if previous_room_path.is_empty():
		return false

	var left_exit_zone := get_node_or_null("LeftExitZone") as Node2D
	if left_exit_zone == null:
		return false

	if _player.global_position.x > left_exit_zone.global_position.x + 36.0:
		return false

	_transition_requested = true
	room_transition_requested.emit(previous_room_path, previous_spawn_id)
	return true
```

- [ ] **Step 2: Run the remap contract test**

Run:

```powershell
godot --headless --path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_alpha_demo_formal_level_remap.gd -gexit
```

Expected: still FAIL because scenes and early custom rooms have not been configured.

- [ ] **Step 3: Run Stage9+ smoke tests for regressions**

Run:

```powershell
godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests/stage9 -gdir=res://tests/stage13 -gdir=res://tests/stage14 -gdir=res://tests/stage16 -gexit
```

Expected: existing tests still pass.

## Phase 3: Early Custom Rooms and Scene Topology

**Files:**
- Modify: `scripts/rooms/combat_trial_room.gd`
- Modify: `scripts/rooms/goal_trial_room.gd`
- Modify: `scenes/rooms/combat_trial_room.tscn`
- Modify: `scenes/rooms/goal_trial_room.tscn`
- Modify: `scenes/rooms/stage9_zone_entry_room.tscn`
- Modify: selected Stage13 / Stage14 / Stage16 scenes listed in the test.

- [ ] **Step 1: Add previous-room logic to `CombatTrialRoom`**

In `scripts/rooms/combat_trial_room.gd`, add:

```gdscript
const TUTORIAL_ROOM_PATH := "res://scenes/rooms/tutorial_room.tscn"
```

Add to `_process(_delta)` before the unlocked-exit check:

```gdscript
	if _try_request_previous_room():
		return
```

Add helper:

```gdscript
# 战斗房是普通房间，允许从左侧回教程房；Boss 锁门不使用这套逻辑。
func _try_request_previous_room() -> bool:
	var left_exit_zone := get_node_or_null("LeftExitZone") as Node2D
	if left_exit_zone == null or _player == null or _transition_requested:
		return false

	if _player.global_position.x > left_exit_zone.global_position.x + 36.0:
		return false

	_transition_requested = true
	room_transition_requested.emit(TUTORIAL_ROOM_PATH, &"tutorial_return")
	return true
```

- [ ] **Step 2: Add previous-room logic to `GoalTrialRoom`**

In `scripts/rooms/goal_trial_room.gd`, add:

```gdscript
const COMBAT_TRIAL_ROOM_PATH := "res://scenes/rooms/combat_trial_room.tscn"
```

Add to `_process(_delta)` before the goal completion check:

```gdscript
	if _try_request_previous_room():
		return
```

Add helper:

```gdscript
# 目标房不是 Boss 锁门房，玩家应能从左侧回到战斗房复查路线。
func _try_request_previous_room() -> bool:
	var left_exit_zone := get_node_or_null("LeftExitZone") as Node2D
	if left_exit_zone == null or _player == null or _goal_finished:
		return false

	if _player.global_position.x > left_exit_zone.global_position.x + 36.0:
		return false

	_goal_finished = true
	room_transition_requested.emit(COMBAT_TRIAL_ROOM_PATH, &"combat_return")
	return true
```

- [ ] **Step 3: Add explicit return spawn IDs to flow configs or scene spawn methods**

Use existing `RoomFlowConfig` resources when present. Add these spawn IDs:

```text
tutorial_return -> near tutorial right-side safe floor
combat_return -> near combat right-side safe floor
goal_return -> near goal right-side safe floor
stage13_entry_return -> near Stage13 entry right-side safe floor
stage14_shrine_return -> near shrine right-side safe floor
stage16_seal_release_return -> near threshold right-side safe floor
```

If a room lacks `RoomFlowConfig`, extend its `SPAWN_POSITIONS` dictionary with the exact new spawn.

- [ ] **Step 4: Add `LeftExitZone` nodes and safe landing floors**

For each room in `ORDINARY_BIDIRECTIONAL_LINKS`, add:

```text
LeftExitZone: Area2D
  CollisionShape2D: RectangleShape2D
  ZoneVisual: Polygon2D, alpha <= 0.025
LeftExitMarker: Sprite2D or low-alpha seal marker
```

Rules:

- `LeftExitZone.position.x` should be near the left room boundary.
- Return spawn should land on existing floor, not inside hazard or wall.
- No new `LeftExitZone` in Boss rooms that intentionally lock the arena.

- [ ] **Step 5: Configure Stage9+ previous fields in scenes**

Set scene exports:

```text
stage9_zone_entry_room.previous_room_path = res://scenes/rooms/goal_trial_room.tscn
stage9_zone_entry_room.previous_spawn_id = goal_return
stage13_miasma_marsh_caster_room.previous_room_path = res://scenes/rooms/stage13_miasma_marsh_entry_room.tscn
stage13_miasma_marsh_caster_room.previous_spawn_id = stage13_entry_return
stage14_air_dash_gate_room.previous_room_path = res://scenes/rooms/stage14_air_dash_shrine_room.tscn
stage14_air_dash_gate_room.previous_spawn_id = stage14_shrine_return
stage16_talisman_relay_room.previous_room_path = res://scenes/rooms/stage16_seal_release_threshold_room.tscn
stage16_talisman_relay_room.previous_spawn_id = stage16_seal_release_return
```

- [ ] **Step 6: Run topology test until it passes**

Run:

```powershell
godot --headless --path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_alpha_demo_formal_level_remap.gd -gexit
```

Expected: PASS.

- [ ] **Step 7: Commit bidirectional contract and scene topology**

Run:

```powershell
git add scripts/rooms/stage9_room_base.gd scripts/rooms/combat_trial_room.gd scripts/rooms/goal_trial_room.gd scenes/rooms
git commit -m "feat: add bidirectional demo room links / 添加Demo房间双向连接"
```

Expected: one commit containing room logic and scene topology changes.

## Phase 4: Formal Demo Room Scale and Exit Safety

**Files:**
- Modify: selected `scenes/rooms/*.tscn`
- Modify: `scripts/dev/capture_demo_art_composition_review.gd` if its gates do not cover route-end safety
- Test: `tests/demo/test_alpha_demo_formal_level_remap.gd`

- [ ] **Step 1: Expand key room widths by gameplay role**

Apply these target camera widths:

```text
tutorial_room: keep 1536 or expand only if all four tutorial beats crowd each other
combat_trial_room: 960 minimum
goal_trial_room: 960 minimum, target ledge and goal separated by at least one jump beat
stage13_miasma_marsh_entry_room: 960 minimum
stage14_air_dash_gate_room: 960 minimum, gate approach and landing both visible
stage16_seal_release_threshold_room: 960 minimum, threshold prop not adjacent to immediate pit
```

Only edit `CAMERA_LIMITS` when the room truly needs more space; otherwise adjust floor and platform placement inside the existing width.

- [ ] **Step 2: Fix route-end safety**

For every ordinary exit:

```text
right exit -> next room left spawn lands on safe floor
left exit -> previous room return spawn lands on safe floor
exit zone -> not adjacent to unmarked pit
```

If a pit remains within 160 px of an exit, add either:

```text
safe bridge / landing platform / clear hazard marker / checkpoint before challenge
```

- [ ] **Step 3: Run route and stage tests**

Run:

```powershell
godot --headless --path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_alpha_demo_formal_level_remap.gd -gdir=res://tests/stage5 -gdir=res://tests/stage9 -gdir=res://tests/stage13 -gdir=res://tests/stage14 -gdir=res://tests/stage16 -gexit
```

Expected: all tests pass.

## Phase 5: Misleading Visuals and Image Gen Asset Pass

**Files:**
- Modify: `assets/art/props/stage13_seal_gate_01.svg` only if it can be safely replaced in place
- Or create: `assets/art/props/formal_seal_gate_demo_ai01.png`
- Or create: `assets/art/tilesets/formal_demo_platform_tiles_ai01.png`
- Or create: `assets/art/backgrounds/parallax/*`
- Modify: scene files that reference gate / ledge / exit visuals
- Modify if new assets are used: `docs/assets/asset-manifest.md`

- [ ] **Step 1: Replace red-green seal gate readability**

Preferred solution:

```text
Create a new formal seal gate asset with dark stone frame, talisman bands, closed/active/cleared states, no horizontal red platform-like bar, no green ladder-like rails.
```

Image generation prompt if current assets cannot solve it:

```text
Transparent background PNG, single centered eastern fantasy demon-sealing stone gate prop for a 2D side-view metroidvania, Southern and Northern Dynasties Buddhist talisman design, dark carved stone frame, glowing cyan talisman lines, three readable states shown in one horizontal sheet: locked, active, completed, no text, no UI, no characters, no red horizontal platform bar, no green ladder rails, readable at 64-128 px, enough padding, clean silhouette.
```

Target path:

```text
assets/source/ai_generated/demo_level_formal_remap/formal_seal_gate_demo_ai01.png
assets/art/props/formal_seal_gate_demo_ai01.png
```

- [ ] **Step 2: Replace solid green `GoalLedge`**

If `GoalLedge` remains a platform, replace its visible polygon with formal stone / shrine platform art:

```text
assets/art/tilesets/formal_demo_platform_tiles_ai01.png
```

Prompt if needed:

```text
Transparent background PNG, modular 2D side-view metroidvania platform tiles for an eastern fantasy demon-sealing shrine, 64x64 fixed grid, left cap, middle tile, right cap, underside thickness, cracked stone, subtle talisman engraving, no characters, no UI, no text, no green debug color, no perspective tilt, each tile centered in its own grid cell.
```

If `GoalLedge` is only a goal hint, remove its collision and replace with `GoalMarkerArt` Sprite2D.

- [ ] **Step 3: Add extendable background layers only where room length requires it**

Use existing background art first. If repeated sprites show obvious seams, generate parallax layers:

```text
assets/source/ai_generated/demo_level_formal_remap/parallax_shrine_layer_ai01.png
assets/art/backgrounds/parallax/parallax_shrine_layer_ai01.png
```

Prompt:

```text
Layered 2D metroidvania parallax background strip, eastern fantasy demon-sealing shrine ruins, misty mountain forest, no characters, no UI, no text, no readable foreground platforms, horizontally extendable composition, clean playable foreground empty, soft ink and gongbi inspired palette, 16:9 wide strip, game background layer.
```

- [ ] **Step 4: Run asset and art gates**

Run:

```powershell
godot --headless --path . --import
godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_demo_art_composition_review.gd
```

Expected:

```text
P0=0 / P1=0 / P2=0
```

The contact sheet must not show red-green gate bars as platform-like shapes or solid green ledges.

## Phase 6: Godot MCP Pro Runtime Review

**Files:**
- Create if needed: `scripts/dev/capture_demo_formal_remap_review.gd`
- Output local evidence: `tests/artifacts/local/demo-level-formal-remap/phase06_mcp_review/`
- Update: `docs/progress/logs/YYYY-MM-DD.md`

- [ ] **Step 1: Check Godot MCP Pro connectivity**

Run:

```powershell
.\scripts\dev\check-godot-mcp.ps1
node $env:USERPROFILE\.mcp\godot-mcp-pro\server\build\cli.js project info
```

Expected:

```text
project_name=nano-hunter
project_path=C:/Users/peng8/.codex/worktrees/d7ef/nano-hunter/
```

If direct MCP tools are available, call:

```text
mcp__godot_mcp_pro.get_project_info
mcp__godot_mcp_pro.get_scene_tree
```

If direct tools fail but CLI succeeds, use CLI and record the split-layer result.

- [ ] **Step 2: Start runtime and capture forward / backward samples**

Using Godot MCP Pro direct tools or CLI:

```powershell
node $env:USERPROFILE\.mcp\godot-mcp-pro\server\build\cli.js scene play --mode main
node $env:USERPROFILE\.mcp\godot-mcp-pro\server\build\cli.js runtime tree
```

Manual review path:

```text
Start menu -> Tutorial -> Combat -> back to Tutorial -> Combat -> Goal -> back to Combat -> Goal -> Stage9 entry
Stage13 entry -> caster -> back to entry
Stage14 shrine -> gate -> back to shrine
Stage16 threshold -> relay -> back to threshold
```

Capture screenshots for:

```text
entry, mid, right_exit, left_return
```

- [ ] **Step 3: Record MCP findings**

Write a local report:

```text
tests/artifacts/local/demo-level-formal-remap/phase06_mcp_review/demo_formal_remap_mcp_review.md
```

Required fields:

```text
project_path
main_scene
rooms_reviewed
bidirectional_pass_count
route_end_safety_issues
visual_readability_issues
screenshots
MCP_direct_or_CLI_boundary
```

- [ ] **Step 4: Stop runtime**

Run:

```powershell
node $env:USERPROFILE\.mcp\godot-mcp-pro\server\build\cli.js scene stop
```

Expected: runtime stops without leaving a stale play session.

## Phase 7: Full Regression and Documentation Closeout

**Files:**
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/logs/YYYY-MM-DD.md`
- Modify if asset generation happened: `docs/assets/asset-manifest.md`

- [ ] **Step 1: Run full validation**

Run:

```powershell
godot --headless --path . --import
godot --headless --path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_alpha_demo_formal_level_remap.gd -gexit
godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests/stage5 -gdir=res://tests/stage9 -gdir=res://tests/stage10 -gdir=res://tests/stage11 -gdir=res://tests/stage12 -gdir=res://tests/stage13 -gdir=res://tests/stage14 -gdir=res://tests/stage15 -gdir=res://tests/stage16 -gexit
godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_demo_art_composition_review.gd
godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_full_content_flow_evidence.gd
godot --rendering-driver opengl3 --path . --script res://scripts/dev/run_mcp_player_input_replay_probe.gd
git diff --check
```

Expected:

```text
import passes
formal remap GUT passes
stage GUT passes
DAC gate P0=0 / P1=0 / P2=0
full-flow P0=0 / P1=0 / P2=0
input replay reaches stage16_alpha_demo_completed=true
git diff --check has no new whitespace errors
```

- [ ] **Step 2: Update progress docs**

Add a log block to `docs/progress/logs/YYYY-MM-DD.md`:

```markdown
## Alpha Demo 正式关卡重排执行收口

### 背景

本轮修复用户指出的红绿封印门 / 绿色台阶误读、普通房间不能返回、连接处落坑和房间尺度 / 背景延展问题。

### 操作

- 增加正式 Demo remap 契约测试。
- 为普通房间补双向连接、反向 spawn 和安全落点。
- 替换误导性封印门 / 台阶 / 出口视觉。
- 对关键房间补背景延展和地形连续性。
- 阶段六使用 Godot MCP Pro 完成运行态抽样复核。

### 验证

- Godot import：通过。
- Formal remap GUT：通过。
- Stage5 / Stage9-16 GUT：通过。
- DAC / full-flow / input replay：通过。
- Godot MCP Pro 阶段六：通过。

### 风险 / 遗留

- 本轮完成正式 Demo 级关卡读值和双向通行，不等同商业最终 autotile 或全地图小地图系统。
```

- [ ] **Step 3: Commit docs and closeout**

Run:

```powershell
git add spec-design docs/implementation-plans plan docs/progress docs/assets tests scripts scenes assets
git commit -m "feat: formalize alpha demo level remap / 正式化Alpha Demo关卡重排"
```

Expected: final implementation commit includes code, scenes, tests, assets, and docs for the remap work.

## Self-Review

- Spec coverage: topology, bidirectional return, route-end safety, misleading gate / ledge visuals, background extension, image_gen boundary, Godot MCP Pro Phase 6, tests and docs are covered.
- Placeholder scan: plan contains no empty placeholder markers or undefined task names.
- Type consistency: new room fields use existing GDScript export style; transitions still emit `room_transition_requested(target_room_path, spawn_id)`.

## Execution Closure - 2026-07-02

### Status

- Phase 0 到 Phase 7 已按正式 Demo 级修复路线执行完成。
- 本轮实际未新增 image_gen 资产；绿色台阶 / 平台读值通过复用既有正式石质 underlay 和地形资源修复。
- 已提交 Phase 1 红灯契约测试检查点：`db4f699 test: add formal demo remap contracts / 添加正式Demo关卡重排契约测试`。
- 最终实现改动暂不做全量宽提交：工作树在本轮开始前已有大量资产、场景和文档脏改动，若直接执行计划中的宽 `git add spec-design docs/implementation-plans plan docs/progress docs/assets tests scripts scenes assets` 会把此前美术收口与本轮 remap 混成不可审的单一提交。

### Implemented Result

- `Stage9RoomBase`、`CombatTrialRoom`、`GoalTrialRoom` 已支持 previous-room / return-spawn 契约。
- Combat、Goal、Stage9 entry、Stage13 caster、Stage14 gate、Stage16 relay 等样本普通房间已补左侧返回出口、反向 spawn 和连接处安全落点。
- Goal 原绿色悬浮台阶改为正式石质平台读值。
- 新增 `scripts/dev/capture_demo_formal_remap_review.gd`，覆盖 `6` 条样本链路的前进 / 回退、路线末端安全和视觉读值。
- 排障修正已记录：左出口从 `x=-256` 移到 `x=-304`，避免 Stage9 entry spawn 同帧误触返回。

### Validation Result

- Godot import：通过。
- Formal remap GUT：`4/4` tests、`125` asserts。
- Stage5、Stage9-16 GUT：`97/97` tests、`1476` asserts。
- Phase 6 formal remap review：`rooms_reviewed=6`、`bidirectional_pass_count=6`、`route_end_safety_issues=0`、`visual_readability_issues=0`、`P0=0 / P1=0 / P2=0`。
- DAC strict gate、full-flow evidence、input replay：均为 `P0=0 / P1=0 / P2=0`；input replay `rooms_seen=37`。
- Godot MCP CLI 可连当前项目并取得 runtime tree；Codex 直连 MCP 工具仍返回 editor 未连接。
- `git diff --check`：通过，仅保留既有 CRLF warning。
