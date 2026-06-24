# Nano Hunter Image Gen Preview Log

Last Updated: 2026-06-19

## 用途

本文件记录 Codex 内置 `image_gen` 已生成但尚未落盘的会话预览。它用于保存视觉评审结论、prompt 来源和落盘扫描结果，避免后续 session 误以为“没有产出任何视觉方向”或反过来误判为“资产已经接入”。

本文件不是资产 manifest，也不是完成证明。只有真实 PNG / WEBP 进入 `assets/source/ai_generated/` 或外部资产库，并完成筛选、清稿、图集化和 Godot 验证后，才能更新 `asset-manifest.md` 的接入状态。

## 状态定义

| 状态 | 含义 |
| --- | --- |
| `preview_generated` | 内置 `image_gen` 已在会话中展示预览，但本地文件未确认 |
| `file_detected` | 已在 `$CODEX_HOME/generated_images`、Codex home 或临时目录发现候选文件 |
| `imported_candidate` | 已导入 `assets/source/ai_generated/batch_XX/<asset_id>/candidates/` |
| `discarded_preview` | 预览不适合继续使用，仅保留问题记录 |

## 2026-06-19

### Current session PNG recovery

- Status: `imported_candidate`
- Recovery log: `docs/assets/image-gen-session-recovery-log.md`
- Result: 当前会话中的 `33/33` 个 image gen 预览已从 Codex session JSONL 的 `image_generation_call.result` 恢复为本地 PNG。
- Destination pattern: `assets/source/ai_generated/batch_XX/<asset_id>/candidates/<asset_id>_candidate_01.png`
- Boundary: 下方逐项 visual review 仍保留原始会话评审；其中早先的 `Local file status: not detected` 表示恢复前状态。恢复后的真实边界以 `image-gen-session-recovery-log.md` 为准：已落盘为原始候选，但尚未清稿、切片、图集化或接入 Godot。

### Batch02 default image directory import

- Status: `imported_candidate`
- Recovery log: `docs/assets/image-gen-session-recovery-log.md`
- Result: Batch02 新增 `6/6` 个 image gen 候选已从默认保存目录复制到项目候选目录，并导出为 `assets/art` standalone PNG。
- Default directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Queue status: 当前 queue 已从 `33` 项扩展到 `39` 项，其中 `23` 项为 atlas-linked outputs。
- Boundary: Batch02 当前是 `placeholder_ready`，仍需清理伪文字、拆帧、锚点和小尺寸读值复核；尚未接入 Stage16 UI / 完成反馈。

### stage16_luna_player_readability_ai01

- Batch: `Batch 01`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/characters/player/stage16_luna_player_readability_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported

Visual review:

- 主体方向符合 Luna 玩家读值目标：侧向角色、月白 / 墨青主色、青白符印光、朱砂符纸和轻型动作轮廓成立。
- 适合作为 Luna P0 读值方向的候选参考，后续仍需真实 PNG 落盘后检查透明背景、边缘、尺寸、缩放读值和是否可切入 sprite / concept 流程。
- 不能作为 `assets/art/` 可运行资产引用；当前只保留为会话预览记录。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 5 --limit 12
```

Result:

```text
No recent image candidates found.
```

Follow-up:

- 若用户或客户端能手动保存该预览图，使用 production packet 内的显式路径导入命令：

```powershell
python scripts/assets/import_imagegen_outputs.py --source C:\path\to\image.png --batch 01 --asset-id stage16_luna_player_readability_ai01
```

- 导入后再进行 chroma-key 去背景、尺寸检查、manifest 来源记录和后续清稿。

### stage14_air_dash_icon_ai01

- Batch: `Batch 01`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/ui/stage14_air_dash_icon_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported

Visual review:

- 能力意图清楚：符印环、横向冲刺能量和青白灵光适合 Air Dash 读值。
- 当前预览偏精致徽章和大图标，后续进入 HUD 前需要简化细节、统一线宽，并检查 `64x64` 与 `32x32` 下是否可读。
- 可作为 Air Dash icon 的方向候选，但不能作为 `assets/art/ui/` 可运行资产引用。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 20
```

Result:

```text
No recent image candidates found.
```

### stage15_seal_guardian_ai01

- Batch: `Batch 01`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/characters/enemies/stage15_seal_guardian_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported

Visual review:

- Boss 方向成立：古石甲、佛门封印链、兽面守护者轮廓、青白封印核心和瘴气裂纹都符合 Seal Guardian 的东方奇幻定位。
- 当前细节偏密，右侧烟尾 / 破碎轮廓较长；后续做 Boss sprite sheet 时应收束外轮廓、减少噪声，并把攻击读值和受击体积分离。
- 可作为 Seal Guardian 主方向候选，但尚不能接入 Boss 场景。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 20
```

Result:

```text
No recent image candidates found.
```

### stage15_recovery_charge_icon_ai01

- Batch: `Batch 01`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/ui/stage15_recovery_charge_icon_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported

Visual review:

- 恢复 / 充能意图清楚：莲花形佛门符印、青白回充光、月白符纸和朱砂印记适合 Recovery Charge HUD。
- 当前预览仍偏大图标，需要压缩为更少形状层级，避免在 `32x32` 下读成普通装饰纹章。
- 可作为 Recovery Charge icon 方向候选，但尚未落盘或接入。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 20
```

Result:

```text
No recent image candidates found.
```

### stage14_air_dash_trail_ai01

- Batch: `Batch 01`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/vfx/stage14_air_dash_trail_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported

Visual review:

- 横向速度感明确，青白符印能量、墨迹拖尾和朱砂火花都符合 Air Dash VFX 方向。
- 右侧符印头部略像终点徽章，后续做 VFX atlas 时应拆成短帧并减少固定徽章感。
- 可作为 Air Dash trail 的 VFX 方向候选，但尚未落盘或接入。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### stage14_air_dash_shrine_ai01

- Batch: `Batch 01`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/props/stage14_air_dash_shrine_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported

Visual review:

- 能力圣坛方向成立：石台、佛门符印环、悬挂符纸、青白能量和古刹氛围都稳定。
- 当前更像完整场景装置，而不是单个可复用 prop；后续应拆成 altar、seal ring、talisman paper 和 glow 几个部件，方便状态切换。
- 可作为 Air Dash shrine 方向候选，但尚未落盘或接入。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### stage14_air_dash_gate_ai01

- Batch: `Batch 01`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/props/stage14_air_dash_gate_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported

Visual review:

- 玩法读值清楚：石门柱、横向青白能量栏和朱砂封印锁能表达“需要 Air Dash 穿过”。
- 当前是单一大物件，后续应拆出 locked / open / completed 状态，并降低背景式装饰噪声。
- 可作为 Air Dash gate 方向候选，但尚未落盘或接入。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### stage15_boss_attack_warning_ai01

- Batch: `Batch 01`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-01-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/vfx/stage15_boss_attack_warning_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported

Visual review:

- 红黑危险感强，佛门符印几何与青白边缘光能接回项目视觉体系。
- 当前细节偏精致纹章，正式 Boss warning VFX 应减少细碎线条，做成更直接的 3-6 帧预警序列。
- 可作为 Boss attack warning 方向候选，但尚未落盘或接入。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### luna_run_sheet_ai01

- Batch: `Batch 06`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `luna_run_sheet_ai01`

Visual review:

- 12 帧 run cycle 网格清晰，角色面向、服装、月白 / 墨青色板和符印纸挂件基本一致。
- 这次没有出现帧编号或文字标签，比此前 Luna 动作预览更适合作为动作参考。
- 背景不是完美纯色绿幕，且角色比例仍有轻微漂移；正式化时需要重新切帧、统一脚底基线、补到 `16-24` 帧并清理 alpha。
- 目前只能作为 Luna run 动作方向候选，不能作为 Godot `SpriteFrames` 来源。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### luna_air_dash_sheet_ai01

- Batch: `Batch 06`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `luna_air_dash_sheet_ai01`

Visual review:

- 动作读值明确，能看出 compact anticipation、横向爆发、飞行段和收势。
- 青白能量 trail 没有完全遮住 Luna 轮廓，适合作为 Air Dash 动作参考。
- 网格不够规整，背景绿幕不纯，角色比例和中心点略漂移；正式化前需要重切 cell、统一 centerline，并清稿到 `12-16` 帧。
- 目前不能作为 Godot air dash sprite sheet 直接接入。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### luna_attack_01_sheet_ai01

- Batch: `Batch 06`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `luna_attack_01_sheet_ai01`

Visual review:

- 当前三张 Batch06 预览中最接近动作参考：起手、挥击、主动帧和收势比较清楚。
- 符印武器弧线和青白攻击特效成立，适合后续提炼 attack timing。
- 仍存在绿幕不纯、比例轻微漂移和 cell 不完全规整问题；正式化时需要重切帧、统一脚底基线、补到 `12-16` 帧，并分离角色帧与攻击 VFX。
- 目前不能作为 Godot attack sprite sheet 直接接入。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### luna_idle_sheet_ai01

- Batch: `Batch 06`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/characters/player/sprite_sheets/luna_idle_sheet_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `luna_idle_sheet_ai01`

Visual review:

- 12 帧 idle cycle 方向成立，Luna 角色一致性较好，呼吸、飘带和符纸轻微动势可作为 idle 动作参考。
- 当前更像高分辨率立绘帧，不像最终 `160x160` 游戏小 sprite；后续需要重切 cell、降细节、统一脚底基线，并清稿到 `12-16` 帧。
- 目前不能作为 Godot idle `SpriteFrames` 来源。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### seal_guardian_boss_sheet_ai01

- Batch: `Batch 06`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-06-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `seal_guardian_boss_sheet_ai01`

Visual review:

- 12 帧 Boss attack 方向很强，idle wind-up、封印链抬起、重击 / 横扫和 recovery 的流程清楚。
- Seal Guardian 的古石甲、兽面轮廓、佛门封印链、青白核心和朱砂锁定点都符合项目风格。
- 背景绿幕比多数前序预览更稳定，但正式化仍需要统一 cell、减少高频装饰噪声、明确 hurtbox / attack warning 分离。
- 目前不能作为 Godot Boss sprite sheet 直接接入。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### hud_core_ui_atlas_ai01

- Batch: `Batch 08`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-08-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/ui/atlases/hud_core_ui_atlas_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `hud_core_ui_atlas_ai01`

Visual review:

- HUD 元素族齐全，health seal pips、recovery ring、ability slot、boss trim、checkpoint、completion seal 等方向都符合佛门符印 UI 体系。
- 视觉完成度高，但符纸和小装饰中出现伪文字 / 类文字纹样，正式 UI atlas 必须清理为无文字装饰。
- 小尺寸读值需要二次验证，特别是 `64x64` / `32x32` 下的 health pip、ability slot 和 completion seal。
- 目前不能作为 Godot UI atlas 直接接入。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### icon_sheet_core_ai01

- Batch: `Batch 08`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-08-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/ui/atlases/icon_sheet_core_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `icon_sheet_core_ai01`

Visual review:

- 八个图标语义比较直观，Air Dash、Recovery Charge、checkpoint、sealed gate、boss warning、talisman relay、corruption purge 和 completion 都有可辨识方向。
- 图标细节偏复杂，且符纸元素上有伪文字；正式 icon sheet 需要清除文字感、统一线宽，并在 `32x32` 下重新检查读值。
- 可作为核心 icon sheet 方向候选，但不能直接导入 HUD。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### menu_ninepatch_ui_ai01

- Batch: `Batch 08`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-08-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/ui/menu_ninepatch_ui_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `menu_ninepatch_ui_ai01`

Visual review:

- 面板族方向实用，纸质面板、暗色石质面板、tooltip、button frame 和 divider 的层级清楚。
- 边角和边框适合后续九宫格拆分，但吊牌 / 符纸处仍出现符号纹样；正式版需要转为纯装饰或清除。
- 后续应单独切出可拉伸边框、四角、中心填充和按钮边框，再用 Godot NinePatchRect / StyleBoxTexture 验证。
- 目前不能作为 Godot NinePatch 资产直接接入。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### vfx_seal_magic_atlas_ai01

- Batch: `Batch 10`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-10-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `vfx_seal_magic_atlas_ai01`

Visual review:

