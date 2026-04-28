# Codex 客户端工作流参考

## 目的

本文件只记录 Codex 客户端专属的操作约定。`AGENTS.md` 保留项目通用规则，避免其他账号、其他模型或其他代理客户端接手时被 Codex 专属术语干扰。

如果后续使用的不是 Codex，可以把这里的术语映射为对应客户端能力，但不应因此改写项目玩法、文档留痕、分支隔离、验证和 Godot MCP 人工复核等通用要求。

## 任务清单 UI

Codex 的 `update_plan` / plan UI 会把 `step` 文本展示给用户。项目要求：

- 除非用户明确要求英文，所有 `step` 文本必须使用中文。
- 不使用英文占位或英文模板。
- 如果阶段已经开始时发现任务清单是英文，应立即更新为中文，不等阶段收口。

## 分支前缀

当前 Codex 客户端默认分支前缀为 `codex/`，阶段分支示例：

```text
codex/stage-15-combat-climax-and-elite-boss
```

如果改用其他代理客户端，允许使用对应客户端或团队约定的分支前缀，但必须保持：

- 分支名能直接表达阶段或目标。
- 进度文档记录实际分支名。
- 不把未稳定的阶段实现直接写入 `main`。

## Codex 托管临时 Worktree

Codex 有时会创建托管临时 worktree。它适合短期探索、一次性 review 或互不相关方案试验。

项目阶段型开发仍优先使用固定永久工作树。只有临时任务确实需要隔离时，才使用 Codex 托管临时 worktree。

临时 worktree 收口时需要：

- 关闭指向该临时 worktree 的 Godot、运行实例、终端和资源管理器窗口。
- 复核 `git worktree list`。
- 清理物理目录和本地临时分支。
- 记录清理结果。

固定永久工作树不按临时 worktree 删除。

## Subagent 配置

当前 Codex 客户端使用项目级 `.codex/agents/` 和 `.codex/config.toml` 注册自定义角色。`max_depth`、`max_threads`、`multi_agent_v2` 等都是 Codex 专用配置，不写入 `AGENTS.md` 的通用代理协作规则。

更详细的 multi-agent / subagent 配置说明保留在：

- `docs/dev/codex-multi-agent-settings-reference.md`

通用原则仍写在 `AGENTS.md`：

- 并行前明确文件或模块所有权。
- 不让多个代理同时改同一核心脚本。
- 主协调者负责最终整合、验证和交付。
- 单轮通常只启用 `2-4` 个最相关角色。

## Godot MCP 工具入口

Codex 会把 Godot MCP 暴露为 `mcp__godot_mcp_pro__` 工具命名空间。如果会话工具列表里没有该入口，说明当前 Codex 会话启动时没有加载项目级 MCP。

Codex 客户端下的具体联通和排障方式见：

- `docs/dev/godot-mcp-pro-connectivity-guide.md`

不要在缺少工具入口的旧会话里反复重开 Godot；应从目标固定永久工作树新开 Codex 会话。
