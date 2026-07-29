# Stage22 敌人与 Boss 元素反应执行清单

## 设计与失败契约

- [x] 冻结四个对象的反应窗口、反馈和重置边界。
- [x] 新增 Stage22 GUT，先证明上下文转发、普通命中兼容和四类反应。

## 实现

- [x] Player 只在可选元素反应入口存在时转发 Stage21 攻击上下文。
- [x] Caster / Charger 复用 BaseEnemy 击败契约接入追击破法与散射破势。
- [x] Seal Guardian 复用预警 / 护印 / staggered 接入单一破印窗口。
- [x] 封印脉冲复用既有相位机接入雷风错峰。

## 验证

- [x] Stage22 专项通过。
- [x] Stage3 / 6 / 9 / 13 / 15 / 17 / 20 / 21 邻近回归通过。
- [x] 全量 GUT、Godot import、主场景 smoke 和运行态复核通过。
- [x] 更新状态、时间线、日志与路线清单。
