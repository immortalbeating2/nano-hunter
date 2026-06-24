# Nano Hunter Image Gen Session Recovery Log

Last Updated: 2026-06-20

## 用途

本文件记录从 Codex Desktop 会话 JSONL 中恢复内置 `image_gen` 结果的证据与边界。它只证明原始 PNG 候选已经落盘到本地候选区，不等于资产已经清稿、切片、图集化、导入 Godot 或接入游戏。

## 多项目并行安全规则

当多个项目同时使用 Codex Desktop `image_gen` 时，`C:\Users\peng8\.codex\generated_images` 不是项目专属目录，不能把“最近修改的 PNG”自动视为 Nano Hunter 资产。导入 Nano Hunter 前必须满足至少一个条件：

- 使用明确的 Nano Hunter session JSONL，并由 `scripts/assets/Export-NanoHunterImageGenResults.ps1` 的项目路径过滤或 `-SessionPath` 指定来源。
- 使用人工检查过的具体 `--source <png>` 路径。
- 使用带 `image_id`、`batch`、`asset_id` 的 import map。

`scripts/assets/import_imagegen_outputs.py --copy-latest` 已默认拒绝从全局 `generated_images` 直接复制最新图；只有人工确认图片归属后，才允许加 `--allow-global-latest`。

## 2026-06-20 - Multi-project import safety correction

### 背景

复核当前会话落盘方式时，发现全局 `C:\Users\peng8\.codex\generated_images` 同时包含 Nano Hunter 与其它项目 / 会话的 PNG。曾短暂按“最新 PNG”将 `5` 张图复制为 Nano Hunter raw candidates，但该判定不能证明项目归属。

### 修正

已删除本次误导入的 `5` 个候选副本：

- `assets/source/ai_generated/batch_06/luna_run_sheet_ai01/candidates/luna_run_sheet_ai01_candidate_05.png`
- `assets/source/ai_generated/batch_11/seal_guardian_spine_parts_ai01/candidates/seal_guardian_spine_parts_ai01_candidate_09.png`
- `assets/source/ai_generated/batch_06/seal_guardian_boss_sheet_ai01/candidates/seal_guardian_boss_sheet_ai01_candidate_03.png`
- `assets/source/ai_generated/batch_11/luna_spine_parts_ai01/candidates/luna_spine_parts_ai01_candidate_04.png`
- `assets/source/ai_generated/batch_06/luna_attack_01_sheet_ai01/candidates/luna_attack_01_sheet_ai01_candidate_05.png`

同时加固 `scripts/assets/import_imagegen_outputs.py`：默认阻止从全局 `generated_images` 执行 `--copy-latest`，要求改用明确 `--source`、明确 session 恢复或显式 `--allow-global-latest`。

### 边界

- 原始全局 `.codex/generated_images` 文件未删除。
- 没有修改 `assets/art/` 可接入资产。
- 没有重建 selected sources、atlas、SpriteFrames、TileSet 或 runtime catalog。
- 本次只修正导入安全边界，不把任何新图认定为 Nano Hunter 资产。

## 2026-06-20 - Generated images directory recovery to raw candidates

### 来源

- Source root: `C:\Users\peng8\.codex\generated_images`
- Source folders:
  - `019eb737-d207-7e73-8178-9af9f1516c34`
  - `019edfaf-11b3-76c1-9662-00e5c5b15964`
  - `019ea2b0-ce9b-7f71-ad7b-d17335be8ad3`
- Recovery method: 从 Codex Desktop 默认生成图目录读取 2026-06-20 下午新增 PNG，先哈希比对确认未进入 `assets/source/ai_generated/`、`assets/art/` 或 `assets/source/imagegen_inbox/`，再按视觉内容保守映射到现有 Batch raw candidate 目录。

### 输出

- Full inbox copy:

```text
assets/source/imagegen_inbox/recovered-2026-06-20-current-thread/
```

- Ledger:

```text
assets/source/imagegen_inbox/recovered-2026-06-20-current-thread/recovery-ledger.json
```

- 恢复数量：`30`
- 写入方式：
  - `30` 张完整原图复制到 inbox。
  - `30` 张按现有资产队列复制为下一个 raw candidate 编号。
  - 未覆盖已有 candidate、未覆盖 `assets/art/` 输出、未替换场景 / HUD / VFX / SpriteFrames 引用。

### 映射摘要

