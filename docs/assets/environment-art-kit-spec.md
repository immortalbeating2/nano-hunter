# Environment Art Kit Spec / 场景美术 Kit 规格

本规格用于修正 Demo 场景美术装配口径：房间不能只证明“有资源引用”，必须证明背景、地面、台阶、平台、碰撞和出口共同组成可玩的完整场景。

## Runtime Layer Contract

每个正式房间按以下层级组织：

| Layer | 作用 | 验收要求 |
| --- | --- | --- |
| `Backdrop` | 色调兜底 | 只能兜底，不能作为完成背景 |
| `*BackgroundArt` | 区域背景 / 视差底图 | 覆盖相机视口，不露纯色大空洞 |
| `TerrainUnderlay` / `FloorVisual` | 连续地形读形 | 只能作为过渡保底；正式签核前必须有材质边缘或 TileMap 叠层 |
| `*TilesetPreview` / TileMap | 地面、平台、台阶、墙体模块 | 需要连续铺设，不允许零散样片堆放 |
| `GameplayProps` | 门、机关、checkpoint、能力神龛 | 视觉位置与碰撞 / Area 一致 |
| `HazardVisuals` | 危险区视觉 | 必须能对应到 Area 或明确为装饰 |
| `ForegroundDecor` | 雾、草、枝条 | 不能遮挡脚底、出口、Boss 预警和 HUD |
| `HUD` | 教程和状态 UI | 不能有大图撑开或遮挡核心玩法区域 |

## Area Kits

| Kit | 房间范围 | 必备资产 |
| --- | --- | --- |
| `shrine_trial` | Tutorial、Stage14、部分 Stage16 | 古刹背景、石阶地面、平台边、墙体、内外角、破损台阶、符印装饰 |
| `miasma_marsh` | Stage13 | 瘴泽背景、安全湿地地面、毒雾 / 毒水边、根须平台、石块边缘、封印碎片 |
| `seal_climax` | Stage15、Stage16 终局 | 封印禁地背景、Boss 场地面、封印门、机关台、终点反馈地台 |
| `legacy_demo` | Test、Stage9-11 旧区 | 可复用 shrine / miasma kit；不得长期保留纯灰盒道路 |

## Blocking Rules

- 可见节点带 `visual_preview_only`、`collision_still_graybox`、`visual_preview_only_collision_still_graybox` 时，不能作为完成签核。
- 可见整张 `TileSheetArt` / `TilesArt` / atlas preview 不能作为正式关卡地形。
- 纯色或半透明 Polygon 地形只能作为过渡 underlay，不能作为最终道路资产。
- 平台 / 台阶必须有左端、中段、右端、下沿和厚度；没有路线语义的低台阶应删除或改成装饰。
- 背景不得只覆盖一小块；房间相机范围内不能出现非设计意图的大面积纯色底。
- 玩家可站视觉必须与碰撞一致，脚底不能明显悬空或陷入贴图。
- 房间末端必须有出口、墙、落点或明确危险提示，不能让玩家沿看似正常路线直接掉死。

## Image Gen Trigger

只有当现有资源无法组成区域 kit 时才生成新图：

- `TileSet`：透明或中性底，规则网格，建议 32x32 / 64x64，含地面、平台边、墙体、内角、外角、台阶、破损和装饰。
- `Background`：16:9，无 UI / 文字，playable 区域留干净，不画误导性可站平台。
- `Props`：透明背景 PNG，单体居中，关闭 / 触发 / 完成状态可区分。

目标路径：

```text
assets/source/ai_generated/demo_art_composition/dac06/
assets/art/backgrounds/demo_art_composition/
assets/art/tilesets/demo_art_composition/
assets/art/props/demo_art_composition/
```
