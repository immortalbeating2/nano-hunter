# Formal Demo Map Redesign Batch 01

## 目标

把 `test_room`、`combat_trial_room`、`goal_trial_room` 从历史灰盒 / 旧试铺状态推进为可验证的机制沙盒与首战短链，验证正式样板规则能否安全推广到早期房间。

## 范围

- `test_room`：保留 Stage1-4 精确 shape collision，只清理错误试铺层，并按真实 shape bounds 补可读顶沿、端点 cap 与墙体质量。
- `combat_trial_room`：改为 `18x6` 单敌首战房，连续主地面、入口反应区、清敌锁门和门后安全区明确。
- `goal_trial_room`：改为 `20x8` 目标房，下层战斗推进、右侧上层目标平台和出口安全区明确；完成判定必须真正接近上层目标。

## 不做项

- 不改变 Stage1-7 的攻击、冲刺、敌人、门控和房间连接契约。
- 不把 `test_room` 包装成主线正式房；它继续是精确机制测量沙盒。
- 不新增 Image Gen 资产，不把旧随机 formal decor 复制到其它房间。

## 实现

- 复用已验收的正式碰撞 TileSet、神龛地面表面、薄平台、门禁、背景和敌人资产。
- `combat_trial_room` / `goal_trial_room` 由 `TerrainCollisionVisual` / `PlatformCollisionVisual` 承担静态地形碰撞；表面层保持 visual-only。
- 背景底色按单张背景真实边界覆盖，消除半透明矩形硬边。
- 出生点使用 Luna 落地后的稳定中心坐标，不使用 TileMap 单元行或可踩顶面坐标代替。

## 验证

- Batch 1 GUT：`4/4` tests，`226` asserts。
- Stage1 / Stage3 / Stage4：`25/25` tests，`119` asserts。
- Stage6：`7/7` tests，`78` asserts。
- Stage7：`3/3` tests，`52` asserts。
- formal remap：`8/8` tests，`184` asserts。
- 五张运行态截图与 JSON：`ok=true`。
- `godot --headless --path . --import` 通过。

## 退出条件

- 三房逻辑、碰撞、重试和连接回归通过。
- Luna 脚底与可见表面一致，门前后和目标平台有安全落点。
- 背景无重复拼接或矩形硬边，旧随机 tile 不再显示。
- 下一批可进入 Stage9 五房区域级推广。
