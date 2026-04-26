# Codex Multi-Agent Settings Reference

## 结论

本项目当前采用：

```toml
[agents]
# max_threads = 4
max_depth = 1
```

自定义 agent 放在官方项目级路径 `.codex/agents/`，并在 `.codex/config.toml` 中注册。旧的 `.codex/agent/` 不是官方加载路径，已在 2026-04-27 迁移。

当前显式 `max_threads = 4` 暂时注释，是因为用户在当前 Codex Desktop / `multi_agent_v2` 环境下观察到冲突。处理方式不是关闭 `multi_agent_v2`，而是：

- 保留 `.codex/agents/` 自定义 agent。
- 保留 `max_depth = 1`，防止递归委派。
- 暂时让 `max_threads` 回落到 Codex 官方默认值。
- 在 `AGENTS.md` 和任务执行层继续限制单轮通常只启用 `2-4` 个最相关角色。
- 等当前 Codex Desktop 对显式 `max_threads` 的兼容性稳定后，再取消注释。

## 官方依据

- Codex 官方文档说明：subagent workflow 默认可用，但 Codex 只有在用户明确要求时才会生成子代理。
- 官方项目级自定义 agent 路径是 `.codex/agents/`；个人级路径是 `~/.codex/agents/`。
- 每个自定义 agent TOML 必须包含 `name`、`description`、`developer_instructions`。
- 全局 subagent 设置位于 `.codex/config.toml` 的 `[agents]` 下。
- `agents.max_threads` 是并发打开 agent 线程上限，未设置时默认 `6`。
- `agents.max_depth` 是生成 agent 的嵌套深度；未设置时默认 `1`。官方建议除非确实需要递归委派，否则保持默认，避免重复 fan-out 带来的 token、延迟和资源风险。
- `multi_agent` / `multi_agent_v2` 是 Codex 客户端功能开关；`.codex/agents/` 与 `[agents]` 是 subagent / custom agent 配置。两者相关但不是同一层配置。

参考：

- https://developers.openai.com/codex/subagents
- https://developers.openai.com/codex/config-reference
- https://developers.openai.com/codex/guides/build-ai-native-engineering-team

## 本项目设置原因

项目推荐的人工并行上限仍然是 `2-4` 个 agent。显式 `max_threads = 4` 比官方默认 `6` 更保守，适合当前 Godot 原型项目；但在当前 `multi_agent_v2` 存在兼容性问题时，先不强行写入：

- Godot 场景、脚本、资源和进度文档经常互相牵连，过多并行容易抢同一批核心文件。
- Windows + Godot + MCP + 固定 worktree 的运行态现场不适合大量并发编辑。
- 当前阶段仍以 Alpha Demo 候选为目标，不需要大型团队式并行。

`max_depth = 1` 继续采用官方默认语义，并保持显式写入：

- 允许主代理派生直接子代理。
- 不允许子代理继续派生子代理。
- 主代理始终负责最终整合、验证和对用户交付。

## 当前角色池

核心通用角色：

- `design`：玩法设计、阶段边界、正式阶段计划与设计文档。
- `architecture`：核心结构、共享契约、工程目录和跨系统接口。
- `gameplay`：玩家、战斗、敌人、能力、门控等可玩逻辑。
- `content`：房间、区域、遭遇、资产接入与内容配置。
- `qa`：GUT、验证清单、运行态复核与回归风险。
- `production`：AGENTS、进度文档、流程治理、收口、发布和远端同步记录。

本项目专项角色：

- `godot_runtime`：Godot 编辑器、MCP、插件、导入缓存、运行态复核与启动报错排查。
- `asset_direction`：资产风格一致性、提示词、资产清单、替换优先级与授权记录。

## 游戏开发通用参考

小型独立游戏 / 原型期：

- `max_threads = 3-4`
- `max_depth = 1`
- 建议角色：`design`、`gameplay`、`content`、`qa`、`production`

中型游戏 demo / 垂直切片：

- `max_threads = 4-5`
- `max_depth = 1`
- 建议增加：`architecture`、`asset_direction`、`runtime_tools`

大型内容生产期：

- `max_threads = 5-6`
- `max_depth = 1`
- 只在任务能按目录 / 模块完全分离时启用接近上限的并行。

不建议把 `max_depth` 提到 `2+`，除非已经有非常严格的任务队列、文件所有权和自动化验证，因为游戏项目的资源、场景和运行态工具链很容易因为递归委派而变得不可控。

## multi_agent_v2 与 max_threads 冲突时怎么处理

如果当前 Codex Desktop 出现 `multi_agent_v2` 与显式 `max_threads` 的兼容性问题：

1. 不关闭 `multi_agent_v2`，因为它是当前多代理能力的客户端特性开关。
2. 暂时注释 `.codex/config.toml` 中的 `max_threads = 4`。
3. 保留 `max_depth = 1`。
4. 保留 `.codex/agents/*.toml`。
5. 在任务描述中显式限制并行角色数量，例如“本轮最多启用 3 个 agents：gameplay / content / qa”。
6. 如果后续版本不再冲突，再恢复 `max_threads = 4`。

这个处理的含义是：运行时并发上限交给 Codex 默认值，但项目流程仍然不允许随意 fan-out。

## 使用规则

- 每次并行前必须写明每个 agent 的文件或模块所有权。
- 不让多个 agent 同时改同一核心脚本。
- 对 Godot 项目配置、插件、场景主链路、玩家控制、战斗、checkpoint、HUD 等共享面，默认由主代理最终整合。
- 如果只是调查或 review，优先使用只读角色或内置 `explorer`。
- 如果涉及实现，优先使用 `worker` 或项目专项角色，并明确写入范围。
