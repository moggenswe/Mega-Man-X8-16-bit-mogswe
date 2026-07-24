extends Node2D
class_name NewAbility, "res://src/HUD/ability_icon.png"

export var active: = true
export var hard_conflicts: Array
export var soft_conflicts: Array
var current_conflicts: Array
var executing: = false
var timer: = 0.0
signal start(ability_name)
signal stop(ability_name)
onready var character = get_character()

func _ready() -> void :
	connect_conflicts()

func get_character():
	return get_parent()

func connect_conflicts() -> void :
	for nodepath in hard_conflicts:
		var ability = get_node(nodepath)
		ability.connect("start", self, "_on_hard_conflict")
		ability.connect("stop", self, "_on_hard_conflict_stop")
	for nodepath in soft_conflicts:
		var ability = get_node(nodepath)
		ability.connect("start", self, "_on_soft_conflict")
	

func _on_signal(_p = null) -> void :
	if active:
		if not is_executing():
			if should_execute():
				if _StartCondition():
					execute()
				else:
					Log("StartCondition returned false")
			else:
				Log("Should_execute returned false")
		else:
			
			pass
	else:
		Log("Deactivated")

func is_executing() -> bool:
	return executing

func should_execute() -> bool:
	if character.has_method("should_execute_abilities"):
		return character.should_execute_abilities() and current_conflicts.size() == 0
	else:
		return current_conflicts.size() == 0
		
func execute() -> void :
	emit_signal("start", name)
	executing = true
	_Setup()

func _physics_process(delta: float) -> void :
	if is_executing():
		timer += delta
		if _EndCondition():
			end()
		else:
			_Update(delta)

func _on_hard_conflict(ability_name: String) -> void :
	Log("detected hard conflict with " + ability_name)
	current_conflicts.append(ability_name)
	if is_executing():
		end()

func _on_soft_conflict(ability_name: String) -> void :
	Log("detected soft conflict with " + ability_name)
	if is_executing():
		end()
		
func _on_hard_conflict_stop(ability_name: String) -> void :
	current_conflicts.erase(ability_name)

func EndAbility() -> void :
	end()

func end() -> void :
	executing = false
	_Interrupt()
	timer = 0
	emit_signal("stop", name)



func _StartCondition() -> bool:
	return true

func _Setup() -> void :
	pass
	
func _Update(_delta) -> void :
	set_physics_process(false)
	

func _EndCondition() -> bool:
	return false

func _Interrupt() -> void :
	pass



func activate() -> void :
	active = true
func deactivate() -> void :
	active = false

export var debug_logs: = false
func Log(msg) -> void :
	if debug_logs:
		print_debug(get_parent().name + "." + name + ": " + str(msg))
