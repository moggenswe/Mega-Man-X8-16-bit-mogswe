extends "res://src/Levels/PitchBlack/Darkness.gd"

onready var smoke: Particles2D = $"../camera2D/parallaxBackground/parallaxLayer4/particles2D"


func _on_playerDetector_body_entered(_body: Node) -> void :
	Event.emit_signal("darkness")

	create_tween().tween_property(smoke, "modulate:a", 1.0, 1)
	pass


func _on_playerDetector_body_exited(_body: Node) -> void :
	Event.emit_signal("turn_off_darkness")

	create_tween().tween_property(smoke, "modulate:a", 0.0, 1)
	pass
