extends Node2D
class_name JudgementArea

onready var earlyArea2D = get_node("EarlyArea2D")
onready var greatArea2D = get_node("GreatArea2D")
onready var perfectArea2D = get_node("PerfectArea2D")
onready var lateArea2D = get_node("LateArea2D")

func get_early_area():
	return earlyArea2D

func get_great_area():
	return greatArea2D
	
func get_perfect_area():
	return perfectArea2D

func get_late_area():
	return lateArea2D
