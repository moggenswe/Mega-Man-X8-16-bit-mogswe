extends Node2D


func _on_playerDetector_body_entered(_body: Node) -> void :
	Event.emit_signal("darkness")
	pass


func _on_playerDetector_body_exited(_body: Node) -> void :
	Event.emit_signal("turn_off_darkness")
	pass
