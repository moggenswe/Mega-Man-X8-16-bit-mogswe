extends EnemyDeath

func extra_actions_after_death() -> void :
	Event.emit_signal("miniboss_kill")

func get_spawn_item():
	return GameManager.get_next_spawn_item(100, 0, 0, 0, 0, 100)
