extends X8OptionButton
onready var equip: AudioStreamPlayer = $"../../../equip"


func setup() -> void :
	if get_subtank_count() == 0:
		visible = false
	dim()
	display()
	material.set_shader_param("grayscale", not GameManager.equip_subtanks)

func on_press() -> void :
	increase_value()
	if GameManager.equip_subtanks:
		equip.play()
		strong_flash()
	else:
		play_sound()
		flash()
	material.set_shader_param("grayscale", not GameManager.equip_subtanks)

func process_inputs() -> void :
	pass
		
func increase_value() -> void :
	GameManager.equip_subtanks = not GameManager.equip_subtanks
	display()

func decrease_value() -> void :
	GameManager.equip_subtanks = not GameManager.equip_subtanks
	display()

func display() -> void :
	if not GameManager.equip_subtanks:
		value.text = " "
		self_modulate.a = 0.7
	else:
		value.text = "x" + str(get_subtank_count())
		self_modulate.a = 1

func get_subtank_count() -> int:
	var count = 0
	for item in GameManager.collectibles:
		if "subtank" in item:
			count += 1
	return count

