# Nano Hunter Status

Last Updated: 2026-04-11

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 2：基础移动手感（已完成，待进入阶段 3）`

## Stage Goal

在现有阶段 1 骨架上完成“跑、停、跳、落地”的基础移动闭环，并把 `coyote time`、`jump buffer`、`可变跳高` 做到可看、可玩、可调，为阶段 3 的最小攻击循环接入做准备。

## Playable Now

- `godot --path .` 仍会进入 `Main.tscn`
- 主场景仍只生成 1 个玩家实例到 `Runtime`
- 阶段 2 的输入契约、状态契约和核心跑跳行为已通过自动化验证
- `project.godot` 已补齐 `move_left`、`move_right`、`jump` 的静态默认键位，编辑器侧和运行时共享同一套输入基线
- 测试房间新增了中段平台，可覆盖平地跑动、起跳、落地、跌落后补跳的验证路径
- 当前仍以占位玩家和简单几何平台为主，目标是先把移动手感做准

## Adjustable Now

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

## Exit Criteria

- 玩家可稳定完成平地起跑、收停、起跳、落地与平台间移动
- `idle -> run -> jump_rise -> jump_fall -> land` 状态切换清晰可读
- 高级手感至少包含 `coyote time`、`jump buffer`、`可变跳高`
- 阶段 1 与阶段 2 自动化测试保持绿色
- 当前结果足以承接阶段 3 的最小攻击循环接入

## Asset Status

- 当前仍以占位资产与简单几何可视化为主
- 阶段 2 不引入正式 HUD，也不展开房间系统重构
- 后续若需视觉强化，优先补能力识别与动作可读性

## Next Stage

`阶段 3：基础战斗手感`

## Current Goal

阶段 2 已完成收口，下一步转入阶段 3 的最小攻击循环设计与实现。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用其编辑器插件

## In Progress

- 维护阶段 2 已完成基线的文档留痕
- 为阶段 3 的最小攻击循环准备设计与接入点

## Recently Completed

- 建立 `codex/stage-2-movement-feel` 分支与 `.worktrees/stage-2-movement-feel`
- 收口阶段 2 玩家跑跳、状态切换和高级手感实现
- 为测试房间加入阶段 2 所需平台
- 新增阶段 2 自动化测试
- 通过编辑器侧复核定位输入配置缺口，并将默认键位静态写入 `project.godot`
- 为阶段 2 增补“静态默认输入事件”回归断言，确认输入契约不再只依赖运行时补齐
- 修复 `codex/stage-2-movement-feel` worktree 的 Git 索引损坏，恢复 `git status` 与 `git diff --check`
- 同步后续阶段分工：攻击阶段 3，冲刺阶段 4，HUD 与房间系统重构阶段 5
- 修正阶段 2 worktree 中的 Godot MCP 版本与项目级 autoload 兼容问题
- 在沙箱外重新确认 `godot --headless --path . --import`、阶段 1 GUT 与阶段 2 GUT 全部通过

## Risks And Blockers

- 桌面端 Godot MCP 连接已恢复，但当前 `simulate_key(KEY_SPACE)` 在运行态里仍未稳定复现跳跃；阶段 2 的跳跃结论继续以自动化验证和项目静态输入表为主
- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 警告
- 本轮恢复了部分项目级 autoload 以保证编辑器可解析，但不改变阶段 2 玩法范围
- `PlayerSpawn` 仍与 `TestRoom` 并列，阶段 2 本轮不处理场景归属重构

## Next Recommended Steps

1. 以当前阶段 2 基线为起点，开始阶段 3 的攻击循环设计和实现计划
2. 若后续仍依赖编辑器侧自动试玩，可继续跟进 `simulate_key(KEY_SPACE)` 的工具链噪声，但不把它当作阶段 2 玩法阻塞
3. 如准备提交，先整理当前 worktree 中已有的插件同步改动与阶段 2 改动边界
