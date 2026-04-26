# Asset Generation Brief

Last Updated: 2026-04-27

## 用途

本文件用于指导用户寻找、生成和替换 Nano Hunter 的资产。它不替代 `asset-manifest.md`，而是提供更适合“去找资产 / 生成资产 / 保持一致性”的方向、提示词和投放路径。

本文件必须优先对齐总设计北极星：`spec-design/2026-03-23-nano-hunter-design.md`。

## 总设计锚点

- 时代背景：南北朝时期
- 主角：`Luna`，镇妖卫赏金猎人，隐藏佛妖混血身份
- 能力表现：佛门符印、元素序列连锁、姿态切换、妖性觉醒
- 生物设计：山海经妖物意象
- 世界观冲突：佛门、妖怪势力、镇妖卫、腐化官僚、地方军阀、皇家
- 美术方向：Ori 式柔美流动感 + 山海经东方神秘感 + 水墨 / 工笔色系
- UI 方向：符印法阵、灵力链、竹简 / 卷轴、悬赏榜、官府驿站

## 当前资产状态

- Stage 12 已建立资产目录、资产清单和接入检查清单。
- Stage 12-13 已接入一批项目内 SVG 占位资产，用于玩家轮廓、敌人轮廓、攻击 / 命中 VFX、HUD 图标、第二小区域环境、危险提示、门控与区域终点装置。
- 这些资产主要是 `占位资产` 和 `可替换结构样例`，不是最终美术。
- Stage 12-13 中出现的“实验室 / 生物废液区”属于灰盒阶段方向偏移；后续资产寻找和生成不应继续扩大现代生物实验室设定，而应改回南北朝东方奇幻语境。

## 灰盒命名回归方案

| 旧灰盒 / 偏移称呼 | 后续建议称呼 | 资产解释方向 |
| --- | --- | --- |
| 实验室区 | 山门古刹 / 镇妖试炼场 / 佛门封妖禁地 | 古刹、石碑、符印机关、镇妖卫试炼设施 |
| 生物废液区 | 瘴泽妖域 / 腐瘴荒泽 / 妖血瘴沼 | 瘴气、妖血、腐化水泽、山海经异兽污染 |
| 净化门 | 符印封门 / 镇妖印门 | 佛门符印或镇妖卫机关门 |
| 净化节点 | 镇妖符桩 / 佛印石灯 / 法阵锚点 | 触发符印机关，解除封门 |
| 酸液危险 | 腐瘴水 / 妖毒沼 / 魇蚀池 | 妖气腐化地形，不使用科幻酸池语义 |
| 终点装置 | 悬赏榜封印 / 镇妖石龛 / 佛门石碑 | 区域完成、剧情碎片或能力前置 |

## 风格锚点

核心方向：

- 2D side-view metroidvania
- Northern and Southern Dynasties inspired dark fantasy
- Shanhaijing-inspired monsters and spirits
- Buddhist talismans, seal magic, ritual circles
- bounty hunter of a demon-suppressing bureau
- readable silhouettes, clean gameplay shapes
- ink wash, gongbi-inspired color accents, soft Ori-like glow
- compact 640x360 gameplay readability
- not photorealistic, not modern sci-fi, not biotech laboratory

建议基准色：

- Luna / 玩家：月白、墨青、青蓝灵光，少量妖性紫红。
- 佛门 / 符印：月白、金色、青蓝、朱砂红。
- 妖域 / 瘴泽：黛紫、墨绿、暗青、病态黄绿，但交互物必须高亮。
- 危险物：腐绿、毒黄、暗紫边缘光。
- 门控与目标：青蓝 / 月白符印能量，对比背景。
- 官府 / 镇妖卫：玄黑、朱红、铜金、竹简色。

一致性约束：

- 角色和敌人都保持清晰外轮廓。
- 地形资产不得抢过玩家、敌人和危险物的可读性。
- 所有交互物必须有“关闭 / 可触发 / 已完成”三种可读状态的设计空间。
- 生成图像优先无背景或透明背景；如果工具不支持透明背景，使用纯色背景方便抠图。
- 同一类资产使用同一视角、同一光源方向、同一轮廓粗细和相近色板。
- 不使用现代实验器材、金属管线、生化舱、科幻警示牌、现代 UI 面板作为主视觉。

