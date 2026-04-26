# Nano Hunter Asset Manifest

## 使用范围

本清单是 Stage 12 起的资产管线入口，用来记录“需要什么资产、放在哪里、现在是什么状态、来源和授权是否清楚”。当前阶段只做 `规范 + 轻替换`，不把清单扩展成数据库或编辑器插件。

## 状态值

- `needed`：已经确认需求，但尚未有可接入文件。
- `placeholder_ready`：已有占位或临时样例，可用于验证路径和可读性。
- `integrated`：已经接入当前 demo，并通过自动化或人工复核确认没有破坏流程。
- `deferred`：保留需求，但不进入当前阶段。

## 资产条目

| 资产 ID | 用途 | 目标路径 | 尺寸 / 规格 | 来源 | 授权状态 | 当前状态 | 接入阶段 | 替换优先级 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| stage12_player_silhouette | 玩家轮廓可读性样例 | `assets/art/characters/player/stage12_player_silhouette.svg` | 64x64 SVG，占位剪影 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P0 | 保留现有碰撞，场景内额外接入 `Stage12Silhouette` 与 `Stage12HelmetMark` |
| stage12_basic_melee_silhouette | 基础近战敌轮廓区分 | `assets/art/characters/enemies/stage12_basic_melee_silhouette.svg` | 64x64 SVG，占位剪影 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P0 | 强调近战威胁，不改变敌人 AI / Hurtbox |
| stage12_ground_charger_silhouette | 地面冲锋敌轮廓区分 | `assets/art/characters/enemies/stage12_ground_charger_silhouette.svg` | 64x64 SVG，占位剪影 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P0 | 强调尖锐和地面冲刺方向，不改变碰撞 |
| stage12_aerial_sentinel_silhouette | 空中哨兵轮廓区分 | `assets/art/characters/enemies/stage12_aerial_sentinel_silhouette.svg` | 64x64 SVG，占位剪影 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P0 | 强调悬浮空中威胁，不改变出生高度 |
| stage12_slash_vfx | 攻击 slash 最小表现 | `assets/art/vfx/stage12_slash_vfx.svg` | 64x32 SVG，占位 VFX | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P1 | 接入玩家 `Stage12SlashPreview`，只做攻击可读性，不参与判定 |
| stage12_hit_spark_vfx | 命中 spark 最小表现 | `assets/art/vfx/stage12_hit_spark_vfx.svg` | 48x48 SVG，占位 VFX | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P1 | 接入三类敌人的 `Stage12HitSpark`，只做受击可读性，不改变击败契约 |
| stage12_checkpoint_gate_goal_icons | checkpoint / 门控 / 终点提示图形 | `assets/art/ui/stage12_checkpoint_gate_goal_icons.svg` | 96x32 SVG，占位图标组 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 12 | P0 | HUD 与终点房使用同一套视觉语义：生命、冲刺、目标 |
| stage12_lab_biome_reference | 第一区域实验室环境参考 | `assets/art/environment/biome_01_lab/.gitkeep` | 目录占位 | 待补 | 待确认 | needed | Stage 13+ | P2 | Stage 12 只建立目录，不提前生产完整环境资产 |
| stage13_bio_waste_biome_reference | 生物废液区环境主题参考 | `assets/art/environment/biome_02_bio_waste/` | 目录与 SVG 占位资产 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 第二小区域主题入口，地形、背景和装饰资产默认投放到该主题目录 |
| stage13_bio_waste_tiles | 废液地面 / 平台可读性资产 | `assets/art/environment/biome_02_bio_waste/stage13_bio_waste_tiles_01.svg` | SVG 占位 tile，兼容当前灰盒平台尺寸 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 服务平台边界和废液区域的碰撞可读性 |
| stage13_bio_waste_background | 生物废液区背景层 | `assets/art/environment/biome_02_bio_waste/stage13_bio_waste_background_01.svg` | SVG 占位背景层，不干扰平台和敌人读值 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P1 | 第一轮占位背景，后续可替换为正式背景 |
| stage13_purification_gate | 净化门控视觉 | `assets/art/props/stage13_purification_gate_01.svg` | SVG 占位装置，表达关闭 / 开启状态 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 对应 Stage 13 新门控，不扩成正式钥匙系统 |
| stage13_purification_node | 净化节点视觉 | `assets/art/props/stage13_purification_node_01.svg` | SVG 占位节点，表达可触发状态 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 用于净化门控解除条件 |
| stage13_spore_shooter_silhouette | 孢子投射敌轮廓 | `assets/art/characters/enemies/stage13_spore_shooter_silhouette.svg` | 64x64 SVG，占位剪影 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 第 4 类敌人，需与近战、冲锋、空中敌轮廓明显区分 |
| stage13_acid_hazard_warning | 废液 / 酸液危险提示 | `assets/art/vfx/stage13_acid_hazard_warning_01.svg` | SVG 占位警示，不改变碰撞边界 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P0 | 用于废液池 / 酸液地形的危险可读性 |
| stage13_bio_waste_goal_device | 第二小区域终点装置 | `assets/art/props/stage13_bio_waste_goal_device_01.svg` | SVG 占位终点装置，表达区域完成和 Stage 14 前置诱因 | 项目内临时绘制 | 项目自有占位 | integrated | Stage 13 | P1 | 终点房承接 Stage 14 回溯能力前置，但 Stage 13 不发放新能力 |
| stage12_demo_sfx_pack | Demo 最小音效包 | `assets/audio/sfx/.gitkeep` | 待定 | 待补 | 待确认 | deferred | Stage 16 | P2 | 不进入 Stage 12 实现 |
| stage12_demo_music_loop | Demo 最小 BGM 循环 | `assets/audio/music/.gitkeep` | 待定 | 待补 | 待确认 | deferred | Stage 16 | P3 | 不进入 Stage 12 实现 |

## 维护规则

- 新区域、新敌人、新能力、新 UI 或 Boss 需求默认追加到本清单，不重新创建另一套资产规划。
- 使用外部免费、购买、AI 生成或正式项目资产前，必须补齐来源与授权状态。
- 如果资产会改变碰撞、判定或玩家误读边界，必须先进入 `asset-ingestion-checklist.md` 做接入复核。
