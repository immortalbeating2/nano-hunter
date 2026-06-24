# Animation Runtime Replacement Pass / 动作正式替换批次

## Summary

本计划启动动作正式替换批次，把当前已批准为 `final-ready source / hidden runtime preview` 的角色、敌人和 Boss sprite sheets，继续推进到真正可替换玩家 / 敌人 / Boss 运行时动画的标准。

当前 baseline：`55/55 final-ready` 资产包已完成，但原始 animation source 仍只是 preview / source。新增严格审计后，原 8 张 animation source sheets 为 `0/8 runtime replacement ready`、`8/8 blocked`；runtime candidate audit 已在 ARP-17 拆成活跃候选与归档参考：`15/15 active ready`、`0 active blocked`、`8 archived references`、`0 archive errors`。其中 Luna `idle` / `run` / `jump_fall` / `air_dash_body` / `attack_body` / `hit_react` / `death_idle` 已接入玩家运行时视觉层，Luna attack slash / seal arc 已在 ARP-18 拆为独立 VFX visual，Seal Guardian `idle` / `warning` / `attack_body` / `defeat` 已接入 Boss 运行时视觉层，四个普通敌人也已接入各自的单体 runtime visual，ARP-19 进一步把普通敌人受击 spark 从 Stage12 占位迁移到独立 runtime VFX visual。

## Stage Boundary / Preflight

- 本批次是 `Asset Production Track` 的 animation runtime polish，不是新玩法 Stage。
- 只有当替换动作改变玩家控制器、敌人 AI、Boss 状态机、hitbox / hurtbox、damage window 或 cancel window 时，才升级为对应 Stage14 / Stage15 / Stage16 polish 实施计划。
- 本轮先建立严格审计和替换门槛，不直接把 preview SpriteFrames 替换到 live controller。

## Key Changes

- 新增 `scripts/assets/audit_animation_runtime_replacement.py`。
- 新增 `docs/assets/animation-runtime-replacement-audit-report.json` 与 `.md`。
- 新增 `spec-design/2026-06-24-animation-runtime-replacement-pass.md`。
- 将动作替换标准明确为：不贴边、不跨格、无未解释 duplicate、脚底基线稳定、中心点漂移可控、角色动作与 VFX 分层、运行态测试通过。

## Current Audit Result

| Asset | Runtime replacement status | Main blockers |
| --- | --- | --- |
| `luna_idle_sheet_ai01` | blocked | 贴边、边距不足 |
| `luna_run_sheet_ai01` | blocked | 贴边、边距不足、duplicate frames |
| `luna_air_dash_sheet_ai01` | blocked | 贴边、边距不足、duplicate frames、脚底基线不稳 |
| `luna_attack_01_sheet_ai01` | blocked | 贴边、边距不足、内容缩放漂移 |
| `luna_jump_fall_sheet_ai01` | blocked | 贴边、边距不足、脚底基线不稳 |
| `luna_hit_death_sheet_ai01` | blocked | 贴边、边距不足、脚底基线不稳、内容缩放漂移 |
| `enemies_core_sheet_ai01` | blocked | 贴边、边距不足、脚底基线不稳 |
| `seal_guardian_boss_sheet_ai01` | blocked | 贴边、边距不足、脚底基线不稳 |

## ARP-01 Candidate Result

已从现有 final-ready source 派生第一组 runtime-normalized Luna idle / run 候选，候选不会覆盖原 source sheet：

- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_idle_runtime_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_idle_runtime_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_idle_runtime_sheet_ai01.spriteframes.tres`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_run_runtime_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_run_runtime_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_run_runtime_sheet_ai01.spriteframes.tres`

候选审计结果：

| Candidate | Source | Frames | Status | Key result |
| --- | --- | ---: | --- | --- |
| `luna_idle_runtime_sheet_ai01` | `luna_idle_sheet_ai01` | 16 | runtime_replacement_ready candidate | 最小边距 `left=36, top=8, right=36, bottom=8`，脚底基线漂移 `0` |
| `luna_run_runtime_sheet_ai01` | `luna_run_sheet_ai01` | 21 | runtime_replacement_ready candidate | 去除 source 中 3 个 exact duplicate frames；最小边距 `left=16, top=18, right=16, bottom=8`，脚底基线漂移 `0` |

接入结果：`luna_idle_runtime_sheet_ai01` 与 `luna_run_runtime_sheet_ai01` 已绑定到 `scenes/player/player_placeholder.tscn` 的可见 `LunaRuntimeAnimationVisual` 节点；`scripts/player/player_placeholder.gd` 根据 `current_state` 在 `idle` / `land` 与 `run` 之间切换 runtime SpriteFrames。Stage14 GUT 已保护该节点不是隐藏预览，并验证 `idle -> run` 的运行时资源切换。

边界：ARP-01 只正式替换 Luna idle / run 的视觉层，不改变移动参数、碰撞体、hitbox / hurtbox、damage timing 或 cancel window。

## ARP-02 Candidate / Binding Result

已从现有 final-ready source 派生第二组 runtime-normalized Luna jump/fall 与 air dash 候选，候选不会覆盖原 source sheet：

- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_fall_runtime_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_fall_runtime_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_fall_runtime_sheet_ai01.spriteframes.tres`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_air_dash_runtime_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_air_dash_runtime_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_air_dash_runtime_sheet_ai01.spriteframes.tres`

候选审计结果：

| Candidate | Source | Frames | Status | Key result |
| --- | --- | ---: | --- | --- |
| `luna_jump_fall_runtime_sheet_ai01` | `luna_jump_fall_sheet_ai01` | 24 | runtime_replacement_ready candidate | 最小边距 `left=24, top=40, right=24, bottom=8`，脚底基线漂移 `1` |
| `luna_air_dash_runtime_sheet_ai01` | `luna_air_dash_sheet_ai01` | 14 | runtime_replacement_ready candidate | 去除 source 中 2 个 exact duplicate frames；最小边距 `left=24, top=35, right=24, bottom=8`，脚底基线漂移 `0` |

