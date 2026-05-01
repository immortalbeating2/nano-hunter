# Stage16 Alpha Demo 打包候选正式开发计划

## Summary

Stage16 基于已合并的 Stage15 `main`，目标是把 Stage12-15 形成的系统、内容、资产管线和验证方式收束成第二版更完整的 `Alpha Demo` 候选。

本阶段采用 `Alpha Demo 打包候选 + 中等内容扩张`：新增 `5` 个终局封印链房间，补齐主菜单、暂停、重开、完成反馈、最小音频、第二轮关键视觉需求、Demo 级 QA checklist、灰盒主线自动化和 Alpha Demo release notes。

本阶段继续使用固定永久工作树与阶段分支 `codex/stage-16-alpha-demo-candidate`，采用 subagent / multiagent 分工。自动化通过不等于阶段完成，Godot MCP 运行态人工复核与 release notes 是阶段收口硬门槛。

## Stage Boundary / Preflight

- 前置基线：Stage15 已完成并合并回 `main`，包含 `Seal Guardian / 封印守卫`、`Recovery Charge / 恢复充能`、Stage15 战斗高潮链路、挑战支线全清门控、失败重试和完成房反馈。
- 阶段入口：Stage15 `stage15_completion_room` 完成后进入 Stage16 终局封印链。
- 阶段出口：玩家进入 `stage16_alpha_demo_end_room`，并在 `Main.get_demo_progress_snapshot()` 中标记 `stage16_alpha_demo_completed=true`。
- 工作模式：固定永久工作树 + 阶段分支 + subagent / multiagent 分工。
- Preflight：
  - 确认当前工作树位于 `codex/stage-16-alpha-demo-candidate`。
  - 确认 `main` 的 Stage15 稳定验证记录仍作为前置基线。
  - 进入实现前运行 Godot import 和当前全量 GUT，或记录若因环境原因无法立即运行。

## Goals

- 新增 `5` 个终局封印链房间，承接 Stage15 completion room。
- 补齐最小主菜单、暂停、继续、重开和 Alpha Demo 完成反馈。
- 扩展 `Main.get_demo_progress_snapshot()`，表达 Stage16 完成态、QA checklist 状态和 release notes 状态。
- 升级 HUD 完成态显示，避免完成房继续显示旧 Boss 目标或旧收集行。
- 升级灰盒主线自动化，覆盖主线、失败重试、Stage14 回溯链、Stage15 Boss 和 Stage16 终点。
- 记录第二轮关键视觉与最小音频需求。
- 建立 Demo 级 QA checklist 与 Alpha Demo release notes，目标路径为 `docs/deliverables/stage16-alpha-demo-candidate/qa-checklist.md` 与 `docs/deliverables/stage16-alpha-demo-candidate/release-notes.md`。
- 完成 Godot MCP 运行态人工复核。

## Non-Goals

- 不追求完整商业版内容量。
- 不新增第三个大区域。
- 不新增核心能力、敌人类别或第二个 Boss。
- 不做正式存档、成就、设置页、键位配置或多槽位菜单。
- 不做完整剧情系统、过场动画或对白系统。
- 不把 `SealGuardianBoss` 扩展为正式 Boss 框架。
- 不把灰盒 driver 扩展为通用自动寻路或通用关卡求解器。

## Key Changes

- 新增 Stage16 文档三件套：
  - `spec-design/2026-04-29-stage-16-alpha-demo-candidate-design.md`
  - `docs/implementation-plans/2026-04-29-stage-16-alpha-demo-candidate.md`
  - `plan/2026-04-29-stage-16-alpha-demo-candidate.md`
- 从 Stage15 completion room 接入 Stage16 终局封印链：
  - `stage16_seal_release_threshold_room`
  - `stage16_talisman_relay_room`
  - `stage16_backtrack_confirmation_room`
  - `stage16_corruption_purge_room`
  - `stage16_alpha_demo_end_room`
- 新增 Alpha Demo 最小壳：
  - 主菜单开始入口
  - 暂停 / 继续
  - 重开
  - 完成反馈
- 更新资产和音频需求：
  - 封印裂开与符印链条
  - 符印连锁 VFX
  - 妖瘴净化 VFX
  - Alpha Demo 完成 UI
  - 最小 SFX / BGM
