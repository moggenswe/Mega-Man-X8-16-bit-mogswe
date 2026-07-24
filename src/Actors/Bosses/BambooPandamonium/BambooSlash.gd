extends AttackAbility

const degrees: = [0, 90, - 45, 15, - 30, - 15, - 45, 90, 15, - 45, 30, 0]
export var slash: PackedScene
var current_degree: = 0
var performed_slashes: = 0
var slash1_timer: = 1.55 - 0.454
var alert_pitch: = 0.5
onready var pandaslash: AudioStreamPlayer2D = $pandaslash
onready var roar: AudioStreamPlayer2D = $roar
onready var alert: AudioStreamPlayer2D = $alert
onready var claw_appear: AudioStreamPlayer2D = $claw_appear
onready var claw_retreat: AudioStreamPlayer2D = $claw_retreat

signal cancel
signal slashed
signal ready_for_stun

func _Setup():
	current_degree = 0
	character.emit_signal("damage_reduction", 0.5)

func _Update(_delta) -> void :
	process_gravity(_delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("rage_prepare_loop")
		next_attack_stage()
		
	elif attack_stage == 1 and timer > 0.227:
		play_animation("rage_start")
		claw_appear.play()
		roar.play()
		next_attack_stage()
		
	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("rage_loop")
		next_attack_stage()
		
	elif attack_stage == 3 and timer > 0.454:
		play_animation("slash_prepare")
		create_slashes()
		turn_and_face_player()
		emit_signal("ready_for_stun")
		next_attack_stage()
		
	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("slash_prepare_loop")
		next_attack_stage()
		
	elif attack_stage == 5 and timer > slash1_timer:
		play_animation("slash1")
		
		activate_slashes()
		next_attack_stage()
	
	elif attack_stage == 6 and timer > 0.5:
		play_animation("slash2_prepare")
		create_slashes()
		turn_and_face_player()
		next_attack_stage()
		
	elif attack_stage == 7 and has_finished_last_animation():
		play_animation("slash2_prepare_loop")
		next_attack_stage()
		
	elif attack_stage == 8 and timer > 1.22:
		play_animation("slash2")
		
		activate_slashes()
		if performed_slashes >= 4:
			go_to_attack_stage(10)
		else:
			next_attack_stage()
		
	elif attack_stage == 9 and timer > 0.5:
		play_animation("slash3_prepare")
		create_slashes()
		turn_and_face_player()
		go_to_attack_stage(4)
		slash1_timer = 1.25
		


	
	elif attack_stage == 10 and timer > 0.5:
		play_animation("slash2_end")
		claw_retreat.play()
		next_attack_stage()
	
	elif attack_stage == 11 and has_finished_last_animation():
		EndAbility()
	
func activate_slashes() -> void :
	emit_signal("slashed")
	screenshake()
	pandaslash.play()
	performed_slashes += 1
	
func create_slashes() -> void :
	create_slash()
	var interval = 0.454
	Tools.timer(interval, "create_slash", self)
	Tools.timer(interval * 2, "create_slash", self)

func create_slash() -> void :
	if executing:
		var s = instantiate(slash)
		s.global_position = GameManager.get_player_position()
		s.rotate_degrees(degrees[current_degree])
		var _d = connect("slashed", s, "activate")
		_d = connect("cancel", s, "queue_free")
		current_degree += 1
		play_alert()

func play_alert() -> void :
	alert.pitch_scale = alert_pitch
	alert.play()
	alert_pitch += 0.12
	if alert_pitch >= 0.5 + 0.12 * 3:
		alert_pitch = 0.5
	

func _Interrupt() -> void :
	performed_slashes = 0
	character.emit_signal("damage_reduction", 1.0)
	emit_signal("cancel")
	._Interrupt()
