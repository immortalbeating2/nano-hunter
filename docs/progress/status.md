# Nano Hunter Status

Last Updated: 2026-07-30

## Current Status

- 2026-07-30 完成 Stage23 镇妖驿站与悬赏榜：Stage11 新增可见榜牌触发区，DemoShell 复用 DetailPanel 提供“断瘴缉术 / 妖骨取证 / 封脉清障”三条固定悬赏；Main 统一保存 accepted / completed / turned-in 状态，分别观察 Caster 击败、`marsh_relic` 回收与雷→风散去封印脉冲。三条悬赏可独立接取、追踪、完成、回驿站回交，并最终解锁“雷泽荒原路引”；HUD 与世界图只读消费计数，重开清空，Stage11 短链完成仍不等同 Alpha 完成。Stage23 `5/5` / `42` assertions、Stage11/13/16/19/20/22/23 邻近组合 `62/62` / `1250`、递归全量 GUT `39` scripts / `284/284` tests / `8333` assertions；Godot `4.6.3` import、主场景 smoke、Windows/OpenGL 全流程运行探针与截图、编辑器错误 `0`、`git diff --check` 通过，临时 MCP autoload 已清理。本阶段未加入随机任务、货币、交易市集、对话树或正式存档。
- 2026-07-30 完成 Stage22 敌人与 Boss 元素反应：Player 只在目标显式支持时转发 Stage21 攻击上下文，最终生命 / 击败仍走原 `receive_attack(...)`。风→雷命中 Caster 会清除同房余弹，并在 Seal Guardian `close_pressure` 预警期直接清空护印进入既有 stagger；雷→风命中 Charger 会取消冲锋并退位，命中封印脉冲会把当前相位错回完整休止段。普通命中、风印斩弹和旧失败恢复保持不变。Stage22 `5/5` / `31` assertions、Stage3/6/9/13/15/17/20/21/22 邻近组合 `86/86` / `1308`、递归全量 GUT `38` scripts / `279/279` tests / `8291` assertions；Godot `4.6.3` import、主场景 smoke、Windows/OpenGL 四对象运行探针、Boss 真实 Player 命中与截图、编辑器错误 `0`、`git diff --check` 通过，临时 MCP autoload 已清理。Stage22 没有加入元素伤害表、普通敌人血条或新 Boss 阶段。
- 2026-07-30 完成 Stage21 元素、姿态与两步序列：Luna 现有雷 / 风两元素与疾印 / 御印两姿态，`Q` / `E` 切换；风→雷形成横向追击贯穿，雷→风形成纵向散射破势，两步窗口为 `2.0s`。元素与姿态由 Main 跨房保留，序列随玩家重建清空，重开恢复雷 + 疾；风印仍由 Stage10 奖励解锁。HUD 顶部安全区显示当前元素、姿态、序列、剩余窗口和反应名，攻击 VFX 同步元素色。Stage21 `5/5` / `47` assertions、Stage3/6/10/13/15/17/20/21 邻近组合 `88/88` / `1335`、递归全量 GUT `37` scripts / `274/274` tests / `8260` assertions；Godot `4.6.3` import、主场景 smoke、Windows/OpenGL 输入与三类战斗房运行态复核、`git diff --check` 通过，临时 MCP autoload 已清理。Stage21 不实现敌人专属元素反应，该范围进入 Stage22。
- 2026-07-30 新增北极星后续 Stage 路线计划：当前 Stage20 已完成 Alpha Demo 的银河城最小闭环，但距离北极星最大缺口仍是“元素序列连锁 + 符印姿态切换”。新增 `spec-design/2026-07-30-north-star-stage-roadmap.md`、`plan/2026-07-30-north-star-stage-roadmap.md` 和 `docs/implementation-plans/2026-07-30-north-star-stage-roadmap.md`；推荐后续顺序为 Stage21 `2 元素 + 2 姿态 + 2 步序列`、Stage22 敌人与 Boss 元素反应、Stage23 镇妖驿站 / 悬赏榜、Stage24 圣物 / 组件 Build、Stage25 雷泽荒原小型第二区域、Stage26 北极星 Alpha Candidate。该计划不修改运行时代码，也不替代每个 Stage 开始前的专属设计和执行清单。
- 2026-07-30 已将 `C:\Users\peng8\.codex\worktrees\d7ef\nano-hunter` 的 `codex/stage-17-animation-runtime-stabilization` 分支合入当前 `codex/upgrade-godot-mcp-1-15-hardening` 分支；d7ef 工作树未提交的 Stage18-20 内容已先收口为提交 `cc5df58`，当前分支的 Godot MCP 工具数量口径修正已保留。冲突只出现在进度文档，已保留两边日志并采用 Stage20 最新状态作为当前项目状态；尚未合并 `main` / push。
- 2026-07-28 完成 Stage20 六类银河城缺口闭环：Stage9 Switch 的 SC-01 改为首轮可用第二路线，Stage10 Branch 授予风印；Stage10 Challenge / Stage14 Gate 接入循环封印脉冲；Caster 发射可被风印斩散的定向腐瘴弹；新增风印 + Air Dash 的 SC-06（Stage13 Gate ↔ Stage14 Gate）；`marsh_relic` / `warden_sigil` 成为可切换的恢复 / 攻击距离 Build；Stage11 首次确认触发一次正式剧情事件。世界图现为 `38` 房、`3` 区域环、`6` 条远端连接，拓扑和条件仍由 JSON 驱动。Stage20 `6/6` / `60` assertions、邻近回归 `104/104` / `3332`、递归全量 GUT `36` scripts / `269/269` tests / `8213` assertions；Godot `4.6.3` import / smoke、世界图 JSON、资产包 strict audit、Windows/OpenGL MCP 六项运行态复核和 `git diff --check` 通过，`project.godot` 无临时 autoload diff。该结果闭环的是 Alpha Demo 六项最小生产切片，不等于完整商业银河城；尚无正式存档 / 快速旅行、多组交叉门、完整装备树、多角色剧情链或真人连续试玩签核。
- 2026-07-28 完成 Stage19 发现式地图美术与可维护性重构：使用 Image Generation 生成无文字 / 无拓扑宣纸铜框底板和非运行时组件母版；`38` 房、五区域、4 支路和 SC-01 至 SC-05 迁入独立归一化 JSON，旧五行蛇形矩形图改为佛龛符印节点、弧形墨线、金色断续捷径和相邻墨雾。DemoShell 按底板比例响应式扩展，`2560x1440` 运行态约 `1597x1100`；后续移动或改连房间只改 JSON，不需要重新生图。Stage19 `6/6` / `207` asserts、Stage16 `20/20` / `484`、递归全量 GUT `35` scripts / `263/263` tests / `8128` asserts，Godot import / smoke、asset package / provenance / source-safety strict、Windows/OpenGL 初始与全展开复核通过，编辑器错误 `0`。
- 2026-07-28 完成 Stage19 房间蓝图与探索地图收口：新增 `38/38` 正式房间八项核对矩阵，覆盖职责 / 平台、出入口、敌人、陷阱、门控、奖励和叙事；暂停菜单加入发现式地图，显示当前房、已发现房、相邻轮廓及 SC-01 至 SC-05 状态；Stage11 从旧 Demo 终点修正为左返 Stage10、右进 Stage13 的镇妖驿厅，完整 Demo 完成态只属于 Stage16。Windows/OpenGL 已复核完整地图和首次发现态；Stage19 `5/5` / `83` asserts，Stage11/13/16/18 专项全绿，递归全量 GUT `35` scripts / `262/262` tests / `8004` asserts，Godot import、主场景 smoke 与 `git diff --check` 通过。Stage19 收口时仍缺早期路线分叉、第二类环境危险、第二能力交叉门控、奖励 Build 深度和正式剧情事件，已由上方 Stage20 最小切片继续处理；本阶段本身未为填空新增敌人或陷阱。
- 2026-07-25 新增 Alpha Demo 世界地图组成与路线蓝图 `spec-design/2026-07-25-alpha-demo-world-map-blueprint.md` 及 `spec-design/images/2026-07-25-alpha-demo-room-route-blueprint.jpg`：将当前实装的 34 房首次通关骨架、4 个可选房、3 个区域闭环、SC-01 至 SC-05、Air Dash / `marsh_relic` / `warden_sigil` 回访顺序整理为房间截图总图、区域级、全房间级和解锁级视图。正式图中每张卡片都是当前运行房间，Stage 只作分组；生图仅提供无文字制图底板，房间与路线由工程事实确定性合成。结论是宏观拓扑已不再是纯单链，但首次安全路线仍为长骨架，能力取得偏晚且早期分支偏少；当时缺少的正式地图 UI 已由 Stage19 补入，本轮本身未修改运行时地图连接。
- 2026-07-18 完成宏观银河城世界图重构：不新增大批房间，将 34 房首次通关长链重接为镇妖试炼、瘴泽分流、神龛至封妖禁地 3 个区域环路，并加入 SC-01 至 SC-05 共 5 条远端连接。Air Dash 重新开启 Stage9 / Stage10 旧上层路线；Stage13 资源 / 挑战支路分别改为回到 Checkpoint / 前送 Goal，并授予 `marsh_relic` / `warden_sigil` 两个跨房持久收益；12 组锚点房补入秘密墙、叙事碑、危险机关和区域地标。Stage18 `12/12` / `1711` asserts，全量 GUT `34` scripts / `257/257` tests / `7919` asserts，39 房 DAC `P0/P1/P2=0`，input-only 首次通关 replay 自 Tutorial 自然经过 34 房到 Stage16 终点且 `P0/P1/P2=0`，Godot import / smoke 通过。当前仍在 `codex/stage-17-animation-runtime-stabilization`，未合并 / push，既有 Stage17 资产处置与平台校正改动均保留。
- 2026-07-16 完成正式平台视觉 / 碰撞与上行可达性校正：共享 `tutorial_thin_platform_visual_ai01.tileset.tres` 的 3 个切片统一增加 `texture_origin.y=14`，将 38/38 个正式房间的薄平台可见顶沿对齐到 `PlatformCollisionVisual` 的 one-way 碰撞顶沿；Stage10 三房与 Stage13 五处上行台阶各收紧为最多一格净空，Stage13 Return 高台降为可由单跳到达的高度，并补回 `stage13_goal_return` 生成契约。新增真实 Luna 物理回归覆盖 Stage10 三房、Stage13 六房和共享切片 alpha 顶沿。验证：全量 GUT `33` scripts / `245/245` tests / `6207` asserts、Godot import、主场景 smoke、Stage10/Stage13/教程及 Batch4-6 Windows 运行态截图报告均通过；未合并 / push。
- 2026-07-12 完成 Stage17 后的最终资产处置：正式场景 `52` 个 Preview 命名节点收敛为 `0`（删除 `50` 个隐藏历史节点、重命名 `2` 个真实运行节点），另移除 `7` 个 source-only 方向稿绑定；在删除前零引用、import、Stage12-17 与 Demo GUT 门禁通过后，物理删除 `14` 个 Stage12/13 旧 SVG 与 `14` 个 `.import`。runtime map 现为 `55` 项，处置为 `26 runtime_keep / 20 source_dev_keep / 9 archive_keep`；P0 正式运行计划为 `11` 项并同步收敛 rehearsal `11` 节点、target matrix `12` 场景 / `23` 引用、`6` 个批次。最终 runtime source safety 为 `11` 项、`0` review-required、`0` unsafe，final acceptance 为 `55/55 final-ready`；Godot import、全量 GUT `33` scripts / `240/240` tests / `6147` asserts、asset package strict audit、动画替换 `21/21 active ready` 与项目隔离审计均通过。当前结果仍在 `codex/stage-17-animation-runtime-stabilization`，未合并 / push。
- 2026-07-11 Stage17 `动作运行态稳定化` 开发与自动化收口完成：Luna 保持固定 runtime transform，Attack / Air Dash / Hit React 由 gameplay phase 映射关键帧，Jump 使用 Model Lock v1 四物理相位；四类普通敌人 cycle 会播放、defeat 可见，Ground Charger 具备 telegraph / charge / recover；Seal Guardian 拆分 strike / recovery / staggered，body / VFX 到达后半帧且单次攻击只结算一次伤害。最终验证为 Stage17 `10/10` / `118` asserts、全量 GUT `229/229` / `6245` asserts、strict audit `21/21 active ready`、OpenGL runtime probe 十一项全真、键盘 / synthetic Joypad smoke `ok=true`，以及无调试注入的 input-only Demo 重放 `34` 次主线房间进入、最终完成标记 `true`、`P0/P1/P2=0`。
- 2026-07-11 完成根 `AGENTS.md` 治理瘦身：从 `530` 行收敛为 `108` 行的仓库执行契约，只保留跨阶段硬规则、事实来源、最短流程和完成门禁；阶段历史、MCP 端口、插件候选、资产 Batch、worktree 操作手册和单次故障经验退出根文件，继续由现有专题文档与 Git 历史负责。本轮不修改 Stage17 动画运行时代码。
- 2026-07-11 完成角色 / 敌人 / Boss 动作、39 房内容和北极星实现度审计。关键修正：Luna 节点 scale 固定，视觉变大变小来自跨动作模型与时序未统一；Attack `0.23s` 对应 16 帧 / 18fps、Air Dash `0.24s` 对应 16 帧 / 20fps，均会截断大部分帧；Jump/Fall 是时间顺播而非物理相位映射。运行探针确认四类普通敌人 cycle 均未播放，Boss 在 staggered 状态隐藏。39 房当前有 `16` 个战斗房、`24` 个普通敌人实例、`1` 个 Boss；空间职责已明确，敌人行为和动作仍是原型级。北极星完整实现约 `25-30%`，独特核心“元素 + 姿态 + 序列连锁”约 `0-10%`。
- 2026-07-11 `codex/demo-level-formal-remap` 完成 Formal Demo Map Redesign：三类样板与 Batch 1-9 全部收口，当前 `39/39` 个可运行房间已按职责重排。Stage16 五房分别形成上层释放、三层中继、回溯确认、危险净化和终局大厅；Purge 首轮节点悬在平台间的问题已由运行图拒绝并修正。
- 最终验证：全量 GUT `31` scripts、`219/219` tests、`6105` asserts；39 房 Windows/OpenGL 运行态截图审计 `P0=0 / P1=0 / P2=0`；Stage16 自动完整主线到达 Alpha Demo End；Godot import 通过。
- 地图契约：其余 38 房使用正式 TileMap collision 与独立 visual-only surface；`test_room` 因保留 Stage1-4 非整格机制碰撞，使用真实 shape bounds 顶沿 / cap，作为显式机制沙盒例外，不把随机 tile 或背景装饰当道路。
- 资产结论：本轮没有为 Stage13-16 追加 Image Gen；未选候选、source sheet、整房概念图和 `imagegen_inbox` 未登记文件没有进入运行时。当前背景和地形达到 Alpha Demo 可读标准，但不等于商业版最终多区域背景、autotile 与装饰多样性清稿。
- 当前边界：结果尚未合并到 `main` 或推送远端；`AGENTS.md` 仍保持主线 Stage16 指针。自动化已经覆盖生产键盘映射、synthetic Joypad 和完整 input-only Demo 路线，但不冒充实体手柄硬件认证或真人体验签核；最终美术签核也仍属于后续发布级验收。
- 2026-07-11 完成正式地图 Batch 8，Stage15 战斗高潮链收口：Pressure `24x9` 新增双敌全清门；Challenge `26x10` 形成瘴气绕行、双敌全清和门后奖励；Boss `28x10` 从旧窄地面扩为宽 arena 与左右规避平台；Completion `18x8` 用上层封印装置进入 Stage16。Boss 运行复核初次误把击退力当伤害，已改为按公开生命逐次命中；Stage15 旧测试同步更新封印焦点坐标、危险 VFX 可读范围和 Pressure 清敌 driver。验证：Batch8 `5/5` / `193` asserts，Stage15/16 + formal remap `45/45` / `1106` asserts，六图运行态 `ok=true`，Godot import 通过。正式重排进度 `34/39`，下一批处理 Stage16 最后五房。
- 2026-07-11 完成正式地图 Batch 7，Stage14 全链收口：Shrine `20x8` 收敛为单一能力焦点；Backtrack Hub `26x10` 把三个收益点分布到递增三层；Loop Return `20x8` 用两段上行和上层目标进入 Stage15。Loop 首轮运行图发现 Goal marker 挂在平台下，根因是触发仍用旧地面高度，已将视觉与触发一起移到上层可踩面；Stage13 Goal 与 Stage14 Gate 同步补右侧安全 return spawn。验证：Batch7 `4/4` / `137` asserts，Stage14-16 + formal remap `61/61` / `1504` asserts，五图运行态 `ok=true`，Godot import 通过。正式重排进度 `30/39`，下一批处理 Stage15 剩余四房。
- 2026-07-11 完成正式地图 Batch 6，Stage13 全区域正式重排收口：Branch Hub `24x9` 把资源、挑战、主线三路放到不同高度；Resource `18x8` 成为无敌人两级上行奖励房；Challenge `24x9` 新增清敌门，法师未击败时不能直接取得门后奖励；Return `20x8` 承担支路 / 主线汇流降压；Goal `20x8` 把祭器与 Stage14 入口放到明确上层平台。验证：Batch6 `5/5` / `214` asserts，Stage13/manual/Stage14/Stage16/formal remap `58/58` / `1464` asserts，六图运行态 `ok=true`，Goal 真实切入 Stage14，Godot import 通过。正式重排进度 `27/39` 房，下一批处理 Stage14 剩余三房。
- 2026-07-11 完成正式地图 Batch 5 Stage13 中段四房：Gate `22x9` 形成“两级上行触符印、返回下层过门”的局部门控；Crossfire `26x10` 用三层平台和双法师形成交叉火力；Checkpoint `18x8` 收敛为可见恢复点与单观察台的降压大厅；Pressure `24x9` 形成地面瘴气危险、上层绕行和右侧远程压制。Gate 原纯逻辑 `SealNode` 已复用现有符印桩 AtlasTexture 补可见目标；Checkpoint 首轮截图因背景露蓝边被拒绝，扩大覆盖后通过。验证：Batch5 `4/4` / `197` asserts，Stage13/manual/Stage14/Stage16/formal remap `58/58` / `1479` asserts，七图运行态 `ok=true`，Godot import 通过。下一批完成 Stage13 剩余 Branch Hub / Resource / Challenge / Return / Goal 五房。
- 2026-07-11 完成正式地图 Batch 4：Stage11 终点改为 `18x8` 三选择安全大厅；Stage13 Entry `20x8` 增加区域 checkpoint 与揭示平台，Caster `24x9` 形成三层远程压制并补清敌门，Miasma `22x8` 形成下层危险带与两段上层绕行。瘴气警示 VFX 从几乎不可见提升到可读但不过曝，旧 Stage13 测试同步从“警示必须很淡”改为范围契约；地面可达性改为优先读取正式 TileMap。验证：Batch4 `4/4` / `183` asserts，Stage11/13/14/16 + formal remap `63/63` / `1515` asserts，六图运行态 `ok=true`，Godot import 通过。下一批继续 Stage13 中段 4 房。
- 2026-07-11 完成正式地图 Batch 3 Stage10 三房：Aerial `24x9` 形成三层空中战与显式奖励支路入口，Branch `18x8` 形成两级上行的恢复 / 收集回报房，Challenge `26x10` 形成三层三敌 arena 并由旧“任意一敌死亡开门”纠正为全清门；三房补齐反向连接、安全 spawn 和主线 return spawn，支路返回不再回到主房开头或立即重触发。运行态目检曾拒绝 `16x8` 支路的大块空底色，扩大到 `18x8` 后背景完整覆盖。验证：Batch3 `3/3` / `154` asserts、Stage10/11/12/16 `46/46` / `912` asserts、五图运行态报告 `ok=true`、Godot import 通过。下一批合并处理 Stage11 终点与 Stage13 入口链首批 3 房。
- 2026-07-11 完成正式地图 Batch 2 Stage9 五房区域推广：五间旧 `15x6` 单层模板分别重做为 Entry `18x6` 区域揭示、Combat `20x8` 双层首战、Charger `22x8` 长直冲锋带、Switch `20x9` 两级机关路线、Final `24x9` 上下层混合遭遇；补齐五房反向连接、安全 return spawn 和每房相机边界，冲锋房 checkpoint 在击败敌人后点亮。正式 TileMap collision + visual-only surface 替代旧 Floor / Wall 和随机 decor；复用单张瘴泽背景的不同取景，不启用已判为 source-only 的碎片化瘴泽 TileSet。验证：Batch2 GUT `5/5` / `320` asserts、Stage9-10/13-16 + formal remap `89/89` / `2042` asserts、七图运行态报告 `ok=true`、Godot import 通过。下一批进入 Stage10 三房。
- 2026-07-11 完成正式地图 Batch 1 首战短链推广：`test_room` 保留 Stage1-4 精确碰撞并按真实 shape bounds 补可读顶沿 / cap，`combat_trial_room` 重做为 `18x6` 单敌锁门房，`goal_trial_room` 重做为 `20x8` 下层战斗 + 右侧上层目标房；单张背景底色已扩到真实图片边界，旧随机 formal decor 和大面积暗矩形退出运行态。回归过程中修正 combat / goal spawn 将“可踩顶面”误作“角色中心”的坐标错误，死亡重试与返回落点现使用运行态稳定中心。验证：Batch 1 GUT `4/4` / `226` asserts、Stage1/3/4 `25/25` / `119` asserts、Stage6 `7/7` / `78` asserts、Stage7 `3/3` / `52` asserts、formal remap `8/8` / `184` asserts、五图运行态报告 `ok=true`、Godot import 通过。下一批进入 Stage9 五房区域级推广。
- 2026-07-11 完成 `stage15_mixed_gauntlet_room` 正式战斗场样板：房间从旧 `15x6` 单层三敌横排扩为 `26x9`，形成左侧近战区、中段冲锋通道与上层规避台、右侧空中敌人层、左上挑战支路和清场门安全区；Boss arena 单张背景覆盖完整房间，旧材质大图、旧 formal decor 和灰盒地形退出运行态。验证：gauntlet template GUT `5/5` / `309` asserts、Stage15 GUT `17/17` / `402` asserts、Godot import、四视角运行态截图复核 `ok=true`。三类正式样板已完成，下一步进入最小共同规则评估与首批 `3-5` 房推广。
- 2026-07-11 完成 `stage14_air_dash_gate_room` 正式能力门样板：房间从旧 `15x6` shape 跟随试铺扩为 `24x9` 显式蓝图，形成下层安全回落、两段起跳、`192px` Air Dash 缺口、右侧连续崖台和门前后安全区；随机 Door / Decor tile 已清空，单张背景覆盖完整房间，崖体复用低对比石质 underlay。入口 spawn 移出左出口触发区，并恢复 / 守护 next / previous room、spawn、checkpoint、HUD step 与能力门导出字段。验证：gate template GUT `5/5` / `555` asserts、formal remap GUT `8/8` / `189` asserts、Stage14 GUT `16/16` / `389` asserts、Godot import、四状态运行态截图复核 `ok=true`。下一样板为 `stage15_mixed_gauntlet_room`。
- 2026-07-10 完成 `tutorial_room` 第一轮正式房间构图样板：保留 `24x6` 四段教学节拍，背景从两张重复贴图收敛为单张 `0.92` 覆盖完整房间，消除竖向接缝和右侧空白；删除随机地面石物，入口只保留弱化石灯，跳跃平台本身承担地标，Air Dash 神龛安装到实体低顶上方；共享 `TrainingDummy` 从误标链门切片改为人工复核的试炼碑。通过 Atlas alpha bounds 和运行态坐标确认玩家脚底为 `y=160`、主地面原可见顶面为 `y=167`，将 `GroundSurfaceVisual` 上移 `7px` 并统一落地物基线，现已满足 Luna / 训练碑脚底与视觉地面吻合。验证：tutorial template GUT `6/6` / `502` asserts、Stage3 GUT `5/5` / `18` asserts、Stage5 GUT `9/9` / `100` asserts、Godot import、四点运行态截图复核 `ok=true`，其中 `background_coverage_ok=true`、`landmark_layout_ok=true`、`start_ground_alignment_ok=true`、`training_target_ok=true`。下一样板为 `stage14_air_dash_gate_room`。
- 2026-07-10 完成 `tutorial_room` 薄平台视觉替换：从既有 `shrine_trial_tileset_ai01` 平台件裁出 24px 高薄上沿，新增 `tutorial_thin_platform_visual_ai01` 与 `ThinPlatformSurfaceVisual`；`GroundSurfaceVisual` 只保留主路连续地面，跳台和 dash 门低顶不再使用厚石梁平台件；`TerrainCollisionVisual` / `PlatformCollisionVisual` 仍承担碰撞权威，不改 one-way 平台、dash 门门禁或房间推进。验证：tutorial template GUT `3/3` / `452` asserts、Stage5 GUT `9/9`、运行态截图复核 `ok=true` 且 `thin_platform_surface_visible=true` / `surface_visual_ok=true`、Godot import 和 `git diff --check` 通过；边界：本轮不使用 image gen 重生整套平台资产。
- 2026-07-09 完成 `tutorial_room` 64px 网格驱动正式 demo 样板房：主路固定为 `x=-7..15, y=2` 连续 23 格，跳台收紧为 `x=-4..-3, y=1` 连续 2 格，dash 门低顶和出口安全落点按网格蓝图铺设；`TerrainCollisionVisual` / `PlatformCollisionVisual` 承担地形与薄平台权威碰撞，`GroundSurfaceVisual` 复用 `shrine_trial_tileset_ai01` 的 left / center / right 地面件做 visual-only 连续主路视觉，带格线的 `GroundUnderlayVisual` 已隐藏退役，`DoorVisual` / `BackgroundVisual` / `DecorVisual` / `ForegroundVisual` 在本房保持空 TileMap，避免孤立门柱、重复墙件、地面下碎石和漂浮小台座误读；`ExitBarrier` / `ExitZone` / `TutorialDummy` 保持独立逻辑节点。验证：tutorial template GUT `3/3` / `432` asserts、Stage5 GUT `9/9`、运行态截图复核 `ok=true` 且 `grid_blueprint_ok=true` / `surface_visual_ok=true` / `ground_underlay_retired=true`、Godot import 通过、`git diff --check` 通过；边界：不全图推广，不新建通用关卡生成器。
- 2026-07-09 完成 `stage14_air_dash_gate_room` 房间级 Terrain 模板复制验证：`LeftWall` / `Floor` 的真实地形碰撞迁移到 `TerrainCollisionVisual`，旧试铺层隐藏并显式禁用碰撞，`DoorVisual` / `BackgroundVisual` / `DecorVisual` / `ForegroundVisual` 保持 visual-only，`GateBarrier` / `ExitZone` / `LeftExitZone` / `AirDashGateSensor` 保持独立逻辑碰撞。验证：Stage14 gate template GUT `3/3`、Stage14 GUT `16/16`、运行态截图复核 `ok=true`；边界：不全图推广，不处理房间长度 / 层级扩展。
- 当前稳定游戏基线仍是 `main` 上的 Stage16 Alpha Demo 打包候选，包含最小 Demo 壳、Stage15 `Seal Guardian / 封印守卫`、`Recovery Charge / 恢复充能`、Stage16 五房终局封印链、Alpha Demo 完成反馈、`docs/deliverables/stage16-alpha-demo-candidate/` 交付物与第二轮资产 / 音频需求记录。
- Godot MCP Pro 1.13.1 增量已合并到主线；当前项目保留 `17605-17619` / `17620-17624`、rendezvous、workspace/session 握手和 diagnostic tools，并吸收 ping/pong、heartbeat timeout、idle/stale UI 与输入模拟修正。
- 资产生产线治理已合并到主线；`Asset Production Track / 资产生产线` 作为长期并行工作流运行，玩法 Stage 仍先用灰盒 / 占位验证，资产 Batch 同步生成候选，玩法稳定后再清理并接入可运行资产。
- 本次合并刻意排除了 Luna 行走关键帧生成内容：`assets/art/characters/player/luna_walk/`、`docs/progress/logs/2026-05-05.md` 和 `asset-manifest.md` 中对应行不进入本轮远端同步。

