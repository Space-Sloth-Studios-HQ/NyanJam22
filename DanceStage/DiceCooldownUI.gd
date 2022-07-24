extends Line2D

export var bar_width = 200

onready var dice_cooldown_timer = get_node("DiceCooldownTimer")
onready var conductor = get_parent().get_parent()

func _ready():
	conductor.connect("dice_used_changed", self, "_on_dice_rolled")
	points[1].x = bar_width

func _on_dice_rolled(_dice_used):
	points[1].x = 0

func _process(delta):
	if points[1].x <= bar_width:
		points[1].x += delta * (bar_width / dice_cooldown_timer.wait_time)
