# Nano Hunter AGENTS And Progress Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a project-specific `AGENTS.md` plus baseline progress documents so future sessions can follow the mixed superpowers workflow and recover context from repository docs instead of chat history.

**Architecture:** Treat `AGENTS.md` as the stable governance document and `docs/progress/` as the evolving project record. Seed the progress documents with the current repository state first, then add `AGENTS.md`, then reconcile the progress docs so they reflect the new governance baseline.

**Tech Stack:** Markdown, Git, PowerShell validation commands, Godot 4.6 project conventions

---

## File Structure

- Create: `AGENTS.md`
  - Stable project-level rules for workflow, documentation discipline, validation, plugin policy, and session startup.
- Create: `docs/progress/status.md`
  - Canonical current project snapshot for the next session to read after `AGENTS.md`.
- Create: `docs/progress/timeline.md`
  - Chronological major-event log for the whole project.
- Create: `docs/progress/2026-03-31.md`
  - Detailed daily log for repository setup, plugin trimming, git setup, AGENTS design work, and AGENTS implementation.
- Reference only: `spec-design/2026-03-31-nano-hunter-agents-design.md`
  - Approved design spec that the implementation must match.

## Notes Before Execution

- Create and use a dedicated branch or worktree before editing repository files.
- Keep the implementation scope focused on governance documents only. Do not start gameplay scaffolding in this plan.
- Keep comments and prose in Chinese to match the approved design direction.

### Task 1: Seed The Progress Documentation Baseline

**Files:**
- Create: `docs/progress/status.md`
- Create: `docs/progress/timeline.md`
- Create: `docs/progress/2026-03-31.md`
- Test: `docs/progress/status.md`
- Test: `docs/progress/timeline.md`
- Test: `docs/progress/2026-03-31.md`

- [ ] **Step 1: Write the initial status snapshot**

```markdown
# Nano Hunter Status

Last Updated: 2026-03-31

## Current Phase

`Vertical Slice / 原型期`

## Current Goal

为 `nano-hunter` 建立稳定的项目级工作规范与进度留痕基线，并为后续第一版可玩原型搭建明确的文档入口。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城
- 主要语言：GDScript
- 当前启用插件：`better-terrain`、`godot_mcp`、`gut`
- 当前设计文档目录：`spec-design/`

## In Progress

- 根据已批准设计规范创建项目专属 `AGENTS.md`
- 建立 `docs/progress/` 目录下的状态、时间线、日记录文档

## Recently Completed

- 初始化 Godot 工程并整理基础仓库文件
- 将默认启用插件收敛为 `better-terrain`、`godot_mcp`、`gut`
- 将仓库纳入 Git 跟踪并推送到 GitHub
- 编写并提交 `spec-design/2026-03-31-nano-hunter-agents-design.md`

## Risks And Blockers

- 目前还没有主场景、玩家控制器、关卡原型或测试目录
- 如果没有统一的项目级规范与进度文档，后续多 session 开发容易偏离目标

## Next Recommended Steps

1. 完成 `AGENTS.md` 落地
2. 将本次治理性改动同步到时间线与当日日志
3. 在规范稳定后，为第一版可玩原型编写实现计划
```

- [ ] **Step 2: Write the project timeline**

```markdown
# Nano Hunter Timeline

## 2026-03-31

- 初始化 `nano-hunter` Godot 4.6 工程，并引入所需插件目录。
- 收敛默认启用插件，保留 `better-terrain`、`godot_mcp`、`gut`，关闭其他当前阶段不需要的插件。
- 将本地仓库纳入 Git 跟踪，创建首次提交 `68d07cf` `Initial project setup`，并推送到 `origin/main`。
- 完成 `AGENTS.md` 设计讨论，形成并提交设计规范 `spec-design/2026-03-31-nano-hunter-agents-design.md`，提交 `e05611e`。
- 启动项目级进度文档体系落地，创建 `docs/progress/` 基础文档。
```

- [ ] **Step 3: Write the detailed daily log**

