# Nano Hunter Timeline

## 2026-04-26

- 修正阶段型开发默认工作树策略：后续默认采用 `固定永久工作树 + 阶段分支`，主工作区保持 `main` 稳定现场，固定永久工作树复用为阶段开发与 Godot MCP 人工复核现场；Codex 托管临时 worktree 仅用于短期并行探索或一次性任务。
- 记录 Stage13 流程偏差：本轮实际在主路径上切到 `codex/stage-13-second-content-zone-production` 分支开发，而不是独立固定永久工作树；后续 Stage14 起应恢复规范结构。
- Stage 13 最终收口复核完成：新增 `tests/stage13/test_stage_13_manual_review_closure.gd`，用 headless Godot fallback 从 `Main.tscn` 驱动到 Stage 13，并覆盖主路径、两条支路、酸液反馈、checkpoint 恢复和净化门控。
- Stage 13 收口复核发现并修复 checkpoint 时序问题：`checkpoint_on_ready` 在动态换房时可能早于 `Main` 绑定信号发出，导致 Stage13 压力房失败恢复回 Stage11 终点；现改为 `call_deferred("activate_checkpoint")`，复测通过。
- Stage 13 收口 fresh 验证通过：`godot --headless --path . --import` 通过；Stage 13 GUT `9/9 passed`；Stage 1-13 全量 GUT `87/87 passed`；`git diff --check` 通过。
- 将 `codex/stage-13-second-content-zone-production` 以“仅分支”模式本地合并回 `main`，merge commit 为 Stage 13 第二小区域收口点；本轮无阶段 worktree 需要清理，后续 Stage14 起恢复固定永久工作树策略。
- Godot MCP 固定工作树流程精简：`enter-worktree-godot-mcp.ps1` 改为日常唯一入口，stale-only 场景改为重开 Codex 前先确认没有其他活跃 Godot MCP 会话，再执行 `-ResetBeforeReopen -ConfirmNoOtherGodotMcpSessions` 清旧 bridge；`AGENTS.md` 与 `docs/dev/godot-mcp-pro-connectivity-guide.md` 已同步为固定永久工作树规则。
- Stage 13 正式开发首轮实现落地：新增 `生物废液区` 10 个主线房间、2 条小支路、`SporeShooterEnemy`、废液 / 酸液危险、净化门控、Stage11 终点后的继续入口、Stage13 灰盒主路径测试与轻量占位资产。
- Stage 13 首轮自动化验证通过：先以专项红测锁定 `生物废液区 + 10 房 + 2 支路` 契约，再推进到 Stage 13 专项 GUT `8/8 passed`；补 SVG 占位资产后全量 Stage 1-13 GUT `86/86 passed`。
- Stage 13 排障记录：首轮全量 GUT 曾因新 SVG 资产尚未执行 Godot import 导致 `spore_shooter_enemy.tscn` 的 Texture2D 资源加载失败；运行 `godot --headless --path . --import` 生成 `.import` 后复测全绿。

- 从最新 `main` fast-forward 当前 `codex/stage-13-second-content-zone-production` 分支，确认 Stage 13 preflight 以 Stage 12 已合并的稳定 demo 基线为前置；本轮实际采用 `仅分支`，未额外创建阶段 worktree。
- 启动 `阶段 13：第二小区域内容生产` 正式文档设计：新增 `spec-design/2026-04-26-stage-13-second-content-zone-production-design.md`、`docs/implementation-plans/2026-04-26-stage-13-second-content-zone-production.md` 与 `plan/2026-04-26-stage-13-second-content-zone-production.md`。
- Stage 13 范围固定为 `生物废液区 + 10 个主线房间 + 2 条小支路`，新增第 4 类敌人 `孢子投射敌`、区域危险 `废液池 / 酸液地形` 与区域门控 `净化门控`；本轮为 preflight 文档落地，不进入玩法实现。
- 追加 Stage 13 资产需求到 `docs/assets/asset-manifest.md`：`biome_02_bio_waste`、废液平台 / 背景、净化门 / 节点、孢子投射敌轮廓、废液危险提示与区域终点装置。
- 完成 Stage 13 preflight fresh baseline：Godot MCP dry-run 输出 `SafeOpenEditor`，`godot --headless --path . --import` 通过，Stage 1-12 全量 GUT `78/78 passed`，`git diff --check` 通过。
- 复查 Stage 12 正式计划、实现计划、资产清单、人工复核记录与当前 diff 后，补齐 slash / hit spark 的运行时轻量接入，确认 Stage 12 已满足退出条件；`docs/progress/status.md` 已更新为“阶段 12 已完成，待合并回 main”，实现计划 checkbox 已标记完成。
- 将 `codex/stage-12-asset-pipeline-and-demo-polish` 以“分支 + worktree”模式本地合并回 `main`，merge commit 为 `f00ab48`；本轮合并范围包含资产管线、轻量视觉资产、Stage 12 专项测试、项目级 `.codex/config.toml` 与进度文档。
- 在 `main` 上完成 Stage 12 合并后最终验证：`godot --headless --path . --import` 通过，Stage 1-12 全量 GUT `78/78 passed`，`git diff --check` 通过。
- 清理 Stage 12 开发现场：`git worktree list` 仅剩主工作区，本地分支 `codex/stage-12-asset-pipeline-and-demo-polish` 已删除，`.worktrees/stage-12-asset-pipeline-and-demo-polish` 物理目录已删除，`6505-6509` 旧 bridge 监听已释放。
- 根据收口复核反馈，同步修正 `AGENTS.md` 当前默认目标：当前 `main` 已完成并收口阶段 12，下一阶段默认进入 `阶段 13：第二小区域内容生产`。
- 根据 review 反馈恢复 `AGENTS.md` 中 Stage 12-16 roadmap 的历史起点表述，并新增阶段收口规则：阶段完成并合并回 `main` 后必须同步更新“当前默认目标”。
- 收敛 Godot MCP Pro 项目约定：项目级 `.codex/config.toml` 作为 MCP 注册入口；`scripts/dev/check / safe-repair / force-repair / open / enter-worktree` 保留为 bridge、编辑器与 worktree 排障工具。
- 收紧 Godot MCP bridge 收口规则：阶段收口优先定位并释放当前阶段 / 当前 worktree 对应旧 bridge；无法归属且可能存在其他活跃会话时，不默认释放所有 `6505-6509` bridge。
- 补充阶段收口远端同步规则：阶段收口并合并回 `main` 后，若主线验证通过且用户没有要求暂缓，应默认 push 到 `origin/main` 并记录结果。
- 尝试将规则提交 `f95c0f2` push 到 `origin/main`，但连接 GitHub `443` 端口超时；本轮记录为远端同步失败，待网络恢复后重试。
- 使用恢复后的 Godot MCP 完成 Stage 12 完整运行态人工复核：从 `Main.tscn` 起点灰盒驱动到 `stage11_demo_end_room`，覆盖教程、战斗、目标房、Stage9 五房间、Stage10 主房、Stage10 挑战房与 Demo 终点。
- 补充复核 Stage10 支线、挑战房、失败重试、Demo 完成与 replay 重开：支线恢复点 / 收集反馈成立，挑战房奖励反馈成立，终点房失败后回到终点 checkpoint，完成后可返回教程房重新开始。
- 视觉复核发现 HUD 目标图标把三联 SVG 整张压入单图标位，并且长目标文本在 640x360 下有压字风险；已将 HUD 战斗面板加宽加高，并将 `ObjectiveIcon` 改为 `AtlasTexture` 截取单个目标图标区域。
- Stage 12 完整复核后的 fresh 验证通过：`godot --headless --path . --import` 通过，Stage 12 专项 GUT `9/9 passed`，Stage 1-12 全量 GUT `78/78 passed`，`git diff --check` 通过；`project.godot` 已清理 MCP 临时 autoload 注入且无 diff。
- 将 Godot MCP 临时 autoload 的清理节奏写回 `AGENTS.md`，并按复核反馈压缩为短规则：复核期间保留临时注入，全部 MCP 运行态检查结束后再清理 `project.godot` diff；清理后若继续使用 MCP，需重新注入并确认连通。

