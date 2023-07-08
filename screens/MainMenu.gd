extends Node
onready var start_button = $Container/Buttons/StartBtn
onready var exit_button = $Container/Buttons/ExitBtn


func _on_Button_pressed():
	var new_scene = preload("res://GameMechanicsScreen/GameMechanicsScreen.tscn")
	get_tree().change_scene_to(new_scene)

func _on_ExitBtn_pressed():
	get_tree().quit()
