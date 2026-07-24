extends NewAbility

var destroy_damage: = 8
var rider
var recent_rider
var player_nearby: = false
onready var ceiling_check: RayCast2D = $ceiling_check
onready var ceiling_check_2: RayCast2D = $ceiling_check2

onready var animation = AnimationController.new($"../animatedSprite", self)

signal rider_on
signal rider_off

func should_execute() -> bool:
	if ceiling_check.is_colliding():
		return false
	return character.active and character.has_health() and current_conflicts.size() == 0

func _Setup() -> void :
	make_rider()
	emit_signal("rider_on")

func _Update(_delta) -> void :
	if not rider.has_health():
		character.emit_signal("death")

func _Interrupt() -> void :
	eject()
	emit_signal("rider_off")
	
func _on_body_enter(body) -> void :
	if should_execute() and is_rideable(body):
		rider = body.get_character()
		recent_rider = body.get_character()
		_on_signal()

func reenable_ride_time() -> void :
	recent_rider = null

func is_rideable(player) -> bool:
	var non_states: = ["Ride", "Forced", "Finish", "Intro"]
	if GameManager.player:
		if not GameManager.player.listening_to_inputs:
			return false
	if player.has_method("get_character"):
		var character = player.get_character()
		if character.has_method("is_executing_either"):
			if not character.is_executing_either(non_states):
				return recent_rider == null
	return false

func make_rider() -> void :
	parent_rider_to_self(rider)
	rider.modulate = Color(1, 1, 1, 0.01)
	rider.emit_signal("land")
	rider.ride(character)
	rider.disable_collision()
	Event.emit_signal("ridearmor_activate")
	Log("Controlled by " + rider.name)

func parent_rider_to_self(_rider):
	_rider.get_parent().remove_child(_rider)
	get_parent().call_deferred("add_child", _rider)

func eject():
	remove_rider()
	rider = null

func force_eject():
	Log("Explosion force ejected rider.")
	remove_rider()
	if is_instance_valid(rider):
		rider.damage(destroy_damage, rider)
	rider = null

func remove_rider():
	if is_instance_valid(rider):
		Log("Ejecting: " + rider.name)
		return_rider_to_original_parent()
		rider.enable_collision()
		rider.eject(character)
		rider.modulate = Color(1, 1, 1, 1)
		Event.emit_signal("ridearmor_deactivate")
		Tools.timer(0.65, "reenable_ride_time", self)

func return_rider_to_original_parent():
	get_parent().remove_child(rider)
	get_parent().get_parent().add_child(rider)
	rider.global_position = global_position
	rider.global_position.y = global_position.y + 12


func _on_new_direction(dir) -> void :
	scale.x = dir

