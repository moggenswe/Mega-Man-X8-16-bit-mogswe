extends AttackAbility

func _Setup():

	set_direction(get_facing_direction() * - 1.0, true)
	
	
func _EndCondition() -> bool:
	return true