- VFX 族方向完整，Air Dash trail、talisman relay、corruption purge、boss warning、hit spark 和 slash arc 都有明确视觉语言。
- 青白灵力、朱砂符印火花、墨迹运动和瘴气暗色能统一到项目符印特效体系。
- 当前预览包含英文标签 / 标题，这是正式 VFX atlas 的阻断问题；后续必须去文字、重排为纯帧格，并减少每格背景噪声。
- 可作为 VFX 语法和帧组构成参考，但不能作为 Godot VFX atlas 或 `SpriteFrames` 来源。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 10 --limit 30
```

Result:

```text
No recent image candidates found.
```

### miasma_marsh_tileset_ai01

- Batch: `Batch 07`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-07-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/tilesets/miasma_marsh_tileset_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `miasma_marsh_tileset_ai01`

Visual review:

- TileSet 方向成立，安全石台、平台边、墙体、转角、藤根、毒水边缘、封印碎石和瘴泽装饰件都有清楚的模块化意图。
- 安全地形与危险毒水的颜色和形状区分较好，适合继续作为 `biome_02_miasma_marsh` 第一轮 TileSet 视觉参考。
- 纯绿背景有利于后续抠图，但正式可接入版仍需要重排为稳定网格、统一 tile 尺寸、清理边缘光晕，并按 Godot TileSet 规则补 collision / terrain set。
- 当前只能作为 TileSet 方向预览；不能直接构建 `assets/art/tilesets/miasma_marsh_tileset_ai01.png`。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No recent image candidates found.
```

### shrine_gate_prop_atlas_ai01

- Batch: `Batch 09`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-09-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/atlases/shrine_gate_prop_atlas_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `shrine_gate_prop_atlas_ai01`

Visual review:

- 道具族风格统一，ability shrine inactive / active、sealed gate locked / open、talisman relay pillar、corruption purge stone、checkpoint lantern 和 ancient stone tablet 都能回到南北朝东方奇幻与佛门符印语境。
- shrine 和 gate 的状态差异比较清楚，active / open 使用青白灵力与朱砂符印强化，适合后续作为玩法状态反馈参考。
- 独立物件构图适合后续拆 atlas，但符纸和石碑上仍有类文字纹样；正式接入前必须清除文字感，避免误读为可阅读文本。
- 当前只能作为 prop atlas 方向预览；不能直接构建 `assets/art/atlases/shrine_gate_prop_atlas_ai01.png`。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No recent image candidates found.
```

### luna_spine_parts_ai01

- Batch: `Batch 11`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-11-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/spine_parts/luna_spine_parts_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `luna_spine_parts_ai01`

Visual review:

- Luna 拆件方向成立，头部、前发、后发、躯干、手臂、前臂、手、腿、靴子、腰带、符纸和法器都有独立拆分意图。
- 角色配色延续 moon white / ink teal / cyan-white seal glow / cinnabar talisman accents，与 Batch06 的 Luna 动作方向基本一致。
- 部件分离度适合后续作为 Spine-style rigging 或手工拆件图集参考，但正式可接入版仍需要统一 pivot 逻辑、左右肢体命名、边缘透明清理和层级顺序。
- 符纸仍有类文字纹样；正式版必须清除文字感，只保留抽象符印装饰。
- 当前只能作为拆件参考预览；不能直接构建 `assets/art/spine_parts/luna_spine_parts_ai01.png` 或接入任何骨骼动画管线。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No recent image candidates found.
```

### promo_key_art_sheet_ai01

- Batch: `Batch 12`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-12-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/promo/promo_key_art_sheet_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `promo_key_art_sheet_ai01`

Visual review:

- Key art 方向成立，Luna 位于神龛 / 瘴泽前景，Seal Guardian 作为上方巨大剪影形成压迫感，符印灵光和墨雾氛围贴合项目主视觉。
- 16:9 构图和顶部留白适合后续标题安全区；可作为 Alpha Demo capsule / store art / trailer still 的主视觉方向参考。
- 当前预览仍含符纸类文字纹样；正式版必须清理所有可读感文字，并保留独立标题安全区供后续人工排版。
- 当前只能作为宣传主视觉方向预览；不能直接构建 `assets/art/promo/promo_key_art_sheet_ai01.png` 或对外发布。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No recent image candidates found.
```

### nano_hunter_logo_direction_ai01

- Batch: `Batch 12`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-12-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/promo/nano_hunter_logo_direction_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: none

Visual review:

- Logo direction 的符印圆章、墨笔字势、金色 / 朱砂配色与东方暗黑奇幻主题一致，可作为后续人工 logo 重绘参考。
- 标志轮廓具备可识别性，适合拆成 emblem、rough wordmark 和 seal stamp 三个方向继续筛选。
- AI 文字存在字形漂移和伪字风险，不能作为最终 logo；正式生产必须由人工重绘字形、矢量化并检查中英文标题规范。
- 当前只能作为 logo direction 预览；不能直接构建最终 `Nano Hunter` 标题字或品牌资产。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No recent image candidates found.
```

