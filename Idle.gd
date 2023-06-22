extends "res://AbstractState.gd"


func enter(value = null) -> void:
	character._play_animation("idle")

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump" + str(character.id)):
		emit_signal("finished","jump")
	if event.is_action_pressed("fire_cannon" + str(character.id)):
		emit_signal("finished" , "shoot")
	if event.is_action_pressed("hit_enemy" + str(character.id)):
		emit_signal("finished" , "attack")

func update(delta:float) -> void:
	character.handle_movement()
	character.handle_charge_jump(delta)
	if character.move_direction != 0:
		emit_signal("finished" , "walk")
	else:
		character._handle_deacceleration()
		character.apply_speed_limit()
		character._apply_movement()
		if character.is_on_floor():
			character._play_animation("idle")
		else:
			character._play_animation("jump")

func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character.handle_hit(value[0])
			emit_signal("finished", "knockback" , value[1])