| Batch | Asset IDs | Added candidates |
| --- | --- | ---: |
| Batch 06 | `luna_run_sheet_ai01`, `luna_air_dash_sheet_ai01`, `luna_attack_01_sheet_ai01`, `luna_idle_sheet_ai01`, `luna_jump_fall_sheet_ai01`, `luna_hit_death_sheet_ai01`, `enemies_core_sheet_ai01` | 10 |
| Batch 08 | `icon_sheet_core_ai01`, `hud_core_ui_atlas_ai01` | 5 |
| Batch 09 | `equipment_pickup_atlas_ai01`, `shrine_gate_prop_atlas_ai01` | 4 |
| Batch 10 | `vfx_combat_atlas_ai01`, `vfx_seal_magic_atlas_ai01` | 3 |
| Batch 11 | `luna_spine_parts_ai01`, `seal_guardian_spine_parts_ai01` | 8 |

### 验证

```powershell
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\audit_asset_target_coverage.py --strict
godot --headless --path . --import
```

结果：

- Ledger 记录 `30` items；所有 `inbox_path` 与 `candidate_path` 均存在。
- `30/30` inbox PNG 与 `30/30` raw candidate PNG 均可由 Pillow 打开校验。
- `validate_asset_production_queue.py` 通过：`55` items、`26` atlas-linked outputs。
- `audit_asset_target_coverage.py --strict` 通过：`26/26` atlas-linked outputs，duplicates 均为 `0`。
- `godot --headless --path . --import` 退出码为 `0`，新增 raw candidates 成功进入 Godot import 缓存。

### 边界

- 这批映射的 `mapping_confidence` 统一记录为 `review_required`；它们是候选补充，不是正式选中源图。
- 当前没有重跑 `prepare_selected_sources.py` 或 `build_asset_atlases.py`，因此 `assets/art/` 输出仍保持上一轮通过审计的版本。
- 后续若要使用这些新增候选，需要按资产类型人工挑选，再执行 selected source 准备、atlas rebuild、art readiness / package audit 和对应 Godot 复核。

## 2026-06-20 - Project-filtered session recovery to imagegen inbox

### 来源

- Source session: `C:\Users\peng8\.codex\sessions\2026\04\29\rollout-2026-04-29T16-28-19-019dd85a-7144-7b63-924f-979212c1d613.jsonl`
- Source cwd: `C:\Users\peng8\.codex\worktrees\3073\nano-hunter`
- Source fields: `image_generation_call.result`
- Recovery method: 先使用全局恢复脚本从 Codex Desktop session JSONL 解码 PNG，再按 session id 过滤出当前 `nano-hunter` worktree 的图像。

### 输出

- Project-filtered inbox:

```text
assets/source/imagegen_inbox/recovered-nano-hunter-session/
```

- 恢复数量：`84`
- 哈希比对结果：
  - `71` 张已能在 `assets/source/ai_generated/` 或 `assets/art/` 中找到同哈希副本。
  - `13` 张暂未找到可靠 `asset_id` / batch 映射，保留在 inbox 待人工分拣。
- 清理边界：
  - 本次曾短暂执行全会话宽扫到 `assets/source/imagegen_inbox/recovered-all-sessions/`。
  - 宽扫产生的 `332` 个跨项目 `rollout-*.png` 副本已删除。
  - 已存在的 indexed 恢复文件未删除。

### 验证

```powershell
& 'C:\Users\peng8\Documents\Codex\tools\imagegen-export\Export-CodexImageGenResults.ps1' -TodayOnly -OutDir 'C:\Users\peng8\.codex\worktrees\3073\nano-hunter\assets\source\imagegen_inbox\recovered-2026-06-20'
& 'C:\Users\peng8\Documents\Codex\tools\imagegen-export\Export-CodexImageGenResults.ps1' -OutDir 'C:\Users\peng8\.codex\worktrees\3073\nano-hunter\assets\source\imagegen_inbox\recovered-all-sessions'
.\scripts\assets\Export-NanoHunterImageGenResults.ps1 -TodayOnly -DryRun
.\scripts\assets\Export-NanoHunterImageGenResults.ps1 -SessionPath "$env:USERPROFILE\.codex\sessions\2026\04\29\rollout-2026-04-29T16-28-19-019dd85a-7144-7b63-924f-979212c1d613.jsonl" -DryRun
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\audit_asset_target_coverage.py --strict
```

结果：

