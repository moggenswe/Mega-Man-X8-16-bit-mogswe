extends AudioStreamPlayer

export var loop: AudioStream
export var play_on_start: = true
var started_loop: = false

func _ready() -> void :
	if play_on_start:
		play()
	if loop:
		connect("finished", self, "play_loop")

func play_loop() -> void :
	if loop and not started_loop:
		started_loop = true
		stream = loop
		play()

func fade_out() -> void :
	print_debug("Starting song fadeout")
	var t = create_tween()
	t.tween_property(self, "volume_db", - 80.0, 1.5)

func play(from_position: float = 0.0) -> void :
	print_debug("playing")
	.play()
