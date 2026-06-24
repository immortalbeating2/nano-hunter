# Nano Hunter Status

Last Updated: 2026-06-25

## Current Status

- 当前稳定游戏基线仍是 `main` 上的 Stage16 Alpha Demo 打包候选，包含最小 Demo 壳、Stage15 `Seal Guardian / 封印守卫`、`Recovery Charge / 恢复充能`、Stage16 五房终局封印链、Alpha Demo 完成反馈、`docs/deliverables/stage16-alpha-demo-candidate/` 交付物与第二轮资产 / 音频需求记录。
- Godot MCP Pro 1.13.1 增量已合并到主线；当前项目保留 `17605-17619` / `17620-17624`、rendezvous、workspace/session 握手和 diagnostic tools，并吸收 ping/pong、heartbeat timeout、idle/stale UI 与输入模拟修正。
- 资产生产线治理已合并到主线；`Asset Production Track / 资产生产线` 作为长期并行工作流运行，玩法 Stage 仍先用灰盒 / 占位验证，资产 Batch 同步生成候选，玩法稳定后再清理并接入可运行资产。
- 本次合并刻意排除了 Luna 行走关键帧生成内容：`assets/art/characters/player/luna_walk/`、`docs/progress/logs/2026-05-05.md` 和 `asset-manifest.md` 中对应行不进入本轮远端同步。

## Current Stable Baseline

- `main` 稳定基线：Stage16 Alpha Demo 打包候选已合并，主线验证通过。
- 当前可试玩方向：从教程、战斗原型、回溯门控、首个精英 Boss 原型推进到 Alpha Demo 候选；下一步默认进入 Alpha Demo 试玩反馈、稳定性修正与 Stage17 规划。
- 当前设计约束：后续阶段继续向南北朝东方奇幻、封妖禁地、瘴泽、妖域、符印机关等语境回收灰盒命名，不继续扩大现代实验室表达。
- 当前资产方向：围绕 Alpha Demo 候选补强 Luna、Air Dash、Seal Guardian、Stage16 UI / 终局反馈、区域表现、最小 SFX / BGM 和动画参考，不追求完整商业版资产量。
- 当前资产补齐目标已扩展为长期完整资产族：角色、关卡地图场景、UI / 界面、图标、道具与装备、特效、动画帧 / 序列帧、贴图、宣传运营、LOGO、CG、分镜和叙事剧情资产，并最终整理为 Godot 可用的 Sprite Sheet、Texture Atlas、Tile Set、Spine 拆件图集、UI 图集、特效图集和九宫格图片。
- 2026-06-25 复核结论：动作正式替换批次的活跃候选严格审计已通过，runtime source review queue 清零；当前剩余历史 blocked reference 仅作为归档证据保留，不再构成活跃替换阻塞。

## Recent Status Changes

### 2026-06-25 - Animation Runtime Replacement Pass 复核收口

- 状态：动作正式替换批次的活跃候选与来源复核已收口，当前 runtime source review queue 为 `0 review-required assets, 0 unsafe`，runtime source safety 为 `30 runtime assets, 0 review-required, 0 unsafe`，动作替换严格审计为 `15/15 active ready, 0 active blocked, 8 archived references, 0 archive errors`。
- 范围：本轮只做复核收口与状态同步，不新增 runtime 动作图、不替换玩法逻辑、不改 Boss / 敌人 / 玩家控制器行为。
- 验证：`python scripts/assets/build_runtime_source_review_queue.py` 通过并输出 `0 review-required assets, 0 unsafe`；`python scripts/assets/audit_runtime_source_safety.py --write-report` 通过并输出 `30 runtime assets, 0 review-required, 0 unsafe`；`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict` 通过并输出 `15/15 active ready, 0 active blocked, 8 archived references, 0 archive errors`。
- 边界：8 个历史 blocked reference 仍保留在候选清单中作为归档证据与重生成依据，但已不再被算作当前开发阻塞。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-18 Luna attack slash / seal arc VFX runtime binding

- 状态：Luna `attack` / `air_attack` 现在使用三层运行态表现：clean body `luna_attack_body_runtime_sheet_ai02`、独立 slash VFX `luna_attack_slash_vfx_runtime_ai01`、独立 seal arc VFX `luna_attack_seal_arc_vfx_runtime_ai01`。旧 `Stage12SlashPreview` 只保留为隐藏 legacy preview，不再作为正式攻击运行态视觉。
- 范围：新增两个由现有 VFX atlas 派生的 SpriteFrames 子资源；更新 `scripts/player/player_placeholder.gd`、`scenes/player/player_placeholder.tscn`、Stage14 GUT、`scripts/dev/capture_luna_attack_vfx_review.gd` 与资产 / 进度文档。两个攻击 VFX 均写入并验证 `gameplay_collision=false` 与 `damage_source=false`。
- 验证：Godot import 通过；Stage14 GUT 通过 `15/15`、`274` asserts；`godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_luna_attack_vfx_review.gd` 通过，报告显示玩家处于 `attack`，body / slash / seal arc 均可见，旧 Stage12 SVG 隐藏，两个 VFX resource / metadata OK，且无 Area / Collision 子节点。
- 边界：本轮只替换 Luna 攻击 VFX visual，不改变攻击起手、active / recovery 时长、hitbox / hurtbox、伤害窗口、取消窗口、恢复充能或敌人受击逻辑；后续仍可继续微调 VFX offset、alpha、播放速度和命中帧同步读感。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-19 Enemy hit spark runtime VFX binding

- 状态：普通敌人受击 spark 已从 Stage12 占位 `Stage12HitSpark` 迁移到独立 `enemy_hit_spark_vfx_runtime_ai01`；四类普通敌人现在在 `receive_attack()` 后显示新的 `EnemyHitSparkVfxVisual`，旧占位只保留为 hidden fallback。
- 范围：更新 `scripts/combat/base_enemy.gd`、四个普通敌人场景、Stage12 GUT、`scripts/dev/capture_enemy_hit_spark_vfx_review.gd` 与资产 / 进度文档；普通敌人受击闪现在明确是纯视觉 runtime VFX 层，不再依赖旧 Stage12 单张 SVG 占位。
- 验证：Godot import 通过；Stage12 GUT 通过 `9/9`、`147` asserts；Stage15 GUT 通过 `14/14`、`267` asserts；`godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_enemy_hit_spark_vfx_review.gd` 通过，报告显示基础敌人受击时 runtime VFX 可见，resource / metadata OK，且无 Area / Collision 子节点。
- 边界：本轮只替换普通敌人受击闪视觉，不改变 `receive_attack()`、击败契约、hurtbox、collision、defeated 信号或敌人 AI；后续若要继续 polish，可单独调整 spark 亮度、持续时间、扩散半径和与击败动作的同步读感。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-17 active candidate / archived reference audit split

- 状态：动作替换候选审计已从混合 `candidate / reference` 口径拆成活跃候选与归档参考；当前 strict gate 为 `15/15 active ready`、`0 active blocked`、`8 archived references`、`0 archive errors`。旧失败稿、污染切割稿和已被 clean body / 独立 VFX 替代的图仍保留为证据，但不再误算为 active blocker。
- 范围：更新 `scripts/assets/audit_animation_runtime_replacement.py`、`docs/assets/animation-runtime-replacement-candidates.json`、`docs/assets/animation-runtime-replacement-candidate-audit-report.json` 与 `.md`；归档参考必须声明 `superseded_by`，审计会确认替代资产存在。
- 验证：`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict` 通过；写报告审计输出同一结果。当前口径证明活跃 runtime sheet 几何 / 资源门禁已通过，不等于完整商业动作库或所有未来状态动画都已完成。
- 边界：ARP-17 只修正审计门禁和资产清单状态，不改变玩家、敌人、Boss、VFX 或 UI 的运行时引用；后续新增敌人多状态、Luna slash / seal arc polish、Boss VFX 节奏或 Stage17 内容时，仍需按对应 Batch / Stage 单独验证。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-16 Luna Air Dash trail VFX runtime binding

- 状态：`stage14_air_dash_trail_ai01` 已从静态提示 / standalone VFX source 推进到玩家 `dash` 状态的运行时拖尾视觉层；`LunaRuntimeAnimationVisual` 继续使用 clean `luna_air_dash_body_runtime_sheet_ai02`，拖尾由独立 `AirDashTrailArt` 显示。当前 candidate / reference audit 仍为 `16/23 ready, 7 blocked`，因为本轮不新增角色动作候选。
- 范围：更新 `scripts/player/player_placeholder.gd`、`scenes/player/player_placeholder.tscn`、`tests/stage14/test_stage_14_backtracking_and_ability_gating.gd` 与新增 `scripts/dev/capture_luna_air_dash_vfx_review.gd`；Air Dash trail 只在 `STATE_DASH` 显示，跟随朝向放在角色身后，并写入 / 验证 `gameplay_collision=false` 与 `damage_source=false`。
- 验证：Stage14 GUT 通过 `15/15`、`225` asserts；`godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_luna_air_dash_vfx_review.gd` 通过，写出本地截图和 JSON 报告到 `tests/artifacts/local/animation-runtime-replacement/arp_16_luna_air_dash_trail_vfx/`；报告显示玩家状态为 `dash`，clean body / trail 均可见，trail resource / metadata OK，且 trail 下无 Area / Collision 子节点。
- 边界：本轮只绑定 Air Dash trail visual，不改变 dash speed、dash duration、cooldown、Air Dash 解锁 / 消耗 / 落地恢复、碰撞、hurtbox / hitbox 或能力门控；`stage14_air_dash_trail_ai01.vfx_rules.json` 仍是 first-pass standalone VFX rule，后续可继续 polish mask / blend / alpha。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-15 Seal Guardian attack VFX runtime binding

- 状态：`seal_guardian_attack_vfx_atlas_ai01` 已从 first-pass VFX rules candidate 推进到 Seal Guardian Boss 攻击状态的运行时视觉层，并完成第一轮本地运行态截图复核；该节点只在 `ground_impact` / `air_punish` 显示，`idle` / `close_pressure` / `defeated` 隐藏。当前 candidate / reference audit 仍为 `16/23 ready, 7 blocked`，因为本轮不新增角色动作候选。
- 范围：更新 `scripts/combat/seal_guardian_boss.gd`、`scenes/enemies/seal_guardian_boss.tscn`、`scripts/dev/capture_animation_runtime_replacement_review.gd` 与 Stage15 GUT；新增 `SealGuardianAttackVfxVisual`，引用 `seal_guardian_attack_vfx_atlas_ai01.spriteframes.tres` 的 `boss_attack_vfx` 动画，并写入 `gameplay_collision=false` / `damage_source=false` metadata。运行态复核后将 VFX 下移到接近 Boss origin，并设置到 body 后方，减少遮挡。
- 验证：`godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_animation_runtime_replacement_review.gd` 通过，写出本地截图和 JSON 报告到 `tests/artifacts/local/animation-runtime-replacement/arp_15_seal_guardian_attack_vfx/`；报告显示 Boss 状态为 `ground_impact`，body / VFX 均可见，VFX resource / metadata OK，且 VFX 下无 Area / Collision 子节点。此前 `audit_vfx_rules.py --strict`、asset package audit、Godot import、Stage15 GUT `14/14`、`267` asserts、Stage14 GUT `15/15`、`211` asserts 已通过。
- 边界：本轮只绑定 Boss attack VFX visual，不改变 `AttackArea`、真实伤害判定、碰撞、hurtbox / hitbox、攻击时序、Boss AI 或房间流程；本地复核通过的是 anchor / 遮挡的第一轮 runtime readability，不等于最终 VFX 亮度、blend、粒子节奏或发布级美术 polish 完成。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-14 Seal Guardian attack body AI02 runtime binding

- 状态：旧 `seal_guardian_attack_runtime_sheet_ai01` / `seal_guardian_attack_body_runtime_sheet_ai01` 因 baked VFX、清理洞和 detached fragments 继续保留为 blocked references；本轮用内置 `image_gen` 重新生成 clean Boss attack body，并整理为 `seal_guardian_attack_body_runtime_sheet_ai02`。当前 candidate / reference audit 推进为 `16/23 ready, 7 blocked`。
- 范围：新增 `assets/source/imagegen_inbox/animation_runtime_replacement/arp_14/imagegen_seal_guardian_attack_body_clean_source_ai02.png`、`seal_guardian_attack_body_runtime_sheet_ai02.*` 和 `scripts/assets/build_imagegen_seal_guardian_attack_body_candidate.py`；更新 `scripts/combat/seal_guardian_boss.gd`、`scenes/enemies/seal_guardian_boss.tscn` 与 Stage15 GUT，让 Boss `ground_impact` / `air_punish` 状态使用干净 body layer。
- 验证：`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --write-report` 输出 `16/23 ready, 7 blocked`；`python scripts/assets/audit_asset_package.py --strict --write-report` 通过；`godot --headless --path . --import` 通过；Stage15 GUT 通过 `14/14`、`244` asserts；Stage14 GUT 通过 `15/15`、`211` asserts。
- 边界：本轮只替换 Boss attack body visual，不改变 `windup_duration`、`strike_duration`、`recovery_duration`、`AttackArea`、伤害窗口、hurtbox / hitbox、Boss AI 或房间流程；Boss attack VFX atlas 的状态机映射和运行态复核仍需后续单独完成。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-13 Luna air dash body AI02 runtime binding

- 状态：旧 `luna_air_dash_runtime_sheet_ai01` 虽通过几何审计，但含 baked cyan energy / trail，不再接 live dash；本轮用内置 `image_gen` 重新生成 clean body 源图，并整理为 `luna_air_dash_body_runtime_sheet_ai02`。当前 candidate / reference audit 推进为 `15/22 ready, 7 blocked`。
- 范围：新增 `assets/source/imagegen_inbox/animation_runtime_replacement/arp_13/imagegen_luna_air_dash_body_clean_source_ai02.png`、`luna_air_dash_body_runtime_sheet_ai02.*` 和 `scripts/assets/build_imagegen_luna_air_dash_body_candidate.py`；更新 `scripts/player/player_placeholder.gd`、`scenes/player/player_placeholder.tscn` 与 Stage14 GUT，让玩家 `dash` 状态使用干净 body layer。
- 验证：`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --write-report` 输出 `15/22 ready, 7 blocked`；`python scripts/assets/audit_asset_package.py --strict --write-report` 通过；`godot --headless --path . --import` 通过；Stage14 GUT 通过 `15/15`、`211` asserts；Stage15 GUT 通过 `14/14`、`239` asserts。
- 边界：本轮只替换 dash 视觉身体层，不改变 dash speed、dash duration、cooldown、Air Dash 解锁 / 消耗 / 落地恢复、碰撞、hurtbox / hitbox 或能力门控；完整 Air Dash VFX 播放时序仍需后续单独绑定和人工运行态复核。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-12 Luna hit / death runtime binding

- 状态：`luna_hit_react_runtime_sheet_ai01` 与 `luna_death_idle_runtime_sheet_ai01` 已从 geometry-ready candidate 推进到玩家 live runtime visual；当前 candidate / reference audit 仍为 `14/21 ready, 7 blocked`，因为本轮是接入既有 ready clips，不新增候选。
- 范围：更新 `scripts/player/player_placeholder.gd` 和 Stage14 GUT；玩家非致命受击切到 `hit_react`，致命受击切到 `death_idle`，恢复满血后退出 death / hit visual。死亡 visual 优先于受击闪烁，不继承 damage flash 调色。
- 验证：`godot --headless --path . --import` 通过；Stage14 GUT 通过 `14/14`、`202` asserts；Stage15 GUT 通过 `14/14`、`239` asserts；asset package audit 通过；candidate audit 写出 `14/21 ready, 7 blocked`。
- 边界：本轮只替换受击 / 死亡视觉层，不改变 `receive_damage()` 的扣血、无敌、击退、defeated signal、checkpoint 恢复、hurtbox / hitbox 或 HUD 逻辑。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-11 Luna attack body AI02 runtime binding

- 状态：用内置 `image_gen` 重新生成 Luna clean attack body 源图，并通过 `scripts/assets/build_imagegen_luna_attack_body_candidate.py` 投影切格 / 去绿幕 / 规范化为 `luna_attack_body_runtime_sheet_ai02`。新候选通过 formal runtime candidate audit，当前 candidate / reference audit 为 `14/21 ready, 7 blocked`。
- 范围：新增 `assets/source/imagegen_inbox/animation_runtime_replacement/arp_11/imagegen_luna_attack_body_clean_source_ai02.png`、`luna_attack_body_runtime_sheet_ai02.*`、构建脚本、candidate manifest 条目与审计报告；更新 `scripts/player/player_placeholder.gd`、`scenes/player/player_placeholder.tscn` 和 Stage14 GUT，让 `attack` / `air_attack` 只接入干净 body layer。
- 验证：`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --write-report` 输出 `14/21 ready, 7 blocked`；strict audit 按预期仍失败 `14/21 ready, 7 blocked`；`godot --headless --path . --import` 通过；Stage14 GUT 通过 `13/13`、`184` asserts。
- 边界：本轮不改变攻击判定、hitbox / hurtbox、伤害窗口、slash VFX、取消窗口或 Air Dash；旧 `luna_attack_body_runtime_sheet_ai01` 继续作为 blocked reference 保留。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-10 enemy core runtime binding

- 状态：四个普通敌人的单体 runtime clips 已接入对应场景的可见 `EnemyRuntimeAnimationVisual`：基础近战、地面冲锋、空中哨卫、瘴气施法敌。`BaseEnemy.receive_attack()` 现在会在敌人清除时隐藏该视觉层。
- 范围：更新 `scenes/combat/basic_melee_enemy.tscn`、`ground_charger_enemy.tscn`、`aerial_sentinel_enemy.tscn`、`miasma_caster_enemy.tscn`、`scripts/combat/base_enemy.gd` 与 Stage15 GUT；`enemies_core_runtime_sheet_ai01` 继续作为 blocked roster reference，不再被误用为单个 runtime clip。
- 验证：`godot --headless --path . --import` 通过；Stage15 GUT 通过 `14/14`、`239` asserts；candidate / reference strict audit 仍按预期失败 `13/20 ready, 7 blocked`。
- 边界：本轮只替换普通敌人视觉层，不改变巡逻、冲锋、悬浮、瘴气压制、触碰伤害、攻击窗口、collision、hurtbox 或死亡反馈时序。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-09 Seal Guardian runtime binding

