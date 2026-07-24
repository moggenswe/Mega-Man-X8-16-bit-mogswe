extends RigidBody2D

var break_guards: = false
var facing_direction: = 0

func get_facing_direction() -> int:
	return get_parent().character.get_facing_direction()

func leave(_body):
	get_parent().leave(_body)

func hit(_body) -> void :
	get_parent().hit(_body)

func deflect(_whatever):
	pass
