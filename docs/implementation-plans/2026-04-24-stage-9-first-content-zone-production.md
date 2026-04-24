# Stage 9 First Content Zone Production Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development when姝ｅ紡瀹炵幇寮€濮嬶紝骞跺湪婊¤冻鏉′欢鏃跺疄闄呭惎鐢?`subagent / multi-agent`锛涙湰杞噸鐐规槸楠岃瘉闃舵 8 鐨勬ā鏉垮拰閰嶇疆鍖栫粨鏋滆兘鍚︾湡姝ｆ敮鎾戝唴瀹圭敓浜э紝涓嶆帴鍙楀洖閫€鍒拌剼鏈骇涓存椂鎷艰銆?
**Goal:** 鍦ㄩ樁娈?8 绋冲畾鍩虹嚎涓婏紝浜у嚭绗竴娈电湡姝ｅ儚鈥滄父鎴忓尯鍩熲€濈殑 `4-6` 鎴块棿绾挎€т富绾垮唴瀹癸紝鎺ュ叆绗?`2` 绫绘晫浜恒€侀涓寮?checkpoint 鍜岀涓€绉嶆寮忛棬鎺с€?**Architecture:** 淇濇寔褰撳墠閰嶇疆璧勬簮銆丠UD 蹇収鎺ュ彛鍜屾晫浜烘ā鏉垮叆鍙ｄ笉鍙橈紝涓嶆柊澧炴柊鑳藉姏銆佷笉鍋氭敮璺€佷笉鍋氬湴鍥剧郴缁熴€傞€氳繃绾挎€т富绾垮皬鍖哄煙銆佸湴闈㈠啿閿嬫晫銆佹埧闂村叆鍙ｅ瓨妗ｇ偣鍜屽紑鍏抽棬锛岄獙璇佸唴瀹圭敓浜ч摼璺凡缁忔垚绔嬨€?**Tech Stack:** Godot 4.6銆丟DScript銆乣.tscn` 鏂囨湰鍦烘櫙銆丟UT銆丳owerShell

---

## Task 1: 鏀跺彛 stage9 preflight 鏂囨。涓庡紑鍙戠幇鍦?
**Files:**
- Create: `spec-design/2026-04-24-stage-9-first-content-zone-production-design.md`
- Create: `docs/implementation-plans/2026-04-24-stage-9-first-content-zone-production.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-24.md`

- [ ] 鍦?`codex/stage-9-first-content-zone-production` 涓庡搴?`.worktrees/` 涓惎鍔ㄦ湰杞?preflight
- [ ] 璁板綍鏈疆閲囩敤 `鍒嗘敮 + worktree` 鐨勫師鍥犮€佺洰鏍囪寖鍥翠笌涓嶅仛椤?- [ ] 鏄庣‘鏈疆鏄€滈涓皬鍖哄煙鍐呭鐢熶骇鈥濓紝涓嶆槸缁х画鍋?stage8 绯荤粺鏀跺彛
- [ ] 鍥哄畾鏈疆鍏抽敭閫夋嫨锛?  - 绗?2 绫绘晫浜猴細`鍦伴潰鍐查攱鏁宍
  - checkpoint锛歚鎴块棿鍏ュ彛瀛樻。鐐筦
  - 闂ㄦ帶锛歚寮€鍏抽棬`
  - 鍖哄煙缁撴瀯锛歚绾挎€т富绾垮尯`

## Task 2: 鎼缓棣栦釜绾挎€т富绾垮皬鍖哄煙

**Files:**
- Create/Modify: new room scenes and scripts for the stage9 content zone
- Modify: `scripts/main/main.gd` only as needed for鎺ュ叆鏂板尯鍩?- Test: `tests/stage9/test_stage_9_first_content_zone_production.gd`

- [ ] 鍏堣ˉ绾㈡祴锛屾毚闇插綋鍓嶄富绾胯繕娌℃湁 `4-6` 鎴块棿鐨勫皬鍖哄煙缁撴瀯
- [ ] 鍥哄畾鍋?`4-6` 鎴块棿鐨勭嚎鎬т富绾垮尯锛屼笉鍋氭敮璺紝涓嶅仛鍗婂紑鏀惧洖鐜?- [ ] 鎺ㄨ崘鎴块棿鏋勬垚涓猴細
  - 鍏ュ彛鎴?  - 鍩虹鎴樻枟鎴?  - 鍐查攱鏁岄娆℃暀瀛︽埧
  - 寮€鍏抽棬闂ㄦ帶鎴?  - 娣峰悎鎴樻枟/闂ㄦ帶鎴?  - 鍖哄煙缁堢偣鎴?- [ ] 淇濇寔褰撳墠涓夋鍘熷瀷閾捐矾涓嶈鎺ㄧ炕锛宻tage9 浣滀负鏂板唴瀹瑰尯鍩熺嫭绔嬫帴鍏?
