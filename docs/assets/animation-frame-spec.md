# Nano Hunter Animation Frame Spec

Last Updated: 2026-06-24

## 用途

本文件规定角色、敌人、Boss、VFX 的序列帧规格，重点保证主角 Luna 的动作帧数足够高，不把正式动画退回低帧原型表达。它服务 `Batch 06 - 角色与敌人动画帧`、`Batch 10 - VFX Atlas` 和 `Batch 11 - Spine 拆件图集`。

## 总原则

- Luna 是玩家长时间注视对象，帧数标准最高。
- 敌人和 Boss 以读值、预警和节奏清楚为先，不盲目追求与主角同帧数。
- 所有 sprite sheet 必须固定帧格尺寸、固定脚底基线、固定朝向和稳定缩放。
- Image gen 输出只作为候选与源素材；最终可接入版需要在 Aseprite / Krita 等工具中清稿、对齐和必要补帧。
- 高帧数优先用于运动连续性强的动作：run、air dash、attack combo、death、Boss attack。

## Luna 高帧数标准

| 动作 | 最低可用帧数 | 推荐正式帧数 | 优先级 | 备注 |
| --- | --- | --- | --- | --- |
| idle / breathing | 8 | 12-16 | P0 | 呼吸、披带、符纸轻动；不能大幅改变碰撞读值 |
| walk | 8 | 12-16 | P1 | 若后续保留 walk，需与 run 区分节奏 |
| run | 12 | 16-24 | P0 | 主角核心循环动作，必须高帧数、脚底稳定 |
| jump start | 4 | 6-8 | P0 | 起跳压缩和披带延迟 |
| jump rise | 4 | 6-8 | P0 | 上升姿态保持，避免抖动 |
| fall | 4 | 6-8 | P0 | 下落姿态可循环或分段 |
| land | 4 | 6-8 | P1 | 落地回弹和符纸 / 发带 follow-through |
| air dash | 8 | 12-16 | P0 | 高速但要读得清，单独配 VFX trail |
| ground dash | 8 | 12-16 | P1 | 若与 Air Dash 同能力，可共用部分姿态 |
| basic attack 1 | 8 | 12-16 | P0 | 起手、有效帧、收招必须清楚 |
| basic attack 2 / follow-up | 8 | 12-16 | P1 | 后续连段或演示用 |
| aerial attack | 8 | 12-16 | P1 | 不改变当前玩法前先作为候选 |
| hit / hurt | 4 | 6-8 | P0 | 受击方向和恢复窗口清楚 |
| recovery charge use | 8 | 12-16 | P1 | 只在机制稳定后接入 |
| death / defeat | 12 | 16-24 | P1 | Demo polish 时使用，不能过长影响重开节奏 |

## 敌人与 Boss 帧数标准

| 类型 | 动作 | 推荐帧数 | 备注 |
| --- | --- | --- | --- |
| 基础敌人 | idle / move | 6-10 | 保持成本低，轮廓变化清楚 |
| 基础敌人 | attack / hit / defeat | 6-12 | 攻击预警帧必须明确 |
| 瘴气妖术投射者 | cast / recover | 8-12 | 施法读值优先 |
| Seal Guardian | idle | 8-12 | 体量感和封印链轻动 |
| Seal Guardian | warning | 8-12 | 玩家必须能提前读懂 |
| Seal Guardian | attack | 12-20 | Boss 主动作，帧数高于普通敌人 |
| Seal Guardian | hit / stagger | 6-10 | 弱点反馈清楚 |
| Seal Guardian | defeat / seal release | 16-24 | 可作为 Stage16 polish 候选 |

## VFX 序列帧标准

| VFX | 推荐帧数 | 输出 |
| --- | --- | --- |
| slash | 6-10 | `assets/art/vfx/atlases/` |
| hit spark | 6-8 | `assets/art/vfx/atlases/` |
| air dash trail | 8-12 | `assets/art/vfx/atlases/` |
| boss warning | 8-12 | `assets/art/vfx/atlases/` |
| talisman relay | 8-12 | `assets/art/vfx/atlases/` |
| corruption purge | 12-16 | `assets/art/vfx/atlases/` |

