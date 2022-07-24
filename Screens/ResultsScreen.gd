extends Node2D
class_name ResultsScreen

var missedCount = 123
var perfectCount = 123
var greatCount = 123
var lateCount = 123
var earlyCount = 123
var score = 50000
var song = "Ado - Usseewa"
var rank = ""
var failed = false

onready var missedCountLabel = $Control/MissedCount
onready var perfectCountLabel = $Control/PerfectCount
onready var greatCountLabel = $Control/GreatCount
onready var earlyCountLabel = $Control/EarlyCount
onready var lateCountLabel = $Control/LateCount
onready var scoreLabel = $Control/Score
onready var rankLabel = $Control/Rank
onready var accuracyLabel = $Control/Accuracy
onready var songLabel = $Control/Song

func _ready():
	set_counts(123, 1233, 123, 123, 123, 123, false)

func set_counts(missedCount, perfectCount, greatCount, lateCount, earlyCount, score, failed):
	self.missedCount = missedCount
	self.perfectCount = perfectCount
	self.greatCount = greatCount
	self.lateCount = lateCount
	self.earlyCount = earlyCount
	self.score = score
	
	var total = missedCount + perfectCount + greatCount + lateCount + earlyCount
	var accuracy: float = (float(perfectCount + greatCount + lateCount + earlyCount) / total) * 100.0
	
	missedCountLabel.text = "Missed: " + str(self.missedCount)
	perfectCountLabel.text = "Perfect: " + str(self.perfectCount)
	greatCountLabel.text = "Great: " + str(self.greatCount)
	lateCountLabel.text = "Late: " + str(self.lateCount)
	earlyCountLabel.text = "Early: " + str(self.earlyCount)
	accuracyLabel.text = "Accuracy: " + str(accuracy) + "%"
	scoreLabel.text = "Score: " + str(self.score)
	songLabel.text = song
	if failed:
		rankLabel.text = "Rank: F"
	else:
		if accuracy >= 100:
			rankLabel.text = "Rank: SS"
		elif accuracy >= 95:
			rankLabel.text = "Rank: S"
		elif accuracy >= 90:
			rankLabel.text = "Rank: A"
		elif accuracy >= 80:
			rankLabel.text = "Rank: B"
		elif accuracy >= 70:
			rankLabel.text = "Rank: C"
		else:
			rankLabel.text = "Rank: D"


func _on_MainMenuButton_pressed():
	get_tree().change_scene("res://Screens/MainMenu.tscn")


func _on_SongSelectionButton_pressed():
	get_tree().change_scene("res://Screens/SongSelectionMenu.tscn")
