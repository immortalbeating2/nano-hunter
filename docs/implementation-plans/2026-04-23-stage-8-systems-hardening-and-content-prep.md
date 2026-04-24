# Stage 8 Systems Hardening And Content Prep Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development when姝ｅ紡瀹炵幇寮€濮嬶紝骞跺湪婊¤冻鏉′欢鏃跺疄闄呭惎鐢?`subagent / multi-agent`锛涙湰杞噸鐐规槸绋冲浐鎺ュ彛涓庨厤缃敹鍙ｏ紝涓嶆帴鍙楃户缁互鑴氭湰绾т复鏃堕€昏緫鎵╁唴瀹广€?
**Goal:** 鍦ㄩ樁娈?7 绋冲畾鍩虹嚎涓婏紝浼樺厛瀹屾垚鍙傛暟鏁版嵁鍖栵紝鍏舵鏀跺彛 HUD 绗簩杞帴鍙ｏ紝鏈€鍚庢妸 `BasicMeleeEnemy` 鏁寸悊鎴愬彲澶嶇敤鏁屼汉妯℃澘锛屼负鍚庣画鎵╁唴瀹瑰缓绔嬫洿绋崇殑宸ョ▼鍩虹嚎銆?**Architecture:** 淇濈暀褰撳墠 `Main -> TutorialRoom -> CombatTrialRoom -> GoalTrialRoom` 鐨勪笁娈电煭閾捐矾涓嶅彉锛屼笉鏂板鑳藉姏銆佷笉鏂板鎴块棿銆佷笉鏂板鏁屼汉绉嶇被銆傞€氳繃鍙閰嶇疆璧勬簮銆佺粺涓€ HUD 涓婁笅鏂囨帴鍙ｄ笌鍩虹鏁屼汉妯℃澘锛屾妸褰撳墠鍘熷瀷涓殑鍏抽敭涓存椂閫昏緫鏀跺彛鎴愭洿鍙鐢ㄧ殑绋冲畾缁撴瀯銆?**Tech Stack:** Godot 4.6銆丟DScript銆乣.tscn` 鏂囨湰鍦烘櫙銆丟UT銆丳owerShell

---

## Task 1: 鏀跺彛 stage8 preflight 鏂囨。涓庡紑鍙戠幇鍦?
**Files:**
- Create: `spec-design/2026-04-23-stage-8-systems-hardening-and-content-prep-design.md`
- Create: `docs/implementation-plans/2026-04-23-stage-8-systems-hardening-and-content-prep.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 鍦?`codex/stage-8-systems-hardening-and-content-prep` 涓庡搴?`.worktrees/` 涓惎鍔ㄦ湰杞?preflight
- [ ] 璁板綍鏈疆閲囩敤 `鍒嗘敮 + worktree` 鐨勫師鍥犮€佺洰鏍囪寖鍥翠笌涓嶅仛椤?- [ ] 鏄庣‘鏈疆涓荤洰鏍囨槸鈥滅ǔ鍥烘帴鍙ｂ€濓紝涓嶆槸鈥滅户缁墿 stage7 鍐呭鈥?- [ ] 鏄庣‘鍙傛暟鏁版嵁鍖栧彧鍋氬埌鍙閰嶇疆璧勪骇锛屾ā鏉垮寲鍙厛钀藉湪鏁屼汉渚?
## Task 2: 鐜╁銆佹晫浜轰笌鎴块棿鍏抽敭鍙傛暟鏁版嵁鍖?
**Files:**
- Create: `scripts/configs/player_config.gd` or equivalent `Resource`
- Create: `scripts/configs/basic_enemy_config.gd` or equivalent `Resource`
- Create: room flow config resource(s) for current chain
- Modify: `scripts/player/player_placeholder.gd`
- Modify: `scripts/combat/basic_melee_enemy.gd`
- Modify: current room scripts as needed
- Test: `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`

