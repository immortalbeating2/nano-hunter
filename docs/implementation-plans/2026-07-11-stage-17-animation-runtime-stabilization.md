# Stage 17 Animation Runtime Stabilization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不改变当前玩家手感、房间职责和战斗数值的前提下，让 Luna、四类普通敌人与 Seal Guardian 的动作按真实玩法状态完整、稳定、可测试地显示。

**Architecture:** 继续复用现有 GDScript 状态、`AnimatedSprite2D` 和 SpriteFrames。玩家短动作由玩法计时映射到关键帧；普通敌人共享播放与死亡入口放在 `BaseEnemy`；Boss 把 post-attack recovery 与 guard-break stagger 拆成两个状态。动画层只读取玩法状态，不反向驱动伤害或房间流程。

**Tech Stack:** Godot 4.6.3、GDScript、GUT、Python 资产审计、现有 Image Gen / Batch06 资产流程。

**执行状态（2026-07-11）：** 开发实现、自动化回归、严格审计、OpenGL 运行探针、键盘 / synthetic Joypad smoke 和 input-only Demo 全链路重放均已完成。仅保留实体手柄 / 真人体验签核，以及合并 `main` 后的阶段指针更新；这两项不由当前分支自动宣称。

---

## 文件职责映射

- `tests/stage17/test_stage_17_animation_runtime_stabilization.gd`：Stage17 唯一专项契约测试入口。
- `scripts/player/player_placeholder.gd`：Luna 状态到 body / VFX 关键帧映射。
- `scripts/configs/player_config.gd`、`scenes/player/player_placeholder_config.tres`：独立受击视觉时长。
- `scripts/combat/base_enemy.gd`：普通敌人默认播放、统一资源切换与 defeat visual。
- `scripts/combat/basic_melee_enemy.gd`：idle_move 与 defeat。
- `scripts/combat/ground_charger_enemy.gd`：patrol / telegraph / charge / recover / defeat。
- `scripts/combat/aerial_sentinel_enemy.gd`：hover 与 defeat。
- `scripts/combat/miasma_caster_enemy.gd`：idle_cast / pulse 与 defeat。
- `scripts/combat/seal_guardian_boss.gd`：strike / recovery / staggered 状态拆分和 body / VFX 帧同步。
- `scripts/assets/audit_animation_runtime_replacement.py`：Model Lock 和跨动作尺寸门禁。
- `scripts/dev/capture_stage17_animation_runtime_review.gd`：统一运行态时间序列与截图证据。
- `scripts/dev/run_stage17_input_smoke.gd`：键盘与 synthetic Joypad 生产 InputMap smoke。
- `scripts/dev/mcp_player_input_replay_probe.gd`、`scripts/dev/run_mcp_player_input_replay_probe.gd`：只通过输入推进 Alpha Demo 主线并输出阻塞证据。
- `docs/assets/asset-manifest.md`：新增 Batch06 Stage17 资源登记。

## Task 1：建立安全基线和失败测试

**Files:**

- Create: `tests/stage17/test_stage_17_animation_runtime_stabilization.gd`
- Read: `docs/assets/2026-07-11-character-enemy-animation-runtime-audit.md`
- Read: `spec-design/2026-07-11-stage-17-animation-runtime-stabilization-design.md`

- [x] **Step 1：先收口当前地图分支现场**

Run:

```powershell
git status --short
git branch --show-current
git log -1 --oneline
```

Expected:

- 当前地图重排已有明确提交点。
- Stage17 不在未知未提交改动上直接实现。

- [x] **Step 2：创建并切换阶段分支**

Run:

```powershell
git switch -c codex/stage-17-animation-runtime-stabilization
```

Expected: 当前分支为 `codex/stage-17-animation-runtime-stabilization`。

- [x] **Step 3：记录实现前基线**

Run:

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Expected: 记录当前真实通过数；任何基线失败先单独诊断，不把它伪装成 Stage17 回归。

- [x] **Step 4：写 Stage17 失败测试**

测试文件至少包含以下独立测试函数：

- `test_luna_runtime_transform_never_changes_between_actions`
- `test_luna_attack_uses_startup_active_recovery_keyframes_within_point_23_seconds`
- `test_luna_air_dash_uses_six_readable_frames_and_does_not_end_standing`
- `test_luna_jump_animation_follows_start_rise_fall_land_phases`
- `test_luna_hit_react_ends_before_invulnerability`
- `test_all_regular_enemy_cycles_start_and_advance`
- `test_regular_enemy_defeat_keeps_visual_feedback_without_blocking_room_clear`
- `test_ground_charger_animation_follows_patrol_telegraph_charge_and_recover`
- `test_boss_attack_recovery_and_stagger_are_visible_and_distinct`
- `test_boss_attack_body_and_vfx_reach_late_frames_and_damage_once`

