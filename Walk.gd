extends "res://AbstractState.gd"

func enter(value = null, value2 = null)  -> void:
	character._play_animation("move")

# Clean up the state. Reinitialize values like a timer
func exit() -> void:
	return


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump" + str(character.id)):
		emit_signal("finished","jump")



func update(delta:float) -> void:
	character.handle_movement()
	character.apply_speed_limit()
	character._apply_movement()
	character.handle_charge_jump(delta)
	character.handle_hit()
	character.handle_fire()
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