- 用户重开会话后，继续按 `docs/dev/godot-mcp-pro-connectivity-guide.md` 排查 Stage 12 worktree 的 Godot MCP 联通问题。
- 执行 `scripts/dev/enter-worktree-godot-mcp.ps1 -ForceKillBridge` 后，旧 `6505-6509` bridge 监听已释放；随后当前会话的 `godot-mcp-pro` bridge 延迟监听到 `6505`。
- 运行 `scripts/dev/open-worktree-godot.ps1` 打开当前 Stage 12 worktree 的 Godot 编辑器后，脚本层复测达到 `RecommendedAction: AlreadyConnected`，编辑器进程已连接到 `127.0.0.1:6505`。
- 第二次重开会话后，脚本层仍为 `AlreadyConnected`，本轮对话内 `mcp__godot_mcp_pro__.detect_circular_dependencies` 成功返回 `has_circular=false`；Godot MCP 工具层已恢复，可继续 Stage 12 运行态人工复核。
- 使用恢复后的 MCP 工具启动 `Main.tscn` 并成功截取 `640x360` 首屏截图；人工目视确认 Stage 12 首屏 HUD 图标与玩家轮廓可见。临时截图文件已删除，完整 demo 人工复核仍待继续。

## 2026-04-25

- 在 `codex/stage-12-asset-pipeline-and-demo-polish` worktree 中完成 Stage 12 首轮实现：新增 `docs/assets/asset-manifest.md`、`docs/assets/asset-ingestion-checklist.md`、资产目录结构、第一批占位 SVG、玩家 / 三类敌人轻量轮廓标记、HUD 图标槽、Stage9 门控 / checkpoint 提示与终点房方向提示。
- 新增 `tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd`，按 TDD 先确认资产目录 / 清单 / 视觉节点 / HUD 图标缺失的红灯，再推进到 Stage 12 专项 GUT `8/8 passed`。
- 重新确认 Stage 12 自动化基线：`godot --headless --path . --import` 通过，Stage 1-12 全量 GUT `77/77 passed`，`git diff --check` 通过。
- 复测 Godot MCP 联通性：脚本仍输出 `RecommendedAction: ReopenSessionThenForceKillBridge`，MCP 工具仍报告 `Godot editor is not connected`；本轮记录为“运行态人工复核待重开会话 / bridge 恢复后补做”，不在当前会话强杀旧 bridge。
- 从已合并 Stage 12-16 路线的最新 `main` 创建 `codex/stage-12-asset-pipeline-and-demo-polish` 与 `.worktrees/stage-12-asset-pipeline-and-demo-polish`，作为阶段 12 的隔离开发现场。
- 在 stage12 worktree 中启动 preflight：新建设计文档 `spec-design/2026-04-25-stage-12-asset-pipeline-and-demo-polish-design.md`、正式计划 `plan/2026-04-25-stage-12-asset-pipeline-and-demo-polish.md` 与实现计划 `docs/implementation-plans/2026-04-25-stage-12-asset-pipeline-and-demo-polish.md`。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 12：资产管线与第一轮 Demo 表现升级（preflight 已启动）”，并明确本轮固定采用 `规范 + 轻替换`，阶段收口前必须包含人工复核。
- 运行 `scripts/dev/enter-worktree-godot-mcp.ps1 -DryRun` 进行 Godot MCP 进场检查；当前 RecommendedAction 为 `ReopenSessionThenForceKillBridge`，本轮 preflight 先记录该状态并使用 headless 自动化验证作为 fresh 基线。
- 完成 Stage 12 preflight fresh baseline：`git diff --check` 通过，`godot --headless --path . --import` 通过，Stage 1-11 全量 GUT `69/69 passed`。
- 在 `codex/stage-11-playable-demo-slice` worktree 中补写 Stage 11 灰盒主线自动化设计与实现计划，目标从“真人手操补最终复核”扩展为“先形成一条可重复自动化主线基线”。
- 新增 `tests/stage11/support/stage11_graybox_mainline_driver.gd` 与新的 Stage 11 灰盒主线测试入口，让测试从“驾驶器未实现”的红灯推进到当前 `5/5 passed` 的绿灯状态。
- 本轮同时确认并补平了一个生产主线缺口：`GoalTrialRoom` 完成后现在会真实接入 `stage9_zone_entry_room`，灰盒主线自动化不再需要测试侧过桥。
- 在补平该缺口后，重新确认 `stage7`、`stage11`、`Stage 1-11 全量 GUT`、`godot --headless --path . --import` 与 `git diff --check` 全部通过；当前 worktree 已达到 Stage 11 可收口的自动化基线。
- 新增 `scripts/dev/check-godot-mcp.ps1`、`scripts/dev/repair-godot-mcp.ps1`、`scripts/dev/open-worktree-godot.ps1` 与公共函数文件 `scripts/dev/godot-mcp-common.ps1`，把新 worktree 进场时的 Godot MCP 检查 / 修复 / 打开流程工程化。
- 在上述基础上继续新增 `scripts/dev/enter-worktree-godot-mcp.ps1`，把 `check -> repair -> open` 收敛成单命令入口，并通过 `-DryRun` 验证串联流程正常。
- 针对“清掉旧 bridge 也可能把当前会话自己的 bridge 一起清掉”的约束，再新增 `scripts/dev/safe-repair-godot-mcp.ps1`，并把一键入口默认切换到安全模式；默认只关闭当前 worktree Godot 编辑器，不默认杀 bridge，只有显式 `-ForceKillBridge` 才会清 bridge。
- 新增 `docs/dev/godot-mcp-pro-connectivity-guide.md`，并在 `AGENTS.md` 中显式要求后续 session 遇到 Godot MCP 联通问题时优先阅读该文档。
- 在 Stage 11 已收口到 `main` 后，新建 `codex/stage-12-16-roadmap` 分支，以“仅分支”模式补写后续路线设计，不额外创建 worktree；本轮只修改路线与进度文档，不进入 Stage 12 实现。
- 新增 `spec-design/2026-04-25-stage-12-to-stage-16-roadmap.md`，正式固定 Stage 12-16 的大颗粒度路线：Demo 反馈与资产管线、第二小区域、回溯与能力门控、精英 / Boss 原型、Alpha Demo 打包候选。
- 同步更新 `docs/progress/status.md` 与当日日志，明确 Stage 12 下一步应先做独立设计与 preflight，并把资产清单 / 资产目录规范作为 Stage 12 的优先入口。
- 根据用户确认，将 Stage 12-16 路线升级为“加厚版”：每个阶段增加内容、资产、验证与 polish 量，同时新增阶段容量上限，避免因扩大范围重新回到频繁开 worktree 或阶段失控。
- 根据用户复核反馈，继续将 Stage 12-16 路线同步到项目级 `AGENTS.md`，补齐当前默认目标、阶段 12-16 检查点、阶段容量上限、资产策略和 subagents 默认许可，避免后续 session 只读 `AGENTS.md` 时仍停留在 Stage 9-11 视角。

