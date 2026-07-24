extends PickUp

export var extra_lives: = 1
	
func process_effect(_delta) -> void :
	pass

func process_state(delta) -> void :
	if is_on_floor():
		time_since_spawn += delta
		if expirable and not executing:
			if time_since_spawn > duration * 0.75:
				set_modulate(Color(1, 1, 1, abs(round(cos(time_since_spawn * 500)))))
			if time_since_spawn > duration:
				queue_free()

func _on_area2D_body_entered(body: Node) -> void :
	if not executing:
		if body.is_in_group("Player"):
			executing = true
			visible = false
			$sound.play()
			add_lives()

func add_lives() -> void :
	var current_lives = GlobalVariables.get("player_lives")
	GlobalVariables.set("player_lives", current_lives + extra_lives)
	Tools.timer(3.0, "queue_free", self)
	
