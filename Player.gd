extends KinematicBody2D

class_name Player
onready var arm = $Arm
onready var target
onready var body : Sprite = $Body
onready var body_eye : TextureRect = $Body.get_child(0)
onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var dash_timer : Timer = $DashTimer
onready var countdown_timer = $CountdownTimer
onready var dash_police = $DashPolice
onready var audio_player = $PlayerAudio
onready var audio_voice = $PlayerVoice
onready var audio_explosion = get_parent().get_node("Explosion")
onready var destructibles = get_tree().get_nodes_in_group("Destructible")
onready var destruction_polygon = get_node("DestructionArea/Polygon2D")
onready var destruction_area = get_node("DestructionArea")

# signals
signal health_changed(current_health,id)
signal hit(dmg , knockback , power)
signal mana_changed(current_mana,id)
signal player_die(id)
# state/life
export (float) var max_health = 500.0
var health_player:float = max_health
export (float) var max_mana = 500.0
export (float) var energy_power_penalty = 100.0
var mana_player:float = max_mana

# knockback
var knockback_force = Vector2(500, -500)
var knockback_direction = Vector2.RIGHT
var knockback_timer = 0
var knockback_duration = 0.5
var aire_knock = false

const KNOCKBACK_FORCE = 500
const KNOCKBACK_FORCE_UP = 500
const KNOCKBACK_DURATION = 1
var isKnockback = false
var knockbackTimer = 0
var isKnockbackRight = false

# movement
var move_direction : int = 0
const FLOOR_NORMAL := Vector2.UP
const SNAP_DIRECTION := Vector2.UP
const SNAP_LENGHT := 32.0
const SLOPE_THRESHOLD := deg2rad(46)

# physics
export (int) var GRAVITY = 50
export (float) var ACCELERATION:float = 100.0
export (float) var H_SPEED_LIMIT:float = 400.0
export (float) var FRICTION_WEIGHT:float = 0.1
# physics/jump
export (int) var JUMP_SPEED = 2000
const JUMP_CHARGE_FORCE = 2000
const JUMP_CHARGE_TIME = 0.3

# charged jump
var jump_pressed_time = 0
var jump_force_charged = 0
var double_jump = false
var jump_count = 1
var was_on_floor = false

# charged jump/transition color
var fire_available = true
var original_color = Color(1,1,1)
var loading_color = Color(1, 1, 1)
var target_color = Color(1, 0, 0)
var charge_mana_color = Color(0, 0.7, 1.0)
var color_transition_duration = 1.0
var color_transition_timer = 0.0

# dash
var is_action_repeat = false
var count_is_action_repeated = 0
var can_dash;
const MAX_DASH_COUNT = 2
const DASH_TIME_THRESHOLD = 0.2

var last_action_name
var projectile_container
var id

var velocity:Vector2 = Vector2.ZERO
var snap_vector:Vector2 

export (PackedScene) var projectile_scene:PackedScene
var proj_instance

var isAudioPlaying = false

var hit_force = 0

func _ready():
	health_player = max_health
	mana_player = max_mana
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

func handle_energy_charge():
		# Energy charge 
	if Input.is_action_pressed("charge_mana" + str(id)) && is_on_floor():
		if (mana_player < max_mana):
			mana_player += 2
			emit_signal("mana_changed",get_mana(),id)
	
	if Input.is_action_just_released("charge_mana" + str(id)):
		_play_animation("idle")

		
func handle_movement():
	move_direction = int(Input.is_action_pressed("move_right" + str(id) )) - int(Input.is_action_pressed("move_left" + str(id)))	
	if move_direction != 0:
		velocity.x = velocity.x + (move_direction * ACCELERATION)
	if move_direction < 0:
		body.flip_h = true
		dash_police.scale.y = -1
		$Arm/ArmTip.position.x = -100
		$Enemy_Detection_Area.scale.x = -1
		hit_force = -velocity.x
	elif move_direction > 0:
		dash_police.scale.y = 1
		body.flip_h = false
		$Arm/ArmTip.position.x = 100
		$Enemy_Detection_Area.scale.x = 1
		hit_force = velocity.x
	if Input.is_action_just_pressed("move_right" + str(id)):
		last_action_name = "move_right" + str(id)
		can_dash = true
		dash_timer.start()
	if Input.is_action_just_pressed("move_left" + str(id)):
		last_action_name = "move_left" + str(id)
		can_dash = true
		dash_timer.start()

func handle_dash():
		is_action_repeat = last_action_name == get_current_action_name()
		count_is_action_repeated;
		if is_action_repeat: 
			count_is_action_repeated += 1
		if !is_action_repeat || count_is_action_repeated > 1:
			count_is_action_repeated = 0
			return false
		if is_action_repeat && can_dash && count_is_action_repeated == 1 && !dash_police.is_colliding() && mana_player - 100 > 0:
			return true

func handle_dash_joystick():
	if !dash_police.is_colliding() && mana_player - 100 > 0:
		return true
	else:
		return false
	