- 状态：`Seal Guardian / 封印守卫` 已新增可见 `SealGuardianRuntimeAnimationVisual`，正式接入通过几何审查的 `idle`、`warning` 与 `defeat` 三段 Boss runtime clips；Boss 进入攻击 / 硬直状态时该 runtime visual 继续隐藏，避免误用 blocked attack frames。
- 范围：更新 `scenes/enemies/seal_guardian_boss.tscn`、`scripts/combat/seal_guardian_boss.gd` 与 Stage15 GUT，新增对 `seal_guardian_idle_runtime_sheet_ai01`、`seal_guardian_warning_runtime_sheet_ai01`、`seal_guardian_defeat_runtime_sheet_ai01` 的运行态状态切换保护。
- 验证：`godot --headless --path . --import` 通过；Stage15 GUT 通过 `13/13`、`184` asserts；candidate / reference strict audit 仍按预期失败 `13/20 ready, 7 blocked`，保留 Luna attack、Boss attack 等 blocker。
- 边界：本轮不是 Boss attack 正式替换；`seal_guardian_attack_runtime_sheet_ai01` 与 `seal_guardian_attack_body_runtime_sheet_ai01` 仍 blocked，正式接入前必须重新生成或人工清稿干净 body frames，并补 VFX / hitbox / damage window 复核。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-08 Seal Guardian attack VFX rules

- 状态：为 `seal_guardian_attack_vfx_atlas_ai01` 补齐 first-pass VFX rule sidecar，并把 VFX rules 索引从 `6 assets / 78 frame rules` 更新为 `7 assets / 86 frame rules`。该规则层明确只作为视觉 VFX anchor / blend 候选，全部帧仍禁用 `gameplay_collision` 与 `damage_source`。
- 范围：新增 `assets/art/vfx/vfx_rules/seal_guardian_attack_vfx_atlas_ai01.vfx_rules.json`，更新 `assets/art/vfx/vfx_rules/vfx_rules.index.json`，并修正 `scripts/assets/audit_asset_package.py` 的 VFX rules asset count 校验，使其读取索引预期而不是硬编码旧数量。
- 验证：`python scripts/assets/audit_vfx_rules.py --strict` 通过，`7 assets, 86 frame rules, 86 collision-disabled rules`；`python scripts/assets/audit_asset_package.py --strict --write-report` 通过并重写 `docs/assets/asset-package-audit-report.json`，报告 `86 VFX rules`；`godot --headless --path . --import` 通过。
- 边界：本轮不是 Boss attack live binding；`seal_guardian_attack_body_runtime_sheet_ai01` 仍 blocked，Stage15 Boss room 仍未接入该 VFX atlas，正式接入前还需要重新生成或人工清稿 Boss attack body，并补运行态复核。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-07 Seal Guardian attack VFX split attempt

- 状态：尝试从 blocked `seal_guardian_attack_runtime_sheet_ai01` 中拆出 `seal_guardian_attack_body_runtime_sheet_ai01` 与独立 `seal_guardian_attack_vfx_atlas_ai01`。VFX atlas 已生成并通过 Godot import；attack body 因残留上方 cyan slash、底部清理洞和 `detached_frame_fragments` 继续 blocked。candidate / reference audit 当前为 `13/20 runtime_replacement_ready`、`7 blocked`。
- 范围：扩展 `scripts/assets/build_animation_runtime_split_candidates.py`，新增 `remove_low_cyan_vfx` / `keep_low_cyan_vfx`，生成 Boss attack body blocked reference 与 `assets/art/vfx/atlases/seal_guardian_attack_vfx_atlas_ai01.*`，并刷新 `docs/assets/animation-runtime-replacement-candidates.json` 与 candidate audit 报告。
- 验证：ARP-07 dry-run `2 assets, 16 frames`；真实构建 `2 assets, 16 frames`；`python -m py_compile scripts/assets/build_animation_runtime_candidates.py scripts/assets/build_animation_runtime_split_candidates.py scripts/assets/audit_animation_runtime_replacement.py` 通过；`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict` 按预期失败，`13/20 ready, 7 blocked`；`godot --headless --path . --import` 通过并重新导入 Boss attack body PNG 与 attack VFX atlas PNG。
- 边界：本轮不是 Boss attack 修复完成，只是拆层尝试和失败样本留痕；正式 live binding 仍需要重新生成或人工清稿 Boss attack body，并给独立 VFX atlas 补 anchor / blend / VFX rules 与 Stage15 运行态复核。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-06 Seal Guardian Boss split candidates

- 状态：`seal_guardian_boss_runtime_sheet_ai01` 已从 active ready 候选降级为 `blocked_candidate_reference`，原因是它混合 `idle` / `warning` / `attack` / `defeat`，不是单个 Boss runtime clip。已拆出 `seal_guardian_idle_runtime_sheet_ai01`、`seal_guardian_warning_runtime_sheet_ai01`、`seal_guardian_attack_runtime_sheet_ai01` 与 `seal_guardian_defeat_runtime_sheet_ai01`；其中 `attack` 因 cyan ground slash / impact VFX 烘入帧内继续 blocked。candidate / reference audit 当前为 `13/19 runtime_replacement_ready`、`6 blocked`。
- 范围：扩展 `scripts/assets/build_animation_runtime_split_candidates.py` 的 ARP-06 Boss split specs，刷新 `docs/assets/animation-runtime-replacement-candidates.json` 与 candidate audit 报告，并在 `assets/art/characters/enemies/sprite_sheets/runtime_replacement/` 生成四个 Boss 短 clip 的 PNG、frames JSON、SpriteFrames 与 source records。
- 验证：Boss split dry-run `4 assets, 20 frames`；真实构建 `4 assets, 20 frames`；`python -m py_compile scripts/assets/build_animation_runtime_candidates.py scripts/assets/build_animation_runtime_split_candidates.py scripts/assets/audit_animation_runtime_replacement.py` 通过；`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict` 按预期失败，`13/19 ready, 6 blocked`；`godot --headless --path . --import` 通过并重新导入 4 张 Boss split PNG。
- 边界：Boss `idle`、`warning`、`defeat` 只批准为 geometry-ready candidates，尚未替换 `seal_guardian_boss.tscn`、Boss 状态机、Stage15 Boss room 或 damage / hurtbox 时序；Boss `attack` 需要先拆出独立 VFX atlas 后才能继续 live binding。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-05 enemy core split candidates

- 状态：`enemies_core_runtime_sheet_ai01` 已从 active ready 候选降级为 `blocked_candidate_reference`，原因是它是多敌人 roster，不是单个 runtime clip。已拆出 `enemy_basic_melee_runtime_sheet_ai01`、`enemy_ground_charger_runtime_sheet_ai01`、`enemy_aerial_sentinel_runtime_sheet_ai01` 与 `enemy_miasma_caster_runtime_sheet_ai01` 四个单敌人 geometry-ready candidates。candidate / reference audit 当前为 `11/15 runtime_replacement_ready`、`4 blocked`。
- 范围：扩展 `scripts/assets/build_animation_runtime_split_candidates.py` 支持 per-spec 输出目录与 `--only`，把敌人合集拆分写入 `assets/art/characters/enemies/sprite_sheets/runtime_replacement/`，并刷新 `docs/assets/animation-runtime-replacement-candidates.json` 与 candidate audit 报告。
- 验证：enemy split dry-run `4 assets, 32 frames`；真实构建 `4 assets, 32 frames`；`python -m py_compile scripts/assets/build_animation_runtime_candidates.py scripts/assets/build_animation_runtime_split_candidates.py scripts/assets/audit_animation_runtime_replacement.py` 通过；`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict` 按预期失败，`11/15 ready, 4 blocked`；`godot --headless --path . --import` 通过并重新导入 6 张相关 PNG。
- 边界：四个敌人 clip 只批准为 geometry-ready candidates，尚未替换敌人 live animation、AI 状态机、攻击窗口、碰撞体或 hurtbox；`Seal Guardian` 当前仍只是 geometry-ready Boss candidate，正式接 Boss room 前需继续拆 warning / attack / recover 并跑 Stage15 验证。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-04 split correction

- 状态：根据用户截图复核，`luna_attack_body_runtime_sheet_ai01` 仍存在相邻帧残片 / baked slash debris，已从 ready 候选撤回并标记为 `blocked_candidate_reference`。candidate / reference audit 当前为 `6/9 runtime_replacement_ready`、`3 blocked`。
- 范围：新增 `scripts/assets/build_animation_runtime_split_candidates.py`，从 ARP-03 blocked candidates 派生 `luna_attack_body_runtime_sheet_ai01`、`luna_hit_react_runtime_sheet_ai01` 与 `luna_death_idle_runtime_sheet_ai01`；扩展 `scripts/assets/audit_animation_runtime_replacement.py`，新增 `detached_frame_fragments` 与 `blocked_candidate_reference` gate。
- 验证：split dry-run `3 assets, 28 frames`；真实构建 `3 assets, 28 frames`；`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict` 按预期失败，`6/9 ready, 3 blocked`；报告明确列出 `luna_attack_body_runtime_sheet_ai01` 为 blocked reference。
- 边界：`luna_hit_react_runtime_sheet_ai01` 与 `luna_death_idle_runtime_sheet_ai01` 只批准为 geometry-ready candidates，尚未接 live hit/death；`attack_body` 需要重新生成干净角色身体帧或从独立逐帧源重切，不再从污染 sheet 强行裁。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-03 Luna attack / hit-death blocked candidates

- 状态：继续派生 `luna_attack_01_runtime_sheet_ai01` 与 `luna_hit_death_runtime_sheet_ai01`，但 candidate strict audit 当前为 `4/6 runtime_replacement_ready`、`2 blocked`。ARP-03 两个新候选均只作为 blocked candidate / 重生成依据，不接入 live attack、air attack、hit reaction 或 death 状态。
- 范围：使用 `scripts/assets/build_animation_runtime_candidates.py --pass-id ARP-03 --merge-existing` 生成 attack 与 hit/death runtime PNG、frames JSON、SpriteFrames 和 source records；刷新 `docs/assets/animation-runtime-replacement-candidates.json` 与 candidate audit 报告。
- 验证：ARP-03 dry-run `2 assets, 40 frames`；真实构建 `2 assets, 40 frames`；`godot --headless --path . --import` 通过并重新导入两个 ARP-03 PNG；`python scripts/assets/audit_animation_runtime_replacement.py --candidate-manifest docs/assets/animation-runtime-replacement-candidates.json --strict` 按预期失败，`4/6 ready, 2 blocked`。
- 边界：`luna_attack_01_runtime_sheet_ai01` 与 `luna_hit_death_runtime_sheet_ai01` 均被 `unstable_content_scale` 阻止；attack 还需要把 slash / cyan arc 拆到独立 VFX 层，hit/death 需要拆成更稳定的 `hit_react`、`knockdown`、`death_idle` 等语义 clips。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-02 Luna jump/fall runtime binding

- 状态：在 ARP-01 idle / run 之后，继续派生 `luna_jump_fall_runtime_sheet_ai01` 与 `luna_air_dash_runtime_sheet_ai01`；candidate strict audit 当前为 `4/4 runtime_replacement_ready`、`0 blocked`。其中 Luna `jump_fall` 已接入玩家可见 `LunaRuntimeAnimationVisual`，`air_dash` 暂保留为 geometry-ready candidate。
- 范围：扩展 `scripts/assets/build_animation_runtime_candidates.py` 支持 `--pass-id` 与 `--merge-existing`，避免 ARP-02 覆盖 ARP-01；更新 `docs/assets/animation-runtime-replacement-candidates.json`、candidate audit 报告，以及 `assets/art/characters/player/sprite_sheets/runtime_replacement/` 下的 jump/fall 与 air dash PNG、frames JSON、SpriteFrames 和 source records；更新 `scripts/player/player_placeholder.gd` 与 Stage14 GUT，让 `jump_rise / jump_fall` 使用 jump/fall runtime sheet。
- 验证：ARP-02 dry-run `2 assets, 38 frames`；真实构建 `2 assets, 38 frames`；candidate strict audit `4/4 ready, 0 blocked`；`godot --headless --path . --import` 通过并重新导入两个 ARP-02 PNG；`godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit` 通过，`12/12 passed`、`176` asserts。
- 边界：本轮只正式替换 Luna `jump_fall` 的运行时视觉层，不改变跳跃参数、碰撞、hitbox / hurtbox、damage timing 或 cancel window；`luna_air_dash_runtime_sheet_ai01` 因仍需复核与独立 `AirDashTrailArt` 的 VFX 分层关系，暂不接 live dash。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-01 Luna idle / run runtime binding

- 状态：基于现有 final-ready source 派生并接入 `luna_idle_runtime_sheet_ai01` 与 `luna_run_runtime_sheet_ai01` 两个 runtime-normalized 候选；候选层严格审计为 `2/2 runtime_replacement_ready`、`0 blocked`，并已绑定到玩家可见 `LunaRuntimeAnimationVisual`。原 8 张 source sheets 仍保持 `0/8 ready, 8 blocked`，不被误判为正式替换。
- 范围：新增 `scripts/assets/build_animation_runtime_candidates.py`、`docs/assets/animation-runtime-replacement-candidates.json`、`docs/assets/animation-runtime-replacement-candidate-audit-report.json` / `.md`，生成 `assets/art/characters/player/sprite_sheets/runtime_replacement/` 下的 idle / run PNG、frames JSON、SpriteFrames 和 source records；更新 `scenes/player/player_placeholder.tscn`、`scripts/player/player_placeholder.gd` 与 Stage14 GUT，让 `idle / land` 使用 idle runtime sheet、`run` 使用 run runtime sheet。
- 验证：candidate dry-run `2 assets, 37 frames`；真实构建 `2 assets, 37 frames`；candidate strict audit `2/2 ready, 0 blocked`；`godot --headless --path . --import` 通过并重新导入两个 runtime candidate PNG；`godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit` 通过，`12/12 passed`；像素检查未发现不透明绿幕残留。
- 边界：本轮只正式替换 Luna idle / run 的运行时视觉层，不改变移动参数、碰撞、hitbox / hurtbox、damage timing 或 cancel window；跳跃、攻击、dash、受击、敌人和 Boss 动作仍未达到正式替换标准。

### 2026-06-24 - Animation Runtime Replacement Pass ARP-00 audit gate

- 状态：正式启动 `Animation Runtime Replacement Pass / 动作正式替换批次`，把当前 8 张角色 / 敌人 / Boss animation sheets 从 hidden/runtime preview 标准升级到 formal runtime replacement 审计标准。新增严格审计后，当前为 `0/8 runtime replacement ready`、`8/8 blocked`；这确认 `55/55 final-ready` 资产包仍只是 source / preview / direction ready，不等于 live controller 动画可替换。
- 范围：新增 `spec-design/2026-06-24-animation-runtime-replacement-pass.md`、`docs/implementation-plans/2026-06-24-animation-runtime-replacement-pass.md`、`scripts/assets/audit_animation_runtime_replacement.py`、`docs/assets/animation-runtime-replacement-audit-report.json` 与 `.md`，并把正式替换门槛同步到 `docs/assets/animation-frame-spec.md`。
- 验证：`python scripts/assets/audit_animation_runtime_replacement.py --write-report` 输出 `0/8 ready, 8 blocked`；`python scripts/assets/audit_animation_runtime_replacement.py --strict` 按预期失败，用于阻止当前 preview sheets 被误判为正式替换；`python scripts/assets/audit_animation_rules.py --strict` 仍通过 `8 assets, 172 frame rules`。
- 边界：本轮建立正式替换审计门槛和执行计划；后续从 Luna idle / run 开始逐动作重生或重排，通过几何审计后再接入运行态。

### 2026-06-24 - P2 final-ready mini pack 26

- 状态：第二十六批 `7` 个 P2 promo / CG / story 资产从 `structural-ready` 推进为 `final-ready` direction source：`capsule_art_alpha_demo_ai01`、`cg_seal_guardian_reveal_ai01`、`nano_hunter_logo_direction_ai01`、`promo_key_art_sheet_ai01`、`storyboard_intro_bounty_ai01`、`storyboard_miasma_marsh_ai01`、`storyboard_narrative_sheet_ai01`。当前整体为 `55/55 structural-ready`、`55/55 final-ready`、`0/55 blocked`；P0 / P1 / P2 blocked assets 均已清零。
- 范围：不新增图片生成；复核既有 image_gen promo / logo / CG / storyboard outputs，生成 P2 promo / story contact sheet，补齐 finalization review，并按顺序刷新 art readiness、final-art queue、acceptance gates、family coverage、asset package 与 final-art workbench。
- 验证：Asset finalization reviews `55/55 approved final-ready records`；Art readiness `55/55 structural ready, 55/55 final ready`；final review queue `0 manual-review entries, 55 final-ready assets`；final acceptance gates `0 blocked assets, 55 final-ready assets`；asset package audit 通过并记录 `55 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 55 final-ready`；final-art workbench `55 cards, 0 manual-review assets, 55 final-ready assets`。
- 边界：本轮只批准为 Alpha Demo presentation / promo direction source、logo direction source、CG direction source 和 narrative storyboard direction source；不批准最终 logo 字体、平台裁切、公开营销图、商店页素材、最终剧情脚本、对白、本地化、过场成片或发布级 CG。

### 2026-06-24 - P1 final-ready mini pack 25

- 状态：第二十五批 `4` 个 P1 props / equipment / texture 资产从 `structural-ready` 推进为 `final-ready`：`equipment_pickup_atlas_ai01`、`reusable_seal_props_ai01`、`shrine_gate_prop_atlas_ai01`、`material_texture_atlas_ai01`。当前整体为 `55/55 structural-ready`、`48/55 final-ready`、`7/55 blocked`；P0 / P1 blocked assets 已清零，剩余全部为 P2 promo / CG / storyboard。
- 范围：不新增图片生成；复核既有 image_gen equipment / pickup atlas、shrine / gate prop atlas、reusable seal prop sheet 和 material texture atlas，生成 P1 props / texture contact sheet，补齐 finalization review，并刷新 art readiness、final-art queue、acceptance gates、family coverage、asset package 与 final-art workbench。
- 验证：Asset finalization reviews `48/48 approved final-ready records`；Art readiness `55/55 structural ready, 48/55 final ready`；final review queue `7 manual-review entries, 48 final-ready assets`；final acceptance gates `7 blocked assets, 48 final-ready assets`，blocked by priority 为 P2 `7`；asset package audit 通过并记录 `48 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 48 final-ready`；final-art workbench `55 cards, 7 manual-review assets, 48 final-ready assets`。
- 边界：本轮只批准为 source atlas / prop source / material reference source；不批准最终 pickup 逻辑、reward balance、shrine / gate 状态机、collision、room placement、runtime scale、无缝贴图、shader/material binding 或 terrain replacement。

### 2026-06-24 - P1 final-ready mini pack 24

