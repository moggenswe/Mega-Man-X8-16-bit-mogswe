extends Node2D

onready var fade: Sprite = $fade
onready var tween: = TweenController.new(self, false)
onready var inspired: Label = $inspired

var exiting: = false

func _ready() -> void :
	fade.modulate = Color.black
	Tools.timer(0.5, "fadein", self)
	Tools.timer(10.0, "fadeout", self)

func _input(event: InputEvent) -> void :
	if event.is_action_pressed("pause"):
		fadeout()

func fadein():
	if not exiting:
		inspired.modulate = Color.darkblue
		tween.attribute("modulate:a", 0.0, 0.5, fade)
		tween.add_attribute("modulate", Color.white, 0.5, inspired)
	

func fadeout():
	if not exiting:
		exiting = true
		tween.reset()
		tween.attribute("modulate", Color.darkblue, 0.5, inspired)
		tween.add_attribute("modulate:a", 1.0, 0.5, fade)
		tween.add_wait(0.5)
		tween.add_callback("next_screen")

func next_screen():
	var _dv = get_tree().change_scene("res://src/Title/IntroAlysson.tscn")
