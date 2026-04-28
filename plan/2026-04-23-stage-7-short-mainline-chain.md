# 阶段 7：短链路主流程串联最终计划记录

> 说明：本文档用于留存本会话中最终确认过的 `stage7` 计划版本。
> 原始执行用计划仍保留在 [2026-04-23-stage-7-short-mainline-chain.md](/Users/peng8/Desktop/Project/Game/nano-hunter/docs/implementation-plans/2026-04-23-stage-7-short-mainline-chain.md)。

## Summary

以当前已完成的 `stage6` 为稳定基线，`stage7` 固定采用“三段顺序链路”方案，把现有的 `TutorialRoom -> CombatTrialRoom` 扩展为一条真正可走通的最小主流程：`教学房 -> 实战房 -> 目标房`。第 3 段目标房固定采用“混合门控目标”，也就是玩家需要先承接前一段战斗压力，再利用已有能力通过门控并抵达出口或明确完成点。

本轮目标不是做完整关卡系统，而是验证 3 件事已经成立：房间切换不再只是阶段 6 的定向跳转，主流程已经具备至少一次连续推进，玩家能在一条短链路中同时经历“教学回顾、战斗承压、目标完成”。本轮继续不做大地图、存档、分支路线和正式 checkpoint 系统。

## Preflight

- 本轮固定采用 `分支 + worktree`。
- 分支名固定为 `codex/stage-7-short-mainline-chain`。
- worktree 固定放在 `.worktrees/stage-7-short-mainline-chain`。
- 开始实现前必须先补齐：
  - `spec-design/2026-04-23-stage-7-short-mainline-chain-design.md`
  - `docs/implementation-plans/2026-04-23-stage-7-short-mainline-chain.md`
  - `docs/progress/status.md`
  - `docs/progress/timeline.md`
  - `docs/progress/logs/2026-04-23.md`
- preflight 文档里必须显式写明：
  - 本轮只做“三段顺序链路”
  - `GoalTrialRoom` 是混合门控目标房
  - 本轮不做大地图、存档、正式 checkpoint、多分支路线
  - 本轮的代理协作是“满足条件即必须启用”，不是软建议
- preflight 完成后才进入玩法实现；preflight 阶段改动应只包含设计、计划和进度启动记录。

## Key Changes

### 主流程结构与房间职责

- 主流程固定为 3 段：
  - `TutorialRoom`：继续承担已完成的基础教学与能力回顾
  - `CombatTrialRoom`：继续承担首次真实战斗压力
  - 新增 `GoalTrialRoom`：承担 stage7 的混合门控目标完成
- `Main` 从“支持单次定向切房”提升为“支持固定顺序三段流转”的最小主流程控制器，但仍不扩展成通用房间图系统。
- `GoalTrialRoom` 的完成条件固定为：
  - 玩家必须进入房间后处理一次明显的空间门控
  - 门控必须依赖现有能力组合，不新增新能力
  - 达成后触发明确完成反馈，作为阶段 7 退出点
- 推荐的默认实现是：`CombatTrialRoom` 完成后进入 `GoalTrialRoom`，在目标房中用 `dash + jump + attack` 的既有组合完成一次带门控的短推进。

### 房间契约与运行时接口

- 保持当前房间契约继续由 `Main` 消费，不回退到硬编码房间名。
- 在现有最小契约基础上统一为：
  - `room_transition_requested(room_id_or_path, spawn_id)`
  - `get_spawn_position(spawn_id) -> Vector2`
  - `get_camera_limits() -> Rect2i`
  - `should_reset_on_player_defeat() -> bool`
- `CombatTrialRoom` 和 `GoalTrialRoom` 都应使用同一套“房间请求切换 / 提供出生点 / 提供 HUD 文案”的思路，避免 `Main` 为每个房间写特殊逻辑。
- `Main` 的职责固定为：
  - 当前房间实例化与切换
  - 玩家生成与重置
  - HUD 绑定
  - 不负责关卡内具体门控逻辑
- `GoalTrialRoom` 应新增最小完成信号或过渡请求，用来告诉 `Main` 当前短链路已经结束。

### 目标房玩法边界

- `GoalTrialRoom` 固定做“混合门控目标”，不做纯战斗房，也不做纯平台房。
- 推荐的最小玩法结构：
  - 入场后先识别一个关闭的出口或目标点
  - 通过一组现有能力门槛接近目标区域
  - 在接近过程中至少需要 1 次简单战斗或攻击型交互来解除阻挡
  - 最终到达目标点后结束短链路
