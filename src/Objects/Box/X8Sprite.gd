extends AnimatedSprite

func make_invisible() -> void :
	visible = false

func restart() -> void :
	playing = true
	frame = 0
