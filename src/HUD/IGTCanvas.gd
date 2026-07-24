extends CanvasLayer





onready var total_time_label = $IGTRect / IGTLabelContainer / TotalTime
onready var stage_time_label = $IGTRect / IGTLabelContainer / node2D / StageTime


func _ready():
	Configurations.connect("value_changed", self, "_on_igt_value_changed")
	if Configurations.get("IGTDisplay"):
		visible = true
	else:
		visible = false


func _on_igt_value_changed(key):
	if key == "IGTDisplay":
		visible = Configurations.get("IGTDisplay")

func _physics_process(delta):
	total_time_label.text = Tools.get_full_readable_time(IGT.total_time)
	if IGT.times.has(IGT.current_section):
		stage_time_label.text = Tools.get_full_readable_time(IGT.times[IGT.current_section])
