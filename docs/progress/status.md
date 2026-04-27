# Nano Hunter Status

Last Updated: 2026-04-27

## Latest Update - 2026-04-27 Stage 14 Backtracking And Ability Gating

- Stage 14 已在固定永久工作树 `C:\Users\peng8\.codex\worktrees\ffc3\nano-hunter` 的 `codex/stage-14-backtracking-ability-gating` 分支启动并完成首轮实现。
- 新增唯一核心能力 `Air Dash / 空中二段冲刺`：保留原地面 dash，解锁后空中可使用一次 dash，落地恢复，房间切换后由 `Main` 重新注入能力状态。
- Stage 13 区域终点已接入 Stage 14：能力获得房、空中冲刺门、回溯 hub、主线回环房构成第一条类银河恶魔城回溯链路。
- 新增至少 `3` 个 Stage 14 回溯收益点，`Main.get_demo_progress_snapshot()` 记录 `air_dash_unlocked` 与 `stage14_backtrack_reward_count`。
- HUD 增加 Stage 14 能力 / 回溯收益状态行，资产 manifest 追加 Air Dash 图标、能力装置、能力门和回溯收益点需求。
- 新增 Stage14 专项 GUT，覆盖能力默认锁定、空中一次性 dash、落地恢复、房间切换保留、能力门、3 个收益点、Stage13 接入与灰盒主线回环。
- 已补做 Godot MCP 运行态复核，并按复核结果修正 Stage14 出生地板覆盖与 HUD Stage14 显示优先级。

## Latest Update - 2026-04-27 Developed Stage Comment Readability Pass

- 已按 `AGENTS.md` 新注释约束，对 Stage 1-13 已开发核心代码补强注释可读性。
- 本轮只增加说明性注释，不改变玩法逻辑、数值、场景结构或测试断言。
- 覆盖重点：玩家控制 / 战斗判定、Main 房间推进、敌人基类与敌人变体、Stage 9/10/13 房间基类、Stage 11 终点房、配置资源、Stage 11 灰盒 driver 与 Stage 13 收口测试 helper。
- 验证结果：`git diff --check` 通过；`godot --headless --path . --import` 通过；Stage 1-13 全量 GUT `87/87 passed`，`619` 个断言通过。
- 注意：当前工作区仍保留用户先前对 `.codex/config.toml` 的未提交改动，本轮注释补强不纳入该文件。

## Latest Update - 2026-04-27 Global Agent Settings Split

- agent 通用行为设置已调整为用户级全局配置承载：`~/.codex/config.toml` 负责 `max_depth/max_threads` 等机器级偏好。
- 项目级 `.codex/config.toml` 只保留 Nano Hunter 专属内容：`godot-mcp-pro` MCP 注册与 `[agents.<role>]` 角色注册。
- 这个拆分是合理的：不会把个人并发偏好强制提交给项目，但仍让进入本仓库的会话能发现项目专属 agents。
- 当前已验证项目级配置、项目 agent TOML 与全局配置均可被 TOML 解析。

## Latest Update - 2026-04-27 Governance, Plugin, Agent, Asset Cleanup

- 当前项目级 agent 配置已从临时 `.codex/agent/` 迁入官方加载路径 `.codex/agents/`，并通过 `.codex/config.toml` 的 `[agents]` 注册。
- 当前因 `multi_agent_v2` 与显式 `max_threads` 的本地兼容性冲突，`.codex/config.toml` 暂时注释 `max_threads = 4`，保留 `max_depth = 1`；项目执行层仍限制单轮通常只启用 `2-4` 个最相关角色。
- 核心角色保留 `design`、`architecture`、`gameplay`、`content`、`qa`、`production`；基于本项目历史痛点新增按需专项角色 `godot_runtime` 与 `asset_direction`。
- `AGENTS.md` 的注释约束已提升为“文档可阅读性”标准：重要代码段必须能通过文件头、分段注释与关键流程注释理解职责、原因和协作对象。
- 插件策略已收紧：当前默认只启用 `godot_mcp` 与 `gut`；`DialogueManager` 与 `ControllerIcons` 不再作为项目 autoload 默认加载，其他已安装插件继续作为候选保留。
- `spec-design/2026-03-23-nano-hunter-design.md` 已明确为总设计北极星；Stage 12-13 中的“实验室 / 生物废液区”视为灰盒偏移，后续资产和命名必须回归南北朝、镇妖卫、佛门符印、山海经妖物与东方水墨 / 工笔方向。
- 新增资产生成与一致性规划文档，作为用户寻找 / 生成 / 替换资产的入口，并已按总设计方向重写。

