# Stage31 北极星 Alpha 技术候选 Release Notes

## 核心闭环

- 世界图保持 `44` 个正式房间、`8` 条远端连接，不为存档或传送扩房。
- 核心战斗保持雷 / 风两元素、疾印 / 御印两姿态，以及风→雷追击贯穿、雷→风散射破势两种两步序列。
- Stage27 补入 Luna 姿态 / 空中 / 序列表现、四类技能 VFX，以及 Seal Guardian 正式动作 / VFX 技术候选。
- Stage28 把 Stage11 镇妖驿站、三悬赏、四 Build / 两槽和三段固定事件升级为正式表现技术候选。
- Stage29–30 把六房雷泽替换为专属区域表现，并加入雷蚀獠、两阶段夔影雷骸、妖雷吸收、雷兽妖核和回访雷幕捷径。

## Stage31 存档与传送

- 正式路径为 `user://north_star_save.json`，上一有效档为 `user://north_star_save.backup.json`，schema `version = 1`。
- 保存白名单覆盖 checkpoint、完成态、能力、元素 / 姿态、回访 / 探索收益、悬赏、Build、剧情、visited rooms、Boss 与 travel points；生命、速度、攻击 / 序列计时、暂停与 UI 面板不保存。
- 保存失败不会终止当前会话；备份轮换失败时保留上一主档，不应用半份状态。
- Continue 只在主档或备份有效时启用。损坏主档会显示“备份可继续”；双档无效会禁用 Continue，并允许 New Game 生成新有效档。
- 双点传送只包含 `waystation_main` 与 `thunder_outpost`；未发现目标、非驿站起点、当前点重复选择都不会切房或改档。

## 手柄与 UI

- 主菜单、暂停菜单和复用 DetailPanel 保持同一套键盘 / 手柄路径：十字键或左摇杆导航、A 确认、B 返回、Menu 暂停。
- Continue 无有效档时退出焦点链；暂停菜单仅在固定驿站启用“驿站传送”。
- Godot MCP Pro 发现“可传送项取得焦点但仍在 ScrollContainer 外”后，已在传送面板显示一帧后把焦点项滚入可视区。
- 快速连续切房曾允许旧房间延迟 checkpoint 信号覆盖新房间；Main 现在在移除旧房前统一断开其房间与子节点信号。

## 验证

- Stage31：`5/5` tests、`78` assertions。
- Stage23–31 相邻组合：`42/42` tests、`540` assertions。
- 递归 GUT：`48` scripts、`322/322` tests、`8865` assertions。
- Godot `4.6.3` headless import、主场景 smoke、strict asset package 与 `git diff --check` 通过；strict package 为 `78` queue、`78/78` structural-ready、`55/78` final-ready、`23` manual review、`0` unsafe / outside。
- Godot MCP Pro 生产 Main 覆盖无档 / 有效档 / 备份 / 双档损坏、Continue 全状态恢复、快速切房 checkpoint、暂停菜单实际 `ui_down/ui_accept`、双站双向传送和焦点可视滚动；最终 `editor errors=0`。
- 本轮临时存档、运行场景、三个 MCP autoload 与精确 Godot editor 进程树均已清理，`project.godot` 无差异。

## 音频与美术边界

- Stage31 新增四条 3 秒 Stable Audio scratch SFX；Stage27–31 全部音频生成均为串行并发 `1`，硬上限 `<4`。
- scratch WAV 已通过解码、格式与 SHA256 校验，但尚未真人试听、裁切、响度 / loop / stacking、授权复核或运行时绑定。
- Stage31 UI 为复用 Stage16 / Stage28 运行资产的确定性 `4x4` 合成图集，SHA256 为 `dcd3c7496a67339440ac7b08ba75c3e26ded8e1ea4f797d9d91b370aba62d715`。
- 自动化与 MCP 不替代 Luna / Boss 动作质量、VFX 遮挡、32px / 64px UI 可读性、无 HUD 理解度和真实 21:9 审美签核。

## 当前阻断

- Gate26H 尚未由真人签署。
- Windows export、设置页、最终 mix、发布授权总检与 Beta 包属于 Stage32；本候选不冒充可发布构建。
