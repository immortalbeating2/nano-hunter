# Nano Hunter Timeline

本文件只记录项目里程碑级事件。每日细节、命令输出、MCP 复核过程、分支操作原因和误判修正过程保存在 `docs/progress/logs/YYYY-MM-DD.md`。每条里程碑默认包含范围、结果、关键验证、详情日志；重要阶段收口或工具链修复可补提交 hash 与遗留风险。

## 2026-06-28

- **Godot MCP Pro v1.15.0 hardening upgrade**：以官方 `1.15.0` 为基底重新吸收本地 bridge hardening。
  结果：稳定目录切换到 `1.15.0-nh.1`；项目插件、Node server、补丁模板与联通文档同步更新；`.mcp.json` 继续使用 `%USERPROFILE%\.mcp\godot-mcp-pro\server\build\index.js`。
  关键验证或结论：新稳定路径 `npm run build` 通过，`npm test` 通过 `2` 个测试文件 / `6` 个测试；工具注册数为 `176`，包含本地 `get_bridge_status`；patch dry-run 通过；Godot editor 连接新稳定 bridge `17615`，CLI `project info` 使用 `17620` 通过。
  详情日志链接：`docs/progress/logs/2026-06-28.md`；遗留：npm audit 仍报告上游依赖 `10` 个漏洞，本轮不执行 `npm audit fix`，避免扩大依赖变更。

## 2026-06-24

- **Animation Runtime Replacement Pass ARP-19 Enemy hit spark runtime VFX binding**：把普通敌人受击 spark 从 Stage12 占位迁移到独立 runtime VFX visual。
  结果：新增 `enemy_hit_spark_vfx_runtime_ai01.spriteframes.tres`；`basic_melee_enemy.tscn`、`ground_charger_enemy.tscn`、`aerial_sentinel_enemy.tscn`、`miasma_caster_enemy.tscn` 均新增 `EnemyHitSparkVfxVisual`；旧 `Stage12HitSpark` 仅保留为 hidden fallback。
  关键验证或结论：Godot import 通过；Stage12 GUT `9/9 passed`、`147` asserts；Stage15 GUT `14/14 passed`、`267` asserts；`capture_enemy_hit_spark_vfx_review.gd` 写出本地截图和 JSON 报告，确认基础敌人受击时 runtime VFX 可见、resource / metadata OK 且无 Area / Collision 子节点。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换普通敌人受击闪视觉，不改变 `receive_attack()`、击败契约、hurtbox、collision、defeated 信号或敌人 AI。

- **Animation Runtime Replacement Pass ARP-18 Luna attack slash / seal arc VFX runtime binding**：把 Luna 攻击表现从旧 Stage12 单张 SVG 预览，推进到 clean attack body + 独立 slash VFX + 独立 seal arc VFX 三层运行态视觉。
  结果：新增 `luna_attack_slash_vfx_runtime_ai01.spriteframes.tres` 与 `luna_attack_seal_arc_vfx_runtime_ai01.spriteframes.tres`，分别引用 `vfx_combat_atlas_ai01` slash 段与 `vfx_seal_magic_atlas_ai01` seal burst 段；玩家攻击起手播放两个 VFX，攻击结束 / 受击 / 恢复时隐藏；旧 `Stage12SlashPreview` 保留为 legacy hidden preview。
  关键验证或结论：Godot import 通过；Stage14 GUT `15/15 passed`、`274` asserts；`capture_luna_attack_vfx_review.gd` 写出本地截图和 JSON 报告，确认玩家处于 `attack`、body / slash / seal arc 均可见、旧 Stage12 SVG 隐藏、两个 VFX resource / metadata OK 且无 Area / Collision 子节点。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换 Luna 攻击 VFX visual，不改变攻击时序、hitbox / hurtbox、伤害窗口、取消窗口、恢复充能或敌人受击逻辑。

- **Animation Runtime Replacement Pass ARP-17 active candidate / archived reference audit split**：把动作替换候选审计从混合 `candidate / reference` 数字拆成活跃 runtime candidates 与归档 references。
  结果：`docs/assets/animation-runtime-replacement-candidates.json` 中 8 个历史失败稿 / 已替代参考保留为 `archived_*` 或 `superseded_reference`，并声明 `superseded_by`；`audit_animation_runtime_replacement.py` 默认 strict gate 只阻塞活跃候选，同时验证归档参考的替代资产存在。
  关键验证或结论：candidate strict audit 通过 `15/15 active ready, 0 active blocked, 8 archived references, 0 archive errors`；这证明当前活跃 runtime sheet 几何 / 资源门禁已清零，不代表完整商业动作库或所有后续状态动画已完成。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只修正审计门禁与清单状态，不改变玩家、敌人、Boss 或 VFX 的 runtime 引用。

- **Animation Runtime Replacement Pass ARP-16 Luna Air Dash trail VFX runtime binding**：把 `stage14_air_dash_trail_ai01` 接入玩家 `dash` 状态的纯视觉拖尾层，并完成第一轮本地运行态截图复核。
  结果：`player_placeholder.gd` 新增 Air Dash trail 同步；`AirDashTrailArt` 只在 `STATE_DASH` 显示，跟随朝向位于角色身后，metadata 显式 `gameplay_collision=false` 与 `damage_source=false`；clean body 仍由 `luna_air_dash_body_runtime_sheet_ai02` 承担。
  关键验证或结论：Stage14 GUT `15/15 passed`、`225` asserts；`capture_luna_air_dash_vfx_review.gd` 写出本地截图和 JSON 报告，确认玩家处于 `dash`、clean body / trail 均可见、trail resource / metadata OK 且无 Area / Collision 子节点；本轮不新增角色动作候选，candidate / reference audit 保持 `16/23 ready, 7 blocked`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只绑定 Air Dash trail visual，不改变 dash 物理、能力消耗 / 恢复、碰撞、hurtbox / hitbox 或门控；后续仍可继续 polish mask / blend / alpha。

- **Animation Runtime Replacement Pass ARP-15 Seal Guardian attack VFX runtime binding**：把 `seal_guardian_attack_vfx_atlas_ai01` 接入 Seal Guardian `ground_impact` / `air_punish` 的纯视觉 VFX 层，并完成第一轮本地运行态截图复核。
  结果：`seal_guardian_boss.tscn` 新增 `SealGuardianAttackVfxVisual`；`seal_guardian_boss.gd` 按 Boss 攻击状态显示 `boss_attack_vfx`，非攻击状态隐藏；VFX 节点 metadata 继续显式 `gameplay_collision=false` 与 `damage_source=false`；运行态复核后把 VFX 下移到接近 Boss origin 并置于 body 后方，降低遮挡。
  关键验证或结论：VFX rules audit 通过 `7 assets, 86 frame rules`；asset package audit 通过；Godot import 通过；Stage15 GUT `14/14 passed`、`267` asserts；Stage14 GUT `15/15 passed`、`211` asserts；`capture_animation_runtime_replacement_review.gd` 写出本地截图和 JSON 报告，确认 Boss 处于 `ground_impact`、body / VFX 均可见、VFX resource / metadata OK 且无 Area / Collision 子节点；candidate / reference audit 保持 `16/23 ready, 7 blocked`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只绑定 Boss attack VFX visual，不改变 AttackArea、真实伤害、碰撞、hurtbox / hitbox、Boss AI 或房间流程；后续仍可继续 polish VFX 亮度、blend 和节奏。

- **Animation Runtime Replacement Pass ARP-14 Seal Guardian attack body AI02 runtime binding**：用内置 `image_gen` 重新生成 clean Boss attack body，并接入 Seal Guardian `ground_impact` / `air_punish` runtime visual。
  结果：新增 `imagegen_seal_guardian_attack_body_clean_source_ai02.png`、`seal_guardian_attack_body_runtime_sheet_ai02.*` 与构建脚本；candidate audit 推进到 `16/23 ready, 7 blocked`；旧 Boss attack / attack body 候选继续作为 blocked references。
  关键验证或结论：Godot import 通过；Stage15 GUT `14/14 passed`、`244` asserts；Stage14 GUT `15/15 passed`、`211` asserts；asset package audit 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换 Boss attack body visual，不改变 Boss 攻击时序、AttackArea、伤害窗口、hurtbox / hitbox、AI 或房间流程。

- **Animation Runtime Replacement Pass ARP-13 Luna air dash body AI02 runtime binding**：用内置 `image_gen` 重新生成 clean Air Dash body，并接入玩家 `dash` runtime visual。
  结果：新增 `imagegen_luna_air_dash_body_clean_source_ai02.png`、`luna_air_dash_body_runtime_sheet_ai02.*` 与构建脚本；candidate audit 推进到 `15/22 ready, 7 blocked`；旧 `luna_air_dash_runtime_sheet_ai01` 因 baked cyan energy / trail 继续作为 reference，不接 live dash。
  关键验证或结论：Godot import 通过；Stage14 GUT `15/15 passed`、`211` asserts；Stage15 GUT `14/14 passed`、`239` asserts；asset package audit 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换 dash body visual，不改变 dash 速度、持续时间、冷却、Air Dash 消耗 / 恢复、碰撞、hurtbox / hitbox 或能力门控。

- **Animation Runtime Replacement Pass ARP-12 Luna hit / death runtime binding**：把已通过几何审查的 Luna `hit_react` 与 `death_idle` 短 clip 接入玩家受击 / 死亡运行时视觉层。
  结果：`player_placeholder.gd` 在非致命 `receive_damage()` 后切到 `luna_hit_react_runtime_sheet_ai01`，在 defeated 状态优先切到 `luna_death_idle_runtime_sheet_ai01`；恢复满血后退出 death / hit visual。
  关键验证或结论：Godot import 通过；Stage14 GUT `14/14 passed`、`202` asserts；Stage15 GUT `14/14 passed`、`239` asserts；candidate audit 保持 `14/21 ready, 7 blocked`，因为本轮接入既有 ready clips。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换受击 / 死亡视觉层，不改变扣血、无敌、击退、defeated signal、checkpoint、hurtbox / hitbox 或 HUD 逻辑。

- **Animation Runtime Replacement Pass ARP-11 Luna attack body AI02 runtime binding**：用内置 `image_gen` 重新生成 Luna 干净攻击身体层，并接入玩家 `attack` / `air_attack` runtime visual。
  结果：新增 `imagegen_luna_attack_body_clean_source_ai02.png`、`luna_attack_body_runtime_sheet_ai02.*` 与构建脚本；candidate audit 推进到 `14/21 ready, 7 blocked`；旧 `luna_attack_body_runtime_sheet_ai01` 继续作为 blocked reference。
  关键验证或结论：Godot import 通过；Stage14 GUT `13/13 passed`、`184` asserts；strict candidate audit 仍按预期失败 `14/21 ready, 7 blocked`，因为其他旧 blocker 仍保留。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换 Luna attack body 视觉层，不改变攻击判定、slash VFX、hitbox / hurtbox 或伤害窗口。

- **Animation Runtime Replacement Pass ARP-10 enemy core runtime binding**：把四个普通敌人单体 runtime clips 接入对应场景的可见视觉层。
  结果：`basic_melee_enemy.tscn`、`ground_charger_enemy.tscn`、`aerial_sentinel_enemy.tscn` 与 `miasma_caster_enemy.tscn` 均新增 `EnemyRuntimeAnimationVisual`；`BaseEnemy.receive_attack()` 在敌人清除时隐藏 runtime visual。
  关键验证或结论：Godot import 通过；Stage15 GUT `14/14 passed`、`239` asserts；candidate / reference audit 仍保留 `13/20 ready, 7 blocked`，其中 `enemies_core_runtime_sheet_ai01` 继续作为 blocked roster reference。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只替换普通敌人视觉层，不改变 AI、伤害、碰撞或多状态动画时序。

- **Animation Runtime Replacement Pass ARP-09 Seal Guardian runtime binding**：把通过几何审查的 Boss `idle`、`warning` 与 `defeat` 三段动作接入可见运行态动作层。
  结果：`seal_guardian_boss.tscn` 新增 `SealGuardianRuntimeAnimationVisual`；`seal_guardian_boss.gd` 按 `idle` / `close_pressure` / `defeated` 切换 runtime SpriteFrames；攻击和硬直状态继续隐藏该 visual，避免误用 blocked Boss attack frames。
  关键验证或结论：Godot import 通过；Stage15 GUT `13/13 passed`、`184` asserts；candidate / reference strict audit 仍按预期为 `13/20 ready, 7 blocked`，Boss attack body 仍需重新生成或人工清稿。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是 Boss 三段非攻击动作 live visual binding，不是 Boss attack 正式替换。

- **Animation Runtime Replacement Pass ARP-08 Seal Guardian attack VFX rules**：为 ARP-07 拆出的 `seal_guardian_attack_vfx_atlas_ai01` 补 first-pass VFX rule sidecar 和索引。
  结果：新增 `assets/art/vfx/vfx_rules/seal_guardian_attack_vfx_atlas_ai01.vfx_rules.json`；`vfx_rules.index.json` 更新为 `7 assets / 86 frame rules`；`audit_asset_package.py` 的 VFX rules 数量校验改为读取索引预期。
  关键验证或结论：`audit_vfx_rules.py --strict` 通过，`7 assets, 86 frame rules`；综合资产包审计通过并重写 `asset-package-audit-report.json`，记录 `86 VFX rules`；所有新增 VFX rule 都显式禁用 gameplay collision 与 damage source。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是 VFX anchor / blend / no-damage 规则层，不是 Boss attack live binding。

- **Animation Runtime Replacement Pass ARP-07 Seal Guardian attack VFX split attempt**：尝试把 blocked Boss attack 拆成身体层和独立地面冲击 VFX atlas。
  结果：新增 `seal_guardian_attack_body_runtime_sheet_ai01` 和 `seal_guardian_attack_vfx_atlas_ai01`；VFX atlas 放入 `assets/art/vfx/atlases/`，不参与角色动作 ready 数字；attack body 因残留上方 cyan slash、底部清理洞和 detached fragments 标记为 blocked reference。
  关键验证或结论：ARP-07 构建 `2 assets, 16 frames`；candidate / reference audit 当前为 `13/20 ready, 7 blocked`；Godot import 通过并重新导入 Boss attack body PNG 与 attack VFX atlas PNG；当前 Boss attack 仍需重新生成或人工清稿，不能 live binding。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是 VFX 分层尝试和失败样本留痕，不是 Boss attack 正式替换完成。

