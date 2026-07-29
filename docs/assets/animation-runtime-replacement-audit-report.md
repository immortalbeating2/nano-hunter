# Animation Runtime Replacement Audit

Status: `runtime_replacement_ready`

- Active assets: `21`
- Active ready: `21`
- Active blocked: `0`
- Archived references: `10`
- Archived reference errors: `0`

| Asset | Status | Key blockers | Min margins | Baseline variance | Notes |
| --- | --- | --- | --- | ---: | --- |
| `luna_idle_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=36, top=8, right=36, bottom=8 | 0 | - |
| `luna_run_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=16, top=18, right=16, bottom=8 | 0 | - |
| `luna_hit_react_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=24, top=41, right=25, bottom=8 | 0 | - |
| `luna_death_idle_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=24, top=88, right=25, bottom=8 | 0 | - |
| `enemy_basic_melee_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=38, top=46, right=38, bottom=8 | 1 | - |
| `enemy_ground_charger_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=24, top=44, right=24, bottom=8 | 0 | - |
| `enemy_aerial_sentinel_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=28, top=44, right=27, bottom=8 | 0 | - |
| `enemy_miasma_caster_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=36, top=44, right=36, bottom=8 | 1 | - |
| `seal_guardian_idle_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=25, top=52, right=25, bottom=8 | 0 | - |
| `seal_guardian_warning_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=26, top=46, right=25, bottom=8 | 0 | - |
| `seal_guardian_defeat_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=25, top=45, right=25, bottom=8 | 0 | - |
| `luna_attack_body_runtime_sheet_ai02` | `runtime_replacement_ready` | - | left=24, top=12, right=24, bottom=8 | 0 | - |
| `luna_air_dash_body_runtime_sheet_ai02` | `runtime_replacement_ready` | - | left=24, top=33, right=24, bottom=8 | 0 | - |
| `seal_guardian_attack_body_runtime_sheet_ai02` | `runtime_replacement_ready` | - | left=30, top=8, right=30, bottom=8 | 0 | - |
| `luna_jump_state_runtime_sheet_ai04` | `runtime_replacement_ready` | - | left=30, top=12, right=31, bottom=12 | 8 | - |
| `seal_guardian_stagger_runtime_sheet_ai01` | `runtime_replacement_ready` | - | left=34, top=30, right=33, bottom=8 | 0 | - |
| `enemy_basic_melee_defeat_runtime_sheet_ai02` | `runtime_replacement_ready` | - | left=38, top=42, right=38, bottom=12 | 0 | - |
| `enemy_ground_charger_defeat_runtime_sheet_ai02` | `runtime_replacement_ready` | - | left=27, top=56, right=27, bottom=12 | 0 | - |
| `enemy_aerial_sentinel_defeat_runtime_sheet_ai02` | `runtime_replacement_ready` | - | left=36, top=40, right=36, bottom=12 | 0 | - |
| `enemy_miasma_caster_defeat_runtime_sheet_ai02` | `runtime_replacement_ready` | - | left=38, top=40, right=38, bottom=12 | 0 | - |
| `enemy_ground_charger_action_runtime_sheet_ai02` | `runtime_replacement_ready` | - | left=23, top=40, right=23, bottom=12 | 0 | - |

## Archived References

| Asset | Status | Replacements | Errors |
| --- | --- | --- | --- |
| `luna_jump_fall_runtime_sheet_ai01` | `superseded_reference` | luna_jump_state_runtime_sheet_ai04 | - |
| `luna_air_dash_runtime_sheet_ai01` | `superseded_reference` | luna_air_dash_body_runtime_sheet_ai02, stage14_air_dash_trail_ai01 | - |
| `luna_attack_01_runtime_sheet_ai01` | `archived_blocked_reference` | luna_attack_body_runtime_sheet_ai02, luna_attack_slash_vfx_runtime_ai01 | - |
| `luna_hit_death_runtime_sheet_ai01` | `archived_blocked_reference` | luna_hit_react_runtime_sheet_ai01, luna_death_idle_runtime_sheet_ai01 | - |
| `luna_attack_body_runtime_sheet_ai01` | `archived_blocked_reference` | luna_attack_body_runtime_sheet_ai02 | - |
| `enemies_core_runtime_sheet_ai01` | `archived_blocked_reference` | enemy_basic_melee_runtime_sheet_ai01, enemy_ground_charger_runtime_sheet_ai01, enemy_aerial_sentinel_runtime_sheet_ai01, enemy_miasma_caster_runtime_sheet_ai01 | - |
| `seal_guardian_boss_runtime_sheet_ai01` | `archived_blocked_reference` | seal_guardian_idle_runtime_sheet_ai01, seal_guardian_warning_runtime_sheet_ai01, seal_guardian_attack_body_runtime_sheet_ai02, seal_guardian_defeat_runtime_sheet_ai01 | - |
| `seal_guardian_attack_runtime_sheet_ai01` | `archived_blocked_reference` | seal_guardian_attack_body_runtime_sheet_ai02, seal_guardian_attack_vfx_atlas_ai01 | - |
| `seal_guardian_attack_body_runtime_sheet_ai01` | `archived_blocked_reference` | seal_guardian_attack_body_runtime_sheet_ai02 | - |
| `luna_jump_fall_runtime_sheet_ai03` | `superseded_reference` | luna_jump_state_runtime_sheet_ai04 | - |

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
