extends Node

onready var parent = get_parent()

func _ready() -> void :
	Event.listen("stage_rotate", self, "on_rotate_stage")
	Event.listen("stage_rotate_end", self, "on_rotate_end")

func on_rotate_stage() -> void :
	var tween: SceneTreeTween = parent.create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(parent, "modulate:a", 0.0, 0.25)
	if parent.emitting:
		parent.restart()
		
		
	
func on_rotate_end() -> void :
	var tween: SceneTreeTween = parent.create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(parent, "modulate:a", 1.0, 0.25)
		