func apply_speed_limit():
	if is_on_floor():
		velocity.x = clamp(velocity.x, -2000, 2000)
	else:
		velocity.x = clamp(velocity.x, -3000, 3000)
		
func _handle_deacceleration():
		velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0

func calculate_destruction(body , destruction_polygon):
	var final_position = Transform2D(0, get_node("DestructionArea/Polygon2D").global_position).xform(get_node("DestructionArea/Polygon2D").polygon)
	body.carve(final_position)
	audio_explosion.play()

func _apply_movement():
	velocity.y += GRAVITY
	velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, true, 4, SLOPE_THRESHOLD)
	if abs(velocity.x) >=2000 || abs(velocity.y)  >=2000:
		destruction_area.monitoring = true
		print("x: " + str(velocity.x))
		print("y: " + str(velocity.y))
		for body in destruction_area.get_overlapping_bodies():
			if body in destructibles:
				call_deferred("calculate_destruction" , body , destruction_polygon)
			else:
				destruction_area.monitoring = false
	
func get_health():
	return (health_player / max_health) * 100

	
func get_mana():
	return (mana_player / max_mana) * 100
	
func fire():
	if projectile_scene != null && fire_available && mana_player > 0:
		var proj_instance = projectile_scene.instance()
		_play_animation("shoot")
		proj_instance.initialize(projectile_container, arm.get_node("ArmTip").global_position, target)
		fire_available = false
		mana_player -= energy_power_penalty
		emit_signal("mana_changed",get_mana(),id)
		countdown_timer.start()

#NEW

func handle_fire():
	if Input.is_action_pressed("fire_cannon" + str(id)):
		if (mana_player > 0):
			fire()
			if mana_player < 0:
				mana_player = 0

func handle_hit():
	if Input.is_action_just_pressed("hit_enemy" + str(id)):
		_play_animation("hit")
		hit()
	if Input.is_action_just_released("hit_enemy" + str(id)):
		$Enemy_Detection_Area.monitoring = false

func handle_charge_jump(delta):
	var jump: bool = Input.is_action_just_pressed('jump' + str(id))
	var on_floor: bool = is_on_floor()
	
	if Input.is_action_pressed("jump" + str(id)):
		jump_pressed_time += delta
		
		if jump_pressed_time >= JUMP_CHARGE_TIME && on_floor:
			jump_force_charged = JUMP_CHARGE_FORCE
			jump_count=2
			_play_animation("chargejump", false)
			
		elif jump_pressed_time < JUMP_CHARGE_TIME && jump_pressed_time > 0.1:
			_play_animation("jumpcharge", false)
			jump_force_charged = JUMP_CHARGE_FORCE / 2
			

func handle_jump():
	
	var on_floor: bool = is_on_floor()

	if Input.is_action_just_released("jump" + str(id)) && jump_count > 0:
				if !on_floor && jump_count == 1 && velocity.y > 0:
					velocity.y = 0
					jump_force_charged = JUMP_CHARGE_FORCE / 2
				if !on_floor && jump_count == 1 && velocity.y < 0 && velocity.y >= -500:
					print("poderoso")
					velocity.y = 0
					jump_force_charged = JUMP_CHARGE_FORCE + 400
				if !on_floor && jump_count == 1 && velocity.y < 0 && velocity.y < -200:
					print("no tanto")
					velocity.y = 0
					jump_force_charged = JUMP_CHARGE_FORCE
				velocity.y -= JUMP_SPEED + jump_force_charged
				jump_count -= 1


func dash(valor):
		mana_player -= 100
		global_position.x += valor
		if mana_player < 0:
			mana_player = 0
		emit_signal("mana_changed",get_mana(),id)
		

	
func get_current_action_name():
	var actions = InputMap.get_actions()
	for action in actions:
		if Input.is_action_pressed(action) && "move" in action:
			return action

func hit():
	$Enemy_Detection_Area.monitoring = true
	
func notify_hit(dmg , knockback , power) -> void:
	emit_signal("hit" , dmg , knockback,  power)
	
	
func _handle_hit(dmg :int):
	health_player = health_player - dmg
	emit_signal("health_changed",(health_player / max_health) * 100,id)
	if (health_player <= 0):
		emit_signal("player_die",id)
		

func _play_animation(animation_name:String, should_restart:bool = true, playback_speed:float = 1.0):
	if anim_player.has_animation(animation_name):
		if should_restart:
			anim_player.stop()
		anim_player.playback_speed = playback_speed
		anim_player.advance(0)
		anim_player.play(animation_name)


func _on_DashTimer_timeout():
	can_dash = false
	
func _on_Enemy_Detection_Area_body_entered(body : Player):
	var y_hit = velocity.y
	if velocity.y <=  0:
		y_hit = -velocity.y
	if body != null:
		body.notify_hit(25 , global_position.direction_to(body.global_position) , hit_force + y_hit + 500)

func _on_CountdownTimer_timeout():
	fire_available = true

func play_audio(audio):
	audio_player.stream = audio
	audio_player.play()
