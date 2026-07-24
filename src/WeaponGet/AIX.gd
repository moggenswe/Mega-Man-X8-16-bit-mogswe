extends "res://src/Actors/Player.gd"


func has_just_pressed_left() -> bool:
	return get_action_just_pressed("left_emulated")
	
func has_just_pressed_right() -> bool:
	return get_action_just_pressed("right_emulated")

func check_for_dash():
	if get_action_just_pressed("dash_emulated"):
		Event.emit_signal("input_dash")

func get_action_pressed(action) -> bool:
	if listening_to_inputs:
		return Input.is_action_pressed(action)
	return false

func get_just_pressed_axis() -> int:
	return less_buggy_pressed_dir

func get_pressed_axis() -> int:
	return less_buggy_pressed_dir
	
var less_buggy_pressed_dir: = 0
func _input(event: InputEvent) -> void :
	if event.is_action_pressed("right_emulated"):
		less_buggy_pressed_dir = 1
	elif event.is_action_released("right_emulated"):
		less_buggy_pressed_dir = 0
	if event.is_action_pressed("left_emulated"):
		less_buggy_pressed_dir = - 1
	elif event.is_action_released("left_emulated"):
		less_buggy_pressed_dir = 0