```markdown
# Nano Hunter Development Log - 2026-03-31

## Background

今天的目标不是直接开始玩法开发，而是先为 `nano-hunter` 建立稳定的工程治理和文档基线，确保后续原型开发能够持续按 `superpowers` 的混合工作流推进。

## Work Completed

- 审查当前 Godot 项目状态，确认仓库仍处于非常早期阶段，主体内容为插件和设计文档。
- 根据当前阶段需求，收敛默认启用插件，仅保留 `better-terrain`、`godot_mcp`、`gut`。
- 将工程纳入 Git 跟踪并推送到 GitHub 仓库 `immortalbeating2/nano-hunter`。
- 基于 `angel-fallen` 的参考 `AGENTS.md`，抽离适用于 `nano-hunter` 的项目级规范设计。
- 编写并提交 `spec-design/2026-03-31-nano-hunter-agents-design.md` 作为正式设计依据。
- 开始建立 `docs/progress/` 目录下的状态、时间线、当日日志文档。

## Validation Already Observed

- `git status --short --branch`
- `git remote -v`
- `Get-Content project.godot`
- `Get-Content spec-design/2026-03-31-nano-hunter-agents-design.md`

## Open Items

- 正式 `AGENTS.md` 仍待落地
- 进度文档需要在 `AGENTS.md` 创建完成后进行一次同步更新
- 第一版玩法原型的实现计划尚未开始编写

## Next Step

根据已批准的设计规范创建 `AGENTS.md`，然后更新 `status.md`、`timeline.md` 和当日日志，使它们能作为后续 session 的稳定入口。
```

- [ ] **Step 4: Run baseline documentation checks**

Run:

```powershell
Test-Path docs/progress/status.md
Test-Path docs/progress/timeline.md
Test-Path docs/progress/2026-03-31.md
Select-String -Path docs/progress/status.md -Pattern "Current Phase","Next Recommended Steps"
Select-String -Path docs/progress/timeline.md -Pattern "2026-03-31","Initial project setup","AGENTS"
```

Expected:

- Three `True` results from `Test-Path`
- Matching lines from `status.md`
- Matching timeline lines that mention `2026-03-31`, `Initial project setup`, and `AGENTS`

- [ ] **Step 5: Commit the baseline progress docs**

```bash
git add docs/progress/status.md docs/progress/timeline.md docs/progress/2026-03-31.md
git commit -m "建立进度文档基线 / Add progress docs baseline"
```

### Task 2: Add AGENTS.md And Reconcile Progress Docs

**Files:**
- Create: `AGENTS.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-03-31.md`
- Test: `AGENTS.md`
- Test: `docs/progress/status.md`
- Test: `docs/progress/timeline.md`
- Test: `docs/progress/2026-03-31.md`

- [ ] **Step 1: Write the project-level AGENTS.md**

