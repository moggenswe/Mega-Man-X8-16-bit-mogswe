extends Node

export var dialogue: Resource
var started: = false
func _ready() -> void :
	Tools.timer(3, "start", self)

func start():
	if Configurations.get("AutoSkipDialog"):
		start_gameplay()
	elif not GameManager.was_dialogue_seen(dialogue):
		GameManager.start_dialog(dialogue)
	else:
		start_gameplay()

func start_gameplay():
	if not GameManager.player:
		# On a same-stage reload (e.g. loading a debug save state taken
		# during/before this cutscene), this node's own _ready() timer can
		# fire again before GameManager.player has been reassigned by the
		# freshly-recreated player scene. Wait rather than crash - this
		# would otherwise abort here and skip emitting "gameplay_start"
		# for every listener (recording/ghost playback) for the rest of
		# the level.
		Tools.timer(0.1, "start_gameplay", self)
		return
	started = true
	print("Starting Gameplay.........................")
	GameManager.player.activate()
	Event.emit_signal("gameplay_start")
	GameManager.player.reactivate_charge()


func _on_dialog_concluded() -> void :
	if not started:
		start_gameplay()
