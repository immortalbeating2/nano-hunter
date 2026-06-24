# Asset Runtime Integration Map Implementation Plan

Date: 2026-06-20

## Summary

为当前 `55` 个 image gen 资产建立运行时 / 发布接入映射。该层把每个资产绑定到目标 track、目标系统、推荐 Godot 资源类型和候选场景，方便后续 Stage polish 逐项替换引用。它不直接修改游戏运行时场景引用，也不声称资产已经正式接入。

## Goals

- 为每个 queue item 生成一条 integration map entry。
- 记录推荐资源类型：`Texture2D`、`AtlasTexture`、`SpriteFrames`、`TileSet`、`StyleBoxTexture` 或 Spine-style atlas / json。
- 记录目标 track：runtime gameplay、runtime animation、runtime environment、runtime UI、runtime VFX、animation pipeline、release / narrative 等。
- 记录至少一个当前存在的候选场景或开发 / 发布入口。
- 将 runtime map 纳入 Art readiness 与综合资产包审计。

## Non-Goals

- 不替换 `player_placeholder.tscn`、`demo_shell.tscn`、Stage14-16 房间、Boss 或 HUD 的实际引用。
- 不改变 `assets/art` 输出。
- 不改变任何资产的 `final_ready` 状态。
- 不跳过人工清稿、布局、碰撞、VFX timing、动画帧序和 gameplay readability 复核。

## Key Changes

- 新增 `scripts/assets/build_asset_runtime_map.py`。
- 新增 `scripts/assets/audit_asset_runtime_map.py`。
- 生成 `docs/assets/asset-runtime-integration-map.json`。
- 扩展 `scripts/assets/audit_art_readiness.py`，把 `runtime_reference_not_replaced` 推进为 `runtime_binding_map_ready_manual_replacement`。
- 扩展 `scripts/assets/audit_asset_package.py`，校验 runtime map entry 覆盖。

## Validation

```powershell
python scripts\assets\build_asset_runtime_map.py
python scripts\assets\audit_asset_runtime_map.py --strict
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\audit_asset_package.py --strict --write-report
```

当前结果：

- `Asset runtime integration map built: 55 entries, 9 tracks.`
- `Asset runtime map OK: 55 entries, 9 tracks.`
- `runtime_reference_not_replaced=0`
- `runtime_binding_map_ready_manual_replacement=55`
- `Asset package audit OK`，并记录 `55 runtime map entries`

## Exit Criteria

- 每个 queue item 有 runtime map entry。
- 每条 entry 有 track、target system、recommended resource type 和至少一个存在的候选场景。
- `missing_output_count=0`。
- `missing_target_scene_candidate_count=0`。
- readiness / package audit 通过。

## Risks / Follow-Up

- 当前 map 是接入路径，不是正式替换。
- 后续要按 Stage polish 逐项替换场景、HUD、Boss、VFX、TileSet 或发布素材引用。
- 正式替换后必须运行 Godot import、对应 GUT、人工试玩和 `asset-ingestion-checklist.md`。
