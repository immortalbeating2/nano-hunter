# Stage22 敌人与 Boss 元素反应计划

## Goal

复用 Stage21 序列和现有 `receive_attack(...)`，为 Caster、Charger、Seal Guardian 与封印脉冲接入四个最小、可读、可回归的元素反应。

## Scope

- Player 在真实命中时提供当前元素、姿态和本次序列反应。
- `wind -> thunder` 清除 Caster 余弹，并在 Boss 预警期直接破印。
- `thunder -> wind` 让 Charger 破势退位，并把封印脉冲重置到休止段。
- 普通命中、敌人击败、Boss 生命和房间失败恢复继续走既有契约。

## Validation

- Stage22 专项先红后绿。
- 回归 Stage3 / 6 / 9 / 13 / 15 / 17 / 20 / 21。
- 运行 Godot import、递归全量 GUT、主场景 smoke、Windows/OpenGL 运行态复核和 `git diff --check`。

## Non-goals

- 不建元素伤害表、异常状态系统或新 Boss 阶段。
- 不新增资产、新敌人或第二套伤害结算。
