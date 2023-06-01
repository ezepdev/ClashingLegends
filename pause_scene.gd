extends HBoxContainer

func _ready():
	visible = false;

func _on_ContinueBtn_pressed():
	visible = false;
	get_tree().set_pause(false)	


func _on_ExitBtn_pressed():
	pass # Replace with function body.
