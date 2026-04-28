# Nano Hunter Timeline

本文件只记录项目里程碑级事件。每日细节、命令输出、MCP 复核过程和分支操作原因保存在 `docs/progress/logs/YYYY-MM-DD.md`。

## 2026-03-31

- 建立 Godot 4.6 原型仓库治理基线，明确 `spec-design/`、`docs/progress/`、`plan/` 与 GUT 测试方向。详情见 `docs/progress/logs/2026-03-31.md`。

## 2026-04-01

- 完成 Stage1 启动骨架：`Main.tscn`、测试房间、相机、基础碰撞和首批 GUT。详情见 `docs/progress/logs/2026-04-01.md`。

## 2026-04-06

- 建立分支 / worktree 使用规则雏形，并确认主工作区保留稳定基线。详情见 `docs/progress/logs/2026-04-06.md`。

## 2026-04-10

- 调整阶段推进节奏，强化“设计、实现、验证、留痕”闭环。详情见 `docs/progress/logs/2026-04-10.md`。

## 2026-04-11

- 继续整理早期项目治理、阶段文档和验证命令记录。详情见 `docs/progress/logs/2026-04-11.md`。

## 2026-04-20

- 更新早期原型推进记录，为 Stage5 后续可试玩切片做准备。详情见 `docs/progress/logs/2026-04-20.md`。

## 2026-04-21

- 推进 Stage5 教程垂直切片与早期 HUD / 房间链路验证。详情见 `docs/progress/logs/2026-04-21.md`。

## 2026-04-22

- 补强 Stage5-Stage6 前置验证和进度文档，继续收敛原型期流程。详情见 `docs/progress/logs/2026-04-22.md`。

## 2026-04-23

- Stage5 教程垂直切片完成，随后完成 Stage6 最小真实战斗循环、Stage7 短链路主流程串联与 Stage8 系统稳固 / 内容生产前准备。详情见 `docs/progress/logs/2026-04-23.md`。

## 2026-04-24

- 完成 Stage9 首个小区域内容生产、Stage10 战斗变化与轻量成长循环、Stage11 可交付试玩 Demo 切片的主要实现与验证。详情见 `docs/progress/logs/2026-04-24.md`。

## 2026-04-25

- 规划 Stage12-Stage16 更大颗粒度路线，开始 Stage12 资产管线与第一轮 Demo 表现升级。详情见 `docs/progress/logs/2026-04-25.md`。

## 2026-04-26

- Stage12 收口并合并，Stage13 第二小区域内容生产完成主要实现与验证；同时整理 Godot MCP 固定工作树连接策略。详情见 `docs/progress/logs/2026-04-26.md`。

## 2026-04-27

- Stage14 回溯与能力门控成型完成并作为新稳定基线，新增 `Air Dash / 空中二段冲刺`、能力门、回溯链路与 `3` 个回溯收益点。
- 启动 Stage15 战斗高潮与首个精英 Boss 原型，实现 Seal Guardian、Recovery Charge、Stage15 房间链路、HUD 与专项测试的主体内容。
- 整理客户端 / CLI、Godot MCP 和插件治理文档，降低 AGENTS 对单一客户端实现的绑定。详情见 `docs/progress/logs/2026-04-27.md`。

## 2026-04-28

- 完成 Stage15 Godot MCP 运行态人工复核，覆盖 Stage14 回环入口、Stage15 前置段、混合遭遇、Boss 房、失败重试、Boss 击败和完成房反馈。
- 修复 MCP 复核发现的 Stage15 completion room HUD 问题，并新增回归测试保护完成房不再显示旧主目标、恢复充能或旧收集行。
- 提交前 QA 发现 Stage15 混合遭遇和挑战支线可被绕过；已补全清门控、挑战支线出口门和回归测试。
- Stage15 已拆为 3 个阶段分支提交并合并回 `main`，合并后主线验证通过：Godot import、Stage15 专项 GUT `11/11`、全量 GUT `107/107`、`git diff --check HEAD` 和乱码扫描。
- 完成全仓自有 GDScript 函数入口注释审计清零和乱码扫描，确认 Stage15 专项 GUT、全量 GUT、Godot import 与 `git diff --check` 通过。
- 调整进度文档治理：日日志迁入 `docs/progress/logs/`，MCP 截图改为 `tests/artifacts/local/` 本地证据产物，`status.md` 与 `timeline.md` 改为低重复格式。详情见 `docs/progress/logs/2026-04-28.md`。