## 2026-04-24

- 从已完成注释补强并同步到 `main` 的稳定基线建立 `codex/stage-11-playable-demo-slice` 与 `.worktrees/stage-11-playable-demo-slice`，作为阶段 11 的唯一开发入口。
- 在 stage11 worktree 中启动 preflight：新建设计文档 `spec-design/2026-04-24-stage-11-playable-demo-slice-design.md` 与实现计划 `docs/implementation-plans/2026-04-24-stage-11-playable-demo-slice.md`。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 11：可交付试玩 Demo 切片（设计与 preflight 中）”，并明确本轮固定采用“扩成完整 Demo、复用 stage9-10、不新增新机制、显式要求注释补强”的方案。
- 完成 stage11 preflight fresh 基线验证：`godot --headless --path . --import` 通过，Stage 1-10 GUT `64/64 passed`，`git diff --check` 通过。
- 在 `codex/comment-coverage-hardening` 中补强阶段 1-10 的关键脚本与测试注释，并同步收紧 `AGENTS.md` 的注释规则：保留“少而精”，但新增“文件头职责注释、关键流程分段注释、阶段测试文件头说明”的最低覆盖要求。
- 从最新 `main` 建立 `codex/stage-10-combat-variation-and-light-progression` 与 `.worktrees/stage-10-combat-variation-and-light-progression`，作为阶段 10 的唯一开发入口。
- 在 stage10 worktree 中启动 preflight：新建设计文档 `spec-design/2026-04-24-stage-10-combat-variation-and-light-progression-design.md` 与实现计划 `docs/implementation-plans/2026-04-24-stage-10-combat-variation-and-light-progression.md`。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 10：战斗变化与轻量成长循环（设计与 preflight 中）”，并明确本轮固定选择为 `空中攻击`、第 `3` 类普通敌人、`恢复点 + 收集物`、`1` 条可选支路与 `1` 个挑战房。
- 在 `codex/stage-8-systems-hardening-and-content-prep` worktree 中完成 Stage 8 首轮实现：新增玩家配置资源、房间流程配置资源、基础敌人配置资源，并把当前关键参数从脚本导出字段收口到只读资源。
- 新增 `scripts/combat/base_enemy.gd`，将 `BasicMeleeEnemy` 从单体原型收口为基于基础契约的最小模板入口，同时保留 `receive_attack(...)` 与 `defeated` 契约。
- 收口 HUD 第二轮接口：房间侧新增 `get_hud_context()`，玩家侧新增 `get_hud_status_snapshot()`，`TutorialHUD` 改为统一消费只读快照而非继续依赖零散 `get()` 探测。
- 新增 `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`，覆盖玩家配置应用、房间 HUD 上下文、基础敌人配置应用与模板契约。
- 在当前会话中重新定位 `godot-mcp` 阻塞：清理旧 `6505-6509` 监听后仍无法恢复工具直连，确认当前问题不再是旧 bridge 占端口，而是 Codex 侧 bridge 未在本会话重新建立监听；本轮改用 shell + headless 验证完成 fallback。
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 GUT 与 `git diff --check` 全部通过，确认 Stage 8 当前结果已达到“可作为继续扩内容前稳定基线”的首轮退出条件。

## 2026-03-31

- 初始化 `nano-hunter` 的 Godot 4.6 工程并建立基础仓库结构。
- 建立项目级 `AGENTS.md`、`docs/progress/` 与 `spec-design/` 留痕体系。
- 关闭当前阶段不兼容的 `better-terrain` 激活，保留 `godot_mcp` 与 `gut` 作为默认启用插件。
- 完成 `阶段 1：可启动骨架` 的基础入口：`Main.tscn`、占位玩家、测试房间与启动入口验证。

## 2026-04-01

- 完成 `阶段 1` 的显示与相机调优：固定基准分辨率、整数倍缩放、留边策略与测试房间相机边界。
- 补齐阶段 1 的设计文档、实现计划与进度留痕。
- 将阶段 1 的稳定结果合并回 `main`，形成第一版可启动、可看、可调的试玩检查点。

## 2026-04-06

- 基于阶段 1 的实践经验，收敛分支与 worktree使用策略，明确“小任务默认仅分支，阶段开发默认分支 + worktree”。
- 新建设计文档 `spec-design/2026-04-06-branch-and-worktree-strategy.md`，明确“仅分支”与“分支 + worktree”的适用条件。
- 将 `codex/branch-vs-worktree-policy` 合并回 `main` 并删除分支，同时保留 `codex/stage-2-movement-feel` 作为阶段 2 的开发入口。

## 2026-04-10

- 基于阶段 1 与阶段 2 的执行差异，补充“默认开发节奏”治理规则，明确它是对 `AGENTS.md` 现有“大功能 / 小改动”分流的执行层细化，而不是替代规则。
- 在 `AGENTS.md` 中新增“大功能默认节奏”“小改动默认节奏”与对应决策规则，统一 `brainstorming`、`subagent`、`worktree` 与提交次数的默认用法。
- 新建设计留痕 `spec-design/2026-04-10-development-cadence-standardization.md`，说明为什么要把阶段型开发节奏从聊天约定提升为项目内显式规范。
- 新增实现计划 `docs/implementation-plans/2026-04-10-development-cadence-standardization.md`，把本次治理修订限定为文档与规则收口，不混入额外玩法实现。
- 更新 `docs/progress/status.md`、`docs/progress/timeline.md` 与当日日志，明确后续阶段 3、4、5 默认沿用大功能节奏，文档修订、配置调整与单点 bugfix 则沿用小改动节奏。
- 重新建立本地 `codex/stage-2-movement-feel` 分支与 `.worktrees/stage-2-movement-feel` 隔离工作区，避免在带未提交改动的主工作区上直接推进阶段 2。
- 新增阶段 2 设计留痕，锁定本轮只做基础移动手感，不做冲刺、攻击、HUD 与房间系统重构。
- 收口 `project.godot`：加入 `move_left`、`move_right`、`jump` 命名输入动作，并保持 `better-terrain` 编辑器插件禁用。
- 将占位玩家演进为可控原型，加入 `idle / run / jump_rise / jump_fall / land` 状态、导出调参字段，以及 `coyote time`、`jump buffer`、`可变跳高`。
- 扩展 `TestRoom`，加入中段平台，覆盖阶段 2 的基础平台移动验证路径。
- 新增 `tests/stage2/test_stage_2_movement_feel.gd`，验证输入契约、状态契约、跑停、跳跃、可变跳高、`coyote time` 与 `jump buffer`。
- 明确后续阶段安排：攻击放 `阶段 3`，冲刺优先放 `阶段 4`，HUD 与房间系统重构放 `阶段 5`。
- 为补做 GUI 手动试玩，同步阶段 2 worktree 中的 `godot_mcp` 到 `1.10.1`，并恢复工程依赖的项目级 autoload，收口 Godot MCP 的项目侧兼容问题。
- 在后续接续中于沙箱外重新确认 `godot --headless --path . --import`、阶段 1 GUT 与阶段 2 GUT 均通过，确认当前 worktree 自动化基线仍为绿色。
- 将 GUI 阻塞进一步收敛为当前 Codex 桌面线程拿不到编辑器侧连接，而不是阶段 2 worktree 的项目配置回退。
- 清理误开的开发现场：
  - 仓库根工作区已切回 `main`
  - 误开的本地分支 `stage-2-movement-feel` 已删除
  - 只保留 `.worktrees/stage-2-movement-feel` 作为阶段 2 工作树
  - 外部 `f400` worktree 已从 Git worktree 元数据移除，但其物理目录仍被 `Codex.exe` 占用，待关闭对应桌面窗口后再删

