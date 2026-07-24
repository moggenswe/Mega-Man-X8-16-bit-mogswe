extends "res://src/Actors/InheritorAnimatedSprite.gd"


func _ready() -> void :
	Event.connect("cutman_throw", self, "hide_hair")
	Event.connect("cutman_received", self, "show_hair")
	
	pass

func hide_hair():
	visible = false
	
func show_hair():
	visible = true

func _process(_delta: float) -> void :
	var anim_to_play
	var character_animation = parent.animation
	var character_frame = parent.frame
	anim_to_play = character_animation

	if animation != anim_to_play:
		play(anim_to_play)
	if frame != character_frame:
		frame = character_frame
	
	flip_h = parent.flip_h