```markdown
# AGENTS.md - Nano Hunter 代理工作指南

## 目的

本文件面向在 `nano-hunter` 仓库中工作的智能编码代理与后续开发 session。
项目当前处于 Godot 4.6 的 2D 类银河恶魔城原型期。
优先做小而准、可验证、可追溯的改动，不要跳过设计与留痕直接扩张实现范围。

## 项目快照

- 引擎：Godot 4.6.x
- 类型：2D 类银河恶魔城
- 主要语言：GDScript
- 当前阶段：`Vertical Slice / 原型期`
- 当前默认启用插件：`better-terrain`、`godot_mcp`、`gut`
- 设计文档目录：`spec-design/`
- 进度文档目录：`docs/progress/`

## 规则优先级

1. 用户直接要求
2. 本项目 `AGENTS.md`
3. 已批准的设计文档与实现计划
4. 通用默认习惯与辅助技能建议

如用户要求、项目文档和默认习惯冲突，以用户要求和本项目文档为准。

## 工作流：混合版 Superpowers

### 大功能

满足任一情况，按大功能处理：

- 新增或重做核心玩法系统
- 修改角色控制、战斗循环、状态机、敌人 AI、关卡推进、能力门控
- 新增或重做主流程 UI
- 新增项目级目录规范、资源规范、测试规范、存档规范
- 任何明显影响后续开发方向的工作

大功能必须遵循：

1. `brainstorming` 或等效设计确认
2. 设计文档确认或补写
3. 实现计划
4. 实现
5. 验证
6. 更新进度文档

### 小改动

以下工作可按小改动处理：

- 小范围配置调整
- 插件启停和工程整理
- 小型目录修正
- 单脚本的小 bug 修复
- 不影响整体架构的辅助性修改

小改动允许轻量流程，但仍必须：

1. 先写明目标和影响范围
2. 再实施修改
3. 做最小必要验证
4. 更新进度文档

### 强制升级为大功能的条件

即使表面看起来是小改动，只要出现以下情况，也必须升级为大功能流程：

- 需求边界不清
- 会影响多个子系统
- 需要新建多个核心文件或目录
- 可能改变后续玩法方向
- 设计文档与现实实现明显冲突

## 文档留痕是强制要求

所有开发活动都必须留痕。未更新文档的开发不算完成，未记录验证结果的改动不算真正交付。

### 文档职责

- `spec-design/`
  - 存放设计文档、玩法设计、系统设计
  - 如实现导致设计变化，必须同步回写

- `docs/progress/status.md`
  - 当前项目状态真源
  - 新 session 进入项目时优先阅读

- `docs/progress/timeline.md`
  - 全项目关键事件时间线

- `docs/progress/YYYY-MM-DD.md`
  - 当日详细开发日志

### 记录要求

每次记录至少写明：

- 做了什么
- 为什么做
- 影响了什么
- 验证结果
- 风险或遗留问题
- 下一步建议

### 文档冲突时的判断顺序

1. 当前代码与可运行结果
2. 最新的进度文档
3. 最新的设计文档
4. 更早的聊天上下文

如发现设计与实现偏离，先更新文档再继续推进。

## 当前阶段与默认目标

本项目当前为 `Vertical Slice / 原型期`。
这一部分属于可演进的阶段性规范，应在里程碑切换时更新，而不是因为零碎小任务频繁改写。

当前默认目标：

- 主场景
- 玩家基础移动
- 跳跃 / 冲刺 / 基础攻击
- 2 个姿态以内
- 2-3 个元素以内
- 最小 HUD
- 最小可回溯关卡验证

其余中后期设计保留在 `spec-design/`，不默认进入实现。

## 目录约定

当前项目应逐步形成以下目录：

- `scenes/`：游戏场景
- `scripts/`：核心脚本
- `assets/`：美术与音频资源
- `tests/`：GUT 测试
- `spec-design/`：设计文档
- `docs/progress/`：进度与时间线文档

原则：

- 目录扩展小步前进
- 没有明确需求时，不提前铺设复杂结构
- 命名优先服务当前原型开发

## 验证约定

- 工程配置改动后，至少做一次 Godot 无头启动检查
- 脚本或场景改动后，优先做最小可运行验证
- 若已有 GUT 测试，则优先运行最接近的测试
- 修 bug 时，优先补最小回归测试
- 未记录验证结果，不应声称“完成”

## 插件约定

当前默认启用插件：

- `better-terrain`
- `godot_mcp`
- `gut`

其他插件视为“已安装但当前阶段不启用”。
若后续新增或重新启用插件，必须在进度文档中记录启用日期、目的与影响范围。

## 代码与注释约定

- 新增注释统一使用中文
- 优先写小而清晰的 GDScript 文件
- 优先显式类型与清晰命名
- 沿用项目现有模式，不做无关的大重构
- 当前阶段优先服务原型可玩性，不提前实现中后期复杂系统

## 提交约定

- 每次提交围绕一个明确进展点
- 提交信息使用“中文 + English”
- 提交前至少确认：
  - 相关改动已验证
  - 进度文档已更新
  - 未提交无关噪音文件

若只是中途探索但结果未稳定，可暂不提交，但仍要写入当日日志。

## Session 接续顺序

新 session 进入项目时，建议按以下顺序读取：

1. `AGENTS.md`
2. `docs/progress/status.md`
3. 最近一篇 `docs/progress/YYYY-MM-DD.md`
4. 相关 `spec-design/` 文档

不要只凭聊天末尾几句直接进入编码。
```

- [ ] **Step 2: Update the status snapshot to reflect the new governance baseline**

```markdown
# Nano Hunter Status

Last Updated: 2026-03-31

## Current Phase

`Vertical Slice / 原型期`

## Current Goal

先稳定项目级工作流、进度留痕和 session 接续入口，再为第一版可玩原型编写实现计划，避免后续开发方向偏离。

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城
- 主要语言：GDScript
- 当前启用插件：`better-terrain`、`godot_mcp`、`gut`
- 当前设计文档目录：`spec-design/`
- 当前进度文档目录：`docs/progress/`

## In Progress

- 为第一版可玩原型准备下一份实现计划

## Recently Completed

- 初始化 Godot 工程并整理基础仓库文件
- 将默认启用插件收敛为 `better-terrain`、`godot_mcp`、`gut`
- 将仓库纳入 Git 跟踪并推送到 GitHub
- 编写并提交 `spec-design/2026-03-31-nano-hunter-agents-design.md`
- 创建项目专属 `AGENTS.md`
- 建立 `docs/progress/` 下的状态、时间线、当日日志文档

## Risks And Blockers

- 目前还没有主场景、玩家控制器、关卡原型或测试目录
- 如果后续未严格维护进度文档，仍可能出现多 session 方向漂移

## Next Recommended Steps

1. 为第一版可玩原型编写实现计划
2. 明确首个原型的场景、脚本和测试目录布局
3. 从主场景和玩家基础移动开始推进垂直切片
```