- 2026-06-20 当日 session 目录没有新的 `image_generation_call.result` 输出，`TodayOnly` 恢复数量为 `0`。
- 全会话扫描可恢复历史 `image_gen` PNG；项目过滤后当前 `nano-hunter` session 为 `84` 张。
- 项目内恢复脚本 `scripts/assets/Export-NanoHunterImageGenResults.ps1` 已可复用；默认恢复到 `assets/source/imagegen_inbox/recovered-nano-hunter-session/`，传入 `-ImportMap` 时可按 `image_id`、`batch`、`asset_id` 映射到 `assets/source/ai_generated/batch_XX/<asset_id>/candidates/`。
- `validate_asset_production_queue.py` 通过：`55` items、`26` atlas-linked outputs。
- `audit_asset_target_coverage.py --strict` 通过：`26/26` atlas-linked outputs 均满足 target count 且 `duplicates=0`。

### 边界

- `assets/source/imagegen_inbox/**` 按 `.gitignore` 默认不进入普通 Git。
- `recovered-nano-hunter-session/` 是本地恢复 / 待分拣区，不是正式资产目录。
- 只有已进入 `assets/source/ai_generated/batch_XX/<asset_id>/...` 或 `assets/art/...` 的图像才视为进入当前项目资产生产链。
- 未匹配的 `13` 张不能自动归入 batch；需要人工确认用途、风格和授权记录后再导入。

## 2026-06-19 - 当前会话 PNG 恢复

### 来源

- Source session: `C:\Users\peng8\.codex\sessions\2026\04\29\rollout-2026-04-29T16-28-19-019dd85a-7144-7b63-924f-979212c1d613.jsonl`
- Source fields: `image_generation_call.result`
- Mapping source: `docs/assets/image-gen-prompt-queue.json`
- Recovery method: 按当前项目的 `asset_id` 与已确认的 `image_generation_call.id` 映射解码 base64 PNG，并写入对应 Batch 候选目录。

### 结果

- 恢复数量：`33/33`
- 缺失数量：`0`
- 输出位置：

```text
assets/source/ai_generated/batch_XX/<asset_id>/candidates/<asset_id>_candidate_01.png
```

- 本地恢复摘要：

```text
assets/source/ai_generated/session_recovery_2026-06-19.json
```

该摘要文件位于 `assets/source/ai_generated/` 下，按资产存储策略默认不进入普通 Git。

### 已恢复批次

| Batch | Count | Asset IDs |
| --- | ---: | --- |
| Batch 00 | 1 | `style_board_global_ai01` |
| Batch 01 | 8 | `stage16_luna_player_readability_ai01`, `stage14_air_dash_icon_ai01`, `stage14_air_dash_trail_ai01`, `stage14_air_dash_shrine_ai01`, `stage14_air_dash_gate_ai01`, `stage15_seal_guardian_ai01`, `stage15_boss_attack_warning_ai01`, `stage15_recovery_charge_icon_ai01` |
| Batch 06 | 5 | `luna_run_sheet_ai01`, `luna_air_dash_sheet_ai01`, `luna_attack_01_sheet_ai01`, `luna_idle_sheet_ai01`, `seal_guardian_boss_sheet_ai01` |
| Batch 07 | 3 | `miasma_marsh_tileset_ai01`, `shrine_trial_tileset_ai01`, `material_texture_atlas_ai01` |
| Batch 08 | 3 | `hud_core_ui_atlas_ai01`, `icon_sheet_core_ai01`, `menu_ninepatch_ui_ai01` |
| Batch 09 | 2 | `shrine_gate_prop_atlas_ai01`, `equipment_pickup_atlas_ai01` |
| Batch 10 | 2 | `vfx_seal_magic_atlas_ai01`, `vfx_combat_atlas_ai01` |
| Batch 11 | 2 | `luna_spine_parts_ai01`, `seal_guardian_spine_parts_ai01` |
| Batch 12 | 4 | `promo_key_art_sheet_ai01`, `nano_hunter_logo_direction_ai01`, `capsule_art_alpha_demo_ai01`, `cg_seal_guardian_reveal_ai01` |
| Batch 13 | 3 | `storyboard_narrative_sheet_ai01`, `storyboard_intro_bounty_ai01`, `storyboard_miasma_marsh_ai01` |

### 验证

```powershell
python - <<'PY'
from pathlib import Path
from PIL import Image
rows = []
for path in sorted(Path("assets/source/ai_generated").rglob("*_candidate_01.png")):
    with Image.open(path) as img:
        rows.append((path, img.size, img.mode))
print(len(rows))
PY
```

结果：`33` 个候选 PNG 均可由 Pillow 打开并读取尺寸。

抽查结论：