接入结果：`luna_jump_fall_runtime_sheet_ai01` 已接入 `LunaRuntimeAnimationVisual`；`scripts/player/player_placeholder.gd` 根据 `current_state` 在 `jump_rise` / `jump_fall` 状态切换到 `jump_fall` runtime SpriteFrames。Stage14 GUT 已验证 `idle -> run -> jump_fall` 的运行时资源切换。

边界：`luna_air_dash_runtime_sheet_ai01` 只批准为 geometry-ready reference，不接 live dash。原因是该候选仍有部分能量拖尾 / 光效烘在角色帧里；ARP-13 已改用 clean body 版 `luna_air_dash_body_runtime_sheet_ai02` 接入 live dash。

## ARP-03 Candidate Result

已从现有 final-ready source 派生 Luna attack 与 hit/death 的 runtime-normalized candidates，候选不会覆盖原 source sheet：

- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_attack_01_runtime_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_attack_01_runtime_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_attack_01_runtime_sheet_ai01.spriteframes.tres`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_hit_death_runtime_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_hit_death_runtime_sheet_ai01.frames.json`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_hit_death_runtime_sheet_ai01.spriteframes.tres`

候选审计结果：

| Candidate | Source | Frames | Status | Key result |
| --- | --- | ---: | --- | --- |
| `luna_attack_01_runtime_sheet_ai01` | `luna_attack_01_sheet_ai01` | 16 | blocked | 已修正贴边、边距和基线；仍因 `unstable_content_scale` blocked，且 slash / cyan arc 仍烘在角色帧里 |
| `luna_hit_death_runtime_sheet_ai01` | `luna_hit_death_sheet_ai01` | 24 | blocked | 已修正贴边、边距和基线；仍因 `unstable_content_scale` blocked，站立受击到倒地跨度过大 |

边界：ARP-03 只生成 blocked candidates 和后续重生成依据，不接入 live attack、air attack、hit reaction 或 death 状态。正式替换前需要把 attack slash 拆到独立 VFX 层，并把 hit / death 拆成语义更稳定的短 clips，例如 `hit_react`、`knockdown`、`death_idle`。

## ARP-04 Split Candidate / Manual Correction Result

已从 ARP-03 blocked candidates 继续拆出短语义 clips：

- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_attack_body_runtime_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_hit_react_runtime_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_death_idle_runtime_sheet_ai01.png`

候选审计与人工复核结果：

| Candidate | Source | Frames | Status | Key result |
| --- | --- | ---: | --- | --- |
| `luna_attack_body_runtime_sheet_ai01` | `luna_attack_01_runtime_sheet_ai01` | 10 | blocked reference | 用户截图复核指出仍有相邻帧残片 / baked slash debris；已从 ready 撤回，标记为 `blocked_candidate_reference` |
| `luna_hit_react_runtime_sheet_ai01` | `luna_hit_death_runtime_sheet_ai01` | 11 | runtime_replacement_ready candidate | 几何审计通过；ARP-12 已接入 live hit reaction 视觉层 |
| `luna_death_idle_runtime_sheet_ai01` | `luna_hit_death_runtime_sheet_ai01` | 7 | runtime_replacement_ready candidate | 几何审计通过；ARP-12 已接入 live death idle 视觉层 |

门槛修正：`scripts/assets/audit_animation_runtime_replacement.py` 新增 `detached_frame_fragments` 与 `blocked_candidate_reference` gate。前者用于捕捉单格内明显断裂残片、相邻帧碎片或 baked VFX debris；后者确保保留在 manifest 中的失败样本不会被误判为 active ready candidate。

## ARP-05 Enemy Core Split Candidate Result

已从 `enemies_core_runtime_sheet_ai01` 继续拆出四个 enemy-specific runtime candidates，避免把多敌人 roster 误判为一个可接入 runtime clip：

- `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_basic_melee_runtime_sheet_ai01.png`
- `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_ground_charger_runtime_sheet_ai01.png`
- `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_aerial_sentinel_runtime_sheet_ai01.png`
- `assets/art/characters/enemies/sprite_sheets/runtime_replacement/enemy_miasma_caster_runtime_sheet_ai01.png`

候选审计与人工复核结果：

| Candidate | Source | Frames | Status | Key result |
| --- | --- | ---: | --- | --- |
| `enemies_core_runtime_sheet_ai01` | `enemies_core_sheet_ai01` | 32 | blocked reference | 几何可导入，但语义上是 `basic_melee` / `ground_charger` / `aerial_sentinel` / `miasma_caster` 多敌人合集，不能作为单个 runtime clip 接入 |
| `enemy_basic_melee_runtime_sheet_ai01` | `enemies_core_runtime_sheet_ai01` | 8 | runtime_replacement_ready candidate | 单敌人 clip，最小边距 `left=38, top=46, right=38, bottom=8`，脚底基线漂移 `1` |
| `enemy_ground_charger_runtime_sheet_ai01` | `enemies_core_runtime_sheet_ai01` | 8 | runtime_replacement_ready candidate | 单敌人 clip，最小边距 `left=24, top=44, right=24, bottom=8`，脚底基线漂移 `0` |
| `enemy_aerial_sentinel_runtime_sheet_ai01` | `enemies_core_runtime_sheet_ai01` | 8 | runtime_replacement_ready candidate | 单敌人 clip，最小边距 `left=28, top=44, right=27, bottom=8`，脚底基线漂移 `0` |
| `enemy_miasma_caster_runtime_sheet_ai01` | `enemies_core_runtime_sheet_ai01` | 8 | runtime_replacement_ready candidate | 单敌人 clip，最小边距 `left=36, top=44, right=36, bottom=8`，脚底基线漂移 `1` |

