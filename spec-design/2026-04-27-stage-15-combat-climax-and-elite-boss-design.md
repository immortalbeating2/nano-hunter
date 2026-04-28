# Stage 15 战斗高潮与首个精英 Boss 原型设计

## 目标

Stage 15 在 Stage 14 已完成的回溯链路之后，加入 Demo 后半段第一场战斗高潮。核心目标固定为一个精英 Boss 原型 `Seal Guardian / 封印守卫`，以及唯一战斗容错机制 `Recovery Charge / 恢复充能`。

本阶段仍服务 Alpha Demo 候选，不扩展成正式 Boss 框架、技能树、药瓶经济或剧情演出系统。

## 核心体验

- Stage 14 loop return 房结束后，玩家进入 Boss 前压迫段。
- 压迫段通过混合敌人组合让玩家重新确认移动、攻击、空中冲刺和恢复充能。
- Boss 房锁定节奏：进入、读招、受击、恢复充能、失败重试、击败后释放出口。
- Boss 击败后进入阶段完成房，作为 Stage 16 Alpha Demo 打包候选的前置完成反馈。

## Seal Guardian

Seal Guardian 是单阶段精英 Boss。它沿用普通敌人的 `receive_attack(...)` 与 `defeated` 契约，但提供更稳定的 HUD 与测试读值。

稳定接口：

- `receive_attack(hit_direction: Vector2, knockback_force: float) -> void`
- `is_defeated() -> bool`
- `get_current_health() -> int`
- `get_max_health() -> int`
- `get_boss_state() -> StringName`

状态范围：

- `idle`：等待玩家进入压迫距离。
- `close_pressure`：短读招，用颜色变化表达攻击即将到来。
- `ground_impact`：地面冲击，处理普通站位压力。
- `air_punish`：当玩家明显高于 Boss 时触发空中惩罚读值。
- `staggered`：短暂硬直，既用于出招后收招，也用于护印被打空后的喘息。
- `defeated`：击败状态，关闭主体碰撞并发出 `defeated`。

## Recovery Charge

Recovery Charge 是 Stage 15 唯一新增战斗扩展。它只提供战斗容错，不成为正式资源系统。

- 玩家命中可受击对象后获得恢复充能。
- 如果目标在本次命中后被击败，额外获得击败奖励充能。
- 充能满后，玩家受伤时可消耗充能恢复 1 点生命。
- 满血时不能消费充能，生命不超过 `max_health`。
- 房间切换不要求正式持久化；本阶段作为运行期战斗反馈存在。

## 房间结构

- `stage15_seal_pressure_room`：Stage 14 后的入口压迫段。
- `stage15_mixed_gauntlet_room`：混合敌人遭遇，确认恢复充能价值。
- `stage15_challenge_branch_room`：可选战斗挑战支线。
- `stage15_seal_guardian_boss_room`：Boss 专用房，负责 HUD 上下文、失败重试和胜利转场。
- `stage15_completion_room`：阶段完成反馈房。

## HUD 与资产方向

HUD 必须继续显示 Stage 14 Air Dash 与回溯收益，不允许被 Boss UI 覆盖。Boss 房额外显示恢复充能比例、就绪状态、Boss 名称、生命和状态。

资产 manifest 追加 Stage 15 占位需求：Boss 剪影、攻击预警、Boss HUD、恢复充能图标和封印机关视觉。视觉方向应逐步回归南北朝东方奇幻、佛门符印与封妖机关语境。

## 不做项

- 不做多阶段 Boss。
- 不做正式 Boss 框架或数据驱动 Boss 编辑器。
- 不做药瓶、蓝量、技能树或战斗经济系统。
- 不做正式剧情演出、过场动画或完整音频制作。
- 不引入第二个新能力。

## 验收标准

- Stage 14 loop return 能进入 Stage 15 前置段。
- 玩家命中敌人可积累恢复充能，满后可恢复 1 点生命。
- Boss 能被攻击、减血、击败并发出 `defeated`。
- Boss 房支持失败重试和击败后转场。
- `Main.get_demo_progress_snapshot()` 可读到 Stage 15 Boss 击败状态。
- Stage 15 专项 GUT、全量 GUT、Godot import、`git diff --check` 通过。
- 必须完成 Godot MCP 人工复核，并记录运行态结论。