- 状态：第二十四批 `10` 个环境 / TileSet 资产从 `structural-ready` 推进为 `final-ready`：`biome01_air_dash_shrine_room_ai01`、`biome01_shrine_trial_background_ai01`、`biome01_shrine_trial_room_parallax_ai01`、`biome01_shrine_trial_tiles_ai01`、`biome02_miasma_hazard_room_ai01`、`biome02_miasma_marsh_background_ai01`、`biome02_miasma_marsh_tiles_ai01`、`miasma_marsh_tileset_ai01`、`shrine_trial_tileset_ai01`、`stage15_seal_guardian_boss_room_ai01`。当前整体为 `55/55 structural-ready`、`44/55 final-ready`、`11/55 blocked`；P0 blocked assets 已清零，剩余为 P1 `4`、P2 `7`。
- 范围：不新增图片生成；复核既有 image_gen shrine trial / miasma marsh / Seal Guardian room backgrounds、tile visual pass 和两套 editor TileSet source，补齐 finalization review，并刷新 art readiness、final-art queue、acceptance gates、family coverage、asset package 与 final-art workbench。
- 验证：Asset finalization reviews `44/44 approved final-ready records`；Art readiness `55/55 structural ready, 44/55 final ready`；final review queue `11 manual-review entries, 44 final-ready assets`；final acceptance gates `11 blocked assets, 44 final-ready assets`，blocked by priority 为 P1 `4`、P2 `7`；asset package audit 通过并记录 `44 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 44 final-ready`。
- 边界：本轮只批准为当前 Alpha Demo environment visual source / editor TileSet source；不批准最终 autotile、collision polygon、hazard damage Area、navigation、occlusion、完整 parallax split、全场景替换或商业级背景清稿。

### 2026-06-24 - P0 final-ready mini pack 23

- 状态：第二十三批 `1` 个 P0 Spine cutout source 资产从 `structural-ready` 推进为 `final-ready`：`seal_guardian_spine_parts_ai01`。当前整体为 `55/55 structural-ready`、`34/55 final-ready`、`21/55 blocked`；P0 blocked assets 已清零，剩余为 P1 `14`、P2 `7`。
- 范围：不新增图片生成；复核既有 image_gen Seal Guardian 24-part Spine-style cutout atlas、frames / regions metadata、semantics、`.atlas`、`.spine_style.json`、`.cutout_manifest.json` 和总索引，补齐 finalization review，并刷新 art readiness、final-art queue、acceptance gates、family coverage、asset package 与 final-art workbench。
- 验证：Asset finalization reviews `34/34 approved final-ready records`；Art readiness `55/55 structural ready, 34/55 final ready`；final review queue `21 manual-review entries, 34 final-ready assets`；final acceptance gates `21 blocked assets, 34 final-ready assets`，blocked by priority 为 P1 `14`、P2 `7`；asset package audit 通过并记录 `34 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 34 final-ready`；Spine cutout exports `2` assets / `48` parts 审计通过。
- 边界：本轮只批准 `seal_guardian_spine_parts_ai01` 为当前 Alpha Demo 后续 rigging handoff 的 Seal Guardian Spine-style cutout source / export package；当前拆件仍需后续动画阶段复核 pivot、layer order、边缘清理和 rigging polish；不批准正式 Spine rig、Godot Skeleton2D / Bone2D 绑定、运行时动画替换、Boss 状态机时序、hitbox / hurtbox、damage window、公开 sprite source、商店页素材或商业动画清稿。

### 2026-06-24 - P0 final-ready mini pack 22

- 状态：第二十二批 `1` 个 P0 Spine cutout source 资产从 `structural-ready` 推进为 `final-ready`：`luna_spine_parts_ai01`。当前整体为 `55/55 structural-ready`、`33/55 final-ready`、`22/55 blocked`；剩余 P0 只剩 `seal_guardian_spine_parts_ai01`。
- 范围：不新增图片生成；复核既有 image_gen Luna 24-part Spine-style cutout atlas、regions、semantics、`.atlas`、`.spine_style.json`、`.cutout_manifest.json` 和总索引，补齐 finalization review，并刷新 art readiness、final-art queue、acceptance gates、family coverage、asset package 与 final-art workbench。
- 验证：Asset finalization reviews `33/33 approved final-ready records`；Art readiness `55/55 structural ready, 33/55 final ready`；final review queue `22 manual-review entries, 33 final-ready assets`；final acceptance gates `22 blocked assets, 33 final-ready assets`，其中 blocked by priority 为 P0 `1`、P1 `14`、P2 `7`；asset package audit 通过并记录 `33 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 33 final-ready`；Spine cutout exports `2` assets / `48` parts 审计通过；Godot import 通过；final-art workbench `55 cards, 22 manual-review assets, 33 final-ready assets`。
- 边界：本轮只批准 `luna_spine_parts_ai01` 为当前 Alpha Demo 后续 rigging handoff 的 Luna Spine-style cutout source / export package；不批准正式 Spine rig、Godot Skeleton2D / Bone2D 绑定、运行时动画替换、hitbox / hurtbox、攻击时序、公开 sprite source、商店页素材或商业动画清稿。

### 2026-06-24 - P0 final-ready mini pack 21

- 状态：第二十一批 `1` 个 P0 animation sheet 资产从 `structural-ready` 推进为 `final-ready`：`enemies_core_sheet_ai01`。当前整体为 `55/55 structural-ready`、`32/55 final-ready`、`23/55 blocked`。
- 范围：使用内置 `image_gen` 生成并采用 `candidate_06`，替换旧版跨格 VFX、错误最终格和 duplicate fallback 风险的 core enemies sheet；按项目管线抽取 `32/32` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；在基础近战敌人场景新增隐藏 `EnemiesCoreAnimationPreview` 引用并补 Stage15 GUT 保护；补齐 finalization review，并刷新 candidate pool、provenance、source safety、runtime map、P0 replacement plan、runtime source review、art readiness、final-art queue、acceptance gates、candidate gallery、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `32/32 approved final-ready records`；ImageGen candidate pool `133 candidates, 102 unselected candidates`；Asset provenance `55 records, 133 candidate hashes, 55 output hashes`；ImageGen source safety `133 candidates, 0 unsafe`；Runtime source safety `30 runtime assets, 18 review-required, 0 unsafe`；Art readiness `55/55 structural ready, 32/55 final ready`；final review queue `23 manual-review entries, 32 final-ready assets`；final acceptance gates `23 blocked assets, 32 final-ready assets`；asset package audit 通过并记录 `32 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 32 final-ready`；candidate review gallery `102 candidates, 55 assets`；final-art workbench `55 cards, 23 manual-review assets, 32 final-ready assets`；runtime source workbench `18 assets, 72 candidates`；P0 runtime rehearsal `30 nodes`；Godot import 通过；Stage15 GUT `12/12`、`156` asserts 通过；`git diff --check` 通过。
- 边界：本轮只批准 `enemies_core_sheet_ai01` 为当前 Alpha Demo hidden/runtime core enemy roster animation preview；candidate 06 抽取 `32/32` selected frames，修正旧版跨格 VFX、错误最终格和 duplicate fallback 风险；不批准正式敌人 AI 动画替换、攻击判定、hurtbox / hitbox、逐敌人状态机、公开 sprite sheet、商店页素材或商业动画清稿。

### 2026-06-24 - P0 final-ready mini pack 20

- 状态：第二十批 `1` 个 P0 animation sheet 资产从 `structural-ready` 推进为 `final-ready`：`luna_hit_death_sheet_ai01`。当前整体为 `55/55 structural-ready`、`31/55 final-ready`、`24/55 blocked`。
- 范围：使用内置 `image_gen` 生成 `candidate_04`，替换旧版混合比例、残留绿边和动作不连续的 Luna hit/death sheet；按项目管线抽取 `24/24` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；在玩家场景新增隐藏 `LunaHitDeathAnimationPreview` 引用并补 Stage14 GUT 保护；补齐 finalization review，并刷新 candidate pool、provenance、source safety、runtime map、P0 replacement plan、art readiness、final-art queue、acceptance gates、candidate gallery、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `31/31 approved final-ready records`；ImageGen candidate pool `131 candidates, 99 unselected candidates`；Asset provenance `55 records, 131 candidate hashes, 55 output hashes`；ImageGen source safety `131 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 31/55 final ready`；final review queue `24 manual-review entries, 31 final-ready assets`；final acceptance gates `24 blocked assets, 31 final-ready assets`；asset package audit 通过并记录 `31 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 31 final-ready`；candidate review gallery `99 candidates, 55 assets`；final-art workbench `55 cards, 24 manual-review assets, 31 final-ready assets`；Godot import 通过；Stage14 GUT `11/11`、`149` asserts 通过；`git diff --check` 通过。
- 边界：本轮只批准 `luna_hit_death_sheet_ai01` 为当前 Alpha Demo hidden/runtime Luna hit/death animation preview；candidate 04 抽取 `24/24` selected frames 且无 duplicate recovery-frame fallback；不批准正式玩家控制器动画替换、collision height、hitbox / hurtbox、受击无敌时序、失败 / 重开逻辑、公开 sprite sheet、商店页素材或商业动画清稿。

### 2026-06-24 - P0 final-ready mini pack 19

- 状态：第十九批 `1` 个 P0 animation sheet 资产从 `structural-ready` 推进为 `final-ready`：`seal_guardian_boss_sheet_ai01`。当前整体为 `55/55 structural-ready`、`30/55 final-ready`、`25/55 blocked`。
- 范围：使用内置 `image_gen` 生成 `candidate_04`，替换旧版混合四足兽 / 人形守卫的 Seal Guardian Boss sheet；按项目管线抽取 `20/20` selected frames，重建 `256x192` SpriteFrames atlas、frames、semantics 和 animation rules；补齐 finalization review，并刷新 candidate pool、provenance、source safety、art readiness、final-art queue、acceptance gates、candidate gallery、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `30/30 approved final-ready records`；ImageGen candidate pool `130 candidates, 97 unselected candidates`；Asset provenance `55 records, 130 candidate hashes, 55 output hashes`；ImageGen source safety `130 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 30/55 final ready`；final review queue `25 manual-review entries, 30 final-ready assets`；final acceptance gates `25 blocked assets, 30 final-ready assets`；asset package audit 通过并记录 `30 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 30 final-ready`；candidate review gallery `97 candidates, 55 assets`；final-art workbench `55 cards, 25 manual-review assets, 30 final-ready assets`；Godot import 通过；Stage15 GUT `12/12`、`148` asserts 通过；`git diff --check` 通过。
- 边界：本轮只批准 `seal_guardian_boss_sheet_ai01` 为当前 Alpha Demo hidden/runtime Seal Guardian boss attack animation preview；candidate 04 抽取 `20/20` selected frames，修正旧版四足兽 / 人形守卫混合漂移；不批准正式 Boss 状态机动画替换、攻击判定、damage window、受击 / 击败动作、公开 sprite sheet、商店页素材或商业动画清稿。

### 2026-06-24 - P0 final-ready mini pack 18

- 状态：第十八批 `1` 个 P0 animation sheet 资产从 `structural-ready` 推进为 `final-ready`：`luna_jump_fall_sheet_ai01`。当前整体为 `55/55 structural-ready`、`29/55 final-ready`、`26/55 blocked`。
- 范围：使用内置 `image_gen` 生成 `candidate_05` 与 `candidate_06`，最终采用 `candidate_06` 替换旧版需要 duplicate 补位的 jump / fall sheet；按项目管线抽取 `24/24` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；补齐 finalization review，并刷新 candidate pool、provenance、source safety、art readiness、final-art queue、acceptance gates、candidate gallery、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `29/29 approved final-ready records`；ImageGen candidate pool `129 candidates, 95 unselected candidates`；Asset provenance `55 records, 129 candidate hashes, 55 output hashes`；ImageGen source safety `129 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 29/55 final ready`；final review queue `26 manual-review entries, 29 final-ready assets`；final acceptance gates `26 blocked assets, 29 final-ready assets`；asset package audit 通过并记录 `29 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 29 final-ready`；candidate review gallery `95 candidates, 55 assets`；final-art workbench `55 cards, 26 manual-review assets, 29 final-ready assets`；Godot import 通过。
- 边界：本轮只批准 `luna_jump_fall_sheet_ai01` 为当前 Alpha Demo hidden/runtime Luna jump/fall animation preview；candidate 06 抽取 `24/24` selected frames 且无 duplicate recovery-frame fallback；不批准正式玩家控制器动画替换、collision height、hitbox / hurtbox、跳跃物理时序、公开 sprite sheet、商店页素材或商业动画清稿。

### 2026-06-24 - P0 final-ready mini pack 17

- 状态：第十七批 `1` 个 P0 animation sheet 资产从 `structural-ready` 推进为 `final-ready`：`luna_attack_01_sheet_ai01`。当前整体为 `55/55 structural-ready`、`28/55 final-ready`、`27/55 blocked`。
- 范围：使用内置 `image_gen` 生成 `candidate_06`，替换旧版混合概念 attack sheet；按项目管线抽取 `16/16` selected frames，重建 `192x160` SpriteFrames atlas、frames、semantics 和 animation rules；补齐 finalization review，并刷新 candidate pool、provenance、source safety、art readiness、final-art queue、acceptance gates、candidate gallery、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `28/28 approved final-ready records`；ImageGen candidate pool `127 candidates, 94 unselected candidates`；Asset provenance `55 records, 127 candidate hashes, 55 output hashes`；ImageGen source safety `127 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 28/55 final ready`；final review queue `27 manual-review entries, 28 final-ready assets`；final acceptance gates `27 blocked assets, 28 final-ready assets`；asset package audit 通过并记录 `28 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 28 final-ready`；candidate review gallery `94 candidates, 55 assets`；final-art workbench `55 cards, 27 manual-review assets, 28 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
- 边界：本轮只批准 `luna_attack_01_sheet_ai01` 为当前 Alpha Demo hidden/runtime Luna attack 01 animation preview；不批准正式玩家控制器动画替换、hitbox / hurtbox、伤害时序、取消窗口、公开 sprite sheet、商店页素材或商业动画清稿。

### 2026-06-24 - P0 final-ready mini pack 16

- 状态：第十六批 `1` 个 P0 animation sheet 资产从 `structural-ready` 推进为 `final-ready`：`luna_air_dash_sheet_ai01`。当前整体为 `55/55 structural-ready`、`27/55 final-ready`、`28/55 blocked`。
- 范围：使用内置 `image_gen` 生成 `candidate_06`，替换旧版混合姿态 Air Dash sheet；按项目管线抽取 `16/16` selected frames，重建 `192x160` SpriteFrames atlas、frames、semantics 和 animation rules；补齐 finalization review，并刷新 candidate pool、provenance、source safety、art readiness、final-art queue、acceptance gates、candidate gallery、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `27/27 approved final-ready records`；ImageGen candidate pool `126 candidates, 91 unselected candidates`；Asset provenance `55 records, 126 candidate hashes, 55 output hashes`；ImageGen source safety `126 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 27/55 final ready`；final review queue `28 manual-review entries, 27 final-ready assets`；final acceptance gates `28 blocked assets, 27 final-ready assets`；asset package audit 通过并记录 `27 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 27 final-ready`；candidate review gallery `91 candidates, 55 assets`；final-art workbench `55 cards, 28 manual-review assets, 27 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
- 边界：本轮只批准 `luna_air_dash_sheet_ai01` 为当前 Alpha Demo hidden/runtime Luna Air Dash animation preview；candidate 06 抽帧结果包含两个显式标记的 duplicate recovery frames；不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗或位移时序、公开 sprite sheet、商店页素材或商业动画清稿。

### 2026-06-24 - P0 final-ready mini pack 15

- 状态：第十五批 `1` 个 P0 animation sheet 资产从 `structural-ready` 推进为 `final-ready`：`luna_run_sheet_ai01`。当前整体为 `55/55 structural-ready`、`26/55 final-ready`、`29/55 blocked`。
- 范围：使用内置 `image_gen` 生成 `candidate_06`，替换旧版混合概念 run sheet；按项目管线抽取 `24/24` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；补齐 finalization review，并刷新 candidate pool、provenance、source safety、art readiness、final-art queue、acceptance gates、candidate gallery、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `26/26 approved final-ready records`；ImageGen candidate pool `125 candidates, 89 unselected candidates`；Asset provenance `55 records, 125 candidate hashes, 55 output hashes`；ImageGen source safety `125 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 26/55 final ready`；final review queue `29 manual-review entries, 26 final-ready assets`；final acceptance gates `29 blocked assets, 26 final-ready assets`；asset package audit 通过并记录 `26 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 26 final-ready`；candidate review gallery `89 candidates, 55 assets`；final-art workbench `55 cards, 29 manual-review assets, 26 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
- 边界：本轮只批准 `luna_run_sheet_ai01` 为当前 Alpha Demo hidden/runtime Luna run animation preview；不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗时序、公开 sprite sheet、商店页素材或商业动画清稿。

### 2026-06-24 - P0 final-ready mini pack 14

- 状态：第十四批 `1` 个 P0 animation sheet 资产从 `structural-ready` 推进为 `final-ready`：`luna_idle_sheet_ai01`。当前整体为 `55/55 structural-ready`、`25/55 final-ready`、`30/55 blocked`。
- 范围：使用内置 `image_gen` 生成 `candidate_05`，替换旧版混合姿态 idle sheet；按项目管线抽取 `16/16` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；补齐 finalization review，并刷新 candidate pool、provenance、source safety、art readiness、final-art queue、acceptance gates、candidate gallery、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `25/25 approved final-ready records`；ImageGen candidate pool `124 candidates, 87 unselected candidates`；Asset provenance `55 records, 124 candidate hashes, 55 output hashes`；ImageGen source safety `124 candidates, 0 unsafe`；Runtime source safety `28 runtime assets, 15 review-required, 0 unsafe`；Art readiness `55/55 structural ready, 25/55 final ready`；final review queue `30 manual-review entries, 25 final-ready assets`；final acceptance gates `30 blocked assets, 25 final-ready assets`；asset package audit 通过并记录 `25 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 25 final-ready`；candidate review gallery `87 candidates, 55 assets`；final-art workbench `55 cards, 30 manual-review assets, 25 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
- 边界：本轮只批准 `luna_idle_sheet_ai01` 为当前 Alpha Demo hidden/runtime Luna idle animation preview；不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗时序、公开 sprite sheet、商店页素材或商业动画清稿。

### 2026-06-24 - P0 final-ready mini pack 13

