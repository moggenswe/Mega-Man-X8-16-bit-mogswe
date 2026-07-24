extends AttackAbility
export var crystal: PackedScene
onready var roar: AudioStreamPlayer2D = $roar
const crystal_height: = 54.0

signal ready_for_stun

func _Setup() -> void :
	turn_and_face_player()
	play_animation("rage_prepare")
	character.emit_signal("damage_reduction", 0.5)
	roar.play()
	Event.emit_signal("trilobyte_desperation")

func _Update(delta) -> void :
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("rage_loop")
		next_attack_stage()

	elif attack_stage == 1 and timer > 1:
		play_animation("rage_end")
		next_attack_stage()
		
	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("rage_to_idle")
		if not is_colliding_with_wall_on_direction(1):
			next_attack_stage()
		else:
			go_to_attack_stage(6)

	elif attack_stage == 3 and has_finished_last_animation():
		set_direction(1)
		play_animation("run_start")
		next_attack_stage()
	
	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("run")
		force_movement(horizontal_velocity)
		next_attack_stage()
	
	elif attack_stage == 5:
		if is_colliding_with_wall_on_direction(1):
			force_movement(0)
			next_attack_stage()

	elif attack_stage == 6:
		set_direction( - 1)
		play_animation("rage_prepare")
		next_attack_stage()

	elif attack_stage == 7 and has_finished_last_animation():
		play_animation("desperation_prepare")
		next_attack_stage()

	elif attack_stage == 8 and has_finished_last_animation():
		play_animation("desperation")
		crystal_wave()
		emit_signal("ready_for_stun")
		next_attack_stage()
	
	elif attack_stage == 9:
		pass

	elif attack_stage == 10:
		play_animation("desperation_end")
		next_attack_stage()

	elif attack_stage == 11 and has_finished_last_animation():
		play_animation_once("idle")
		if timer > 3:
			EndAbility()

func _Interrupt() -> void :
	character.emit_signal("damage_reduction", 1.0)
	Event.emit_signal("trilobyte_desperation_end")

func crystal_wave() -> void :
	var interval: = 0.1
	create_wave(0.01, interval)
	create_wave(1.5, interval)
	create_wave(3.0, interval)
	create_wave(4.5, interval)
	create_wave(6.0, interval)
	create_wave(7.5, interval)
	Tools.timer(7.5, "next_attack_stage", self)

func create_wave(initial_time: float, interval: float) -> void :
	Tools.timer(initial_time, "create_ground_crystal", self)
	Tools.timer(initial_time + interval, "create_second_ground_crystal", self)
	Tools.timer(initial_time + interval * 7.5, "create_ceiling_crystal", self)
	Tools.timer(initial_time + interval * 8.5, "create_second_ceiling_crystal", self)
	

func create_crystal(offset: = Vector2.ZERO, inverted: = false) -> void :
	if not executing:
		return
	var c = instantiate(crystal)
	c.global_position += Vector2(offset.x - 32, offset.y)
	c.current_health = 20
	if inverted:
		c.scale.y = - 1
	c.initialize( - 200)
	
func create_ground_crystal() -> void :
	create_crystal()

func create_second_ground_crystal() -> void :
	create_crystal(Vector2(0, - crystal_height - 4))

func create_ceiling_crystal() -> void :
	create_crystal(Vector2(32.0, - 116 - 16), true)

func create_second_ceiling_crystal() -> void :
	create_crystal(Vector2(32, - 58 - 16), true)

