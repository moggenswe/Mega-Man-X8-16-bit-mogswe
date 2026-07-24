extends X8TextureButton

onready var parent: = get_parent()
export var legible_name: String
export var description: String
onready var name_display: Label = $"../../../../Description/name"
onready var disc_display: Label = $"../../../../Description/disc"
onready var equip: AudioStreamPlayer = $"../../../../../../equip"

func _on_focus_entered() -> void :
	play_sound()
	display_info()
	flash()

func _on_focus_exited() -> void :
	if name in parent.current_armor:
		return
	elif name in GameManager.equip_exceptions:
		return
	else:
		dim()

func on_press() -> void :
	if not is_viable_armor(name):
		GameManager.add_equip_exception(name)
	else:
		GameManager.remove_equip_exception(get_body_part_name(name))
		GameManager.reposition_collectible_in_savedata(name)
	strong_flash()
	Tools.timer(0.075, "play", equip)
	parent.equip(self)

func is_viable_armor(armor_name: String) -> bool:
	return "icarus" in armor_name or "hermes" in armor_name

func get_body_part_name(collectible_name: String) -> String:
	return collectible_name.substr(7)

func display_info() -> void :
	name_display.text = legible_name
	disc_display.text = description

func visually_unequip_items() -> void :
	pass