测试固定断言：

```gdscript
assert_eq(runtime_visual.position, Vector2(0.0, -16.0))
assert_eq(runtime_visual.scale, Vector2(0.45, 0.45))
assert_true(observed_frames.size() >= 5)
assert_true(enemy_visual.is_playing())
assert_ne(frame_before, frame_after)
assert_true(boss_visual.visible)
assert_true(boss_state in [&"recovery", &"staggered"])
```

- [x] **Step 5：运行测试并确认当前失败**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage17/test_stage_17_animation_runtime_stabilization.gd -gexit
```

Expected: 至少因普通敌人 `is_playing=false`、Boss staggered invisible、Luna 帧数不足和 Jump 相位错误失败。

- [x] **Step 6：提交失败测试**

```powershell
git add tests/stage17/test_stage_17_animation_runtime_stabilization.gd
git commit -m "添加 Stage17 动作失败契约 / Add Stage17 animation failing contracts"
```

## Task 2：实现 Luna 短动作关键帧契约

**Files:**

- Modify: `scripts/player/player_placeholder.gd`
- Modify: `scripts/configs/player_config.gd`
- Modify: `scenes/player/player_placeholder_config.tres`
- Test: `tests/stage17/test_stage_17_animation_runtime_stabilization.gd`
- Test: `tests/stage3/test_stage_3_combat_feel.gd`
- Test: `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`

- [x] **Step 1：新增受击视觉独立计时**

在 `PlayerConfig` 增加：

```gdscript
@export var hit_react_visual_duration: float = 0.20
```

在默认资源增加：

```text
hit_react_visual_duration = 0.2
```

在玩家脚本同步为运行时字段，并在 `receive_damage()` 中设置 `_hit_react_visual_remaining`；在物理帧单独递减，不能复用 `_damage_invulnerability_remaining`。

- [x] **Step 2：加入最小关键帧常量**

在玩家脚本中加入：

```gdscript
const LUNA_ATTACK_KEYFRAMES := [4, 6, 7, 8, 10, 12]
const LUNA_AIR_DASH_KEYFRAMES := [0, 2, 4, 6, 7, 8]
const LUNA_HIT_REACT_KEYFRAMES := [0, 2, 4, 5]
const LUNA_ATTACK_VFX_KEYFRAMES := [0, 1, 3, 5, 6, 7]
```

不要新建通用 animation controller。

- [x] **Step 3：实现统一 normalized progress 到关键帧映射**

在 `player_placeholder.gd` 增加唯一 helper：

```gdscript
func _select_keyframe(keyframes: Array, elapsed: float, duration: float) -> int:
	if keyframes.is_empty():
		return 0
	var progress := clampf(elapsed / maxf(duration, 0.0001), 0.0, 0.9999)
	return int(keyframes[mini(int(progress * keyframes.size()), keyframes.size() - 1)])
```

- [x] **Step 4：Attack 由 gameplay phase 驱动 body 与 VFX**

要求：

- startup 使用 body frame `4`，VFX hidden。
- active 使用 body frames `6,7`，在 active 首帧显示 slash / seal arc。
- recovery 使用 body frames `8,10,12`，VFX 同步后半段并在结束隐藏。
- `_perform_attack_hits()` 仍只在 active 首次进入时调用一次。

- [x] **Step 5：Air Dash 和 Hit React 改为手动帧映射**

- Dash 使用 `_dash_elapsed / dash_duration` 映射 6 帧。
- Hit 使用 `_hit_react_visual_remaining` 的反向进度映射 4 帧。
- 手动帧状态调用 `pause()` 并写 `frame`；Idle、Run、Death 继续 `play()`。

- [x] **Step 6：运行 Luna 专项测试**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage17/test_stage_17_animation_runtime_stabilization.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage3/test_stage_3_combat_feel.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
```

Expected: Attack、Dash、Hit 相关 Stage17 测试通过；Jump 测试仍因新资源未接入失败。

## Task 3：生成并接入 Luna Model Lock Jump 资源

**Files:**

- Create: `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_state_runtime_sheet_ai04.png`
- Create: `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_state_runtime_sheet_ai04.frames.json`
- Create: `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_state_runtime_sheet_ai04.source.json`
- Create: `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_state_runtime_sheet_ai04.spriteframes.tres`
- Modify: `scripts/player/player_placeholder.gd`
- Modify: `scripts/assets/audit_animation_runtime_replacement.py`
- Modify: `docs/assets/asset-manifest.md`
- Test: `tests/stage17/test_stage_17_animation_runtime_stabilization.gd`

