extends EnemyDeath

func get_spawn_item():
	return GameManager.get_next_spawn_item(85, 5, 5, 30, 50, 0.1)


func _on_EnemyDeath_ability_start(_ability) -> void :
	character.set_collision_mask_bit(0, false)
	character.set_collision_mask_bit(9, false)
	pass
