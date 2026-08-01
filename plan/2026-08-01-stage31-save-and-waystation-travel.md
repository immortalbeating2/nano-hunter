# Stage31 单档存档与双驿站传送计划

设计真源：`spec-design/2026-07-31-post-stage26-north-star-gap-and-stage27-32-roadmap.md`
执行清单：`docs/implementation-plans/2026-08-01-stage31-save-and-waystation-travel.md`

## 目标

让主菜单 Continue 恢复真实进度，并在已发现的 Stage11 镇妖驿站与雷泽前哨之间提供受门控的双点传送。

## 冻结数据契约

- 文件：`user://north_star_save.json`；上一有效档：`user://north_star_save.backup.json`；schema `version = 1`。
- 只持久化 Main 已持有或 Stage30 明确新增的权威状态：checkpoint room / spawn、完成标记、Air Dash / 风印 / 雷吸收、元素 / 姿态、探索与回访奖励、三组悬赏状态、可用 / 装备 Build、story event、visited rooms、Stage15 / Stage30 Boss 与区域关键状态、已发现 travel points。
- 不持久化瞬时状态：当前位置、速度、生命、攻击 / 序列计时、暂停、UI 面板、临时受击和当前房间局部动画帧。
- 读取只接受白名单字段与支持版本；未知 ID 丢弃，类型错误 / 路径越界 / JSON 损坏视为无效档，不应用半份状态。

## 实施顺序

1. 登记 `NS31-PersistenceTravelUI`，冻结 save / corrupted / travel / checkpoint 图标与提示音。
2. 在 Main 增加最小 `build_save_snapshot()` / `apply_save_snapshot()`；序列化直接消费现有字典和快照，不建立 SaveGame 领域镜像。
3. 用 FileAccess / JSON 写临时文件，校验可回读后再轮换 backup 与正式档；失败时保留上一有效档并返回错误结果。
4. 启动时只检查有效性并更新 Continue；点击 Continue 后才应用完整状态并从 checkpoint 载入。损坏档显示明确提示，可安全 New Game，不自动覆盖。
5. checkpoint、关键奖励 / Boss / bounty 回交后触发保存；失败只提示，不中断当前会话。
6. 将 Stage11 与 Stage25 入口 checkpoint 分别登记为 `waystation_main`、`thunder_outpost`；目标房已访问后才可从驿站面板传送，统一调用 Main 的房间切换入口。
7. 传送前保存，传送后刷新 checkpoint / HUD；门控校验失败时不切房、不改存档。

## 主要触点

- `scripts/main/main.gd` 的运行状态、checkpoint、房间切换和公开快照。
- `scripts/ui/demo_shell.gd` / `scenes/ui/demo_shell.tscn` 的 Continue 与 DetailPanel。
- Stage11 与 Stage25 entry 的 checkpoint / 交互节点。

## 验证

新增 Stage31 正常档、关闭重开、旧版本、损坏 JSON、错误类型、未知 ID、写入失败、backup、Continue、未发现 / 已发现传送和门控绕过测试；Stage23-30 邻近组合、递归全量、import、smoke、Gate26M 与 `git diff --check`。

## 退出标准

关闭程序后从正确 checkpoint 恢复全部声明状态；无效档不崩溃、不污染当前进度、不覆盖 backup；传送仅有两点且不能绕过未解锁内容。

## 非目标

不做多存档槽、云同步、跨平台迁移、任意房间传送、复杂迁移框架或存储加密。
