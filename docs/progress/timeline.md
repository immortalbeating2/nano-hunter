# Nano Hunter Timeline

本文件只记录项目里程碑级事件。每日细节、命令输出、MCP 复核过程、分支操作原因和误判修正过程保存在 `docs/progress/logs/YYYY-MM-DD.md`。每条里程碑默认包含范围、结果、关键验证、详情日志；重要阶段收口或工具链修复可补提交 hash 与遗留风险。

## 2026-03-31

- **仓库治理基线**：建立 Godot 4.6 原型仓库治理基线。
  结果：明确 `spec-design/`、`docs/progress/`、`plan/` 与 GUT 测试方向。
  详情：`docs/progress/logs/2026-03-31.md`。

## 2026-04-01

- **Stage1 启动骨架**：完成 `Main.tscn`、测试房间、相机、基础碰撞和首批 GUT。
  结果：项目进入可启动原型状态。
  详情：`docs/progress/logs/2026-04-01.md`。

## 2026-04-06

- **分支 / worktree 规则雏形**：建立分支与 worktree 使用规则。
  结果：确认主工作区保留稳定基线。
  详情：`docs/progress/logs/2026-04-06.md`。

## 2026-04-10

- **阶段推进节奏调整**：强化“设计、实现、验证、留痕”闭环。
  结果：阶段开发流程从经验约定转为可追踪规则。
  详情：`docs/progress/logs/2026-04-10.md`。

## 2026-04-11

- **早期治理整理**：继续整理项目治理、阶段文档和验证命令记录。
  结果：早期原型流程留痕更完整。
  详情：`docs/progress/logs/2026-04-11.md`。

## 2026-04-20

- **Stage5 后续准备**：更新早期原型推进记录。
  结果：为 Stage5 后续可试玩切片做准备。
  详情：`docs/progress/logs/2026-04-20.md`。

## 2026-04-21

- **Stage5 教程切片推进**：推进教程垂直切片与早期 HUD / 房间链路验证。
  结果：教程区短流程进入可验证状态。
  详情：`docs/progress/logs/2026-04-21.md`。

## 2026-04-22

- **Stage5-Stage6 前置验证**：补强阶段前置验证和进度文档。
  结果：继续收敛原型期流程。
  详情：`docs/progress/logs/2026-04-22.md`。

## 2026-04-23

- **Stage5-Stage8 收口**：Stage5 教程垂直切片完成，随后完成 Stage6 最小真实战斗循环、Stage7 短链路主流程串联与 Stage8 系统稳固 / 内容生产前准备。
  结果：项目从早期手感验证推进到内容生产前准备。
  详情：`docs/progress/logs/2026-04-23.md`。

## 2026-04-24

- **Stage9-Stage11 内容推进**：完成首个小区域内容生产、战斗变化与轻量成长循环、可交付试玩 Demo 切片的主要实现与验证。
  结果：第一版可交付试玩 Demo 切片形成。
  详情：`docs/progress/logs/2026-04-24.md`。

## 2026-04-25

- **Stage12-Stage16 路线规划**：规划更大颗粒度路线，开始 Stage12 资产管线与第一轮 Demo 表现升级。
  结果：后续 Alpha Demo 候选路线明确。
  详情：`docs/progress/logs/2026-04-25.md`。

## 2026-04-26

- **Stage12-Stage13 推进**：Stage12 收口并合并，Stage13 第二小区域内容生产完成主要实现与验证。
  结果：Demo 表现升级与第二小区域内容形成阶段基线。
  详情：`docs/progress/logs/2026-04-26.md`。

## 2026-04-27

- **Stage14 稳定基线**：完成回溯与能力门控成型。
  结果：新增 `Air Dash / 空中二段冲刺`、能力门、回溯链路与 `3` 个回溯收益点。
  详情：`docs/progress/logs/2026-04-27.md`。

- **Stage15 主体启动**：启动战斗高潮与首个精英 Boss 原型。
  结果：实现 Seal Guardian、Recovery Charge、Stage15 房间链路、HUD 与专项测试主体内容。
  详情：`docs/progress/logs/2026-04-27.md`。

- **客户端 / 插件治理整理**：整理客户端 / CLI、Godot MCP 和插件治理文档。
  结果：降低 AGENTS 对单一客户端实现的绑定。
  详情：`docs/progress/logs/2026-04-27.md`。

## 2026-04-28

- **Stage15 运行态复核与修复**：完成 Godot MCP 运行态人工复核，并修复 completion room HUD 问题。
  结果：完成房不再显示旧主目标、恢复充能或旧收集行；补入回归测试。
  详情：`docs/progress/logs/2026-04-28.md`。

- **Stage15 QA 收口**：发现并修复混合遭遇和挑战支线可绕过问题。
  结果：补全清门控、挑战支线出口门和回归测试；Stage15 分支合并回 `main`。
  验证：Godot import、Stage15 专项 GUT `11/11`、全量 GUT `107/107`、`git diff --check HEAD` 和乱码扫描通过。
  详情：`docs/progress/logs/2026-04-28.md`。

- **进度文档治理初步调整**：日日志迁入 `docs/progress/logs/`，MCP 截图改为 `tests/artifacts/local/` 本地证据产物。
  结果：降低 `status.md` 与 `timeline.md` 的重复度。
  详情：`docs/progress/logs/2026-04-28.md`。