## Current Stable Baseline

- 当前分支候选：`codex/stage-17-animation-runtime-stabilization` 当前同时包含 Stage17 动作运行态收口、正式平台校正、Stage18 宏观银河城世界图重构、Stage19 房间蓝图 / 发现式地图和 Stage20 六类银河城缺口闭环；`codex/demo-level-formal-remap` / `985ec28` 仍是正式地图回退基线。当前分支尚未合并 `main` 或推送远端。
- `main` 稳定基线：Stage16 Alpha Demo 打包候选已合并，主线验证通过。
- 当前可试玩方向：Stage16 Alpha Demo 内容、Stage17 动作运行态稳定化、Stage18–20 的三环路 / 六远端连接、发现式地图与六类关卡缺口闭环已形成分支候选；合并前先做实体手柄、真人首次通关和能力回访路线签核，合并后再独立规划最小 `2 元素 + 2 姿态 + 2 步序列` 北极星战斗切片。
- 当前设计约束：后续阶段继续向南北朝东方奇幻、封妖禁地、瘴泽、妖域、符印机关等语境回收灰盒命名，不继续扩大现代实验室表达。
- 当前资产方向：围绕 Alpha Demo 候选补强 Luna、Air Dash、Seal Guardian、Stage16 UI / 终局反馈、区域表现、最小 SFX / BGM 和动画参考，不追求完整商业版资产量。
- 当前资产补齐目标已扩展为长期完整资产族：角色、关卡地图场景、UI / 界面、图标、道具与装备、特效、动画帧 / 序列帧、贴图、宣传运营、LOGO、CG、分镜和叙事剧情资产，并最终整理为 Godot 可用的 Sprite Sheet、Texture Atlas、Tile Set、Spine 拆件图集、UI 图集、特效图集和九宫格图片。
- 2026-07-07 完成 DemoShell `选择关卡` 测试入口实装：主菜单现在会打开滚动房间列表，覆盖 Alpha Demo 主线 `34` 个房间和 `4` 个支线房；点击条目后调用 `Main.start_demo_at_room(...)`，仍通过生产 `Main.tscn` 装配玩家、HUD、相机和房间，Stage14 之后的测试条目会补空中冲刺 / 回溯奖励 / Boss 击败等必要前置状态。验证：Stage16 GUT `19/19` tests、`504` asserts 通过，Godot import 与目标文件 `git diff --check` 通过。
- 2026-07-05 继续完成 DemoShell 主菜单构图收敛：主菜单从中心大弹窗改为按 viewport 动态计算的左侧紧凑导航面板，宽度限制在 `300-420`，按钮高度约 `31`，保留 `开始游戏 / 继续游戏 / 选择关卡 / 设置 / 控制说明 / 退出游戏` 六项入口但不再遮住标题背景主体；Stage16 GUT `18/18` tests、`463` asserts 通过，Godot import 通过，DemoShell layout hover 与 start review 均为 `ok=true`，`menu_normal_2048x1152.png` / `menu_hover_2048x1152.png` 目检确认背景成为主视觉且 hover 不压扁按钮。
- 2026-07-05 继续完成 Stage14 backtrack reward pedestal 运行态替换：`stage14_backtrack_hub_room.tscn` 的 `BacktrackRewardOne/Two/Three` 均新增 `RewardPedestalArt`，复用 `shrine_gate_prop_atlas_ai01.reward_marker_idle` AtlasTexture 作为小型奖励标识，`RewardArt` 继续作为上层奖励晶体；不改奖励计数、收集距离、隐藏逻辑、出口或玩家路线；Stage14 GUT `16/16` tests、`379` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage14_backtrack_hub.png` 目检确认奖励点不再只是孤立漂浮晶体。
- 2026-07-05 继续完成 Stage16 purge focus base 运行态替换：`stage16_corruption_purge_room.tscn/CorruptionPurgeNode` 新增 `PurgeFocusBaseArt`，并从远景较弱的 `shrine_gate_prop_atlas_ai01.seal_ring_active` 收敛为 `shrine_gate_prop_atlas_ai01.miasma_ward_purged` AtlasTexture 作为小型净化石质机关，`TalismanRelayEchoArt` 继续作为上层确认 VFX；不改妖瘴危险 Area、净化接近距离、门控、出口或玩家路线；Stage16 GUT `18/18` tests、`462` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage16_purge.png` 目检确认净化点有石质机关底座和上层净化光效。
- 2026-07-05 继续完成 Stage16 relay focus base 运行态替换：`stage16_talisman_relay_room.tscn` 的 `TalismanRelayA/B/C` 均新增 `RelayFocusBaseArt`，复用 `shrine_gate_prop_atlas_ai01.seal_ring_idle` AtlasTexture 作为小型符印器物，`RelayArt` 继续作为上层符印 VFX；不改 `required_talisman_relay_count`、接近距离、门控、出口或玩家路线；Stage16 GUT `18/18` tests、`452` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage16_relay.png` 目检确认 relay 不再只是孤立光点。
- 2026-07-05 继续完成 Stage15 pressure focus prop 运行态替换：`stage15_seal_pressure_room.tscn` 新增 `PressureFocusArt`，复用 `shrine_gate_prop_atlas_ai01.seal_pillar_intact` AtlasTexture 作为封印压力点底座，`PressureSigilArt` 保持为上层能量 VFX；不改压力逻辑、敌人、出口、碰撞或房间推进；Stage15 GUT `17/17` tests、`404` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage15_pressure.png` 目检确认压力点不再像悬浮 UI 标记且未遮挡路线。
- 2026-07-05 继续完成 Luna runtime render layer correction：`PlayerPlaceholder.z_index` 设为 `3`，高于全房间 `FormalForegroundEdgeDecor.z_index=2`，避免玩家运行态身体被前景边缘压住并读成嵌入地面；不改碰撞体、动作帧、相机、房间地形或门禁资源；Stage14 GUT `16/16` tests、`352` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，2K 专项复核 `ok=true` / `camera_zoom=[3.2, 3.2]`，`stage14_gate.png` 与 `stage16_threshold.png` 目检确认 Luna 不再被前景边缘盖脚。
- 2026-07-05 继续完成 marker-backed trigger visual cleanup batch：隐藏 Stage10 `BranchZone/BranchVisual`、Stage13 branch hub 三块 route visual、Stage13 goal `GoalZone/GoalVisual`、Stage14 loop return `GoalZone/GoalVisual`、Stage15 gauntlet `ChallengeBranchZone/ChallengeVisual`；只处理已有正式 marker / GoalDevice 覆盖的目标和支路入口，不改普通房间边界 `ExitZone`、Area2D 碰撞、支路跳转、目标推进、奖励或敌人逻辑；Stage10 GUT `11/11` tests、`108` asserts，Stage13 GUT `13/13` tests、`368` asserts，Stage14 GUT `16/16` tests、`351` asserts，Stage15 GUT `17/17` tests、`394` asserts 均通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`。
- 2026-07-05 继续完成 Stage11 endpoint trigger visual cleanup：`stage11_demo_end_room.tscn` 的 `ReplayVisual`、`GoalVisual`、`ContinueVisual` 三块低透明触发区底板均设为隐藏，保留 `ReplayMarkerArt`、`GoalMarkerArt`、`ContinueMarkerArt` 作为重开 / 完成 / 继续的正式运行态读值；不改三个 Area2D 碰撞、重开、完成或继续逻辑；Stage12 GUT `10/10` tests、`243` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage11_end.png` 目检确认三枚 marker 仍可读且弱触发区底板不再显示。
- 2026-07-05 继续完成 GoalTrial target marker 运行态替换：`goal_trial_room.tscn/GoalZone` 新增 / 调整 `GoalMarkerArt`，复用 `equipment_pickup_atlas_ai01.demo_completion_token` AtlasTexture，并隐藏 `GoalZone/ZoneVisual` 弱触发区底板；不改 `GoalZone` 碰撞、战斗清敌、门禁、左侧返回或 Stage9 入口推进；formal remap GUT `6/6` tests、`142` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，formal remap 运行态复核 `P0=0 / P1=0 / P2=0`，`goal_trial_target_focus.png` 目检确认目标 token 可读且旧红白面具误用 / 弱触发区矩形已消失。
- 2026-07-05 继续完成 Stage10 main optional branch marker 运行态替换：`stage10_zone_aerial_room.tscn/BranchZone` 下新增 `BranchMarkerArt`，复用 `equipment_pickup_atlas_ai01.reward_orb_small` AtlasTexture；不改 `BranchZone` 碰撞、可选支路跳转、空中攻击价值点或敌人遭遇；Stage10 GUT `11/11` tests、`106` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage10_aerial.png` 目检确认可选支路标识可读且未遮挡 Luna、HUD、空中价值标识、敌人、平台或主线出口。
- 2026-07-05 继续完成 Stage15 gauntlet challenge branch marker 运行态替换：`stage15_mixed_gauntlet_room.tscn/ChallengeBranchZone` 下新增 `ChallengeMarkerArt`，复用 `equipment_pickup_atlas_ai01.boss_core_shard` AtlasTexture；不改 `ChallengeBranchZone` 碰撞、支路跳转、敌人遭遇或 Boss 门控；Stage15 GUT `17/17` tests、`392` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage15_gauntlet.png` 目检确认挑战支路标识可读且未遮挡 Luna、HUD、敌人、地面或右侧 Boss 门路线。
- 2026-07-05 继续完成 Stage14 loop return goal marker 运行态替换：`stage14_loop_return_room.tscn/GoalZone` 下新增 `GoalMarkerArt`，复用 `equipment_pickup_atlas_ai01.map_scrap` AtlasTexture；不改 `GoalZone` 碰撞、Stage14 到 Stage15 的房间推进或 HUD 读值；Stage14 GUT `16/16` tests、`349` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage14_loop_return.png` 目检确认目标标识未遮挡 Luna、HUD、地面、右侧门槛或出口路线。
- 2026-07-05 继续完成 Stage10 value / recovery / reward marker 运行态替换：`AirAttackValueMarker/ValueArt` 复用 `equipment_pickup_atlas_ai01.air_dash_charm`，`RecoveryPoint/CheckpointArt` 复用 `shrine_gate_prop_atlas_ai01.checkpoint_active`，`BranchCollectible/CollectibleArt` 复用 `equipment_pickup_atlas_ai01.reward_orb_small`，`ChallengeCollectible/CollectibleArt` 复用 `equipment_pickup_atlas_ai01.boss_core_shard`；不改触发距离、收集计数、恢复逻辑、支路跳转或挑战房推进；Stage10 GUT `11/11` tests、`98` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage10_aerial.png`、`stage10_branch.png` 与 `stage10_challenge.png` 目检确认价值点、恢复点和奖励点可读且不遮挡 Luna、HUD、敌人、平台、门禁或出口。
- 2026-07-05 继续完成 Stage13 checkpoint 运行态 prop 替换：`stage13_miasma_marsh_checkpoint_room.tscn/RecoveryPoint` 下新增 `CheckpointArt`，复用 `shrine_gate_prop_atlas_ai01.checkpoint_active` AtlasTexture；不改 checkpoint 信号、重生或房间推进；Stage13 GUT `13/13` tests、`360` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage13_checkpoint.png` 目检确认 checkpoint prop 可读且不遮挡 Luna、HUD、平台或出口。
- 2026-07-05 继续完成 Stage13 resource / challenge branch 奖励点运行态替换：两条支路的 `Stage13Reward` 下新增 `RewardArt`，资源支路复用 `equipment_pickup_atlas_ai01.seal_fragment`，挑战支路复用 `equipment_pickup_atlas_ai01.reward_orb_large`，并保持作为奖励 Marker 子节点以便拾取后随逻辑节点隐藏；Stage13 GUT `13/13` tests、`351` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage13_resource_branch.png` 与 `stage13_challenge_branch.png` 目检确认奖励点可读且不遮挡 Luna、HUD、平台或出口。
- 2026-07-05 继续完成 Stage13 branch hub 路线标识运行态替换：`ResourceBranchZone`、`ChallengeBranchZone`、`ExitZone` 分别新增 `ResourceMarkerArt`、`ChallengeMarkerArt`、`ExitMarkerArt`，复用 `equipment_pickup_atlas_ai01.reward_orb_small`、`boss_core_shard`、`map_scrap` AtlasTexture；不改 Area2D 碰撞、支路跳转或主线出口；Stage13 GUT `13/13` tests、`335` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage13_branch_hub.png` 目检确认路线标识不遮挡 Luna、HUD、平台或出口。
- 2026-07-05 继续把 Stage16 threshold 拆分链锚 prop 扩展到同一封印链的 Stage15 completion 与 Stage16 backtrack：`CompletionSeal` / `BacktrackConfirmationNode` 新增 `SealChainAnchorLeftArt` / `SealChainAnchorRightArt`，复用 `shrine_gate_prop_atlas_ai01.chain_anchor_left/right` AtlasTexture；三处 `ReusableSealPropsPreviewArt` 均继续隐藏，避免整张 source sheet 上屏；Stage16 GUT `18/18` tests、`422` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage15_completion.png` 与 `stage16_backtrack.png` 目检确认链锚 prop 不遮挡路线、HUD、敌人或门禁。
- 2026-07-05 继续完成 Stage16 threshold 拆分单件前景 prop 接入：`stage16_seal_release_threshold_room.tscn/SealReleaseNode` 新增 `SealChainAnchorLeftArt` / `SealChainAnchorRightArt`，分别绑定 `shrine_gate_prop_atlas_ai01.chain_anchor_left/right` AtlasTexture；`ReusableSealPropsPreviewArt` 继续隐藏，避免整张 source sheet 作为正式运行态装饰上屏；Stage16 GUT `18/18` tests、`378` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，`stage16_threshold.png` 目检确认链锚 prop 不遮挡路线、HUD 或门禁。
- 2026-07-05 继续完成 TutorialHUD 常驻小图标、普通目标徽标与面板贴图层统一：冲刺 / 恢复图标从 standalone PNG 切到 `icon_sheet_core_ai01.air_dash` / `icon_sheet_core_ai01.recovery_charge` AtlasTexture，与生命图标统一到同一 64px icon sheet；普通目标行 `ObjectiveIcon` 从旧 SVG 切到 `hud_core_ui_atlas_ai01.room_goal_marker`，恢复 / Boss 行隐藏以免挤压读值；`PromptPanelArt` / `BattlePanelArt` 复用 `menu_ninepatch_ui_ai01` 深色 atlas 贴图层，避免 HUD 继续只是纯 `StyleBoxFlat` 小黑框；Stage12 GUT `10/10` tests、`237` asserts 通过，Godot import 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0` 通过，`tutorial_room.png`、`stage13_entry.png`、`stage15_pressure.png` 与 `stage15_boss.png` 目检确认 HUD 小图标、目标徽标和面板贴图层未变形或遮挡。
- 2026-07-05 继续完成 Stage13 目标装置运行态 prop 替换：`stage13_miasma_marsh_goal_room.tscn/GoalDevice` 从亮色 `Polygon2D` 改为 `shrine_gate_prop_atlas_ai01.miasma_ward_idle` AtlasTexture，并保留 `GoalZone` 碰撞 / Stage14 跳转不变；Stage13 GUT `13/13` tests、`332` asserts 通过，Godot import 通过，全内容流程截图证据和全 `39` 房 DAC 均为 `P0=0 / P1=0 / P2=0`，`stage13_goal_device.png` 目检确认目标区域不再是几何占位块。
- 2026-07-04 已修复 DemoShell 主菜单分辨率适配和开始按钮 hover 压扁问题，并把小型测试入口扩为正式主菜单列：`开始游戏`、`继续游戏`、`选择关卡`、`设置`、`控制说明`、`退出游戏` 均在 640x360 基准视口与 2K 窗口下可读；主菜单按钮改用 `360x32` 左右的专用 StyleBoxFlat 交互态，避免继续拉伸 UI 图片九宫格。`继续 / 选择关卡 / 设置 / 控制说明` 已改为复用主菜单皮肤的详情页，未实现的系统在详情页内说明边界；暂停 / 失败 / 完成提示文字改为深色，失败提示层已加高以避免角色身体穿出。`stage16_demo_menu_icons_ai01` 已拆出 continue / restart / back 三个语义匹配 AtlasTexture，只接入暂停继续、暂停重开、失败继续和详情返回，不硬套到主菜单六项；运行态布局 / hover、启动四态截图、控制说明详情页、暂停 / 失败提示可读性与 640 / 1024 / 2048 三档复核均为 `ok=true`，未触发重生成按钮图片。
- 2026-07-04 继续完成 Stage16 终点房完成反馈运行态文字收敛：`stage16_alpha_demo_end_room.tscn` 的 `AlphaDemoCompletionArt` / `CompletionPanelEchoArt` 牌面新增 `CompletionMessageLabel`，显示 `Alpha Demo 已完成`，浅金字 + 1px 深色描边适配深色牌面；Stage16 GUT `18/18` tests、`303` asserts 通过，全 `39` 房 DAC 截图复核仍为 `P0=0 / P1=0 / P2=0`，`stage16_end.png` 目检可读。
- 2026-07-04 继续完成 Stage16 终点房完成反馈安全区收敛：复用现有 `stage16_alpha_demo_completion_ai01` / `stage16_completion_panel_ui_ai01`，将完成大图从 `position=(256,30) / scale=0.26` 调到 `position=(150,30) / scale=0.18`，文字牌同步左移到安全区；Stage16 GUT `18/18` tests、`326` asserts 通过，Godot import、全 `39` 房 DAC `P0=0 / P1=0 / P2=0` 通过，`stage16_end.png` 目检确认完成图不再贴右边裁切且文字可读。
- 2026-07-04 继续完成 TutorialHUD 空提示面板收紧：房间 HUD 只提供标题、正文为空时，`PromptPanel` 从完整提示框自动收为窄标题条，避免右上角出现大块空黑框 / 长黑条；有正文时恢复完整宽度。Stage12 GUT `10/10` tests、`197` asserts 通过，全 `39` 房 DAC 截图复核仍为 `P0=0 / P1=0 / P2=0`，`stage13_entry.png` 目检确认右上提示区已收紧，`tutorial_room.png` 目检确认教程正文未被挤压。
- 2026-07-04 继续完成 TutorialHUD 运行态 meter 条正式化：生命 / 冲刺 / 恢复 / Boss 条保留原 ColorRect 宽度逻辑，但叠加 `hud_core_ui_atlas_ai01.meter_rail` 轨道装饰；恢复 / Boss 轨道纳入原有 Stage15 / Boss 房显隐逻辑。Stage12 GUT `10/10` tests、`221` asserts 通过，Godot import、全 `39` 房 DAC `P0=0 / P1=0 / P2=0` 和 `git diff --check` 通过，`test_room.png` 原图目检确认 HUD 条不再是完全裸色条。
- 2026-07-04 继续完成 Stage16 符印中继运行态可读性收敛：复用现有 `stage16_talisman_relay_ai01` 三个 region，将 `RelayArt.scale` 从 `0.045` 提到 `0.065`，不新增图片、不改门控碰撞或房间推进；Stage16 GUT `18/18` tests、`322` asserts 通过，Godot import、全 `39` 房 DAC `P0=0 / P1=0 / P2=0` 通过，`stage16_relay.png` 目检确认中继可读且未遮挡路径、门禁或 HUD。
- 2026-07-04 继续完成 Stage14 神龛房硬边源图 / 触发区矩形清理：`stage14_air_dash_shrine_room.tscn` 隐藏 `ShrineTrialParallaxArt`、`AirDashShrineRoomArt` 和已有正式门禁 prop 覆盖的 `ExitZone/ZoneVisual`，保留主背景、TileSet、神龛、门禁 prop 与 Air Dash trail；Stage14 GUT `16/16` tests、`345` asserts 通过，全 `39` 房 DAC 截图复核仍为 `P0=0 / P1=0 / P2=0`，`stage14_shrine.png` 目检不再出现源图 / 触发区硬边块。
- 2026-07-04 继续完成 Stage15 completion 与 Stage16 threshold / backtrack 的 source sheet 误上屏收敛：`ReusableSealPropsPreviewArt` 在三个正式流程房间改为隐藏，并标记为 `hidden_source_sheet_not_runtime_prop`；`capture_demo_art_composition_review.gd` 新增 `reusable_seal_props_ai01` 可见 source sheet 检查。Stage16 GUT `18/18` tests、`313` asserts，Stage15 GUT `17/17` tests、`388` asserts，全 `39` 房 DAC 截图复核仍为 `P0=0 / P1=0 / P2=0`，`stage15_completion.png`、`stage16_threshold.png`、`stage16_backtrack.png` 目检通过。
- 2026-07-04 继续完成三状态封印释放 prop 运行态可读性收敛：Stage15 completion、Stage16 threshold 与 Stage16 backtrack 继续复用 `stage16_seal_release_threshold_ai01` 三个 AtlasTexture，只把对应 `Sprite2D.scale` 从 `0.055` 提到 `0.085`，局部 y 从 `-12` 下移到 `8`；Stage16 GUT `18/18` tests、`341` asserts 通过，Godot import、全 `39` 房 DAC `P0=0 / P1=0 / P2=0` 通过，三张目标截图目检确认道具可读且未遮挡路径或门禁。
- 2026-07-04 继续修正 DAC 运行态截图验收口径：`capture_demo_art_composition_review.gd` 切房后等待玩家物理落地再截图，并在报告中写入 `state / animation / floor` 玩家姿态列；全 `39` 房最新 DAC 仍为 `P0=0 / P1=0 / P2=0`，所有房间均为 `floor` 状态，刷新后的单张截图和 `dac03_contact_sheet.png` 不再把切房下落帧误当作 Luna 静态默认姿态。
- 2026-07-04 继续补强 FP-01 运行态美术读值验收：`capture_final_art_polish_fp01_review.gd` 不再检查隐藏 source preview 节点，而是检查 Stage13 / Stage14 / Stage15 / Stage16 当前实际可见的背景、TileMap、门禁 prop、神龛 prop 和 Boss runtime visual；Stage14 shrine / gate 已显式覆盖 `shrine_gate_prop_atlas_ai01` 的可见 `ShrineArt`、`GatePreviewArt`、`ShrineEchoArt`、`GateArt`。验证：FP-01 非 headless 运行态截图复核 `ok=true`，Demo remap GUT `5/5`、Stage14 GUT `16/16`、Godot import、全 `39` 房 DAC `P0=0 / P1=0 / P2=0`、`git diff --check` 均通过。
- 2026-07-04 继续修正 DemoShell 主菜单运行态资产预览：`MenuIconStrip` 现在隐藏，避免把 `stage16_demo_menu_icons_ai01` 的 2x3 source sheet 压缩成底部小条夹在菜单按钮之间；资源引用仍保留给后续正式切图和测试追踪。验证：Godot import 通过，Stage16 GUT `18/18` tests、`267` asserts，菜单 hover 复核与 2K 专项复核均为 `ok=true`。
- 2026-07-04 继续修正 DemoShell 暂停菜单运行态资产预览：`PausePanelArt` 现在隐藏，避免 `stage16_pause_panel_ui_ai01` 的预制横向槽位与当前“继续 / 重开”按钮错位叠显；资源引用仍保留给后续暂停菜单清稿。验证：Godot import 通过，Stage16 GUT `18/18` tests、`269` asserts，四态 DemoShell 截图复核 `ok=true`。
- 2026-07-04 已完成 P0 运行态视觉验收复核修正：Godot 显示适配从 `viewport / keep / integer` 改为更适合当前正式 Demo 大图资产的 `canvas_items / expand / fractional`；Main 按 `640x360` 基准给玩家 Camera2D 补高分屏 zoom，2K 同 16:9 下 `camera_zoom=[3.2, 3.2]`，避免一次暴露 3.2 倍设计视野和背景拼接缝；Luna ai03 运行态视觉锚点从碰撞盒底部对齐改为可见地表顶面对齐，`LunaRuntimeAnimationVisual.position = Vector2(0, -32)`；Stage14 Air Dash shrine / gate、GoalTrial gate、Stage9 switch、Stage16 seal threshold 等运行态占位读值已改用现有正式 atlas / VFX。验证：Godot import、Stage1、formal remap、Stage14、Stage16、全房间 DAC OpenGL 复核与 2K 专项复核均通过，报告 `P0=0 / P1=0 / P2=0` 或 `ok=true`。
- 2026-07-04 继续完成 GoalTrial gate 与 Stage9 switch controller 运行态替换：`goal_trial_room.tscn` 的 `GoalBarrier/BarrierArt` 改用 `shrine_gate_prop_atlas_ai01.seal_gate_locked`，`stage9_zone_switch_room.tscn` 隐藏黄色 `SwitchVisual` 与旧绿色 `Stage12CheckpointMarker`，改用 `shrine_gate_prop_atlas_ai01.talisman_stake_lit` AtlasTexture 作为正式机关 prop；Stage7 / Stage9 / formal remap GUT 与全房间 DAC OpenGL 截图复核均通过，`goal_trial.png` 和 `stage9_switch.png` 目检不再出现红绿 / 黄绿测试色块。
- 2026-07-04 继续完成 Stage9 switch controller idle / lit 两态接入：`stage9_zone_switch_room.tscn` 的 `GateSwitch/SwitchArt` 默认从 `talisman_stake_lit` 改为 `006_shrine_gate_prop_atlas_ai01_auto_007_c01` / `talisman_stake_idle`，`activate_gate_switch()` 后再切到 `007_shrine_gate_prop_atlas_ai01_auto_008_c01` / `talisman_stake_lit`；Stage9 GUT `4/4` tests、`43` asserts 通过，全房间 DAC OpenGL 截图复核 `P0=0 / P1=0 / P2=0`，`stage9_switch.png` 目检显示默认机关不再像已激活。
- 2026-07-04 继续完成 Stage15 pressure room、Stage13 / Stage15 腐瘴危险提示和 MiasmaCaster 压制范围运行态 VFX 替换与强度收敛：隐藏大块菱形 `PressureSigil`、绿色 warning SVG / Polygon 和 MiasmaCaster 大八边形 `MiasmaPressureVisual`，改用 `vfx_seal_magic_atlas_ai01` 与从 `vfx_combat_atlas_ai01` purge 语义帧派生的 `miasma_purge_warning_vfx_runtime_ai01`；Stage13 / Stage15 GUT `30/30` tests、`710` asserts 通过，全房间 DAC OpenGL 截图复核 `P0=0 / P1=0 / P2=0`，目标截图不再出现高可见几何占位或大面积调试范围圈。
- 2026-07-04 继续完成 TutorialHUD 生命图标运行态占位收敛：`BattlePanel/HealthIcon` 从红色 `ColorRect` 色块改为 `icon_sheet_core_ai01.health` editor AtlasTexture，保持 `12x12` 小尺寸并补 Stage12 HUD 资源 / asset_id / 尺寸断言；Stage12 / Stage14 / Stage15 / Stage16 GUT `61/61` tests、`1181` asserts 通过，全房间 DAC OpenGL 截图复核 `P0=0 / P1=0 / P2=0`，`tutorial_room.png` 与 `stage15_pressure.png` 目检确认未拉伸或遮挡。
- 2026-07-04 继续完成 Stage14 / Stage15 reward 与 Stage16 corruption purge 运行态修正：Stage14 三个回溯收益点隐藏黄色菱形 `RewardVisual`，Stage15 支路 `Stage13Reward` 改为 `Marker2D` 并新增 `Stage13RewardArt`，均改用 `equipment_pickup_atlas_ai01.reward_orb_large`；Stage16 `CorruptionMiasma` 大紫色 Polygon 降为弱地面氛围，净化读值交给 `stage16_corruption_purge_ai01` VFX。Stage14 / Stage15 / Stage16 GUT 与全房间 DAC OpenGL 截图复核均通过，`stage14_backtrack_hub.png`、`stage15_challenge_branch.png` 和 `stage16_purge.png` 目检通过。
- 2026-07-04 继续完成 Stage16 seal release threshold 三状态源图切片：新增 locked / active / released 三个 `AtlasTexture` editor resource，Stage16 threshold、Stage15 completion 和 Stage16 backtrack 分别引用单状态切片，不再把整张三状态 PNG 缩小上屏；Stage15 / Stage16 GUT、Godot import 与全房间 DAC OpenGL 截图复核均通过，`stage15_completion.png`、`stage16_threshold.png`、`stage16_backtrack.png` 目检通过。
- 2026-07-04 根据用户最新运行态截图继续复核 Stage16 relay 右侧门禁：此前保留的 `boss_gate_locked` 特殊切片在实机距离下读成红绿竖杆 / 调试门禁，现已改回通用 `seal_gate_locked` 关闭石门切片，并移除 `Stage9RoomBase` 对该特殊切片的保留逻辑。验证：Godot import、Stage14 / Stage16 GUT、formal remap 运行态复核、全 `39` 房 DAC 与 2K 专项复核均通过，`stage16_relay_to_threshold_entry.png` 目检不再出现红绿竖杆。
- 2026-07-04 继续完成 TrainingDummy 与 Stage11 endpoint marker 运行态 prop 替换：`training_dummy.tscn` 的 `DummyArt` 从绿色十字 / 准星状 `stage13_seal_node_01.svg` 改为 `shrine_gate_prop_atlas_ai01.seal_pillar_cracked`；`stage11_demo_end_room.tscn` 隐藏三个高亮箭头 Polygon，改用 `equipment_pickup_atlas_ai01` 的 bronze bell / demo token / shrine key 小型标识；Stage3 / Stage5 / Stage12 GUT 与全房间 DAC OpenGL 截图复核均通过，`test_room.png` 与 `stage11_end.png` 目检确认目标占位已消失。
- 2026-07-04 已补正式 Demo 剩余资产缺口复核：当前新增 image-gen 运行态阻断数为 `0`，不再需要立刻生成新图来清除红绿门禁、黄绿控制器、大块危险区或整张源图上屏；但正式 Demo polish 仍建议保留 `6` 个视觉资产包和 `1` 个音频资产包，高标准公开试玩可扩到 `8-10` 个资产包，优先地形边缘 / autotile 清稿与门禁 / 机关状态 prop。
- 2026-07-04 继续完成 FormalTerrainTilemapDecor 地表边缘、前景边缘和背景覆盖收敛：复用现有 `shrine_trial_tileset_ai01` / `miasma_marsh_tileset_ai01`，Stage9 / Stage10 / Stage13 切到瘴泽 TileSet，其余主流程房间切到神龛 TileSet，重刷 `39` 房共 `620` 个地表视觉 tile；可见 `BackgroundArt` 从 `scale=0.5` 提升到 `0.58`，消除 640 基准镜头左侧底色露出；连续地形 underlay alpha 已从 `0.36` 经 `0.20` 继续收敛到 `0.12`，避免读作灰盒底板；全 `39` 房新增 / 重刷 `FormalForegroundEdgeDecor` 稀疏前景边缘层，共 `149` 个 edge tile；DAC 新增 `blocky_floor_tilemap`、`theme_tileset_mismatch`、收紧后的 `heavy_textured_underlay` 与 `missing_foreground_edge_decor` P2 检查。验证：formal remap + Stage9 / Stage13 / Stage14 / Stage15 / Stage16 GUT `73/73` tests、`1485` asserts 通过，全房间 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`，Godot import 通过。
- 2026-07-04 继续完成门禁 / 机关状态 VFX 第一轮反馈：新增 `GateStateVfx` helper，复用 `vfx_seal_magic_atlas_ai01` 给教程门、战斗门、目标门、Stage9+ 通用门和 Stage9 switch 激活补短封印动画；不改碰撞、房间推进或开门条件。验证：Godot import 通过；Stage5 / Stage6 / Stage7 / Stage9 / Stage13 / Stage14 / Stage15 / Stage16 GUT `87/87` tests、`1598` asserts；全 `39` 房 DAC OpenGL 复核 `P0=0 / P1=0 / P2=0`；本地门禁聚焦脚本 `17` 个门禁用例 `ok=true`。
- 2026-07-04 继续完成全主流程封印门状态 prop 统一替换与锁定 / 开启状态复核：教程、战斗试炼、Stage9、Stage10、Stage15、Stage16 中残留的旧 `stage13_seal_gate_01.svg` 运行态封印门绑定已统一迁到 `shrine_gate_prop_atlas_ai01`；常规锁门态现在使用关闭石门切片 `002_shrine_gate_prop_atlas_ai01_auto_003_c01` / `seal_gate_locked`，解锁后脚本切到开启切片 `003_shrine_gate_prop_atlas_ai01_auto_004_c01` / `seal_gate_open`；Stage16 relay 经后续截图复核也改回同一常规锁门态，`boss_gate_locked` 不再作为活动运行态门禁。同步修正 `shrine_gate_prop_atlas_ai01.semantics.json` 首轮机器语义，FP-02 atlas split audit 与 asset semantics audit 均通过；DAC 新增 `visible_legacy_gate_sprite` P1 检查。验证：Stage3 / Stage5 / Stage6 / Stage7 / Stage9 / Stage13 / Stage14 / Stage15 / Stage16 GUT `91/91` tests、`1518` asserts，通过全 `39` 房 DAC `P0=0 / P1=0 / P2=0`、`17` 个门禁聚焦运行态截图 `ok=true`、Godot import 和 `git diff --check`；本轮状态复核补跑 Stage5 / Stage6 / Stage7 / Stage9 / Stage14 / Stage16 GUT `57/57` tests、`850` asserts。
- 2026-07-04 继续完成普通敌人运行态可读性收敛：四类普通敌人的 `EnemyRuntimeAnimationVisual` 统一从 `scale=0.42 / alpha=0.82` 提升到 `scale=0.5 / alpha=1.0`，只影响视觉层，不改碰撞、AI、伤害或动作 timing；Stage15 GUT 增加 scale / alpha 下限断言。验证：Stage13 + Stage15 GUT `29/29` tests、`683` asserts 通过，全 `39` 房 DAC `P0=0 / P1=0 / P2=0`，Godot import 和 `git diff --check` 通过。
- 2026-07-03 已完成 Luna 全套运行态 body 动作帧 ai03 替换：用内置 `image_gen` 生成并规范化 `idle`、`run`、`jump_fall`、`attack_body`、`air_dash_body`、`hit_react`、`death_idle` 7 张单动作透明 PNG sprite sheet，共 `128` 帧、统一 `192x192` 固定格；玩家运行态和 Stage14 断言已切到 `luna_*_runtime_sheet_ai03`。验证：像素检查角落 alpha / 格边 alpha / 下半部残线均为 `0`，动作替换严格审计 `7/7 active ready`，Godot import 通过，Stage12 / Stage14 / Stage15 / Stage16 GUT `57/57` tests、`1013` asserts 通过。
- 2026-07-02 已完成 Alpha Demo 正式关卡重排执行收口：在正式计划基础上新增并加厚 formal remap GUT 契约测试，为 Tutorial / Combat / Goal / Stage9 / Stage13 / Stage14 / Stage16 普通房间补双向返回、反向 spawn、安全落点和连接处地面覆盖；Stage9 / 13 / 14 / 16 共享房间支持 scene-level spawn positions，Goal 绿色悬浮台阶改为正式石质平台读值；新增 `scripts/dev/capture_demo_formal_remap_review.gd` 输出 Phase 6 运行态复核报告。验证：Godot import 通过，formal remap GUT `4/4` tests、`125` asserts，Stage5、Stage9-16 GUT `97/97` tests、`1476` asserts，DAC / full-flow / input replay 均为 `P0=0 / P1=0 / P2=0`，input replay `rooms_seen=37`，Godot MCP CLI project / runtime tree 可连当前项目；Codex 直连 MCP 工具仍返回 editor 未连接。本轮未新增 image_gen 资产，复用现有正式地形和石质 underlay。
- 2026-07-02 复核修正：全内容主线可玩证据仍有效，但不再等同于场景美术 Kit 完成。`docs/assets/environment-art-kit-spec.md` 已冻结区域 Kit 规格；`capture_demo_art_composition_review.gd` 已加严为 strict art kit gate，新增背景覆盖、visible preview-only、visible graybox、无纹理 Polygon 地形、可见触发区色块、道具 Polygon 底板、HUD 大图遮挡和缺少正式 TileMap 装饰层检查。初始严格报告覆盖 `39` 房间，结果为 `P0=0 / P1=61 / P2=0`；本轮先修复背景覆盖、preview / graybox、连续地形 underlay、触发区色块和 Stage15 / Stage16 道具底板，再用内置 `image_gen` 生成透明规则网格地形 kit，并为 `39` 房间接入 `FormalTerrainTilemapDecor` / `607` 个视觉 tile。当前 OpenGL DAC-03 strict gate、full-flow 生产流程证据和输入式 replay wrapper 均为 `P0=0 / P1=0 / P2=0`；Stage5、Stage9-16、Stage12 GUT `97/97` tests、`1476` asserts 通过。当前达到 Alpha Demo 级资产配置验收；商业级手工 autotile、完整 parallax split、地貌边缘清稿和美术总监级签核仍属于后续 polish。
- 2026-07-01 已完成全内容 Demo 级流程证据和 MCP 输入式主线 replay 收口：`capture_full_content_flow_evidence.gd` 沿生产 `Main.tscn` 和真实房间切换契约捕获 `34` 个主线房 + `5` 个支路 / 内部房；`mcp_player_input_replay_probe.gd` 从主菜单点击 `开始` 后只用 `Input.action_press/release` 和失败继续 UI focus 跑到 `stage16_alpha_demo_end_room.tscn`，`elapsed=269.6s`、`rooms_seen=35`、`stage16_alpha_demo_completed=true`，截图包保存到 `tests/artifacts/local/full-content-demo-qa/mcp_2026_07_01/player_input_replay/`。该结果达到当前 Alpha Demo 级主线可玩验收，不等同商业最终清稿、真人录屏或 2026-07-02 strict art kit gate。
- 2026-06-27 剩余美术资产管线 P0 / P1 已完成第一轮处理：raw candidate PNG 按存储策略视为 ordinary Git 外可选原始证据，当前 Git 可重放资产包审计、来源安全、provenance、final art gate、Godot import、TileSet editor audit 和 Stage13 / Stage14 / Stage15 / Stage16 GUT 均通过；runtime integration map 已推进为 `55/55 scene_reference_verified`。本轮未新增 image_gen 输出；后续动作帧生成已锁定透明背景规则网格 sprite sheet 规格。
- 最终美术精修 FP-01 已完成第一轮运行态读值截图 / JSON smoke：Stage13 entry、Stage14 shrine / gate、Stage15 Boss room、Stage16 seal release threshold 的目标 visual preview 节点均可见、资源和 `asset_id` 正确，且没有误挂 Area / Collision 子节点。下一步进入 FP-02 atlas / 大图语义拆分精修。
- 最终美术精修 FP-02 已完成第一轮 atlas / 大图语义拆分审计：3 个 atlas 为 `split_ready`，`reusable_seal_props_ai01` 为 `standalone_preview_ready`；没有触发 P2 重生图。
- 最终美术精修 FP-03 已完成第一轮 TileSet 语义和 collision 复核：`miasma_marsh_tileset_ai01` 与 `shrine_trial_tileset_ai01` 均为 `tileset_semantics_ready`，Godot TileSet audit、Stage13 / Stage14 GUT 与资产总门禁通过；没有触发 P2 重生图。
- 最终美术精修 FP-04 已完成第一轮 UI / NinePatch / HUD 小尺寸复核：`menu_ninepatch_ui_ai01` 的 `8` 个 StyleBoxTexture、`9` 个 Theme mappings、DemoShell / TutorialHUD runtime references、`4` 个 standalone UI panel rules、`2` 个小图标源图与 `3` 个 UI atlas regions 均通过结构和引用审计；没有触发 P2 重生图。
- 最终美术精修 FP-05 与完成审计已完成：active animation candidates 为 `15/15 active ready`、VFX rules 为 `7 assets / 86 frame rules`、animation rules 为 `8 assets / 172 frame rules`，Luna attack / Air Dash、Seal Guardian attack VFX 与 enemy hit spark 运行态截图复核通过；最终完成审计为 `5/5 FP batches, 2/2 final gates, 0 errors`。本轮 FP-01 到 FP-05 均未触发 image_gen 重生成。
- Batch 04 音频资产已有全量生成参考入口：`docs/assets/audio-asset-prompt-reference.md` 现已覆盖角色动作、战斗、UI、环境 / 氛围、物品交互、古代机关 / 机械、怪物 / NPC、BGM、语音、系统反馈和音频配置资产；当前只完成 prompt / 路径 / 命令 / 配置入口文档，不生成实际音频、不接入运行时代码。
- 2026-06-28 已修复 DemoShell 开始界面错位和“点击开始后只剩标题背景”的问题：标题背景现在只在主菜单显示，开始后隐藏；主菜单面板加宽并重新排布标题、状态文案和开始按钮。
- 2026-06-28 已修复教程运行态玩家旧占位视觉与正式 Luna 动画叠加的问题，并把 `JumpGuidePlatform` 调整为能从下方通过、也能实际跳上的教学平台；Stage5 真实跳跃 / 下方通行回归、Stage12 / Stage14 资产保护和运行态截图复核均通过。
- 2026-06-28 已完成一轮 Godot MCP Pro 运行态 UI / 主流程 smoke：主菜单、开始后、暂停菜单和完成面板布局均已截图复核；暂停面板破碎装饰层已隐藏，教程提示字号下调以避免明显裁切；MCP 压力输入和 Stage1 / Stage2 / Stage5 / Stage12 / Stage14 / Stage16 GUT 均通过。
- 2026-06-28 已修复教程攻击步骤红色封印柱不可被攻击打开的问题，并把教程 HUD / 状态 HUD 收紧为小尺寸安全区文案；Godot MCP Pro 真实 `attack` 输入验证红柱命中后 `step=exit`、出口解锁、碰撞禁用，Stage5 / Stage12 / Stage16 GUT 均通过。
- 2026-06-29 已生成系统性关卡场景和地图布置计划：新增设计方向、正式计划和 LL-00 到 LL-06 执行清单；下一步默认先执行 LL-00 逐房审计，不直接大规模重铺地图。
- 2026-06-29 已完成 LL-00 到 LL-06 第一轮执行：新增逐房审计脚本，审计 `27` 个关键房间并清零 `P0/P1`；补齐 `3` 个样板房 visual-only TileMapLayer 与 `stage16_corruption_purge` hazard author Area；当前剩余 `P2=21`，不阻塞 Alpha Demo 主链路，后续进入现有资产复用 / 批量 visual replacement。
- 2026-06-29 已完成 Broad Art P2 visual replacement Pass 01-05：复用现有 miasma / shrine / seal / UI 资产补齐剩余 P2 visual gaps；LL-00 审计从 `P2=21` 降到 `P2=0`，Stage5 / Stage13 / Stage14 / Stage15 / Stage16 GUT `65/65` 通过，RoleMux / agy 独立交叉核验为 `PASS`，本轮不触发 image_gen。
- 2026-06-30 已完成 P1 / P2 / P3 样板闭环：UI 文案和面板收紧，教程训练靶与出口封印柱替换为现有正式符印资产，Tutorial / Stage13 entry / Stage14 gate / Stage15 boss / Stage16 end 五个样板房 TileMap 承担主要地形视觉并隐藏对应灰盒多边形视觉；Stage5 / Stage6 / Stage12 / Stage13 / Stage14 / Stage15 / Stage16 GUT `83/83` 通过，LL-00 仍为 `P0=0 / P1=0 / P2=0`。
- 2026-06-30 复核修正：用户运行态截图证明当前旧审计口径不能判断 Demo 级资产配置合理性；`P2=0` 只代表资源绑定 / 结构审计清零，不代表背景覆盖、道路连续、脚底贴合、视觉碰撞一致、路线末端安全和整体场景构图完成。已新增 `docs/implementation-plans/2026-06-30-demo-art-composition-asset-configuration-plan.md`，后续按 DAC-00 到 DAC-07 推进整体关卡美术配置修复。
- 2026-06-30 已完成 DAC-01 主路线资产配置第一轮修复：Stage13 entry 和五个 P3 样板房恢复连续地形 underlay、背景相机覆盖和可见出口 / 目标标记；主路线红色 `BarrierVisual` 封印柱替换为现有封印门图；Alpha Demo 主路线 `20` 个关键房间通过 `capture_demo_art_composition_review.gd` 运行态截图审计，DAC 报告为 `P0=0 / P1=0 / P2=0`；Stage5 / Stage13 / Stage14 / Stage15 / Stage16 GUT `67/67` 通过。
- 2026-06-30 已完成 DAC-02 支路扩展审计和第一轮发布级美术签核口径：`capture_demo_art_composition_review.gd` 覆盖扩展到 `27` 个主线 / 支路关键房间，新增 `Decor` 与 `Signoff` 字段；补齐剩余地表材质过渡层并清理 Stage15 challenge branch 红色占位门；当前 DAC-02 为 `P0=0 / P1=0 / P2=0`，`27/27` 房间进入 `manual_review_candidate`。
- 2026-06-25 复核结论：动作正式替换批次的活跃候选严格审计已通过，runtime source review queue 清零；当前剩余历史 blocked reference 仅作为归档证据保留，不再构成活跃替换阻塞。

