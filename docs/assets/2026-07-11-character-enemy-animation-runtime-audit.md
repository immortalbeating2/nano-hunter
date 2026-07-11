# Character, Enemy and Boss Animation Runtime Audit

## 结论

- Luna、四类普通敌人和 Seal Guardian 都已经有运行态 PNG / SpriteFrames，不是“完全没做”。
- 当前问题主要不是节点动态修改 `scale`：`LunaRuntimeAnimationVisual` 始终使用 `scale = 0.45`、`position = (0, -16)`。
- Luna 的不稳定来自跨动作模型尺度没有统一锁定，以及动作时长没有匹配玩法状态。
- 四类普通敌人的 8 帧 cycle 已绑定，但没有 `autoplay`，脚本也没有调用 `play()`；当前运行态基本停在首帧。
- Seal Guardian 已按状态播放 idle / warning / attack / defeat，但攻击和 VFX 被 `0.18s` 攻击状态提前截断，`staggered` 状态没有动画映射，会隐藏 Boss 视觉约 `0.55s`。
- 现有审计只证明“单张 sheet 几何可用”，不能证明跨动作模型一致、播放时序正确或状态机完整。

## Luna 运行态绑定

| 动作 | 当前资源 | 帧数 / FPS | 资源时长 | 玩法时长 | 结论 |
| --- | --- | ---: | ---: | ---: | --- |
| Idle | `luna_idle_runtime_sheet_ai03` | 16 / 8 | 2.00s loop | 持续 | 稳定 |
| Run | `luna_run_runtime_sheet_ai03` | 24 / 18 | 1.33s loop | 持续 | 基线稳定，横向姿态明显放宽 |
| Jump / Fall | `luna_jump_fall_runtime_sheet_ai03` | 24 / 14 | 1.71s | 由物理决定 | 阻塞：按时间顺播，不区分上升 / 顶点 / 下落，脚底范围 `130-168`，播放结束后仍可能在空中重播 |
| Attack | `luna_attack_body_runtime_sheet_ai03` | 16 / 18 | 0.89s | 0.23s | 阻塞：通常只显示前约 4 帧，大部分动作帧永远到不了 |
| Air Dash | `luna_air_dash_body_runtime_sheet_ai03` | 16 / 20 | 0.80s | 0.24s | 阻塞：通常只显示前约 5 帧；动作内脚底漂移 18px |
| Hit React | `luna_hit_react_runtime_sheet_ai03` | 8 / 14 | 0.57s | 0.35s 无敌时间 | 阻塞：后段被截断，且受击动画与完整无敌时间直接绑定 |
| Death | `luna_death_idle_runtime_sheet_ai03` | 20 / 10 | 2.00s | 持续 | 可用；姿态尺寸变化属于倒地动作，但仍需终帧试玩 |

## Luna 跨动作尺寸证据

所有当前 ai03 动作都使用 `192x192` cell，但实际人物内容中位尺寸并不一致：

| 动作 | 内容宽度中位数 | 内容高度中位数 | 主要风险 |
| --- | ---: | ---: | --- |
| Idle | 84 | 143 | 基准 |
| Run | 116 | 140 | 宽度比 Idle 增加约 38%，可由跑姿解释，但需锁定头身比例 |
| Jump / Fall | 74 | 99 | 高度显著缩小，且最后回到站姿，最容易读成角色缩放 |
| Attack | 81 | 132 | 体量接近，但动画前段偏站立，命中动作不充分 |
| Air Dash | 98 | 91 | 横卧姿态合理，但状态太短导致姿态跳切 |
| Hit React | 109 | 115 | 轮廓明显放宽，需确认不是模型比例变化 |

## Luna Model Lock v1

后续生成、清稿和接入必须同时遵守这张锁定表：

| 字段 | 锁定值 / 规则 |
| --- | --- |
| Model ID | `luna_model_v1` |
| Canonical reference | `luna_idle_runtime_sheet_ai03` 的正面侧身造型、服装、发饰、法器和面部比例 |
| Cell | `192x192` |
| Runtime node | `LunaRuntimeAnimationVisual` |
| Runtime transform | `position = (0, -16)`，`scale = 0.45`；动作资源不得自行补偿 scale |
| Ground foot baseline | grounded 动作统一 `foot_y = 176 +/- 2px` |
| Center line | `center_x = 96 +/- 2px` |
| Standing body height | `140 +/- 6px`；攻击和受击不得通过缩小整个人物制造动作感 |
| Airborne rule | 可改变姿态包围盒，但头、躯干、四肢和法器的解剖比例必须保持与 canonical reference 一致 |
| VFX rule | slash、seal arc、dash trail、hit spark 与 body sheet 分离 |
| Generation rule | 每次只生成一个动作；固定 cell、固定镜头、透明背景、相同服装 / 发型 / 法器、禁止自动缩放主体 |

