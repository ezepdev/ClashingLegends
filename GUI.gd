extends Control

onready var lifebar_player1 = $LifeBarPlayer1
onready var lifebar_player2 = $LifeBarPlayer2
onready var tween = $Tween
onready var player1: Player
onready var player2: Player

var animated_health_player1: float
var animated_health_player2: float

func _ready():
	player1 = get_parent().get_parent().get_node("Player1")
	player2 = get_parent().get_parent().get_node("Player2")
	
	animated_health_player1 = player1.get_health()
	animated_health_player2 = player2.get_health()
	
	player1.connect("health_changed",self,"_on_Player_health_changed")
	player2.connect("health_changed",self,"_on_Player_health_changed")

func _process(delta):
	lifebar_player1.value = animated_health_player1
	lifebar_player2.value = animated_health_player2

func _on_Player_health_changed(current_health:float,id:int):
	print("GUI receive player damage signal from player: " + str(id) )
	update_health(current_health, id)

func update_health(new_value,id):
	if (id == 1):
		tween.interpolate_property(self, "animated_health_player1", animated_health_player1, new_value, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	else:
		tween.interpolate_property(self, "animated_health_player2", animated_health_player2, new_value, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)		
	if not tween.is_active():
		tween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
