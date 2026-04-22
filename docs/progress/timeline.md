# Nano Hunter Timeline

## 2026-03-31

- 初始化 `nano-hunter` 的 Godot 4.6 工程并建立基础仓库结构。
- 建立项目级 `AGENTS.md`、`docs/progress/` 与 `spec-design/` 留痕体系。
- 关闭当前阶段不兼容的 `better-terrain` 激活，保留 `godot_mcp` 与 `gut` 作为默认启用插件。
- 完成 `阶段 1：可启动骨架` 的基础入口：`Main.tscn`、占位玩家、测试房间与启动入口验证。

## 2026-04-01

- 完成 `阶段 1` 的显示与相机调优：固定基准分辨率、整数倍缩放、留边策略与测试房间相机边界。
- 补齐阶段 1 的设计文档、实现计划与进度留痕。
- 将阶段 1 的稳定结果合并回 `main`，形成第一版可启动、可看、可调的试玩检查点。

## 2026-04-06

- 基于阶段 1 的实践经验，收敛分支与 worktree使用策略，明确“小任务默认仅分支，阶段开发默认分支 + worktree”。
- 新建设计文档 `spec-design/2026-04-06-branch-and-worktree-strategy.md`，明确“仅分支”与“分支 + worktree”的适用条件。
- 将 `codex/branch-vs-worktree-policy` 合并回 `main` 并删除分支，同时保留 `codex/stage-2-movement-feel` 作为阶段 2 的开发入口。

## 2026-04-10

- 基于阶段 1 与阶段 2 的执行差异，补充“默认开发节奏”治理规则，明确它是对 `AGENTS.md` 现有“大功能 / 小改动”分流的执行层细化，而不是替代规则。
- 在 `AGENTS.md` 中新增“大功能默认节奏”“小改动默认节奏”与对应决策规则，统一 `brainstorming`、`subagent`、`worktree` 与提交次数的默认用法。
- 新建设计留痕 `spec-design/2026-04-10-development-cadence-standardization.md`，说明为什么要把阶段型开发节奏从聊天约定提升为项目内显式规范。
- 新增实现计划 `docs/superpowers/plans/2026-04-10-development-cadence-standardization.md`，把本次治理修订限定为文档与规则收口，不混入额外玩法实现。
- 更新 `docs/progress/status.md`、`docs/progress/timeline.md` 与当日日志，明确后续阶段 3、4、5 默认沿用大功能节奏，文档修订、配置调整与单点 bugfix 则沿用小改动节奏。
- 重新建立本地 `codex/stage-2-movement-feel` 分支与 `.worktrees/stage-2-movement-feel` 隔离工作区，避免在带未提交改动的主工作区上直接推进阶段 2。
- 新增阶段 2 设计留痕，锁定本轮只做基础移动手感，不做冲刺、攻击、HUD 与房间系统重构。
- 收口 `project.godot`：加入 `move_left`、`move_right`、`jump` 命名输入动作，并保持 `better-terrain` 编辑器插件禁用。
- 将占位玩家演进为可控原型，加入 `idle / run / jump_rise / jump_fall / land` 状态、导出调参字段，以及 `coyote time`、`jump buffer`、`可变跳高`。
- 扩展 `TestRoom`，加入中段平台，覆盖阶段 2 的基础平台移动验证路径。
- 新增 `tests/stage2/test_stage_2_movement_feel.gd`，验证输入契约、状态契约、跑停、跳跃、可变跳高、`coyote time` 与 `jump buffer`。
- 明确后续阶段安排：攻击放 `阶段 3`，冲刺优先放 `阶段 4`，HUD 与房间系统重构放 `阶段 5`。
- 为补做 GUI 手动试玩，同步阶段 2 worktree 中的 `godot_mcp` 到 `1.10.1`，并恢复工程依赖的项目级 autoload，收口 Godot MCP 的项目侧兼容问题。
- 在后续接续中于沙箱外重新确认 `godot --headless --path . --import`、阶段 1 GUT 与阶段 2 GUT 均通过，确认当前 worktree 自动化基线仍为绿色。
- 将 GUI 阻塞进一步收敛为当前 Codex 桌面线程拿不到编辑器侧连接，而不是阶段 2 worktree 的项目配置回退。
- 清理误开的开发现场：
  - 仓库根工作区已切回 `main`
  - 误开的本地分支 `stage-2-movement-feel` 已删除
  - 只保留 `.worktrees/stage-2-movement-feel` 作为阶段 2 工作树
  - 外部 `f400` worktree 已从 Git worktree 元数据移除，但其物理目录仍被 `Codex.exe` 占用，待关闭对应桌面窗口后再删

