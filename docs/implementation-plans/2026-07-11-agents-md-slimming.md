# AGENTS.md 瘦身 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把根 `AGENTS.md` 收敛为稳定的仓库执行契约，并把动态状态与工具细节路由到现有专题文档。

**Architecture:** 根文件只保留跨阶段硬规则、事实来源、最短流程和完成门禁。阶段、MCP、插件、资产与客户端细节继续由现有专题文档负责，不新增第二套手册。

**Tech Stack:** Markdown、PowerShell、Git。

---

### Task 1: 固化治理边界

**Files:**
- Create: `spec-design/2026-07-11-agents-md-slimming-design.md`
- Modify: `spec-design/2026-03-31-nano-hunter-agents-design.md`

- [x] **Step 1: 记录 AGENTS 内容准入规则、目标结构、迁移表和验收标准**
- [x] **Step 2: 在旧设计文档顶部标注其历史基线身份并链接新设计**
- [x] **Step 3: 运行路径检查**

Run: `Test-Path spec-design/2026-07-11-agents-md-slimming-design.md`

Expected: `True`

### Task 2: 重写根 AGENTS.md

**Files:**
- Modify: `AGENTS.md`

- [x] **Step 1: 用八段式稳定契约替换 530 行混合手册**
- [x] **Step 2: 保留规则优先级、北极星、中文协作、任务分级、代码契约、文档门禁、验证和 Git 安全原则**
- [x] **Step 3: 删除阶段历史、动态状态、端口、Batch、插件候选、worktree 清理手册和单次故障经验**
- [x] **Step 4: 检查行数**

Run: `(Get-Content AGENTS.md).Count`

Expected: 不超过 `160`

### Task 3: 更新项目留痕

**Files:**
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/logs/2026-07-11.md`

- [x] **Step 1: 在当前状态中记录治理入口已收敛，不改变 Stage17 实现边界**
- [x] **Step 2: 在时间线增加仓库治理里程碑**
- [x] **Step 3: 在当日日志记录背景、操作、验证、风险和下一步**

### Task 4: 验证瘦身结果

**Files:**
- Verify: `AGENTS.md`
- Verify: `spec-design/2026-07-11-agents-md-slimming-design.md`
- Verify: `docs/implementation-plans/2026-07-11-agents-md-slimming.md`

- [x] **Step 1: 验证 AGENTS 引用路径全部存在**
- [x] **Step 2: 扫描不应继续出现的动态内容**

Run: `rg -n "阶段 1|阶段 16|17605|Batch 0|当前分支|没有定义主场景|UTF-8 文本" AGENTS.md`

Expected: 无匹配。

- [x] **Step 3: 检查 Markdown 差异**

Run: `git diff --check`

Expected: 无输出且退出码为 `0`。

- [x] **Step 4: 检查最终范围**

Run: `git status --short`

Expected: 只包含本计划列出的治理文档。
