# Stage 7 Short Mainline Chain Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development when瀹炵幇寮€濮嬶紝骞跺湪婊¤冻鏉′欢鏃跺疄闄呭惎鐢?`subagent / multi-agent`锛涙湰杞笉鍐嶆帴鍙楀彧鍦ㄨ鍒掗噷鍐欌€滄帹鑽愨€濓紝浣嗘墽琛屾椂鍥為€€涓洪粯璁ゅ崟绾挎帹杩涖€?
**Goal:** 鍦ㄩ樁娈?6 绋冲畾鍩虹嚎涓婏紝鎶婂綋鍓?`TutorialRoom -> CombatTrialRoom` 鎺ㄨ繘涓?`TutorialRoom -> CombatTrialRoom -> GoalTrialRoom` 鐨勭煭閾捐矾涓绘祦绋嬨€?**Architecture:** 淇濈暀鐜版湁鏁欏鎴夸笌瀹炴垬鎴匡紱鏂板 `GoalTrialRoom` 浣滀负娣峰悎闂ㄦ帶鐩爣鎴匡紱`Main` 鍗囩骇涓烘敮鎸佸浐瀹氫笁娈甸『搴忔祦杞殑鏈€灏忎富娴佺▼鎺у埗鍣紱HUD 鎺ュ叆涓夋娴佺▼鎻愮ず銆?**Tech Stack:** Godot 4.6銆丟DScript銆乣.tscn` 鏂囨湰鍦烘櫙銆丟UT銆丳owerShell

---

## Task 1: 鏀跺彛 stage7 preflight 鏂囨。涓庡紑鍙戠幇鍦?
**Files:**
- Create: `spec-design/2026-04-23-stage-7-short-mainline-chain-design.md`
- Create: `docs/implementation-plans/2026-04-23-stage-7-short-mainline-chain.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 鍦?`codex/stage-7-short-mainline-chain` 涓庡搴?`.worktrees/` 涓惎鍔ㄦ湰杞?preflight
- [ ] 璁板綍鏈疆閲囩敤 `鍒嗘敮 + worktree` 鐨勫師鍥犮€佺洰鏍囪寖鍥翠笌涓嶅仛椤?- [ ] 鏄庣‘鏈疆浠ｇ悊鍗忎綔鏄‖绾︽潫锛岃€屼笉鏄蒋寤鸿

## Task 2: 璁?Main 鏀寔涓夋椤哄簭娴佽浆

**Files:**
- Modify: `scenes/main/main.tscn`
- Modify: `scripts/main/main.gd`
- Test: `tests/stage7/test_stage_7_short_mainline_chain.gd`

- [ ] 鍏堣ˉ绾㈡祴锛屾毚闇插綋鍓?`Main` 浠嶅仠鐣欏湪闃舵 6 鐨勫畾鍚戝垏鎴块€昏緫
- [ ] 璁?`Main` 鑳芥寜椤哄簭鎺ㄨ繘 `TutorialRoom -> CombatTrialRoom -> GoalTrialRoom`
- [ ] 淇濇寔鎴块棿鍒囨崲鑳藉姏鍙湇鍔′笁娈电煭閾捐矾锛屼笉鎵╂垚姝ｅ紡鎴块棿鍥剧郴缁?- [ ] 淇濇寔鎴樻枟鎴垮け璐ユ椂浠嶅彧閲嶇疆褰撳墠鎴樻枟鎴匡紝涓嶅洖婊氭暣鏉￠摼璺?
## Task 3: 鏂板缓 GoalTrialRoom 涓庢贩鍚堥棬鎺ф祦绋?
**Files:**
- Create: `scenes/rooms/goal_trial_room.tscn`
- Create: `scripts/rooms/goal_trial_room.gd`
- Possibly Modify: `scenes/combat/basic_melee_enemy.tscn`
- Possibly Modify: `scripts/combat/basic_melee_enemy.gd`
- Test: `tests/stage7/test_stage_7_short_mainline_chain.gd`

- [ ] 鏂板缓 `GoalTrialRoom`锛屽浐瀹氫负鈥滄贩鍚堥棬鎺х洰鏍囨埧鈥?- [ ] 璁╃洰鏍囨埧鍚屾椂鎵胯浇涓€娆＄┖闂撮棬鎺т笌涓€娆℃渶灏忔敾鍑诲瀷浜や簰
- [ ] 璁╂埧闂村湪鐩爣杈炬垚鍚庡彂鍑烘槑纭畬鎴愪俊鍙锋垨杩囨浮璇锋眰
- [ ] 涓嶅紩鍏ョ浜岀被鏁屼汉銆佹柊鑳藉姏銆侀挜鍖欑郴缁熸垨璧勬簮鏀堕泦寰幆

## Task 4: HUD 鍗囩骇涓轰笁娈垫祦绋嬫彁绀?
**Files:**
- Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `scripts/ui/tutorial_hud.gd`
- Possibly Modify: `scripts/rooms/tutorial_room.gd`
- Possibly Modify: `scripts/rooms/combat_trial_room.gd`
- Test: `tests/stage7/test_stage_7_short_mainline_chain.gd`

