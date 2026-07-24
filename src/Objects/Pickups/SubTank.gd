extends LifeUp


func _ready() -> void :
	pass

func _physics_process(delta: float) -> void :
	if timer > 0:
		timer += delta
		if timer > 1.5:
			if not $audioStreamPlayer2D.playing:
				timer = 0
				GameManager.unpause(name)
				GameManager.player.equip_subtank(collectible_name)
				GlobalVariables.set(collectible_name, 0)
				queue_free()
				

func process_increase_health(_delta: float) -> void :
	pass

func achievement_check() -> void :
	print("Achievements: checking subtanks...")
	var subtanks = 0
	for collectible in GameManager.collectibles:
		if "subtank" in collectible:
			subtanks += 1
	
	if subtanks == 4:
		Achievements.unlock("COLLECTALLSUBTANKS")
	else:
		Savefile.save()
