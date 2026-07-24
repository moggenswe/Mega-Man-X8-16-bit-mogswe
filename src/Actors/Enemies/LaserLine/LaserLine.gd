extends Enemy

export var laser_direction: = 1

func _ready() -> void :
	set_direction_on_ready()

func set_collision_bit() -> void :
	pass

func set_direction_on_ready() -> void :
	set_direction(laser_direction)
	update_facing_direction()

func set_direction(dir: int, update: = false) -> void :
	.set_direction(dir, update)
	
