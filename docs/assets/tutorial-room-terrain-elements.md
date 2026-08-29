# Tutorial Room Terrain Elements

## 目的

本文件冻结 `tutorial_room.tscn` 的房间级地形元素清单和 `formal_terrain_kit_ai01` 语义清洗结果。后续复制到 Stage14 gate 或其它房间前，先以本房作为模板样本验证：视觉地面、薄平台、门口和断崖边界必须与真实可玩碰撞一致。

当前样板房使用 64px 网格蓝图驱动铺设：主路为 `x=-7..15, y=2` 连续 23 格，跳台为 `x=-4..-3, y=1` 连续 2 格，dash 门低顶为 `x=2..3, y=1`，出口安全落点为 `x=10..14, y=2`。脚本只按这张蓝图铺 TileMapLayer，不再按旧碰撞块逐段猜 tile。

## 房间元素清单

| 元素 | 场景节点 / 图层 | 玩法职责 | 视觉职责 | 碰撞权威 |
| --- | --- | --- | --- | --- |
| 起点主地面 | `FloorStart` -> `TerrainCollisionVisual` | 新手出生与第一段移动 | 连续平地，左右 cap 收边 | `TerrainCollisionVisual` TileSet solid |
| 跳跃教学薄平台 | `JumpGuidePlatform` -> `PlatformCollisionVisual` / `ThinPlatformSurfaceVisual` | 教学单向平台落脚 | 2 格水平短平台，使用 `tutorial_jump_platform_visual_ai02`；轻薄、下方留空，不表达墙体或坡面 | `PlatformCollisionVisual` TileSet one-way |
| 冲刺门前地面 | `DashGateLeft` -> `TerrainCollisionVisual` | 门前安全落点 | 平地 cap 明确，避免误读为空气墙 | `TerrainCollisionVisual` TileSet solid |
| 冲刺门后地面 | `DashGateRight` -> `TerrainCollisionVisual` | 门后安全落点 | 门后落脚可读 | `TerrainCollisionVisual` TileSet solid |
| 冲刺门上沿 | `DashGateCeiling` -> `TerrainCollisionVisual` / `DashGateLintelVisual` | 无冲刺时限制通过 | 使用 `tutorial_dash_gate_lintel_visual_ai01` 的厚重石铜封印梁，与单向跳台保持不同轮廓和重量 | `TerrainCollisionVisual` TileSet thin_solid |
| 左侧墙体 | `LeftWall` -> `TerrainCollisionVisual` | 房间左边界 | cliff side 明确边界 | `TerrainCollisionVisual` TileSet solid |
| 右侧墙体 | `RightWall` -> `TerrainCollisionVisual` | 房间右边界 | cliff side 明确边界 | `TerrainCollisionVisual` TileSet solid |
| 战斗区地面 | `CombatFloor` -> `TerrainCollisionVisual` | 教程 dummy 战斗落脚 | 连续平地，减少随机拼贴感 | `TerrainCollisionVisual` TileSet solid |
| 出口地面 | `ExitFloor` -> `TerrainCollisionVisual` | 出口前安全落点 | 右侧 cap 收边 | `TerrainCollisionVisual` TileSet solid |
| 出口封印 | `ExitBarrier` | 门控阻挡 | 门禁 / 封印表现独立于 terrain | 独立 `StaticBody2D` |
| 出口触发 | `ExitZone` | 房间切换 | 只做逻辑触发，不当作路 | 独立 `Area2D` |
| 教程靶子 | `TutorialDummy` | 战斗教学目标 | 敌人 / 靶子读值 | 独立角色碰撞 |
| 入口空间地标 | `TutorialLandmarks/EntryStoneLantern` | 无玩法碰撞 | 弱化石灯只提示起点方向，退到玩家与地表后方 | visual-only |
| Air Dash 门地标 | `TutorialLandmarks/DashGateSealShrine` | 无新增碰撞 | 发光神龛安装在实体低顶上方，解释能力门而不占用行走线 | visual-only |
| 单张房间背景 | `TutorialShrineBackgroundArt` | 无玩法碰撞 | `0.92` 等比覆盖完整 `24x6` 房间，消除重复接缝和右侧空白 | visual-only |
| 退役重复背景 | `TutorialShrineBackgroundArtLeft` | 无玩法职责 | 隐藏保留，不再参与运行态构图 | visual-only |
| 门框与门槛视觉 | `DoorVisual` | 无玩法碰撞 | 解释房间连接与安全落点 | visual-only |
| 背景符纹 / 藤蔓 | `BackgroundVisual` | 无玩法碰撞 | 氛围，不读成路 | visual-only |
| 地表裂纹 / 支撑 | `DecorVisual` | 无玩法碰撞 | 低密度结构提示 | visual-only |
| 前景挂饰 | `ForegroundVisual` | 无玩法碰撞 | 空间层次，不遮挡路线 | visual-only |
| 旧神龛 TileSet 预览 | `ShrineTrialTilesetPreview` | 无玩法职责 | 历史参考层，隐藏保留 | collision disabled |
| 连续主路视觉 | `GroundSurfaceVisual` | 无玩法碰撞 | 复用 `shrine_trial_tileset_ai01` left / center / right 地面件，把主路读成一整段地面 | visual-only |
| 单向跳台视觉 | `ThinPlatformSurfaceVisual` | 无玩法碰撞 | 只覆盖跳跃教学 2 格，绑定 `tutorial_jump_platform_visual_ai02` | visual-only；`physics_affordance=one_way_platform` |
| 实体门楣视觉 | `DashGateLintelVisual` | 无玩法碰撞 | 只覆盖 dash 门低顶 2 格，绑定 `tutorial_dash_gate_lintel_visual_ai01` | visual-only；`physics_affordance=thin_solid` |
| 退役地表底纹 | `GroundUnderlayVisual` | 无玩法碰撞 | 带格线，已隐藏保留，不能再当主路连续面 | visual-only |

