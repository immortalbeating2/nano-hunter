# HUD / Pause Image Gen Direction Review

Date: 2026-08-10
Status: direction 02 selected; v3 superseded; corrected v4 runtime technical candidate integrated; human visual / release review pending
Provider: official OpenAI built-in `image_gen`

## Locked interaction contract

- Pause and failure actions use fixed-width text rows with no leading icons.
- One shared cyan rune-light band tracks the current focus; the band moves, the row geometry does not morph.
- The selected static art pack must provide a complete pause outer frame enclosing the title and every action.
- Gameplay HUD requires independent battle, tutorial and element / stance proportions with generous text-safe regions.

## Reference roles

1. `tests/artifacts/local/runtime-visual-integrity/hud-formal-review/layouts/2048x1152.png`: gameplay composition and edit base.
2. `tests/artifacts/local/pause-interaction-options/a_shared_flow_band.png`: focus interaction only.
3. `assets/art/ui/main_menu_shell_ai02.png`: C2 palette, mood and world-art direction.

## Generated directions

| Direction | Visual language | Review file | SHA256 | Decision |
| --- | --- | --- | --- | --- |
| 01 符印铜墨 | blackened bronze, charcoal lacquer, antique-gold wear, cyan seal channels | `tests/artifacts/local/hud-pause-imagegen-direction-review/direction_01_talisman_bronze_ink.png` | `bea2bce751d509e2e0b9e3083d166d3a985e031dcff8ce95bc3913dd2f8cb82b` | not selected |
| 02 镇妖官印 | dark lacquer archive, hammered bronze clamps, official seals, restrained cinnabar | `tests/artifacts/local/hud-pause-imagegen-direction-review/direction_02_warden_lacquer_archive.png` | `282ac16719f31e8a0f4482a23dee7646bb920965a0b694b721665e085a0939bd` | selected 2026-08-10 |
| 03 月蚀玄石 | carved black stone, smoke jade, cold silver inlay, cyan seal fissures | `tests/artifacts/local/hud-pause-imagegen-direction-review/direction_03_moon_eclipse_jade.png` | `ecafd6b1f9e6af8b0846b55476082362d5c81fa457e41656ed2510c770a8e08f` | not selected |

## Prompt set boundary

All three prompts preserved the gameplay background and character, removed the old HUD, displayed three purpose-built HUD proportions plus one complete pause frame, kept every row inside the pause frame, and fixed the selected A focus behavior. The only intentional prompt delta was material language: bronze-ink, warden lacquer archive, or moon-eclipse stone / jade.

## Superseded v3 result

- Four separate no-text RGBA frames were produced under `assets/art/ui/hud_warden_lacquer_v3/`; they now remain historical only and have zero intended live bindings.
- Battle, tutorial and element use independent high-resolution proportions and independent `StyleBoxTexture` safe areas. Standard 16:9 occupancy is constrained to about `22%~25%`, `34%~39%`, and `22%~25%` width respectively instead of enlarging one shared bitmap.
- Pause uses its dedicated tall frame at about `30%` viewport width and `50%` height. Failure reuses the related low horizontal notification frame; both use fixed text geometry and one shared Shader-driven focus band.
- Dynamic text remains Godot-rendered. The direction mockup's baked text is not present in runtime assets.
- Real Windows/D3D12 evidence is stored at `tests/artifacts/local/runtime-visual-integrity/hud-formal-review/layouts/2048x1152.png`, `tests/artifacts/local/demo-shell-start-review/demo_shell_pause.png`, and `tests/artifacts/local/demo-shell-start-review/demo_shell_failure.png`.

The v3 prompt / implementation incorrectly converted decorative density concerns into a ban on chains, tassels and hanging official plaques, and separately removed the battle HUD's large left official seal without a user requirement. Those exclusions are revoked; v3 is not the current visual contract.

## Corrected direction 02 v4 runtime result

- The four base frames were regenerated at the actual runtime ratios: Battle `2.70:1`, Tutorial `3.90:1`, Element `2.53:1`, Pause `1.05:1`.
- Stretchable soot-black lacquer bases live under `assets/art/ui/hud_warden_official_v4/`; official seal, chain hook, hanging talisman / tassel and cinnabar stamp are separate RGBA assets and separate non-stretch Godot layers.
- Battle explicitly retains the large left official-seal anchor. All three HUD surfaces and Pause declare `visual_anchor_contract=02_warden_seal_chains_tassel` and preserve ornament aspect ratio.
- Health, dash, objective and recovery icons plus the meter rail were regenerated as the same 02 family; `hud_warden_official_v4.theme.tres` supplies one runtime font stack.
- Current standard occupancy is about Battle `23.75%`, Tutorial `40%`, Element `25%`; Pause is about `26% x 44%`, reducing the v3 screen footprint without squashing its border.
- Thirteen runtime PNGs have adjacent provenance records. Raw generation sources are isolated under `assets/source/ai_generated/batch_08/hud_warden_official_v4/`.
- Current Windows/OpenGL evidence is `tests/artifacts/local/demo-shell-start-review/demo_shell_started.png`, `demo_shell_pause.png` and `demo_shell_failure.png`.

## Remaining approval boundary

- Automated layout, source, regression and screenshot checks establish a runtime technical candidate only.
- Human review of final visual fidelity, physical display readability, controller feel, source terms and external release remains pending; Gate26H is not advanced by this record.