- **Animation Runtime Replacement Pass ARP-06 Seal Guardian Boss split candidates**：把 `seal_guardian_boss_runtime_sheet_ai01` 从 Boss 多动作串联 sheet 误用风险中分离出来，拆成 Boss `idle`、`warning`、`attack` 与 `defeat` 短 clip。
  结果：`seal_guardian_boss_runtime_sheet_ai01` 标记为 `blocked_candidate_reference`；新增四个 Boss split runtime PNG、frames JSON、SpriteFrames 和 source records；`seal_guardian_attack_runtime_sheet_ai01` 因 cyan ground slash / impact VFX 烘在攻击帧里，也标记为 blocked reference。
  关键验证或结论：Boss split 构建 `4 assets, 20 frames`；candidate / reference audit 当前为 `13/19 ready, 6 blocked`；Godot import 通过并重新导入 4 张 Boss split PNG；Boss `idle`、`warning`、`defeat` 只批准为 geometry-ready candidates，尚未替换 live Boss room 或状态机。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是 Boss 候选池治理和动作短 clip 准备，不是 Stage15 Boss 正式动画替换。

- **Animation Runtime Replacement Pass ARP-05 enemy core split candidates**：把 `enemies_core_runtime_sheet_ai01` 从多敌人 roster 误用风险中分离出来，拆成四个单敌人 runtime candidates。
  结果：`enemies_core_runtime_sheet_ai01` 标记为 `blocked_candidate_reference`；新增 `enemy_basic_melee_runtime_sheet_ai01`、`enemy_ground_charger_runtime_sheet_ai01`、`enemy_aerial_sentinel_runtime_sheet_ai01` 与 `enemy_miasma_caster_runtime_sheet_ai01` 的 runtime PNG、frames JSON、SpriteFrames 和 source records；`build_animation_runtime_split_candidates.py` 支持 per-spec 输出目录与 `--only`。
  关键验证或结论：enemy split 构建 `4 assets, 32 frames`；candidate / reference audit 当前为 `11/15 ready, 4 blocked`；Godot import 通过并重新导入 6 张相关 PNG；四个单敌人 clip 只批准为 geometry-ready candidates，尚未替换 live enemy animation、AI 状态机、攻击窗口或 hurtbox。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是敌人候选池治理和单体 clip 准备，不是敌人场景正式替换。

- **Animation Runtime Replacement Pass ARP-04 split correction**：根据用户截图复核，撤回 `luna_attack_body_runtime_sheet_ai01` 的 ready 口径，并把相邻帧残片 / baked slash debris 纳入正式审计门槛。
  结果：新增 `scripts/assets/build_animation_runtime_split_candidates.py`；拆出 `luna_attack_body_runtime_sheet_ai01`、`luna_hit_react_runtime_sheet_ai01` 与 `luna_death_idle_runtime_sheet_ai01`；`luna_attack_body_runtime_sheet_ai01` 标记为 `blocked_candidate_reference`；`audit_animation_runtime_replacement.py` 新增 `detached_frame_fragments` 与 `blocked_candidate_reference` gate。
  关键验证或结论：split 构建 `3 assets, 28 frames`；candidate / reference strict audit 当前为 `6/9 ready, 3 blocked`；`luna_hit_react_runtime_sheet_ai01` 与 `luna_death_idle_runtime_sheet_ai01` 几何审计通过但未接 live hit/death；`attack_body` 需要重新生成或从干净逐帧源重切。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮是人工复核修正和候选池治理，不新增 live attack / hit / death 替换。

- **Animation Runtime Replacement Pass ARP-03 Luna attack / hit-death blocked candidates**：继续从现有 final-ready source 派生 Luna attack 与 hit/death 的 runtime-normalized candidates，但用 strict audit 阻止它们误入 live controller。
  结果：新增 `luna_attack_01_runtime_sheet_ai01` 与 `luna_hit_death_runtime_sheet_ai01` 的 runtime PNG、frames JSON、SpriteFrames 和 source records；candidate manifest 扩展到 `6` 个候选；Godot import 可正常导入两个 blocked candidates。
  关键验证或结论：ARP-03 构建 `2 assets, 40 frames`；candidate strict audit 当前 `4/6 ready, 2 blocked`；两个新候选均被 `unstable_content_scale` 阻止。attack 还存在 slash / cyan arc 烘入角色帧的问题；hit/death 站立受击到倒地跨度过大，不适合作为单个正式运行时 clip 直接替换。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：不接 live attack、air attack、hit reaction 或 death 状态；后续需要拆独立 attack VFX，并把 hit/death 拆成更稳定的语义 clips。

- **Animation Runtime Replacement Pass ARP-02 Luna jump/fall runtime binding**：继续从现有 final-ready source 派生 Luna jump/fall 与 air dash 的 runtime-normalized 候选，并把通过审计的 jump/fall 接入玩家可见运行时动画节点。
  结果：`scripts/assets/build_animation_runtime_candidates.py` 支持 `--pass-id` 与 `--merge-existing`；`docs/assets/animation-runtime-replacement-candidates.json` 扩展到 `4` 个候选；新增 jump/fall 与 air dash runtime PNG、frames JSON、SpriteFrames 和 source records；`scripts/player/player_placeholder.gd` 根据 `current_state` 在 `jump_rise` / `jump_fall` 状态切换到 `luna_jump_fall_runtime_sheet_ai01`。
  关键验证或结论：ARP-02 构建 `2 assets, 38 frames`；candidate strict audit 当前 `4/4 ready, 0 blocked`；`luna_jump_fall_runtime_sheet_ai01` 最小边距 `left=24, top=40, right=24, bottom=8`、脚底基线漂移 `1`；`luna_air_dash_runtime_sheet_ai01` 去除 2 个 duplicate frames，最小边距 `left=24, top=35, right=24, bottom=8`、脚底基线漂移 `0`；Godot import 通过；Stage14 GUT `12/12 passed`、`176` asserts。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只正式替换 Luna jump/fall 运行时视觉层；air dash 目前只批准为 geometry-ready candidate，未接 live dash，仍需复核与独立 `AirDashTrailArt` 的 VFX 分层关系。

- **Animation Runtime Replacement Pass ARP-01 Luna idle / run runtime binding**：从现有 final-ready source 派生 Luna idle / run 的 runtime-normalized 候选，并把通过严格审计的两个候选接入玩家可见运行时动画节点。
  结果：新增 `scripts/assets/build_animation_runtime_candidates.py`、`docs/assets/animation-runtime-replacement-candidates.json`、candidate audit 报告，以及 `assets/art/characters/player/sprite_sheets/runtime_replacement/` 下的 idle / run PNG、frames JSON、SpriteFrames 和 source records；`scenes/player/player_placeholder.tscn` 新增 `LunaRuntimeAnimationVisual`；`scripts/player/player_placeholder.gd` 根据 `current_state` 切换 idle / run runtime SpriteFrames。
  关键验证或结论：候选构建 `2 assets, 37 frames`；candidate strict audit 为 `2/2 ready, 0 blocked`；`luna_idle_runtime_sheet_ai01` 最小边距 `left=36, top=8, right=36, bottom=8`、脚底基线漂移 `0`；`luna_run_runtime_sheet_ai01` 移除 3 个 exact duplicate frames，最小边距 `left=16, top=18, right=16, bottom=8`、脚底基线漂移 `0`；Godot import 通过；Stage14 GUT `12/12 passed`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只正式替换 Luna idle / run 运行时视觉层；跳跃、攻击、dash、受击、敌人和 Boss 动作仍未达到正式替换标准。

- **Animation Runtime Replacement Pass ARP-00 audit gate**：启动动作正式替换批次，把当前 hidden/runtime animation preview 资产升级到 formal runtime replacement 审计标准。
  结果：新增 `scripts/assets/audit_animation_runtime_replacement.py`、`docs/assets/animation-runtime-replacement-audit-report.json` / `.md`、`spec-design/2026-06-24-animation-runtime-replacement-pass.md` 与 `docs/implementation-plans/2026-06-24-animation-runtime-replacement-pass.md`；当前 8 张角色 / 敌人 / Boss animation sheets 均被阻止直接替换 live controller。
  关键验证或结论：Animation runtime replacement audit `0/8 ready, 8 blocked`；`audit_animation_runtime_replacement.py --strict` 按预期失败；`audit_animation_rules.py --strict` 仍通过 `8 assets, 172 frame rules`，说明现有 rules 可审计但不足以证明正式替换。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：本轮只建立正式替换门槛和 blocker 报告，不替换 live player / enemy / Boss controller 动画。

- **P2 final-ready mini pack 26**：将 `capsule_art_alpha_demo_ai01`、`cg_seal_guardian_reveal_ai01`、`nano_hunter_logo_direction_ai01`、`promo_key_art_sheet_ai01`、`storyboard_intro_bounty_ai01`、`storyboard_miasma_marsh_ai01` 与 `storyboard_narrative_sheet_ai01` 推进为当前 Alpha Demo presentation / promo / narrative direction source。
  结果：不新增图片生成；复核既有 image_gen promo / logo / CG / storyboard outputs；生成 P2 promo / story contact sheet；扩展 finalization review records；final-art queue 刷新为 `0` 个 manual-review entries、`55` 个 final-ready assets；Pass 02 blocked assets 已清零。
  关键验证或结论：Asset finalization reviews `55/55 approved final-ready records`；Art readiness `55/55 structural ready, 55/55 final ready`；final acceptance gates `0 blocked assets, 55 final-ready assets`；asset package audit 通过并记录 `55 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 55 final-ready`；final-art workbench `55 cards, 0 manual-review assets, 55 final-ready assets`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 direction source，不批准最终 logo 字体、平台裁切、公开营销图、商店页素材、最终剧情脚本、对白、本地化、过场成片或发布级 CG。

- **P1 final-ready mini pack 25**：将 `equipment_pickup_atlas_ai01`、`reusable_seal_props_ai01`、`shrine_gate_prop_atlas_ai01` 与 `material_texture_atlas_ai01` 推进为当前 Alpha Demo source atlas / prop source / material reference source。
  结果：不新增图片生成；复核既有 image_gen equipment / pickup atlas、shrine / gate prop atlas、reusable seal prop sheet 和 material texture atlas；生成 P1 props / texture contact sheet；扩展 finalization review records；final-art queue 刷新为 `7` 个 manual-review entries、`48` 个 final-ready assets；P0 / P1 blocked assets 已清零。
  关键验证或结论：Asset finalization reviews `48/48 approved final-ready records`；Art readiness `55/55 structural ready, 48/55 final ready`；final acceptance gates `7 blocked assets, 48 final-ready assets`，blocked by priority 为 P2 `7`；asset package audit 通过并记录 `48 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 48 final-ready`；final-art workbench `55 cards, 7 manual-review assets, 48 final-ready assets`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 source atlas / prop source / material reference source，不批准最终 pickup 逻辑、reward balance、shrine / gate 状态机、collision、room placement、runtime scale、无缝贴图、shader/material binding 或 terrain replacement。

- **P1 final-ready mini pack 24**：将 `biome01_air_dash_shrine_room_ai01`、`biome01_shrine_trial_background_ai01`、`biome01_shrine_trial_room_parallax_ai01`、`biome01_shrine_trial_tiles_ai01`、`biome02_miasma_hazard_room_ai01`、`biome02_miasma_marsh_background_ai01`、`biome02_miasma_marsh_tiles_ai01`、`miasma_marsh_tileset_ai01`、`shrine_trial_tileset_ai01` 与 `stage15_seal_guardian_boss_room_ai01` 推进为当前 Alpha Demo environment visual source / editor TileSet source。
  结果：不新增图片生成；复核既有 image_gen 环境背景、房间图、tile visual pass 和两套 TileSet source；扩展 finalization review records；final-art queue 刷新为 `11` 个 manual-review entries、`44` 个 final-ready assets；P0 blocked assets 继续保持清零。
  关键验证或结论：Asset finalization reviews `44/44 approved final-ready records`；Art readiness `55/55 structural ready, 44/55 final ready`；final acceptance gates `11 blocked assets, 44 final-ready assets`，blocked by priority 为 P1 `4`、P2 `7`；asset package audit 通过并记录 `44 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 44 final-ready`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 environment visual source / editor TileSet source，不批准最终 autotile、collision polygon、hazard damage Area、navigation、occlusion、完整 parallax split、全场景替换或商业级背景清稿。