## 文件投放规则

- 玩家：`assets/art/characters/player/`
- 敌人 / 妖物：`assets/art/characters/enemies/`
- 环境：当前仍沿用既有目录，但后续命名应逐步向古代东方区域回归
  - `assets/art/environment/biome_01_lab/`：后续解释为山门古刹 / 镇妖试炼场方向
  - `assets/art/environment/biome_02_bio_waste/`：后续解释为瘴泽妖域 / 妖毒沼方向
- 道具 / 符印门控 / 石碑 / 驿站设施：`assets/art/props/`
- UI / 法阵 / 悬赏榜 / 卷轴图标：`assets/art/ui/`
- VFX / 符印 / 元素 / 妖气：`assets/art/vfx/`
- 音效：`assets/audio/sfx/`
- BGM：`assets/audio/music/`
- AI 生成原图或参考：`assets/source/ai_generated/`
- 可编辑源文件：`assets/source/editable/`
- 外部参考图：`assets/source/references/`

任何准备进项目的外部或 AI 资产，都要回填 `docs/assets/asset-manifest.md` 的来源、授权状态、当前状态和替换优先级。

## 全局提示词模板

英文正向模板：

```text
2D side-view metroidvania game asset, Northern and Southern Dynasties inspired Chinese dark fantasy, Shanhaijing monster mythology, Buddhist talisman seal magic, demon-suppressing bounty hunter world, clean readable silhouette, high contrast gameplay readability, ink wash and gongbi-inspired colors, soft Ori-like glow, compact shape language for 640x360 gameplay, transparent background, game-ready concept sprite
```

英文负向模板：

```text
photorealistic, cinematic screenshot, noisy background, excessive details, low contrast, blurry edges, front-facing portrait, isometric view, 3D render, modern laboratory, biotech facility, sci-fi armor, cyberpunk, futuristic UI, text, watermark, logo, gore, unreadable silhouette
```

中文辅助描述：

```text
2D 横版类银河恶魔城资产，南北朝东方奇幻背景，镇妖卫赏金猎人 Luna，佛门符印、元素灵力、山海经妖物意象，轮廓清晰，战斗中易读，水墨 / 工笔色系，柔和灵光，透明背景，适合 640x360 游戏画面。
```

## Stage 14-16 初步资产需求

| 阶段 | 资产 | 目标路径 | 规格建议 | 优先级 | 风格备注 |
| --- | --- | --- | --- | --- | --- |
| Stage 14 | 新移动 / 探索能力图标 | `assets/art/ui/stage14_ability_icon_01.svg` | 32x32 或 64x64，强识别 | P0 | 用符印姿态或元素印记表达，不用科技图标 |
| Stage 14 | 能力获取装置 | `assets/art/props/stage14_ability_station_01.svg` | 128x96，关闭 / 激活 / 已领取状态 | P0 | 佛门石龛、镇妖符台、古刹法阵 |
| Stage 14 | 回溯门控标识 | `assets/art/props/stage14_backtrack_gate_01.svg` | 96x96，表达“新能力可通过” | P0 | 符印封门、妖气封障、元素克制障碍 |
| Stage 14 | 回溯收益点标识 | `assets/art/props/stage14_backtrack_reward_marker_01.svg` | 48x48 或 64x64 | P1 | 圣物、念珠、铜铃、佛门石碑碎片 |
| Stage 14 | 新能力 VFX | `assets/art/vfx/stage14_ability_trail_01.svg` | 64x32 或 sprite strip | P1 | 元素灵力轨迹、符印残影、妖性异色边缘 |
| Stage 15 | 精英 / Boss 轮廓 | `assets/art/characters/enemies/stage15_elite_boss_silhouette_01.svg` | 128x128 或 160x128 | P0 | 山海经异兽 / 腐化官妖 / 军阀妖化候选 |
| Stage 15 | Boss 房背景锚点 | `assets/art/environment/biome_02_bio_waste/stage15_boss_room_backdrop_01.svg` | 320x180 或分层背景 | P1 | 腐瘴荒泽、破败古庙、妖气祭坛 |
| Stage 15 | Boss 攻击预警 | `assets/art/vfx/stage15_boss_warning_01.svg` | 64x64 或 96x32 | P0 | 符印警示、妖气裂纹、朱砂阵线 |
| Stage 15 | 战斗资源 / 扩展动作 UI | `assets/art/ui/stage15_combat_resource_icon_01.svg` | 32x32 | P1 | 符印姿态、元素序列、妖性觉醒资源 |
| Stage 16 | 主菜单背景 | `assets/art/ui/stage16_title_background_01.png` | 1280x720 或 640x360 | P1 | Luna 立于古刹 / 悬赏榜 / 妖域入口前 |
| Stage 16 | 暂停 / 重开 / 完成 UI 图标 | `assets/art/ui/stage16_demo_menu_icons_01.svg` | 32x32 图标组 | P0 | 竹简、印章、法阵、镇妖卫符号 |
| Stage 16 | 最小音效包 | `assets/audio/sfx/` | wav/ogg，短反馈 | P0 | 符纸、铜铃、刀刃、妖气、石门、法阵 |
| Stage 16 | 最小 BGM loop | `assets/audio/music/` | ogg，30-90 秒 loop | P1 | 古琴 / 箫 / 鼓点 + 暗色氛围，不要现代电子主导 |

