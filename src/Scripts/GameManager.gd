extends Node

const codename: = "X8FC"
const version: = "1.0.0.9 - Tchy, Rose Xorn & Mogswe's Speedrun Version V.1.0.0.9"
const current_demo: = "16-bit"

var player: Character
var camera: Camera2D
var state: = "Normal"
var bikes = []
var debug_actions = []
var debug_skip: = 1
var collectibles: = []
var equip_exceptions: = []
var equip_hearts: = true
var equip_subtanks: = true
var seen_dialogues = []
var current_level: String
const heal_spawn = preload("res://src/Objects/Heal.tscn")
const small_heal_spawn = preload("res://src/Objects/SmallHeal.tscn")
const ammo_spawn = preload("res://src/Objects/Pickups/Ammo.tscn")
const small_ammo_spawn = preload("res://src/Objects/Pickups/SmallAmmo.tscn")
const life_spawn = preload("res://src/Objects/Pickups/ExtraLife.tscn")
var last_time_debug_reset: = 0.0
var end_stage_timer: = 0.0
var stage_start_msec: = 0.0

var checkpoint: CheckpointSettings

var checkpoint_cam_width: = Vector2.ZERO
var checkpoint_cam_height: = Vector2.ZERO


const player_life_count: = "player_lives"

var current_stage_info: StageInfo

var time_attack: = false
var ta_status: = "Recording..."

var ghost_file = "user://score.save"

var maximum_distance: = Vector2(480, 320)
var maximum_bike_distance: = Vector2(199, 100)
var debug_go_to_next_stage: = false
var best_recording: = []

var music_player: MusicPlayer
var music_volume: = - 6.0
var dialog_box

var player_died: = false
var pause_sources: Array

var debug_enabled: = false
var last_player_position: = Vector2.ZERO

var lumine_boss_order: Array

# --- Debug: boss fight kill-time / DPS / per-weapon damage tracker ---
# Started from BossDamage.activate_get_hit() (first frame the boss can be
# hit), logged from BossDamage.reduce_health() (every hit, by weapon name),
# stopped from BossDamage.apply_invulnerability_or_death() (the instant
# health hits 0 - the actual kill, not the death animation finishing).
var debug_boss_fight_active: = false
var debug_boss_fight_start_msec: = 0.0
var debug_boss_fight_end_msec: = 0.0
var debug_boss_damage_log: Dictionary = {}
# The HUD only displays the fight info from the kill moment onward (showing
# it live covered too much of the gameplay) - this flag is what it watches to
# know when to start, and it's cleared again once stage select is reached.
var debug_boss_fight_show_result: = false

func debug_boss_fight_start(_boss_name: String = "") -> void :
	debug_boss_fight_active = true
	debug_boss_fight_start_msec = OS.get_ticks_msec()
	debug_boss_fight_end_msec = 0.0
	debug_boss_damage_log = {}
	debug_boss_fight_show_result = false

func debug_boss_fight_log_hit(amount: float, weapon_name: String) -> void :
	if not debug_boss_fight_active:
		return
	if not debug_boss_damage_log.has(weapon_name):
		debug_boss_damage_log[weapon_name] = 0.0
	debug_boss_damage_log[weapon_name] += amount

func debug_boss_fight_end() -> void :
	if not debug_boss_fight_active:
		return
	debug_boss_fight_active = false
	debug_boss_fight_end_msec = OS.get_ticks_msec()
	debug_boss_fight_show_result = true

func debug_boss_fight_reset() -> void :
	debug_boss_fight_active = false
	debug_boss_fight_start_msec = 0.0
	debug_boss_fight_end_msec = 0.0
	debug_boss_damage_log = {}
	debug_boss_fight_show_result = false

func debug_boss_fight_kill_time() -> float:
	if debug_boss_fight_start_msec <= 0.0:
		return 0.0
	var end_msec = debug_boss_fight_end_msec if debug_boss_fight_end_msec > 0.0 else OS.get_ticks_msec()
	return (end_msec - debug_boss_fight_start_msec) / 1000.0

func debug_boss_fight_total_damage() -> float:
	var total: = 0.0
	for weapon_name in debug_boss_damage_log:
		total += debug_boss_damage_log[weapon_name]
	return total

func debug_boss_fight_dps() -> float:
	var elapsed = debug_boss_fight_kill_time()
	if elapsed <= 0.0:
		return 0.0
	return debug_boss_fight_total_damage() / elapsed

