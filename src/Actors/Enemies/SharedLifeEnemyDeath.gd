extends EnemyDeath


func get_spawn_item():
	return GameManager.get_next_spawn_item(100.0, 0, 0, 0, 0, 100)