## 分类提示词

Luna / 玩家轮廓：

```text
2D side-view metroidvania protagonist sprite concept, Luna, female demon-suppressing bounty hunter from Northern and Southern Dynasties inspired Chinese fantasy, mask and ritual weapon, Buddhist talisman seals, moon-white and ink-teal palette, subtle demonic bloodline accent, clean readable silhouette, transparent background, no modern armor
```

新能力 VFX：

```text
2D side-view metroidvania ability effect, Buddhist talisman seal trail, elemental spiritual energy chain, cyan-white ink glow with vermilion seal accents, clean arc shape, transparent background, readable at small size, no modern sci-fi particles
```

回溯门控：

```text
2D side-view metroidvania gate prop, ancient Chinese talisman sealed gate, Buddhist seal magic, stone and wood shrine structure, cyan-white spiritual seams, closed and open state readable, transparent background, clean silhouette, not a futuristic door
```

瘴泽妖域 Boss：

```text
2D side-view metroidvania elite boss silhouette, Shanhaijing-inspired corrupted beast, miasma swamp guardian, ancient Chinese dark fantasy, large readable body shape, clear weak-point glow, ink purple and sickly green palette, transparent background, game-ready concept sprite, no gore, no sci-fi
```

Boss 攻击预警：

```text
2D game VFX warning marker, vermilion talisman circle and dark miasma cracks, high contrast readable telegraph for boss attack, transparent background, crisp edges, minimal details, ancient Chinese fantasy
```

主菜单背景：

```text
2D game title screen background, Luna standing before an ancient demon-suppressing shrine and bounty board, Northern and Southern Dynasties Chinese dark fantasy, distant Shanhaijing monster silhouettes, ink wash atmosphere, soft Ori-like glow, readable center space for title, no text, no logo, 16:9 composition
```

音效搜索关键词：

```text
short talisman cast, bronze bell chime, ink slash, ancient stone gate open, paper charm flutter, demon miasma hiss, Chinese drum warning stinger, soft guqin dark loop
```

## 一致性工作流

1. 先生成或寻找同一资产主题的 `3-6` 张候选。
2. 只选轮廓最清楚、颜色最接近风格锚点的候选。
3. 若候选带有现代实验室、生物科技、科幻装甲或现代 UI 语义，默认淘汰或只作为构图参考。
4. 原图放入 `assets/source/ai_generated/` 或 `assets/source/references/`。
5. 可接入版本导出到对应 `assets/art/` 或 `assets/audio/` 目录。
6. 回填 `asset-manifest.md`，标记来源、授权、状态和替换优先级。
7. 若资产改变碰撞、判定、玩家误读边界或 HUD 布局，必须补 `asset-ingestion-checklist.md` 记录。
