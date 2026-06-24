# Batch 06 Supplemental Animation Coverage

## Summary

本计划补齐 Batch 06 角色与敌人动画帧中仍缺的三组核心候选：Luna jump / fall、Luna hit / death、基础敌人 roster sheet。它延续现有 Batch 06 管线，不新开独立 Stage，也不改变当前玩法实现。

## Scope

- `luna_jump_fall_sheet_ai01`
- `luna_hit_death_sheet_ai01`
- `enemies_core_sheet_ai01`

## Output Targets

- `assets/art/characters/player/sprite_sheets/luna_jump_fall_sheet_ai01.png`
- `assets/art/characters/player/sprite_sheets/luna_hit_death_sheet_ai01.png`
- `assets/art/characters/enemies/sprite_sheets/enemies_core_sheet_ai01.png`
- 对应 `.frames.json`
- 对应 `.spriteframes.tres`

## Generation Method

- 使用 Codex 内置 `image_gen`，每个 asset 单独生成一张 sprite sheet 候选。
- 默认从 `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613` 复制生成结果。
- 原始候选放入 `assets/source/ai_generated/batch_06/<asset_id>/candidates/<asset_id>_candidate_01.png`。
- 使用 `scripts/assets/prepare_selected_sources.py --only <asset_id> --overwrite` 拆出 `selected_frames/`。
- 使用 `scripts/assets/build_asset_atlases.py --only <asset_id>` 生成 Godot 可用 sheet。

## Verification

- `python scripts\assets\validate_asset_production_queue.py`
- `python scripts\assets\prepare_selected_sources.py --only <asset_id> --overwrite`
- `python scripts\assets\build_asset_atlases.py --only <asset_id>`
- `godot --headless --path . --import`
- `git diff --check`

## Exit Criteria

- 三个 asset 均有 source candidate。
- 三个 asset 均有 `assets/art` PNG、`.frames.json` 和 `.spriteframes.tres`。
- Godot import 退出码为 `0`。
- 文档记录保持 `placeholder_ready`，不标记为 `integrated`。

## Non-Goals

- 不替换玩家、敌人或 Boss 的运行时动画引用。
- 不承诺最终帧数、最终清稿质量或正式碰撞读值。
- 不启用 Spine / Aseprite 插件。