## Latest Update - 2026-04-26 Project Agent Role Configuration

- 项目级 agent 配置曾落地到 `.codex/agent/`；2026-04-27 已迁入官方 `.codex/agents/` 路径。
- 当前默认并行参数记录为 `max_threads = 4`、`max_depth = 1`；角色池包含 `design`、`architecture`、`gameplay`、`content`、`qa`、`production`，但单次任务默认只启用 `2-4` 个最相关角色。
- `AGENTS.md` 已移除旧的“代理 A / B / C”默认拆分，并改为引用项目级角色池；Stage 12-16 roadmap 与早期 agent / 节奏设计文档已同步修订当前执行口径。
- 本次只修改项目治理配置和文档，不改动玩法、场景、脚本、测试或 Godot 工程配置。

## Latest Update - 2026-04-26 Permanent Worktree Policy

- 项目阶段型开发默认流程已修正为 `固定永久工作树 + 阶段分支`：本地稳定主工作区尽量保持在 `main`，阶段开发复用一个固定永久工作树，并在其中创建或切换 `codex/stage-*` 分支。
- 不再默认每个阶段都新建一个长期 worktree；Codex 托管临时 worktree 仅用于短期并行探索、一次性 review 或可丢弃试验。
- 固定永久工作树用于保留 Godot 导入缓存、编辑器现场和 Godot MCP 人工复核现场；阶段合并后删除阶段分支，但保留永久工作树并同步回最新 `main`。
- 本次 Stage13 已记录为流程偏差：实际开发发生在主路径上的阶段分支，而不是独立固定永久工作树；后续阶段从 Stage14 起应按新规则恢复主路径 `main` + 固定永久阶段工作树的结构。

## Latest Update - 2026-04-26 Stage 13 Manual Review Closure

- Stage 13 最终收口项已完成自动化等价复核：由于当前会话未暴露 Godot MCP 运行时工具，本轮采用 headless Godot + GUT closure driver 作为 fallback，直接从 `Main.tscn` 驱动到 Stage 11 demo 终点后继续进入 Stage 13。
- 新增 `tests/stage13/test_stage_13_manual_review_closure.gd`，覆盖人工复核清单：进入 Stage 13、完整主路径到区域终点、资源支路、挑战支路、酸液反馈、checkpoint 恢复、净化门从关闭到开启。
- 收口复核发现并修复 checkpoint 时序问题：动态切房时 `checkpoint_on_ready` 可能早于 `Main` 绑定 `checkpoint_requested` 发出，导致 Stage13 压力房失败恢复回到 Stage11 终点；现已在 `Stage9RoomBase` 中延后一帧激活 ready checkpoint，确保信号被 Main 接住。
- Fresh 验证结果：Stage 13 closure GUT `1/1 passed`；Stage 13 专项 GUT `9/9 passed`；Stage 1-13 全量 GUT `87/87 passed`；`godot --headless --path . --import` 通过；`git diff --check` 通过。

## Latest Update - 2026-04-26 Stage 13 First Implementation Pass

