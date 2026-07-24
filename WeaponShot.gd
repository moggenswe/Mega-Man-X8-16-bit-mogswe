extends Actor
class_name WeaponShot

export var damage: = 1.0
export var damage_to_bosses: = 1.0
export var damage_to_weakness: = 1.0
export var horizontal_velocity: = 360.0
export var vertical_position_range: = 1
export var time_outside_screen: = 0.4
export var fire_sound: AudioStream
export var hit_sound: AudioStream
export var hit: PackedScene
export var break_guards: = false
var countdown_to_destruction: = 0.0
var facing_direction: = 1
var original_pitch: = 1.0
var timer_since_spawn: = 0.0
var continuous_damage: = false

onready var audio = $audioStreamPlayer2D
onready var visibilityNotifier: = $visibilityNotifier2D
var damageOnTouch
onready var hit_particle = get_node("Hit Particle")
var emitted_hit_particle = false

signal hit
	
signal projectile_started
signal projectile_end(this)

func _ready() -> void :

	visibilityNotifier.connect("screen_exited", self, "_on_visibilityNotifier2D_screen_exited")
	Event.listen("disable_unneeded_objects", self, "disable_visual_and_mechanics")
	if not is_in_group("Player Projectile") and not is_in_group("Enemy Projectile"):
		print_debug(name + ": Not in any projectile group.")

func emit_hit_particle():
	if not emitted_hit_particle:
		hit_particle.emit(facing_direction)
		emitted_hit_particle = true

func _physics_process(delta: float) -> void :
	timer_since_spawn += delta
	if not has_health():
		disable_visual_and_mechanics()
		emit_hit_particle()
	
	if countdown_to_destruction > 0:
		countdown_to_destruction += delta
	
		if countdown_to_destruction > time_outside_screen:
			destroy()
	
	elif timer_since_spawn > 2:
		if not visibilityNotifier.is_on_screen():
			destroy()


func hit(_body) -> void :
	if hit_sound:
		$audioStreamPlayer2D.stream = hit_sound
		$audioStreamPlayer2D.play()
	_body.damage(damage, self)
	emit_hit_particle()
	disable_visual_and_mechanics()
	emit_signal("hit")

func deflect(_body) -> void :
	disable_visual_and_mechanics()

func disable_visual_and_mechanics():
	disable_projectile_visual()
	disable_particle_visual()
	call_deferred("disable_damage")
	countdown_to_destruction = 0.01
	

func leave(_body) -> void :
	pass

func projectile_setup(direction: int, spawn_point: Vector2, launcher_velocity: = 0.0):
	references_setup(direction)
	position_setup(spawn_point, direction)
	launch_setup(direction, launcher_velocity)
	play_fire_sound()
	call_deferred("emit_signal", "projectile_started")
	
func references_setup(direction):
	set_direction(direction)
	update_facing_direction()
	animatedSprite.scale.x = direction
	original_pitch = audio.pitch_scale
	
func position_setup(spawn_point: Vector2, direction: int):
	var x = spawn_point.x
	var y = spawn_point.y
	position.x = position.x + x * direction
	position.y = position.y + y + int(rand_range( - vertical_position_range, vertical_position_range))
	facing_direction = direction
	
func play_fire_sound(pitch: = true):
	if fire_sound != null:
		if pitch:
			audio.pitch_scale = original_pitch + rand_range( - 0.05, 0.0)
		audio.stream = fire_sound
		audio.play()

func launch_setup(_direction, launcher_velocity: = 0.0):
	set_horizontal_speed((horizontal_velocity + launcher_velocity) * _direction)

func disable_projectile_visual():
	animatedSprite.visible = false

func disable_particle_visual():
	$particles2D.visible = false

func destroy():
	emit_signal("projectile_end", self)
	queue_free()

func _on_visibilityNotifier2D_screen_exited() -> void :
	countdown_to_destruction = 0.01
	
func disable_damage():
	if damageOnTouch == null:
		damageOnTouch = get_node("DamageOnTouch")
	if damageOnTouch != null:
		damageOnTouch.deactivate()

func can_be_hit() -> bool:
	return animatedSprite.visible