边界：ARP-05 只批准四个单敌人 clips 为 geometry-ready runtime candidates，尚未替换 `basic_melee_enemy.tscn` 或其它敌人场景的 live animation；正式接入前仍需敌人状态机、攻击窗口、碰撞体 / hurtbox 和 Stage15 运行态复核。

## ARP-06 Seal Guardian Boss Split Candidate Result

已从 `seal_guardian_boss_runtime_sheet_ai01` 继续拆出四个 Boss action-specific runtime candidates，避免把 idle / warning / attack / defeat 串联 sheet 误判为一个可接入 Boss `attack` clip：

- `assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_idle_runtime_sheet_ai01.png`
- `assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_warning_runtime_sheet_ai01.png`
- `assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_attack_runtime_sheet_ai01.png`
- `assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_defeat_runtime_sheet_ai01.png`

候选审计与人工复核结果：

| Candidate | Source | Frames | Status | Key result |
| --- | --- | ---: | --- | --- |
| `seal_guardian_boss_runtime_sheet_ai01` | `seal_guardian_boss_sheet_ai01` | 20 | blocked reference | 几何可导入，但语义上混合 `idle` / `warning` / `attack` / `defeat`，不能作为单个 Boss `attack` runtime clip 接入 |
| `seal_guardian_idle_runtime_sheet_ai01` | `seal_guardian_boss_runtime_sheet_ai01` | 4 | runtime_replacement_ready candidate | Boss idle 短 clip，最小边距 `left=25, top=52, right=25, bottom=8`，脚底基线漂移 `0` |
| `seal_guardian_warning_runtime_sheet_ai01` | `seal_guardian_boss_runtime_sheet_ai01` | 4 | runtime_replacement_ready candidate | Boss warning 短 clip，最小边距 `left=26, top=46, right=25, bottom=8`，脚底基线漂移 `0` |
| `seal_guardian_attack_runtime_sheet_ai01` | `seal_guardian_boss_runtime_sheet_ai01` | 8 | blocked reference | 几何可导入，但 cyan ground slash / impact VFX 仍烘在 Boss attack frames 中，正式接 live attack 前必须拆入独立 VFX atlas |
| `seal_guardian_defeat_runtime_sheet_ai01` | `seal_guardian_boss_runtime_sheet_ai01` | 4 | runtime_replacement_ready candidate | Boss defeat / seal-release 短 clip，最小边距 `left=25, top=45, right=25, bottom=8`，脚底基线漂移 `0` |

边界：ARP-06 只批准 Boss `idle`、`warning` 与 `defeat` 为 geometry-ready candidates，尚未替换 `seal_guardian_boss.tscn` 或 Stage15 Boss room 的 live animation；`attack` 因 VFX 分层问题 blocked，正式接入前还需补独立 Boss attack VFX atlas、damage window、hitbox / hurtbox 与 Stage15 GUT / 运行态复核。

## ARP-07 Seal Guardian Attack VFX Split Attempt

已尝试从 `seal_guardian_attack_runtime_sheet_ai01` 中拆出 Boss attack 身体层和独立 VFX atlas：

- `assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_attack_body_runtime_sheet_ai01.png`
- `assets/art/vfx/atlases/seal_guardian_attack_vfx_atlas_ai01.png`

候选审计与人工复核结果：

| Candidate | Source | Frames | Status | Key result |
| --- | --- | ---: | --- | --- |
| `seal_guardian_attack_body_runtime_sheet_ai01` | `seal_guardian_attack_runtime_sheet_ai01` | 8 | blocked reference | 自动拆出 lower ground VFX 后仍有上方 cyan slash 烘在 body frames 中，且底部清理留下可见洞 / detached fragments；不能作为正式 Boss attack body |
| `seal_guardian_attack_vfx_atlas_ai01` | `seal_guardian_attack_runtime_sheet_ai01` | 8 | VFX atlas candidate | 从低位 cyan ground slash / impact 区域提取的独立 VFX 候选；不参与角色 runtime replacement audit，后续需补 VFX rules、anchor、blend 和 Stage15 绑定复核 |

边界：ARP-07 证明当前 Boss attack 不能靠简单色彩扣图达到正式替换标准。后续应重新生成或人工清稿 Boss attack body，并把 attack trail / impact 完整放入独立 VFX atlas，再接 Stage15 Boss 状态机。

## ARP-08 Seal Guardian Attack VFX Rule Layer

已为 ARP-07 的独立 VFX atlas 补齐 first-pass VFX rules：

- `assets/art/vfx/vfx_rules/seal_guardian_attack_vfx_atlas_ai01.vfx_rules.json`
- `assets/art/vfx/vfx_rules/vfx_rules.index.json`

规则层结果：

| Asset | Rules | Status | Key result |
| --- | ---: | --- | --- |
| `seal_guardian_attack_vfx_atlas_ai01` | 8 | placeholder_ready | 每帧记录 `region`、`anchor_px=[128,154]`、`anchor_normalized=[0.5,0.802083]`、`recommended_blend=additive_alpha`，并显式设置 `gameplay_collision=false`、`damage_source=false` |

边界：ARP-08 只批准 Boss attack VFX atlas 的 first-pass anchor / blend / no-collision / no-damage 规则，不批准最终 VFX 清稿、Stage15 Boss room 绑定、伤害窗口、hitbox / hurtbox 或 live attack replacement。

## ARP-09 Seal Guardian Idle / Warning / Defeat Runtime Binding

已把 ARP-06 中通过几何审查的 Boss `idle`、`warning` 与 `defeat` 三段动作接入 `seal_guardian_boss.tscn` 的可见运行态动作层：

