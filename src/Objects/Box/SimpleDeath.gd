extends Node2D
onready var explosion: Particles2D = $explosion
onready var remains: Particles2D = $remains
onready var box: StaticBody2D = $".."

func activate() -> void :
	explosion.emitting = true
	remains.emitting = true
	spawn_item()

func spawn_item() -> void :
	var item = GameManager.get_next_spawn_item(85, 50, 25, 5, 5, 1)
	if item:
		var spawned_item = item.instance()
		spawned_item.global_position = box.global_position
		spawned_item.velocity.y = - 100
		spawned_item.expirable = true
		box.get_parent().call_deferred("add_child", spawned_item)
