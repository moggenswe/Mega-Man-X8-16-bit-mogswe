extends X8OptionButton

func setup() -> void :
	set_fps(get_fps())

func increase_value() -> void :
	set_fps(next())

func decrease_value() -> void :
	set_fps(prev())

func next() -> int:
	if get_fps() == 60:
		return 75
	elif get_fps() == 75:
		return 120
	elif get_fps() == 120:
		return 144
	elif get_fps() == 144:
		return 30
	elif get_fps() == 30:
		return 45
	elif get_fps() == 45:
		return 50
	elif get_fps() == 50:
		return 55
	elif get_fps() == 55:
		return 60
	return 60
	
func prev() -> int:
	if get_fps() == 60:
		return 55
	elif get_fps() == 55:
		return 50
	elif get_fps() == 50:
		return 45
	elif get_fps() == 45:
		return 30
	elif get_fps() == 30:
		return 144
	elif get_fps() == 144:
		return 120
	elif get_fps() == 120:
		return 75
	elif get_fps() == 75:
		return 60
	return 60

func get_fps() -> int:
	if Configurations.get("FPS"):
		return Configurations.get("FPS")
	return 60


func set_fps(value: int) -> void :
	Configurations.set("FPS", value)
	Engine.target_fps = value
	Engine.set_iterations_per_second(value)
	display_value(get_fps())
