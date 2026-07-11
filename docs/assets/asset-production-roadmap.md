# Nano Hunter Asset Production Roadmap

Last Updated: 2026-06-19

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
| Batch 04 | 音频资产 | 补全量音频资产参考与 Stage16 首批 SFX / 氛围 / BGM / 配置入口 | 是 | Stage16 audio pass / Stage17+ audio library |
| Batch 05 | 动画参考与宣传素材 | 生成动作参考、Boss 入场、trailer 草案 | 默认否 | 后续动画 / 宣传 |
| Batch 06 | 角色与敌人动画帧 | 补 Luna 高帧数动作帧、敌人 / Seal Guardian 动作帧和 sprite sheets | 是，接入前需复核 | Stage14-17 animation pass |
| Batch 07 | TileSet 与贴图 | 补地形 tile、材质贴图、危险池和平台边缘 | 是 | Stage13-17 environment pass |
| Batch 08 | UI / Icon Atlas | 补 HUD、菜单、图标、九宫格与 UI 图集 | 是 | Stage16+ UI polish |
| Batch 09 | Prop / Equipment Atlas | 补 shrine、gate、符桩、石碑、武器、奖励物 | 是 | Stage14-17 content polish |
| Batch 10 | VFX Atlas | 补 slash、hit、dash、seal、warning、purge 序列帧 | 是 | Stage12-17 VFX pass |
| Batch 11 | Spine 拆件图集 | 为 Luna 与 Boss 准备后续骨骼动画拆件候选 | 默认否 | Future animation pipeline |
| Batch 12 | Promo / LOGO / CG | 补 LOGO、key art、封面、运营图、CG | 默认否 | Demo presentation / marketing |
| Batch 13 | Narrative Storyboard | 补剧情分镜、过场氛围和叙事插图 | 默认否 | Future narrative pass |
| Batch 14+ | 后续 Stage 资产 | 随新区域、新敌人、新能力、Boss、支线和 UI 追加 | 视 Stage 而定 | Stage17+ |

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

目标：先补全量音频资产参考口径，再按 Stage16 Alpha Demo 需要生成首批可接入音频；不在本批直接建立完整音频系统。

资产需求：

- 角色动作音效：Luna 脚步、跳跃、落地、空中冲刺、滑墙候选、攻击发力。
- 战斗音效：攻击、命中、格挡 / 反制候选、敌人消散、投射物、Boss 预警、Boss impact。
- UI 音效：确认、取消、焦点移动、暂停打开 / 关闭、完成反馈。
- 环境音效 / 氛围声：山门古刹、瘴泽妖域、Boss 房、封印释放阈值。
- 物品与交互音效：checkpoint、拾取、能力神龛、封印门开合、符印 relay、恢复充能。
- 载具 / 机械音效：当前世界观不做现代载具，统一改为古代机关、石质升降平台、封印链、机括锁。
- 怪物 / NPC 音效：普通敌人警觉、冲锋蓄力、空中敌悬浮、Seal Guardian 低吼、后续 NPC 含混语音候选。
- 音乐资产 BGM：主菜单、山门古刹、瘴泽探索、瘴泽战斗、Boss、胜利 / 失败 stinger。
- 语音资产：Luna 短促无台词发力 / 受击 / 冲刺呼吸，后续 NPC 无台词候选。
- 系统反馈音：checkpoint 保存、能力解锁、条件不足、重开 / retry。
- 音频配置资产：audio event catalog、mix targets、generation manifest、ingestion checklist。

推荐工具：

- ElevenLabs：SFX、人声、怪物声。
- Suno / Lyria 3：BGM 草案与 loop。
- Audacity / Reaper：裁剪、响度统一、无缝 loop。
- Godot：导入、压缩和播放验证。

Prompt、命令、全量分类矩阵与存放地址参考：`docs/assets/audio-asset-prompt-reference.md`。

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

