extends KinematicBody2D

onready var arm = $Arm

const FLOOR_NORMAL := Vector2.UP  # Igual a Vector2(0, -1)
const SNAP_DIRECTION := Vector2.UP
const SNAP_LENGHT := 32.0
const SLOPE_THRESHOLD := deg2rad(46)

export (float) var ACCELERATION:float = 30.0
export (float) var H_SPEED_LIMIT:float = 400.0
export (int) var jump_speed = 300
export (float) var FRICTION_WEIGHT:float = 0.1
export (int) var gravity = 10

const JUMP_CHARGE_FORCE = 500
const JUMP_CHARGE_TIME = 0.3
var jump_pressed_time = 0
var jump_force_charged = 0
var double_jump = false
var jump_count = 1
var was_on_floor = false

var dash_count = 0
var dash_timer = 0
var dashL_count = 0
var dashL_timer = 0
const MAX_DASH_COUNT = 2
const DASH_TIME_THRESHOLD = 0.2

var projectile_container
var id

var velocity:Vector2 = Vector2.ZERO
var snap_vector:Vector2 = SNAP_DIRECTION * SNAP_LENGHT

export (PackedScene) var projectile_scene:PackedScene
var proj_instance

func initialize(projectile_container , id):
	self.projectile_container = projectile_container
	self.id = id
	#arm.projectile_container = projectile_container

	
func fire():
	if projectile_scene != null:
		var proj_instance = projectile_scene.instance()
		proj_instance.initialize(projectile_container, arm.get_node("ArmTip").global_position, Vector2.RIGHT)
	else:
		print("AAAAAAAAAAAAAA")#fire_timer.start()
	
func get_input(delta):
	# Cannon fire
	if Input.is_action_just_pressed("fire_cannon" + str(id)):
#		if projectile_container == null:
#			projectile_container = get_parent()
#			arm.projectile_container = projectile_container
		fire()
		
	# Jump Action
	var jump: bool = Input.is_action_just_pressed('jump' + str(id))
	var on_floor: bool = is_on_floor()
	if on_floor and not was_on_floor:
		jump_count = 1
		
	if jump:
		jump_pressed_time = 0
		jump_force_charged = 0
	
	if Input.is_action_pressed("jump" + str(id)):
		jump_pressed_time += delta
		if jump_pressed_time >= JUMP_CHARGE_TIME && on_floor:
			jump_force_charged = JUMP_CHARGE_FORCE
			jump_count=2
			
		elif jump_pressed_time < JUMP_CHARGE_TIME && jump_pressed_time > 0.1:
			jump_force_charged = JUMP_CHARGE_FORCE / 2

	if Input.is_action_just_released("jump" + str(id)) && jump_count > 0:
				if !on_floor && jump_count == 1 && velocity.y > 0:
					velocity.y = 0
					jump_force_charged = JUMP_CHARGE_FORCE / 2
				if !on_floor && jump_count == 1 && velocity.y < 0 && velocity.y >= -200:
					print("poderoso")
					velocity.y = 0
					jump_force_charged = JUMP_CHARGE_FORCE + 400
				if !on_floor && jump_count == 1 && velocity.y < 0 && velocity.y < -200:
					print("no tanto")
					velocity.y = 0
					jump_force_charged = JUMP_CHARGE_FORCE
				velocity.y -= jump_speed + jump_force_charged
				jump_count -= 1
	


	#horizontal speed
	var h_movement_direction:int = int(Input.is_action_pressed("move_right" + str(id) )) - int(Input.is_action_pressed("move_left" + str(id)))
	if h_movement_direction != 0:
		velocity.x = clamp(velocity.x + (h_movement_direction * ACCELERATION), -H_SPEED_LIMIT, H_SPEED_LIMIT)
		if Input.is_action_just_pressed("move_right" + str(id)):
			dash_count += 1
			if dash_count < MAX_DASH_COUNT:
				dash_timer = 0
			elif dash_timer <= DASH_TIME_THRESHOLD:
				dash_count = 0
				dash_timer = 0
				dash(100)
			else:
				dash_timer = 0
		if Input.is_action_just_pressed("move_left" + str(id)):
			dashL_count += 1
			if dashL_count < MAX_DASH_COUNT:
				dashL_timer = 0
			elif dashL_timer <= DASH_TIME_THRESHOLD:
				dashL_count = 0
				dashL_timer = 0
				dash(-100)
			else:
				dashL_timer = 0
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0
		
	var mouse_position:Vector2 = get_global_mouse_position()
	arm.look_at(mouse_position)

func dash(valor):
	global_position.x += valor

func _physics_process(delta):
	dash_timer += delta
	dashL_timer += delta
	get_input(delta)
	was_on_floor = is_on_floor()
	
	
	
	# Apply velocity
	var snap:Vector2
	
	velocity.y += gravity

	#velocity = move_and_slide(velocity, FLOOR_NORMAL) # Sin stop on slope
#	velocity = move_and_slide(velocity, FLOOR_NORMAL, true) # Con stop on slope
#	velocity.y = move_and_slide(velocity, FLOOR_NORMAL, true).y # Con stop on slope y cancelando corrección de momentum horizontal
#	velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, true) # Usando move_and_slide_with_snap y sin threshold de slope
	velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, true, 4, SLOPE_THRESHOLD) # Usando move_and_slide_with_snap y con threshold de slope
