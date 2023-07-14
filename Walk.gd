extends "res://AbstractState.gd"

func enter(value = null, value2 = null)  -> void:
	character._play_animation("move")

# Clean up the state. Reinitialize values like a timer
func exit() -> void:
	return


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump" + str(character.id)):
		emit_signal("finished","jump")
	elif event is InputEventKey: 
		if event.is_action_pressed("move_left" + str(character.id)) || event.is_action_pressed("move_right" + str(character.id)):
			if character.handle_dash():
				emit_signal("finished", "dash")
	elif event is InputEventJoypadButton:
		if character.handle_dash_joystick():
			if event.is_action_pressed("joystick_dash" + str(character.id)):
				emit_signal("finished" , "dash")



func update(delta:float) -> void:
	character.handle_movement()
	character.apply_speed_limit()
	character._apply_movement()
	character.handle_charge_jump(delta)
	character.handle_hit()
	character.handle_fire()
	character._handle_constant_energy()
	if character.is_on_floor() && character.anim_player.get_current_animation() != "chargejump":
		character.energy.visible = false
	if character.move_direction == 0:
		emit_signal("finished", "idle")
	else:
		if character.is_on_floor():
			character._play_animation("walk")
			

func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value[0])
			emit_signal("finished", "knockback" , value[1] , value[2])
