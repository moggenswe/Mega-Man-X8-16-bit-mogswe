extends AnimatedSprite

onready var parent: = get_parent()

func _process(_delta: float) -> void :
	var anim_to_play
	var character_animation = parent.animation
	var character_frame = parent.frame
	anim_to_play = character_animation

	if animation != anim_to_play:
		play(anim_to_play)
	if frame != character_frame:
		frame = character_frame


func _on_KingCrab_zero_health() -> void :
	print_debug("Setting headcrab frames to fullbody frames")
	parent.frames = frames
	visible = false
	pass