- [ ] **Step 3: Update the project timeline with the governance milestone**

```markdown
# Nano Hunter Timeline

## 2026-03-31

- 初始化 `nano-hunter` Godot 4.6 工程，并引入所需插件目录。
- 收敛默认启用插件，保留 `better-terrain`、`godot_mcp`、`gut`，关闭其他当前阶段不需要的插件。
- 将本地仓库纳入 Git 跟踪，创建首次提交 `68d07cf` `Initial project setup`，并推送到 `origin/main`。
- 完成 `AGENTS.md` 设计讨论，形成并提交设计规范 `spec-design/2026-03-31-nano-hunter-agents-design.md`，提交 `e05611e`。
- 创建 `docs/progress/` 基础文档，建立状态、时间线和当日日志留痕体系。
- 创建项目专属 `AGENTS.md`，正式落地 `nano-hunter` 的混合版 `superpowers` 工作流与进度文档约定。
```

- [ ] **Step 4: Update the daily log with the final governance result**

```markdown
# Nano Hunter Development Log - 2026-03-31

## Background

今天的目标不是直接开始玩法开发，而是先为 `nano-hunter` 建立稳定的工程治理和文档基线，确保后续原型开发能够持续按 `superpowers` 的混合工作流推进。

## Work Completed

- 审查当前 Godot 项目状态，确认仓库仍处于非常早期阶段，主体内容为插件和设计文档。
- 根据当前阶段需求，收敛默认启用插件，仅保留 `better-terrain`、`godot_mcp`、`gut`。
- 将工程纳入 Git 跟踪并推送到 GitHub 仓库 `immortalbeating2/nano-hunter`。
- 基于 `angel-fallen` 的参考 `AGENTS.md`，抽离适用于 `nano-hunter` 的项目级规范设计。
- 编写并提交 `spec-design/2026-03-31-nano-hunter-agents-design.md` 作为正式设计依据。
- 创建 `docs/progress/status.md`、`docs/progress/timeline.md`、`docs/progress/2026-03-31.md`，建立项目级进度留痕入口。
- 创建项目专属 `AGENTS.md`，明确混合版 `superpowers` 工作流、大功能/小改动边界、文档留痕强制规则、验证约定、插件策略和 session 接续顺序。

## Validation Already Observed

- `git status --short --branch`
- `git remote -v`
- `Get-Content project.godot`
- `Get-Content spec-design/2026-03-31-nano-hunter-agents-design.md`
- `Test-Path docs/progress/status.md`
- `Test-Path docs/progress/timeline.md`
- `Test-Path docs/progress/2026-03-31.md`
- `Select-String -Path AGENTS.md -Pattern "混合版 Superpowers","文档留痕","Session 接续顺序"`

## Open Items

- 第一版可玩原型的实现计划尚未开始编写
- 当前仍缺少主场景、角色、关卡和测试目录

## Next Step

基于已经落地的 `AGENTS.md` 与进度文档体系，为第一版可玩原型编写详细实现计划，并在后续开发中持续维护时间线和状态文档。
```

- [ ] **Step 5: Run AGENTS and progress document validation**

Run:

```powershell
Test-Path AGENTS.md
Select-String -Path AGENTS.md -Pattern "混合版 Superpowers","文档留痕是强制要求","当前阶段与默认目标","Session 接续顺序"
Select-String -Path docs/progress/status.md -Pattern "创建项目专属 AGENTS.md","第一版可玩原型"
Select-String -Path docs/progress/timeline.md -Pattern "创建项目专属 AGENTS.md","docs/progress"
Select-String -Path docs/progress/2026-03-31.md -Pattern "创建项目专属 AGENTS.md","混合版","工作流"
git diff --check
```

Expected:

- `Test-Path AGENTS.md` returns `True`
- `Select-String` finds all required lines in `AGENTS.md` and the progress documents
- `git diff --check` produces no output

- [ ] **Step 6: Commit the AGENTS and progress updates**

```bash
git add AGENTS.md docs/progress/status.md docs/progress/timeline.md docs/progress/2026-03-31.md
git commit -m "新增项目 AGENTS 规范 / Add project AGENTS guide"
```
