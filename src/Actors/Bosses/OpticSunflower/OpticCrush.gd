extends AttackAbility
onready var rage: AudioStreamPlayer2D = $rage
signal ready_for_stun
signal beam

func _Setup() -> void :
	turn_and_face_player()
	play_animation("rage_prepare")
	rage.play()
	character.emit_signal("damage_reduction", 0.5)

func _Update(delta) -> void :
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("rage_loop")
		next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.5:
		play_animation("desp_prepare")
		next_attack_stage()
	
	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("desp_prepare_loop")
		next_attack_stage()
		
	elif attack_stage == 3 and timer > 0.5:
		play_animation("desp")
		emit_signal("beam")
		emit_signal("ready_for_stun")
		next_attack_stage()
	
	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("desp_loop")
		
		next_attack_stage()
		
	elif attack_stage == 5 and timer > 3:
		play_animation("desp_end")
		next_attack_stage()
		
	elif attack_stage == 6 and has_finished_last_animation():
		EndAbility()

func _Interrupt():
	._Interrupt()
	character.emit_signal("damage_reduction", 1.0)
