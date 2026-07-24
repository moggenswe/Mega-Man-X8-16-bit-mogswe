extends X8TextureButton

export var stage_info: Resource
export var frame: = 0
export var intensity: = 0
signal stage_selected(info)


func _on_focus_entered() -> void :
	play_sound()
	emit_signal("stage_selected", stage_info)

func on_press() -> void :
	get_node(menu_path).picked_stage(stage_info)
