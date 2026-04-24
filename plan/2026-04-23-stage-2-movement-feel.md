# 闃舵 2锛氬熀纭€绉诲姩鎵嬫劅鏈€缁堣鍒掕褰?
> 璇存槑锛氭湰鏂囨。鐢ㄤ簬鐣欏瓨 `stage2` 鐨勬渶缁堢‘璁ょ増璁″垝銆?
> 鍘熷鎵ц鐢ㄨ鍒掍粛淇濈暀鍦?[2026-04-10-stage-2-movement-feel.md](/Users/peng8/Desktop/Project/Game/nano-hunter/docs/implementation-plans/2026-04-10-stage-2-movement-feel.md)銆?
## Summary

`stage2` 鐨勭洰鏍囨槸鍦?`stage1` 鍚姩楠ㄦ灦涔嬩笂锛屽仛鍑虹涓€鐗堝彲璋冩暣鐨勫熀纭€绉诲姩鎵嬫劅锛屽寘鎷細

- 璺戝仠
- 璺宠穬
- 钀藉湴
- 楂樼骇鎵嬫劅绐楀彛

鏈疆淇濇寔 `Main + Runtime + TestRoom + PlayerPlaceholder` 鐨勬棦鏈夐鏋朵笉鍙橈紝鍙湪鐜版湁鍗犱綅鐜╁涓婂閲忓姞鍏ュ懡鍚嶈緭鍏ュ姩浣溿€佸鍑鸿皟鍙傚瓧娈典笌鏈€灏忔樉寮忕姸鎬佹祦杞€?
## Key Changes

### 宸ョ▼鍩虹嚎

- 鍦?`project.godot` 涓柊澧炲懡鍚嶈緭鍏ュ姩浣滐細
  - `move_left`
  - `move_right`
  - `jump`
- 鏄庣‘褰撳墠闃舵缁х画绂佺敤 `better-terrain`

### 鐜╁绉诲姩鍘熷瀷

- 鍦?`PlayerPlaceholder` 涓婂疄鐜板熀纭€绉诲姩杈撳叆
- 鏂板鏈€灏忕姸鎬佹祦杞細
  - `idle`
  - `run`
  - `jump_rise`
  - `jump_fall`
  - `land`
- 鏆撮湶鏍稿績璋冨弬瀛楁锛?  - 鏈€澶ч€熷害
  - 鍦伴潰鍔犻€熷害 / 鍑忛€熷害
  - 绌轰腑鍔犻€熷害
  - 璺宠穬閫熷害
  - 钀藉湴鏃堕暱

### 楂樼骇鎵嬫劅绐楀彛

- `coyote time`
- `jump buffer`
- `鍙彉璺抽珮`

### 闃舵杈圭晫

- 鏈疆鏄庣‘涓嶅仛锛?  - 鏀诲嚮
  - 鍐插埡
  - HUD
  - 鎴块棿绯荤粺閲嶆瀯

## Test Plan

- `godot --headless --path . --import`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage2/test_stage_2_movement_feel.gd -gexit`
- `git diff --check`

## Assumptions

- `stage2` 鍥哄畾鍙獙璇佸熀纭€绉诲姩涓庤烦璺冩墜鎰燂紝涓嶆彁鍓嶆贩鍏ユ垬鏂椾笌鑳藉姏宸紓
- 闃舵 2 缁撴潫鏃讹紝椤圭洰搴旇兘绋冲畾鎵挎帴 `stage3` 鐨勬敾鍑绘帴鍏?
