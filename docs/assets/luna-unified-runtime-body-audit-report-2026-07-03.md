# Animation Runtime Replacement Audit

Status: `runtime_replacement_ready`

- Active assets: `7`
- Active ready: `7`
- Active blocked: `0`
- Archived references: `0`
- Archived reference errors: `0`

| Asset | Status | Key blockers | Min margins | Baseline variance | Notes |
| --- | --- | --- | --- | ---: | --- |
| `luna_idle_runtime_sheet_ai03` | `runtime_replacement_ready` | - | left=52, top=32, right=51, bottom=16 | 0 | - |
| `luna_run_runtime_sheet_ai03` | `runtime_replacement_ready` | - | left=32, top=32, right=33, bottom=16 | 0 | - |
| `luna_jump_fall_runtime_sheet_ai03` | `runtime_replacement_ready` | - | left=51, top=24, right=51, bottom=24 | 38 | - |
| `luna_attack_body_runtime_sheet_ai03` | `runtime_replacement_ready` | - | left=30, top=32, right=31, bottom=16 | 0 | - |
| `luna_air_dash_body_runtime_sheet_ai03` | `runtime_replacement_ready` | - | left=24, top=41, right=24, bottom=41 | 18 | - |
| `luna_hit_react_runtime_sheet_ai03` | `runtime_replacement_ready` | - | left=33, top=32, right=33, bottom=16 | 0 | - |
| `luna_death_idle_runtime_sheet_ai03` | `runtime_replacement_ready` | - | left=24, top=53, right=24, bottom=16 | 0 | - |

## Archived References

| Asset | Status | Replacements | Errors |
| --- | --- | --- | --- |

## Gate Meaning

- `content_touches_cell_edge`: opaque pixels touch a frame boundary; this is not acceptable for formal runtime replacement.
- `insufficient_edge_padding`: one or more frames lack the minimum transparent padding required by the action profile.
- `unstable_foot_baseline`: foot / bottom bound drift is above the profile threshold and may cause visible jitter.
- `unstable_center_x`: horizontal center drift is above the profile threshold and may cause runtime position popping.
- `unstable_content_scale`: content size changes too much across frames and may read as character scale drift.
- `detached_frame_fragments`: sizable disconnected opaque components remain inside a cell and may indicate adjacent-frame fragments or baked VFX debris.
- `blocked_candidate_reference`: legacy status for a failed candidate retained as evidence or regeneration input.
- `archived_blocked_reference` / `superseded_reference`: not part of the active strict gate, but must declare existing `superseded_by` replacements.
- `duplicate_frame_hashes`: exact duplicate frames remain in the sheet and should be removed before formal replacement.

This audit proves formal runtime replacement readiness only for the sprite sheet geometry and resource layer. Gameplay timing, hitbox / hurtbox, damage windows, cancel windows and playtest readability still require scene-level tests.
