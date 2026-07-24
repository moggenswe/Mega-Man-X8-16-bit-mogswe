extends NinePatchRect
onready var bike_bar: NinePatchRect = $"../Ride Bar"
onready var armor_bar: NinePatchRect = $"../RideArmor Bar"
onready var tween: = TweenController.new(self, false)

var fading_out: = false
var fading_in: = false

func _ready() -> void :
	Event.connect("player_death", self, "disable")

func disable():
	set_physics_process(false)

func fade_out():
	if not fading_out:
		fading_out = true
		fading_in = false
		tween.reset()
		tween.attribute("modulate:a", 0.1, 0.1)
		tween.attribute("modulate:a", 0.1, 0.1, bike_bar)
		tween.attribute("modulate:a", 0.1, 0.1, armor_bar)
	
func fade_in():
	if not fading_in:
		fading_in = true
		fading_out = false
		tween.reset()
		tween.attribute("modulate:a", 1.0, 0.6)
		tween.attribute("modulate:a", 1.0, 0.6, bike_bar)
		tween.attribute("modulate:a", 1.0, 0.6, armor_bar)

func _physics_process(_delta: float) -> void :
	if player_is_near_lifebar():
		fade_out()
	else:
		fade_in()

func player_is_near_lifebar() -> bool:
	var screencenter = GameManager.camera.get_camera_screen_center()
	return GameManager.get_player_position().x < screencenter.x - 199 + 36 and \
	GameManager.get_player_position().y < screencenter.y + 10