## 2026-04-11

- 恢复当前会话的 Godot 编辑器侧 MCP 连接，重新获得阶段 2 的编辑器复核能力。
- 在阶段 2 编辑器复核中发现 `project.godot` 的命名动作只有动作名、没有静态默认键位，补写回归测试后确认该缺口会直接让阶段 2 工程基线测试转红。
- 将 `move_left`、`move_right`、`jump` 的默认键位静态写入 `project.godot`，使项目配置、编辑器侧验证和运行时输入契约重新对齐。
- 重新确认 `godot --headless --path . --import`、阶段 1 GUT 与阶段 2 GUT 均通过，将阶段 2 状态从“待 GUI 复核”更新为“已完成，待进入阶段 3”。
- 修复当前 codex/stage-2-movement-feel worktree 的 Git 索引损坏，恢复 git status 与 git diff --check。
- 将 codex/stage-2-movement-feel 本地合并回 main，并在主线结果上重新确认 --import、阶段 1 GUT、阶段 2 GUT 与 git diff --check 全部通过。

## 2026-04-20

- 将当前一组 `godot_mcp` 相关改动确认为插件正常更新，而不是临时实验；本轮按主线小改动收口，不与阶段 3 玩法实现混做。
- 本轮 MCP 更新包含：
  - 插件版本从 `1.10.1` 升级到 `1.12.0`
  - 插件退出时只清理“本 session 注入的 autoload”
  - `command_router` 接入 Android 相关命令
  - `base_command` 改进游戏用户目录解析逻辑
- 将 `.mcp.json` 明确保留为本地配置，并加入本地 Git 忽略，而不是写入项目级 `.gitignore`。
- 从收口后的 `main` 建立 `codex/stage-3-combat-feel` 与 `.worktrees/stage-3-combat-feel`，作为阶段 3 的隔离开发现场。
- 在阶段 3 worktree 中启动设计文档、实现计划、状态页、时间线与当日日志，锁定第一轮范围为“攻击 + 木桩目标”，暂不写入实际战斗实现。
- 新建设计文档 `spec-design/2026-04-20-stage-3-combat-feel-design.md`，明确本轮只做玩家普通攻击、固定木桩目标、命中反馈与基础受击反馈。
- 新增实现计划 `docs/superpowers/plans/2026-04-20-stage-3-combat-feel.md`，把阶段 3 拆为输入契约、玩家攻击、木桩目标、阶段 3 GUT 与文档收口五个实施项。
- 将 worktree 内 `docs/progress/status.md` 从“阶段 2 已完成”推进到“阶段 3 设计准备中”，让后续 session 进入时能直接读到当前战斗阶段目标。

## 2026-04-21

