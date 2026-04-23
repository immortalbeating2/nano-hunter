# Nano Hunter Status

Last Updated: 2026-04-23

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 6：最小真实战斗循环（设计与 preflight 中）`

## Stage Goal

在阶段 5 已完成的教程区垂直切片基线上，做出一个“教程后独立战斗房 + 1 个基础近战敌人 + 玩家生命 / 受击 / 本段即时重置”的最小真实战斗闭环，让玩家第一次真正承受战斗压力，而不只是完成教学目标。

## Playable Now

- `godot --path .` 当前会进入 `Main.tscn`，并默认加载 `TutorialRoom`
- 主场景会生成 1 个占位玩家到 `Runtime`
- 阶段 2 的移动、跳跃、落地与基础状态切换仍然可用
- 阶段 3 的地面普通攻击、固定命中范围与 `TrainingDummy` 仍然保留
- 阶段 4 的仅地面 `dash` 仍然保持可用，并带有最小可读性反馈
- `TestRoom` 仍保留为阶段 2 / 3 / 4 的回归与调参沙盒
- `TutorialRoom` 已接入“移动/跳跃 -> dash -> 攻击 -> 出口”的单场景线性教学流程
- 最小 HUD 已接入“提示区 + 战斗面板”，提示区默认显示首条移动 / 跳跃教学文案
- 战斗面板当前只做展示：固定生命框位与 `dash` 状态文本，不接正式扣血 / 死亡 / 恢复循环
- `BattlePanel` 的两行文本布局已稳定分离，不再出现重叠错绘

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
- 阶段 3 当前可调的攻击参数：
- `attack_startup_duration`
- `attack_active_duration`
- `attack_recovery_duration`
- `attack_hitbox_size`
- `attack_hitbox_offset`
- `attack_knockback_force`
- 阶段 4 当前可调的冲刺参数：
- `dash_duration`
- `dash_speed`
- `dash_cooldown`
- 阶段 5 当前可调项主要集中在：
- `TutorialRoom` 中各教学节点的位置
- 教学提示文案
- 出口门控的开启时机
- 最小 HUD 的版面与提示表达

## Exit Criteria

- `Main` 默认加载教程主房间，而不是继续硬编码 `TestRoom`
- 教程区能按“移动/跳跃 -> dash -> 攻击 -> 出口”顺序稳定推进
- 最小 HUD 已接入“提示区 + 战斗面板”，且战斗面板仅做展示
- 教程区门控采用低压模型，不引入正式死亡 / 恢复循环
- 阶段 1 / 2 / 3 / 4 / 5 自动化测试保持绿色
- 当前结果足以作为下一轮垂直切片扩展的稳定基线

当前状态：以上退出条件已满足。

## Asset Status

- 当前仍以占位资源与简易几何可视化为主
- 阶段 5 允许为教程区加入最小 HUD 外观、提示文本与轻量级氛围视觉
- 本轮目标是“看得懂、玩得下去、能调方向”，不是最终美术完成

## Next Stage

`阶段 6 当前已启动；后续目标为阶段 7：短链路主流程串联`

## Current Goal

当前 `codex/stage-6-minimal-real-combat-loop` worktree 已从稳定 `main` 启动，目标是在不混入 stage7/8 内容的前提下，先补齐阶段 6 的设计文档、实现计划与进度启动记录，再进入“独立战斗房 + 基础近战敌人 + 玩家受击 / 生命 / 重置”的正式实现。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 6：最小真实战斗循环` 已启动，当前处于 `设计与 preflight` 阶段
- 已确认本轮采用 `分支 + worktree`
- 已确认本轮优先评估 `multi-agent`
- 当前尚未进入玩法脚本和场景实现

## Recently Completed

- 阶段 4 的“最小能力差异”已完成并合并回 `main`
- 当前 `dash` 已同时具备输入契约、探索价值、战斗接敌价值与最小可读性反馈
- `main` 已成为阶段 5 的稳定起点
- 新建阶段 5 worktree，并补齐阶段 5 的设计文档、实现计划与进度页启动记录
- 阶段 5 教程区垂直切片已完整收口，自动化验证覆盖主入口迁移、教程顺序、`dash` 门槛、出口解锁与 HUD 战斗面板布局
- `codex/stage-5-tutorial-vertical-slice` 已本地合并回 `main`，主线 fresh 验证继续保持绿色
- 已确认阶段 5 完成后的默认路线为 `阶段 6 -> 阶段 7 -> 阶段 8`

## Risks And Blockers

- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 历史警告，但当前不作为阶段阻塞项
- 阶段 6 最容易失控的方向是：把 checkpoint、多敌人、远程敌人、复杂 AI 与多房间流程一起提前混入
- `Main` 本轮只应补最小房间过渡与当前房间重置，不应顺势扩成完整房间系统
- 当前 `AGENTS.md` 中仍有重复的“测试文件异常排查约定”段落；这不是阶段阻塞项，但后续整理规范时可收口

## Recommended Roadmap

- `阶段 6：最小真实战斗循环`
- 目标：在现有教程切片之后，加入第一次真实战斗压力，而不再只是教学目标
- 范围：1 个基础敌人或攻击性障碍、玩家受击 / 生命 / 死亡或重置的最小闭环、教程后短实战段
- `阶段 7：短链路主流程串联`
- 目标：把当前单房间教程推进为至少两段连续流程，而不只是一个教学房间
- 范围：短链路主流程、最小门控、房间切换或区域衔接、一次完整小目标达成
- `阶段 8：系统稳固与内容生产前准备`
- 目标：为后续持续扩内容打底，而不是继续堆临时逻辑
- 范围：HUD 第二轮、参数数据化、敌人 / 房间模板化、必要的工程与流程收口

## Next Recommended Steps

1. 先完成阶段 6 preflight，只保留设计文档、实现计划与进度启动记录改动。
2. 正式实现时优先验证“教程后独立战斗房 + 基础近战敌人 + 玩家受击 / 重置”是否成立。
3. 若写入范围可分离，按 `Main` / `CombatTrialRoom + 玩家 + 敌人` / `HUD + 测试 + 文档` 三块主动评估 `multi-agent`。