### storyboard_narrative_sheet_ai01

- Batch: `Batch 13`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-13-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/storyboards/storyboard_narrative_sheet_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `storyboard_narrative_sheet_ai01`

Visual review:

- 六格分镜方向成立，接 bounty、进入古刹、发现瘴气、触发符门、对峙 Seal Guardian、净化封印链的叙事顺序清楚。
- 镜头节奏适合后续用于 intro rough cut、trailer 节奏草图或剧情演出参考，Luna 与 Seal Guardian 的大小关系和压迫感能读出来。
- 当前预览适合作为叙事节奏方向，但正式版仍需要统一角色比例、面板边距、镜头连续性和所有符纸类文字纹样。
- 当前只能作为 storyboard direction 预览；不能直接构建 `assets/art/storyboards/storyboard_narrative_sheet_ai01.png` 或接入剧情演出。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No recent image candidates found.
```

### style_board_global_ai01

- Batch: `Batch 00`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-00-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/promo/style_board_global_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: none

Visual review:

- 全局风格板方向成立，Luna、Seal Guardian、符印、神龛 / 门、石构、瘴泽色板、HUD 图标母题、VFX 色板和材质块都能收束到同一东方暗黑奇幻视觉系统。
- moon white、ink teal、cyan-white seal glow、vermilion talisman accents、muted gold、dark miasma green / purple 的主色关系清楚，可作为后续批次统一风格参考。
- 构图适合内部 art direction board，但仍有符纸类文字纹样和局部细节密度偏高问题；正式拆为资产前必须清除文字感并降低噪声。
- 当前只能作为全局风格方向预览；不能直接构建 `assets/art/promo/style_board_global_ai01.png` 或替代具体游戏资产。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No recent image candidates found.
```

### shrine_trial_tileset_ai01

- Batch: `Batch 07`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-07-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/tilesets/shrine_trial_tileset_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `shrine_trial_tileset_ai01`

Visual review:

- Shrine trial TileSet 方向成立，古刹地面、平台边、墙体、转角、破损楼梯、屋瓦、符印石面和填充砖块都有明确模块化意图。
- 相比 miasma marsh TileSet，这张更偏安全地形和古刹试炼区，能作为 `biome_01_shrine_trial` 的第一轮 TileSet 参考。
- 平台 / 墙体边界较清楚，适合后续按 64x64 或项目实际 tile 尺寸重切；正式版仍需统一网格、清理符纸类文字纹样和边缘光晕。
- 当前只能作为 TileSet 方向预览；不能直接构建 `assets/art/tilesets/shrine_trial_tileset_ai01.png` 或 Godot TileSet。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No matching image_gen PNG found. One unrelated Temp JPEG icon was detected and rejected.
```

### material_texture_atlas_ai01

- Batch: `Batch 07`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-07-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/textures/material_texture_atlas_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `material_texture_atlas_ai01`

Visual review:

- 材质方向成立，古刹石材、瘴泽泥、水面、木材、符纸、青铜、树根、屋瓦和墨雾边缘的材质语法能覆盖当前区域美术。
- 适合作为后续环境清稿、TileSet 细节和 prop 表面材质参考。
- 当前预览背景不是稳定纯绿，且符纸 / 石印上仍有类文字纹样；正式 atlas 必须重新排纯净网格、统一 swatch 尺寸并清理文字感。
- 当前只能作为 texture direction 预览；不能直接构建 `assets/art/textures/material_texture_atlas_ai01.png`。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No matching image_gen PNG found. One unrelated Temp JPEG icon was detected and rejected.
```

### equipment_pickup_atlas_ai01

- Batch: `Batch 09`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-09-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/atlases/equipment_pickup_atlas_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `equipment_pickup_atlas_ai01`

Visual review:

