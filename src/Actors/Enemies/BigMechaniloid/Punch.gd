extends AttackAbility

onready var tween = TweenController.new(self)
onready var damage_area: Node2D = $damage_area
onready var drill: AudioStreamPlayer2D = $drill

signal stop

func _Setup() -> void :
	play_animation("punch_prepare")

func _Update(delta) -> void :
	process_gravity(delta)
	
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("punch_start")
		drill.play()
		step()
		next_attack_stage()
		
	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("punch_loop")
		screenshake()
		damage_area.activate()
		next_attack_stage()
		
	elif attack_stage == 2 and timer > 1:
		damage_area.deactivate()
		play_animation("punch_end")
		next_attack_stage()
		
	elif attack_stage == 3 and has_finished_last_animation():
		play_animation("idle")
		next_attack_stage()
		
	elif attack_stage == 4 and timer > 0.65:
		EndAbility()

func _Interrupt() -> void :
	emit_signal("stop")
	force_movement(0)
	damage_area.deactivate()

func step() -> void :
	tween.method("force_movement", 0.0, horizontal_velocity, 0.2)
	tween.add_method("force_movement", horizontal_velocity, 0.0, 0.45)
