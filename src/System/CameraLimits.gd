extends Area2D
class_name CameraLimits
export var debug: = false
export var disabled: = false
var can_be_disabled: = true
signal accessed
onready var collider: CollisionShape2D = $collisionShape2D

onready var limits = get_child(0)

func disable(_b = null) -> void :
	if can_be_disabled:
		disabled = true
		modulate = Color.red
		debug_print("disabled.")

func enable(_b = null) -> void :
	disabled = false
	modulate = Color.white
	collider.set_deferred("disabled", true)
	collider.set_deferred("disabled", false)
	debug_print("enabled.")

func enable_and_translate(_b = null) -> void :
	enable()
	can_be_disabled = false
	GameManager.camera.start_door_translate(global_position, self)

func soft_disable(_b = null) -> void :
	push_error("deprecated, use disable instead")
	disable(_b)

func get_limit_left() -> float:
	on_access()
	return limits.global_position.x - limits.shape.extents.x

func get_limit_right() -> float:
	on_access()
	return limits.global_position.x + limits.shape.extents.x

func get_limit_top() -> float:
	on_access()
	return limits.global_position.y - limits.shape.extents.y

func get_limit_bottom() -> float:
	on_access()
	return limits.global_position.y + limits.shape.extents.y

func on_access() -> void :
	emit_signal("accessed")
	

func debug_print(message) -> void :
	if debug:
		print_debug("CameraZone " + name + ": " + str(message))


func deactivate() -> void :
	disable()
	
func enable_and_update():
	if disabled:
		enable()
		GameManager.camera.update_area_limits(self)
		
	pass


func activate() -> void :
	if disabled:
		enable_and_translate()
