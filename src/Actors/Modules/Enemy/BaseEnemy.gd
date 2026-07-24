extends "res://src/Actors/Panda.gd"

func process_death(delta: float):
	Event.emit_signal("enemy_kill", self)
	queue_free()