- 装备 / 拾取物方向成立，talisman charm、seal fragment、recovery shard、jade token、spirit lantern core、bracelet、ritual blade charm、purified crystal、bronze bell 和 folded talisman bundle 都有清楚轮廓。
- 纯绿背景和独立物件布局适合后续抠图与 atlas 切分，整体色彩和符印语法与 UI / prop 资产一致。
- 符纸上仍有抽象符印细节；正式版需要确认没有可读文字，并统一每个物件的像素尺寸、描边粗细和 pickup glow。
- 当前只能作为 equipment atlas 方向预览；不能直接构建 `assets/art/atlases/equipment_pickup_atlas_ai01.png`。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No matching image_gen PNG found. One unrelated Temp JPEG icon was detected and rejected.
```

### vfx_combat_atlas_ai01

- Batch: `Batch 10`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-10-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/vfx/atlases/vfx_combat_atlas_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `vfx_combat_atlas_ai01`

Visual review:

- 战斗 VFX 帧组方向成立，slash arc、hit spark、boss impact burst、guard break flash、pickup sparkle 和 warning pulse 都能区分。
- cyan-white spiritual energy、vermilion talisman spark、ink-brush motion 和 miasma impact accent 统一到当前项目特效语法。
- 正式版需要拆成稳定帧组、去除多余符纸伪字、降低粒子噪声，并确保每组 VFX 的锚点和播放时长可控。
- 当前只能作为 combat VFX atlas 方向预览；不能直接构建 `assets/art/vfx/atlases/vfx_combat_atlas_ai01.png` 或 `SpriteFrames`。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No matching image_gen PNG found. One unrelated Temp JPEG icon was detected and rejected.
```

### seal_guardian_spine_parts_ai01

- Batch: `Batch 11`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-11-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/spine_parts/seal_guardian_spine_parts_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `seal_guardian_spine_parts_ai01`

Visual review:

- Seal Guardian 拆件方向很强，beast-mask head、stone torso core、shoulders、arms、claws、chains、talisman locks、armor plates、seal core 和 miasma fragments 都有可切分意图。
- 部件分离度适合后续作为 Spine-style rigging 或 Boss 手工拆件参考，并且与已有 Seal Guardian boss sheet 风格一致。
- 正式版必须清除锁牌 / 符纸上的类文字纹样，统一 pivot、层级顺序、左右肢体命名和遮挡关系。
- 当前只能作为 boss cutout parts 方向预览；不能直接构建 `assets/art/spine_parts/seal_guardian_spine_parts_ai01.png` 或接入骨骼动画。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 20 --limit 10
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No matching image_gen PNG found. One unrelated Temp JPEG icon was detected and rejected.
```

### capsule_art_alpha_demo_ai01

- Batch: `Batch 12`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-12-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/promo/capsule_art_alpha_demo_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `capsule_art_alpha_demo_ai01`

Visual review:

- Alpha Demo capsule art 方向成立，Luna、Seal Guardian、佛门封印链、瘴泽雾气和古刹遗构能在小尺寸宣传图中读出游戏题材。
- 画面整体比 key art 更偏商店 capsule / 宣传横幅，适合作为后续 Steam capsule、itch.io header 或 trailer still 的构图参考。
- 标题安全区和负空间仍需重排，正式版要避免把角色、Boss 轮廓和标题区互相挤压。
- 当前只能作为 capsule art 方向预览；不能直接构建 `assets/art/promo/capsule_art_alpha_demo_ai01.png` 或用于对外发布。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No matching image_gen PNG found. One unrelated Temp JPEG icon was detected and rejected.
```

### cg_seal_guardian_reveal_ai01

- Batch: `Batch 12`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-12-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/promo/cg_seal_guardian_reveal_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `cg_seal_guardian_reveal_ai01`

Visual review:

- Boss reveal CG 方向很强，Seal Guardian 的体量、封印链、石面兽首、胸口封印核和瘴气压迫感清楚。
- 适合作为 Boss 入场 CG、宣传截图或 trailer 定帧参考，并能和现有 Boss sprite / 拆件方向保持一致。
- 符纸和锁牌上仍有类文字纹样；正式版必须清理为不可读符印或手工重绘。
- 当前只能作为 CG 方向预览；不能直接构建 `assets/art/promo/cg_seal_guardian_reveal_ai01.png` 或接入剧情演出。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No matching image_gen PNG found. One unrelated Temp JPEG icon was detected and rejected.
```

### storyboard_intro_bounty_ai01

- Batch: `Batch 13`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-13-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/storyboards/storyboard_intro_bounty_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `storyboard_intro_bounty_ai01`

Visual review:

- 六格 intro bounty 分镜节奏清楚，能表达 Luna 接受镇妖赏金、穿过山门、发现符印腐化、进入瘴泽禁地的前情。
- 适合作为剧情演出、trailer 开场和 demo 引导的镜头参考。
- 赏金文书和符纸上有明显伪文字；正式版必须改成无文字图形、可控符号或另行排版真实 UI 字。
- 当前只能作为 storyboard 方向预览；不能直接构建 `assets/art/storyboards/storyboard_intro_bounty_ai01.png`。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No matching image_gen PNG found. One unrelated Temp JPEG icon was detected and rejected.
```