## 2026-04-11

- 恢复当前会话的 Godot 编辑器侧 MCP 连接，重新获得阶段 2 的编辑器复核能力。
- 在阶段 2 编辑器复核中发现 `project.godot` 的命名动作只有动作名、没有静态默认键位，补写回归测试后确认该缺口会直接让阶段 2 工程基线测试转红。
- 将 `move_left`、`move_right`、`jump` 的默认键位静态写入 `project.godot`，使项目配置、编辑器侧验证和运行时输入契约重新对齐。
- 重新确认 `godot --headless --path . --import`、阶段 1 GUT 与阶段 2 GUT 均通过，将阶段 2 状态从“待 GUI 复核”更新为“已完成，待进入阶段 3”。
- 修复当前 codex/stage-2-movement-feel worktree 的 Git 索引损坏，恢复 git status 与 git diff --check。
- 将 codex/stage-2-movement-feel 本地合并回 main，并在主线结果上重新确认 --import、阶段 1 GUT、阶段 2 GUT 与 git diff --check 全部通过。

## 2026-04-20

- 将当前一组 `godot_mcp` 相关改动确认为插件正常更新，而不是临时实验；本轮按主线小改动收口，不与阶段 3 玩法实现混做。
- 本轮 MCP 更新包含：
  - 插件版本从 `1.10.1` 升级到 `1.12.0`
  - 插件退出时只清理“本 session 注入的 autoload”
  - `command_router` 接入 Android 相关命令
  - `base_command` 改进游戏用户目录解析逻辑
- 将 `.mcp.json` 明确保留为本地配置，并加入本地 Git 忽略，而不是写入项目级 `.gitignore`。
- 从收口后的 `main` 建立 `codex/stage-3-combat-feel` 与 `.worktrees/stage-3-combat-feel`，作为阶段 3 的隔离开发现场。
- 在阶段 3 worktree 中启动设计文档、实现计划、状态页、时间线与当日日志，锁定第一轮范围为“攻击 + 木桩目标”，暂不写入实际战斗实现。
- 新建设计文档 `spec-design/2026-04-20-stage-3-combat-feel-design.md`，明确本轮只做玩家普通攻击、固定木桩目标、命中反馈与基础受击反馈。
- 新增实现计划 `docs/implementation-plans/2026-04-20-stage-3-combat-feel.md`，把阶段 3 拆为输入契约、玩家攻击、木桩目标、阶段 3 GUT 与文档收口五个实施项。
- 将 worktree 内 `docs/progress/status.md` 从“阶段 2 已完成”推进到“阶段 3 设计准备中”，让后续 session 进入时能直接读到当前战斗阶段目标。

## 2026-04-21

- 补充阶段 3 与阶段 4 的“打击感反馈分层约定”，明确阶段 3 允许做基础可读性反馈，更强反馈留到阶段 4 结合能力差异评估。
- 在 `project.godot` 中新增 `attack` 动作与默认键位，将阶段 3 输入契约静态写回工程配置。
- 将占位玩家增量演进为支持地面普通攻击的原型：新增 `attack` 状态、前方命中范围、单次攻击单次命中与攻击恢复逻辑。
- 新增 `TrainingDummy` 场景与脚本，并将其接入 `TestRoom`，建立固定木桩目标与最小受击反馈。
- 新增 `tests/stage3/test_stage_3_combat_feel.gd`，覆盖输入契约、攻击状态、命中朝向、单次命中与木桩契约。
- 重新确认 `godot --headless --path . --import`、阶段 1 GUT、阶段 2 GUT、阶段 3 GUT 与 `git diff --check` 全部通过；`--import` 退出时仍保留 `ObjectDB instances leaked at exit` 历史警告。
- 当晚继续微调 Stage 3 时，清理当前 worktree 的 `.godot` 缓存后暴露出 `project.godot` 的历史配置风险：`autoload` 仍保留 `BetterTerrain`，且插件入口使用 `uid://...` 引用。
- 修复 `project.godot`：移除 `BetterTerrain` autoload，并将 `DialogueManager`、`ControllerIcons` 改回 `res://...` 路径引用，避免冷启动后再次触发 `Unrecognized UID` 与 `better-terrain` 解析错误。
- 修复后重新确认 `godot --headless --path . --import`、阶段 1 GUT、阶段 2 GUT 与 `git diff --check` 通过。
- 当前仍存在单独阻塞：Stage 3 的 GUT 入口会触发 Godot signal 11 崩溃，尚未定位到最终根因。
- 进一步缩小 Stage 3 GUT 崩溃范围：确认 `test_stage_3_combat_feel.gd` 可以在健康的 Stage 1 GUT 上下文中被加载、反射、实例化并手动执行单条测试方法，因此当前更像是 “GUT 将其作为独立目标测试入口运行” 的链路在 Godot 4.6 下不稳定，而不是 Stage 3 测试脚本内容本身立即崩溃。
- 将 Stage 3 GUT 崩溃继续前移定位：确认 Stage 1 / Stage 2 的 `-gtest` 目标仍可正常进入 `gut_cmdln` 入口，而 Stage 3 目标、缺失脚本目标与非测试脚本目标都会在 `gut_cmdln.gd` `_init()` 之前触发 Godot `signal 11`，因此当前更像是目标路径启动链异常，而不是 Stage 3 测试逻辑本身立即崩溃。
- 通过稳定入口恢复 Stage 3 自动化回归：保留 `tests/stage3/test_stage_3_combat_feel.gd` 作为真实测试定义，在 `tests/stage2/test_stage_2_movement_feel.gd` 中新增 5 条 `test_stage_3_bridge_*` 包装测试，重新确认 `Stage 2 + Stage 3 bridge` 命令达到 `12/12 passed`。
- 将 `project.godot` 中实际残留的 `BetterTerrain` autoload 真正移除，与当前阶段“不启用 better-terrain”的项目规范重新对齐。
- 用户补充 Windows 崩溃弹窗，确认 Stage 3 独立入口触发的是 Godot Win64 原生访问冲突（空指针附近 `0x58` 读错误）。
- 在干净复现里进一步确认：Stage 3 独立 `-gtest` 可以跑到 `GutRunner.quit`，但会在原生退出阶段触发 `signal 11`；只跑最简单的输入契约单测也同样崩溃。
- 临时最小探针 `tests/stage1/test_probe_minimal.gd` 证明“新增独立测试脚本目标”也可能触发同类问题；删除探针并重新导入后，Stage 1 独立入口恢复通过。
- 继续对 `tests/stage3/test_stage_3_combat_feel.gd` 做同路径二分后确认：将该文件整份重写并规范化后，Stage 3 独立 `-gtest` 恢复正常，说明先前崩溃更像是该文件文本/编码状态异常，而不是 Stage 3 玩法测试逻辑本身错误。
- 移除 Stage 2 中为绕过崩溃而添加的 `test_stage_3_bridge_*` 临时桥接，恢复独立的 Stage 3 suite 入口。
- 补充 `AGENTS.md` 中的“测试文件异常排查约定”，把本轮 Stage 3 GUT 文本状态异常的高置信度排查经验沉淀为后续默认排查顺序。
- 重新以 fresh 验证确认 `godot --headless --path . --import`、阶段 1 GUT、阶段 2 GUT、阶段 3 GUT 与 `git diff --check` 全部通过，确认 Stage 3 已达到可合并里程碑。
- 将 `codex/stage-3-combat-feel` 以“分支 + worktree”模式本地合并回 `main`，并清理 `.worktrees/stage-3-combat-feel`，使主线进入“阶段 3 已完成，待进入阶段 4”的稳定状态。

