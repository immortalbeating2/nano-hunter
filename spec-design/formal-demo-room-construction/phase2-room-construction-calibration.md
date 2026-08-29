# F04-F09 actual construction calibration

This report is regenerated from the six production `.tscn` scenes. The original blueprint remains the design baseline; cyan geometry and gold anchors are current runtime construction.

## Calibration result

- Status: `aligned_after_tuning`
- Global maximum anchor deviation: dx `83.2u`, dy `57.6u`
- Movement rulers: jump sample `96.44u`; Air Dash sample `110.00u`; grid `32u`; camera segment `640x360`.
- Automated evidence proves scene structure, collision support, segment coverage, route clearance, and anchor tolerances. It does not replace a fresh human playtest.

## Before/after deviations

| Room | Before tuning | After tuning |
|---|---|---|
| F04 | Vista x -64 and descent x 544 compressed the three-segment reveal. | max dx 32u / max dy 39.2u; spawns supported=True; segments covered=True |
| F05 | Projectile observation anchor was absent; shrine/practice anchors were not blueprint-auditable. | max dx 25.6u / max dy 38.4u; spawns supported=True; segments covered=True |
| F06 | Air Dash reward sat at (880,64) on the first-visit upper route instead of the lower revisit route. | max dx 83.2u / max dy 57.6u; spawns supported=True; segments covered=True |
| F07 | Gate and shortcut shared x=800; F14 return spawn was 178.89u from the shortcut marker. | max dx 19.2u / max dy 40.8u; spawns supported=True; segments covered=True |
| F08 | F10 return spawn was (560,76), outside the blueprint loop landing and lacked a named landing marker. | max dx 51.2u / max dy 11.2u; spawns supported=True; segments covered=True |
| F09 | Lower resource branch had only 32u below an overlapping solid main floor; fast entry/decision anchors were absent. | max dx 19.2u / max dy 42.4u; spawns supported=True; segments covered=True |

## Deliverables

- F04: [F04-stage13_miasma_marsh_entry_room-actual.svg](F04-stage13_miasma_marsh_entry_room-actual.svg) + [F04-stage13_miasma_marsh_entry_room-overlay.svg](F04-stage13_miasma_marsh_entry_room-overlay.svg)
- F05: [F05-stage13_miasma_marsh_caster_room-actual.svg](F05-stage13_miasma_marsh_caster_room-actual.svg) + [F05-stage13_miasma_marsh_caster_room-overlay.svg](F05-stage13_miasma_marsh_caster_room-overlay.svg)
- F06: [F06-stage13_miasma_marsh_miasma_room-actual.svg](F06-stage13_miasma_marsh_miasma_room-actual.svg) + [F06-stage13_miasma_marsh_miasma_room-overlay.svg](F06-stage13_miasma_marsh_miasma_room-overlay.svg)
- F07: [F07-stage13_miasma_marsh_gate_room-actual.svg](F07-stage13_miasma_marsh_gate_room-actual.svg) + [F07-stage13_miasma_marsh_gate_room-overlay.svg](F07-stage13_miasma_marsh_gate_room-overlay.svg)
- F08: [F08-stage13_miasma_marsh_checkpoint_room-actual.svg](F08-stage13_miasma_marsh_checkpoint_room-actual.svg) + [F08-stage13_miasma_marsh_checkpoint_room-overlay.svg](F08-stage13_miasma_marsh_checkpoint_room-overlay.svg)
- F09: [F09-stage13_miasma_marsh_branch_hub_room-actual.svg](F09-stage13_miasma_marsh_branch_hub_room-actual.svg) + [F09-stage13_miasma_marsh_branch_hub_room-overlay.svg](F09-stage13_miasma_marsh_branch_hub_room-overlay.svg)
