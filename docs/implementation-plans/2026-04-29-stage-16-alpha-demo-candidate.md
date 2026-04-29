# Stage 16 Alpha Demo 打包候选实现计划

## 范围

阶段分支：`codex/stage-16-alpha-demo-candidate`

工作模式：固定永久工作树 + 阶段分支 + subagent / multiagent 分工。

核心交付：

- Stage16 终局封印链 `5` 个房间。
- Alpha Demo 最小主菜单、暂停、重开和完成反馈。
- Stage16 HUD、Main 快照、灰盒主线 driver 和专项 GUT。
- 第二轮关键视觉与最小音频需求记录。
- Demo 级 QA checklist 与 Alpha Demo release notes。
- Godot MCP 运行态人工复核。

## Subagent 分工

- `design`：阶段边界、终局封印链体验、Goals / Non-Goals、正式阶段计划。
- `architecture`：Main / HUD / 房间契约、Demo 壳接口、暂停与重开边界、灰盒 driver 扩展点。
- `content`：Stage16 房间链路、房间职责、回溯确认点、资产和音频 manifest。
- `qa`：Stage16 GUT、灰盒主线 driver、QA checklist、MCP 复核清单。

按需追加：

- `asset_direction`：视觉与音频命名、授权状态和替换优先级。
- `godot_runtime`：MCP preflight、运行态复核和 autoload 清理确认。
- `production`：进度文档、分支留痕、release notes 和阶段收口。

主协调者负责最终整合，禁止多个 subagent 同时修改同一核心脚本。

## 实施清单

- [x] 从固定永久工作树创建 Stage16 阶段分支。
- [x] 通过 subagent 拆分 architecture、content、qa 职责，并由主代理补齐 design / production 治理视角。
- [x] 新增 Stage16 设计文档、实现计划和正式阶段计划。
- [x] 新增 Stage16 专项 GUT 红测，覆盖 Main 快照、房间链路、Demo 壳、HUD 完成态、release notes 和 QA checklist。
- [x] 新增或扩展 Alpha Demo 灰盒 driver，目标从 Stage11 终点升级到 Stage16 Alpha Demo 终点。
- [x] 扩展 `Main.get_demo_progress_snapshot()`，新增 Stage16 完成态、release notes 和 QA checklist 读值。
- [x] 调整 `restart_demo()`，明确完整重开时清理 Stage14 / Stage15 / Stage16 运行期进度。
- [x] 新增最小 Demo 壳：主菜单、暂停、继续、重开。
- [x] 新增 Stage16 终局封印链房间：
  - `stage16_seal_release_threshold_room`
  - `stage16_talisman_relay_room`
  - `stage16_backtrack_confirmation_room`
  - `stage16_corruption_purge_room`
  - `stage16_alpha_demo_end_room`
- [x] 从 `stage15_completion_room` 接入 Stage16 入口。
- [x] 更新 HUD，使 Alpha Demo 完成态优先显示，不再显示旧 Boss 目标、旧收集行或战斗中恢复充能行。
- [x] 更新 `docs/assets/asset-manifest.md`，追加 Stage16 视觉与音频需求。
- [x] 新增 Demo 级 QA checklist。
- [x] 新增 Alpha Demo release notes。
- [x] 运行 Godot import、Stage16 专项 GUT、Stage15 专项 GUT、全量 GUT 与 `git diff --check`。
- [x] 使用 Godot MCP 从 `Main.tscn` 做运行态人工复核。
- [x] MCP 尝试结束后清理并确认 `project.godot` 无临时 autoload diff。
- [x] 更新 `docs/progress/status.md`、`docs/progress/timeline.md` 和当日日志。

## 推荐实现顺序

1. 写 Stage16 专项 GUT 红测和文档存在性测试。
2. 建立 Stage16 灰盒 driver 骨架，复用 Stage11 driver 的结果结构。
3. 扩展 Main 快照和重开语义。
4. 实现最小 Demo 壳。
5. 新增 Stage16 房间链路并接入 Stage15 completion room。
6. 更新 HUD 完成态显示规则。
7. 追加资产 / 音频 manifest、QA checklist 和 release notes。
8. 跑自动化回归。
9. 做 Godot MCP 运行态人工复核。
10. 文档收口并拆分提交。

