# Stage 8 Systems Hardening And Content Prep Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development when正式实现开始，并在满足条件时实际启用 `subagent / multi-agent`；本轮重点是稳固接口与配置收口，不接受继续以脚本级临时逻辑扩内容。

**Goal:** 在阶段 7 稳定基线上，优先完成参数数据化，其次收口 HUD 第二轮接口，最后把 `BasicMeleeEnemy` 整理成可复用敌人模板，为后续扩内容建立更稳的工程基线。
**Architecture:** 保留当前 `Main -> TutorialRoom -> CombatTrialRoom -> GoalTrialRoom` 的三段短链路不变，不新增能力、不新增房间、不新增敌人种类。通过只读配置资源、统一 HUD 上下文接口与基础敌人模板，把当前原型中的关键临时逻辑收口成更可复用的稳定结构。
**Tech Stack:** Godot 4.6、GDScript、`.tscn` 文本场景、GUT、PowerShell

---

## Task 1: 收口 stage8 preflight 文档与开发现场

**Files:**
- Create: `spec-design/2026-04-23-stage-8-systems-hardening-and-content-prep-design.md`
- Create: `docs/superpowers/plans/2026-04-23-stage-8-systems-hardening-and-content-prep.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 在 `codex/stage-8-systems-hardening-and-content-prep` 与对应 `.worktrees/` 中启动本轮 preflight
- [ ] 记录本轮采用 `分支 + worktree` 的原因、目标范围与不做项
- [ ] 明确本轮主目标是“稳固接口”，不是“继续扩 stage7 内容”
- [ ] 明确参数数据化只做到只读配置资产，模板化只先落在敌人侧

## Task 2: 玩家、敌人与房间关键参数数据化

**Files:**
- Create: `scripts/configs/player_config.gd` or equivalent `Resource`
- Create: `scripts/configs/basic_enemy_config.gd` or equivalent `Resource`
- Create: room flow config resource(s) for current chain
- Modify: `scripts/player/player_placeholder.gd`
- Modify: `scripts/combat/basic_melee_enemy.gd`
- Modify: current room scripts as needed
- Test: `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`

- [ ] 先补红测，暴露当前关键参数仍散落在脚本导出字段中
- [ ] 把玩家关键参数收口到只读配置资源
- [ ] 把 `BasicMeleeEnemy` 关键参数收口到只读配置资源
- [ ] 把当前三段主流程中的关键门控文案或阈值收口到最小房间配置资源
- [ ] 保持初始化路径简单：场景实例持有配置资源并在固定入口读取应用

## Task 3: HUD 第二轮接口收口

**Files:**
- Modify: `scripts/ui/tutorial_hud.gd`
- Possibly Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `scripts/main/main.gd`
- Modify: room scripts as needed
- Test: `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`

- [ ] 先补红测，暴露当前 HUD 过度依赖零散 `has_method()` 探测
- [ ] 固定房间侧 HUD 上下文接口
- [ ] 固定玩家侧战斗状态只读接口
- [ ] 让 HUD 统一通过稳定接口读取步骤标题、提示文本、生命值与 `dash` 状态
- [ ] 保持 HUD 仍是当前唯一前台入口，不扩结算 UI、菜单或背包

## Task 4: 基础敌人模板化

**Files:**
- Modify: `scripts/combat/basic_melee_enemy.gd`
- Possibly Create: `scripts/combat/base_enemy.gd` or equivalent
- Possibly Create: shared enemy config or helper layer
- Test: `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`

- [ ] 先补红测，暴露当前 `BasicMeleeEnemy` 仍是单体原型实现
- [ ] 抽出基础敌人共用契约与最小骨架
- [ ] 保持 `receive_attack(...)` 与 `defeated` 信号不回归
- [ ] 让当前近战敌人继续作为第一种具体模板实例运行
- [ ] 不在本轮新增第二类敌人

## Task 5: Stage 8 自动化验证与文档收口

**Files:**
- Create: `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 覆盖玩家关键参数已从配置资源读取并成功应用
- [ ] 覆盖基础近战敌人关键参数已从配置资源读取并成功应用
- [ ] 覆盖房间/HUD 上下文能通过统一接口稳定读取
- [ ] 覆盖基础敌人模板契约不回归
- [ ] 覆盖既有 Stage 1-7 测试继续通过
- [ ] 若启用了重要的 `subagent` / `multi-agent`，补写 `Delegation Log`

## Delegation Requirement

### Mandatory Gate

本轮在正式实现前必须先做任务拆分。只要同时满足以下条件，就必须启用代理协作：

- 存在 2 个以上子任务
- 写入范围可隔离
- 验证可独立
- 下一步不强依赖单一阻塞结果

### Default Split

阶段 8 默认按以下方式启用 `multi-agent`：

- 代理 A：参数数据化与配置资源接入
- 代理 B：HUD 第二轮接口收口
- 代理 C：基础敌人模板化、Stage 8 GUT 与文档留痕

### Allowed Fallback

若实现时发现两个以上任务会持续同时改同一批核心文件，则允许降级为：

- 至少 1 个 `subagent` 负责非阻塞侧任务
- 主代理负责阻塞主线整合

### Only Valid Exceptions

只有在以下情况成立时，才允许不启用 `multi-agent`：

- 需求仍未收敛
- 单点调试尚未定位
- 写入范围无法隔离
- 当前会话工具授权边界不允许实际启用

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
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd -gexit`
- `git diff --check`

## Completion Criteria

- 玩家、基础近战敌人与当前主流程关键参数已从只读配置资源稳定读取
- HUD 已改为统一消费稳定只读接口，而不是继续依赖零散探测
- `BasicMeleeEnemy` 已整理成可复用的基础敌人模板入口
- `Main`、三段房间主流程与当前玩法闭环保持稳定，不因系统收口而回归
- 阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 自动化验证全部通过
- 当前结果足以作为后续继续扩内容的稳定前置基线
