# Stage 5 Tutorial Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 鍦ㄩ樁娈?4 绋冲畾鍩虹嚎涓婂仛鍑轰竴涓€滃崟鍦烘櫙銆佷綆鍘嬨€佸彲鐞嗚В鈥濈殑鏁欑▼鍖哄瀭鐩村垏鐗囷紝鎶?`move / jump / dash / attack` 涓叉垚鏈€灏忎富娴佺▼锛屽苟鎺ュ叆鏈€灏?HUD銆?
**Architecture:** 灏?`Main` 浠庘€淭estRoom 涓撶敤鍏ュ彛鈥濊縼绉讳负鈥滀富鎴块棿濂戠害鍏ュ彛鈥濓紝榛樿瀹炰緥鍖栨柊鐨?`TutorialRoom`銆備繚鐣?`TestRoom` 浣滀负鍥炲綊涓庤皟鍙傛矙鐩掋€傛暀绋嬪尯閲囩敤鍗曞満鏅嚎鎬ф祦绋嬶紝鎴樻枟鏁欏缁х画娌跨敤鏈€灏忓彈鍑诲绾︼紝涓嶅紩鍏ユ寮忔晫浜?AI銆佸畬鏁寸敓鍛?姝讳骸寰幆鎴栨埧闂寸郴缁熼噸鏋勩€?
**Tech Stack:** Godot 4.6銆丟DScript銆乣.tscn` 鏂囨湰鍦烘櫙銆丟UT銆丳owerShell

---

## Task 1: 鏀跺彛闃舵 5 鍓嶇疆鏂囨。涓庡紑鍙戠幇鍦?
**Files:**
- Create: `spec-design/2026-04-22-stage-5-tutorial-vertical-slice-design.md`
- Create: `docs/implementation-plans/2026-04-22-stage-5-tutorial-vertical-slice.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-22.md`

- [ ] 鍦?`codex/stage-5-tutorial-vertical-slice` 涓庡搴?`.worktrees/` 涓惎鍔ㄦ湰杞?preflight銆?- [ ] 璁板綍鏈疆閲囩敤 `鍒嗘敮 + worktree` 鐨勫師鍥犮€侀樁娈电洰鏍囥€佸紑鍙戣竟鐣屼笌楠岃瘉棰勬湡銆?- [ ] 鏄庣‘鏈疆鍙仛鏁欑▼鍖哄瀭鐩村垏鐗囷紝涓嶆贩鍏ュ畬鏁存晫浜?AI銆佹寮忔浜″惊鐜垨鎴块棿绯荤粺閲嶆瀯銆?
## Task 2: 杩佺Щ Main 鐨勪富鎴块棿濂戠害

**Files:**
- Modify: `scenes/main/main.tscn`
- Modify: `scripts/main/main.gd`
- Test: `tests/stage1/test_stage_1_startup_skeleton.gd`

- [ ] 鍏堣ˉ澶辫触娴嬭瘯锛屾毚闇?`Main` 浠嶅浐瀹氫緷璧?`TestRoom` 鐨勫巻鍙茶€﹀悎銆?- [ ] 灏嗕富鎴块棿鑺傜偣杩佺Щ涓洪€氱敤鍛藉悕锛屼緥濡?`Room`銆?- [ ] 淇濇寔 `Main` 缁х画鍙緷璧?`get_camera_limits() -> Rect2i` 濂戠害銆?- [ ] 淇濊瘉鐜╁鐢熸垚銆佺浉鏈洪檺浣嶄笌鐜版湁鍚姩楠ㄦ灦鍦ㄦ柊濂戠害涓嬩粛鎴愮珛銆?
## Task 3: 鏂板缓 TutorialRoom 涓庢暀绋嬮棬鎺?
**Files:**
- Create: `scenes/rooms/tutorial_room.tscn`
- Create: `scripts/rooms/tutorial_room.gd`
- Possibly Modify: `scenes/combat/training_dummy.tscn` or add tutorial blocker variant
- Test: `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`

- [ ] 鏂板缓鍗曞満鏅?`TutorialRoom`锛屾壙杞解€滅Щ鍔?璺宠穬 -> dash -> 鏀诲嚮 -> 鍑哄彛鈥濈殑绾挎€ф祦绋嬨€?- [ ] 鍔犲叆浣庡帇闂ㄦ帶锛屽厑璁哥帺瀹跺師鍦伴噸澶嶅皾璇曪紝涓嶆帴姝ｅ紡澶辫触閲嶆潵銆?- [ ] 鎴樻枟鏁欏浼樺厛澶嶇敤 `TrainingDummy` 濂戠害锛屾垨鏂板鍚屽绾︾殑鏁欑▼闃绘尅鐩爣銆?- [ ] 淇濇寔 `TestRoom` 涓嶆壙鎷呬富娴佺▼鍏ュ彛鑱岃矗銆?
## Task 4: 鎺ュ叆鏈€灏?HUD

**Files:**
- Create: `scenes/ui/tutorial_hud.tscn`
- Create: `scripts/ui/tutorial_hud.gd`
- Modify: `scenes/main/main.tscn` or `TutorialRoom` integration point
- Test: `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`

- [ ] 鏂板鏁欏鎻愮ず鍖猴紝鏄剧ず褰撳墠鐩爣涓庢寜閿彁绀恒€?- [ ] 鏂板鏈€灏忔垬鏂楅潰鏉垮尯锛屽彧鍋氬睍绀猴紝涓嶆帴瀹屾暣鎵ｈ / 姝讳骸 / 鎭㈠寰幆銆?- [ ] 璁?HUD 鑳介殢鏁欑▼姝ラ鎺ㄨ繘鏇存柊鎻愮ず鍐呭銆?- [ ] 淇濇寔 HUD 鏈嶅姟浜庣悊瑙ｏ紝涓嶉伄鎸′富瑕佹父鐜╁尯鍩熴€?
## Task 5: 鑷姩鍖栭獙璇佷笌鏂囨。鏀跺彛

**Files:**
- Modify: `tests/stage1/test_stage_1_startup_skeleton.gd`
- Create: `tests/stage5/test_stage_5_tutorial_vertical_slice.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-22.md`

- [ ] 瑕嗙洊 `Main` 榛樿杩涘叆鏁欑▼涓绘埧闂达紝鑰屼笉鏄?`TestRoom`銆?- [ ] 瑕嗙洊涓绘埧闂村绾︺€丠UD 榛樿鏄剧ず涓庣涓€鏉℃暀绋嬫彁绀恒€?- [ ] 瑕嗙洊鏁欑▼椤哄簭鎺ㄨ繘銆乣dash` 闂ㄦ銆佹敾鍑婚樆鎸＄洰鏍囦笌鍑哄彛瑙ｉ攣銆?- [ ] 鑻ヤ娇鐢ㄤ簡閲嶈鐨?`subagent` / `multi-agent`锛岃ˉ鍐?`Delegation Log`銆?
## Recommended Delegation

