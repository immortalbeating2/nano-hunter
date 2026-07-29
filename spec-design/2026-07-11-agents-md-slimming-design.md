# Nano Hunter AGENTS.md 瘦身治理设计

## 背景

当前 `AGENTS.md` 已增长到约 `530` 行，混合承载稳定规则、阶段历史、当前状态、资产批次、插件盘点、MCP 端口、worktree 清理和单次故障经验。动态内容持续失真，例如工程已经配置主场景，但旧验证说明仍按“没有主场景”处理。

本次目标不是把全部内容原样搬到另一份大文档，而是删除过期信息，只为仍有效的细节保留现有专题入口。

## 定位

`AGENTS.md` 是仓库级执行契约和阅读路由，只回答：

1. 哪些规则不可违反。
2. 开始修改前必须读取什么。
3. 大功能、小改动分别走什么最短流程。
4. 如何验证、留痕和安全交付。

它不再承担项目状态页、阶段路线图、插件手册、资产路线图、客户端说明或故障知识库职责。

## 内容准入规则

一条内容只有同时满足以下条件，才进入根 `AGENTS.md`：

- 对整个仓库生效，而非只服务某个 Stage、分支、客户端或工具版本。
- 跨阶段稳定，不需要随里程碑频繁更新。
- 代理在首次修改前必须知道。
- 没有更明确的专题文档作为事实来源。

禁止写入：当前日期、当前分支、阶段完成历史、测试数量、MCP 端口表、资产 Batch 清单、未启用插件逐项说明和一次性故障结论。

## 目标结构

精简后的 `AGENTS.md` 控制在约 `120-160` 行，采用以下结构：

1. 作用与边界
2. 项目常量与规则优先级
3. 必读顺序与事实来源
4. 任务分级与最短流程
5. 项目实现约束
6. 文档与资产留痕
7. 验证与完成门禁
8. Git、协作与维护规则

## 迁移与删除

| 原内容 | 处理方式 |
| --- | --- |
| 当前阶段、默认目标、Stage 1-16 历史 | 删除，改读 `docs/progress/status.md`、相关设计和计划 |
| Superpowers 与开发节奏重复说明 | 合并为大功能 / 小改动两套最短流程 |
| 文档目录逐项长解释 | 压缩为事实来源表和最小更新要求 |
| MCP 端口、连接和 worktree 清理细节 | 删除，只链接 `docs/dev/godot-mcp-pro-connectivity-guide.md` |
| 插件候选逐项说明 | 删除，只链接 `docs/dev/plugin-inventory.md` |
| 资产 Batch、历史阶段资产策略 | 删除，只保留玩法优先、登记、来源与接入门禁 |
| Codex 客户端和 multi-agent 参数 | 删除，只链接对应客户端专题文档 |
| 分支与 worktree 操作手册 | 保留稳定安全原则，删除工具和端口级步骤 |
| 测试文件 UTF-8 崩溃案例 | 从生效契约删除，历史日志和 Git 继续保留证据 |
| 代码、注释、验证、提交规则 | 保留项目级硬约束并去重 |

## 专题事实来源

- 当前状态：`docs/progress/status.md`
- 里程碑：`docs/progress/timeline.md`
- 当日操作：`docs/progress/logs/YYYY-MM-DD.md`
- 总设计北极星：`spec-design/2026-03-23-nano-hunter-design.md`
- 当前阶段：由 `status.md` 链接到对应 `spec-design/`、`plan/` 和 `docs/implementation-plans/`
- Codex 客户端：`docs/dev/codex-client-workflow-reference.md`
- Codex 多代理设置：`docs/dev/codex-multi-agent-settings-reference.md`
- Godot MCP：`docs/dev/godot-mcp-pro-connectivity-guide.md`
- 插件：`docs/dev/plugin-inventory.md`
- 资产需求与状态：`docs/assets/asset-manifest.md`
- 资产生产：`docs/assets/asset-production-roadmap.md`
- 资产存储：`docs/assets/asset-storage-policy.md`

## 维护规则

- 阶段开始、完成或分支切换不再触发 `AGENTS.md` 更新。
- 规则变化优先替换旧规则，不做追加式堆叠。
- 专题细节只维护一份，`AGENTS.md` 只保留链接和不可违背的摘要。
- 新规则若不能通过内容准入检查，应写入状态、计划、日志或对应专题文档。

## 验收标准

- `AGENTS.md` 不超过 `160` 行。
- 不再包含动态阶段历史、端口表、Batch 清单或一次性故障处理。
- 主场景、默认插件和文档路径与当前仓库一致。
- 所有引用路径存在。
- 常见陈旧词扫描和 `git diff --check` 通过。
- 纯文档治理不运行无关的 Godot / GUT 全量回归。

## 不做项

- 不清理整个 `docs/` 目录。
- 不重写已有 MCP、插件、资产或客户端专题文档。
- 不改变 Stage17 玩法、动画、资产或测试范围。
- 不提交、合并或推送，除非用户另行要求。