func _ready() -> void :
	print("GameManager: Initializing...")
	set_pause_mode(2)
	BossRNG.initialize()
	Savefile.load_save()
	on_level_start()

func start_dialog(dialog_tree) -> void :
	dialog_box.startup(dialog_tree)

func start_capsule_dialog(dialog_tree) -> void :
	dialog_box.startup(dialog_tree)
	dialog_box.connect("dialog_concluded", self, "play_stage_song")

func stop_character_inputs() -> void :
	player.stop_listening_to_inputs()

func resume_character_inputs() -> void :
	print("Resuming Character Inputs...")
	player.start_listening_to_inputs()

func play_song(song: AudioStream) -> void :
	music_player.play_song(song)
	
func play_stage_song() -> void :
	music_player.play_stage_song()

func is_player_in_scene() -> bool:
	if player and is_instance_valid(player):
		return true
	return false

func half_music_volume() -> void :
	Event.emit_signal("half_music_volume")
	if music_player:
		music_volume = music_player.volume_db
		music_player.volume_db = music_volume - 10
	else:
		push_warning("GameManager: No MusicPlayer found.")
	
func normal_music_volume() -> void :
	Event.emit_signal("normal_music_volume")
	if music_player:
		music_player.volume_db = music_volume
	else:
		push_warning("GameManager: No MusicPlayer found.")


func on_level_start():
	print("GameManager: On Level Start...")
	last_player_position = Vector2.ZERO
	player = null
	bikes.clear()
	change_state("Normal")
	call_deferred("add_collectibles_to_player")
	call_deferred("emit_stage_start_signal")
	call_deferred("save_stage_start_msec")
	call_deferred("position_player_on_checkpoint")
	call_deferred("start_stage_music")
	end_stage_timer = 0
	BossRNG.reset_seed()

func start_stage_music() -> void :
	if is_instance_valid(music_player):
		music_player.call_deferred("play_stage_song")

func start_level(StageName: String) -> void :
	
	clear_checkpoint()
	set_player_lives_to_at_least_2()
	current_level = StageName
	var path: String
	if StageName == "NoahsPark":
		path = "res://src/Levels/NoahsPark/Intro_NoahsPark.tscn"
	else:
		path = "res://src/Levels/" + StageName + "/Stage_" + StageName + ".tscn"
	var _dv = get_tree().change_scene(path)
	call_deferred("restart_level")

func set_player_lives_to_at_least_2() -> void :
	if not GlobalVariables.exists(player_life_count) or GlobalVariables.get(player_life_count) < 2:
		GlobalVariables.set(player_life_count, 2)

func go_to_intro() -> void :
	print_debug(":::::::: going to intro")
	var _dv = get_tree().change_scene("res://src/Title/IntroCapcom.tscn")

func go_to_disclaimer() -> void :
	print_debug(":::::::: going to disclaimer")
	var _dv = get_tree().change_scene("res://src/Title/DisclaimerScreen.tscn")

func go_to_igt() -> void :
	print_debug(":::::::: going to igt screen")
	var _dv = get_tree().change_scene("res://src/Screens/IGTScreen.tscn")
	GameManager.call_deferred("restart_level")

func go_to_lumine_boss_test() -> void :
	print_debug(":::::::: going to seraph lumine boss test")
	var _dv = get_tree().change_scene("res://src/Levels/SigmaPalace/SeraphTest.tscn")
	GameManager.checkpoint = null
	GameManager.call_deferred("restart_level")
	

func end_level():
	Event.emit_signal("fade_out")
	end_stage_timer = 0.01
	GameManager.pause("EndLevel")
	debug_go_to_next_stage = true
	Savefile.save()

var won_against_final_boss: = false

func end_game():
	Event.emit_signal("final_fade_out")
	end_stage_timer = 0.01
	GameManager.pause("EndGame")
	debug_go_to_next_stage = true
	won_against_final_boss = true
	Savefile.save()

func on_death():
	Event.emit_signal("fade_out")
	end_stage_timer = 0.01
	GameManager.pause("Death")
	BossRNG.player_died()
	Savefile.save()
	player_died = true

func finished_fade_out() -> void :
	if player_died:
		player_died = false
		
		if current_level == "NoahsPark":
			call_deferred("restart_level")
			

		
		elif GlobalVariables.get(player_life_count) > 0:
			handle_player_death()
			call_deferred("restart_level")

		
		else:
			Event.emit_signal("game_over")
			call_deferred("go_to_stage_select")

	
	else:
		if won_against_final_boss:
			won_against_final_boss = false
			call_deferred("go_to_end_cutscene")
		elif weapon_got and weapon_got != "none":
			call_deferred("go_to_weapon_get")
		else:
			call_deferred("go_to_stage_select")

