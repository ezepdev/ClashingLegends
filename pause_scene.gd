extends HBoxContainer

func _ready():
	visible = false;

func _process(delta):
	if (GuiKeyBinding.visible && Input.is_action_just_pressed("pause")):
		GuiKeyBinding.visible = false
		visible = true
		get_node("ContinueBtn").re_focus()

func _on_ContinueBtn_pressed():
	visible = false;
	get_tree().set_pause(false)	

func _on_ExitBtn_pressed():
	get_tree().set_pause(false)
	var new_scene = load("res://screens/MainMenu.tscn")
	get_tree().change_scene_to(new_scene)
	queue_free()


func _on_Controls_pressed():
	visible = false
	GuiKeyBinding.visible = true