## Recent Status Changes

### 2026-07-18 - Macro Metroidvania world graph established

- 将线性 34 房主线保留为安全首次通关路径，同时以 3 个闭合区域环路和 5 条远端连接建立真实回访结构；捷径继续复用 `room_transition_requested` 与独立 spawn，不引入第二套地图管理器。
- `Stage9RoomBase` 提供通用能力 / 奖励门控捷径与叙事碑；Main 持久保存 `marsh_relic`、`warden_sigil`；Stage13 两条支路在出口、危险和长期收益上均已分离。
- 12 组锚点房加入秘密墙、机关、碑文和区域地标；秘密墙可见实体与碰撞尺寸一致，全房正式薄平台逐格确认 one-way 且缩放后厚度不超过 `4px`。
- 验证：Stage18 `12/12` / `1711` asserts；全量 GUT `257/257` / `7919` asserts；39 房 DAC 与 34 房 input-only 首次通关 replay 均为 `P0/P1/P2=0`；Godot import / smoke 通过。
- 详情：`spec-design/2026-07-18-macro-metroidvania-world-graph-design.md`、`plan/2026-07-18-macro-metroidvania-world-graph.md`、`docs/implementation-plans/2026-07-18-macro-metroidvania-world-graph.md`、`docs/progress/logs/2026-07-18.md`。当前分支未合并 / push。

