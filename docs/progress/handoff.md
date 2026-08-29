# Nano Hunter `/handoff`

更新时间：2026-08-29

## 一句话续接

F01–F18 Blueprint V2、F03 悬赏榜、Stage16 路线回归与全量机器门禁均已收口；当前唯一合并硬门禁是 Gate26H 真人连续试玩。Gate26H 通过后 fast-forward 合并 `main`，18 房正式环境资产和 Stage32 分别放到后续新分支，不继续堆在本分支。

## 事实源与阅读顺序

1. `AGENTS.md`：仓库执行契约。
2. `docs/progress/status.md`：当前总状态；以日期更晚的条目覆盖同文件中的历史快照。
3. 本文件：当前会话续接边界与下一步。
4. `docs/progress/logs/2026-08-29.md`：最近一次 F03 UI 实现与验证。
5. `spec-design/2026-08-26-formal-demo-room-blueprint-v2-design.md`：18 房完整玩法蓝图。
6. `spec-design/2026-08-27-formal-demo-blueprint-v2-runtime-adoption-design.md`：生产灰盒采用合同。
7. `docs/deliverables/stage31-north-star-alpha-candidate/gate26h-human-playtest-checklist.md`：当前真人门禁。

运行时代码、生产 `.tscn` 和新鲜运行结果高于历史计划与旧聊天结论。`docs/progress/status.md` 中“仍是单次会话、无跨进程 Continue”的旧风险已被 Stage31 的单档存档、Continue 和双驿站实现取代，不应继续沿用。

## 当前成熟度

| 工作流 | 当前状态 | 完成边界 |
| --- | --- | --- |
| Blueprint V2 设计 | `COMPLETE` | F01–F18、48 屏段、38 连接、14 奖励与逐房 QA 已冻结 |
| Blueprint V2 生产采用 | `COMPLETE` | RTA-01–06、18/18 房结构/Spawn/相机/交互及六组自然输入证据完成 |
| F03 悬赏榜 UI | `TECHNICAL CANDIDATE` | 专用暗漆铜框、动态内容、2K 视觉与邻近测试通过；未等同发布签核 |
| Stage16 全文件回归 | `PASS` | F18→F03 按当前 `WaystationZone + ui_down` 合同修正旧 fixture；`22/22 / 646` |
| 全量机器门禁 | `PASS` | `66` scripts / `446/446` tests / `12076` assertions、exit `0`；既有 orphan/leak warning 无失败断言 |
| Gate26H | `PENDING` | 尚无填写完整的测试人、实体手柄、30–45 分钟路线、21:9、美术及音频决定 |
| F01–F18 正式环境美术 | `NOT STARTED AS A FULL PASS` | 当前地表、部分背景与通用机关仍含代理/复用资产 |
| Stage27–31 scratch 音频 | `PENDING REVIEW` | 未逐条 ACCEPT/REWORK/REJECT，未批准接入 runtime |
| Stage32 Beta Candidate | `NOT STARTED` | 必须等 Gate26H P0=0、P1 已修复或接受后进入 |

## 当前工作区

- 分支：`codex/stage21-26-north-star-alpha`；最新代码检查点为 `2d48fe4`，本交接文档收口提交位于其后。
- `main`：`9cc5250`；本交接提交后当前分支相对 `main` 为 `0 behind / 36 ahead`，可在 Gate26H 通过后使用 `--ff-only` 合并。
- 只有当前主工作区一个 worktree，没有额外 worktree。
- 批量开发现场已拆为 `9b6634f`（运行视觉资产 / 审计）和 `2d48fe4`（正式房间 / 运行时 / 回归）两个检查点；不再有数百项待归档变化。
- 当前仍故意保留五类未归属现场：`.codex/config.toml`、`AGENTS - reference.md`、`backend/app/schemas/contract_supplier_ledgers.py`、`design-qa.md`、根目录 `player_placeholder.tscn`。它们未进入本轮提交，不得为追求 clean tree 而删除、checkout 或强制加入。
- `.code-review-graph/` 是提交钩子生成的本地索引，已加入 `.gitignore`；ignored 测试证据和 imagegen inbox 图片同样不进入提交。
- 本轮用户已授权受控收口，但 Gate26H 未通过，所以仍不 merge、push、删除分支或发布。

最近 F03 UI 文件簇至少包括：

- `assets/art/ui/stage28_bounty_archive_frame_warden_ai01.png`
- `scenes/ui/demo_shell.tscn`
- `scripts/ui/demo_shell.gd`
- `tests/stage23/test_stage_23_waystation_bounty_board.gd`
- `tests/stage28/test_stage_28_waystation_presentation.gd`
- `docs/assets/stage28-waystation-asset-matrix.md`

这些文件及已提交的 `plan/`、`spec-design/`、`docs/implementation-plans/`、资产目录和本地证据均不得覆盖或清理。

## 已完成且不要回退

- F01–F18 正式编号、世界图和选关定义已经统一。
- F03→F04→F03→F04 的“假跌落”根因已在共享门控状态恢复中修正，不是 03/04 之间存在深坑。
- F09→F10→F08、F09↔F12、F07↔F14 主动祭坛、F14→F15 主路与 F18→F03 主动归驿已经分离并有生产自然输入证据。
- 普通相邻边界可以自然穿越；建筑门、祭坛、法坛和明确支路继续复用 `ui_down` 确认，不新增第二套交互管理器。
- F03 重复道路视觉已经移除，碰撞/出生/交互/相机统一到背景正式道路基线；悬赏榜本轮只换 Bounty 容器，没有重做共享 DetailPanel。

