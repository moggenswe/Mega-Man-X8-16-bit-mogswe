extends TextureRect

onready var icon_bg: TextureRect = $"../icon_bg"
onready var tween: = TweenController.new(self, false)
export var fullset_signal: = "full_"
const flash_duration: = 0.5
onready var animated_sprite: AnimatedSprite = $"../animatedSprite"


func _ready() -> void :
	Event.connect(fullset_signal, self, "full_set")
	Event.connect("mixed_set", self, "reset")
	icon_bg.visible = false
	visible = false
	pass


func full_set() -> void :
	animated_sprite.frame = 0
	modulate.a = 1.0
	self_modulate = Color(7, 7, 7, 1)
	icon_bg.self_modulate = Color(7, 7, 7, 1)
	tween.reset()
	tween.attribute("self_modulate", Color.white, flash_duration)
	tween.attribute("self_modulate", Color.white, flash_duration, icon_bg)
	material.set_shader_param("grayscale", false)


func reset() -> void :
	tween.reset()
	material.set_shader_param("grayscale", true)
	modulate.a = 0.75


func display() -> void :
	icon_bg.visible = true
	visible = true
