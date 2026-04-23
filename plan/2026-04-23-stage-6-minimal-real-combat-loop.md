# 阶段 6：最小真实战斗循环最终计划记录

> 说明：本文档用于留存本会话中最终确认过的 `stage6` 计划版本。  
> 原始执行用计划仍保留在 [2026-04-23-stage-6-minimal-real-combat-loop.md](/Users/peng8/Desktop/Project/Game/nano-hunter/docs/superpowers/plans/2026-04-23-stage-6-minimal-real-combat-loop.md)。

## Summary

以 `stage5` 的稳定基线为起点，`stage6` 固定采用“`TutorialRoom` 教学完成后进入独立战斗房 + 1 个基础近战敌人 + 玩家最小受击/生命/死亡重置闭环”的方案，把当前的 `move / jump / dash / attack` 推进成第一次真实承压的可玩循环。

本轮的完成标准不是扩系统，而是验证这 4 件事已经成立：玩家会被敌人真正威胁、会因为受击而调整操作、能在一次短战斗中击败敌人、死亡后能低摩擦回到本段继续尝试。失败循环固定为“本段即时重置”，不回滚整个教程区。

## Key Changes

### 开发前准备

- 按阶段型开发默认节奏执行 `分支 + worktree`。
- 分支名固定为 `codex/stage-6-minimal-real-combat-loop`。
- 开始实现前补齐 `spec-design/` 设计文档、`docs/superpowers/plans/` 实现计划、`docs/progress/` 启动记录。
- 当日日志预留 `Delegation Log`，因为本轮适合主动使用 `subagent / multi-agent`。

### 主流程与房间组织

- 保留 `Main` 默认从教程主流程开始，不回退到 `TestRoom`。
- `TutorialRoom` 继续负责 `move / jump / dash / attack` 教学，但完成后不直接结束，而是通过一次窄接口切入独立战斗房。
- 新增一个独立战斗房，建议命名为 `CombatTrialRoom`，只承载 stage6 的第一段真实战斗，不扩成通用房间系统。
- `Main` 增加最小房间切换能力，但只服务两件事：
  - `TutorialRoom -> CombatTrialRoom` 的单次过渡
  - 玩家在 `CombatTrialRoom` 死亡后的本段重置
- 本轮不做通用房间图、不做多出口分支、不做正式 checkpoint 系统。

### 玩家生命、受击与重置闭环

- 在玩家脚本上新增最小生命系统，固定为 `3` 点生命。
- 新增受击流程：
  - 玩家可被敌人命中并失去 `1` 点生命
  - 受击后进入短暂无敌期
  - 同时有轻量受击击退与可读性反馈
- 新增最小死亡流程：
  - 生命归零后玩家进入 defeated 状态
  - 不做正式死亡动画树，不做掉落，不做资源惩罚
  - 由 `Main` 负责即时重置当前战斗房并把玩家放回本段起点
  - 重置后玩家生命回满，房间敌人与门控同步回到初始状态
- 玩家在教程房完成前不承受真实战斗伤害；真实受击只发生在独立战斗房中。

### 基础近战敌人与战斗房目标

- 新增 1 个基础近战敌人，采用“单巡逻路径 + 接触伤害”的最小模型，不引入复杂 AI。
- 敌人行为固定为：
  - 在一小段水平范围内巡逻
  - 遇到玩家后继续保持近身压力
  - 与玩家身体接触时造成 `1` 点伤害
  - 自身生命固定为 `1`，被玩家当前普通攻击命中后立即失效
- 新增战斗房门控：
  - 战斗房入口后，出口默认锁定
  - 玩家击败该敌人后，出口解锁
  - 玩家抵达出口区域后判定 `stage6` 切片完成
- 本轮不做多敌人组合、不做远程敌人、不做敌人伤害数值扩展。

### HUD 与运行时可读性

- 保留现有提示区，但 HUD 从“教程专用展示”提升为“教程 + 战斗共用的最小运行时 HUD”。
- 战斗面板必须真实反映：
  - 玩家当前生命值 `3 -> 0`
  - `dash` 是否可用
  - 当前房间提示文本
