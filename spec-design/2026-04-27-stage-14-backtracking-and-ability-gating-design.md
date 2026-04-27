# Stage 14 Backtracking And Ability Gating Design

Date: 2026-04-27

## Design Goal

Stage 14 turns the Stage 13 endpoint into the first true backtracking loop. The only new core ability is `Air Dash`: the player keeps the existing ground dash, gains one air dash while airborne, and refreshes that air dash after landing.

The stage must prove five things without building a full map, quest log, save system, or multi-ability progression:

- A new ability can be earned in a room after Stage 13.
- That ability persists across room transitions.
- A gate can read the ability and stop or release progression.
- Old-space rewards can become meaningful after the ability is unlocked.
- The main path can loop back and then continue forward.

## Player Ability

`PlayerPlaceholder` remains the owner of movement execution. `Main` owns the runtime unlock state and injects it into the player whenever a room respawns the player.

Rules:

- Ground dash remains available by the existing cooldown and grounded checks.
- Air dash is locked by default.
- After unlock, the player may start one dash while airborne.
- Starting an air dash consumes the airborne use.
- Landing refreshes the airborne use.
- Room transitions must not remove the unlock.

Public methods:

- `set_air_dash_unlocked(is_unlocked: bool) -> void`
- `is_air_dash_unlocked() -> bool`
- `is_air_dash_available() -> bool`

## Stage Flow

The flow begins at `stage13_bio_waste_goal_room` and enters:

1. `stage14_air_dash_shrine_room`: grants Air Dash.
2. `stage14_air_dash_gate_room`: validates the first ability gate.
3. `stage14_backtrack_hub_room`: exposes at least three backtracking rewards.
4. `stage14_loop_return_room`: confirms the loop can return to mainline continuation.

The first pass is graybox by intent. It values legible contracts and automated coverage over final layout density.

## HUD And Feedback

HUD snapshots include:

- `air_dash_unlocked`
- `air_dash_available`
- `stage14_backtrack_reward_count`

The Stage 14 HUD line should answer two player questions: whether the ability is unlocked, and whether the current airborne charge is usable.

## Asset Direction

Stage 14 assets are manifest requirements first. Placeholder visuals may remain simple, but naming and notes should point future art back toward the project north star: talisman gates, Buddhist seal machinery, corrupted ritual spaces, and graceful motion language rather than modern lab technology.

## Non Goals

- No full map screen.
- No quest log.
- No formal save file.
- No stamina, mana, skill tree, or alternate dash resource.
- No second new ability.