- `style_board_global_ai01` 可作为全局风格板候选。
- `stage16_luna_player_readability_ai01` 是绿幕背景角色方向稿，后续必须去背景、清边和重新评估缩放读值，不能直接作为透明 sprite 接入。

### 边界

- 这些 PNG 是原始候选，不是最终 `assets/art/` 可运行资产。
- 当前不自动复制到 `selected_frames/` 或 `selected_items/`；需要人工筛选、切图、清稿、去文字、去背景或重排后再进入图集构建。
- 当前不更新 `asset-manifest.md` 为 `integrated`。
- 当前不运行 Godot import；只有候选被整理成可接入资产并进入 `assets/art/` 后再执行。

## 2026-06-19 - 第一版 selected 源图、standalone 资产与 Godot 候选图集

### 操作

从已恢复的 raw candidates 继续执行：

```powershell
python scripts\assets\prepare_selected_sources.py --overwrite
python scripts\assets\export_standalone_candidates.py --overwrite
python scripts\assets\build_asset_atlases.py --dry-run --strict
python scripts\assets\build_asset_atlases.py
godot --headless --path . --import
```

### 结果

- `selected_frames`: `88`
- `selected_items`: `52`
- `selected_tiles`: `32`
- `selected_parts`: `24`
- `selected_panels`: `18`
- standalone PNG: `10`
- `assets/art/**/*.png`: `33`
- `assets/art/**/*_ai01.png.import`: `33`
- `assets/art/**/*.json`: `23`
- `assets/art/**/*.spriteframes.tres`: `7`

### 验证

- `python scripts\assets\build_asset_atlases.py --dry-run --strict` 通过最低构建门槛，所有 atlas-linked 输出为 `minimum satisfied`。
- `python scripts\assets\build_asset_atlases.py` 成功生成第一版候选 sheet / atlas。
- `python scripts\assets\export_standalone_candidates.py --overwrite` 成功导出 Batch00 / Batch01 / logo direction 的 `10` 张 standalone PNG。
- `godot --headless --path . --import` 退出码为 `0`，新生成 PNG 已被 Godot reimport；新增 standalone PNG 单独触发 `10` 个 reimport step。

### 边界

- 当前输出只满足 `expected_min`，未达到 `expected_target`。
- `luna_run_sheet_ai01` 使用自动 duplicate 补足最低帧数，后续需要补生成或人工绘制完整过渡帧。
- TileSet、Promo、CG 和 Storyboard 类输出含自动网格裁切痕迹，后续需要人工清稿、重切和语义命名。
- 当前产物可作为 Godot 编辑器预览与后续接入候选，不标记为最终商业品质资产。

## 2026-06-19 - Batch02 默认目录复制与 standalone 导出

### 来源

- Default image directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Source files:
  - `ig_03247622dcb9f17c016a3526744cd8819b9dc7fd66b0f0002b.png` -> `stage16_title_background_ai01`
  - `ig_03247622dcb9f17c016a3526b979f8819bb27397db11dfaf43.png` -> `stage16_demo_menu_icons_ai01`
  - `ig_03247622dcb9f17c016a3526f5e294819b91c65826d3f95f98.png` -> `stage16_seal_release_threshold_ai01`
  - `ig_03247622dcb9f17c016a3527375858819ba4bbe6ee5847ad82.png` -> `stage16_talisman_relay_ai01`
  - `ig_03247622dcb9f17c016a35277889b8819baf125401cba989d7.png` -> `stage16_corruption_purge_ai01`
  - `ig_03247622dcb9f17c016a3527bcf808819bb7586e8388808343.png` -> `stage16_alpha_demo_completion_ai01`

### 输出

- Raw candidates:
  - `assets/source/ai_generated/batch_02/<asset_id>/candidates/<asset_id>_candidate_01.png`
- Standalone `assets/art` outputs:
  - `assets/art/ui/stage16_title_background_ai01.png`
  - `assets/art/ui/stage16_demo_menu_icons_ai01.png`
  - `assets/art/props/stage16_seal_release_threshold_ai01.png`
  - `assets/art/vfx/stage16_talisman_relay_ai01.png`
  - `assets/art/vfx/stage16_corruption_purge_ai01.png`
  - `assets/art/ui/stage16_alpha_demo_completion_ai01.png`

### 验证

- `python scripts\assets\validate_asset_production_queue.py` 通过：`39` items、`23` atlas-linked outputs。
- `python scripts\assets\export_standalone_candidates.py --overwrite` 成功导出全部 standalone，其中包括 Batch02 `6` 张。
- `godot --headless --path . --import` 退出码为 `0`，Batch02 输出触发 reimport。
- 当前 `assets/art/**/*.png` 总数为 `39`。
- 当前 `assets/art/**/*.png.import` 总数为 `39`。

