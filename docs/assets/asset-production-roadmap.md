# Nano Hunter Asset Production Roadmap

Last Updated: 2026-05-14

## 定位

资产生产线是 `Nano Hunter` 的长期并行工作流，不替代玩法 Stage。Stage 负责证明玩法、内容和可试玩链路成立；资产 Batch 负责为已经确定或正在验证的 Stage 补视觉、音频、动画参考和展示质量。

默认节奏：

```text
Stage 设计目标
-> 资产需求登记
-> 灰盒 / 占位实现
-> 资产 Batch 生成候选
-> 玩法验证
-> 清理可接入版
-> 替换资产
-> Godot 导入与测试
-> 进度留痕
```

## 批次总览

| Batch | 名称 | 目标 | 是否直接接入游戏 | 关联阶段 |
| --- | --- | --- | --- | --- |
| Batch 00 | 风格锁定 | 锁定 Luna、镇妖卫、佛门符印、瘴泽妖域、Seal Guardian 视觉方向 | 否 | Stage16 后续资产线 |
| Batch 01 | P0 玩法可读资产 | 补 Luna、Air Dash、Seal Guardian、Boss 预警、Recovery Charge 等最影响读值的资产 | 是，接入前需复核 | Stage14-16 polish |
| Batch 02 | Stage16 UI 与终局反馈 | 补主菜单、暂停 / 重开、终局封印链、完成反馈 | 是 | Stage16 Alpha Demo polish |
| Batch 03 | 区域表现资产 | 补山门古刹 / 镇妖试炼场与瘴泽妖域区域表现 | 是 | Stage13-16 visual pass |
| Batch 04 | 音频资产 | 补最小 SFX、人声、怪物声与 BGM loop | 是 | Stage16 audio pass |
| Batch 05 | 动画参考与宣传素材 | 生成动作参考、Boss 入场、trailer 草案 | 默认否 | 后续动画 / 宣传 |
| Batch 06+ | 后续 Stage 资产 | 随新区域、新敌人、新能力、Boss、支线和 UI 追加 | 视 Stage 而定 | Stage17+ |

## Batch 00 - 风格锁定

目标：先定方向，不直接改游戏引用。

资产需求：

- Luna 侧面全身方向稿、半身设定、色板。
- 镇妖卫 / 佛门符印风格板。
- 瘴泽妖域环境氛围板。
- Seal Guardian Boss 风格方向。

推荐工具：

- Image2 / GPT Image：主方向稿。
- Nano Banana / Gemini Image：基于入选方向做局部修改和风格变体。

退出条件：

- 至少确定 `1` 套 Luna 方向、`1` 套符印视觉语义、`1` 套瘴泽妖域色板和 `1` 套 Seal Guardian 方向。
- `asset-generation-brief.md` 中记录可复用 prompt 或 prompt 模板。

## Batch 01 - P0 玩法可读资产

目标：补当前 Alpha Demo 候选最影响可读性的核心资产。

| Asset ID | 目标路径 | 工具建议 | 状态 |
| --- | --- | --- | --- |
| stage16_luna_player_readability_ai01 | `assets/art/characters/player/stage16_luna_player_readability_ai01.png` | Image2 / GPT Image | needed |
| stage14_air_dash_icon_ai01 | `assets/art/ui/stage14_air_dash_icon_ai01.png` | Nano Banana / Gemini Image | needed |
| stage14_air_dash_trail_ai01 | `assets/art/vfx/stage14_air_dash_trail_ai01.png` | Image2 + Nano Banana | needed |
| stage14_air_dash_shrine_ai01 | `assets/art/props/stage14_air_dash_shrine_ai01.png` | Image2 / GPT Image | needed |
| stage14_air_dash_gate_ai01 | `assets/art/props/stage14_air_dash_gate_ai01.png` | Image2 + Nano Banana | needed |
| stage15_seal_guardian_ai01 | `assets/art/characters/bosses/stage15_seal_guardian_ai01.png` | Image2 / GPT Image | needed |
| stage15_boss_attack_warning_ai01 | `assets/art/vfx/stage15_boss_attack_warning_ai01.png` | Nano Banana / Gemini Image | needed |
| stage15_recovery_charge_icon_ai01 | `assets/art/ui/stage15_recovery_charge_icon_ai01.png` | Nano Banana / Gemini Image | needed |

