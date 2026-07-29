# Formal Demo Map Redesign Batch 07 - Stage14 Remaining

## 目标

完成 Stage14 Shrine、Backtrack Hub、Loop Return 三房，和已验收 Air Dash Gate 一起形成完整能力获得、能力验证、回溯收益与进入 Stage15 的正式链路。

## 房间蓝图

- Shrine `20x8`：单一能力神龛焦点与门前安全地面。
- Backtrack Hub `26x10`：三个收益点沿三段递增高度分布。
- Loop Return `20x8`：两段上行与上层 Stage15 目标。

## 关键改动

- 三房使用正式 TileMap collision / surface，旧 Floor / Wall、整房间源图和随机 decor 退出运行态。
- Shrine 隐藏旧整房概念图、瘴气房图和 tile sheet，只保留区域背景、神龛、门预览和 Air Dash 预览。
- Hub 三个奖励不再横排，分别放在 `y=184 / 120 / 56` 三层可踩面。
- Loop Return 首轮运行图发现 GoalZone 沿用旧地面高度，marker 挂在平台下；已把视觉与触发一起移到上层平台。
- Stage13 Goal 与 Stage14 Gate 补右侧安全 return spawn，完成双向连接。

## 验证

- Batch7 `4/4` tests，`137` asserts。
- Stage14 `16/16` / `389` asserts；Stage15 `17/17` / `402` asserts；Stage16 `20/20` / `529` asserts；formal remap `8/8` / `184` asserts。
- 五张运行态截图报告 `ok=true`：神龛授予 Air Dash、三个收益累计为 3、Loop Return 真实切入 Stage15。
- Godot import 与目标文件 `git diff --check` 通过。

## 下一步

进入 Stage15 剩余 Pressure、Challenge、Boss、Completion 四房；Mixed Gauntlet 正式战斗样板已完成。
