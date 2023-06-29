extends "res://AbstractState.gd"

var doble_jump

func enter(value = null) -> void:
	character.snap_vector = Vector2.ZERO
	character._play_animation("jump")
	doble_jump = 1

func exit() -> void:
	character.snap_vector = character.SNAP_DIRECTION * character.SNAP_LENGHT
	character.jump_count = 1
	character.jump_pressed_time = 0
	character.jump_force_charged = 0


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire_cannon" + str(character.id)):
		character.fire()
	if event.is_action_pressed("jump" + str(character.id)) && character.jump_count == 1:
		if character.move_direction != 0:
			character._play_animation("fly")
		elif doble_jump == 1:
			doble_jump = 0 
			character._play_animation("jump" , false)


func update(delta:float) -> void:
	character.handle_jump()
	character.handle_movement()
	character.apply_speed_limit()
	character._apply_movement()
	character.handle_hit()
	if character.move_direction == 0:
		character._handle_deacceleration()
	if character.is_on_floor():
		if character.move_direction == 0:
			emit_signal("finished", "idle")
		else:
			emit_signal("finished", "walk")


func handle_event(event: String, value = null) -> void:
		match event:
			"hit":
				character.handle_hit(value[0])
				emit_signal("finished", "knockback" , value[1])
