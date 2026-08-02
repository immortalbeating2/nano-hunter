# Stage31 存档与双驿站传送资产矩阵

## 运行边界

- Stage31 复用 Stage16 主菜单与 Stage28 驿站运行资产，只补 Continue、存档健康状态、checkpoint 和双点传送图标；不重绘角色、房间或第三个传送点。
- `scripts/assets/build_stage31_persistence_travel_ui.py` 从两张已接入 PNG 确定性合成 `4x4` 图集；来源 hash、cell 与输出 hash 分别保存在 `.source.json` / `.frames.json`。
- 图标只负责显示，不持有存档、碰撞、伤害或传送门控权威。正式状态仍来自 `Main` 快照。
- `integrated` 只证明生产 UI 已引用；外部发布条款、32px 读值与真人审美仍留给 Gate26H。

## NS31-PersistenceTravelUI

| Runtime output | 规格 | SHA256 | 来源 / 状态 |
| --- | --- | --- | --- |
| `assets/art/ui/stage31_persistence_travel_ui_runtime_ai01.png` | `640x640`、`4x4`、每格 `160x160` | `dcd3c7496a67339440ac7b08ba75c3e26ded8e1ea4f797d9d91b370aba62d715` | Stage16 菜单图标 + Stage28 驿站图标；deterministic composite；integrated / Gate26H pending |

| Cells | Semantic state | Consumer |
| --- | --- | --- |
| `0-3` | `continue_load / new_game / save_success / save_error` | 主菜单 Continue / New Game 与存档结果 |
| `4-7` | `waystation_main / thunder_outpost / travel_available / travel_locked` | 暂停菜单与驿站传送列表 |
| `8-11` | `checkpoint / backup / return / paused_save` | 存档 / checkpoint 状态提示 |
| `12-15` | `current_waystation / current_outpost / save_pending / valid_save` | 当前站点与存档健康状态 |

运行时只直接消费当前需要的 New Game、Continue、save error、两站、available / locked 与 current 图标；其余 cell 是同一冻结图集里的状态补充，不引入新的 UI 系统。

## NS31-Audio 试听队列

本批使用 `local-game-audio` 的 Stable Audio 3 Small SFX，严格串行生成：实际并发 `1`，CPU-light lane 硬限制 `1`，项目约束硬上限 `<4`。参数统一为 `sm-sfx + same-s + fp32 + 8 steps + 8 threads`。文件只保存在 `D:/AI/audio/outputs/scratch/nano-hunter/stage31/`，均已通过 `soundfile` 解码、时长、声道与 hash 验证；尚未人工试听、响度清理、授权复核或复制进项目。

| Event | Seed | Prompt 摘要 | Format / peak / RMS | Scratch file | SHA256 | 状态 |
| --- | ---: | --- | --- | --- | --- | --- |
| 保存成功 | `3101` | 符印盖章、纸封轻响、短铜铃；no music / no voice | stereo / 44.1kHz / 3.0s / `0.357056` / `0.013846` | `nano_hunter_stage31_save_success_candidate_sa3_seed3101.wav` | `eee8fc9885e13a948f0149e0f91fe3cb0f0d0d2fb8fcc45fb0b2c2e7ef66147e` | candidate only；listen / trim / mix pending |
| 存档错误 | `3102` | 破符脆裂、木击、灰烬嘶声；no music / no voice | stereo / 44.1kHz / 3.0s / `0.538452` / `0.019163` | `nano_hunter_stage31_save_error_candidate_sa3_seed3102.wav` | `44b31048c3f89d523887abc9a450e8aded6292dbf8c3ae06f67af1646476074e` | candidate only；listen / trim / mix pending |
| 驿站传送 | `3103` | 木门风掠、短铜铃、微弱电尾；no music / no voice | stereo / 44.1kHz / 3.0s / `0.338715` / `0.024686` | `nano_hunter_stage31_waystation_travel_candidate_sa3_seed3103.wav` | `ee1f02b7f15ba3bf1b799ec844233b0d51956568fcb07de86e3a50cbd9d20fce` | candidate only；listen / trim / stacking pending |
| checkpoint | `3104` | 石印共鸣、纸张拂动、温和短铃；no music / no voice | stereo / 44.1kHz / 3.0s / `0.293030` / `0.013213` | `nano_hunter_stage31_checkpoint_candidate_sa3_seed3104.wav` | `3f862908372f78502161eea26b1643c0e463c5164c3eb36426f51396461792b5` | candidate only；listen / trim / stacking pending |

试听接受后才允许裁切静音、统一 peak / loudness、记录 accepted hash 与 tool terms、转 OGG、复制到 `assets/audio/` 并绑定事件 / 总线。当前不得声称音频已接入。

## 自动与人工边界

- PNG 已由 Godot `4.6.3` 导入；Stage31 GUT 保护有效 / 无效 Continue 图标、双站条目、状态与手柄焦点。
- `soundfile` 已确认四条 WAV 均为 `3.0s`、stereo、`44.1kHz` 且可解码。
- Gate26H 仍需真人确认 32px 图标辨识、存档提示是否容易理解、四条音效的裁切 / 响度 / 堆叠与商业发布边界。
