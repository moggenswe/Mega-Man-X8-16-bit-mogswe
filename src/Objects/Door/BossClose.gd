extends "res://src/Objects/Door/Close.gd"

export var signal_to_emit: = "boss_door_closed"

func _Interrupt() -> void :
	if signal_to_emit != "none":
		Event.emit_signal(signal_to_emit)
	collider.set_deferred("disabled", false)