- [x] **Step 1：按 Model Lock v1 生成单一 jump-state sheet**

固定输出语义：

```text
jump_start: 3 frames
rise_hold: 2 frames
fall_hold: 2 frames
land: 4 frames
cell: 192x192
center_x: 96 +/- 2px
grounded foot_y: 176 +/- 2px
standing reference height: 140 +/- 6px
```

- [x] **Step 2：SpriteFrames 使用固定 animation 名**

```text
jump_start
rise_hold
fall_hold
land
```

`rise_hold` 与 `fall_hold` 可 loop；`jump_start` 与 `land` 不 loop。

- [x] **Step 3：扩展严格审计**

在现有审计中增加：

- Model ID / canonical reference 记录。
- grounded foot baseline。
- center line。
- standing body height。
- 跨动作中位高度偏差。

Expected: 新 jump 资源通过，旧 `luna_jump_fall_runtime_sheet_ai03` 保留为 archived reference，不再 live binding。

- [x] **Step 4：接入物理相位映射**

```gdscript
STATE_JUMP_RISE + jump visual elapsed <= jump_start duration -> jump_start
STATE_JUMP_RISE -> rise_hold
STATE_JUMP_FALL -> fall_hold
STATE_LAND -> land
```

落地结束后回 idle；空中不得播放 land 或 idle。

- [x] **Step 5：运行审计和测试**

```powershell
python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage17/test_stage_17_animation_runtime_stabilization.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
```

- [x] **Step 6：提交 Luna 动作契约**

```powershell
git add scripts/player/player_placeholder.gd scripts/configs/player_config.gd scenes/player/player_placeholder_config.tres scripts/assets/audit_animation_runtime_replacement.py tests/stage17/test_stage_17_animation_runtime_stabilization.gd assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_state_runtime_sheet_ai04* docs/assets/asset-manifest.md
git commit -m "修复 Luna 动作状态契约 / Stabilize Luna animation state contract"
```

## Task 4：在 BaseEnemy 一次修复普通敌人播放与死亡入口

**Files:**

- Modify: `scripts/combat/base_enemy.gd`
- Test: `tests/stage17/test_stage_17_animation_runtime_stabilization.gd`
- Test: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`

- [x] **Step 1：新增共享资源切换 helper**

```gdscript
func _play_runtime_animation(frames: SpriteFrames, animation_name: StringName, asset_id: String, restart := false) -> void:
	if _runtime_animation_visual == null or frames == null or not frames.has_animation(animation_name):
		return
	var should_restart := restart
	_runtime_animation_visual.visible = true
	if _runtime_animation_visual.sprite_frames != frames:
		_runtime_animation_visual.sprite_frames = frames
		should_restart = true
	if _runtime_animation_visual.animation != animation_name:
		_runtime_animation_visual.animation = animation_name
		should_restart = true
	_runtime_animation_visual.set_meta("asset_id", asset_id)
	if should_restart or not _runtime_animation_visual.is_playing():
		_runtime_animation_visual.play(animation_name)
```

该 helper 只保留在基类，不复制到四个子类。

- [x] **Step 2：默认 cycle 在 `_ready()` 启动**

`_prepare_runtime_visual_stack()` 完成后读取场景已配置的 `animation` 并调用 `play()`。这一步应让四类普通敌人当前 ai01 cycle 都出现 `is_playing=true` 和 frame progression。

- [x] **Step 3：defeat 不再立即隐藏 body**

`receive_attack(...)` 继续立即：

- 设置 `_is_defeated`。
- 关闭 collision / hurtbox。
- 显示 hit spark。
- 发出 `defeated`。

但 body 交给 `_play_defeat_animation()`；没有 defeat 资源时保留当前终帧，不能隐藏成空白。

- [x] **Step 4：运行共享回归**

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage17/test_stage_17_animation_runtime_stabilization.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage6/test_stage_6_minimal_real_combat_loop.gd -gexit
```

Expected: 默认 cycle 测试通过；defeat 资产测试仍待 Task 5。

## Task 5：接入普通敌人真实行为和死亡动作

**Files:**

- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_basic_melee_defeat_runtime_sheet_ai02.png`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_basic_melee_defeat_runtime_sheet_ai02.frames.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_basic_melee_defeat_runtime_sheet_ai02.source.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_basic_melee_defeat_runtime_sheet_ai02.spriteframes.tres`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_action_runtime_sheet_ai02.png`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_action_runtime_sheet_ai02.frames.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_action_runtime_sheet_ai02.source.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_action_runtime_sheet_ai02.spriteframes.tres`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_defeat_runtime_sheet_ai02.png`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_defeat_runtime_sheet_ai02.frames.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_defeat_runtime_sheet_ai02.source.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_defeat_runtime_sheet_ai02.spriteframes.tres`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_aerial_sentinel_defeat_runtime_sheet_ai02.png`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_aerial_sentinel_defeat_runtime_sheet_ai02.frames.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_aerial_sentinel_defeat_runtime_sheet_ai02.source.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_aerial_sentinel_defeat_runtime_sheet_ai02.spriteframes.tres`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_miasma_caster_defeat_runtime_sheet_ai02.png`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_miasma_caster_defeat_runtime_sheet_ai02.frames.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_miasma_caster_defeat_runtime_sheet_ai02.source.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_miasma_caster_defeat_runtime_sheet_ai02.spriteframes.tres`
- Modify: `scripts/combat/basic_melee_enemy.gd`
- Modify: `scripts/combat/ground_charger_enemy.gd`
- Modify: `scripts/combat/aerial_sentinel_enemy.gd`
- Modify: `scripts/combat/miasma_caster_enemy.gd`
- Modify: `scripts/configs/ground_charger_enemy_config.gd`
- Modify: `scripts/configs/ground_charger_enemy_config.tres`
- Modify: `docs/assets/asset-manifest.md`
- Test: `tests/stage17/test_stage_17_animation_runtime_stabilization.gd`

- [x] **Step 1：生成最小状态资产**

固定 animation 名：

```text
basic_melee_defeat
ground_charger_telegraph
ground_charger_charge
ground_charger_recover
ground_charger_defeat
aerial_sentinel_defeat
miasma_caster_defeat
```

- [x] **Step 2：Basic / Aerial / Caster 只映射真实行为**

- Basic：现有 cycle 持续 loop；击败切 defeat。
- Aerial：现有 cycle 持续 loop；击败切 defeat。
- Caster：现有 cycle 持续 loop，与 pulse aura 同步；击败切 defeat 并隐藏压力 VFX。
- 不新增 basic attack、aerial dive 或 caster projectile。

- [x] **Step 3：Ground Charger 在真实状态切换时改动画**

先在配置中增加：

```gdscript
@export var telegraph_duration: float = 0.12
```

状态映射：

```gdscript
patrol -> existing ground_charger_cycle
trigger -> ground_charger_telegraph for 0.12 seconds
telegraph end -> ground_charger_charge and start movement
charge end -> ground_charger_recover
recover end -> patrol cycle
receive_attack -> ground_charger_defeat
```

Telegraph 期间不移动、不造成新的伤害判定；原 charge speed、charge duration、recovery duration 和 touch damage 保持不变。

- [x] **Step 4：运行敌人专项与阶段回归**

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage17/test_stage_17_animation_runtime_stabilization.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage9/test_stage_9_first_content_zone_production.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage10/test_stage_10_combat_variation_and_light_progression.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage13/test_stage_13_second_content_zone_production.gd -gexit
```

## Task 6：拆分 Boss recovery 与 staggered 并同步动作 / VFX

**Files:**

- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_stagger_runtime_sheet_ai01.png`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_stagger_runtime_sheet_ai01.frames.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_stagger_runtime_sheet_ai01.source.json`
- Create: `assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_stagger_runtime_sheet_ai01.spriteframes.tres`
- Modify: `scripts/combat/seal_guardian_boss.gd`
- Test: `tests/stage17/test_stage_17_animation_runtime_stabilization.gd`
- Test: `tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`

- [x] **Step 1：新增 recovery 状态**

```gdscript
const STATE_RECOVERY: StringName = &"recovery"
```

状态链改为：

```text
idle -> close_pressure -> ground_impact / air_punish -> recovery -> idle
receive_attack with guard <= 0 -> staggered -> idle
```

- [x] **Step 2：strike 和 recovery 分别映射 attack 前后帧**

- strike `0.18s`：body / VFX frames `0-3`。
- strike 结束边界：结算一次 damage，进入 recovery。
- recovery：body / VFX frames `4-7`，按当前 phase-adjusted recovery duration 映射。
- recovery 结束：guard 恢复并进入 idle。

- [x] **Step 3：staggered 使用独立资源和 `stagger_duration`**

- `receive_attack()` 护印降为 0 时进入 staggered。
- staggered 全程显示 `seal_guardian_stagger_runtime_sheet_ai01`。
- `_update_attack_loop()` 对 staggered 使用 `stagger_duration`，不再复用 recovery duration。
- staggered 结束恢复 guard 并进入 idle。

- [x] **Step 4：任何状态都不得落入隐藏分支**

`_sync_runtime_animation_visual()` 必须显式覆盖 idle、warning、attack、recovery、staggered、defeated。未知状态才允许报错并 fallback idle，不能直接 `visible=false`。

- [x] **Step 5：运行 Boss 测试**

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage17/test_stage_17_animation_runtime_stabilization.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
```

