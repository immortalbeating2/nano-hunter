# Stage 6 Minimal Real Combat Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 鍦ㄩ樁娈?5 绋冲畾鍩虹嚎涓婏紝鍋氬嚭鈥滄暀绋嬪悗鐙珛鎴樻枟鎴?+ 1 涓熀纭€杩戞垬鏁屼汉 + 鐜╁鐢熷懡 / 鍙楀嚮 / 鏈鍗虫椂閲嶇疆鈥濈殑鏈€灏忕湡瀹炴垬鏂楅棴鐜€?**Architecture:** 淇濈暀 `TutorialRoom` 浣滀负鏁欏鍏ュ彛锛屾柊澧?`CombatTrialRoom` 鎵胯浇鐪熷疄鎴樻枟鍘嬪姏锛沗Main` 鍙ˉ鏈€灏忔埧闂磋繃娓′笌褰撳墠鎴块棿閲嶇疆锛涚帺瀹舵柊澧炵敓鍛?/ 鍙楀嚮 / defeated 淇″彿锛汬UD 鍗囩骇涓虹湡瀹炴垬鏂楃姸鎬佽鍙栥€?**Tech Stack:** Godot 4.6銆丟DScript銆乣.tscn` 鏂囨湰鍦烘櫙銆丟UT銆丳owerShell

---

## Task 1: 鏀跺彛 stage6 preflight 鏂囨。涓庡紑鍙戠幇鍦?
**Files:**
- Create: `spec-design/2026-04-23-stage-6-minimal-real-combat-loop-design.md`
- Create: `docs/implementation-plans/2026-04-23-stage-6-minimal-real-combat-loop.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 鍦?`codex/stage-6-minimal-real-combat-loop` 涓庡搴?`.worktrees/` 涓惎鍔ㄦ湰杞?preflight
- [ ] 璁板綍鏈疆閲囩敤 `鍒嗘敮 + worktree` 鐨勫師鍥犮€佺洰鏍囪寖鍥翠笌涓嶅仛椤?- [ ] 鏄庣‘鏈疆閲囩敤 `multi-agent` 浼樺厛璇勪及绛栫暐锛屽苟棰勭暀 `Delegation Log`

## Task 2: 涓?Main 澧炲姞鏈€灏忔埧闂磋繃娓′笌閲嶇疆鑳藉姏

**Files:**
- Modify: `scenes/main/main.tscn`
- Modify: `scripts/main/main.gd`
- Test: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`

- [ ] 鍏堣ˉ绾㈡祴锛屾毚闇插綋鍓?`Main` 杩樹笉鏀寔鏁欑▼鍚庡垏鍏ョ嫭绔嬫垬鏂楁埧涓庢垬鏂楁埧閲嶇疆
- [ ] 璁?`Main` 鑳藉搷搴旀埧闂村彂鍑虹殑杩囨浮璇锋眰锛屽苟鍒囧埌鐩爣鎴块棿涓庣洰鏍囧嚭鐢熺偣
- [ ] 璁?`Main` 鑳藉湪鐜╁ defeated 鍚庨噸缃綋鍓嶆垬鏂楁埧涓庣帺瀹剁姸鎬?- [ ] 淇濇寔杩欏鑳藉姏鍙湇鍔?`TutorialRoom -> CombatTrialRoom` 涓庢垬鏂楁埧鏈閲嶇疆锛屼笉鎵╂垚姝ｅ紡鎴块棿绯荤粺

## Task 3: 鐜╁鐢熷懡銆佸彈鍑讳笌 defeated 闂幆

**Files:**
- Modify: `scripts/player/player_placeholder.gd`
- Possibly Modify: `scenes/player/player_placeholder.tscn`
- Test: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`

- [ ] 鍏堣ˉ绾㈡祴锛屾毚闇插綋鍓嶇帺瀹剁己灏戠敓鍛姐€佸彈鍑汇€佹棤鏁屾椂闂翠笌 defeated 淇″彿
- [ ] 鏂板鏈€灏忕敓鍛界郴缁燂紝榛樿 `max_health = 3`
- [ ] 鏂板 `receive_damage(...)`銆乣health_changed(...)` 涓?`defeated()`
- [ ] 鎺ュ叆鏈€灏忓彈鍑诲嚮閫€銆佺煭鏆傛棤鏁屼笌鍙鎬у弽棣?- [ ] 淇濇寔褰撳墠绉诲姩銆佹敾鍑汇€佸湴闈?`dash` 鐨勬棦鏈夊绾︿笉琚洖褰掔牬鍧?
## Task 4: 鏂板缓 CombatTrialRoom 涓庡熀纭€杩戞垬鏁屼汉

