# Nano Hunter Status

Last Updated: 2026-04-20

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 3：基础战斗手感（设计准备中）`

## Stage Goal

在阶段 2 稳定跑跳基线上，建立“玩家普通攻击 -> 命中 -> 木桩受击反馈”的最小攻击循环，并为后续敌人接入保留最小清晰契约。

## Playable Now

- `godot --path .` 仍会进入 `Main.tscn`
- 主场景仍只生成 1 个玩家实例到 `Runtime`
- 阶段 2 的输入契约、状态契约和核心跑跳行为已通过自动化验证
- `project.godot` 已补齐 `move_left`、`move_right`、`jump` 的静态默认键位，编辑器侧和运行时共享同一套输入基线
- 测试房间已有中段平台，可覆盖平地跑动、起跳、落地、跌落后补跳的验证路径
- 当前仍以占位玩家和简单几何平台为主；阶段 3 第一轮会继续沿用这一原型风格，只额外接入固定木桩目标

## Adjustable Now

- 阶段 2 现有移动参数：
  - `max_run_speed`
  - `ground_acceleration`
  - `ground_deceleration`
  - `air_acceleration`
  - `jump_velocity`
  - `jump_cut_ratio`
  - `rise_gravity`
  - `fall_gravity`
  - `max_fall_speed`
  - `coyote_time_window`
  - `jump_buffer_window`
  - `landing_state_duration`
- 阶段 3 计划新增的攻击参数：
  - `attack_startup_duration`
  - `attack_active_duration`
  - `attack_recovery_duration`
  - `attack_hitbox_size`
  - `attack_hitbox_offset`
  - `attack_knockback_force`

## Exit Criteria

- 玩家可稳定进行地面普通攻击并命中固定木桩
- `attack` 状态、命中反馈与木桩受击反馈清晰可读
- 阶段 1 与阶段 2 自动化测试保持绿色
- 阶段 3 的最小攻击循环测试通过
- 当前结果足以承接后续敌人或能力差异接入

## Asset Status

- 当前仍以占位资产与简单几何可视化为主
- 阶段 3 第一轮继续使用占位攻击可视化与木桩反馈，不引入正式 HUD
- 后续若需视觉强化，优先补攻击与受击可读性

## Next Stage

`阶段 4：最小能力差异`

## Current Goal

当前 worktree 已从收口后的 `main` 建立，接下来按“攻击 + 木桩目标”的范围完成阶段 3 的设计、计划、实现与验证。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用其编辑器插件

## In Progress

- 维护主线 MCP 插件更新与本地配置隔离的留痕
- 以新的默认开发节奏作为后续阶段推进基线
- 启动阶段 3 的设计稿、实现计划与测试准备

## Recently Completed

- 将“默认开发节奏”正式写回 `AGENTS.md`、设计稿、实现计划与主线进度文档
- 收口阶段 2 玩家跑跳、状态切换和高级手感实现，并合并回 `main`
- 同步后续阶段分工：攻击阶段 3，冲刺阶段 4，HUD 与房间系统重构阶段 5
- 将本轮 MCP 扩展改动确认为“插件正常更新”处理，而不是额外实验功能
- 从收口后的 `main` 建立 `codex/stage-3-combat-feel` 与对应 `.worktrees/stage-3-combat-feel`
- 启动阶段 3 的设计文档与实现计划，锁定第一轮为“攻击 + 木桩目标”

## Risks And Blockers

- 当前阶段 3 还没有任何战斗实现，本轮必须先保持接口简单，不要把敌人 AI 或数值系统提前混入
- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 警告
- `PlayerSpawn` 仍与 `TestRoom` 并列，本轮不处理场景归属重构
- 如果后续 session 不按 `AGENTS.md -> status.md -> 当日日志 -> 相关 spec` 的顺序接续，仍可能重新出现流程漂移

## Next Recommended Steps

1. 在当前 worktree 中实现 `attack` 输入、玩家攻击状态与最小命中范围
2. 为 `TestRoom` 接入固定木桩目标，并补齐阶段 3 GUT 测试
3. 若后续仍依赖编辑器侧自动试玩，可继续跟进 `simulate_key(KEY_SPACE)` 的工具链噪声，但不把它当作阶段 3 阶段目标阻塞