- 补充阶段 3 与阶段 4 的“打击感反馈分层约定”，明确阶段 3 允许做基础可读性反馈，更强反馈留到阶段 4 结合能力差异评估。
- 在 `project.godot` 中新增 `attack` 动作与默认键位，将阶段 3 输入契约静态写回工程配置。
- 将占位玩家增量演进为支持地面普通攻击的原型：新增 `attack` 状态、前方命中范围、单次攻击单次命中与攻击恢复逻辑。
- 新增 `TrainingDummy` 场景与脚本，并将其接入 `TestRoom`，建立固定木桩目标与最小受击反馈。
- 新增 `tests/stage3/test_stage_3_combat_feel.gd`，覆盖输入契约、攻击状态、命中朝向、单次命中与木桩契约。
- 重新确认 `godot --headless --path . --import`、阶段 1 GUT、阶段 2 GUT、阶段 3 GUT 与 `git diff --check` 全部通过；`--import` 退出时仍保留 `ObjectDB instances leaked at exit` 历史警告。
- 当晚继续微调 Stage 3 时，清理当前 worktree 的 `.godot` 缓存后暴露出 `project.godot` 的历史配置风险：`autoload` 仍保留 `BetterTerrain`，且插件入口使用 `uid://...` 引用。
- 修复 `project.godot`：移除 `BetterTerrain` autoload，并将 `DialogueManager`、`ControllerIcons` 改回 `res://...` 路径引用，避免冷启动后再次触发 `Unrecognized UID` 与 `better-terrain` 解析错误。
- 修复后重新确认 `godot --headless --path . --import`、阶段 1 GUT、阶段 2 GUT 与 `git diff --check` 通过。
- 当前仍存在单独阻塞：Stage 3 的 GUT 入口会触发 Godot signal 11 崩溃，尚未定位到最终根因。
- 进一步缩小 Stage 3 GUT 崩溃范围：确认 `test_stage_3_combat_feel.gd` 可以在健康的 Stage 1 GUT 上下文中被加载、反射、实例化并手动执行单条测试方法，因此当前更像是 “GUT 将其作为独立目标测试入口运行” 的链路在 Godot 4.6 下不稳定，而不是 Stage 3 测试脚本内容本身立即崩溃。
- 将 Stage 3 GUT 崩溃继续前移定位：确认 Stage 1 / Stage 2 的 `-gtest` 目标仍可正常进入 `gut_cmdln` 入口，而 Stage 3 目标、缺失脚本目标与非测试脚本目标都会在 `gut_cmdln.gd` `_init()` 之前触发 Godot `signal 11`，因此当前更像是目标路径启动链异常，而不是 Stage 3 测试逻辑本身立即崩溃。
- 通过稳定入口恢复 Stage 3 自动化回归：保留 `tests/stage3/test_stage_3_combat_feel.gd` 作为真实测试定义，在 `tests/stage2/test_stage_2_movement_feel.gd` 中新增 5 条 `test_stage_3_bridge_*` 包装测试，重新确认 `Stage 2 + Stage 3 bridge` 命令达到 `12/12 passed`。
- 将 `project.godot` 中实际残留的 `BetterTerrain` autoload 真正移除，与当前阶段“不启用 better-terrain”的项目规范重新对齐。
- 用户补充 Windows 崩溃弹窗，确认 Stage 3 独立入口触发的是 Godot Win64 原生访问冲突（空指针附近 `0x58` 读错误）。
- 在干净复现里进一步确认：Stage 3 独立 `-gtest` 可以跑到 `GutRunner.quit`，但会在原生退出阶段触发 `signal 11`；只跑最简单的输入契约单测也同样崩溃。
- 临时最小探针 `tests/stage1/test_probe_minimal.gd` 证明“新增独立测试脚本目标”也可能触发同类问题；删除探针并重新导入后，Stage 1 独立入口恢复通过。
- 继续对 `tests/stage3/test_stage_3_combat_feel.gd` 做同路径二分后确认：将该文件整份重写并规范化后，Stage 3 独立 `-gtest` 恢复正常，说明先前崩溃更像是该文件文本/编码状态异常，而不是 Stage 3 玩法测试逻辑本身错误。
- 移除 Stage 2 中为绕过崩溃而添加的 `test_stage_3_bridge_*` 临时桥接，恢复独立的 Stage 3 suite 入口。
- 补充 `AGENTS.md` 中的“测试文件异常排查约定”，把本轮 Stage 3 GUT 文本状态异常的高置信度排查经验沉淀为后续默认排查顺序。
- 重新以 fresh 验证确认 `godot --headless --path . --import`、阶段 1 GUT、阶段 2 GUT、阶段 3 GUT 与 `git diff --check` 全部通过，确认 Stage 3 已达到可合并里程碑。
- 将 `codex/stage-3-combat-feel` 以“分支 + worktree”模式本地合并回 `main`，并清理 `.worktrees/stage-3-combat-feel`，使主线进入“阶段 3 已完成，待进入阶段 4”的稳定状态。