### 边界

- Batch02 当前为 `placeholder_ready`，不是 `integrated`。
- `stage16_title_background_ai01` 的符纸存在伪文字，正式接入前需清理。
- `stage16_demo_menu_icons_ai01` 需要小尺寸读值复核。
- `stage16_talisman_relay_ai01` 与 `stage16_corruption_purge_ai01` 仍需拆帧、锚点和 VFX atlas 整理。

## 2026-06-19 - Batch03 default image directory copy and standalone export

### Source

- Default image directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Source files:
  - `ig_03247622dcb9f17c016a35364007e4819b804c6587e3fd97d1.png` -> `biome01_shrine_trial_tiles_ai01`
  - `ig_03247622dcb9f17c016a35369469ac819b9055e6723f13b3d2.png` -> `biome01_shrine_trial_background_ai01`
  - `ig_03247622dcb9f17c016a3536e4de4c819b8615cf38b061e9be.png` -> `biome02_miasma_marsh_tiles_ai01`
  - `ig_03247622dcb9f17c016a3537397fac819b9e8d7f3ee81cb76e.png` -> `biome02_miasma_marsh_background_ai01`
  - `ig_03247622dcb9f17c016a35378b99ac819bb2ce081bd0dfe5fd.png` -> `reusable_seal_props_ai01`

### Outputs

- Raw candidates:
  - `assets/source/ai_generated/batch_03/<asset_id>/candidates/<asset_id>_candidate_01.png`
- Standalone `assets/art` outputs:
  - `assets/art/environment/biome_01_shrine_trial/biome01_shrine_trial_tiles_ai01.png`
  - `assets/art/environment/biome_01_shrine_trial/biome01_shrine_trial_background_ai01.png`
  - `assets/art/environment/biome_02_miasma_marsh/biome02_miasma_marsh_tiles_ai01.png`
  - `assets/art/environment/biome_02_miasma_marsh/biome02_miasma_marsh_background_ai01.png`
  - `assets/art/props/reusable_seal_props_ai01.png`

### Verification

- `python scripts\assets\validate_asset_production_queue.py` passed: `44` items, `23` atlas-linked outputs.
- `python scripts\assets\export_standalone_candidates.py --overwrite` exported all standalone candidates, including Batch03 `5` PNG files.
- `godot --headless --path . --import` exited `0`; Batch03 source candidates and standalone outputs were imported.
- Current `assets/art/**/*.png` count is `44`.
- Current `assets/art/**/*.png.import` count is `44`.

### Boundary

- Batch03 is currently `placeholder_ready`, not `integrated`.
- Tile sheets still need manual slicing, tile semantics, collision readability, scale cleanup and background parallax review before scene replacement.

## 2026-06-19 - Batch06 supplemental animation coverage default directory copy

### Source

- Default image directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Source files:
  - `ig_03256ebf80d66dc1016a353bb4e854819bbe29f362cda6c6be.png` -> `luna_jump_fall_sheet_ai01`
  - `ig_03256ebf80d66dc1016a353c6d8c94819bb3f5a090a19afaee.png` -> `luna_hit_death_sheet_ai01`
  - `ig_03256ebf80d66dc1016a353cdf7b00819b81c53110915cf00e.png` -> `enemies_core_sheet_ai01`

### Outputs

- Raw candidates:
  - `assets/source/ai_generated/batch_06/<asset_id>/candidates/<asset_id>_candidate_01.png`
- Selected frames:
  - `assets/source/ai_generated/batch_06/<asset_id>/selected_frames/<asset_id>_auto_*.png`
- Godot sheet outputs:
  - `assets/art/characters/player/sprite_sheets/luna_jump_fall_sheet_ai01.png`
  - `assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.png`
  - `assets/art/characters/enemies/sprite_sheets/enemies_core_sheet_ai01.png`
  - corresponding `.frames.json` and `.spriteframes.tres`

### Verification

- `python scripts\assets\validate_asset_production_queue.py` passed: `47` items, `26` atlas-linked outputs.
- `python scripts\assets\prepare_selected_sources.py --only <asset_id> --overwrite` prepared `16/16` selected frames for each supplemental sheet.
- `python scripts\assets\build_asset_atlases.py --only <asset_id>` wrote all three sheet PNGs, frames JSON files and SpriteFrames resources.
- `godot --headless --path . --import` exited `0`; new sheet outputs, source candidates and selected frames were imported.
- Current `assets/art/**/*.png` count is `47`.
- Current `assets/art/**/*.png.import` count is `47`.

