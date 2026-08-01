# Stage27-32 北极星 Beta 路线执行清单

## 入口

- [x] 北极星差距评估：`spec-design/2026-07-31-post-stage26-north-star-gap-and-stage27-32-roadmap.md`
- [x] 美术资产差距评估：`docs/assets/2026-07-31-post-stage26-north-star-art-gap-assessment.md`
- [x] 正式路线：`plan/2026-07-31-stage27-32-north-star-beta-roadmap.md`
- [x] Preflight26A、Gate26M、Stage27-31 已分别建立正式计划与同名执行清单。
- [x] 本次 Stage21-26 组合回归：`31/31` tests、`294` assertions；Godot MCP Pro 主场景与编辑器错误 `0`。
- [x] 开发前确认当前地形改动的提交 / 分支归属，确保 Stage27 从可验证基线开始：`eb98e47`。
- [x] 把 `stage19_discovery_map_base_ai01` 补入 runtime map / readiness / acceptance 边界，重新通过全部 strict 资产审计。

## Gate26M：可立即执行的 MCP / 自动技术门禁

- [ ] Godot MCP Pro bridge workspace 与当前项目一致，`get_project_info` / 输入动作 / 编辑器错误可读。
- [ ] 生产主场景模拟主菜单、暂停、地图、详情、攻击、元素 / 姿态切换和返回链。
- [ ] 断言焦点、暂停状态、HUD、关键进度字段，并捕获连续帧 / 截图 / 输出日志。
- [ ] 将可重复问题固化为最小 GUT；明确记录 MCP 无法判断手感、迷路、误读和审美完成度。

## Gate26H：延后真人签核

- [ ] 允许延后到 Stage31 完成后；未完成时 Stage26 保持“待外部人工签核”，但不阻塞 Stage27-31。
- [ ] 真人从主菜单完成一次首次通关、能力回访、悬赏回交和两槽 Build 调整。
- [ ] 用实体手柄记录菜单、元素 / 姿态切换、误按、舒适度和迷路点。
- [ ] 复核 Luna 全动作、四类技能 VFX、Seal Guardian 与雷泽 Boss 的读招 / 命中 / 阶段表现。

## Stage27：正式战斗美术、Luna 全动作集与首批音频

- [x] 专属设计边界与正式计划已冻结：`plan/2026-08-01-stage27-formal-combat-art-audio.md`。
- [ ] 登记并制作 `NS27-LunaFormalMotion`、`NS27-CoreCombatVFX`、`NS27-SealGuardianPolish` 与 `NS27-Audio`。
- [ ] 将 Luna 当前 `7` clips / `111` 帧逐项正式验收，并补齐 idle / run / jump 分段 / land / air dash / 两姿态地面攻击 / 空中攻击 / 两序列收势 / 元素切换 / 姿态切换 / 恢复 / hit / death。
- [ ] 四种攻击结果使用不同形状 / 节奏 VFX，不只换色。
- [ ] 把 Seal Guardian 当前 `5` clips / `24` 帧提升为近 / 远 warning / attack、guard break / stagger、phase transition、hit、defeat 与配套 VFX。
- [ ] 通过 `local-game-audio` 生成首批战斗、Boss 预警和 UI 候选；SFX 走 Stable Audio、BGM / stinger 走 ACE-Step，scratch 试听接受后才接入。
- [ ] 接入音频事件与音量设置，保留 prompt、seed、runtime、候选和授权记录。
- [ ] 复用调试选关实现发布隔离的全能力预设。
- [ ] 完成无 HUD 识别、动作锚点 / 体积 / 色边、Boss 完整演出、专项 / 邻近 / 全量、import、smoke 与 Gate26M；真人短测可延后到 Gate26H。

## Stage28：镇妖驿站叙事锚点与悬赏 / Build 表现

