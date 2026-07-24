extends "res://src/Objects/Door/CameraTranslator.gd"

func _ready() -> void :
	if get_checkpoint() < associated_checkpoint:
		disable_limits(next_limit)

func last_zone_entered() -> void :
	pass
	
	

func get_checkpoint() -> int:
	if GameManager.checkpoint:
		return GameManager.checkpoint.id
	return - 1


func _on_StartPortal_teleport_start() -> void :
	pass


func _on_StartPortal_teleported() -> void :
	enable_limits(next_limit)
	disable_limits(previous_limit)
	update_limits(next_limit)
	pass