- [ ] 鍏堣ˉ绾㈡祴锛屾毚闇插綋鍓嶅叧閿弬鏁颁粛鏁ｈ惤鍦ㄨ剼鏈鍑哄瓧娈典腑
- [ ] 鎶婄帺瀹跺叧閿弬鏁版敹鍙ｅ埌鍙閰嶇疆璧勬簮
- [ ] 鎶?`BasicMeleeEnemy` 鍏抽敭鍙傛暟鏀跺彛鍒板彧璇婚厤缃祫婧?- [ ] 鎶婂綋鍓嶄笁娈典富娴佺▼涓殑鍏抽敭闂ㄦ帶鏂囨鎴栭槇鍊兼敹鍙ｅ埌鏈€灏忔埧闂撮厤缃祫婧?- [ ] 淇濇寔鍒濆鍖栬矾寰勭畝鍗曪細鍦烘櫙瀹炰緥鎸佹湁閰嶇疆璧勬簮骞跺湪鍥哄畾鍏ュ彛璇诲彇搴旂敤

## Task 3: HUD 绗簩杞帴鍙ｆ敹鍙?
**Files:**
- Modify: `scripts/ui/tutorial_hud.gd`
- Possibly Modify: `scenes/ui/tutorial_hud.tscn`
- Modify: `scripts/main/main.gd`
- Modify: room scripts as needed
- Test: `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`

- [ ] 鍏堣ˉ绾㈡祴锛屾毚闇插綋鍓?HUD 杩囧害渚濊禆闆舵暎 `has_method()` 鎺㈡祴
- [ ] 鍥哄畾鎴块棿渚?HUD 涓婁笅鏂囨帴鍙?- [ ] 鍥哄畾鐜╁渚ф垬鏂楃姸鎬佸彧璇绘帴鍙?- [ ] 璁?HUD 缁熶竴閫氳繃绋冲畾鎺ュ彛璇诲彇姝ラ鏍囬銆佹彁绀烘枃鏈€佺敓鍛藉€间笌 `dash` 鐘舵€?- [ ] 淇濇寔 HUD 浠嶆槸褰撳墠鍞竴鍓嶅彴鍏ュ彛锛屼笉鎵╃粨绠?UI銆佽彍鍗曟垨鑳屽寘

## Task 4: 鍩虹鏁屼汉妯℃澘鍖?
**Files:**
- Modify: `scripts/combat/basic_melee_enemy.gd`
- Possibly Create: `scripts/combat/base_enemy.gd` or equivalent
- Possibly Create: shared enemy config or helper layer
- Test: `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`

- [ ] 鍏堣ˉ绾㈡祴锛屾毚闇插綋鍓?`BasicMeleeEnemy` 浠嶆槸鍗曚綋鍘熷瀷瀹炵幇
- [ ] 鎶藉嚭鍩虹鏁屼汉鍏辩敤濂戠害涓庢渶灏忛鏋?- [ ] 淇濇寔 `receive_attack(...)` 涓?`defeated` 淇″彿涓嶅洖褰?- [ ] 璁╁綋鍓嶈繎鎴樻晫浜虹户缁綔涓虹涓€绉嶅叿浣撴ā鏉垮疄渚嬭繍琛?- [ ] 涓嶅湪鏈疆鏂板绗簩绫绘晫浜?
## Task 5: Stage 8 鑷姩鍖栭獙璇佷笌鏂囨。鏀跺彛

**Files:**
- Create: `tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-23.md`

- [ ] 瑕嗙洊鐜╁鍏抽敭鍙傛暟宸蹭粠閰嶇疆璧勬簮璇诲彇骞舵垚鍔熷簲鐢?- [ ] 瑕嗙洊鍩虹杩戞垬鏁屼汉鍏抽敭鍙傛暟宸蹭粠閰嶇疆璧勬簮璇诲彇骞舵垚鍔熷簲鐢?- [ ] 瑕嗙洊鎴块棿/HUD 涓婁笅鏂囪兘閫氳繃缁熶竴鎺ュ彛绋冲畾璇诲彇
- [ ] 瑕嗙洊鍩虹鏁屼汉妯℃澘濂戠害涓嶅洖褰?- [ ] 瑕嗙洊鏃㈡湁 Stage 1-7 娴嬭瘯缁х画閫氳繃
- [ ] 鑻ュ惎鐢ㄤ簡閲嶈鐨?`subagent` / `multi-agent`锛岃ˉ鍐?`Delegation Log`

