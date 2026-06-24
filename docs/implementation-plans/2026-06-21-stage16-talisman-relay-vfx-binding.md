# Stage16 Talisman Relay VFX Binding

## Summary

继续推进 P0 runtime replacement，把 `stage16_talisman_relay_ai01` 从资源目录 / catalog / rehearsal 推进到正式 Stage16 relay 与 purge 房间引用。该资产用于强化终局封印链中的符印传递读值，但本轮只做低风险 Sprite2D 资源绑定，不改变碰撞、门控脚本或房间推进逻辑。

## Scope

- 更新 `scenes/rooms/stage16_talisman_relay_room.tscn`。
- 更新 `scenes/rooms/stage16_corruption_purge_room.tscn`。
- 更新 `tests/stage16/test_stage_16_alpha_demo_candidate.gd`。
- 刷新 P0 replacement、scene replacement batches、art readiness、final art review queue / workbench、acceptance gates、asset package audit 和进度文档。

## Key Changes

- `Stage16TalismanRelayRoom` 三个 relay marker 下新增 `RelayArt` Sprite2D，引用 `res://assets/art/vfx/stage16_talisman_relay_ai01.png`。
- `Stage16CorruptionPurgeRoom` 的 `CorruptionPurgeNode` 下新增 `TalismanRelayEchoArt` Sprite2D，引用同一资源。
- 所有新增 Sprite2D 都记录 `metadata/asset_id = "stage16_talisman_relay_ai01"`。
- 新增 Stage16 GUT 断言，保护 relay / purge 房间的资源路径与 metadata。

## Validation

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage16/test_stage_16_alpha_demo_candidate.gd -gexit
python scripts\assets\build_p0_runtime_replacement_plan.py
python scripts\assets\build_p0_target_scene_replacement_matrix.py
python scripts\assets\build_p0_scene_replacement_batches.py
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\build_final_art_review_queue.py
python scripts\assets\audit_final_art_review_queue.py --strict
godot --headless --path . --script res://scripts/dev/build_final_art_review_workbench.gd
godot --headless --path . --script res://scripts/dev/audit_final_art_review_workbench.gd
python scripts\assets\build_final_art_acceptance_gates.py
python scripts\assets\audit_p0_runtime_replacement_plan.py --strict
python scripts\assets\audit_p0_target_scene_replacement_matrix.py --strict
python scripts\assets\audit_p0_scene_replacement_batches.py --strict
python scripts\assets\audit_final_art_acceptance_gates.py --strict
python scripts\assets\audit_imagegen_source_safety.py --write-report --strict
python scripts\assets\audit_asset_package.py --strict --write-report
```

## Result

- Stage16 GUT：`11/11 passed`，`103` asserts。
- P0 runtime replacement plan：`15 planned replacements, 13 already referenced`。
- P0 scene replacement batches：`41 planned scene-asset replacements, 14 already referenced`。
- Final art acceptance gates：`runtime_replacement = 13 passed, 42 blocked`。
- Art readiness：`55/55 structural_ready, 0/55 final_ready`。
- Source safety：`101 candidates, 0 unsafe`。

## Exit Criteria

- Relay / purge 两个正式房间都引用 `stage16_talisman_relay_ai01`。
- Stage16 房间链路专项测试通过。
- P0 replacement 与 final-art gates 计数刷新到新基线。
- 不把 VFX frame order、mask / blend、最终清稿、授权条款或 final approval 误标为完成。
