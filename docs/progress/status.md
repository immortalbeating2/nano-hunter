# Nano Hunter Status

Last Updated: 2026-04-21

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 3：基础战斗手感（已完成，待进入阶段 4）`

## Stage Goal

在阶段 2 稳定跑跳基线上，建立“玩家普通攻击 -> 命中 -> 木桩受击反馈”的最小攻击循环，并为后续敌人接入保留最小清晰契约。

## Playable Now

- `godot --path .` 仍会进入 `Main.tscn`
- 主场景仍只生成 1 个玩家实例到 `Runtime`
- 阶段 2 的输入契约、状态契约和核心跑跳行为已通过自动化验证
- `project.godot` 已补齐 `move_left`、`move_right`、`jump`、`attack` 的静态默认键位，编辑器侧和运行时共享同一套输入基线
- 测试房间已有中段平台，可覆盖平地跑动、起跳、落地、跌落后补跳的验证路径
- 当前仍以占位玩家和简单几何平台为主；阶段 3 第一轮继续沿用这一原型风格，并已接入固定木桩目标
- 占位玩家已具备地面普通攻击、前方固定命中范围、单次攻击单次命中与基础恢复逻辑
- `TestRoom` 已接入 `TrainingDummy`，可观察木桩受击闪白与轻微位移反馈

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
- 阶段 3 可加入轻量级打击感反馈参数，但仅用于保证命中可读性；若反馈开始承担能力差异或更强节奏表达，应在阶段 4 单独评估并留痕

## Exit Criteria

- 玩家可稳定进行地面普通攻击并命中固定木桩
- `attack` 状态、命中反馈与木桩受击反馈清晰可读
- 阶段 1 与阶段 2 自动化测试保持绿色
- 阶段 3 的最小攻击循环测试通过
- 当前结果足以承接后续敌人或能力差异接入

## Asset Status

- 当前仍以占位资产与简单几何可视化为主
- 阶段 3 第一轮继续使用占位攻击可视化与木桩反馈，不引入正式 HUD
- 木桩反馈已加强为“闪白 + 位移 + 轻微缩放”的轻量级组合，用于提高命中可读性
- 后续若需视觉强化，优先补攻击与受击可读性

## Next Stage

`阶段 4：最小能力差异`

## Current Goal

`main` 将承载阶段 3 的稳定基线；下一步优先补阶段 4“最小能力差异”的设计确认、实现计划与新的分支 / worktree 入口。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用其编辑器插件

## In Progress

- 维护阶段 3 已完成基线的主线留痕
- 以新的默认开发节奏作为后续阶段推进基线
- 为阶段 4 的设计确认、实现计划与隔离开发现场做准备

## Recently Completed

- 将“默认开发节奏”正式写回 `AGENTS.md`、设计稿、实现计划与主线进度文档
- 收口阶段 2 玩家跑跳、状态切换和高级手感实现，并合并回 `main`
- 同步后续阶段分工：攻击阶段 3，冲刺阶段 4，HUD 与房间系统重构阶段 5
- 将本轮 MCP 扩展改动确认为“插件正常更新”处理，而不是额外实验功能
- 从收口后的 `main` 建立 `codex/stage-3-combat-feel` 与对应 `.worktrees/stage-3-combat-feel`
- 启动阶段 3 的设计文档与实现计划，锁定第一轮为“攻击 + 木桩目标”
- 补充阶段 3 与阶段 4 之间的“打击感反馈分层约定”，避免后续遗漏更强反馈方向
- 实现 `attack` 输入、玩家攻击状态、前方命中查询与单次攻击单次命中
- 新增 `TrainingDummy` 场景与脚本，并将其接入 `TestRoom`
- 新增阶段 3 GUT 测试，并确认阶段 1 / 2 / 3 测试全部通过
- 重新以 fresh 验证确认 `godot --headless --path . --import`、阶段 1 GUT、阶段 2 GUT、阶段 3 GUT 与 `git diff --check` 全部通过
- 将阶段 3 判定为可合并的稳定里程碑，并准备合并回 `main`

## Risks And Blockers

- `godot --headless --path . --import` 退出时仍会输出 `ObjectDB instances leaked at exit` 警告
- `PlayerSpawn` 仍与 `TestRoom` 并列，本轮不处理场景归属重构
- 当前木桩反馈已有闪白、位移和轻微缩放，但尚未引入更强的停顿、镜头或能力差异表达；这部分留到阶段 4 结合能力差异再评估
- 当前桌面线程内置 `mcp__godot_mcp_pro__` 连接仍不稳定；后续若要做帧级 GUI 复核，仍优先使用 Godot MCP Pro CLI 或新的桌面会话重建桥接
- 如果后续 session 不按 `AGENTS.md -> status.md -> 当日日志 -> 相关 spec` 的顺序接续，仍可能重新出现流程漂移

## Next Recommended Steps

1. 以当前 `main` 为新稳定基线，启动阶段 4“最小能力差异”的 brainstorming、设计文档与实现计划
2. 新建阶段 4 分支与 worktree，并把“更强反馈如何服务能力差异”作为设计确认的显式问题之一
3. 若阶段 4 接入能力差异后发现当前攻击与移动节奏不匹配，优先回调现有移动 / 攻击参数，不提前扩展 HUD 或房间系统重构
4. 若后续仍依赖编辑器侧自动试玩，可继续跟进 `simulate_key(KEY_SPACE)` 与桌面线程桥接噪声，但不把它当作阶段 4 设计启动阻塞
## 2026-04-21 Supplemental Update

- `project.godot` 已去掉历史遗留的 `BetterTerrain` autoload，并把 `DialogueManager`、`ControllerIcons` 改回稳定的 `res://...` 路径引用。
- 修复原因：
  - 清理当前 worktree 的 `.godot` 缓存后，旧的 `uid://...` autoload 引用会触发 `Unrecognized UID`
  - 同时会重新暴露 `better-terrain` 的历史解析错误
