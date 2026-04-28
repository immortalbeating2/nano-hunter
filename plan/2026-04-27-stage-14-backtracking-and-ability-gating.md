# Stage14 回溯与能力门控成型正式开发计划

## Summary

Stage14 基于 Stage13 稳定基线，新增唯一核心探索能力 `Air Dash / 空中二段冲刺`，并用它建立第一条真正的类银河恶魔城回溯链路。

本阶段只做 1 个新能力、1 类能力门控、至少 3 个回溯收益点、1 条主线回环和 1 条可选回访支路；不做完整地图系统、任务日志、多能力并行或正式存档。

## Stage Boundary

- 前置基线：Stage13 第二小区域内容生产已完成并可从主线终点继续推进。
- 阶段入口：Stage13 终点房进入 Stage14 能力获得房。
- 阶段出口：玩家获得 Air Dash，打开能力门，回访旧区收益点，完成主线回环并抵达 Stage15 入口前置位置。
- 工作模式：固定永久工作树 + 阶段分支 `codex/stage-14-backtracking-ability-gating`。

## Goals

- 在 `PlayerPlaceholder` 中保留现有地面 dash，并新增空中一次性 dash 规则。
- 在 `Main` 中保存运行期 Air Dash 解锁状态，保证房间切换和重生后能力不丢失。
- 新增 Stage14 shrine、gate、hub、loop return 等灰盒房间。
- 至少改造 3 个旧区回溯收益点，让能力获得后有明确回访价值。
- HUD 显示 Air Dash 是否解锁、是否可用，以及回溯收益计数。
- 通过 GUT、Godot import、`git diff --check` 和 Godot MCP 运行态人工复核完成收口。

## Non-Goals

- 不做完整地图系统。
- 不做任务日志、正式存档、技能树、蓝量、耐力或多能力并行。
- 不把 Air Dash 替代现有地面 dash。
- 不把回溯链路扩展成完整开放世界结构。
- 不引入正式美术替换，只做可读灰盒和资产需求记录。

## Key Changes

- 新增 Stage14 文档三件套：
  - `spec-design/2026-04-27-stage-14-backtracking-and-ability-gating-design.md`
  - `docs/implementation-plans/2026-04-27-stage-14-backtracking-and-ability-gating.md`
  - `plan/2026-04-27-stage-14-backtracking-and-ability-gating.md`
- 玩家能力扩展：
  - `air_dash_unlocked`
  - 空中一次 dash 使用机会
  - 落地恢复空中 dash 使用机会
- 主流程状态：
  - `Main` 持有 Air Dash 解锁状态
  - 换房重生后重新注入玩家实例
- Stage14 内容：
  - 能力获得房
  - Air Dash 门控房
  - 回溯 hub
  - 主线回环房
  - 3 个旧区回溯收益点
  - 1 条可选回访支路
- HUD 与资产：
  - Air Dash 解锁 / 可用状态
  - Stage14 回溯收益计数
  - `docs/assets/asset-manifest.md` 追加能力图标、门控提示、收益点和占位视觉需求

## Public Interfaces

`PlayerPlaceholder` 新增：

- `set_air_dash_unlocked(is_unlocked: bool) -> void`
- `is_air_dash_unlocked() -> bool`
- `is_air_dash_available() -> bool`

`get_hud_status_snapshot()` 新增：

- `air_dash_unlocked`
- `air_dash_available`

`Main.get_demo_progress_snapshot()` 新增：

- `air_dash_unlocked`
- `stage14_backtrack_reward_count`

Stage14 房间沿用：

- `room_transition_requested`
- `checkpoint_requested`
- `get_hud_context() -> Dictionary`

## Content Scope

- `stage14_air_dash_shrine_room`：发放 Air Dash，给出能力获得反馈。
- `stage14_air_dash_gate_room`：验证未获得能力时阻挡、获得能力后可通过。
- `stage14_backtrack_hub_room`：组织回访旧区收益点和可选支路。
- `stage14_loop_return_room`：主线回环并承接 Stage15 入口。
- 旧区回溯收益点：至少 3 个可识别、可收集、可计数的收益点。

## Asset Scope

- 继续使用灰盒与占位资产优先。
- 需要在 `docs/assets/asset-manifest.md` 追加：
  - Air Dash 能力图标
  - Air Dash 门控提示
  - 回溯收益点视觉
  - Stage14 shrine / gate / loop return 占位视觉
- 不在本阶段要求正式美术替换。

## Implementation Plan

- Preflight：在桌面仓库确认 `main` clean，运行 Godot import、Stage1-13 全量 GUT 和 `git diff --check`。
- 修复永久工作树：从桌面仓库 `main` 创建或同步固定工作树，并 checkout 阶段分支。
- TDD：先写 Stage14 专项 GUT，覆盖 Air Dash、能力持久化、门控、收益点和主线回环。
- 能力实现：扩展 `PlayerPlaceholder`、HUD 快照和 `Main` 能力注入。
- 内容实现：新增 Stage14 房间脚本 / 场景，并局部改造旧区收益点。
- 收口实现：扩展灰盒主线 driver，覆盖 Stage13 终点到 Stage14 回环的完整链路。

## Test Plan

- Air Dash 未解锁时不可在空中触发。
- 获得能力后，空中可触发一次 dash，落地后恢复。
- 房间切换后 Air Dash 解锁状态仍保留。
- 能力门默认阻挡，获得 Air Dash 后可通过。
- 至少 3 个回溯收益点可识别、收集、计数。
- 灰盒主线可完成“获得能力 -> 回头开门 -> 进入新路线”。
- 回归命令：

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
git diff --check
```

## Manual Review / Runtime Review

- 必须用 Godot MCP 从 `Main.tscn` 复核 Stage13 终点进入 Stage14。
- 必须确认获得 Air Dash、打开能力门、收集至少 3 个回溯收益点、完成主线回环。
- 必须记录 HUD 可读性、checkpoint 恢复、能力门碰撞和出生点是否清楚。
- MCP 发现的问题必须转成代码修复；若属于可自动化回归的行为，必须补 GUT。

## Documentation Updates

- 更新 `docs/progress/status.md`。
- 更新 `docs/progress/timeline.md`。
- 更新当日日志 `docs/progress/logs/YYYY-MM-DD.md`。
- 更新 `docs/assets/asset-manifest.md`。
- 若实现改变 Stage14 设计边界，同步回写 `spec-design/`。

## Exit Criteria

- Air Dash 能力、门控、回溯收益点和主线回环实现完成。
- Stage14 专项 GUT、全量 GUT、Godot import 和 `git diff --check` 通过。
- Godot MCP 运行态人工复核完成并留痕。
- 进度文档、资产 manifest 和阶段收口记录已更新。
- 分支结果可以作为 Stage15 的稳定前置基线。

## Risks

- Air Dash 若过强，可能削弱现有跳跃和地面 dash 的关卡价值。
- 回溯收益点如果只做计数，可能缺少“值得回头”的体验。
- 旧区局部改造可能影响 Stage1-13 既有测试链路，需要全量 GUT 保护。
- MCP 复核如果被连接问题阻塞，必须记录原因并尽快恢复，不用自动化替代人工复核。

## Assumptions

- Stage14 唯一新增能力固定为 `Air Dash / 空中二段冲刺`。
- Air Dash 是探索能力，不引入资源消耗、技能树或正式成长系统。
- Stage14 仍以灰盒可读性为主，正式资产只进入 manifest。
- Stage14 完成后将作为 Stage15 战斗高潮的前置主线基线。
