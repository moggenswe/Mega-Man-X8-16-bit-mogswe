extends SimpleProjectile

func initialize(_direction) -> void :
	Log("Initializing")
	activate()
	reset_timer()
	
	_Setup()
	
func explode() -> void :
	pass
	
func _OnHit(_target_remaining_HP) -> void :
	pass

func _OnScreenExit() -> void :
	Log("Exited Screen")
