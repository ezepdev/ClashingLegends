extends Polygon2D

var imagen
func _ready():
	imagen = texture.get_data()
	imagen.lock()
func _process(delta):
	if Input.is_action_pressed("prueba"):
#		uv = PoolVector2Array([Vector2(0.0 , 0.0) , Vector2(640.0 , 0.0) , Vector2(640.0 , 640.0) , Vector2(0.0 , 640.0)])
		texture = imagen
