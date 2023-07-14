extends RigidBody2D

export (float) var VELOCITY:float = 5000.0

var direction:Vector2
var target:KinematicBody2D
var sprite1 = "res://assets/dbz/energy-pic.png"
var sprite2 = "res://assets/dbz/energy-veg.png"
var texture : Texture
var audio_player

func initialize(container, spawn_position:Vector2, target):
	global_position = spawn_position
	container.add_child(self)
	audio_player = get_parent().get_node("Explosion")
	if(target.id == 1):
		texture = ResourceLoader.load(sprite1)
		$Sprite.texture = texture
		collision_mask |= 4
		collision_mask |= 8
	else:
		texture = ResourceLoader.load(sprite2)
		$Sprite.texture = texture
		collision_mask = 2
		collision_mask |= 8
	self.target = target
	self.direction = global_position.direction_to(target.global_position)
	rotation = direction.angle()
	
func _physics_process(delta):
	position += direction * VELOCITY * delta

func _on_EnergyBall_body_entered(body:Object):
	audio_player.play()
	if body is KinematicBody2D:
		body.notify_hit(35 , global_position.direction_to(body.global_position), 2000)
	elif body in get_tree().get_nodes_in_group("Destructible"):
		var final_position = Transform2D(0, $Polygon2D.global_position).xform($Polygon2D.polygon)
		body.carve(final_position)	
	queue_free()