### 2026-07-11 - Stage17 animation runtime stabilization completed on branch

- 状态：Luna、四类普通敌人与 Seal Guardian 的 Animation State Contract 已实现，Stage17 开发与自动化验收完成。
- 范围：短动作关键帧、Jump Model Lock v1、普通敌人 cycle / defeat、Ground Charger 读招与状态动作、Boss recovery / staggered、统一运行探针和输入式 Demo 重放；不增加房间、敌人、投射物或北极星核心系统。
- 验证：Stage17 `10/10` tests、`118` asserts；全量 GUT `229/229` tests、`6245` asserts；strict audit `21/21 active ready`；OpenGL probe `ok=true`；input smoke `ok=true`；input-only replay `34` 次主线房间进入并完成 Stage16，`P0/P1/P2=0`。
- 边界：尚未合并 / push；实体手柄硬件认证和真人体验签核不由自动化结论代替，`AGENTS.md` 仅在合并后更新。

### 2026-07-11 - AGENTS repository contract slimmed

- 状态：根 `AGENTS.md` 已从阶段手册和工具知识库收敛为稳定的仓库执行契约。
- 范围：保留北极星、中文协作、任务分级、代码契约、文档门禁、验证和 Git 安全原则；动态状态与操作细节改读现有专题文档。
- 验证：根文件 `108` 行、`8` 个章节；陈旧阶段、端口、Batch、旧主场景说明和 UTF-8 单次故障词扫描无匹配。
- 边界：不改变 Stage17 设计、动画、玩法、资产或测试范围。