- 状态：第十三批 `1` 个 P0 VFX atlas 资产从 `structural-ready` 推进为 `final-ready`：`vfx_combat_atlas_ai01`。当前整体为 `55/55 structural-ready`、`24/55 final-ready`、`31/55 blocked`。
- 范围：复核既有 combat VFX atlas 为无文字、透明、32 帧战斗反馈图集；在玩家与 Seal Guardian 场景中增加隐藏 `CombatVfxPreview` runtime 预览引用；补齐 semantics、VFX rules 与 finalization review，明确 collision / damage 继续 disabled，并刷新 art readiness、final-art queue、acceptance gates、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `24/24 approved final-ready records`；ImageGen candidate pool `123 candidates, 85 unselected candidates`；Asset provenance `55 records, 123 candidate hashes, 55 output hashes`；ImageGen source safety `123 candidates, 0 unsafe`；Runtime source safety `28 runtime assets, 15 review-required, 0 unsafe`；Art readiness `55/55 structural ready, 24/55 final ready`；final review queue `31 manual-review entries, 24 final-ready assets`；final acceptance gates `31 blocked assets, 24 final-ready assets`；asset package audit 通过并记录 `24 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 24 final-ready`；final-art workbench `55 cards, 31 manual-review assets, 24 final-ready assets`；Godot import 通过；Stage14 GUT `11/11`、Stage15 GUT `12/12` 通过。
- 边界：本轮只批准 `vfx_combat_atlas_ai01` 为当前 Alpha Demo hidden/runtime combat VFX preview；不批准最终战斗时序、玩法碰撞、伤害来源、受击窗口、通用公开 VFX 图集、商店页素材或宣传素材。

### 2026-06-24 - P0 final-ready mini pack 12

- 状态：第十二批 `1` 个 P0 VFX atlas 资产从 `structural-ready` 推进为 `final-ready`：`vfx_seal_magic_atlas_ai01`。
- 范围：使用内置 `image_gen` 重生 `candidate_05`，替换早期带英文标签的 seal magic atlas 候选；重建 `32/32` selected frames、atlas、SpriteFrames、semantics 和 VFX rules；补齐 finalization review，并刷新 candidate pool、provenance、source safety、art readiness、final-art queue、acceptance gates、candidate gallery、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `23/23 approved final-ready records`；ImageGen candidate pool `123 candidates, 85 unselected candidates`；Asset provenance `55 records, 123 candidate hashes, 55 output hashes`；ImageGen source safety `123 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 23/55 final ready`；final review queue `32 manual-review entries, 23 final-ready assets`；final acceptance gates `32 blocked assets, 23 final-ready assets`；asset package audit 通过并记录 `23 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 23 final-ready`；candidate review gallery `85 candidates, 55 assets`；final-art workbench `55 cards, 32 manual-review assets, 23 final-ready assets`；Godot import 通过；Stage14 GUT `11/11`、Stage15 GUT `12/12` 通过。
- 边界：本轮只批准 `vfx_seal_magic_atlas_ai01` 为当前 Alpha Demo hidden/runtime seal magic VFX preview；不批准最终战斗时序、玩法碰撞、伤害来源、通用公开 VFX 图集、商店页素材或宣传素材。

### 2026-06-24 - P0 final-ready mini pack 11

- 状态：第十一批 `1` 个 P0 HUD atlas 资产从 `structural-ready` 推进为 `final-ready`：`hud_core_ui_atlas_ai01`。
- 范围：确认 `hud_core_ui_atlas_ai01` 作为当前 `TutorialHUD` source atlas preview 和编辑器 `AtlasTexture` 资源集可用；将 `semantics.json` 从旧版 gameplay HUD 语义改为可见 HUD 装饰、符旗、面板、分隔线和莲花徽章描述；补齐 finalization review，并刷新 art readiness、final-art queue、acceptance gates 与 family coverage。
- 验证：Asset finalization reviews `22/22 approved final-ready records`；Art readiness `55/55 structural ready, 22/55 final ready`；final review queue `33 manual-review entries, 22 final-ready assets`；final acceptance gates `33 blocked assets, 22 final-ready assets`；asset package audit 通过并记录 `22 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 22 final-ready`；final-art workbench `55 cards, 33 manual-review assets, 22 final-ready assets`；Godot import 通过；Stage12 GUT `9/9` 通过。
- 边界：本轮只批准 `hud_core_ui_atlas_ai01` 为当前 `TutorialHUD` source atlas preview / editor AtlasTexture resource set；不批准直接替换 gameplay health、Boss health、Recovery Charge、Air Dash state、最终 Theme mapping、完整 HUD 设计系统、商店页 UI 或宣传素材。

### 2026-06-24 - P0 final-ready mini pack 10

- 状态：第十批 `1` 个 P0 icon atlas 资产从 `structural-ready` 推进为 `final-ready`：`icon_sheet_core_ai01`。
- 范围：确认 `icon_sheet_core_ai01` 作为 Alpha Demo 内部核心图标源图集和编辑器 `AtlasTexture` 预览可用；修正 `semantics.json` 为可见图形语义描述，避免沿用旧版 gameplay / HUD / menu 语义直接绑定；补齐 finalization review，并刷新 art readiness、final-art queue、acceptance gates、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `21/21 approved final-ready records`；Art readiness `55/55 structural ready, 21/55 final ready`；final review queue `34 manual-review entries, 21 final-ready assets`；final acceptance gates `34 blocked assets, 21 final-ready assets`；asset package audit 通过并记录 `21 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 21 final-ready`；final-art workbench `55 cards, 34 manual-review assets, 21 final-ready assets`；Godot import 通过；Stage12 GUT `9/9` 通过；`git diff --check` 通过。
- 边界：本轮只批准 `icon_sheet_core_ai01` 为当前 Alpha Demo internal core icon source atlas；不批准作为直接 gameplay HUD/menu semantic binding、完整最终图标体系、商店页 UI、宣传素材，也不替代专用 `stage14_air_dash_icon_ai01`、`stage15_recovery_charge_icon_ai01` 或 `stage16_demo_menu_icons_ai01`。

### 2026-06-23 - P0 final-ready mini pack 09

- 状态：第九批 `1` 个 P0 DemoShell menu icon 资产从 `structural-ready` 推进为 `final-ready`：`stage16_demo_menu_icons_ai01`。
- 范围：使用内置 `image_gen` 生成统一南北朝东方奇幻 / 佛门符印风格的 `2x3` 六宫格菜单图标候选，显式导入为 `candidate_04`，转换为 RGBA alpha PNG，补齐 source、regions、semantics 与 finalization review，并刷新 provenance、source safety、candidate gallery、art readiness、final-art queue、acceptance gates、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `20/20 approved final-ready records`；ImageGen candidate pool `122 candidates, 83 unselected candidates`；ImageGen source safety `122 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 20/55 final ready`；final review queue `35 manual-review entries, 20 final-ready assets`；final acceptance gates `35 blocked assets, 20 final-ready assets`；asset package audit 通过并记录 `20 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 20 final-ready`；candidate review gallery `83 candidates, 55 assets`；final art review workbench `55 cards, 35 manual-review assets, 20 final-ready assets`；Godot import 通过；Stage16 GUT `13/13` 通过。
- 边界：本轮只批准 `stage16_demo_menu_icons_ai01` 作为当前 `DemoShell` 的六宫格 runtime menu icon strip；不批准完整最终图标体系、未来按钮状态重做、HUD atlas 无关区域、商店页 UI、宣传素材或剩余 `35` 个 blocked 资产。

### 2026-06-23 - P0 final-ready mini pack 08

- 状态：第八批 `1` 个 P0 runtime Theme / StyleBox 资产从 `structural-ready` 推进为 `final-ready`：`menu_ninepatch_ui_ai01`。
- 范围：确认 `menu_ninepatch_ui_ai01` 的 `8` 个 StyleBoxTexture、`9` 个 Theme style mappings、DemoShell / TutorialHUD runtime UI skin binding 和 RGBA 透明 PNG 状态；补齐 finalization review；刷新 art readiness、final-art queue、acceptance gates、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `19/19 approved final-ready records`；Art readiness `55/55 structural ready, 19/55 final ready`；final review queue `36 manual-review entries, 19 final-ready assets`；final acceptance gates `36 blocked assets, 19 final-ready assets`；asset package audit 通过并记录 `19 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 19 final-ready`；Godot import 通过；Editor StyleBoxTexture resources `8`、Editor UI skin `9 style mappings, 4 standalone panels`、runtime UI skin binding `2 scenes, 5 panels, 4 textures`；Stage12 GUT `9/9`、Stage16 GUT `13/13` 通过。
- 边界：本轮只批准 `menu_ninepatch_ui_ai01` 作为当前 `DemoShell` 与 `TutorialHUD` 的 runtime Theme / StyleBoxTexture skin；不批准完整最终 UI 设计系统、未来按钮状态重做、商店页 UI、无关 atlas 区域、商业宣传素材或剩余 `36` 个 blocked 资产。

### 2026-06-23 - P0 final-ready mini pack 07

- 状态：第七批 `2` 个 P0 DemoShell runtime panel 资产从 `structural-ready` 推进为 `final-ready`：`stage16_pause_panel_ui_ai01`、`stage16_completion_panel_ui_ai01`。
- 范围：将两个 Stage16 UI panel 的 chroma-key 绿底转换为 RGBA alpha PNG，确认四角透明且无不透明绿残留；补齐 finalization review；刷新 provenance、art readiness、final-art queue、acceptance gates、asset package、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `18/18 approved final-ready records`；Art readiness `55/55 structural ready, 18/55 final ready`；final review queue `37 manual-review entries, 18 final-ready assets`；final acceptance gates `37 blocked assets, 18 final-ready assets`；asset package audit 通过并记录 `18 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 18 final-ready`；Godot import 通过；runtime UI skin binding `2 scenes, 5 panels, 4 textures`；Stage16 GUT `13/13`、Stage12 GUT `9/9` 通过。
- 边界：本轮只批准两个 Stage16 panel 作为当前 `DemoShell` pause / completion runtime panel preview；不批准通用 UI atlas、最终按钮状态、菜单图标语义、商店页完成图、商业宣传素材或剩余 `37` 个 blocked 资产。

### 2026-06-23 - P0 final-ready mini pack 06

- 状态：第六批 `2` 个 P0 TutorialHUD runtime frame 资产从 `structural-ready` 推进为 `final-ready`：`stage15_boss_hud_frame_ai01`、`stage14_ability_status_hud_ai01`。
- 范围：将两个 HUD frame 的 chroma-key 绿底转换为 RGBA alpha PNG，确认四角透明且无不透明绿残留；补齐 finalization review；刷新 art readiness、final-art queue、acceptance gates、family coverage 与 final-art workbench。
- 验证：Asset finalization reviews `16/16 approved final-ready records`；Art readiness `55/55 structural ready, 16/55 final ready`；final review queue `39 manual-review entries, 16 final-ready assets`；final acceptance gates `39 blocked assets, 16 final-ready assets`；family coverage `10/10 families, 7/7 Godot formats, 16 final-ready`。
- 边界：本轮只批准两个 HUD frame 作为当前 `TutorialHUD` runtime frame preview；不批准切成通用 UI atlas、按钮状态、独立图标集、Boss 血量逻辑、商业宣传素材或剩余 `39` 个 blocked 资产。

### 2026-06-23 - P0 final-ready mini pack 05

- 状态：第五批 `1` 个 P0 Stage16 VFX 资产从 `structural-ready` 推进为 `final-ready`：`stage16_corruption_purge_ai01`。
- 范围：补齐 `stage16_corruption_purge_ai01` 的 finalization review；确认其 `3x2` / `6` frame VFX rules、显式 `region_rect` 运行时引用、`.source.json` 派生记录和 Stage16 GUT 引用保护；刷新 art readiness、final-art queue、acceptance gates、family coverage 与综合资产包审计。
- 验证：Asset finalization reviews `14/14 approved final-ready records`；VFX rules `6 assets, 78 frame rules`；Art readiness `55/55 structural ready, 14/55 final ready`；final review queue `41 manual-review entries, 14 final-ready assets`；final acceptance gates `41 blocked assets, 14 final-ready assets`；family coverage `10/10 families, 7/7 Godot formats, 14 final-ready`；asset package audit 通过并记录 `14 asset finalization approvals` 与 `78 VFX rules`。
- 边界：本轮只批准 `stage16_corruption_purge_ai01` 作为当前 Stage16 purge 房间的 region-bound visual VFX；不批准整张 sheet 直接上屏、伤害判定、通用动画序列、VFX atlas 商业发布或剩余 `41` 个 blocked 资产。

### 2026-06-21 - P0 final-ready mini pack 04

- 状态：第四批 `1` 个 P0 Stage16 VFX 资产从 `structural-ready` 推进为 `final-ready`：`stage16_talisman_relay_ai01`。
- 范围：`stage16_talisman_relay_ai01` 的 VFX rules 从整图 1 frame 修正为 `3x2` / `6` frame region grid；`Stage16TalismanRelayRoom` 与 `Stage16CorruptionPurgeRoom` 的 talisman relay Sprite2D 改为显式 `region_rect`，避免整张候选 sheet 上屏；扩展 finalization review，并刷新 art readiness、final-art queue、acceptance gates、family coverage、final-art workbench 与综合资产包审计。
- 验证：Asset finalization reviews `13/13 approved final-ready records`；VFX rules `6 assets, 73 frame rules`；Art readiness `55/55 structural ready, 13/55 final ready`；final review queue `42 manual-review entries, 13 final-ready assets`；final acceptance gates `42 blocked assets, 13 final-ready assets`；family coverage `10/10 families, 7/7 Godot formats, 13 final-ready`；asset package audit 通过并记录 `13 asset finalization approvals`；Godot import 通过；Stage16 GUT `13/13`、`125` asserts 通过。
- 边界：本轮只批准 `stage16_talisman_relay_ai01` 作为当前 Stage16 relay / purge 房间的 region-bound visual VFX；不批准整张 sheet 直接上屏、伤害判定、通用动画序列、VFX atlas 商业发布或 `stage16_corruption_purge_ai01`。

### 2026-06-21 - Final-ready mini pack 03

- 状态：第三批 `4` 个 runtime prop / internal style 资产从 `structural-ready` 推进为 `final-ready`：`stage14_air_dash_shrine_ai01`、`stage14_air_dash_gate_ai01`、`stage16_seal_release_threshold_ai01`、`style_board_global_ai01`。
- 范围：扩展 `docs/assets/asset-finalization-review-records.json` 与 `.md`；刷新 art readiness、final-art queue、acceptance gates、family coverage 和 final-art workbench；同步 `docs/assets/asset-manifest.md`、`p0-finalization-list.md`、`asset-completion-matrix.md`、`image-gen-production-backlog.md`、`godot-atlas-build-pipeline.md` 与 Pass 02 goal。
- 验证：Asset finalization reviews `12/12 approved final-ready records`；Art readiness `55/55 structural ready, 12/55 final ready`；final review queue `43 manual-review entries, 12 final-ready assets`；final acceptance gates `43 blocked assets, 12 final-ready assets`；family coverage `10/10 families, 7/7 Godot formats, 12 final-ready`；asset package audit 通过并记录 `12 asset finalization approvals`；Godot import 通过；Stage14 GUT `11/11`、Stage16 GUT `13/13` 通过。
- 边界：本轮批准的是已无 family-specific blocker 的 prop / internal style assets；`style_board_global_ai01` 只批准为内部风格锁定参考，不代表公开宣传图；动画、UI atlas、VFX atlas、TileSet、宣传 CG 和叙事图仍未 final-ready。

### 2026-06-21 - P0 final-ready mini pack 02

- 状态：第二批 `4` 个 P0 / Stage16 runtime 资产从 `structural-ready` 推进为 `final-ready`：`stage15_seal_guardian_ai01`、`stage16_luna_player_readability_ai01`、`stage16_alpha_demo_completion_ai01`、`stage16_title_background_ai01`。
- 范围：扩展 `docs/assets/asset-finalization-review-records.json` 与 `.md`；刷新 art readiness、final-art queue、acceptance gates、family coverage 和 final-art workbench；同步 `docs/assets/asset-manifest.md`、`p0-finalization-list.md`、`asset-completion-matrix.md`、`image-gen-production-backlog.md`、`godot-atlas-build-pipeline.md` 与 Pass 02 goal。
- 验证：Asset finalization reviews `8/8 approved final-ready records`；Art readiness `55/55 structural ready, 8/55 final ready`；final review queue `47 manual-review entries, 8 final-ready assets`；final acceptance gates `47 blocked assets, 8 final-ready assets`；family coverage `10/10 families, 7/7 Godot formats, 8 final-ready`；asset package audit 通过并记录 `8 asset finalization approvals`；Godot import 通过；Stage14 GUT `11/11`、Stage15 GUT `12/12`、Stage16 GUT `13/13` 均通过；`git diff --check` 通过。
- 边界：本轮批准的是已 runtime referenced、且无 family-specific blocker 的方向稿 / completion / title background；不代表 Luna / Boss 动画 sheet、UI atlas、NinePatch、TileSet、VFX atlas 或宣传发行素材已经完成 final-ready。

### 2026-06-21 - P0 final-ready mini pack 01

- 状态：首批 `4` 个 P0 runtime 单体资产从 `structural-ready` 推进为 `final-ready`：`stage14_air_dash_icon_ai01`、`stage15_recovery_charge_icon_ai01`、`stage14_air_dash_trail_ai01`、`stage15_boss_attack_warning_ai01`。
- 范围：新增 `docs/assets/asset-finalization-review-records.json` 与 `.md`；更新 `scripts/assets/audit_art_readiness.py` 让 final-ready 由人工 finalization record 驱动；更新 final-art queue / acceptance gates / family coverage / asset package 审计口径；同步 `docs/assets/asset-manifest.md`、`asset-completion-matrix.md` 与 `p0-finalization-list.md`。
- 验证：Art readiness `55/55 structural ready, 4/55 final ready`；final review queue `51 manual-review entries, 4 final-ready assets`；final acceptance gates `51 blocked assets, 4 final-ready assets`；asset package audit 通过并记录 `4 asset finalization approvals`；Godot import 通过；Stage14 GUT `11/11`、Stage15 GUT `12/12`、Stage16 GUT `13/13` 均通过。
- 边界：本轮只批准 4 个 Codex built-in image_gen 生成的 Alpha Demo P0 runtime 资产；不覆盖外部工具、宣传发行素材、未列出的候选图或剩余 `51` 个仍有 blocker 的资产。

### 2026-06-21 - Asset finalization pass 01 decisions

