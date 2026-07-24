extends X8TextureButton
class_name CallbackButton
export var method: String

func on_press() -> void :
	.on_press()
	call_method()

func call_method() -> void :
	if method:
		menu.call("button_call", method)
	else:
		push_error("No method set")
	
	