### 2026-07-11 - Stage17 animation runtime stabilization plan confirmed

- 状态：已批准 Stage17 动作运行态稳定化边界，形成设计文档、正式阶段计划和逐任务执行清单。
- 方案：不拉长玩家攻击 / Dash，不暴力倍速完整长动画；改为 gameplay phase -> keyframe contract。普通敌人共享入口一次启动 cycle，Boss 新增 recovery 并把 guard-break stagger 独立出来。
- 文档：`spec-design/2026-07-11-stage-17-animation-runtime-stabilization-design.md`、`plan/2026-07-11-stage-17-animation-runtime-stabilization.md`、`docs/implementation-plans/2026-07-11-stage-17-animation-runtime-stabilization.md`。
- 边界（计划确认时）：Formal Demo 本地回退点 `985ec28` 已建立并切到 `codex/stage-17-animation-runtime-stabilization`；后续实现与完成状态以上方最新条目为准。

### 2026-07-11 - Animation, room content and North Star audit

- 状态：确认动作资产“几何 ready”不等于运行态动作完成，并建立 39 房内容目录与北极星差距矩阵。
- 证据：普通敌人运行探针全部 `is_playing=false / frame 0 -> 0`；Boss `state=staggered / visible=false`；Luna 攻击、Dash、受击资源时长均长于玩法状态窗口。
- 文档：`docs/assets/2026-07-11-character-enemy-animation-runtime-audit.md`、`spec-design/2026-07-11-alpha-demo-room-content-catalog.md`、`spec-design/2026-07-11-north-star-implementation-audit.md`。
- 下一步：先修 Animation State Contract，再做最小 `2 姿态 + 2 元素 + 2 步序列` 核心玩法验证；不继续盲目生成 ai04 或增加敌人种类。

