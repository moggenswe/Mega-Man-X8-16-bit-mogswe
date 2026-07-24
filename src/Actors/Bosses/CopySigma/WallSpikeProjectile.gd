extends GenericProjectile
var exploded: = false
onready var vanish: AudioStreamPlayer2D = $vanish
onready var fire_1: Particles2D = $animatedSprite / fire1
onready var fire_2: Particles2D = $animatedSprite / fire2
onready var fire_3: Particles2D = $animatedSprite / fire3

func _Update(delta) -> void :
	if not exploded and is_on_ceiling():
		explode()

func _OnHit(_d) -> void :
	pass

func explode() -> void :
	fire_1.emitting = false
	fire_2.emitting = false
	fire_3.emitting = false
	exploded = true
	animatedSprite.play("explode")
	disable_damage()
	Tools.timer(1, "destroy", self)
	vanish.play_rp()