- 允许复用阶段 6 的基础近战敌人，但不新增第二类敌人。
- 不引入新能力、不引入资源收集循环、不引入背包或钥匙系统；如需要“钥匙感”，应表现为即时触发的门控解除，而不是正式物品系统。

### HUD 与玩家反馈

- HUD 继续沿用现有最小形态，但提示逻辑要升级为真正的“主流程分段提示”：
  - 教学房提示
  - 实战房提示
  - 目标房提示
  - 最终完成提示
- 战斗面板继续真实反映：
  - 生命值
  - `dash` 状态
  - 当前房间上下文提示
- 如果本轮加入最小“完成反馈”，优先使用房间内提示、出口状态变化或 HUD 文案，不新增独立结算 UI。

### Subagent / Multi-Agent 强制规则

- 本轮不再把代理协作写成“推荐”，而是写成实现前硬约束。
- preflight 完成后，主代理必须先做任务拆分；若满足以下条件，则必须启用代理协作，不能默认回退主代理单线推进：
  - 存在 2 个以上子任务
  - 子任务写入范围可隔离
  - 子任务验证可独立
  - 下一步不强依赖单一阻塞结果
- 对 stage7，以下拆分一旦成立，就默认必须启用 `multi-agent`：
  - 代理 A：`Main` 与三段房间流转契约
  - 代理 B：`GoalTrialRoom` 与门控流程
  - 代理 C：HUD 分段提示、Stage 7 GUT、文档留痕
- 若实现时发现 A/B/C 中有两块会持续同时改同一核心文件，则降级为：
  - 至少 1 个 `subagent` 负责非阻塞侧任务
  - 主代理只保留阻塞主线整合
- 只有在以下例外条件成立时，才允许不启用 `multi-agent`：
  - 需求仍未收敛
  - 单点调试尚未定位
  - 写入范围无法隔离
- 若出现上述例外，必须在当日日志 `Delegation Log` 中写明：
  - 本次为何没有启用
  - 哪个条件不满足
  - 后续何时重新评估

## Public APIs / Interfaces

- `Main` 继续消费统一房间契约，不新增特判式房间分支。
- 房间侧需要稳定支持：
  - `room_transition_requested(...)`
  - `get_spawn_position(...)`
  - `get_camera_limits()`
  - `get_current_prompt_text()` 或等价 HUD 文案接口
- 新的 `GoalTrialRoom` 应暴露明确的“目标已完成”过渡接口，形式可为：
  - 直接发 `room_transition_requested(...)`
  - 或最小 `goal_completed` 信号，由 `Main` 转换成流程结束动作
- 不新增新的玩家核心能力接口；stage7 默认只复用 `move / jump / dash / attack / receive_damage / defeated` 这些现有能力。

## Test Plan

- 基线验证继续保留：
  - `godot --headless --path . --import`
  - Stage 1 GUT
  - Stage 2 GUT
  - Stage 3 GUT
  - Stage 4 GUT
  - Stage 5 GUT
  - Stage 6 GUT
  - `git diff --check`
- 新增 Stage 7 GUT，至少覆盖：
  - `Main` 能按预期从 `TutorialRoom -> CombatTrialRoom -> GoalTrialRoom` 顺序推进
  - `GoalTrialRoom` 满足主房间契约并提供独立出生点
  - `CombatTrialRoom` 完成后能稳定进入目标房
  - 目标房初始门控关闭，满足条件后解锁
  - 目标房完成后会触发明确的短链路完成状态
  - HUD 能随三段流程正确切换提示文本
  - 玩家若在战斗房死亡，仍只重置当前战斗房，而不会回滚整条链路
  - 既有 Stage 1-6 测试不回归
- 手动复核重点：
  - 玩家是否能感知“这已经不是单房间教学，而是一条短主流程”
  - 房间切换是否自然，不像硬跳关
  - 目标房是否真的同时体现“空间推进 + 最小压力”，而不是任一侧过弱

## Assumptions

- `stage7` 固定采用“三段顺序链路”，不压缩为两段，也不重做为全新主流程。
- 第 3 段固定为“混合门控目标房”，不是纯探索房，也不是纯战斗房。
- 本轮默认采用 `分支 + worktree`，且 preflight 必须先完成。
- 本轮继续不做：
  - 大地图
  - 存档
  - 正式 checkpoint 系统
  - 多分支路线
  - 第二类敌人
  - 新能力
- `subagent / multi-agent` 在 stage7 中是“满足条件即必须启用”的实现约束，不再只是建议；如果最终未启用，必须在 `Delegation Log` 中写明符合哪一条例外条件。
