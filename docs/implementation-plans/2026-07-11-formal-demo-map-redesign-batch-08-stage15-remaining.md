# Formal Demo Map Redesign Batch 08 - Stage15 Remaining

## 目标

完成 Stage15 Pressure、Challenge、Boss、Completion 四房，和已验收 Mixed Gauntlet 一起形成正式 Demo 战斗高潮链。

## 房间蓝图

- Pressure `24x9`：封印焦点、双敌分层和全清门。
- Challenge `26x10`：地面瘴气、三层绕行、双敌全清与门后奖励。
- Boss `28x10`：宽地面、左右规避平台和中央 Seal Guardian。
- Completion `18x8`：上层封印完成装置和进入 Stage16 的短大厅。

## 关键改动

- Pressure 新增全清门，Ground Charger 与 Miasma Caster 分居下层 / 高层。
- Challenge 扩大危险绕行和敌人间距，奖励放在门前右侧安全区。
- Boss arena 从旧约 864px 地面扩为 28 格，旧方向稿、预警图和动画预览隐藏但保留资源引用。
- Completion 隐藏整张 reusable props preview，只保留 seal、左右 chain anchor 和正式背景。
- Gauntlet 增补 Boss return spawn；四房补 previous link、LeftExitZone 和安全 spawn。

## 验证

- Batch8 `5/5` tests，`193` asserts。
- Stage15 `17/17` / `393` asserts；Stage16 `20/20` / `529` asserts；formal remap `8/8` / `184` asserts。
- 六张运行态截图报告 `ok=true`：Pressure / Challenge 清场门、Boss 击败到 Completion、Completion 到 Stage16 均通过。
- Godot import 与目标文件 `git diff --check` 通过。

## 下一步

进入最终 Batch 9，重做 Stage16 五房并完成 `39/39` 房；随后执行完整主流程试玩、全房截图审计和最终文档收口。