- `SealGuardianRuntimeAnimationVisual`
- `seal_guardian_idle_runtime_sheet_ai01`
- `seal_guardian_warning_runtime_sheet_ai01`
- `seal_guardian_defeat_runtime_sheet_ai01`

运行态绑定结果：

| State | Runtime asset | Binding result |
| --- | --- | --- |
| `idle` | `seal_guardian_idle_runtime_sheet_ai01` | Boss 初始 / 待机状态显示可见 runtime clip |
| `close_pressure` | `seal_guardian_warning_runtime_sheet_ai01` | Boss 进入读招预警时切换 warning clip |
| `defeated` | `seal_guardian_defeat_runtime_sheet_ai01` | Boss 被击败后切换 defeat clip |
| `ground_impact` / `air_punish` | `seal_guardian_attack_body_runtime_sheet_ai02` | ARP-14 后 Boss 攻击状态显示 clean attack body clip |
| `staggered` | 暂无正式 body clip | 运行态动作层隐藏，继续使用现有灰盒颜色 / VFX 读值 |

边界：ARP-09 当时只批准 `idle`、`warning` 与 `defeat` 三段 Boss runtime visual binding；ARP-14 已补上 clean `attack_body` live visual。`seal_guardian_attack_runtime_sheet_ai01` 与 `seal_guardian_attack_body_runtime_sheet_ai01` 仍 blocked，不再作为 live attack 来源。

## ARP-10 Enemy Core Runtime Visual Binding

已把 ARP-05 中拆出的四个单敌人 geometry-ready clips 接入对应普通敌人场景的可见 runtime visual 层：

- `enemy_basic_melee_runtime_sheet_ai01`
- `enemy_ground_charger_runtime_sheet_ai01`
- `enemy_aerial_sentinel_runtime_sheet_ai01`
- `enemy_miasma_caster_runtime_sheet_ai01`

运行态绑定结果：

| Scene | Runtime asset | Binding result |
| --- | --- | --- |
| `basic_melee_enemy.tscn` | `enemy_basic_melee_runtime_sheet_ai01` | 新增 `EnemyRuntimeAnimationVisual`，显示基础近战单体 clip |
| `ground_charger_enemy.tscn` | `enemy_ground_charger_runtime_sheet_ai01` | 新增 `EnemyRuntimeAnimationVisual`，显示地面冲锋单体 clip |
| `aerial_sentinel_enemy.tscn` | `enemy_aerial_sentinel_runtime_sheet_ai01` | 新增 `EnemyRuntimeAnimationVisual`，显示空中哨卫单体 clip |
| `miasma_caster_enemy.tscn` | `enemy_miasma_caster_runtime_sheet_ai01` | 新增 `EnemyRuntimeAnimationVisual`，显示瘴气施法敌单体 clip |

`BaseEnemy.receive_attack()` 现在会在敌人清除时同步隐藏 `EnemyRuntimeAnimationVisual`，保持视觉层和碰撞 / hurtbox 失效一致。

边界：ARP-10 只批准四个普通敌人的单体 runtime visual binding；不改变巡逻、冲锋、悬浮、瘴气压制、触碰伤害、攻击窗口、collision、hurtbox 或死亡反馈时序。`enemies_core_runtime_sheet_ai01` 继续保留为 blocked roster reference，不作为 live runtime clip 使用。

## ARP-11 Luna Attack Body AI02 Regeneration / Runtime Binding

已使用内置 `image_gen` 重新生成干净 Luna attack body 源图，并通过项目脚本整理为正式 runtime candidate：

- 源图：`assets/source/imagegen_inbox/animation_runtime_replacement/arp_11/imagegen_luna_attack_body_clean_source_ai02.png`
- 构建脚本：`scripts/assets/build_imagegen_luna_attack_body_candidate.py`
- Runtime sheet：`assets/art/characters/player/sprite_sheets/runtime_replacement/luna_attack_body_runtime_sheet_ai02.png`
- SpriteFrames：`assets/art/characters/player/sprite_sheets/runtime_replacement/luna_attack_body_runtime_sheet_ai02.spriteframes.tres`

构建结果：

| Candidate | Source | Frames | Status | Key result |
| --- | --- | ---: | --- | --- |
| `luna_attack_body_runtime_sheet_ai02` | built-in `image_gen` chroma strip | 8 | `runtime_replacement_ready` | 投影切出 8 个角色段，统一到 `192x160` cell；审计边距 `left=24, top=12, right=24, bottom=8`，脚底基线漂移 `0`，无相邻帧残片 |

运行态绑定结果：

| State | Runtime asset | Binding result |
| --- | --- | --- |
| `attack` | `luna_attack_body_runtime_sheet_ai02` | 玩家地面攻击显示干净 body clip |
| `air_attack` | `luna_attack_body_runtime_sheet_ai02` | 玩家空中攻击复用同一 body clip |

边界：ARP-11 只批准 Luna attack body 的运行态视觉层；不改变 `attack_startup_duration`、`attack_active_duration`、`attack_recovery_duration`、hitbox / hurtbox、伤害窗口、取消窗口或 `Stage12SlashPreview`。旧 `luna_attack_body_runtime_sheet_ai01` 继续作为 blocked reference 保留，用于记录等宽切割 / 残片问题。

## ARP-12 Luna Hit / Death Runtime Binding

已把 ARP-04 中通过 geometry / resource gate 的 Luna hit / death 短 clip 接入玩家运行态视觉层：