## Task 3: 鏂板绗?2 绫绘晫浜衡€滃湴闈㈠啿閿嬫晫鈥?
**Files:**
- Create/Modify: enemy scene/script/config under current enemy template path
- Modify: room scenes that place the new enemy
- Test: `tests/stage9/test_stage_9_first_content_zone_production.gd`

- [ ] 鍏堣ˉ绾㈡祴锛屾毚闇插綋鍓嶅彧鏈?`BasicMeleeEnemy`
- [ ] 鏂板鈥滃湴闈㈠啿閿嬫晫鈥濓紝缁х画缁ф壙褰撳墠鍩虹鏁屼汉妯℃澘鍏ュ彛
- [ ] 鍥哄畾琛屼负杈圭晫锛?  - 甯告€佺煭璺濈宸￠€绘垨寰呮満
  - 杩涘叆瑙﹀彂鑼冨洿鍚庡仛涓€娆℃槑鏄剧殑姘村钩鍐查攱
  - 淇濇寔鎺ヨЕ浼ゅ
  - 缁х画娌跨敤褰撳墠 `receive_attack(...)` 涓?`defeated` 濂戠害
- [ ] 涓嶅紩鍏ヨ繙绋嬫晫浜恒€佹姢鐩炬晫浜恒€佺簿鑻辨晫浜烘垨澶氶樁娈?AI

## Task 4: 鎺ュ叆棣栦釜姝ｅ紡 checkpoint 涓庡紑鍏抽棬闂ㄦ帶

**Files:**
- Modify: `scripts/main/main.gd`
- Modify/Create: room scripts/scenes used in the stage9 zone
- Test: `tests/stage9/test_stage_9_first_content_zone_production.gd`

- [ ] 鍏堣ˉ绾㈡祴锛屾毚闇插綋鍓嶆病鏈夋寮?checkpoint 涓庡紑鍏抽棬涓荤嚎闂ㄦ帶
- [ ] 鍥哄畾 checkpoint 涓衡€滄埧闂村叆鍙ｅ瓨妗ｇ偣鈥?- [ ] 鍥哄畾鏇存柊瑙勫垯锛?  - 閫氳繃鍏抽敭鎴块棿鍚庡埛鏂版仮澶嶇偣
  - 澶辫触鍚庝粠鏈€杩戜竴娆″凡婵€娲?checkpoint 鎴块棿鍏ュ彛鎭㈠
- [ ] 鍥哄畾闂ㄦ帶涓衡€滃紑鍏抽棬鈥?- [ ] 璁╁紑鍏抽棬涓庡尯鍩熸帹杩涚粦瀹氾紝渚嬪娓呮埧鎴栬Е鍙戞満鍏冲悗瑙ｉ攣涓嬩竴鎵囬棬
- [ ] 涓嶅紩鍏ュ瓨妗ｇ郴缁熴€侀挜鍖欑郴缁熸垨鍙牬鍧忛樆鎸′綔涓轰富闂ㄦ帶

## Task 5: 澶嶇敤閰嶇疆璧勬簮涓?HUD 鏈€灏忔墿灞?
**Files:**
- Modify/Create: room flow configs under current config paths
- Modify: `scripts/ui/tutorial_hud.gd` only as needed for stage9 prompt support
- Test: `tests/stage9/test_stage_9_first_content_zone_production.gd`

- [ ] 璁?stage9 灏忓尯鍩熷疄闄呭鐢ㄥ綋鍓嶉樁娈?8 宸叉湁鐨勯厤缃祫婧愯矾寰勫拰妯″紡
- [ ] 鏂板涓庡皬鍖哄煙鐩稿叧鐨勶細
  - 鎴块棿鏍囬 / 鎻愮ず
  - checkpoint 鎻愮ず
  - 寮€鍏抽棬鐘舵€佹渶灏忓彲璇绘€ф彁绀?- [ ] 淇濇寔 HUD 缁х画娌跨敤褰撳墠绗簩杞帴鍙ｏ紝涓嶆墿鎴愮涓夎疆 UI 绯荤粺
- [ ] 涓嶅厑璁镐负姹傚揩鍥為€€鍒拌剼鏈噷纭紪鐮佷竴鎵规柊鍙傛暟

## Task 6: Stage 9 鑷姩鍖栭獙璇佷笌鏂囨。鏀跺彛

**Files:**
- Create: `tests/stage9/test_stage_9_first_content_zone_production.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-24.md`

