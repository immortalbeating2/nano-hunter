# Stage26 后北极星美术资产差距评估

日期：2026-08-01
基线：当前 `codex/stage21-26-north-star-alpha` 工作树；评估使用现有代码、场景、ignored 运行截图、运行时真实引用、SpriteFrames 元数据与实时只读资产审计，不把候选文件存在、帧数达标或 MCP 能播放当成正式运行表现。

## 结论

当前美术不是“从零开始”，也不是“北极星美术已经完成”。准确状态是：Stage12-17 建立的 Alpha 资产技术底座已经可用，Stage21-26 新增的北极星系统却没有获得同等强度的专属美术与音频。

- 本次现场重算为 `56/56 structural-ready`、`55/56 final-ready`；磁盘上的旧 `docs/assets/art-readiness-audit-report.json` / acceptance 报告仍是 `55/55` 已批准集合，不代表新增第 `56` 项已完成治理，也不代表商业手绘清稿、最终 typography、autotile 或完整试玩美术签核。
- `docs/assets/asset-runtime-integration-map.json` 当前 `55` 项中 `25` 项为场景引用已验证，`29` 项不是运行目标，另 `1` 项仍是手工替换映射；不能把 `55` 项全部理解为正式场景正在使用。
- `stage19_discovery_map_base_ai01` 已被 `DemoShell` 真实引用，却缺少 runtime integration map 条目，导致 strict runtime-map 审计失败；这是 Stage27 前必须清掉的资产治理漂移，不是图片未上屏。
- 最终处置为 `26 runtime_keep / 20 source_dev_keep / 9 archive_keep`；source sheet、Spine 拆件、宣传方向和分镜仍按各自边界使用。
- Luna 当前生产代码实际引用 `7` 个动作片段、合计 `111` 帧：idle `16`、run `24`、jump state `11`、attack body `16`、air dash `16`、hit `8`、death `20`。它们证明管线可运行，不代表全动作集或正式清稿完成。
- Luna 当前只引用 slash / seal arc 两套各 `8` 帧攻击 VFX，二者共同按当前元素改色；没有风、雷、风→雷、雷→风四套独立技能特效。
- Seal Guardian 当前生产代码实际引用 idle `4`、warning `4`、attack `8`、stagger `4`、defeat `4`，合计 `24` 帧，以及一套 `8` 帧 attack VFX；没有独立近 / 远攻击、明确阶段转换和高质量击败演出。
- `assets/audio/` 只有 `music/.gitkeep` 与 `sfx/.gitkeep`，当前实际接入音频为零。

## 正式 Demo 美术完成定义

“正式 Demo”不以文件数、生成图分辨率或 SpriteFrames 能播放为准，至少同时满足：

1. **统一角色**：同一角色跨动作的脸、发型、服装、武器、身体比例和轮廓一致，没有明显 AI 形变、透明抠图色边或体积跳变。
2. **完整动作语义**：当前实际玩法状态均有对应动作；前摇、命中窗口、收势、受击、阶段变化和死亡不能由同一静态短循环冒充。
3. **战斗可读性**：两元素、两姿态、两种序列和 Boss 攻击在关闭文字提示、色弱不只看颜色的条件下仍可区分。
4. **运行时闭环**：正式资源在生产场景真实引用，固定根部锚点，碰撞 / 伤害仍由代码权威；连续帧、实际游戏距离、16:9 / 2K / 21:9 和性能复核通过。
5. **来源与发布**：source、candidate、runtime、accepted 和 release 状态分离，生成工具、prompt、人工清稿、授权和最终选择可追溯。

## 运行态抽查

抽查证据：

