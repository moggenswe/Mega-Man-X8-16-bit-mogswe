extends EnemyDeath
signal screen_flash
onready var reploid: AnimatedSprite = $reploid

func get_spawn_item():
	return GameManager.get_next_spawn_item(100, 0, 100, 0, 0, 0)

func _ready() -> void :
	Tools.timer(0.1, "rename", self)

func rename():
	name = "BossDeath"
	
func _on_EnemyDeath_ability_start(_ability) -> void :
	pass
	
	

func extra_actions_after_death() -> void :
	emit_signal("screen_flash")
	pass

func extra_actions_at_death_start() -> void :
	Event.emit_signal("gateway_boss_defeated", character.name.to_lower())
	character.set_horizontal_speed(0)
	character.set_vertical_speed(0)
	reploid.material = sprite.material
	sprite.material.set_shader_param("Alpha_Blink", 1)
