# Stage 15 战斗高潮与首个精英 Boss 原型实现计划

## 范围

阶段分支：`codex/stage-15-combat-climax-and-elite-boss`

工作模式：固定永久工作树 + 阶段分支 + subagent 分工。

核心交付：

- `SealGuardianBoss` 精英 Boss 原型。
- `Recovery Charge` 恢复充能。
- Stage 14 loop return 到 Stage 15 的主线接入。
- Boss 前置段、混合遭遇、挑战支线、Boss 房与完成房。
- Stage 15 HUD、资产 manifest 与自动化测试。
- Godot MCP 运行态人工复核。

## Subagent 分工

- `design`：阶段边界、Boss 状态、不做项、文档建议。
- `gameplay`：Boss 脚本、恢复充能、玩家命中充能接口。
- `content`：Stage15 房间、主线接入、挑战支线、占位资产需求。
- `qa`：Stage15 GUT、灰盒 driver、验证清单。
- `godot_runtime`：MCP 联通策略、运行态复核清单、发现问题后的测试固化建议。
- `production`：进度文档、分支 / worktree / MCP 留痕和阶段收口记录。

主协调者负责最终整合，禁止多个 subagent 同时修改同一核心脚本。

## 实施清单

- [x] 从固定永久工作树创建 Stage15 阶段分支。
- [x] 通过 subagent 拆分设计、QA、运行态、内容和玩法职责。
- [x] 新增 Stage15 专项 GUT，覆盖恢复充能、Boss 契约、Boss 房、HUD、主线灰盒和资产 manifest。
- [x] 扩展 `PlayerPlaceholder`：新增恢复充能稳定接口与 HUD 快照字段。
- [x] 新增 `SealGuardianBoss` 与 Boss 场景。
- [x] 新增 Stage15 Boss 房脚本，接入 `Main` 进度快照与胜利转场。
- [x] 新增 Stage15 压迫段、混合遭遇、挑战支线、Boss 房和完成房。
- [x] 从 Stage14 loop return 房接入 Stage15 前置段。
- [x] 扩展 HUD，显示恢复充能与 Boss 状态。
- [x] 更新 `docs/assets/asset-manifest.md` Stage15 占位需求。
- [x] 修复提交前 QA 发现的混合遭遇 / 挑战支线可绕过风险，并补全清门控回归测试。
- [x] 运行 Godot import、Stage15 专项 GUT、全量 GUT、`git diff --check`。
- [x] 使用 Godot MCP 从 `Main.tscn` 做运行态人工复核。
- [x] MCP 结束后清理 `project.godot` 临时 autoload diff。
- [x] 更新 `docs/progress/` 并进入拆分提交。

## 验证命令

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
git diff --check
```

最终收口复跑结果：

- `godot --headless --path . --import`：通过。
- Stage15 专项 GUT：`11/11 passed`，`102` 个断言。
- 全量 GUT：`107/107 passed`，`777` 个断言。
- `git diff --check`：通过，仅 PowerShell 脚本提示 CRLF/LF 规范化。

## Godot MCP 人工复核

运行入口：

```powershell
.\scripts\dev\enter-worktree-godot-mcp.ps1
```

复核路径：

1. 从 `Main.tscn` 进入或直达 Stage14 loop return。
2. 确认 Stage14 loop return 能进入 `stage15_seal_pressure_room`。
3. 确认混合遭遇房能进入 Boss 房。
4. 确认 Boss 出生点、Boss 状态读值、攻击读招和受击反馈可见。
5. 确认 Recovery Charge HUD 随命中增长，并在满充能后可恢复 1 点生命。
6. 确认失败后回到 Boss 房 checkpoint。
7. 确认 Boss 击败后进入 `stage15_completion_room`。
8. 若 MCP 发现运行态问题，修复后补至少 1 条回归测试。

## 风险

- Boss 当前仍为灰盒单体脚本，不代表正式 Boss 框架。
- Recovery Charge 是运行期战斗容错，不保证跨正式存档持久化。
- Stage 13-15 部分命名仍处于灰盒偏移，后续 Stage16 应继续向东方封妖语境收拢。