旧 `LeftWall`、`RightWall`、`FloorStart`、`JumpGuidePlatform`、`DashGateLeft`、`DashGateRight`、`DashGateCeiling`、`CombatFloor`、`ExitFloor` 的 `CollisionShape2D` 保留为 authoring bounds，但运行态碰撞已禁用，由 TileMapLayer 承担地形碰撞权威。
旧 `ShrineTrialTilesetPreview` 必须同时 `visible=false` 与 `collision_enabled=false`；Godot 中隐藏 TileMapLayer 不等于禁用碰撞，这一层曾在 dash 门前形成空气墙。
`TerrainCollisionVisual` 与 `PlatformCollisionVisual` 是碰撞权威而非展示层，必须保持 `collision_enabled=true`、`visible=false`；实际地表只由 `GroundSurfaceVisual`、`ThinPlatformSurfaceVisual` 与 `DashGateLintelVisual` 展示，避免碰撞层以半透明方式形成第二套幽灵台阶。

## TileSet 语义清洗表

| 语义 | 本房采用状态 | 碰撞角色 | 使用位置 | 备注 |
| --- | --- | --- | --- | --- |
| `flat_ground_center` | 采用 | solid | 主路平地中段 | 只服务连续可踩面 |
| `left_cap` / `right_cap` | 采用 | solid | 每段平地左右端 | 解决断崖 / 平台边界不清 |
| `cliff_side` | 采用 | solid | 左右墙体 | 明确不可穿越边界 |
| `one_way_platform` | 采用 | one_way_platform | 跳跃教学薄平台 | 视觉唯一绑定 `tutorial_jump_platform_visual_ai02`，只用于可从下方通过的平台 |
| `door_transitions_broken_arch_top_trim` | 采用但重标 | thin_solid | 冲刺门上沿 | 只保留碰撞角色；可见层唯一绑定 `tutorial_dash_gate_lintel_visual_ai01` |
| `door_frame` | 采用 | decorative_visual_only | 左右门框 | 不参与碰撞 |
| `door_threshold` | 采用 | decorative_visual_only | 出口安全落点提示 | 只解释落脚，不替代地面碰撞 |
| `support` | 采用 | decorative_visual_only | 地面下方支撑 | 密度低，避免读成路 |
| `crack` / `vine` / `talisman` / `hanging` | 采用 | decorative_visual_only | 裂纹、背景、前景挂饰 | 氛围层，不参与玩法碰撞 |
| `stair_ramp` | 暂缓 | 未接入 | 本房不用 | 等有台阶 / 坡道房再定义 |
| `inner_corner` / `outer_corner` | 暂缓 | 未接入 | 本房不用 | 等 cliff vertical slice 再验证 |
| hazard / 其它候选 tile | 暂缓 | visual-only 或未接入 | 本房不用 | 不把未验证素材塞入教程房 |

## 房间级验收口径

