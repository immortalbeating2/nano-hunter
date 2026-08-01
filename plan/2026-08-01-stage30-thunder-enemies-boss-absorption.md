# Stage30 雷泽敌群、区域首领与元素吸收成长计划

设计真源：`spec-design/2026-07-31-post-stage26-north-star-gap-and-stage27-32-roadmap.md`
美术基线：`docs/assets/2026-07-31-post-stage26-north-star-art-gap-assessment.md`
执行清单：`docs/implementation-plans/2026-08-01-stage30-thunder-enemies-boss-absorption.md`

## 目标

在现有六房内形成“普通敌群 → 两阶段雷泽首领 → 妖雷吸收 → 回访收益”闭环，不建立第二套敌人、Boss 或伤害框架。

## 冻结设计

- 普通敌人家族：`雷蚀獠`，一个主体通过导出参数形成巡游 / 蓄雷两种房间配置；覆盖 idle、move、warning、attack、hit、defeat。
- 区域首领：`夔影雷骸`，放入现有“驿路远眺”房并保持六房总数；两阶段、近压 / 落雷两类攻击、破势硬直与击败演出。
- 两序列优势：风→雷可在 warning 窗直接削穿护雷；雷→风扩大破势 / 击退窗口；普通攻击仍可完成战斗。
- 吸收能力：`thunder_absorption_unlocked`。战斗读值为雷元素命中有护印目标时额外削减 `1` 点 guard；回访门控为雷雨洼地中的一处吸收雷幕捷径，只在击败首领后开放，不跳过首次主线门控。
- 大妖组件：`thunder_beast_core`，加入现有两槽 Build 列表；效果为雷风散射击退再乘 `1.2`，不叠加新资源条。

## 实施顺序

1. 登记 `NS30-ThunderEnemyFamily`、`NS30-ThunderBossFormal`，完成概念、动作、VFX、音频和 Boss 房构图门禁。
2. 让普通敌人复用 BaseEnemy 的生命、攻击入口和 `defeated`，只追加 warning / 雷蓄能状态。
3. 以 Seal Guardian 的公开信号与状态快照为样板实现首领；复用 `receive_attack(...)`、可选 `receive_elemental_attack(...)`、`defeated`，不抽象通用 Boss 编辑器。
4. 在 Main 增加首领击败、吸收能力和第五件组件状态，并通过现有 Player 注入 / attack context 传递吸收标记。
5. 在现有雷雨洼地配置一处能力回访捷径；未解锁时保持原路线，解锁后只缩短返回路径。
6. 触发一次稳定 story event 表达 Luna 的妖性共鸣，接入吸收、奖励、首领 warning / impact / phase / defeat 音频。

## 验证

新增 Stage30 敌人 / Boss / 奖励 / 捷径专项；Stage21 / 22 / 24 / 25 / 26 邻近组合；普通打法、两序列打法、阶段切换、锚点 / 时序、递归全量、import、smoke、Gate26M 与 strict 资产审计。

## 退出标准

敌人、首领、两阶段、两序列优势、吸收能力、组件和回访捷径形成完整闭环；新角色 / VFX / 音频均为专属资产；普通攻击可通关且旧 Boss 行为不变。

## 非目标

不加第三元素、完整敌人生态、通用 Boss 工具、第二资源条、新房间或全地图捷径。
