# Stage30 雷泽敌群、区域首领与元素吸收成长执行清单

## 设计与资产

- [x] 正式计划已锁定 `雷蚀獠`、`夔影雷骸`、吸收能力、组件和回访捷径：`plan/2026-08-01-stage30-thunder-enemies-boss-absorption.md`。
- [ ] Stage29 退出门通过。
- [ ] 登记 `NS30-ThunderEnemyFamily` 与 `NS30-ThunderBossFormal`。
- [ ] 普通敌人、Boss 两阶段动作、专属 VFX / 音频、Boss 房构图通过候选与来源门。

## 玩法实现

- [ ] `雷蚀獠` 复用 BaseEnemy，巡游 / 蓄雷只由导出参数区分。
- [ ] `夔影雷骸` 复用攻击入口、公开状态信号、快照与 `defeated`，普通攻击可完成。
- [ ] 风→雷 warning 破护雷、雷→风破势 / 击退优势可读且不重复扣血。
- [ ] Boss 击败授予 `thunder_absorption_unlocked` 与 `thunder_beast_core`，奖励幂等。
- [ ] 雷吸收对雷元素护印攻击额外削 `1` guard；组件只把雷风击退乘 `1.2`。
- [ ] 雷雨洼地吸收雷幕捷径只在击败后开放，不绕过首次主线。
- [ ] 妖性共鸣事件只触发一次，切房 / 读档后不重复。

## 验证

- [ ] Stage30 敌人 / Boss / 奖励 / 捷径专项通过。
- [ ] Stage21 / 22 / 24 / 25 / 26 邻近组合与递归全量通过。
- [ ] 动作锚点 / 时序、普通 / 序列打法、import、smoke、Gate26M 与 strict 资产审计通过。
- [ ] 状态、时间线和当日日志更新。