- [x] 专属设计边界与正式计划已冻结：`plan/2026-08-01-stage28-waystation-bounty-build-presentation.md`。
- [ ] 登记并制作 `NS28-Waystation`。
- [ ] 正式驿站、三状态悬赏榜、驿卒与三段短事件接入生产场景。
- [ ] 三悬赏、四 Build、两槽均有唯一图标与状态。
- [ ] 复用 DetailPanel；不引入通用对话 / 任务框架。
- [ ] 完成手柄焦点、小尺寸、事件去重、首次理解度和回归验证。

## Stage29：雷泽荒原正式美术与区域机制清稿

- [x] 专属设计边界与正式计划已冻结：`plan/2026-08-01-stage29-thunder-waste-formal-art.md`。
- [ ] 登记并制作 `NS29-ThunderWaste`。
- [ ] 保持六房拓扑，替换瘴泽背景复用和关键 Polygon 灰盒表现。
- [ ] 接入专用背景、TileSet、props、天气 / 机关 VFX、氛围与 BGM。
- [ ] 入口 checkpoint 完成雷泽前哨表现，但不提前做传送。
- [ ] 完成六房引用、碰撞对齐、16:9 / 2K / 21:9、专项与全量验证。

## Stage30：雷泽敌群、区域首领与元素吸收成长

- [x] 专属设计边界与正式计划已冻结，锁定额外护印削减、雷幕捷径与雷兽妖核：`plan/2026-08-01-stage30-thunder-enemies-boss-absorption.md`。
- [ ] 登记并制作 `NS30-ThunderEnemyFamily` 与 `NS30-ThunderBossFormal`。
- [ ] 新增一个普通敌人家族和一个两阶段区域首领。
- [ ] 两种现有序列均有可读优势，普通打法仍可完成。
- [ ] 首领授予雷系吸收强化与一个大妖组件，并触发妖性共鸣事件。
- [ ] 雷泽 Boss 至少覆盖两种 warning / attack、两阶段、phase transition、guard break / stagger、hit、defeat 与独立 warning / impact / phase / defeat VFX。
- [ ] 完成新角色 SpriteFrames、VFX、音频、锚点 / 时序、Boss / 回访和全量验证。

## Stage31：单档存档与双驿站传送

- [x] 专属设计边界与正式计划已冻结，字段白名单、version 1、backup 与双点传送契约明确：`plan/2026-08-01-stage31-save-and-waystation-travel.md`。
- [ ] 登记并制作 `NS31-PersistenceTravelUI`。
- [ ] 从 Main 快照实现一个本地存档和真实 Continue。
- [ ] 保留上一有效档，损坏档可安全提示 / 新开。
- [ ] 只实现 Stage11 与雷泽前哨两点、已发现后可用的传送。
- [ ] 完成正常 / 旧版 / 损坏 / 写入失败 / 关闭重开 / 门控绕过测试。

## Stage32：北极星 Beta Candidate

- [ ] 写专属收口设计、QA checklist、release notes 和完成度审计。
- [ ] 登记并制作 `NS32-BetaPresentation`，只处理发布候选必需项。
- [ ] 冻结内容，完成设置、宽屏、性能、Windows export 和最终 mix。
- [ ] 完成标题字、运行态美术总检与资产 / 音频发布授权复核。
- [ ] 完成陌生玩家首次通关、定向回访和实体手柄主观签核。
- [ ] 全量自动化、import、smoke、export smoke、运行态证据和文档一致性通过。

## 每阶段共同门禁

- [ ] 只修改当前 Stage 范围，保留无关用户 / 并行工作树改动。
- [ ] 新资产先登记 manifest，再生成 / 接入；source、candidate、runtime 和 release 状态不混写。
- [ ] 非平凡脚本 / 测试有中文文件头与职责说明。
- [ ] 相关 GUT、Godot import、主场景 smoke、运行态复核和 `git diff --check` 有新鲜证据。
- [ ] 更新 `docs/progress/status.md`、`docs/progress/timeline.md` 和当日日志后才可声称完成。
