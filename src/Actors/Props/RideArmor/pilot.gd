extends "res://src/Actors/Props/RideArmor/RepeatAnimation.gd"


func _ready() -> void :
	material = GameManager.player.animatedSprite.material
