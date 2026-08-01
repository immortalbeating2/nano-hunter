# Stage27-32 北极星 Beta 路线计划

设计真源：`spec-design/2026-07-31-post-stage26-north-star-gap-and-stage27-32-roadmap.md`
美术评估：`docs/assets/2026-07-31-post-stage26-north-star-art-gap-assessment.md`
执行清单：`docs/implementation-plans/2026-07-31-stage27-32-north-star-beta-roadmap.md`

## Summary

Stage21-26 已完成批准的北极星 Alpha 系统范围，但现有元素 / 姿态主要靠同动作染色与文字表达，Luna 和既有 Boss 只达到技术可运行，驿站 / Build 缺少专属表现，雷泽仍是复用背景和 Polygon 灰盒，音频与跨进程存档缺失。下一路线冻结无边界扩张，按 `Preflight26A -> Gate26M -> Stage27-31 -> Gate26H -> Stage32` 推进一个可公开复核的 Beta 垂直切片。

## Individual Plans

- Preflight26A：`plan/2026-08-01-preflight26a-clean-baseline.md`
- Gate26M：`plan/2026-08-01-gate26m-automated-technical-baseline.md`
- Stage27：`plan/2026-08-01-stage27-formal-combat-art-audio.md`
- Stage28：`plan/2026-08-01-stage28-waystation-bounty-build-presentation.md`
- Stage29：`plan/2026-08-01-stage29-thunder-waste-formal-art.md`
- Stage30：`plan/2026-08-01-stage30-thunder-enemies-boss-absorption.md`
- Stage31：`plan/2026-08-01-stage31-save-and-waystation-travel.md`

每份正式计划均有 `docs/implementation-plans/` 下的同名执行清单。Stage32 继续保留为 Gate26H 后的候选收口，不在本轮提前展开。

## Stage Boundary / Preflight

- 当前运行基线：Stage26 Alpha Candidate；44 房、8 条远端连接、2 元素、2 姿态、2 步序列、3 悬赏、4 Build、6 房雷泽原型。
- Stage26 自动化与实体手柄技术门禁已收口；真人首次通关、回访、理解度和手感仍属于 Gate26H。Gate26H 允许延后到 Stage31 后，不阻塞 Stage27-31，但 Stage32 前必须完成。
- 当前共享工作树有独立地形视觉 / 碰撞改动；进入任何新 Stage 前必须先明确其提交与分支归属，不把未提交现场混入 Stage27。
- 当前资产队列为 `56` 项，而 runtime map / 旧 acceptance 仍为 `55` 项；Stage19 地图底板已上屏但缺登记。Preflight26A 必须先修复该治理漂移，并让 strict runtime-map 审计恢复通过。
- 本次只读复核的新鲜基线为 Stage21-26 `31/31` tests、`294` assertions，Godot `4.6.3` 主场景启动、MCP workspace 握手和编辑器错误 `0`；临时 MCP autoload 已清理。
- 每个 Stage 开始前仍需独立设计、正式 `plan/` 和 implementation plan；本路线只锁定顺序、范围与退出门。

## Key Changes

- Gate26M：用 Godot MCP Pro + GUT 自动复核主菜单 / 暂停 / 地图 / 详情、输入、状态、动作切换、VFX、截图和错误；不冒充主观真人体验。
- Stage27：Luna 正式全动作集、四类独立技能 VFX、既有 Seal Guardian 正式 polish、首批本地生成战斗 / UI 音频、开发期全能力测试预设。
- Stage28：正式镇妖驿站、悬赏榜、驿卒短叙事、悬赏与四件 Build 专属图标。
- Stage29：不扩房，把雷泽六房替换为专用背景、TileSet、props、机关 VFX、氛围与 BGM。
- Stage30：一个雷泽敌人家族、一个具有完整高质量动作 / VFX 的两阶段区域首领、雷系吸收强化、大妖组件和妖性共鸣事件。
- Stage31：一个版本化本地存档、真实 Continue、Stage11 与雷泽前哨双点传送。
- Stage32：停止新增内容，完成设置、Windows 导出、真人签核、美术 / 音频 / 授权和 Beta 交付收口。

## Reused Contracts

