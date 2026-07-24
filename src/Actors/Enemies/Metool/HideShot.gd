extends "res://src/Actors/Enemies/Metool/Hide.gd"


func _StartCondition() -> bool:
	return not is_player_looking_away()