退出条件：

- 每个资产至少有 `3-6` 张候选。
- 可接入版使用透明背景或可稳定抠图背景。
- 替换前不改变碰撞、判定或 HUD 布局契约。

## Batch 02 - Stage16 UI 与终局反馈

目标：让 Alpha Demo 结尾、主菜单和暂停 / 重开反馈更像可展示 demo。

资产需求：

- `stage16_title_background_ai01`
- `stage16_demo_menu_icons_ai01`
- `stage16_seal_release_threshold_ai01`
- `stage16_talisman_relay_ai01`
- `stage16_backtrack_confirmation_ai01`
- `stage16_corruption_purge_ai01`
- `stage16_alpha_demo_completion_ai01`

推荐工具：

- Image2 / GPT Image：主菜单背景、完成反馈大图、终局封印链方向。
- Nano Banana / Gemini Image：图标组、符印、按钮图案、局部重绘。
- Inkscape / Krita：最终图标清稿。

## Batch 03 - 区域表现资产

目标：把灰盒区域视觉推进到山门古刹、镇妖试炼场、瘴泽妖域和封妖禁地方向。

资产需求：

- `biome_01_shrine_trial`：地形 tile、背景层、镇妖试炼装置、石碑、符印机关。
- `biome_02_miasma_marsh`：腐瘴地面、背景、危险提示、符桩、封印门、石龛。
- 可复用 props：佛印石灯、悬赏榜、镇妖符桩、封印链、破败古庙构件。

退出条件：

- 地形资产不得抢过玩家、敌人、危险物和交互物读值。
- 背景层不暗示错误碰撞边界。
- 所有交互物保留“关闭 / 可触发 / 已完成”三种状态设计空间。

## Batch 04 - 音频资产

目标：补 Alpha Demo 最小音频表现，不建立完整音频系统。

资产需求：

- SFX：跳跃、空中冲刺、攻击、命中、受击、封印门开合、符印激活、Boss 预警、恢复充能、完成反馈。
- Voice：Luna 短促受击 / 发力声、Seal Guardian 低吼；先作为候选，不默认大量接入。
- BGM：主菜单 loop、瘴泽区域 loop、Boss loop。

推荐工具：

- ElevenLabs：SFX、人声、怪物声。
- Suno / Lyria 3：BGM 草案与 loop。
- Audacity / Reaper：裁剪、响度统一、无缝 loop。
- Godot：导入、压缩和播放验证。

## Batch 05 - 动画参考与宣传素材

目标：生成动作参考和宣传材料，不直接导入为游戏内 sprite 动画。

资产需求：

- Luna 空中冲刺动作参考。
- Seal Guardian 攻击节奏参考。
- Boss 入场短片参考。
- Alpha Demo trailer 草案。
- 主菜单动态背景参考。

推荐工具：

- Seedance 2 / Veo 3.1：动画参考、宣传视频、镜头氛围。
- Aseprite / Krita：从参考中手工提炼关键帧。
- AsepriteWizard：只有正式采用 `.aseprite` / `.ase` 动画源时再启用。

## 后续 Batch 规则

- 每个新增 Stage 默认先登记资产需求，再决定是否开新的 Batch。
- 新区域默认拆为“区域表现 Batch + 敌人 / VFX Batch + 音频 Batch”。
- 新 Boss 默认拆为“Boss 概念 / 轮廓 Batch + Boss 房 / 预警 / 音频 Batch”。
- 不让资产生产阻塞灰盒玩法验证；不让未验证玩法提前消耗正式资产制作成本。