## 2026-04-22

- 从当前 `main` 建立 `codex/stage-4-minimal-ability-difference` 与 `.worktrees/stage-4-minimal-ability-difference`，作为阶段 4 的唯一开发入口。
- 新建设计文档 `spec-design/2026-04-22-stage-4-minimal-ability-difference-design.md`，固定本轮能力形式为“仅地面冲刺”，验证形式为“TestRoom 混合验证”。
- 新增实现计划 `docs/implementation-plans/2026-04-22-stage-4-minimal-ability-difference.md`，把阶段 4 拆为 preflight、冲刺状态、TestRoom 门槛、轻量反馈、自动化验证与文档收口五个实施项。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 4 已启动，设计与 preflight 已完成”，并明确延后项归属：哪些留在阶段 4、哪些明确留给阶段 5、哪些继续后延。
- 将修正后的 `subagent` / `multi-agent` 规则同步到当前 worktree 的 `AGENTS.md`，使阶段 4 后续实现默认主动评估代理协作，而不是默认主代理单线推进。
- 完成 fresh preflight 的首轮验证：`.worktrees` 忽略检查通过，`godot --headless --path . --import` 通过，Stage 1 GUT 与 Stage 2 GUT 通过。
- 复核确认 Stage 3 独立 `-gtest` 本身未回归失败；使用沙箱外稳定运行方式后，`main` 与 stage4 worktree 中的 Stage 3 GUT 都恢复 `5/5` 通过。
- 因此阶段 4 当前状态更新为“preflight 已完成，可进入实际实现”。
- 进入阶段 4 的第一批实际实现：在 `project.godot` 与 `scripts/main/main.gd` 中接入 `dash` 输入契约，在 `scripts/player/player_placeholder.gd` 中加入仅地面 `dash` 状态、方向规则、持续时间、速度与冷却时间。
- 新增 `tests/stage4/test_stage_4_minimal_ability_difference.gd`，覆盖阶段 4 的最小能力差异核心契约，并确认 `6/6` 通过。
- 扩展 `scenes/rooms/test_room.tscn`，加入 `DashGapLeft`、`DashGapRight` 与 `DashCombatDummy`，作为阶段 4 的最小探索 / 战斗门槛节点。
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 GUT 与 `git diff --check` 全部通过。
- 通过 Godot MCP Pro CLI 与内置 MCP 工具复核运行态，确认 `Main/TestRoom/Runtime/PlayerPlaceholder` 与 stage4 新节点全部进入运行树，并成功触发一次 `dash` 位移。
- 在第二轮 stage4 收敛中，将 `TestRoom` 从“有节点但价值不清晰”进一步推进为真正的验证区：加入 `FloorRight` 与 `DashGateCeiling`，把地面缺口和低顶组合成明确的仅地面 dash 门槛。
- 同时回调 `dash` 默认参数：将 `dash_duration` 提高到 `0.24`、`dash_speed` 提高到 `440.0`，让 stage4 默认手感更贴近“能力差异”而不是“擦线可用”。
- 将 `tests/stage4/test_stage_4_minimal_ability_difference.gd` 扩展到 `8/8` 通过，新增探索门槛与战斗接敌价值验证，确认无 dash 无法稳定通过 gate，而 dash 可以稳定通过并更快进入可出手区。
- 再补做一轮运行态人工手感复核，确认低顶 + 缺口构图已经足够表达“仅地面 dash 门槛”，且过门槛后到 `DashCombatDummy` 只需短距离补位即可进入出手区，使阶段 4 进入可收口判断。
- 最后补上最小 dash 可读性反馈：冲刺期间玩家本体切到更亮的冷白色，退出后恢复默认颜色；stage4 自动化同步扩展到 `9/9` 通过，阶段 4 达到可收口状态。
- 将 `codex/stage-4-minimal-ability-difference` 以“分支 + worktree”模式本地合并回 `main`，并在主线上重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 GUT 与 `git diff --check` 全部通过。
- 从当前 `main` 建立 `codex/stage-5-tutorial-vertical-slice` 与 `.worktrees/stage-5-tutorial-vertical-slice`，作为阶段 5 的唯一开发入口。
- 新建设计文档 `spec-design/2026-04-22-stage-5-tutorial-vertical-slice-design.md`，固定本轮采用“单场景线性教程区 + 低压教学 + 能力教学优先”的方案。
- 新增实现计划 `docs/implementation-plans/2026-04-22-stage-5-tutorial-vertical-slice.md`，将阶段 5 拆为主房间契约迁移、`TutorialRoom`、最小 HUD、阶段 5 自动化与文档收口。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 5：教程区垂直切片（设计与开发准备中）”，并明确本轮的主流程目标、历史耦合风险与下一步实现入口。
- 明确阶段 5 的代理协作建议：若写入范围可分离，优先按“`Main` 契约迁移 / `TutorialRoom` + HUD / 测试与文档”三块主动评估 `multi-agent` 并行。

## 2026-04-23

- 在 `codex/stage-5-tutorial-vertical-slice` 中完成阶段 5 的主入口迁移：`Main` 不再硬编码 `TestRoom`，而是默认加载 `TutorialRoom` 并依赖统一主房间契约。
- 新增 `TutorialRoom` 与最小 HUD，建立“移动/跳跃 -> dash -> 攻击 -> 出口”的单场景低压教学切片。
- 新增 `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`，覆盖主入口迁移、教程顺序推进、`dash` 门槛、出口解锁与 HUD 战斗面板布局。
- 收敛 HUD 首屏提示、教程节点布局与 `BattlePanel` 重叠问题，确认当前垂直切片在自动化与运行态证据上都达到可收口状态。
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 GUT 与 `git diff --check` 全部通过，确认阶段 5 已达到稳定基线并可准备合并回 `main`。

