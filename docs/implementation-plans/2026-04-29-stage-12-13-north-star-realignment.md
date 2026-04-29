# Stage 12-13 North Star Realignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or execute the checklist task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repackage Stage 12-13 away from modern lab / bio waste wording and back into Nano Hunter's Southern-Northern Dynasties eastern fantasy north star.

**Architecture:** Keep gameplay behavior stable while renaming Stage 12-13 resources, scenes, scripts, helper methods, tests, visible HUD wording, and asset documentation. The public room, enemy, HUD, checkpoint, and transition contracts remain unchanged.

**Tech Stack:** Godot 4.6, GDScript, GUT, Markdown project docs.

---

## Task 1: Branch And Collaboration Setup

**Files:**
- Modify: `docs/progress/logs/2026-04-29.md`
- Modify: `docs/progress/timeline.md`

- [x] Confirm the current worktree is clean and `HEAD` is contained by `main`.
- [x] Create or switch to `codex/north-star-realign-stage12-13` in the current worktree.
- [x] Use read-only subagents for `design`, `asset_direction`, and `qa` review; the main agent performs all edits.
- [x] Record that this session uses `当前工作树 + 阶段修正分支`.

## Task 2: Design And Formal Plan Docs

**Files:**
- Create: `spec-design/2026-04-29-stage-12-13-north-star-realignment-design.md`
- Create: `plan/2026-04-29-stage-12-13-north-star-realignment.md`
- Modify: Stage 12/13 existing design docs and formal plans

- [x] Document the reason for the deviation and the exact old-name to new-name mapping.
- [x] State that gameplay structure and Stage 14 Air Dash are out of scope for behavior changes.
- [x] Update Stage 12-16 roadmap language so future work inherits shrine trial / miasma marsh terminology.
- [x] Keep old names only in explicit historical mapping sections.

## Task 3: Godot Resource And Code Repackaging

**Files:**
- Modify: Stage 13 room scenes, room base script, enemy scene/script/config, Stage 11/14/15 references
- Modify: Stage 12/13 asset paths and `.import` metadata

- [x] Rename `biome_01_lab` to `biome_01_shrine_trial`.
- [x] Rename `bio_waste` to `miasma_marsh`.
- [x] Rename `acid_hazard` to `miasma_hazard`.
- [x] Rename `purification_gate/node` to `seal_gate/seal_node`.
- [x] Rename `spore_shooter` to `miasma_caster`.
- [x] Update `Main`, Stage 11 continue flow, Stage 14 entry references, and Stage 15 mixed encounter references.
- [x] Preserve behavior: room count, branch count, damage values, checkpoint rules, enemy pressure timing, and public contracts.

## Task 4: Tests And Residual Scan

**Files:**
- Modify: `tests/stage12/`
- Modify: `tests/stage13/`
- Modify: `tests/stage14/`
- Modify: `tests/stage15/`

- [x] Update Stage 12 asset directory assertions.
- [x] Update Stage 13 enemy, hazard, gate, room path, manifest, and graybox driver assertions.
- [x] Update Stage 14 goal-room reference.
- [x] Update Stage 15 encounter enemy node reference.
- [x] Run residual scan for modern-lab terms in self-owned files, excluding third-party plugins and explicit old-name mapping sections.

## Task 5: Verification And Progress Closure

**Commands:**
- `git diff --check`
- `godot --headless --path . --import`
- Stage 13 GUT
- Stage 14 GUT
- Stage 15 GUT
- Full GUT

- [x] Record command results in `docs/progress/logs/2026-04-29.md`.
- [x] Update `docs/progress/status.md` and `docs/progress/timeline.md`.
- [x] Use Godot MCP runtime review for Stage 13 entry, miasma hazard, seal gate, goal room, and Stage 14 entry reference.

## Runtime Review Result

- Godot MCP editor review opened `stage13_miasma_marsh_entry_room.tscn`, `stage13_miasma_marsh_miasma_room.tscn`, `stage13_miasma_marsh_gate_room.tscn`, and `stage13_miasma_marsh_goal_room.tscn`.
- Godot MCP runtime scene tree review confirmed `Stage13MiasmaMarshMiasmaRoom/MiasmaHazard`, `Stage13MiasmaMarshGateRoom/SealNode`, `Stage13MiasmaMarshGateRoom/GateBarrier`, and `Stage13MiasmaMarshGoalRoom/GoalZone`.
- Static reference check confirmed `stage13_miasma_marsh_goal_room.tscn` still transitions to `res://scenes/rooms/stage14_air_dash_shrine_room.tscn`, and Stage15 mixed gauntlet references the renamed Stage13 base / enemy vocabulary.
