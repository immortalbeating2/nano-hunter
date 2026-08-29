# Stage30 雷泽敌人与首领资产矩阵

## 运行边界

- Stage30 只在 Stage25 既有六房中加入雷蚀獠、夔影雷骸、雷吸收捷径与雷兽妖核；房间拓扑、出口、碰撞、伤害窗口、元素序列、Boss 护印和 Build 两槽仍由原契约负责。
- 当前官方 built-in `image_gen` 请求因网络错误未产生文件，随后按仓库路由使用已配置的独立图像 API；所有实际候选均记录为 `independent_image_api_edit_fixed_grid_chroma_to_alpha_stage30`，外部发布条款继续人工复核。
- 原始候选保存在 ignored `assets/source/ai_generated/batch_30/`；运行输出由 `scripts/assets/build_stage30_thunder_enemy_boss_assets.py` 确定性构建。
- `integrated` 只证明生产场景真实引用，不表示动作连贯性、特效亮度、音频试听、商业授权或 Gate26H 已批准。

## 通用模型锁

- 雷蚀獠三张 body 统一登记为 `thunder_fang_model_v1`，canonical 为 `stage30_thunder_fang_locomotion_runtime_ai01#0`；夔影雷骸五张 body 统一登记为 `kui_thunder_boss_model_v1`，canonical 为 `stage30_kui_boss_phase1_presence_runtime_ai01#0`。
- 唯一机器权威为 `docs/assets/character-creature-model-locks.json`。Stage30 构建器会把相同 contract 写入每张 `.frames.json` / `.source.json`；严格像素审计和生产 GUT 会阻止未知、缺少 metadata 或 `runtime_binding_allowed=false` 的 body 进入 live binding。
- 当前两族均为 `geometry_lock_ready=true / identity_lock_ready=true / runtime_binding_allowed=true / identity_review_status=pending_gate26h`。其中 `identity_lock_ready` 来自头顶、身体核心、脚底、根节点、前后轮廓和 canonical 比例的逐帧 alpha 技术审计，不是人工身份审美批准。
- 全生产反向扫描覆盖 `res://scripts` / `res://scenes` 并排除资产工具、开发审查场景与测试证据；夔影雷骸真窗口连续性报告位于 ignored `tests/artifacts/local/character-creature-model-lock/runtime-continuity/boss_runtime_continuity_report.json`，新鲜覆盖 `17/17` 状态、五套允许 body 和恒定根锚。阶段变化、头角 / 肢体 / 甲胄 / 轮廓、动作重量、授权和外部发布仍按 Gate26H / `docs/assets/final-art-acceptance-gates.json` 的 `final_ready` 分别签核。

## 正式 Demo 帧数基线

| Pack | Body / VFX 帧 | 运行用途 | 当前结论 |
| --- | ---: | --- | --- |
| 雷蚀獠 body | `48` | idle / patrol / move / charged idle / warning / startup / attack / recovery / hit / guard break / stagger / defeat | 达到普通敌人 `36-60` 帧目标；动作连贯性仍需 Gate26H |
| 雷蚀獠 VFX | `16` | warning / attack / guard break / stagger | 已接入视觉层；无碰撞与伤害权威 |
| 夔影雷骸 body | `80` | 两阶段 idle、两类 warning / attack、recovery、hit、guard break、stagger、phase transition、defeat | 达到 Boss `80-120` 帧目标下限；动作重量感仍需 Gate26H |
| 夔影雷骸 combat / state VFX | `32` | close / lightning warning 与 impact、guard break、stagger、phase transition、defeat | 已接入既有 Boss 状态；无碰撞与伤害权威 |
| 雷吸收 / 奖励 VFX | `16` | absorption unlock / thunder beast core / demon resonance / shortcut curtain | 已接入奖励、Build 图标和捷径状态；无碰撞与伤害权威 |

## 运行态资产与 hash