- 状态：完成 `15/15` 个 runtime source review-required 资产的第一轮人工视觉复核结论；全部判定为 `confirmed_for_cleanup`，进入清稿 / 重建候选，不需要先整批重生图。
- 范围：新增 `docs/implementation-plans/2026-06-21-asset-finalization-pass-01.md`、`docs/assets/runtime-source-review-decisions.json`、`docs/assets/runtime-source-review-decisions.md`、`docs/assets/p0-finalization-list.md` 和 `scripts/assets/audit_runtime_source_review_decisions.py`；扩展 `scripts/assets/audit_asset_package.py` 纳入 runtime source cleanup decisions；本地审图联系表保留在 `tests/artifacts/local/asset-finalization-pass-01/`。
- 验证：`python scripts\assets\audit_runtime_source_review_decisions.py --strict` 输出 `15 decisions, 15 confirmed for cleanup, 0 final-ready`；`python scripts\assets\audit_asset_package.py --write-report --strict` 通过并记录 `15 runtime source cleanup decisions`。
- 边界：本轮不关闭 `license_terms_manual_review`，不替换 `assets/art/` 或运行时引用，不把任何资产标记为 `final_ready`；下一目标为 `Nano Hunter P0 Art Cleanup and Runtime Rebuild Pass 02`。

### 2026-06-21 - Runtime source regeneration candidate pass

- 状态：按统一 Nano Hunter 美术风格重生成 15 个 runtime review-required 资产的新 raw candidates；其中 7 个必须重生项已通过落盘门禁，8 个混合来源项也已追加统一风格候选。
- 范围：新增 `docs/implementation-plans/2026-06-21-runtime-source-regeneration-candidate-pass.md`；追加 15 张 PNG 到 `assets/source/ai_generated/.../candidates/`；扩展 `scripts/assets/audit_runtime_source_regeneration_landing.py` 支持 `--accept-latest-existing`；刷新 candidate pool、provenance、source safety、candidate review gallery、project isolation、landing report 与综合资产包报告。
- 验证：Candidate pool `120 candidates, 547 selected sources, 82 unselected candidates, 55 review-required assets`；source safety `120 candidates, 35 project-session confirmed, 30 ledger review-required, 55 provenance review-required, 0 unsafe`；runtime source regeneration landing `7 assets, 0 pending, 7 landed, 0 invalid`；Godot import 通过；candidate review gallery `82 candidates, 55 assets`；project isolation `1936 files, 0 forbidden markers, 0 outside paths, 0 project_key errors`；asset package audit 通过并记录 `7/7 runtime source regeneration landed`；`git diff --check` 通过。
- 边界：本轮只追加候选，不自动替换 selected sources、`assets/art/` 输出或运行时场景引用；`15` 个 runtime review-required 资产仍需要人工审图、清稿、切片 / 导出和接入复核，整体 `final_ready` 仍为 `0/55`。

### 2026-06-21 - Project asset isolation audit

- 状态：针对“多个项目一起开发是否搞错资产”的风险，新增项目资产隔离审计；当前已扫描资产相关文件，未发现已知外项目标识、外项目绝对路径或非 Nano Hunter `project_key`。
- 范围：新增 `scripts/assets/audit_project_asset_isolation.py`、`docs/assets/project-asset-isolation-report.json`、`docs/assets/project-asset-isolation-report.md` 和 `docs/implementation-plans/2026-06-21-project-asset-isolation-audit.md`；扩展 `scripts/assets/audit_asset_package.py` 纳入该门槛；更新资产矩阵和 image gen backlog。
- 验证：`python scripts\assets\audit_project_asset_isolation.py --write-report --strict` 输出 `1918 files, 0 forbidden markers, 0 outside paths, 0 project_key errors`；综合资产包审计将校验这些计数必须为 `0`。
- 边界：该审计只证明当前资产记录层未发现已知外项目污染证据，不把 `70` 个 source review-required raw candidates 或 `15` 个 runtime review-required assets 升级为 confirmed；`final_ready` 仍为 `0/55`。

### 2026-06-21 - Standalone source sidecar project-key hardening

- 状态：响应多项目并行资产混用风险，补强 standalone `.source.json` 项目键门禁；现有 9 个 standalone 派生记录均包含 `project_key = nano-hunter` 与 `project_name = Nano Hunter`。
- 范围：更新 `scripts/assets/export_standalone_candidates.py`、`scripts/assets/audit_imagegen_candidate_pool.py` 和现有 standalone `.source.json`；刷新 candidate pool、provenance、source safety、runtime source safety、candidate review gallery 与综合资产包报告。
- 验证：Candidate pool `105 candidates, 547 selected sources, 67 unselected candidates, 47 review-required assets`；source safety `105 candidates, 35 project-session confirmed, 30 ledger review-required, 40 provenance review-required, 0 unsafe`；candidate review gallery `67 candidates, 47 assets`；asset package audit 通过并记录 `67 candidate review cards, 0 unsafe source candidates`；runtime source safety 最新为 `28 runtime assets, 15 review-required, 0 unsafe`；`git diff --check` 通过。
- 边界：该修复只证明 standalone 派生记录具备 Nano Hunter 项目归属门禁，不代表 15 个 runtime review-required 资产已经人工复核、授权确认、清稿或达到 `final_ready`。

### 2026-06-21 - HUD core UI atlas source confirmation

- 状态：从 `project_session_confirmed` 的 `hud_core_ui_atlas_ai01_candidate_01` 重建 `selected_items`、HUD core atlas 与 editor AtlasTextures，补齐运行时 HUD 图集的 selected source 派生证据。
- 范围：新增 `docs/implementation-plans/2026-06-21-hud-core-ui-atlas-source-confirmation.md`；更新 `assets/source/ai_generated/batch_08/hud_core_ui_atlas_ai01/selected_items/`、`assets/art/ui/atlases/hud_core_ui_atlas_ai01.png`、`.regions.json`、editor AtlasTextures、provenance、runtime source safety 与综合资产包报告。
- 验证：`prepare_selected_sources.py` 从 `candidate_01` 拆出 `16/16`；`audit_asset_target_coverage.py --strict` 通过；`audit_editor_atlas_textures.py --strict` 通过 `302` 个 AtlasTexture；runtime source safety 从 `16` 个降到 `15` 个 review-required，`0` unsafe；Godot import 通过；asset package audit 通过。
- 边界：这只把 HUD core 从“派生未记录”推进为“来源确认的 runtime preview”；不代表 UI 小尺寸读值、Theme 最终套用、NinePatch、授权或 `final_ready`。

### 2026-06-21 - Runtime source review queue

- 状态：新增剩余 runtime source review-required 资产的集中复核队列，避免为了降低来源风险数字而自动回退到 duplicate 补位或质量更弱的候选。
- 范围：新增 `scripts/assets/build_runtime_source_review_queue.py`、`docs/assets/runtime-source-review-queue.json`、`docs/assets/runtime-source-review-queue.md` 和 `docs/implementation-plans/2026-06-21-runtime-source-review-queue.md`；扩展综合资产包审计纳入 runtime source safety 与 runtime source review queue。
- 验证：Runtime source review queue `15 review-required assets, 0 unsafe`；策略分组为 `8 manual_compare_selected_mix`、`7 manual_source_review_or_regenerate`；asset package audit 通过并记录 `15 runtime source review-required assets, 15 runtime source review queue entries`。
- 边界：该队列是下一步审图 / 重生图 / 来源确认入口，不把任何 review-required 候选升级为 confirmed，也不改变运行时场景引用。

### 2026-06-21 - Runtime source regeneration packet

- 状态：为 `manual_source_review_or_regenerate` 的 7 个运行时 UI / VFX 资产生成下一轮 image gen 重生图执行包。
- 范围：新增 `scripts/assets/build_runtime_source_regeneration_packet.py`、`docs/assets/runtime-source-regeneration-packet.json`、`docs/assets/runtime-source-regeneration-packet.md` 和 `docs/implementation-plans/2026-06-21-runtime-source-regeneration-packet.md`；扩展综合资产包审计校验 regeneration packet。
- 验证：Runtime source regeneration packet `7 assets`；asset package audit 通过并记录 `7 runtime source regeneration prompts`；每个条目包含下一候选路径、当前运行时场景、当前输出路径和完整 image gen prompt。
- 边界：该条记录描述的是前置执行包生成阶段；后续已在同日追加实际 image_gen 候选落盘 pass，但执行包本身仍不代表自动接入。

### 2026-06-21 - Runtime source review workbench

- 状态：新增 Godot 编辑器可打开的运行时来源复核工作台，把剩余 `15` 个 runtime review-required 资产的当前输出和候选图集中展示。
- 范围：新增 `scripts/dev/build_runtime_source_review_workbench.gd`、`scripts/dev/audit_runtime_source_review_workbench.gd`、`scenes/dev/runtime_source_review_workbench.tscn`、`docs/assets/runtime-source-review-workbench-manifest.json` 和 `docs/implementation-plans/2026-06-21-runtime-source-review-workbench.md`；扩展综合资产包审计校验 workbench。
- 验证：Godot headless 审计通过：`15 assets, 15 current outputs, 34 candidates`；manifest 记录 `23` 个 selected candidate previews；asset package audit 通过并记录 `34 runtime source workbench candidates`。
- 边界：该场景只是人工审图入口，不确认来源、不替换 selected source、不改变运行时引用，也不代表 final-ready。

### 2026-06-21 - ImageGen supplemental icon candidates

- 状态：继续按 Nano Hunter 专属候选池补齐基础图标方向，新增 `stage16_demo_menu_icons_ai01_candidate_02` 与 `stage14_air_dash_icon_ai01_candidate_02` 两个评审候选，并为已接入 runtime 的 8 个 standalone UI / VFX PNG 补齐 `.source.json` 派生记录。
- 范围：新增 `docs/implementation-plans/2026-06-21-imagegen-supplemental-icon-candidates.md`；刷新 candidate pool、provenance、source safety、candidate review gallery、runtime source safety 与综合资产包报告。
- 验证：Candidate pool `105 candidates, 547 selected sources, 67 unselected candidates, 47 review-required assets`；source safety `105 candidates, 35 project-session confirmed, 30 ledger review-required, 40 provenance review-required, 0 unsafe`；candidate review gallery `67 candidates, 47 assets`；asset package audit 通过；runtime source safety 最新为 `28 runtime assets, 15 review-required, 0 unsafe`。
- 边界：两个新增 PNG 仍只是评审候选，不代表 final-ready；本次重新导出 standalone PNG 时均保留当前候选 01 语义，没有切换到 `candidate_02` 或改变 HUD / DemoShell / Stage16 / Boss 房引用语义。

### 2026-06-21 - Runtime source safety and confirmed P0 binding

- 状态：针对多项目并行开发风险，新增 P0 运行态来源门禁，并只接入 `project_session_confirmed` 派生明确的 `luna_jump_fall_sheet_ai01` 与 `stage16_seal_release_threshold_ai01`。
- 范围：新增 `scripts/assets/audit_runtime_source_safety.py`、`docs/assets/runtime-source-safety-report.json`、`docs/assets/runtime-source-safety-report.md` 和实施计划；修复 selected source candidate index 记录、standalone `.source.json` 记录与 `stage16_seal_release_threshold_ai01` runtime map 目标场景；更新玩家场景、Stage16 封印阈值房、Stage14 / Stage16 GUT 与 P0 报告。
- 验证：Source safety `103 candidates, 35 project-session confirmed, 30 ledger review-required, 38 provenance review-required, 0 unsafe`；runtime source safety `28 runtime assets, 16 review-required, 0 unsafe`；Godot import 通过；Stage14 GUT `11/11`、`135` 个断言；Stage16 GUT `13/13`、`113` 个断言；P0 replacement plan 推进到 `0 planned replacements, 28 already referenced`；P0 scene replacement batches 为 `18 planned scene-asset replacements, 36 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `36 passed, 19 blocked`。
- 边界：这只是来源确认和 preview binding，不代表 16 个 review-required runtime assets 已经来源确认，不代表授权、最终帧序、UI / VFX / TileSet polish 或 `final_ready`。

### 2026-06-21 - Seal Magic VFX atlas preview binding

- 状态：继续推进 P0 runtime replacement，把 `vfx_seal_magic_atlas_ai01` 的 Godot `SpriteFrames` 作为隐藏 VFX 预览层接入玩家场景和 Seal Guardian Boss 场景。
- 范围：更新 `scenes/player/player_placeholder.tscn`、`scenes/enemies/seal_guardian_boss.tscn`、Stage14 / Stage15 GUT；刷新 art readiness、final review queue、final acceptance gates、P0 replacement / scene reports 与综合资产包报告；新增 `docs/implementation-plans/2026-06-21-seal-magic-vfx-atlas-preview-binding.md`。
- 验证：Godot import 通过；Stage14 GUT `11/11`、`128` 个断言；Stage15 GUT `12/12`、`141` 个断言；P0 replacement plan 推进到 `2 planned replacements, 26 already referenced`；P0 scene replacement batches 推进到 `21 planned scene-asset replacements, 34 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `35 passed, 20 blocked`。
- 边界：这只是 AnimatedSprite2D VFX preview binding，不替换正式 VFX 播放、hitbox、damage Area、mask / blend、anchor、授权确认或 `final_ready`。

### 2026-06-21 - Luna core SpriteFrames preview binding

- 状态：继续推进 P0 runtime replacement，把 `luna_run_sheet_ai01`、`luna_air_dash_sheet_ai01`、`luna_attack_01_sheet_ai01` 与 `luna_idle_sheet_ai01` 的 Godot `SpriteFrames` 作为隐藏动画预览层接入正式玩家场景。
- 范围：更新 `scenes/player/player_placeholder.tscn` 和 `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`；刷新 P0 runtime replacement、target scene matrix、scene batches、final review queue、final acceptance gates 与综合资产包报告；新增 `docs/implementation-plans/2026-06-21-luna-core-spriteframes-preview-binding.md`。
- 验证：Godot import 通过；Stage14 GUT `11/11` 通过，`121` 个断言；P0 replacement plan 推进到 `3 planned replacements, 25 already referenced`；P0 scene replacement batches 推进到 `23 planned scene-asset replacements, 32 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `34 passed, 21 blocked`；source safety 仍为 `0 unsafe`。
- 边界：这只是 AnimatedSprite2D preview binding，不替换玩家控制器动画、碰撞盒、攻击窗口、Air Dash 时序、授权确认或 `final_ready`；`luna_jump_fall_sheet_ai01` 因无 `project_session_confirmed` candidate 仍未接入。

### 2026-06-21 - ImageGen project key source gate

- 状态：针对多项目并行开发风险，为 image_gen provenance 和 source-safety 层补齐 `project_key = nano-hunter` 强制门禁。
- 范围：更新 `scripts/assets/build_asset_provenance.py`、`scripts/assets/audit_asset_provenance.py`、`scripts/assets/audit_imagegen_source_safety.py`、`docs/assets/asset-provenance-records.json`、`docs/assets/imagegen-source-safety-report.json` 和 `docs/assets/asset-storage-policy.md`；新增 `docs/implementation-plans/2026-06-21-imagegen-project-key-source-gate.md`。
- 验证：Provenance 审计通过 `55 records, 101 candidate hashes, 55 output hashes`；source safety 审计通过 `101 candidates, 33 project-session confirmed, 30 ledger review-required, 38 provenance review-required, 0 unsafe`。
- 边界：该门禁只证明项目归属可审计，不代表 `review_required` 候选已经人工复核、授权确认、清稿、运行时替换或达到 `final_ready`。

### 2026-06-21 - Seal Guardian SpriteFrames preview binding

- 状态：继续推进 P0 runtime replacement，把 `seal_guardian_boss_sheet_ai01` 的 Godot `SpriteFrames` 作为隐藏动画预览层接入 Seal Guardian Boss 场景和 Stage15 Boss 房。
- 范围：更新 `scenes/enemies/seal_guardian_boss.tscn`、`scenes/rooms/stage15_seal_guardian_boss_room.tscn` 和 `tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`；刷新 P0 replacement、scene batches、final art gates 与综合资产包报告；新增 `docs/implementation-plans/2026-06-21-seal-guardian-spriteframes-preview-binding.md`。
- 验证：Godot import 通过；Stage15 GUT `12/12` 通过；P0 replacement plan 推进到 `7 planned replacements, 21 already referenced`；P0 scene replacement batches 推进到 `27 planned scene-asset replacements, 28 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `30 passed, 25 blocked`；source safety 仍为 `0 unsafe`。
- 边界：这只是 AnimatedSprite2D preview binding，不替换 Boss 状态机、攻击时序、damage Area、hitbox、正式动画播放、授权确认或 `final_ready`。

### 2026-06-21 - Miasma TileSet preview binding

- 状态：继续推进 P0 scene replacement，把 `miasma_marsh_tileset_ai01` 的 Godot `TileSet` 资源作为视觉预览层接入 Stage13 瘴泽入口房和 Stage14 Air Dash gate 房。
- 范围：更新 `scenes/rooms/stage13_miasma_marsh_entry_room.tscn`、`scenes/rooms/stage14_air_dash_gate_room.tscn`、`tests/stage13/test_stage_13_second_content_zone_production.gd` 和 `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`；刷新 P0 replacement、scene batches 与综合资产包报告；新增 `docs/implementation-plans/2026-06-21-miasma-tileset-preview-binding.md`。
- 验证：Godot import 通过；Stage13 GUT `9/9`、Stage14 GUT `11/11` 通过；`miasma_marsh_tileset_ai01` 为 `project_session_confirmed`；P0 replacement plan 推进到 `8 planned replacements, 20 already referenced`；P0 scene replacement batches 推进到 `28 planned scene-asset replacements, 27 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `29 passed, 26 blocked`；source safety 仍为 `0 unsafe`。
- 边界：这只是 TileMapLayer visual preview binding，不改变灰盒碰撞、autotile、正式 hazard Area、TileSet collision / terrain 复核、授权确认或 `final_ready`。

### 2026-06-21 - Player readability and Air Dash trail binding

- 状态：继续推进 P0 runtime replacement，把 `stage16_luna_player_readability_ai01` 接入正式玩家场景，并把 `stage14_air_dash_trail_ai01` 接入玩家场景和 Stage14 神龛房。
- 范围：更新 `scenes/player/player_placeholder.tscn`、`scenes/rooms/stage14_air_dash_shrine_room.tscn` 和 `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`；刷新 P0 replacement、scene batches、final art gates 与综合资产包报告；新增 `docs/implementation-plans/2026-06-21-player-readability-and-air-dash-trail-binding.md`。
- 验证：Stage14 GUT `11/11` 通过；两个资产均为 `project_session_confirmed`；P0 replacement plan 推进到 `9 planned replacements, 19 already referenced`；P0 scene replacement batches 推进到 `30 planned scene-asset replacements, 25 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `28 passed, 27 blocked`。
- 边界：这只接入玩家可读性方向稿和 Air Dash trail 静态资源，不改变玩家移动 / Air Dash 状态机、VFX 播放时序、动画帧序、授权确认或 `final_ready`。

