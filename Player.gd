extends KinematicBody2D

class_name Player
onready var arm = $Arm
onready var target
onready var body : Sprite = $Body
onready var body_eye : TextureRect = $Body.get_child(0)
onready var anim_player : AnimationPlayer = $AnimationPlayer


signal health_changed(current_health,id)
signal hit(dmg , knockback)

var loading_color = Color(1, 1, 1)
var target_color = Color(1, 0, 0)
var color_transition_duration = 1.0
var color_transition_timer = 0.0
var knockback_force = Vector2(500, -500)
var knockback_direction = Vector2.RIGHT
var knockback_timer = 0
var knockback_duration = 0.5
var aire_knock = false

var move_direction : int = 0

export (float) var max_health = 500.0
var health_player:float = max_health

const FLOOR_NORMAL := Vector2.UP
const SNAP_DIRECTION := Vector2.UP
const SNAP_LENGHT := 32.0
const SLOPE_THRESHOLD := deg2rad(46)

const KNOCKBACK_FORCE = 500
const KNOCKBACK_FORCE_UP = 500
const KNOCKBACK_DURATION = 1
var isKnockback = false
var knockbackTimer = 0
var isKnockbackRight = false

export (float) var ACCELERATION:float = 100.0
export (float) var H_SPEED_LIMIT:float = 400.0
export (int) var jump_speed = 2000
export (float) var FRICTION_WEIGHT:float = 0.1
export (int) var gravity = 50

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
var snap_vector:Vector2 

export (PackedScene) var projectile_scene:PackedScene
var proj_instance

var original_color = Color(1,1,1)

func _ready():
	health_player = max_health
	original_color = body.modulate
	snap_vector = SNAP_DIRECTION * SNAP_LENGHT

func initialize(projectile_container , id):
	self.projectile_container = projectile_container
	$Arm.hide();
	self.id = id
	if (id == 1):
		target = get_parent().get_node("Player2")
	else:
		target = get_parent().get_node("Player1")

func handle_movement():
	move_direction = int(Input.is_action_pressed("move_right" + str(id) )) - int(Input.is_action_pressed("move_left" + str(id)))
	if move_direction != 0:
		velocity.x = velocity.x + (move_direction * ACCELERATION)
	if move_direction < 0:
		body.flip_h = true
	elif move_direction > 0:
		body.flip_h = false
		
func apply_speed_limit():
	if is_on_floor():
		velocity.x = clamp(velocity.x, -1200, 1200)
	else:
		velocity.x = clamp(velocity.x, -3000, 3000)
		
func _handle_deacceleration():
		velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0

func _apply_movement():
	velocity.y += gravity
	velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, true, 4, SLOPE_THRESHOLD)
	
func get_health():
	return (health_player / max_health) * 100
	
func fire():
	if projectile_scene != null:
		var proj_instance = projectile_scene.instance()
		proj_instance.initialize(projectile_container, arm.get_node("ArmTip").global_position, target)

#NEW

func handle_fire():
	if Input.is_action_just_pressed("fire_cannon" + str(id)):
		fire()

func handle_hit():
	if Input.is_action_just_pressed("hit_enemy" + str(id)):
		arm.visible = true;
		hit()
	if Input.is_action_just_released("hit_enemy" + str(id)):
		arm.visible = false;

func handle_charge_jump(delta):
	var jump: bool = Input.is_action_just_pressed('jump' + str(id))
	var on_floor: bool = is_on_floor()
	
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

func handle_jump():
	
	var on_floor: bool = is_on_floor()

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
				
#	if !is_on_floor():
#		if aire_knock:
#			velocity.x = clamp(velocity.x + (move_direction * ACCELERATION), -H_SPEED_LIMIT, H_SPEED_LIMIT)
#		else:
#			velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0
#			velocity.x = clamp(velocity.x + (move_direction * ACCELERATION), -1000, 1000)
	
func get_input(delta):
	if move_direction != 0:
		if is_on_floor():
			aire_knock = false
			velocity.x = clamp(velocity.x + (move_direction * 30), -1000, 1000)
		if Input.is_action_just_pressed("move_right" + str(id)):
			body.flip_h = false
			anim_player.play("move")
			arm.position.x = 0
			arm.scale.x = 1
			body_eye.rect_scale.x = 0.05
			dash_count += 1
			if dash_count < MAX_DASH_COUNT:
				dash_timer = 0
			elif dash_timer <= DASH_TIME_THRESHOLD:
				dash_count = 0
				dash_timer = 0
				dash(500)
			else:
				dash_timer = 0
		if Input.is_action_just_pressed("move_left" + str(id)):
			body.flip_h = true
			anim_player.play("move")
			arm.position.x = 0
			arm.scale.x = -1
			body_eye.rect_scale.x = -0.05
			
			dashL_count += 1
			if dashL_count < MAX_DASH_COUNT:
				dashL_timer = 0
			elif dashL_timer <= DASH_TIME_THRESHOLD:
				dashL_count = 0
				dashL_timer = 0
				dash(-500)
			else:
				dashL_timer = 0

func dash(valor):
	anim_player.play("dash")
	global_position.x += valor

func _physics_process(delta):
	dash_timer += delta
	dashL_timer += delta
	

func hit():
	var col = get_node("Arm/RayCast2D").get_collider()
	if get_node("Arm/RayCast2D").is_colliding():
		if global_position < col.global_position:
			col.notify_hit("right")
		else:
			col.notify_hit("left")
	
func notify_hit(dmg , knockback) -> void:
	emit_signal("hit" , dmg , knockback)
	
func _handle_hit(dmg :int):
	health_player = health_player - 100
	emit_signal("health_changed",(health_player / max_health) * 100,id)
	if (health_player == 0):
		var main_scene = load("res://screens/MainMenu.tscn")
		get_tree().change_scene_to(main_scene) 
		queue_free()
#	if(empuje == "left"):
#		isKnockback = true
#		isKnockbackRight = false
#		aire_knock = true
#	elif(empuje == "right"):
#		isKnockback = true
#		isKnockbackRight = true
#		aire_knock = true

func _play_animation(animation_name:String, should_restart:bool = true, playback_speed:float = 1.0):
	if anim_player.has_animation(animation_name):
		if should_restart:
			anim_player.stop()
		anim_player.playback_speed = playback_speed
		anim_player.play(animation_name)
