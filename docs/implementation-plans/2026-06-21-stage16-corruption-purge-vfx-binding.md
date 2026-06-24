# Stage16 Corruption Purge VFX Binding

## Summary

本计划继续推进 Stage16 VFX 运行时引用，把 `stage16_corruption_purge_ai01` 接入正式 `Stage16CorruptionPurgeRoom` 的妖瘴净化表现层。

该资产当前位于项目内 `assets/art/vfx/stage16_corruption_purge_ai01.png`，并在 manifest、provenance、runtime map、runtime catalog 与 source safety report 中有记录；但来源安全分类仍是 `workspace_provenance_recorded_review_required`，不是机器 ledger 强确认。因此本次只完成当前项目候选的可运行引用，不声明最终授权、最终清稿或最终项目归属人工复核完成。

## Scope

- 更新 `scenes/rooms/stage16_corruption_purge_room.tscn`，在 `CorruptionMiasma` 下新增 `PurgeArt` Sprite2D。
- 新增 `metadata/asset_id = "stage16_corruption_purge_ai01"`，保护节点与资源路径可审计。
- 更新 `tests/stage16/test_stage_16_alpha_demo_candidate.gd`，新增 Stage16 corruption purge VFX 引用保护。
- 刷新 final art review queue、acceptance gates、source safety 和综合资产包报告。

## Non-Goals

- 不生成新 PNG。
- 不从全局 `C:\Users\peng8\.codex\generated_images` 导入 latest 图片。
- 不把 `stage16_corruption_purge_ai01` 标记为 `final_ready`。
- 不确认 VFX 帧序、mask / blend、锚点、timing 或商业授权。
- 不扩大到其它 review-required 候选的运行时替换。

## Asset Source Boundary

- `stage16_corruption_purge_ai01` 当前 source safety entry 为 `workspace_provenance_recorded_review_required`。
- 该状态表示候选在当前 workspace 有 Nano Hunter prompt / provenance 记录，但缺少机器可读 source ledger。
- 本次接入依据是：目标 PNG 已在当前仓库 `assets/art/vfx/`、manifest / provenance / runtime map 可追溯、Godot runtime catalog 可加载。
- 后续发布或最终美术批准前，仍必须人工复核候选确属 Nano Hunter 当前资产方向，并确认授权条款。

## Verification Plan

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\build_final_art_review_queue.py
python scripts\assets\audit_final_art_review_queue.py --strict
python scripts\assets\build_final_art_acceptance_gates.py
python scripts\assets\audit_final_art_acceptance_gates.py --strict
python scripts\assets\audit_imagegen_source_safety.py --write-report --strict
python scripts\assets\audit_asset_package.py --strict --write-report
git diff --check
```

## Exit Criteria

- Stage16 GUT 中 corruption purge VFX 引用测试通过。
- `stage16_corruption_purge_ai01` 的 final-art `runtime_replacement` gate 通过。
- 综合 final-art gate 维持 `final_ready = 0/55`，不误报最终美术完成。
- source safety audit 维持 `0 unsafe`，并保留该资产的 `review_required` 边界。