### 2026-07-11 - Formal Demo Map Redesign 39-room closure

- 状态：三类样板与 Batch 1-9 已完成，当前分支达到 `39/39` 房正式重排候选。
- 范围：房间尺寸、地形轮廓、敌人空间、门控、支路、回溯、地标、双向连接和安全 spawn；不重写玩家控制、敌人 AI 或存档。
- 验证：全量 GUT `219/219` tests、`6105` asserts；39 房运行态截图 `P0=0 / P1=0 / P2=0`；Godot import 通过；Stage16 driver 到达 Alpha Demo End。
- 边界：尚未合并 `main`；仍需真人连续试玩与最终美术签核，区域背景和装饰多样性不冒充商业版终稿。

### 2026-07-05 - DemoShell main menu composition correction

- 状态：标题主菜单不再作为中心大弹窗遮住背景主体，当前是左侧紧凑导航面板。
- 范围：`DemoShell` 主菜单按 viewport 动态计算宽度和左侧留边，宽度限制在 `300-420`，按钮高度约 `31`；保留六项入口和详情页逻辑，不新增 UI 图片。
- 验证：Stage16 GUT `18/18` tests、`463` asserts；`godot --headless --path . --import` 通过；`capture_demo_shell_layout_hover_review.gd` 与 `capture_demo_shell_start_review.gd` 均为 `ok=true`；`menu_normal_2048x1152.png` / `menu_hover_2048x1152.png` 目检确认背景成为主视觉且 hover 不压扁按钮。
- 边界：本轮不等于正式标题 Logo、完整设置 / 选关系统或主菜单动效完成。

### 2026-07-05 - Stage14 backtrack reward pedestal runtime replacement

- 状态：Stage14 回溯 hub 的三枚奖励不再只是孤立漂浮晶体，运行态已有小型石质奖励标识承托。
- 范围：`BacktrackRewardOne/Two/Three` 均新增 `RewardPedestalArt`，复用 `shrine_gate_prop_atlas_ai01.reward_marker_idle` AtlasTexture；`RewardArt` 仍是上层奖励晶体；不改奖励计数、收集距离、隐藏逻辑、出口、HUD 或玩家路线。
- 验证：Stage14 GUT `16/16` tests、`379` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage14_backtrack_hub.png` 目检确认奖励点可读且未遮挡路线。
- 边界：本轮不等于正式奖励经济、拾取动画、拾取音效、背包 UI 或 Stage14 回溯链路终稿完成。

### 2026-07-05 - Stage16 purge focus base runtime replacement

- 状态：Stage16 purge 房净化确认点不再只是孤立符印光点，运行态已有石质净化机关承托确认 VFX。
- 范围：`CorruptionPurgeNode` 新增 `PurgeFocusBaseArt`，并从远景较弱的 `shrine_gate_prop_atlas_ai01.seal_ring_active` 收敛为 `shrine_gate_prop_atlas_ai01.miasma_ward_purged` AtlasTexture；`TalismanRelayEchoArt` 仍是上层确认 VFX；不改妖瘴危险 Area、净化接近距离、门控、出口、HUD 或玩家路线。
- 验证：Stage16 GUT `18/18` tests、`462` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage16_purge.png` 目检确认净化点有石质机关底座和上层净化光效，且未遮挡路线。
- 边界：本轮不等于专用净化激活动画、危险区 VFX 全套清稿、净化音效或 Stage16 终局演出完成。

### 2026-07-05 - Stage16 relay focus base runtime replacement

- 状态：Stage16 relay 房三枚中继不再只是孤立符印光点，运行态已有小型符印器物承托发光层。
- 范围：`TalismanRelayA/B/C` 均新增 `RelayFocusBaseArt`，复用 `shrine_gate_prop_atlas_ai01.seal_ring_idle` AtlasTexture；`RelayArt` 仍是上层符印 VFX；不改 `required_talisman_relay_count`、接近距离、门控、出口、HUD 或玩家路线。
- 验证：Stage16 GUT `18/18` tests、`452` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage16_relay.png` 目检确认 relay 可读且未遮挡路线。
- 边界：本轮不等于专用 relay 激活动画、三段收集音效、完整终局演出或 Stage16 关卡终稿完成。

### 2026-07-05 - Stage15 pressure focus prop runtime replacement

- 状态：Stage15 pressure 房压力点不再只像悬浮 VFX / UI 标记，运行态已有可见封印机关底座承托能量层。
- 范围：新增 `PressureFocusArt`，复用 `shrine_gate_prop_atlas_ai01.seal_pillar_intact` AtlasTexture；`PressureSigilArt` 仍是上层封印能量 VFX；不改压力逻辑、敌人、出口、碰撞、HUD 或房间推进。
- 验证：Stage15 GUT `17/17` tests、`404` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage15_pressure.png` 目检确认机关焦点可读且未遮挡路线。
- 边界：本轮不等于专用封印压力动画、机关交互音效、完整危险 VFX sheet、Boss 前压迫演出或 Stage15 关卡终稿完成。

### 2026-07-05 - Luna runtime render layer correction

- 状态：Luna 运行态 body 已明确绘制在正式前景边缘之上，不再因为 `FormalForegroundEdgeDecor` 层级覆盖而读成嵌入地面。
- 范围：只把 `PlayerPlaceholder.z_index` 设为 `3`，并补 Stage14 玩家资产测试断言；不改碰撞体、动作帧、相机、房间地形或门禁资源。
- 验证：Stage14 GUT `16/16` tests、`352` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；2K 专项复核 `ok=true` / `camera_zoom=[3.2, 3.2]`；`stage14_gate.png` 与 `stage16_threshold.png` 目检确认 Luna 不再被前景边缘盖脚。

### 2026-07-05 - Stage10 main optional branch marker runtime replacement