**Files:**
- Create: `scenes/rooms/combat_trial_room.tscn`
- Create: `scripts/rooms/combat_trial_room.gd`
- Create: `scenes/combat/basic_melee_enemy.tscn`
- Create: `scripts/combat/basic_melee_enemy.gd`
- Test: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`

- [ ] 鏂板缓鐙珛鎴樻枟鎴匡紝浣滀负鏁欑▼鍚庣殑绗竴娈电湡瀹炴垬鏂?- [ ] 鏂板缓 1 涓熀纭€杩戞垬鏁屼汉锛岄噰鐢ㄢ€滃皬鑼冨洿宸￠€?+ 鎺ヨЕ浼ゅ + 1 娆¤鍛戒腑鍗冲け鏁堚€濈殑鏈€灏忔ā鍨?- [ ] 鎴樻枟鎴块粯璁ゅ嚭鍙ｉ攣瀹氾紝鏁屼汉琚嚮璐ュ悗鍑哄彛瑙ｉ攣
- [ ] 鎴块棿鏆撮湶鏈€灏忓绾︼細閲嶇疆銆佹彁绀烘枃鏈€佸嚭鐢熺偣涓庤繃娓¤姹?- [ ] 涓嶅紩鍏ュ鏁屼汉銆佽繙绋嬫晫浜恒€佸鏉?AI 鎴栧畬鏁存暟鍊肩郴缁?
## Task 5: HUD 鍗囩骇涓虹湡瀹炴垬鏂楃姸鎬佽鍙?
**Files:**
- Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `scripts/ui/tutorial_hud.gd`
- Test: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`

- [ ] 璁╂垬鏂楅潰鏉跨湡瀹炲弽鏄犵帺瀹剁敓鍛藉€硷紝鑰屼笉鍐嶅彧鏄剧ず鍥哄畾鏂囨湰
- [ ] 淇濇寔 `dash` 鐘舵€佹樉绀虹户缁彲鐢?- [ ] 璁╂彁绀哄尯鑳藉鍦?`TutorialRoom` 鍜?`CombatTrialRoom` 涔嬮棿鍒囨崲瀵瑰簲鏂囨
- [ ] 淇濇寔 HUD 浠嶇劧鏄渶灏忚繍琛屾椂闈㈡澘锛屼笉鎵╀负瀹屾暣鍓嶅彴绯荤粺

## Task 6: Stage 6 鑷姩鍖栭獙璇佷笌鏂囨。鏀跺彛

**Files:**
- Create: `tests/stage6/test_stage_6_minimal_real_combat_loop.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 瑕嗙洊鐜╁鍒濆鐢熷懡銆佸彈鍑绘帀琛€銆佹棤鏁岀獥鍙ｄ笌 defeated 淇″彿
- [ ] 瑕嗙洊 `TutorialRoom` 瀹屾垚鍚庤姹傚垏鍒?`CombatTrialRoom`
- [ ] 瑕嗙洊鎴樻枟鎴垮嚭鍙ｅ垵濮嬮攣瀹氥€佹晫浜鸿鍑昏触鍚庤В閿?- [ ] 瑕嗙洊鐜╁鍦ㄦ垬鏂楁埧姝讳骸鍚庝細琚湰娈靛嵆鏃堕噸缃笖鐢熷懡鍥炴弧
- [ ] 瑕嗙洊 HUD 鐢熷懡鏄剧ず涓庡綋鍓嶆彁绀哄悓姝ユ洿鏂?- [ ] 鑻ヤ娇鐢ㄤ簡閲嶈鐨?`subagent` / `multi-agent`锛岃ˉ鍐?`Delegation Log`

## Recommended Delegation

- `multi-agent` 鎺ㄨ崘鎷嗗垎锛?- 浠ｇ悊 A锛歚Main` 鐨勬埧闂磋繃娓′笌鏈閲嶇疆
- 浠ｇ悊 B锛氱帺瀹剁敓鍛?/ 鍙楀嚮 / 鍩虹杩戞垬鏁屼汉 / `CombatTrialRoom`
- 浠ｇ悊 C锛欻UD 鐪熷疄鐘舵€佽鍙栥€丼tage 6 GUT 涓庢枃妗ｇ暀鐥?- 涓讳唬鐞嗚礋璐ｏ細
- 杈圭晫绾︽潫
- 缁撴灉鏁村悎
- 鏈€缁堥獙璇?- 鍚堝苟鏀跺彛
- 鑻ュ涓瓙浠诲姟闇€瑕佸悓鏃舵敼鍚屼竴鎵规牳蹇冩枃浠讹紝鍏堥檷绾т负 `subagent` 鎴栦富浠ｇ悊涓茶澶勭悊

## Verification

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage3/test_stage_3_combat_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage4/test_stage_4_minimal_ability_difference.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage6/test_stage_6_minimal_real_combat_loop.gd -gexit`
- `git diff --check`

## Completion Criteria

- 鏁欑▼瀹屾垚鍚庤兘绋冲畾杩涘叆 `CombatTrialRoom`
- 鐜╁鎷ユ湁鏈€灏忕敓鍛姐€佸彈鍑汇€佹棤鏁屼笌 defeated 闂幆
- 鎴樻枟鎴跨殑鍩虹杩戞垬鏁屼汉鑳界ǔ瀹氬埗閫犵涓€娆＄湡瀹炲帇鍔?- 鐜╁姝讳骸鍚庝細琚綆鎽╂摝鍦伴噸缃埌鎴樻枟鎴挎湰娈佃捣鐐?- HUD 鑳界湡瀹炲弽鏄犵敓鍛藉€间笌褰撳墠鎴樻枟鎻愮ず
- 闃舵 1 / 2 / 3 / 4 / 5 / 6 鑷姩鍖栭獙璇佸叏閮ㄩ€氳繃
- 褰撳墠缁撴灉瓒充互浣滀负闃舵 7 鐨勭ǔ瀹氬墠缃熀绾?
