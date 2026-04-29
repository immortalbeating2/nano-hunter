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

- [ ] Confirm the current worktree is clean and `HEAD` is contained by `main`.
- [ ] Create or switch to `codex/north-star-realign-stage12-13` in the current worktree.
- [ ] Use read-only subagents for `design`, `asset_direction`, and `qa` review; the main agent performs all edits.
- [ ] Record that this session uses `当前工作树 + 阶段修正分支`.

## Task 2: Design And Formal Plan Docs

**Files:**
- Create: `spec-design/2026-04-29-stage-12-13-north-star-realignment-design.md`
- Create: `plan/2026-04-29-stage-12-13-north-star-realignment.md`
- Modify: Stage 12/13 existing design docs and formal plans

- [ ] Document the reason for the deviation and the exact old-name to new-name mapping.
- [ ] State that gameplay structure and Stage 14 Air Dash are out of scope for behavior changes.
- [ ] Update Stage 12-16 roadmap language so future work inherits shrine trial / miasma marsh terminology.
- [ ] Keep old names only in explicit historical mapping sections.

## Task 3: Godot Resource And Code Repackaging

**Files:**
- Modify: Stage 13 room scenes, room base script, enemy scene/script/config, Stage 11/14/15 references
- Modify: Stage 12/13 asset paths and `.import` metadata

- [ ] Rename `biome_01_lab` to `biome_01_shrine_trial`.
- [ ] Rename `bio_waste` to `miasma_marsh`.
- [ ] Rename `acid_hazard` to `miasma_hazard`.
- [ ] Rename `purification_gate/node` to `seal_gate/seal_node`.
- [ ] Rename `spore_shooter` to `miasma_caster`.
- [ ] Update `Main`, Stage 11 continue flow, Stage 14 entry references, and Stage 15 mixed encounter references.
- [ ] Preserve behavior: room count, branch count, damage values, checkpoint rules, enemy pressure timing, and public contracts.

## Task 4: Tests And Residual Scan

**Files:**
- Modify: `tests/stage12/`
- Modify: `tests/stage13/`
- Modify: `tests/stage14/`
- Modify: `tests/stage15/`

- [ ] Update Stage 12 asset directory assertions.
- [ ] Update Stage 13 enemy, hazard, gate, room path, manifest, and graybox driver assertions.
- [ ] Update Stage 14 goal-room reference.
- [ ] Update Stage 15 encounter enemy node reference.
- [ ] Run residual scan for modern-lab terms in self-owned files, excluding third-party plugins and explicit old-name mapping sections.

## Task 5: Verification And Progress Closure

**Commands:**
- `git diff --check`
- `godot --headless --path . --import`
- Stage 13 GUT
- Stage 14 GUT
- Stage 15 GUT
- Full GUT

- [ ] Record command results in `docs/progress/logs/2026-04-29.md`.
- [ ] Update `docs/progress/status.md` and `docs/progress/timeline.md`.
- [ ] If Godot MCP runtime review is unavailable, record the fallback reason and rely on headless import plus GUT.
