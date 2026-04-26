# Asset Generation Brief

Last Updated: 2026-04-27

## 用途

本文件用于指导用户寻找、生成和替换 Nano Hunter 的资产。它不替代 `asset-manifest.md`，而是提供更适合“去找资产 / 生成资产 / 保持一致性”的方向、提示词和投放路径。

## 当前资产状态

- Stage 12 已建立资产目录、资产清单和接入检查清单。
- Stage 12-13 已接入一批项目内 SVG 占位资产，用于玩家轮廓、敌人轮廓、攻击 / 命中 VFX、HUD 图标、第二小区域环境、酸液危险、净化门控与区域终点装置。
- 当前资产主要是 `占位资产` 和 `AI / 人工可替换目标的结构样例`，不是最终美术。
- Stage 14-16 仍需要继续补：新能力表现、回溯门控标识、Boss / 精英、战斗高潮 VFX、主菜单 / 暂停 UI、音效与 BGM。

## 风格锚点

核心方向：

- 2D side-view metroidvania
- nano-scale hunter inside a contaminated bio-lab
- readable silhouettes, clean gameplay shapes
- biotech laboratory + organic waste zone
- compact 640x360 gameplay readability
- high contrast interactive objects
- not photorealistic, not noisy, not overly detailed

建议基准色：

- 玩家：冷白、青蓝、少量荧光绿，用于突出主角。
- 实验室区：深灰、冷蓝、白色灯带。
- 生物废液区：深紫、病态绿、暗红褐，但交互物必须高亮。
- 危险物：酸绿 / 黄绿，高亮边缘。
- 门控与目标：青蓝 / 白色能量，对比背景。

一致性约束：

- 角色和敌人都保持清晰外轮廓。
- 地形资产不得抢过玩家、敌人和危险物的可读性。
- 所有交互物必须有“关闭 / 可触发 / 已完成”三种可读状态的设计空间。
- 生成图像优先无背景或透明背景；如果工具不支持透明背景，使用纯色背景方便抠图。
- 同一类资产使用同一视角、同一光源方向、同一轮廓粗细和相近色板。

## 文件投放规则

- 玩家：`assets/art/characters/player/`
- 敌人：`assets/art/characters/enemies/`
- 环境：`assets/art/environment/biome_01_lab/`、`assets/art/environment/biome_02_bio_waste/`
- 道具 / 门控 / 终点装置：`assets/art/props/`
- UI：`assets/art/ui/`
- VFX：`assets/art/vfx/`
- 音效：`assets/audio/sfx/`
- BGM：`assets/audio/music/`
- AI 生成原图或参考：`assets/source/ai_generated/`
- 可编辑源文件：`assets/source/editable/`
- 外部参考图：`assets/source/references/`

任何准备进项目的外部或 AI 资产，都要回填 `docs/assets/asset-manifest.md` 的来源、授权状态、当前状态和替换优先级。

## 全局提示词模板

英文正向模板：

```text
2D side-view metroidvania game asset, nano-scale hunter inside a contaminated biotech laboratory, clean readable silhouette, high contrast gameplay readability, compact shape language for 640x360 gameplay, crisp edges, limited color palette, subtle biotech details, consistent top-left rim light, transparent background, game-ready concept sprite
```

英文负向模板：

```text
photorealistic, cinematic screenshot, noisy background, excessive details, low contrast, blurry edges, front-facing portrait, isometric view, 3D render, text, watermark, logo, UI mockup, gore, unreadable silhouette
```

中文辅助描述：

```text
2D 横版类银河恶魔城资产，纳米猎人在污染生物实验室中探索，轮廓清晰，战斗中易读，高对比，少量生物科技细节，统一左上方边缘光，透明背景，适合 640x360 游戏画面。
```

## Stage 14-16 初步资产需求

