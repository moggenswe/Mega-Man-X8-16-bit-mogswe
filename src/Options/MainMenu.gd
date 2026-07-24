extends X8Menu
onready var info: Label = $Menu / demo_02

func _input(event: InputEvent) -> void :
	if not locked:
		if event.is_action_pressed("pause"):
			var start_event = InputEventAction.new()
			start_event.action = "ui_accept"
			start_event.pressed = true
			Input.parse_input_event(start_event)

func _ready() -> void :
	info.text = GameManager.current_demo + " V." + GameManager.version
	pass
