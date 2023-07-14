extends Node
onready var start_button = $Container/Buttons/StartBtn
onready var exit_button = $Container/Buttons/ExitBtn



func _ready():
	GuiKeyBinding.connect("visibility_changed",self,"_on_KeybindingVisibility_changed")

func _on_KeybindingVisibility_changed():
	
			if (GuiKeyBinding.visible):
				start_button.focus_mode = Control.FOCUS_NONE
				exit_button.focus_mode = Control.FOCUS_NONE
				
			else:
				start_button.focus_mode = Control.FOCUS_ALL
				exit_button.focus_mode = Control.FOCUS_ALL				
				

func _on_Button_pressed():
	var new_scene = preload("res://Main.tscn")
	get_tree().change_scene_to(new_scene)

func _on_ExitBtn_pressed():
	get_tree().quit()

func _on_SettingsBtn_pressed():
	get_tree().paused = true
	GuiKeyBinding.visible = true
