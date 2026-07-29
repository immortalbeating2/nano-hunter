# Formal Demo Map Redesign Batch 02 - Stage9

## 目标

把 Stage9 五间旧 `15x6` 单层房重做为首个具有连续节拍和房间轮廓差异的小区域，同时保留敌人、开关、门控、checkpoint 和 Stage10 连接契约。

## 房间蓝图

- Entry `18x6`：区域揭示、自动 checkpoint、单个观察平台。
- Combat `20x8`：近战首战、两处规避平台、清敌门。
- Charger `22x8`：长直冲锋带、两处逃生台、击败后点亮 checkpoint。
- Switch `20x9`：两级上行平台、上层开关、下层门与安全出口。
- Final `24x9`：上层近战、下层冲锋、双层混合遭遇、全清门。

## 实现边界

- Stage9RoomBase 新增每房 `camera_limits` 导出字段，默认值保持旧契约，后段继承房不受影响。
- 五房补齐 previous room、previous spawn、LeftExitZone 和稳定 return spawn。
- 正式 TileMap collision 与 visual-only surface 分层复用已验收资源；旧 shape Floor / Wall、随机 formal decor 和材质大图退出运行态。
- 复用单张瘴泽背景并按房间宽度改变取景；不启用已判定为 source-only 的 `miasma_marsh_tileset_ai01`。
- 不新增 Image Gen 资产。

## 验证

- Batch 2：`5/5` tests，`320` asserts。
- Stage9-10、Stage13-16、formal remap：`89/89` tests，`2042` asserts。
- 七张运行态截图报告 `ok=true`。
- Godot import 通过。

## 退出条件

- 五房职责、长度和层级可区分。
- 脚底、平台、门、开关、checkpoint 和敌人空间在运行态可读。
- 双向连接、死亡 checkpoint 和 Stage10 入口未回归。
