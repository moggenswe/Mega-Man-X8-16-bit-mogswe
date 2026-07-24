extends AttackAbility

export var vertical_offset: = 10.0
export var strong_lightining: PackedScene
export var damage_reduction_during_desperation: = 0.5
var travel_duration: = 1.0
var cast_times: = 0
signal stop
signal ready_for_stun
onready var space: Node = $"../Space"
onready var tween: = TweenController.new(self)
onready var raycasts: Array = [$check, $check2, $check3, $check4, $check5]
var current_lightnings: Array
onready var spin: AudioStreamPlayer2D = $spin
onready var lightning_sfx: AudioStreamPlayer2D = $lightning
onready var move: AudioStreamPlayer2D = $"../move"

var current_crystal_walls: Array

var sequence3: Array = [[1, 3, 5], [2, 4], [1, 4, 5], [1, 2, 4], [3, 5], [2, 4], [1, 3, 5], [2, 3, 4]]
var sequence2: Array = [[1, 4], [2, 3, 5], [1, 4, 5], [1, 3, 5], [2, 4], [2, 5], [1, 2, 3], [1, 4, 5]]
var sequence: Array = [[2, 5], [1, 3, 5], [2, 3, 5], [2, 4], [1, 3, 5], [1, 5], [2, 3, 4], [1, 3, 5]]
var current_sequence
var final_storms: Array
onready var flash: Sprite = $flash


func _ready() -> void :
	Event.connect("crystal_wall_created", self, "on_wall_created")

func on_wall_created(wall) -> void :
	current_crystal_walls.append(wall)

func _Setup() -> void :
	cast_times = 0
	pick_random_storm_sequence()
	for cast in raycasts:
		cast.enabled = true
	

func pick_random_storm_sequence() -> void :
	var rng = randf() * 3
	if rng < 1.0:
		Log("Picked sequence 1")
		current_sequence = sequence
	elif rng >= 1.0 and rng <= 2.0:
		Log("Picked sequence 2")
		current_sequence = sequence2
	else:
		Log("Picked sequence 3")
		current_sequence = sequence3
	

func _Update(_delta) -> void :
	if attack_stage == 0:
		turn_and_face_player()
		play_animation("roll_prepare")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation_once("roll_start")
		spin.play()
		next_attack_stage()
			
	elif attack_stage == 2 and timer > 0.75:
		play_animation("thunder_loop")
		shake()
		next_attack_stage()
	
	elif attack_stage == 3 and timer > 0.45:
		play_animation("intro")
		next_attack_stage()
		
	elif attack_stage == 4 and timer > 0.65:
		play_animation("move_up")
		move.play_rp()
		go_to_center()
		next_attack_stage()
		
	elif attack_stage == 5 and timer > travel_duration:
		next_attack_stage()
		
	elif attack_stage == 6:
		play_animation("storm_prepare")
		cast_warnings()
		emit_signal("ready_for_stun")
		next_attack_stage()
		
	elif attack_stage == 7 and has_finished_last_animation():
		play_animation("storm_start")
		next_attack_stage()
		
	elif attack_stage == 8 and has_finished_last_animation():
		play_animation("storm_loop")
		cast_storm()
		next_attack_stage()
		
	elif attack_stage == 9 and timer > 1.0:
		play_animation("storm_stop")
		next_attack_stage()
	
	elif attack_stage == 10 and timer > 0.45:
		if cast_times < 3:
			go_to_attack_stage(6)
		else:
			play_animation("storm_prepare")
			cast_extra_warnings()
			next_attack_stage()
			
	elif attack_stage == 11 and timer > 1.25:
		play_animation("storm_start")
		next_attack_stage()
		
	elif attack_stage == 12 and has_finished_last_animation():
		play_animation("storm_loop")
		cast_final_storm()
		next_attack_stage()
		
	elif attack_stage == 13 and timer > 0.65:
		play_animation("storm_start")
		next_attack_stage()
		
	elif attack_stage == 14 and has_finished_last_animation():
		play_animation("storm_loop")
		cast_final_storm()
		next_attack_stage()
		
	elif attack_stage == 15 and timer > 1.0:
		play_animation("storm_stop")
		next_attack_stage()
	
	elif attack_stage == 16 and timer > 0.45:
		play_animation("storm_prepare")
		final_storms.clear()
		cast_extra_warnings(true)
		next_attack_stage()
	
	elif attack_stage == 17 and timer > 1.5:
		play_animation("storm_start")
		next_attack_stage()
		
	elif attack_stage == 18 and has_finished_last_animation():
		play_animation("storm_loop")
		cast_final_storm()
		next_attack_stage()
		
	elif attack_stage == 19 and timer > 0.65:
		play_animation("storm_start")
		next_attack_stage()
		
	elif attack_stage == 20 and has_finished_last_animation():
		play_animation("storm_loop")
		cast_final_storm()
		next_attack_stage()

	elif attack_stage == 21 and timer > 0.65:
		play_animation("storm_start")
		next_attack_stage()
		
	elif attack_stage == 22 and has_finished_last_animation():
		play_animation("storm_loop")
		cast_final_storm()
		next_attack_stage()
	
	elif attack_stage == 23 and timer > 1.0:
		play_animation("storm_stop")
		next_attack_stage()
	
	elif attack_stage == 24 and has_finished_last_animation():
		turn_towards_point(space.get_closest_position())
		play_animation("storm_end")
		next_attack_stage()
		
	elif attack_stage == 25 and has_finished_last_animation():
		play_animation("move_down")
		move.play_rp()
		go_to_closest_position()
		next_attack_stage()
	
	elif attack_stage == 26 and timer > travel_duration:
		EndAbility()

