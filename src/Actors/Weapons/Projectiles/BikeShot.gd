extends WeaponShot
class_name BikeShot

func disable_damage():
	$collisionShape2D.disabled = true
	

func deflect(_body) -> void :
	.deflect(_body)
	$deflect_particle.emit(facing_direction)