- **P0 final-ready mini pack 23**：将 `seal_guardian_spine_parts_ai01` 从 structural-ready Spine 拆件图集，推进为当前 Alpha Demo 后续 rigging handoff 的 Seal Guardian Spine-style cutout source / export package。
  结果：复核既有 image_gen `24` part atlas、frames / regions metadata、semantics、`.atlas`、`.spine_style.json`、`.cutout_manifest.json` 与总索引；扩展 finalization review records；final-art queue 刷新为 `21` 个 manual-review entries、`34` 个 final-ready assets；P0 blocked assets 已清零。
  关键验证或结论：Asset finalization reviews `34/34 approved final-ready records`；Art readiness `55/55 structural ready, 34/55 final ready`；final acceptance gates `21 blocked assets, 34 final-ready assets`，blocked by priority 为 P1 `14`、P2 `7`；asset package audit 通过并记录 `34 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 34 final-ready`；Spine cutout exports `2` assets / `48` parts 审计通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 future rigging handoff cutout source，不批准正式 Spine rig、Skeleton2D / Bone2D 绑定、运行时动画替换、Boss 状态机时序、hitbox / hurtbox、damage window、公开 sprite source、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 22**：将 `luna_spine_parts_ai01` 从 structural-ready Spine 拆件图集，推进为当前 Alpha Demo 后续 rigging handoff 的 Luna Spine-style cutout source / export package。
  结果：复核既有 image_gen `24` part atlas、regions、semantics、`.atlas`、`.spine_style.json`、`.cutout_manifest.json` 与总索引；扩展 finalization review records；final-art queue 刷新为 `22` 个 manual-review entries、`33` 个 final-ready assets；剩余 P0 只剩 `seal_guardian_spine_parts_ai01`。
  关键验证或结论：Asset finalization reviews `33/33 approved final-ready records`；Art readiness `55/55 structural ready, 33/55 final ready`；final acceptance gates `22 blocked assets, 33 final-ready assets`；asset package audit 通过并记录 `33 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 33 final-ready`；Spine cutout exports `2` assets / `48` parts 审计通过；Godot import 通过；final-art workbench `55 cards, 22 manual-review assets, 33 final-ready assets`。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 future rigging handoff cutout source，不批准正式 Spine rig、Skeleton2D / Bone2D 绑定、运行时动画替换、hitbox / hurtbox、攻击时序、公开 sprite source、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 21**：将 `enemies_core_sheet_ai01` 从旧版跨格 VFX、错误最终格和 duplicate fallback 风险的 core enemies sheet，推进为当前 Alpha Demo hidden/runtime core enemy roster animation preview。
  结果：使用内置 `image_gen` 生成并采用 `candidate_06`；按项目管线抽取 `32/32` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；基础近战敌人场景新增隐藏 `EnemiesCoreAnimationPreview` 引用；扩展 finalization review records；final-art queue 刷新为 `23` 个 manual-review entries、`32` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `32/32 approved final-ready records`；ImageGen candidate pool `133 candidates, 102 unselected candidates`；Asset provenance `55 records, 133 candidate hashes, 55 output hashes`；ImageGen source safety `133 candidates, 0 unsafe`；Runtime source safety `30 runtime assets, 18 review-required, 0 unsafe`；Art readiness `55/55 structural ready, 32/55 final ready`；final acceptance gates `23 blocked assets, 32 final-ready assets`；asset package audit 通过并记录 `32 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 32 final-ready`；candidate review gallery `102 candidates, 55 assets`；final-art workbench `55 cards, 23 manual-review assets, 32 final-ready assets`；runtime source workbench `18 assets, 72 candidates`；P0 runtime rehearsal `30 nodes`；Godot import 通过；Stage15 GUT `12/12`、`156` asserts 通过；`git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime core enemy roster animation preview，不批准正式敌人 AI 动画替换、攻击判定、hurtbox / hitbox、逐敌人状态机、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 20**：将 `luna_hit_death_sheet_ai01` 从旧版混合比例、残留绿边和动作不连续的 hit/death sheet，推进为当前 Alpha Demo hidden/runtime Luna hit/death animation preview。
  结果：使用内置 `image_gen` 生成并采用 `candidate_04`；按项目管线抽取 `24/24` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；玩家场景新增隐藏 `LunaHitDeathAnimationPreview` 引用；扩展 finalization review records；final-art queue 刷新为 `24` 个 manual-review entries、`31` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `31/31 approved final-ready records`；ImageGen candidate pool `131 candidates, 99 unselected candidates`；Asset provenance `55 records, 131 candidate hashes, 55 output hashes`；ImageGen source safety `131 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 31/55 final ready`；final acceptance gates `24 blocked assets, 31 final-ready assets`；asset package audit 通过并记录 `31 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 31 final-ready`；candidate review gallery `99 candidates, 55 assets`；final-art workbench `55 cards, 24 manual-review assets, 31 final-ready assets`；Godot import 通过；Stage14 GUT `11/11`、`149` asserts 通过；`git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna hit/death animation preview，不批准正式玩家控制器动画替换、collision height、hitbox / hurtbox、受击无敌时序、失败 / 重开逻辑、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 19**：将 `seal_guardian_boss_sheet_ai01` 从旧版混合四足兽 / 人形守卫 sheet，推进为当前 Alpha Demo hidden/runtime Seal Guardian boss attack animation preview。
  结果：使用内置 `image_gen` 生成并采用 `candidate_04`；按项目管线抽取 `20/20` selected frames，重建 `256x192` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `25` 个 manual-review entries、`30` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `30/30 approved final-ready records`；ImageGen candidate pool `130 candidates, 97 unselected candidates`；Asset provenance `55 records, 130 candidate hashes, 55 output hashes`；ImageGen source safety `130 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 30/55 final ready`；final acceptance gates `25 blocked assets, 30 final-ready assets`；asset package audit 通过并记录 `30 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 30 final-ready`；candidate review gallery `97 candidates, 55 assets`；final-art workbench `55 cards, 25 manual-review assets, 30 final-ready assets`；Godot import 通过；Stage15 GUT `12/12`、`148` asserts 通过；`git diff --check` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Seal Guardian boss attack animation preview，不批准正式 Boss 状态机动画替换、攻击判定、damage window、受击 / 击败动作、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 18**：将 `luna_jump_fall_sheet_ai01` 从旧版需要 duplicate 补位的 jump / fall sheet，推进为当前 Alpha Demo hidden/runtime Luna jump/fall animation preview。
  结果：使用内置 `image_gen` 生成 `candidate_05` 与 `candidate_06`，最终采用 `candidate_06`；按项目管线抽取 `24/24` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `26` 个 manual-review entries、`29` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `29/29 approved final-ready records`；ImageGen candidate pool `129 candidates, 95 unselected candidates`；Asset provenance `55 records, 129 candidate hashes, 55 output hashes`；ImageGen source safety `129 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 29/55 final ready`；final acceptance gates `26 blocked assets, 29 final-ready assets`；asset package audit 通过并记录 `29 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 29 final-ready`；candidate review gallery `95 candidates, 55 assets`；final-art workbench `55 cards, 26 manual-review assets, 29 final-ready assets`；Godot import 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna jump/fall animation preview，不批准正式玩家控制器动画替换、collision height、hitbox / hurtbox、跳跃物理时序、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 17**：将 `luna_attack_01_sheet_ai01` 从旧版混合概念 attack sheet，推进为当前 Alpha Demo hidden/runtime Luna attack 01 animation preview。
  结果：使用内置 `image_gen` 生成 `candidate_06`，复制到项目候选目录，按项目管线抽取 `16/16` selected frames，重建 `192x160` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `27` 个 manual-review entries、`28` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `28/28 approved final-ready records`；ImageGen candidate pool `127 candidates, 94 unselected candidates`；Asset provenance `55 records, 127 candidate hashes, 55 output hashes`；ImageGen source safety `127 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 28/55 final ready`；final acceptance gates `27 blocked assets, 28 final-ready assets`；asset package audit 通过并记录 `28 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 28 final-ready`；candidate review gallery `94 candidates, 55 assets`；final-art workbench `55 cards, 27 manual-review assets, 28 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna attack 01 animation preview，不批准正式玩家控制器动画替换、hitbox / hurtbox、伤害时序、取消窗口、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 16**：将 `luna_air_dash_sheet_ai01` 从旧版混合姿态 Air Dash sheet，推进为当前 Alpha Demo hidden/runtime Luna Air Dash animation preview。
  结果：使用内置 `image_gen` 生成 `candidate_06`，复制到项目候选目录，按项目管线抽取 `16/16` selected frames，重建 `192x160` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `28` 个 manual-review entries、`27` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `27/27 approved final-ready records`；ImageGen candidate pool `126 candidates, 91 unselected candidates`；Asset provenance `55 records, 126 candidate hashes, 55 output hashes`；ImageGen source safety `126 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 27/55 final ready`；final acceptance gates `28 blocked assets, 27 final-ready assets`；asset package audit 通过并记录 `27 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 27 final-ready`；candidate review gallery `91 candidates, 55 assets`；final-art workbench `55 cards, 28 manual-review assets, 27 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna Air Dash animation preview；candidate 06 含两个显式 duplicate recovery frames，不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗或位移时序、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 15**：将 `luna_run_sheet_ai01` 从旧版混合概念 run sheet，推进为当前 Alpha Demo hidden/runtime Luna run animation preview。
  结果：使用内置 `image_gen` 生成 `candidate_06`，复制到项目候选目录，按项目管线抽取 `24/24` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `29` 个 manual-review entries、`26` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `26/26 approved final-ready records`；ImageGen candidate pool `125 candidates, 89 unselected candidates`；Asset provenance `55 records, 125 candidate hashes, 55 output hashes`；ImageGen source safety `125 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 26/55 final ready`；final acceptance gates `29 blocked assets, 26 final-ready assets`；asset package audit 通过并记录 `26 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 26 final-ready`；candidate review gallery `89 candidates, 55 assets`；final-art workbench `55 cards, 29 manual-review assets, 26 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna run animation preview，不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗时序、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 14**：将 `luna_idle_sheet_ai01` 从旧版混合姿态 idle sheet，推进为当前 Alpha Demo hidden/runtime Luna idle animation preview。
  结果：使用内置 `image_gen` 生成 `candidate_05`，复制到项目候选目录，按项目管线抽取 `16/16` selected frames，重建 `160x160` SpriteFrames atlas、frames、semantics 和 animation rules；扩展 finalization review records；final-art queue 刷新为 `30` 个 manual-review entries、`25` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `25/25 approved final-ready records`；ImageGen candidate pool `124 candidates, 87 unselected candidates`；Asset provenance `55 records, 124 candidate hashes, 55 output hashes`；ImageGen source safety `124 candidates, 0 unsafe`；Runtime source safety `28 runtime assets, 15 review-required, 0 unsafe`；Art readiness `55/55 structural ready, 25/55 final ready`；final acceptance gates `30 blocked assets, 25 final-ready assets`；asset package audit 通过并记录 `25 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 25 final-ready`；candidate review gallery `87 candidates, 55 assets`；final-art workbench `55 cards, 30 manual-review assets, 25 final-ready assets`；Godot import 通过；Stage14 GUT `11/11` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime Luna idle animation preview，不批准正式玩家控制器动画替换、hitbox / hurtbox、战斗时序、公开 sprite sheet、商店页素材或商业动画清稿。

- **P0 final-ready mini pack 13**：将 `vfx_combat_atlas_ai01` 从 review-required combat VFX atlas，推进为当前 Alpha Demo hidden/runtime combat VFX preview。
  结果：确认既有 atlas 为无文字、透明、32 帧战斗反馈图集；在玩家与 Seal Guardian 场景中增加隐藏 `CombatVfxPreview` runtime 预览引用；关闭该资产 semantics / VFX rules 的人工复核标记，并扩展 finalization review records；final-art queue 刷新为 `31` 个 manual-review entries、`24` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `24/24 approved final-ready records`；ImageGen candidate pool `123 candidates, 85 unselected candidates`；Asset provenance `55 records, 123 candidate hashes, 55 output hashes`；ImageGen source safety `123 candidates, 0 unsafe`；Runtime source safety `28 runtime assets, 15 review-required, 0 unsafe`；Art readiness `55/55 structural ready, 24/55 final ready`；final acceptance gates `31 blocked assets, 24 final-ready assets`；asset package audit 通过并记录 `24 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 24 final-ready`；final-art workbench `55 cards, 31 manual-review assets, 24 final-ready assets`；Godot import 通过；Stage14 GUT `11/11`、Stage15 GUT `12/12` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime combat VFX preview，不批准最终战斗时序、玩法碰撞、伤害来源、受击窗口、公开 VFX 图集、商店页素材或宣传素材。

- **P0 final-ready mini pack 12**：将 `vfx_seal_magic_atlas_ai01` 从旧版带英文标签的 seal magic VFX atlas 候选，推进为当前 Alpha Demo hidden/runtime seal magic VFX preview。
  结果：使用内置 `image_gen` 重生 `candidate_05`，复制到项目候选目录，重建 `32/32` selected frames、atlas、SpriteFrames、semantics 和 VFX rules；扩展 finalization review records；final-art queue 刷新为 `32` 个 manual-review entries、`23` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `23/23 approved final-ready records`；ImageGen candidate pool `123 candidates, 85 unselected candidates`；Asset provenance `55 records, 123 candidate hashes, 55 output hashes`；Art readiness `55/55 structural ready, 23/55 final ready`；final acceptance gates `32 blocked assets, 23 final-ready assets`；asset package audit 通过并记录 `23 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 23 final-ready`；candidate review gallery `85 candidates, 55 assets`；final-art workbench `55 cards, 32 manual-review assets, 23 final-ready assets`；Godot import 通过；Stage14 GUT `11/11`、Stage15 GUT `12/12` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 hidden/runtime seal magic VFX preview，不批准最终战斗时序、玩法碰撞、伤害来源、公开 VFX 图集、商店页素材或宣传素材。

- **P0 final-ready mini pack 11**：将 `hud_core_ui_atlas_ai01` 从旧版 gameplay HUD 语义待复核状态，推进为当前 `TutorialHUD` source atlas preview。
  结果：修正 `assets/art/ui/atlases/hud_core_ui_atlas_ai01.semantics.json`，把旧版 health / ability / boss status 等机器语义改为可见 HUD 装饰、符旗、面板、分隔线和莲花徽章描述；扩展 finalization review records；final-art queue 刷新为 `33` 个 manual-review entries、`22` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `22/22 approved final-ready records`；Art readiness `55/55 structural ready, 22/55 final ready`；final acceptance gates `33 blocked assets, 22 final-ready assets`；asset package audit 通过并记录 `22 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 22 final-ready`；final-art workbench `55 cards, 33 manual-review assets, 22 final-ready assets`；Godot import 通过；Stage12 GUT `9/9` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 `TutorialHUD` source atlas preview / editor AtlasTexture resource set，不批准直接 gameplay HUD 语义绑定、最终 Theme mapping、完整 HUD 设计系统、商店页 UI 或宣传素材。

- **P0 final-ready mini pack 10**：将 `icon_sheet_core_ai01` 从旧版核心图标语义待复核状态，推进为当前 Alpha Demo 内部核心图标源图集。
  结果：修正 `assets/art/ui/atlases/icon_sheet_core_ai01.semantics.json`，把旧版 gameplay / HUD / menu 语义替换为图像可见语义描述；扩展 finalization review records；final-art queue 刷新为 `34` 个 manual-review entries、`21` 个 final-ready assets。
  关键验证或结论：Asset finalization reviews `21/21 approved final-ready records`；Art readiness `55/55 structural ready, 21/55 final ready`；final acceptance gates `34 blocked assets, 21 final-ready assets`；asset package audit 通过并记录 `21 asset finalization approvals`；family coverage `10/10 families, 7/7 Godot formats, 21 final-ready`；final-art workbench `55 cards, 34 manual-review assets, 21 final-ready assets`；Godot import 通过；Stage12 GUT `9/9` 通过。
  详情日志链接：`docs/progress/logs/2026-06-24.md`；边界：只批准为 internal core icon source atlas / editor AtlasTexture preview，不批准直接 gameplay HUD/menu 语义绑定、完整最终图标体系、商店页 UI 或宣传素材。

## 2026-06-23

- **P0 final-ready mini pack 09**：将 `stage16_demo_menu_icons_ai01` 从旧版 menu icon preview 推进为当前 DemoShell 六宫格 runtime menu icon strip。
  结果：用内置 `image_gen` 生成 `candidate_04`，显式导入项目候选目录，转换为 RGBA alpha PNG，并补齐 `source.json`、`regions.json`、`semantics.json` 与 finalization review；final-art queue 刷新为 `35` 个 manual-review entries、`20` 个 final-ready assets。
  关键验证或结论：ImageGen candidate pool `122 candidates, 83 unselected candidates`；ImageGen source safety `122 candidates, 0 unsafe`；Art readiness `55/55 structural ready, 20/55 final ready`；final acceptance gates `35 blocked assets, 20 final-ready assets`；asset package audit 通过并记录 `20 asset finalization approvals`；candidate review gallery `83 candidates, 55 assets`；final art review workbench `55 cards, 35 manual-review assets, 20 final-ready assets`；Godot import 通过；Stage16 GUT `13/13` 通过。
  详情日志链接：`docs/progress/logs/2026-06-23.md`；边界：只批准当前 `DemoShell` 六宫格 runtime menu icon strip，不批准完整最终图标体系、未来按钮状态重做、HUD atlas 无关区域、商店页 UI 或宣传素材。

- **P0 final-ready mini pack 08**：将 `menu_ninepatch_ui_ai01` 从 NinePatch / StyleBoxTexture preview 推进为当前 runtime Theme / StyleBox skin。
  结果：`8` 个 StyleBoxTexture、`9` 个 Theme style mappings、DemoShell / TutorialHUD runtime UI skin binding 均通过审计；final-art queue 刷新为 `36` 个 manual-review entries、`19` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 19/55 final ready`；final acceptance gates `36 blocked assets, 19 final-ready assets`；asset package audit 通过并记录 `19 asset finalization approvals`；Godot import 通过；Editor StyleBoxTexture resources `8`、Editor UI skin `9 style mappings, 4 standalone panels`、runtime UI skin binding `2 scenes, 5 panels, 4 textures`；Stage12 GUT `9/9`、Stage16 GUT `13/13` 通过。
  详情日志链接：`docs/progress/logs/2026-06-23.md`；边界：只批准当前 `DemoShell` / `TutorialHUD` runtime Theme / StyleBoxTexture skin，不批准完整最终 UI 设计系统、未来按钮状态重做、商店页 UI 或无关 atlas 区域。

