extends "res://AbstractState.gd"

func enter(value = null , value2 = null) -> void:
	character._play_animation("energy")

# Clean up the state. Reinitialize values like a timer
func exit() -> void:
	return


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump" + str(character.id)):
		emit_signal("finished","jump")
	if event.is_action_released("charge_mana" + str(character.id)):
		emit_signal("finished" , "idle")


func update(delta:float) -> void:
	character.handle_movement()
	character.handle_energy_charge()
	if character.move_direction != 0:
		emit_signal("finished" , "walk")
	else:
		character._handle_deacceleration()
		character.apply_speed_limit()
		character._apply_movement()


func _on_animation_finished(anim_name: String) -> void:
	return


func handle_event(event: String, value = null) -> void:
	return
