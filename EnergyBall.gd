extends RigidBody2D

export (float) var VELOCITY:float = 800.0

var direction:Vector2

func initialize(container, spawn_position:Vector2, direction:Vector2):
	container.add_child(self)
	self.direction = direction
	global_position = spawn_position

func _physics_process(delta):
	position += direction * VELOCITY * delta
