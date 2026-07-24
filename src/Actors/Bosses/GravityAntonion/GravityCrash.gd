extends AttackAbility
signal start_desperation
export var deactivate_hurl: = true
export var damage_reduction_during_desperation: = 0.5
onready var roar: AudioStreamPlayer2D = $roar
onready var desperate: AudioStreamPlayer2D = $desperate

signal ready_for_stun

func _Setup() -> void :
	play_animation("rage")
	character.emit_signal("damage_reduction", damage_reduction_during_desperation)


func _Update(delta) -> void :
	process_gravity(delta)
	if attack_stage == 0 and timer > 1.0:
		play_animation("summon_start")
		roar.play()
		next_attack_stage()
	
	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("summon_loop")
		start_desperation_attack()
		emit_signal("ready_for_stun")
		desperate.play()
		next_attack_stage()
	
	elif attack_stage == 2 and timer > 4:
		play_animation("summon_end")
		next_attack_stage()
	
	elif attack_stage == 3 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void :
	character.emit_signal("damage_reduction", 1.0)


func start_desperation_attack() -> void :
	emit_signal("start_desperation")
	if deactivate_hurl:
		$"../GravityHurl".deactivate()