### storyboard_miasma_marsh_ai01

- Batch: `Batch 13`
- Prompt source: `docs/implementation-plans/2026-06-19-imagegen-batch-13-production-packet.md`
- Queue source: `docs/assets/image-gen-prompt-queue.json`
- Target path: `assets/art/storyboards/storyboard_miasma_marsh_ai01.png`
- Status: `preview_generated`
- Local file status: not detected
- Import status: not imported
- Atlas output id: `storyboard_miasma_marsh_ai01`

Visual review:

- 瘴泽分镜可读性很好，毒水、断裂封印石、relay 符桩、封印门开启和路径显现等关卡教学信息明确。
- 适合作为 `biome_02_miasma_marsh` 的关卡引导、环境叙事和 trailer 过场参考。
- 正式版需要统一镜头比例、清理符纸伪字，并把可玩信息和剧情镜头分开整理。
- 当前只能作为 storyboard 方向预览；不能直接构建 `assets/art/storyboards/storyboard_miasma_marsh_ai01.png`。

Commands / evidence:

```powershell
python scripts/assets/import_imagegen_outputs.py --since-minutes 120 --limit 30 --include-codex-home --include-temp
```

Result:

```text
No matching image_gen PNG found. One unrelated Temp JPEG icon was detected and rejected.
```

## 2026-06-19 - Batch03 Default Directory Recovery

- Default directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Queue status: 当前 queue 已从 `39` 项扩展到 `44` 项，其中 `23` 项为 atlas-linked outputs。
- Local file status: `5/5` Batch03 PNG copied to `assets/source/ai_generated/batch_03/<asset_id>/candidates/<asset_id>_candidate_01.png`。
- Import status: `godot --headless --path . --import` passed; `assets/art/**/*.png` 与 `.png.import` 均为 `44`。

Mapped assets:

- `ig_03247622dcb9f17c016a35364007e4819b804c6587e3fd97d1.png` -> `biome01_shrine_trial_tiles_ai01`
- `ig_03247622dcb9f17c016a35369469ac819b9055e6723f13b3d2.png` -> `biome01_shrine_trial_background_ai01`
- `ig_03247622dcb9f17c016a3536e4de4c819b8615cf38b061e9be.png` -> `biome02_miasma_marsh_tiles_ai01`
- `ig_03247622dcb9f17c016a3537397fac819b9e8d7f3ee81cb76e.png` -> `biome02_miasma_marsh_background_ai01`
- `ig_03247622dcb9f17c016a35378b99ac819bb2ce081bd0dfe5fd.png` -> `reusable_seal_props_ai01`

## 2026-06-19 - Batch06 Supplemental Animation Coverage

- Default directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Queue status: 当前 queue 已从 `44` 项扩展到 `47` 项，其中 `26` 项为 atlas-linked outputs。
- Local file status: `3/3` supplemental Batch06 PNG copied to `assets/source/ai_generated/batch_06/<asset_id>/candidates/<asset_id>_candidate_01.png`。
- Import status: `godot --headless --path . --import` passed; `assets/art/**/*.png` 与 `.png.import` 均为 `47`。

Mapped assets:

- `ig_03256ebf80d66dc1016a353bb4e854819bbe29f362cda6c6be.png` -> `luna_jump_fall_sheet_ai01`
- `ig_03256ebf80d66dc1016a353c6d8c94819bb3f5a090a19afaee.png` -> `luna_hit_death_sheet_ai01`
- `ig_03256ebf80d66dc1016a353cdf7b00819b81c53110915cf00e.png` -> `enemies_core_sheet_ai01`

Visual review:

- `luna_jump_fall_sheet_ai01` has usable silhouette continuity, but landing / idle-like frames need ordering cleanup.
- `luna_hit_death_sheet_ai01` is readable and non-gory, but detail density should be simplified before gameplay-scale integration.
- `enemies_core_sheet_ai01` gives distinct melee / charger / aerial / caster silhouettes, but must be split by enemy type and action before runtime use.

## 2026-06-19 - Batch03 Supplemental Room Backgrounds