### 2026-06-21 - Stage15 Boss art runtime binding

- 状态：继续推进 P0 runtime replacement，把 `stage15_seal_guardian_ai01` 与 `stage15_boss_attack_warning_ai01` 接入正式 Seal Guardian Boss 场景和 Stage15 Boss 房。
- 范围：更新 `scenes/enemies/seal_guardian_boss.tscn`、`scenes/rooms/stage15_seal_guardian_boss_room.tscn` 和 `tests/stage15/test_stage_15_combat_climax_and_elite_boss.gd`；刷新 P0 replacement、scene batches、final art gates 与综合资产包报告；新增 `docs/implementation-plans/2026-06-21-stage15-boss-art-runtime-binding.md`。
- 验证：Stage15 GUT `12/12` 通过；两个资产均为 `project_session_confirmed`；P0 replacement plan 推进到 `11 planned replacements, 17 already referenced`；P0 scene replacement batches 推进到 `33 planned scene-asset replacements, 22 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `26 passed, 29 blocked`。
- 边界：这只接入 Boss 方向稿和攻击预警静态资源，不改变 Boss 逻辑、攻击时序、damage Area、动画帧序、授权确认或 `final_ready`。

### 2026-06-21 - Stage14 Air Dash prop runtime binding

- 状态：继续推进 P0 runtime replacement，把 `stage14_air_dash_shrine_ai01` 与 `stage14_air_dash_gate_ai01` 接入正式 Stage14 shrine / gate 房间。
- 范围：更新 `scenes/rooms/stage14_air_dash_shrine_room.tscn`、`scenes/rooms/stage14_air_dash_gate_room.tscn` 和 `tests/stage14/test_stage_14_backtracking_and_ability_gating.gd`；刷新 P0 replacement、scene batches、final art gates 与综合资产包报告；新增 `docs/implementation-plans/2026-06-21-stage14-air-dash-prop-runtime-binding.md`。
- 验证：Stage14 GUT `10/10` 通过；两个资产均为 `project_session_confirmed`；P0 replacement plan 推进到 `13 planned replacements, 15 already referenced`；P0 scene replacement batches 推进到 `37 planned scene-asset replacements, 18 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `24 passed, 31 blocked`。
- 边界：这只接入 shrine / gate 静态道具 PNG，不改变 Air Dash 门控、碰撞、prop 最终清稿、授权确认或 `final_ready`。

### 2026-06-21 - Stage16 corruption purge VFX binding

- 状态：继续推进 Stage16 VFX runtime binding，把 `stage16_corruption_purge_ai01` 接入正式 `Stage16CorruptionPurgeRoom`。
- 范围：更新 `scenes/rooms/stage16_corruption_purge_room.tscn` 和 `tests/stage16/test_stage_16_alpha_demo_candidate.gd`；刷新 final art review queue / gates、source safety 与综合资产包报告；新增 `docs/implementation-plans/2026-06-21-stage16-corruption-purge-vfx-binding.md`。
- 验证：Stage16 GUT `12/12` 通过；`stage16_corruption_purge_ai01` 的 `runtime_replacement` gate 已通过；acceptance gates 的总体 `runtime_replacement` 刷新到 `22 passed, 33 blocked`；综合资产包审计通过并维持 `0 unsafe source candidates`。
- 边界：该资产 source safety 仍为 `workspace_provenance_recorded_review_required`，只证明当前项目候选已可运行引用，不代表来源人工复核、授权、VFX polish 或 `final_ready` 完成。

### 2026-06-21 - Stage16 talisman relay VFX binding

- 状态：继续推进 `batch_06_stage16_chain`，把 `stage16_talisman_relay_ai01` 接入正式 Stage16 relay / purge 房间。
- 范围：更新 `scenes/rooms/stage16_talisman_relay_room.tscn`、`scenes/rooms/stage16_corruption_purge_room.tscn` 和 `tests/stage16/test_stage_16_alpha_demo_candidate.gd`；刷新 P0 replacement、final art queue / gates、source safety 和综合资产包报告；新增 `docs/implementation-plans/2026-06-21-stage16-talisman-relay-vfx-binding.md`。
- 验证：Stage16 GUT `11/11` 通过；P0 replacement plan 推进到 `15 planned replacements, 13 already referenced`；P0 scene replacement batches 推进到 `41 planned scene-asset replacements, 14 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `13 passed, 42 blocked`。
- 边界：这只接入 relay VFX PNG 到正式房间，不代表 VFX 帧序、mask / blend、最终清稿、授权确认或 `final_ready` 完成。

### 2026-06-21 - ImageGen source safety audit

- 状态：针对多项目并行开发补齐 image_gen 来源安全审计层，避免全局 `generated_images` 中其它项目 PNG 误入 Nano Hunter 资产生产线。
- 范围：新增 `scripts/assets/audit_imagegen_source_safety.py` 与 `docs/assets/imagegen-source-safety-report.json`；扩展 `scripts/assets/audit_asset_package.py`；更新资产矩阵、生产 backlog、implementation plan 和进度日志。
- 验证：source safety audit 输出 `101 candidates, 33 project-session confirmed, 30 ledger review-required, 38 provenance review-required, 0 unsafe`；综合资产包审计通过并纳入 `0 unsafe source candidates`。
- 边界：这只证明跨项目来源风险受控，不代表 `review_required` 候选已经清稿、授权、选中、接入运行时或达到 `final_ready`。

### 2026-06-21 - TutorialHUD atlas resource binding

- 状态：继续推进 `batch_02_hud`，把 `hud_core_ui_atlas_ai01` 与 `icon_sheet_core_ai01` 的 Godot `AtlasTexture` 资源绑定到正式 `TutorialHUD`。
- 范围：更新 `scenes/ui/tutorial_hud.tscn` 和 `tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd`；刷新 P0 replacement、final art queue / gates 和综合资产包报告；新增 `docs/implementation-plans/2026-06-21-tutorial-hud-atlas-resource-binding.md`。
- 验证：Stage12 GUT `9/9` 通过，Stage14 GUT `9/9` 通过，Stage15 GUT `11/11` 通过；P0 replacement plan 推进到 `16 planned replacements, 12 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `12 passed, 43 blocked`。
- 边界：两个 atlas 当前为隐藏 `TextureRect` preview 资源绑定，不代表最终 HUD 图标选择、布局替换、小尺寸读值、授权确认或 `final_ready` 完成。

### 2026-06-21 - TutorialHUD frame resource binding

- 状态：继续推进 `batch_02_hud`，把 Stage14 ability status HUD frame 与 Stage15 Boss HUD frame 资源绑定到正式 `TutorialHUD`。
- 范围：更新 `scenes/ui/tutorial_hud.tscn` 和 `tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd`；刷新 P0 replacement、final art queue / gates 和综合资产包报告；新增 `docs/implementation-plans/2026-06-21-tutorial-hud-frame-resource-binding.md`。
- 验证：Stage12 GUT `9/9` 通过，Stage14 GUT `9/9` 通过，Stage15 GUT `11/11` 通过；P0 replacement plan 推进到 `18 planned replacements, 10 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `10 passed, 45 blocked`。
- 边界：两个 frame 当前为隐藏 `TextureRect` 资源绑定占位，不代表最终 HUD 布局、NinePatch / 裁切、读值复核、授权确认或 `final_ready` 完成。

### 2026-06-21 - TutorialHUD P0 icon runtime binding

- 状态：继续推进 `batch_02_hud`，把 Air Dash 与 Recovery Charge 的 image gen 图标接入正式 `TutorialHUD`。
- 范围：更新 `scenes/ui/tutorial_hud.tscn` 和 `tests/stage12/test_stage_12_asset_pipeline_and_demo_polish.gd`；刷新 P0 replacement、final art queue / gates 和综合资产包报告；新增 `docs/implementation-plans/2026-06-21-tutorial-hud-p0-icon-runtime-binding.md`。
- 验证：Stage12 GUT `9/9` 通过，Stage14 GUT `9/9` 通过，Stage15 GUT `11/11` 通过；P0 replacement plan 推进到 `20 planned replacements, 8 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `8 passed, 47 blocked`。
- 边界：这只接入两个 HUD 图标节点，不代表 HUD atlas、Boss HUD frame、ability status HUD、图标清稿、授权确认或 `final_ready` 完成。

### 2026-06-21 - Stage16 completion art runtime binding

- 状态：继续推进 P0 runtime replacement，把 `stage16_alpha_demo_completion_ai01` 接入正式 Stage16 终点房完成反馈。
- 范围：更新 `scenes/rooms/stage16_alpha_demo_end_room.tscn`、`tests/stage16/test_stage_16_alpha_demo_candidate.gd`、P0 replacement / scene batch 审计脚本与资产报告；新增 `docs/implementation-plans/2026-06-21-stage16-completion-art-runtime-binding.md`。
- 验证：Stage16 专项 GUT `10/10` 通过；P0 replacement plan 推进到 `22 planned replacements, 6 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `6 passed, 49 blocked`；综合资产包审计通过。
- 边界：这只接入终点房完成反馈 PNG，不代表 UI 最终清稿、授权确认或 `final_ready`；整体仍为 `55/55 structural_ready`、`0/55 final_ready`。

### 2026-06-21 - DemoShell UI shell texture binding

- 状态：继续推进 `batch_01_ui_shell`，把 DemoShell 标题背景、菜单图标、暂停面板和完成面板候选接入正式 UI 场景。
- 范围：更新 `scenes/ui/demo_shell.tscn`、`scripts/ui/demo_shell.gd`、`scripts/dev/audit_runtime_ui_skin_binding.gd`、`scripts/assets/audit_asset_package.py` 和 `tests/stage16/test_stage_16_alpha_demo_candidate.gd`；新增 `docs/implementation-plans/2026-06-21-demoshell-ui-shell-texture-binding.md` 与 `docs/progress/logs/2026-06-21.md`。
- 验证：`audit_runtime_ui_skin_binding.gd` 输出 `2 scenes, 5 panels, 4 textures`；Stage16 专项 GUT `9/9` 通过；P0 replacement plan 推进到 `23 planned replacements, 5 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `5 passed, 50 blocked`。
- 边界：这只接入 DemoShell UI 壳的部分纹理，不代表 UI 最终清稿；`final_ready` 仍为 `0/55`。

### 2026-06-20 - Runtime UI skin binding

- 状态：把 image gen UI skin 从 dev showcase / rehearsal 推进到正式运行时 UI 场景引用。
- 范围：更新 `scenes/ui/demo_shell.tscn` 与 `scenes/ui/tutorial_hud.tscn`，根 Control 绑定 `nano_hunter_imagegen_ui.theme.tres`，`MainMenu`、`PauseMenu`、`PromptPanel` 与 `BattlePanel` 绑定 `menu_ninepatch_ui_ai01` 的 `StyleBoxTexture`；新增 `scripts/dev/audit_runtime_ui_skin_binding.gd` 和 `docs/implementation-plans/2026-06-20-runtime-ui-skin-binding.md`；扩展 `audit_art_readiness.py` 与 `audit_asset_package.py`。
- 验证：`audit_runtime_ui_skin_binding.gd` 输出 `2 scenes, 4 panels`；综合资产包审计输出 `9 UI Theme mappings, 4 runtime UI skin panels`；P0 replacement plan 推进到 `26 planned replacements, 2 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `2 passed, 53 blocked`。
- 边界：这只接入九宫格 UI skin，不替换独立 UI 背景、HUD 图标、Boss HUD frame 或 ability status HUD；`final_ready` 仍为 `0/55`。

### 2026-06-20 - P0 scene replacement batches

- 状态：把 P0 target scene replacement matrix 拆成可逐批执行的场景替换顺序，方便后续按 UI、HUD、玩家、Boss、Stage14、Stage16、Stage13 TileSet 和战斗敌人动画分批接入。
- 范围：新增 `scripts/assets/build_p0_scene_replacement_batches.py`、`scripts/assets/audit_p0_scene_replacement_batches.py`、`docs/assets/p0-scene-replacement-batches.json`、`docs/assets/p0-scene-replacement-batches.md` 和 `docs/implementation-plans/2026-06-20-p0-scene-replacement-batches.md`；扩展 `audit_asset_package.py`。
- 验证：批次审计输出 `9 batches, 13 scenes, 28 assets, 55 scene-asset references`；综合资产包审计纳入 `9 P0 scene replacement batches`。
- 边界：该批次计划只做后续正式替换的执行顺序和验证范围，不修改 `.tscn`，不关闭 `runtime_replacement` gate。

### 2026-06-20 - P0 target scene replacement matrix

- 状态：把 P0 runtime replacement plan 按目标场景聚合，形成后续正式替换时的场景级执行矩阵。
- 范围：新增 `scripts/assets/build_p0_target_scene_replacement_matrix.py`、`scripts/assets/audit_p0_target_scene_replacement_matrix.py`、`docs/assets/p0-target-scene-replacement-matrix.json`、`docs/assets/p0-target-scene-replacement-matrix.md` 和 `docs/implementation-plans/2026-06-20-p0-target-scene-replacement-matrix.md`；扩展 `audit_asset_package.py`。
- 验证：目标场景矩阵审计输出 `13 scenes, 28 assets, 55 scene-asset references`；综合资产包审计纳入 `13 P0 target scenes`。
- 边界：该矩阵只做场景级替换排程，不修改正式 `.tscn` 引用，不关闭 `runtime_replacement` gate。

### 2026-06-20 - P0 runtime replacement rehearsal

- 状态：为 `28` 个 P0 runtime entries 生成 Godot 编辑器排练场景，验证资源可绑定到兼容节点。
- 范围：新增 `scripts/dev/build_p0_runtime_replacement_rehearsal.gd`、`scripts/dev/audit_p0_runtime_replacement_rehearsal.gd`、`scenes/dev/p0_runtime_replacement_rehearsal.tscn`、`docs/assets/p0-runtime-replacement-rehearsal-manifest.json` 和 `docs/implementation-plans/2026-06-20-p0-runtime-replacement-rehearsal.md`；扩展 `audit_asset_package.py`。
- 验证：Godot 审计输出 `P0 runtime replacement rehearsal OK: 28 nodes`；综合资产包审计纳入 `28 P0 runtime rehearsal nodes`。
- 边界：该场景只证明 P0 资源可被 Godot 节点消费，不修改正式 gameplay / HUD / room 场景引用，不关闭 `runtime_replacement` gate。

### 2026-06-20 - P0 runtime replacement plan

- 状态：为 P0 runtime entries 生成运行时替换执行计划，明确每个资产的目标场景、资源路径、替换模式、当前引用状态和验证命令。
- 范围：新增 `scripts/assets/build_p0_runtime_replacement_plan.py`、`scripts/assets/audit_p0_runtime_replacement_plan.py`、`docs/assets/p0-runtime-replacement-plan.json`、`docs/assets/p0-runtime-replacement-plan.md` 和 `docs/implementation-plans/2026-06-20-p0-runtime-replacement-plan.md`；扩展 `audit_asset_package.py`。
- 验证：P0 runtime replacement plan 初始审计输出 `28 entries, 27 planned replacements, 1 already referenced`；后续 runtime UI skin binding 已推进到 `26 planned replacements, 2 already referenced`；综合资产包审计纳入 `28 P0 runtime replacement-plan entries`。
- 边界：该计划只把 `runtime_replacement` gate 拆成可执行替换清单，不直接修改正式场景引用，不代表运行时替换完成。

### 2026-06-20 - Final art acceptance gates

- 状态：把 `55` 个结构可用资产拆成最终美术验收门槛，明确每个资产从 `structural_ready` 到 `final_ready` 还需要关闭哪些 gate。
- 范围：新增 `scripts/assets/build_final_art_acceptance_gates.py`、`scripts/assets/audit_final_art_acceptance_gates.py`、`docs/assets/final-art-acceptance-gates.json`、`docs/assets/final-art-acceptance-gates.md` 和 `docs/implementation-plans/2026-06-20-final-art-acceptance-gates.md`；扩展 `audit_asset_package.py`。
- 验证：Acceptance gates 审计输出 `55 assets, 55 blocked assets, 0 final-ready assets`；综合资产包审计纳入 `55 final-art acceptance-gated assets`。
- 边界：来源追踪、Godot 结构资源和编辑器复核卡已通过，不代表授权条款、运行时替换、专项清稿或最终批准完成。

### 2026-06-20 - Final art review Workbench

- 状态：把最终美术复核队列转成 Godot 编辑器可打开的 Workbench，支持按 P0 / P1 / P2 和 family 查看 `55` 个资产预览、blockers 与 next actions。
- 范围：新增 `scripts/dev/build_final_art_review_workbench.gd`、`scripts/dev/audit_final_art_review_workbench.gd`、`scenes/dev/final_art_review_workbench.tscn`、`docs/assets/final-art-review-workbench-manifest.json` 和 `docs/implementation-plans/2026-06-20-final-art-review-workbench.md`；扩展 `audit_asset_package.py`。
- 验证：Godot 审计输出 `Final art review workbench OK: 55 cards, 55 manual-review assets, 0 final-ready assets`；综合资产包审计纳入 `55 final-art workbench cards`。
- 边界：该 Workbench 是编辑器内扫图和复核排程入口，不代表最终美术批准、授权完成、运行时替换或玩法读值完成。

### 2026-06-20 - Final art review queue

- 状态：把 `55` 个 image gen 资产的 readiness blockers 转换为最终美术复核队列，明确每个资产的人工清稿、授权、运行时替换和 Godot 复核动作。
- 范围：新增 `scripts/assets/build_final_art_review_queue.py`、`scripts/assets/audit_final_art_review_queue.py`、`docs/assets/final-art-review-queue.json`、`docs/assets/final-art-review-queue.md` 和 `docs/implementation-plans/2026-06-20-final-art-review-queue.md`；扩展 `audit_asset_package.py`。
- 验证：复核队列审计输出 `55 assets, 55 manual-review entries, 0 final-ready assets`；综合资产包审计输出 `55 final-art review entries`。
- 边界：该队列是复核 / 清稿 / 接入任务入口，不代表任何资产已经最终美术批准或正式替换运行时引用。

### 2026-06-20 - Background alpha policy

- 状态：为 `11` 个背景 / tile / texture / promo / CG / storyboard 类 alpha 输出补齐策略记录，把 readiness warning 清零并转为人工复核 blocker。
- 范围：新增 `scripts/assets/build_background_alpha_policy.py`、`scripts/assets/audit_background_alpha_policy.py`、`docs/assets/background-alpha-policy-report.json` 和 `docs/implementation-plans/2026-06-20-background-alpha-policy.md`；扩展 `audit_art_readiness.py` 与 `audit_asset_package.py`；生成 `6` 张 opaque preview。
- 验证：背景 alpha policy 审计通过：`11 records, 6 opaque previews, 5 alpha-allowed atlas assets`；Art readiness 输出 `warnings_by_type={}`、`alpha_padding_policy_manual_review=5`、`opaque_preview_manual_review=6`；综合资产包审计输出 `11 background alpha policies`。
- 边界：该策略只说明 alpha 用途和提供 opaque preview，不代表宣传 / CG / 分镜 / TileSet 最终清稿或运行时接入完成。

### 2026-06-20 - ImageGen import safety guard

- 状态：修正多项目并行开发下的 image gen 导入风险，防止把全局 `.codex/generated_images` 的“最新 PNG”误判为 Nano Hunter 资产。
- 范围：加固 `scripts/assets/import_imagegen_outputs.py`，新增 `--allow-global-latest` 显式确认开关；补充 `docs/assets/image-gen-session-recovery-log.md`、`docs/assets/asset-completion-matrix.md` 和 `docs/implementation-plans/2026-06-20-imagegen-import-safety-guard.md`。
- 验证：`python -m py_compile scripts\assets\import_imagegen_outputs.py` 通过；默认 `--copy-latest` 从全局 `generated_images` 导入时按预期拒绝；显式 `--source --dry-run` 仍能规划目标路径且不复制。
- 边界：本次只修正导入安全边界；不生成新资产、不重建 atlas、不替换 `assets/art/` 或运行时引用。

### 2026-06-20 - ImageGen runtime asset catalog

- 状态：在 runtime map 之后新增 Godot `ResourcePreloader` 目录场景，把 `55` 个 image gen 资产推进到可被 Godot 集中加载的 runtime catalog 状态。
- 范围：新增 `scripts/dev/build_imagegen_runtime_asset_catalog.gd`、`scripts/dev/audit_imagegen_runtime_asset_catalog.gd`、`scenes/dev/imagegen_runtime_asset_catalog.tscn`、`docs/assets/imagegen-runtime-asset-catalog-manifest.json` 和 `docs/implementation-plans/2026-06-20-imagegen-runtime-asset-catalog.md`；扩展 `scripts/assets/audit_art_readiness.py` 与 `scripts/assets/audit_asset_package.py` 纳入 runtime catalog。
- 验证：Godot build / audit 输出 `55 resources`；综合资产包审计输出 `55 runtime catalog resources`；Art readiness 中 `runtime_binding_map_ready_manual_replacement=0`、`runtime_catalog_ready_manual_replacement=55`。
- 边界：runtime catalog 只证明资源可集中加载，不代表正式 gameplay / HUD / room / Boss / VFX / TileSet 引用已替换。

### 2026-06-20 - Asset runtime integration map

- 状态：为 `55` 个 image gen 资产补齐运行时 / 发布接入 map，把每个资产绑定到目标 track、目标系统、推荐 Godot 资源类型和候选场景。
- 范围：新增 `scripts/assets/build_asset_runtime_map.py`、`scripts/assets/audit_asset_runtime_map.py`、`docs/assets/asset-runtime-integration-map.json` 和 `docs/implementation-plans/2026-06-20-asset-runtime-integration-map.md`；扩展 `scripts/assets/audit_art_readiness.py` 与 `scripts/assets/audit_asset_package.py` 纳入 runtime map。
- 验证：`python scripts\assets\audit_asset_runtime_map.py --strict` 输出 `55 entries, 9 tracks`；Art readiness 中 `runtime_reference_not_replaced=0`、`runtime_binding_map_ready_manual_replacement=55`；综合资产包审计输出 `55 runtime map entries`。
- 边界：runtime map 只证明接入路径已明确，不代表场景引用已经替换、运行时读值通过或最终美术完成。

### 2026-06-20 - Asset provenance records

- 状态：为 `55` 个 image gen 资产补齐来源、prompt、raw candidate hash 和 `assets/art` output hash 记录，把授权相关状态从“未记录来源”推进到“来源已记录、条款待人工复核”。
- 范围：新增 `scripts/assets/build_asset_provenance.py`、`scripts/assets/audit_asset_provenance.py`、`docs/assets/asset-provenance-records.json` 和 `docs/implementation-plans/2026-06-20-asset-provenance-records.md`；扩展 `scripts/assets/audit_art_readiness.py` 与 `scripts/assets/audit_asset_package.py` 纳入 provenance。
- 验证：`python scripts\assets\audit_asset_provenance.py --strict` 输出 `55 records, 120 candidate hashes, 55 output hashes`；Art readiness 仍为 `55/55 structural ready, 0/55 final ready`，blocker 从 `license_record_pending` 改为 `license_terms_manual_review`；综合资产包审计输出 `55 provenance records`。
- 边界：provenance 只证明来源和 hash 可追溯，不代表商业条款、最终美术审批或运行时接入完成。

### 2026-06-20 - ImageGen candidate review gallery

- 状态：把 `72` 个尚未进入 selected source 的 raw candidates 整理为 Godot 编辑器评审场景，方便后续人工扫图和决定是否替换选中源图。
- 范围：新增 `scripts/dev/build_imagegen_candidate_review_gallery.gd`、`scripts/dev/audit_imagegen_candidate_review_gallery.gd`、`scenes/dev/imagegen_candidate_review_gallery.tscn`、`docs/assets/imagegen-candidate-review-gallery-manifest.json` 和 `docs/implementation-plans/2026-06-20-imagegen-candidate-review-gallery.md`；扩展 `scripts/assets/audit_asset_package.py` 纳入 candidate review gallery 证据。
- 验证：`godot --headless --path . --script res://scripts/dev/audit_imagegen_candidate_review_gallery.gd` 输出 `Imagegen candidate review gallery OK: 72 candidates, 53 assets`；综合资产包审计输出 `72 unselected candidates, 72 candidate review cards`。
- 边界：Gallery 只证明未选候选可被 Godot 加载和集中展示，不自动重建 atlas，不替换 `assets/art` 或运行时引用，也不改变 `0/55 final_ready` 的真实状态。

