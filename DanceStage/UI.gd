extends Control

onready var conductor = get_parent()
onready var score_label = get_node("ScoreLabel")
onready var hits_label = get_node("HitsLabel")
onready var miss_label = get_node("MissLabel")
onready var dice_label = get_node("DiceUsedLabel")
onready var hit_streak_label = get_node("HitStreakLabel")

func _ready():
	conductor.connect("score_changed", self, "_on_score_changed")
	conductor.connect("dice_used_changed", self, "_on_dice_used_changed")
	conductor.connect("missed_changed", self, "_on_missed_changed")
	conductor.connect("hit_changed", self, "_on_hit_changed")
	conductor.connect("hit_streak_changed", self, "_on_hit_streak_changed")
	
func _on_score_changed(score):
	score_label.text = "Score: " + str(score)

func _on_hit_changed(hits):
	hits_label.text = "Hits: " + str(hits)
	
func _on_missed_changed(miss):
	miss_label.text = "Missed: " + str(miss)
	
func _on_dice_used_changed(dice_used):
	dice_label.text = "Dice Used: " + str(dice_used)

func _on_hit_streak_changed(hit_streak):
	hit_streak_label.text = "X" + str(hit_streak)
