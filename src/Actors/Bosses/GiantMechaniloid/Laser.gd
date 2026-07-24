extends AttackAbility
onready var laser_eye: Node2D = $"../animatedSprite/LaserEye"

func _Setup() -> void :
	play_animation("laser_prepare")

func _Update(_delta) -> void :
	process_gravity(_delta)
	
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("laser_prepare_loop")
		next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.5:
		activate_laser_eye()
		next_attack_stage()
	
	elif attack_stage == 2 and timer > 0.5:
		play_animation("laser")
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		play_animation("laser_end_loop")
		next_attack_stage()
		
	elif attack_stage == 4 and timer > 1.0:
		play_animation("laser_end")
		laser_eye.deactivate()
		next_attack_stage()

	elif attack_stage == 5 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void :
	laser_eye.deactivate()
	

func activate_laser_eye() -> void :
	laser_eye.rotation_order = Vector2( - 230, - 360)
	laser_eye.position.x = - 5
	laser_eye.rotation_degrees = laser_eye.rotation_order[0]
	laser_eye.duration = 0.75
	laser_eye.make_visible_and_activate_damage()
		
	
	Tools.timer(0.5, "activate", laser_eye)
	Tools.timer(0.5, "move_laser_eye", self)

func move_laser_eye() -> void :
	Tools.tween(laser_eye, "position:x", 5.0, 0.4)
		
