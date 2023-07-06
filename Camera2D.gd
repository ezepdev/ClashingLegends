extends Camera2D



var player1: Node
var player2: Node
var initial_zoom: float = 1.0
export (float) var min_zoom: float = 1.0
export (float) var max_zoom: float = 5.0

func _ready():
	player1 = get_parent().get_node("Player1")
	player2 = get_parent().get_node("Player2")
	
func _process(delta: float):
	if player1 and player2:
		var average_position = (player1.global_position + player2.global_position) / 2
		var distance = player1.global_position.distance_to(player2.global_position)
		global_position = average_position

		set_zoom(Vector2((clamp(distance / 800 , min_zoom , max_zoom)) , (clamp(distance / 800 , min_zoom , max_zoom))))