- Default directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Queue status: 当前 queue 已从 `47` 项扩展到 `51` 项，其中 `26` 项为 atlas-linked outputs。
- Local file status: `4/4` supplemental Batch03 PNG copied to `assets/source/ai_generated/batch_03/<asset_id>/candidates/<asset_id>_candidate_01.png`。
- Import status: `godot --headless --path . --import` passed; `assets/art/**/*.png` 与 `.png.import` 均为 `51`。

Mapped assets:

- `ig_03256ebf80d66dc1016a354335466c819bbcb4080cfb6fbfda.png` -> `biome01_shrine_trial_room_parallax_ai01`
- `ig_03256ebf80d66dc1016a354380fcb8819b9494d9f86dfbef6b.png` -> `biome01_air_dash_shrine_room_ai01`
- `ig_03256ebf80d66dc1016a3543c48908819b84d8370785253157.png` -> `biome02_miasma_hazard_room_ai01`
- `ig_03256ebf80d66dc1016a35440b2eec819ba7b90eca0fe680c0.png` -> `stage15_seal_guardian_boss_room_ai01`

Visual review:

- `biome01_shrine_trial_room_parallax_ai01` has strong room staging and clear center lane; edge chains should be darkened or cropped before use.
- `biome01_air_dash_shrine_room_ai01` leaves a usable shrine placement zone; large shrine / statue details need contrast control.
- `biome02_miasma_hazard_room_ai01` separates safe ground and hazard water better than the broad miasma background.
- `stage15_seal_guardian_boss_room_ai01` has a readable arena floor, but the background beast mask must be dimmed so it does not compete with the actual boss.

## 2026-06-19 - Batch08 Supplemental UI Panels

- Default directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Queue status: 当前 queue 已从 `51` 项扩展到 `55` 项，其中 `26` 项为 atlas-linked outputs。
- Local file status: `4/4` supplemental Batch08 PNG copied to `assets/source/ai_generated/batch_08/<asset_id>/candidates/<asset_id>_candidate_01.png`。
- Import status: `godot --headless --path . --import` passed; `assets/art/**/*.png` 与 `.png.import` 均为 `55`。

Mapped assets:

- `ig_03256ebf80d66dc1016a355b1b5c08819ba2b067a558a32728.png` -> `stage16_pause_panel_ui_ai01`
- `ig_03256ebf80d66dc1016a355b695c48819ba940eccd6b5cf2f0.png` -> `stage16_completion_panel_ui_ai01`
- `ig_03256ebf80d66dc1016a355bbfe2cc819b9378f4421162b83f.png` -> `stage15_boss_hud_frame_ai01`
- `ig_03256ebf80d66dc1016a355bf8e8dc819bbacc1fef9491c517.png` -> `stage14_ability_status_hud_ai01`

Visual review:

- `stage16_pause_panel_ui_ai01` has a usable shrine-panel layout with a central empty zone for later real UI text; decorative talisman marks must be cleaned before final use.
- `stage16_completion_panel_ui_ai01` fits Alpha Demo completion feedback and leaves a strong message area; gold / vermilion detail needs contrast tuning for 640x360.
- `stage15_boss_hud_frame_ai01` reads as a long Seal Guardian boss-status frame; it still needs a proper health-mask region and runtime contrast review.
- `stage14_ability_status_hud_ai01` gives clear icon sockets for Air Dash / Recovery-style state display; it should be simplified before small HUD use.

Transparency check:

- `stage16_pause_panel_ui_ai01`: size `1536x1024`, corner alpha values are `0`, transparent pixels `689375`, opaque green pixels `0`.
- `stage16_completion_panel_ui_ai01`: size `1536x1024`, corner alpha values are `0`, transparent pixels `705364`, opaque green pixels `0`.
- `stage15_boss_hud_frame_ai01`: size `2172x724`, corner alpha values are `0`, transparent pixels `1084900`, opaque green pixels `0`.
- `stage14_ability_status_hud_ai01`: size `1536x1024`, corner alpha values are `0`, transparent pixels `1147641`, opaque green pixels `0`.

Boundary:

- These UI panels are `placeholder_ready` only. They are not wired into DemoShell, Stage15 Boss HUD or Stage14 ability HUD.
- The green-looking background in some image viewers is transparent RGB residue from the chroma-key pass, not an opaque green screen; Godot import keeps the PNG alpha.
