# Stage 4 Minimal Ability Difference Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 鍦ㄩ樁娈?3 绋冲畾鍩虹嚎涓婏紝閫氳繃鈥滀粎鍦伴潰鍐插埡 + TestRoom 娣峰悎楠岃瘉鈥濊瘉鏄庢渶灏忚兘鍔涘樊寮傚凡缁忓叿澶囧疄闄呯帺娉曚环鍊笺€?
**Architecture:** 淇濇寔 `Main.tscn + Runtime + TestRoom + PlayerPlaceholder + TrainingDummy` 鐨勭幇鏈夐鏋朵笉鍙橈紝鍦ㄥ崰浣嶇帺瀹朵笂澧為噺鍔犲叆 `dash` 杈撳叆涓庣姸鎬侊紝骞跺彧鎵╁睍 `TestRoom` 鏉ラ獙璇佹帰绱㈤棬妲涘拰鎴樻枟闂ㄦ銆傜户缁部鐢ㄩ樁娈?3 鐨勬敾鍑讳笌鍙楀嚮鏈€灏忓绾︼紝涓嶅紩鍏ョ┖涓啿鍒恒€佹棤鏁屽抚銆佹敾鍑诲彇娑堟垨 HUD銆?
**Tech Stack:** Godot 4.6銆丟DScript銆乣.tscn` 鏂囨湰鍦烘櫙銆丟UT銆丳owerShell

---

## Task 1: 鏀跺彛 Stage 4 鍓嶇疆鏂囨。涓庡紑鍙戠幇鍦?
**Files:**
- Create: `spec-design/2026-04-22-stage-4-minimal-ability-difference-design.md`
- Create: `docs/implementation-plans/2026-04-22-stage-4-minimal-ability-difference.md`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Create: `docs/progress/2026-04-22.md`
- Modify: `AGENTS.md`

- [ ] 鍦?`codex/stage-4-minimal-ability-difference` 涓庡搴?`.worktrees/` 涓惎鍔ㄦ湰杞?preflight銆?- [ ] 鎶?`AGENTS.md` 鐨勪唬鐞嗗崗浣滆鍒欏悓姝ュ埌褰撳墠 worktree锛岄伩鍏嶅疄鐜伴樁娈垫寜鏃ц鍒欒鍒ゃ€?- [ ] 璁板綍鏈疆鍒嗘敮 / worktree 妯″紡銆侀樁娈电洰鏍囥€佸欢鍚庨」褰掑睘涓庨獙璇侀鏈熴€?
## Task 2: 鏂板鍐插埡杈撳叆涓庢渶灏忕姸鎬佹満

**Files:**
- Modify: `project.godot`
- Modify: `scripts/player/player_placeholder.gd`
- Test: `tests/stage4/test_stage_4_minimal_ability_difference.gd`

- [ ] 涓?`dash` 杈撳叆濂戠害琛ュけ璐ユ祴璇曘€?- [ ] 鍦ㄧ帺瀹惰剼鏈腑鏂板 `dash` 鐘舵€佷笌瀵煎嚭璋冨弬瀛楁銆?- [ ] 鍥哄畾鏈疆鍐插埡杈圭晫锛?  - 鍙厑璁稿湴闈㈣Е鍙?  - 鍙厑璁镐粠 `idle` / `run` / `land` 杩涘叆
  - 涓嶈兘鍦?`attack` 涓Е鍙?  - 涓嶈兘鍦ㄧ┖涓Е鍙?- [ ] 璺戦樁娈?4 娴嬭瘯锛岀‘璁ゅ啿鍒虹姸鎬佷笌鏂瑰悜濂戠害杞豢銆?
## Task 3: 鎵╁睍 TestRoom 鐨勮兘鍔涘樊寮傞獙璇佺偣

**Files:**
- Modify: `scenes/rooms/test_room.tscn`
- Test: `tests/stage4/test_stage_4_minimal_ability_difference.gd`

- [ ] 鍦?`TestRoom` 涓柊澧炰竴涓帰绱㈤棬妲涳紝璇佹槑涓嶇敤鍐插埡闅句互绋冲畾閫氳繃銆?- [ ] 鍦?`TestRoom` 涓柊澧炰竴涓垬鏂楅棬妲涳紝璇佹槑鍐插埡鑳芥槑鏄炬敼鍠勬帴鏁岃妭濂忔垨鍑烘墜浣嶇疆銆?- [ ] 淇濇寔 `TrainingDummy` 涓庨樁娈?3 鐨勬渶灏忓彈鍑诲绾︿笉鍙樸€?
## Task 4: 钀藉湴鏈€灏忚兘鍔涘樊寮傚弽棣?
**Files:**
- Modify: `scripts/player/player_placeholder.gd`
- Possibly Modify: `scenes/rooms/test_room.tscn`
- Test: `tests/stage4/test_stage_4_minimal_ability_difference.gd`

- [ ] 涓哄啿鍒鸿ˉ鏈€灏忓彲璇绘€у弽棣堬紝浣嗗彧鏈嶅姟鑳藉姏璇嗗埆銆?- [ ] 涓嶅紩鍏ユ棤鏁屽抚銆佹敾鍑诲彇娑堛€佸Э鎬佺郴缁熸垨鍏冪礌绯荤粺銆?- [ ] 鑻ュ啿鍒烘帴鍏ュ悗鏆撮湶涓庣幇鏈夌Щ鍔?/ 鏀诲嚮鑺傚鍐茬獊锛屼紭鍏堝洖璋冨凡鏈夊弬鏁般€?
## Task 5: 鑷姩鍖栭獙璇佷笌鏂囨。鏀跺彛

**Files:**
- Create: `tests/stage4/test_stage_4_minimal_ability_difference.gd`
- Modify: `docs/progress/status.md`
- Modify: `docs/progress/timeline.md`
- Modify: `docs/progress/2026-04-22.md`

- [ ] 瑕嗙洊 `dash` 杈撳叆銆佸湴闈㈣Е鍙戙€佺┖涓姝€佹敾鍑讳腑绂佹銆佹柟鍚戣鍒欍€佺姸鎬佹仮澶嶃€?- [ ] 瑕嗙洊鎺㈢储闂ㄦ涓庢垬鏂楅棬妲涚殑鏈€灏忎环鍊奸獙璇併€?- [ ] 璁板綍鍝簺鍙嶉宸插湪闃舵 4 钀藉湴锛屽摢浜涚户缁悗寤躲€?- [ ] 鑻ヤ娇鐢ㄤ簡閲嶈鐨?`subagent` / `multi-agent`锛岃ˉ鍐?`Delegation Log`銆?
## Verification

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage3/test_stage_3_combat_feel.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage4/test_stage_4_minimal_ability_difference.gd -gexit`
- `git diff --check`

## Completion Criteria

- 鐜╁鍙ǔ瀹氫粠鍦伴潰瑙﹀彂鍐插埡锛屽苟涓庢櫘閫氱Щ鍔ㄥ舰鎴愭竻鏅板樊寮傘€?- 鍚屼竴娴嬭瘯鎴块棿鍐呭悓鏃跺瓨鍦ㄦ帰绱环鍊煎拰鎴樻枟浠峰€肩殑鏈€灏忛獙璇佺偣銆?- 闃舵 4 鐨勮交閲忓弽棣堣冻浠ヨ〃杈锯€滆兘鍔涘樊寮傗€濓紝浣嗘病鏈夋墿鍐欐垚瀹屾暣婕斿嚭绯荤粺銆?- 闃舵 1 / 2 / 3 / 4 鑷姩鍖栭獙璇佸叏閮ㄩ€氳繃銆?- 褰撳墠缁撴灉瓒充互鎵挎帴闃舵 5 鐨勬暀绋嬪尯鍨傜洿鍒囩墖璁捐銆?
