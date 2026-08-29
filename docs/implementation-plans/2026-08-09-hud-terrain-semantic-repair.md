# HUD 内容安全区与地形资产语义专项修复执行清单

权威设计：`spec-design/2026-08-09-hud-terrain-semantic-repair.md`

本轮是非 Stage 专项修复，不写入根目录 `plan/`。

## Checkpoint 0：红灯与范围

- [x] HUD 测试改为读取 StyleBox content margins，并证明当前 raw TextureRect 方案失败。
- [x] 地形测试改为 top-to-top，证明教程实体门楣两格约 `22px` 错位。
- [x] 全 44 房收集 `asset_id -> physics role`，证明旧薄平台资产跨 `one_way_platform / thin_solid`。

## Checkpoint 1：独立资产与接入

- [x] 使用官方内置 `image_gen` 分别生成水平单向跳台与实体封印门楣原图。
- [x] 以 `generate2dsprite` 的透明底 / 格位 QC 处理为 3 格 strip，逐张 `view_image` 复核。
- [x] 新 TileSet 写入唯一 `asset_id`、`physics_affordance` 和 content-top 契约。
- [x] 所有普通薄平台迁移到单向跳台资产；教程门楣迁移到独立层和独立资产。

## Checkpoint 2：HUD 内容安全区

- [x] Prompt / Battle / Element 三面板改用 NinePatch StyleBoxTexture。
- [x] 移除全尺寸 raw art TextureRect，布局从实际 content safe rect 派生。
- [x] 更新 HUD 捕获报告，使 `ok=true` 必须包含所有可见文字 / 图标位于内容安全区。

## Checkpoint 3：全地图排查

- [x] 对 44 房重新生成二维报告，逐资产列出物理角色、top gap 与房间来源。
- [x] 修复全部未豁免顶缘错误和同图异物理角色；零新增问题也要记录明确统计。
- [x] 保留门禁、Area、移动体与 retired authoring bounds 的既有边界。

## Checkpoint 4：验证与留痕

- [x] Godot import、HUD / 教程地形 / 全房地形定向 GUT。
- [x] 资产 package / UI binding 审计和递归全量 GUT。
- [x] Windows/D3D12 实机截图覆盖教程跳台、门楣和 HUD 正常 / 最长文案状态。
- [x] 更新 asset manifest、地形契约、状态与当日日志；保留真人审美和 Gate26H 边界。

## 最终证据

- 全地图二维审计：`44` 房、`38` 个正式 TileMap 房、`6` 个静态 Floor 房、`1973` 条记录、`711` 个碰撞清单项、`failed=0`；两个例外仍只是在教程外边界墙顶明确登记的 `outer_boundary_wall_top`。
- HUD 真窗口：`7` 档布局、`5` 种提醒状态、`1` 个共享动态强调层，`ok=true`；横框内容安全边距为 `24 / 64 / 24 / 24px`。
- 严格资产包：`80` 个队列项、`6` 个 TileSet、`80` 个 runtime catalog 资源、`0` unsafe source candidates；新地形资产继续受人工条款与 final-art gate 阻断。
- 递归 GUT：`51` scripts、`339/339` tests、`10020` assertions；Godot `4.6.3` import 与主场景 smoke 退出码均为 `0`。
