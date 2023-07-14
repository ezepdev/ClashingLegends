extends "res://AbstractState.gd"

var doble_jump
var land_sound = load("res://audio/land2.wav")
var jump_sound = load("res://audio/jump (2).wav")
func enter(value = null , value2 = null) -> void:
	character.audio_player.stream = jump_sound
	character.audio_player.play()
	character.snap_vector = Vector2.ZERO
	character._play_animation("jump")
	doble_jump = 1
	if character.jump_count == 2:
		character.energy.visible = true
	

func exit() -> void:
	character.snap_vector = character.SNAP_DIRECTION * character.SNAP_LENGHT
	character.jump_count = 1
	character.jump_pressed_time = 0
	character.jump_force_charged = 0
	character.energy.visible = false


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump" + str(character.id)) && character.jump_count == 1:
		character.audio_player.stream = jump_sound
		character.audio_player.play()
		if character.move_direction != 0:
			character._play_animation("fly")
		elif doble_jump == 1:
			doble_jump = 0 
			character._play_animation("jump" , false)
	elif event is InputEventKey: 
		if event.is_action_pressed("move_left" + str(character.id)) || event.is_action_pressed("move_right" + str(character.id)):
			if character.handle_dash():
				emit_signal("finished", "dash")
	elif event is InputEventJoypadButton:
		if character.handle_dash_joystick():
			if event.is_action_pressed("joystick_dash" + str(character.id)):
				emit_signal("finished" , "dash")


func update(delta:float) -> void:
	if character.jump_count == 0:
		character.energy.visible = false
	character.handle_movement()
	character.apply_speed_limit()
	character.handle_jump()
	character._apply_movement()
	character.handle_hit()
	character.handle_fire()
	character._handle_constant_energy()
	if character.move_direction == 0:
		character._handle_deacceleration()
	if character.is_on_floor():
		character.audio_player.stream = land_sound
		character.audio_player.play()
		if character.move_direction == 0:
			emit_signal("finished", "idle")
		else:
			emit_signal("finished", "walk")


func handle_event(event: String, value = null) -> void:
		match event:
			"hit":
				character._handle_hit(value[0])
				emit_signal("finished", "knockback" , value[1], value[2])