## Delegation Requirement

### Mandatory Gate

鏈疆鍦ㄦ寮忓疄鐜板墠蹇呴』鍏堝仛浠诲姟鎷嗗垎銆傚彧瑕佸悓鏃舵弧瓒充互涓嬫潯浠讹紝灏卞繀椤诲惎鐢ㄤ唬鐞嗗崗浣滐細

- 瀛樺湪 2 涓互涓婂瓙浠诲姟
- 鍐欏叆鑼冨洿鍙殧绂?- 楠岃瘉鍙嫭绔?- 涓嬩竴姝ヤ笉寮轰緷璧栧崟涓€闃诲缁撴灉

### Default Split

闃舵 8 榛樿鎸変互涓嬫柟寮忓惎鐢?`multi-agent`锛?
- 浠ｇ悊 A锛氬弬鏁版暟鎹寲涓庨厤缃祫婧愭帴鍏?- 浠ｇ悊 B锛欻UD 绗簩杞帴鍙ｆ敹鍙?- 浠ｇ悊 C锛氬熀纭€鏁屼汉妯℃澘鍖栥€丼tage 8 GUT 涓庢枃妗ｇ暀鐥?
### Allowed Fallback

鑻ュ疄鐜版椂鍙戠幇涓や釜浠ヤ笂浠诲姟浼氭寔缁悓鏃舵敼鍚屼竴鎵规牳蹇冩枃浠讹紝鍒欏厑璁搁檷绾т负锛?
- 鑷冲皯 1 涓?`subagent` 璐熻矗闈為樆濉炰晶浠诲姟
- 涓讳唬鐞嗚礋璐ｉ樆濉炰富绾挎暣鍚?
### Only Valid Exceptions

鍙湁鍦ㄤ互涓嬫儏鍐垫垚绔嬫椂锛屾墠鍏佽涓嶅惎鐢?`multi-agent`锛?
- 闇€姹備粛鏈敹鏁?- 鍗曠偣璋冭瘯灏氭湭瀹氫綅
- 鍐欏叆鑼冨洿鏃犳硶闅旂
- 褰撳墠浼氳瘽宸ュ叿鎺堟潈杈圭晫涓嶅厑璁稿疄闄呭惎鐢?
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
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage8/test_stage_8_systems_hardening_and_content_prep.gd -gexit`
- `git diff --check`

## Completion Criteria

- 鐜╁銆佸熀纭€杩戞垬鏁屼汉涓庡綋鍓嶄富娴佺▼鍏抽敭鍙傛暟宸蹭粠鍙閰嶇疆璧勬簮绋冲畾璇诲彇
- HUD 宸叉敼涓虹粺涓€娑堣垂绋冲畾鍙鎺ュ彛锛岃€屼笉鏄户缁緷璧栭浂鏁ｆ帰娴?- `BasicMeleeEnemy` 宸叉暣鐞嗘垚鍙鐢ㄧ殑鍩虹鏁屼汉妯℃澘鍏ュ彛
- `Main`銆佷笁娈垫埧闂翠富娴佺▼涓庡綋鍓嶇帺娉曢棴鐜繚鎸佺ǔ瀹氾紝涓嶅洜绯荤粺鏀跺彛鑰屽洖褰?- 闃舵 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 鑷姩鍖栭獙璇佸叏閮ㄩ€氳繃
- 褰撳墠缁撴灉瓒充互浣滀负鍚庣画缁х画鎵╁唴瀹圭殑绋冲畾鍓嶇疆鍩虹嚎

