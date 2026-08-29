# Stage27-32 北极星 Beta 路线执行清单

> 2026-08-29 取代说明：本清单保留为旧 `44` 房 / Stage31 候选的历史执行记录。F01–F18 Blueprint V2 与后续整体关卡重设已取代 Gate26H → Stage32 依赖；旧 Gate26H 以 `SUPERSEDED / NOT EXECUTED` 关闭，未完成的真人项目不再按本清单执行。

## 入口

- [x] 北极星差距评估：`spec-design/2026-07-31-post-stage26-north-star-gap-and-stage27-32-roadmap.md`
- [x] 美术资产差距评估：`docs/assets/2026-07-31-post-stage26-north-star-art-gap-assessment.md`
- [x] 正式路线：`plan/2026-07-31-stage27-32-north-star-beta-roadmap.md`
- [x] Preflight26A、Gate26M、Stage27-31 已分别建立正式计划与同名执行清单。
- [x] 本次 Stage21-26 组合回归：`31/31` tests、`294` assertions；Godot MCP Pro 主场景与编辑器错误 `0`。
- [x] 开发前确认当前地形改动的提交 / 分支归属，确保 Stage27 从可验证基线开始：`eb98e47`。
- [x] 把 `stage19_discovery_map_base_ai01` 补入 runtime map / readiness / acceptance 边界，重新通过全部 strict 资产审计。

## Gate26M：可立即执行的 MCP / 自动技术门禁

- [x] Godot MCP Pro bridge workspace 与当前项目一致，`get_project_info`、运行态 InputMap 与编辑器错误可读。
- [x] 生产主场景模拟主菜单、暂停、地图、详情、攻击、元素 / 姿态切换和返回链。
- [x] 断言焦点、暂停状态、HUD、关键进度字段，并捕获 `6` 帧连续帧、截图与输出日志。
- [x] 未发现可重复产品问题，不新增 GUT；已记录 MCP 无法判断手感、迷路、误读和审美完成度。

## Gate26H：延后真人签核

- [x] 已批准延后到 Stage31 完成后；未完成时 Stage26 保持“待外部人工签核”，但不阻塞 Stage27-31。
- [x] Stage31 技术候选与正式真人执行单已交付：`docs/deliverables/stage31-north-star-alpha-candidate/gate26h-human-playtest-checklist.md`。
- [x] 2026-08-29：旧 Gate26H 因候选基线被取代，以 `SUPERSEDED / NOT EXECUTED` 关闭；不是 `PASS`。
- ~~真人从主菜单完成一次首次通关、能力回访、悬赏回交和两槽 Build 调整。~~ 未执行，转交未来新候选门禁。
- ~~用实体手柄记录菜单、元素 / 姿态切换、误按、舒适度和迷路点。~~ 未执行，转交未来新候选门禁。
- ~~复核 Luna 全动作、四类技能 VFX、Seal Guardian 与雷泽 Boss 的读招 / 命中 / 阶段表现。~~ 未执行，转交未来新候选门禁。
- ~~完成 Stage27-31 音频候选接受 / 拒绝、真实 21:9 和 32px / 64px UI 可读性记录。~~ 未执行，转交未来新候选门禁。

## Stage27：正式战斗美术、Luna 全动作集与首批音频

- [x] 专属设计边界与正式计划已冻结：`plan/2026-08-01-stage27-formal-combat-art-audio.md`。
- [x] 登记并制作 `NS27-LunaFormalMotion`、`NS27-CoreCombatVFX`、`NS27-SealGuardianPolish`，并登记 `NS27-Audio` scratch 候选。
- [x] 在既有 `7` clips / `111` 帧权威上增加 `16` 帧正式战斗补片，覆盖两姿态、空中、两序列收势、元素 / 姿态切换与恢复；基础 locomotion / hit / death 继续复用已验证 clips。
- [x] 四种攻击结果使用不同形状 / 节奏 VFX，不只换色。
- [x] Seal Guardian 增加 `16` 帧正式状态补片与 `16` 帧 VFX，覆盖近 / 远 warning / attack、guard break / stagger、phase transition、hit 与 defeat。
- [x] 通过 `local-game-audio` 以并发 `1` 串行生成首批战斗、Boss 预警和 UI scratch 候选并记录 prompt / seed / hash。
- [ ] 接入音频事件与音量设置，保留 prompt、seed、runtime、候选和授权记录。
- [x] 复用调试选关实现发布隔离的全能力预设。
- [x] 完成动作锚点 / 体积 / 色边、Boss 状态演出、专项 / 邻近 / 全量、import、smoke 与 MCP 自动复核。
- [ ] 无 HUD 真人识别、美术审美、音频试听 / 混音 / 授权与 Boss 手感留 Gate26H。

