# Stage 14 Backtracking And Ability Gating Implementation Plan

Date: 2026-04-27

## Scope

Implement Stage 14 as the first backtracking and ability-gating slice. The single new ability is Air Dash. The stage connects from the Stage 13 endpoint, grants the ability, tests a gate, exposes three backtracking rewards, and exits through a loop-return room.

## Steps

1. Preflight the desktop `main` baseline with Godot import, full Stage 1-13 GUT, and `git diff --check`.
2. Recreate the permanent Stage14 worktree at `C:\Users\peng8\.codex\worktrees\ffc3\nano-hunter` on `codex/stage-14-backtracking-ability-gating`.
3. Add Stage14 GUT tests before implementation.
4. Extend `PlayerPlaceholder` with Air Dash unlock, availability, one-use airborne consumption, landing recharge, and HUD snapshot fields.
5. Extend `Main` with runtime Air Dash ownership, player injection after room transitions, backtrack reward counting, and progress snapshot fields.
6. Add Stage14 room base behavior for shrine unlock, ability gate state, rewards, and HUD context.
7. Add four Stage14 graybox scenes and connect the Stage13 goal room to the shrine.
8. Update HUD, asset manifest, progress docs, and design docs.
9. Verify with Stage14 GUT, full GUT, Godot import, and `git diff --check`.

## Acceptance Criteria

- Air Dash is locked by default and cannot trigger in air.
- Unlocking Air Dash enables one airborne dash.
- Landing refreshes the airborne use.
- Air Dash unlock persists across room transitions.
- The first Stage14 gate is blocked before unlock and open after unlock.
- Three backtracking reward points can be collected and counted.
- The Stage13 endpoint transitions into Stage14.
- A graybox driver can complete: shrine -> gate -> backtrack rewards -> loop return.

## Verification Commands

```powershell
godot --headless --path . --import
godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage14/test_stage_14_backtracking_and_ability_gating.gd -gexit
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
git diff --check
```
