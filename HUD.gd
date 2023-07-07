extends CanvasLayer

onready var show_char_timer = $ShowCharTimer
onready var message = $Message
onready var buttons_container = $ButtonsContainer

var number_of_char = 1
var player_winner;

func initialize(message_text):
	message.text = str(message_text)
	
func _ready():
	buttons_container.hide()
	show_char_timer.start();
	message.visible_characters = 0	

func _on_ShowCharTimer_timeout():
	if (message.percent_visible < 1):
		message.visible_characters += 1;
	else:
		show_char_timer.stop()
		buttons_container.show()
		get_node("ButtonsContainer/Restart").re_focus()

func _on_Restart_pressed():
	var new_scene = load("res://Main.tscn")
	get_tree().change_scene_to(new_scene)
	queue_free()

func _on_Exit_pressed():
	var new_scene = load("res://screens/MainMenu.tscn")
	get_tree().change_scene_to(new_scene)
	queue_free()
