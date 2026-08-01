# Stage27 正式战斗资产矩阵

## 边界

- 运行态动作只消费现有 gameplay state；动画帧不反向修改移动、hitbox、伤害、护印或状态机。
- 新图源均为当前 `nano-hunter` 会话内 Codex built-in `image_gen`，4x4 固定网格、magenta chroma、本地去背；来源与 hash 记录在 `asset-provenance-records.json`。
- `integrated` 表示场景真实引用，不表示外部发布条款已批准，也不替代 Gate26H 的动作连贯性、小尺寸读值和声音试听。

## Luna 动作矩阵

运行态复用既有 128 个基础 body 帧，并新增 16 个 Stage27 body 帧；合计 144 个独立运行图像帧。切换 / 恢复等短 clip 复用新增行内帧，不虚报为额外原画。

| Clip | Source | Anchor | Runtime condition |
| --- | --- | --- | --- |
| idle / run | existing ai03 | foot `y=176` | idle / horizontal run |
| jump_start / rise_hold / fall_hold / land | existing jump-state ai04 | body center / foot | existing jump states |
| apex | Stage27 row 2 frame 1 | body center | `abs(velocity.y) < 80` |
| air_dash | existing ai03 | body center | dash |
| swift attack | existing attack ai03 | foot | ground attack + swift + no sequence reaction |
| ward attack | Stage27 row 1 | foot `y=178` | ground attack + ward |
| air attack | Stage27 row 2 | body center | air attack |
| wind→thunder finisher | Stage27 row 3 | foot `y=178` | `wind_thunder_pierce` |
| thunder→wind finisher | Stage27 row 4 | foot `y=178` | `thunder_wind_scatter` |
| element switch / stance switch / recover | Stage27 row reuse | foot `y=178` | 0.22s presentation-only overlay |
| hit / death | existing ai03 | foot | existing damage / defeat state |

## 核心战斗 VFX

| Animation | Shape | Runtime timing | Authority |
| --- | --- | --- | --- |
| `wind_attack` | thin forward crescent | existing attack visual window, 4 sampled frames | visual only |
| `thunder_attack` | compact vertical strike | same | visual only |
| `wind_thunder_pierce` | narrow forward lance | same | visual only |
| `thunder_wind_scatter` | broad radial fan | same | visual only |

SpriteFrames cell is `256x192`; player nodes preserve `gameplay_collision=false` and `damage_source=false`. Damage geometry remains in `player_placeholder.gd`.

## Seal Guardian 动作与 VFX

| Boss state | Body clip | VFX clip |
| --- | --- | --- |
| close warning | `close_pressure` | `warning` |
| air warning / punish | `air_warning` / `air_punish` | `warning` / `impact` |
| ground impact / recovery | `ground_impact` / `recovery` | `impact` |
| guard break | `guard_break` | `guard_break` |
| phase 2 transition | `phase_transition` | `phase_transition` |
| hit / defeated | `hit` / `defeat` | existing flash / `defeat` |

Body cell is `256x192`, foot anchor `y=184`; VFX cell is `256x192`. Existing `receive_attack(...)`, `receive_elemental_attack(...)`, signals and damage timing remain unchanged.

## NS27-Audio 试听队列

生成并发固定为 `1`，输出只在 `D:/AI/audio/outputs/scratch/nano-hunter/stage27/`。格式均为 stereo / 44.1kHz / 16-bit / 1.500s WAV。

| Event candidate | File / seed | SHA-256 | Status |
| --- | --- | --- | --- |
| wind attack | `luna_wind_attack_seed2701.wav` | `04229e2b522cc06fb35d5548b86d6c813e7df24b164ef5c000a0167c63802905` | human listen pending |
| thunder attack | `luna_thunder_attack_seed2702.wav` | `2a530e4781c683934e3959695902abbd1ebd2a32ee5a937dba9c578cf8a45a60` | human listen pending |
| wind→thunder | `luna_wind_thunder_pierce_seed2703.wav` | `920eb9f279d5502f181756191a9ea5876ca3cb54a905c9037b00d02ab87832b5` | human listen pending |
| thunder→wind | `luna_thunder_wind_scatter_seed2704.wav` | `c8b507cb65d5ccea5d89a4b42e36d206040ee4328c46d688bba7279499bd6a0a` | human listen pending |
| Boss guard break | `seal_guardian_guard_break_seed2705.wav` | `c813327984a53e999c5a641e0a3c7da9967de5fb6e23d0594b98c3be47de9a61` | human listen + peak cleanup pending |
| UI confirm | `ui_confirm_seed2706.wav` | `31a20fb27c75c62daae90a48a85bf0c9dac54568cae71f3f55275d35d0bd8dae` | human listen + peak cleanup pending |

试听接受后才允许：裁切 / 峰值与响度统一 → 记录 accepted hash / tool terms → 转 OGG → 复制到 `assets/audio/` → 绑定事件与总线。当前不得声称已接入音频。