- `multi-agent` 鎺ㄨ崘鎷嗗垎锛?- 浠ｇ悊 A锛歚Main` 涓庝富鎴块棿濂戠害杩佺Щ
- 浠ｇ悊 B锛歚TutorialRoom`銆丠UD 涓庨棬鎺ф祦绋?- 浠ｇ悊 C锛歋tage 1 濂戠害杩佺Щ娴嬭瘯銆丼tage 5 GUT 涓庢枃妗ｇ暀鐥?- 涓讳唬鐞嗚礋璐ｏ細
- 杈圭晫绾︽潫
- 缁撴灉鏁村悎
- 鏈€缁堥獙璇?- 鍚堝苟鏀跺彛
- 鑻ュ嚭鐜板涓瓙浠诲姟鍚屾椂鍐欏叆鍚屼竴鎵规牳蹇冩枃浠讹紝鍏堥檷绾т负 `subagent` 鎴栬浆鍥炰富浠ｇ悊涓茶澶勭悊

## Verification

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage3/test_stage_3_combat_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage4/test_stage_4_minimal_ability_difference.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit`
- `git diff --check`

## Completion Criteria

- `Main` 宸茶縼绉讳负涓绘埧闂村绾﹀叆鍙ｏ紝骞堕粯璁よ繘鍏ユ暀绋嬪尯
- 鏁欑▼鍖哄彲椤哄簭瀹屾垚绉诲姩/璺宠穬銆乣dash`銆佹敾鍑讳笌鍑哄彛娴佺▼
- 鏈€灏?HUD 宸蹭笂绾匡紝涓旀垬鏂楅潰鏉垮彧鍋氬睍绀?- 闃舵 1 / 2 / 3 / 4 / 5 鑷姩鍖栭獙璇佸叏閮ㄩ€氳繃
- 褰撳墠缁撴灉瓒充互浣滀负涓嬩竴杞瀭鐩村垏鐗囨墿灞曠殑绋冲畾鍩虹嚎