Model Lock 只能解决“画的是不是同一个 Luna”。还必须增加 `Animation State Contract`，解决“什么时候播哪一帧”：

- Jump 拆为 `jump_start / rise_hold / fall_hold / land`，由物理状态选 clip，不顺播整段 24 帧。
- Attack 用 `startup / active / recovery` 对齐关键帧，或只保留能在 `0.23s` 内读清的 4-6 帧。
- Air Dash 按 `0.24s` 重排 4-6 帧，最后一帧不得提前回站姿。
- Hit React 使用独立短计时，不直接占满无敌时间。
- 测试必须检查实际 frame progression、状态结束帧和跨动作像素高度，而不只检查资源路径与 animation 名。

## 普通敌人

| 敌人 | 当前动作资源 | 玩法状态 | 动画完成度 |
| --- | --- | --- | --- |
| Basic Melee | `enemy_basic_melee_runtime_sheet_ai01`，8 帧 cycle | 正弦巡逻、触碰伤害、一击清除 | 未完成：无 idle / move / attack / hit / defeat 拆分，cycle 未播放 |
| Ground Charger | `enemy_ground_charger_runtime_sheet_ai01`，8 帧 cycle | 巡逻、同高度触发、直线冲锋、恢复、一击清除 | 未完成：行为有状态，动画没有跟随 patrol / charge / recover，cycle 未播放 |
| Aerial Sentinel | `enemy_aerial_sentinel_runtime_sheet_ai01`，8 帧 cycle | 原地上下悬浮、触碰伤害、一击清除 | 未完成：只有悬浮占位，没有攻击动作，cycle 未播放 |
| Miasma Caster | `enemy_miasma_caster_runtime_sheet_ai01`，8 帧 cycle | 仅压力范围 VFX 和触碰伤害，没有真实弹体 | 未完成：没有 cast / projectile / recover / defeat，cycle 未播放 |

普通敌人共享的 `enemy_hit_spark_vfx_runtime_ai01` 能正常播放并在完成后隐藏；Miasma Caster 的压力 aura 也会显示。这些只证明局部 VFX 已接入，不等于敌人动作完成。

## Seal Guardian

| 状态 | 当前资源 | 状态时长 | 资源时长 | 结论 |
| --- | --- | ---: | ---: | --- |
| Idle | `seal_guardian_idle_runtime_sheet_ai01` | 持续 | 0.50s loop | 可用 |
| Close Pressure | `seal_guardian_warning_runtime_sheet_ai01` | 0.45s | 0.40s | 基本匹配 |
| Ground Impact / Air Punish | `seal_guardian_attack_body_runtime_sheet_ai02` | 0.18s | 0.67s | 阻塞：仅前约 2 帧可见 |
| Attack VFX | `seal_guardian_attack_vfx_atlas_ai01` | 0.18s | 0.67s | 阻塞：VFX 同样被截断 |
| Staggered | 无 | 0.55s / 二阶段 0.41s | - | 阻塞：代码会隐藏 runtime visual，Boss 在恢复期消失 |
| Defeated | `seal_guardian_defeat_runtime_sheet_ai01` | 持续 | 0.50s | 可用，但只有 4 帧 |

## 修复顺序

1. 先修运行时状态绑定：普通敌人开始播放、Boss stagger 不消失、攻击 / Dash / Hit 时长与帧数匹配。
2. 再锁 Luna Model Lock 和跨动作像素测量；不要先继续生成 ai04。
3. 将普通敌人按行为最少拆为 `idle_move / telegraph_attack / hit_defeat`，Miasma Caster 必须先决定是否真正实现弹体。
4. 最后补 Boss stagger / hit、完整 attack keyframes 和 VFX 同步。

## 证据边界

- 几何审计：`docs/assets/luna-unified-runtime-body-audit-report-2026-07-03.json`、`docs/assets/animation-runtime-replacement-candidate-audit-report.json`。
- 运行绑定：`scripts/player/player_placeholder.gd`、`scripts/combat/base_enemy.gd`、`scripts/combat/seal_guardian_boss.gd` 与对应 `.tscn`。
- 本地运行探针：四类普通敌人均为 `is_playing=false / frame 0 -> 0`；Boss 在 `state=staggered` 时 `visible=false`。证据保存在 `tests/artifacts/local/animation-content-audit/runtime_probe.json`。
- 本报告不修改玩法代码；下一批应先补失败测试，再修状态绑定。