func go_to_end_cutscene():
	print_debug(":::::::: going to final cutscene")
	var _dv = get_tree().change_scene("res://src/Levels/SigmaPalace/FinalCutscene.tscn")
	call_deferred("force_unpause")
	call_deferred("on_level_start")
	pass
	
func go_to_credits():
	print_debug(":::::::: going to final cutscene")
	var _dv = get_tree().change_scene("res://src/Levels/SigmaPalace/CreditsScene.tscn")
	call_deferred("force_unpause")
	call_deferred("on_level_start")
	pass

func handle_player_death() -> void :
	var lives = GlobalVariables.get(player_life_count)
	print_debug("Player died, current lives: " + str(lives) + " being reduced by 1")
	GlobalVariables.set(player_life_count, lives - 1)

func go_to_stage_select() -> void :
	print_debug(":::::::: going to stage select")
	debug_boss_fight_reset()
	var _dv = get_tree().change_scene("res://src/StageSelect/StageSelectScreen.tscn")

func go_to_weapon_get() -> void :
	print_debug(":::::::: going to weapon get")
	var _dv = get_tree().change_scene("res://src/WeaponGet/WeaponGetScene.tscn")
	call_deferred("force_unpause")
	call_deferred("on_level_start")

func go_to_stage_intro(stage: StageInfo) -> void :
	print_debug(":::::::: going to stage and boss intro")
	current_stage_info = stage
	var _dv = get_tree().change_scene("res://src/BossIntro/BossIntro.tscn")

func restart_level():
	print_debug("::::::::  Restarting level")
	get_tree().reload_current_scene()
	GameManager.force_unpause()
	on_level_start()

func reached_checkpoint(new_checkpoint):
	if GameManager.time_attack:
		return

	if not checkpoint or new_checkpoint.id > checkpoint.id:
		set_checkpoint(new_checkpoint)
	else:
		print_debug("GameManager: Checkpoint not set: " + str(checkpoint.id))

func set_checkpoint(new_checkpoint):
	checkpoint = new_checkpoint
	Event.emit_signal("reached_checkpoint", new_checkpoint)
	print_debug("GameManager: New checkpoint: " + str(checkpoint.id))

func clear_checkpoint() -> void :
	checkpoint = null

func position_player_on_checkpoint() -> void :
	if not player:
		return
	if GameManager.time_attack:
		return
	if checkpoint:
		player.global_position = checkpoint.respawn_position
		player.set_direction(checkpoint.character_direction)
		var last_checkpoint_door = get_node_or_null(checkpoint.last_door)
		if last_checkpoint_door and last_checkpoint_door.has_method("reached_checkpoint"):
			last_checkpoint_door.reached_checkpoint()
		print("GameManager: moved player to checkpoint " + str(checkpoint.id))
		Event.emit_signal("moved_player_to_checkpoint", checkpoint)

func set_player(object):
	print_debug("Setting player: " + object.name)
	player = object
	player.active = false
	player.visible = false
	player.deactivate()

func add_collectibles_to_player():
	if player:
		for collectible in collectibles:
			if not has_equip_exception(collectible):
				player.equip_parts(collectible)
		player.finished_equipping()

func has_equip_exception(collectible: String) -> bool:
	if is_armor(collectible):
		for exception in equip_exceptions:
			if exception in collectible:
				return true
				
	elif is_heart(collectible):
		if not equip_hearts:
			return true
		
	elif is_subtank(collectible):
		if not equip_subtanks:
			print("SSSSSSSSSSSSSSSSSSSSSS Subtank exceptin" + collectible)
			return true
		
	return false

func add_equip_exception(armor_part: String) -> void :
	if not armor_part in equip_exceptions:
		equip_exceptions.append(armor_part)
	else:
		equip_exceptions.erase(armor_part)
		equip_exceptions.append(armor_part)

func remove_equip_exception(armor_part: String) -> void :
	equip_exceptions.erase(armor_part)

func add_collectible_to_savedata(collectible: String):
	if not is_collectible_in_savedata(collectible):
		collectibles.append(collectible)
	else:
		reposition_collectible_in_savedata(collectible)

func remove_collectible_from_savedata(collectible: String):
	if is_collectible_in_savedata(collectible):
		collectibles.erase(collectible)

