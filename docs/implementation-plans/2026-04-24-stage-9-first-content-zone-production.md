# Stage 9 First Content Zone Production Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development when正式实现开始，并在满足条件时实际启用 `subagent / multi-agent`；本轮重点是验证阶段 8 的模板和配置化结果能否真正支撑内容生产，不接受回退到脚本级临时拼装。

**Goal:** 在阶段 8 稳定基线上，产出第一段真正像“游戏区域”的 `4-6` 房间线性主线内容，接入第 `2` 类敌人、首个正式 checkpoint 和第一种正式门控。
**Architecture:** 保持当前配置资源、HUD 快照接口和敌人模板入口不变，不新增新能力、不做支路、不做地图系统。通过线性主线小区域、地面冲锋敌、房间入口存档点和开关门，验证内容生产链路已经成立。
**Tech Stack:** Godot 4.6、GDScript、`.tscn` 文本场景、GUT、PowerShell

---

## Task 1: 收口 stage9 preflight 文档与开发现场

**Files:**
- Create: `spec-design/2026-04-24-stage-9-first-content-zone-production-design.md`
- Create: `docs/implementation-plans/2026-04-24-stage-9-first-content-zone-production.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-24.md`

- [ ] 在 `codex/stage-9-first-content-zone-production` 与对应 `.worktrees/` 中启动本轮 preflight
- [ ] 记录本轮采用 `分支 + worktree` 的原因、目标范围与不做项
- [ ] 明确本轮是“首个小区域内容生产”，不是继续做 stage8 系统收口
- [ ] 固定本轮关键选择：
  - 第 2 类敌人：`地面冲锋敌`
  - checkpoint：`房间入口存档点`
  - 门控：`开关门`
  - 区域结构：`线性主线区`

## Task 2: 搭建首个线性主线小区域

**Files:**
- Create/Modify: new room scenes and scripts for the stage9 content zone
- Modify: `scripts/main/main.gd` only as needed for接入新区域
- Test: `tests/stage9/test_stage_9_first_content_zone_production.gd`

- [ ] 先补红测，暴露当前主线还没有 `4-6` 房间的小区域结构
- [ ] 固定做 `4-6` 房间的线性主线区，不做支路，不做半开放回环
- [ ] 推荐房间构成为：
  - 入口房
  - 基础战斗房
  - 冲锋敌首次教学房
  - 开关门门控房
  - 混合战斗/门控房
  - 区域终点房
- [ ] 保持当前三段原型链路不被推翻，stage9 作为新内容区域独立接入

## Task 3: 新增第 2 类敌人“地面冲锋敌”

**Files:**
- Create/Modify: enemy scene/script/config under current enemy template path
- Modify: room scenes that place the new enemy
- Test: `tests/stage9/test_stage_9_first_content_zone_production.gd`

- [ ] 先补红测，暴露当前只有 `BasicMeleeEnemy`
- [ ] 新增“地面冲锋敌”，继续继承当前基础敌人模板入口
- [ ] 固定行为边界：
  - 常态短距离巡逻或待机
  - 进入触发范围后做一次明显的水平冲锋
  - 保持接触伤害
  - 继续沿用当前 `receive_attack(...)` 与 `defeated` 契约
- [ ] 不引入远程敌人、护盾敌人、精英敌人或多阶段 AI

## Task 4: 接入首个正式 checkpoint 与开关门门控

**Files:**
- Modify: `scripts/main/main.gd`
- Modify/Create: room scripts/scenes used in the stage9 zone
- Test: `tests/stage9/test_stage_9_first_content_zone_production.gd`

- [ ] 先补红测，暴露当前没有正式 checkpoint 与开关门主线门控
- [ ] 固定 checkpoint 为“房间入口存档点”
- [ ] 固定更新规则：
  - 通过关键房间后刷新恢复点
  - 失败后从最近一次已激活 checkpoint 房间入口恢复
- [ ] 固定门控为“开关门”
- [ ] 让开关门与区域推进绑定，例如清房或触发机关后解锁下一扇门
- [ ] 不引入存档系统、钥匙系统或可破坏阻挡作为主门控

## Task 5: 复用配置资源与 HUD 最小扩展

**Files:**
- Modify/Create: room flow configs under current config paths
- Modify: `scripts/ui/tutorial_hud.gd` only as needed for stage9 prompt support
- Test: `tests/stage9/test_stage_9_first_content_zone_production.gd`

- [ ] 让 stage9 小区域实际复用当前阶段 8 已有的配置资源路径和模式
- [ ] 新增与小区域相关的：
  - 房间标题 / 提示
  - checkpoint 提示
  - 开关门状态最小可读性提示
- [ ] 保持 HUD 继续沿用当前第二轮接口，不扩成第三轮 UI 系统
- [ ] 不允许为求快回退到脚本里硬编码一批新参数

## Task 6: Stage 9 自动化验证与文档收口

**Files:**
- Create: `tests/stage9/test_stage_9_first_content_zone_production.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-24.md`

- [ ] 覆盖线性主线区可从入口推进到终点
- [ ] 覆盖第 2 类敌人已接入且行为与基础敌人明显不同
- [ ] 覆盖 checkpoint 激活后失败会从最近 checkpoint 房间入口恢复
- [ ] 覆盖开关门默认关闭、满足条件后解锁
- [ ] 覆盖小区域房间配置资源已被实际读取
- [ ] 确认 Stage 1-8 测试不回归
- [ ] 若启用了重要的 `subagent` / `multi-agent`，补写 `Delegation Log`

## Delegation Requirement

### Mandatory Gate

本轮在正式实现前必须先做任务拆分。只要同时满足以下条件，就必须启用代理协作：

- 存在 2 个以上子任务
- 写入范围可隔离
- 验证可独立
- 下一步不强依赖单一阻塞结果

### Default Split

阶段 9 默认按以下方式启用 `multi-agent`：

- 代理 A：小区域房间与开关门 / checkpoint 流程
- 代理 B：地面冲锋敌实现与敌人配置接入
- 代理 C：Stage 9 GUT、HUD 最小提示接线与文档留痕

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

若触发例外，必须在 `docs/progress/2026-04-24.md` 或当日后续日志中写明：

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
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage9/test_stage_9_first_content_zone_production.gd -gexit`
- `git diff --check`

## Completion Criteria

- 已完成一个 `4-6` 房间的线性主线小区域
- 第 `2` 类敌人“地面冲锋敌”已接入并稳定工作
- 首个正式 checkpoint 与开关门门控已接入主流程
- 现有配置资源、HUD 接口和敌人模板已被真正用于内容生产
- 阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 / 9 自动化验证全部通过
- 当前结果足以承接 `阶段 10：战斗变化与轻量成长循环`
