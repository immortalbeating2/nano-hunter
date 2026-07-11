# Stage 17 Animation Runtime Stabilization / 动作运行态稳定化

## Summary

Stage 17 修复 Luna、四类普通敌人与 Seal Guardian 的动作运行态：固定 Luna 模型锁定、把短玩法状态映射到可读关键帧、启动普通敌人动画、补最小行为 / 死亡动作，并拆开 Boss recovery 与 staggered。

本阶段完成后，当前 Alpha Demo 的角色和敌人动作应达到“可看、可玩、可调、可验证”的稳定基线，但不代表商业版完整动作库或北极星战斗系统完成。

## Completion Record

- 2026-07-11：Stage17 开发实现和代理可执行的自动化验收已完成于 `codex/stage-17-animation-runtime-stabilization`；尚未合并 `main`，也未推送远端。
- Luna、四类普通敌人与 Seal Guardian 均按本计划完成动作状态契约；新增资源全部由可重放构建脚本生成并通过严格审计。
- 最终验证：Stage17 `10/10` tests、`118` asserts；全量 GUT `229/229` tests、`6245` asserts；strict audit `21/21 active ready`；OpenGL 运行探针 `ok=true` 且十一项检查全真。
- 输入验证：键盘与 synthetic Joypad smoke 均为 `ok=true`；从主菜单开始的 input-only replay 完成 `34` 次主线房间进入并触发 Stage16 最终完成，`P0/P1/P2=0`。
- 唯一边界例外：input replay 证明 Stage10 Challenge 的 Aerial Sentinel 在 Formal Demo 重排后比真实攻击可达范围高约 `2px`，因此仅将其根节点 `y=120 -> 144` 并同步 Batch3 构建脚本 / 契约测试；不改房间职责、敌人类型、玩家攻击范围或 Hurtbox。
- 验证边界：自动化不冒充真人或实体手柄硬件认证；该项保留为合并 / 发布前人工签核，不构成遗留代码修复。

## Goals

- Luna 所有动作保持固定 runtime transform，跨动作不再读成缩放跳变。
- Attack、Air Dash、Jump / Fall / Land、Hit React 与玩法状态时长一致。
- 四类普通敌人的 animation 真正播放，并跟随已有行为状态；击败后有可见死亡动作。
- Boss strike、recovery、staggered、defeated 全程有动作映射，body 与 VFX 同步且伤害只结算一次。
- 建立 Stage17 GUT、严格资产审计和运行探针证据。

## Non-Goals

- 不增加房间、敌人种类、Boss 招式或新区域。
- 不实现 Miasma Caster 投射物。
- 不改变玩家攻击总时长、Air Dash 时长、移动速度、hitbox / hurtbox 尺寸或房间门控。
- 不实现元素、姿态、序列连锁、装备、技能树、任务和叙事系统。
- 不引入通用动画框架或新依赖。

## Stage Boundary / Preflight

- 当前 `codex/demo-level-formal-remap` 必须先形成稳定提交点；不得直接在大量未提交地图 / 资产改动上开始 Stage 17。
- 默认分支：`codex/stage-17-animation-runtime-stabilization`。
- 默认工作方式：复用当前固定永久工作树，不新建临时 worktree。
- 开始前记录：当前提交、`git status --short`、Godot import 和全量 GUT 结果。
- 若 Stage 17 实现需要改动当前地图或房间职责，视为越界，停止并另开任务。

## Key Changes

1. Luna 不再让长动画自然播放后被短状态截断；Attack、Air Dash、Hit React 使用关键帧相位映射。
2. `luna_jump_state_runtime_sheet_ai04` 按 Model Lock v1 生成，提供 `jump_start / rise_hold / fall_hold / land`。
3. `BaseEnemy` 统一启动默认动画并处理 defeat visual；子类只声明真实行为状态映射。
4. Ground Charger 增加 telegraph / charge / recover 动作；其它无主动攻击行为的普通敌人不伪造攻击状态。
5. Boss 增加 `STATE_RECOVERY`；`STATE_STAGGERED` 只承担护印击破，使用 `stagger_duration` 和独立 stagger clip。
6. 新增 Stage17 自动测试和统一运行态序列探针。

