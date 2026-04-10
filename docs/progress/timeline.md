# Nano Hunter Timeline

## 2026-03-31

- 初始化 `nano-hunter` 的 Godot 4.6 工程并建立基础仓库结构。
- 建立项目级 `AGENTS.md`、`docs/progress/` 与 `spec-design/` 留痕体系。
- 关闭当前阶段不兼容的 `better-terrain` 激活，保留 `godot_mcp` 与 `gut` 作为默认启用插件。
- 完成 `阶段 1：可启动骨架` 的基础入口：`Main.tscn`、占位玩家、测试房间与启动入口验证。

## 2026-04-01

- 完成 `阶段 1` 的显示与相机调优：固定基准分辨率、整数倍缩放、留边策略与测试房间相机边界。
- 补齐阶段 1 的设计文档、实现计划与进度留痕。
- 将阶段 1 的稳定结果合并回 `main`，形成第一版可启动、可看、可调的试玩检查点。

## 2026-04-06

- 基于阶段 1 的实践经验，收敛分支与 worktree使用策略，明确“小任务默认仅分支，阶段开发默认分支 + worktree”。
- 新建设计文档 `spec-design/2026-04-06-branch-and-worktree-strategy.md`，明确“仅分支”与“分支 + worktree”的适用条件。
- 将 `codex/branch-vs-worktree-policy` 合并回 `main` 并删除分支，同时保留 `codex/stage-2-movement-feel` 作为阶段 2 的开发入口。

## 2026-04-10

- 基于阶段 1 与阶段 2 的执行差异，补充“默认开发节奏”治理规则，明确它是对 `AGENTS.md` 现有“大功能 / 小改动”分流的执行层细化，而不是替代规则。
- 在 `AGENTS.md` 中新增“大功能默认节奏”“小改动默认节奏”与对应决策规则，统一 `brainstorming`、`subagent`、`worktree` 与提交次数的默认用法。
- 新建设计留痕 `spec-design/2026-04-10-development-cadence-standardization.md`，说明为什么要把阶段型开发节奏从聊天约定提升为项目内显式规范。
- 新增实现计划 `docs/superpowers/plans/2026-04-10-development-cadence-standardization.md`，把本次治理修订限定为文档与规则收口，不混入额外玩法实现。
- 更新 `docs/progress/status.md`、`docs/progress/timeline.md` 与当日日志，明确后续阶段 3、4、5 默认沿用大功能节奏，文档修订、配置调整与单点 bugfix 则沿用小改动节奏。
- 重新建立本地 `codex/stage-2-movement-feel` 分支与 `.worktrees/stage-2-movement-feel` 隔离工作区，避免在带未提交改动的主工作区上直接推进阶段 2。
- 新增阶段 2 设计留痕，锁定本轮只做基础移动手感，不做冲刺、攻击、HUD 与房间系统重构。
- 收口 `project.godot`：加入 `move_left`、`move_right`、`jump` 命名输入动作，并保持 `better-terrain` 编辑器插件禁用。
- 将占位玩家演进为可控原型，加入 `idle / run / jump_rise / jump_fall / land` 状态、导出调参字段，以及 `coyote time`、`jump buffer`、`可变跳高`。
- 扩展 `TestRoom`，加入中段平台，覆盖阶段 2 的基础平台移动验证路径。
- 新增 `tests/stage2/test_stage_2_movement_feel.gd`，验证输入契约、状态契约、跑停、跳跃、可变跳高、`coyote time` 与 `jump buffer`。
- 明确后续阶段安排：攻击放 `阶段 3`，冲刺优先放 `阶段 4`，HUD 与房间系统重构放 `阶段 5`。
- 为补做 GUI 手动试玩，同步阶段 2 worktree 中的 `godot_mcp` 到 `1.10.1`，并恢复工程依赖的项目级 autoload，收口 Godot MCP 的项目侧兼容问题。
- 在后续接续中于沙箱外重新确认 `godot --headless --path . --import`、阶段 1 GUT 与阶段 2 GUT 均通过，确认当前 worktree 自动化基线仍为绿色。
- 将 GUI 阻塞进一步收敛为当前 Codex 桌面线程拿不到编辑器侧连接，而不是阶段 2 worktree 的项目配置回退。
- 清理误开的开发现场：
  - 仓库根工作区已切回 `main`
  - 误开的本地分支 `stage-2-movement-feel` 已删除
  - 只保留 `.worktrees/stage-2-movement-feel` 作为阶段 2 工作树
  - 外部 `f400` worktree 已从 Git worktree 元数据移除，但其物理目录仍被 `Codex.exe` 占用，待关闭对应桌面窗口后再删

## 2026-04-11

- 恢复当前会话的 Godot 编辑器侧 MCP 连接，重新获得阶段 2 的编辑器复核能力。
- 在阶段 2 编辑器复核中发现 `project.godot` 的命名动作只有动作名、没有静态默认键位，补写回归测试后确认该缺口会直接让阶段 2 工程基线测试转红。
- 将 `move_left`、`move_right`、`jump` 的默认键位静态写入 `project.godot`，使项目配置、编辑器侧验证和运行时输入契约重新对齐。
- 重新确认 `godot --headless --path . --import`、阶段 1 GUT 与阶段 2 GUT 均通过，将阶段 2 状态从“待 GUI 复核”更新为“已完成，待进入阶段 3”。
- 修复当前 codex/stage-2-movement-feel worktree 的 Git 索引损坏，恢复 git status 与 git diff --check。
- 将 codex/stage-2-movement-feel 本地合并回 main，并在主线结果上重新确认 --import、阶段 1 GUT、阶段 2 GUT 与 git diff --check 全部通过。

