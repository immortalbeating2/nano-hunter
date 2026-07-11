# Formal Demo Map Redesign Batch 06 - Stage13 Branches / Goal

## 目标

完成 Stage13 剩余 Branch Hub、Resource Branch、Challenge Branch、Return、Goal 五房，使瘴泽区域的分支、汇流和终点成为可读的正式 Demo 链路。

## 房间蓝图

- Branch Hub `24x9`：下层资源路线、上层挑战路线和地面主线路线三分叉。
- Resource Branch `18x8`：无敌人、两级上行、低风险奖励。
- Challenge Branch `24x9`：三层法师战、清敌门和门后奖励。
- Return `20x8`：支路与主线汇流后的降压穿越。
- Goal `20x8`：上层祭器与进入 Stage14 的区域终点。

## 关键改动

- 五房补齐 previous room、LeftExitZone、安全 spawn、独立相机与正式 TileMap collision / surface。
- Hub 复用现有三类 route marker，并把触发点放到不同高度，避免图标横排。
- Challenge 新增正式清敌门，敌人未击败时无法直接取门后奖励和离开。
- Return 统一回到 Hub，避免两条支路要求一个房间维护多重 previous target。
- Goal 保留原 Stage14 入口契约，只把祭器和触发区移到明确上层平台。
- 无新增 Image Gen。

## 验证

- Batch6 `5/5` tests，`214` asserts。
- Stage13 `13/13` / `340` asserts；manual closure `1/1` / `22` asserts。
- Stage14 `16/16` / `389` asserts；Stage16 `20/20` / `529` asserts；formal remap `8/8` / `184` asserts。
- 六张运行态截图报告 `ok=true`，资源奖励、挑战清敌门和 Goal 到 Stage14 的真实切房均通过。
- Godot import 与目标文件 `git diff --check` 通过。

## 下一步

进入 Stage14 剩余 Shrine、Backtrack Hub、Loop Return 三房；Stage14 Gate 正式能力门样板已完成，不重复重做。
