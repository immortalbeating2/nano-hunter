# Preflight26A 可审计开发基线计划

设计真源：`spec-design/2026-07-31-post-stage26-north-star-gap-and-stage27-32-roadmap.md`
执行清单：`docs/implementation-plans/2026-08-01-preflight26a-clean-baseline.md`

## 目标

在不扩展玩法的前提下，把 Stage27 的入口恢复为“归属明确、资产审计一致、可重复验证”的基线。

## 实施顺序

1. 盘点当前分支、HEAD、tracked / untracked 改动和活跃 Godot / MCP 进程，按“地形对齐、北极星路线、个人配置 / 候选资产、未知”分组。
2. 对地形视觉 / 碰撞批次执行专项、全量、import、主场景 smoke 和 diff 校验；只在证据成立后确定其检查点归属，不吸收 `.codex/config.toml`、inbox、backend 或其他个人现场。
3. 以 `stage19_discovery_map_base_ai01` 的真实 DemoShell 引用为依据，补齐 runtime integration map、readiness 与 acceptance 的同一资产 ID 边界。
4. 重新执行 strict readiness、package、runtime-map 和 final acceptance 审计；数量与条目集合必须一致。
5. 从确认后的基线重跑 Stage21-26 组合、递归 GUT、Godot import、主场景 smoke、编辑器错误与 `git diff --check`。
6. 确认没有遗留临时 MCP autoload、错误项目 workspace 或本轮启动但未记录的桥接进程，记录 Stage27 起点提交。

## 约束

- 不修改玩家、战斗、房间拓扑、UI 流程或资产画面。
- 不把“文件存在”改写为 final-ready；只修复已上屏资产的治理缺口。
- 不删除、不移动、不提交归属不明的用户文件。
- 若地形批次未通过新鲜验证，保留现场并把 Preflight 标为未完成，不以文档覆盖失败。

## 验证

- 地形专项与 `tests/demo/test_walkable_surface_visual_collision_alignment.gd`。
- Stage21-26 组合与递归 GUT。
- `godot --headless --path . --import`、主场景 smoke、strict 资产审计、UTF-8 / 陈旧路径 / `git diff --check`。
- Godot MCP Pro workspace、autoload 与编辑器错误只读检查。

## 退出标准

- 后续 Stage 可引用一个明确提交作为起点。
- strict 资产审计对同一登记集合全部通过，`stage19_discovery_map_base_ai01` 不再缺图。
- 当前工作树中所有保留改动均有归属说明；临时 MCP autoload 为零。

## 非目标

不生成新美术 / 音频，不做 Gate26H，不实施 Stage27 功能。
