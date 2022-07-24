extends Node2D

onready var dance_stage = preload("res://DanceStage/DanceStage.tscn")

func _on_UsseewaDiceButton_pressed():
	var dance_stage_instance = dance_stage.instance()
	dance_stage_instance.set_dice_enabled(true)
	var parent = get_parent()
	parent.add_child(dance_stage_instance)
	parent.remove_child(self)

func _on_UsseewaNoDiceButton_pressed():
	var dance_stage_instance = dance_stage.instance()
	dance_stage_instance.set_dice_enabled(false)
	var parent = get_parent()
	parent.add_child(dance_stage_instance)
	parent.remove_child(self)


func _on_MainMenuButton_pressed():
	get_tree().change_scene("res://Screens/MainMenu.tscn")