## 2026-04-23

- 排查并修复当前 stage5 worktree 中 `godot_mcp` 的会话错连问题：确认旧 `godot-mcp-pro` bridge 残留占用 `6505-6509`，清理旧 bridge 后恢复当前会话与 Godot 的 MCP 连通性。
- 基于这次排障，将“阶段 / worktree 收口时同步确认旧 `godot-mcp-pro` bridge 已退出”的高置信度经验写回 `AGENTS.md`，避免后续 session 重复踩坑。
- 正式进入阶段 5 的第一轮实现：把 `Main` 从固定 `TestRoom` 入口迁移为主房间契约入口，并默认实例化 `TutorialRoom`。
- 新增 `scenes/rooms/tutorial_room.tscn` 与 `scripts/rooms/tutorial_room.gd`，落地单场景线性教学流程：`move / jump -> dash -> attack -> exit`。
- 新增 `scenes/ui/tutorial_hud.tscn` 与 `scripts/ui/tutorial_hud.gd`，接入最小 HUD：提示区 + 战斗面板；战斗面板只做展示，不接正式生命 / 死亡循环。
- 更新 Stage 1 契约测试，移除 `Main -> TestRoom` 的固定耦合假设；新增 `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`，覆盖主房间迁移、教程顺序、`dash` 门槛与出口解锁。
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 GUT 与 `git diff --check` 全部通过。
- 通过运行态 Godot MCP 复核确认 `Main/Room/TutorialDummy`、`Main/HUD/TutorialHUD` 与提示标签全部进入运行树，阶段 5 已从“开发准备中”推进到“首轮可玩实现已落地”。
- 在后续轻量收敛中，补强了 `StepLabel`、首条按键提示文案、首段跳台位置与 `dash -> attack` 的稳定推进条件，使阶段 5 从“能跑通”进一步推进到“教程表达更清楚”。
- 在 HUD 排障中确认 `BattlePanel` 的文本重叠根因是 `PanelContainer` 与手动定位混用；改为普通 `Panel` 后，战斗面板两行文本恢复稳定分离。
- 最终重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 GUT、运行态主入口与 HUD 读值均正常，阶段 5 达到“已完成，形成稳定基线”的里程碑状态。
- 将 `codex/stage-5-tutorial-vertical-slice` 以“分支 + worktree”模式本地合并回 `main`，并在主线上重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 GUT 与 `git diff --check` 全部通过。
- 阶段 5 合并后已删除本地分支 `codex/stage-5-tutorial-vertical-slice`，且 Git worktree 元数据已移除；当前仅剩 `.worktrees/stage-5-tutorial-vertical-slice` 物理目录仍被活动中的 VS Code / Godot 进程占用，待关闭对应窗口后再删。
- 在阶段 1-5 全部完成后，确认后续默认路线收敛为：
  - `阶段 6：最小真实战斗循环`
  - `阶段 7：短链路主流程串联`
  - `阶段 8：系统稳固与内容生产前准备`
- 当前推荐顺序是先补“真实战斗压力”，再补“短主流程串联”，最后再做偏长期的系统稳固与内容生产前准备。
- 新建设计留痕 `spec-design/2026-04-23-stage-6-to-stage-8-roadmap.md`，把阶段 5 完成后的推荐路线、顺序理由与阶段 6-8 边界正式写回仓库。
- 将上述路线收口提交到 `main`：提交 `AGENTS.md`、`status.md`、`timeline.md`、当日日志与 `spec-design/2026-04-23-stage-6-to-stage-8-roadmap.md`，形成“阶段 5 完成后的 stage6-8 路线确认”稳定基线。
- 从干净 `main` 建立 `codex/stage-6-minimal-real-combat-loop` 与 `.worktrees/stage-6-minimal-real-combat-loop`，作为阶段 6 的唯一开发入口。
- 在 stage6 worktree 中启动 preflight：新建设计文档 `spec-design/2026-04-23-stage-6-minimal-real-combat-loop-design.md` 与实现计划 `docs/implementation-plans/2026-04-23-stage-6-minimal-real-combat-loop.md`。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 6：最小真实战斗循环（设计与 preflight 中）”，并明确本轮目标为“独立战斗房 + 基础近战敌人 + 玩家受击 / 生命 / 即时重置”。
- 明确阶段 6 的代理协作建议：若写入范围可分离，优先按“`Main` 与房间切换 / 玩家生命与战斗房 / HUD + 测试 + 文档”三块主动评估 `multi-agent` 并行。
- 完成阶段 6 的首轮 TDD 实现：新增 `CombatTrialRoom`、`BasicMeleeEnemy` 与 `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`，并将 `Main`、玩家、HUD 补齐到“教程后实战压力 + 生命 / 受击 / 即时重置”的最小真实战斗闭环。
- 在收口验证中重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 / 6 GUT 与 `git diff --check` 全部通过，确认阶段 6 已形成阶段 7 的稳定前置基线。
- 在随后的手感收敛中，继续按 TDD 补上“首接敌距离”和“受击后脱离感”的阶段 6 回归约束；仅通过前移 `BasicMeleeEnemy` 初始站位与增强玩家受击击退参数完成最小调参，并再次确认 `--import`、阶段 1 / 2 / 3 / 4 / 5 / 6 GUT 与 `git diff --check` 全部通过。
- 从干净 `main` 建立 `codex/stage-7-short-mainline-chain` 与 `.worktrees/stage-7-short-mainline-chain`，作为阶段 7 的唯一开发入口。
- 在 stage7 worktree 中启动 preflight：新建设计文档 `spec-design/2026-04-23-stage-7-short-mainline-chain-design.md` 与实现计划 `docs/implementation-plans/2026-04-23-stage-7-short-mainline-chain.md`。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 7：短链路主流程串联（设计与 preflight 中）”，并明确本轮只做三段顺序链路：`TutorialRoom -> CombatTrialRoom -> GoalTrialRoom`。
- 明确阶段 7 的代理协作从“建议”升级为“满足条件即必须启用”的实现约束：
  - 代理 A：`Main` 与三段房间流转契约
  - 代理 B：`GoalTrialRoom` 与门控流程
  - 代理 C：HUD 分段提示、Stage 7 GUT 与文档留痕