### Boundary

- Batch06 supplemental is currently `placeholder_ready`, not `integrated`.
- Luna jump/fall frame ordering, Luna hit/death style simplification, and core enemy row splitting still require manual cleanup before runtime use.

## 2026-06-19 - Batch03 supplemental room backgrounds default directory copy

### Source

- Default image directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Source files:
  - `ig_03256ebf80d66dc1016a354335466c819bbcb4080cfb6fbfda.png` -> `biome01_shrine_trial_room_parallax_ai01`
  - `ig_03256ebf80d66dc1016a354380fcb8819b9494d9f86dfbef6b.png` -> `biome01_air_dash_shrine_room_ai01`
  - `ig_03256ebf80d66dc1016a3543c48908819b84d8370785253157.png` -> `biome02_miasma_hazard_room_ai01`
  - `ig_03256ebf80d66dc1016a35440b2eec819ba7b90eca0fe680c0.png` -> `stage15_seal_guardian_boss_room_ai01`

### Outputs

- Raw candidates:
  - `assets/source/ai_generated/batch_03/<asset_id>/candidates/<asset_id>_candidate_01.png`
- Standalone `assets/art` outputs:
  - `assets/art/environment/biome_01_shrine_trial/biome01_shrine_trial_room_parallax_ai01.png`
  - `assets/art/environment/biome_01_shrine_trial/biome01_air_dash_shrine_room_ai01.png`
  - `assets/art/environment/biome_02_miasma_marsh/biome02_miasma_hazard_room_ai01.png`
  - `assets/art/environment/boss_rooms/stage15_seal_guardian_boss_room_ai01.png`

### Verification

- `python scripts\assets\validate_asset_production_queue.py` passed: `51` items, `26` atlas-linked outputs.
- `python scripts\assets\export_standalone_candidates.py --only <asset_id> --overwrite` exported all four room/background PNG files.
- `godot --headless --path . --import` exited `0`; new room backgrounds and source candidates were imported.
- Current `assets/art/**/*.png` count is `51`.
- Current `assets/art/**/*.png.import` count is `51`.

### Boundary

- Batch03 supplemental room backgrounds are currently `placeholder_ready`, not `integrated`.
- Room backgrounds still need brightness pass, layer split, parallax configuration and scene reference replacement before runtime use.

## 2026-06-19 - Batch08 supplemental UI panels default directory copy

### Source

- Default image directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Source files:
  - `ig_03256ebf80d66dc1016a355b1b5c08819ba2b067a558a32728.png` -> `stage16_pause_panel_ui_ai01`
  - `ig_03256ebf80d66dc1016a355b695c48819ba940eccd6b5cf2f0.png` -> `stage16_completion_panel_ui_ai01`
  - `ig_03256ebf80d66dc1016a355bbfe2cc819b9378f4421162b83f.png` -> `stage15_boss_hud_frame_ai01`
  - `ig_03256ebf80d66dc1016a355bf8e8dc819bbacc1fef9491c517.png` -> `stage14_ability_status_hud_ai01`

### Outputs

- Raw candidates:
  - `assets/source/ai_generated/batch_08/<asset_id>/candidates/<asset_id>_candidate_01.png`
- Standalone `assets/art` outputs:
  - `assets/art/ui/stage16_pause_panel_ui_ai01.png`
  - `assets/art/ui/stage16_completion_panel_ui_ai01.png`
  - `assets/art/ui/stage15_boss_hud_frame_ai01.png`
  - `assets/art/ui/stage14_ability_status_hud_ai01.png`

### Verification

- `python scripts\assets\validate_asset_production_queue.py` passed: `55` items, `26` atlas-linked outputs.
- `python scripts\assets\export_standalone_candidates.py --only <asset_id> --overwrite` exported all four UI panel PNG files.
- `godot --headless --path . --import` exited `0`; new UI panel outputs and source candidates were imported.
- Current `assets/art/**/*.png` count is `55`.
- Current `assets/art/**/*.png.import` count is `55`.

### Boundary

- Batch08 supplemental UI panels are currently `placeholder_ready`, not `integrated`.
- Pause / completion panels, Boss HUD frame and ability status HUD still need layout slicing, text-safe area review, ninepatch / mask cleanup, small-size readability checks and runtime UI replacement before use.

