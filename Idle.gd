extends "res://AbstractState.gd"


func enter(value = null) -> void:
	character._play_animation("idle")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire_cannon" + str(character.id)):
		character.fire()
	if event.is_action_released("jump" + str(character.id)):
		emit_signal("finished","jump")
	elif character.is_on_floor() && event.is_action_pressed("charge_mana" + str(character.id)):
		emit_signal("finished" , "charge")
	elif event.is_action_pressed("move_left" + str(character.id)) || event.is_action_pressed("move_right" + str(character.id)):
		if character.handle_dash():
			emit_signal("finished", "dash")


func update(delta:float) -> void:
	character.handle_movement()
	character.handle_charge_jump(delta)
	character.handle_hit()
	if character.move_direction != 0:
		emit_signal("finished" , "walk")
	else:
		character._handle_deacceleration()
		character.apply_speed_limit()
		character._apply_movement()
		if character.is_on_floor() && character.anim_player.get_current_animation() != "hit" && character.anim_player.get_current_animation() != "shoot"  && character.anim_player.get_current_animation() != "energy"  && character.anim_player.get_current_animation() != "chargejump":
			character._play_animation("idle")
		elif !character.is_on_floor():
			character._play_animation("jump")

func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value[0])
			emit_signal("finished", "knockback" , value[1])
