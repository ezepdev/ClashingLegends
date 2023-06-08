extends RigidBody2D

export (float) var VELOCITY:float = 5000.0

var direction:Vector2
var target:KinematicBody2D
	
func initialize(container, spawn_position:Vector2, target):
	global_position = spawn_position
	container.add_child(self)
	if(target.id == 1):
		collision_mask |= 4
		collision_mask |= 8
	else:
		collision_mask = 2
		collision_mask |= 8
	self.target = target
	self.direction = global_position.direction_to(target.global_position)
	
func _physics_process(delta):
	position += direction * VELOCITY * delta

func _on_EnergyBall_body_entered(body:Object):
	if (body is KinematicBody2D):
		if(body.global_position < global_position):	
			body.notify_hit("left")
		else:
			body.notify_hit("right")
	if body in get_tree().get_nodes_in_group("Destructible"):
		var final_position = Transform2D(0, $Polygon2D.global_position).xform($Polygon2D.polygon)
		body.carve(final_position)
		
	queue_free()