- 玩家元素与姿态继续由 Main 快照跨房持有；序列仍由 Player 管理。
- 战斗继续走 `receive_attack(...)` / 可选 `receive_elemental_attack(...)` / `defeated`，不建立平行伤害系统。
- 房间继续走 `room_transition_requested`、`checkpoint_requested`、`get_hud_context()`。
- UI 继续复用 DemoShell DetailPanel、现有 Theme 和发现式地图动态绘制。
- Stage29 只替换 Stage25 显示层与配置，保留六房拓扑和现有机关逻辑。
- Stage31 从现有 Main 快照序列化，不复制一份进度模型。

## Test Plan

- 每个 Stage：专项 GUT、最邻近组合、递归全量、Godot import、主场景 smoke、`git diff --check`。
- Gate26M：MCP workspace、输入链、菜单焦点、运行状态、连续帧、关键截图和编辑器 / 输出错误。
- Stage27：Luna `18` clips 正式动作矩阵、无 HUD 识别、Seal Guardian 两阶段读招、全能力预设发布隔离、音频重复 / 响度、Stage21 / 22 / 24 / 26 回归。
- Stage28：榜单 / Build 手柄焦点、三段事件去重、小图标 32px / 64px 和首次玩家理解度。
- Stage29：六房真实场景引用、视觉 / 碰撞对齐、16:9 / 2K / 21:9、原雷泽背景与关键 Polygon 退役检查。
- Stage30：普通打法与两序列打法、Boss 两阶段、动画锚点 / 时序、击败奖励与回访门控。
- Stage31：正常档、旧版本档、损坏档、写入失败、关闭重开、双点传送门控。
- Stage32：Windows export smoke、完整首次通关、回访 / 悬赏 / Build / Boss / 存档 / 传送、实体手柄与最终美术 / 音频签核。

## Asset Plan

- 资产需求按 `NS27-LunaFormalMotion`、`NS27-CoreCombatVFX`、`NS27-SealGuardianPolish`、`NS27-Audio`、`NS28-Waystation`、`NS29-ThunderWaste`、`NS30-ThunderEnemyFamily`、`NS30-ThunderBossFormal`、`NS31-PersistenceTravelUI`、`NS32-BetaPresentation` 推进。
- 现场队列为 `56` 项、重算 `55/56 final-ready`；旧 `55/55 final-ready` 只证明旧登记集合在声明范围内通过。先补 Stage19 地图条目，再要求每个新 Pack 独立登记、绑定和运行验收。
- Stage27 将 Luna 当前 `7` clips / `111` 帧重新按正式 Demo 门禁逐项验收并补齐到全动作集，同时把 Seal Guardian 当前 `5` clips / `24` 帧提升为正式 Boss 表现；Stage30 的新敌人 / Boss 必须有专属动作，不能只换色复用旧角色。
- Stage27 SFX 默认由本机 Stable Audio 3 Small SFX 生成，BGM / stinger 由 ACE-Step 1.5 生成；候选先进入 scratch，经验证、人工试听、provenance 和 manifest 后才允许接入项目。

## Manual Review

- Gate26H：延后到 Stage31 后，与 Beta 前真人完整基线合并；未执行前保持开放，不阻塞 Stage27-31。
- Stage27：关闭文字提示后辨识元素 / 姿态 / 序列，并评审 Luna 全动作和 Seal Guardian 完整 Boss 演出。
- Stage28：陌生玩家自行完成接榜、回交和两槽调整。
- Stage29：雷泽是否在第一眼区别于瘴泽，危险 / 祭柱 / 出口是否无 HUD 可读。
- Stage30：Boss 两阶段与吸收奖励是否清楚，普通打法是否仍可完成。
- Stage31：关闭程序后的恢复是否符合预期，传送是否破坏探索。
- Stage32：陌生玩家 Beta 全流程和实体手柄主观签核。

## Explicit Deferrals

- Stage32 前不扩第三元素、第三姿态、三步序列或完整技能树。
- 不做随机悬赏、交易市集、完整经济、NPC 群像或多结局。
- 不扩雷泽房数，不同时开启第三完整区域。
- 不做多档、云存档、全地图传送或通用 Boss / 对话编辑器。
- Stage33+ 不预编号；待 Beta 数据决定完整商业版拆分。

## Exit Criteria

- Stage27-31 各自完成独立退出门且没有用后续 Stage 掩盖当前缺口。
- Stage32 取得自动、运行态、真人、实体手柄、美术、音频、存档与 Windows 导出证据。
- 交付说明能明确回答：Beta 垂直切片已完成什么，完整 6-8 元素 / 区域 / 剧情商业版仍缺什么。
