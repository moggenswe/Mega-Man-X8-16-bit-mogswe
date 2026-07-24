extends SimplePlayerProjectile
var target_list: Array
var interval: = 0.064
const continuous_damage: = true
const bypass_shield: = true
const destroyer: = true
onready var thunder: AudioStreamPlayer2D = $thunder
onready var animated_sprite_2: AnimatedSprite = $animatedSprite2
onready var light: Light2D = $light

func _DamageTarget(body) -> int:
	target_list.append(body)
	return 0

func _OnHit(_target_remaining_HP) -> void :
	pass

func _OnDeflect() -> void :
	pass

func _Setup() -> void :
	Tools.timer(0.12, "mid_animation", self)
	Tools.timer(1.45, "end_animation", self)
	thunder.play_rp(0.07, 0.85)
	animatedSprite.playing = true
	animated_sprite_2.playing = true
	next_attack_stage()

func mid_animation() -> void :
	animatedSprite.play("loop")
	animated_sprite_2.play("loop")

func end_animation() -> void :
	animatedSprite.play("end")
	animated_sprite_2.play("end")
	light.dim(0.5, 0)
	next_attack_stage()

func _Update(_delta) -> void :
	if attack_stage == 1:
		if timer > interval:
			damage_targets_in_list()
			timer = 0.0
			Event.emit_signal("screenshake", 0.2)
	
	elif attack_stage == 2:
		disable_damage()
		if timer > 0.5:
			disable_visuals()
			next_attack_stage()
	
	if ending and timer > 1.2:
		destroy()

func damage_targets_in_list() -> void :
	if target_list.size() > 0:
		for body in target_list:
			if is_instance_valid(body):
				body.damage(damage, self)

func leave(_body) -> void :
	if _body in target_list:
		target_list.erase(_body)