- `tests/artifacts/local/stage21/stage21_element_hud_runtime.png`
- `tests/artifacts/local/stage23/stage23_bounty_board_runtime.png`
- `tests/artifacts/local/stage24/stage24_two_slot_build_runtime.png`
- `tests/artifacts/local/stage25/stage25_relay_grounded_runtime.png`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_attack_body_runtime_sheet_ai03.png`
- `assets/art/characters/player/sprite_sheets/runtime_replacement/luna_jump_state_runtime_sheet_ai04.png`
- `assets/art/characters/enemies/sprite_sheets/runtime_replacement/seal_guardian_attack_body_runtime_sheet_ai02.png`
- `assets/art/vfx/atlases/seal_guardian_attack_vfx_atlas_ai01.png`

| 系统 | 当前真实表现 | 问题等级 | 结论 |
| --- | --- | --- | --- |
| 元素 / 姿态 / 序列 | 同一 Luna `attack_body`、同一 slash / seal arc VFX 按风青绿 / 雷蓝紫染色；HUD 用两行文字显示状态 | P0 表现 | 逻辑可测，但玩家主要靠读字，不符合“符印法阵 + 灵力链”核心视觉锚点 |
| 敌人 / Boss 反应 | 复用弹体消失、Charger 退位 / defeat、Boss stagger、脉冲关闭 | P1 表现 | 结果真实，但缺少反应前摇、命中确认和序列专属特效 / 音效 |
| 镇妖驿站 / 悬赏 | 背景与既有区域接近；世界内悬赏榜 marker 复用既有 equipment atlas 图标；榜单是现有 parchment 面板和文字按钮 | P0 身份 | UI 可读，但场景不像独立驿站，缺少悬赏榜 prop、驿卒与镇妖卫制度感 |
| 圣物 / 组件 Build | 四件物品以文字列表显示，没有独立图标、槽位构图和获得演出 | P1 可读性 | 数值差异存在，视觉上仍像调试设置页 |
| 雷泽荒原 | 复用 `biome02_miasma_marsh_background_ai01` 染冷蓝；雷云、闪电、祭柱、屏障主要是 Polygon2D；门与 marker 复用旧 atlas | P0 区域 | 是当前最明显灰盒。区域机制成立，但尚无独立环境身份 |
| 角色动作 | idle / run / jump / attack / dash / hit / death 可运行，共 `7` clips / `111` 帧 | P0 正式 Demo | 现有帧存在动作语义合并和跨帧一致性风险；疾 / 御、风 / 雷、空中攻击、恢复和两种序列共用或缺少动作 |
| UI | 现有九宫格、地图底板、按钮和 HUD 可用 | P1 一致性 | 北极星新增系统缺少专属图标，文字密度高，32px / 手柄焦点下识别成本偏高 |
| 音频 | 无运行文件 | P0 缺失 | 战斗节奏、敌人预警、菜单反馈和区域氛围都缺少一半感知通道 |
| Promo / LOGO / CG | 有方向稿和 source 资产 | P2 发布 | 只能作为方向参考，不能作为最终标题字、商店 capsule 或公开 CG |

## 正式 Demo 资产缺口看板

下表中的帧数是排产包络，不是质量替代物；旧帧只有逐项通过正式门禁后才能复用。

| 资产族 | 当前生产引用 | 正式 Demo 最小目标 | 当前缺口 | 优先级 / Stage |
| --- | --- | --- | --- | --- |
| Luna 基础移动 | idle `16`、run `24`、jump `11`、air dash `16`、hit `8`、death `20` | 拆分并清稿 idle、run、jump start / rise / apex / fall / land、air dash、hit、death | jump 多语义共用；缺 land；需统一比例、根部、服装和透明边缘 | P0 / Stage27 |
| Luna 战斗 body | 单一 attack body `16` 帧用于全部元素 / 姿态 | 疾印地面攻击、御印地面攻击、空中攻击、风→雷收势、雷→风收势、元素切换、姿态切换、恢复 | `8` 类战斗语义缺失或共用同一动作 | P0 / Stage27 |
| Luna 技能 VFX | slash `8` + seal arc `8`，按元素改色 | 风击、雷击、风→雷、雷→风四套独立 startup / active / impact / recovery；另补切换、命中、恢复与 dash 反馈 | 只有两套形状，玩家主要靠颜色和 HUD 文字 | P0 / Stage27 |
| Seal Guardian 动作 | `5` clips / `24` 帧 | idle、近 / 远 warning、近 / 远 attack、guard break / stagger、phase transition、hit、defeat，约 `8-9` clips / `72-110` 帧 | 攻击类型、二阶段和击败轮廓不足；现有 defeat 不能稳定读成倒下 / 消散 | P0 / Stage27 |
| Seal Guardian VFX | 单套 attack VFX `8` 帧 | 近 / 远 warning、impact、破印、转阶段、击败消散 | 没有阶段和结果层级 | P0 / Stage27 |
| 雷泽普通敌人 | 无专属角色 | idle / move / warning / attack / hit / defeat，约 `6` clips / `36-60` 帧，加元素反应 VFX | 整个区域没有敌人视觉生态 | P0 / Stage30 |
| 雷泽区域 Boss | 无 | 两种攻击、两阶段、phase transition、guard break / stagger、hit、defeat与配套特效，约 `8-10` clips / `80-120` 帧 | 完全缺失，不能换色 Seal Guardian | P0 / Stage30 |
| 驿站 / 悬赏 / Build | 通用背景、marker 和文字面板 | 正式驿站、三状态榜牌、驿卒、3 悬赏图标、4 Build 图标、2 槽状态 | 制度与成长缺少独立视觉身份 | P0-P1 / Stage28 |
| 雷泽环境 | 瘴泽背景冷色复用和 Polygon2D | 专用 TileSet、2-3 层背景、地标、天气、祭柱 / 屏障状态和 Boss 房 | 当前是最明显区域灰盒 | P0 / Stage29-30 |
| 音频 | 运行文件 `0` | 首批战斗 / UI / Boss SFX、雷泽氛围 / BGM 与混音事件 | 整个正式 Demo 缺少声音反馈通道 | P0 / Stage27 起 |

### Luna 全动作集排产包络

| Clip | 建议最终帧数 | 关键验收 |
| --- | --- | --- |
| idle / run | `8-12` / `12-16` | 呼吸、披带和脚步节奏自然；循环首尾不跳 |
| jump start / rise / apex / fall / land | 各 `2-6` | 空中阶段轮廓清楚；land 不复用蹲姿或死亡帧 |
| air dash | `8-12` | 身体压低、方向明确、根部轨迹稳定，与 trail 分层 |
| 疾印 / 御印地面攻击 | 各 `8-12` | 前摇、active、收势不同；姿态轮廓不是只换颜色 |
| 空中攻击 | `8-12` | 与跳跃轮廓区分，落地 / 取消边界不闪帧 |
| 风→雷 / 雷→风收势 | 各 `6-8` | 一个强调贯穿，一个强调扩散，动作和 VFX 同时可读 |
| 元素切换 / 姿态切换 | 各 `6-8` | 符印手势、身体重心和 UI 反馈一致 |
| 恢复 | `8-12` | 明确蓄势和生效点，不与 idle 混淆 |
| hit / death | `6-8` / `16-20` | 受击方向、失衡和最终倒地清楚；可重复受击不抖动 |

共约 `18` 个 clips、`121-169` 个基础最终帧；加必要的转身、衔接和替换帧后，以 `150-200` 帧作为生产包络。正式验收仍以一致性、读值和运行表现为准。

## 可以直接复用的底座

- Luna、四类普通敌人、Seal Guardian 的现有状态映射、固定 cell 和 SpriteFrames 接入方式；现有画面只作为候选底稿与时序参考，不自动继承正式 Demo 通过状态。
- `menu_ninepatch_ui_ai01`、现有 UI Theme、发现式地图动态绘制与 parchment panel。
- `shrine_gate_prop_atlas_ai01`、`equipment_pickup_atlas_ai01` 中已经过单件切片和运行验证的通用 shrine / gate / reward 资源。
- 现有 slash、hit、seal、warning VFX 作为时序和锚点参考；不能继续只靠染色承担所有新语义。
- 现有场景碰撞、TileMap 和 44 房视觉 / 碰撞对齐门禁；新美术只替换显示层，不重写玩法碰撞。

## 必须新增或正式清稿的资产包

| Pack ID | Stage | 优先级 | 最小内容 | 动作帧要求 | 当前不做 |
| --- | --- | --- | --- | --- | --- |
| `NS27-LunaFormalMotion` | Stage27 | P0 | Luna 全动作集统一清稿、缺失动作补齐、固定格与锚点元数据 | 约 `18` clips / `150-200` 帧生产包络 | 不改变移动、碰撞和伤害规则 |
| `NS27-CoreCombatVFX` | Stage27 | P0 | 风击、雷击、风→雷、雷→风四组技能 VFX；切换、命中、恢复、dash 与 HUD 图标 | VFX 与 body 分层 | 不以换色算独立特效 |
| `NS27-SealGuardianPolish` | Stage27 | P0 | 既有 Boss 近 / 远攻击、阶段、破印、硬直、击败动作与 VFX | 约 `8-9` clips / `72-110` 帧 | 不重写 Boss 伤害框架 |
| `NS27-Audio` | Stage27 | P0 | 攻击、命中、元素 / 姿态、两序列、受伤、敌人 / Boss 预警、UI 焦点 / 确认 / 返回 | 不适用 | 不先做完整语音与全区域 BGM |
| `NS28-Waystation` | Stage28 | P0 | 驿站背景 / 地形、三状态悬赏榜、驿卒 sprite / portrait、3 悬赏图标、4 Build 图标、2 槽 UI | 驿卒 4-6 帧 idle 即可 | 不做 NPC 群像、通用对话系统 |
| `NS29-ThunderWaste` | Stage29 | P0 | 风格板、2-3 层背景、区域 TileSet、安全 / 危险地表、雷云 / 荒草 / 残旗、祭柱 / 屏障状态、天气 VFX | 环境状态帧优先 | 不扩六房拓扑 |
| `NS30-ThunderEnemyFamily` | Stage30 | P0 | 1 个普通敌人家族、元素反应、击败与战斗 SFX | 约 `6` clips / `36-60` 帧 | 不做完整敌人生态库 |
| `NS30-ThunderBossFormal` | Stage30 | P0 | 1 个两阶段首领、Boss 房、吸收 VFX、大妖组件、战斗 SFX / Boss 音乐 | 约 `8-10` clips / `80-120` 帧及独立阶段 VFX | 不做通用 Boss rig |
| `NS31-PersistenceTravelUI` | Stage31 | P1 | save / continue / corrupted / travel 图标、两驿站状态、传送确认面板与音效 | 无新增 body 动作 | 不做多存档槽与全地图传送图标库 |
| `NS32-BetaPresentation` | Stage32 | P1-P2 | 正式标题字、设置 / 菜单清稿、宽屏边缘修正、最终 mix、必要 capsule / release 图 | 只修真人复核发现的动作问题 | 不提前制作完整商业宣传套件 |

## 动作帧结论

Stage21-26 没有增加与元素、姿态、序列、悬赏、Build 或雷泽对应的新动作帧。当前代码在所有元素 / 姿态下继续选择同一个 `luna_attack_body_runtime_sheet_ai03`，攻击 VFX 通过 `_get_element_vfx_color(...)` 改色。

原路线中“只补一组短姿态切换、不重做 Luna 全套”的最小方案已经取消。正式 Demo 的正确顺序是：

1. Stage27 先完成 Luna 当前玩法覆盖的全动作集与四类真正不同形状 / 节奏的技能 VFX。
2. 同阶段提升既有 Seal Guardian；它是 Demo 内已经出现的 Boss，不能把 `24` 帧技术可用短片段当成正式展示。
3. Stage30 的雷泽敌人与区域 Boss 从概念、动作、VFX 到音频独立生产，不能复用旧敌人或 Seal Guardian 换色冒充。

所有新动作继续遵守透明背景、单动作规则网格、固定 cell、稳定根部锚点、无跨格特效；玩法窗口仍由代码权威，SpriteFrames 不反向决定 hitbox 或伤害时机。

## 美术验收门

- Stage27 开发前先补齐 `stage19_discovery_map_base_ai01` 的 runtime-map / readiness / acceptance 记录，并让全部 strict 资产审计重新通过。
- `存在文件`、`source sheet 可加载`、`Gallery 可见` 和 `final-ready 旧审计` 均不能替代新 Stage 的真实场景引用。
- 每个 Pack 必须经历：manifest 登记、来源 / 授权、候选选择、清稿 / 切片、Godot import、真实场景绑定、小尺寸 / 锚点 / 碰撞读值、运行态截图和对应 GUT。
- Luna / Boss 静止动作的根部漂移应控制在运行时 `2px` 内；连续动作不得出现脸、服装、武器和身体体积跳变，透明边缘不得保留可见紫 / 绿色抠图色边。
- 雷泽和驿站以场景截图签核；元素 / 姿态以无 HUD 短视频或连续运行复核；Boss 以完整 warning → attack → impact → stagger / phase → defeat 录制签核；音频以事件覆盖、响度和重复播放复核。
- Gate26M 可以自动检查资源引用、动作切换、时序、截图、连续帧和错误；最终审美、手感、误读和路线理解仍由延后的 Gate26H 真人签核。
- Stage32 前单独完成公开标题字、宣传图和 AI / 音频工具发布条款复核，不能用内部 Alpha 批准替代发布授权。