| Asset ID | Clips | SHA256 | 候选记录 |
| --- | --- | --- | --- |
| `stage30_thunder_fang_locomotion_runtime_ai01` | `idle / patrol / move / charged_idle` | `d0bdbaac8ef0ed61147b7b04bc05a05bde59f69667e388bfdece6f958d23ff15` | candidate 01 因绿色污染拒绝；candidate 02 接受 |
| `stage30_thunder_fang_attack_runtime_ai01` | `warning / startup / attack / recovery` | `acc16a1428c52e4d1e19f233047cb9efc00d4957fcf6dc174cb71cff11187005` | candidate 01 接受 |
| `stage30_thunder_fang_reaction_runtime_ai01` | `hit / guard_break / stagger / defeat` | `96010ce2f0c77764522baee43177accc8ecac6688277ccf16a403f6871689048` | candidate 01 接受 |
| `stage30_thunder_fang_vfx_runtime_ai01` | `warning / attack / guard_break / stagger` | `2efddce42137d40e29d6684fb5e4f400a8a70fb9811ade4165da4fcf448afb20` | candidate 01 接受 |
| `stage30_kui_boss_phase1_presence_runtime_ai01` | phase 1 idle / warnings / recovery | `ba4d8606a13e5cc70883d654f31f786b3f95ec0e031ab46663fb9fd42f9cf417` | candidate 01 接受 |
| `stage30_kui_boss_phase1_attacks_runtime_ai01` | phase 1 close / lightning startup + attack | `ea08cff0e2f1f0329aac045b2b252290ec6eb86478ee5c912ce7c17f4f1908be` | candidate 01 接受 |
| `stage30_kui_boss_transition_reaction_runtime_ai01` | hit / stagger / guard break / phase transition | `dd49a737be2a33dbc3ffe23e074418d492d56fe2dff39fbce4fa458fb5f0011d` | candidate 01 接受 |
| `stage30_kui_boss_phase2_presence_runtime_ai01` | phase 2 idle / warnings / recovery | `26d9fd6d27f4d345bdc3ab96a9040efdfe01ab75e2a6e9c4affbc918b8ac0a87` | candidate 01 因洋红污染拒绝；candidate 02 接受 |
| `stage30_kui_boss_phase2_resolution_runtime_ai01` | phase 2 close / lightning / recovery / defeat | `c6569149f525e65aad9bd03b73eb20df78bc033bd942e3be4f50c3276a0117bf` | 首次请求未产文件；重述后 candidate 01 接受 |
| `stage30_kui_boss_combat_vfx_runtime_ai01` | close / lightning warning + impact | `85d2d42db35965f5dd0174fdddcaae641a6f59da69458dc0959a9a71e4e9967b` | candidate 01 接受 |
| `stage30_kui_boss_state_vfx_runtime_ai01` | guard break / stagger / phase transition / defeat | `d3aa47cccd22ecbf10b3c036c2eaaacff56045a47c4ac86e359c1972c6a4aeaf` | candidate 01 接受 |
| `stage30_thunder_absorption_reward_vfx_runtime_ai01` | absorption / core / resonance / shortcut | `2be00fe820364d19a229e8a5f92ede41f5a431a226ae7d0d215a9a930c3d3f5e` | candidate 01 接受 |

## 场景绑定

| Production scene | Runtime binding | Gameplay authority |
| --- | --- | --- |
| 雷雨洼地 | 1 只普通雷蚀獠；雷吸收 `ShortcutZone` 与 storm curtain | 路由继续发 `room_transition_requested`；能力来自 Main |
| 引雷坡道 | 1 只蓄雷雷蚀獠 | warning 窗风雷破甲，雷风散射取消攻击 |
| 风蚀岔口 | 普通 / 蓄雷各 1 只 | 沿用 `receive_attack(...)` / `defeated` |
| 夔影断驿（原远眺房） | 夔影雷骸、Boss 门、奖励 VFX | 沿用 Seal Guardian 生命 / 护印 / 阶段 / 状态与 Stage25 出口 |
| DemoShell Build | 雷兽妖核 cell | 只读 Build 快照；雷风击退经玩家统一出口乘 `1.2` |

## NS30-Audio 试听队列

本批严格串行并发 `1`，全局硬上限 `<4`。Stable Audio 使用 `sm-sfx + same-s + fp32 + 8 steps + 8 threads`；ACE-Step 使用 `fast` 配置、worker `1`、batch `1`。文件只保存在 `D:/AI/audio/outputs/scratch/nano-hunter/stage30/`，均已通过 `soundfile` 解码与 hash 验证；未试听、未清理、未授权、未复制进项目。

