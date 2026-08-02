# Stage31 北极星 Alpha 技术候选

## 候选状态

- 当前是可交 Gate26H 真人试玩的源码技术候选，不是 release-final，也没有 Windows 导出包。
- Preflight26A、Gate26M、Stage27、Stage28、Stage29、Stage30、Stage31 的批准范围均已实现并通过各自技术门禁。
- Gate26H 真人路线、手柄舒适度、美术审美、音频试听 / 授权和真实 21:9 仍为开放门禁；完成后才进入 Stage32 Beta Candidate 收口。

## 试玩入口

- Godot：`4.6.3`
- 主场景：`res://scenes/main/main.tscn`
- 主菜单“开始游戏”创建 version `1` 单档；有效档存在时“继续游戏”才可聚焦和启用。
- Editor debug build 的“DEBUG 北极星全能力巡检”可快速检查 Luna 全能力、两元素、两姿态、两序列和 Boss 表现；它不属于发布流程。

## 本候选新增

- `user://north_star_save.json` 单档与 `north_star_save.backup.json` 上一有效备份；写入采用 temp 回读校验、备份轮换、主档替换顺序。
- Continue 恢复 checkpoint、能力、元素 / 姿态、Stage14 回访、探索奖励、三悬赏、两槽 Build、剧情事件、地图发现、Stage15 / Stage30 Boss 与双驿站发现状态。
- 损坏主档可从有效备份继续；主档和备份都无效时 Continue 禁用，可安全开始新游戏。
- `waystation_main` 与 `thunder_outpost` 两个固定传送点；目标发现后只能从两处驿站面板双向传送，传送前后均保存 checkpoint。
- Stage27–30 的 Luna / Boss / VFX、镇妖驿站、雷泽荒原、雷蚀獠与夔影雷骸正式 Demo 技术资产均包含在候选中。

## 交付文件

- `release-notes.md`：候选内容、验证与已知边界。
- `gate26h-human-playtest-checklist.md`：真人首次路线、回访、手柄、美术、音频、存档与宽屏签核步骤。
- `candidate-manifest.json`：机器可读的候选状态、验证数字和开放门禁。

## 明确未完成

- Stage27–31 的本地音频只在 `D:/AI/audio/outputs/scratch/nano-hunter/stage27/` 至 `stage31/`；生成并发均为 `1`、硬上限 `<4`，尚未接受或接入 runtime。
- 资产治理为 `78/78 structural-ready`、`55/78 final-ready`；`23` 项继续等待真人审美 / 授权签核。
- 没有多槽、云同步、跨版本迁移、任意房传送、键位重绑定、最终 mix 或 Windows 发布包；这些不得从本候选状态推断为完成。
