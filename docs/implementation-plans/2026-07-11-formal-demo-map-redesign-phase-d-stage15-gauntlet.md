# Formal Demo Map Redesign Phase D - Stage15 Gauntlet

## 目标

把 `stage15_mixed_gauntlet_room` 从 `15x6` 单层三敌横排，重做为 `26x9` 正式战斗场样板；保留三类敌人、全清门控、挑战支路、checkpoint、Boss 出口与 HUD 契约。

## 执行清单

- [x] 冻结近战区、冲锋通道、上层规避台、空中敌人层、挑战支路与清场门安全区。
- [x] 用显式网格生成连续主地面和三段有明确用途的 one-way 平台。
- [x] 将三类敌人分别放入 `x=64 / 448 / 832` 的独立战斗段落。
- [x] 把挑战支路放到左上平台，避免主线出生点自动触发。
- [x] 单张 Boss arena 背景覆盖完整 `26x9` 房间，隐藏旧材质大图和随机视觉试铺。
- [x] 保留三敌全清开门、challenge branch、checkpoint、Boss 连接和恢复充能 HUD。
- [x] 验证冲锋敌只在同高度通道触发，上层平台可规避；空中敌与右侧平台形成独立层。
- [x] 完成 GUT、Godot import、四视角运行态截图和人工构图复核。

## 房间蓝图

- 相机边界：`Rect2i(-512, -288, 1664, 576)`，即 `26x9` 个 64px 单位。
- 主地面：`x=-8..17, y=3`，完整覆盖入口、三段遭遇和 Boss 门出口。
- 挑战支路平台：`x=-7..-4, y=2`；触发点 `(-352, 104)`。
- 冲锋规避平台：`x=5..8, y=2`；Ground Charger 位于 `(448, 216)`。
- 空中战平台：`x=11..14, y=2`；Aerial Sentinel 位于 `(832, 104)`。
- Basic Melee 位于 `(64, 216)`；Gate 位于 `(1024, 168)`；Exit 位于 `(1104, 160)`。

## 验证结果

- Stage15 gauntlet template GUT：`5/5` tests，`309` asserts。
- Stage15 GUT：`17/17` tests，`402` asserts。
- 运行态复核：`stage15_gauntlet_formal_room_review`，`ok=true`。
- Godot import：通过。

## Completion Criteria

- 三类敌人不再同层横排，每类都有独立空间职责。
- 支路不挡主线，玩家主动上平台才进入挑战入口。
- 冲锋通道有可学习的同高度触发与上层规避关系。
- 空中敌人可从右侧平台接敌，不与地面敌人完全重叠。
- 三敌全清后门碰撞与视觉同步打开，门前后地面连续。
- 背景不出现重复硬边，旧灰盒碰撞和旧试铺不再参与运行时。
