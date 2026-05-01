# Codex 客户端工作流参考

## 目的

本文件只记录 Codex 客户端专属映射。项目通用规则仍以 `AGENTS.md` 为准；Godot MCP 联通、端口、rendezvous、stale bridge 与 runtime autoload 排障统一参考 `docs/dev/godot-mcp-pro-connectivity-guide.md`。

如果后续使用的不是 Codex，可以把这里的术语映射为对应客户端能力，但不应因此改写项目玩法、文档留痕、分支隔离、验证和阶段收口等通用要求。

## 任务清单 UI

Codex 的 `update_plan` / plan UI 会把 `step` 文本展示给用户。`AGENTS.md` 要求面向用户的任务清单默认使用中文；在 Codex 中，这条规则具体落到 `update_plan` 的 `step` 字段。

默认要求：

- 除非用户明确要求英文，`step` 文本使用中文。
- 不使用英文占位或英文模板。
- 如果阶段已经开始时发现任务清单是英文，应立即更新为中文。

## 分支前缀

当前 Codex 客户端默认分支前缀为 `codex/`，例如：

```text
codex/stage-17-feedback-stabilization
codex/fix-godot-mcp-bridge-lifecycle
```

分支隔离、命名、合并、删除和留痕规则以 `AGENTS.md` 为准。若其它客户端使用不同前缀，只需在进度文档中记录实际分支名，不改写项目通用分支规则。

## Codex 托管临时 Worktree

Codex 有时会创建托管临时 worktree。它属于 `AGENTS.md` 中的“临时 worktree”，适合短期探索、一次性 review 或互不相关方案试验。

固定永久工作树、临时 worktree 的选择、清理、证据迁移和日志留痕规则以 `AGENTS.md` 为准。不要把 Codex 托管临时 worktree 的删除流程套用到固定永久工作树。

## Subagent 配置

当前 Codex 客户端可通过项目级 `.codex/agents/` 与 `.codex/config.toml` 注册自定义角色。`max_depth`、`max_threads`、`multi_agent_v2` 等是 Codex 专属配置，不写入 `AGENTS.md` 的通用代理协作规则。

更详细的 Codex multi-agent / subagent 配置说明保留在：

- `docs/dev/codex-multi-agent-settings-reference.md`

代理协作原则、角色边界、并行写入限制和主协调者责任以 `AGENTS.md` 为准。

## Godot MCP 工具入口

Codex Desktop 当前通常把 Godot MCP Pro 暴露为 `mcp__godot_mcp_pro__` 工具命名空间。该前缀只是 Codex 当前显示方式，不是跨客户端标准。

如果 Codex 会话工具列表里没有 Godot MCP Pro 入口，通常说明该会话启动时没有加载项目级 MCP server；普通 PowerShell 脚本无法让已启动会话热加载 MCP 工具。

处理方式：

1. 确认当前物理目录是目标 worktree。
2. 从目标 worktree 新开 Codex 会话。
3. 运行 `.\scripts\dev\enter-worktree-godot-mcp.ps1 -DryRun` 做进场诊断。

具体联通、端口规划、rendezvous、stale bridge、`Transport closed` 和 runtime autoload 排障流程，不在本文重复展开，统一参考：

- `docs/dev/godot-mcp-pro-connectivity-guide.md`