## Sprite Sheet 拆分规则

- Luna 每个核心动作先独立成表，不急于合并大图集：
  - `assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.png`
  - `assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.png`
  - `assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.png`
- 单动作通过验证后，再合并到：
  - `assets/art/characters/player/sprite_sheets/luna_core_actions_sheet_ai01.png`
- 敌人与 Boss 同理，先按动作拆，再合并。
- 每张 sheet 必须在同一文件旁保留帧数、格子尺寸、动作名和来源记录，可写入同名 `.md` 或 manifest 备注。

## 正式运行时替换门槛

`final-ready source / hidden runtime preview` 不等于正式运行时替换。动作 sheet 只有通过以下门槛后，才能替换玩家、敌人或 Boss live controller 动画：

- 所有帧 alpha 内容不得触碰 cell 边界。
- 普通角色动作至少保留 `4px` 最小边缘透明，建议左右 `12px`；攻击、Air Dash、Boss 等大幅动作建议左右 `24px`。
- 不允许未解释的 exact duplicate frame hashes；如确实是 hold frame，必须在 metadata 中记录并由测试覆盖。
- 脚底 / 底部边界漂移必须可控，Luna 核心移动动作优先控制在 `10px` 以内。
- 横向中心点漂移不能导致 runtime position popping。
- 内容尺寸变化不能读成角色缩放漂移。
- 单个 runtime clip 只能表达一个角色 / 敌人 / Boss 的一个明确动作或短状态；多敌人 roster、多动作合集、展示用 contact sheet 即使几何审计通过，也必须先拆成 entity-specific / action-specific clips。
- 攻击 slash、Air Dash trail、hit spark 等 VFX 默认拆到独立 VFX atlas，不烘在角色动作 cell 边缘。
- 正式替换必须同步验证 `SpriteFrames`、动画名、播放速度、场景引用、hitbox / hurtbox、damage window、cancel window 和人工试玩读值。

当前正式替换审计入口：

- `scripts/assets/audit_animation_runtime_replacement.py`
- `docs/assets/animation-runtime-replacement-audit-report.md`
- `docs/assets/animation-runtime-replacement-candidate-audit-report.md`

## 推荐格子尺寸

| 对象 | 推荐单帧尺寸 | 备注 |
| --- | --- | --- |
| Luna | 128x128 或 160x160 | 当前原型可先 128，披带 / 武器较长时用 160 |
| 普通敌人 | 96x96 或 128x128 | 保持读值，不与 Boss 混淆 |
| Seal Guardian | 192x192 或 256x192 | Boss 可横向更宽 |
| 小图标动画 | 64x64 | UI atlas 中统一 |
| VFX | 128x64、128x128、192x128 | 按效果范围固定 |

## Image Gen 注意事项

- 直接让 image gen 一次生成 24 帧完整高质量 sheet 的一致性风险很高；推荐先生成 `8-12` 帧动作候选，再用 Aseprite / Krita 复制、补间、清稿和补帧到正式帧数。
- 对 Luna run、air dash、attack 这类 P0 动作，可以采用两步：
  1. 生成高一致性的 `8-12` 帧候选 sheet。
  2. 人工清稿并补到 `16-24` 帧正式 sheet。
- Seedance / Veo 适合做动作节奏参考，不直接作为游戏 sprite sheet。
- 若使用 Spine 拆件，Luna 仍需要少量 sprite sheet 作为风格和关键姿态参考。

## 接入验证

- Godot 导入前：检查透明背景、帧格尺寸、脚底基线、朝向、缩放、动作循环首尾。
- Godot 导入后：运行 `godot --headless --path . --import`。
- 替换 Luna 动画后：必须人工试玩检查移动、跳跃、Air Dash、攻击、受击和 HUD 遮挡。
- 如果动画改变玩家误读边界，必须按 `asset-ingestion-checklist.md` 记录并回退或修正。