## Public Interfaces

- `PlayerConfig` 新增：`hit_react_visual_duration: float = 0.20`。
- `GroundChargerEnemyConfig` 新增：`telegraph_duration: float = 0.12`，只负责冲锋前读招，不改变伤害值。
- `SealGuardianBoss.get_boss_state()` 可能新增返回值：`recovery`。
- `SealGuardianBoss` 保留现有 `strike_duration`、`recovery_duration`、`stagger_duration` 导出字段；语义修正为 strike、攻击恢复和护印硬直三段独立窗口。
- 普通敌人继续对外只依赖 `receive_attack(...)`、`defeated`、`is_defeated()`；动画 helper 保持 `_` 前缀，不成为房间公开契约。
- 不新增全局 autoload、单例或通用动画服务。

## Content Scope

- 玩家：Idle、Run、Jump Start、Rise、Fall、Land、Attack、Air Attack、Ground / Air Dash、Hit React、Death。
- 普通敌人：Basic Melee、Ground Charger、Aerial Sentinel、Miasma Caster。
- Boss：Idle、Warning、Ground Impact / Air Punish、Recovery、Staggered、Defeated。
- 试玩房间仅作为复核入口，不改变内容：tutorial、Stage9 charger、Stage10 aerial、Stage13 caster、Stage15 Boss。

## Asset Scope

复用：

- Luna idle / run / attack / air dash / hit / death ai03。
- 四类普通敌人现有 ai01 cycle。
- Boss idle / warning / attack body / attack VFX / defeat。

新增：

- `luna_jump_state_runtime_sheet_ai04` 及 metadata / SpriteFrames。
- `enemy_basic_melee_defeat_runtime_sheet_ai02`。
- `enemy_ground_charger_action_runtime_sheet_ai02`。
- `enemy_ground_charger_defeat_runtime_sheet_ai02`。
- `enemy_aerial_sentinel_defeat_runtime_sheet_ai02`。
- `enemy_miasma_caster_defeat_runtime_sheet_ai02`。
- `seal_guardian_stagger_runtime_sheet_ai01`。

所有新增资产属于 Asset Production Track Batch 06 的 Stage17 补充，不建立新的资产体系。

## Implementation Plan

### Checkpoint 1 - 失败测试与 Luna 动作契约

- 新增 Stage17 GUT，先证明当前 Attack / Air Dash 截断、Jump 相位错误、Hit 与无敌时间耦合、敌人不播放和 Boss 隐藏。
- 在玩家控制器内加入最小关键帧映射；不新建通用 animation controller。
- 新增 `hit_react_visual_duration`，保持其余玩法参数不变。
- 生成并接入 Model Lock v1 的 Luna jump state 资源。
- 提交建议：`修复 Luna 动作状态契约 / Stabilize Luna animation state contract`。

### Checkpoint 2 - 普通敌人与 Boss 状态映射

- 在 `BaseEnemy` 一次修复默认 cycle 启动和 defeat visual。
- Ground Charger 绑定 patrol / telegraph / charge / recover；其余敌人只映射真实已有行为。
- 生成并接入四类敌人 defeat 资源。
- Boss 拆出 recovery，补 stagger clip，并同步 body / VFX 帧段。
- 提交建议：`接入敌人与 Boss 动作状态 / Wire enemy and boss animation states`。

### Checkpoint 3 - 运行态复核与阶段收口

- 新增统一 probe，记录完整状态 / 帧时间序列和截图。
- 跑专项与全量 GUT、严格资产审计、Godot import、真人试玩。
- 更新资产、状态、时间线和当日日志。
- 提交建议：`收口 Stage17 动作验证 / Close Stage17 animation QA`。

## Test Plan

专项：

- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage17/test_stage_17_animation_runtime_stabilization.gd -gexit`
- `python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict`
- `godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_stage17_animation_runtime_review.gd`

回归：

- Stage3：攻击与受击。
- Stage6：普通敌人最小战斗闭环。
- Stage9：Ground Charger。
- Stage10：Aerial Sentinel 与空中攻击。
- Stage13：Miasma Caster 与压力房。
- Stage14：Air Dash 与动作资源绑定。
- Stage15：Boss 状态机、恢复充能与房间胜利。
- Stage16：完整 Alpha Demo 主链和完成反馈。
- 全量：`godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
- 导入：`godot --headless --path . --import`
- 文本：乱码扫描与 `git diff --check`。

## Manual Review / Runtime Review

- Luna：Idle -> Run -> Jump Start -> Rise -> Fall -> Land；Ground / Air Attack；Ground / Air Dash；Hit -> 无敌剩余；Death 终帧。
- 普通敌人：默认循环确实推进；Charger 读招 / 冲锋 / 恢复；四类 defeat 可见且门控立即解锁。
- Boss：warning -> strike -> recovery -> idle；护印击破 -> staggered -> idle；attack body 与 VFX 同帧段；任何状态都不隐藏。
- 复核输出放入 `tests/artifacts/local/stage17-animation-runtime/`，默认不提交截图。
- 已完成 OpenGL 截图逐张复核和 input-only 全链路连续重放；实体手柄硬件体验仍需人工签核。

## Documentation Updates

- `docs/assets/asset-manifest.md`：登记新增 Batch06 Stage17 资产和状态。
- `docs/assets/2026-07-11-character-enemy-animation-runtime-audit.md`：修复后追加 closure 链接，不覆盖原始证据。
- `docs/progress/status.md`：更新 Stage17 当前状态、风险和下一步。
- `docs/progress/timeline.md`：记录 Stage17 规划和最终收口里程碑。
- `docs/progress/logs/YYYY-MM-DD.md`：记录每个 checkpoint 的操作、验证、提交和遗留。
- 阶段完成并合并 main 后再更新根 `AGENTS.md` 的当前默认目标。

## Exit Criteria

- Luna runtime transform 在所有动作中保持固定；Model Lock 严格审计和人工复核通过。
- Attack 在 `0.23s` 内经过 startup / active / recovery 关键帧，Air Dash 在 `0.24s` 内经过至少 6 个可读姿态。
- Jump / Rise / Fall / Land 按物理相位显示，空中不回站姿。
- Hit React 在 `0.20s` 左右结束，玩家仍保留完整 `0.35s` 无敌时间。
- 四类普通敌人的默认 animation `is_playing=true` 且 frame 推进；击败后有可见 defeat。
- Boss strike / recovery / staggered / defeated 全程 visible；攻击和 VFX 到达终帧；伤害每次攻击只结算一次。
- Stage17 专项、相关阶段回归和全量 GUT 全绿；Godot import、严格资产审计、运行探针和人工试玩通过。
- 进度文档完整更新；当前分支形成可回退提交点。

## Risks

- Luna Hit React 的宽高变化可能在关键帧重排后仍读成模型漂移；若人工复核失败，只重生成 Hit React。
- 新敌人 defeat sheet 可能增加 Batch06 工作量；不得因此扩展敌人 AI 或攻击系统。
- Boss 新 recovery 状态会影响既有测试对 `staggered` 的期待，需要同步修正测试，但不得改变房间胜利契约。
- 当前工作树很脏；错误基线选择是最大工程风险，必须先收口地图分支。

## Assumptions

- 现有玩家攻击、Dash、生命、门控和 Boss 伤害数值保持当前基线。
- Godot 4.6.x、GUT、godot_mcp 继续可用。
- 当前 ai03 / enemy ai01 / Boss runtime 资源可继续作为合法源资产；只补确实缺失或违反 Model Lock 的动作。
- 下一玩法阶段会单独规划最小 `2 元素 + 2 姿态 + 2 步序列`，不在 Stage17 偷跑。