- 状态：Stage10 主房左侧可选奖励支路入口不再只靠低透明触发区和 HUD 文案读值，运行态已有可见 `reward_orb_small` 标识。
- 范围：`BranchZone/BranchMarkerArt` 新增 `Sprite2D`，复用 `equipment_pickup_atlas_ai01.reward_orb_small` AtlasTexture；不改 `BranchZone` 碰撞、可选支路跳转、空中攻击价值点、敌人遭遇或 HUD 读值。
- 验证：Stage10 GUT `11/11` tests、`106` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage10_aerial.png` 目检确认可选支路标识可读且未遮挡 Luna、HUD、空中价值标识、敌人、平台或主线出口。
- 边界：本轮不等于完整小地图、选关系统、支路奖励经济、入口动画、音效或 Stage10 关卡终稿完成。

### 2026-07-05 - Stage15 gauntlet challenge branch marker runtime replacement

- 状态：Stage15 mixed gauntlet 房左侧挑战支路入口不再只靠低透明触发区和 HUD 文案读值，运行态已有可见 `boss_core_shard` 标识。
- 范围：`ChallengeBranchZone/ChallengeMarkerArt` 新增 `Sprite2D`，复用 `equipment_pickup_atlas_ai01.boss_core_shard` AtlasTexture；不改 `ChallengeBranchZone` 碰撞、支路跳转、敌人遭遇、Boss 门控或 HUD 读值。
- 验证：Stage15 GUT `17/17` tests、`392` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage15_gauntlet.png` 目检确认挑战支路标识可读且未遮挡 Luna、HUD、敌人、地面或右侧 Boss 门路线。
- 边界：本轮不等于完整挑战房系统、支路奖励经济、入口动画、门禁音效或 Stage15 关卡终稿完成。

### 2026-07-05 - Stage14 loop return goal marker runtime replacement

- 状态：Stage14 回环房右侧目标入口不再只靠低透明触发区和 HUD 文案读值，运行态已有可见 `map_scrap` 路线标识。
- 范围：`GoalZone/GoalMarkerArt` 新增 `Sprite2D`，复用 `equipment_pickup_atlas_ai01.map_scrap` AtlasTexture；不改 `GoalZone` 碰撞、Stage14 到 Stage15 的房间推进、checkpoint 或 HUD 读值。
- 验证：Stage14 GUT `16/16` tests、`349` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage14_loop_return.png` 目检确认目标标识未遮挡 Luna、HUD、地面、右侧门槛或出口路线。
- 边界：本轮不等于完整小地图、选关系统、出口动画、门禁音效或 Stage14 关卡终稿完成。

### 2026-07-05 - Stage10 value / recovery / reward marker runtime replacement

- 状态：Stage10 空中攻击价值点、支路恢复点、支路收集物和挑战房奖励点不再只是不可见 `Marker2D`，运行态已有可见符饰 / checkpoint / 奖励标识。
- 范围：`AirAttackValueMarker/ValueArt`、`RecoveryPoint/CheckpointArt`、`BranchCollectible/CollectibleArt`、`ChallengeCollectible/CollectibleArt` 新增 `Sprite2D`，分别复用 `equipment_pickup_atlas_ai01.air_dash_charm`、`shrine_gate_prop_atlas_ai01.checkpoint_active`、`equipment_pickup_atlas_ai01.reward_orb_small`、`equipment_pickup_atlas_ai01.boss_core_shard`；不改触发距离、收集计数、恢复逻辑、支路跳转、挑战房推进或 HUD 读值。
- 验证：Stage10 GUT `11/11` tests、`98` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage10_aerial.png`、`stage10_branch.png` 与 `stage10_challenge.png` 目检确认价值点、恢复点和奖励点可读且未遮挡路线。
- 边界：本轮不等于正式奖励经济、拾取动画、拾取音效、checkpoint 激活动画、空中攻击专用教学演出或背包 UI 完成。

### 2026-07-05 - Stage13 checkpoint runtime prop replacement

- 状态：Stage13 checkpoint 房不再只有不可见 `RecoveryPoint` 逻辑点，运行态已有可见 checkpoint prop。
- 范围：`RecoveryPoint/CheckpointArt` 新增 `Sprite2D`，复用 `shrine_gate_prop_atlas_ai01.checkpoint_active` AtlasTexture；不改 checkpoint 信号、重生、碰撞、HUD 或房间推进。
- 验证：Stage13 GUT `13/13` tests、`360` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage13_checkpoint.png` 目检确认 checkpoint prop 可读且未遮挡路线。
- 边界：本轮不等于正式存档系统、保存 UI、checkpoint 音效或激活动画完成。

### 2026-07-05 - Stage13 branch reward marker runtime replacement

- 状态：Stage13 资源 / 挑战支路的奖励点不再只是逻辑 Marker，运行态已能看到现有 equipment atlas 的奖励标识。
- 范围：两条支路的 `Stage13Reward` 下新增 `RewardArt`，资源支路复用 `equipment_pickup_atlas_ai01.seal_fragment`，挑战支路复用 `equipment_pickup_atlas_ai01.reward_orb_large`；挑战支路奖励点轻微左移；不改奖励计数、支路返回、碰撞、HUD 或房间推进。
- 验证：Stage13 GUT `13/13` tests、`351` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage13_resource_branch.png` 与 `stage13_challenge_branch.png` 目检确认奖励点可读且未遮挡路线。
- 边界：本轮不等于正式奖励经济、拾取动画、拾取音效、背包 UI 或奖励平衡完成。

### 2026-07-05 - Stage15/16 seal-chain split foreground prop expansion

- 状态：封印链关键房间不再只有 threshold 一处有拆分链锚 prop；Stage15 completion 和 Stage16 backtrack 也已接入同一套可见拆分单件前景装饰。
- 范围：`CompletionSeal` 与 `BacktrackConfirmationNode` 新增 `SealChainAnchorLeftArt` / `SealChainAnchorRightArt`；继续复用 `shrine_gate_prop_atlas_ai01.chain_anchor_left/right` AtlasTexture；不改 `ReusableSealPropsPreviewArt` 的隐藏边界、不改 Stage15 到 Stage16 接入、backtrack 门禁、ExitZone、checkpoint 或 Stage16 房间推进。
- 验证：Stage16 GUT `18/18` tests、`422` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage15_completion.png` 与 `stage16_backtrack.png` 目检确认链锚 prop 不遮挡路线、HUD、敌人或门禁。
- 边界：本轮是现有 prop atlas 的封印链小范围扩展，不等于完整区域前景装饰包、手工 autotile、门禁动画、门禁音效或 source sheet 全面拆分完成。

### 2026-07-05 - Stage16 threshold split foreground prop integration

- 状态：Stage16 第一房不再只有隐藏的 reusable seal source sheet 作为编辑期线索，已接入两个可见的拆分链锚前景 prop。
- 范围：新增 `SealChainAnchorLeftArt` / `SealChainAnchorRightArt` 两个 `Sprite2D`，复用 `shrine_gate_prop_atlas_ai01.chain_anchor_left/right` AtlasTexture；不改 `ReusableSealPropsPreviewArt` 的隐藏边界、不改门禁碰撞、ExitZone、checkpoint 或 Stage16 房间推进。
- 验证：Stage16 GUT `18/18` tests、`378` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage16_threshold.png` 目检确认链锚 prop 不遮挡路线、HUD 或门禁。
- 边界：本轮是现有 prop atlas 的单房间拆分接入，不等于完整区域前景装饰包、手工 autotile、门禁动画、门禁音效或 source sheet 全面拆分完成。

### 2026-07-05 - TutorialHUD core icon, objective marker and panel art unification

- 状态：左上常驻 HUD 的生命、冲刺、恢复三枚小图标已统一到同一 `icon_sheet_core_ai01` 图集，普通目标行徽标也已切到 `hud_core_ui_atlas_ai01.room_goal_marker`，HUD / 提示面板补入 `menu_ninepatch_ui_ai01` 深色 atlas 贴图层，不再混用 standalone 大图、旧 SVG、纯平面小黑框和图集小图标。
- 范围：`TutorialHUD/BattlePanel/DashIcon` 改用 `icon_sheet_core_ai01.air_dash`，`RecoveryChargeIcon` 改用 `icon_sheet_core_ai01.recovery_charge`，`ObjectiveIcon` 改用 `hud_core_ui_atlas_ai01.room_goal_marker`，`PromptPanelArt` / `BattlePanelArt` 复用现有 `menu_ninepatch_ui_ai01` atlas；只换 TextureRect 资源、metadata 和普通 / 恢复 / Boss 行的徽标显隐位置，不改 HUD 数值、恢复机制或 Boss 条。
- 验证：Stage12 GUT `10/10` tests、`237` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`tutorial_room.png`、`stage13_entry.png`、`stage15_pressure.png` 和 `stage15_boss.png` 目检确认图标与面板贴图统一、未变形、未遮挡运行画面。
- 边界：本轮不等于完整 HUD 设计系统、Boss / 能力 HUD 清稿、设置 / 选关 UI 或音频完成。

### 2026-07-05 - Stage13 goal device runtime prop replacement

- 状态：Stage13 目标房的 `GoalDevice` 不再是亮色 `Polygon2D` 占位，已替换为现有 `shrine_gate_prop_atlas_ai01.miasma_ward_idle` 石质 / 青光 prop。
- 范围：只改 `GoalDevice` 的显示节点、资源路径、metadata、scale 和 `z_index`；不改 `GoalZone`、碰撞、checkpoint、Stage13 到 Stage14 的主线跳转或 HUD。
- 验证：Stage13 GUT `13/13` tests、`332` asserts；`godot --headless --path . --import` 通过；全内容流程截图证据 `P0=0 / P1=0 / P2=0`；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage13_goal_device.png` 目检确认目标区域 prop 可读且未遮挡地形。
- 边界：本轮不等于完整区域前景装饰包、手工 autotile、专用目标交互动画或音效完成。

### 2026-07-04 - DemoShell semantic button icon polish

- 状态：DemoShell 不再把整张菜单 icon sheet 误当主菜单装饰，也已把语义匹配的按钮图标接入到实际可见的小面板按钮。
- 范围：新增 `stage16_demo_menu_icons_ai01` 的 `continue_play`、`restart`、`back` 三个 AtlasTexture editor resource；只接入暂停继续、暂停重开、失败继续和详情返回按钮。主菜单六项暂不接图标，因为现有 icon sheet 没有开始、设置、选关、退出等准确语义；`capture_demo_shell_layout_hover_review.gd` 增加 `2048x1152` case，并把脚本 hover 验收收敛为几何命中 + 截图留证，保留 `is_hovered()` 字段作诊断。
- 验证：Stage16 GUT `18/18` tests、`356` asserts；`godot --headless --path . --import` 通过；`capture_demo_shell_start_review.gd` 通过；`capture_demo_shell_layout_hover_review.gd` 覆盖 `640x360`、`1024x576`、`2048x1152` 三档并返回 `ok=true`。
- 边界：本轮是复用现有 icon sheet 的安全接入，不等于完整主菜单 icon set、正式设置 / 选关系统、UI 动效或最终按钮清稿完成。

### 2026-07-04 - Stage16 seal release prop readability polish

- 状态：Stage15 completion、Stage16 threshold、Stage16 backtrack 的封印释放三状态道具不再在运行态距离下读成像素噪点。
- 范围：继续复用现有 `stage16_seal_release_threshold_ai01` locked / active / released 三个 AtlasTexture，只把 `SealCompletionArt`、`SealReleaseThresholdArt`、`BacktrackConfirmationArt` 的 scale 从 `0.055` 提到 `0.085`，局部 y 从 `-12` 下移到 `8`；Stage16 测试增加可读性 scale / y 断言；不新增图片、不改门控、碰撞、房间推进或 source sheet 隐藏策略。
- 验证：Stage16 GUT `18/18` tests、`341` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage15_completion.png`、`stage16_threshold.png`、`stage16_backtrack.png` 目检确认三状态 prop 可读且未遮挡路径或门禁。
- 边界：本轮是现有三状态 AtlasTexture 的运行态尺寸校正，不等于专用开门动画、门禁 SFX、完整机关状态机或最终 prop 清稿完成。

### 2026-07-04 - Stage16 completion art safe-area polish

