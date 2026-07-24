extends AudioStreamPlayer
class_name MusicPlayer

export var debug_logs: = false
export var stop_song_on_dialogue: = true
export var boss_intro: AudioStream
export var boss_song: AudioStream
export var angry_boss_intro: AudioStream
export var angry_boss_song: AudioStream
export var stage_clear_song: AudioStream
export var capsule_song: AudioStream
export var stage_intro: AudioStream
export var stage_song: AudioStream
export var miniboss_intro: AudioStream
export var miniboss_song: AudioStream
export var play_angry_boss_theme: = true
var fade_in: = false
var fade_out: = false
var slow_fade_out: = false
var volume: = - 6.0

var capsule: = false

var queued_song: AudioStream
var next_song_in: = 0.0


func Log(message) -> void :
	if debug_logs:
		print("Music: " + message)

func _ready() -> void :
	Event.listen("cutscene_start", self, "start_fade_out")
	Event.listen("end_cutscene_start", self, "start_fade_out")
	Event.listen("boss_door_open", self, "start_fade_out")
	Event.listen("capsule_open", self, "capsule_fade_out_and_song")
	Event.listen("capsule_dialogue_end", self, "start_fade_in")
	Event.listen("player_death", self, "start_slow_fade_out")
	Event.listen("play_miniboss_music", self, "play_miniboss_song")
	Event.listen("play_boss_music", self, "play_boss_song")
	Event.listen("play_angry_boss_music", self, "play_angry_boss_song")
	Event.listen("stage_clear", self, "play_stage_clear_song")
	Event.listen("play_stage_song", self, "play_stage_song")
	GameManager.music_player = self
	
	if not stage_song and stream:
		stage_song = stream

func capsule_fade_out_and_song() -> void :
	start_fade_out()
	capsule = true

func start_fade_out():
	Log("Fade Out")
	fade_out = true
	fade_in = false
	capsule = false

func start_fade_in():
	Log("Fade In")
	fade_out = false
	slow_fade_out = false
	fade_in = true
	capsule = false

func start_slow_fade_out():
	Log("Slow Fade Out")
	slow_fade_out = true
	fade_in = false
	capsule = false

func play_stage_song():
	Log("Starting Stage Song")
	volume_db = volume
	queue_loop_if_needed(stage_intro, stage_song)
	fade_out = false
	slow_fade_out = false
	play()
	
func play_stage_song_regardless_of_volume():
	Log("Starting Stage Song wo care for volume")
	queue_loop_if_needed(stage_intro, stage_song)
	fade_out = false
	slow_fade_out = false
	play()

func play_angry_boss_song():
	if play_angry_boss_theme:
		if stream == angry_boss_intro:
			return
		elif stream == angry_boss_song:
			return
		Log("Starting Angry Boss Song")
		queue_loop_if_needed(angry_boss_intro, angry_boss_song)
		fade_out = false
		volume_db = volume
		play()

func play_stage_clear_song():
	Log("Starting Stage Clear Song")
	stream = stage_clear_song
	fade_out = false
	slow_fade_out = false
	volume_db = volume
	play()
	
func play_boss_song():
	Log("Starting Boss Song")
	queue_loop_if_needed(boss_intro, boss_song)
	fade_out = false
	slow_fade_out = false
	volume_db = volume
	play()

func queue_loop_if_needed(intro, loop) -> void :
	if intro:
		stream = intro
		next_song_in = intro.get_length()
		Log("Next song in: " + str(next_song_in))
		queued_song = loop
	else:
		stream = loop
	

func play_song(song: AudioStream, intro = false):
	start_fade_in()
	if intro and stream == intro:
		return
	elif stream == song:
		return
	Log("Starting Song")
	queue_loop_if_needed(intro, song)
	play()

func reset_fade_out():
	Log("Resetting fadeout")
	fade_out = false
	slow_fade_out = false
	volume_db = volume
	

func play_song_wo_fadein(song: AudioStream, intro = false):
	reset_fade_out()
	if intro and stream == intro:
		return
	elif stream == song:
		return
	Log("Starting Song")
	queue_loop_if_needed(intro, song)
	play()

func is_stream(song, intro = false) -> bool:
	return stream == song or stream == intro

func is_playing_boss_song() -> bool:
	return stream == boss_intro or stream == boss_song

func is_playing_miniboss_song() -> bool:
	return stream == miniboss_intro or stream == miniboss_song

func _physics_process(_delta: float) -> void :
	if queued_song and get_playback_position() >= next_song_in:
		stream = queued_song
		play()
		queued_song = null

func _process(_delta: float) -> void :
	if fade_out:
		volume_db = lerp(volume_db, - 80, _delta / 4)
		if capsule == true and volume_db <= - 25:
			play_song(capsule_song)
			Log("Playing Capsule Song")
	elif slow_fade_out:
		volume_db = lerp(volume_db, - 80, _delta / 8)
		
	elif fade_in:
		volume_db = lerp(volume_db, volume, _delta * 4)

func play_miniboss_song():
	Log("Starting Miniboss Song")
	volume_db = volume
	queue_loop_if_needed(miniboss_intro, miniboss_song)
	fade_out = false
	slow_fade_out = false
	play()
