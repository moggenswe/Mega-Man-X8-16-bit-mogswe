extends EnemyDamage
class_name BossDamage


export var debugging: = false
export var debug_visual: = false
export var activate_after_intro: = true
export var weakenesses: Array
export var weakness_multiplier: = 1.0
const normal_invulnerability_time: = 0.06
const weakness_invulnerability_time: = 1.75
const charged_weakness_invul_time: = 2.15
const normal_flash_time: = 0.35
const buster_family = ["Buster", "Lemon"]
var hit_by_weakeness: = false
var can_get_hit: = false
var custom_hitbox
signal charged_weakness_hit
signal took_damage
var debug_last_hit: = 0.0

func _ready() -> void :
	if get_node_or_null("dps"):
		$dps.visible = false
	can_get_hit = debugging
	if activate_after_intro:
		character.listen("intro_concluded", self, "activate_get_hit")
	character.listen("damage_reduction", self, "set_damage_reduction")
	add_weakness("GigaCrash")
	deactivate()

func add_weakness(weakness: String):
	if not weakness in weakenesses:
		print_debug("adding weakness to " + weakness)
		weakenesses.append(weakness)
		print_debug("current weaknesses: " + str(weakenesses))

func remove_weakness(weakness: String):
	print_debug("removing weakness to " + weakness)
	weakenesses.erase(weakness)
	print_debug("current weaknesses: " + str(weakenesses))

func activate_get_hit():
	can_get_hit = true
	activate()
	GameManager.debug_boss_fight_start(character.name, character.max_health)

func should_call_hit(_inflicter) -> bool:
	return can_get_hit

func connect_area_events():
	for child in get_children():
		if child is Area2D:
			custom_hitbox = child
			child.connect("body_entered", self, "_on_area2D_body_entered")
			child.connect("body_exited", self, "_on_area2D_body_exited")
			return
	area2D.connect("body_entered", self, "_on_area2D_body_entered")
	area2D.connect("body_exited", self, "_on_area2D_body_exited")


func reduce_health(_damage, inflicter) -> void :
	debug_last_hit = OS.get_ticks_msec()
	Event.emit_signal("hit_enemy")
	var dmg_value = 1
	if "damage_to_bosses" in inflicter:
		dmg_value = inflicter.damage_to_bosses * damage_reduction
	if is_weakness(inflicter):
		dmg_value = handle_weakness(inflicter)
	else:
		character.reduce_health(dmg_value)
		max_flash_time = normal_flash_time
		invulnerability_time = normal_invulnerability_time
	emit_signal("took_damage")
	emit_signal("got_hit", inflicter)
	increment_pds(dmg_value)
	GameManager.debug_boss_fight_log_hit(dmg_value, inflicter.name, character.current_health)

func is_weakness(inflicter) -> bool:
	for word in weakenesses:
		if word in inflicter.name:
			return true
	return false

func is_a_buster(inflicter) -> bool:
	for word in buster_family:
		if word in inflicter.name:
			return true
	return false

func handle_weakness(inflicter) -> float:
	var dmg_value = 0.0
	dmg_value = inflicter.damage_to_weakness * weakness_multiplier * damage_reduction
	character.reduce_health(dmg_value)
	if "Charged" in inflicter.name or "Punch" in inflicter.name:
		print_debug("Hit by charged weakness for " + str(dmg_value))
		invulnerability_time = charged_weakness_invul_time
		emit_signal("charged_weakness_hit", get_inflicter_direction(inflicter))
	else:
		print_debug("Hit by weakness for " + str(dmg_value))
		invulnerability_time = weakness_invulnerability_time
	max_flash_time = invulnerability_time
	return dmg_value
	
func get_inflicter_direction(inflicter) -> int:
	if inflicter.global_position.x < global_position.x:
		return 1
	else:
		return - 1

func play_shader():
	if not character.has_health():
		max_flash_time = invulnerability_time / 6
		
	animatedSprite.material.set_shader_param("Flash", 1)
	if debug_visual:
		animatedSprite.material.set_shader_param("Should_Blink", 1)
	if character.current_health > 0:
		i_timer = 0.01
	else:
		i_timer = normal_flash_time / 2

func stop_shader() -> void :
	animatedSprite.material.set_shader_param("Flash", 0)
	animatedSprite.material.set_shader_param("Should_Blink", 0)
	

func should_stop_blinking() -> bool:
	if debug_visual:
		return not character.is_invulnerable()
		
	return i_timer > max_flash_time

func apply_invulnerability_or_death() -> void :
		if character.current_health <= 0:
			GameManager.debug_boss_fight_end()
			character.emit_zero_health_signal()
		else:
			character.set_invulnerability(invulnerability_time)
			character.emit_signal("got_hit")

func deactivate():
	
	active = false
	if custom_hitbox != null:
		custom_hitbox.get_node("collisionShape2D").call_deferred("set_disabled", true)
	else:
		$"../area2D/collisionShape2D".call_deferred("set_disabled", true)

func activate():
	
	active = true
	if custom_hitbox != null:
		custom_hitbox.get_node("collisionShape2D").call_deferred("set_disabled", false)
	else:
		$"../area2D/collisionShape2D".call_deferred("set_disabled", false)
	

func should_ignore_damage(inflicter) -> bool:
	if character.is_invulnerable() or not character.has_health():
		if not bypass_hit_invulnerable:
			return true
		elif "bypass_shield" in inflicter:
			return false
	if only_on_screen and not GameManager.is_on_screen(character.global_position):
		return true
	if ignore_nearby_hits and character.has_shield():
		if inflicter.is_in_group("Props") or "bypass_shield" in inflicter:
			
			return false
		return true
	return false