- [ ] 瑕嗙洊绾挎€т富绾垮尯鍙粠鍏ュ彛鎺ㄨ繘鍒扮粓鐐?- [ ] 瑕嗙洊绗?2 绫绘晫浜哄凡鎺ュ叆涓旇涓轰笌鍩虹鏁屼汉鏄庢樉涓嶅悓
- [ ] 瑕嗙洊 checkpoint 婵€娲诲悗澶辫触浼氫粠鏈€杩?checkpoint 鎴块棿鍏ュ彛鎭㈠
- [ ] 瑕嗙洊寮€鍏抽棬榛樿鍏抽棴銆佹弧瓒虫潯浠跺悗瑙ｉ攣
- [ ] 瑕嗙洊灏忓尯鍩熸埧闂撮厤缃祫婧愬凡琚疄闄呰鍙?- [ ] 纭 Stage 1-8 娴嬭瘯涓嶅洖褰?- [ ] 鑻ュ惎鐢ㄤ簡閲嶈鐨?`subagent` / `multi-agent`锛岃ˉ鍐?`Delegation Log`

## Delegation Requirement

### Mandatory Gate

鏈疆鍦ㄦ寮忓疄鐜板墠蹇呴』鍏堝仛浠诲姟鎷嗗垎銆傚彧瑕佸悓鏃舵弧瓒充互涓嬫潯浠讹紝灏卞繀椤诲惎鐢ㄤ唬鐞嗗崗浣滐細

- 瀛樺湪 2 涓互涓婂瓙浠诲姟
- 鍐欏叆鑼冨洿鍙殧绂?- 楠岃瘉鍙嫭绔?- 涓嬩竴姝ヤ笉寮轰緷璧栧崟涓€闃诲缁撴灉

### Default Split

闃舵 9 榛樿鎸変互涓嬫柟寮忓惎鐢?`multi-agent`锛?
- 浠ｇ悊 A锛氬皬鍖哄煙鎴块棿涓庡紑鍏抽棬 / checkpoint 娴佺▼
- 浠ｇ悊 B锛氬湴闈㈠啿閿嬫晫瀹炵幇涓庢晫浜洪厤缃帴鍏?- 浠ｇ悊 C锛歋tage 9 GUT銆丠UD 鏈€灏忔彁绀烘帴绾夸笌鏂囨。鐣欑棔

### Allowed Fallback

鑻ュ疄鐜版椂鍙戠幇涓や釜浠ヤ笂浠诲姟浼氭寔缁悓鏃舵敼鍚屼竴鎵规牳蹇冩枃浠讹紝鍒欏厑璁搁檷绾т负锛?
- 鑷冲皯 1 涓?`subagent` 璐熻矗闈為樆濉炰晶浠诲姟
- 涓讳唬鐞嗚礋璐ｉ樆濉炰富绾挎暣鍚?
### Only Valid Exceptions

鍙湁鍦ㄤ互涓嬫儏鍐垫垚绔嬫椂锛屾墠鍏佽涓嶅惎鐢?`multi-agent`锛?
- 闇€姹備粛鏈敹鏁?- 鍗曠偣璋冭瘯灏氭湭瀹氫綅
- 鍐欏叆鑼冨洿鏃犳硶闅旂
- 褰撳墠浼氳瘽宸ュ叿鎺堟潈杈圭晫涓嶅厑璁稿疄闄呭惎鐢?
鑻ヨЕ鍙戜緥澶栵紝蹇呴』鍦?`docs/progress/2026-04-24.md` 鎴栧綋鏃ュ悗缁棩蹇椾腑鍐欐槑锛?
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
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage9/test_stage_9_first_content_zone_production.gd -gexit`
- `git diff --check`

## Completion Criteria

- 宸插畬鎴愪竴涓?`4-6` 鎴块棿鐨勭嚎鎬т富绾垮皬鍖哄煙
- 绗?`2` 绫绘晫浜衡€滃湴闈㈠啿閿嬫晫鈥濆凡鎺ュ叆骞剁ǔ瀹氬伐浣?- 棣栦釜姝ｅ紡 checkpoint 涓庡紑鍏抽棬闂ㄦ帶宸叉帴鍏ヤ富娴佺▼
- 鐜版湁閰嶇疆璧勬簮銆丠UD 鎺ュ彛鍜屾晫浜烘ā鏉垮凡琚湡姝ｇ敤浜庡唴瀹圭敓浜?- 闃舵 1 / 2 / 3 / 4 / 5 / 6 / 7 / 8 / 9 鑷姩鍖栭獙璇佸叏閮ㄩ€氳繃
- 褰撳墠缁撴灉瓒充互鎵挎帴 `闃舵 10锛氭垬鏂楀彉鍖栦笌杞婚噺鎴愰暱寰幆`

