extends "res://src/Actors/Props/RideArmor/RepeatAnimation.gd"

func _ready() -> void :
	material = GameManager.player.animatedSprite.get_child(0).material

func _on_signal() -> void :
	var armor = GameManager.player.get_armor_sprites()
	for piece in armor:
		if piece.name == name:
			visible = piece.visible
