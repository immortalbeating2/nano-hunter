# Animation Runtime Replacement Pass Design

## Summary

本设计定义 `Animation Runtime Replacement Pass / 动作正式替换批次` 的真实完成标准。它承接当前 `55/55 final-ready` 资产包，但不沿用 hidden/runtime preview 的低门槛：只有通过几何边界、帧序、基线、运行时绑定、hitbox / hurtbox、时序和试玩复核的动作，才允许替换玩家、敌人或 Boss 的正式运行时动画。

当前结论：现有 8 张角色 / 敌人 / Boss sprite sheet 均只能作为 preview / source，不能直接作为正式运行时替换。

## Goals

- 把 Luna、基础敌人和 Seal Guardian 的关键动作从 preview 资源推进到正式可试玩动画。
- 每个动作 sheet 必须做到不贴边、不跨格、不依赖 duplicate 补位、脚底基线稳定、中心点漂移可控、缩放变化不误导碰撞。
- 正式替换时同步验证 `SpriteFrames`、场景引用、动画名、播放速度、hitbox / hurtbox、damage window、cancel window 和人工试玩读值。
- 保留东方奇幻水墨 / 工笔方向，不重新引入现代实验室、生化或科幻表达。

## Non-Goals

- 不在本 pass 内追求商业级全角色完整动作集。
- 不把 current final-ready source package 重新定义为 runtime-ready。
- 不把 VFX 贴进角色动作格内作为正式方案；攻击 / dash / hit VFX 默认拆成独立 VFX layer。
- 不改变玩家控制器、敌人 AI 或 Boss 状态机的玩法语义，除非对应动作替换计划明确包含时序调整和测试。

## Runtime Replacement Gates

每个正式替换动作必须同时满足：

- 固定 cell 尺寸和固定帧数，`SpriteFrames` region 与 `frames.json` 一致。
- 所有帧 alpha 内容不得触碰 cell 边界。
- 普通角色动作至少保留 `4px` 最小边缘透明，建议左右 `12px`；攻击、Air Dash、Boss 等大幅动作建议左右 `24px`。
- 不允许 exact duplicate frame hashes，除非 metadata 显式记录为 intentional hold frame 且测试覆盖。
- 脚底 / 底部边界漂移不得造成视觉抖动；Luna 核心移动动作优先控制在 `10px` 以内。
- 横向中心点漂移不能导致 runtime position popping。
- 内容尺寸变化不能读成角色缩放漂移。
- 角色身体与攻击 / dash VFX 分层：角色 sheet 保持身体动作，VFX atlas 负责 slash / trail / hit spark。
- 接入后必须运行最接近的 Stage14 / Stage15 / Stage16 GUT，并做一次人工运行态复核。

## Asset Scope

第一轮覆盖当前 8 个 preview sheets：

- `luna_idle_sheet_ai01`
- `luna_run_sheet_ai01`
- `luna_air_dash_sheet_ai01`
- `luna_attack_01_sheet_ai01`
- `luna_jump_fall_sheet_ai01`
- `luna_hit_death_sheet_ai01`
- `enemies_core_sheet_ai01`
- `seal_guardian_boss_sheet_ai01`

## Recommended Order

1. `ARP-00 Audit Gate`：建立严格审计报告，确认当前 8 张 sheet 的正式替换 blockers。
2. `ARP-01 Luna Idle / Run`：先处理低风险循环动作，验证脚底基线、pivot 和播放器替换路径。
3. `ARP-02 Luna Air Dash / Jump-Fall`：处理移动能力动作，拆出独立 trail VFX，验证能力状态可读性。
4. `ARP-03 Luna Attack 01`：重新生成或重排角色攻击动作，slash VFX 独立接入，再绑定攻击时序。
5. `ARP-04 Enemy Core`：按敌人类型拆分或重排基础敌人动作，避免一个大表混合多个行为。
6. `ARP-05 Seal Guardian Boss`：处理 Boss warning / attack / recover，绑定 Boss 状态机和 damage window。

## Exit Criteria

- `docs/assets/animation-runtime-replacement-audit-report.json` 显示目标动作 `runtime_replacement_ready`。
- 对应 `.spriteframes.tres` 被正式场景使用，而不是隐藏 preview 节点。
- 对应测试验证动画名、帧数、场景引用和关键时序。
- 人工运行态复核确认没有边缘裁切、重叠、脚底抖动、比例跳变、HUD 遮挡或 hitbox 误读。
- 当日日志记录替换范围、验证结果、风险和下一步。
