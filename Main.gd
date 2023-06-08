extends Node

onready var player1 = $Player1
onready var player2 = $Player2
onready var menu_pause = $UI/Menu/pause_scene

func _ready():
	randomize()
	player1.initialize(self , 1)
	player2.initialize(self , 2)
	
func _process(delta):
	if (Input.is_action_just_pressed("pause")):
		get_tree().set_pause(true);
		menu_pause.visible = true;


	
	