## 2026-06-19 - Target-count atlas rebuild from recovered candidates

### Source

- Reused existing recovered image gen candidates under `assets/source/ai_generated/batch_XX/<asset_id>/candidates/<asset_id>_candidate_01.png`.
- No new raw image generation was required in this step.

### Outputs

- Rebuilt selected sources to `expected_target`:
  - `selected_frames`: `236`
  - `selected_items`: `122`
  - `selected_tiles`: `96`
  - `selected_parts`: `48`
  - `selected_panels`: `36`
- Rebuilt all atlas-linked `assets/art` outputs:
  - `26/26` atlas-linked outputs reached `expected_target`.
  - `26` metadata JSON files were updated.
  - `10` SpriteFrames resources were updated.

### Verification

- `python scripts\assets\prepare_selected_sources.py --target target --overwrite` completed.
- `python scripts\assets\build_asset_atlases.py --dry-run --strict` reported every output as `ready with expected_target/expected_target sources`.
- `python scripts\assets\build_asset_atlases.py` rebuilt all PNG, metadata JSON and SpriteFrames outputs.
- `python scripts\assets\audit_asset_target_coverage.py --strict` passed for `26` atlas-linked outputs.
- `godot --headless --path . --import` exited `0` after scanning target-count outputs and ignored selected sources.

### Boundary

- This is a target-count editor-ready rebuild, not final art polish.
- Multiple animation, VFX, prop / equipment, icon and NinePatch outputs still contain duplicate fill frames / items.
- TileSet, Promo, CG and Storyboard sheets still require manual semantic slicing and cleanup.
- The rebuilt outputs remain `placeholder_ready`, not `integrated`.

## 2026-06-20 - Default directory supplemental candidates and duplicate reduction

### Source

- Default image directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Source files:
  - `ig_089a810e5fa4f084016a35699c7240819bb4cc85e8ec183fa7.png` -> `luna_run_sheet_ai01_candidate_02`
  - `ig_089a810e5fa4f084016a356bee5750819b9b1095e70ed0b5fc.png` -> `vfx_combat_atlas_ai01_candidate_02`
  - `ig_089a810e5fa4f084016a356c29253c819b8c14fed4d0a32500.png` -> `enemies_core_sheet_ai01_candidate_02`
  - `ig_089a810e5fa4f084016a356c67be6c819b8098bdb2c2dd77fd.png` -> `shrine_gate_prop_atlas_ai01_candidate_02`
  - `ig_089a810e5fa4f084016a356ca62acc819b9e033db86ee3937b.png` -> `equipment_pickup_atlas_ai01_candidate_02`
  - `ig_089a810e5fa4f084016a356cd4b878819b83561c2b41aa47e6.png` -> `luna_run_sheet_ai01_candidate_03`

### Outputs

- Raw candidates:
  - `assets/source/ai_generated/batch_06/luna_run_sheet_ai01/candidates/luna_run_sheet_ai01_candidate_02.png`
  - `assets/source/ai_generated/batch_10/vfx_combat_atlas_ai01/candidates/vfx_combat_atlas_ai01_candidate_02.png`
  - `assets/source/ai_generated/batch_06/enemies_core_sheet_ai01/candidates/enemies_core_sheet_ai01_candidate_02.png`
  - `assets/source/ai_generated/batch_09/shrine_gate_prop_atlas_ai01/candidates/shrine_gate_prop_atlas_ai01_candidate_02.png`
  - `assets/source/ai_generated/batch_09/equipment_pickup_atlas_ai01/candidates/equipment_pickup_atlas_ai01_candidate_02.png`
  - `assets/source/ai_generated/batch_06/luna_run_sheet_ai01/candidates/luna_run_sheet_ai01_candidate_03.png`
- Rebuilt `assets/art` outputs:
  - `assets/art/characters/player/sprite_sheets/luna_run_sheet_ai01.png`
  - `assets/art/vfx/atlases/vfx_combat_atlas_ai01.png`
  - `assets/art/characters/enemies/sprite_sheets/enemies_core_sheet_ai01.png`
  - `assets/art/atlases/shrine_gate_prop_atlas_ai01.png`
  - `assets/art/atlases/equipment_pickup_atlas_ai01.png`

### Duplicate audit

| Asset ID | Before | After |
| --- | ---: | ---: |
| `luna_run_sheet_ai01` | 12 | 0 |
| `vfx_combat_atlas_ai01` | 17 | 1 |
| `enemies_core_sheet_ai01` | 16 | 0 |
| `shrine_gate_prop_atlas_ai01` | 16 | 0 |
| `equipment_pickup_atlas_ai01` | 13 | 0 |

