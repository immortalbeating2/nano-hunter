# Stage29 雷泽荒原资产与音频候选矩阵

## 运行边界

- Stage29 只替换 Stage25 六房的显示层；房间拓扑、`StaticBody2D`、`CollisionShape2D`、出口、marker、伤害与接地机关仍由原 Stage25 契约负责。
- 原始图像候选保存在 ignored `assets/source/ai_generated/batch_29/`；运行输出由 `scripts/assets/build_stage29_thunder_waste_assets.py` 确定性生成。
- `integrated` 只证明生产场景真实引用，不代表外部发布条款、美术审美、小尺寸读值或 Gate26H 已批准。

## 运行态美术

| Asset ID | Runtime output | 运行用途 | SHA256 | 人工边界 |
| --- | --- | --- | --- | --- |
| `stage29_thunder_waste_background_ai01` | `assets/art/environment/thunder_waste/stage29_thunder_waste_background_runtime_ai01.png` | 六房共享 `1280x512` 三层雷泽背景 | `0cfa75a78e2f45706c82b64e3cd5ef89f57dc9f6525a2f8a1806d868cec7eeab` | Gate26H 构图、对比度、授权 |
| `stage29_thunder_waste_environment_sheet_ai01` | `stage29_thunder_waste_environment_runtime_ai01.png` | 安全 / 危险地表源、六个独立地标、雷云与 props | `5c78b24f105019a3e9a3e98f0e1e7661a7b8ba79db994fa37c02907efa317548` | Gate26H 64px 读值、重复感、授权 |
| `stage29_thunder_waste_environment_sheet_ai01` | `stage29_thunder_waste_tiles_runtime_ai01.{png,tileset.tres}` | `64px` 安全 / 危险地表显示 TileSet；无碰撞权威 | `6e9738c43999bdb3ff7fe2b7a3f732d80f47c06f5914dd0863e44bdb368562b2` | Gate26H 地表 / 危险区辨识 |
| `stage29_thunder_waste_state_vfx_ai01` | `stage29_thunder_waste_state_vfx_runtime_ai01.{png,spriteframes.tres}` | 雷暴、祭柱、屏障、出口、支路与前哨状态 | `0602ac1b0de782164599360260ea3e1530013008fe16ef2af41f94979a1361c6` | Gate26H 动态节奏、亮度、授权 |

### Environment 4x4 cell

- `0-3`：安全地表、雷裂危险地表、左右坡面。
- `4-9`：入口界碑、雷雨洼地台、引雷坡、风蚀岔口、接地祭台、驿路远眺遗构；六房分别只消费一个索引。
- `10-15`：雷云、芦草、破旗、引雷杆、乱石草丛、前哨小祠。

运行态 MCP 首轮目检发现地标行号使用浮点除法，导致 `5/6/7/9` 错裁；共享 `_stage29_atlas_texture()` 已改为显式 `floori`，并由 Stage29 GUT 逐索引保护 atlas region。

### State VFX 4x4 cell

| Cells | Semantic state | Authority |
| --- | --- | --- |
| `0-3` | `storm_startup / storm_active_a / storm_active_b / storm_grounded` | visual only |
| `4-7` | `relay_active / relay_struck / relay_grounded / relay_disabled` | visual only |
| `8-10` | `barrier_locked / barrier_unlock / barrier_open` | visual only |
| `11-15` | `exit_right / outpost_checkpoint / branch_up / cloud_flash / safe_discharge` | visual only |

全部 `102` 条项目 VFX rule 均保持 `gameplay_collision=false`、`damage_source=false`；Stage29 的碰撞与伤害不从图像帧派生。生成入口保留已有 sidecar，只追加新资产，避免覆盖已人工批准的规则或遗漏历史 Boss VFX。

## 六房绑定

| Room | Landmark | Mechanism | Travel |
| --- | ---: | --- | --- |
| 入口界碑 | `4` | checkpoint / route entry | `thunder_outpost` |
| 雷雨洼地 | `5` | storm hazard + 3 visual hazard tiles | none |
| 引雷坡道 | `6` | route slope landmark | none |
| 风蚀岔口 | `7` | existing branch to relay room | none |
| 接地祭柱 | `8` | storm + relay + locked/open barrier | none |
| 驿路远眺 | `9` | region outlook / return route | none |

六房共用 `18` 个安全显示格；只有雷雨洼地和祭柱房各有 `3` 个危险显示格。入口只登记稳定 travel point ID，本阶段没有传送按钮或新路线。

## NS29-Audio 试听队列

本批严格串行并发 `1`，全局硬上限 `<4`。文件只保存在 `D:/AI/audio/outputs/scratch/nano-hunter/stage29/`，均已通过 `soundfile` 解码验证；未试听、未清理、未授权、未复制进项目。

| Event | Engine / seed | Format | Scratch file | SHA256 | 状态 |
| --- | --- | --- | --- | --- | --- |
| 雷泽环境 | Stable Audio 3 Small SFX / `2901` | stereo / 44.1kHz / 8.0s | `stage29_thunder_waste_ambience_seed2901.wav` | `22dbbb529a2b508d07c5b2c057a9fefdaf25698983332d0baf5beadd70842b10` | candidate only；peak / loop / listen pending |
| 祭柱接地 | Stable Audio 3 Small SFX / `2902` | stereo / 44.1kHz / 3.0s | `stage29_relay_grounding_seed2902.wav` | `c020fa82b29b72fb1517c98c695ecf186d06bbd4ea5f39ff1e360147661d535f` | candidate only；peak / stacking / listen pending |
| 雷泽探索 BGM | ACE-Step 1.5 / `2903` | stereo / 48kHz / 30.0s / 72 BPM / D minor | `stage29_thunder_waste_exploration_bgm_seed2903.wav` | `d5a944641436b3cc5fb885636bb0e80d8c8609dd519cccc5d21da37e677c1c50` | candidate only；loop / mix / listen pending |

两条 Stable Audio 候选的模型预览峰值高于 `1.0`，落盘峰值为 `0.999969`，必须先做 peak / loudness 清理；BGM 落盘峰值为 `0.891266`。试听接受后才允许记录 accepted hash、补齐 tool terms、转 OGG、复制到 `assets/audio/` 并绑定事件 / 总线。

## 自动与运行态证据

- strict 资产治理：`66/66 structural-ready`、`55/66 final-ready`，`11` 项保留人工签核；综合 package、source safety、provenance、runtime map / catalog、gallery、workbench 与 acceptance gates 均通过。
- Godot MCP Pro：生产 Main 逐房进入六房；确认地标 `4-9`、入口 `thunder_outpost`、`18` 个安全格、危险房 `3` 个危险格，以及祭柱接地后 `relay_grounded / barrier_open / collision disabled / storm hidden`。
- ignored 证据位于 `tests/artifacts/local/stage29/mcp/`：六房原生 `2560x1440` 无 HUD 图、地标近景、`1280x720` 缩放预览与 `2560x1080` safe-boundary 预览。safe-boundary 只验证构图安全区，不替代真实 21:9 显示器和 Gate26H 真人审美签核。