| Event | Engine / seed | Format / peak | Scratch file | SHA256 | 状态 |
| --- | --- | --- | --- | --- | --- |
| 雷蚀獠预警 | Stable Audio / `3001` | stereo / 44.1kHz / 3.0s / `0.896332` | `stage30_thunder_fang_warning_seed3001.wav` | `a00b58b0150a5afc2a4ae3502742e1293134db0820aff8954462677977dfe6e9` | candidate only；listen / mix pending |
| 雷蚀獠冲锋命中 | Stable Audio / `3002` | stereo / 44.1kHz / 3.0s / `0.999969` | `stage30_thunder_fang_charge_impact_seed3002.wav` | `25231ade8fa68701e7a9d7c9997074dcaf33e8a957a5967b3bbde29fde6d197c` | candidate only；peak cleanup / listen pending |
| 夔影近身预警 | Stable Audio / `3003` | stereo / 44.1kHz / 3.0s / `0.752686` | `stage30_kui_close_warning_seed3003.wav` | `f02ce69760f3d3a3aab2fd1829da54bb44129b81486d0941e550fea27139a60a` | candidate only；listen / mix pending |
| 夔影落雷命中 | Stable Audio / `3004` | stereo / 44.1kHz / 3.0s / `0.562103` | `stage30_kui_lightning_impact_seed3004.wav` | `48804d170784df520abe15bbe81ba674721705989b2adc23c7c518a7c29df2bd` | candidate only；listen / stacking pending |
| 夔影阶段转换 | Stable Audio / `3005` | stereo / 44.1kHz / 3.0s / `0.826660` | `stage30_kui_phase_transition_seed3005.wav` | `2f0379bbecf8cf1684e1089b662354b565b56655119dd9f0bf5087126947c257` | candidate only；listen / mix pending |
| 雷吸收奖励 | Stable Audio / `3006` | stereo / 44.1kHz / 3.0s / `0.372681` | `stage30_thunder_absorption_reward_seed3006.wav` | `eb0e512a07cce757554843aed7cbb6e167a6cf7f9104cf6e452f3d65aa99a829` | candidate only；listen / UI stacking pending |
| 夔影雷骸 Boss BGM | ACE-Step 1.5 fast / `3007` | stereo / 48kHz / 30.0s / 78 BPM / D minor / `0.891235` | `stage30_kui_thunder_boss_bgm_seed3007.wav` | `0e0668b235b550c54eebde66b45e65d682a66d4352f8dd4cf68a42733a325709` | candidate only；loop seam / mix / listen pending |

试听接受后才允许：裁切 / 峰值与响度统一 → 记录 accepted hash / tool terms → 转 OGG → 复制到 `assets/audio/` → 绑定事件与总线。当前不得声称音频已接入。

## Gate26H 人工边界

- 雷蚀獠 warning、冲锋方向与两击生命是否无 HUD 可理解。
- 夔影雷骸近身 / 落雷两招读招、phase 2 升温、破印 / 散射硬直是否有重量且不被 VFX 遮挡。
- 雷吸收奖励、雷兽妖核图标与捷径 curtain 是否能被真人识别为“能力取得 / 可通行”。
- 7 条音频候选逐条试听、peak / loudness、Boss BGM loop seam、战斗混音与发布条款。

## 自动与 MCP 运行态复核

- Stage30 专项 `5/5` tests、`53` assertions；Stage21 / 22 / 24 / 25 / 26 / 29 邻近回归通过；递归 GUT 为 `47` scripts、`317/317` tests、`8785` assertions。
- Godot `4.6.3` import 与生产主场景 smoke 退出码为 `0`；strict asset package 为 `78` queue、`166` VFX rules、`78` runtime map / catalog、`10/10` families、`7/7` formats、`0` unsafe / outside。
- Godot MCP Pro 在生产 Main 中确认普通 / 蓄雷雷蚀獠并存，连续三帧姿态有变化；雷雨洼地 curtain 在能力前为 frame `0` / shortcut `false`，能力后为 frame `2` / shortcut `true`。
- 夔影雷骸运行快照覆盖 phase 1 近压预警、phase 1 落雷、phase 2 转换、phase 2 落雷预警与雷风破势；吸收上下文从 guard `2` 一次降为 `0`，进入 `staggered` 且 `scatter_stagger_bonus=true`。
- 击败后 Boss 生命 / 护印为 `0`、奖励 VFX 可见、`thunder_absorption_unlocked=true`、`thunder_beast_core` 已装备；重复胜利入口不增加 `story_event_count`。MCP 最终 `editor errors=[]`，运行场景、三个临时 autoload 与本轮精确 editor 进程树已清理，`project.godot` 无 diff。
- 截图保存在 ignored `tests/artifacts/local/stage30/mcp/01-10_*.png`；它们证明运行引用与状态表现，不替代 Gate26H 的招式理解度、手感、混音和审美签核。
