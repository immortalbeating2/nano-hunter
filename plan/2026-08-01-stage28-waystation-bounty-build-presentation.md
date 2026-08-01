# Stage28 镇妖驿站、悬赏与 Build 正式表现计划

设计真源：`spec-design/2026-07-31-post-stage26-north-star-gap-and-stage27-32-roadmap.md`
美术基线：`docs/assets/2026-07-31-post-stage26-north-star-art-gap-assessment.md`
执行清单：`docs/implementation-plans/2026-08-01-stage28-waystation-bounty-build-presentation.md`

## 目标

让 Stage11 成为可一眼识别的镇妖驿站，并让第一次玩家仅靠世界提示和手柄焦点完成接榜、回交与两槽 Build 调整。

## 实施顺序

1. 登记 `NS28-Waystation`，冻结驿站构图、三状态悬赏榜、驿卒 idle / portrait、三悬赏图标、四 Build 图标和两槽状态。
2. 只替换 Stage11 显示层与 marker：正式背景 / 地形、榜牌 prop、驿卒；保留出口、checkpoint、碰撞和 Stage25 解锁逻辑。
3. 复用 Main 的三条固定悬赏和四件固定 Build 数据，为 snapshot 条目补稳定 `icon_id` / `state_id`，不建立新任务或物品模型。
4. 复用 DemoShell DetailPanel 和动态按钮，增加图标、槽位、状态与手柄焦点；保持键盘、鼠标和手柄同一路径。
5. 复用现有 story event 机制交付三段短事件：首次到站、三榜回交、雷泽归来；用稳定事件 ID 去重并允许关闭。
6. 用 `local-game-audio` 以串行并发 `1` 生成榜单、奖励、装备、NPC 与驿站环境 scratch 候选并登记；仅在 Gate26H 真人试听、清理和授权接受后接入运行时，不引入语音或通用对话插件。

## 主要触点

- `scenes/rooms/stage11_demo_end_room.tscn`、`scripts/rooms/stage11_demo_end_room.gd`。
- `scripts/main/main.gd` 现有 bounty / build / story snapshot。
- `scripts/ui/demo_shell.gd` 与 `scenes/ui/demo_shell.tscn` 现有 DetailPanel。

## 验证

Stage23 / 24 / 25 专项、新增 Stage28 UI 与事件测试、递归全量、import、主场景 smoke、Gate26M 手柄焦点链、32px / 64px 读值和 strict 资产审计。

## 退出标准

三悬赏、四 Build、两槽和三段事件拥有稳定且唯一的视觉状态；切房、暂停、关闭面板不会重复奖励或重复剧情；Stage25 路引门控不变。

## 非目标

不做随机悬赏、货币、商店、完整物品栏、NPC 群像、分支对话树或通用任务框架。
