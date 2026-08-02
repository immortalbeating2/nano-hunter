# Stage31 单档存档与双驿站传送执行清单

## 设计与资产

- [x] version 1 字段、文件、backup、白名单和瞬时状态边界已冻结。
- [x] 正式计划：`plan/2026-08-01-stage31-save-and-waystation-travel.md`。
- [x] Stage30 退出门通过。
- [x] 登记并接入 `NS31-PersistenceTravelUI`；其为 Stage16 / 28 运行资产的确定性合成，真人小尺寸 / 授权签核留 Gate26H。

## 存档

- [x] Main 构建 / 应用白名单存档快照，不复制第二份进度模型。
- [x] temp 写入、回读校验、backup 轮换和正式替换顺序可恢复。
- [x] checkpoint、关键奖励 / Boss / bounty 回交触发保存；失败不终止当前会话。
- [x] Continue 仅在有效档存在时启用，点击后从存档 checkpoint 载入。
- [x] 损坏 / 不支持版本档明确提示，可 New Game，且不覆盖 backup。

## 双点传送

- [x] `waystation_main` 与 `thunder_outpost` 有稳定 ID、房间 / spawn 映射和发现状态。
- [x] 目标未发现时不可传送；已发现后仅从驿站面板调用 Main 切房入口。
- [x] 传送前保存、传送后刷新 checkpoint / HUD；失败不切房、不改档。

## 验证与交付

- [x] 正常、关闭重开、旧版本、损坏 JSON、错误类型、未知 ID、写失败、backup、Continue 测试通过：Stage31 `5/5`、`78` assertions。
- [x] 未发现 / 已发现、两方向、门控绕过与重复传送测试通过；MCP 额外覆盖真实暂停菜单输入与焦点可视滚动。
- [x] Stage23-30 邻近组合、递归全量、import、smoke、Gate26M 与 `git diff --check` 通过：全量 `48` scripts、`322/322`、`8865` assertions。
- [x] 冻结 Stage31 技术候选，更新状态 / 时间线 / 日志，并生成 Gate26H 真人试玩清单；真人签核本身保持待办。
