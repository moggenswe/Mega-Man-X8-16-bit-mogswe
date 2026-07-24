extends AttackAbility

var side_hit: = 0
onready var damage: Node2D = $"../Damage"
onready var boss_ai: Node2D = $"../BossAI"

export var stop_at_land: = false

func _ready() -> void :
	var _s = damage.connect("charged_weakness_hit", self, "start_stun")

func start_stun(hit_direction: int) -> void :
	if active and character.has_health():
		side_hit = hit_direction
		character.interrupt_all_moves()
		ExecuteOnce()

func _Setup() -> void :
	force_movement_toward_direction(horizontal_velocity, side_hit)
	set_vertical_speed( - jump_velocity)

func _Update(delta) -> void :
	process_gravity(delta)

func _EndCondition() -> bool:
	return timer > 0.05 and character.is_on_floor()

func _Interrupt() -> void :
	play_animation("idle")
	if stop_at_land:
		force_movement(0)

func reactivate(_s = null) -> void :
	Log("Reactivating Stun")
	activate()

