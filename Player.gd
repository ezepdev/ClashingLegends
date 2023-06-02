extends KinematicBody2D

class_name Player
onready var arm = $Arm
onready var target
onready var body : Sprite = $Body

signal health_changed(current_health,id)

var loading_color = Color(1, 1, 1)
var target_color = Color(1, 0, 0)
var color_transition_duration = 1.0
var color_transition_timer = 0.0

var knockback_force = Vector2(500, -500)
var knockback_direction = Vector2.RIGHT
var knockback_timer = 0
var knockback_duration = 0.5

# health player
export (float) var max_health = 500.0
var health_player:float = max_health

const FLOOR_NORMAL := Vector2.UP  # Igual a Vector2(0, -1)
const SNAP_DIRECTION := Vector2.UP
const SNAP_LENGHT := 32.0
const SLOPE_THRESHOLD := deg2rad(46)

const KNOCKBACK_FORCE = 500
const KNOCKBACK_FORCE_UP = 500
const KNOCKBACK_DURATION = 1
var isKnockback = false
var knockbackTimer = 0
var isKnockbackRight = false

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

var original_color = Color(1,1,1)

func _ready():
	health_player = max_health
	original_color = body.modulate

func initialize(projectile_container , id):
	self.projectile_container = projectile_container
	self.id = id
	if (id == 1):
		target = get_parent().get_node("Player2")
	else:
		target = get_parent().get_node("Player1")
	#arm.projectile_container = projectile_container


func get_health():
	return (health_player / max_health) * 100

	
func fire():
	if projectile_scene != null:
		var proj_instance = projectile_scene.instance()
		proj_instance.initialize(projectile_container, arm.get_node("ArmTip").global_position, target)
	
func get_input(delta):
	# Cannon fire
	if Input.is_action_just_pressed("fire_cannon" + str(id)):
#		if projectile_container == null:
#			projectile_container = get_parent()
#			arm.projectile_container = projectile_container
		fire()
	
	if Input.is_action_just_pressed("hit_enemy" + str(id)):
#		if projectile_container == null:
#			projectile_container = get_parent()
#			arm.projectile_container = projectile_container
		hit()
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
		if on_floor:
			var t = jump_pressed_time / JUMP_CHARGE_TIME
			var current_color = loading_color.linear_interpolate(target_color, t)
			body.modulate = current_color
		if jump_pressed_time >= JUMP_CHARGE_TIME && on_floor:
			jump_force_charged = JUMP_CHARGE_FORCE
			jump_count=2
			
		elif jump_pressed_time < JUMP_CHARGE_TIME && jump_pressed_time > 0.1:
			jump_force_charged = JUMP_CHARGE_FORCE / 2

	if Input.is_action_just_released("jump" + str(id)) && jump_count > 0:
				color_transition_timer = 0
				body.modulate = loading_color
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
			arm.position.x = 0
			arm.scale.x = 1
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
			arm.position.x = 0
			arm.scale.x = -1
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

func dash(valor):
	global_position.x += valor

func _physics_process(delta):
	if isKnockback:
		knockbackTimer += delta
		if knockbackTimer >= KNOCKBACK_DURATION:
			isKnockback = false
			isKnockbackRight = false
			knockbackTimer = 0
		else:
			if isKnockbackRight:
				velocity.x = KNOCKBACK_FORCE
				velocity.x *= (1 - knockbackTimer / KNOCKBACK_DURATION)  # Frenado progresivo
				velocity.y = -KNOCKBACK_FORCE_UP
				velocity.y *= (1 - knockbackTimer / KNOCKBACK_DURATION)  # Frenado progresivo
				velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, true, 4, SLOPE_THRESHOLD)

			else: 
				velocity.x = -KNOCKBACK_FORCE
				velocity.x *= (1 - knockbackTimer / KNOCKBACK_DURATION)  # Frenado progresivo
				velocity.y = -KNOCKBACK_FORCE_UP
				velocity.y *= (1 - knockbackTimer / KNOCKBACK_DURATION)  # Frenado progresivo
				velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, true, 4, SLOPE_THRESHOLD)
	dash_timer += delta
	dashL_timer += delta
	get_input(delta)
	was_on_floor = is_on_floor()
	
	var snap:Vector2
	
	velocity.y += gravity

	velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, true, 4, SLOPE_THRESHOLD) # Usando move_and_slide_with_snap y con threshold de slope

func hit():
	var col = get_node("Arm/RayCast2D").get_collider()
	if get_node("Arm/RayCast2D").is_colliding():
		if global_position < col.global_position:
			col.notify_hit("right")
		else:
			col.notify_hit("left")
	
func notify_hit(empuje) -> void:
	health_player = health_player - 100
	emit_signal("health_changed",(health_player / max_health) * 100,id)
	if (health_player == 0):
		var main_scene = load("res://screens/MainMenu.tscn")
		get_tree().change_scene_to(main_scene) 
		queue_free()
	if(empuje == "left"):
		isKnockback = true
		isKnockbackRight = false
	elif(empuje == "right"):
		isKnockback = true
		isKnockbackRight = true
