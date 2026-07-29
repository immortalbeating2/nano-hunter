# Formal Terrain Kit Generation - 2026-07-06

## 背景

用户要求停止继续沿用被腰斩、东拼西凑或只适合隐藏预览的旧 TileSet，重新生成一套正式 terrain kit，覆盖当前 Alpha Demo 已开发关卡需要的平地、台阶、断崖、门口衔接、内外角、端头和地图装饰资产。

本轮只完成“正式源资产生成、透明化、网格规范化与 Godot 导入”。尚未把这些新图替换进运行时 TileMap，避免破坏当前已经恢复的清晰石板道路主体。

## 生成范围

| Sheet | 内容 | 原始透明图 | 最终规则网格图 |
| --- | --- | --- | --- |
| flat_edges | 平地中心、左右端头、内外角、单向平台、装饰地砖 | `assets/art/tilesets/formal_terrain_kit/formal_terrain_flat_edges_ai01.png` | `assets/art/tilesets/formal_terrain_kit/grid/formal_terrain_flat_edges_ai01_grid.png` |
| stairs_cliffs | 左右台阶、短台阶、竖直断崖、断崖端头、墙侧、支撑、碎平台 | `assets/art/tilesets/formal_terrain_kit/formal_terrain_stairs_cliffs_ai01.png` | `assets/art/tilesets/formal_terrain_kit/grid/formal_terrain_stairs_cliffs_ai01_grid.png` |
| door_transitions | 左右门口、封印门、门槛衔接、门楣、门柱、安全落点、门控台 | `assets/art/tilesets/formal_terrain_kit/formal_terrain_door_transitions_ai01.png` | `assets/art/tilesets/formal_terrain_kit/grid/formal_terrain_door_transitions_ai01_grid.png` |
| decor_props | 苔藓、碎石、石灯、香炉、符桩、悬布链条、瘴气、符印、石台、断柱 | `assets/art/tilesets/formal_terrain_kit/formal_terrain_decor_props_ai01.png` | `assets/art/tilesets/formal_terrain_kit/grid/formal_terrain_decor_props_ai01_grid.png` |

原始 chroma-key 图保存在：

`assets/source/ai_generated/formal_terrain_kit_2026_07_06/`

这些 raw 文件只用于溯源和重新抠图，不作为运行时引用；目录内已放置 `.gdignore`，避免 Godot 将色键源图作为运行时资源扫描 / 导入。

## 生成与处理规则

- 每张图按独立主题生成，不把所有地形和装饰硬塞进一张大画布。
- 使用平面 chroma-key 背景生成，再用 alpha 透明化；最终可接入 PNG 均为透明背景。
- 生成 prompt 强制要求：固定格子、每格一个资产、资产居中、大留白、禁止绿色 / 白色 / 棋盘格背景、禁止自由排布展示图、禁止相邻帧或资产重叠、禁止裁切。
- `scripts/assets/build_formal_terrain_kit_grid.py` 将透明源图重排为严格机器网格。
- 最终 grid 规格统一为 `1536x1152`，`4` 列 x `3` 行，每格 `384x384`。
- 每张最终 grid 图都带 `.layout.json`，记录每格可见区域，供后续 TileSet 构建脚本读取。

## 验证

| 检查项 | 结果 |
| --- | --- |
| `image_gen` 生成 | 4 张源图已生成并复制到项目 source 目录 |
| 透明化 | 4 张源图已去 chroma-key；四角 alpha 均为 `0` |
| 离散残点清理 | 门口图清理 `32` 像素；台阶断崖图清理 `3` 像素；平地图无小碎片；装饰图保留碎石 / 瘴气细节 |
| 规则网格规范化 | 4 张最终图均为 `1536x1152`、`4x3`、`384x384` cell |
| 最小格内边距 | flat_edges `56px`；stairs_cliffs `43px`；door_transitions `31px`；decor_props `43px` |
| 视觉复核 | 未发现半截资产、贴边裁切、相邻资产重叠或明显旧式红绿占位门禁 |
| 脚本语法 | `python -m py_compile scripts/assets/build_formal_terrain_kit_grid.py` 通过 |
| Godot 导入 | `godot --headless --path . --import` 通过，并生成 PNG `.import` |
| raw 源图隔离 | `assets/source/ai_generated/formal_terrain_kit_2026_07_06/.gdignore` 已加入；raw chroma-key `.import` 已移除 |

## 当前状态

- 这批资产已从 `source_ready / placeholder_ready` 源图推进到 Godot editor TileSet 候选资源。
- 它们解决了“旧图边缘贴边、源图混杂、门禁占位风格不统一、切割后容易出现半截”的资产来源问题。
- 已生成 `assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres`、`.tileset_rules.json`、`formal_terrain_kit_ai01.semantics.json` 和 `formal_terrain_kit_ai01.regions.json`。
- 还没有解决运行时 TileMap 替换、最终碰撞拟合、自动地形规则、门口衔接具体坐标和房间逐段审美复核。

## TileSet 派生复核

| 项目 | 结果 |
| --- | --- |
| Godot TileSet | `assets/art/tilesets/editor_tilesets/formal_terrain_kit_ai01.tileset.tres` |
| Source 数 | `4`，分别对应 flat_edges / stairs_cliffs / door_transitions / decor_props |
| Tile 数 | `48` |
| Tile size | `384x384` |
| Rules counts | solid `24`；one_way_platform `4`；hazard_visual_only `1`；decorative_visual_only `19` |
| 本地 review scene | `tests/artifacts/local/formal-terrain-kit/review/formal_terrain_kit_review.tscn` |
| 本地 review report | `tests/artifacts/local/formal-terrain-kit/review/formal_terrain_kit_review.json`，`tiles_painted=27`，`ok=true` |
| 自动化测试 | `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/demo/test_formal_terrain_kit_resource.gd` 通过，`3/3` |

截图说明：当前 Codex / Godot headless 使用 dummy rendering，无法稳定导出 viewport PNG，因此本轮保留可打开的本地 `.tscn` review board 和 JSON 证据，不把截图失败视为 TileSet 失败。

## 下一步

1. 打开本地 review scene 进行人工视觉确认，重点看平地、台阶、断崖、门口和装饰是否保持同一材质语言。
2. 在少量代表房间做非破坏性分支替换：一段平地、一个台阶、一个断崖、一个门口、一个回程入口。
3. 确认通过后，再批量替换 Stage9-16 的道路 / 门口衔接，而不是直接整张图铺进现有房间。
