# Stage28 镇妖驿站资产与音频候选矩阵

## 运行态美术

| Asset ID | Runtime output | 运行用途 | 自动证据 | 人工边界 |
| --- | --- | --- | --- | --- |
| `stage28_waystation_background_ai01` | `assets/art/environment/waystation/stage28_waystation_background_runtime_ai01.png` | Stage11 `1152x512` 正式背景显示层 | SHA256 `cbfa9c29b597eb6236b7fcb9bc3c0bbe967c580d2a30ff797f0768248e0886de` | Gate26H 构图 / 对比度 / 授权 |
| `stage28_waystation_world_sheet_ai01` | `stage28_waystation_world_runtime_ai01.{png,spriteframes.tres}` | 四状态榜牌、驿卒 4 帧 idle、雷泽路引、左右 marker、checkpoint | SHA256 `b50da0659751c27956b89a923924b33833cf59bd1b4516bfd6bfbd9d432b63c3` | Gate26H 64px 读值 / 动作审美 / 授权 |
| `stage28_waystation_ui_sheet_ai01` | `assets/art/ui/stage28_waystation_ui_runtime_ai01.png` | 驿卒 portrait、3 悬赏、4 Build、空 / 已装备槽位 | SHA256 `ff9d76dbc90d2d1c121f0f3362fd62f6a11af58c70e3073f736d44ef1fee113f` | Gate26H 32px / 64px 读值 / 授权 |
| `stage28_bounty_archive_frame_warden_ai01` | `assets/art/ui/stage28_bounty_archive_frame_warden_ai01.png` | 悬赏榜专用暗漆铜框；标题、统计、任务、图标、焦点和返回均由 Godot 动态绘制 | RGBA `1306×1205`；SHA256 `b6ee259326b5b6a9933d723f5c1d90ece0098bcbb34afb24173a0823d95f08a2`；2K 视觉复核 PASS | 用户最终审美 / 物理显示距离 / 外部发布授权 |

原始候选保存在 ignored `assets/source/ai_generated/batch_28/`；色键或 Alpha 清理结果在各自 `prepared/`。`build_stage28_waystation_assets.py` 只生成原有背景 / 图集；新增悬赏框是独立单图，不塞入既有 `4×4` 图集，也不改变 Stage11 碰撞、出口、checkpoint、任务或 Stage25 路引逻辑。

### 世界表 4x4

- `0-3`：`bounty_available / accepted / completed / turned_in`。
- `4-7`：同一驿卒 `clerk_idle` 四帧。
- `8-11`：灯、钟、`route_locked / route_open`。
- `12-15`：左 / 右路标、checkpoint、案卷箱。

### UI 表 4x4

- `0` 驿卒 portrait；`1-3` 三悬赏。
- `4-7` 四 Build：瘴泽遗物、镇妖挑战符、腐瘴法珠、守印金刚心。
- `8-11` 空槽、已装备槽、焦点空槽、焦点装备槽。
- `12-15` 奖励印、获得提示、比较 / 交换、雷泽路引。

## Stable Audio 候选

生成入口：Stable Audio 3 Small SFX / TFLite CPU，`sm-sfx + same-s + fp32 + 8 steps + 8 threads`。本批严格串行并发 `1`，硬上限 `<4`；均为 stereo / 44.1kHz，并已通过 `soundfile 0.14.0` 打开验证。

| Event | Seed | Duration | Scratch path | SHA256 | 状态 |
| --- | ---: | ---: | --- | --- | --- |
| 榜牌展开：木板、纸页、克制铜铃 | 2801 | 2.000s | `D:/AI/audio/outputs/scratch/nano-hunter/stage28/stage28_bounty_board_open_seed2801.wav` | `e681d810179db1c90fa37e3f9ae817009bf6a866ca00e2a755496edc86136887` | candidate only |
| 回交盖印：厚纸、铜印、短金色余响 | 2802 | 2.000s | `D:/AI/audio/outputs/scratch/nano-hunter/stage28/stage28_bounty_reward_stamp_seed2802.wav` | `70d9535e3744fd8f1f512ad6da2fd7f2ad30bb5209986ccf507268ceba3b7825` | candidate only |
| Build 装备：玉石入槽、铜扣闭合 | 2803 | 2.000s | `D:/AI/audio/outputs/scratch/nano-hunter/stage28/stage28_relic_equip_seed2803.wav` | `f3da78d246442b66e583c15c893e72937d3b278dc56550ec3f760fa711795928` | candidate only |
| 驿卒交互：小铜铃、衣袖、符纸 | 2804 | 2.000s | `D:/AI/audio/outputs/scratch/nano-hunter/stage28/stage28_waystation_clerk_bell_seed2804.wav` | `687d3bec71592a6e85de3503e4e1e887f658164cc84c5cef2d854b3d2b96c895` | candidate only |
| 驿站环境：山风、远钟、符纸、室内底噪 | 2805 | 5.000s | `D:/AI/audio/outputs/scratch/nano-hunter/stage28/stage28_waystation_ambience_seed2805.wav` | `6951400a094dd0535ae5026998eb679422947e45829b401e28a3cb1c54774a4b` | candidate only |

首项第一次调用在模型加载前因未显式传 `--decoder` 收到 EOF，没有生成文件；补 `--decoder same-s` 后五项依次成功。当前没有真人试听、响度 / peak 清理、循环接缝、叠爆或授权接受，所以没有复制到 `assets/audio/`，也不标记为 integrated / accepted。