- 新增 `docs/deliverables/stage16-alpha-demo-candidate/qa-checklist.md` 与 `docs/deliverables/stage16-alpha-demo-candidate/release-notes.md`。

## Public Interfaces

`Main.get_demo_progress_snapshot()` 新增：

- `stage16_alpha_demo_completed`
- `stage16_release_notes_ready`
- `stage16_qa_checklist_ready`

`restart_demo()`：

- 继续作为 Demo 壳和完成房的重开入口。
- Stage16 实现时必须明确完整重开会清理 Stage14 / Stage15 / Stage16 运行期进度，避免重玩污染验证。

Stage16 房间沿用：

- `room_transition_requested(target_room_path: String, spawn_id: StringName)`
- `checkpoint_requested(room_path: String, spawn_id: StringName)`
- `goal_completed`
- `bind_player(player)`
- `bind_main(main)`
- `get_hud_context() -> Dictionary`

Demo 壳沿用：

- 调用 `restart_demo()`
- 读取 `get_demo_progress_snapshot()`
- 暂停状态自持，不写入正式存档或全局设置。

## Content Scope

新增 `5` 个终局封印链房间：

- `stage16_seal_release_threshold_room`：封印裂开入口，承接 Stage15 completion room。
- `stage16_talisman_relay_room`：符印连锁与 Air Dash 再确认房。
- `stage16_backtrack_confirmation_room`：回溯收益、Boss 击败和 Demo 完成条件确认房。
- `stage16_corruption_purge_room`：妖瘴净化房，回收 Stage13 废液 / 酸液灰盒语境。
- `stage16_alpha_demo_end_room`：Alpha Demo 最终完成房。

本阶段不新增敌人类别。若需要压力，复用既有敌人或危险，表现包装为封印失衡、妖瘴残留或符印机关故障。

## Asset Scope

`docs/assets/asset-manifest.md` 追加 Stage16 需求：

- `stage16_seal_release_props`
- `stage16_talisman_relay_vfx`
- `stage16_corruption_purge_vfx`
- `stage16_alpha_demo_completion_ui`
- `stage16_demo_sfx_pack`
- `stage16_demo_music_loop`

Stage16 不要求所有条目都成为正式美术，只要求路径、用途、授权状态、当前状态和替换优先级可追溯。

## Subagent / Multiagent Execution Model

Stage16 默认启用 `4` 个核心 subagent，由主协调者负责最终整合：

- `design`：阶段边界、终局封印链体验、Goals / Non-Goals、正式阶段计划结构。
- `architecture`：Main / HUD / 房间契约、Demo 壳接口、暂停与重开边界、灰盒 driver 扩展点。
- `content`：Stage16 房间职责、房间顺序、回溯验证点、资产与音频范围。
- `qa`：Stage16 GUT、灰盒主线自动化升级、QA checklist、MCP 运行态复核清单。

按需追加：

- `asset_direction`：第二轮视觉和音频命名、资产清单、替换优先级与授权记录。
- `godot_runtime`：Godot MCP preflight、运行态人工复核、autoload 清理确认。
- `production`：进度文档、分支 / worktree 留痕、release notes 和阶段收口。

执行约束：

- 子代理不得继续派生子代理。
- 不让多个代理同时修改同一核心脚本。
- 主协调者负责接口整合、最终验证和对用户交付。

## Implementation Plan

- 第一批并行：`design`、`architecture`、`content`、`qa` 做阶段边界、接口、房间链路和测试策略确认。
- 第二批并行：`architecture` 与 `qa` 建立 Main / HUD / driver 红测，`content` 建立 Stage16 房间链路。
- 第三批：主协调者整合 Demo 壳、HUD 完成态、Main 快照和房间链路。
- 第四批：`qa` 与 `godot_runtime` 做自动化 + MCP 运行态复核，`production` 做 release notes 与进度文档收口。

推荐实现顺序：

1. 写 Stage16 专项 GUT 红测。
2. 新增 Stage16 灰盒 driver。
3. 扩展 Main 快照和重开语义。
4. 实现最小 Demo 壳。
5. 新增 Stage16 房间并接入 Stage15 completion room。
6. 更新 HUD 完成态规则。
7. 更新资产 manifest、QA checklist 和 release notes。
8. 跑自动化与 Godot MCP 运行态人工复核。