| Asset ID | Runtime state | Status | Notes |
| --- | --- | --- | --- |
| `luna_hit_react_runtime_sheet_ai01` | 非致命 `receive_damage()` 后的受击无敌窗口 | live runtime visual | 只替换视觉层；生命、击退、无敌时间和 HUD 快照不变 |
| `luna_death_idle_runtime_sheet_ai01` | `current_health <= 0` 后的 defeated visual | live runtime visual | death 优先级高于受击闪烁；恢复满血后退出 death / hit visual |

接入结果：`scripts/player/player_placeholder.gd` 在 `_is_defeated` 时优先显示 `death_idle`，在 `_damage_invulnerability_remaining > 0.0` 时显示 `hit_react`；`receive_damage()` 和 `restore_full_health()` 会立即同步 runtime visual。Stage14 GUT 新增非致命受击、致命死亡和恢复退出 death / hit visual 的断言。

边界：ARP-12 不改变 `receive_damage()` 的扣血、无敌、击退、defeated signal、checkpoint 恢复或任何 hurtbox / hitbox 时序。`luna_hit_death_runtime_sheet_ai01` 仍作为 blocked mixed reference 保留，不直接接入 live controller。

## ARP-13 Luna Air Dash Body AI02 Regeneration / Runtime Binding

已使用内置 `image_gen` 重新生成干净 Luna Air Dash body 源图，并通过项目脚本整理为正式 runtime candidate：

- 源图：`assets/source/imagegen_inbox/animation_runtime_replacement/arp_13/imagegen_luna_air_dash_body_clean_source_ai02.png`
- 构建脚本：`scripts/assets/build_imagegen_luna_air_dash_body_candidate.py`
- Runtime sheet：`assets/art/characters/player/sprite_sheets/runtime_replacement/luna_air_dash_body_runtime_sheet_ai02.png`
- SpriteFrames：`assets/art/characters/player/sprite_sheets/runtime_replacement/luna_air_dash_body_runtime_sheet_ai02.spriteframes.tres`

构建结果：

| Candidate | Source | Frames | Status | Key result |
| --- | --- | ---: | --- | --- |
| `luna_air_dash_body_runtime_sheet_ai02` | built-in `image_gen` chroma strip | 8 | `runtime_replacement_ready` | 投影切出 8 个角色段，统一到 `192x160` cell；审计通过，无 cyan energy ball、air trail、slash arc 或相邻帧残片 |

运行态绑定结果：

| State | Runtime asset | Binding result |
| --- | --- | --- |
| `dash` | `luna_air_dash_body_runtime_sheet_ai02` | 玩家 dash 状态显示干净 body clip |

边界：ARP-13 只批准 Air Dash body 的运行态视觉层；不改变 dash speed、dash duration、cooldown、Air Dash 解锁 / 消耗 / 落地恢复、碰撞、hurtbox / hitbox 或能力门控。旧 `luna_air_dash_runtime_sheet_ai01` 继续作为带 baked VFX 的 geometry-ready reference，不直接接入 live controller。

## ARP-14 Seal Guardian Attack Body AI02 Regeneration / Runtime Binding

已使用内置 `image_gen` 重新生成干净 Seal Guardian attack body 源图，并通过项目脚本整理为正式 runtime candidate：

- 源图：`assets/source/imagegen_inbox/animation_runtime_replacement/arp_14/imagegen_seal_guardian_attack_body_clean_source_ai02.png`
- 构建脚本：`scripts/assets/build_imagegen_seal_guardian_attack_body_candidate.py`
- Runtime sheet：`assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_attack_body_runtime_sheet_ai02.png`
- SpriteFrames：`assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_attack_body_runtime_sheet_ai02.spriteframes.tres`

构建结果：

| Candidate | Source | Frames | Status | Key result |
| --- | --- | ---: | --- | --- |
| `seal_guardian_attack_body_runtime_sheet_ai02` | built-in `image_gen` magenta strip | 8 | `runtime_replacement_ready` | 投影切出 8 个 Boss body 段，统一到 `256x192` cell；审计边距 `left=30, top=8, right=30, bottom=8`，脚底基线漂移 `0`，无 detached component blocker |

运行态绑定结果：

| State | Runtime asset | Binding result |
| --- | --- | --- |
| `ground_impact` | `seal_guardian_attack_body_runtime_sheet_ai02` | Boss 地面攻击状态显示 clean attack body |
| `air_punish` | `seal_guardian_attack_body_runtime_sheet_ai02` | Boss 空中惩罚状态复用 clean attack body |

边界：ARP-14 只批准 Boss attack body 的运行态视觉层；不改变 `windup_duration`、`strike_duration`、`recovery_duration`、`AttackArea`、伤害窗口、hurtbox / hitbox、Boss AI、room flow 或 `seal_guardian_attack_vfx_atlas_ai01`。旧 `seal_guardian_attack_runtime_sheet_ai01` 与 `seal_guardian_attack_body_runtime_sheet_ai01` 继续作为 blocked references 保留，用于记录 baked VFX / 清理洞问题。

## Implementation Plan

1. `ARP-00 Audit Gate`
   - 保留当前 preview assets，但禁止把它们视为正式 runtime replacement。
   - 用 `audit_animation_runtime_replacement.py` 输出可重复报告。
   - 把报告链接回资产文档和进度文档。

2. `ARP-01 Luna Idle / Run`
   - 优先重排或重生成 Luna idle / run。
   - 目标：循环动作可替换、脚底基线稳定、无 duplicate、无贴边。
   - 接入范围：只替换玩家视觉动画，不改变移动参数。
   - 当前进度：runtime-normalized candidates 已生成并通过 candidate strict audit；Player 正式视觉层已接入 idle / run；Stage14 GUT 通过。

3. `ARP-02 Luna Air Dash / Jump-Fall`
   - Air Dash trail 拆入独立 VFX 层，角色 sheet 只保留身体姿态。
   - Jump / fall 分段复核起跳、上升、下落和落地帧。
   - 当前进度：jump/fall runtime candidate 已生成、通过 strict audit 并接入 Player 正式视觉层；旧 air dash runtime candidate 因 VFX 烘入不接 live dash，ARP-13 已重生 clean body 版并接入 Player dash 状态。

