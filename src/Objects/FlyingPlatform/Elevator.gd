extends Node2D

export var movespeed: = - 60
export var active: = true
var speed: = 0

signal activated
signal player_reached_bottom

func start(_b) -> void :
	active = true
	speed = movespeed
	emit_signal("activated")

func stop() -> void :
	active = false
	speed = 0

func emit_reached_signal(_b) -> void :
	emit_signal("player_reached_bottom")