- Stage 13 已从 preflight 推进到首轮正式实现：从 `stage11_demo_end_room` 完成后新增 `ContinueZone`，可进入 `stage13_bio_waste_entry_room.tscn`。
- 新增 `生物废液区` 灰盒内容：`10` 个主线房间、`2` 条小支路、区域终点房、主线 checkpoint、资源 / 恢复支路与风险挑战支路。
- 新增第 `4` 类敌人 `SporeShooterEnemy`，沿用 `base_enemy.gd` 的 `receive_attack(...)` 与 `defeated` 契约，并通过 `spore_shooter_enemy_config.tres` 暴露远程压制半径与接触伤害。
- 新增区域机制：废液 / 酸液危险、净化节点、净化门控；checkpoint 仍保持运行期恢复点，不扩成正式存档。
- 新增 Stage 13 轻量 SVG 占位资产与 Godot `.import` 文件：生物废液平台 / 背景、孢子投射敌轮廓、酸液危险提示、净化门、净化节点、区域终点装置。
- 自动化覆盖已扩展到 Stage 13：`tests/stage13/test_stage_13_second_content_zone_production.gd` 覆盖入口、10 房主线、2 支路、新敌人、酸液、净化门控、资产 manifest 与灰盒主路径。
- Fresh 验证结果：`godot --headless --path . --import` 通过；Stage 1-13 全量 GUT `86/86 passed`；Stage 13 专项 GUT `8/8 passed`。
- 仍待阶段最终收口前人工复核：从 `Main.tscn` 实机跑到 Stage 13 入口、完整主路径、两条支路、酸液反馈、checkpoint 恢复、净化门关闭到开启。

## Latest Update - 2026-04-26 Stage 13 Preflight Kickoff

- 当前 `codex/stage-13-second-content-zone-production` 分支已 fast-forward 到最新 `main`，以 Stage 12 已合并的稳定 demo 基线作为前置；本轮实际采用 `仅分支`，未额外创建阶段 worktree。
- Stage 13 正式文档设计已启动并落盘：新增正式计划、设计文档与执行清单。
- 本阶段固定为 `生物废液区 + 10 个主线房间 + 2 条小支路`，并锁定第 `4` 类敌人 `孢子投射敌`、区域危险 `废液池 / 酸液地形`、区域门控 `净化门控`。
- Stage 13 新资产需求已追加到 `docs/assets/asset-manifest.md`，继续沿用 Stage 12 建立的资产清单与接入检查，而不是重建资产体系。
- Stage 13 preflight fresh baseline 已完成：`godot --headless --path . --import` 通过，Stage 1-12 全量 GUT `78/78 passed`，`git diff --check` 通过；Godot MCP dry-run 当前建议为 `SafeOpenEditor`。
- 当前状态：Stage 13 仅完成 preflight 文档设计与资产需求记录，尚未进入玩法、场景或脚本实现。

## Latest Update - 2026-04-26 Stage 12 Full Runtime Review

- Godot MCP 在用户重开会话后已恢复可用，并已用 `mcp__godot_mcp_pro__` 完成 Stage 12 完整运行态人工复核。
- 主线灰盒复核已从 `Main.tscn` 起点覆盖到 `stage11_demo_end_room`，确认序列为：教程房 -> 战斗房 -> 目标房 -> Stage9 五房间 -> Stage10 主房 -> Stage10 挑战房 -> Demo 终点房。
- Stage10 支线复核已覆盖：主房进入支线、支线恢复点 / 收集反馈、支线返回主线、挑战房收集反馈与挑战房进入 Demo 终点。
- 失败与完成复核已覆盖：Demo 终点房 checkpoint 重试、`demo_completed=true`、`replay_available=true`、完成后 `ReplayZone` 返回教程房。
- 视觉复核发现并修复 HUD 目标图标 / 长目标文本的挤压风险：`BattlePanel` 已加宽加高，`ObjectiveIcon` 改为 `AtlasTexture` 截取目标图标区域，避免把三联 SVG 整张压入单个图标位。
- 当前状态：Stage 12 已完成完整运行态人工复核；最终 fresh 验证已通过：`godot --headless --path . --import` 通过，Stage 12 专项 GUT `9/9 passed`，Stage 1-12 全量 GUT `78/78 passed`，`git diff --check` 通过；`project.godot` 中 Godot MCP 临时 autoload 注入已清理且当前无 `project.godot` diff。
- 收口判断：Stage 12 已满足退出条件，并已通过本地 merge commit `f00ab48` 合并回 `main`；主线最终验证通过，Stage 12 worktree / 本地阶段分支 / 旧 bridge 监听已清理，可作为 Stage 13 的稳定前置基线。

