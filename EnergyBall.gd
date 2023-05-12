extends RigidBody2D

export (float) var VELOCITY:float = 600.0

var direction:Vector2
var target:KinematicBody2D
	
func initialize(container, spawn_position:Vector2, target):
	container.add_child(self)
	print(direction)
	global_position = spawn_position	
	self.target = target
	self.direction = global_position.direction_to(target.global_position)
	
func _physics_process(delta):
	position += direction * VELOCITY * delta

