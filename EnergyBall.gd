extends RigidBody2D

export (float) var VELOCITY:float = 5000.0

var direction:Vector2
var target:KinematicBody2D
	
func initialize(container, spawn_position:Vector2, target):
	container.add_child(self)
	print(direction)
	if(target.id == 1):
		collision_mask = 4
	else:
		collision_mask = 2
	global_position = spawn_position
	self.target = target
	self.direction = global_position.direction_to(target.global_position)
	
func _physics_process(delta):
	position += direction * VELOCITY * delta

func _on_EnergyBall_body_entered(body:Object):
	print(body)
	if (body is KinematicBody2D):
		if(body.global_position < global_position):	
			body.notify_hit("left")
		else:
			body.notify_hit("right")
		
	queue_free()
