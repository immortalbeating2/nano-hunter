# Stage29 雷泽荒原正式美术与区域机制清稿计划

设计真源：`spec-design/2026-07-31-post-stage26-north-star-gap-and-stage27-32-roadmap.md`
美术基线：`docs/assets/2026-07-31-post-stage26-north-star-art-gap-assessment.md`
执行清单：`docs/implementation-plans/2026-08-01-stage29-thunder-waste-formal-art.md`

## 目标

保持 Stage25 六房拓扑和机关逻辑，把冷色瘴泽复用与关键 Polygon 灰盒替换成正式雷泽区域表现。

## 实施顺序

1. 登记 `NS29-ThunderWaste`，用六房真实摄像机边界冻结风格板、2-3 层背景、TileSet、安全 / 危险地表、props、雷云和机关状态表。
2. 先在房间基类接入共享雷泽背景 / 地形资源，保持所有 StaticBody / CollisionShape / 门 / marker 的节点路径与坐标不变。
3. 逐房替换入口、雷雨洼地、坡道、岔口、祭柱、远眺的构图和地标；不增加第七房。
4. 将雷暴、接地祭柱、屏障和出口提示的关键纯色 Polygon 替换为正式 startup / active / grounded / disabled VFX，逻辑仍由 Stage25 脚本驱动。
5. 将入口 checkpoint 清稿为“雷泽前哨”，预留 Stage31 的 travel point ID，但本阶段不提供传送按钮。
6. 接入雷泽氛围与一条探索 BGM，经试听接受后绑定；校验循环点和切房不中断策略。

## 主要触点

- `scenes/rooms/stage25_thunder_waste_*` 六房与 `stage25_thunder_waste_room_base.tscn`。
- `scripts/rooms/stage25_thunder_waste_room.gd`、`stage25_storm_relay.gd`，只增加显示状态绑定。
- 雷泽专用 TileSet、背景、props、VFX 与音频资源。

## 验证

Stage25 专项、六房场景实例化与引用测试、视觉 / 碰撞对齐、16:9 / 2K / 21:9 截图、递归全量、import、主场景 smoke、Gate26M 和 strict 资产审计。

## 退出标准

六房不再以瘴泽背景作为主视觉，不再以大块纯色 Polygon 承担关键机关完成态；无 HUD 可区分安全地表、危险区、祭柱和出口；路线与碰撞结果不变。

## 非目标

不扩房、不加敌人 / Boss、不实现传送、不改世界图拓扑、不新增第三元素。