func is_collectible_in_savedata(collectible: String) -> bool:
	return collectible in collectibles

func reposition_collectible_in_savedata(collectible: String) -> void :
	collectibles.erase(collectible)
	collectibles.append(collectible)

func _physics_process(delta: float) -> void :
	handle_end_of_level(delta)
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		Configurations.set("Fullscreen", OS.window_fullscreen)
		Savefile.save()
	

func handle_end_of_level(delta: float) -> void :
	if end_stage_timer > 0:
		end_stage_timer += delta
		if end_stage_timer > 1:
			GameManager.force_unpause()
			

var primrose_paused: = false

func primrose_pause():
	pause("Primrose")

func primrose_unpause():
	unpause("Primrose")
	
func pause(source: String):
	if not source in pause_sources:
		pause_sources.append(source)
		print("paused by " + source)
	update_pause_state()

func unpause(source: String):
	pause_sources.erase(source)
	print("removed pause of " + source)
	update_pause_state()

func force_unpause():
	pause_sources.clear()
	update_pause_state()

func update_pause_state():
	if pause_sources.size() > 0:
		get_tree().paused = true
		Event.emit_signal("pause")
	else:
		get_tree().paused = false
		Event.emit_signal("unpause")

func is_on_screen(target_global_position) -> bool:
	return abs(camera.get_camera_screen_center().x - target_global_position.x) < 230 and abs(camera.get_camera_screen_center().y - target_global_position.y) < 150

func precise_is_on_screen(target_global_position) -> bool:
	return abs(camera.get_camera_screen_center().x - target_global_position.x) < 200 and abs(camera.get_camera_screen_center().y - target_global_position.y) < 128

func is_on_camera(object: Node) -> bool:
	if camera == null:
		return false
	var max_distance_from_camera_center: = Vector2(196 + 64, 112 + 64)
	return is_pos_nearby(camera.get_camera_screen_center(), object.global_position, max_distance_from_camera_center)

func is_player_nearby(object: Node) -> bool:
	if player == null:
		return false
	
	return is_nearby(player, object, maximum_distance)

func is_bike_nearby(object: Node) -> bool:
	for bike in bikes:
		if object != bike:
			if is_nearby(object, bike, maximum_bike_distance) and bike.has_health():
				Log.msg("Bike detected nearby: " + bike.name)
				return true
	return false

func is_nearby(object1: Node, object2: Node, distance: Vector2) -> bool:
	if not is_instance_valid(object1):
		return false
	elif not is_instance_valid(object2):
		return false
	else:
		if not object1.is_inside_tree() and not object2.is_inside_tree():
			return abs(object1.position.x - object2.position.x) < distance.x and \
			abs(object1.position.y - object2.position.y) < distance.y
		elif not object1.is_inside_tree():
			return abs(object1.position.x - object2.global_position.x) < distance.x and \
			abs(object1.position.y - object2.global_position.y) < distance.y
		elif not object2.is_inside_tree():
			return abs(object1.global_position.x - object2.global.x) < distance.x and \
			abs(object1.global_position.y - object2.global.y) < distance.y

		return abs(object1.global_position.x - object2.global_position.x) < distance.x and \
		abs(object1.global_position.y - object2.global_position.y) < distance.y

func is_pos_nearby(pos1: Vector2, pos2: Vector2, distance: Vector2) -> bool:
	return abs(pos1.x - pos2.x) < distance.x and \
	abs(pos1.y - pos2.y) < distance.y

func save_stage_start_msec():
	stage_start_msec = OS.get_ticks_msec()

func get_stage_start_msec() -> float:
	return stage_start_msec

func change_state(new_state: String) -> void :
	state = new_state

func get_state() -> String:
	return state

func get_next_spawn_item(drop_item_chance = 25, 
							small_health_chance = 30, 
							big_health_chance = 15, 
							small_ammo_chance = 15, 
							big_ammo_chance = 10, 
							extra_life_chance = 0.1):

	var chance = randf() * 100
	if not is_between(chance, 0, drop_item_chance):
		return null
	
	var shc = small_health_chance
	var bhc = shc + big_health_chance
	var sac = bhc + small_ammo_chance
	var bac = sac + big_ammo_chance
	var elc = bac + extra_life_chance
	var c = randf() * elc
	
	if is_between(c, 0, shc):
		return small_heal_spawn
	elif is_between(c, shc, bhc):
		return heal_spawn
	elif is_between(c, bhc, sac):
		return small_ammo_spawn
	elif is_between(c, sac, bac):
		return ammo_spawn
	elif is_between(c, bac, elc):
		return life_spawn