- **P0 final-ready mini pack 07**：将 `stage16_pause_panel_ui_ai01` 与 `stage16_completion_panel_ui_ai01` 从 chroma-key preview 推进为 DemoShell runtime panel preview。
  结果：两个 Stage16 panel 输出均转换为 RGBA alpha PNG，四角透明且无不透明绿残留；final-art queue 刷新为 `37` 个 manual-review entries、`18` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 18/55 final ready`；final acceptance gates `37 blocked assets, 18 final-ready assets`；asset package audit 通过并记录 `18 asset finalization approvals`；Godot import 通过；runtime UI skin binding `2 scenes, 5 panels, 4 textures`；Stage16 GUT `13/13`、Stage12 GUT `9/9` 通过。
  详情日志链接：`docs/progress/logs/2026-06-23.md`；边界：只批准当前 `DemoShell` pause / completion runtime panel preview，不批准通用 UI atlas、最终按钮状态、菜单图标语义、商店页完成图或商业宣传素材。

- **P0 final-ready mini pack 06**：将 `stage15_boss_hud_frame_ai01` 与 `stage14_ability_status_hud_ai01` 从 chroma-key preview 推进为 TutorialHUD runtime frame。
  结果：两个 HUD frame 输出均转换为 RGBA alpha PNG，四角透明且无不透明绿残留；final-art queue 刷新为 `39` 个 manual-review entries、`16` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 16/55 final ready`；final acceptance gates `39 blocked assets, 16 final-ready assets`；family coverage `10/10 families, 7/7 Godot formats, 16 final-ready`。
  详情日志链接：`docs/progress/logs/2026-06-23.md`；边界：只批准当前 `TutorialHUD` runtime frame preview，不批准通用 UI atlas、按钮状态、独立图标集、Boss 血量逻辑或商业宣传素材。

- **P0 final-ready mini pack 05**：将 `stage16_corruption_purge_ai01` 从 review-required VFX sheet 推进为 region-bound Stage16 purge runtime VFX。
  结果：补齐 `stage16_corruption_purge_ai01` finalization review；该资产使用 `3x2` / `6` frame VFX rules，Stage16 purge 房间继续通过显式 `region_rect` 引用单格视觉帧；final-art queue 刷新为 `41` 个 manual-review entries、`14` 个 final-ready assets。
  关键验证或结论：VFX rules `6 assets, 78 frame rules`；Art readiness `55/55 structural ready, 14/55 final ready`；final acceptance gates `41 blocked assets, 14 final-ready assets`；asset package audit 通过并记录 `14 asset finalization approvals` 与 `78 VFX rules`。
  详情日志链接：`docs/progress/logs/2026-06-23.md`；边界：只批准当前 Stage16 region-bound visual VFX，不批准整张 sheet 上屏、伤害判定、通用动画序列、商业宣传素材或剩余 `41` 个 blocked 资产。

## 2026-06-21

- **P0 final-ready mini pack 04**：将 `stage16_talisman_relay_ai01` 从整图 VFX sheet 预览推进为 region-bound Stage16 runtime VFX。
  结果：`build_vfx_rules.py` 为该资产生成 `3x2` / `6` frame region rules；Stage16 relay / purge 房间的 talisman relay Sprite2D 改为显式 `region_rect`，避免整张候选 sheet 上屏；final-art queue 刷新为 `42` 个 manual-review entries、`13` 个 final-ready assets。
  关键验证或结论：VFX rules `6 assets, 73 frame rules`；Art readiness `55/55 structural ready, 13/55 final ready`；final acceptance gates `42 blocked assets, 13 final-ready assets`；asset package audit 通过并记录 `13 asset finalization approvals`；Godot import 通过；Stage16 GUT `13/13`、`125` asserts 通过。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；边界：只批准当前 Stage16 region-bound visual VFX，不批准整张 sheet 上屏、伤害判定、通用动画序列或 `stage16_corruption_purge_ai01`。

- **ImageGen runtime review-required 资产统一重生候选落盘**：按统一 Nano Hunter 美术风格为 15 个 runtime review-required 资产追加新 raw candidates，不覆盖当前 `assets/art/` 输出或运行时引用。
  结果：新增 15 张候选 PNG，其中 8 张用于混合来源资产的统一风格对照，7 张用于 `manual_source_review_or_regenerate` 的必须重生路径；落盘报告推进到 `7/7 runtime source regeneration landed`；candidate review gallery 刷新为 `82 candidates, 55 assets`。
  关键验证或结论：Candidate pool 输出 `120 candidates, 547 selected sources, 82 unselected candidates, 55 review-required assets`；source safety 输出 `120 candidates, 35 project-session confirmed, 30 ledger review-required, 55 provenance review-required, 0 unsafe`；Godot import 通过；project isolation 输出 `1936 files, 0 forbidden markers, 0 outside paths, 0 project_key errors`；综合资产包审计通过，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；实施计划：`docs/implementation-plans/2026-06-21-runtime-source-regeneration-candidate-pass.md`。

- **ImageGen runtime source safety 与确认来源 P0 接入**：针对多项目并行开发风险，新增运行态来源门禁，并只接入当前 Nano Hunter 会话确认来源的 `luna_jump_fall_sheet_ai01` 与 `stage16_seal_release_threshold_ai01`。
  结果：新增 runtime source safety 报告；`luna_jump_fall_sheet_ai01` 从 `candidate_04` 重建并接入玩家场景隐藏预览，`stage16_seal_release_threshold_ai01` 从 `candidate_02` 导出并接入 Stage16 封印阈值房 visual preview；P0 runtime replacement plan 推进到 `0 planned replacements, 28 already referenced`。
  关键验证或结论：Source safety 输出 `103 candidates, 35 project-session confirmed, 0 unsafe`；runtime source safety 输出 `28 runtime assets, 16 review-required, 0 unsafe`；Godot import 通过；Stage14 GUT `11/11`、Stage16 GUT `13/13` 通过；P0 scene replacement batches 为 `9 batches, 14 scenes, 28 assets, 54 scene-asset references`；acceptance gates 的 `runtime_replacement` 推进到 `36 passed, 19 blocked`，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；实施计划：`docs/implementation-plans/2026-06-21-runtime-source-safety-and-confirmed-p0-binding.md`。