- 当前验证状态更新为：
  - `godot --headless --path . --import` 通过
  - Stage 1 GUT 10/10 通过
  - Stage 2 GUT 7/7 通过
  - Stage 3 GUT 仍单独触发 Godot signal 11 崩溃，暂未恢复
  - `git diff --check` 通过
- 当前阶段结论不变：
  - Stage 3 的最小攻击闭环实现仍在
  - 木桩反馈增强仍保留
  - 但 Stage 3 自动化回归目前处于“实现在、测试入口异常”的阻塞状态
- 当前对 Stage 3 测试异常的最新判断：
  - 更像是“新建的 GUT 测试脚本资源会触发崩溃”
  - 而不是 GUT 整体不可用，或 Stage 3 某一条测试断言单独写坏
## 2026-04-21 Additional Narrowing

- 最新对照表明：
  - `test_stage_3_combat_feel.gd` 可被健康测试安全 `load()`
  - 可安全反射方法列表与常量表
  - 可实例化、挂树，并手动调用单条 Stage 3 测试方法
- 因此当前更准确的判断是：
  - 不是 Godot 单纯无法加载 Stage 3 测试脚本
  - 不是 Stage 3 测试方法一运行就必崩
  - 更像是 “GUT 将 Stage 3 脚本作为独立测试入口运行” 时触发的崩溃
- 当前自动化状态保持为：
  - Stage 1 GUT 通过
  - Stage 2 GUT 通过
  - Stage 3 直接入口仍触发 Godot `signal 11`
## 2026-04-21 Additional Narrowing 2

- 最新入口级探针表明：
  - Stage 1 / Stage 2 的 `-gtest` 目标可正常进入 `gut_cmdln` 入口并完成运行
  - Stage 3 目标、缺失脚本目标、非测试脚本目标都会在 `gut_cmdln.gd` `_init()` 之前触发 Godot `signal 11`
- 因此当前更准确的判断是：
  - 崩点已经前移到 GUT 正常入口之前
  - Stage 3 现象与“无效目标路径”更相似
  - 继续深挖时应优先把问题当作“目标路径启动链异常”，而不是“Stage 3 测试函数局部逻辑错误”
## 2026-04-21 Stage 3 Recovery Note

- Stage 3 自动化验证目前已恢复，但恢复方式是“稳定入口桥接”，不是独立 Stage 3 入口已修复。
- 当前稳定验证方式：
  - `tests/stage3/test_stage_3_combat_feel.gd` 继续作为 Stage 3 的真实测试定义
  - `tests/stage2/test_stage_2_movement_feel.gd` 中新增临时 `test_stage_3_bridge_*` 包装测试，逐条代理执行 Stage 3 真实测试方法
  - `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit` 当前为 `12/12 passed`
- 当前仍未解决的问题：
  - `res://tests/stage3/test_stage_3_combat_feel.gd` 作为独立 `-gtest` 目标时，Godot 仍会在更早阶段触发 `signal 11`
- 当前配置一致性状态：
  - `project.godot` 中残留的 `BetterTerrain` autoload 已真正移除
- 用户补充的 Windows 崩溃弹窗确认这是 Godot Win64 原生访问冲突，表现为读取空指针附近 `0x58` 地址。
- 最新干净复现表明：Stage 3 独立 `-gtest` 目标可以跑完整个 GUT 链并走到 `GutRunner.quit`，但进程仍会在原生退出阶段触发 `signal 11`。
- 只运行 Stage 3 里最简单的 `attack` 输入契约单测也会出现同样的原生退出崩溃，因此当前问题不依赖木桩命中或复杂物理过程。
- 当前最稳妥的结论仍是：Stage 3 现在“能通过”依赖 Stage 2 bridge；独立 Stage 3 suite 的原生退出崩溃尚未根治。
- Stage 3 独立 GUT 入口现已恢复：`tests/stage3/test_stage_3_combat_feel.gd` 当前可直接独立运行并通过 `5/5`。
- 本轮定位结论更新为：问题更像是 `tests/stage3/test_stage_3_combat_feel.gd` 先前存在文本/编码层面的异常状态，而不是 Stage 3 测试逻辑本身错误。该结论来自“同路径最小版通过、同路径完整重写后也通过”的对照结果。
- 临时 bridge 已从 `tests/stage2/test_stage_2_movement_feel.gd` 移除，Stage 2 测试恢复为原生 `7/7`，Stage 3 回到独立 suite 验证。