- Luna 脚底必须落在可见地面或平台上。
- `formal_terrain_kit_ai01` 的 384px TileData 碰撞 polygon 必须使用格心局部 X 坐标 `-192..192`；`0..384` 会让资源审计与运行物理语义脱节。生成权威仅为 `build_formal_terrain_kit_tileset_resource.gd`，不得只手改 `.tres`。
- 逐格二维 footprint 的碰撞左右边界容差为 `0.25px`；left / right cap 允许的透明收边必须来自真实 alpha 扫描且不超过 `12.25px`，不能用全局宽松阈值掩盖整格偏移。
- 主地面运行态碰撞脚底基线固定为 `y=160`；`GroundSurfaceVisual` 的 left / center / right 切片分别使用 `texture_origin.y=1/0/-2`，消除三类图片自身 alpha 顶沿的 `1-2px` 差异。
- 单向跳台 left / center / right 切片使用 `tutorial_jump_platform_visual_ai02` 的 `texture_origin.y=7/7/7`；实体门楣使用 `tutorial_dash_gate_lintel_visual_ai01` 的 `-3/0/-3`。验收统一按真实 alpha 顶沿与碰撞顶沿做 top-to-top 比较，不再拿图片底边或任意最近边缘假装对齐。
- `TerrainCollisionVisual` 与 `PlatformCollisionVisual` 必须隐藏但保留碰撞；`GroundSurfaceVisual`、`ThinPlatformSurfaceVisual` 与 `DashGateLintelVisual` 必须可见但禁用碰撞。
- 训练目标和入口地标必须按真实可见像素底边落在 `y=160`，不能按纹理框或旧 authoring bounds 猜位置。
- 所有可踩面必须来自 `TerrainCollisionVisual` 或 `PlatformCollisionVisual`，不能靠隐藏旧碰撞撑住。
- 背景、装饰、前景、门框层必须 `collision_enabled=false`，且密度低到不会被误读成路。
- 门口前后必须各有安全落点，门上沿必须有 thin solid 语义，避免“装饰挡路”。
- 断崖 / 平台边界必须有 cap，不再出现悬浮碎块或空气瓦片。
- 主路必须是一条连续 23 格 run；平台必须是一条连续 2 格 one-way run，并有左右 cap。
- `GroundSurfaceVisual` 必须只覆盖主路 23 格，且只使用 left / center / right 三类地面件；不能循环整排混合素材。
- `ThinPlatformSurfaceVisual` 必须只覆盖跳台 2 格并使用 `tutorial_jump_platform_visual_ai02`；`DashGateLintelVisual` 必须只覆盖 dash 门低顶 2 格并使用 `tutorial_dash_gate_lintel_visual_ai01`。两个 `asset_id` 的允许物理角色互斥，禁止再次合并。
- `DoorVisual` / `BackgroundVisual` / `DecorVisual` / `ForegroundVisual` 在本教学房内保持空 TileMap，不再铺孤立门框、小台座、重复墙件或地面下碎石。
- `GroundUnderlayVisual` 必须隐藏，不能用带格线底纹冒充连续主路。
- 教学房背景只能有一个可见完整覆盖实例；重复背景必须隐藏，不能出现竖向拼接缝或镜头右侧露空。
- 跳跃平台本身承担第二段地标，不再在落点额外摆石块；Air Dash 地标必须安装在实体低顶上方，不得变成路面障碍。
- 所有隐藏的历史 TileMapLayer 也必须显式 `collision_enabled=false`，不能留下空气墙。
- `test_walkable_surface_visual_collision_alignment.gd` 从生产世界图配置读取全部 44 房：38 个正式 TileMap 房逐格核对真实纹理 alpha 顶沿与碰撞多边形，6 个 Stage25 静态 Floor 房核对可见 Polygon 与 CollisionShape 顶沿；同时反向汇总 `asset_id -> physics_affordance`，同图跨互斥角色立即失败。2026-08-09 新鲜报告覆盖 `1973` 条记录，`one_way_platform=293`、`thin_solid=2`、`failed=0`，新增房间必须进入同一审计。
- 同一专项测试还会反向枚举 exposed terrain、所有 CollisionObject2D/TileMapLayer，并用教程薄平台左右内外四点 PhysicsServer 落体探针验证实际接触边缘。运行态证据由 `capture_walkable_surface_2d_review.gd` 在 `--debug-collisions` 下生成 44 张逐房总览和带 SHA-256 的 JSON；这些自动证据不替代真人路线读值签核。