## Stage28：镇妖驿站叙事锚点与悬赏 / Build 表现

- [x] 专属设计边界与正式计划已冻结：`plan/2026-08-01-stage28-waystation-bounty-build-presentation.md`。
- [x] 登记并制作 `NS28-WaystationBackground`、`NS28-WaystationWorld` 与 `NS28-BountyBuildUI`，音频登记为 scratch 候选。
- [x] 正式驿站、三状态悬赏榜、驿卒与三段短事件接入生产场景。
- [x] 三悬赏、四 Build、两槽均有唯一图标与状态。
- [x] 复用 DetailPanel；不引入通用对话 / 任务框架。
- [x] 完成实际 Joypad 焦点、自动小尺寸门、事件去重和回归验证；MCP 发现并修复列表焦点跳过问题。
- [ ] 首次理解度、32px / 64px 真人可读性、音频试听与美术审美留 Gate26H。

## Stage29：雷泽荒原正式美术与区域机制清稿

- [x] 专属设计边界与正式计划已冻结：`plan/2026-08-01-stage29-thunder-waste-formal-art.md`。
- [x] 登记并制作 `NS29-ThunderWasteBackground / Environment / StateVFX`，音频登记为 scratch 候选。
- [x] 保持六房拓扑，替换瘴泽背景复用和关键 Polygon 灰盒表现。
- [x] 接入专用背景、TileSet、props、天气 / 机关 VFX；氛围、接地和 BGM 以并发 `1` 进入 scratch，未提前绑定。
- [x] 入口 checkpoint 完成雷泽前哨表现并登记 `thunder_outpost`，但不提前做传送。
- [x] 完成六房引用、碰撞对齐、原生 2K / 720p / 21:9 safe-boundary、专项与全量验证；真实 21:9 主观签核仍留 Gate26H。

## Stage30：雷泽敌群、区域首领与元素吸收成长

- [x] 专属设计边界与正式计划已冻结，锁定额外护印削减、雷幕捷径与雷兽妖核：`plan/2026-08-01-stage30-thunder-enemies-boss-absorption.md`。
- [x] 登记并制作 `NS30-ThunderEnemyFamily` 与 `NS30-ThunderBossFormal`。
- [x] 新增一个普通敌人家族和一个两阶段区域首领。
- [x] 两种现有序列均有可读优势，普通打法仍可完成。
- [x] 首领授予雷系吸收强化与一个大妖组件，并触发妖性共鸣事件。
- [x] 雷泽 Boss 覆盖两种 warning / attack、两阶段、phase transition、guard break / stagger、hit、defeat 与独立 warning / impact / phase / defeat VFX。
- [x] 完成新角色 SpriteFrames、VFX、音频 scratch、锚点 / 时序、Boss / 回访和全量验证；真人审美 / 试听留 Gate26H。

## Stage31：单档存档与双驿站传送

- [x] 专属设计边界与正式计划已冻结，字段白名单、version 1、backup 与双点传送契约明确：`plan/2026-08-01-stage31-save-and-waystation-travel.md`。
- [x] 登记并制作 `NS31-PersistenceTravelUI`。
- [x] 从 Main 快照实现一个本地存档和真实 Continue。
- [x] 保留上一有效档，损坏档可安全提示 / 新开。
- [x] 只实现 Stage11 与雷泽前哨两点、已发现后可用的传送。
- [x] 完成正常 / 旧版 / 损坏 / 写入失败 / 关闭重开 / 门控绕过测试，并交付 Gate26H 真人试玩包。

## Stage32：北极星 Beta Candidate

- [ ] 写专属收口设计、QA checklist、release notes 和完成度审计。
- [ ] 登记并制作 `NS32-BetaPresentation`，只处理发布候选必需项。
- [ ] 冻结内容，完成设置、宽屏、性能、Windows export 和最终 mix。
- [ ] 完成标题字、运行态美术总检与资产 / 音频发布授权复核。
- [ ] 完成陌生玩家首次通关、定向回访和实体手柄主观签核。
- [ ] 全量自动化、import、smoke、export smoke、运行态证据和文档一致性通过。

## 每阶段共同门禁

- [x] Stage27-31 均保持批准范围，无关用户 / 并行工作树改动未混入阶段提交。
- [x] 新资产先登记 manifest；source、candidate、runtime 和 release 状态保持分离。
- [x] 非平凡脚本 / 测试有中文文件头与职责说明。
- [x] 相关 GUT、Godot import、主场景 smoke、运行态复核和 `git diff --check` 均有新鲜证据。
- [x] Stage27-31 的状态、时间线和当日日志已逐阶段更新；旧 Gate26H 人工结果以 `SUPERSEDED / NOT EXECUTED` 关闭，未来新候选门禁待关卡设计冻结后定义。
