# Formal Demo Map Redesign Batch 03 - Stage10

## 目标

把 Stage10 三间同规格单层房重做为主线空中战、紧凑奖励支路和多层挑战 arena，并保证支路返回与 Stage11 推进成立。

## 房间蓝图

- Aerial `24x9`：三层平台、显式支路入口、空中敌与下层冲锋敌。
- Branch `18x8`：两级上行、恢复点、奖励、单敌门和主线 return spawn。
- Challenge `26x10`：三层三敌空间，全清后开门并进入 Stage11。

## 关键改动

- 三房使用正式 TileMap collision + visual-only surface，旧 Floor / Wall、随机 decor 和材质大图退出运行态。
- 主房补 Stage9 previous link；支路和挑战房补主房 previous link、LeftExitZone 与安全 spawn。
- 支路返回改用 `stage10_aerial_return`，不回主房开头、不立即重触发支路。
- Challenge 启用 `require_all_enemies_defeated`，修正旧任意一敌死亡开门规则。
- 复用现有瘴泽背景、敌人、门禁、恢复点、奖励和 VFX，不新增 Image Gen。

## 验证

- Batch3：`3/3` tests，`154` asserts。
- Stage10 / 11 / 12 / 16：`46/46` tests，`912` asserts。
- 五张运行态截图报告 `ok=true`。
- Godot import 通过。
