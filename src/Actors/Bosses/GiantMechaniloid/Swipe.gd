extends AttackAbility
onready var actual_attack: Node2D = $"../animatedSprite/swipe_attack"
onready var prepare_attack: Node2D = $"../animatedSprite/swipe_prepare"
onready var drill: AudioStreamPlayer2D = $drill
onready var swipe: AudioStreamPlayer2D = $swipe

func _Setup() -> void :
	play_animation("swipe_prepare")
	prepare_attack.scale.x = 1
	actual_attack.scale.x = 1
	drill.play()
	
func _Update(_delta) -> void :
	process_gravity(_delta)
	
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("swipe_prepare_loop")
		prepare_attack.activate()
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.65:
		play_animation("swipe_start")
		next_attack_stage()
		
	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("swipe")
		swipe.play()
		prepare_attack.deactivate()
		actual_attack.activate()
		screenshake(0.5)
		next_attack_stage()
		
	elif attack_stage == 3 and timer > 0.45:
		play_animation("swipe_end")
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void :
	prepare_attack.deactivate()