## Latest Update - 2026-04-26 Godot MCP Reopen Attempt

- 用户重开会话后，已按 `docs/dev/godot-mcp-pro-connectivity-guide.md` 执行 Stage 12 worktree 的 Godot MCP 恢复尝试。
- `enter-worktree-godot-mcp.ps1 -ForceKillBridge` 已释放旧 `6505-6509` 监听；随后当前会话的 `godot-mcp-pro` bridge 延迟监听到 `6505`，当前 worktree 的 Godot 编辑器也已连接到该 bridge。
- 第二次重开会话后，脚本层复测结果：`check-godot-mcp.ps1` 输出 `RecommendedAction: AlreadyConnected`。
- 第二次重开会话后，工具层复测结果：`mcp__godot_mcp_pro__.detect_circular_dependencies` 成功返回，`has_circular=false`，检查 `20` 个场景。
- 当前判断：Godot MCP 已恢复可调用；Stage 12 自动化实现仍有效；首屏运行态烟测已确认 HUD 与玩家轮廓可见，但完整人工复核清单仍待补。

## Latest Update - Stage 12 First Implementation Pass

- Stage 12 首轮实现已落地：资产目录规范、`docs/assets/asset-manifest.md`、`docs/assets/asset-ingestion-checklist.md`、第一批占位 SVG、玩家 / 三类敌人轻量可读性节点、HUD 图标槽、Stage9 门控 / checkpoint 提示与终点房方向提示均已接入。
- 当前实现仍遵守 `规范 + 轻替换`：不新增新区域、不新增新核心玩法、不改变玩家碰撞、敌人 Hurtbox、敌人 AI、房间流转或 checkpoint 契约。
- 自动化验证已通过：`godot --headless --path . --import` 通过，Stage 12 专项 GUT `8/8 passed`，Stage 1-12 全量 GUT `77/77 passed`，`git diff --check` 通过。
- Godot MCP 当前未联通：`check-godot-mcp.ps1` 输出 `RecommendedAction: ReopenSessionThenForceKillBridge`，MCP 工具仍报告 `Godot editor is not connected`。本轮未在当前会话强杀 bridge，运行态人工复核仍需在重开会话并恢复当前 worktree Godot 编辑器连接后补做。
- 当前状态判断：Stage 12 已达到“自动化首轮实现完成”，但尚未达到“阶段收口”，因为完整人工复核还未完成。

## Current Phase

`Vertical Slice / 原型期`

## Current Stage

`阶段 14：回溯与能力门控成型（首轮实现中）`

> Update: 2026-04-27 Stage 14 已从 Stage 13 终点接入首轮灰盒实现：获得 `Air Dash / 空中二段冲刺` 后，可打开第一道能力门，回访并收集 `3` 个回溯收益点，再进入主线回环房。当前阶段在固定永久工作树 `C:\Users\peng8\.codex\worktrees\ffc3\nano-hunter` 的 `codex/stage-14-backtracking-ability-gating` 分支上开发。

## Stage Goal

在 Stage 13 已完成的第二小区域末端，加入第一条真正的回溯与能力门控链路。本阶段固定目标为：

- 唯一新核心能力：`Air Dash / 空中二段冲刺`
- 1 类能力门控：空中冲刺门
- 至少 `3` 个回溯收益点
- 1 条主线回环
- 1 条可选回访支路
- 不引入完整地图、任务日志、多能力并行或正式存档

## Playable Now

- `godot --path .` 当前进入 `Main.tscn`，默认从教程主线开始
- 当前稳定主线链路已成立：
  - `TutorialRoom`
  - `CombatTrialRoom`
  - `GoalTrialRoom`
  - `stage9_zone_entry_room`
  - `stage9_zone_combat_room`
  - `stage9_zone_charger_room`
  - `stage9_zone_switch_room`
  - `stage9_zone_final_room`
  - `stage10_zone_aerial_room`
  - `stage10_zone_branch_room`
  - `stage10_zone_challenge_room`
  - `stage11_demo_end_room`
