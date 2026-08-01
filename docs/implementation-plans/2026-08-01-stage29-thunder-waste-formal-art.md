# Stage29 雷泽荒原正式美术与区域机制清稿执行清单

## 设计与资产

- [x] Stage29 设计边界已在北极星路线 spec 中冻结。
- [x] 正式计划：`plan/2026-08-01-stage29-thunder-waste-formal-art.md`。
- [x] Stage28 退出门通过：技术候选提交 `7fa774e`，真人签核仍按批准边界延后。
- [x] 登记 `NS29-ThunderWasteBackground / Environment / StateVFX / Audio` 及来源 / 授权 / 状态。
- [x] 背景、TileSet、安全 / 危险地表、props、雷云、祭柱 / 屏障状态通过运行候选门；音频只进入 scratch 试听队列。

## 六房接入

- [x] 基类接入专用雷泽显示资源，节点路径、碰撞和 marker 坐标不变。
- [x] 入口、洼地、坡道、岔口、祭柱、远眺逐房完成构图与唯一地标。
- [x] 关键雷暴 / 祭柱 / 屏障 Polygon 已由正式状态资产 / VFX 替换。
- [x] 入口 checkpoint 显示为雷泽前哨并登记 `thunder_outpost`，但无传送功能。
- [x] 氛围、接地与探索 BGM 以并发 `1` 生成 scratch 候选；试听、peak / loop / mix、授权和 runtime 绑定明确留 Gate26H。

## 验证

- [x] Stage19 / 25 / 26 / 29 `20/20`、`464` assertions；递归 GUT `46` scripts / `312/312` / `8732` assertions，六房引用与碰撞权威通过。
- [x] 原生 2K、720p、21:9 safe-boundary、无 HUD 自动读值、Godot `4.6.3` import / smoke、MCP `editor errors=0` 与 strict 资产审计通过；真实宽屏与审美留 Gate26H。
- [x] 瘴泽主背景和关键纯色 Polygon 退役检查通过，MCP 发现的 atlas 浮点行号错裁已回归修复；状态、时间线、日志已更新。
