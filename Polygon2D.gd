extends Polygon2D

export var radius: float = 100.0
export var num_sides: int = 16

func _ready():
	polygon = generate_circle_polygon(radius, num_sides , position)
	
func generate_circle_polygon(radius: float, num_sides: int, position: Vector2) -> PoolVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PoolVector2Array

	for _i in num_sides:
		polygon.append(vector + position)
		vector = vector.rotated(angle_delta)

	return polygon
