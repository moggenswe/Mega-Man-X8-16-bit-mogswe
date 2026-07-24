extends "res://src/Options/SimpleMusicPlayer.gd"


func _ready() -> void :
	Event.listen("fadeout_startmenu", self, "fade_out")

func fade_out() -> void :
	print_debug("Starting song fadeout")
	var t = create_tween()
	t.tween_property(self, "volume_db", - 80.0, 4)
