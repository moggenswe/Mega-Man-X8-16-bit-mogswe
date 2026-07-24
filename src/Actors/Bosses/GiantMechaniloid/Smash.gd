extends AttackAbility

onready var actual_attack: Node2D = $"../animatedSprite/smash_attack"
onready var stomp: AudioStreamPlayer2D = $stomp

func _Setup() -> void :
	play_animation("smash_prepare")
	set_direction( - get_facing_direction())

func _Update(_delta) -> void :
	process_gravity(_delta)
	
	if attack_stage == 0 and timer > 0.85:
		play_animation("smash_start")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("smash")
		stomp.play()
		screenshake(2)
		actual_attack.activate()
		next_attack_stage()
		
	elif attack_stage == 2 and timer > 1.0:
		play_animation("smash_end")
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		EndAbility()