- 状态：Stage16 终点房完成反馈大图不再贴住 640 基准镜头右边缘或读成被裁切的 UI。
- 范围：`stage16_alpha_demo_end_room.tscn` 继续复用现有 `stage16_alpha_demo_completion_ai01` 与 `stage16_completion_panel_ui_ai01`，只调整 `AlphaDemoCompletionArt` 的位置 / 缩放和文字牌安全区；Stage16 测试新增完成图整图盒子左右边界和缩放上限断言；不新增图片、不改完成触发、ExitZone、HUD 完成态或房间推进。
- 验证：Stage16 GUT `18/18` tests、`326` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage16_end.png` 目检确认完成图完整留在右侧区域内，`Alpha Demo 已完成` 文案仍可读。
- 边界：本轮是现有完成反馈资产的运行态安全区校正，不等于结算页、完成动画、音效或最终 UI 清稿完成。

### 2026-07-04 - Stage16 talisman relay readability polish

- 状态：Stage16 relay 房间的符印中继不再在运行态距离下读成过小弱几何点。
- 范围：`stage16_talisman_relay_room.tscn` 中三个 `RelayArt` 继续复用 `stage16_talisman_relay_ai01` region-bound VFX，只把视觉层 `scale` 从 `0.045` 提到 `0.065`；Stage16 测试增加 `0.06-0.08` 可读性边界断言；不新增图片、不改门控、碰撞、房间推进或 HUD。
- 验证：Stage16 GUT `18/18` tests、`322` asserts；`godot --headless --path . --import` 通过；全 `39` 房 DAC `P0=0 / P1=0 / P2=0`；`stage16_relay.png` 目检确认中继可读且未遮挡路径、门禁或 HUD。
- 边界：本轮是现有 VFX region 的运行态尺寸校正，不等于专用中继动画、门禁 SFX、Boss 门状态机或完整机关资产包完成。

## Current Risks

- Stage18 已建立自动可达与门控证据，但尚无正式地图 UI、存档式探索状态或真人路线发现测试；当前主要设计风险是玩家是否能自然记住 SC-01 / SC-02 / SC-05 的前置地标，以及两条 Stage13 支路的奖励吸引力是否足以支撑回访。
- Stage17 的脏工作树前置风险已由 Formal Demo 回退点 `985ec28` 和专用阶段分支解除；当前主要交付风险转为“尚未合并 / push，以及实体手柄与真人体验尚未签核”，不再是动作运行代码缺失。
- 2026-07-04 2K 同 16:9 运行态已通过 Camera2D zoom 收回到 640x360 设计视野，不再直接暴露上一轮截图中的明显竖向背景拼接缝；但这不等于背景商业清稿完成。若后续要支持 21:9、自由缩放镜头或大幅横向可视范围，仍需要背景无缝化、parallax split、可延展边缘或逐房宽屏构图 polish。
- 2026-06-19 内置 `image_gen` 已生成 Batch00 / Batch01 / Batch02 / Batch03 / Batch06-Batch13 的 `55/55` 个候选 PNG；2026-06-20 已追加补充候选用于 duplicate clearance；2026-06-21 已追加当前项目确认候选用于 `luna_jump_fall_sheet_ai01` 和 `stage16_seal_release_threshold_ai01`，并追加 `stage16_demo_menu_icons_ai01_candidate_02` 与 `stage14_air_dash_icon_ai01_candidate_02` 两个评审候选；9 个 standalone runtime UI / VFX / prop PNG 已补齐带 `project_key = nano-hunter` 的 `.source.json`，`hud_core_ui_atlas_ai01` 已从 `candidate_01` 重建 selected source 与 atlas。同日继续为 15 个 runtime review-required 资产追加统一风格重生候选，当前候选池为 `120` raw candidates、`547` selected sources、`82` unselected candidates；source safety 为 `0` unsafe，runtime source safety 仍有 `15` 个 runtime assets 需来源 / 派生复核。当前已生成 target-count `assets/art` 候选 sheet / atlas / standalone PNG，`26/26` 个 atlas-linked outputs 已达到 `expected_target` 且全部 `duplicates=0`；非 SpriteFrames atlas-linked 输出已生成 `302` 个 Godot `AtlasTexture` editor resources，Batch07 两套 TileSet sheet 已生成 `2` 个 Godot `TileSet` `.tileset.tres`、`2` 个 `.tileset_rules.json`、`96` 个 tile rules、`64` 个 collision-ready tiles 和 `8` 个 hazard visual-only tiles，Batch08 `menu_ninepatch_ui_ai01` 已生成 `8` 个 Godot `StyleBoxTexture` 资源骨架、`1` 个 Godot `Theme` 候选、`9` 个 Theme stylebox mappings 和 `4` 个 standalone UI skin panel rules，Batch10 / standalone VFX 已生成 `6` 个 VFX rule sidecars 与 `73` 条 anchor-blend rules，Batch06 角色 / 敌人 Sprite Sheet 已生成 `8` 个 animation rule sidecars 与 `172` 条 frame rules，Batch11 已生成 `2` 个 Spine-style cutout exports / `48` 个 part descriptors；P0 runtime replacement plan 当前为 `28/28` already referenced，final-art `runtime_replacement` gate 为 `37 passed / 18 blocked`；Art readiness 报告确认 `55/55` structural-ready、`13/55` final-ready；综合资产包审计报告 `ok=true`。风险转为“剩余 42 个资产的候选质量、授权记录、15 个 runtime review-required 来源复核、TileSet 碰撞 / terrain 人工复核、正式危险 Area author、UI Theme 最终套用和读值、VFX mask / timing / runtime hookup、角色动画帧序 / 基线 / timing 复核、NinePatch 清稿、Spine parts 语义绑定和游戏内正式接入仍未完成”；`stage16_talisman_relay_ai01` 只批准为当前 Stage16 region-bound visual VFX。
- Batch 00-05 当前是资产需求与治理记录，不代表资产已生成或接入。
- Batch 06-13 当前已有 target-count 候选 Sprite Sheet、Texture Atlas、TileSet sheet、Spine 拆件图集、UI 图集、VFX 图集和九宫格 sheet；它们是 `provisional / target-count pass`，不代表最终清稿或玩法接入完成。
- `docs/assets/image-gen-prompt-queue.json` 当前是 `55` 条生产队列，不是资产完成证明；queue 条目只有在真实 PNG 落盘、筛选、清稿、图集化并验证后才能改为接入状态。
- `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md` 与 `docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md` 是执行单，不是完成证明。
- `docs/assets/image-gen-preview-log.md` 记录的是未落盘会话预览；除非后续导入真实 PNG，否则不视为资产完成。
- `assets/source/imagegen_inbox/` 是 Codex Desktop 手动下载 / 另存预览图的本地接力目录，只保留 `.gitkeep`；实际图片默认不进入普通 Git，确认 asset id 后用 `scripts/assets/import_imagegen_outputs.py --include-inbox` 或 `--source` 导入。
- `scripts/assets/import_imagegen_outputs.py --magic-scan` 是排查无扩展名缓存的诊断选项；扫描结果仍需人工确认，不能自动导入 Temp、clipboard 或插件图片。
- Batch00 当前是全局风格板 `1/1` 原始候选已落盘；只能作为 art direction 参考，不能替代具体游戏资产。
- Batch01 当前是 `8/8` 原始候选已落盘；其中单图方向稿仍需去背景、清边、缩放读值检查和人工筛选，不能更新为 `integrated`。
- Batch06 当前已生成 target-count 核心 sprite sheet 与 `SpriteFrames`；相关角色 / Boss / 敌人 atlas-linked 输出均已降到 `0` duplicate，但仍需人工帧序、角色一致性、碰撞读值和动画速度复核，不能直接替换玩家或敌人正式动画。
- Batch07 当前已生成第一版 TileSet / texture sheet，并已有 `miasma_marsh_tileset_ai01` 与 `shrine_trial_tileset_ai01` 的 Godot `.tileset.tres` 和 `.tileset_rules.json`；两个 TileSet 已具备 first-pass physics layer、terrain set、solid / one-way platform 碰撞候选和 hazard / decor visual-only 规则。但 TileSet 仍是自动裁切结果，尚未配置 autotile、navigation、occlusion、正式伤害 Area 或运行时 TileMap 引用，仍需人工重切、统一网格、碰撞误读和危险边界复核。
- Batch08 当前已生成第一版 UI atlas、icon sheet 和 NinePatch sheet；`menu_ninepatch_ui_ai01` 已有 `8` 个 Godot `StyleBoxTexture` 资源骨架，但仍需去文字、统一线宽、九宫格边界检查、拉伸失真复核、Theme 接入和 32x32 / 64x64 读值复核。
- Batch08 supplemental 当前已生成 pause / completion panel、Boss HUD frame 和 ability status HUD 四张 standalone UI PNG，但仍需切片、mask / NinePatch 设计、小尺寸读值、伪文字清理和运行态 UI 接入复核。
- Batch09 当前已生成第一版 prop / equipment atlas；`shrine_gate_prop_atlas_ai01` 和 `equipment_pickup_atlas_ai01` 已降到 `0` duplicate，但仍需拆件语义命名、状态帧整理和缩放读值检查，不能直接替换 shrine / gate / checkpoint / pickup 物件。
- Batch10 当前已生成第一版 VFX atlas 与 `SpriteFrames`；`vfx_combat_atlas_ai01` 与 `vfx_seal_magic_atlas_ai01` 均已降到 `0` duplicate，但正式版必须去文字、重排纯帧格并控制每组 VFX 锚点。
- Batch11 当前已生成第一版 Spine-style 拆件图集，并有 `.atlas` / `.spine_style.json` / `.cutout_manifest.json` 交接描述；但仍需拆层、补遮挡边缘、语义命名、pivot、层级顺序和绑定规格，不能直接接入骨骼动画或启用 Aseprite / Spine 类插件。
- Batch12 当前已生成第一版宣传 / CG sheet；key art 和 capsule art 不能对外发布，logo direction 不能作为最终标题字，CG 正式版必须人工清理文字、矢量化或重绘。
- Batch13 当前已生成第一版叙事分镜 sheet；仍需裁切、重排、去文字和剧情脚本匹配，不能直接接入剧情演出。
- AI 生成工具、音乐工具和视频工具的授权条款可能随账号计划变化；每批资产接入前必须记录工具、prompt、来源和授权状态。
- 原始 AI 候选、失败稿、参考图、源文件和授权截图默认不进入普通 Git；误提交会膨胀仓库并增加授权噪音。
- Godot MCP Pro 的端口迁移与 rendezvous 根治已通过静态、构建、脚本和 smoke 验证；当前会话若要实测 Godot MCP 直连新 rendezvous，需要从本 worktree 重开 IDE / CLI 会话加载新 server。
- MCP 运行态截图和一次性复核证据默认保留在 `tests/artifacts/local/`，不进入提交。

## Next Steps

- Stage24 下一步：保留两槽上限，把 `marsh_relic` / `warden_sigil` 纳入正式装备选择，再增加 2-3 个只服务元素序列的圣物或组件；不扩成装备树、背包或多资源经济。
- Stage18 下一步：用真人连续试玩分别验证安全首次通关、取得 Air Dash 后的 Stage10 回访、取得 `marsh_relic` 后的 Stage9 回访、Stage13 两支路选择和 `warden_sigil` 高风险捷径；只按明确证据调整地标、提示和收益节奏，不扩成地图 UI 或快速旅行系统。
- Stage17 下一步：审查并合并 `codex/stage-17-animation-runtime-stabilization`，在实体手柄 / 真人体验签核后更新 `AGENTS.md` 主线阶段指针；随后为最小 `2 元素 + 2 姿态 + 2 步序列` 另做 brainstorming、设计和正式阶段计划。
- Formal Demo map 下一步：先做提交前差异审查和真人连续试玩；若发现具体房间读值问题，按房间证据局部修正，不再回到随机全图替换。当前 39 房截图脚本已经覆盖主线、支路和非主线机制沙盒。
- 下一步建议转入人工美术签核 / 发布级 polish 清单：伪文字清理、最终 typography、正式 autotile / hazard Area author、TileMap 手工边缘拟合、UI 细节清稿和完整试玩审美反馈；若后续新增或重做动作帧，继续按透明背景规则网格 sprite sheet 规格使用 image_gen。
- 若后续必须重生成动作帧，统一使用 image_gen，并严格要求透明背景 PNG、标准规则网格 sprite sheet、单动作优先、固定格子、角色居中、同一角色 / 比例 / 视角、根部锚点稳定、充足留白、无绿底 / 白底 / 棋盘格、无自由排布 / 跳跃弧线散布 / 相邻帧重叠 / 裁切 / 跨格特效。
- 推送主线后，按 `docs/assets/asset-production-roadmap.md` 从 Batch 00 / Batch 01 开始生成候选资产。
- 真正接入资产时，运行 `godot --headless --path . --import`，并按影响范围执行对应 GUT 或人工复核。
- 若继续处理 Luna 行走关键帧素材，应单独提交或单独保留，不混入资产治理合并。

## References

- 资产存储策略：`docs/assets/asset-storage-policy.md`
- 资产生产路线图：`docs/assets/asset-production-roadmap.md`
- 完整资产补齐矩阵：`docs/assets/asset-completion-matrix.md`
- 动画帧数规格：`docs/assets/animation-frame-spec.md`
- Image gen 生产 backlog：`docs/assets/image-gen-production-backlog.md`
- Image gen prompt queue：`docs/assets/image-gen-prompt-queue.json`
- Image gen preview log：`docs/assets/image-gen-preview-log.md`
- Image gen session recovery log：`docs/assets/image-gen-session-recovery-log.md`
- Batch00 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-00-production-packet.md`
- Batch01 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- Batch06 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md`
- Batch07 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-07-production-packet.md`
- Batch08 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-08-production-packet.md`
- Batch09 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-09-production-packet.md`
- Batch10 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-10-production-packet.md`
- Batch11 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-11-production-packet.md`
- Batch12 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-12-production-packet.md`
- Batch13 production packet：`docs/implementation-plans/2026-06-19-imagegen-batch-13-production-packet.md`
- Image gen 提示词库：`docs/assets/image-gen-prompt-library.md`
- Godot 图集构建流程：`docs/assets/godot-atlas-build-pipeline.md`
- Asset semantics index：`docs/assets/asset-semantics-index.json`
- Asset semantic label plan：`docs/implementation-plans/2026-06-20-asset-semantic-label-pass.md`
- Art readiness audit report：`docs/assets/art-readiness-audit-report.json`
- Art readiness audit plan：`docs/implementation-plans/2026-06-20-art-readiness-audit.md`
- ImageGen Asset Gallery manifest：`docs/assets/imagegen-asset-gallery-manifest.json`
- ImageGen Asset Integration Showcase manifest：`docs/assets/imagegen-asset-integration-showcase-manifest.json`
- ImageGen Asset Integration Showcase plan：`docs/implementation-plans/2026-06-20-imagegen-asset-integration-showcase.md`
- Editor TileSet collision rule plan：`docs/implementation-plans/2026-06-20-editor-tileset-collision-rules.md`
- Image gen 输出定位 / 导入脚本：`scripts/assets/import_imagegen_outputs.py`
- Image gen selected 源图准备脚本：`scripts/assets/prepare_selected_sources.py`
- Image gen standalone 候选导出脚本：`scripts/assets/export_standalone_candidates.py`
- Image gen 生产队列校验脚本：`scripts/assets/validate_asset_production_queue.py`
- Image gen 批次执行单导出脚本：`scripts/assets/export_imagegen_batch_plan.py`
- 资产生成 brief：`docs/assets/asset-generation-brief.md`
- 资产清单：`docs/assets/asset-manifest.md`
- 资产接入 checklist：`docs/assets/asset-ingestion-checklist.md`
- Godot MCP 排障入口：`docs/dev/godot-mcp-pro-connectivity-guide.md`
- Stage16 Alpha Demo QA checklist：`docs/deliverables/stage16-alpha-demo-candidate/qa-checklist.md`
- Stage16 Alpha Demo release notes：`docs/deliverables/stage16-alpha-demo-candidate/release-notes.md`
- 当日日志：`docs/progress/logs/2026-06-19.md`
- 关键时间线：`docs/progress/timeline.md`
