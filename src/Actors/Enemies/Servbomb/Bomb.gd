extends "res://src/Actors/Bosses/BambooPandamonium/BambooGrenade.gd"

func _ready() -> void :
	animatedSprite.playing = true

func _Update(delta) -> void :
	process_gravity(delta)
	
	if is_on_floor():
		explode()
