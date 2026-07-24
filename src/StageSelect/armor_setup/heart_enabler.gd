extends X8OptionButton
onready var equip: AudioStreamPlayer = $"../../../equip"


func setup() -> void :
	if get_heart_count() == 0:
		visible = false
	dim()
	display()
	material.set_shader_param("grayscale", not GameManager.equip_hearts)

func on_press() -> void :
	increase_value()
	if GameManager.equip_hearts:
		equip.play()
		strong_flash()
	else:
		play_sound()
		flash()
	material.set_shader_param("grayscale", not GameManager.equip_hearts)

func process_inputs() -> void :
	pass
		
func increase_value() -> void :
	GameManager.equip_hearts = not GameManager.equip_hearts
	display()

func decrease_value() -> void :
	GameManager.equip_hearts = not GameManager.equip_hearts
	display()

func display() -> void :
	if not GameManager.equip_hearts:
		value.text = " "
		self_modulate.a = 0.7
	else:
		value.text = "x" + str(get_heart_count())
		self_modulate.a = 1

func get_heart_count() -> int:
	var count = 0
	for item in GameManager.collectibles:
		if "life_up" in item:
			count += 1
	return count

