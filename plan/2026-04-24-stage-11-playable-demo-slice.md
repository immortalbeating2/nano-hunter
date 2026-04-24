# 阶段 11：可交付试玩 Demo 切片开发计划

## Summary

以已完成并收口的 `stage10` 为稳定基线，`stage11` 固定采用“扩成完整 demo”的方案，不再新增新的核心动作、敌人类别或第二个大区域，而是把当前 `stage1-10` 已验证成立的系统与内容收成一个可以连续试玩、失败重来、到达终点并得到明确反馈的 demo 级切片。

本轮继续保留 `分支 + worktree`、阶段开始前的完整 preflight、阶段结束前的自动化验证与最终人工复核收口。与前一阶段不同的是，本轮会把“代码注释补强”作为显式要求，确保 demo 阶段继续扩内容时不会在低可读性基线上前进。

本轮关键选择固定为：

- demo 形态：`8-12` 个有效体验节点的完整试玩链路
- 内容策略：优先复用 `stage9-10` 现有房间与系统，只新增最小必要连接与终点表达
- polish 重点：HUD / 目标提示 / 门控可读性 / demo 终点反馈
- 注释要求：`stage11` 触达的核心脚本必须满足新的文件头与分段注释标准

## Preflight

- 本轮固定按 `分支 + worktree` 启动
- 分支名固定为 `codex/stage-11-playable-demo-slice`
- worktree 固定放在 `.worktrees/stage-11-playable-demo-slice`
- 实现前必须先补齐并同步：
  - `spec-design/2026-04-24-stage-11-playable-demo-slice-design.md`
  - `docs/implementation-plans/2026-04-24-stage-11-playable-demo-slice.md`
  - `plan/2026-04-24-stage-11-playable-demo-slice.md`
  - `docs/progress/status.md`
  - `docs/progress/timeline.md`
  - 当日日志
- preflight 必须先做一轮 fresh 基线确认：
  - `godot --headless --path . --import`
  - Stage 1-10 GUT
  - `git diff --check`
- preflight 中必须显式写明本轮不做项：
  - 不做第二个大区域
  - 不做正式经济 / 装备 / 技能树
  - 不做完整剧情系统
  - 不做第 `4` 类敌人或新的核心战斗动作
  - 不做正式商业体量美术替换

## Key Changes

### Demo 闭环

- 以当前主链路为骨架，收成一条可以从开始一路推进到 demo 终点的完整试玩路线
- 新增 `1` 个明确的 demo 终点房或等价终点状态
- 完成后必须有：
  - 明确完成提示
  - 最小终点反馈
  - 可返回或重开试玩的入口
- 失败 / 重来继续沿用现有 checkpoint 与 room reset，不扩展成正式存档系统

### 内容收束与可读性

- 不再新增新机制，重点放在现有内容的收束：
  - 主线推进是否顺畅
  - 支路是否值得进入
  - 挑战房是否可读
  - 终点是否明确
- HUD 做一轮 demo 级最小 polish，但不重构成复杂系统
- 固定补强的信息：
  - 当前主目标
  - 支路 / 挑战房收益提示
  - 恢复点 / 收集物反馈
  - demo 完成反馈
- 关键门控、支路入口、挑战房入口与终点方向必须有更明确的视觉或文案提示

### 注释补强要求

- `stage11` 修改过的核心脚本必须满足新的注释最低覆盖标准
- 新增脚本必须包含文件头职责注释
- 超过约 `120` 行或承担多职责的脚本必须有分段注释
- 主流程控制、终点推进、HUD 关键读值路径与 demo 完成逻辑必须有阅读引导注释
- 阶段测试文件继续要求文件头说明与主体 / 辅助函数分段

## Public APIs / Interfaces

- `Main` 或主流程控制层新增最小 demo 完成态读值或等价接口
- 房间推进配置可新增“demo 终点”相关最小字段，但不扩成通用剧情系统
- HUD 快照接口新增 demo 目标 / 完成反馈相关最小字段
- 不新增新的玩家动作接口
- 不新增新的敌人基础契约
- 继续沿用现有：
  - 玩家 HUD 快照
  - 房间 `get_hud_context()`
  - 敌人 `receive_attack(...)` / `defeated`

## Test Plan

- 基线验证继续保留：
  - `godot --headless --path . --import`
  - Stage 1-10 GUT
  - `git diff --check`
- 新增 Stage 11 GUT，至少覆盖：
  - 现有主线可连续推进到 demo 终点
  - 支路 / 挑战房仍可进入且不破坏主线
  - demo 完成反馈可以被稳定触发
  - 失败 / 重来后仍能回到正确推进点
  - HUD 可读出 demo 目标 / 完成态的最小信息
  - Stage 1-10 既有测试不回归
- 阶段收口前必须补完整人工复核，不以自动化替代：
  - 从开始到 demo 终点完整跑一遍
  - 至少一次进入支路
  - 至少一次进入挑战房
  - 至少一次失败 / 重来验证
  - 确认 HUD、提示、门控、支路收益和终点反馈在真人观看下可理解
  - 记录人工复核结果、卡点、平衡问题与是否达到 demo 基线

## Assumptions

- `stage11` 默认复用 `stage1-10` 现有内容作为 demo 骨架，而不是新开区域
- 本轮重点是 demo 闭环、可读性和内容收束，不再继续扩玩法系统
- 注释补强属于本阶段显式要求，不留到 demo 收口末尾再补
- 若实现中发现试玩链路过长，应优先裁剪冗余节点，而不是继续增房间
