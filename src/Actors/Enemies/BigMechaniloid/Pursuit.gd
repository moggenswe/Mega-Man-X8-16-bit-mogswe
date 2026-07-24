extends AttackAbility

onready var tween = TweenController.new(self)
onready var step: AudioStreamPlayer2D = $step
var ignore: = true
	
signal stop

func _Setup() -> void :
	if ignore:
		ignore = false
		return
	
	step()
	play_animation("walk_start")

func _Update(delta) -> void :
	process_gravity(delta * 6.5)
	
	if attack_stage == 0 and timer > get_time_between_steps():
		play_animation("walk_step")
		step()
		next_attack_stage()
		
	elif attack_stage == 1 and timer > get_time_between_steps():
		play_animation("walk_step2")
		step()
		go_to_attack_stage(0)

func _Interrupt() -> void :
	emit_signal("stop")
	force_movement(0)

func get_time_between_steps() -> float:
	
	if distance_from_player() > 240 and is_player_in_front():
		return 0.55
	
	return 0.65

func get_pursuit_speed() -> float:
	if distance_from_player() > 240:
		return horizontal_velocity * 1.15
	return horizontal_velocity

func step_sound_and_screenshake() -> void :
	step.play()
	screenshake(0.8)

func distance_from_player() -> float:
	return abs(global_position.x - GameManager.get_player_position().x)

func step() -> void :
	tween.method("force_movement", 0.0, get_pursuit_speed(), 0.2)
	tween.add_callback("step_sound_and_screenshake")
	tween.add_method("force_movement", horizontal_velocity, 0.0, 0.2)