## 2026-04-29

- **Stage12-13 北极星回收修正**：创建并完成 `codex/north-star-realign-stage12-13`。
  结果：将现代实验室 / 生物废液表达回收到山门古刹、镇妖试炼场、瘴泽妖域、符印封印机关和瘴气妖术投射者。
  验证：Godot MCP 人工复核完成，分支合并到 `main` 并推送 `origin/main`。
  详情：`docs/progress/logs/2026-04-29.md`。

- **Stage16 Alpha Demo 候选**：从固定永久工作树创建 `codex/stage-16-alpha-demo-candidate` 并完成主体实现。
  结果：五房终局封印链、Stage15 completion 接入、最小 Demo 壳、Main / HUD Stage16 完成态、Stage16 专项 GUT、Alpha Demo 灰盒 driver、`docs/deliverables/stage16-alpha-demo-candidate/` 交付物与资产 / 音频 manifest 条目完成。
  验证：Godot MCP 运行态复核覆盖主菜单、暂停 / 继续 / 重开、Stage15 completion、Stage16 五房运行态节点、导出 next-room 链路与 Alpha Demo 终点。
  详情：`docs/progress/logs/2026-04-29.md`。

- **Stage16 合并基线**：Stage16 Alpha Demo 打包候选合并回 `main`。
  结果：`main` 成为 Stage16 Alpha Demo 候选稳定基线。
  验证：Godot import、Stage16 专项 GUT `8/8`、Stage15 专项 GUT `11/11`、全量 GUT `115/115`、`git diff --check HEAD` 通过。
  详情：`docs/progress/logs/2026-04-29.md`。

## 2026-04-30

- **Godot MCP bridge lifecycle hardening**：启动并完成工具链修复分支 `codex/fix-godot-mcp-bridge-lifecycle` 的第一轮 hardening。
  结果：扩展 stdio bridge 端口规划，保留 `godot-cli` 端口，新增 bridge lock/heartbeat、workspace handshake、lazy reconnect、诊断脚本和插件升级后可重放补丁源。
  验证：Node `npm test` / `npm run build`、Godot import、诊断脚本 dry-run、补丁脚本 dry-run 和 `git diff --check` 通过。
  提交：`ddaad7d`。
  遗留：该阶段不等于完整根治，Godot 插件仍可能优先连接旧低端口 bridge。
  详情：`docs/progress/logs/2026-04-30.md`。

- **Godot MCP 通用补丁工具**：将 hardening 补丁脚本通用化为可搬移、可跨项目使用的工具。
  结果：默认只覆盖全局 Node server 与目标项目 `addons/godot_mcp`；项目诊断脚本改为 `-IncludeProjectScripts` 可选项。
  验证：补丁脚本 dry-run 矩阵、外部 Node server 构建测试、Godot import、诊断脚本和乱码扫描通过。
  提交：`fd7638f`。
  详情：`docs/progress/logs/2026-04-30.md`。

- **Godot MCP 文档入口收敛**：将脚本速查与排障流程合并进 `docs/dev/godot-mcp-pro-connectivity-guide.md`。
  结果：connectivity guide 成为唯一权威入口，`AGENTS.md` 只保留项目级原则和指针。
  验证：旧引用扫描和 `git diff --check` 通过。
  提交：`a41ea03`。
  详情：`docs/progress/logs/2026-04-30.md`。

- **Godot MCP hardening 复核修正**：人工复核确认当前方案仍缺 session/port rendezvous。
  结果：文档状态修正为“hardening 已完成，完整根治未完成”；后续需新增独立 rendezvous 计划。
  关键证据：当前会话工具入口存在，但 MCP 只读工具返回 Godot editor 未连接；Godot editor 可被旧 `6505` bridge 抢先连接。
  详情：`docs/progress/logs/2026-04-30.md`。

## 2026-05-01

- **Godot MCP 端口迁移与 rendezvous 根治**：在 `codex/fix-godot-mcp-bridge-lifecycle` 上继续工具链根治。
  结果：stdio 主端口迁移到 `17605-17619`，CLI 主端口迁移到 `17620-17624`，旧 `6505-6509` / `6510-6514` 降级为 legacy；Node 写项目本地 rendezvous，Godot 插件优先连接当前会话指定端口。
  关键验证：外部 Node server `npm test` / `npm run build` 通过；完整 Godot 与脚本验证见当日日志。
  详情：`docs/progress/logs/2026-05-01.md`。

## 2026-05-13

- **Godot MCP Pro 1.13.1 增量合并**：启动 `codex/upgrade-godot-mcp-1-13-1-increments`，审查并吸收 1.13.1 可用增量。
  结果：保留 `17605-17619` / `17620-17624`、rendezvous、workspace/session 握手和 diagnostic tools，同时合入 ping/pong、heartbeat timeout、idle/stale UI 与输入 `unhandled=false` 修正。
  关键验证：外部 Node server `npm test` / `npm run build`、补丁脚本 dry-run、MCP 诊断脚本、入口脚本 dry-run、Godot import 和 `git diff --check` 通过。
  详情：`docs/progress/logs/2026-05-13.md`。
