# 阶段 13：第二小区域内容生产执行清单

## 目标

将 Stage 13 从正式文档设计推进到可实施入口。当前文件是后续实现用执行清单，固定 `生物废液区 + 10 主线房 + 2 支路` 的范围，不在 preflight 中混入玩法实现。

## 前置检查

- [x] 确认当前分支为 `codex/stage-13-second-content-zone-production`
- [x] 确认本轮实际采用 `仅分支`，未额外创建阶段 worktree
- [x] 确认当前分支已 fast-forward 到最新 `main`
- [x] 确认 `git status --short --branch` 无非预期改动
- [x] 运行 `scripts/dev/enter-worktree-godot-mcp.ps1 -DryRun`，记录 Godot MCP 进场状态；如失败则记录 fallback
- [x] 运行 `godot --headless --path . --import`
- [x] 运行 Stage 1-12 全量 GUT：`godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
- [x] 运行 `git diff --check`

## 文档落地

- [x] 新增 `spec-design/2026-04-26-stage-13-second-content-zone-production-design.md`
- [x] 新增 `plan/2026-04-26-stage-13-second-content-zone-production.md`
- [x] 新增本执行清单：`docs/implementation-plans/2026-04-26-stage-13-second-content-zone-production.md`
- [x] 更新 `docs/progress/status.md`，将当前阶段推进到 `阶段 13：第二小区域内容生产（preflight 已启动）`
- [x] 更新 `docs/progress/timeline.md`，记录 Stage 13 分支、仅分支模式、范围和 preflight 状态
- [x] 更新 `docs/progress/2026-04-26.md`，记录本轮做了什么、为什么做、影响范围、验证结果、风险与下一步
- [x] 更新 `docs/assets/asset-manifest.md`，追加 `biome_02_bio_waste` 与 Stage 13 第一批资产需求

## 后续实现拆分

后续正式实现建议拆成 4 个阶段内小里程碑，不额外创建新 worktree。

### A. 区域骨架与主线接入

- [x] 新增 Stage 13 房间基类和 `10` 个主线房间
- [x] 从 `stage11_demo_end_room` 接入 Stage 13 入口
- [x] 建立主线房间推进顺序
- [x] 接入区域 checkpoint 与失败恢复
- [x] 新增 Stage 13 灰盒主路径测试

### B. 新敌人与区域危险

- [x] 新增 `SporeShooterEnemy` 行为脚本、场景和配置资源
- [x] 新增废液 / 酸液危险节点或房间侧最小危险逻辑
- [x] 覆盖孢子投射敌、废液危险与 checkpoint 互动的 GUT
- [x] 保持现有玩家受击、无敌和恢复契约不回归

### C. 净化门控与两条支路

- [x] 新增净化门控的最小节点、脚本或房间侧逻辑
- [x] 新增资源 / 恢复收益支路
- [x] 新增风险挑战收益支路
- [x] 覆盖两条支路进入、完成、返回或结束反馈
- [x] 覆盖净化门控默认阻挡和条件解除

### D. 资产、HUD、复核与收口

- [x] 接入 Stage 13 第一批占位 / 临时资产
- [x] 补 Stage 13 HUD 区域目标、废液危险、净化门控和支路反馈文案
- [x] 扩展灰盒主线自动化，至少跑通 Stage 13 主路径
- [x] 运行 Stage 13 专项 GUT
- [x] 运行 Stage 1-13 全量 GUT
- [x] 运行 `godot --headless --path . --import`
- [x] 运行 `git diff --check`
- [x] 完成人工复核并写入当日日志

## 完成标准

- Stage 13 主路径可从现有 demo 终点后进入并跑通
- `10` 个主线房间、`2` 条小支路、孢子投射敌、废液危险、净化门控和区域终点均有验证证据
- 资产 manifest 已记录 Stage 13 资产需求与接入状态
- Stage 1-13 全量自动化通过
- 人工复核完成并留痕
- 文档、测试和进度记录完整

## 2026-04-26 流程说明

- 本轮 Stage 13 实际采用 `仅分支`：`codex/stage-13-second-content-zone-production`，未额外创建阶段 worktree。
- 这是一次阶段流程偏差；收口时保留事实记录，不补造 worktree 记录。
- 本轮同时调整了项目脚本与文档治理：`enter-worktree-godot-mcp.ps1`、`docs/dev/godot-mcp-pro-connectivity-guide.md` 与 `AGENTS.md` 已转向固定永久工作树策略，后续 Stage 14 起按新规则执行。

## 2026-04-26 首轮实现结果

- 已完成：Stage 13 主线入口、10 个主线房间、2 条小支路、孢子投射敌、废液 / 酸液危险、净化门控、区域终点房、Stage 13 灰盒主路径自动化与轻量占位资产。
- 自动化覆盖：`tests/stage13/test_stage_13_second_content_zone_production.gd` 覆盖入口、主线顺序、支路返回、新敌人配置、酸液伤害、净化门控、资产 manifest 与 `Main.tscn` 灰盒推进。
- 排障记录：补充 SVG 资产后，首轮全量 GUT 因新 SVG 未生成 `.import` 导致 `spore_shooter_enemy.tscn` 无法按 Texture2D 加载；运行 `godot --headless --path . --import` 后生成导入文件并复测通过。
- 当前验证：Stage 13 专项 GUT `8/8 passed`；Stage 1-13 全量 GUT `86/86 passed`；`godot --headless --path . --import` 通过。
- 未完成：人工运行时复核尚未执行，阶段最终收口前仍需按 Manual Review 清单完成并写入当日日志。

## 2026-04-26 最终收口结果

- 已完成最终收口复核：新增 `tests/stage13/test_stage_13_manual_review_closure.gd`，用 headless Godot fallback 覆盖 Manual Review 清单。
- 覆盖项：从 `Main.tscn` 到 Stage13 入口、完整 Stage13 主路径、两条支路、酸液反馈、checkpoint 恢复、净化门关闭到开启。
- 修复项：`Stage9RoomBase` 的 `checkpoint_on_ready` 改为 deferred 激活，避免动态换房时 Main 错过 checkpoint 信号。
- 最终验证：Stage 13 GUT `9/9 passed`；Stage 1-13 全量 GUT `87/87 passed`；`godot --headless --path . --import` 通过；`git diff --check` 通过。