4. `ARP-03 Luna Attack 01`
   - 重新生成或重排 attack sheet，slash VFX 独立为 VFX atlas。
   - 绑定 hitbox / damage window 前必须先通过 geometry audit。
   - 当前进度：attack 与 hit/death runtime-normalized candidates 已生成并导入 Godot，但作为 blocked reference 保留；`luna_attack_body_runtime_sheet_ai01` 也因人工复核发现残片被撤回 ready。

5. `ARP-04 Luna Hit / Death Split`
   - 当前进度：`hit_react` 与 `death_idle` 已拆分为 geometry-ready candidates，并在 ARP-12 接入玩家受击 / 死亡视觉层；`attack_body` 因相邻帧残片 blocked。
   - 后续要么重新生成干净 attack body，要么从独立逐帧源重新切，不再从污染 sheet 强行裁。

6. `ARP-05 Enemy Core`
   - 将多敌人 roster preview 拆为可替换的 enemy-specific clips。
   - 每个敌人至少明确 idle / move / attack / hit 的最小 clip 边界。
   - 当前进度：`enemies_core_runtime_sheet_ai01` 已降级为 blocked reference；四个单敌人 clips 已生成、Godot import 通过，并在 candidate audit 中通过 geometry/resource gate。

7. `ARP-06 Seal Guardian Boss`
   - 优先处理 warning / attack / recover。
   - 正式替换必须跟 Stage15 Boss room 和 Boss script 状态机测试一起走。
   - 当前进度：原 Boss 串联 sheet 已降级为 blocked reference；`idle`、`warning`、`defeat` 已生成并通过 geometry/resource gate；旧 `attack` 因 baked VFX blocked，ARP-14 已重生 clean attack body 并接入 Boss attack 状态。

8. `ARP-07 Seal Guardian Attack VFX Split`
   - 从 blocked Boss attack 中尝试拆 body 与 VFX。
   - 当前进度：`seal_guardian_attack_vfx_atlas_ai01` 已生成并可导入 Godot；`seal_guardian_attack_body_runtime_sheet_ai01` 因残留上方 slash、清理洞和 detached fragments blocked。
   - 当前修正：ARP-14 已改用内置 `image_gen` 重生 clean Boss attack body，不再从旧污染 sheet 强行清理。
   - 当前绑定：ARP-15 已把 `seal_guardian_attack_vfx_atlas_ai01` 接入 Boss attack VFX visual，并完成第一轮本地运行态截图复核；后续仍可继续 polish 亮度 / blend / 节奏。

9. `ARP-08 Seal Guardian Attack VFX Rules`
   - 为 `seal_guardian_attack_vfx_atlas_ai01` 补 first-pass VFX rule sidecar 和索引。
   - 当前进度：VFX rules 专项审计通过 `7 assets, 86 frame rules`；综合资产包审计通过并记录 `86 VFX rules`。
   - 当前绑定：Stage15 Boss 场景已新增显式 `SealGuardianAttackVfxVisual`，并保持 `gameplay_collision=false` / `damage_source=false` metadata。

10. `ARP-09 Seal Guardian Runtime Binding`
   - 把 `seal_guardian_idle_runtime_sheet_ai01`、`seal_guardian_warning_runtime_sheet_ai01` 与 `seal_guardian_defeat_runtime_sheet_ai01` 接入 `SealGuardianRuntimeAnimationVisual`。
   - 当前进度：Stage15 GUT 已保护 Boss `idle` / `warning` / `defeat` 状态；ARP-14 进一步把 clean `attack_body` 接入 `ground_impact` / `air_punish`。
   - 当前进度：ARP-15 进一步把 `seal_guardian_attack_vfx_atlas_ai01` 接入攻击状态的独立 VFX visual；第一轮运行态截图复核已确认 anchor / 遮挡可接受。

11. `ARP-10 Enemy Core Runtime Binding`
   - 把四个单敌人 runtime clips 接入对应普通敌人场景的 `EnemyRuntimeAnimationVisual`。
   - 当前进度：Stage15 GUT 新增四个普通敌人 runtime visual 引用与 defeated 隐藏断言并通过 `14/14`。
   - 下一步：如果要推进普通敌人攻击 / 受击 / 死亡多状态动画，需要为每类敌人重新生成分状态 clips，并补 AI 状态机映射与碰撞 / hurtbox 复核。

12. `ARP-11 Luna Attack Body AI02`
   - 用内置 `image_gen` 重新生成干净 Luna attack body 源图，避免继续从污染 sheet 强行裁切。
   - 当前进度：`luna_attack_body_runtime_sheet_ai02` 已通过 candidate audit 并接入玩家 `attack` / `air_attack` runtime visual；Stage14 GUT 通过 `13/13`、`184` asserts。

13. `ARP-12 Luna Hit / Death Runtime Binding`
   - 把已通过审计的 `luna_hit_react_runtime_sheet_ai01` 和 `luna_death_idle_runtime_sheet_ai01` 接入玩家受击 / 死亡视觉层。
   - 当前进度：Stage14 GUT 通过 `14/14`、`202` asserts；Stage15 GUT 通过 `14/14`、`239` asserts。
   - 下一步：若要完成完整攻击表现，还需要独立 slash / seal arc VFX atlas、VFX anchor rules、attack active frame 可视同步和人工运行态复核。

