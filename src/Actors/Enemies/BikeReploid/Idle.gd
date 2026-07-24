extends "res://src/Actors/Enemies/Big Tractor/AttackIdle.gd"


func _Update(delta) -> void :
	process_gravity(delta)
	force_movement(horizontal_velocity)

func check_for_event_errors() -> void :
	return
