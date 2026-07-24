extends KinematicBody2D
class_name GenericProjectile

export var active: = false
export var debug_logs: = false
export var damage: = 1.0
export var damage_to_bosses: = 1.0
export var damage_to_weakness: = 1.0
export var time_off_screen: = 0.05
var facing_direction: = 1
var last_message
var velocity: = Vector2.ZERO
var timer: = 0.0
var attack_stage: = 0
var creator: Node2D

var off_screen_timer: = 0.0

var damage_ot: Node2D
onready var visibility: = $visibilityNotifier2D
onready var animatedSprite: AnimatedSprite = $animatedSprite

	
signal hit(target)
signal deflect(deflector)
signal projectile_end(projectile)
	
signal zero_health

func _ready() -> void :
	damage_ot = get_node_or_null("DamageOnTouch")
	check_group_and_alert()
	connect_disable_unneeded_object()
	visibility.connect("screen_exited", self, "_OnScreenExit")

func connect_disable_unneeded_object() -> void :
	Event.listen("disable_unneeded_objects", self, "destroy")
	

func initialize(direction) -> void :
	Log("Initializing")
	activate()
	reset_timer()
	set_direction(direction)
	_Setup()

func set_creator(_creator: Node2D) -> void :
	Log("Setting creator: " + _creator.name)
	creator = _creator

func process_movement():
	velocity = move_and_slide_with_snap(velocity, Vector2.ZERO, Vector2.UP, true)

func activate() -> void :
	Log("Activating")
	active = true

func reset_timer() -> void :
	timer = 0

func next_attack_stage() -> void :
	attack_stage += 1
	reset_timer()
	Log("Entering Attack Stage " + str(attack_stage))

func previous_attack_stage() -> void :
	attack_stage -= 1
	reset_timer()
	Log("Entering Attack Stage " + str(attack_stage))

func go_to_attack_stage(stage: int) -> void :
	attack_stage = stage
	reset_timer()
	Log("Entering Attack Stage " + str(attack_stage))
	
func set_direction(new_direction):
	Log("Seting direction: " + str(new_direction))
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction

func get_direction():
	return facing_direction

func get_facing_direction() -> int:
	return get_direction()

func deactivate() -> void :
	Log("Deactivating")
	active = false

func deflect(_body) -> void :
	_OnDeflect()
	emit_signal("deflect", _body)

func hit(_body) -> void :
	if active:
		Log("Hit " + _body.name)
		var target_hp = _DamageTarget(_body)
		_OnHit(target_hp)

func _Setup() -> void :
	pass

func _DamageTarget(_body) -> int:
	return _body.damage(damage, self)

func _OnHit(_target_remaining_HP) -> void :
	disable_visuals()

func _OnDeflect() -> void :
	Log("Deflected")
	disable_visuals()

func _Update(_delta) -> void :
	pass

func _OnScreenExit() -> void :
	Log("Exited Screen")
	destroy()

func _physics_process(delta: float) -> void :
	if active:
		timer += delta
		handle_off_screen(delta)
		_Update(delta)
		process_movement()

func handle_off_screen(delta: float) -> void :
	if off_screen_timer > time_off_screen:
		Log("Off screen for too long, destroying")
		destroy()
	elif not visibility.is_on_screen():
		off_screen_timer += delta
	else:
		off_screen_timer = 0

func disable_visuals():
	Log("Disabling Visuals")
	$animatedSprite.visible = false
	destroy()

func disable_damage():
	if damage_ot != null:
		damage_ot.deactivate()

func enable_visuals():
	Log("Enabling Visuals")
	$animatedSprite.visible = true


func leave(_body) -> void :
	pass

func destroy():
	Log("Being Destroyed")
	emit_signal("projectile_end", self)
	queue_free()

func set_horizontal_speed(speed: float):
	velocity.x = speed

func add_horizontal_speed(speed: float):
	velocity.x = velocity.x + speed
	
func get_horizontal_speed() -> float:
	return velocity.x

func get_vertical_speed() -> float:
	return velocity.y
	
func add_vertical_speed(speed: float):
	velocity.y = velocity.y + speed

func set_vertical_speed(speed: float):
	velocity.y = speed

func check_group_and_alert() -> void :
	if not is_in_group("Player Projectile") and not is_in_group("Enemy Projectile"):
		print_debug(name + ": Not in any projectile group.")

func Log(msg) -> void :
	if debug_logs:
		if not last_message == str(msg):
			if is_instance_valid(creator):
				print(creator.name + "." + name + ": " + str(msg))
			else:
				print(name + ": " + str(msg))
			last_message = str(msg)

func listen(event_name: String, listener, method_to_call: String):
	var error_code = connect(event_name, listener, method_to_call)
	if error_code != 0:
		print(name + ".listen: Connection error. Code: " + str(error_code))
		print(listener.name + "'s method " + method_to_call + " on event " + event_name)

func process_gravity(_delta: float, gravity: = 900.0, max_fall_speed: = 400.0) -> void :
	add_vertical_speed(gravity * _delta)
	if get_vertical_speed() > max_fall_speed:
		set_vertical_speed(max_fall_speed)