func is_between(c, _min, _max) -> bool:
	return c > _min and c < _max

func start_boss():
	Event.emit_signal("boss_cutscene_start")
	
func emit_stage_start_signal():
	Event.emit_signal("stage_start")
	
func emit_intro_signal():
	player.active = true
	player.visible = true
	Event.emit_signal("intro_x")

func start_end_cutscene() -> void :
	change_state("Cutscene")
	Event.emit_signal("end_cutscene_start")
	
func start_cutscene() -> void :
	change_state("Cutscene")
	Event.emit_signal("cutscene_start")

func end_cutscene() -> void :
	change_state("Normal")
	Event.emit_signal("cutscene_over")
	
func end_boss_death_cutscene() -> void :
	change_state("StageClear")
	clear_checkpoint()
	Event.emit_signal("stage_clear")

func add_bike(object: Node) -> void :
	bikes.append(object)
	
func debug_action_step():
	if debug_skip > 0:
		debug_skip += 1
	if debug_skip == 4:
		debug_skip = 1

func get_player_position() -> Vector2:
	if player:
		if player.is_inside_tree():
			last_player_position = player.global_position
	return last_player_position

func get_player_facing_direction() -> int:
	if player:
		return player.get_facing_direction()
	else:
		return 1

func start_debug_action(action: = "action"):
	if not debug_actions.has(action):
		debug_actions.append(action)

func debug_every_action_in_list():
	debug_action_step()
	for action in debug_actions:
		debug_action_every_other_frame(action)

func debug_action_every_other_frame(default: = "action"):
	if debug_skip == 1:
		Input.action_press(default)
	if debug_skip > 2:
		Input.action_release(default)

func save_seen_dialogue(dialog) -> void :
	if not dialog in seen_dialogues:
		seen_dialogues.append(dialog)

func was_dialogue_seen(dialog) -> bool:
	return dialog in seen_dialogues

func is_armor(collectible_name: String) -> bool:
	return "hermes" in collectible_name or "icarus" in collectible_name

func is_heart(collectible_name: String) -> bool:
	return "life_up" in collectible_name

func is_subtank(collectible_name: String) -> bool:
	return "tank" in collectible_name

func fill_subtanks() -> void :
	print_debug(":: Filling Subtanks...")
	Event.emit_signal("add_to_subtank", 900.0)

var used_cheats: = false

func is_cheating() -> bool:
	if OS.has_feature("editor"):
		return false
	return used_cheats

var weapon_got: = "none"
var current_armor: Array
func prepare_weapon_get(weapon_name: String, equipped_armor: Array) -> void :
	print_debug(":: Preparing Weapon get for: " + weapon_name)
	weapon_got = weapon_name
	current_armor = equipped_armor

func finish_weapon_get() -> void :
	weapon_got = "none"
	current_armor = []

func has_beaten_the_game() -> bool:
	return GlobalVariables.get("seraph_lumine_defeated")

var debug_save_state: Dictionary = {}

func save_debug_state() -> void :
	if not player:
		print_debug("GameManager: Can't save debug state, no player.")
		return
	var shot = player.get_node("Shot")
	var weapon_ammo = {}
	for weapon in shot.weapons:
		weapon_ammo[weapon.name] = weapon.current_ammo
	var riding_scene_path = ""
	var riding_health = 0.0
	if player.ride and is_instance_valid(player.ride):
		riding_scene_path = player.ride.filename
		riding_health = player.ride.current_health
	debug_save_state = {
		"stage": current_level,
		"position": player.global_position,
		"direction": player.get_facing_direction(),
		"velocity": player.velocity,
		"health": player.current_health,
		"max_health": player.max_health,
		"current_weapon_name": shot.current_weapon.name if shot.current_weapon else "",
		"weapon_ammo": weapon_ammo,
		"collectibles": collectibles.duplicate(),
		"global_variables": GlobalVariables.variables.duplicate(true),
		"rng_seed": BossRNG.seed_rng,
		"last_door": checkpoint.last_door if checkpoint else NodePath(),
		"riding_scene_path": riding_scene_path,
		"riding_health": riding_health,
	}
	print("GameManager: Debug save state captured at " + current_level + " " + str(player.global_position) + (" (riding " + riding_scene_path + ")" if riding_scene_path != "" else ""))