### 2026-06-20 - ImageGen candidate pool audit layer

- 状态：新增 raw candidate / selected source 使用关系审计层，把新增 image gen PNG 从“已落盘”推进到“可追踪、可分拣、不可误判为最终资产”的候选池状态。
- 范围：新增 `scripts/assets/audit_imagegen_candidate_pool.py`、`docs/assets/imagegen-candidate-pool-report.json` 和 `docs/implementation-plans/2026-06-20-imagegen-candidate-pool-audit.md`；扩展 `scripts/assets/audit_asset_package.py` 纳入 candidate pool 证据。
- 验证：`python scripts\assets\audit_imagegen_candidate_pool.py --strict --write-report` 输出 `101 candidates, 538 selected sources, 72 unselected candidates, 53 review-required assets.`；综合资产包审计输出 `72 unselected candidates`；Art readiness 仍保持 `55/55 structural ready, 0/55 final ready`。
- 边界：新增 `30` 张 PNG 只作为 raw candidates 和人工分拣 backlog，不自动重建 `assets/art`，不替换运行时引用，也不改变任何资产的 `final_ready` / `integrated` 状态。

### 2026-06-20 - Character animation rules layer

- 状态：为 Luna、Seal Guardian 和 core enemies 的 Sprite Sheet 生成 first-pass animation rules，把角色 / 敌人动画从“有 SpriteFrames”推进到“有可审计 clip、fps、loop、pivot、脚底基线和 frame duration 规则”。
- 范围：新增 `scripts/assets/build_animation_rules.py`、`scripts/assets/audit_animation_rules.py` 和 `docs/implementation-plans/2026-06-20-character-animation-rules.md`；生成 `assets/art/characters/animation_rules/` 下 `8` 个 animation rule sidecars 与 `animation_rules.index.json`；扩展 `audit_asset_package.py` 与 `audit_art_readiness.py` 纳入 animation rules。
- 验证：`python scripts\assets\audit_animation_rules.py --strict` 输出 `Animation rules OK: 8 assets, 172 frame rules.`；综合资产包审计输出 `172 animation rules`；Godot import、Gallery 和 Integration Showcase 审计继续通过。
- 边界：当前不代表最终帧序、角色一致性、脚底基线、碰撞盒读值、动画速度或运行时动画替换完成。

### 2026-06-20 - VFX anchor / blend rules layer

- 状态：为 Batch10 VFX atlas 和 standalone VFX PNG 生成 first-pass anchor / blend rules，把 VFX 从“有图集和 SpriteFrames”推进到“有可审计接入规则”。
- 范围：新增 `scripts/assets/build_vfx_rules.py`、`scripts/assets/audit_vfx_rules.py` 和 `docs/implementation-plans/2026-06-20-vfx-anchor-rules.md`；生成 `assets/art/vfx/vfx_rules/` 下 `6` 个 VFX rule sidecars 与 `vfx_rules.index.json`；扩展 `audit_asset_package.py` 与 `audit_art_readiness.py` 纳入 VFX rules。
- 验证：`python scripts\assets\audit_vfx_rules.py --strict` 输出 `VFX rules OK: 6 assets, 68 frame rules, 68 collision-disabled rules.`；综合资产包审计输出 `68 VFX rules`；Godot import、Gallery 和 Integration Showcase 审计继续通过。
- 边界：当前规则显式禁止 VFX 作为 collision / damage source，但不代表运行时 VFX 已替换、mask 清稿完成或真实伤害判定已 author。

### 2026-06-20 - Godot editor UI skin / Theme rules layer

- 状态：在 `StyleBoxTexture` 资源层之上，为 Batch08 `menu_ninepatch_ui_ai01` 生成 Godot `Theme` 候选和 UI skin rules，把九宫格候选推进到 Theme 映射与 text-safe area 规则入口。
- 范围：新增 `scripts/dev/build_editor_ui_skin.gd`、`scripts/dev/audit_editor_ui_skin.gd` 和 `docs/implementation-plans/2026-06-20-editor-ui-skin-rules.md`；生成 `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres` 与 `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json`；扩展 `audit_asset_package.py` 与 `audit_art_readiness.py` 纳入 UI skin 证据。
- 验证：`audit_editor_ui_skin.gd` 初始输出 `Editor UI skin OK: 8 style mappings, 4 standalone panels`；后续 runtime UI skin binding 已推进到 `9 style mappings` 和 `4 runtime UI skin panels`；readiness 报告仍保持 `55/55 structural ready, 0/55 final ready`。
- 边界：当前 UI skin 是 `placeholder_ready` editor candidate，不代表 DemoShell、Boss HUD 或 ability HUD 已替换；伪文字清理、真实布局、拉伸失真、小尺寸读值和运行态 UI 复核仍未完成。

### 2026-06-20 - ImageGen semantic label pass

- 状态：为已生成的 image gen 图集和 standalone 图标组补 first-pass 语义标签，减少自动编号切片无法直接接入的问题。
- 范围：新增 `scripts/assets/build_asset_semantics.py`、`scripts/assets/audit_asset_semantics.py`、`docs/assets/asset-semantics-index.json`、`assets/art/**/*.semantics.json` 和 `assets/art/ui/stage16_demo_menu_icons_ai01.semantics.json`；扩展 readiness / package audit 纳入语义标签覆盖。
- 验证：`python scripts\assets\build_asset_semantics.py` 写入 `26` 个 atlas-linked semantics / `538` entries；`python scripts\assets\audit_asset_semantics.py --strict` 输出 `Asset semantics OK: 26 assets, 538/538 semantic entries.`；综合资产包审计输出 `544 semantic labels`。
- 边界：这些标签是机器 first-pass，不是人工确认；readiness blocker 已从具体 semantic naming 缺口转为 `semantic_labels_manual_review`，最终接入前仍需人工确认图像内容、裁切范围和玩法语义。

### 2026-06-20 - ImageGen art readiness audit

- 状态：新增美术接入就绪审计层，用机器可读报告区分 `structural_ready` 与 `final_ready`，并修复 Seal Guardian 单图洋红 chroma key 未移除的问题。
- 范围：新增 `scripts/assets/audit_art_readiness.py` 与 `docs/assets/art-readiness-audit-report.json`；扩展 `scripts/assets/audit_asset_package.py` 纳入 readiness 报告；扩展 `scripts/assets/export_standalone_candidates.py` 支持绿色 / 洋红 chroma key；重导出 `assets/art/characters/enemies/stage15_seal_guardian_ai01.png` 为带 alpha 的 `RGBA` PNG。
- 验证：`python scripts\assets\audit_art_readiness.py --strict --write-report` 输出 `Art readiness audit OK: 55/55 structural ready, 0/55 final ready.`；`python scripts\assets\audit_asset_package.py --strict --write-report` 输出 `55 art-ready structures`；`alpha_expected_but_not_detected` 已清零。
- 边界：`structural_ready` 不等于 `integrated` 或最终美术完成；所有 `55` 个输出仍需授权记录、人工清稿、语义命名、运行时引用替换和 gameplay readability 复核。

### 2026-06-20 - Godot imagegen asset gallery and integration showcase

- 状态：新增 Godot 编辑器内资产 Gallery 预览入口，并继续新增节点级 Integration Showcase，证明当前 image gen 资产包可以被真实 Godot 节点加载。
- 范围：新增 `scripts/dev/build_imagegen_asset_gallery.gd`、`scripts/dev/audit_imagegen_asset_gallery.gd`、`scripts/dev/capture_imagegen_asset_gallery.gd`、`scripts/dev/build_imagegen_asset_integration_showcase.gd`、`scripts/dev/audit_imagegen_asset_integration_showcase.gd`、`scenes/dev/imagegen_asset_gallery.tscn`、`scenes/dev/imagegen_asset_integration_showcase.tscn`、`docs/assets/imagegen-asset-gallery-manifest.json` 和 `docs/assets/imagegen-asset-integration-showcase-manifest.json`。
- 验证：Gallery build / audit 通过，审计实际检查 `361` 个普通纹理预览和 `8` 个 `StyleBoxTexture` 预览；Gallery 非 headless 渲染烟测写出 `ok=true` 采样报告。Integration Showcase build / audit 通过，manifest 记录 `10` 个 `AnimatedSprite2D`、`2` 个 `TileMapLayer`、`4` 个 `PanelContainer` 和 `8` 个 `Sprite2D`，审计输出 `Imagegen asset integration showcase OK: res://scenes/dev/imagegen_asset_integration_showcase.tscn`。
- 边界：Gallery 是人工扫图和编辑器验收入口，Integration Showcase 是 node-consumption smoke；当前仍不证明最终清稿、授权、运行时引用替换、TileSet collision、NinePatch 清稿、动画调速或玩法读值。

### 2026-06-20 - Godot editor TileSet resource layer

- 状态：在 target-count、duplicate clearance 和 `AtlasTexture` 资源层之后，为 Batch07 两套 TileSet sheet 生成 Godot `TileSet` `.tileset.tres` 资源骨架。
- 范围：新增 `scripts/dev/build_editor_tilesets.gd` 与 `scripts/dev/audit_editor_tilesets.gd`；生成 `assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres` 与 `assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres`。
- 验证：`godot --headless --path . --script res://scripts/dev/build_editor_tilesets.gd` 写入 `2` 个资源；`godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd` 输出 `Editor TileSet resources OK: 2`；现有 target-count / AtlasTexture 审计继续通过。
- 边界：当前是 TileSet editor resource skeleton，只证明 texture、tile size、atlas source 和 tile 坐标可加载；collision、terrain sets、autotile、危险边界和运行时 TileMap 引用仍未完成。

### 2026-06-20 - Godot editor StyleBoxTexture resource layer

- 状态：为 Batch08 `menu_ninepatch_ui_ai01` 的 `8` 个 region 生成 Godot `StyleBoxTexture` `.tres` 资源骨架。
- 范围：新增 `scripts/dev/build_editor_styleboxes.gd` 与 `scripts/dev/audit_editor_styleboxes.gd`；生成 `assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/` 下 `8` 个 `.stylebox_texture.tres` 和 `menu_ninepatch_ui_ai01.styleboxes.index.json`。
- 验证：`godot --headless --path . --script res://scripts/dev/build_editor_styleboxes.gd` 输出 `Editor StyleBoxTexture resources built: 8`；`godot --headless --path . --script res://scripts/dev/audit_editor_styleboxes.gd` 输出 `Editor StyleBoxTexture resources OK: 8`。
- 边界：当前是九宫格 editor resource skeleton，只证明 texture、region 和保守 `24px` margin 可加载；Theme 接入、UI 清稿、伪文字清理、拉伸失真和运行时 UI 引用仍未完成。

### 2026-06-20 - Spine-style cutout export layer

- 状态：为 Batch11 Luna 与 Seal Guardian 拆件图集生成 Spine-style `.atlas`、`.spine_style.json` 和项目 cutout manifest。
- 范围：新增 `scripts/assets/build_spine_cutout_manifests.py` 与 `scripts/assets/audit_spine_cutout_manifests.py`；生成 `assets/art/spine_parts/spine_exports/` 下 `2` 个 asset exports、`48` 个 part descriptors。
- 验证：`python scripts\assets\build_spine_cutout_manifests.py --dry-run` 计划 `2` assets / `48` parts；正式构建写入索引；`python scripts\assets\audit_spine_cutout_manifests.py --strict` 输出 `Audited 2 Spine-style cutout exports with 48 parts.`
- 边界：当前是拆件交接描述，不是正式 Spine 工程、Godot 骨骼 rig 或运行时动画；部件语义命名、pivot、层级顺序、遮挡边缘和动画曲线仍未完成。

### 2026-06-20 - Asset package audit layer

- 状态：新增综合资产包审计脚本与结构化报告，用于统一记录当前 image gen 资产包、atlas 输出和 editor resources 的完整性。
- 范围：新增 `scripts/assets/audit_asset_package.py`；生成 `docs/assets/asset-package-audit-report.json`。
- 验证：`python scripts\assets\audit_asset_package.py --strict --write-report` 通过，报告 `ok=true`、`errors=[]`，覆盖 `55` queue items、`71` candidate PNGs、`26` atlas-linked outputs、`302` AtlasTextures、`2` TileSets、`8` StyleBoxes 和 `48` spine parts。
- 边界：当前仍是结构性审计，不证明最终美术质量、授权、运行时接入、TileSet collision、NinePatch 拉伸、VFX 锚点、Spine pivot 或玩法读值。

### 2026-06-20 - ImageGen duplicate reduction pass 01