## 未完成任务与顺序

### A. 已完成：机器收口

- Stage16 旧 fixture 已按当前 F18 主动归驿合同修正，`22/22 / 646`。
- 首轮全量发现的 19 个旧 TileMap / 坐标 / F 编号 / 交互期望已按生产 Phase2 合同更新；最终 `446/446 / 12076`。
- 不要重复打开这些已绿机器项；只有真人路线发现可复现问题时，才按具体房间局部修复。

### B. 当前主门禁：Gate26H 真人连续试玩

按现有 checklist 从生产 `main.tscn` 完成一次 30–45 分钟自然路线，必须覆盖：

- 首次通关、能力回访、悬赏接取/完成/回交与两槽 Build；
- 雷泽路线、两阶段 Boss、奖励因果和捷径；
- 完全退出后的 Continue、`waystation_main ↔ thunder_outpost` 双向往返；
- 实体手柄误按、舒适度、迷路点、读招；
- Luna / Seal Guardian / 夔影雷骸、驿站/雷泽、32px/64px UI、真实 21:9 和无 HUD 可读性。

只根据真实问题局部调整对应房间的地形、镜头、交互或提示；不要重新打开已经通过的 18 房拓扑，也不要用直接切房或坐标注入代替玩家路线。

Gate26H 记录完成且 P0=0、P1 已修复或书面接受后：

1. 在本分支提交填写后的 checklist 与必要修复，重新跑受影响测试；若改了运行时，重跑全量。
2. 确认 `git status --short` 只剩上方五类保留现场，不把它们加入提交。
3. 执行 `git switch main`，再执行 `git merge --ff-only codex/stage21-26-north-star-alpha`。
4. 在 `main` 上运行 Godot import 与全量 GUT；结果仍绿后才把合并视为完成。
5. 不自动 push；只有用户明确要求远端同步时才 `git push origin main`。分支删除也放在用户确认合并结果之后。

### C. Gate26H 之后：正式资产替换

1. 依 F01–F18 当前灰盒逐屏登记正式资产缺口：地表、区域建筑、普通出口、能力门、祭坛/法坛、危险、地标、前景与视差层。
2. 保持已通过的碰撞和路线合同，先做视觉替换，不用美术缺失反向重写拓扑。
3. 已知专项：F09 正常站立时头部持续切入上层单向平台；F03 掌柜仍是临时体量，正式统一风格人物资产尚未生成。
4. WorldMap 拓扑、LevelSelect 内容顺序/文案和 Completion 最终信息结构继续等 Gate26H 流程稳定后再统一，避免重复返工。

### D. 音频与 Stage32

- 对 Stage27–31 scratch 音频逐条记录 `ACCEPT / REWORK / REJECT`、裁切、响度/削波、loop、授权；接受前不复制到 `assets/audio/`，不绑定 runtime。
- Gate26H 关闭后再建立 Stage32 专属设计与执行单，只做设置、最终 mix、授权总检、宽屏/性能、Windows export 和 Beta Candidate；不新增区域、系统或第二套框架。

## 下一代理的最短启动流程

```powershell
git branch --show-current
git status --short
git rev-list --left-right --count main...HEAD
```

若收到新的真人房间问题：先按真实输入复现该房，再读即将修改的共享调用链和具体 `.tscn`；只修证据指向的根因。若没有新的真人反馈：执行 Gate26H，不提前开始大批美术生产或 Stage32。

完成改动后按影响范围追加：

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/room_design -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage31/test_stage_31_save_and_waystation_travel.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
python scripts/assets/audit_asset_package.py --strict --write-report
git diff --check
```

## 最近验证基线

- Blueprint V2：F01–F18 `18/18`；`room_design 64/64 / 2289`；六组自然输入报告均 `done=true / P0/P1/P2=0`。
- F03 Bounty：Stage28 `8/8 / 100`、Stage23 `5/5 / 42`、Stage24 `5/5 / 36`、Stage31 `6/6 / 84`。
- Godot import：最近一次退出码 `0`。
- 严格资产包：`81` queue/runtime 条目通过；这只证明资产治理一致，不证明最终审美或授权。
- Stage16：`22/22 / 646`。
- 最终递归 GUT：`66` scripts / `446/446` tests / `12076` assertions、exit `0`；既有 ObjectDB orphan/leak warning 保留。
- Git 检查点：`9b6634f`、`2d48fe4`；本交接提交后分支预计 `0 behind / 36 ahead`。

以上机器数字均为本次受控收口的新鲜结果；它们不能替代 Gate26H 真人判断。

## 证据位置

- 18 房运行图：`tests/artifacts/local/formal-blueprint-v2/runtime-visual/`
- 六组自然输入报告：`tests/artifacts/local/formal-blueprint-v2/natural-input/`
- F03 道路/体量修正：`tests/artifacts/local/f03-waystation-fix/`
- F03 悬赏榜最终图：`tests/artifacts/local/stage28-bounty-ui/bounty_runtime_2560x1440.png`

这些目录默认 ignored，只作本地核验，不要因未被 Git 跟踪而删除。