- **ImageGen Seal Magic VFX Atlas 预览接入**：继续推进 P0 runtime replacement，把 `vfx_seal_magic_atlas_ai01` 接入玩家场景和 Seal Guardian Boss 场景作为隐藏 VFX 预览层。
  结果：`PlayerPlaceholder` 与 `SealGuardianBoss` 均新增隐藏 `SealMagicVfxPreview`，引用 `vfx_seal_magic_atlas_ai01.spriteframes.tres` 的 `seal_magic` 动画；该资产至少包含 1 个 `project_session_confirmed` candidate。
  关键验证或结论：Godot import 通过；Stage14 GUT `11/11`、Stage15 GUT `12/12` 通过；P0 replacement plan 推进到 `2 planned replacements, 26 already referenced`，P0 scene replacement batches 推进到 `21 planned scene-asset replacements, 34 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `35 passed, 20 blocked`，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Luna 核心 SpriteFrames 预览接入**：继续推进 P0 runtime replacement，把 Luna run / air dash / attack / idle 四个 SpriteFrames 接入正式玩家场景作为隐藏动画预览层。
  结果：`PlayerPlaceholder` 新增 `LunaRunAnimationPreview`、`LunaAirDashAnimationPreview`、`LunaAttackAnimationPreview` 与 `LunaIdleAnimationPreview`，均引用当前项目 session 已确认的 Luna 核心动作 SpriteFrames；`luna_jump_fall_sheet_ai01` 因缺少 `project_session_confirmed` candidate 仍保持未接入。
  关键验证或结论：Godot import 通过；Stage14 GUT `11/11` 通过；P0 replacement plan 推进到 `3 planned replacements, 25 already referenced`，P0 scene replacement batches 推进到 `23 planned scene-asset replacements, 32 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `34 passed, 21 blocked`，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen 项目键来源门禁**：针对多项目并行开发风险，为 image_gen provenance 与 source-safety 层补齐 `project_key = nano-hunter` 强制检查。
  结果：`asset-provenance-records.json` 顶层和 55 条记录均带有 `project_key = nano-hunter`，`imagegen-source-safety-report.json` 顶层带有 `project_key = nano-hunter`；后续非 Nano Hunter 来源记录会在 strict 审计中失败。
  关键验证或结论：`audit_asset_provenance.py --strict` 通过，输出 `55 records, 101 candidate hashes, 55 output hashes`；`audit_imagegen_source_safety.py --write-report --strict` 通过，输出 `101 candidates, 33 project-session confirmed, 30 ledger review-required, 38 provenance review-required, 0 unsafe`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Seal Guardian SpriteFrames 预览接入**：继续推进 P0 runtime replacement，把 Boss SpriteFrames 接入正式 Boss 场景 / Boss 房作为隐藏动画预览层。
  结果：`SealGuardianBoss` 新增 `SealGuardianAnimationPreview`，`Stage15SealGuardianBossRoom` 新增 `SealGuardianRoomAnimationPreview`，均引用 `assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.spriteframes.tres`；P0 replacement plan 推进到 `7 planned replacements, 21 already referenced`，P0 scene replacement batches 推进到 `27 planned scene-asset replacements, 28 already referenced`。
  关键验证或结论：Godot import 通过；Stage15 GUT `12/12` 通过；acceptance gates 的 `runtime_replacement` 推进到 `30 passed, 25 blocked`，但 Boss 动画仍需 frame order / baseline / timing 人工复核，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen 瘴泽 TileSet 预览接入**：继续推进 P0 scene replacement，把 `miasma_marsh_tileset_ai01` 的 Godot `TileSet` 资源接入 Stage13 / Stage14 正式房间作为视觉预览层。
  结果：`Stage13MiasmaMarshEntryRoom` 与 `Stage14AirDashGateRoom` 均新增 `MiasmaTilesetPreview` `TileMapLayer`，引用 `assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres`；该资产为 `project_session_confirmed`；P0 replacement plan 推进到 `8 planned replacements, 20 already referenced`，P0 scene replacement batches 推进到 `28 planned scene-asset replacements, 27 already referenced`。
  关键验证或结论：Godot import 通过；Stage13 GUT `9/9`、Stage14 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `29 passed, 26 blocked`，但 TileSet 仍需 collision / terrain / hazard 人工复核，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen 玩家可读性与 Air Dash trail 接入**：继续推进 P0 runtime replacement，把 Luna 方向稿和 Air Dash trail 接入正式玩家 / Stage14 神龛房。
  结果：`PlayerPlaceholder` 新增 `LunaReadabilityArt` 与 `AirDashTrailArt`，`Stage14AirDashShrineRoom` 新增 `AirDashTrailPreviewArt`；两个资产均为 `project_session_confirmed`；P0 replacement plan 推进到 `9 planned replacements, 19 already referenced`，P0 scene replacement batches 推进到 `30 planned scene-asset replacements, 25 already referenced`。
  关键验证或结论：Godot import 通过；Stage14 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `28 passed, 27 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Stage15 Boss 资产接入**：继续推进 P0 runtime replacement，把 Seal Guardian Boss 方向稿和攻击预警图接入正式 Boss 场景 / Boss 房。
  结果：`SealGuardianBoss` 新增 `SealGuardianArt` 与 `AttackWarningArt`，`Stage15SealGuardianBossRoom` 新增 `SealGuardianRoomArt` 与 `BossWarningRoomArt`；两个资产均为 `project_session_confirmed`；P0 replacement plan 推进到 `11 planned replacements, 17 already referenced`，P0 scene replacement batches 推进到 `33 planned scene-asset replacements, 22 already referenced`。
  关键验证或结论：Godot import 通过；Stage15 GUT `12/12` 通过；acceptance gates 的 `runtime_replacement` 推进到 `26 passed, 29 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Stage14 Air Dash 道具接入**：继续推进 P0 runtime replacement，把 Air Dash shrine / gate 两个静态道具接入正式 Stage14 房间。
  结果：`Stage14AirDashShrineRoom` 新增 `ShrineArt` 与 `GatePreviewArt`，`Stage14AirDashGateRoom` 新增 `ShrineEchoArt` 与 `GateArt`；两个资产均为 `project_session_confirmed`；P0 replacement plan 推进到 `13 planned replacements, 15 already referenced`，P0 scene replacement batches 推进到 `37 planned scene-asset replacements, 18 already referenced`。
  关键验证或结论：Godot import 通过；Stage14 GUT `10/10` 通过；acceptance gates 的 `runtime_replacement` 推进到 `24 passed, 31 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Stage16 corruption purge VFX 接入**：继续推进 Stage16 VFX runtime binding，把 `stage16_corruption_purge_ai01` 接入正式 purge 房间。
  结果：`Stage16CorruptionPurgeRoom` 的 `CorruptionMiasma` 新增 `PurgeArt`，直接引用 `assets/art/vfx/stage16_corruption_purge_ai01.png`；该资产的 `runtime_replacement` gate 已通过。
  关键验证或结论：Stage16 GUT `12/12` 通过；acceptance gates 的总体 `runtime_replacement` 刷新到 `22 passed, 33 blocked`，但 `stage16_corruption_purge_ai01` 仍保留 `workspace_provenance_recorded_review_required` 来源边界，整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Stage16 relay VFX 接入**：继续推进 `batch_06_stage16_chain`，把 `stage16_talisman_relay_ai01` 接入正式 Stage16 relay / purge 房间。
  结果：`Stage16TalismanRelayRoom` 三个 relay marker 新增 `RelayArt`，`Stage16CorruptionPurgeRoom` 的 purge node 新增 `TalismanRelayEchoArt`；P0 replacement plan 推进到 `15 planned replacements, 13 already referenced`，P0 scene replacement batches 推进到 `41 planned scene-asset replacements, 14 already referenced`。
  关键验证或结论：Godot import 通过；Stage16 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `13 passed, 42 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen 来源安全审计层**：针对多项目并行开发时全局 `generated_images` 可能混入其它项目 PNG 的风险，新增候选来源安全审计。
  结果：新增 `imagegen-source-safety-report.json`，把 `101` 个 raw candidates 分类为 `33` 个 project-session confirmed、`30` 个 ledger review-required、`38` 个 provenance review-required 和 `0` 个 unknown / unsafe；综合资产包审计纳入 `0 unsafe source candidates`。
  关键验证或结论：`audit_imagegen_source_safety.py --write-report --strict` 通过；`audit_asset_package.py --strict --write-report` 通过。该层只证明来源风险受控，不代表最终美术、授权或运行时接入完成。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen TutorialHUD HUD atlas 资源绑定**：继续推进 `batch_02_hud`，把 HUD core atlas 与 icon sheet 的 Godot `AtlasTexture` 资源纳入正式 HUD 场景引用。
  结果：`TutorialHUD/BattlePanel` 新增隐藏 `HudCoreAtlasPreview` 与 `IconSheetCorePreview`，分别引用 `hud_core_ui_atlas_ai01` 与 `icon_sheet_core_ai01` 的首个 `AtlasTexture`；P0 replacement plan 推进到 `16 planned replacements, 12 already referenced`。
  关键验证或结论：Stage12 GUT `9/9`、Stage14 GUT `9/9`、Stage15 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `12 passed, 43 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen TutorialHUD HUD frame 资源绑定**：继续推进 `batch_02_hud`，把 Stage14 ability status 与 Stage15 Boss HUD frame 资源纳入正式 HUD 场景引用。
  结果：`TutorialHUD/BattlePanel` 新增隐藏 `AbilityStatusFrameArt` 与 `BossHudFrameArt`，分别引用 `stage14_ability_status_hud_ai01.png` 与 `stage15_boss_hud_frame_ai01.png`；P0 replacement plan 推进到 `18 planned replacements, 10 already referenced`。
  关键验证或结论：Stage12 GUT `9/9`、Stage14 GUT `9/9`、Stage15 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `10 passed, 45 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen TutorialHUD P0 图标接入**：继续推进 `batch_02_hud`，把 Air Dash 与 Recovery Charge 图标接入正式 HUD。
  结果：`TutorialHUD/BattlePanel/DashIcon` 改为引用 `stage14_air_dash_icon_ai01.png` 的 `TextureRect`，新增 `RecoveryChargeIcon` 引用 `stage15_recovery_charge_icon_ai01.png`；P0 replacement plan 推进到 `20 planned replacements, 8 already referenced`。
  关键验证或结论：Stage12 GUT `9/9`、Stage14 GUT `9/9`、Stage15 GUT `11/11` 通过；acceptance gates 的 `runtime_replacement` 推进到 `8 passed, 47 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen Stage16 完成反馈资产接入**：继续推进 P0 runtime replacement，把 `stage16_alpha_demo_completion_ai01` 接入正式 Stage16 终点房。
  结果：`stage16_alpha_demo_end_room.tscn` 新增 `AlphaDemoCompletionArt`，直接引用 `assets/art/ui/stage16_alpha_demo_completion_ai01.png`；P0 replacement plan 推进到 `22 planned replacements, 6 already referenced`。
  关键验证或结论：Stage16 专项 GUT `10/10` 通过；P0 scene replacement batches 审计通过；acceptance gates 的 `runtime_replacement` 推进到 `6 passed, 49 blocked`，但整体 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

- **ImageGen DemoShell UI 壳纹理接入**：继续推进 `batch_01_ui_shell`，把 DemoShell 标题背景、菜单图标、暂停面板和完成面板候选接入正式 UI 场景。
  结果：`DemoShell` 新增 `TitleBackground`、`MainMenu/MenuIconStrip`、`PauseMenu/PausePanelArt` 和 `CompletionPanel/CompletionPanelArt`；综合资产包审计纳入 `5 runtime UI skin panels` 与 `4 runtime UI skin textures`。
  关键验证或结论：`audit_runtime_ui_skin_binding.gd` 输出 `2 scenes, 5 panels, 4 textures`；Stage16 专项 GUT `9/9` 通过；P0 replacement plan 推进到 `23 planned replacements, 5 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `5 passed, 50 blocked`，但 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`。

## 2026-06-20

- **ImageGen runtime UI skin binding**：将 UI skin 从 dev showcase / rehearsal 推进到正式 UI 场景引用。
  结果：`DemoShell` 与 `TutorialHUD` 根 Control 绑定 `nano_hunter_imagegen_ui.theme.tres`，`MainMenu`、`PauseMenu`、`PromptPanel` 与 `BattlePanel` 绑定 `menu_ninepatch_ui_ai01` 的 `StyleBoxTexture`；综合资产包审计纳入 `9 UI Theme mappings` 与 `4 runtime UI skin panels`。
  关键验证或结论：`audit_runtime_ui_skin_binding.gd` 输出 `2 scenes, 4 panels`；P0 replacement plan 推进到 `26 planned replacements, 2 already referenced`；acceptance gates 的 `runtime_replacement` 推进到 `2 passed, 53 blocked`，但 `final_ready` 仍为 `0/55`。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen P0 场景替换批次**：将 P0 target scene replacement matrix 拆成可逐批执行的替换顺序。
  结果：新增 `p0-scene-replacement-batches.json` 与 `p0-scene-replacement-batches.md`，覆盖 `9` 个替换批次、`13` 个目标场景、`28` 个唯一 P0 资产和 `55` 个 scene-asset references；综合资产包审计纳入 `9 P0 scene replacement batches`。
  关键验证或结论：批次审计通过，输出 `9 batches, 13 scenes, 28 assets, 55 scene-asset references`；该层只做执行顺序和验证范围规划，不修改正式 `.tscn`。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen P0 目标场景替换矩阵**：将 P0 runtime replacement plan 按目标场景聚合。
  结果：新增 `p0-target-scene-replacement-matrix.json` 与 `p0-target-scene-replacement-matrix.md`，覆盖 `13` 个目标场景、`28` 个唯一 P0 资产和 `55` 个 scene-asset references；综合资产包审计纳入 `13 P0 target scenes`。
  关键验证或结论：矩阵审计通过，输出 `13 scenes, 28 assets, 55 scene-asset references`；该层只做场景级替换排程，不修改正式 `.tscn`。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen P0 运行时替换排练场景**：将 P0 replacement plan 中的资源绑定到 Godot 兼容节点。
  结果：新增 `p0_runtime_replacement_rehearsal.tscn` 与 `p0-runtime-replacement-rehearsal-manifest.json`，覆盖 `28` 个 P0 resource-bound nodes；综合资产包审计纳入 `28 P0 runtime rehearsal nodes`。
  关键验证或结论：Godot build / audit 通过，输出 `P0 runtime replacement rehearsal OK: 28 nodes`；该场景是正式替换前排练，不修改目标 gameplay / HUD / room 场景引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen P0 运行时替换计划**：将 P0 runtime map 条目拆成目标场景、资源路径、替换模式和验证命令。
  结果：新增 `p0-runtime-replacement-plan.json` 与 `p0-runtime-replacement-plan.md`，覆盖 `28` 个 P0 runtime entries；`27` 个仍需手动替换，`1` 个已被 dev Gallery 引用；综合资产包审计纳入 `28 P0 runtime replacement-plan entries`。
  关键验证或结论：P0 replacement plan 初始审计通过，输出 `28 entries, 27 planned replacements, 1 already referenced`；后续 runtime UI skin binding 已推进到 `26 planned replacements, 2 already referenced`；该计划本身不自动修改正式场景引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen 最终美术验收门槛**：将 `55` 个结构可用资产拆成 7 道 final-ready gate。
  结果：新增 `final-art-acceptance-gates.json` 与 `final-art-acceptance-gates.md`，明确来源追踪、授权条款、Godot 结构资源、编辑器复核卡、运行时替换、资产族专项清稿和最终批准的通过 / 阻塞状态；综合资产包审计纳入 `55 final-art acceptance-gated assets`。
  关键验证或结论：Acceptance gates 审计通过，输出 `55 assets, 55 blocked assets, 0 final-ready assets`；当前只有结构 / 追踪 / 复核入口通过，授权、运行时替换和最终批准仍全部阻塞。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen 最终美术复核 Workbench**：将最终美术复核队列转成 Godot 编辑器可打开的审图工作台。
  结果：新增 `final_art_review_workbench.tscn` 与 `final-art-review-workbench-manifest.json`，按 priority / family 展示 `55` 个资产预览、blockers、next actions 和资源路径；综合资产包审计纳入 `55 final-art workbench cards`。
  关键验证或结论：Godot build / audit 通过，输出 `55 cards, 55 manual-review assets, 0 final-ready assets`；该层是编辑器复核入口，不代表最终美术或运行时替换完成。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen 最终美术复核队列**：将 `55` 个结构可用资产的 readiness blockers 转换为可逐项勾选的人工复核任务。
  结果：新增 `final-art-review-queue.json` 与 `final-art-review-queue.md`，按 family / priority / blocker / next action 记录每个资产的清稿、授权、运行时替换和 Godot 复核入口；综合资产包审计纳入 `55 final-art review entries`。
  关键验证或结论：`audit_final_art_review_queue.py --strict` 通过，输出 `55 assets, 55 manual-review entries, 0 final-ready assets`；`audit_asset_package.py --strict --write-report` 通过。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen 背景 alpha 策略**：为 `11` 个背景类 alpha 输出补齐策略记录和 opaque preview。
  结果：`background_asset_contains_alpha` warning 清零；tile / atlas 类保留 alpha padding 策略，promo / CG / storyboard 类生成 opaque preview；综合资产包审计纳入 `11 background alpha policies`。
  关键验证或结论：`audit_background_alpha_policy.py --strict` 通过；Art readiness 输出 `warnings_by_type={}`、`alpha_padding_policy_manual_review=5`、`opaque_preview_manual_review=6`；`audit_asset_package.py --strict --write-report` 通过。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

- **ImageGen 多项目导入安全修正**：修正全局 `.codex/generated_images` 在多项目并行时可能混入其它项目 PNG 的风险。
  结果：`scripts/assets/import_imagegen_outputs.py --copy-latest` 默认拒绝从全局 `generated_images` 直接复制最新图，必须改用明确 `--source`、明确 session JSONL 恢复、import map，或人工确认后加 `--allow-global-latest`；已删除本轮误导入的 5 个候选副本并记录边界。
  关键验证或结论：`python -m py_compile scripts\assets\import_imagegen_outputs.py` 通过；默认 `--copy-latest` 按预期拒绝全局最新图；显式 `--source --dry-run` 仍能规划目标路径且不复制。
  详情日志链接：`docs/progress/logs/2026-06-20.md`。

## 2026-06-19

- **完整资产补齐矩阵与图集化路线**：将资产生产线从 Batch 00-05 扩展到完整美术资产族与 Godot 图集化目标。
  结果：新增 `docs/assets/asset-completion-matrix.md`、`docs/assets/animation-frame-spec.md`、`docs/assets/image-gen-production-backlog.md`、`docs/assets/image-gen-prompt-library.md`、`docs/assets/image-gen-prompt-queue.json`、`docs/assets/image-gen-preview-log.md`、`docs/assets/godot-atlas-build-pipeline.md`、`docs/assets/asset-atlas-build-manifest.json`、`scripts/assets/build_asset_atlases.py`、`scripts/assets/import_imagegen_outputs.py`、`scripts/assets/validate_asset_production_queue.py`、`scripts/assets/export_imagegen_batch_plan.py`、`docs/implementation-plans/2026-06-19-full-asset-completion-and-atlas-plan.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-00-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-07-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-08-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-09-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-10-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-11-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-12-production-packet.md`、`docs/implementation-plans/2026-06-19-imagegen-batch-13-production-packet.md`，扩展 `asset-production-roadmap.md` 与 `asset-manifest.md` 到 Batch 06-13，并新增 Sprite Sheet、Texture Atlas、Tile Set、Spine 拆件、UI 图集、VFX 图集、贴图、宣传和分镜目录骨架；主角 Luna 动作升级为高帧数规格。
  关键验证或结论：prompt queue 已扩展到 33 个具体 image gen 任务和 23 个 atlas-linked 输出，Batch00 / Batch01 / Batch06 / Batch07 / Batch08 / Batch09 / Batch10 / Batch11 / Batch12 / Batch13 已导出 production packet；内置 `image_gen` 已生成 Batch00 `1/1`、Batch01 `8/8`、Batch06 `5/5`、Batch07 `3/3`、Batch08 `3/3`、Batch09 `2/2`、Batch10 `2/2`、Batch11 `2/2`、Batch12 `4/4` 与 Batch13 `3/3` 会话预览并记录 preview log，当前 queue `33/33` 条目已有预览记录；`import_imagegen_outputs.py` 已支持 `--include-inbox` 扫描 `assets/source/imagegen_inbox/` 手动保存落点，并支持 `--magic-scan` 按文件头排查无扩展名缓存；当前默认目录、inbox、Temp 和 Codex home 均未发现本轮可复制 PNG，当前改动不声称正式资产已落盘或接入。
  详情日志链接：`docs/progress/logs/2026-06-19.md`。

## 2026-03-31

- **仓库治理基线**：建立 Godot 4.6 原型仓库治理基线。
  结果：明确 `spec-design/`、`docs/progress/`、`plan/` 与 GUT 测试方向。
  详情：`docs/progress/logs/2026-03-31.md`。

## 2026-04-01

- **Stage1 启动骨架**：完成 `Main.tscn`、测试房间、相机、基础碰撞和首批 GUT。
  结果：项目进入可启动原型状态。
  详情：`docs/progress/logs/2026-04-01.md`。

## 2026-04-06

- **分支 / worktree 规则雏形**：建立分支与 worktree 使用规则。
  结果：确认主工作区保留稳定基线。
  详情：`docs/progress/logs/2026-04-06.md`。

## 2026-04-10

- **阶段推进节奏调整**：强化“设计、实现、验证、留痕”闭环。
  结果：阶段开发流程从经验约定转为可追踪规则。
  详情：`docs/progress/logs/2026-04-10.md`。

## 2026-04-11

- **早期治理整理**：继续整理项目治理、阶段文档和验证命令记录。
  结果：早期原型流程留痕更完整。
  详情：`docs/progress/logs/2026-04-11.md`。

## 2026-04-20

- **Stage5 后续准备**：更新早期原型推进记录。
  结果：为 Stage5 后续可试玩切片做准备。
  详情：`docs/progress/logs/2026-04-20.md`。

## 2026-04-21

- **Stage5 教程切片推进**：推进教程垂直切片与早期 HUD / 房间链路验证。
  结果：教程区短流程进入可验证状态。
  详情：`docs/progress/logs/2026-04-21.md`。

## 2026-04-22

- **Stage5-Stage6 前置验证**：补强阶段前置验证和进度文档。
  结果：继续收敛原型期流程。
  详情：`docs/progress/logs/2026-04-22.md`。

## 2026-04-23

- **Stage5-Stage8 收口**：Stage5 教程垂直切片完成，随后完成 Stage6 最小真实战斗循环、Stage7 短链路主流程串联与 Stage8 系统稳固 / 内容生产前准备。
  结果：项目从早期手感验证推进到内容生产前准备。
  详情：`docs/progress/logs/2026-04-23.md`。

## 2026-04-24

- **Stage9-Stage11 内容推进**：完成首个小区域内容生产、战斗变化与轻量成长循环、可交付试玩 Demo 切片的主要实现与验证。
  结果：第一版可交付试玩 Demo 切片形成。
  详情：`docs/progress/logs/2026-04-24.md`。

## 2026-04-25

- **Stage12-Stage16 路线规划**：规划更大颗粒度路线，开始 Stage12 资产管线与第一轮 Demo 表现升级。
  结果：后续 Alpha Demo 候选路线明确。
  详情：`docs/progress/logs/2026-04-25.md`。

## 2026-04-26

- **Stage12-Stage13 推进**：Stage12 收口并合并，Stage13 第二小区域内容生产完成主要实现与验证。
  结果：Demo 表现升级与第二小区域内容形成阶段基线。
  详情：`docs/progress/logs/2026-04-26.md`。

## 2026-04-27

- **Stage14 稳定基线**：完成回溯与能力门控成型。
  结果：新增 `Air Dash / 空中二段冲刺`、能力门、回溯链路与 `3` 个回溯收益点。
  详情：`docs/progress/logs/2026-04-27.md`。

- **Stage15 主体启动**：启动战斗高潮与首个精英 Boss 原型。
  结果：实现 Seal Guardian、Recovery Charge、Stage15 房间链路、HUD 与专项测试主体内容。
  详情：`docs/progress/logs/2026-04-27.md`。

- **客户端 / 插件治理整理**：整理客户端 / CLI、Godot MCP 和插件治理文档。
  结果：降低 AGENTS 对单一客户端实现的绑定。
  详情：`docs/progress/logs/2026-04-27.md`。

## 2026-04-28

- **Stage15 运行态复核与修复**：完成 Godot MCP 运行态人工复核，并修复 completion room HUD 问题。
  结果：完成房不再显示旧主目标、恢复充能或旧收集行；补入回归测试。
  详情：`docs/progress/logs/2026-04-28.md`。

- **Stage15 QA 收口**：发现并修复混合遭遇和挑战支线可绕过问题。
  结果：补全清门控、挑战支线出口门和回归测试；Stage15 分支合并回 `main`。
  验证：Godot import、Stage15 专项 GUT `11/11`、全量 GUT `107/107`、`git diff --check HEAD` 和乱码扫描通过。
  详情：`docs/progress/logs/2026-04-28.md`。

- **进度文档治理初步调整**：日日志迁入 `docs/progress/logs/`，MCP 截图改为 `tests/artifacts/local/` 本地证据产物。
  结果：降低 `status.md` 与 `timeline.md` 的重复度。
  详情：`docs/progress/logs/2026-04-28.md`。

## 2026-04-29

- **Stage12-13 北极星回收修正**：创建并完成 `codex/north-star-realign-stage12-13`。
  结果：将现代实验室 / 生物废液表达回收到山门古刹、镇妖试炼场、瘴泽妖域、符印封印机关和瘴气妖术投射者。
  验证：Godot MCP 人工复核完成，分支合并到 `main` 并推送 `origin/main`。
  详情：`docs/progress/logs/2026-04-29.md`。

- **Stage16 Alpha Demo 候选**：从固定永久工作树创建 `codex/stage-16-alpha-demo-candidate` 并完成主体实现。
  结果：五房终局封印链、Stage15 completion 接入、最小 Demo 壳、Main / HUD Stage16 完成态、Stage16 专项 GUT、Alpha Demo 灰盒 driver、`docs/deliverables/stage16-alpha-demo-candidate/` 交付物与资产 / 音频 manifest 条目完成。
  验证：Godot MCP 运行态复核覆盖主菜单、暂停 / 继续 / 重开、Stage15 completion、Stage16 五房运行态节点、导出 next-room 链路与 Alpha Demo 终点。
  详情：`docs/progress/logs/2026-04-29.md`。

- **Stage16 合并基线**：Stage16 Alpha Demo 打包候选合并回 `main`。
  结果：`main` 成为 Stage16 Alpha Demo 候选稳定基线。
  验证：Godot import、Stage16 专项 GUT `8/8`、Stage15 专项 GUT `11/11`、全量 GUT `115/115`、`git diff --check HEAD` 通过。
  详情：`docs/progress/logs/2026-04-29.md`。

## 2026-04-30

- **Godot MCP bridge lifecycle hardening**：启动并完成工具链修复分支 `codex/fix-godot-mcp-bridge-lifecycle` 的第一轮 hardening。
  结果：扩展 stdio bridge 端口规划，保留 `godot-cli` 端口，新增 bridge lock/heartbeat、workspace handshake、lazy reconnect、诊断脚本和插件升级后可重放补丁源。
  验证：Node `npm test` / `npm run build`、Godot import、诊断脚本 dry-run、补丁脚本 dry-run 和 `git diff --check` 通过。
  提交：`ddaad7d`。
  遗留：该阶段不等于完整根治，Godot 插件仍可能优先连接旧低端口 bridge。
  详情：`docs/progress/logs/2026-04-30.md`。

- **Godot MCP 通用补丁工具**：将 hardening 补丁脚本通用化为可搬移、可跨项目使用的工具。
  结果：默认只覆盖全局 Node server 与目标项目 `addons/godot_mcp`；项目诊断脚本改为 `-IncludeProjectScripts` 可选项。
  验证：补丁脚本 dry-run 矩阵、外部 Node server 构建测试、Godot import、诊断脚本和乱码扫描通过。
  提交：`fd7638f`。
  详情：`docs/progress/logs/2026-04-30.md`。

- **Godot MCP 文档入口收敛**：将脚本速查与排障流程合并进 `docs/dev/godot-mcp-pro-connectivity-guide.md`。
  结果：connectivity guide 成为唯一权威入口，`AGENTS.md` 只保留项目级原则和指针。
  验证：旧引用扫描和 `git diff --check` 通过。
  提交：`a41ea03`。
  详情：`docs/progress/logs/2026-04-30.md`。

- **Godot MCP hardening 复核修正**：人工复核确认当前方案仍缺 session/port rendezvous。
  结果：文档状态修正为“hardening 已完成，完整根治未完成”；后续需新增独立 rendezvous 计划。
  关键证据：当前会话工具入口存在，但 MCP 只读工具返回 Godot editor 未连接；Godot editor 可被旧 `6505` bridge 抢先连接。
  详情：`docs/progress/logs/2026-04-30.md`。

## 2026-05-01

- **Godot MCP 端口迁移与 rendezvous 根治**：在 `codex/fix-godot-mcp-bridge-lifecycle` 上继续工具链根治。
  结果：stdio 主端口迁移到 `17605-17619`，CLI 主端口迁移到 `17620-17624`，旧 `6505-6509` / `6510-6514` 降级为 legacy；Node 写项目本地 rendezvous，Godot 插件优先连接当前会话指定端口。
  关键验证：外部 Node server `npm test` / `npm run build` 通过；完整 Godot 与脚本验证见当日日志。
  详情：`docs/progress/logs/2026-05-01.md`。

## 2026-05-13

- **Godot MCP Pro 1.13.1 增量合并**：启动 `codex/upgrade-godot-mcp-1-13-1-increments`，审查并吸收 1.13.1 可用增量。
  结果：保留 `17605-17619` / `17620-17624`、rendezvous、workspace/session 握手和 diagnostic tools，同时合入 ping/pong、heartbeat timeout、idle/stale UI 与输入 `unhandled=false` 修正。
  关键验证：外部 Node server `npm test` / `npm run build`、补丁脚本 dry-run、MCP 诊断脚本、入口脚本 dry-run、Godot import 和 `git diff --check` 通过。
  详情：`docs/progress/logs/2026-05-13.md`。

## 2026-05-14

- **资产生产线治理落地**：建立 Asset Production Track 文档基线。
  结果：新增 `asset-storage-policy.md` 与 `asset-production-roadmap.md`，补强资产生成 brief、manifest、接入 checklist、`.gitignore` 与 `AGENTS.md`。
  目标范围：Batch 00-05 的资产生产、存储、工具分工、授权记录和后续 Stage 补充规则。
  详情：`docs/progress/logs/2026-05-14.md`。

## 2026-05-22

- **资产生产线治理合并**：按用户要求合并并推送除 Luna 行走关键帧生成内容外的其它主线内容。
  结果：`codex/asset-production-track-governance` 合并到 `main`；Luna 行走关键帧目录、5 月 5 日日志和对应 manifest 行保留为本地未提交内容。
  详情：`docs/progress/logs/2026-05-22.md`。

## 2026-06-19

- **ImageGen 会话 PNG 恢复落盘**：按用户提供的 `Export-CodexImageGenResults.ps1` 思路，从当前 Codex session JSONL 的 `image_generation_call.result` 恢复 Nano Hunter 本轮生成图。
  结果：Batch00 / Batch01 / Batch06-Batch13 共 `33/33` 个原始候选 PNG 已写入 `assets/source/ai_generated/batch_XX/<asset_id>/candidates/`；源候选按资产存储策略默认不进入普通 Git。
  关键验证或结论：Pillow 成功打开并读取 `33` 个 PNG 尺寸；当前仍不是正式 `assets/art/` 可运行资产，后续需清稿、切片、图集化和 Godot 导入验证。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **第一版 Godot 候选图集生成**：新增 raw candidate 自动拆分脚本和 standalone 导出脚本，并把恢复出的 image gen 候选推进到 `assets/art/` 可导入候选。
  结果：生成 `33` 张候选 PNG、`23` 个 frames / regions JSON、`7` 个 `SpriteFrames` `.tres`，覆盖 Sprite Sheet、Texture Atlas、TileSet sheet、Spine 拆件图集、UI 图集、VFX 图集、九宫格 sheet、宣传图、LOGO 方向、分镜图和 Batch01 P0 单体方向稿。
  关键验证或结论：`prepare_selected_sources.py --overwrite`、`export_standalone_candidates.py --overwrite`、`build_asset_atlases.py --dry-run --strict`、`build_asset_atlases.py` 和 `godot --headless --path . --import` 通过；当前仍是 provisional first pass，未达到 `expected_target`，未接入玩法。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **Batch02 Stage16 UI 与终局反馈候选补齐**：把 Stage16 标题背景、菜单图标、终局封印、relay / purge VFX 和 Alpha Demo completion UI 加入 prompt queue 并生成候选。
  结果：queue 从 `33` 项扩展为 `39` 项；新增 `6` 张 Batch02 standalone PNG，`assets/art/**/*.png` 总数推进到 `39`。
  关键验证或结论：`validate_asset_production_queue.py` 通过：`39` items、`23` atlas-linked outputs；`export_standalone_candidates.py --overwrite` 和 `godot --headless --path . --import` 通过。当前状态为 `placeholder_ready`，仍未接入 Stage16 UI / 完成反馈。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **Batch03 区域表现候选落盘**：为 `biome_01_shrine_trial` 与 `biome_02_miasma_marsh` 生成 tile / background 候选，并补充 reusable seal props。
  结果：queue 从 `39` 项扩展为 `44` 项；新增 `5` 张 Batch03 standalone PNG，`assets/art/**/*.png` 总数推进到 `44`。
  关键验证或结论：`validate_asset_production_queue.py` 通过：`44` items、`23` atlas-linked outputs；`export_standalone_candidates.py --overwrite` 和 `godot --headless --path . --import` 通过。当前状态为 `placeholder_ready`，仍未切片为正式 TileSet 或替换场景背景 / props。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **Batch06 supplemental 动画覆盖补齐**：补齐 Luna jump/fall、Luna hit/death 与 core enemies 三组角色 / 敌人动画候选。
  结果：queue 从 `44` 项扩展为 `47` 项；新增 `3` 张 Batch06 supplemental Sprite Sheet、`3` 个 frames JSON、`3` 个 SpriteFrames，`assets/art/**/*.png` 总数推进到 `47`。
  关键验证或结论：`validate_asset_production_queue.py` 通过：`47` items、`26` atlas-linked outputs；三组 `prepare_selected_sources.py --only <asset_id> --overwrite` 均拆出 `16/16` selected frames；三组 `build_asset_atlases.py --only <asset_id>` 均成功；`godot --headless --path . --import` 通过。当前状态为 `placeholder_ready`，仍未替换运行时动画。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **Batch03 supplemental 房间背景补齐**：补齐 shrine trial room、Air Dash shrine room、miasma hazard room 与 Seal Guardian boss room 四张具体房间 / 视差源图。
  结果：queue 从 `47` 项扩展为 `51` 项；新增 `4` 张 Batch03 supplemental standalone PNG，`assets/art/**/*.png` 总数推进到 `51`。
  关键验证或结论：`validate_asset_production_queue.py` 通过：`51` items、`26` atlas-linked outputs；四组 `export_standalone_candidates.py --only <asset_id> --overwrite` 成功；`godot --headless --path . --import` 通过。当前状态为 `placeholder_ready`，仍未替换场景引用或配置视差层。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **Batch08 supplemental UI 面板补齐**：补齐 Stage16 pause / completion panel、Stage15 Boss HUD frame 与 Stage14 ability status HUD 四张 UI 候选。
  结果：queue 从 `51` 项扩展为 `55` 项；新增 `4` 张 Batch08 supplemental standalone PNG，`assets/art/**/*.png` 总数推进到 `55`。
  关键验证或结论：`validate_asset_production_queue.py` 通过：`55` items、`26` atlas-linked outputs；四组 `export_standalone_candidates.py --only <asset_id> --overwrite` 成功；`godot --headless --path . --import` 通过；透明度检查确认四张图角落 alpha 为 `0` 且无不透明绿幕像素。当前状态为 `placeholder_ready`，仍未替换 DemoShell / Boss HUD / ability HUD。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；恢复记录：`docs/assets/image-gen-session-recovery-log.md`。

- **ImageGen target-count 图集重建**：把已落盘 image gen 候选从 minimum first pass 推进到 target-count editor-ready rebuild。
  结果：`26/26` 个 atlas-linked outputs 达到 `expected_target`；selected source 变为 `selected_frames=236`、`selected_items=122`、`selected_tiles=96`、`selected_parts=48`、`selected_panels=36`；`assets/art/**/*.png` 保持 `55` 张，metadata JSON 为 `26` 个，`.spriteframes.tres` 为 `10` 个。
  关键验证或结论：`prepare_selected_sources.py --target target --overwrite`、`build_asset_atlases.py --dry-run --strict`、`build_asset_atlases.py`、`audit_asset_target_coverage.py --strict` 与 `godot --headless --path . --import` 通过。当前状态仍为 `placeholder_ready`，未替换运行时引用；部分动画、VFX、prop / equipment、icon 和 NinePatch 输出仍含 duplicate 补位。
  详情日志链接：`docs/progress/logs/2026-06-19.md`；实施计划：`docs/implementation-plans/2026-06-19-imagegen-target-count-atlas-rebuild.md`。

## 2026-06-20

- **ImageGen runtime asset catalog**：把 runtime map 中的 `55` 个资产生成 Godot `ResourcePreloader` 目录场景。
  结果：新增 `scripts/dev/build_imagegen_runtime_asset_catalog.gd`、`scripts/dev/audit_imagegen_runtime_asset_catalog.gd`、`scenes/dev/imagegen_runtime_asset_catalog.tscn`、`docs/assets/imagegen-runtime-asset-catalog-manifest.json` 和对应实施计划；readiness / package audit 纳入 runtime catalog。
  关键验证或结论：Godot catalog build / audit 均输出 `55 resources`；Art readiness 中 `runtime_catalog_ready_manual_replacement=55`；综合审计输出 `55 runtime catalog resources`。当前仍需正式替换运行时引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-runtime-asset-catalog.md`。

