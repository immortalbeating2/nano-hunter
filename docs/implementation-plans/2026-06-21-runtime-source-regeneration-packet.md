# Runtime Source Regeneration Packet

## Summary

本计划把 runtime source review queue 中 `manual_source_review_or_regenerate` 的 7 个资产整理为可直接执行的 image gen 重生图包。当前环境没有暴露可调用的 built-in `image_gen` 工具，因此本轮只生成执行包，不声称新 PNG 已经生成。

## Scope

- 新增 `scripts/assets/build_runtime_source_regeneration_packet.py`。
- 新增 `docs/assets/runtime-source-regeneration-packet.json`。
- 新增 `docs/assets/runtime-source-regeneration-packet.md`。
- 更新 `scripts/assets/audit_asset_package.py`，让综合资产包审计校验 regeneration packet。

## Assets

- `stage16_demo_menu_icons_ai01` -> `candidate_03`
- `stage16_talisman_relay_ai01` -> `candidate_02`
- `stage16_alpha_demo_completion_ai01` -> `candidate_02`
- `stage16_pause_panel_ui_ai01` -> `candidate_02`
- `stage16_completion_panel_ui_ai01` -> `candidate_02`
- `stage15_boss_hud_frame_ai01` -> `candidate_02`
- `stage14_ability_status_hud_ai01` -> `candidate_02`

## Non-Goals

- 不生成新 PNG。
- 不覆盖当前 `assets/art/` 输出。
- 不重建 selected sources、atlas、standalone PNG 或运行时场景引用。
- 不把 review-required 候选升级为 confirmed。

## Verification

```powershell
python -m py_compile scripts\assets\build_runtime_source_regeneration_packet.py scripts\assets\audit_asset_package.py
python scripts\assets\build_runtime_source_regeneration_packet.py
python scripts\assets\audit_asset_package.py --write-report --strict
```

## Current Result

- Runtime source regeneration packet：`7` assets。
- Asset package audit：通过，并记录 `7 runtime source regeneration prompts`。
- 每个条目都写明下一候选路径、当前运行时场景、现有输出路径和完整 image gen prompt。

## Next Step

恢复可调用的 built-in `image_gen` 后，按 `docs/assets/runtime-source-regeneration-packet.md` 逐项生成 PNG，保存到对应 candidate path，再运行 source safety、runtime source review queue、regeneration packet 和 asset package audit。
