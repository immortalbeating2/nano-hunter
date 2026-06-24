# Animation Runtime Replacement Audit

Status: `blocked`

- Assets: `8`
- Ready: `0`
- Blocked: `8`

| Asset | Status | Key blockers | Min margins | Baseline variance | Notes |
| --- | --- | --- | --- | ---: | --- |
| `luna_run_sheet_ai01` | `blocked` | content_touches_cell_edge, duplicate_frame_hashes, insufficient_edge_padding | left=3, top=0, right=4, bottom=0 | 3 | duplicate_frame_groups=[[0, 21], [1, 22], [2, 23]]; edge_touch_frames=[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20] |
| `luna_air_dash_sheet_ai01` | `blocked` | content_touches_cell_edge, duplicate_frame_hashes, insufficient_edge_padding, unstable_foot_baseline | left=0, top=0, right=0, bottom=4 | 23 | duplicate_frame_groups=[[0, 14], [1, 15]]; edge_touch_frames=[3, 5, 6, 7] |
| `luna_attack_01_sheet_ai01` | `blocked` | content_touches_cell_edge, insufficient_edge_padding, unstable_content_scale | left=0, top=0, right=0, bottom=2 | 2 | edge_touch_frames=[3, 6, 12]; edge_padding_failures=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] |
| `luna_idle_sheet_ai01` | `blocked` | content_touches_cell_edge, insufficient_edge_padding | left=31, top=1, right=32, bottom=0 | 2 | edge_touch_frames=[12, 13, 14, 15]; edge_padding_failures=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] |
| `seal_guardian_boss_sheet_ai01` | `blocked` | content_touches_cell_edge, insufficient_edge_padding, unstable_foot_baseline | left=0, top=7, right=0, bottom=11 | 17 | edge_touch_frames=[0, 1, 9, 12, 14]; edge_padding_failures=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19] |
| `luna_jump_fall_sheet_ai01` | `blocked` | content_touches_cell_edge, insufficient_edge_padding, unstable_foot_baseline | left=3, top=0, right=0, bottom=3 | 22 | edge_touch_frames=[4, 8, 9, 11, 22]; edge_padding_failures=[4, 6, 8, 9, 10, 11, 13, 14, 18, 19, 20, 22] |
| `luna_hit_death_sheet_ai01` | `blocked` | content_touches_cell_edge, insufficient_edge_padding, unstable_content_scale, unstable_foot_baseline | left=0, top=0, right=0, bottom=2 | 49 | edge_touch_frames=[5, 7, 8, 9, 11, 14, 15, 16, 17, 21]; edge_padding_failures=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 23] |
| `enemies_core_sheet_ai01` | `blocked` | content_touches_cell_edge, insufficient_edge_padding, unstable_foot_baseline | left=0, top=2, right=0, bottom=0 | 26 | edge_touch_frames=[11, 19, 20]; edge_padding_failures=[11, 19, 20, 22, 24, 25, 26, 27, 28, 29, 30, 31] |

## Gate Meaning

- `content_touches_cell_edge`: opaque pixels touch a frame boundary; this is not acceptable for formal runtime replacement.
- `insufficient_edge_padding`: one or more frames lack the minimum transparent padding required by the action profile.
- `unstable_foot_baseline`: foot / bottom bound drift is above the profile threshold and may cause visible jitter.
- `unstable_center_x`: horizontal center drift is above the profile threshold and may cause runtime position popping.
- `unstable_content_scale`: content size changes too much across frames and may read as character scale drift.
- `duplicate_frame_hashes`: exact duplicate frames remain in the sheet and should be removed before formal replacement.

This audit proves formal runtime replacement readiness only for the sprite sheet geometry and resource layer. Gameplay timing, hitbox / hurtbox, damage windows, cancel windows and playtest readability still require scene-level tests.