14. `ARP-13 Luna Air Dash Body AI02`
   - 用内置 `image_gen` 重新生成干净 Luna Air Dash body 源图，避免继续使用带 cyan energy / trail 的旧 air dash sheet。
   - 当前进度：`luna_air_dash_body_runtime_sheet_ai02` 已通过 candidate audit 并接入玩家 `dash` runtime visual；Stage14 GUT 通过 `15/15`、`211` asserts；Stage15 GUT 通过 `14/14`、`239` asserts。
   - 当前补充：ARP-16 已把 `AirDashTrailArt` 接入玩家 `dash` 的独立纯视觉拖尾层，并完成第一轮本地运行态截图复核。

15. `ARP-14 Seal Guardian Attack Body AI02`
   - 用内置 `image_gen` 重新生成干净 Seal Guardian attack body 源图，避免继续使用带 baked slash / ground impact 的旧 Boss attack sheet。
   - 当前进度：`seal_guardian_attack_body_runtime_sheet_ai02` 已通过 candidate audit 并接入 Boss `ground_impact` / `air_punish` runtime visual；Stage15 GUT 通过 `14/14`、`244` asserts；Stage14 GUT 通过 `15/15`、`211` asserts。
   - 当前进度：ARP-15 已继续完成 Boss attack VFX visual 显式绑定。

16. `ARP-15 Seal Guardian Attack VFX Runtime Binding`
   - 把 `seal_guardian_attack_vfx_atlas_ai01` 作为独立纯视觉层接入 Boss `ground_impact` / `air_punish`。
   - 当前进度：`SealGuardianAttackVfxVisual` 已引用 `boss_attack_vfx` 动画，并在 metadata 与测试中锁定 `gameplay_collision=false` / `damage_source=false`。
   - 当前复核：新增 `scripts/dev/capture_animation_runtime_replacement_review.gd`，本地截图和 JSON 报告写入 `tests/artifacts/local/animation-runtime-replacement/arp_15_seal_guardian_attack_vfx/`；报告确认 Boss 处于 `ground_impact`、body / VFX 均可见、VFX resource / metadata OK，且 VFX 节点下无 Area / Collision 子节点。
   - 下一步：如果继续 polish，可以微调 VFX 亮度、blend 和播放节奏；不需要再为“是否接入 attack VFX visual”开单独阻断。

17. `ARP-16 Luna Air Dash Trail VFX Runtime Binding`
   - 把 `stage14_air_dash_trail_ai01` 作为独立纯视觉层接入玩家 `dash` 状态。
   - 当前进度：`AirDashTrailArt` 只在 `STATE_DASH` 显示，跟随玩家朝向放在角色身后；metadata 与 Stage14 GUT 锁定 `gameplay_collision=false` / `damage_source=false`。
   - 当前复核：新增 `scripts/dev/capture_luna_air_dash_vfx_review.gd`，本地截图和 JSON 报告写入 `tests/artifacts/local/animation-runtime-replacement/arp_16_luna_air_dash_trail_vfx/`；报告确认玩家处于 `dash`、clean body / trail 均可见、trail resource / metadata OK，且 trail 节点下无 Area / Collision 子节点。
   - 下一步：如果继续 polish，可以微调 trail mask、blend、alpha 和持续时间；不需要再为“是否接入 Air Dash trail visual”开单独阻断。

18. `ARP-17 Active Candidate / Archived Reference Audit Split`
   - 把 candidate manifest 中的历史失败稿、污染切割稿和已被 clean body / 独立 VFX 替代的参考图，统一标记为 `archived_*` / `superseded_reference`。
   - 当前进度：`audit_animation_runtime_replacement.py` 默认只把活跃 runtime candidates 纳入 strict gate；归档参考仍保留在报告中，但必须声明 `superseded_by`，并由审计确认替代资产存在。
   - 当前结果：candidate strict audit 通过 `15/15 active ready`、`0 active blocked`、`8 archived references`、`0 archive errors`。
   - 边界：ARP-17 不删除旧失败样本，也不把归档参考重新批准为可接入动画；它只修正门禁口径，避免旧污染稿继续占用“待修 blocker”数字。

19. `ARP-18 Luna Attack Slash / Seal Arc VFX Runtime Binding`
   - 从现有 `vfx_combat_atlas_ai01` 与 `vfx_seal_magic_atlas_ai01` 派生两个小型运行态 SpriteFrames 子资源：`luna_attack_slash_vfx_runtime_ai01` 与 `luna_attack_seal_arc_vfx_runtime_ai01`。
   - 当前进度：玩家 `attack` / `air_attack` 状态现在同时显示 clean `luna_attack_body_runtime_sheet_ai02`、`AttackSlashVfxVisual` 与 `AttackSealArcVfxVisual`；旧 `Stage12SlashPreview` 保留为隐藏 legacy preview，不再由攻击起手触发。
   - 当前复核：新增 `scripts/dev/capture_luna_attack_vfx_review.gd`，本地截图和 JSON 报告写入 `tests/artifacts/local/animation-runtime-replacement/arp_18_luna_attack_vfx_runtime/`；报告确认玩家处于 `attack`、body / slash / seal arc 均可见，两个 VFX resource / metadata OK，旧 Stage12 SVG 隐藏，且 VFX 节点下无 Area / Collision 子节点。
   - 边界：ARP-18 只替换攻击表现的独立 VFX visual，不改变 `attack_startup_duration`、`attack_active_duration`、`attack_recovery_duration`、hitbox / hurtbox、伤害窗口、取消窗口、恢复充能或敌人受击逻辑。

