# ImageGen Candidate Pool Audit - 2026-06-20

## Summary

Track the current `image_gen` raw candidate pool separately from selected sources and `assets/art` outputs. This prevents newly recovered PNG files from being mistaken for final art while still making them visible to the production pipeline.

## Scope

- Add a candidate-pool audit script.
- Generate a machine-readable report under `docs/assets/`.
- Extend the full asset package audit to include candidate-pool status.
- Record how many raw candidates exist, how many selected-source images exist, and which assets still have unselected candidates requiring manual review.

## Key Changes

- Add `scripts/assets/audit_imagegen_candidate_pool.py`.
- Add `docs/assets/imagegen-candidate-pool-report.json`.
- Update `scripts/assets/audit_asset_package.py` to include candidate-pool evidence.
- Update asset docs and progress docs with the new `101` raw candidate / `72` unselected candidate boundary.

## Non-Goals

- Do not automatically promote newly recovered candidates into selected sources.
- Do not rebuild `assets/art` output just because new raw candidates exist.
- Do not mark any asset as `final_ready` or `integrated`.
- Do not replace runtime scene, HUD, VFX, TileSet, SpriteFrames or Theme references.

## Verification

```powershell
python -m py_compile scripts\assets\audit_imagegen_candidate_pool.py scripts\assets\audit_asset_package.py scripts\assets\audit_art_readiness.py
python scripts\assets\audit_imagegen_candidate_pool.py --strict --write-report
python scripts\assets\audit_asset_package.py --strict --write-report
python scripts\assets\audit_art_readiness.py --strict --write-report
python scripts\assets\validate_asset_production_queue.py
python scripts\assets\audit_asset_target_coverage.py --strict
git diff --check
```

## Exit Criteria

- Candidate pool report exists and passes strict mode.
- Full asset package audit passes strict mode and prints unselected candidate count.
- Art readiness remains `55/55 structural ready, 0/55 final ready`.
- Existing atlas-linked outputs remain `26/26` target-ready with `duplicates=0`.

## Boundary

This layer proves candidate inventory and review backlog only. It does not prove art approval, license readiness, cleanup quality, selected-source promotion, atlas rebuild, runtime replacement, or gameplay readability.
