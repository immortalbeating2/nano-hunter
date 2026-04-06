# Nano Hunter Timeline

## 2026-03-31

- 初始化 `nano-hunter` 的 Godot 4.6 工程，并建立基础仓库结构。
- 将本地仓库纳入 Git 跟踪，创建首次提交 `68d07cf` `Initial project setup`，并推送到 `origin/main`。
- 编写并提交设计规范 `spec-design/2026-03-31-nano-hunter-agents-design.md`，提交 `e05611e`。
- 追加仓库卫生规则，忽略本地 `.worktrees/` 目录，提交 `e83ed51`。
- 编写并提交 `docs/superpowers/plans/2026-03-31-agents-foundation.md`，提交 `20f8dc3`。
- 在 worktree `codex/agents-foundation` 中调查 Godot 基线崩溃，确认 `better-terrain` 在当前阶段激活时会触发兼容性和解析问题。
- 关闭 `better-terrain` 的当前阶段激活，仅保留 `godot_mcp` 与 `gut` 作为默认可用插件，提交 `5cfc113`。
- 在当前 worktree 中开始建立项目级进度留痕体系，落地 `docs/progress/` 的状态、时间线和日记录文档。
- 在当前 worktree 中创建项目专属 `AGENTS.md`，并补齐 `docs/progress/` 的状态、时间线和日记录文档；相关治理基线随后提交到 `acb12ef` 与 `733819e`。
- 在 `spec-design/2026-03-31-nano-hunter-agents-design.md` 中补充文档定位说明，明确设计稿负责记录治理依据，`AGENTS.md` 负责承载当前执行规范。
- 在 `AGENTS.md` 中补充项目内代码的注释约定，明确中文注释、关键玩法流程的引导性注释以及低信息量注释的限制。
- 在 `AGENTS.md` 与设计稿中补充 `subagent` / `multi-agent` 使用原则，并明确重要委派需写入当日日志的 `Delegation Log`。
- 在 `AGENTS.md` 与设计稿中补充交互语言约定，明确面向用户与项目文档默认使用中文，系统固定 UI 允许保留原文。
- 在 `AGENTS.md`、设计稿与 `status.md` 中补充 5 个可试玩检查点、阶段记录字段与原型期资产策略，明确每阶段都必须可看、可玩、可调。
- 编写并保存 `阶段 1：可启动骨架` 的实现计划 `docs/superpowers/plans/2026-03-31-stage-1-startup-skeleton.md`，为 `Main.tscn`、测试房间与占位玩家的落地做任务拆分。
- 在执行 `阶段 1` Task 1 时发现，受限运行环境会阻止 Godot 写入 `AppData/Godot`，从而导致 `GUT` CLI 触发崩溃弹窗；提权后确认 `GUT` 当前 `5/5 passed`，`godot --headless --path . --import` 通过但仍保留 `ObjectDB instances leaked at exit` 警告。
- 完成 `阶段 1` Task 1：新增 `run/main_scene`、`scenes/main/main.tscn` 与启动入口测试，提交 `6e77ab8`。
- 完成 `阶段 1` Task 2：新增 `scripts/main/main.gd`、`player_placeholder` 场景与结构测试，提交 `939f251`；随后根据 review 修正占位玩家可见性与出生时序，提交 `719fc92`。
- 完成 `阶段 1` Task 3：新增 `scenes/rooms/test_room.tscn` 并在 `Main.tscn` 中实例化测试房间，提交 `49d69e4`；随后补强房间碰撞与实例化测试契约，提交 `6770ba5`。
- 当前 worktree 版本已经可以直接启动进入 `Main.tscn`，形成第一个可启动、可看、可调的试玩检查点；已将后续 `PlayerSpawn` 与 `TestRoom` 归属问题记为阶段 2 注意项。

## 2026-04-01

- 根据当前试玩反馈，启动阶段 1 画面与相机调优，目标是把固定分辨率、整数倍缩放、保比例留边和房间边界相机限制一次收口。
- 编写并提交阶段 1 画面与相机调优设计 `spec-design/2026-04-01-stage-1-display-and-camera-tuning-design.md`，提交 `3a5f4da`。
- 编写并提交 `阶段 1` 画面与相机调优计划 `docs/superpowers/plans/2026-04-01-stage-1-display-and-camera-tuning.md`，提交 `d7418d2`。
- 完成 `阶段 1` Task 1：实现显示设置与基础启动收口，提交 `6597c44`，并在 review 后以 `1c832ab` 完成修复收口。
- 完成 `阶段 1` Task 2：实现测试房间边界相机限制与房间构图调优，提交 `9213814`，并在 review 后以 `ccd6ad7` 完成修复收口。
- 当前阶段 1 已具备固定分辨率、留边策略和房间边界相机限制，试玩时不再露出默认灰色空区。
- 为保证 `--import` 校验后工作树仍保持干净，补跟踪 `scripts/rooms/test_room.gd.uid`，并将 `project.godot` 调整为 Godot 规范化写回形式。
- 在 `main` 上先单独提交一组既有的 `godot_mcp` 与项目入口调整，提交 `00721fe`，避免后续合并时把在途改动和阶段成果混在一起。
- 将 `codex/agents-foundation` 合并回 `main`，提交 `6e11ff6`，让阶段 1 原型、治理基线和进度文档正式进入主线。
- 合并完成后清理 `codex/agents-foundation` 分支与对应 worktree，只保留主工作区继续作为当前稳定基线。

## 2026-04-06

- 基于阶段 1 的实践经验，收敛分支与 worktree 使用策略：默认先开分支，只有阶段型开发、并行开发或需要隔离 Godot 现场时再额外创建 worktree。
- 新建设计文档 `spec-design/2026-04-06-branch-and-worktree-strategy.md`，明确“仅分支”与“分支 + worktree”的适用条件。
- 从 `main` 开出短分支 `codex/branch-vs-worktree-policy`，本次采用模式为 `仅分支`，用于落地工作流规则修订并作为今后留痕示例。
- 将 `codex/branch-vs-worktree-policy` 快进合并回 `main`，并再次验证阶段 1 测试保持 `10/10 passed`。
- 删除已合并的 `codex/branch-vs-worktree-policy`，把主工作目录重新收拢到 `main`。
- 将 `codex/stage-2-movement-feel` 及其 worktree 快进到最新 `main`，保留为后续阶段 2 的开发入口。