func load_debug_state() -> void :
	if debug_save_state.empty():
		print("GameManager: No debug save state to load.")
		return
	var state = debug_save_state
	GlobalVariables.load_variables(state["global_variables"])
	collectibles = state["collectibles"].duplicate()
	BossRNG.set_seed(state["rng_seed"])
	if current_level == state["stage"]:
		restart_level()
	else:
		start_level(state["stage"])
	# start_level() calls clear_checkpoint() internally, so the debug
	# checkpoint must be assigned after triggering the reload/load, not
	# before - otherwise it gets wiped and the player ends up at the
	# stage's default spawn instead of the saved position.
	var debug_checkpoint = CheckpointSettings.new()
	debug_checkpoint.id = - 1
	debug_checkpoint.respawn_position = state["position"]
	debug_checkpoint.character_direction = state["direction"]
	debug_checkpoint.last_door = state["last_door"]
	checkpoint = debug_checkpoint
	Tools.timer_p(0.05, "_finish_loading_debug_state", self, state)

func _finish_loading_debug_state(state) -> void :
	if not player:
		return
	player.max_health = state["max_health"]
	player.current_health = state["health"]
	player.velocity = state["velocity"]
	var shot = player.get_node("Shot")
	for weapon in shot.weapons:
		if state["weapon_ammo"].has(weapon.name):
			weapon.current_ammo = state["weapon_ammo"][weapon.name]
	for weapon in shot.weapons:
		if weapon.name == state["current_weapon_name"]:
			shot.set_current_weapon(weapon)
			break
	if state.get("riding_scene_path", "") != "":
		mount_player_on_ride(state["riding_scene_path"], state["riding_health"])
	print("GameManager: Debug save state loaded.")

func mount_player_on_ride(scene_path: String, ride_health: float) -> void :
	var ride_scene = load(scene_path)
	if not ride_scene:
		print_debug("GameManager: Couldn't load saved ride scene: " + scene_path)
		return
	var ride_instance = ride_scene.instance()
	get_tree().current_scene.add_child(ride_instance, true)
	ride_instance.current_health = ride_health
	var bike_mount = ride_instance.get_node_or_null("Riden")
	if bike_mount:
		# Bike (BikeRiden.gd extends src/Actors/Props/Ride.gd): forcing
		# make_rider() directly hits the exact same race as the Ride Armor
		# case below - the player isn't grounded yet right after a
		# checkpoint/save-state teleport, so their own Fall/Jump ability can
		# evict the freshly-started ride the very next physics frame, and
		# nothing re-enables their collision afterward. Bike.gd's own
		# `Ride.gd` already has a working organic mount trigger
		# (`_on_area2D_body_entered` -> `is_able_to_ride` -> `make_rider`),
		# the same one Debugger.gd's own `_on_spawn_bike_pressed()` debug
		# button relies on (it just spawns the bike at the player's
		# position with no forced mount) - so do the same here instead of
		# forcing it.
		ride_instance.global_position = player.global_position
		print("GameManager: Bike restored (unmounted) at " + str(ride_instance.global_position) + " - walk into it to remount.")
		return
	# Matches Debugger.gd's _on_spawn_ridearm_pressed()/_on_spawn_gridearm_pressed()
	# debug spawn (the -16 y offset there is a proven-working spawn position,
	# not an arbitrary one - mirror it rather than spawning exactly on top
	# of the player).
	var ride_spawn_position = player.global_position
	ride_spawn_position.y -= 16
	ride_instance.global_position = ride_spawn_position
	var armor_mount = ride_instance.get_node_or_null("Ride")
	if armor_mount:
		# Directly forcing Ride Armor's NewAbility-based mount (rider= then
		# _on_signal()) races the player's own Fall/Jump ability: right
		# after a checkpoint/save-state teleport the player hasn't had a
		# physics step to settle onto solid ground yet, so Fall/Jump can
		# win a same-frame priority conflict and evict the freshly-started
		# Ride ability, leaving the player stuck collision-disabled with
		# nothing to re-enable it (organic mounting never hits this since
		# the player is normally already grounded when they walk up to a
		# Ride Armor). Rather than fight that race, just leave the Ride
		# Armor unmounted next to the player and let its own
		# `_on_body_enter` Area2D trigger the mount the normal way, the
		# instant the player is next actually standing on the ground -
		# exactly like walking up to any other Ride Armor.
		print("GameManager: Ride Armor restored (unmounted) at " + str(ride_instance.global_position) + " - walk into it to remount.")
		return
	print_debug("GameManager: Saved ride scene has no Ride/Riden node: " + scene_path)
