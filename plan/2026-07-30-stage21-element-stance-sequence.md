# Stage21 元素、姿态与两步序列计划

设计真源：`spec-design/2026-07-30-stage21-element-stance-sequence.md`

执行清单：`docs/implementation-plans/2026-07-30-stage21-element-stance-sequence.md`

## 范围

- 在现有 Player 攻击入口内加入风 / 雷选择、疾 / 御选择和两步序列。
- Main 只持有跨房元素与姿态；序列继续是玩家局部战斗状态。
- TutorialHUD 复用现有面板样式显示元素、姿态、序列与窗口。
- 不修改房间拓扑、敌人类别、Boss 阶段、正式资产或 Build 系统。

## 公共契约

- Player：元素 / 姿态切换、序列快照、有效攻击判定与击退读值。
- Main：元素 / 姿态持久化，并把当前玩家序列转发到 Demo 快照。
- HUD：只消费 Player / Main 快照。

## 验证

- Stage21 专项覆盖输入、风印门槛、两种序列、倒计时、跨房和重开。
- 邻近回归覆盖 Stage3 / 6 / 10 / 13 / 15 / 17 / 20。
- 收口执行全量 GUT、Godot 4.6.3 import、主场景 smoke、运行态截图复核与 `git diff --check`。

## 退出标准

- 两元素、两姿态和两种顺序效果在三个既有战斗房可用。
- Stage20 的风印斩弹、Build、失败恢复与房间切换契约保持成立。
- 设计、实现、验证和当日进度留痕一致。
