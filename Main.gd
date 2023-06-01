extends Node

onready var player1 = $Player1
onready var player2 = $Player2

func _ready():
	randomize()
	player1.initialize(self , 1)
	player2.initialize(self , 2)
