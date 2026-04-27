# Stage 14 Backtracking And Ability Gating Checklist

Date: 2026-04-27

## Preflight

- [x] Confirm desktop `main` is clean.
- [x] Run Godot import on desktop `main`.
- [x] Run Stage 1-13 full GUT on desktop `main`.
- [x] Run `git diff --check` on desktop `main`.
- [x] Create permanent Stage14 worktree and branch.

## TDD

- [x] Add Stage14 failing tests for player Air Dash API and behavior.
- [x] Add Stage14 failing tests for scenes, gate, rewards, Stage13 link, and manifest entries.
- [x] Confirm Stage14 tests fail for missing implementation before production changes.

## Implementation

- [x] Implement Air Dash unlock, consumption, landing recharge, and HUD snapshot fields.
- [x] Persist Air Dash through `Main` and inject it after room transitions.
- [x] Add Stage14 shrine, gate, hub, and loop-return room behavior.
- [x] Connect Stage13 goal room to Stage14.
- [x] Add Stage14 graybox scenes.
- [x] Add Stage14 HUD and progress snapshot fields.
- [x] Add Stage14 asset manifest requirements.
- [x] Update progress and design documents.

## Verification

- [x] Run Stage14 GUT.
- [x] Run full GUT.
- [x] Run Godot import.
- [x] Run `git diff --check`.
- [x] Review final diff summary.
- [x] Run Godot MCP runtime review.
- [x] Apply MCP-driven spawn floor and HUD priority microfixes.
