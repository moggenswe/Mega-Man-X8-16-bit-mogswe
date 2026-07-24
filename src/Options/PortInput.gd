extends SpinBox

onready var parent_button = $"../Button"

var old_value: int
func _ready():
	old_value = int(value)
func _input(event):
	
	if visible:
		if event is InputEventKey:
			if event.scancode == KEY_ESCAPE:
				value = old_value
				return_control()
			elif event.scancode == KEY_ENTER:
				return_control()
		elif event.is_action_pressed("ui_accept"):
			return_control()
		elif event.is_action_pressed("ui_up"):
			value += 1
		elif event.is_action_pressed("ui_down"):
			value -= 1
		
func return_control():
	release_focus()
	old_value = int(value)
	visible = false
	editable = false
	parent_button.menu.unlock_buttons()
	parent_button.value.visible = true
	parent_button.call_deferred("grab_focus")