- 完成 stage7 preflight 的最小核对：`main` 与 stage7 worktree 同时存在，当前改动仅限文档启动记录，尚未进入玩法实现。
- 完成阶段 7 的首轮 TDD 实现：新增 `tests/stage7/test_stage_7_short_mainline_chain.gd`，先以红测确认当前缺口集中在“战斗房未过渡到目标房 / 目标房不存在 / 战斗房失败局部重置回归”三处。
- 将 `Main` 的房间切换逻辑从阶段 6 的定向判断收敛为统一消费房间侧 `room_transition_requested`，并新增 `GoalTrialRoom` 作为第三段混合门控目标房。
- 扩展 `CombatTrialRoom`，让其在清房后能稳定过渡到 `GoalTrialRoom`；同时保持战斗房失败时仍只重置当前房间，不回滚整条短链路。
- 新增 `scenes/rooms/goal_trial_room.tscn` 与 `scripts/rooms/goal_trial_room.gd`，以“击败守门敌人 -> 解锁门控 -> 抵达目标点”的最小结构完成阶段 7 的第三段验证。
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 GUT 与 `git diff --check` 全部通过，确认阶段 7 已达到可作为阶段 8 前置基线的稳定状态。
- 随后补做阶段 7 的完整人工复核：通过真实游戏窗口配合 `godot_mcp` 文件通道读值 / 截图，确认 `TutorialRoom -> CombatTrialRoom -> GoalTrialRoom` 三段链路、战斗房局部重置与目标房“短链路完成”状态都已成立。
- 将 `codex/stage-7-short-mainline-chain` 以“分支 + worktree”模式本地合并回 `main`，并在主线上重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 GUT 与 `git diff --check` 全部通过。
- 阶段 7 收口时，先检查直接指向该 worktree 的进程；Git 侧 worktree 元数据在第一次删除时已移除，但物理目录因 WindowsTerminal 占用未能立即删除。
- 关闭对应的 `WindowsTerminal` 进程后，使用长路径方式成功清理 `.worktrees/stage-7-short-mainline-chain` 物理目录，并删除本地分支 `codex/stage-7-short-mainline-chain`。
- 将 `stage8` 执行版计划写回主线：新增 `docs/implementation-plans/2026-04-23-stage-8-systems-hardening-and-content-prep.md`，固定本轮优先级为“参数数据化 -> HUD 第二轮 -> 敌人模板化”。
- 从干净 `main` 建立 `codex/stage-8-systems-hardening-and-content-prep` 与 `.worktrees/stage-8-systems-hardening-and-content-prep`，作为阶段 8 的唯一开发入口。
- 在 stage8 worktree 中启动 preflight：新建设计文档 `spec-design/2026-04-23-stage-8-systems-hardening-and-content-prep-design.md`。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 8：系统稳固与内容生产前准备（设计与 preflight 中）”，并明确本轮不新增能力、不新增敌人种类、不扩主流程长度。
- 明确阶段 8 的代理协作要求：若写入范围可分离，优先按“配置资源 / HUD 接口 / 敌人模板 + 测试文档”三块实际启用代理协作，而不是只写建议。
- 完成阶段 8 的首轮实现：新增玩家配置资源、房间流程配置资源、基础敌人模板 `base_enemy.gd` 与 Stage 8 GUT，并把 `TutorialHUD`、当前三段房间与 `BasicMeleeEnemy` 收口到稳定只读接口。
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 GUT 与 `git diff --check` 全部通过，确认阶段 8 已达到可作为新稳定基线的收口条件。
- 将 `codex/stage-8-systems-hardening-and-content-prep` 以“分支 + worktree”模式本地合并回 `main`，并在主线上再次确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 GUT 与 `git diff --check` 全部通过。
- 阶段 8 收口时，先关闭直接指向该 worktree 的 Godot 编辑器进程；首次 `git worktree remove` 因 Windows 长路径失败，但 Git 侧元数据已移除。
- 随后改用长路径方式成功清理 `.worktrees/stage-8-systems-hardening-and-content-prep` 物理目录，并删除本地分支 `codex/stage-8-systems-hardening-and-content-prep`。
- 在阶段 6-8 全部完成后，重新评估后续路线，不再沿用原型前半段那种“单个验证点一个阶段”的颗粒度。
- 正式将阶段 9-11 调整为更大颗粒度的内容型阶段：
  - `阶段 9：首个小区域内容生产`
  - `阶段 10：战斗变化与轻量成长循环`
  - `阶段 11：可交付试玩 Demo 切片`
- 新建设计留痕 `spec-design/2026-04-24-stage-9-to-stage-11-roadmap.md`，把阶段 8 完成后的新路线、放大阶段颗粒度的原因与阶段 9-11 边界正式写回仓库。
- 从干净 `main` 建立 `codex/stage-9-first-content-zone-production` 与 `.worktrees/stage-9-first-content-zone-production`，作为阶段 9 的唯一开发入口。
- 在 stage9 worktree 中启动 preflight：新建设计文档 `spec-design/2026-04-24-stage-9-first-content-zone-production-design.md`。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 9：首个小区域内容生产（设计与 preflight 中）”，并明确本轮固定为 `4-6` 房间线性主线区。
- 明确阶段 9 的关键选择：
  - 第 `2` 类敌人：`地面冲锋敌`
  - checkpoint：`房间入口存档点`
  - 门控：`开关门`
  - 区域结构：`线性主线区`
- 完成阶段 9 的首轮 TDD 实现：新增 `tests/stage9/test_stage_9_first_content_zone_production.gd`，先以红测固定“5 房间线性主线区 / GroundChargerEnemy / 开关门 / checkpoint 恢复”四类行为。
- 新增 `GroundChargerEnemy`、`ground_charger_enemy_config.tres` 与 5 个 `stage9_zone_*` 房间场景，将 stage8 的配置化入口首次真正用于小区域内容生产。
- 扩展 `scripts/main/main.gd`，让 `Main` 支持运行期 checkpoint 恢复；stage9 中玩家失败后会从最近一次激活的房间入口恢复，而不是只重置当前房间。
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 / 9 GUT 与 `git diff --check` 全部通过，确认阶段 9 已达到阶段 10 的稳定前置基线。
- 在同一轮收口中复测当前线程的 `godot_mcp` 连通性：重新打开当前 worktree 的 Godot 编辑器后，`mcp__godot_mcp_pro__.get_open_scripts` 成功返回 `count = 0`，说明本会话直连已恢复。
## 2026-04-24 - Stage 10 首轮实现通过自动化验证

- 分支：`codex/stage-10-combat-variation-and-light-progression`
- 模式：`分支 + worktree`
- 范围：按 stage10 文档完成 `空中攻击`、第 `3` 类普通敌人、`恢复点 + 收集物`、`1` 条可选支路与 `1` 个挑战房的最小实现。
- Godot MCP：当前会话内未稳定连通；旧 bridge 清理后，`godot --headless --path . --import` 可启动插件但 headless 结束会断开，MCP 工具仍报告 `Godot editor is not connected`。若后续需要编辑器 MCP，应重开 AI 会话并重新打开当前 worktree 的 Godot 编辑器。
- 验证：`godot --headless --path . --import` 通过；`Stage 1-10 GUT` 通过 `58/58`；`git diff --check` 通过。

## 2026-04-24 - Stage 10 第二轮可玩化接入通过自动化验证

- 分支：`codex/stage-10-combat-variation-and-light-progression`
- 模式：`分支 + worktree`
- 范围：把 stage10 首轮 API / 场景进一步接成可玩链路：`stage9_zone_final_room` 串到 `stage10_zone_aerial_room`，主房间新增 `BranchZone` 可进入支路，恢复点 / 收集物改为玩家位置触发，HUD 新增最小成长反馈行。
- MCP：当前已联通，`get_project_info` 可返回项目路径、主场景与 Godot 版本。
- 验证：`Stage 1-10 GUT` 通过 `62/62`；`git diff --check` 通过。