## 2026-04-22

- 从当前 `main` 建立 `codex/stage-4-minimal-ability-difference` 与 `.worktrees/stage-4-minimal-ability-difference`，作为阶段 4 的唯一开发入口。
- 新建设计文档 `spec-design/2026-04-22-stage-4-minimal-ability-difference-design.md`，固定本轮能力形式为“仅地面冲刺”，验证形式为“TestRoom 混合验证”。
- 新增实现计划 `docs/superpowers/plans/2026-04-22-stage-4-minimal-ability-difference.md`，把阶段 4 拆为 preflight、冲刺状态、TestRoom 门槛、轻量反馈、自动化验证与文档收口五个实施项。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 4 已启动，设计与 preflight 已完成”，并明确延后项归属：哪些留在阶段 4、哪些明确留给阶段 5、哪些继续后延。
- 将修正后的 `subagent` / `multi-agent` 规则同步到当前 worktree 的 `AGENTS.md`，使阶段 4 后续实现默认主动评估代理协作，而不是默认主代理单线推进。
- 完成 fresh preflight 的首轮验证：`.worktrees` 忽略检查通过，`godot --headless --path . --import` 通过，Stage 1 GUT 与 Stage 2 GUT 通过。
- 复核确认 Stage 3 独立 `-gtest` 本身未回归失败；使用沙箱外稳定运行方式后，`main` 与 stage4 worktree 中的 Stage 3 GUT 都恢复 `5/5` 通过。
- 因此阶段 4 当前状态更新为“preflight 已完成，可进入实际实现”。
- 进入阶段 4 的第一批实际实现：在 `project.godot` 与 `scripts/main/main.gd` 中接入 `dash` 输入契约，在 `scripts/player/player_placeholder.gd` 中加入仅地面 `dash` 状态、方向规则、持续时间、速度与冷却时间。
- 新增 `tests/stage4/test_stage_4_minimal_ability_difference.gd`，覆盖阶段 4 的最小能力差异核心契约，并确认 `6/6` 通过。
- 扩展 `scenes/rooms/test_room.tscn`，加入 `DashGapLeft`、`DashGapRight` 与 `DashCombatDummy`，作为阶段 4 的最小探索 / 战斗门槛节点。
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 GUT 与 `git diff --check` 全部通过。
- 通过 Godot MCP Pro CLI 与内置 MCP 工具复核运行态，确认 `Main/TestRoom/Runtime/PlayerPlaceholder` 与 stage4 新节点全部进入运行树，并成功触发一次 `dash` 位移。
- 在第二轮 stage4 收敛中，将 `TestRoom` 从“有节点但价值不清晰”进一步推进为真正的验证区：加入 `FloorRight` 与 `DashGateCeiling`，把地面缺口和低顶组合成明确的仅地面 dash 门槛。
- 同时回调 `dash` 默认参数：将 `dash_duration` 提高到 `0.24`、`dash_speed` 提高到 `440.0`，让 stage4 默认手感更贴近“能力差异”而不是“擦线可用”。
- 将 `tests/stage4/test_stage_4_minimal_ability_difference.gd` 扩展到 `8/8` 通过，新增探索门槛与战斗接敌价值验证，确认无 dash 无法稳定通过 gate，而 dash 可以稳定通过并更快进入可出手区。
- 再补做一轮运行态人工手感复核，确认低顶 + 缺口构图已经足够表达“仅地面 dash 门槛”，且过门槛后到 `DashCombatDummy` 只需短距离补位即可进入出手区，使阶段 4 进入可收口判断。
- 最后补上最小 dash 可读性反馈：冲刺期间玩家本体切到更亮的冷白色，退出后恢复默认颜色；stage4 自动化同步扩展到 `9/9` 通过，阶段 4 达到可收口状态。
- 将 `codex/stage-4-minimal-ability-difference` 以“分支 + worktree”模式本地合并回 `main`，并在主线上重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 GUT 与 `git diff --check` 全部通过。
- 从当前 `main` 建立 `codex/stage-5-tutorial-vertical-slice` 与 `.worktrees/stage-5-tutorial-vertical-slice`，作为阶段 5 的唯一开发入口。
- 新建设计文档 `spec-design/2026-04-22-stage-5-tutorial-vertical-slice-design.md`，固定本轮采用“单场景线性教程区 + 低压教学 + 能力教学优先”的方案。
- 新增实现计划 `docs/superpowers/plans/2026-04-22-stage-5-tutorial-vertical-slice.md`，将阶段 5 拆为主房间契约迁移、`TutorialRoom`、最小 HUD、阶段 5 自动化与文档收口。
- 将当前 worktree 的 `docs/progress/status.md` 推进到“阶段 5：教程区垂直切片（设计与开发准备中）”，并明确本轮的主流程目标、历史耦合风险与下一步实现入口。
- 明确阶段 5 的代理协作建议：若写入范围可分离，优先按“`Main` 契约迁移 / `TutorialRoom` + HUD / 测试与文档”三块主动评估 `multi-agent` 并行。

