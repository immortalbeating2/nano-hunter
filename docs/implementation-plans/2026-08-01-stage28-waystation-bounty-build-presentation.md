# Stage28 镇妖驿站、悬赏与 Build 正式表现执行清单

## 设计与资产

- [x] Stage28 设计边界已在北极星路线 spec 中冻结。
- [x] 正式计划：`plan/2026-08-01-stage28-waystation-bounty-build-presentation.md`。
- [x] Stage27 技术候选退出门通过；音频与美术真人签核继续留在 Gate26H。
- [x] 登记 `NS28-WaystationBackground`、`NS28-WaystationWorld`、`NS28-BountyBuildUI` 与 `NS28-Audio` 的来源、hash、运行输出和签核状态。
- [x] 驿站背景、三状态榜牌、驿卒四帧、3 bounty、4 Build 与 2 slot 资产通过结构和自动小尺寸门。
- [ ] 正式美术审美、32px / 64px 真人可读性与授权由 Gate26H 签核。

## 运行接入

- [x] Stage11 只替换显示层，出口、checkpoint、碰撞和 Stage25 门控不变。
- [x] bounty / build snapshot 提供稳定 icon / state，仍使用现有三悬赏、四 Build 与两槽数据。
- [x] DetailPanel 显示图标、槽位、装备 / 完成状态，键鼠与手柄复用同一操作入口。
- [x] 首次到站、三榜回交、雷泽归来三段事件有稳定 ID、可关闭且不会重复发奖。
- [x] 以并发 `1` 串行生成并验证 `5` 个 Stage28 scratch WAV，保留 prompt / seed / SHA256；硬上限 `<4`。
- [ ] 真人试听、peak / loudness、循环缝、叠爆和授权接受后，再接入榜单、奖励、装备、NPC 与环境 SFX。

## 验证

- [x] Stage23 / 24 / 25、Stage28 UI / 事件专项通过；历史测试已迁移到新的事件与视觉契约。
- [x] Godot MCP Pro 在生产主场景用实际 `InputEventJoypadButton` 复核主菜单、悬赏与 Build 焦点；发现并修复“第一项直接跳到返回”的共享焦点链问题。
- [x] 三段事件去重、暂停 / 切房、import、smoke、strict 资产审计和 MCP 最终 `editor errors=0` 通过，临时 autoload / 本轮 editor 已清理。
- [x] 本轮生产代码修改后的递归全量 GUT 为 `45` scripts / `309/309` tests / `8642` assertions；Godot `4.6.3` import 与主场景 smoke 通过。
- [x] 更新状态、时间线、当日日志与 Stage28 资产矩阵；最终 diff / 暂存范围门禁在提交前执行。
- [ ] 真人首次理解度、手柄舒适度、32px / 64px 可读性、音频与美术审美由 Gate26H 最终签核。
