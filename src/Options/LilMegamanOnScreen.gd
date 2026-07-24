extends AnimatedSprite
onready var option_holder: VBoxContainer = $"../Menu/OptionHolder"
var choices: Array
onready var shot = get_child(0)
onready var initial_shot_pos = get_child(0).position
onready var menu: Control = $"../Menu"

func _ready() -> void :
	choices = []
	choices = option_holder.get_children()
	visible = false
	for option in choices:
		var _s = option.connect("focus_entered", self, "_on_focus", [option])
		_s = option.connect("pressed", self, "_on_pressed", [option])
	connect("animation_finished", self, "_on_anim_finished")


func _on_focus(option) -> void :
	print_debug(option.name)
	global_position.y = option.rect_global_position.y + 7
	frame = 0
	play("recover")

func _process(delta: float) -> void :
	if visible != menu.visible:
		visible = menu.visible

func _on_pressed(option) -> void :
	shot.visible = true
	shot.position = initial_shot_pos
	
	var t = create_tween()
	t.tween_property(shot, "position:x", 400.0, 1)
	play("shot")

func _on_anim_finished() -> void :
	play("recover")
