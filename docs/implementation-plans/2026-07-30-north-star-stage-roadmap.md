# 北极星后续 Stage 路线执行清单

## 范围

- 设计真源：`spec-design/2026-07-30-north-star-stage-roadmap.md`
- 正式入口：`plan/2026-07-30-north-star-stage-roadmap.md`
- 本清单按顺序跟踪 Stage21-26；每个 Stage 仍以独立设计与执行清单为准。

## Stage21 元素序列与符印姿态

- [x] Brainstorming：确认 `wind` / `thunder`、`疾` / `御` 的输入、战斗节奏和 UI 表达。
- [x] 设计：补 `spec-design/YYYY-MM-DD-stage21-element-stance-sequence.md`。
- [x] 计划：补 `plan/YYYY-MM-DD-stage21-element-stance-sequence.md` 和执行清单。
- [x] 实现目标：两元素、两姿态、两步序列窗口、两种顺序不同效果、HUD 展示。
- [x] 验证目标：Stage21 专项、邻近战斗、全量 GUT、Godot import、运行态复核。

## Stage22 敌人与 Boss 元素反应

- [x] 以前一阶段序列系统为唯一入口，不另建第二套伤害框架。
- [x] Caster / Charger / Seal Guardian 各接一个可读元素反应。
- [x] 封印脉冲接一个序列削弱或错峰效果。
- [x] 验证普通打法仍可通关，序列打法有明确优势。

## Stage23 镇妖驿站与悬赏榜

- [x] 将 Stage11 驿厅升级为最小悬赏入口。
- [x] 实现 2-3 个固定悬赏，不做随机任务。
- [x] 完成接取、追踪、完成、回交、奖励全流程。
- [x] 验证状态快照、暂停 / 地图 / 完成语义和重开边界。

## Stage24 圣物 / 组件 Build 深化

- [ ] 保留 2 槽上限。
- [ ] 将 `marsh_relic` / `warden_sigil` 纳入正式装备选择。
- [ ] 新增 2-3 个服务元素序列的圣物或组件。
- [ ] 验证装备组合对序列窗口、姿态冷却、恢复或攻击读值有可测影响。

## Stage25 第二区域原型

- [ ] 锁定雷泽荒原或等价第二区域主题。
- [ ] 新增 `6-8` 房小型区域，不扩到完整商业区域。
- [ ] 至少包含一个新区域机制、一个旧区回访口和一个小回环。
- [ ] 更新世界图 JSON、发现式地图、房间矩阵和对应测试。

## Stage26 北极星 Alpha Candidate

- [ ] 集成 Stage21-25，停止新增大系统。
- [ ] 完成真人首次通关、能力回访、悬赏回交和 Build 调整试玩。
- [ ] 复核实体手柄、暂停 / 地图 / HUD、失败恢复、音效缺口和存档边界。
- [ ] 更新 QA checklist、release notes、北极星完成度审计和进度文档。

## 当前不做

- [ ] 不一次做满 6-8 元素。
- [ ] 不在 Stage21 前扩新大区。
- [ ] 不提前做完整技能树、交易市集、通用对话系统或多结局。
- [ ] 不把路线图当作已完成实现。
