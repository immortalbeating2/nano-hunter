# Stage27 正式战斗美术、Luna 全动作集与首批音频计划

设计真源：`spec-design/2026-07-31-post-stage26-north-star-gap-and-stage27-32-roadmap.md`
美术基线：`docs/assets/2026-07-31-post-stage26-north-star-art-gap-assessment.md`
执行清单：`docs/implementation-plans/2026-08-01-stage27-formal-combat-art-audio.md`

## 目标

不改变 Stage21-22 战斗权威，把 Luna、四类攻击结果与 Seal Guardian 提升到正式 Demo 可读标准，并接入第一批战斗 / UI 声音。

## 实施顺序

1. 在 manifest 登记 `NS27-LunaFormalMotion`、`NS27-CoreCombatVFX`、`NS27-SealGuardianPolish`、`NS27-Audio`，冻结动作矩阵、cell、根部锚点、VFX 时序和事件表。
2. 先做最小运行验证包：疾印 / 御印攻击 body 与风击 / 雷击 / 风雷贯穿 / 雷风散射四种不同轮廓 VFX；确认状态映射后再批量清稿。
3. 完成 Luna idle、run、jump start / rise / apex / fall / land、air dash、两姿态地面攻击、空中攻击、两序列收势、元素切换、姿态切换、恢复、hit、death；玩法窗口仍由 `player_placeholder.gd` 权威控制。
4. 扩展现有 SpriteFrames 选择表，只按当前状态 / 姿态 / 反应选动画；不得由动画帧反向改变 hitbox、伤害或移动。
5. 为 Seal Guardian 补齐近 / 远 warning / attack、guard break / stagger、phase transition、hit、defeat 及 warning / impact / 破印 / 转阶段 / 消散 VFX，继续复用现有 Boss 状态机。
6. 用本机 Stable Audio 串行生成短 SFX 候选（默认并发 `1`，硬上限 `<4`）；候选只进入 scratch。逐项试听接受、记录 prompt / seed / runtime / 授权后再复制到项目并绑定事件。
7. 复用 DemoShell 的 Stage 选关数据，增加仅 `OS.is_debug_build()` 可见的“北极星全能力巡检”预设，调用现有 `start_demo_at_room(..., debug_progress)`。
8. 完成无 HUD 识别、锚点 / 体积 / 色边、小尺寸、音频叠爆与 Gate26M 回归。

## 主要触点

- `scripts/player/player_placeholder.gd` 与现有 Luna SpriteFrames / VFX 资源。
- `scripts/combat/seal_guardian_boss.gd`、`scenes/enemies/seal_guardian_boss.tscn` 与 Stage15 Boss 房。
- `scripts/ui/demo_shell.gd` 的既有调试选关入口。
- `assets/art/characters/`、`assets/art/vfx/`、`assets/audio/` 和资产治理文档。

## 验证

- Stage21、22、24、26 专项；玩家动画、Boss 状态和开发预设最小新 GUT；递归全量。
- Godot import、主场景 smoke、Gate26M 连续帧、运行截图、编辑器错误、strict 资产审计和 `git diff --check`。
- 声音事件覆盖、延迟、连续触发、总线音量与静音复核；人工试听接受单独记录。

## 退出标准

关闭文字提示仍能区分两元素、两姿态和两种序列；Luna 全动作与 Seal Guardian 完整演出在生产场景真实引用；开发预设不出现在 release build；首批接受音频可统一调音量。

## 非目标

不加第三元素、技能树、骨骼动画框架、完整 BGM / 语音或新房间。