## Batch 06 - 角色与敌人动画帧

目标：把角色与敌人从单张方向稿推进到可用于 Godot 动画的动作帧和 sprite sheet；其中 Luna 作为主角必须按高帧数标准推进。

资产需求：

- Luna：idle、walk、run、jump start、jump rise、fall、land、attack、aerial attack、hit、death、air dash；核心动作遵循 `docs/assets/animation-frame-spec.md`，run 推荐 `16-24` 帧，air dash / attack 推荐 `12-16` 帧，death 推荐 `16-24` 帧。
- 敌人：基础近战、冲锋、空中哨兵、瘴气妖术投射者的 idle / move / attack / hit / defeat。
- Seal Guardian：idle、attack warning、attack、hit、defeat。

输出：

- `assets/art/characters/player/sprite_sheets/`
- `assets/art/characters/enemies/sprite_sheets/`

约束：

- 直接 image gen 的高帧 sheet 可作为候选，不直接视为正式接入资产。
- Luna P0 动作允许先生成 `8-12` 帧候选，再由 Aseprite / Krita 清稿补到正式帧数。
- 每张 sheet 必须固定帧格、脚底基线、朝向和缩放。

## Batch 07 - TileSet 与贴图

目标：把山门古刹 / 镇妖试炼场与瘴泽妖域的灰盒环境推进到可切 tile 的生产状态。

资产需求：

- 平台、地面、墙面、边缘、危险池、装饰 tile。
- 石材、木构、符纸、瘴气地表、腐化水面、布料和金属边饰贴图。

输出：

- `assets/art/tilesets/`
- `assets/art/textures/`

## Batch 08 - UI / Icon Atlas

目标：把 HUD、菜单、图标和九宫格面板整理成统一 UI 图集。

资产需求：

- 主菜单、暂停、重开、完成反馈面板。
- HUD 血量、能力状态、Boss 状态、Recovery Charge。
- Air Dash、checkpoint、门控、终点、奖励图标。
- 九宫格面板和按钮背景。

输出：

- `assets/art/ui/`
- `assets/art/ui/atlases/`

## Batch 09 - Prop / Equipment Atlas

目标：把交互道具、关卡装饰、装备和奖励物整理成 props / equipment 图集。

资产需求：

- Air Dash shrine、封印门、符桩、石碑、石龛、悬赏榜、佛印石灯。
- Luna 武器、符纸、念珠、铜铃、镇妖令牌、奖励物。

输出：

- `assets/art/props/`
- `assets/art/atlases/`

## Batch 10 - VFX Atlas

目标：把当前可玩读值需要的 VFX 统一为序列帧和图集。

资产需求：

- Slash、hit spark、Air Dash trail、Boss warning、talisman relay、corruption purge。

输出：

- `assets/art/vfx/`
- `assets/art/vfx/atlases/`

## Batch 11 - Spine 拆件图集

目标：为后续骨骼动画预留 Luna 与 Boss 拆件图集，但当前不默认启用 Spine 插件。

资产需求：

- Luna：头、躯干、上臂、前臂、手、腿、披带、武器、符纸。
- Seal Guardian：头 / 面具、躯干、前肢、后肢、尾部或封印链、弱点核心。

输出：

- `assets/art/spine_parts/`

## Batch 12 - Promo / LOGO / CG

目标：补宣传与运营图，不阻塞 playable demo。

资产需求：

- 项目 LOGO / 标题字方向。
- Key Art、Steam capsule、社媒图、Demo 封面。
- CG 图。

输出：

- `assets/art/promo/`

## Batch 13 - Narrative Storyboard

目标：补剧情分镜、过场氛围和叙事插图，作为后续剧情阶段参考。

资产需求：

- Luna 接悬赏、山门古刹入口、瘴泽妖域异变、Seal Guardian 封印破裂、Alpha Demo 完成反馈。

输出：

- `assets/art/storyboards/`
