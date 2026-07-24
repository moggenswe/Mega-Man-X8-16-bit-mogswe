class_name VileLightning extends Node2D

var rotate_speed: = 60
export var frames: Array
onready var line: Line2D = $line
onready var collision: AnimatedSprite = $line / finish
onready var ray: RayCast2D = $ray
onready var end: = $end
onready var area_2d: Area2D = $DamageOnTouch / area2D
onready var damage_on_touch: Node2D = $DamageOnTouch
onready var finish_particles: Particles2D = $finish_particles

var executing = false

func _ready() -> void :
	deactivate()

func prepare() -> void :
	finish_particles.emitting = true

func activate() -> void :
	set_physics_process(true)
	set_process(true)
	damage_on_touch.activate()
	line.visible = true
	executing = true

func finish() -> void :
	finish_particles.emitting = true
	deactivate()

func deactivate() -> void :
	set_physics_process(false)
	set_process(false)
	damage_on_touch.deactivate()
	line.visible = false
	executing = false

func flicker() -> void :
	offlick()
	Tools.timer(0.1, "flick", self)
	Tools.timer(0.2, "offlick", self)
	Tools.timer(0.5, "flick", self)
	Tools.timer(0.6, "offlick", self)
	Tools.timer(0.7, "unflick", self)

func offlick() -> void :
	if executing:
		line.visible = false
		damage_on_touch.deactivate()

func flick() -> void :
	if executing:
		line.visible = true

func unflick() -> void :
	if executing:
		line.visible = true
		damage_on_touch.activate()

func _physics_process(_delta: float) -> void :
	if visible:
		if ray.is_colliding():
			set_line_position(to_local(ray.get_collision_point()))
		else:
			set_line_position(end.position)

func set_line_position(hit_position) -> void :
	line.points[1] = hit_position
	collision.position = hit_position
	area_2d.scale.y = hit_position.y

func _process(_delta: float) -> void :
	if visible:
		line.texture = frames[collision.frame]
