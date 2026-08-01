# Stage27 正式战斗美术、Luna 全动作集与首批音频执行清单

## 设计与登记

- [x] Stage27 设计边界已在北极星路线 spec 中冻结。
- [x] 正式计划：`plan/2026-08-01-stage27-formal-combat-art-audio.md`。
- [ ] Preflight26A 与 Gate26M 通过。
- [ ] manifest 登记四个 NS27 pack，补来源、授权、candidate / runtime / accepted 边界。
- [ ] 冻结 Luna 动作矩阵、Seal Guardian 动作矩阵、cell / root anchor、四 VFX 时序和音频事件表。

## Luna 与核心 VFX

- [ ] 最小验证包证明疾 / 御 body 与四类 VFX 可按现有状态稳定切换。
- [ ] Luna 基础移动：idle、run、jump start / rise / apex / fall / land、air dash。
- [ ] Luna 战斗：疾印、御印、空中攻击、风雷收势、雷风收势、元素切换、姿态切换、恢复、hit、death。
- [ ] 风击、雷击、风→雷、雷→风具有不同形状、节奏与 impact，不只换色。
- [ ] 动作不反向控制碰撞、移动、伤害或 hitbox；锚点 / 体积 / 色边 / 翻转通过运行审计。

## Seal Guardian 与音频

- [ ] 近 / 远 warning / attack、guard break / stagger、phase transition、hit、defeat 全部接入现有状态机。
- [ ] warning / impact / 破印 / phase / defeat VFX 在生产 Boss 房真实引用。
- [ ] Stable Audio 候选逐项生成到 scratch；未试听接受的不进入项目。
- [ ] 接受项补 prompt / seed / runtime / 授权记录并绑定攻击、命中、切换、序列、受伤、Boss 和 UI 事件。
- [ ] SFX 音量 / 静音可控，无明显延迟和叠爆。

## 开发入口与验证

- [ ] 增加仅 debug build 可见的北极星全能力巡检预设，复用 `start_demo_at_room`。
- [ ] Stage21 / 22 / 24 / 26、新增动画 / Boss / 预设专项与递归全量通过。
- [ ] import、smoke、Gate26M、strict 资产审计和 `git diff --check` 通过。
- [ ] 更新状态、时间线、日志；真人主观项明确留给 Gate26H。
