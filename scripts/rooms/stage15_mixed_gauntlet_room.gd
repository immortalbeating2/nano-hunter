extends "res://scripts/rooms/stage13_miasma_marsh_room_base.gd"

# mixed gauntlet 是三类敌人混合战斗样板，单独扩大房间边界。
const FORMAL_GAUNTLET_CAMERA_LIMITS := Rect2i(-512, -288, 1664, 576)


# 三条路线描述敌人压力与移动能力的对应关系，供 HUD、遥测和灰盒复核统一读取。
func get_combat_route_profile() -> Dictionary:
	return {
		"ground": {"required_ability": &"move", "enemy_role": &"basic_melee"},
		"charger": {"required_ability": &"dash", "enemy_role": &"ground_charger"},
		"aerial": {"required_ability": &"air_dash", "enemy_role": &"aerial_sentinel"},
	}


func get_camera_limits() -> Rect2i:
	return FORMAL_GAUNTLET_CAMERA_LIMITS
