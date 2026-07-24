extends SimplePlayerProjectile

export var laser: PackedScene

var duration: = 2.0
var tracked: Node2D
var initial_speed: = 80.0
var pursuit_speed: = 120.0
onready var ground_check: RayCast2D = $ground_check

func _Setup() -> void :
	set_horizontal_speed(initial_speed * get_facing_direction())
	Tools.timer(duration, "fire_laser", self)
	Tools.tween(animatedSprite, "speed_scale", 2.0, duration)

func _Update(_delta) -> void :
	if is_tracking():
		if is_distant_enough():
			var target_angle = get_angle_to(tracked.global_position)
			var normalized_angle = Vector2(cos(target_angle), sin(target_angle))
			set_horizontal_speed(normalized_angle.x * pursuit_speed)
			set_vertical_speed(normalized_angle.y * pursuit_speed)
		else:
			set_horizontal_speed(0)
			set_vertical_speed(0)

func fire_laser() -> void :
	var ground_position = Vector2(global_position.x, global_position.y + 256)
	if ground_check.is_colliding():
		ground_position = ground_check.get_collision_point()
	create_laser(ground_position)
	destroy()

func is_distant_enough() -> bool:
	var distance: = global_position.distance_to(tracked.global_position)
	return distance > 8.0

func is_tracking() -> bool:
	if tracked:
		if tracked.has_health():
			return true
		else:
			tracked = null
			stop_tracking()
	return false

func stop_tracking() -> void :
	set_horizontal_speed(get_horizontal_speed() / 3)
	set_vertical_speed(get_vertical_speed() / 3)

func _on_tracker_body_entered(body: Node) -> void :
	if not is_tracking():
		if body.has_health():
			tracked = body
			
func create_laser(ground_position) -> void :
	var instance = laser.instance()
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	
