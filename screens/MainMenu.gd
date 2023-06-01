extends Node
onready var start_button = $Container/Buttons/Button
onready var exit_button = $Container/Buttons/Button


## HINT: Mouse input won't work by default for any button added because some other
## Control node will consume the mouse input first.
## Check what does the property Control.mouse_filter do in the docs and experiment.

func _on_Button_pressed():
	var new_scene = preload("res://Main.tscn")
	get_tree().change_scene_to(new_scene)

func _on_ExitBtn_pressed():
	get_tree().quit()
