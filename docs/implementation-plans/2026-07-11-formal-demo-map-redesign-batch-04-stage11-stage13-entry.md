# Formal Demo Map Redesign Batch 04 - Stage11 / Stage13 Entry

## 目标

重做 Stage11 终点大厅，并完成 Stage13 入口、远程敌和瘴气危险前三房的正式入口链。

## 房间蓝图

- Stage11 End `18x8`：完成、重开、继续三个地面标识与安全大厅。
- Stage13 Entry `20x8`：区域 checkpoint、背景揭示和观察平台。
- Stage13 Caster `24x9`：三层远程压制、清敌门和安全出口。
- Stage13 Miasma `22x8`：下层危险带、两段上层规避路线。

## 关键改动

- Stage11 更新相机、start / return spawn 和三个标识位置。
- Stage13 三房补反向连接、安全 spawn 和正式 TileMap collision / surface。
- Caster 新增正式清敌门；Miasma 复用现有 hazard VFX 并提高到可读范围。
- `miasma_marsh_tileset_ai01` 仍只作隐藏来源引用，不进入正式道路。
- 无新增 Image Gen。

## 验证

- Batch4 `4/4` tests，`183` asserts。
- Stage11 / Stage13 / Stage14 / Stage16 / formal remap：`63/63` tests，`1515` asserts。
- 六张运行态截图报告 `ok=true`。
- Godot import 通过。
