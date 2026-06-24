# Batch 03 Supplemental Room Backgrounds

## Summary

本计划补齐 Batch 03 区域表现中仍偏薄的“具体房间背景 / 视差源图”资产。它服务后续 Stage13-16 场景替换、视差拆层和房间气氛统一，不改变当前关卡碰撞、敌人配置或运行时引用。

## Scope

- `biome01_shrine_trial_room_parallax_ai01`
- `biome01_air_dash_shrine_room_ai01`
- `biome02_miasma_hazard_room_ai01`
- `stage15_seal_guardian_boss_room_ai01`

## Output Targets

- `assets/art/environment/biome_01_shrine_trial/biome01_shrine_trial_room_parallax_ai01.png`
- `assets/art/environment/biome_01_shrine_trial/biome01_air_dash_shrine_room_ai01.png`
- `assets/art/environment/biome_02_miasma_marsh/biome02_miasma_hazard_room_ai01.png`
- `assets/art/environment/boss_rooms/stage15_seal_guardian_boss_room_ai01.png`

## Generation Method

- 使用 Codex 内置 `image_gen`，每个房间背景单独生成一张候选图。
- 默认从 `C:\Users\peng8\.codex\generated_images\019dd85a-7144-7b63-924f-979212c1d613` 复制生成结果。
- 原始候选放入 `assets/source/ai_generated/batch_03/<asset_id>/candidates/<asset_id>_candidate_01.png`。
- 使用 `scripts/assets/export_standalone_candidates.py --only <asset_id> --overwrite` 导出到 `assets/art`。

## Verification

- `python scripts\assets\validate_asset_production_queue.py`
- `python scripts\assets\export_standalone_candidates.py --only <asset_id> --overwrite`
- `godot --headless --path . --import`
- `git diff --check`

## Exit Criteria

- 四个 asset 均有 source candidate。
- 四个 asset 均有 `assets/art` PNG 和 Godot `.import`。
- Godot import 退出码为 `0`。
- 文档记录保持 `placeholder_ready`，不标记为 `integrated`。

## Non-Goals

- 不替换现有房间场景引用。
- 不配置 TileSet、碰撞、视差层或运行时 Room 脚本。
- 不承诺最终拆层质量；本轮只提供可复核的背景候选源图。
