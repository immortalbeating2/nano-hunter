# Stage 7 Short Mainline Chain Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development when实现开始，并在满足条件时实际启用 `subagent / multi-agent`；本轮不再接受只在计划里写“推荐”，但执行时回退为默认单线推进。

**Goal:** 在阶段 6 稳定基线上，把当前 `TutorialRoom -> CombatTrialRoom` 推进为 `TutorialRoom -> CombatTrialRoom -> GoalTrialRoom` 的短链路主流程。
**Architecture:** 保留现有教学房与实战房；新增 `GoalTrialRoom` 作为混合门控目标房；`Main` 升级为支持固定三段顺序流转的最小主流程控制器；HUD 接入三段流程提示。
**Tech Stack:** Godot 4.6、GDScript、`.tscn` 文本场景、GUT、PowerShell

---

## Task 1: 收口 stage7 preflight 文档与开发现场

**Files:**
- Create: `spec-design/2026-04-23-stage-7-short-mainline-chain-design.md`
- Create: `docs/superpowers/plans/2026-04-23-stage-7-short-mainline-chain.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 在 `codex/stage-7-short-mainline-chain` 与对应 `.worktrees/` 中启动本轮 preflight
- [ ] 记录本轮采用 `分支 + worktree` 的原因、目标范围与不做项
- [ ] 明确本轮代理协作是硬约束，而不是软建议

## Task 2: 让 Main 支持三段顺序流转

**Files:**
- Modify: `scenes/main/main.tscn`
- Modify: `scripts/main/main.gd`
- Test: `tests/stage7/test_stage_7_short_mainline_chain.gd`

- [ ] 先补红测，暴露当前 `Main` 仍停留在阶段 6 的定向切房逻辑
- [ ] 让 `Main` 能按顺序推进 `TutorialRoom -> CombatTrialRoom -> GoalTrialRoom`
- [ ] 保持房间切换能力只服务三段短链路，不扩成正式房间图系统
- [ ] 保持战斗房失败时仍只重置当前战斗房，不回滚整条链路

## Task 3: 新建 GoalTrialRoom 与混合门控流程

**Files:**
- Create: `scenes/rooms/goal_trial_room.tscn`
- Create: `scripts/rooms/goal_trial_room.gd`
- Possibly Modify: `scenes/combat/basic_melee_enemy.tscn`
- Possibly Modify: `scripts/combat/basic_melee_enemy.gd`
- Test: `tests/stage7/test_stage_7_short_mainline_chain.gd`

- [ ] 新建 `GoalTrialRoom`，固定为“混合门控目标房”
- [ ] 让目标房同时承载一次空间门控与一次最小攻击型交互
- [ ] 让房间在目标达成后发出明确完成信号或过渡请求
- [ ] 不引入第二类敌人、新能力、钥匙系统或资源收集循环

## Task 4: HUD 升级为三段流程提示

**Files:**
- Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `scripts/ui/tutorial_hud.gd`
- Possibly Modify: `scripts/rooms/tutorial_room.gd`
- Possibly Modify: `scripts/rooms/combat_trial_room.gd`
- Test: `tests/stage7/test_stage_7_short_mainline_chain.gd`

- [ ] 让 HUD 能正确区分教学房、实战房、目标房与完成提示
- [ ] 保持战斗面板继续真实读取生命值与 `dash` 状态
- [ ] 不扩成独立结算 UI 或完整前台系统

## Task 5: Stage 7 自动化验证与文档收口

**Files:**
- Create: `tests/stage7/test_stage_7_short_mainline_chain.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 覆盖三段房间顺序推进
- [ ] 覆盖 `GoalTrialRoom` 的房间契约、出生点与完成条件
- [ ] 覆盖目标房门控初始关闭、满足条件后解锁
- [ ] 覆盖 HUD 三段流程提示切换
- [ ] 覆盖 `CombatTrialRoom` 死亡重置不回滚整条链路
- [ ] 若启用了重要的 `subagent` / `multi-agent`，补写 `Delegation Log`

## Delegation Requirement

### Mandatory Gate

本轮在正式实现前必须先做任务拆分。只要同时满足以下条件，就必须启用代理协作：

- 存在 2 个以上子任务
- 写入范围可隔离
- 验证可独立
- 下一步不强依赖单一阻塞结果

### Default Split

阶段 7 默认按以下方式启用 `multi-agent`：

- 代理 A：`Main` 与三段房间流转契约
- 代理 B：`GoalTrialRoom` 与门控流程
- 代理 C：HUD 分段提示、Stage 7 GUT、文档留痕

### Allowed Fallback

若实现时发现两个以上任务会持续同时改同一批核心文件，则允许降级为：

- 至少 1 个 `subagent` 负责非阻塞侧任务
- 主代理负责阻塞主线整合

### Only Valid Exceptions

只有在以下情况成立时，才允许不启用 `multi-agent`：

- 需求仍未收敛
- 单点调试尚未定位
- 写入范围无法隔离

若触发例外，必须在 `docs/progress/2026-04-23.md` 或当日后续日志中写明：

- 为什么不能启用
- 哪个条件不满足
- 何时重新评估

## Verification

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage3/test_stage_3_combat_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage4/test_stage_4_minimal_ability_difference.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage6/test_stage_6_minimal_real_combat_loop.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage7/test_stage_7_short_mainline_chain.gd -gexit`
- `git diff --check`

## Completion Criteria

- `Main` 能稳定推进 `TutorialRoom -> CombatTrialRoom -> GoalTrialRoom`
- `GoalTrialRoom` 成为有效的混合门控目标房，而不是纯平台或纯战斗房
- HUD 能随着三段流程切换提示
- `CombatTrialRoom` 的失败重置仍只作用于当前战斗房
- 阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 自动化验证全部通过
- 当前结果足以作为阶段 8 的稳定前置基线