func cast_warnings() -> void :
	current_lightnings.clear()
	for element in current_sequence[cast_times]:
		create_lightning(raycasts[element - 1].get_collision_point())
	cast_times += 1

func cast_final_warnings() -> void :

	current_lightnings.clear()
	var pack: Array
	for element in current_sequence[cast_times]:
		pack.append(create_lightning(raycasts[element - 1].get_collision_point(), 0.35))
	cast_times += 1
	final_storms.append(pack)
	

func create_lightning(collision_point, warning: = 0.75) -> Node2D:
	var lightning: StrongLightning = strong_lightining.instance()
	lightning.global_position = character.global_position
	get_tree().current_scene.add_child(lightning)
	lightning.position_end(collision_point)
	lightning.update_joints()
	lightning.prepare(warning)
	current_lightnings.append(lightning)
	var _s = lightning.connect("expired", self, "remove_lightning")
	return lightning
	
func cast_extra_warnings(final: = false) -> void :
	cast_final_warnings()
	Tools.timer(0.5, "cast_final_warnings", self)
	if final:
		Tools.timer(1.0, "cast_final_warnings", self)
	
func cast_storm() -> void :
	lightning_sfx.play_rp()
	screenshake()
	if has_valid_crystal_wall():
		cast_special_lightning()
		break_wall()
		for light in current_lightnings:
			light.expire()
			remove_lightning(light)
		return
	for light in current_lightnings:
		light.start_lightning()
	flash.start()
	
func cast_final_storm() -> void :
	lightning_sfx.play_rp()
	screenshake()
	if has_valid_crystal_wall():
		cast_special_lightning()
		final_storms.pop_front()
		if final_storms.size() == 0:
			break_wall()
		return
	for light in final_storms.pop_front():
		if final_storms.size() > 0:
			light.damage_duration = 0.35
		light.start_lightning()
	flash.start()

func has_valid_crystal_wall() -> bool:
	for wall in current_crystal_walls:
		if is_instance_valid(wall) and wall.active and not wall.shattered:
			return true
	return false
	

func cast_special_lightning():
	var wall = get_crystal_wall()
	if wall:
		create_lightning(wall.global_position, 0.0).call_deferred("start_lightning")

func get_crystal_wall():
	for wall in current_crystal_walls:
		if is_instance_valid(wall) and not wall.shattered:
			return wall
	
func break_wall():
	var wall = get_crystal_wall()
	if wall:
		wall.break_crystal()
		current_crystal_walls.erase(wall)

func shake() -> void :
	pass

func remove_lightning(light) -> void :
	current_lightnings.erase(light)

func go_to_closest_position() -> void :
	var destination = space.get_closest_position()
	travel_duration = space.time_to_position(destination, 120)
	turn_towards_point(destination)
	tween.create(Tween.EASE_IN_OUT, Tween.TRANS_SINE)
	tween.add_attribute("global_position", destination, travel_duration, character)

func go_to_center() -> void :
	var destination = space.center + Vector2(0, vertical_offset)
	travel_duration = space.time_to_position(destination, 120)
	turn_towards_point(destination)
	tween.create(Tween.EASE_IN_OUT, Tween.TRANS_SINE, false)
	tween.add_attribute("global_position", destination, travel_duration, character)

func _Interrupt() -> void :
	emit_signal("stop")
	for r in current_lightnings:
		r.queue_free()
	current_lightnings.clear()
	