## 2026-04-24 - Stage 10 MCP 复核发现并修复出生点掉落

- 分支：`codex/stage-10-combat-variation-and-light-progression`
- 范围：用 Godot MCP 直达 `stage10_zone_aerial_room`、支路房与挑战房做运行态复核。
- 发现：`stage10_*_start` 初始 x 坐标落在房间地板外侧，玩家进入 Stage10 后会持续下落。
- 修复：将 Stage10 三个房间 flow config 的出生点从 `Vector2(-224, 96)` 调整到 `Vector2(-128, 96)`，并新增 `test_stage10_spawn_points_land_on_room_floor` 回归测试。
- 复核：MCP 确认主房间出生点稳定落地、`BranchZone` 可切到支路、支路收集物 / 恢复点可触发并更新 HUD。
- 验证：Stage10 GUT `9/9 passed`；Stage 1-10 GUT `63/63 passed`。

## 2026-04-24 - Stage 10 最终人工手操复核通过并补收口修复

- 分支：`codex/stage-10-combat-variation-and-light-progression`
- 模式：`分支 + worktree`
- 范围：补做 stage10 剩余的最终人工手操复核，重点确认主房空中攻击价值、支路入口是否误触、挑战房混合压力。
- 发现：在直进 `stage10_zone_aerial_room` 的真实手操里，玩家出生后会立即误触 `BranchZone`，导致主房空中攻击验证被支路切换提前打断。
- 修复：先补红测 `test_stage10_main_room_spawn_does_not_auto_request_optional_branch`，再将主房 `BranchZone` 从 `Vector2(-96, 96)` 上移到 `Vector2(-96, 24)`，让支路入口从“出生即命中”改回“需要玩家主动跳入”。
- 人工复核：修复后主房不再自动切支路，真实 `jump / attack` 输入可在主房稳定触发；挑战房也已确认真实 `jump / attack / dash` 输入可进场。
- 验证：`godot --headless --path . --import` 通过；Stage 1-10 GUT `64/64 passed`；`git diff --check` 通过。

## 2026-04-26 - 项目级 agent 角色池配置

- 分支：`codex/game-agent-role-config`
- 模式：`仅分支`
- 范围：新增 `.codex/agent/` 项目级角色池配置，并把 `AGENTS.md`、Stage 12-16 roadmap 与早期 agent / 节奏设计文档中的当前执行口径同步为 6 角色方案。
- 当前默认参数：`max_threads = 4`、`max_depth = 1`；角色池为 `design`、`architecture`、`gameplay`、`content`、`qa`、`production`。
- 影响：替代旧的“代理 A / B / C”默认拆分；历史阶段计划中的旧 Delegation Log 保留为历史记录，不回写重写。
- 验证：本次只改项目治理配置和文档；最终以 `git diff --check` 收口。

## 2026-04-27 - 项目治理、插件、资产与 agent 配置修正

- 分支：`codex/project-governance-plugin-assets`
- 模式：`仅分支`
- 范围：将项目级 agent 配置从 `.codex/agent/` 迁入官方加载路径 `.codex/agents/`，并在 `.codex/config.toml` 注册 `[agents]`；补充 `godot_runtime` 与 `asset_direction` 两个本项目专项角色。
- 插件：从 `project.godot` 移除当前代码未引用的 `DialogueManager` 与 `ControllerIcons` autoload，降低进入 Godot 项目时的默认插件加载面。
- 文档：提升 `AGENTS.md` 注释约束，新增插件盘点、Codex multi-agent 设置参考与资产生成规划入口。

## 2026-04-27 - 总设计北极星与 multi-agent 配置口径纠偏

- 分支：`codex/realign-design-agent-settings`
- 模式：`仅分支`
- 范围：根据用户反馈，将 `spec-design/2026-03-23-nano-hunter-design.md` 明确为总设计北极星，并修正资产 brief 中偏向现代生物实验室的方向。
- Agent：区分 Codex `multi_agent_v2` 客户端功能开关与 `.codex/agents/` / `[agents]` subagent 配置；因当前本地冲突，暂时注释显式 `max_threads = 4`，保留 `max_depth = 1` 与项目执行层 `2-4` 并行约束。
- 插件：补充已安装插件是否值得使用、当前不启用原因、后续可评估插件方向和历史报错原因。

## 2026-04-27 - 已开发阶段注释可读性补强

- 分支：`codex/comment-readability-pass`
- 模式：`仅分支`
- 范围：按 `AGENTS.md` 新注释约束，为 Stage 1-13 已开发核心脚本和关键测试 helper 补充文件职责、分段意图、状态切换、信号 / 门控 / checkpoint、灰盒 driver 与配置资源说明。
- 影响：只增加注释，不改动玩法逻辑、数值、场景结构或测试断言。
- 验证：`git diff --check` 通过；`godot --headless --path . --import` 通过；Stage 1-13 全量 GUT `87/87 passed`，`619` 个断言通过。

## 2026-04-27 - agent 通用设置迁至全局配置

- 分支：`codex/global-agent-settings-doc-sync`
- 模式：`仅分支`
- 范围：确认 `max_depth/max_threads` 等通用 agent 行为适合放在用户级全局 `~/.codex/config.toml`，项目级 `.codex/config.toml` 只保留 Godot MCP 注册与 Nano Hunter 专属 agent 角色注册。
- 验证：项目级 `.codex/config.toml`、项目 `.codex/agents/*.toml` 与用户级全局 `~/.codex/config.toml` 均通过 Python `tomllib` 解析；`git diff --check` 通过。

## 2026-04-27 - Stage 14 回溯与能力门控首轮实现

- 分支：`codex/stage-14-backtracking-ability-gating`
- 模式：`固定永久工作树 + 阶段分支`
- 范围：新增唯一核心能力 `Air Dash / 空中二段冲刺`，从 Stage 13 终点接入能力获得房、能力门、回溯 hub 与主线回环房。
- 玩法：空中冲刺默认锁定，获得能力后空中可使用一次 dash，落地恢复；`Main` 持有解锁状态并在房间切换后注入玩家。
- 内容：新增 `stage14_air_dash_shrine_room`、`stage14_air_dash_gate_room`、`stage14_backtrack_hub_room`、`stage14_loop_return_room`，并记录 `3` 个回溯收益点。
- 文档：新增 Stage14 设计、实现计划、执行清单，并追加 Stage14 资产 manifest 需求。
- 收口：Stage14 分支已提交并合并回 `main`；主线基线推进到“阶段 14 已完成，下一阶段 Stage 15 preflight”。
- 验证：`git diff --check` 通过；`godot --headless --path . --import` 通过；Stage14 GUT `9/9 passed`、Stage 1-14 全量 GUT `96/96 passed`。
- 远端与现场：`main` 已 push 到 `origin/main`；本地阶段分支已删除，固定工作树保留为最新 `main` 的 detached 状态；`6505` bridge 监听仅记录未强制释放。
