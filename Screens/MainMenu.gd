extends Node2D

onready var popup_dialog = get_node("Control/PopupDialog")

func _ready():
	popup_dialog.popup_centered(Vector2(620,230))
	
func _on_Button_pressed():
	popup_dialog.queue_free()

func _on_StartButton_pressed():
	get_tree().change_scene("res://Screens/SongSelectionMenu.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()