## 房间链路

推荐主链路：

```text
stage15_seal_guardian_boss_room
-> stage15_completion_room
-> stage16_seal_release_threshold_room
-> stage16_talisman_relay_room
-> stage16_backtrack_confirmation_room
-> stage16_corruption_purge_room
-> stage16_alpha_demo_end_room
```

Stage16 不新增敌人类别。需要压力时复用既有敌人或地形危险，并以“符印失衡、妖瘴净化、封印渗漏”包装。

## 测试计划

Stage16 专项 GUT 覆盖：

- Stage16 房间资源存在并能从 Stage15 completion room 进入。
- `Main.get_demo_progress_snapshot()` 包含 `stage16_alpha_demo_completed`、`stage16_release_notes_ready`、`stage16_qa_checklist_ready`。
- `restart_demo()` 能回到 demo 起点并清理 Stage14 / Stage15 / Stage16 运行期进度。
- 主菜单入口能进入 demo，暂停 / 继续 / 重开能调用正确接口。
- Alpha Demo 完成房优先显示完成反馈，不显示旧 Boss 目标或旧收集行。
- 灰盒 driver 能从 `Main.tscn` 驱动到 Stage16 终点。
- `docs/assets/asset-manifest.md`、QA checklist 和 release notes 包含 Stage16 必要条目。

回归命令：

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
git diff --check
```

## Godot MCP 人工复核

运行入口：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1
```

复核路径：

1. 确认当前会话可见 Godot MCP 工具，并记录脚本连接状态。
2. 从主菜单进入 demo 起点，确认玩家出生、HUD 和起始提示可读。
3. 抽查 Stage14 Air Dash 能力门与回溯收益。
4. 抽查 Stage15 Boss 房、失败重试、Boss 击败和 completion room。
5. 进入 Stage16 终局封印链，确认 5 个房间顺序、出生点、出口和 HUD 反馈。
6. 检查暂停、继续和重开。
7. 检查 Alpha Demo 终点完成反馈、release notes 指向和重开提示。
8. MCP 截图放入 `tests/artifacts/local/stage16-mcp/`，不提交。
9. 复核结束后清理 `project.godot` 中 MCP 临时 autoload diff。

## 文档收口

- `docs/progress/status.md`：更新当前开发现场、最新验证、风险和下一步。
- `docs/progress/timeline.md`：记录 Stage16 分支启动、文档三件套和后续收口里程碑。
- `docs/progress/logs/YYYY-MM-DD.md`：记录分支模式、subagent 分工、设计来源、验证结果和遗留风险。
- `docs/assets/asset-manifest.md`：记录 Stage16 视觉 / 音频条目。
- release notes：记录可试玩范围、验证命令、MCP 复核结果、已知问题和试入口径。

## Completion Criteria

- Stage16 设计、计划和正式阶段计划已写入。
- Stage16 核心实现完成并通过自动化。
- Godot MCP 运行态人工复核完成。
- QA checklist 与 release notes 完成。
- 进度文档完成留痕。
- 分支结果可作为 Alpha Demo 候选基线提交和后续合并。

## 当前自动化验证结果

- `godot --headless --path . --import`：通过。
- Stage16 专项 GUT：`8/8 passed`，`66` 个断言。
- Stage15 专项 GUT：`11/11 passed`，`102` 个断言。
- 全量 GUT：`115/115 passed`，`843` 个断言。
- `git diff --check`：通过。
- Godot MCP 运行态人工复核：通过。复核覆盖 `Main.tscn` 主菜单、暂停 / 继续 / 重开、Stage15 completion room、Stage16 五房运行态节点、导出 next-room 链路和 Alpha Demo 终点节点。
- MCP 本地截图：已保存到 `tests/artifacts/local/stage16-mcp/`，默认不提交。