- 当前 demo 已具备：
  - 明确终点房
  - 最小完成反馈
  - 重开试玩入口
  - 支路 / 挑战房保留
  - 失败 / 重来继续成立
- Stage 13 的第二小区域已可从 Stage 11/12 demo 终点后进入，并形成第二段内容生产基线：
  - `stage13_bio_waste_entry_room`
  - `stage13_bio_waste_spore_room`
  - `stage13_bio_waste_acid_room`
  - `stage13_bio_waste_checkpoint_room`
  - `stage13_bio_waste_gate_room`
  - `stage13_bio_waste_branch_hub_room`
  - `stage13_bio_waste_pressure_room`
  - `stage13_bio_waste_crossfire_room`
  - `stage13_bio_waste_return_room`
  - `stage13_bio_waste_goal_room`
  - `stage13_bio_waste_resource_branch_room`
  - `stage13_bio_waste_challenge_branch_room`

## Adjustable Now

- 玩家关键参数继续统一由 `res://scenes/player/player_placeholder_config.tres` 驱动
- 房间与敌人关键参数继续由只读配置资源驱动
- 当前 demo 收束仍主要通过以下入口调整：
  - `scripts/main/main.gd`
  - `scripts/ui/tutorial_hud.gd`
  - `scripts/rooms/stage11_demo_end_room.gd`
  - `assets/configs/rooms/stage9_zone_*.tres`
  - `assets/configs/rooms/stage10_zone_*.tres`
- Stage 13 新增可调入口包括：
  - `scripts/rooms/stage13_bio_waste_room_base.gd`
  - `scripts/configs/spore_shooter_enemy_config.tres`
  - `docs/assets/asset-manifest.md` 中的 Stage 13 资产条目

## Exit Criteria

- 第二小区域可以从 Stage 11/12 demo 终点后进入
- `10` 个主线房间可稳定推进到区域终点房
- `2` 条小支路均可进入、完成、返回主线或给出明确结束反馈
- `孢子投射敌`、`废液池 / 酸液地形`、`净化门控` 均有自动化或最小运行态证据覆盖
- 区域 checkpoint 与失败重来不破坏前一区域
- Stage 13 资产需求与接入状态已记录到 `docs/assets/asset-manifest.md`
- Stage 13 专项 GUT 通过，Stage 1-13 全量 GUT 通过
- 人工复核覆盖主路径、2 条支路、废液危险、checkpoint 恢复、净化门控与区域终点反馈

当前状态：以上退出条件已通过自动化和 headless manual-review fallback 覆盖；Stage 13 可作为 Stage 14 的稳定前置候选，仍可由用户继续补真人手感复核。

## Asset Status

- 当前仍以占位资源、简单几何可视化与少量临时视觉探索为主。
- Stage 13 已追加 `biome_02_bio_waste`、孢子投射敌、废液危险、净化门控和区域终点相关资产条目。
- 第一轮接入的 Stage 13 资产仍是轻量占位，不代表最终美术；后续 Stage 14+ 继续在同一份 manifest 中追加或替换，不重建资产体系。

## Next Stage

`阶段 14：回溯与能力门控成型`

## Current Goal

当前 `main` 的下一步固定为 Stage 14 preflight：

- 本轮实际采用 `仅分支`，未额外创建阶段 worktree
- 已完成 Stage 13 正式计划、设计文档、执行清单、资产 manifest、脚本与文档治理调整
- 已完成最终验证：`godot --headless --path . --import`、Stage 13 GUT、Stage 1-13 全量 GUT 与 `git diff --check`
- 下一步进入 `阶段 14：回溯与能力门控成型` 的正式 preflight，并按新规则使用固定永久工作树

## Current Defaults

- 引擎：Godot 4.6
- 类型：2D 类银河恶魔城原型
- 主要语言：GDScript
- 当前启用插件：`godot_mcp`、`gut`
- `better-terrain` 保留在仓库中，但当前阶段不启用

## In Progress

