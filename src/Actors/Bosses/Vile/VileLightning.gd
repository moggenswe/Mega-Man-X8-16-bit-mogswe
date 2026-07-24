extends AttackAbility

export var damage_reduction: = 0.5
var desperation_finished: = false
onready var lightnings: = [$VileLightning, $VileLightning3, $VileLightning5]
onready var lightnings2: = [$VileLightning2, $VileLightning4, $VileLightning6]
onready var space: Node = $"../Space"
onready var tween: = TweenController.new(self)
onready var lightning: AudioStreamPlayer2D = $lightning
onready var warning: AudioStreamPlayer2D = $warning
onready var lightning_loop: AudioStreamPlayer2D = $lightning_loop
onready var end: AudioStreamPlayer2D = $end
onready var flash: Sprite = $flash

signal stop
signal ready_for_stun

func _Setup() -> void :
	character.emit_signal("damage_reduction", damage_reduction)
	deactivate_ground_attacks()
	activate_air_attacks()

func _Update(_delta) -> void :
	if attack_stage == 0:
		play_animation("idle_to_flight")
		move_upward()
		next_attack_stage()
	
	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("flight_to_upward")
		next_attack_stage()
	
	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("upward")
		next_attack_stage()
		
	elif attack_stage == 3 and timer > 0.25:
		play_animation("upward_to_flight")
		next_attack_stage()
		
	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("flight")
		next_attack_stage()
		
	elif attack_stage == 5 and timer > 0.45:
		go_to_center()
		next_attack_stage()
	
	elif attack_stage == 6 and timer > 1.25:
		play_animation("shock_prepare")
		warning_shot()
		warning.play()
		next_attack_stage()

	elif attack_stage == 7 and has_finished_last_animation():
		play_animation("shock")
		screenshake()
		flash.start()
		lightning.play()
		lightning_loop.play()
		activate_lightning()
		next_attack_stage()

	elif attack_stage == 8 and desperation_finished:
		play_animation("shock_idle")
		emit_signal("ready_for_stun")
		end.play()
		lightning_loop.stop()
		end_lightning()
		next_attack_stage()

	elif attack_stage == 9 and timer > 1.0:
		play_animation("shock_to_flight")
		next_attack_stage()

	elif attack_stage == 10 and has_finished_last_animation():
		play_animation_once("flight")
		if timer > 1:
			EndAbility()

func warning_shot() -> void :
	for l in lightnings:
		l.prepare()
	for l in lightnings2:
		l.prepare()

func activate_lightning() -> void :
	setup_rotation()
	for l in lightnings:
		l.activate()
	for l in lightnings2:
		l.activate()

func setup_rotation() -> void :
	tween.create(Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)
	tween.add_attribute("rotation_degrees", 45, 2.0)
	tween.add_callback("flicker_1")
	tween.add_attribute("rotation_degrees", - 45, 2.0)
	tween.add_callback("flicker_2")
	tween.add_attribute("rotation_degrees", 25, 2.0)
	tween.add_callback("flicker_1")
	tween.add_attribute("rotation_degrees", - 45, 2.0)
	tween.add_callback("flicker_2")
	tween.add_attribute("rotation_degrees", 45, 2.0)
	tween.add_callback("flicker_1")
	tween.add_attribute("rotation_degrees", 0, 1.5)
	tween.add_callback("finished_rotating")

func flicker_1() -> void :
	for l in lightnings:
		l.flicker()
		
func flicker_2() -> void :
	for l in lightnings2:
		l.flicker()

func finished_rotating() -> void :
	desperation_finished = true

func end_lightning() -> void :
	for l in lightnings:
		l.finish()
	for l in lightnings2:
		l.finish()
		
func deactivate_lightning() -> void :
	for l in lightnings:
		l.deactivate()
	for l in lightnings2:
		l.deactivate()

func move_upward() -> void :
	tween.create(Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)
	tween.add_attribute("global_position:y", character.global_position.y - 64, 1.25, character)
	

func go_to_center() -> void :
	tween.create(Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)
	var final_pos = space.get_center()
	final_pos.y += 8
	tween.add_attribute("global_position", final_pos, 1.25, character)
	tween.add_callback("at_center")

func at_center() -> void :
	pass

func _Interrupt() -> void :
	emit_signal("stop")
	lightning_loop.stop()
	deactivate_lightning()
	character.emit_signal("damage_reduction", 1)
	
func deactivate_ground_attacks():
	var ground_attacks = [$"../VileJump", $"../VileDash", $"../VileCannon", $"../VileMissiles"]
	for attack in ground_attacks:
		attack.deactivate()

func activate_air_attacks():
	var air_attacks = [$"../VileAirCannon", $"../VileAirMissile", $"../VileAirDash"]
	for attack in air_attacks:
		attack.activate()
