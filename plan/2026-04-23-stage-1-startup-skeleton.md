# 闃舵 1锛氬彲鍚姩楠ㄦ灦鏈€缁堣鍒掕褰?
> 璇存槑锛氭湰鏂囨。鐢ㄤ簬鐣欏瓨 `stage1` 鐨勬渶缁堢‘璁ょ増璁″垝銆?
> 鍘熷鎵ц鐢ㄨ鍒掍粛淇濈暀鍦?[2026-03-31-stage-1-startup-skeleton.md](/Users/peng8/Desktop/Project/Game/nano-hunter/docs/implementation-plans/2026-03-31-stage-1-startup-skeleton.md) 鍜?[2026-04-01-stage-1-display-and-camera-tuning.md](/Users/peng8/Desktop/Project/Game/nano-hunter/docs/implementation-plans/2026-04-01-stage-1-display-and-camera-tuning.md)銆?
## Summary

`stage1` 鐨勬渶缁堢洰鏍囨槸寤虹珛椤圭洰绗竴鐗堚€滃彲鍚姩銆佸彲鐪嬨€佸彲璋冣€濈殑璇曠帺妫€鏌ョ偣锛岃€屼笉鏄彁鍓嶈繘鍏ョЩ鍔ㄣ€佹垬鏂椼€丠UD 鎴栧叧鍗＄郴缁熷紑鍙戙€?
杩欎竴闃舵鏈€缁堢敱涓ら儴鍒嗙粍鎴愶細

- 鍚姩楠ㄦ灦
- 鐢婚潰涓庣浉鏈鸿皟浼?
瀹屾垚鍚庯紝椤圭洰搴旇兘鐩存帴浠?`Main.tscn` 鍚姩锛岃繘鍏?`TestRoom`锛岀湅鍒板崰浣嶇帺瀹躲€佸熀纭€纰版挒銆佸浐瀹氬熀鍑嗗垎杈ㄧ巼涓庡彈鎴块棿杈圭晫绾︽潫鐨勭浉鏈恒€?
## Key Changes

### 鍚姩楠ㄦ灦

- 鏂板缓 `Main.tscn` 浣滀负闃舵 1 鐨勫惎鍔ㄥ満鏅?- 鍦?`project.godot` 涓缃?`run/main_scene`
- 鏂板缓 `PlayerPlaceholder` 鍗犱綅鐜╁鍦烘櫙涓庢渶灏忚剼鏈?- 鏂板缓 `TestRoom` 浣滀负绗竴鐗堟祴璇曟埧闂村３浣?- 閫氳繃 `Main` 鍦ㄨ繍琛屾椂鎶婄帺瀹剁敓鎴愬埌 `Runtime` 瀹瑰櫒锛岃€屼笉鏄洿鎺ョ‖鍐欏湪鍦烘櫙鏍戦噷

### 鐢婚潰涓庣浉鏈鸿皟浼?
- 鍥哄畾鍩哄噯鍒嗚鲸鐜囦负 `640x360`
- 鍒濆绐楀彛灏哄鍥哄畾涓?`1280x720`
- 浣跨敤锛?  - `viewport`
  - `keep`
  - `integer`
  鐨勭缉鏀剧瓥鐣?- 涓?`TestRoom` 鏆撮湶鏈€灏忕浉鏈鸿竟鐣屽绾?- 璁╃帺瀹剁殑 `Camera2D` 璇诲彇骞跺簲鐢ㄨ鎴块棿杈圭晫

### 闃舵杈圭晫

- 鏈疆鏄庣‘涓嶅仛锛?  - 绉诲姩杈撳叆
  - 璺宠穬
  - 鏀诲嚮
  - HUD
  - 鎴块棿鍒囨崲
  - 姝ｅ紡鍏冲崱绯荤粺

## Test Plan

- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/stage1/test_stage_1_startup_skeleton.gd -gexit`
- `godot --headless --path . --import`
- `godot --path .`

## Assumptions

- `stage1` 鍥哄畾浠モ€滃惎鍔ㄩ鏋?+ 鏋勫浘绋冲畾鈥濅綔涓虹洰鏍囷紝涓嶆壙鎺ョЩ鍔ㄣ€佹垬鏂楁垨 HUD 寮€鍙?- `Main`銆乣Runtime`銆乣PlayerSpawn` 涓?`TestRoom` 鐨勫熀纭€缁撴瀯浼氬湪鍚庣画闃舵缁х画澶嶇敤