- `阶段 13：第二小区域内容生产` 当前已完成并合并回 `main`
- 本轮实际采用 `仅分支`，未额外创建阶段 worktree；这是本轮流程事实，后续 Stage 14 起按 `固定永久工作树 + 阶段分支` 新规则执行
- 本轮已固定的关键选择：
  - 第二小区域主题：`生物废液区`
  - 主线密度：`10` 个房间
  - 支路密度：`2` 条小支路
  - 第 `4` 类敌人：`孢子投射敌`
  - 区域危险：`废液池 / 酸液地形`
  - 区域门控：`净化门控`
  - 资产策略：沿用 Stage 12 manifest，不重建资产体系

## Recently Completed

- 阶段 13 已完成首轮实现与收口复核：`生物废液区`、`10` 个主线房间、`2` 条小支路、`孢子投射敌`、废液 / 酸液危险、净化门控、区域 checkpoint、区域终点与 Stage 13 资产 manifest 均已落地
- Stage 13 最终验证已记录：Stage 13 GUT `9/9 passed`，Stage 1-13 全量 GUT `87/87 passed`，`godot --headless --path . --import` 通过，`git diff --check` 通过
- 本轮同时完成 Godot MCP 固定工作树流程脚本和文档调整：`scripts/dev/enter-worktree-godot-mcp.ps1`、`docs/dev/godot-mcp-pro-connectivity-guide.md` 与 `AGENTS.md`
- 阶段 12 已完成、验证、合并并清理开发现场
- 阶段 12-16 路线已正式补入主线并同步到 `AGENTS.md`
- Stage 12 正式开发计划已补入：
  - `plan/2026-04-25-stage-12-asset-pipeline-and-demo-polish.md`
- Stage 12 独立设计文档与实现计划已启动：
  - `spec-design/2026-04-25-stage-12-asset-pipeline-and-demo-polish-design.md`
  - `docs/implementation-plans/2026-04-25-stage-12-asset-pipeline-and-demo-polish.md`
- 阶段 10 已完成并作为当前稳定前置基线
- `main` 已补录 stage11 的正式阶段计划：
  - `plan/2026-04-24-stage-11-playable-demo-slice.md`
- 阶段 1-10 的关键脚本与测试文件已补做一轮注释补强
- stage11 已新增：
  - `stage11_demo_end_room`
  - `tests/stage11/test_stage_11_playable_demo_slice.gd`
  - Stage 11 灰盒主线自动化驾驶器
  - `docs/dev/godot-mcp-pro-connectivity-guide.md`
  - `scripts/dev/enter-worktree-godot-mcp.ps1` 作为 Godot MCP 日常唯一入口；其他 `check / safe-repair / open / force-repair` 脚本保留为诊断或高级排障工具

## Risks And Blockers

- 当前主要剩余风险是远端同步、Stage 14 preflight 前的固定永久工作树现场恢复，以及用户后续真人手感复核可能提出的节奏 / 可读性微调
- `godot_mcp` 当前已被工程化留痕；后续人工复核应从目标固定永久工作树启动 Codex，并默认运行 `scripts/dev/enter-worktree-godot-mcp.ps1`
- 当前主路径处于 Stage 13 阶段分支；收口合并后应恢复到 `main`，后续 Stage 14 起按固定永久工作树策略执行

## Recommended Roadmap

- 当前已形成一条可交付试玩 demo 的稳定主线
- 后续路线已正式补为 Stage 12-16：
  - `阶段 12：资产管线与第一轮 Demo 表现升级`
  - `阶段 13：第二小区域内容生产`
  - `阶段 14：回溯与能力门控成型`
  - `阶段 15：战斗高潮与首个精英 / Boss 原型`
  - `阶段 16：Alpha Demo 打包候选`
- 路线总入口：
  - `spec-design/2026-04-25-stage-12-to-stage-16-roadmap.md`

## Next Recommended Steps

1. 进入 Stage 14 正式 preflight
2. 为回溯能力、能力门控、回溯收益点和导航提示补独立设计文档与正式阶段计划
3. 按固定永久工作树策略准备 Stage 14 开发现场，并继续沿用 `docs/assets/asset-manifest.md`