- **Asset runtime integration map**：为当前 image gen 资产包生成运行时 / 发布接入映射。
  结果：新增 `scripts/assets/build_asset_runtime_map.py`、`scripts/assets/audit_asset_runtime_map.py`、`docs/assets/asset-runtime-integration-map.json` 和对应实施计划；readiness / package audit 纳入 runtime map。
  关键验证或结论：runtime map 审计输出 `55 entries, 9 tracks`；Art readiness 中 `runtime_reference_not_replaced=0`、`runtime_binding_map_ready_manual_replacement=55`；综合审计输出 `55 runtime map entries`。当前仍需按 Stage polish 人工替换场景引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-asset-runtime-integration-map.md`。

- **Asset provenance records**：为当前 image gen 资产包生成来源、prompt 和 hash 追踪记录。
  结果：新增 `scripts/assets/build_asset_provenance.py`、`scripts/assets/audit_asset_provenance.py`、`docs/assets/asset-provenance-records.json` 和对应实施计划；readiness / package audit 纳入 provenance。
  关键验证或结论：provenance 审计输出 `55 records, 120 candidate hashes, 55 output hashes`；Art readiness 中授权 blocker 从 `license_record_pending` 推进为 `license_terms_manual_review`；综合审计输出 `55 provenance records`。当前仍需商业条款人工复核。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-asset-provenance-records.md`。