- 在 `CombatTrialRoom` 中，提示内容改为“观察敌人巡逻、接近时机、受击会重置本段、击败敌人后离开”这一类战斗指引。
- 本轮不做正式药水、货币、经验、装备栏或复杂状态图标。

### 推荐代理协作

- 本轮默认应主动评估并优先使用 `multi-agent`。
- 推荐拆成 3 条并行工作流：
  - 代理 A：`Main` 的最小房间切换与本段重置逻辑
  - 代理 B：玩家生命/受击/无敌 + 基础近战敌人 + `CombatTrialRoom`
  - 代理 C：HUD 真实状态接线、Stage 6 GUT、文档留痕
- 若实现时发现多个子任务必须同时改同一核心文件，再降级为 `subagent` 或主代理串行整合，不为了形式并行而硬拆。

## Public APIs / Interfaces

- 玩家新增最小公开能力：
  - `receive_damage(hit_direction: Vector2, damage: int = 1, knockback_force: float = 0.0) -> void`
  - `get_current_health() -> int`
  - `get_max_health() -> int`
- 玩家新增最小信号：
  - `health_changed(current_health: int, max_health: int)`
  - `defeated()`
- 房间侧新增最小过渡契约：
  - 房间可发出 `room_transition_requested(room_id: StringName, spawn_id: StringName)` 信号
  - 房间可选实现 `get_spawn_position(spawn_id: StringName) -> Vector2`
  - 房间可选实现 `reset_room() -> void`
- 新敌人继续沿用当前受击契约：
  - `receive_attack(hit_direction: Vector2, knockback_force: float) -> void`
- HUD 不直接管理玩法逻辑，只消费玩家生命变化、房间提示变化和 `dash` 状态。

## Test Plan

- 基线验证继续保留：
  - `godot --headless --path . --import`
  - Stage 1 GUT
  - Stage 2 GUT
  - Stage 3 GUT
  - Stage 4 GUT
  - Stage 5 GUT
  - `git diff --check`
- 新增 Stage 6 GUT，至少覆盖这些场景：
  - 玩家初始生命为 `3`
  - 玩家受击后生命减少，并在无敌窗口内不会连续掉血
  - 玩家生命归零会触发 defeated 信号
  - `TutorialRoom` 完成后会请求切到 `CombatTrialRoom`
  - `CombatTrialRoom` 初始出口锁定，敌人被击败后出口解锁
  - 玩家在战斗房死亡后，`Main` 会把当前房间和玩家重置到战斗房起点，且生命回满
  - HUD 能反映真实生命值与当前提示，不再只是固定展示文本
- 手动复核重点：
  - 教程结束后进入实战的节奏是否自然
  - 敌人是否足以制造压力，但不会因为伤害过高而变成挫败
  - 死亡重置是否低摩擦，不会把玩家扔回整段教程重新来
  - 当前 `dash + attack` 是否已经对这一类近战敌人有明确价值

## Assumptions

- `stage6` 的唯一真实压力源固定为“1 个基础近战巡逻敌人”，不混入远程敌人或攻击性障碍。
- 失败循环固定为“战斗房本段即时重置”，不是“只掉血不死亡”，也不是“整段教程重开”。
- `CombatTrialRoom` 是独立战斗房，但只通过一次最小房间过渡接在教程后面；本轮不把它扩展成通用多房间系统。
- 玩家生命固定为 `3`，敌人生命固定为 `1`，敌人单次伤害固定为 `1`，这些都视为 stage6 默认调参起点。
- 本轮明确不做：
  - 多敌人组合
  - 远程敌人
  - 正式 checkpoint 系统
  - 存档
  - 掉落与资源惩罚
  - 复杂敌人 AI
  - 姿态与元素系统扩展
- 若实现后发现当前敌人压力仍不足以形成“真实战斗循环”，优先微调敌人巡逻范围、接触伤害时机、玩家无敌时间与战斗房布局，不提前扩系统。