### Verification

- `python scripts\assets\prepare_selected_sources.py --target target --only <asset_id> --overwrite` completed for all five targets.
- `python scripts\assets\build_asset_atlases.py --only <asset_id>` rebuilt all five outputs.
- `python scripts\assets\audit_asset_target_coverage.py --strict` passed for `26` atlas-linked outputs.

### Boundary

- This pass reduces duplicate fill frames / items; it is still `placeholder_ready`, not `integrated`.
- `vfx_combat_atlas_ai01` still has `1` duplicate and should receive another focused candidate or manual cleanup later.
- Remaining duplicate-heavy outputs include Luna air dash, Luna attack, Luna idle, Luna jump/fall, Luna hit/death, Seal Guardian boss, icon sheet, menu ninepatch and seal magic VFX.

## 2026-06-20 - Default directory duplicate clearance pass

### Source

- Default image directory: `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613`
- Source files:
  - `ig_0af4cabc559d1707016a357020ec74819bb828d57d870fdc45.png` -> `seal_guardian_boss_sheet_ai01_candidate_02`
  - `ig_0af4cabc559d1707016a35705a72e4819b8f8749a7d1e5f014.png` -> `luna_jump_fall_sheet_ai01_candidate_02`
  - `ig_0af4cabc559d1707016a3570a48554819bb4157a14d5f40bce.png` -> `luna_hit_death_sheet_ai01_candidate_02`
  - `ig_0af4cabc559d1707016a3570e7ab9c819b9cc4103cd732993d.png` -> `icon_sheet_core_ai01_candidate_02`
  - `ig_0af4cabc559d1707016a35712043ac819ba58b4a6177d86ee2.png` -> `vfx_seal_magic_atlas_ai01_candidate_02`
  - `ig_0af4cabc559d1707016a35716adfbc819b8b57e755bdfd0166.png` -> `luna_air_dash_sheet_ai01_candidate_02`
  - `ig_0af4cabc559d1707016a3574b510e4819b98842766b5021a30.png` -> `luna_idle_sheet_ai01_candidate_02`
  - `ig_0af4cabc559d1707016a3574e3ee0c819bbc6f28ee2860a565.png` -> `luna_attack_01_sheet_ai01_candidate_02`
  - `ig_0af4cabc559d1707016a3575175f00819bbe4e83e30a056afd.png` -> `menu_ninepatch_ui_ai01_candidate_02`
  - `ig_0af4cabc559d1707016a357553cecc819b967028b9a2906afb.png` -> `vfx_combat_atlas_ai01_candidate_03`

### Outputs

- Rebuilt sprite sheets:
  - `assets/art/characters/enemies/sprite_sheets/seal_guardian_boss_sheet_ai01.png`
  - `assets/art/characters/player/sprite_sheets/luna_air_dash_sheet_ai01.png`
  - `assets/art/characters/player/sprite_sheets/luna_attack_01_sheet_ai01.png`
  - `assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.png`
  - `assets/art/characters/player/sprite_sheets/luna_idle_sheet_ai01.png`
  - `assets/art/characters/player/sprite_sheets/luna_jump_fall_sheet_ai01.png`
- Rebuilt UI / VFX outputs:
  - `assets/art/ui/atlases/icon_sheet_core_ai01.png`
  - `assets/art/ui/menu_ninepatch_ui_ai01.png`
  - `assets/art/vfx/atlases/vfx_combat_atlas_ai01.png`
  - `assets/art/vfx/atlases/vfx_seal_magic_atlas_ai01.png`

### Duplicate audit

All `26/26` atlas-linked outputs now report `duplicates=0`.

### Verification

- `python scripts\assets\prepare_selected_sources.py --target target --only <asset_id> --overwrite` completed for all ten pass 02 targets.
- `python scripts\assets\build_asset_atlases.py --only <asset_id>` rebuilt all ten outputs.
- `python scripts\assets\audit_asset_target_coverage.py --strict` passed and reported `duplicates=0` for all `26` atlas-linked outputs.
- `godot --headless --path . --import` exited `0`.

### Boundary

- This clears duplicate fill frames / items from atlas-linked outputs; it does not prove final art polish.
- Sprite order, Luna consistency, Boss frame semantics, icon readability, NinePatch slice bounds, VFX anchor points and TileSet collision semantics still need manual art review before runtime replacement.