20. `ARP-19 Enemy Hit Spark Runtime VFX Binding`
   - 把普通敌人的受击 spark 从 Stage12 占位 `Stage12HitSpark` 迁移到独立 `enemy_hit_spark_vfx_runtime_ai01`，并保留旧占位作为 hidden fallback。
   - 当前进度：`basic_melee_enemy.tscn`、`ground_charger_enemy.tscn`、`aerial_sentinel_enemy.tscn` 与 `miasma_caster_enemy.tscn` 均新增 `EnemyHitSparkVfxVisual`；`BaseEnemy.receive_attack()` 在敌人清除时优先显示该 runtime VFX。
   - 当前复核：新增 `scripts/dev/capture_enemy_hit_spark_vfx_review.gd`，本地截图和 JSON 报告写入 `tests/artifacts/local/animation-runtime-replacement/arp_19_enemy_hit_spark_vfx_runtime/`；报告确认基础敌人受击时 runtime VFX 可见、resource / metadata OK，且无 Area / Collision 子节点。
   - 边界：ARP-19 只替换普通敌人受击闪视觉，不改变 `receive_attack()`、击败契约、hurtbox、collision、defeated 信号或敌人 AI。

## Test Plan

- `python scripts/assets/audit_animation_runtime_replacement.py --write-report`
- `python scripts/assets/audit_animation_runtime_replacement.py --strict`
  - 原 source audit 预期失败：`0/8 ready, 8 blocked`。
  - candidate audit 当前预期通过：`15/15 active ready, 0 active blocked, 8 archived references, 0 archive errors`。
  - 归档参考不再作为 active strict blocker，但必须在 manifest 中声明 `superseded_by`，否则 strict audit 失败。
- `python scripts/assets/audit_animation_rules.py --strict`
- `python scripts/assets/audit_vfx_rules.py --strict`
- `godot --headless --path . --import`
- 替换 Luna 动作后运行 Stage14 GUT。
  - ARP-01 已执行：`godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit`，`12/12 passed`。
  - ARP-02 jump/fall 已执行同一 Stage14 GUT，`12/12 passed`，断言数 `176`。
  - ARP-11 attack body 已执行同一 Stage14 GUT，`13/13 passed`，断言数 `184`。
  - ARP-12 hit / death 已执行同一 Stage14 GUT，`14/14 passed`，断言数 `202`。
  - ARP-13 air dash body 已执行同一 Stage14 GUT，`15/15 passed`，断言数 `211`。
  - ARP-16 air dash trail VFX 已执行同一 Stage14 GUT，`15/15 passed`，断言数 `225`。
  - ARP-18 attack slash / seal arc VFX 已执行同一 Stage14 GUT，`15/15 passed`，断言数 `274`。
- 替换 Boss / enemy 动作后运行 Stage15 GUT。
  - ARP-09 Seal Guardian `idle` / `warning` / `defeat` 已执行：`godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd -gexit`，`13/13 passed`、`184` asserts。
  - ARP-10 普通敌人 runtime visual binding 已执行同一 Stage15 GUT，`14/14 passed`、`239` asserts。
  - ARP-14 Seal Guardian attack body 已执行同一 Stage15 GUT，`14/14 passed`、`244` asserts。
  - ARP-15 Seal Guardian attack VFX 已执行同一 Stage15 GUT，`14/14 passed`、`267` asserts。
  - ARP-18 Luna attack VFX 影响玩家攻击表现后已复跑同一 Stage15 GUT，`14/14 passed`、`267` asserts。
- 影响 DemoShell / Stage16 完成反馈时运行 Stage16 GUT。
- 每个正式替换动作做人工运行态复核：边缘裁切、脚底抖动、比例跳变、hitbox / hurtbox 误读、VFX 重叠和 HUD 遮挡。
  - ARP-15 Seal Guardian attack VFX 第一轮运行态复核已执行：`godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_animation_runtime_replacement_review.gd`，报告 `ok=true`。
  - ARP-16 Luna Air Dash trail VFX 第一轮运行态复核已执行：`godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_luna_air_dash_vfx_review.gd`，报告 `ok=true`。
  - ARP-17 candidate strict gate 已执行：`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict`，通过 `15/15 active ready`、`0 active blocked`、`8 archived references`、`0 archive errors`。
  - ARP-18 Luna attack slash / seal arc VFX 第一轮运行态复核已执行：`godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_luna_attack_vfx_review.gd`，报告 `ok=true`。
  - ARP-19 enemy hit spark runtime VFX 第一轮运行态复核已执行：`godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_enemy_hit_spark_vfx_review.gd`，报告 `ok=true`。

## Manual Review / Runtime Review

- 运行态复核必须截图或记录到 `tests/artifacts/local/animation-runtime-replacement/`。
  - ARP-15 本地证据路径：`tests/artifacts/local/animation-runtime-replacement/arp_15_seal_guardian_attack_vfx/seal_guardian_attack_vfx_runtime.png` 与同目录 JSON 报告。
  - ARP-16 本地证据路径：`tests/artifacts/local/animation-runtime-replacement/arp_16_luna_air_dash_trail_vfx/luna_air_dash_trail_runtime.png` 与同目录 JSON 报告。
  - ARP-18 本地证据路径：`tests/artifacts/local/animation-runtime-replacement/arp_18_luna_attack_vfx_runtime/luna_attack_vfx_runtime.png` 与同目录 JSON 报告。
  - ARP-19 本地证据路径：`tests/artifacts/local/animation-runtime-replacement/arp_19_enemy_hit_spark_vfx_runtime/enemy_hit_spark_vfx_runtime.png` 与同目录 JSON 报告。
- review 必须明确该动作是否替换 live controller，还是只停留在 hidden preview。
- 攻击与 Air Dash 必须同时检查独立 VFX 层，不允许把 slash / trail 继续烘在角色 cell 边缘。

## Assumptions

- 当前 8 张 animation sheets 都可作为风格、动作和后续清稿参考。
- `final-ready` 在本项目中仍表示 source / preview / direction ready，不等同于 formal runtime replacement ready。
- 现阶段优先做 Alpha Demo 可试玩替换，不追求完整商业级动作库。
