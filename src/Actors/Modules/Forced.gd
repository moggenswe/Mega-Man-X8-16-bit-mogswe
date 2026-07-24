extends EventAbility

func _ready() -> void :
	if active:
		character.listen("stop_forced_movement", self, "stop")

func stop(_forcer = null):
	EndAbility()

func _Setup() -> void :
	Log("Lost Control")
	character.stop_listening_to_inputs()
	character.set_horizontal_speed(0)
	character.set_vertical_speed(0)

func _Update(_delta: float) -> void :
	pass

func _Interrupt():
	character.activate()

func _EndCondition() -> bool:
	return false

func is_high_priority() -> bool:
	return true

func StopAnyConflictingMoves():
	if conflicts_with_nothing():
		return
	var moves_to_end = []
	for executing_move in character.executing_moves:
		if executing_move.name == "Charge":
			continue
		if is_high_priority():
			if not executing_move.conflicts_with_nothing():
				moves_to_end.append(executing_move)
		if executing_move.conflicts_with_anything() or executing_move.conflicts_with(self):
			moves_to_end.append(executing_move)
	for move in moves_to_end:
		Log("Interrupting " + move.name)
		move.Interrupt(name)