- [ ] 璁?HUD 鑳芥纭尯鍒嗘暀瀛︽埧銆佸疄鎴樻埧銆佺洰鏍囨埧涓庡畬鎴愭彁绀?- [ ] 淇濇寔鎴樻枟闈㈡澘缁х画鐪熷疄璇诲彇鐢熷懡鍊间笌 `dash` 鐘舵€?- [ ] 涓嶆墿鎴愮嫭绔嬬粨绠?UI 鎴栧畬鏁村墠鍙扮郴缁?
## Task 5: Stage 7 鑷姩鍖栭獙璇佷笌鏂囨。鏀跺彛

**Files:**
- Create: `tests/stage7/test_stage_7_short_mainline_chain.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 瑕嗙洊涓夋鎴块棿椤哄簭鎺ㄨ繘
- [ ] 瑕嗙洊 `GoalTrialRoom` 鐨勬埧闂村绾︺€佸嚭鐢熺偣涓庡畬鎴愭潯浠?- [ ] 瑕嗙洊鐩爣鎴块棬鎺у垵濮嬪叧闂€佹弧瓒虫潯浠跺悗瑙ｉ攣
- [ ] 瑕嗙洊 HUD 涓夋娴佺▼鎻愮ず鍒囨崲
- [ ] 瑕嗙洊 `CombatTrialRoom` 姝讳骸閲嶇疆涓嶅洖婊氭暣鏉￠摼璺?- [ ] 鑻ュ惎鐢ㄤ簡閲嶈鐨?`subagent` / `multi-agent`锛岃ˉ鍐?`Delegation Log`

## Delegation Requirement

### Mandatory Gate

鏈疆鍦ㄦ寮忓疄鐜板墠蹇呴』鍏堝仛浠诲姟鎷嗗垎銆傚彧瑕佸悓鏃舵弧瓒充互涓嬫潯浠讹紝灏卞繀椤诲惎鐢ㄤ唬鐞嗗崗浣滐細

- 瀛樺湪 2 涓互涓婂瓙浠诲姟
- 鍐欏叆鑼冨洿鍙殧绂?- 楠岃瘉鍙嫭绔?- 涓嬩竴姝ヤ笉寮轰緷璧栧崟涓€闃诲缁撴灉

### Default Split

闃舵 7 榛樿鎸変互涓嬫柟寮忓惎鐢?`multi-agent`锛?
- 浠ｇ悊 A锛歚Main` 涓庝笁娈垫埧闂存祦杞绾?- 浠ｇ悊 B锛歚GoalTrialRoom` 涓庨棬鎺ф祦绋?- 浠ｇ悊 C锛欻UD 鍒嗘鎻愮ず銆丼tage 7 GUT銆佹枃妗ｇ暀鐥?
### Allowed Fallback

鑻ュ疄鐜版椂鍙戠幇涓や釜浠ヤ笂浠诲姟浼氭寔缁悓鏃舵敼鍚屼竴鎵规牳蹇冩枃浠讹紝鍒欏厑璁搁檷绾т负锛?
- 鑷冲皯 1 涓?`subagent` 璐熻矗闈為樆濉炰晶浠诲姟
- 涓讳唬鐞嗚礋璐ｉ樆濉炰富绾挎暣鍚?
### Only Valid Exceptions

鍙湁鍦ㄤ互涓嬫儏鍐垫垚绔嬫椂锛屾墠鍏佽涓嶅惎鐢?`multi-agent`锛?
- 闇€姹備粛鏈敹鏁?- 鍗曠偣璋冭瘯灏氭湭瀹氫綅
- 鍐欏叆鑼冨洿鏃犳硶闅旂

鑻ヨЕ鍙戜緥澶栵紝蹇呴』鍦?`docs/progress/2026-04-23.md` 鎴栧綋鏃ュ悗缁棩蹇椾腑鍐欐槑锛?
- 涓轰粈涔堜笉鑳藉惎鐢?- 鍝釜鏉′欢涓嶆弧瓒?- 浣曟椂閲嶆柊璇勪及

## Verification

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage3/test_stage_3_combat_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage4/test_stage_4_minimal_ability_difference.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage5/test_stage_5_tutorial_vertical_slice.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage6/test_stage_6_minimal_real_combat_loop.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage7/test_stage_7_short_mainline_chain.gd -gexit`
- `git diff --check`

## Completion Criteria

- `Main` 鑳界ǔ瀹氭帹杩?`TutorialRoom -> CombatTrialRoom -> GoalTrialRoom`
- `GoalTrialRoom` 鎴愪负鏈夋晥鐨勬贩鍚堥棬鎺х洰鏍囨埧锛岃€屼笉鏄函骞冲彴鎴栫函鎴樻枟鎴?- HUD 鑳介殢鐫€涓夋娴佺▼鍒囨崲鎻愮ず
- `CombatTrialRoom` 鐨勫け璐ラ噸缃粛鍙綔鐢ㄤ簬褰撳墠鎴樻枟鎴?- 闃舵 1 / 2 / 3 / 4 / 5 / 6 / 7 鑷姩鍖栭獙璇佸叏閮ㄩ€氳繃
- 褰撳墠缁撴灉瓒充互浣滀负闃舵 8 鐨勭ǔ瀹氬墠缃熀绾?