Expected:

- Boss attack 每次只扣一次血。
- strike / recovery / staggered visible。
- body 与 VFX 到达后半帧。
- Boss 房 defeated / completion 契约不变。

- [x] **Step 6：提交敌人与 Boss 状态映射**

```powershell
git add scripts/combat tests/stage17 tests/stage9 tests/stage10 tests/stage13 tests/stage15 assets/art/characters/enemies/sprite_sheets/runtime_replacement docs/assets/asset-manifest.md
git commit -m "接入敌人与 Boss 动作状态 / Wire enemy and boss animation states"
```

## Task 7：建立统一运行态时间序列复核

**Files:**

- Create: `scripts/dev/capture_stage17_animation_runtime_review.gd`
- Test artifact: `tests/artifacts/local/stage17-animation-runtime/runtime_report.json`
- Test artifact: `tests/artifacts/local/stage17-animation-runtime/*.png`

- [x] **Step 1：复用现有场景而不是制作新 showcase 场景**

脚本依次实例化或进入：

```text
scenes/player/player_placeholder.tscn
scenes/combat/basic_melee_enemy.tscn
scenes/combat/ground_charger_enemy.tscn
scenes/combat/aerial_sentinel_enemy.tscn
scenes/combat/miasma_caster_enemy.tscn
scenes/combat/seal_guardian_boss.tscn
```

- [x] **Step 2：记录结构化时间序列**

每个样本至少记录：

```json
{
  "time": 0.0,
  "state": "attack",
  "animation": "attack_body",
  "frame": 4,
  "is_playing": false,
  "visible": true
}
```

- [x] **Step 3：脚本自检条件**

- Luna Attack / Dash 观察到规定数量的 distinct frames。
- Jump 相位顺序正确。
- 四敌默认 frame 推进。
- 四敌 defeat 可见。
- Boss recovery / staggered 都 visible。
- Boss attack VFX 后半帧被观察到。

- [x] **Step 4：运行复核**

```powershell
godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_stage17_animation_runtime_review.gd
```

Expected: exit code `0`，JSON `ok=true`；截图进入 ignored local artifacts。

## Task 8：完整回归、文档和阶段收口

**Files:**

- Modify: `docs/assets/2026-07-11-character-enemy-animation-runtime-audit.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/logs/YYYY-MM-DD.md`
- Modify after merge only: `AGENTS.md`

- [x] **Step 1：运行完整验证矩阵**

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage17/test_stage_17_animation_runtime_stabilization.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/stage3 -gdir=res://tests/stage6 -gdir=res://tests/stage9 -gdir=res://tests/stage10 -gdir=res://tests/stage13 -gdir=res://tests/stage14 -gdir=res://tests/stage15 -gdir=res://tests/stage16 -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict
godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_stage17_animation_runtime_review.gd
git diff --check
```

- [ ] **Step 2：做真人连续试玩**

至少完成：

- tutorial 攻击 / 跳跃 / Dash。
- Stage9 Charger。
- Stage10 Aerial。
- Stage13 Caster。
- Stage15 Boss 完整一轮。

键鼠为必测；手柄在 Stage17 收口前至少 smoke 一次。

自动化覆盖结果：键盘与 synthetic Joypad 均经 `Input.parse_input_event` 进入生产玩家；主菜单起点的 input-only replay 连续完成到 Stage16 End。实体手柄与真人体验仍保留为外部人工签核，不在本计划中伪装成自动化结论。

- [x] **Step 3：更新文档**

记录：

- 实际修改范围。
- 自动化通过数。
- 运行探针路径。
- 人工复核结论。
- 是否仍有需重生成的动作。
- 下一阶段仍是独立的最小元素 / 姿态 / 序列切片。

- [x] **Step 4：提交收口**

```powershell
git add docs scripts/dev/capture_stage17_animation_runtime_review.gd
git commit -m "收口 Stage17 动作验证 / Close Stage17 animation QA"
```

- [ ] **Step 5：合并后更新主线阶段指针**

仅在 Stage17 已验证并合并 `main` 后，更新 `AGENTS.md` 当前默认目标；未合并前不得把 main 写成已完成 Stage17。