- **ImageGen candidate review gallery**：把未进入 selected source 的 raw candidates 生成 Godot 编辑器评审场景。
  结果：新增 `scripts/dev/build_imagegen_candidate_review_gallery.gd`、`scripts/dev/audit_imagegen_candidate_review_gallery.gd`、`scenes/dev/imagegen_candidate_review_gallery.tscn`、`docs/assets/imagegen-candidate-review-gallery-manifest.json` 和对应实施计划；综合资产包审计纳入 candidate review gallery。
  关键验证或结论：Godot 审计输出 `72 candidates, 53 assets`；综合审计输出 `72 unselected candidates, 72 candidate review cards`。当前仍是人工分拣入口，不代表 atlas 重建、最终清稿或运行时接入。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-candidate-review-gallery.md`。

- **ImageGen candidate pool audit layer**：新增 raw candidate / selected source 使用关系审计，避免新增 PNG 落盘后被误判为已进入图集或最终资产。
  结果：新增 `scripts/assets/audit_imagegen_candidate_pool.py`、`docs/assets/imagegen-candidate-pool-report.json` 和 `docs/implementation-plans/2026-06-20-imagegen-candidate-pool-audit.md`；综合资产包审计纳入 candidate pool 证据。
  关键验证或结论：`python scripts\assets\audit_imagegen_candidate_pool.py --strict --write-report` 通过，当前记录 `101` raw candidates、`538` selected sources、`72` unselected candidates、`53` review-required assets；`audit_asset_package.py --strict --write-report` 同步输出 `72 unselected candidates`。当前仍不自动重建 `assets/art` 或替换运行时引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-candidate-pool-audit.md`。

- **ImageGen asset semantic label pass**：为 atlas-linked outputs 与 standalone menu icon sheet 生成 first-pass 语义标签。
  结果：新增 `scripts/assets/build_asset_semantics.py`、`scripts/assets/audit_asset_semantics.py`、`docs/assets/asset-semantics-index.json`、`assets/art/**/*.semantics.json`、`assets/art/ui/stage16_demo_menu_icons_ai01.semantics.json` 和 `docs/implementation-plans/2026-06-20-asset-semantic-label-pass.md`。
  关键验证或结论：`python scripts\assets\audit_asset_semantics.py --strict` 输出 `Asset semantics OK: 26 assets, 538/538 semantic entries.`；综合资产包审计输出 `544 semantic labels`。当前仍是 first-pass machine semantic labels，需人工复核。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-asset-semantic-label-pass.md`。

- **ImageGen art readiness audit**：新增美术接入就绪审计层，把结构性资产补齐和最终美术完成分开记录。
  结果：新增 `scripts/assets/audit_art_readiness.py`、`docs/assets/art-readiness-audit-report.json` 和 `docs/implementation-plans/2026-06-20-art-readiness-audit.md`；扩展 `scripts/assets/audit_asset_package.py` 纳入 readiness 报告；扩展 `scripts/assets/export_standalone_candidates.py` 支持绿色 / 洋红 chroma key，并重导出 `stage15_seal_guardian_ai01` 为带 alpha PNG。
  关键验证或结论：`python scripts\assets\audit_art_readiness.py --strict --write-report` 输出 `55/55 structural ready, 0/55 final ready`；`python scripts\assets\audit_asset_package.py --strict --write-report` 输出 `55 art-ready structures`。当前仍未完成最终清稿、授权和运行时替换。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-art-readiness-audit.md`。

- **ImageGen duplicate reduction pass 01**：确认本会话内置 `image_gen` 的默认生成目录可直接作为复制来源，并把补充候选纳入项目资产管线。
  结果：复制补充 PNG 到 `assets/source/ai_generated/.../candidates/`；`prepare_selected_sources.py` 支持多 `candidate_XX` 合并抽取；重建全部曾含 duplicate 的 atlas-linked 输出。
  关键验证或结论：`audit_asset_target_coverage.py --strict` 通过；`26/26` 个 atlas-linked outputs 当前全部为 `duplicates=0`。当前仍是 `placeholder_ready`，未接入运行时引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-duplicate-reduction-pass-01.md`。

- **Godot 编辑器 AtlasTexture 资源层**：把非 SpriteFrames atlas-linked outputs 拆成 Godot 可加载的单 region 资源。
  结果：新增 `scripts/assets/build_editor_atlas_textures.py`、`scripts/assets/audit_editor_atlas_textures.py` 和 `scripts/dev/audit_editor_atlas_textures.gd`；生成 `302` 个 `AtlasTexture` `.tres`，索引为 `assets/art/editor_resources/editor_atlas_textures.index.json`。
  关键验证或结论：`audit_editor_atlas_textures.py --strict` 通过；`godot --headless --path . --script res://scripts/dev/audit_editor_atlas_textures.gd` 输出 `Editor AtlasTexture resources OK: 302`；`godot --headless --path . --import` 通过。当前仍需正式 TileSet collision、NinePatch margins、VFX anchors 和运行时引用接入。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-editor-atlastexture-resource-layer.md`。

- **Godot 编辑器 TileSet 资源层**：把 Batch07 两个 `tileset_sheet` 转成 Godot 可加载的 `TileSet` 候选资源。
  结果：新增 `scripts/dev/build_editor_tilesets.gd` 与 `scripts/dev/audit_editor_tilesets.gd`；生成 `assets/art/tilesets/editor_tilesets/miasma_marsh_tileset_ai01.tileset.tres`、`assets/art/tilesets/editor_tilesets/shrine_trial_tileset_ai01.tileset.tres` 和对应 `.tileset_rules.json`。
  关键验证或结论：`godot --headless --path . --script res://scripts/dev/build_editor_tilesets.gd` 输出 `Editor TileSet resources built: 2`；`godot --headless --path . --script res://scripts/dev/audit_editor_tilesets.gd` 输出 `Editor TileSet resources OK: 2`；综合审计记录 `96` 个 tile rules、`64` 个 collision-ready tiles、`8` 个 hazard visual-only tiles。当前仍未配置 autotile、navigation、正式 hazard Area 或运行时 TileMap 引用。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-editor-tileset-resource-layer.md`、`docs/implementation-plans/2026-06-20-editor-tileset-collision-rules.md`。

- **Godot 编辑器 StyleBoxTexture 资源层**：把 Batch08 `menu_ninepatch_ui_ai01` 的九宫格 region 转成 Godot 可加载的 UI 样式候选资源。
  结果：新增 `scripts/dev/build_editor_styleboxes.gd` 与 `scripts/dev/audit_editor_styleboxes.gd`；生成 `assets/art/ui/styleboxes/menu_ninepatch_ui_ai01/` 下 `8` 个 `.stylebox_texture.tres` 和索引 JSON。
  关键验证或结论：`godot --headless --path . --script res://scripts/dev/build_editor_styleboxes.gd` 输出 `Editor StyleBoxTexture resources built: 8`；`godot --headless --path . --script res://scripts/dev/audit_editor_styleboxes.gd` 输出 `Editor StyleBoxTexture resources OK: 8`。当前仍未接入 Theme、运行时 UI、文字安全区或拉伸复核。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-editor-stylebox-resource-layer.md`。