- 状态：确认内置 `image_gen` 默认生成目录可直接作为可复制来源；本轮复制 `6` 张补充候选到 `assets/source/ai_generated/.../candidates/`，并让 selected source 准备脚本支持同一 asset 的多个 `candidate_XX` 合并抽取。
- 范围：两轮共复制 `16` 张补充候选，重建全部曾含 duplicate 的输出；`26/26` 个 atlas-linked outputs 当前全部为 `duplicates=0`。
- 验证：相关 `prepare_selected_sources.py --target target --only <asset_id> --overwrite` 和 `build_asset_atlases.py --only <asset_id>` 通过；`validate_asset_production_queue.py`、`build_asset_atlases.py --dry-run --strict`、`audit_asset_target_coverage.py --strict`、`godot --headless --path . --import` 通过；新增 `302` 个 Godot `AtlasTexture` editor resources 并通过 Python / Godot 加载审计。
- 边界：当前仍为 `placeholder_ready`，未替换运行时引用；后续重点转为人工清稿、帧序复核、TileSet / NinePatch / VFX 锚点语义整理和运行态接入验证。

### 2026-06-19 - ImageGen target-count 图集重建

- 状态：将已落盘的 image gen 候选从 minimum first pass 推进到 target-count atlas rebuild；`26/26` 个 atlas-linked outputs 已达到 `asset-atlas-build-manifest.json` 的 `expected_target`。
- 范围：重建 Sprite Sheet、Texture Atlas、TileSet sheet、Spine 拆件图集、UI 图集、VFX 图集、九宫格、Promo / CG / Storyboard sheet；selected source 当前为 `selected_frames=236`、`selected_items=122`、`selected_tiles=96`、`selected_parts=48`、`selected_panels=36`。
- 验证：`prepare_selected_sources.py --target target --overwrite`、`build_asset_atlases.py --dry-run --strict`、`build_asset_atlases.py` 和 `audit_asset_target_coverage.py --strict` 通过；`assets/art/**/*.png` 为 `55` 张，metadata JSON 为 `26` 个，`.spriteframes.tres` 为 `10` 个。
- 边界：当前仍为 `placeholder_ready`，未替换运行时引用；duplicate 补位已在 2026-06-20 清零，TileSet / Promo / CG / Storyboard 自动网格裁切、UI / VFX / Spine 清稿和运行态读值仍需后续处理。

### 2026-06-19 - Batch08 supplemental UI 面板补齐

- 状态：补充 Batch08 四个 UI panel / HUD frame 到 `docs/assets/image-gen-prompt-queue.json`，使用内置 `image_gen` 生成 Stage16 pause panel、Stage16 completion panel、Stage15 Boss HUD frame 和 Stage14 ability status HUD 候选。
- 范围：新增 `stage16_pause_panel_ui_ai01`、`stage16_completion_panel_ui_ai01`、`stage15_boss_hud_frame_ai01`、`stage14_ability_status_hud_ai01`；当前 queue 为 `55` items，`assets/art/**/*.png` 为 `55` 张。
- 验证：`python scripts\assets\validate_asset_production_queue.py` 通过：`55` items、`26` atlas-linked outputs；四组 `export_standalone_candidates.py --only <asset_id> --overwrite` 成功；`godot --headless --path . --import` 退出码为 `0`；透明度检查确认四张图角落 alpha 为 `0` 且 opaque green pixels 为 `0`。
- 边界：当前仍为 `placeholder_ready`，未替换 DemoShell、Stage15 Boss HUD 或 Stage14 ability HUD；需要清理伪文字、面板切片、九宫格 / mask 设计、小尺寸读值和运行态 UI 复核。

### 2026-06-19 - Batch03 supplemental 房间背景补齐

- 状态：补充 Batch03 四个具体房间 / 视差源图到 `docs/assets/image-gen-prompt-queue.json`，使用内置 `image_gen` 生成 shrine trial room、Air Dash shrine room、miasma hazard room 和 Seal Guardian boss room 背景候选。
- 范围：新增 `biome01_shrine_trial_room_parallax_ai01`、`biome01_air_dash_shrine_room_ai01`、`biome02_miasma_hazard_room_ai01`、`stage15_seal_guardian_boss_room_ai01`；当前 queue 为 `51` items，`assets/art/**/*.png` 为 `51` 张。
- 验证：`python scripts\assets\validate_asset_production_queue.py` 通过：`51` items、`26` atlas-linked outputs；四组 `export_standalone_candidates.py --only <asset_id> --overwrite` 成功；`godot --headless --path . --import` 退出码为 `0`。
- 边界：当前仍为 `placeholder_ready`，未替换场景背景引用；需要亮度控制、视差拆层、遮挡复核和运行态检查。


### 2026-06-19 - Batch06 supplemental 动画覆盖补齐

- 状态：补充 Batch06 三个缺口到 `docs/assets/image-gen-prompt-queue.json` 和 `asset-atlas-build-manifest.json`，使用内置 `image_gen` 生成 Luna jump/fall、Luna hit/death 和 core enemies 三张候选 sprite sheet。
- 范围：新增 `luna_jump_fall_sheet_ai01`、`luna_hit_death_sheet_ai01`、`enemies_core_sheet_ai01`；当前 queue 为 `47` items，`assets/art/**/*.png` 为 `47` 张，`.spriteframes.tres` 为 `10` 个。
- 验证：三组 sheet 均成功拆出 `16/16` selected frames；`build_asset_atlases.py --only <asset_id>` 成功写出 PNG、frames JSON 与 SpriteFrames；`godot --headless --path . --import` 退出码为 `0`。
- 边界：当前仍为 `placeholder_ready`，未替换运行时玩家或敌人动画；Luna 帧序、hit/death 风格简化和敌人按类型拆分仍需后续清稿。


### 2026-06-19 - Batch03 区域表现候选落盘

- 状态：新增 Batch03 区域表现条目到 `docs/assets/image-gen-prompt-queue.json`，使用内置 `image_gen` 生成 5 张候选，并从默认生成目录复制到项目候选目录后导出为 `assets/art` standalone PNG。
- 范围：新增 `biome01_shrine_trial_tiles_ai01`、`biome01_shrine_trial_background_ai01`、`biome02_miasma_marsh_tiles_ai01`、`biome02_miasma_marsh_background_ai01`、`reusable_seal_props_ai01`；当前 queue 为 `44` items，`assets/art/**/*.png` 为 `44` 张。
- 验证：`python scripts\assets\validate_asset_production_queue.py` 通过：`44` items、`23` atlas-linked outputs；`python scripts\assets\export_standalone_candidates.py --overwrite` 成功；`godot --headless --path . --import` 退出码为 `0`。
- 边界：Batch03 当前为 `placeholder_ready`，尚未切片为正式 TileSet、未配置碰撞语义、未替换场景背景或 props。

## Current Risks

- 2026-06-19 内置 `image_gen` 已生成 Batch00 / Batch01 / Batch02 / Batch03 / Batch06-Batch13 的 `55/55` 个候选 PNG；2026-06-20 已追加补充候选用于 duplicate clearance；2026-06-21 已追加当前项目确认候选用于 `luna_jump_fall_sheet_ai01` 和 `stage16_seal_release_threshold_ai01`，并追加 `stage16_demo_menu_icons_ai01_candidate_02` 与 `stage14_air_dash_icon_ai01_candidate_02` 两个评审候选；9 个 standalone runtime UI / VFX / prop PNG 已补齐带 `project_key = nano-hunter` 的 `.source.json`，`hud_core_ui_atlas_ai01` 已从 `candidate_01` 重建 selected source 与 atlas。同日继续为 15 个 runtime review-required 资产追加统一风格重生候选，当前候选池为 `120` raw candidates、`547` selected sources、`82` unselected candidates；source safety 为 `0` unsafe，runtime source safety 仍有 `15` 个 runtime assets 需来源 / 派生复核。当前已生成 target-count `assets/art` 候选 sheet / atlas / standalone PNG，`26/26` 个 atlas-linked outputs 已达到 `expected_target` 且全部 `duplicates=0`；非 SpriteFrames atlas-linked 输出已生成 `302` 个 Godot `AtlasTexture` editor resources，Batch07 两套 TileSet sheet 已生成 `2` 个 Godot `TileSet` `.tileset.tres`、`2` 个 `.tileset_rules.json`、`96` 个 tile rules、`64` 个 collision-ready tiles 和 `8` 个 hazard visual-only tiles，Batch08 `menu_ninepatch_ui_ai01` 已生成 `8` 个 Godot `StyleBoxTexture` 资源骨架、`1` 个 Godot `Theme` 候选、`9` 个 Theme stylebox mappings 和 `4` 个 standalone UI skin panel rules，Batch10 / standalone VFX 已生成 `6` 个 VFX rule sidecars 与 `73` 条 anchor-blend rules，Batch06 角色 / 敌人 Sprite Sheet 已生成 `8` 个 animation rule sidecars 与 `172` 条 frame rules，Batch11 已生成 `2` 个 Spine-style cutout exports / `48` 个 part descriptors；P0 runtime replacement plan 当前为 `28/28` already referenced，final-art `runtime_replacement` gate 为 `37 passed / 18 blocked`；Art readiness 报告确认 `55/55` structural-ready、`13/55` final-ready；综合资产包审计报告 `ok=true`。风险转为“剩余 42 个资产的候选质量、授权记录、15 个 runtime review-required 来源复核、TileSet 碰撞 / terrain 人工复核、正式危险 Area author、UI Theme 最终套用和读值、VFX mask / timing / runtime hookup、角色动画帧序 / 基线 / timing 复核、NinePatch 清稿、Spine parts 语义绑定和游戏内正式接入仍未完成”；`stage16_talisman_relay_ai01` 只批准为当前 Stage16 region-bound visual VFX。
- Batch 00-05 当前是资产需求与治理记录，不代表资产已生成或接入。
- Batch 06-13 当前已有 target-count 候选 Sprite Sheet、Texture Atlas、TileSet sheet、Spine 拆件图集、UI 图集、VFX 图集和九宫格 sheet；它们是 `provisional / target-count pass`，不代表最终清稿或玩法接入完成。
- `docs/assets/image-gen-prompt-queue.json` 当前是 `55` 条生产队列，不是资产完成证明；queue 条目只有在真实 PNG 落盘、筛选、清稿、图集化并验证后才能改为接入状态。
- `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md` 与 `docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md` 是执行单，不是完成证明。
- `docs/assets/image-gen-preview-log.md` 记录的是未落盘会话预览；除非后续导入真实 PNG，否则不视为资产完成。
- `assets/source/imagegen_inbox/` 是 Codex Desktop 手动下载 / 另存预览图的本地接力目录，只保留 `.gitkeep`；实际图片默认不进入普通 Git，确认 asset id 后用 `scripts/assets/import_imagegen_outputs.py --include-inbox` 或 `--source` 导入。
- `scripts/assets/import_imagegen_outputs.py --magic-scan` 是排查无扩展名缓存的诊断选项；扫描结果仍需人工确认，不能自动导入 Temp、clipboard 或插件图片。
- Batch00 当前是全局风格板 `1/1` 原始候选已落盘；只能作为 art direction 参考，不能替代具体游戏资产。
- Batch01 当前是 `8/8` 原始候选已落盘；其中单图方向稿仍需去背景、清边、缩放读值检查和人工筛选，不能更新为 `integrated`。
- Batch06 当前已生成 target-count 核心 sprite sheet 与 `SpriteFrames`；相关角色 / Boss / 敌人 atlas-linked 输出均已降到 `0` duplicate，但仍需人工帧序、角色一致性、碰撞读值和动画速度复核，不能直接替换玩家或敌人正式动画。
- Batch07 当前已生成第一版 TileSet / texture sheet，并已有 `miasma_marsh_tileset_ai01` 与 `shrine_trial_tileset_ai01` 的 Godot `.tileset.tres` 和 `.tileset_rules.json`；两个 TileSet 已具备 first-pass physics layer、terrain set、solid / one-way platform 碰撞候选和 hazard / decor visual-only 规则。但 TileSet 仍是自动裁切结果，尚未配置 autotile、navigation、occlusion、正式伤害 Area 或运行时 TileMap 引用，仍需人工重切、统一网格、碰撞误读和危险边界复核。
- Batch08 当前已生成第一版 UI atlas、icon sheet 和 NinePatch sheet；`menu_ninepatch_ui_ai01` 已有 `8` 个 Godot `StyleBoxTexture` 资源骨架，但仍需去文字、统一线宽、九宫格边界检查、拉伸失真复核、Theme 接入和 32x32 / 64x64 读值复核。
- Batch08 supplemental 当前已生成 pause / completion panel、Boss HUD frame 和 ability status HUD 四张 standalone UI PNG，但仍需切片、mask / NinePatch 设计、小尺寸读值、伪文字清理和运行态 UI 接入复核。
- Batch09 当前已生成第一版 prop / equipment atlas；`shrine_gate_prop_atlas_ai01` 和 `equipment_pickup_atlas_ai01` 已降到 `0` duplicate，但仍需拆件语义命名、状态帧整理和缩放读值检查，不能直接替换 shrine / gate / checkpoint / pickup 物件。
- Batch10 当前已生成第一版 VFX atlas 与 `SpriteFrames`；`vfx_combat_atlas_ai01` 与 `vfx_seal_magic_atlas_ai01` 均已降到 `0` duplicate，但正式版必须去文字、重排纯帧格并控制每组 VFX 锚点。
- Batch11 当前已生成第一版 Spine-style 拆件图集，并有 `.atlas` / `.spine_style.json` / `.cutout_manifest.json` 交接描述；但仍需拆层、补遮挡边缘、语义命名、pivot、层级顺序和绑定规格，不能直接接入骨骼动画或启用 Aseprite / Spine 类插件。
- Batch12 当前已生成第一版宣传 / CG sheet；key art 和 capsule art 不能对外发布，logo direction 不能作为最终标题字，CG 正式版必须人工清理文字、矢量化或重绘。
- Batch13 当前已生成第一版叙事分镜 sheet；仍需裁切、重排、去文字和剧情脚本匹配，不能直接接入剧情演出。
- AI 生成工具、音乐工具和视频工具的授权条款可能随账号计划变化；每批资产接入前必须记录工具、prompt、来源和授权状态。
- 原始 AI 候选、失败稿、参考图、源文件和授权截图默认不进入普通 Git；误提交会膨胀仓库并增加授权噪音。
- Godot MCP Pro 的端口迁移与 rendezvous 根治已通过静态、构建、脚本和 smoke 验证；当前会话若要实测 Godot MCP 直连新 rendezvous，需要从本 worktree 重开 IDE / CLI 会话加载新 server。
- MCP 运行态截图和一次性复核证据默认保留在 `tests/artifacts/local/`，不进入提交。

## Next Steps

- 下一步从 target-count `assets/art` 候选和 editor resources 开始做人工筛选、清稿、补帧、重切 TileSet / UI / VFX、人工复核 TileSet collision / terrain 候选、author 正式 hazard Area、拆分 Spine parts 语义、复核 StyleBoxTexture / NinePatch margins、配置 mask，并按 `asset-manifest.md` 回填来源、授权、状态和接入路径。
- 推送主线后，按 `docs/assets/asset-production-roadmap.md` 从 Batch 00 / Batch 01 开始生成候选资产。
- 真正接入资产时，运行 `godot --headless --path . --import`，并按影响范围执行对应 GUT 或人工复核。
- 若继续处理 Luna 行走关键帧素材，应单独提交或单独保留，不混入资产治理合并。

## References

- 资产存储策略：`docs/assets/asset-storage-policy.md`
- 资产生产路线图：`docs/assets/asset-production-roadmap.md`
- 完整资产补齐矩阵：`docs/assets/asset-completion-matrix.md`
- 动画帧数规格：`docs/assets/animation-frame-spec.md`
- Image gen 生产 backlog：`docs/assets/image-gen-production-backlog.md`
- Image gen prompt queue：`docs/assets/image-gen-prompt-queue.json`
- Image gen preview log：`docs/assets/image-gen-preview-log.md`
- Image gen session recovery log：`docs/assets/image-gen-session-recovery-log.md`
- Batch00 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-00-production-packet.md`
- Batch01 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- Batch06 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md`
- Batch07 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-07-production-packet.md`
- Batch08 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-08-production-packet.md`
- Batch09 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-09-production-packet.md`
- Batch10 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-10-production-packet.md`
- Batch11 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-11-production-packet.md`
- Batch12 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-12-production-packet.md`
- Batch13 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-13-production-packet.md`
- Image gen 提示词库：`docs/assets/image-gen-prompt-library.md`
- Godot 图集构建流程：`docs/assets/godot-atlas-build-pipeline.md`
- Asset semantics index：`docs/assets/asset-semantics-index.json`
- Asset semantic label plan：`docs/implementation-plans/2026-06-20-asset-semantic-label-pass.md`
- Art readiness audit report：`docs/assets/art-readiness-audit-report.json`
- Art readiness audit plan：`docs/implementation-plans/2026-06-20-art-readiness-audit.md`
- ImageGen Asset Gallery manifest：`docs/assets/imagegen-asset-gallery-manifest.json`
- ImageGen Asset Integration Showcase manifest：`docs/assets/imagegen-asset-integration-showcase-manifest.json`
- ImageGen Asset Integration Showcase plan：`docs/implementation-plans/2026-06-20-imagegen-asset-integration-showcase.md`
- Editor TileSet collision rule plan：`docs/implementation-plans/2026-06-20-editor-tileset-collision-rules.md`
- Image gen 输出定位 / 导入脚本：`scripts/assets/import_imagegen_outputs.py`
- Image gen selected 源图准备脚本：`scripts/assets/prepare_selected_sources.py`
- Image gen standalone 候选导出脚本：`scripts/assets/export_standalone_candidates.py`
- Image gen 生产队列校验脚本：`scripts/assets/validate_asset_production_queue.py`
- Image gen 批次执行单导出脚本：`scripts/assets/export_imagegen_batch_plan.py`
- 资产生成 brief：`docs/assets/asset-generation-brief.md`
- 资产清单：`docs/assets/asset-manifest.md`
- 资产接入 checklist：`docs/assets/asset-ingestion-checklist.md`
- Godot MCP 排障入口：`docs/dev/godot-mcp-pro-connectivity-guide.md`
- Stage16 Alpha Demo QA checklist：`docs/deliverables/stage16-alpha-demo-candidate/qa-checklist.md`
- Stage16 Alpha Demo release notes：`docs/deliverables/stage16-alpha-demo-candidate/release-notes.md`
- 当日日志：`docs/progress/logs/2026-06-19.md`
- 关键时间线：`docs/progress/timeline.md`
