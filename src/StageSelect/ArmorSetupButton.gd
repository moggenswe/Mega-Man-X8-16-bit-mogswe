extends AnimatedSprite
onready var pointer: AnimatedSprite = $"../../map/pointer"

func _on_ArmorSetup_focus_entered() -> void :
	visible = true
	pointer.visible = false

func _on_ArmorSetup_focus_exited() -> void :
	visible = false
