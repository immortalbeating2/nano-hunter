# 阶段 4：最小能力差异（地面冲刺）最终计划记录

> 说明：本文档用于留存本会话中最终确认过的 `stage4` 计划版本。
> 原始执行用计划仍保留在 [2026-04-22-stage-4-minimal-ability-difference.md](/Users/peng8/Desktop/Project/Game/nano-hunter/docs/implementation-plans/2026-04-22-stage-4-minimal-ability-difference.md)。

## Summary

基于 `main` 的 `stage3` 稳定基线，`stage4` 固定采用“仅地面冲刺 + TestRoom 混合验证”的最小方案，验证同一个能力是否同时带来探索价值和战斗价值。
本轮目标不是做完整冲刺系统，而是证明“至少 1 组能力差异”已经具备实际玩法意义，并把 `stage3` 留下的“更强反馈如何服务能力差异”显式承接进来。

阶段型开发按修正后的 `AGENTS.md` 执行：先建 `codex/stage-4-minimal-ability-difference` 分支和对应 `.worktrees/` 现场，再在实现阶段主动评估并优先使用 `subagent / multi-agent` 处理可隔离子任务，而不是默认主代理单线推进。

## Key Changes

### 设计与前置

- 新建设计文档：`spec-design/2026-04-22-stage-4-minimal-ability-difference-design.md`
- 新建实现计划：`docs/implementation-plans/2026-04-22-stage-4-minimal-ability-difference.md`
- 新建开发现场：
  - 分支：`codex/stage-4-minimal-ability-difference`
  - 模式：`分支 + worktree`
- 先把 `docs/progress/status.md`、`docs/progress/timeline.md` 与当日日志切到 `阶段 4：最小能力差异`

### 能力与接口

- 在 `project.godot` 新增输入动作：`dash`
- 在 `scripts/player/player_placeholder.gd` 新增最小状态：`dash`
- 本轮能力边界固定为：
  - 只能在地面触发
  - 只能从 `idle` / `run` / `land` 进入
  - 不能在 `attack` 中触发
  - 不能在空中触发
  - 不带无敌帧
  - 不带攻击取消
  - 不引入姿态切换、元素系统或资源条
- 新增最小调参字段：
  - `dash_duration`
  - `dash_speed`
  - `dash_cooldown`
  - `dash_buffer_window` 或等价最小缓冲参数
- 继续沿用 `stage3` 既有攻击闭环与 `receive_attack(hit_direction, knockback_force)` 契约，不重做普通攻击系统

### 场景与玩法验证

- 继续只扩展 `scenes/rooms/test_room.tscn`，不新建教程区
- 在同一房间中加入两个最小验证点：
  - 探索门槛：不用冲刺难以稳定通过，用冲刺可稳定通过
  - 战斗门槛：冲刺能明显改善接敌节奏或出手位置
- 继续复用 `TrainingDummy`
  - 不引入敌人 AI
  - 不改受击接口
- 允许加入轻量级冲刺反馈：
  - 颜色变化、残影、轻微拉伸、速度线等
  - 这些反馈只用于表达“这是能力差异”
  - 不升级成完整演出系统

### 协作方式

- 本轮默认应主动评估代理协作，而不是先假设主代理单线推进
- 推荐拆成 3 个可隔离子任务：
  - 玩家冲刺状态与参数接入
  - TestRoom 门槛与最小可读性反馈布置
  - Stage 4 GUT 与文档留痕
- 若实现时这 3 块写入范围仍清楚可分离，应优先采用 `multi-agent`
- 若某一块先成为关键路径阻塞，则主代理先本地推进阻塞项，其余块交给 `subagent`
- 只要用了重要代理协作，当日日志必须补 `Delegation Log`

## Deferred Ownership

### 留在 Stage 4 本轮解决

- 地面冲刺本体
- 冲刺输入与状态切换
- 冲刺在探索中的最小价值验证
- 冲刺在战斗接敌中的最小价值验证
- “更强反馈如何服务能力差异”的第一轮落地判断
- 与 `stage3` 移动 / 攻击节奏的基础协调

### 明确留给 Stage 5

- 最小 HUD
- 教程区短流程串联
- 简单门控的正式流程化呈现
- 基础敌人或障碍放入教程区的串联验证
- 房间系统重构是否需要进入垂直切片的再评估

### 本轮继续后延，不默认归入 Stage 5

- 空中冲刺
- 无敌帧
- 攻击取消
- 连段
- 空中攻击
- 正式伤害数值系统
- 生命值 / 死亡 / 掉落系统
- 完整敌人 AI
- 姿态切换方案
- 元素系统方案

## Test Plan

- 基线验证：
  - `godot --headless --path . --import`
  - Stage 1 GUT
  - Stage 2 GUT
  - Stage 3 GUT
- 新增验证：
  - `tests/stage4/test_stage_4_minimal_ability_difference.gd`
  - `git diff --check`
- Stage 4 GUT 至少覆盖：
  - `dash` 动作存在且有默认键位
  - 玩家可从地面进入 `dash`
  - 玩家在空中不能触发冲刺
  - 玩家在 `attack` 中不能触发冲刺
  - 冲刺方向规则正确
  - 冲刺结束后恢复到正常状态
  - 探索门槛可通过冲刺稳定越过
  - 冲刺接敌后可在预期帧数内命中 `TrainingDummy`
- 手动 / 半手动复核：
  - 确认“没有冲刺”和“有冲刺”时，路线或接敌节奏存在清晰差异
  - 若内置桥仍不稳定，优先用 Godot MCP Pro CLI 做运行态检查

## Assumptions

- `stage4` 只验证一组能力差异，因此固定选择“地面冲刺”
- “最小能力差异”的判定标准固定为：
  - 玩家能在同一测试房间中明显感知到能力前后通过方式不同
  - 玩家能感知到接敌节奏不同
  - 差异不是纯视觉变化，也不是纯数值变化
- 若冲刺接入后暴露移动 / 攻击节奏冲突，优先回调已有移动与攻击参数，不提前扩展 HUD 或房间系统重构
- 合并条件沿用阶段型里程碑标准：
  - 范围实现完成
  - fresh 验证通过
  - 文档更新完成
  - 当前结果可作为新的稳定基线承接 `stage5`