## 2026-04-23

- 在 `codex/stage-5-tutorial-vertical-slice` 中完成阶段 5 的主入口迁移：`Main` 不再硬编码 `TestRoom`，而是默认加载 `TutorialRoom` 并依赖统一主房间契约。
- 新增 `TutorialRoom` 与最小 HUD，建立“移动/跳跃 -> dash -> 攻击 -> 出口”的单场景低压教学切片。
- 新增 `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`，覆盖主入口迁移、教程顺序推进、`dash` 门槛、出口解锁与 HUD 战斗面板布局。
- 收敛 HUD 首屏提示、教程节点布局与 `BattlePanel` 重叠问题，确认当前垂直切片在自动化与运行态证据上都达到可收口状态。
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 GUT 与 `git diff --check` 全部通过，确认阶段 5 已达到稳定基线并可准备合并回 `main`。

## 2026-04-23

- 排查并修复当前 stage5 worktree 中 `godot_mcp` 的会话错连问题：确认旧 `godot-mcp-pro` bridge 残留占用 `6505-6509`，清理旧 bridge 后恢复当前会话与 Godot 的 MCP 连通性。
- 基于这次排障，将“阶段 / worktree 收口时同步确认旧 `godot-mcp-pro` bridge 已退出”的高置信度经验写回 `AGENTS.md`，避免后续 session 重复踩坑。
- 正式进入阶段 5 的第一轮实现：把 `Main` 从固定 `TestRoom` 入口迁移为主房间契约入口，并默认实例化 `TutorialRoom`。
- 新增 `scenes/rooms/tutorial_room.tscn` 与 `scripts/rooms/tutorial_room.gd`，落地单场景线性教学流程：`move / jump -> dash -> attack -> exit`。
- 新增 `scenes/ui/tutorial_hud.tscn` 与 `scripts/ui/tutorial_hud.gd`，接入最小 HUD：提示区 + 战斗面板；战斗面板只做展示，不接正式生命 / 死亡循环。
- 更新 Stage 1 契约测试，移除 `Main -> TestRoom` 的固定耦合假设；新增 `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`，覆盖主房间迁移、教程顺序、`dash` 门槛与出口解锁。
- 重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 GUT 与 `git diff --check` 全部通过。
- 通过运行态 Godot MCP 复核确认 `Main/Room/TutorialDummy`、`Main/HUD/TutorialHUD` 与提示标签全部进入运行树，阶段 5 已从“开发准备中”推进到“首轮可玩实现已落地”。
- 在后续轻量收敛中，补强了 `StepLabel`、首条按键提示文案、首段跳台位置与 `dash -> attack` 的稳定推进条件，使阶段 5 从“能跑通”进一步推进到“教程表达更清楚”。
- 在 HUD 排障中确认 `BattlePanel` 的文本重叠根因是 `PanelContainer` 与手动定位混用；改为普通 `Panel` 后，战斗面板两行文本恢复稳定分离。
- 最终重新确认 `godot --headless --path . --import`、阶段 1 / 2 / 3 / 4 / 5 GUT、运行态主入口与 HUD 读值均正常，阶段 5 达到“已完成，形成稳定基线”的里程碑状态。
