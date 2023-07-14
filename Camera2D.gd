extends Camera2D



var player1: Node
var player2: Node
var initial_zoom: float = 1.0
export (float) var min_zoom: float = 1.0
export (Vector2) var zoom_offset: Vector2 = Vector2(100,100)

func _ready():
	player1 = get_parent().get_node("Player1")
	player2 = get_parent().get_node("Player2")
	
func _process(delta: float):
	if player1 and player2:
		var average_position = (player1.global_position + player2.global_position) / 2
		var distance = Vector2(abs(player1.global_position.x - player2.global_position.x) , abs(player1.global_position.y - player2.global_position.y))
		distance += zoom_offset
		global_position = average_position
		var viewport_size : Vector2 = get_viewport_rect().size
		var zm = max(max(distance.x / viewport_size.x, distance.y / viewport_size.y) , min_zoom)
		zm *= 1.1
		set_zoom(Vector2(zm , zm))
		
