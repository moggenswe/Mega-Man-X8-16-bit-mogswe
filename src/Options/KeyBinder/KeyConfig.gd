extends CanvasLayer
class_name X8Menu

var active: = false

export var menu_path: NodePath
export var initial_focus: NodePath
export var exit_action: = "none"
export var start_emit_event: = "none"

onready var menu: Control = get_node(menu_path)
onready var focus: Control = get_node(initial_focus)
onready var fader: ColorRect = $Fader
onready var choice: AudioStreamPlayer = $choice

signal initialize
signal start
signal end
signal lock_buttons
signal unlock_buttons

var locked: = true

func _input(event: InputEvent) -> void :
	if active:
		if exit_action != "none" and event.is_action_pressed(exit_action):
			end()

func _ready() -> void :
	if get_parent().name == "root":
		start()
	else:
		menu.visible = false
		visible = true

func start() -> void :
	emit_signal("initialize")
	print_debug("Starting Menu " + name)
	active = true
	emit_signal("lock_buttons")
	if start_emit_event != "none":
		Event.emit_signal(start_emit_event)
	fader.visible = true
	fader.FadeIn()
	yield(fader, "finished")
	
	unlock_buttons()
	print_debug("Unlocked Buttons")
	emit_signal("start")
	call_deferred("give_focus")

func give_focus() -> void :
	focus.silent = true
	focus.grab_focus()
	print_debug("Focus given to " + focus.name)

func end() -> void :
	print_debug("Closing Menu " + name)
	lock_buttons()
	fader.FadeOut()
	yield(fader, "finished")
	emit_signal("end")
	active = false
	Savefile.save()
	
func play_choice_sound() -> void :
	choice.play()

func button_call(method, param = null) -> void :
	print_debug("Button press: Executing method " + method)
	if param:
		call_deferred(method, param)
	else:
		call(method)
	
func lock_buttons() -> void :
	emit_signal("lock_buttons")
	locked = true
	
func unlock_buttons() -> void :
	emit_signal("unlock_buttons")
	locked = false
