extends Object
class_name TweenController

var tween_list: Array
var owner: Node
func _init(_owner, connect: = true) -> void :
	owner = _owner
	if connect:
		connect_reset()

func connect_reset(end_signal: = "stop") -> void :
	owner.connect(end_signal, self, "reset")

func create(ease_type: = Tween.EASE_IN_OUT, trans_type: = Tween.TRANS_LINEAR, parallel: = false, loops: = 1) -> void :
	var tween: = owner.create_tween()
	tween.set_ease(ease_type).set_trans(trans_type).set_parallel(parallel).set_loops(loops)
	tween_list.append(tween)

func set_loops(value: = - 1) -> void :
	get_last().set_loops(value)

func set_ease(ease_type: = Tween.EASE_IN_OUT, trans_type: = Tween.TRANS_LINEAR) -> void :
	get_last().set_ease(ease_type).set_trans(trans_type)
	

func attribute(attribute: String, final_value = 1.0, duration: = 0.25, object = owner) -> void :
	var tween: = owner.create_tween()

	final_value = match_property_type(object, attribute, final_value)
	tween.tween_property(object, attribute, final_value, duration)
	tween_list.append(tween)

func method(method: String, initial_value: = 0.0, final_value: = 1.0, duration: = 0.25, object = owner) -> void :
	var tween: = owner.create_tween()

	var values = match_value_types(initial_value, final_value)
	tween.tween_method(object, method, values[0], values[1], duration)
	tween_list.append(tween)

func callback(method: String, delay: = 1.0, object = owner, binds = []) -> void :
	var tween: = owner.create_tween()
	tween.tween_callback(object, method, binds).set_delay(delay)
	tween_list.append(tween)

func add_callback(method: String, object = owner, binds = []) -> void :

	get_last().tween_callback(object, method, binds)

func add_attribute(attribute: String, final_value = 1.0, duration: = 0.25, object = owner) -> void :

	final_value = match_property_type(object, attribute, final_value)
	get_last().tween_property(object, attribute, final_value, duration)

func add_method(method: String, initial_value: = 0.0, final_value: = 1.0, duration: = 0.25, object = owner, binds = []) -> void :

	var values = match_value_types(initial_value, final_value)
	get_last().tween_method(object, method, values[0], values[1], duration, binds)

func add_wait(wait_duration: = 0.25) -> void :

	get_last().tween_interval(wait_duration)

func end_ability() -> void :
	set_sequential()
	add_callback("EndAbility", owner)

func set_ease_out() -> void :

	get_last().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func set_sequential():
	get_last().set_parallel(false)

func set_parallel():
	get_last().set_parallel(true)

func set_ignore_pause_mode():
	get_last().set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)

func get_last() -> SceneTreeTween:
	return tween_list.back()

func pause() -> void :
	for tween in tween_list:
		if tween.is_valid():
			tween.pause()
	pass
func unpause() -> void :
	for tween in tween_list:
		if tween.is_valid():
			tween.play()

func reset(_discard = null) -> void :
	for tween in tween_list:
		if tween.is_valid():
			tween.kill()

func end() -> void :
	for tween in tween_list:
		if tween.is_valid():
			tween.custom_step(10000.0)

func custom_step(step) -> void :

	get_last().custom_step(step)

func is_valid() -> bool:
	for tween in tween_list:
		if tween.is_valid():
			return true
	return false

static func match_property_type(object, attribute: String, final_value):
	var current_value = object.get_indexed(attribute)
	if typeof(current_value) == TYPE_REAL and typeof(final_value) == TYPE_INT:
		return float(final_value)
	elif typeof(current_value) == TYPE_INT and typeof(final_value) == TYPE_REAL:
		return int(round(final_value))
	return final_value

# SceneTreeTween's MethodTweener requires initial_value and final_value to be
# the exact same Variant type as each other (there's no target property to
# check against, unlike match_property_type above). Coerces the int side to
# float when they differ - float is what every caller in this codebase means
# (speed/position/alpha/etc.), never the reverse, so this never truncates.
static func match_value_types(initial_value, final_value) -> Array:
	if typeof(initial_value) == TYPE_INT and typeof(final_value) == TYPE_REAL:
		return [float(initial_value), final_value]
	elif typeof(initial_value) == TYPE_REAL and typeof(final_value) == TYPE_INT:
		return [initial_value, float(final_value)]
	return [initial_value, final_value]