## Test Plan

- Stage16 房间资源存在，并从 Stage15 completion room 进入。
- Alpha Demo 终点能标记 `stage16_alpha_demo_completed=true`。
- `Main.get_demo_progress_snapshot()` 含 Stage16 完成态、release notes 状态和 QA checklist 状态。
- `restart_demo()` 能回到 demo 起点并清理 Stage14 / Stage15 / Stage16 运行期状态。
- 主菜单、暂停、继续、重开最小契约成立。
- HUD 在完成房显示 Alpha Demo 完成反馈，不显示旧 Boss 目标、旧收集行或战斗中恢复充能。
- 灰盒 driver 能从 `Main.tscn` 驱动到 Stage16 终点。
- `docs/assets/asset-manifest.md`、QA checklist 和 release notes 包含 Stage16 必要条目。
- 回归命令：

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
git diff --check
```

## Manual Review / Runtime Review

- 必须从固定工作树启动开发会话并确认 Godot MCP 工具可用。
- 必须运行 `.\scripts\dev\enter-worktree-godot-mcp.ps1` 并记录连接状态。
- 必须用 MCP 从 `Main.tscn` 复核：
  - 主菜单开始入口
  - 暂停 / 继续 / 重开
  - Stage14 Air Dash 与回溯收益
  - Stage15 Boss 房、失败重试与 Boss 击败
  - Stage15 completion room 到 Stage16 入口
  - Stage16 终局封印链 5 个房间
  - Alpha Demo 终点完成反馈
  - HUD 可读性与最小音频触发
- MCP 发现的问题必须修复；可自动化的行为必须至少补 1 条回归测试。
- MCP 截图等一次性证据默认放在 `tests/artifacts/local/stage16-mcp/`，不放入 `docs/progress/`。
- MCP 动态注入到 `project.godot` 的 autoload diff 必须在复核结束后清理。

## Documentation Updates

- 更新 `docs/progress/status.md`。
- 更新 `docs/progress/timeline.md`。
- 更新当日日志 `docs/progress/logs/YYYY-MM-DD.md`。
- 更新 `docs/assets/asset-manifest.md`。
- 新增 Demo 级 QA checklist。
- 新增 Alpha Demo release notes。
- 若 Stage16 房间链路、Demo 壳或 QA 范围实现偏离设计，回写 `spec-design/` 与 `docs/implementation-plans/`。

## Exit Criteria

- Stage16 终局封印链、Demo 壳、Main 快照、HUD 完成态、灰盒 driver、QA checklist 和 release notes 实现完成。
- Stage16 专项 GUT、Stage15 专项 GUT、全量 GUT、Godot import 和 `git diff --check` 通过。
- Godot MCP 运行态人工复核完成，且 MCP 发现问题已修复并有回归测试保护。
- `project.godot` 无 MCP autoload 残留 diff。
- 进度文档、资产 manifest、QA checklist 和 release notes 已更新。
- 分支结果可作为 Alpha Demo 候选稳定基线提交、合并和后续远端同步。

## Risks

- Stage16 同时包含内容扩张和打包收束，若继续新增房间，可能稀释 QA 与 release notes 收口。
- Demo 壳若过度扩展，可能提前滑向正式菜单 / 设置 / 存档系统。
- `restart_demo()` 的清理边界若不明确，可能导致 Stage14 / Stage15 运行期状态污染重玩。
- HUD 继续按路径判断阶段状态会逐渐膨胀，Stage16 只允许小步追加，不在本阶段重构完整 UI 状态机。
- MCP 连接状态和脚本判定可能不一致，必须按项目 MCP 指南分层判断。

## Assumptions

- Stage16 新增内容固定为中等扩张，默认 `5` 个终局封印链房间。
- 新增内容焦点是 Boss 后终局封印链，不是第三个大区域。
- Stage16 不新增敌人类别、核心能力、正式存档、正式设置页或完整剧情系统。
- Stage13 既有现代实验室 / 废液语境已通过北极星回收修正迁移到瘴泽妖域；Stage16 文案、HUD、资产备注和 release notes 继续使用封妖禁地、妖瘴、封印渗漏和符印机关语境。
- 主代理负责最终整合；subagent 只在指定职责内工作。
