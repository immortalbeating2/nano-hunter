# Stage16 Alpha Demo QA Checklist

## 使用范围

本清单用于 Stage16 Alpha Demo 候选收口。它记录自动化、Godot MCP 人工复核、主线试玩、暂停 / 重开和 release notes 的最小验收项，不替代正式测试管理系统。

## 自动化检查

- [x] `godot --headless --path . --import`
- [x] Stage16 专项 GUT：`tests/stage16/test_stage_16_alpha_demo_candidate.gd`
- [x] Stage15 专项 GUT：`tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`
- [x] 全量 GUT：`-gdir=res://tests -ginclude_subdirs`
- [x] `git diff --check`

## 主线试玩检查

- [x] 从 `Main.tscn` 进入主菜单。
- [x] 主菜单开始后能从教程起点进入试玩。
- [ ] Stage14 Air Dash 能力门与回溯收益仍可理解。
- [ ] Stage15 Boss 房支持失败重试与 Boss 击败。
- [x] Stage15 completion room 能进入 Stage16 五房链路。
- [x] Stage16 五房链路可稳定推进到 `stage16_alpha_demo_end_room`。
- [x] Alpha Demo 完成反馈显示“已完成”，且不显示旧 Boss 目标、旧收集行或旧恢复充能行。

## Demo 壳检查

- [x] 暂停菜单可打开。
- [x] 暂停后继续能恢复试玩。
- [x] 重开后回到教程起点。
- [x] 重开会清理 Air Dash、Stage14 回溯收益、Stage15 Boss 击败和 Stage16 完成态。

## Godot MCP 运行态复核

- [x] 从固定工作树运行 `.\scripts\dev\enter-worktree-godot-mcp.ps1` 并记录状态。
- [x] 确认 Godot MCP 工具入口可用。
- [x] 复核主菜单、暂停、重开、Stage15 completion、Stage16 五房链路和 Alpha Demo 完成反馈。
- [x] 截图或一次性证据保存到 `tests/artifacts/local/stage16-mcp/`，不提交。
- [x] 复核尝试结束后确认 `project.godot` 中无 MCP 临时 autoload diff。

复核结果：当前会话已通过 `mcp__godot_mcp_pro__` 连接固定工作树 Godot 编辑器；`Main.tscn` 主菜单、暂停菜单、Stage15 completion room、Stage16 五房运行态节点和导出链路均已复核。截图保存在 `tests/artifacts/local/stage16-mcp/`，默认不提交。

## Release Notes 检查

- [x] release notes 记录试玩入口。
- [x] release notes 记录当前内容范围。
- [x] release notes 记录验证命令结果。
- [x] release notes 记录已知问题。
- [x] release notes 记录 Godot MCP 复核状态。