- **Godot 编辑器 UI skin / Theme 规则层**：把 Batch08 `menu_ninepatch_ui_ai01` 的 StyleBox 候选继续映射到 Godot `Theme` 候选，并为 standalone UI / HUD 图生成 text-safe area 规则。
  结果：新增 `scripts/dev/build_editor_ui_skin.gd` 与 `scripts/dev/audit_editor_ui_skin.gd`；生成 `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.theme.tres` 和 `assets/art/ui/editor_ui_skin/nano_hunter_imagegen_ui.rules.json`；初始综合资产包审计新增 `8` 个 UI Theme mappings 和 `4` 个 standalone UI skin panel rules，后续 runtime UI skin binding 已推进到 `9` 个 UI Theme mappings 和 `4` 个 runtime UI skin panels。
  关键验证或结论：初始 `audit_editor_ui_skin.gd` 输出 `Editor UI skin OK: 8 style mappings, 4 standalone panels`；后续已更新为 `9 style mappings` 并接入 DemoShell / TutorialHUD；`python scripts\assets\audit_art_readiness.py --strict --write-report` 保持 `55/55 structural ready, 0/55 final ready`。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-editor-ui-skin-rules.md`。

- **VFX anchor / blend rules layer**：为 Batch10 VFX atlas 和 standalone VFX PNG 生成 first-pass anchor / blend / collision boundary rules。
  结果：新增 `scripts/assets/build_vfx_rules.py` 与 `scripts/assets/audit_vfx_rules.py`；生成 `assets/art/vfx/vfx_rules/` 下 `6` 个 VFX rule sidecars 和 `vfx_rules.index.json`；综合资产包审计新增 `68` 条 VFX rules。
  关键验证或结论：`python scripts\assets\audit_vfx_rules.py --strict` 输出 `VFX rules OK: 6 assets, 68 frame rules, 68 collision-disabled rules.`；所有规则均显式 `gameplay_collision=false` 和 `damage_source=false`；Godot import、Gallery 与 Integration Showcase 审计继续通过。当前仍未替换运行时 VFX 或 author 真实伤害判定。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-vfx-anchor-rules.md`。

- **Character animation rules layer**：为 Luna、Seal Guardian 和 core enemies 的 Sprite Sheet 生成 first-pass clip / timing / pivot / baseline rules。
  结果：新增 `scripts/assets/build_animation_rules.py` 与 `scripts/assets/audit_animation_rules.py`；生成 `assets/art/characters/animation_rules/` 下 `8` 个 animation rule sidecars 和 `animation_rules.index.json`；综合资产包审计新增 `172` 条 animation rules。
  关键验证或结论：`python scripts\assets\audit_animation_rules.py --strict` 输出 `Animation rules OK: 8 assets, 172 frame rules.`；Godot import、Gallery 与 Integration Showcase 审计继续通过。当前仍未确认最终帧序、脚底基线、碰撞盒读值或运行时动画替换。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-character-animation-rules.md`。

- **Spine-style 拆件导出层**：把 Batch11 Luna / Seal Guardian 拆件图集转成可交接的 `.atlas`、`.spine_style.json` 和 cutout manifest。
  结果：新增 `scripts/assets/build_spine_cutout_manifests.py` 与 `scripts/assets/audit_spine_cutout_manifests.py`；生成 `assets/art/spine_parts/spine_exports/` 下 `2` 个 asset exports、`48` 个 part descriptors。
  关键验证或结论：`python scripts\assets\build_spine_cutout_manifests.py --dry-run` 计划 `2` assets / `48` parts；`python scripts\assets\audit_spine_cutout_manifests.py --strict` 输出 `Audited 2 Spine-style cutout exports with 48 parts.`。当前仍不是正式 Spine rig 或运行时骨骼动画。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-spine-cutout-export-layer.md`。

- **资产包综合审计层**：把本轮 image gen 资产包、atlas 输出和 editor resources 汇总为结构化审计报告。
  结果：新增 `scripts/assets/audit_asset_package.py`；生成 `docs/assets/asset-package-audit-report.json`。
  关键验证或结论：`python scripts\assets\audit_asset_package.py --strict --write-report` 通过；报告 `ok=true`，覆盖 `55` queue items、`101` candidate PNGs、`72` unselected raw candidates、`26` atlas-linked outputs、`302` AtlasTextures、`2` TileSets、`8` StyleBoxes 和 `48` spine parts。当前仍是结构性审计，不证明最终美术、授权或运行时集成。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-asset-package-audit-layer.md`。

- **Godot ImageGen Asset Gallery**：把当前 image gen 资产包整理为 Godot 编辑器内可打开的集中预览场景。
  结果：新增 `scripts/dev/build_imagegen_asset_gallery.gd`、`scripts/dev/audit_imagegen_asset_gallery.gd`、`scripts/dev/capture_imagegen_asset_gallery.gd`、`scenes/dev/imagegen_asset_gallery.tscn` 和 `docs/assets/imagegen-asset-gallery-manifest.json`；综合审计报告同步纳入 Gallery scene / manifest。
  关键验证或结论：`godot --headless --path . --script res://scripts/dev/build_imagegen_asset_gallery.gd` 写入场景和 manifest；`godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_gallery.gd` 输出 `Imagegen asset gallery OK: res://scenes/dev/imagegen_asset_gallery.tscn`，并实际检查 `361` 个普通纹理预览和 `8` 个 `StyleBoxTexture` 预览的资源加载与绑定；`godot --rendering-driver opengl3 --path . --script res://scripts/dev/capture_imagegen_asset_gallery.gd` 写出本地截图和 `ok=true` 采样报告。当前仍是预览验收入口，不证明运行时接入。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-asset-gallery-preview.md`。

- **Godot ImageGen Asset Integration Showcase**：把当前 image gen 资产包继续整理为节点级接入演示场景。
  结果：新增 `scripts/dev/build_imagegen_asset_integration_showcase.gd`、`scripts/dev/audit_imagegen_asset_integration_showcase.gd`、`scenes/dev/imagegen_asset_integration_showcase.tscn` 和 `docs/assets/imagegen-asset-integration-showcase-manifest.json`。
  关键验证或结论：`godot --headless --path . --script res://scripts/dev/build_imagegen_asset_integration_showcase.gd` 写入场景和 manifest；`godot --headless --path . --script res://scripts/dev/audit_imagegen_asset_integration_showcase.gd` 输出 `Imagegen asset integration showcase OK: res://scenes/dev/imagegen_asset_integration_showcase.tscn`。manifest 记录 `10` 个 `AnimatedSprite2D`、`2` 个 `TileMapLayer`、`4` 个 `PanelContainer` 和 `8` 个 `Sprite2D`，当前只证明 Godot 节点可消费资源，不证明正式 runtime 引用替换。
  详情日志链接：`docs/progress/logs/2026-06-20.md`；实施计划：`docs/implementation-plans/2026-06-20-imagegen-asset-integration-showcase.md`。

## 2026-06-21

- **Final-ready mini pack 03**：第三批 runtime prop 与内部风格参考完成 finalization review。
  结果：扩展 `docs/assets/asset-finalization-review-records.json` 与 `.md`；`stage14_air_dash_shrine_ai01`、`stage14_air_dash_gate_ai01`、`stage16_seal_release_threshold_ai01`、`style_board_global_ai01` 进入 `final_ready`；final-art queue 刷新为 `43` 个 manual-review entries、`12` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 12/55 final ready`；final acceptance gates `43 blocked assets, 12 final-ready assets`；family coverage `10/10 families, 7/7 Godot formats, 12 final-ready`；prop 图经像素检查确认绿色背景为 alpha=0，不是不透明绿底。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；复核记录：`docs/assets/asset-finalization-review-records.md`。

- **P0 final-ready mini pack 02**：第二批 P0 / Stage16 runtime 方向稿与反馈图完成 finalization review。
  结果：扩展 `docs/assets/asset-finalization-review-records.json` 与 `.md`；`stage15_seal_guardian_ai01`、`stage16_luna_player_readability_ai01`、`stage16_alpha_demo_completion_ai01`、`stage16_title_background_ai01` 进入 `final_ready`；final-art queue 刷新为 `47` 个 manual-review entries、`8` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 8/55 final ready`；final acceptance gates `47 blocked assets, 8 final-ready assets`；final art workbench 已重建；family coverage `10/10 families, 7/7 Godot formats, 8 final-ready`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；复核记录：`docs/assets/asset-finalization-review-records.md`。

- **P0 final-ready mini pack 01**：首批 P0 runtime 单体资产完成 finalization review，并从 structural-ready 推进为 final-ready。
  结果：新增 `docs/assets/asset-finalization-review-records.json` 与 `.md`；`stage14_air_dash_icon_ai01`、`stage15_recovery_charge_icon_ai01`、`stage14_air_dash_trail_ai01`、`stage15_boss_attack_warning_ai01` 进入 `final_ready`；final-art queue 刷新为 `51` 个 manual-review entries、`4` 个 final-ready assets。
  关键验证或结论：Art readiness `55/55 structural ready, 4/55 final ready`；final acceptance gates `51 blocked assets, 4 final-ready assets`；asset package audit 通过并记录 `4 asset finalization approvals`；Godot import、Stage14 / Stage15 / Stage16 GUT 均通过。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；复核记录：`docs/assets/asset-finalization-review-records.md`。

- **Asset finalization pass 01 decisions**：完成首批 P0 runtime 资产审图结论和下一目标定义。
  结果：新增 `docs/assets/runtime-source-review-decisions.json`、`docs/assets/runtime-source-review-decisions.md`、`docs/assets/p0-finalization-list.md`、`docs/implementation-plans/2026-06-21-asset-finalization-pass-01.md` 与 `scripts/assets/audit_runtime_source_review_decisions.py`；`15/15` runtime review-required 资产全部进入 `confirmed_for_cleanup`。
  关键验证或结论：决策审计输出 `15 decisions, 15 confirmed for cleanup, 0 final-ready`；综合资产包审计通过并记录 `15 runtime source cleanup decisions`。当前仍是 cleanup / rebuild 入口，不代表授权、清稿、运行时替换或 final-ready。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；实施计划：`docs/implementation-plans/2026-06-21-asset-finalization-pass-01.md`。

- **Project asset isolation audit**：新增项目资产隔离审计，防止多项目并行时把其它项目 image_gen 输出误归属到 Nano Hunter。
  结果：新增 `scripts/assets/audit_project_asset_isolation.py`、`docs/assets/project-asset-isolation-report.json`、`docs/assets/project-asset-isolation-report.md` 和 `docs/implementation-plans/2026-06-21-project-asset-isolation-audit.md`；综合资产包审计纳入该门槛。
  关键验证或结论：`python scripts\assets\audit_project_asset_isolation.py --write-report --strict` 输出 `1918 files, 0 forbidden markers, 0 outside paths, 0 project_key errors`；综合资产包审计同样通过并记录 `0 forbidden project markers, 0 outside asset paths`。当前只证明资产记录层未发现已知外项目污染证据，不代表 `review-required` 候选已确认。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；实施计划：`docs/implementation-plans/2026-06-21-project-asset-isolation-audit.md`。

- **Runtime source regeneration landing audit**：为 7 个 runtime UI / VFX 重生图候选新增落盘审计，确保后续 image gen 生成结果只进入项目候选池。
  结果：新增 `scripts/assets/audit_runtime_source_regeneration_landing.py`、`docs/assets/runtime-source-regeneration-landing-report.json`、`docs/assets/runtime-source-regeneration-landing-report.md` 和 `docs/implementation-plans/2026-06-21-runtime-source-regeneration-landing-audit.md`；综合资产包审计纳入该门槛。
  关键验证或结论：前置门禁阶段 `python scripts\assets\audit_runtime_source_regeneration_landing.py --write-report --strict` 输出 `7 assets, 7 pending, 0 landed, 0 invalid`；后续同日已执行实际候选落盘 pass，并在最新里程碑中推进到 `7/7 runtime source regeneration landed`。
  详情日志链接：`docs/progress/logs/2026-06-21.md`；实施计划：`docs/implementation-plans/2026-06-21-runtime-source-regeneration-landing-audit.md`。

## 2026-06-25

- **Animation Runtime Replacement Pass 复核收口**：确认动作正式替换批次的活跃候选已收口，runtime source review queue 清零。
  结果：runtime source safety 为 `30 runtime assets, 0 review-required, 0 unsafe`；动作替换严格审计为 `15/15 active ready, 0 active blocked, 8 archived references, 0 archive errors`。
  关键验证或结论：`build_runtime_source_review_queue.py` 输出 `0 review-required assets, 0 unsafe`；`audit_runtime_source_safety.py --write-report` 输出 `30 runtime assets, 0 review-required, 0 unsafe`；`audit_animation_runtime_replacement.py --strict` 通过并确认活跃候选无阻塞。
  详情日志链接：`docs/progress/logs/2026-06-25.md`；遗留：8 个历史 blocked reference 保留为归档证据与重生成依据，不再构成活跃阻塞。