| 阶段 | 资产 | 目标路径 | 规格建议 | 优先级 | 备注 |
| --- | --- | --- | --- | --- | --- |
| Stage 14 | 新移动 / 探索能力图标 | `assets/art/ui/stage14_ability_icon_01.svg` | 32x32 或 64x64，强识别 | P0 | 能力尚未最终锁定，图标需可替换 |
| Stage 14 | 能力获取装置 | `assets/art/props/stage14_ability_station_01.svg` | 128x96，关闭 / 激活 / 已领取状态 | P0 | 用于能力发放或能力提示 |
| Stage 14 | 回溯门控标识 | `assets/art/props/stage14_backtrack_gate_01.svg` | 96x96，能表达“新能力可通过” | P0 | 不要和 Stage 13 净化门混淆 |
| Stage 14 | 回溯收益点标识 | `assets/art/props/stage14_backtrack_reward_marker_01.svg` | 48x48 或 64x64 | P1 | 至少覆盖 3 个回访收益点 |
| Stage 14 | 新能力 VFX | `assets/art/vfx/stage14_ability_trail_01.svg` | 64x32 或 sprite strip | P1 | 根据能力类型调整 |
| Stage 15 | 精英 / Boss 轮廓 | `assets/art/characters/enemies/stage15_elite_boss_silhouette_01.svg` | 128x128 或 160x128 | P0 | 必须和普通敌人明显区分 |
| Stage 15 | Boss 房背景锚点 | `assets/art/environment/biome_02_bio_waste/stage15_boss_room_backdrop_01.svg` | 320x180 或分层背景 | P1 | 先做气氛与可读性，不抢战斗主体 |
| Stage 15 | Boss 攻击预警 | `assets/art/vfx/stage15_boss_warning_01.svg` | 64x64 或 96x32 | P0 | 服务失败重试和可读性 |
| Stage 15 | 战斗资源 / 扩展动作 UI | `assets/art/ui/stage15_combat_resource_icon_01.svg` | 32x32 | P1 | 如果 Stage 15 引入资源机制再锁定 |
| Stage 16 | 主菜单背景 | `assets/art/ui/stage16_title_background_01.png` | 1280x720 或 640x360 | P1 | 可用于 Alpha Demo 包装 |
| Stage 16 | 暂停 / 重开 / 完成 UI 图标 | `assets/art/ui/stage16_demo_menu_icons_01.svg` | 32x32 图标组 | P0 | 保持 HUD 语义一致 |
| Stage 16 | 最小音效包 | `assets/audio/sfx/` | wav/ogg，短反馈 | P0 | 跳跃、攻击、受击、门控、完成 |
| Stage 16 | 最小 BGM loop | `assets/audio/music/` | ogg，30-90 秒 loop | P1 | 不阻塞玩法，但影响 demo 包装 |

## 分类提示词

玩家新能力 VFX：

```text
2D side-view metroidvania ability effect, nano hunter energy trail, cyan and white biotech particles, clean arc shape, transparent background, readable at small size, short burst animation keyframe, no character body, no background
```

回溯门控：

```text
2D side-view metroidvania gate prop, biotech lock that reacts to a traversal ability, cyan-white energy seams, dark lab metal frame, readable open and closed states, transparent background, clean silhouette, not a fantasy door
```

生物废液区 Boss：

```text
2D side-view metroidvania elite boss silhouette, mutated bio-lab guardian, organic waste armor, large readable body shape, clear weak-point glow, dark purple and sickly green palette, transparent background, game-ready concept sprite, no gore
```

Boss 攻击预警：

```text
2D game VFX warning marker, acid bio-energy hazard, high contrast lime green warning shape, readable telegraph for boss attack, transparent background, crisp edges, minimal details
```

主菜单背景：

```text
2D game title screen background, nano-scale hunter overlooking contaminated biotech lab, distant organic waste vats, dark laboratory atmosphere, readable center space for title, limited palette, no text, no logo, 16:9 composition
```

音效搜索关键词：

```text
short sci-fi slash, small robot jump, biotech door unlock, acid hazard sizzle, UI confirm blip, checkpoint activate, boss warning stinger
```

## 一致性工作流

1. 先生成或寻找同一资产主题的 `3-6` 张候选。
2. 只选轮廓最清楚、颜色最接近风格锚点的候选。
3. 原图放入 `assets/source/ai_generated/` 或 `assets/source/references/`。
4. 可接入版本导出到对应 `assets/art/` 或 `assets/audio/` 目录。
5. 回填 `asset-manifest.md`，标记来源、授权、状态和替换优先级。
6. 若资产改变碰撞、判定、玩家误读边界或 HUD 布局，必须补 `asset-ingestion-checklist.md` 记录。
